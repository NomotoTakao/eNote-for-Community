class CreateDLogs < ActiveRecord::Migration
  def self.up
    create_table :d_logs do |t|
      t.string :table_name        ,:limit => 50
      t.string :manipulate_name   ,:limit => 200
      t.integer :manipulate_id
      t.integer  "etcint1",          :default => 0
      t.integer  "etcint2",          :default => 0
      t.string   "etcstr1",          :limit => 200
      t.string   "etcstr2",          :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.string   "created_user_cd",  :limit => 32
      t.datetime "created_at"
    end
  end

  def self.down
    drop_table :d_logs
  end
end
