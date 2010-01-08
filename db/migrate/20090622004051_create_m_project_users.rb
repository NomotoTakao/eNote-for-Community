class CreateMProjectUsers < ActiveRecord::Migration
  def self.up
    create_table "m_project_users", :force => true do |t|
      t.integer  "project_id",                                                               :null => false
      t.string   "user_cd",     :limit => 32,                                                :null => false
      t.integer  "admin_flg",   :limit => 2,                                  :default => 0
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

    add_index "m_project_users", ["project_id"], :name => "idx_m_project_users_1"
    add_index "m_project_users", ["user_cd"], :name => "idx_m_project_users_2"

  end

  def self.down
    drop_table :m_project_users
  end
end
