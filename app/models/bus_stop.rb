class BusStop < ActiveRecord::Base
  self.table_name = "busstops"
  attr_accessible :UserId, :AgencyId, :StopId, :BearingCode, :Intersection,
    :RteSignType, :SchedHolder, :Shelters, :BenchCount, :HasCan, :AddedFrom,
    :StopComment, :UserIP, :DateCreated, :UserAtStop, :InsetFromCurb, :OBAId,
    :ShelterOffset, :ShelterOrientation, :LightingConditions, :InputId, :LastEdited

  # Log some custom information
  def self.usageLogger
    @@usageLogger ||= Logger.new("#{Rails.root}/log/siteusage.log")
  end  
  
  # List all options for sign types here. This order will be used for both the 
  # internal representation (values) and the externally displayed strings (names)
  module SignType
    SINGLE = 0
    NONMETRO = 1
    SINGLELARGE = 2
    DOUBLE = 3
    TRIANGLEKIOSK = 4
    NONE = 5
    UNKNOWN = 6
    COUNT = 7
  end
  
  # Values: internal representation (in db); these may be added to _BUT SHOULD NOT BE REMOVED_
  def self.SIGNTYPEVALUES_CONST
    @@SIGNTYPEVALUES_CONST = ["single pole sign", "non bus pole", "wide base", "two pole sign", "triangle", 
      "no sign", "unknown"]
  end

  # Names: string representation as these appear in the app (these can be changed arbitrarily, just preserve the
  # order as per the SignType pseudo-enum
  def self.SIGNTYPENAMES_CONST
    @@SIGNTYPENAMES_CONST = ["small sign on own pole", "sign on non bus stop pole", "large sign on one pole",
    "large sign on two poles", "triangular kiosk", "no sign"]
  end
  
  module StopPosition
    FAR = 0
    NEAR = 1
    ATCROSS = 2
    OPPOSITETO = 3
    UNKNOWN = 4
    COUNT = 5
  end
       
  # Internal representation; don't change, only add/remove     
  def self.STOPPOSITIONVALUES_CONST
    @@STOPPOSITIONVALUES_CONST = ["far side", "near side", "at cross street", "opposite to", "unknown"] 
  end
  
  # Display strings, change freely
  def self.STOPPOSITIONNAMES_CONST
    @@STOPPOSITIONNAMES_CONST = ["far side", "near side", "at cross street", "opposite to"] 
  end
      
  module ScheduleType
    NO = 0
    YES = 1
    UNKNOWN = 2
    COUNT = 3
  end
  
  def self.SCHEDULEVALUES_CONST
    @@SCHEDULEVALUES_CONST = ["no", "yes", "unknown"]
  end
  
  def self.SCHEDULENAMES_CONST
    @@SCHEDULENAMES_CONST = ["no", "yes"] 
  end
  
  # Position of the pole relative to the curb
  module SignInset
    NEAR = 0
    FAR = 1
    UNKNOWN = 2
    COUNT = 3
  end
  
  def self.SIGNINSETVALUES_CONST
    @@SIGNINSETVALUES_CONST = ["<1", ">1", "unknown"] 
  end
  
  def self.SIGNINSETNAMES_CONST
    @@SIGNINSETNAMES_CONST = ["close to curb (< 1 foot)", "far from curb (> 1 foot)"] 
  end

  module BenchCount
    NONE = 0
    ONE = 1
    TWO = 2
    LOTS = 3
    UNKNOWN = 4
    COUNT = 5
  end
      
  def self.BENCHCOUNTVALUES_CONST
    @@BENCHCOUNTVALUES_CONST = ["0", "1", "2", "3+", "unknown"]
  end
      
  def self.BENCHCOUNTNAMES_CONST
    @@BENCHCOUNTNAMES_CONST = ["0", "1", "2", "3 or more"] 
  end
  
  module ShelterCount
    NONE = 0
    ONE = 1
    TWO = 2
    LOTS = 3
    UNKNOWN = 4
    COUNT = 5
  end
      
  def self.SHELTERCOUNTVALUES_CONST
    @@SHELTERCOUNTVALUES_CONST = ["0", "1", "2", "3+", "unknown"] 
  end
      
  def self.SHELTERCOUNTNAMES_CONST
    @@SHELTERCOUNTNAMES_CONST = ["0", "1", "2", "3 or more"] 
  end
  
  module ShelterInset
    NEAR = 0
    FAR = 1
    UNKNOWN = 2
    COUNT = 3
  end
  
  def self.SHELTERINSETVALUES_CONST
    @@SHELTERINSETVALUES_CONST = ["<1", ">1", "unknown"] 
  end
     
  def self.SHELTERINSETNAMES_CONST
    @@SHELTERINSETNAMES_CONST = ["against curb", "across sidewalk from curb"] 
  end
  
  module ShelterOrientation
    STREET = 0
    AWAY = 1
    PERPENDICULAR = 2
    COUNT = 3
  end
  
  def self.SHELTERORIENTATIONVALUES_CONST
    @@SHELTERORIENTATIONVALUES_CONST = ["streetfacing", "away from street", "sideways", "unknown"] 
  end
      
  def self.SHELTERORIENTATIONNAMES_CONST
    @@SHELTERORIENTATIONNAMES_CONST = ["towards the street", "away from the street", "perpendicular to street"] 
  end
  
  module TrashcanType
    NO = 0
    YES = 1
    UNKNOWN = 2
    COUNT = 3
  end
  
  def self.TRASHCANVALUES_CONST
    @@TRASHCANVALUES_CONST = ["yes", "no", "unknown"] 
  end
  
  def self.TRASHCANNAMES_CONST
    @@TRASHCANNAMES_CONST = ["yes", "no"] 
  end
  
  module LightingType
    NONE = 0
    LOW = 1
    MEDIUM = 2
    BRIGHT = 3
    UNKNOWN = 4
    COUNT = 5
  end
    
  def self.LIGHTINGVALUES_CONST
    @@LIGHTINGVALUES_CONST = ["0", "1", "2", "3", "unknown"]
  end
      
  def self.LIGHTINGNAMES_CONST
    @@LIGHTINGNAMES_CONST = ["no lighting", "poorly lit", "some lighting", "well-lit"] 
  end
         
  # The following methods are used to convert legacy db categories into the categories 
  # currently in use in the app (mostly Metro > our categories, though this could later be 
  # used to map our own categories that we discontinue into new categories)
         
  def self.stopPosition(pos)
    if pos.to_s == ''
      return self.STOPPOSITIONVALUES_CONST[StopPosition::UNKNOWN]
    end
    if (self.STOPPOSITIONVALUES_CONST.include?(pos.downcase))
      return pos.downcase
    else
      case pos.downcase
        when "at cross st"
          return self.STOPPOSITIONVALUES_CONST[StopPosition::ATCROSS]
        when "far middle"
          return self.STOPPOSITIONVALUES_CONST[StopPosition::FAR]
        when "near middle"
          return self.STOPPOSITIONVALUES_CONST[StopPosition::NEAR]
        else
          return self.STOPPOSITIONVALUES_CONST[StopPosition::UNKNOWN]
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
    if (self.SIGNTYPEVALUES_CONST.include?(signCode))
      return signCode
    else
      case signCode
      when "A1 <=2 rts"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLE]
      when "C1H <=48 rts"
        return self.SIGNTYPEVALUES_CONST[SignType::DOUBLE]
      when "B1H <=14 rts"
        return self.SIGNTYPEVALUES_CONST[SignType::DOUBLE]
      when "Single"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLE]
      when "A2 <=6 rts"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLE]
      when "Ksk Hyb Rts"
        return self.SIGNTYPEVALUES_CONST[SignType::TRIANGLEKIOSK]
      when "C2 <=32 rts"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLELARGE]
      when "B1 <=12 rts"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLE]
      when "C2H <=32 rts"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLELARGE]
      when "C1H <=48 rts"
        return self.SIGNTYPEVALUES_CONST[SignType::DOUBLE]
      when "Tunnel Rts"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLE]
      when "None"
        return self.SIGNTYPEVALUES_CONST[SignType::NONE]
      when "C1 <=18 rts"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLELARGE]
      when "A2H <=10 rts"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLE]
      when "Large Routes"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLELARGE]
      when "New double"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLE]
      when "Small Routes"
        return self.SIGNTYPEVALUES_CONST[SignType::SINGLE]
      when "Unknown"
        return self.SIGNTYPEVALUES_CONST[SignType::UNKNOWN]
      else
        return self.SIGNTYPEVALUES_CONST[SignType::UNKNOWN]
      end
    end
  end

  def self.scheduleType(holder)
    if holder.to_s == ''
      return "unknown"
    end
    if (self.SCHEDULEVALUES_CONST.include?(holder.downcase))
      return holder.downcase
    else
      case holder
      when "None"
        return self.SCHEDULEVALUES_CONST[ScheduleType::NO]
      when "Single"
        return self.SCHEDULEVALUES_CONST[ScheduleType::YES]
      when "Midsize"
        return self.SCHEDULEVALUES_CONST[ScheduleType::YES]
      when "H-Panel"
        return self.SCHEDULEVALUES_CONST[ScheduleType::YES]
      when "Double"
        return self.SCHEDULEVALUES_CONST[ScheduleType::YES]
      else
        return self.SCHEDULEVALUES_CONST[ScheduleType::UNKNOWN]
      end
    end
  end

  def self.signInset(pos)
    if (self.SIGNINSETVALUES_CONST.include?(pos))
      return pos
    else
      return self.SIGNINSETVALUES_CONST[SignInset::UNKNOWN]
    end
  end
  
  def self.benchCount(val)
    if (self.BENCHCOUNTVALUES_CONST.include?(val))
      return val
    else
      return self.BENCHCOUNTVALUES_CONST[BenchCount::UNKNOWN]
    end
  end
  
  def self.shelterCount(val)
    if (self.SHELTERCOUNTVALUES_CONST.include?(val))
      return val
    elsif (val == nil)
      return self.SHELTERCOUNTVALUES_CONST[ShelterCount::UNKNOWN]
    elsif (val == "3" or val == "4" or val == "5")
      return self.SHELTERCOUNTVALUES_CONST[ShelterCount::LOTS]
    else
      return self.SHELTERCOUNTVALUES_CONST[ShelterCount::UNKNOWN]
    end
  end
  
  def self.shelterOrientation(val)
    if (self.SHELTERORIENTATIONVALUES_CONST.include?(val))
      return val
    else
      return self.SHELTERORIENTATIONVALUES_CONST[ShelterOrientation::UNKNOWN]
    end
  end
  
  def self.shelterInset(val)
    if (self.SHELTERINSETVALUES_CONST.include?(val))
      return val
    else
      return self.SHELTERINSETVALUES_CONST[ShelterInset::UNKNOWN]
    end
  end
  
  def self.trashCan(val)
    if (self.TRASHCANVALUES_CONST.include?(val))
      return val
    else
      return self.TRASHCANVALUES_CONST[TrashcanType::UNKNOWN]
    end
  end
  
  def self.lighting(val)
    if (self.LIGHTINGVALUES_CONST.include?(val))
      return val
    else
      return self.LIGHTINGVALUES_CONST[LightingType::UNKNOWN]
    end
  end
end
