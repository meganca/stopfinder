class Help
   def self.SIGNTYPEHELP_CONST
    @@SIGNTYPEVALUES_CONST = ["A small sign on one pole.", "A small sign on on a multipurpose pole, such as a telephone or light pole.", 
      "A large sign on one pole.", "A large sign on two poles, making a shape like an H.", "A large triangular kiosk.", 
      "No sign marking stop.", "No information exists for this field."]
  end
  
  def self.SIGNTYPEIMG_CONST
    @@SIGNTYPEIMG_CONST = ['singlepole.png', 'nonmetro.png', 'widebase.png', 'twopoles.png', 'triangularkiosk.png']
  end
  
  def self.SIGNTYPEIMGALT_CONST
    @@SIGNTYPEIMGALT_CONST = ["A small sign on one pole.", "A small sign on on a multipurpose pole, such as a telephone or light pole.", 
      "A large sign on one pole.", "A large sign on two poles, making a shape like an H.", "A large triangular kiosk."]
  end
  
  def self.INTERSECTIONHELP_CONST
    @@INTERSECTIONHELP_CONST = ["The bus stop is located on the first street named, after the intersection of the second, in the direction the bus travels.", 
    "The bus stop is located on the first street named, before the intersection of the second, in the direction the bus travels.",
    "The stop is at the exact intersection of the two streets. This option is deprecated.",
    "The bus stop is located on the first street named, at the t-intersection of the second street.",
    "No information exists for this field."]
  end
  
  def self.INTERSECTIONIMG_CONST
    @@INTERSECTIONIMG_CONST = ['buspositions_simplified.png', 'buspositions_simplified.png', 'buspositions2.png', 'buspositions2.png', 'none.png']
  end
  
  def self.INTERSECTIONIMGALT_CONST
    @@INTERSECTIONIMGALT_CONST = ["A graphic of two intersecting streets, with an arrow indicating the direction the bus travels. 'Near side' is labeled before the intersection, 'far side' after.",
    "A graphic of two intersecting streets, with an arrow indicating the direction the bus travels. 'Near side' is labeled before the intersection, 'far side' after.",
    "A graphic of a t-intersection, with the bus stop marked at the top of the T.",
    "A graphic of a t-intersection, with the bus stop marked at the top of the T."]
  end
  
  def self.SIGNPOSITIONHELP_CONST
    @@SIGNPOSITIONHELP_CONST = ["The sign is at the curb.", "The sign is further from the curb, either on the opposite side of the sidewalk or inset more than a foot.", "No information exists for this field."]
  end
  
  def self.SCHEDULEHELP_CONST
    @@SCHEDULEHELP_CONST = ["The stop has no schedule or the schedule is part of the sign.", 
    "The schedule is separate but attached to the stop pole.", "No information exists for this field."]
  end
  
  def self.SHELTERPOSITIONHELP_CONST
    @@SHELTERPOSITIONHELP_CONST = ["The shelter is placed next to the curb.", 
    "The shelter is inset from the curb, across the sidewalk.", "No information exists for this field."]
  end
  
  def self.SHELTERORIENTATIONHELP_CONST
    @@SHELTERORIENTATIONHELP_CONST = ["The shelter is parallel to the street, with the open side facing the curb.", 
    "The shelter opens away from the street, with the closed back facing the curb.", 
    "The shelter is perpendicular to the street, with the narrow side facing the curb.",
    "No information exists for this field."]
  end
end