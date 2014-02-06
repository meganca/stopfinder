class ChangeClosuresDatesToDatetimes < ActiveRecord::Migration
  def self.up    
    execute "ALTER TABLE closures ALTER COLUMN StartDate datetime;"
    execute "ALTER TABLE closures ALTER COLUMN EndDate datetime;"
  end
  
  def self.down
    execute 'ALTER TABLE closures ALTER COLUMN StartDate date'
    execute 'ALTER TABLE closures ALTER COLUMN EndDate date'
  end
  
end