class AddReputationToUsers < ActiveRecord::Migration
  def self.up
    add_column "users", "stops", :int
    add_column "users", "points", :int
    add_column "users", "accuracy", :double
    add_column "users", "newInfoSubmitted", :int
  end
  
  def self.down
    remove_column "users", "stops"
    remove_column "users", "points"
    remove_column "users", "accuracy"
    remove_column "users", "newInfoSubmitted"
  end
  
end