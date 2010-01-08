class CreateDReserves < ActiveRecord::Migration
  def self.up
    create_table "d_reserves", :force => true do |t|
      t.string   "facility_cd",       :limit => 16,                                                :null => false
      t.string   "place_cd",          :limit => 16
      t.string   "org_cd",            :limit => 9,                                                 :null => false
      t.string   "title",             :limit => 80,                                                :null => false
      t.string   "reserve_org_cd",    :limit => 9
      t.string   "reserve_user_cd",   :limit => 32,                                                :null => false
      t.string   "reserve_user_name", :limit => 40
      t.integer  "plan_allday_flg",   :limit => 2,                                  :default => 0
      t.date     "plan_date_from"
      t.time     "plan_time_from"
      t.date     "plan_date_to"
      t.time     "plan_time_to"
      t.text     "memo"
      t.integer  "d_schedule_id"
      t.integer  "repeat_facility_id"
      t.integer  "repeat_flg",         :limit => 2,                                  :default => 0
      t.date     "repeat_date_to"
      t.integer  "repeat_interval_flg", :limit => 2,                                 :default => 0
      t.integer  "repeat_month_value", :limit => 2,                                  :default => 0
      t.integer  "repeat_week_sun_flg", :limit => 2,                                 :default => 0
      t.integer  "repeat_week_mon_flg", :limit => 2,                                 :default => 0
      t.integer  "repeat_week_tue_flg", :limit => 2,                                 :default => 0
      t.integer  "repeat_week_wed_flg", :limit => 2,                                 :default => 0
      t.integer  "repeat_week_thu_flg", :limit => 2,                                 :default => 0
      t.integer  "repeat_week_fri_flg", :limit => 2,                                 :default => 0
      t.integer  "repeat_week_sat_flg", :limit => 2,                                 :default => 0
      t.integer  "etcint1",                                                         :default => 0
      t.integer  "etcint2",                                                         :default => 0
      t.integer  "etcdec1",           :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",           :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",           :limit => 200
      t.string   "etcstr2",           :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",              :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd",   :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd",   :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd",   :limit => 32
      t.datetime "updated_at"
    end
    add_index "d_reserves", ["facility_cd"], :name => "idx_d_reserves_1"
    add_index "d_reserves", ["org_cd"], :name => "idx_d_reserves_2"
    add_index "d_reserves", ["plan_date_from", "plan_date_to", "reserve_user_cd"], :name => "idx_d_reserves_3"

  end

  def self.down
    drop_table :d_reserves
  end
end
