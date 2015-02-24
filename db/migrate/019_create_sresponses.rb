class CreateSresponses < ActiveRecord::Migration
  def self.up
    create_table :sresponses do |t|
      t.string :name
      t.string :email
      t.string :OBAid
      
      t.string :shortanswer1
      t.string :radio1

      t.timestamps
    end
  end
end
