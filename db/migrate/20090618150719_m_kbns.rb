class MKbns < ActiveRecord::Migration
  def self.up
    create_table "m_kbns", :force => true do |t|
      t.string   "kbn_cd",      :limit => 64,                                                :null => false
      t.integer  "kbn_id",                                                                   :null => false
      t.string   "name",        :limit => 40,                                                :null => false
      t.string   "name_short",  :limit => 20
      t.string   "name_kana",   :limit => 40
      t.integer  "value_int"
      t.string   "value_chr",   :limit => 20
      t.integer  "disp_flg",    :limit => 2,                                  :default => 0
      t.integer  "sort_no",     :limit => 2,                                  :default => 1
      t.text     "notes"
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

    add_index "m_kbns", ["kbn_cd", "kbn_id"], :name => "idx_m_kbns_2"
    add_index "m_kbns", ["kbn_cd"], :name => "idx_m_kbns_1"
  end

  def self.down
    drop_table :m_kbns
  end
end
