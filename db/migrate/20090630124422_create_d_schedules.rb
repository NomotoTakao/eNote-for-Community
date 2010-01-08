class CreateDSchedules < ActiveRecord::Migration
  def self.up
    create_table "d_schedules", :force => true do |t|
      t.string   "user_cd",            :limit => 32,                                                :null => false
      t.string   "title",              :limit => 80,                                                :null => false
      t.integer  "plan_allday_flg",    :limit => 2,                                  :default => 0
      t.date     "plan_date_from"
      t.time     "plan_time_from"
      t.date     "plan_date_to"
      t.time     "plan_time_to"
      t.string   "place",              :limit => 128
      t.text     "memo"
      t.integer  "public_kbn",         :limit => 2,                                  :default => 0
      t.integer  "plan_kbn",                                                         :default => 0
      t.integer  "invite_id",                                                        :default => 0
      t.integer  "invite_flg",         :limit => 2,                                  :default => 0
      t.string   "invite_user_cd",     :limit => 32
      t.string   "invite_user_name",   :limit => 40
      t.text     "invite_comment"
      t.integer  "invite_checked_index",                                             :default => 0
      t.string   "invite_checked_cd",  :limit => 9
      t.integer  "repeat_schedule_id"
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
      t.integer  "reminder_flg",       :limit => 2,                                  :default => 0
      t.integer  "reminder_day_flg",   :limit => 2,                                  :default => 0
      t.integer  "reminder_day_value", :limit => 2,                                  :default => 0
      t.integer  "reminder_week_flg",  :limit => 2,                                  :default => 0
      t.integer  "reminder_week_value", :limit => 2,                                 :default => 0
      t.integer  "reminder_month_flg", :limit => 2,                                  :default => 0
      t.integer  "reminder_month_value", :limit => 2,                                :default => 0
      t.integer  "reminder_specify_flg", :limit => 2,                                :default => 0
      t.date     "reminder_specify_date"
      t.integer  "reminder_mypage_flg", :limit => 2,                                 :default => 0
      t.integer  "reminder_email_flg", :limit => 2,                                  :default => 0
      t.integer  "reminder_mobile_mail_flg", :limit => 2,                            :default => 0
      t.string   "secretary_cd",       :limit => 32
      t.integer  "etcint1",                                                          :default => 0
      t.integer  "etcint2",                                                          :default => 0
      t.integer  "etcdec1",            :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",            :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",            :limit => 200
      t.string   "etcstr2",            :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",               :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd",    :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd",    :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd",    :limit => 32
      t.datetime "updated_at"
    end

    add_index "d_schedules", ["plan_date_from", "plan_date_to", "user_cd"], :name => "idx_d_schedules_2"
    add_index "d_schedules", ["repeat_schedule_id"], :name => "idx_d_schedules_3"
    add_index "d_schedules", ["user_cd"], :name => "idx_d_schedules_1"
  end

  def self.down
    drop_table :d_schedules
  end
end
