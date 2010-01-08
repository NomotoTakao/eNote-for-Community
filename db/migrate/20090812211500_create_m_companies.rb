class CreateMCompanies < ActiveRecord::Migration
  def self.up
    create_table :m_companies do |t|
      t.string   "term_end1",       :limit => 4,  :null => false,               :default => ""
      t.string   "term_end2",       :limit => 4,                                :default => ""
      t.string   "term_end3",       :limit => 4,                                :default => ""
      t.string   "term_end4",       :limit => 4,                                :default => ""
      t.string   "scroll_text",     :limit => 200,                              :default => ""
      t.integer  "etcint1",                                                     :default => 0
      t.integer  "etcint2",                                                     :default => 0
      t.integer  "etcdec1",       :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",       :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",       :limit => 200
      t.string   "etcstr2",       :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",          :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd", :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd", :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd", :limit => 32
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :m_companies
  end
end
