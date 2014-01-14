class BusStop < ActiveRecord::Base
  self.table_name = "stopinfo_dev"
  attr_accessible :UserId, :AgencyId, :StopId, :BearingCode, :Intersection, 
    :RteSignType, :SchedHolder, :Shelters, :BenchCount, :HasCan, :AddedFrom,
    :StopComment, :UserIP, :DateCreated, :UserAtStop, :InsetFromCurb,
    :ClosureType, :ClosurePermanent, :ClosureStartdate, :ClosureEnddate, :MovedTo

  # Constants to keep track of what fields we're collecting
  @@infoFields = ["direction", "position", "sign type", "schedule holder", "is tunnel", 
    "curb inset", "shelters", "benches", "comment"]

  def self.infoFields
    @@infoFields
  end
  
  # Acceptable values for each data type
  @@directionValues = ["northbound", "eastbound", "westbound", "southbound", "unknown"]
  
  def self.directionValues
    @@directionValues
  end

  @@signTypeValues = ["single pole sign", "non bus pole", "two pole sign", "triangle", 
    "wide base", "no sign", "unknown"]
    
  @@signTypeNames = ["small sign on stand alone pole", "sign on non bus stop pole", "large sign on two poles", "triangular kiosk", 
    "large sign on one wide base", "no sign", "unknown"]
	
  def self.signTypeValues
    @@signTypeValues
  end

  def self.signTypeNames
    @@signTypeNames
  end
  
  @@intersectionPositionValues = ["far side", "near side", "at cross street", 
      "far middle", "near middle", "opposite to", "unknown"] 
      
  def self.intersectionPositionValues
    @@intersectionPositionValues
  end
  
  @@scheduleTypeValues = ["single", "midsize", "double", 
      "none", "unknown"] 
      
  def self.scheduleTypeValues
    @@scheduleTypeValues
  end
  
  @@curbInsetValues = ["<1", ">1", "unknown"] 
  
  def self.curbInsetValues
    @@curbInsetValues
  end
  
  @@curbInsetNames = ["close to curb (within 1 foot)", "far from curb (more than 1 foot away)", "unknown"] 
      
  def self.curbInsetNames
    @@curbInsetNames
  end
  
  @@closeMoveValues = ["closed (permanently)", "closed (temporarily)", "moved to a different location (temporarily)"] 
      
  def self.closeMoveValues
    @@closeMoveValues
  end

  @@benchCountValues = ["0", "1", "2", "3 or more", "unknown"] 
      
  def self.benchCountValues
    @@benchCountValues
  end
  
  @@shelterCountValues = ["0", "1", "2", "3 or more", "unknown"] 
      
  def self.shelterCountValues
    @@shelterCountValues
  end
  
  @@trashCanValues = ["yes", "no", "unknown"] 
      
  def self.trashCanValues
    @@trashCanValues
  end
  
  def self.directionName(direction)
    if (directionValues.include?(direction))
      return direction
    else
      case direction
        when "N"
          return "northbound"
        when "E"
          return "eastbound"
        when "W"
          return "westbound"
        when "S"
          return "southbound"
        else
          return "unknown"
      end
    end
  end

         
  def self.intersectionPosition(pos)
    if pos.to_s == ''
      return "unknown"
    end
    if (intersectionPositionValues.include?(pos.downcase))
      return pos.downcase
    else
      case pos
        when "At cross st"
          return "at cross street"
        else
          return "unknown"
      end
    end
  end
    
  def self.isTunnelStop(signCode)
    if signCode == "Tunnel Rts"
      return "true"
    else
      return "false"
    end
  end
    
  def self.signType(signCode)
    if (signTypeValues.include?(signCode))
      return signCode
    else
      case signCode
      when "A1 <=2 rts"
        return "single pole sign"
      when "C1H <=48 rts"
        return "two pole sign"
      when "B1H <=14 rts"
        return "two pole sign"
      when "Single"
        return "single pole sign"
      when "A2 <=6 rts"
        return "single pole sign"
      when "Ksk Hyb Rts"
        return "triangule"
      when "C2 <=32 rts"
        return "wide base"
      when "B1 <=12 rts"
        return "single pole sign"
      when "C2H <=32 rts"
        return "wide base"
      when "C1H <=48 rts"
        return "two pole sign"
      when "Tunnel Rts"
        return "single pole sign"
      when "None"
        return "no sign"
      when "C1 <=18 rts"
        return "wide base"
      when "A2H <=10 rts"
        return "single pole sign"
      when "Large Routes"
        return "wide base"
      when "New double"
        return "single pole sign"
      when "Small Routes"
        return "single pole sign"
      when "Unknown"
        return "unknown"
      else
        return "unknown"
      end
    end
  end

  def self.scheduleType(holder)
    if holder.to_s == ''
      return "unknown"
    end
    if (scheduleTypeValues.include?(holder.downcase))
      return holder.downcase
    else
      case holder
      when "H-Panel"
        return "midsize"
      else
        return "unknown"
      end
    end
  end

  def self.curbInset(pos)
    if (curbInsetValues.include?(pos))
      return pos
    else
      return "unknown"
    end
  end
  
  def self.benchCount(val)
    if (benchCountValues.include?(val))
      return val
    else
      return "unknown"
    end
  end
  
  def self.shelterCount(val)
    if (shelterCountValues.include?(val.to_s))
      return val.to_s
    elsif (val == nil)
      return "unknown"
    elsif (val >= 3)
      return "3 or more"
    else
      return "unknown"
    end
  end
  
  def self.trashCan(val)
    if (trashCanValues.include?(val))
      return val
    else
      return "unknown"
    end
  end
  
  def self.isClosed(type, permanent, startdate, enddate)
    if ((type == nil) || (type == ""))
      return "false"
    elsif (type == "current" && enddate > Time.now)
      return "true"
    elsif (type == "future" && startdate < Time.now && enddate > Time.now)
      return "true"
    else
      return "false"
    end
  end
  
end
