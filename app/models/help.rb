class Help
  class Info
    def initialize(text, img, imgAltText)
      @text = text
      @img = img
      @imgAltText = imgAltText
    end
    
    def text
      @text
    end
    
    def img
      @img
    end
    
    def imgAltText
      @imgAltText
    end
  end
  
  Signs = {"single pole sign" => Info.new("A small sign on one pole.","singlepole.png", "A small sign on one pole."), 
    "non bus pole" => Info.new("A small sign on on a multipurpose pole, such as a telephone or light pole.", "nonmetro.png", "A small sign on on a multipurpose pole, such as a telephone or light pole."), 
    "wide base" => Info.new("A large sign on one pole.", "widebase.png", "A large sign on one pole."), 
    "two pole sign" => Info.new("A large sign on two poles, making a shape like an H.", "twopoles.png", "A large sign on two poles, making a shape like an H."), 
    "triangle" => Info.new("A large triangular kiosk.", "triangularkiosk.png", "A large triangular kiosk."), 
    "no sign" => Info.new("No sign marking stop.",  "", ""), 
    "unknown" => Info.new("No data for this field.", "", "") }
  
  Signs.default = Info.new("No data for this field.", "", "")
  
  def self.SignType
    Signs
  end  
  
  StopPositions = { "far side" => Info.new("The bus stop is located on the first street named, after the intersection of the second, in the direction the bus travels.", 'buspositions_simplified.png', 
    "A graphic of two intersecting streets, with an arrow indicating the direction the bus travels. 'Near side' is labeled before the intersection, 'far side' after."), 
    "near side" => Info.new("The bus stop is located on the first street named, before the intersection of the second, in the direction the bus travels.", 'buspositions_simplified.png',
    "A graphic of two intersecting streets, with an arrow indicating the direction the bus travels. 'Near side' is labeled before the intersection, 'far side' after."), 
    "at cross street" => Info.new("The stop is at the intersection of the two streets. This option is deprecated.", '', ''), 
    "opposite to" => Info.new("The bus stop is located on the first street named, at the t-intersection of the second street.", 'buspositions2.png', 
    "A graphic of a t-intersection, with the bus stop marked at the top of the T."), 
    "unknown" => Info.new("No information exists for this field.", '', '') }
    
  StopPositions.default = Info.new("No information exists for this field.", "", "")
  
  def self.StopPosition
    StopPositions
  end
  
  ScheduleTypes = { "no" => Info.new("The stop has no schedule or the schedule is part of the sign.", "combined.png", ""), 
    "yes" => Info.new("The schedule is separate but attached to the stop pole.", "combined.png", ""), 
    "unknown" => Info.new("No information exists for this field.", "", "") }
  
  ScheduleTypes.default = Info.new("No data for this field.", "", "")
  
  def self.ScheduleType
    ScheduleTypes
  end

  SignInsetTypes = { "<1" => Info.new("The sign is within one foot of the curb.", "", ""), 
    ">1" => Info.new("The sign is further from the curb, either on the opposite side of the sidewalk or inset more than a foot.", "", ""), 
    "unknown" => Info.new("No information exists for this field.", "", "") }
  
  SignInsetTypes.default = Info.new("No data for this field.", "", "")
  
  def self.SignInsetType
    SignInsetTypes
  end
  
  ShelterInsetTypes = { "<1" => Info.new("The shelter is placed next to the curb.", "shelterpositions.png", ""), 
    ">1" => Info.new("The shelter is away from the curb, either in the middle of the sidewalk or across the sidewalk from the curb.", "shelterpositions.png", ""), 
    "unknown" => Info.new("No information exists for this field.", "", "") }
    
  ShelterInsetTypes.default = Info.new("No data for this field.", "", "")
  
  def self.ShelterInsetType
    ShelterInsetTypes
  end
  
  ShelterOrientationTypes = { "streetfacing" => Info.new("The shelter is parallel to the street, with the open side facing the curb.", "streetfacing.png", ""), 
    "away from street" => Info.new("The shelter opens away from the street, with the closed back facing the curb.", "sidewalkfacing.png", ""), 
    "sideways" => Info.new("The shelter is perpendicular to the street, with the narrow side facing the curb.", "perpendicular.png", ""),
    "unknown" => Info.new("No information exists for this field.", "", "") }
  
  ShelterOrientationTypes.default = Info.new("No data for this field.", "", "")
  
  def self.ShelterOrientationType
    ShelterOrientationTypes
  end
end