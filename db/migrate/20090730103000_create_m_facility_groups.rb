class CreateMFacilityGroups < ActiveRecord::Migration
  def self.up
  create_table "m_facility_groups", :force => true do |t|
    t.string   "facility_group_cd",  :limit => 16,             :null => false
    t.string   "name",         :limit => 80,  :default => "",  :null => false
    t.integer  "sort_no",      :limit => 2,   :default => 1
    t.integer  "etcint1",                     :default => 0
    t.integer  "etcint2",                     :default => 0
    t.integer  "etcdec1",                     :default => 0
    t.integer  "etcdec2",                     :default => 0
    t.string   "etcstr1",      :limit => 200
    t.string   "etcstr2",      :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",         :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_facility_groups", ["facility_group_cd"], :name => "idx_m_facility_groups_1"

  end

  def self.down
    drop_table :m_facility_groups
  end
end
