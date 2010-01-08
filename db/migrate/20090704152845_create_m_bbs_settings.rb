class CreateMBbsSettings < ActiveRecord::Migration
  def self.up
    create_table "m_bbs_settings", :force => true do |t|
      t.string   "app_cd",         :limit => 16,                                 :default => "0", :null => false
      t.integer  "new_icon_days",  :limit => 2,                                  :default => 5
      t.integer  "page_max_count",                                               :default => 10
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
  end

  def self.down
    drop_table :m_bbs_settings
  end
end
