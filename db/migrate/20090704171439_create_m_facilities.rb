class CreateMFacilities < ActiveRecord::Migration
  def self.up
    create_table "m_facilities", :force => true do |t|
      t.string   "facility_cd", :limit => 16,                                                 :null => false
      t.string   "facility_group_cd", :limit => 16,                                           :null => false
      t.string   "place_cd",          :limit => 16,                                           :null => false
      t.string   "org_cd",      :limit => 9,                          :default => "0", :null => false
      t.string   "name",        :limit => 80,                                 :default => "", :null => false
      t.integer  "facility_kbn",     :limit => 2
      t.integer  "sort_no",     :limit => 2,                                  :default => 1
      t.text     "memo"
      t.integer  "enable_flg",  :limit => 2,                                  :default => 0
      t.integer  "etcint1",                                                   :default => 0
      t.integer  "etcint2",                                                   :default => 0
      t.integer  "etcdec1",     :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",     :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",     :limit => 200
      t.string   "etcstr2",     :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",        :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd", :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd", :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd", :limit => 32
      t.datetime "updated_at"
    end

    add_index "m_facilities", ["facility_cd"], :name => "idx_m_facilities_1"
  end

  def self.down
    drop_table :m_facilities
  end
end
