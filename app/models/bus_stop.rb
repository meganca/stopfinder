class BusStop < ActiveRecord::Base
  self.table_name = "stopinfo_dev"
  attr_accessible :UserId, :AgencyId, :StopId, :BearingCode, :Intersection, 
    :RteSignType, :SchedHolder, :Shelters, :BenchCount, :CanCount, :BoxCount, 
    :PoleCount, :StopComment, :UserIP, :DateCreated, :UserAtStop, :InsetFromCurb

  # Constants to keep track of what fields we're collecting
  @@infoFields = ["direction", "position", "sign type", "schedule holder", "is tunnel", 
    "curb inset", "shelters", "benches", "boxes", "poles", "comment"]

  def self.infoFields
    @@infoFields
  end
  
  # Acceptable values for each data type
  @@directionValues = ["northbound", "eastbound", "westbound", "southbound", "unknown"]
  
  def self.directionValues
    @@directionValues
  end

  @@signTypeValues = ["small sign on stand alone pole", "sign on non bus stop pole", "large sign on two poles", "triangular kiosk", 
    "large sign on one wide base", "no sign", "unknown"]
	
  def self.signTypeValues
    @@signTypeValues
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
  
  @@curbInsetValues = ["close to curb (within 1 foot)", "far from curb (more than 1 foot away)", "unknown"] 
      
  def self.curbInsetValues
    @@curbInsetValues
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
        return "small sign on stand alone pole"
      when "C1H <=48 rts"
        return "large sign on two poles"
      when "B1H <=14 rts"
        return "large sign on two poles"
      when "Single"
        return "small sign on stand alone pole"
      when "A2 <=6 rts"
        return "small sign on stand alone pole"
      when "Ksk Hyb Rts"
        return "triangular kiosk"
      when "C2 <=32 rts"
        return "large sign on one wide base"
      when "B1 <=12 rts"
        return "small sign on stand alone pole"
      when "C2H <=32 rts"
        return "large sign on one wide base"
      when "C1H <=48 rts"
        return "large sign on two poles"
      when "Tunnel Rts"
        return "small sign on stand alone pole"
      when "None"
        return "no sign"
      when "C1 <=18 rts"
        return "large sign on one wide base"
      when "A2H <=10 rts"
        return "small sign on stand alone pole"
      when "Large Routes"
        return "large sign on one wide base"
      when "New double"
        return "small sign on stand alone pole"
      when "Small Routes"
        return "small sign on stand alone pole"
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
  
end
