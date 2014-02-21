class BusStop < ActiveRecord::Base
  self.table_name = "busstops"
  attr_accessible :UserId, :AgencyId, :StopId, :BearingCode, :Intersection, 
    :RteSignType, :SchedHolder, :Shelters, :BenchCount, :HasCan, :AddedFrom,
    :StopComment, :UserIP, :DateCreated, :UserAtStop, :InsetFromCurb, :OBAId,
    :ShelterOffset, :ShelterOrientation, :LightingConditions

  # Log some custom information
  def self.usageLogger
    @@usageLogger ||= Logger.new("#{Rails.root}/log/siteusage.log")
  end  
  
  # Constants to keep track of what fields we're collecting
  @@signTypeValues = ["single pole sign", "non bus pole", "two pole sign", "triangle", 
    "wide base", "no sign", "unknown"]
    
  @@signTypeNames = ["small sign on own pole", "sign on non bus stop pole", "large sign on two poles", "triangular kiosk", 
    "large sign on one pole", "no sign"]
	
  def self.signTypeValues
    @@signTypeValues
  end

  def self.signTypeNames
    @@signTypeNames
  end
  
  @@intersectionPositionValues = ["far side", "near side", "at cross street", "opposite to", "unknown"] 
      
  @@intersectionPosNames = ["far side", "near side", "at cross street", "opposite to"] 
      
  def self.intersectionPositionValues
    @@intersectionPositionValues
  end
  
  def self.intersectionPosNames
    @@intersectionPosNames
  end
  
  @@scheduleTypeValues = ["yes", "no", "unknown"] 
      
  def self.scheduleTypeValues
    @@scheduleTypeValues
  end
  
  @@scheduleTypeNames = ["yes", "no"] 
      
  def self.scheduleTypeNames
    @@scheduleTypeNames
  end
  
  @@curbInsetValues = ["<1", ">1", "unknown"] 
  
  def self.curbInsetValues
    @@curbInsetValues
  end
  
  @@curbInsetNames = ["close to curb (< 1 foot)", "far from curb (> 1 foot)"] 
      
  def self.curbInsetNames
    @@curbInsetNames
  end

  @@benchCountValues = ["0", "1", "2", "3+", "unknown"] 
      
  def self.benchCountValues
    @@benchCountValues
  end
  
  @@benchCountNames = ["0", "1", "2", "3 or more"] 
      
  def self.benchCountNames
    @@benchCountNames
  end
  
  @@shelterCountValues = ["0", "1", "2", "3+", "unknown"] 
      
  def self.shelterCountValues
    @@shelterCountValues
  end
  
  @@shelterCountNames = ["0", "1", "2", "3 or more"] 
      
  def self.shelterCountNames
    @@shelterCountNames
  end
  
  @@shelterInsetValues = ["<1", ">1", "unknown"] 
  
  def self.shelterInsetValues
    @@shelterInsetValues
  end
  
  @@shelterInsetNames = ["against curb", "across sidewalk from curb"] 
      
  def self.shelterInsetNames
    @@shelterInsetNames
  end
  
  @@shelterOrientationValues = ["streetfacing", "away from street", "sideways", "unknown"] 
  
  def self.shelterOrientationValues
    @@shelterOrientationValues
  end
  
  @@shelterOrientationNames = ["towards the street", "away from the street", "perpendicular to street"] 
      
  def self.shelterOrientationNames
    @@shelterOrientationNames
  end
  
  @@trashCanValues = ["yes", "no", "unknown"] 
      
  def self.trashCanValues
    @@trashCanValues
  end
  
  @@trashCanNames = ["yes", "no"] 
      
  def self.trashCanNames
    @@trashCanNames
  end
  
  @@lightingValues = ["0", "1", "2", "3", "unknown"] 
      
  def self.lightingValues
    @@lightingValues
  end
  
  @@lightingNames = ["no lighting", "poorly lit", "some lighting", "well-lit"] 
      
  def self.lightingNames
    @@lightingNames
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
      case pos.downcase
        when "at cross st"
          return "at cross street"
        when "far middle"
          return "far side"
        when "near middle"
          return "near side"
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
        return "triangle"
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
      when "None"
        return "no"
      when "Single"
        return "yes"
      when "Midsize"
        return "yes"
      when "H-Panel"
        return "yes"
      when "Double"
        return "yes"
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
    if (shelterCountValues.include?(val))
      return val
    elsif (val == nil)
      return "unknown"
    elsif (val == "3" or val == "4" or val == "5")
      return "3+"
    else
      return "unknown"
    end
  end
  
  def self.shelterOrientation(val)
    if (shelterOrientationValues.include?(val))
      return val
    else
      return "unknown"
    end
  end
  
  def self.shelterPosition(val)
    if (shelterInsetValues.include?(val))
      return val
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
  
  def self.lighting(val)
    if (lightingValues.include?(val))
      return val
    else
      return "unknown"
    end
  end
end
