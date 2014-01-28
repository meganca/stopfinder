class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs, {:id => false} do |t|
      t.integer :input_id
      t.string :direction
      t.string :position
      t.string :sign_type
      t.string :sign_position
      t.string :schedule_holder
      t.string :shelters
      t.string :benches
      t.string :trash_can
    end
    
    execute 'ALTER TABLE logs ADD PRIMARY KEY(input_id)'
    remove_column "busstops", "AddedFrom"
    execute 'ALTER TABLE busstops ADD InputId INT NOT NULL AUTO_INCREMENT PRIMARY KEY'
  end
  
  def self.down
    add_column "busstops", "AddedFrom", t.string
    execute 'ALTER TABLE busstops DROP InputId'
  end
  
end