class CreateDNoticeFiles < ActiveRecord::Migration
  def self.up
    create_table "d_notice_files", :force => true do |t|
      t.integer  "d_notice_head_id",                                                               :null => false
      t.integer  "d_notice_body_id",                                                              :null => false
      t.string   "post_org_cd",        :limit => 9
      t.string   "post_user_cd",       :limit => 32
      t.string   "post_user_name",     :limit => 40
      t.datetime "post_date"
      t.string   "title",              :limit => 40
      t.text     "memo"
      t.date     "enable_date_to"
      t.string   "file_name"
      t.string   "real_file_name"
      t.integer  "file_size",          :limit => 8,                                  :default => 0
      t.string   "mime_type"
      t.integer  "etcint1",                                                          :default => 0
      t.integer  "etcint2",                                                          :default => 0
      t.integer  "etcdec1",            :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",            :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",            :limit => 200
      t.string   "etcstr2",            :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",               :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd",    :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd",    :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd",    :limit => 32
      t.datetime "updated_at"
    end

    add_index "d_notice_files", ["d_notice_body_id", "d_notice_head_id"], :name => "idx_d_notice_files_1"
  end

  def self.down
    drop_table :d_notice_files
  end
end
