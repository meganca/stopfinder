class CreateClosures < ActiveRecord::Migration
  def change
    create_table :closures, :id => false, :force => true do |t|
      t.string   "AgencyId",                 :limit => 64,                 :null => false
      t.string   "StopId",                   :limit => 64,                 :null => false
      t.string   "ClosureType"
      t.string   "ClosurePermanent"
      t.date     "StartDate"
      t.date     "EndDate"
      t.string   "MovedTo",           :limit => 64
      t.string   "UserId",                   :limit => 64
      t.string   "UserIP",                   :limit => 64
      t.integer  "UserAtStop"         
      t.datetime "DateCreated"
    end
  end
end
