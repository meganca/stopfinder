class ChangeClosuresDatesToDatetimes < ActiveRecord::Migration
  def self.up    
    execute 'ALTER TABLE closures MODIFY StartDate DATETIME'
    execute 'ALTER TABLE closures MODIFY EndDate DATETIME'
  end
  
  def self.down
    #execute 'ALTER TABLE closures MODIFY StartDate date'
    #execute 'ALTER TABLE closures MODIFY EndDate date'
  end
  
end