class RemoveIpFromBusstops < ActiveRecord::Migration
  def self.up
    remove_column "busstops", "UserIP"
  end
  
  def self.down
  end
  
end