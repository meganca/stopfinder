class BusstopsController < ApplicationController
  respond_to :json
  StopData = Struct.new(:value, :needsValidation)
  @@votingMajority = 0.75
  @@validationMinimum = 3
  
  def show
    ids = (params[:id]).split(/[_?=&]/)
    agencyid = ids[0]
    stopid = ids[1]
    @busstop = BusStop.new(StopId: stopid)
    
    session[:agency_id] = agencyid
    session[:stop_id] = stopid
    
    #OBA API call; store any desired variables into session from this
    queryOBA()
    
    showLog = BusStop.usageLogger
    showLog.info("Viewing stop #{agencyid}_#{stopid} at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Accessed by user #{session[:device_id]}")
    elsif(params[:userid])
      session[:device_id] = params[:userid]
      showLog.info("Accessed by user #{params[:userid]}")
    end

    if(cookies[:user_email])
      showLog.info("User logged in as #{cookies[:user_email]}")
    end
    
    showLog.info("")
    
    # Get the array w/ all results
    stopdata = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = \"" + stopid + "\" AND agencyid = \"" + agencyid + "\"")
    officialstop = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = \""+stopid+"\" AND userid = 0 AND agencyid = \"" + agencyid + "\"")
    
    if(stopdata.empty?)
      showLog.info("Stop #{agencyid}_#{stopid} at #{Time.now} not found in database")
      showLog.info("")
      redirect_to '/about/missing' and return
    end
    
    # Get the comment
    if (Comment.find_by_agency_id_and_stop_id(agencyid, stopid) == nil)
      session[:comment] = ""
    else
      session[:comment] = Comment.find_by_agency_id_and_stop_id(agencyid, stopid).info
    end
    
    # Get array for closures
    closuredata = Closure.find_by_sql("SELECT * FROM " + Closure.table_name + " WHERE stopid = " + stopid + " AND agencyid = " + agencyid + " AND StartDate < UTC_TIMESTAMP() AND EndDate > UTC_TIMESTAMP() ORDER BY DateCreated DESC")
    
    # These fields use both Metro and crowdsourced data; because of this they must be 
    # 'manually' tallied to allow converting from Metro's categories to ours
    intersections = Hash.new
    BusStop.STOPPOSITIONVALUES_CONST.each {|x| intersections[x] = 0 }
    
    signs = Hash.new
    BusStop.SIGNTYPEVALUES_CONST.each {|x| signs[x] = 0 }

    schedules = Hash.new
    BusStop.SCHEDULEVALUES_CONST.each {|x| schedules[x] = 0 }
    
    shelterCount = Hash.new
    BusStop.SHELTERCOUNTVALUES_CONST.each {|x| shelterCount[x] = 0 }
    
    stopdata.each do |stop|
      int = BusStop.stopPosition(stop.Intersection)
      intersections[int] = intersections[int] + 1

      stype = BusStop.signType(stop.RteSignType)
      signs[stype] = signs[stype] + 1

      htype = BusStop.scheduleType(stop.SchedHolder)
      schedules[htype] = schedules[htype] + 1
	  
      shelterCountCount = BusStop.shelterCount(stop.Shelters)
      shelterCount[shelterCountCount] = shelterCount[shelterCountCount] + 1
    end
    
    # Clear out any counts of "no opinion"
    intersections.delete("unknown")
    signs.delete("unknown")
    schedules.delete("unknown")
    shelterCount.delete("unknown")
    
    calculateInfo(signs, :sign_type)
    calculateInfo(intersections, :intersection_pos)
    calculateInfo(schedules, :sched_holder)
    calculateInfo(shelterCount, :shelter_count)
    
    # These fields are uniquely ours and therefore only need queries
    queryCalculate('InsetFromCurb', :sign_inset)
    queryCalculate('BenchCount', :bench_count)
    queryCalculate('ShelterOffset', :shelter_offset)
    queryCalculate('ShelterOrientation', :shelter_orientation)
    queryCalculate('HasCan', :can_count)
    queryCalculate('LightingConditions', :lighting)
    
    closedStatus = Closure.closureStatus(closuredata)
    session[:closure] = {}
    session[:closure][:status] = closedStatus[0]
    session[:closure][:reported] = closedStatus[1]
    session[:closure][:enddate] = closedStatus[2]

    # Information we ONLY get from Metro
    session[:stop_name] = officialstop[0].StopName
    session[:intersection_distance] = officialstop[0].FromCrossCurb   
  end

  def queryCalculate(fieldName, infoSymbol)
    session[infoSymbol] = {}
    
    submissionTotal = BusStop.count_by_sql("SELECT COUNT(*) FROM " + BusStop.table_name + " WHERE stopid = \"" + session[:stop_id] + "\" AND agencyid = \"" + session[:agency_id] + "\" AND " + fieldName + " != \"unknown\" AND userid != \"0\"")
    if (submissionTotal == 0)
      session[infoSymbol][:value] = "unknown"
      session[infoSymbol][:needs_verification] = "false"
      return
    end
    
    # If there are votes, calculate accordingly
    majorityVote = BusStop.find_by_sql("SELECT " + fieldName + ", COUNT(*) AS SUM FROM " + BusStop.table_name + " WHERE stopid = \"" + session[:stop_id] + "\" AND agencyid = \"" + session[:agency_id] + "\" AND " + fieldName + " != \"unknown\" AND userid != \"0\" GROUP BY " + fieldName + " order by SUM desc")
    votedField = majorityVote[0][fieldName].to_s
    majorityCount = BusStop.count(fieldName, :conditions => "stopid = \"" + session[:stop_id] + "\" AND agencyid = \"" + session[:agency_id] + "\" AND " + fieldName + " = \"" + votedField + "\" AND userid != \"0\"")
    session[infoSymbol][:value] = votedField
    
    if (((majorityCount * 1.0 / submissionTotal) > @@votingMajority) && submissionTotal >= @@validationMinimum)
      session[infoSymbol][:needs_verification] = "false"
    else
      session[infoSymbol][:needs_verification] = "true"
    end
  end
  
  def calculateInfo(votingHash, infoSymbol)
    if votingHash.empty? == false     
      majorityValue = votingHash.max_by{|k,v| v}[0]
      count = votingHash.values.inject(0) {|sum,x| sum + x}
      session[infoSymbol] = {}
	  
      if (count == 0)
        session[infoSymbol][:value] = "unknown"
      else
        if (((votingHash[majorityValue] * 1.0 / count) > @@votingMajority) && votingHash[majorityValue] >= @@validationMinimum)
          session[infoSymbol][:value] = majorityValue
          session[infoSymbol][:needs_verification] = "false"
        else
          session[infoSymbol][:value] = majorityValue
          session[infoSymbol][:needs_verification] = "true"
        end
      end
    else
      session[infoSymbol][value] = "unknown"
    end
  end
  
  def queryOBA
    apiURI = "http://api.pugetsound.onebusaway.org/api/where/stop/" + params[:id] + ".json?key=TEST"
    response = Net::HTTP.get_response(URI.parse(apiURI))
    data = response.body
    
    begin
      response = Net::HTTP.get_response(URI.parse(apiURI))
      data = response.body
      hash = JSON.parse(data)
      session[:direction] = hash["data"]["entry"]["direction"]
    rescue
      retry
    end
  end
  
  def update
    ids = (params[:id]).split(/[_&=]/)
    agencyid = ids[0]
    stopid = ids[1]
    session[:update_type] = "new"
    
    if(cookies[:user_id])
      @stopcheck = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = \"" + session[:stop_id] + "\" AND agencyid = \"" + session[:agency_id] + "\" AND userid = \"" + cookies[:user_id] + "\" ORDER BY DateCreated DESC")
      
      # Were there any submissions?
      if(@stopcheck.any?)
        date = DateTime.parse(@stopcheck[0].DateCreated.to_s)
        limit = DateTime.now - 24.hours
        
        if(limit < date)
          session[:update_type] = "edit"
          loadPriorSubmission(@stopcheck[0])
          redirect_to duplicateentry_url(:id => session[:agency_id] + "_" + session[:stop_id]) and return
        end
      end
    end 
    
    showLog = BusStop.usageLogger
    showLog.info("Viewing update/verify form for #{agencyid}_#{stopid} at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Accessed by user #{session[:device_id]}")
    end

    if(cookies[:user_email])
      showLog.info("User logged in as #{cookies[:user_email]}")
    end
    
    showLog.info("")
  end
  
  def edit
  end
  
  def loadPriorSubmission(submission)
    session[:intersection_pos_edit] = submission.Intersection
    session[:sign_type_edit] = submission.RteSignType
    session[:sign_inset_edit] = submission.InsetFromCurb
    session[:sched_holder_edit] = submission.SchedHolder
    session[:shelter_count_edit] = submission.Shelters
    session[:shelter_offset_edit] = submission.ShelterOffset
    session[:shelter_orientation_edit] = submission.ShelterOrientation
    session[:bench_count_edit] = submission.BenchCount
    session[:can_count_edit] = submission.HasCan
    session[:lighting_edit] = submission.LightingConditions
  end
  
  def checkVerifiedForSave(stop)    
    if (session[:intersection_pos][:needs_verification] == "false" && session[:intersection_pos][:value] == stop.Intersection)
      stop.Intersection = "unknown"
    end
      
    if (session[:sign_type][:needs_verification] == "false" && session[:sign_type][:value] == stop.RteSignType)
      stop.RteSignType = "unknown"
    end
      
    if (session[:sign_inset][:needs_verification] == "false" && session[:sign_inset][:value] == stop.InsetFromCurb)
      stop.InsetFromCurb = "unknown"
    end
      
    if (session[:sched_holder][:needs_verification] == "false" && session[:sched_holder][:value] == stop.SchedHolder)
      stop.SchedHolder = "unknown"
    end
    
    if (session[:shelter_count][:needs_verification] == "false" && session[:shelter_count][:value] == stop.Shelters)
      stop.Shelters = "unknown"
    end
      
    if (session[:bench_count][:needs_verification] == "false" && session[:bench_count][:value] == stop.BenchCount)
      stop.BenchCount = "unknown"
    end
      
    if (session[:can_count][:needs_verification] == "false" && session[:can_count][:value] == stop.HasCan)
      stop.HasCan = "unknown"
    end
    
    if (session[:shelter_offset][:needs_verification] == "false" && session[:shelter_offset][:value] == stop.ShelterOffset)
      stop.ShelterOffset = "unknown"
    end
    
    if (session[:shelter_orientation][:needs_verification] == "false" && session[:shelter_orientation][:value] == stop.ShelterOrientation)
      stop.ShelterOrientation = "unknown"
    end
    
    if (session[:lighting][:needs_verification] == "false" && session[:lighting][:value] == stop.LightingConditions)
      stop.LightingConditions = "unknown"
    end
  end

  def create
    # Do this check on ID too, not just logged in users!!
    if(session[:update_type] == "edit" )
      @stopcheck = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = \"" + session[:stop_id] + "\" AND agencyid = \"" + session[:agency_id] + "\" AND userid = \"" + cookies[:user_id] + "\" ORDER BY DateCreated DESC")
      
      # Not a bad place to add it to their tally, either
      priorSubmission = BusStop.find_by_inputid(@stopcheck[0].InputId)
      priorSubmission(params[:busstop])
      checkVerifiedForSave(priorSubmission)
      priorSubmission.save
      redirect_to duplicateentry_url(:id => params[:busstop][:AgencyId] + "_" + params[:busstop][:StopId]) and return
    end 
    
    @busstop = BusStop.new(params[:busstop])
    checkVerifiedForSave(@busstop)
    @busstop.save
    
    @log = Log.new
    @log.input_id = @busstop.InputId
    Log.updateAttributes(@log, session)
    @log.save
    
    showLog = BusStop.usageLogger
    showLog.info("Submitted stop info for #{params[:busstop][:AgencyId]}_#{params[:busstop][:StopId]} at #{Time.now}")
    
    if(session[:device_id])
      showLog.info("Submitted by user #{session[:device_id]}")
    end

    if(cookies[:user_email])
      showLog.info("User logged in as #{cookies[:user_email]}")
    end
    
    showLog.info("")
    
    # Don't overwrite our comment with null for not logged in users
    if(cookies[:user_email])
      Comment.add_or_edit(@busstop.AgencyId, @busstop.StopId, @busstop.StopComment)
    end
    
    redirect_to dataentry_url(:id => params[:busstop][:AgencyId] + "_" + params[:busstop][:StopId])
  end

end