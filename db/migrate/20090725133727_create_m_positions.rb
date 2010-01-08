class CreateMPositions < ActiveRecord::Migration
  def self.up
    create_table :m_positions do |t|
      t.string   "position_cd",       :limit => 8,  :null => false
      t.string   "name",       :limit => 30,  :null => false
      t.integer  "rank",    :limit => 2,   :default => 99,  :null => false
      t.integer  "sort_no",     :limit => 2,                                  :default => 1
      t.text     "memo"
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
    add_index "m_positions", ["position_cd"], :name => "idx_m_positions_1"
  end

  def self.down
    drop_table :m_positions
  end
end
