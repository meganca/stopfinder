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
    
    showLog = BusStop.usageLogger
    showLog.info("Viewing stop #{agencyid}_#{stopid} at #{Time.now}")
    
    if(params[:userid])
      session[:device_id] = params[:userid]
      showLog.info("Accessed by user #{params[:userid]}")
    elsif(session[:device_id] == nil)
      session[:device_id] = ""
    elsif(session[:device_id] != "")
      showLog.info("Accessed by user #{session[:device_id]}")
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
    
    #OBA API call; store any desired variables into session from this
    queryOBA(agencyid, stopid)
    
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
    BusStop.getFieldValues("stop position").each {|x| intersections[x] = 0 }
    
    signs = Hash.new
    BusStop.getFieldValues("sign type").each {|x| signs[x] = 0 }

    schedules = Hash.new
    BusStop.getFieldValues("schedule type").each {|x| schedules[x] = 0 }
    
    shelterCount = Hash.new
    BusStop.getFieldValues("shelter count").each {|x| shelterCount[x] = 0 }
    
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
  
  def queryOBA(agencyid, stopid)
    apiURI = "http://api.pugetsound.onebusaway.org/api/where/stop/" + agencyid + "_" + stopid + ".json?key=693c0a55-9ef0-4302-8bc3-f9b2db93e124"

    begin
      response = Net::HTTP.get_response(URI.parse(apiURI))
      data = response.body
      hash = JSON.parse(data)
      session[:direction] = hash["data"]["entry"]["direction"]
    rescue
      retry
      #session[:direction] = "E"
    end
  end
  
  def rateLimitRedirect(checkArray)
    # Were there any submissions?
    if(checkArray.any?)
      date = DateTime.parse(checkArray[0].DateCreated.to_s)
      limit = DateTime.now - 24.hours
      
      if(limit < date)
        session[:update_type] = "edit"
        session[:submission_id] = checkArray[0].InputId
        loadPriorSubmission(checkArray[0])
        redirect_to duplicateentry_url(:id => session[:agency_id] + "_" + session[:stop_id])
        return true
      end
    end
  end
  
  def update
    ids = (params[:id]).split(/[_&=]/)
    agencyid = ids[0]
    stopid = ids[1]
    session[:update_type] = "new"
    
    if(cookies[:user_id])
      stopcheck = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = \"" + session[:stop_id] + "\" AND agencyid = \"" + session[:agency_id] + "\" AND userid = \"" + cookies[:user_id] + "\" ORDER BY DateCreated DESC")
      redirected = rateLimitRedirect(stopcheck)
    end   
    
    # Have to check for device id; might be side effects for multiple users on one device, but
    # atm that is an outlier and should not be counted.
    if(session[:device_id] && !redirected)
      stopcheck = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = \"" + session[:stop_id] + "\" AND agencyid = \"" + session[:agency_id] + "\" AND OBAId = \"" + session[:device_id] + "\" ORDER BY DateCreated DESC")
      redirected = rateLimitRedirect(stopcheck)
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
    if submission.ShelterOffset == nil
      session[:shelter_offset_edit] = "unknown"
    else
      session[:shelter_offset_edit] = submission.ShelterOffset
    end
    
    if submission.ShelterOrientation == nil
      session[:shelter_orientation_edit] = "unknown"
    else
      session[:shelter_orientation_edit] = submission.ShelterOrientation
    end
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

  def updatePrior(record)
    record.LastEdited = DateTime.now
    record.Intersection = params[:busstop][:Intersection]
    record.RteSignType = params[:busstop][:RteSignType]
    record.InsetFromCurb = params[:busstop][:InsetFromCurb]
    record.SchedHolder = params[:busstop][:SchedHolder]
    record.Shelters = params[:busstop][:Shelters]
    record.ShelterOffset = params[:busstop][:ShelterOffset]
    record.ShelterOrientation = params[:busstop][:ShelterOrientation]
    record.BenchCount = params[:busstop][:BenchCount]
    record.HasCan = params[:busstop][:HasCan]
    record.LightingConditions = params[:busstop][:LightingConditions]
  end
  
  def updateUserAccuracy(priorStops, currentStop)
    priorStops.each do |stop|
      currentUser = User.find_by_id(stop.UserId)
       
      #Check if each field agrees/disagrees with this submission
      if ((currentStop.Intersection != "unknown") && stop.Intersection != "unknown")
        currentUser.otherTotalVotes = currentUser.otherTotalVotes + 1
        if (stop.Intersection == currentStop.Intersection)
          currentUser.otherVerifyingVotes = currentUser.otherVerifyingVotes + 1
        end
      end
      if ((currentStop.RteSignType != "unknown") && stop.RteSignType != "unknown")
        currentUser.otherTotalVotes = currentUser.otherTotalVotes + 1
        if (stop.RteSignType == currentStop.RteSignType)
          currentUser.otherVerifyingVotes = currentUser.otherVerifyingVotes + 1
        end
      end
      if ((currentStop.InsetFromCurb != "unknown") && stop.InsetFromCurb != "unknown")
        currentUser.otherTotalVotes = currentUser.otherTotalVotes + 1
        if (stop.InsetFromCurb == currentStop.InsetFromCurb)
          currentUser.otherVerifyingVotes = currentUser.otherVerifyingVotes + 1
        end
      end
      if ((currentStop.SchedHolder != "unknown") && stop.SchedHolder != "unknown")
        currentUser.otherTotalVotes = currentUser.otherTotalVotes + 1
        if (stop.SchedHolder == currentStop.SchedHolder)
          currentUser.otherVerifyingVotes = currentUser.otherVerifyingVotes + 1
        end
      end
      if ((currentStop.Shelters != "unknown") && stop.Shelters != "unknown")
        currentUser.otherTotalVotes = currentUser.otherTotalVotes + 1
        if (stop.Shelters == currentStop.Shelters)
          currentUser.otherVerifyingVotes = currentUser.otherVerifyingVotes + 1
        end
      end
      if ((currentStop.ShelterOffset != nil) && (stop.ShelterOffset != nil) && (currentStop.ShelterOffset != "unknown") && stop.ShelterOffset != "unknown")
        currentUser.otherTotalVotes = currentUser.otherTotalVotes + 1
        if (stop.ShelterOffset == currentStop.Intersection)
          currentUser.otherVerifyingVotes = currentUser.otherVerifyingVotes + 1
        end
      end
      if ((currentStop.ShelterOrientation != nil) && (stop.ShelterOrientation != nil) && (currentStop.ShelterOrientation != "unknown") && stop.ShelterOrientation != "unknown")
        currentUser.otherTotalVotes = currentUser.otherTotalVotes + 1
        if (stop.ShelterOrientation == currentStop.ShelterOrientation)
          currentUser.otherVerifyingVotes = currentUser.otherVerifyingVotes + 1
        end
      end
      if ((currentStop.BenchCount != "unknown") && stop.BenchCount != "unknown")
        currentUser.otherTotalVotes = currentUser.otherTotalVotes + 1
        if (stop.BenchCount == currentStop.BenchCount)
          currentUser.otherVerifyingVotes = currentUser.otherVerifyingVotes + 1
        end
      end
      if ((currentStop.HasCan != "unknown") && stop.HasCan != "unknown")
        currentUser.otherTotalVotes = currentUser.otherTotalVotes + 1
        if (stop.HasCan == currentStop.HasCan)
          currentUser.otherVerifyingVotes = currentUser.otherVerifyingVotes + 1
        end
      end
      if ((currentStop.LightingConditions != "unknown") && stop.LightingConditions != "unknown")
        currentUser.otherTotalVotes = currentUser.otherTotalVotes + 1
        if (stop.LightingConditions == currentStop.LightingConditions)
          currentUser.otherVerifyingVotes = currentUser.otherVerifyingVotes + 1
        end
      end
      
      currentUser.accuracy = (currentUser.otherVerifyingVotes * 1.0) / currentUser.otherTotalVotes
      printf("Current accuracy: " + currentUser.accuracy.to_s)
      #Check for accuracy badge
      if (currentUser.accuracy >= 0.95)
      	if(!currentUser.badges.include? "003")
      		currentUser.badges = currentUser.badges + "003"
      		flash[:notice] = "Congratulations! You have earned the badge 'Honor Roll'!"
	  	end
	  else
	  	if(currentUser.badges.include "003")
	  		currentUser.badges.slice! "003"
	  	end
	  end
      currentUser.save
    end
  end
  
  def create
  
  	user = User.find_by_id(cookies[:user_id])
    
    #Check to see if they are the original submitter for each field
    if(user != nil)
      if(user.newInfoSubmitted == nil)
        user.newInfoSubmitted = 0
      end
      
      if(user.badges == nil)
        user.badges = ""
      end
      
      if(session[:sign_type][:value].eql? "unknown" && !(params[:busstop][:RteSignType].eql? "unknown"))
      	user.points = user.points + 1
      	user.newInfoSubmitted = user.newInfoSubmitted + 1
      end
      if (session[:intersection_pos][:value]=="unknown" && !(params[:busstop][:Intersection].eql? "unknown"))
          user.points = user.points + 1
          user.newInfoSubmitted = user.newInfoSubmitted + 1
      end
      if (session[:sign_inset][:value]=="unknown" && !(params[:busstop][:InsetFromCurb].eql? "unknown"))
          user.points = user.points + 1
          user.newInfoSubmitted = user.newInfoSubmitted + 1
      end
      if (session[:sched_holder][:value]=="unknown" && !(params[:busstop][:SchedHolder].eql? "unknown"))
          user.points = user.points + 1
          user.newInfoSubmitted = user.newInfoSubmitted + 1
      end
      if (session[:shelter_count][:value]=="unknown" && !(params[:busstop][:Shelters].eql? "unknown"))
          user.points = user.points + 1
          user.newInfoSubmitted = user.newInfoSubmitted + 1
      end
      if (session[:shelter_offset][:value]=="unknown" && !(params[:busstop][:ShelterOffset].eql? "unknown") && !(params[:busstop][:ShelterOffset].eql? nil))
          user.points = user.points + 1
          user.newInfoSubmitted = user.newInfoSubmitted + 1
      end
      if (session[:shelter_orientation][:value]=="unknown" && !(params[:busstop][:ShelterOrientation].eql? "unknown") && !(params[:busstop][:ShelterOrientation].eql? nil))
          user.points = user.points + 1
          user.newInfoSubmitted = user.newInfoSubmitted + 1
      end
      if (session[:bench_count][:value]=="unknown" && !(params[:busstop][:BenchCount].eql? "unknown"))
          user.points = user.points + 1
          user.newInfoSubmitted = user.newInfoSubmitted + 1
      end
      if (session[:can_count][:value]=="unknown" && !(params[:busstop][:HasCan].eql? "unknown"))
          user.points = user.points + 1
          user.newInfoSubmitted = user.newInfoSubmitted + 1
      end
      if (session[:lighting][:value]=="unknown" && !(params[:busstop][:LightingConditions].eql? "unknown"))
          user.points = user.points + 1
          user.newInfoSubmitted = user.newInfoSubmitted + 1
      end
        
      if (user.newInfoSubmitted >= 50 && !(user.badges.include? "001"))
          user.badges = user.badges + "001"
          flash[:notice] = "Congratulations! You have earned the badge 'Information Catalyst'!"
      end
      
      # Check user ranking for badge (only applies to visible users)
	  if user.visible == 1
     	 userWithRank = User.find_by_sql("select t.id, (select count(*) from users x where x.visible=1 AND x.points > t.points) AS position from users t where t.id = " + cookies[:user_id])
      
      # Add 1 because this indexes from 0
      userRank = userWithRank[0].position + 1
      
     
      # Badgechecking things here
      	if (userRank <= 20)
      		if(!user.badges.include? "004")
      			user.badges = user.badges + "004"
      			flash[:notice] = "Congratulations! You are a Top Contributor!"
	  			end
	  	elsif (user.badges.include? "004")
	  			user.badges.slice! "004"
	  	end
	  end
      user.save
    end
    
    if(session[:update_type] == "edit" )
      priorSubmission = BusStop.find(session[:submission_id])
      updatePrior(priorSubmission)
      checkVerifiedForSave(priorSubmission)
      priorSubmission.save
      redirect_to dataentry_url(:id => params[:busstop][:AgencyId] + "_" + params[:busstop][:StopId]) and return
    end 
    
    @busstop = BusStop.new(params[:busstop])
    checkVerifiedForSave(@busstop)
    
    #At the moment, only calculate accuracy on first submit, not update
    if(cookies[:user_id] == nil)
      userId = ""
    else
      userId = cookies[:user_id]
    end
    queryString = "SELECT * FROM " + BusStop.table_name + " WHERE stopid = \"" + session[:stop_id] + "\" AND agencyid = \"" + session[:agency_id] + "\" AND OBAId != \"" + session[:device_id] + "\"  AND userid != \"" + userId + "\" AND userid !=\"\""
    priorStops = BusStop.find_by_sql(queryString)
    updateUserAccuracy(priorStops, @busstop)
 
    @busstop.save
    
    @log = Log.new
    @log.input_id = @busstop.InputId
    Log.updateAttributes(@log, session, cookies[:user_id])
    @log.save
    
    # If we haven't returned by now this is a new info submit, not an edit
    if(cookies[:user_id])
      uniqueStops = BusStop.count("StopId", :distinct => true, :conditions => "userid = \"" + cookies[:user_id].to_s + "\"" )
      if(user.stops == nil) # First recorded submission!
        user.points = 10
        user.stops = uniqueStops
        user.title = "01"
        flash[:notice] = "Congratulations! You have earned the title 'Contributor'!"
      elsif (user.stops < uniqueStops) # This is a new stop
        user.points = user.points + 10
        user.stops = uniqueStops
        if (uniqueStops > 4 && uniqueStops <=14)
        	if(user.title == "01")
        		user.title = "02"
				flash[:notice] = "Congratulations! You have earned the title 'Savvy Traveler'!"
			end
        elsif (uniqueStops > 14 && uniqueStops <=29)
        	if(user.title=="02")
        		user.title = "03"
        		flash[:notice] = "Congratulations! You have earned the title 'Stop Detective'!"
        	end
        elsif (uniqueStops > 29)
        	if(user.title=="03")
        		user.title = "04"
				flash[:notice] = "Congratulations! You have earned the title 'Transit Wizard'!"
			end
        end
      end
      user.save  
    end
   
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