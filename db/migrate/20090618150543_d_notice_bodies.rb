class DNoticeBodies < ActiveRecord::Migration
  def self.up
    create_table "d_notice_bodies", :force => true do |t|
      t.integer  "d_notice_head_id",                                                                :null => false
      t.string   "post_org_cd",       :limit => 9
      t.string   "post_user_cd",      :limit => 32
      t.string   "post_user_name",    :limit => 40
      t.datetime "post_date"
      t.string   "title",             :limit => 40
      t.text     "body"
      t.string   "public_org_cd",     :limit => 9,                                  :default => "0"
      t.integer  "public_flg",        :limit => 2,                                  :default => 0
      t.date     "public_date_from"
      t.date     "public_date_to"
      t.integer  "top_disp_kbn",      :limit => 2,                                  :default => 99
      t.integer  "hottopic_flg",      :limit => 2,                                  :default => 1
      t.text     "meta_tag"
      t.text     "attach_file"
      t.integer  "etcint1",                                                         :default => 0
      t.integer  "etcint2",                                                         :default => 0
      t.integer  "etcdec1",           :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",           :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",           :limit => 200
      t.string   "etcstr2",           :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",              :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd",   :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd",   :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd",   :limit => 32
      t.datetime "updated_at"
    end

    add_index "d_notice_bodies", ["d_notice_head_id", "public_flg", "public_org_cd"], :name => "idx_d_notice_bodies_2"
    add_index "d_notice_bodies", ["d_notice_head_id"], :name => "idx_d_notice_bodies_1"
    add_index "d_notice_bodies", ["hottopic_flg"], :name => "idx_d_notice_bodies_4"
    add_index "d_notice_bodies", ["top_disp_kbn"], :name => "idx_d_notice_bodies_3"

  end

  def self.down
    drop_table :d_notice_bodies
  end
end
