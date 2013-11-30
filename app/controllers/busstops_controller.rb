class BusstopsController < ApplicationController
  StopData = Struct.new(:value, :needsValidation)
  @@votingMajority = 0.75
  
  def show
    ids = (params[:id]).split("_")
    agencyid = ids[0]
    stopid = ids[1]
    @busstop = BusStop.new(StopId: stopid)
	
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

    shelters = Hash.new
    benches = Hash.new
    cans = Hash.new
    boxes = Hash.new
    poles = Hash.new

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
      
      # Add up the fields where we don't know possible values ahead of time
      tallyNumericalValues(shelters, stop.Shelters)
      tallyNumericalValues(benches, stop.BenchCount)
      tallyNumericalValues(cans, stop.CanCount)
      tallyNumericalValues(boxes, stop.BoxCount)
      tallyNumericalValues(poles, stop.PoleCount)

    end

    # Clear out any counts of "no opinion"
    directions.delete("unknown")
    intersections.delete("unknown")
    signs.delete("unknown")
    schedules.delete("unknown")
    insets.delete("unknown")
    benches.delete(-1)
    shelters.delete(-1)
    cans.delete(-1)
    boxes.delete(-1)
    poles.delete(-1)

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
    calculateInfo(boxes, :box_count)
    calculateInfo(poles, :pole_count)
	
	cookies[:validate] = @validate
	cookies[:add] = @add
  end

  def calculateInfo(votingHash, infoSymbol)
    if votingHash.empty? == false     
      majorityValue = votingHash.max_by{|k,v| v}[0]
      count = votingHash.values.inject(0) {|sum,x| sum + x}
      
      if count == 0
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
    redirect_to :action => "show", :id => params[:busstop][:AgencyId] + "_" + params[:busstop][:StopId]
  end

  def addnew
    ids = (params[:id]).split("_")
    agencyid = ids[0]
    stopid = ids[1]
    @busstop = BusStop.find_by_sql("SELECT * FROM " + BusStop.table_name + " WHERE stopid = " + stopid + " AND agencyid = " + agencyid)[0]
	
    addlist = cookies[:add].split("&")
    @add = addlist.map { |x| x.to_sym } 
  end
end