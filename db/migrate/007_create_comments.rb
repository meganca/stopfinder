class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments, {:id => false} do |t|
      t.string :agency_id
      t.string :stop_id
      t.string :info
    end

    execute "ALTER TABLE comments ADD PRIMARY KEY(agency_id, stop_id);"
  end
  
  def self.down
  end
  
end