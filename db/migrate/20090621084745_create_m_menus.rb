class CreateMMenus < ActiveRecord::Migration
  def self.up
    create_table "m_menus", :force => true do |t|
      t.integer  "parent_menu_id",                                                                 :null => false
      t.integer  "sort_no",        :limit => 2,                                  :default => 1
      t.string   "title",          :limit => 32
      t.string   "url",            :limit => 255
      t.string   "target",         :limit => 20
      t.integer  "menu_kbn",       :limit => 2,                                  :default => 0
      t.integer  "folder_flg",     :limit => 2,                                  :default => 0
      t.integer  "public_flg",     :limit => 2,                                  :default => 0
      t.string   "app_cd",         :limit => 16,                                 :default => "0"
      t.string   "icon",           :limit => 64
      t.text     "memo"
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
    add_index "m_menus", ["parent_menu_id"], :name => "idx_m_menus_1"

  end

  def self.down
    drop_table :m_menus
  end
end
