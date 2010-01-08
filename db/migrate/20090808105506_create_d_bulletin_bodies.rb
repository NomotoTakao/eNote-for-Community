class CreateDBulletinBodies < ActiveRecord::Migration
  def self.up
    create_table "d_bulletin_bodies", :force => true do |t|
      t.integer  "d_bulletin_head_id",                                                              :null => false
      t.string   "user_cd",             :limit => 32,                                                :null => false
      t.integer  "answer_kbn",          :limit => 2,                                  :default => 0
      t.datetime "answer_date"
      t.text     "comment"
      t.integer  "etcint1",                                                           :default => 0
      t.integer  "etcint2",                                                           :default => 0
      t.integer  "etcdec1",             :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",             :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",             :limit => 200
      t.string   "etcstr2",             :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",                :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd",     :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd",     :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd",     :limit => 32
      t.datetime "updated_at"
    end
    
    add_index "d_bulletin_bodies", ["d_bulletin_head_id"], :name => "idx_d_bulletin_bodies_1"
    add_index "d_bulletin_bodies", ["user_cd"], :name => "idx_d_bulletin_bodies_2"
  end
  
  def self.down
    drop_table :d_bulletin_bodies
  end
end
