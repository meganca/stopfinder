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
  
  class FieldInfo
    def initialize(displayString, active)
      @displayString = displayString
      @active = active
    end
    
    def displayString
      @displayString
    end
    
    def active
      @active
    end
  end
  
  def self.getHash(name)
    case name.downcase
    when "sign type"
      return Signs
    when "stop position"
      return StopPositions
    when "schedule type"
      return ScheduleTypes
    when "sign inset"
      return SignInsetTypes
    when "bench count"
      return BenchCountCategories
    when "shelter count"
      return ShelterCountCategories
    when "shelter inset"
      return ShelterInsetTypes
    when "shelter orientation"
      return ShelterOrientationTypes
    when "trashcan"
      return TrashcanTypes
    when "lighting"
      return LightingTypes
    else
      return {}
    end
  end
  
  # Returns the list of all internal values for a given field, both active and inactive
  # Params:
  # +field+:: string name of the field, eg SignType
  def self.getFieldValues(field)
    lookupHash = self.getHash(field)
    lookupHash.keys
  end
  
  # Returns the display string corresponding to the given internal representation
  # Params:
  # +field+:: string name of the field, eg SignType
  # +value+:: string internal value of the field, eg 'no sign'
  def self.getFieldName(field, value)
    lookupHash = self.getHash(field)
    lookupHash[value].displayString
  end
  
  # Returns a nested array of [internalval, display] pairs for all active options in a field
  # Params:
  # +field+:: string name of the field, eg SignType
  def self.getActivePairs(field)
    lookupHash = self.getHash(field)
    activePairs = []
    lookupHash.keys.each{ |x| activePairs.push([x, lookupHash[x].displayString]) if lookupHash[x].active == 1}
    activePairs
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
    UNKNOWN = 6 # Leave unknown in this position; add before it
    COUNT = 7
  end
  
  # DO NOT EVER CHANGE THE KEYS. If a field is retired, move it to "0"
  # indicating it is inactive. The second property, displayStrings, can be freely changed.
  Signs = { "single pole sign" => FieldInfo.new("small single sign", 1), 
    "non bus pole" => FieldInfo.new("sign on non-bus pole", 1), 
    "wide base" => FieldInfo.new("large single sign", 1), 
    "two pole sign" => FieldInfo.new("large two pole sign", 1), 
    "triangle" => FieldInfo.new("triangular kiosk", 1), 
    "no sign" => FieldInfo.new("no sign", 1),   
    "unknown" => FieldInfo.new("no data", 1) }
  
  Signs.default =  FieldInfo.new("no data", 0)
 
  module StopPosition
    FAR = 0
    NEAR = 1
    ATCROSS = 2
    OPPOSITETO = 3
    UNKNOWN = 4
    COUNT = 5
  end
  
  StopPositions = { "far side" => FieldInfo.new("far side", 1), 
    "near side" => FieldInfo.new("near side", 1), 
    "at cross street" => FieldInfo.new("at cross street", 0), 
    "opposite to" => FieldInfo.new("opposite to", 1), 
    "unknown" => FieldInfo.new("no data", 1) }
      
  module ScheduleType
    NO = 0
    YES = 1
    UNKNOWN = 2
    COUNT = 3
  end
  
  ScheduleTypes = { "no" => FieldInfo.new("no", 1), 
    "yes" => FieldInfo.new("yes", 1), 
    "unknown" => FieldInfo.new("no data", 1) }
  
  # Position of the pole relative to the curb
  module SignInset
    NEAR = 0
    FAR = 1
    UNKNOWN = 2
    COUNT = 3
  end
  
  SignInsetTypes = { "<1" => FieldInfo.new("at curb", 1), 
    ">1" => FieldInfo.new("away from curb", 1), 
    "unknown" => FieldInfo.new("no data", 1) }
  
  module BenchCount
    NONE = 0
    ONE = 1
    TWO = 2
    LOTS = 3
    UNKNOWN = 4
    COUNT = 5
  end
      
  BenchCountCategories = { "0" => FieldInfo.new("0", 1), 
    "1" => FieldInfo.new("1", 1), 
    "2" => FieldInfo.new("2", 1), 
    "3+" => FieldInfo.new("3 or more", 1), 
    "unknown" => FieldInfo.new("no data", 1) }

  module ShelterCount
    NONE = 0
    ONE = 1
    TWO = 2
    LOTS = 3
    UNKNOWN = 4
    COUNT = 5
  end
  
  ShelterCountCategories = { "0" => FieldInfo.new("0", 1), 
    "1" => FieldInfo.new("1", 1), 
    "2" => FieldInfo.new("2", 1), 
    "3+" => FieldInfo.new("3 or more", 1), 
    "unknown" => FieldInfo.new("no data", 1) }
  
  module ShelterInset
    NEAR = 0
    FAR = 1
    UNKNOWN = 2
    COUNT = 3
  end
  
  ShelterInsetTypes = { "<1" => FieldInfo.new("at curb", 1), 
    ">1" => FieldInfo.new("away from curb", 1), 
    "unknown" => FieldInfo.new("no data", 1) }
  
  module ShelterOrientation
    STREET = 0
    AWAY = 1
    PERPENDICULAR = 2
    COUNT = 3
  end
  
  ShelterOrientationTypes = { "streetfacing" => FieldInfo.new("towards the street", 1), 
    "away from street" => FieldInfo.new("away from the street", 1), 
    "sideways" => FieldInfo.new("perpendicular to street", 1),
    "unknown" => FieldInfo.new("no data", 1) }

  module TrashcanType
    NO = 0
    YES = 1
    UNKNOWN = 2
    COUNT = 3
  end
  
  TrashcanTypes = { "no" => FieldInfo.new("no", 1), 
    "yes" => FieldInfo.new("yes", 1), 
    "unknown" => FieldInfo.new("no data", 1) }
  
  module LightingType
    NONE = 0
    LOW = 1
    MEDIUM = 2
    BRIGHT = 3
    UNKNOWN = 4
    COUNT = 5
  end
  
  LightingTypes = { "0" => FieldInfo.new("no lighting", 1), 
    "1" => FieldInfo.new("poorly lit", 1), 
    "2" => FieldInfo.new("some lighting", 1), 
    "3" => FieldInfo.new("well-lit", 1), 
    "unknown" => FieldInfo.new("no data", 1) }
         
  # The following methods are used to convert legacy db categories into the categories 
  # currently in use in the app (mostly Metro > our categories, though this could later be 
  # used to map our own categories that we discontinue into new categories)
         
  def self.stopPosition(pos)
    positionValues = self.getFieldValues("stop position")
    if pos.to_s == ''
      return positionValues[StopPosition::UNKNOWN]
    end
    if (positionValues.include?(pos.downcase))
      return pos.downcase
    else
      case pos.downcase
        when "at cross st"
          return positionValues[StopPosition::ATCROSS]
        when "far middle"
          return positionValues[StopPosition::FAR]
        when "near middle"
          return positionValues[StopPosition::NEAR]
        else
          return positionValues[StopPosition::UNKNOWN]
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
    signValues = self.getFieldValues("sign type")
    if (signValues.include?(signCode))
      return signCode
    else
      case signCode
      when "A1 <=2 rts"
        return signValues[SignType::SINGLE]
      when "C1H <=48 rts"
        return signValues[SignType::DOUBLE]
      when "B1H <=14 rts"
        return signValues[SignType::DOUBLE]
      when "Single"
        return signValues[SignType::SINGLE]
      when "A2 <=6 rts"
        return signValues[SignType::SINGLE]
      when "Ksk Hyb Rts"
        return signValues[SignType::TRIANGLEKIOSK]
      when "C2 <=32 rts"
        return signValues[SignType::SINGLELARGE]
      when "B1 <=12 rts"
        return signValues[SignType::SINGLE]
      when "C2H <=32 rts"
        return signValues[SignType::SINGLELARGE]
      when "C1H <=48 rts"
        return signValues[SignType::DOUBLE]
      when "Tunnel Rts"
        return signValues[SignType::SINGLE]
      when "None"
        return signValues[SignType::NONE]
      when "C1 <=18 rts"
        return signValues[SignType::SINGLELARGE]
      when "A2H <=10 rts"
        return signValues[SignType::SINGLE]
      when "Large Routes"
        return signValues[SignType::SINGLELARGE]
      when "New double"
        return signValues[SignType::SINGLE]
      when "Small Routes"
        return signValues[SignType::SINGLE]
      when "Unknown"
        return signValues[SignType::UNKNOWN]
      else
        return signValues[SignType::UNKNOWN]
      end
    end
  end

  def self.scheduleType(holder)
    scheduleTypes = self.getFieldValues("schedule type")
    if holder.to_s == ''
      return "unknown"
    end
    if (scheduleTypes.include?(holder.downcase))
      return holder.downcase
    else
      case holder
      when "None"
        return scheduleTypes[ScheduleType::NO]
      when "Single"
        return scheduleTypes[ScheduleType::YES]
      when "Midsize"
        return scheduleTypes[ScheduleType::YES]
      when "H-Panel"
        return scheduleTypes[ScheduleType::YES]
      when "Double"
        return scheduleTypes[ScheduleType::YES]
      else
        return scheduleTypes[ScheduleType::UNKNOWN]
      end
    end
  end

  def self.signInset(pos)
    signInsets = self.getFieldValues("sign inset")
    if (signInsets.include?(pos))
      return pos
    else
      return signInsets[SignInset::UNKNOWN]
    end
  end
  
  def self.benchCount(val)
    benchCounts = self.getFieldValues("bench count")
    if (benchCounts.include?(val))
      return val
    else
      return benchCounts[BenchCount::UNKNOWN]
    end
  end
  
  def self.shelterCount(val)
    shelterCounts = self.getFieldValues("shelter count")
    if (shelterCounts.include?(val))
      return val
    elsif (val == nil)
      return shelterCounts[ShelterCount::UNKNOWN]
    elsif (val == "3" or val == "4" or val == "5")
      return shelterCounts[ShelterCount::LOTS]
    else
      return shelterCounts[ShelterCount::UNKNOWN]
    end
  end
  
  def self.shelterOrientation(val)
    orientations = self.getFieldValues("shelter orientation")
    if (orientations.include?(val))
      return val
    else
      return orientations[ShelterOrientation::UNKNOWN]
    end
  end
  
  def self.shelterInset(val)
    shelterInsets = self.getFieldValues("shelter inset")
    if (shelterInsets.include?(val))
      return val
    else
      return shelterInsets[ShelterInset::UNKNOWN]
    end
  end
  
  def self.trashCan(val)
    cans = self.getFieldValues("trashcan")
    if (cans.include?(val))
      return val
    else
      return cans[TrashcanType::UNKNOWN]
    end
  end
  
  def self.lighting(val)
    lightings = self.getFieldValues("lighting")
    if (lightings.include?(val))
      return val
    else
      return lightings[LightingType::UNKNOWN]
    end
  end
end
