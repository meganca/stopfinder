class AddVisibleToUsers < ActiveRecord::Migration
  def self.up
    add_column "users", "visible", :int, default: 0
  end
  
  def self.down
    remove_column "users", "visible"
  end
  
end