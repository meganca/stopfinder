class CreateDatabase < ActiveRecord::Migration
  def self.up
    ActiveRecord::Schema.define(:version => 0) do

      create_table "stopinfo_dev", :id => false, :force => true do |t|
        t.string   "UserId",                   :limit => 64
        t.string   "AgencyId",                 :limit => 64,                 :null => false
        t.string   "StopId",                   :limit => 64,                 :null => false
        t.datetime "BeginDate"
        t.string   "EndDate",                  :limit => 64
        t.string   "AccessibilityLevel",       :limit => 64
        t.string   "AdaLandingPad",            :limit => 64
        t.string   "AtisTransferPoint",        :limit => 64
        t.string   "Authorization",            :limit => 64
        t.string   "Awning",                   :limit => 64
        t.string   "BearingCode",              :limit => 64
        t.string   "Curb",                     :limit => 64
        t.integer  "CurbHeight"
        t.string   "Bay",                      :limit => 64
        t.string   "BikeRack",                 :limit => 64
        t.string   "CommunityArea",            :limit => 64
        t.string   "CreatedBy",                :limit => 64
        t.string   "CrossStreet",              :limit => 64
        t.string   "CurbPatin",                :limit => 64
        t.string   "DateCreated",              :limit => 64
        t.string   "DateMapped",               :limit => 64
        t.string   "LastEdited",               :limit => 64
        t.float    "Displacement"
        t.string   "Ditch",                    :limit => 64
        t.string   "ExtensionSurface",         :limit => 64
        t.integer  "ExtensionWidth"
        t.integer  "FromCrossCurb",                          :default => -1
        t.integer  "FromIntersectionCtr"
        t.string   "Juris",                    :limit => 64
        t.string   "FareZone",                 :limit => 64
        t.string   "RfpDistrict",              :limit => 64
        t.string   "ZipCode",                  :limit => 64
        t.float    "GPSAveXCoord"
        t.float    "GPSAveYCoord"
        t.string   "InfoSignAnchor",           :limit => 64
        t.string   "InfoSign",                 :limit => 64
        t.string   "Intersection",             :limit => 64
        t.string   "Latitude",                 :limit => 64
        t.string   "LayoverGroup",             :limit => 64
        t.string   "Longitude",                :limit => 64
        t.float    "MappedLinkLen"
        t.float    "PercentFrom"
        t.string   "MappedTransNodeFrom",      :limit => 64
        t.string   "MeasurementMethod",        :limit => 64
        t.string   "ModifiedBy",               :limit => 64
        t.string   "NewsBox",                  :limit => 64
        t.string   "NonMetroSignType",         :limit => 64
        t.integer  "Bollards"
        t.integer  "Shelters"
        t.string   "OnStreet",                 :limit => 64
        t.string   "OtherCoveredArea",         :limit => 64
        t.string   "StopOwner",                :limit => 64
        t.integer  "PaintLength"
        t.string   "ParkingStripSurface",      :limit => 64
        t.string   "Pullout",                  :limit => 64
        t.string   "RetainingWall",            :limit => 64
        t.string   "RideFreeAreaFlag",         :limit => 64
        t.string   "RteSignType",              :limit => 64
        t.string   "SchedHolder",              :limit => 64
        t.string   "ShoulderSurface",          :limit => 64
        t.integer  "ShoulderWidth"
        t.integer  "Side"
        t.integer  "SidewalkWidth"
        t.string   "RteSignMountingDirection", :limit => 64
        t.string   "RteSignPostAnchor",        :limit => 64
        t.string   "RteSignPostType",          :limit => 64
        t.string   "SpecialSign",              :limit => 64
        t.text     "StopComment"
        t.integer  "StopLength"
        t.string   "StopName",                 :limit => 64
        t.string   "StopStatus",               :limit => 64
        t.string   "StopType",                 :limit => 64
        t.string   "StreetAddress",            :limit => 64
        t.integer  "StripWidth"
        t.string   "TrafficSignal",            :limit => 64
        t.string   "TransLinkId",              :limit => 64
        t.string   "WalkwaySurface",           :limit => 64
        t.float    "Xcoord"
        t.float    "Ycoord"
        t.float    "XcoordOffset"
        t.float    "YcoordOffset"
        t.integer  "BenchCount",                             :default => -1
        t.integer  "CanCount",                               :default => -1
        t.integer  "BoxCount",                               :default => -1
        t.integer  "PoleCount",                              :default => -1
        t.string   "InsetFromCurb",            :limit => 64
        t.string   "HasButtonForLight",        :limit => 64
        t.string   "IsClosedOrMoved",          :limit => 64
        t.string   "PermanentlyGone",          :limit => 64
        t.string   "MovedToStop",              :limit => 64
        t.string   "MovedTo",                  :limit => 64
        t.datetime "DurationOfClosure"
        t.string   "UserIP",                   :limit => 64
        t.integer  "UserAtStop"
      end
    end
  end

  def self.down
    # drop all the tables if you really need
    # to support migration back to version 0
    drop_table "stopinfo_dev"
  end
end

