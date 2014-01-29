class AddCommentsToLogs < ActiveRecord::Migration
  def self.up
    add_column :logs, :comment, :string
  end
  
  def self.down
    remove_column :logs, :comment
  end
  
end