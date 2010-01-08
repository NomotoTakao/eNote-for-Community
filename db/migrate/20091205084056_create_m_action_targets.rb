class CreateMActionTargets < ActiveRecord::Migration
  def self.up
    create_table :m_action_targets do |t|
      t.string   "action_target_cd",      :limit => 4,  :null => false
      t.string   "action_target_name",    :limit => 40
      t.integer  "sort_no",          :default => 1
      t.text     "memo"
      t.integer  "etcint1",                                                                :default => 0
      t.integer  "etcint2",                                                                :default => 0
      t.integer  "etcdec1",                  :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",                  :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",                  :limit => 200
      t.string   "etcstr2",                  :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",                     :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd",          :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd",          :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd",          :limit => 32
      t.datetime "updated_at"
    end
    add_index "m_action_targets", ["action_target_cd"], :name => "idx_m_action_targets_1"
  end

  def self.down
    drop_table :m_action_targets
  end
end
