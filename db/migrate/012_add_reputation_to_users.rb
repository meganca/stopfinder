class AddReputationToUsers < ActiveRecord::Migration
  def self.up
    add_column "users", "OBAId", :string
  end
  
  def self.down
    remove_column "users", "OBAId"
  end
  
end