class CreateMUserAttributes < ActiveRecord::Migration
  def self.up
    create_table "m_user_attributes", :force => true do |t|
      t.string   "user_cd",       :limit => 32,                                                 :null => false
      t.string   "name_kana",     :limit => 40
      t.string   "position_cd",   :limit => 8
      t.integer  "job_kbn"
      t.integer  "authority_kbn"
      t.string   "place_cd",      :limit => 16
      t.date     "joined_date"
      t.text     "memo"
      t.integer  "director_flg",  :default=>0
      t.integer  "sort_no",       :default=>0
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

    add_index "m_user_attributes", ["user_cd"], :name => "idx_m_user_attributes_1"  end

  def self.down
    drop_table :m_user_attributes
  end
end
