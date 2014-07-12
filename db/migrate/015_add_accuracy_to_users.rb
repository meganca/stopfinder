class AddAccuracyToUsers < ActiveRecord::Migration
  def self.up
    add_column "users", "otherVerifyingVotes", :int, default: 0
    add_column "users", "otherTotalVotes", :int, default: 0
  end
  
  def self.down
    remove_column "users", "otherVerifyingVotes"
    remove_column "users", "otherTotalVotes"
  end
  
end