class CreateDRssLeafs < ActiveRecord::Migration
  def self.up
    create_table "d_rss_leaves", :force => true do |t|
      t.integer  "d_rss_trunk_id",                                                                :null => false
      t.string   "leaf_id",         :limit => 64
      t.text     "url",                                                           :default => "0"
      t.text     "content"
      t.text     "title"
      t.datetime "publish"
      t.integer  "etcint1",                                                       :default => 0
      t.integer  "etcint2",                                                       :default => 0
      t.integer  "etcdec1",         :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",         :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",         :limit => 200
      t.string   "etcstr2",         :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",            :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd", :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd", :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd", :limit => 32
      t.datetime "updated_at"
    end

    add_index "d_rss_leaves", ["d_rss_trunk_id", "leaf_id"], :name => "idx_d_rss_leaves_2"
    add_index "d_rss_leaves", ["d_rss_trunk_id"], :name => "idx_d_rss_leaves_1"

  end

  def self.down
    drop_table :d_rss_leafs
  end
end
