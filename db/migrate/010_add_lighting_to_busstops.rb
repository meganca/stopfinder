class AddLightingToBusstops < ActiveRecord::Migration
  def self.up
    add_column "busstops", "OBAId", :string
    add_column "busstops", "LightingConditions", :string
    add_column "busstops", "ShelterOrientation", :string
    add_column "busstops", "ShelterOffset", :string
  end
  
  def self.down
    remove_column "busstops", "OBAId"
    remove_column "busstops", "LightingConditions"
    remove_column "busstops", "ShelterOrientation"
    remove_column "busstops", "ShelterOffset"
  end
  
end