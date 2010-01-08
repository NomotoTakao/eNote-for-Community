class MOrgs < ActiveRecord::Migration
  def self.up
    create_table "m_orgs", :force => true do |t|
      t.string   "org_cd",      :limit => 9,                                                 :null => false
      t.integer  "org_lvl",     :limit => 2,                                  :default => 1
      t.string   "org_cd1",     :limit => 2
      t.string   "org_cd2",     :limit => 2
      t.string   "org_cd3",     :limit => 2
      t.string   "org_cd4",     :limit => 3
      t.string   "org_name1",   :limit => 20
      t.string   "org_name2",   :limit => 20
      t.string   "org_name3",   :limit => 20
      t.string   "org_name4",   :limit => 20
      t.string   "place_cd",   :limit => 16
      t.integer  "sort_no",                                                   :default => 0
      t.string   "tel",                        :limit => 20
      t.string   "fax",                        :limit => 20
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

    add_index "m_orgs", ["org_cd"], :name => "idx_m_orgs_1"
  end

  def self.down
    drop_table :m_orgs
  end
end
