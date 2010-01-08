class CreateDBlogBodies < ActiveRecord::Migration
  def self.up
    create_table "d_blog_bodies", :force => true do |t|
      t.integer  "d_blog_head_id",                                                               :null => false
      t.datetime "post_date"
      t.string   "title",            :limit => 80
      t.text     "body"
      t.integer  "public_flg",       :limit => 2,                                  :default => 0
      t.integer  "top_disp_kbn",     :limit => 2,                                  :default => 9
      t.text     "attach_file"
      t.integer  "etcint1",                                                        :default => 0
      t.integer  "etcint2",                                                        :default => 0
      t.integer  "etcdec1",          :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",          :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",          :limit => 200
      t.string   "etcstr2",          :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",             :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd",  :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd",  :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd",  :limit => 32
      t.datetime "updated_at"
    end
    
    add_index "d_blog_bodies", ["d_blog_head_id"], :name => "idx_d_blog_articles_1"
  end
  
  def self.down
    drop_table :d_blog_bodies
  end
end
