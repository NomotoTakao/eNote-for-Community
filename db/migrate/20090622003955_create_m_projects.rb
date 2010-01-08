class CreateMProjects < ActiveRecord::Migration
  def self.up
    create_table "m_projects", :force => true do |t|
      t.string   "name",             :limit => 80,                                                :null => false
      t.string   "name_short",       :limit => 32
      t.date     "enable_date_from",                                                              :null => false
      t.date     "enable_date_to",                                                                :null => false
      t.integer  "enable_flg",       :limit => 2,                                  :default => 0
      t.text     "memo"
      t.integer  "etcint1",                                                        :default => 0
      t.integer  "etcint2",                                                        :default => 0
      t.integer  "etcdec1",          :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",          :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",          :limit => 200
      t.string   "etcstr2",          :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",             :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd",  :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd",  :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd",  :limit => 32
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :m_projects
  end
end
