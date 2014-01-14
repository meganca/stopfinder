class BusstopsController < ApplicationController
  StopData = Struct.new(:value, :needsValidation)
  @@votingMajority = 0.75
  @@closureMinimum = 1
  
  def show
    cookies[:stopid] = params[:id]
    
    ids = (params[:id]).split("_")
    agencyid = ids[0]
    stopid = ids[1]
    @busstop = BusStop.new(StopId: stopid)
    
    # Get the device for display purposes
    checkDevice()
	
    # Track votes and what we have/don't have
    @busstopAttributes = Hash.new
    @validate = Array.new
    @add = Array.new

    # Get the array w/ all results
    stopdata = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = " + stopid + " AND agencyid = " + agencyid)
    officialstop = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = "+stopid+" AND userid = 0 AND agencyid = " + agencyid)
	
    directions = Hash.new
    BusStop.directionValues.each {|x| directions[x] = 0 }
	
    intersections = Hash.new
    BusStop.intersectionPositionValues.each {|x| intersections[x] = 0 }
    
    signs = Hash.new
    BusStop.signTypeValues.each {|x| signs[x] = 0 }

    schedules = Hash.new
    BusStop.scheduleTypeValues.each {|x| schedules[x] = 0 }
    
    insets = Hash.new
    BusStop.curbInsetValues.each {|x| insets[x] = 0 }

    benches = Hash.new
    BusStop.benchCountValues.each {|x| benches[x] = 0 }
	
    shelters = Hash.new
    BusStop.shelterCountValues.each {|x| shelters[x] = 0 }
	
    cans = Hash.new
    BusStop.trashCanValues.each {|x| cans[x] = 0 }
    
    closedvotes = Hash.new
    closedvotes["true"] = 0
    closedvotes["false"] = 0

    stopdata.each do |stop|
      dir = BusStop.directionName(stop.BearingCode)
      directions[dir] = directions[dir] + 1

      int = BusStop.intersectionPosition(stop.Intersection)
      intersections[int] = intersections[int] + 1

      stype = BusStop.signType(stop.RteSignType)
      signs[stype] = signs[stype] + 1

      htype = BusStop.scheduleType(stop.SchedHolder)
      schedules[htype] = schedules[htype] + 1

      itype = BusStop.curbInset(stop.InsetFromCurb)
      insets[itype] = insets[itype] + 1
	  
      benchcount = BusStop.benchCount(stop.BenchCount)
      benches[benchcount] = benches[benchcount] + 1
	  
      sheltercount = BusStop.shelterCount(stop.Shelters)
      shelters[sheltercount] = shelters[sheltercount] + 1
	  
      cancount = BusStop.trashCan(stop.HasCan)
      cans[cancount] = cans[cancount] + 1
      
      closed = BusStop.isClosed(stop.ClosureType, stop.ClosurePermanent, stop.ClosureStartdate, stop.ClosureEnddate)
      closedvotes[closed] = closedvotes[closed] + 1
	  
    end

    # Clear out any counts of "no opinion"
    directions.delete("unknown")
    intersections.delete("unknown")
    signs.delete("unknown")
    schedules.delete("unknown")
    insets.delete("unknown")
    benches.delete("unknown")
    shelters.delete("unknown")
    cans.delete("unknown")
    
    # If the stop isn't closed, ignore; we don't need to do anything
    # This is something where we don't want majority vote, just count
    closedvotes.delete("false")
    if (closedvotes["true"] >= @@closureMinimum)
      @busstopAttributes[:stop_closed] = StopData.new("true", "false")
    else
      @busstopAttributes[:stop_closed] = StopData.new("false", "false")
    end

    # Information we ONLY get from Metro
    @busstopAttributes[:stop_name] = StopData.new(officialstop[0].StopName, "false")
    @busstopAttributes[:intersection_distance] = StopData.new(officialstop[0].FromCrossCurb, "false")
    @busstopAttributes[:is_tunnel_stop] = StopData.new(BusStop.isTunnelStop(officialstop[0].RteSignType), "false")
    
    # Calculate things that we collect dynamically
    calculateInfo(directions, :bearing_code)
    calculateInfo(signs, :sign_type)
    calculateInfo(intersections, :intersection_pos)
    calculateInfo(schedules, :sched_holder)
    calculateInfo(insets, :curb_inset)
    calculateInfo(shelters, :shelter_count)
    calculateInfo(benches, :bench_count)
    calculateInfo(cans, :can_count)
	
	cookies[:validate] = @validate
	cookies[:add] = @add
  end

  def calculateInfo(votingHash, infoSymbol)
    if votingHash.empty? == false     
      majorityValue = votingHash.max_by{|k,v| v}[0]
      count = votingHash.values.inject(0) {|sum,x| sum + x}
      
      if (count == 0)
        @busstopAttributes[infoSymbol] = StopData.new("unknown", "true")
        @add.push(infoSymbol)
      else
        @validate.push(infoSymbol)
        
        if ((votingHash[majorityValue] * 1.0 / count) >= @@votingMajority)
          @busstopAttributes[infoSymbol] = StopData.new(majorityValue, "false")
        else
          @busstopAttributes[infoSymbol] = StopData.new(majorityValue, "true")
        end
      end
    else
      @busstopAttributes[infoSymbol] = StopData.new("unknown", "true")
      @add.push(infoSymbol)
    end
  end
  
  def tallyNumericalValues(tallyHash, vote)
    if (vote).blank? == false
      if tallyHash.has_key?(vote)
        tallyHash[vote] = tallyHash[vote] + 1
      else
        tallyHash[vote] = 1
      end
    end
  end
  
  def checkDevice() 
    if browser.safari?
      @browser = :safari
    else
      @browser = :other
    end
  end
  
  def update
    ids = (params[:id]).split("_")
    agencyid = ids[0]
    stopid = ids[1]
    @busstop = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = " + stopid + " AND agencyid = " + agencyid)[0]
	
    valid = cookies[:validate].split("&")
    @validate = valid.map { |x| x.to_sym } 
  end

  def create
    @busstop = BusStop.new(params[:busstop])
    @busstop.save
    redirect_to dataentry_url(:id => params[:busstop][:AgencyId] + "_" + params[:busstop][:StopId])
  end

  def addnew
    ids = (params[:id]).split("_")
    agencyid = ids[0]
    stopid = ids[1]
    @busstop = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = " + stopid + " AND agencyid = " + agencyid)[0]
	
    addlist = cookies[:add].split("&")
    @add = addlist.map { |x| x.to_sym } 
  end
  
  def closure
    ids = (params[:id]).split("_")
    agencyid = ids[0]
    stopid = ids[1]
    @busstop = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = " + stopid + " AND agencyid = " + agencyid)[0]
  end
  
end