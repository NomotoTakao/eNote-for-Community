class CreateDScheduleAuths < ActiveRecord::Migration
  def self.up
    create_table "d_schedule_auths", :force => true do |t|
      t.integer  "d_schedule_id",                                               :default => 0, :null => false
      t.string   "org_cd",         :limit => 9
      t.string   "user_cd",        :limit => 32
      t.integer  "project_id"
      t.integer  "auth_kbn",       :limit => 2,                                  :default => 1
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

    add_index "d_schedule_auths", ["d_schedule_id"], :name => "idx_d_schedule_auths_1"

  end

  def self.down
    drop_table :d_schedule_auths
  end
end
