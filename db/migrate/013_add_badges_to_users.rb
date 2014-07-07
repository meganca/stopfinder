class AddBadgesToUsers < ActiveRecord::Migration
  def self.up
    add_column "users", "title", :string
    add_column "users", "badges", :string
  end
  
  def self.down
    remove_column "users", "title"
    remove_column "users", "badges"
  end
  
end