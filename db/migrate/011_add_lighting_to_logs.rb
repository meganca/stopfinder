class AddLightingToLogs < ActiveRecord::Migration
  def self.up
    add_column :logs, :shelter_position, :string
    add_column :logs, :shelter_orientation, :string
    add_column :logs, :lighting, :string
    remove_column :logs, :direction
  end
  
  def self.down
    remove_column :logs, :shelter_position
    remove_column :logs, :shelter_orientation
    remove_column :logs, :lighting
    add_column :logs, :direction, :string
  end
  
end