class CreateDMessages < ActiveRecord::Migration
  def self.up
    create_table "d_messages", :force => true do |t|
      t.string   "user_cd",        :limit => 32,                                                :null => false
      t.integer  "message_kbn",    :limit => 2,                                  :default => 0
      t.string   "from_user_cd",   :limit => 32
      t.string   "from_user_name", :limit => 40
      t.string   "title",          :limit => 80
      t.datetime "post_date"
      t.text     "body"
      t.text     "params"
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
    
    add_index "d_messages", ["message_kbn", "user_cd"], :name => "idx_d_messages_2"
    add_index "d_messages", ["user_cd"], :name => "idx_d_messages_1"
    
  end
  
  def self.down
    drop_table :d_messages
  end
end
