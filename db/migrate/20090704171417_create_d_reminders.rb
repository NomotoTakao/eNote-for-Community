class CreateDReminders < ActiveRecord::Migration
  def self.up
    create_table "d_reminders", :force => true do |t|
      t.string   "user_cd",        :limit => 32,                                                  :null => false
      t.integer  "d_schedule_id",                                               :default => 0
      t.integer  "reminder_kbn",   :limit => 2,                                  :default => 0
      t.datetime "notice_date_from"
      t.datetime "notice_date_to"
      t.string   "title",          :limit => 60,                                 :default => "1"
      t.text     "body"
      t.integer  "etcint1",                                                      :default => 0
      t.integer  "etcint2",                                                      :default => 0
      t.integer  "etcdec1",        :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",        :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",        :limit => 200
      t.string   "etcstr2",        :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",           :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd", :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd", :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd", :limit => 32
      t.datetime "updated_at"
    end

    add_index "d_reminders", ["d_schedule_id"], :name => "idx_d_reminders_1"
    add_index "d_reminders", ["notice_date_from"], :name => "idx_d_reminders_2"
    add_index "d_reminders", ["user_cd"], :name => "idx_d_reminders_3"

  end

  def self.down
    drop_table :d_reminders
  end
end
