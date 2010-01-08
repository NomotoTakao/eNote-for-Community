# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 21091810000000) do

  create_table "d_address_group_lists", :force => true do |t|
    t.string   "private_user_cd",    :limit => 32,                 :null => false
    t.integer  "d_address_group_id",                               :null => false
    t.integer  "d_address_id",                                     :null => false
    t.integer  "etcint1",                           :default => 0
    t.integer  "etcint2",                           :default => 0
    t.integer  "etcdec1",                           :default => 0
    t.integer  "etcdec2",                           :default => 0
    t.string   "etcstr1",            :limit => 200
    t.string   "etcstr2",            :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",               :limit => 2,   :default => 0
    t.string   "deleted_user_cd",    :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",    :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",    :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_address_group_lists", ["d_address_group_id", "private_user_cd"], :name => "idx_d_address_group_lists_1"

  create_table "d_address_groups", :force => true do |t|
    t.string   "private_user_cd", :limit => 32
    t.string   "title",           :limit => 20
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd"
    t.datetime "updated_at"
  end

  add_index "d_address_groups", ["private_user_cd"], :name => "idx_d_address_groups_1"

  create_table "d_addresses", :force => true do |t|
    t.integer  "address_kbn",          :limit => 2,   :default => 9, :null => false
    t.string   "user_cd",              :limit => 32
    t.string   "company_cd",           :limit => 16
    t.string   "private_user_cd",      :limit => 32
    t.string   "name",                 :limit => 40
    t.string   "name_kana",            :limit => 40
    t.string   "email_name",           :limit => 40
    t.string   "email_address1",       :limit => 128
    t.string   "email_address2",       :limit => 128
    t.string   "email_address3",       :limit => 128
    t.string   "zip_cd",               :limit => 8
    t.string   "address1",             :limit => 60
    t.string   "address2",             :limit => 60
    t.text     "address3"
    t.string   "tel",                  :limit => 20
    t.string   "fax",                  :limit => 20
    t.string   "mobile_no",            :limit => 20
    t.string   "mobile_address",       :limit => 128
    t.string   "mobile_company",       :limit => 10
    t.string   "mobile_kind",          :limit => 20
    t.string   "homepage_url"
    t.date     "birthday"
    t.string   "memorial_name1",       :limit => 40
    t.date     "memorial_date1"
    t.string   "memorial_name2",       :limit => 40
    t.date     "memorial_date2"
    t.string   "memorial_name3",       :limit => 40
    t.date     "memorial_date3"
    t.string   "company_name",         :limit => 100
    t.string   "company_name_kana",    :limit => 100
    t.string   "company_post",         :limit => 100
    t.string   "company_job",          :limit => 40
    t.string   "company_zip_cd",       :limit => 8
    t.string   "company_address1",     :limit => 60
    t.string   "company_address2",     :limit => 60
    t.text     "company_address3"
    t.string   "company_tel1",         :limit => 20
    t.string   "company_tel2",         :limit => 20
    t.string   "company_fax",          :limit => 20
    t.string   "company_homepage_url"
    t.text     "meta_tag"
    t.text     "memo"
    t.integer  "etcint1",                             :default => 0
    t.integer  "etcint2",                             :default => 0
    t.integer  "etcdec1",                             :default => 0
    t.integer  "etcdec2",                             :default => 0
    t.string   "etcstr1",              :limit => 200
    t.string   "etcstr2",              :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                 :limit => 2,   :default => 0
    t.string   "deleted_user_cd",      :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",      :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",      :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_addresses", ["address_kbn", "company_cd"], :name => "idx_d_addresses_2"
  add_index "d_addresses", ["address_kbn", "private_user_cd"], :name => "idx_d_addresses_3"
  add_index "d_addresses", ["address_kbn", "user_cd"], :name => "idx_d_addresses_1"
  add_index "d_addresses", ["email_address1", "email_address2", "email_address3", "mobile_address"], :name => "idx_d_addresses_4"

  create_table "d_bbs_auths", :force => true do |t|
    t.integer  "d_bbs_board_id",                 :default => 0, :null => false
    t.string   "org_cd",          :limit => 9
    t.string   "user_cd",         :limit => 32
    t.integer  "auth_kbn",        :limit => 2,   :default => 1
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_bbs_auths", ["d_bbs_board_id", "org_cd"], :name => "idx_d_bbs_auths_1"
  add_index "d_bbs_auths", ["d_bbs_board_id", "user_cd"], :name => "idx_d_bbs_auths_2"

  create_table "d_bbs_boards", :force => true do |t|
    t.string   "title",            :limit => 40
    t.integer  "lastpost_body_id"
    t.datetime "lastpost_date"
    t.string   "url"
    t.text     "memo"
    t.integer  "sort_no",          :limit => 8,   :default => 0
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  create_table "d_bbs_comments", :force => true do |t|
    t.integer  "d_bbs_board_id",                                :null => false
    t.integer  "d_bbs_thread_id",                               :null => false
    t.string   "post_user_cd",    :limit => 32
    t.string   "post_user_name",  :limit => 40
    t.datetime "post_date"
    t.text     "body"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_bbs_comments", ["d_bbs_board_id", "d_bbs_thread_id"], :name => "idx_d_bbs_comments_1"

  create_table "d_bbs_files", :force => true do |t|
    t.integer  "d_bbs_board_id",                                :null => false
    t.integer  "d_bbs_thread_id",                               :null => false
    t.string   "post_user_cd",    :limit => 32
    t.string   "post_user_name",  :limit => 40
    t.datetime "post_date"
    t.string   "title",           :limit => 40
    t.text     "memo"
    t.date     "enable_date_to"
    t.string   "file_name"
    t.string   "real_file_name"
    t.integer  "file_size",       :limit => 8,   :default => 0
    t.string   "mime_type"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_bbs_files", ["d_bbs_board_id", "d_bbs_thread_id"], :name => "idx_d_bbs_files_1"

  create_table "d_bbs_threads", :force => true do |t|
    t.integer  "d_bbs_board_id",                                   :null => false
    t.string   "post_user_cd",     :limit => 32
    t.string   "post_user_name",   :limit => 40
    t.datetime "post_date"
    t.string   "title",            :limit => 40
    t.text     "body"
    t.string   "public_org_cd",    :limit => 9,   :default => "0"
    t.integer  "public_flg",       :limit => 2,   :default => 0
    t.date     "public_date_from"
    t.date     "public_date_to"
    t.text     "meta_tag"
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_bbs_threads", ["d_bbs_board_id"], :name => "idx_d_bbs_threads_1"

  create_table "d_blog_bodies", :force => true do |t|
    t.integer  "d_blog_head_id",                                :null => false
    t.datetime "post_date"
    t.string   "title",           :limit => 80
    t.text     "body"
    t.integer  "public_flg",      :limit => 2,   :default => 0
    t.integer  "top_disp_kbn",    :limit => 2,   :default => 9
    t.text     "attach_file"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_blog_bodies", ["d_blog_head_id"], :name => "idx_d_blog_articles_1"

  create_table "d_blog_favorites", :force => true do |t|
    t.string   "user_cd",         :limit => 32,  :default => "0", :null => false
    t.integer  "d_blog_head_id",                 :default => 0,   :null => false
    t.integer  "order_display",                  :default => -1
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  create_table "d_blog_heads", :force => true do |t|
    t.string   "title",                :limit => 40
    t.string   "user_cd",              :limit => 32
    t.string   "user_name",            :limit => 40
    t.integer  "lastpost_body_id"
    t.datetime "lastpost_date"
    t.string   "url"
    t.text     "description"
    t.integer  "default_top_disp_kbn", :limit => 2,   :default => 9
    t.integer  "etcint1",                             :default => 0
    t.integer  "etcint2",                             :default => 0
    t.integer  "etcdec1",                             :default => 0
    t.integer  "etcdec2",                             :default => 0
    t.string   "etcstr1",              :limit => 200
    t.string   "etcstr2",              :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                 :limit => 2,   :default => 0
    t.string   "deleted_user_cd",      :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",      :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",      :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_blog_heads", ["user_cd"], :name => "idx_d_blog_heads_1"

  create_table "d_blog_tags", :force => true do |t|
    t.integer  "d_blog_body_id",                 :default => 0, :null => false
    t.string   "category"
    t.integer  "count",                          :default => 0
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  create_table "d_bookmark_categories", :force => true do |t|
    t.string   "title",           :limit => 128
    t.integer  "sort_no",         :limit => 2,   :default => 1
    t.integer  "public_flg",      :limit => 2,   :default => 0
    t.text     "memo"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  create_table "d_bookmarks", :force => true do |t|
    t.integer  "d_bookmark_category_id",                               :null => false
    t.integer  "sort_no",                :limit => 2,   :default => 1
    t.string   "title",                  :limit => 128
    t.string   "url"
    t.integer  "public_flg",             :limit => 2,   :default => 0
    t.text     "memo"
    t.integer  "etcint1",                               :default => 0
    t.integer  "etcint2",                               :default => 0
    t.integer  "etcdec1",                               :default => 0
    t.integer  "etcdec2",                               :default => 0
    t.string   "etcstr1",                :limit => 200
    t.string   "etcstr2",                :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                   :limit => 2,   :default => 0
    t.string   "deleted_user_cd",        :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",        :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",        :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_bookmarks", ["d_bookmark_category_id"], :name => "idx_d_bookmarks_1"

  create_table "d_bulletin_bodies", :force => true do |t|
    t.integer  "d_bulletin_head_id",                               :null => false
    t.string   "user_cd",            :limit => 32,                 :null => false
    t.integer  "answer_kbn",         :limit => 2,   :default => 0
    t.datetime "answer_date"
    t.text     "comment"
    t.integer  "etcint1",                           :default => 0
    t.integer  "etcint2",                           :default => 0
    t.integer  "etcdec1",                           :default => 0
    t.integer  "etcdec2",                           :default => 0
    t.string   "etcstr1",            :limit => 200
    t.string   "etcstr2",            :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",               :limit => 2,   :default => 0
    t.string   "deleted_user_cd",    :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",    :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",    :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_bulletin_bodies", ["d_bulletin_head_id"], :name => "idx_d_bulletin_bodies_1"
  add_index "d_bulletin_bodies", ["user_cd"], :name => "idx_d_bulletin_bodies_2"

  create_table "d_bulletin_files", :force => true do |t|
    t.integer  "d_bulletin_head_id",                               :null => false
    t.string   "post_user_cd",       :limit => 32
    t.datetime "post_date"
    t.date     "enable_date_to"
    t.string   "file_name"
    t.string   "real_file_name"
    t.integer  "file_size",          :limit => 8,   :default => 0
    t.string   "mime_type"
    t.integer  "etcint1",                           :default => 0
    t.integer  "etcint2",                           :default => 0
    t.integer  "etcdec1",                           :default => 0
    t.integer  "etcdec2",                           :default => 0
    t.string   "etcstr1",            :limit => 200
    t.string   "etcstr2",            :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",               :limit => 2,   :default => 0
    t.string   "deleted_user_cd",    :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",    :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",    :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_bulletin_files", ["d_bulletin_head_id"], :name => "idx_d_bulletin_files_1"

  create_table "d_bulletin_heads", :force => true do |t|
    t.string   "title",              :limit => 40,                 :null => false
    t.string   "post_user_cd",       :limit => 32
    t.string   "post_user_name",     :limit => 40
    t.date     "bulletin_date_from"
    t.date     "bulletin_date_to"
    t.text     "body"
    t.integer  "answer_public_kbn",  :limit => 2,   :default => 1
    t.integer  "etcint1",                           :default => 0
    t.integer  "etcint2",                           :default => 0
    t.integer  "etcdec1",                           :default => 0
    t.integer  "etcdec2",                           :default => 0
    t.string   "etcstr1",            :limit => 200
    t.string   "etcstr2",            :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",               :limit => 2,   :default => 0
    t.string   "deleted_user_cd",    :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",    :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",    :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_bulletin_heads", ["post_user_cd"], :name => "idx_d_bulletin_heads_1"

  create_table "d_cabinet_auths", :force => true do |t|
    t.integer  "d_cabinet_head_id",                :default => 0, :null => false
    t.string   "org_cd",            :limit => 9
    t.string   "user_cd",           :limit => 32
    t.integer  "auth_kbn",          :limit => 2,   :default => 1
    t.integer  "etcint1",                          :default => 0
    t.integer  "etcint2",                          :default => 0
    t.integer  "etcdec1",                          :default => 0
    t.integer  "etcdec2",                          :default => 0
    t.string   "etcstr1",           :limit => 200
    t.string   "etcstr2",           :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",              :limit => 2,   :default => 0
    t.string   "deleted_user_cd",   :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",   :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",   :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_cabinet_auths", ["d_cabinet_head_id", "org_cd"], :name => "idx_d_cabinet_auths_1"
  add_index "d_cabinet_auths", ["d_cabinet_head_id", "user_cd"], :name => "idx_d_cabinet_auths_2"

  create_table "d_cabinet_bodies", :force => true do |t|
    t.integer  "d_cabinet_head_id",                                 :null => false
    t.string   "post_org_cd",       :limit => 9
    t.string   "post_user_cd",      :limit => 32
    t.string   "post_user_name",    :limit => 40
    t.datetime "post_date"
    t.string   "title",             :limit => 40
    t.text     "body"
    t.string   "public_org_cd",     :limit => 9,   :default => "0"
    t.integer  "public_flg",        :limit => 2,   :default => 0
    t.date     "public_date_from"
    t.date     "public_date_to"
    t.text     "meta_tag"
    t.integer  "etcint1",                          :default => 0
    t.integer  "etcint2",                          :default => 0
    t.integer  "etcdec1",                          :default => 0
    t.integer  "etcdec2",                          :default => 0
    t.string   "etcstr1",           :limit => 200
    t.string   "etcstr2",           :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",              :limit => 2,   :default => 0
    t.string   "deleted_user_cd",   :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",   :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",   :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_cabinet_bodies", ["d_cabinet_head_id"], :name => "idx_d_cabinet_bodies_1"
  add_index "d_cabinet_bodies", ["public_org_cd"], :name => "idx_d_cabinet_bodies_2"

  create_table "d_cabinet_files", :force => true do |t|
    t.integer  "d_cabinet_head_id",                               :null => false
    t.integer  "d_cabinet_body_id",                :default => 0, :null => false
    t.string   "post_org_cd",       :limit => 9
    t.string   "post_user_cd",      :limit => 32
    t.string   "post_user_name",    :limit => 40
    t.datetime "post_date"
    t.string   "title",             :limit => 40
    t.text     "memo"
    t.date     "enable_date_to"
    t.string   "file_name"
    t.string   "real_file_name"
    t.integer  "file_size",         :limit => 8,   :default => 0
    t.string   "mime_type"
    t.integer  "etcint1",                          :default => 0
    t.integer  "etcint2",                          :default => 0
    t.integer  "etcdec1",                          :default => 0
    t.integer  "etcdec2",                          :default => 0
    t.string   "etcstr1",           :limit => 200
    t.string   "etcstr2",           :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",              :limit => 2,   :default => 0
    t.string   "deleted_user_cd",   :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",   :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",   :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_cabinet_files", ["d_cabinet_body_id", "d_cabinet_head_id"], :name => "idx_d_cabinet_files_1"

  create_table "d_cabinet_heads", :force => true do |t|
    t.string   "title",              :limit => 40,                 :null => false
    t.integer  "cabinet_kbn",        :limit => 2,   :default => 0
    t.string   "private_user_cd",    :limit => 32
    t.string   "private_org_cd",     :limit => 9
    t.integer  "private_project_id"
    t.integer  "default_enable_day", :limit => 2,   :default => 0
    t.integer  "lastpost_body_id"
    t.datetime "lastpost_date"
    t.string   "url"
    t.integer  "max_disk_size",                     :default => 0
    t.text     "description"
    t.integer  "etcint1",                           :default => 0
    t.integer  "etcint2",                           :default => 0
    t.integer  "etcdec1",                           :default => 0
    t.integer  "etcdec2",                           :default => 0
    t.string   "etcstr1",            :limit => 200
    t.string   "etcstr2",            :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",               :limit => 2,   :default => 0
    t.string   "deleted_user_cd",    :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",    :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",    :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_cabinet_heads", ["cabinet_kbn", "private_org_cd"], :name => "idx_d_cabinet_heads_2"
  add_index "d_cabinet_heads", ["cabinet_kbn", "private_project_id"], :name => "idx_d_cabinet_heads_3"
  add_index "d_cabinet_heads", ["cabinet_kbn", "private_user_cd"], :name => "idx_d_cabinet_heads_1"

  create_table "d_cabinet_indices", :force => true do |t|
    t.integer  "cabinet_kbn",            :limit => 2,   :default => 0, :null => false
    t.string   "index_type",             :limit => 1
    t.integer  "parent_cabinet_head_id",                :default => 0, :null => false
    t.integer  "d_cabinet_head_id",                                    :null => false
    t.string   "title",                  :limit => 40
    t.string   "disp_org_cd",            :limit => 9
    t.integer  "order_display",                         :default => 0
    t.integer  "etcint1",                               :default => 0
    t.integer  "etcint2",                               :default => 0
    t.integer  "etcdec1",                               :default => 0
    t.integer  "etcdec2",                               :default => 0
    t.string   "etcstr1",                :limit => 200
    t.string   "etcstr2",                :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                   :limit => 2,   :default => 0
    t.string   "deleted_user_cd",        :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",        :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",        :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_cabinet_indices", ["d_cabinet_head_id"], :name => "idx_d_cabinet_indices_2"
  add_index "d_cabinet_indices", ["parent_cabinet_head_id"], :name => "idx_d_cabinet_indices_1"

  create_table "d_cabinet_public_orgs", :force => true do |t|
    t.integer  "d_cabinet_body_id"
    t.integer  "org_cd",                           :default => 0, :null => false
    t.integer  "etcint1",                          :default => 0
    t.integer  "etcint2",                          :default => 0
    t.integer  "etcdec1",                          :default => 0
    t.integer  "etcdec2",                          :default => 0
    t.string   "etcstr1",           :limit => 200
    t.string   "etcstr2",           :limit => 200
    t.string   "etctxt1"
    t.string   "etctxt2"
    t.integer  "delf",              :limit => 2,   :default => 0
    t.string   "deleted_user_cd",   :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",   :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",   :limit => 32
    t.datetime "updated_at"
  end

  create_table "d_company_addresses", :force => true do |t|
    t.string   "company_cd",      :limit => 16,                 :null => false
    t.integer  "company_kbn",     :limit => 2,   :default => 1, :null => false
    t.string   "name",            :limit => 100
    t.string   "name_kana",       :limit => 100
    t.string   "name_short",      :limit => 100
    t.string   "zip_cd",          :limit => 8
    t.string   "address1",        :limit => 60
    t.string   "address2",        :limit => 60
    t.text     "address3"
    t.string   "tel1",            :limit => 20
    t.string   "tel2",            :limit => 20
    t.string   "fax",             :limit => 20
    t.string   "homepage_url"
    t.text     "memo"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_company_addresses", ["company_cd"], :name => "idx_d_company_addresses_1"

  create_table "d_logs", :force => true do |t|
    t.string   "table_name",      :limit => 50
    t.string   "manipulate_name", :limit => 200
    t.integer  "manipulate_id"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
  end

  create_table "d_messages", :force => true do |t|
    t.string   "user_cd",         :limit => 32,                 :null => false
    t.integer  "message_kbn",     :limit => 2,   :default => 0
    t.string   "from_user_cd",    :limit => 32
    t.string   "from_user_name",  :limit => 40
    t.string   "title",           :limit => 80
    t.datetime "post_date"
    t.text     "body"
    t.text     "params"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_messages", ["message_kbn", "user_cd"], :name => "idx_d_messages_2"
  add_index "d_messages", ["user_cd"], :name => "idx_d_messages_1"

  create_table "d_notice_auths", :force => true do |t|
    t.integer  "d_notice_head_id",                :default => 0, :null => false
    t.string   "org_cd",           :limit => 9
    t.string   "user_cd",          :limit => 32
    t.integer  "auth_kbn",         :limit => 2,   :default => 1
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_notice_auths", ["d_notice_head_id"], :name => "idx_d_notice_auths_1"
  add_index "d_notice_auths", ["org_cd"], :name => "idx_d_notice_auths_2"
  add_index "d_notice_auths", ["user_cd"], :name => "idx_d_notice_auths_3"

  create_table "d_notice_bodies", :force => true do |t|
    t.integer  "d_notice_head_id",                                 :null => false
    t.string   "post_org_cd",      :limit => 9
    t.string   "post_user_cd",     :limit => 32
    t.string   "post_user_name",   :limit => 40
    t.datetime "post_date"
    t.string   "title",            :limit => 40
    t.text     "body"
    t.string   "public_org_cd",    :limit => 9,   :default => "0"
    t.integer  "public_flg",       :limit => 2,   :default => 0
    t.date     "public_date_from"
    t.date     "public_date_to"
    t.integer  "top_disp_kbn",     :limit => 2,   :default => 99
    t.integer  "hottopic_flg",     :limit => 2,   :default => 1
    t.text     "meta_tag"
    t.text     "attach_file"
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_notice_bodies", ["d_notice_head_id", "public_flg", "public_org_cd"], :name => "idx_d_notice_bodies_2"
  add_index "d_notice_bodies", ["d_notice_head_id"], :name => "idx_d_notice_bodies_1"
  add_index "d_notice_bodies", ["hottopic_flg"], :name => "idx_d_notice_bodies_4"
  add_index "d_notice_bodies", ["top_disp_kbn"], :name => "idx_d_notice_bodies_3"

  create_table "d_notice_files", :force => true do |t|
    t.integer  "d_notice_head_id",                               :null => false
    t.integer  "d_notice_body_id",                               :null => false
    t.string   "post_org_cd",      :limit => 9
    t.string   "post_user_cd",     :limit => 32
    t.string   "post_user_name",   :limit => 40
    t.datetime "post_date"
    t.string   "title",            :limit => 40
    t.text     "memo"
    t.date     "enable_date_to"
    t.string   "file_name"
    t.string   "real_file_name"
    t.integer  "file_size",        :limit => 8,   :default => 0
    t.string   "mime_type"
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_notice_files", ["d_notice_body_id", "d_notice_head_id"], :name => "idx_d_notice_files_1"

  create_table "d_notice_heads", :force => true do |t|
    t.string   "title",                :limit => 40
    t.integer  "lastpost_body_id"
    t.datetime "lastpost_date"
    t.string   "url"
    t.text     "description"
    t.integer  "default_top_disp_kbn", :limit => 2
    t.integer  "etcint1",                             :default => 0
    t.integer  "etcint2",                             :default => 0
    t.integer  "etcdec1",                             :default => 0
    t.integer  "etcdec2",                             :default => 0
    t.string   "etcstr1",              :limit => 200
    t.string   "etcstr2",              :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                 :limit => 2,   :default => 0
    t.string   "deleted_user_cd",      :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",      :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",      :limit => 32
    t.datetime "updated_at"
  end

  create_table "d_notice_indices", :force => true do |t|
    t.integer  "parent_notice_head_id",                :default => 0, :null => false
    t.integer  "d_notice_head_id"
    t.string   "index_type",            :limit => 1
    t.integer  "sort_no",                              :default => 1
    t.string   "title",                 :limit => 40
    t.string   "disp_org_cd",           :limit => 9
    t.integer  "etcint1",                              :default => 0
    t.integer  "etcint2",                              :default => 0
    t.integer  "etcdec1",                              :default => 0
    t.integer  "etcdec2",                              :default => 0
    t.string   "etcstr1",               :limit => 200
    t.string   "etcstr2",               :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                  :limit => 2,   :default => 0
    t.string   "deleted_user_cd",       :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",       :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",       :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_notice_indices", ["parent_notice_head_id"], :name => "idx_d_notice_indices_1"

  create_table "d_notice_public_orgs", :force => true do |t|
    t.integer  "d_notice_body_id",                               :null => false
    t.string   "org_cd",           :limit => 9,                  :null => false
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  create_table "d_reminders", :force => true do |t|
    t.string   "user_cd",          :limit => 32,                   :null => false
    t.integer  "d_schedule_id",                   :default => 0
    t.integer  "reminder_kbn",     :limit => 2,   :default => 0
    t.datetime "notice_date_from"
    t.datetime "notice_date_to"
    t.string   "title",            :limit => 60,  :default => "1"
    t.text     "body"
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_reminders", ["d_schedule_id"], :name => "idx_d_reminders_1"
  add_index "d_reminders", ["notice_date_from"], :name => "idx_d_reminders_2"
  add_index "d_reminders", ["user_cd"], :name => "idx_d_reminders_3"

  create_table "d_report_customers", :force => true do |t|
    t.integer  "d_report_id"
    t.string   "company_cd",       :limit => 32
    t.string   "action_target_cd", :limit => 4
    t.string   "action_group_cd",  :limit => 4
    t.string   "action_cd",        :limit => 8
    t.text     "comment"
    t.float    "action_time",                     :default => 0.0
    t.float    "sale_amount",                     :default => 0.0
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_report_customers", ["company_cd"], :name => "idx_d_report_customers_1"

  create_table "d_reports", :force => true do |t|
    t.string   "user_cd",          :limit => 32,                 :null => false
    t.date     "action_date",                                    :null => false
    t.text     "comment"
    t.string   "superior_user_cd", :limit => 32
    t.date     "confirm_date"
    t.text     "superior_comment"
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_reports", ["user_cd", "action_date"], :name => "idx_d_reports_1"

  create_table "d_reserves", :force => true do |t|
    t.string   "facility_cd",         :limit => 16,                 :null => false
    t.string   "place_cd",            :limit => 16
    t.string   "org_cd",              :limit => 9,                  :null => false
    t.string   "title",               :limit => 80,                 :null => false
    t.string   "reserve_org_cd",      :limit => 9
    t.string   "reserve_user_cd",     :limit => 32,                 :null => false
    t.string   "reserve_user_name",   :limit => 40
    t.integer  "plan_allday_flg",     :limit => 2,   :default => 0
    t.date     "plan_date_from"
    t.time     "plan_time_from"
    t.date     "plan_date_to"
    t.time     "plan_time_to"
    t.text     "memo"
    t.integer  "d_schedule_id"
    t.integer  "repeat_facility_id"
    t.integer  "repeat_flg",          :limit => 2,   :default => 0
    t.date     "repeat_date_to"
    t.integer  "repeat_interval_flg", :limit => 2,   :default => 0
    t.integer  "repeat_month_value",  :limit => 2,   :default => 0
    t.integer  "repeat_week_sun_flg", :limit => 2,   :default => 0
    t.integer  "repeat_week_mon_flg", :limit => 2,   :default => 0
    t.integer  "repeat_week_tue_flg", :limit => 2,   :default => 0
    t.integer  "repeat_week_wed_flg", :limit => 2,   :default => 0
    t.integer  "repeat_week_thu_flg", :limit => 2,   :default => 0
    t.integer  "repeat_week_fri_flg", :limit => 2,   :default => 0
    t.integer  "repeat_week_sat_flg", :limit => 2,   :default => 0
    t.integer  "etcint1",                            :default => 0
    t.integer  "etcint2",                            :default => 0
    t.integer  "etcdec1",                            :default => 0
    t.integer  "etcdec2",                            :default => 0
    t.string   "etcstr1",             :limit => 200
    t.string   "etcstr2",             :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                :limit => 2,   :default => 0
    t.string   "deleted_user_cd",     :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",     :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",     :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_reserves", ["facility_cd"], :name => "idx_d_reserves_1"
  add_index "d_reserves", ["org_cd"], :name => "idx_d_reserves_2"
  add_index "d_reserves", ["plan_date_from", "plan_date_to", "reserve_user_cd"], :name => "idx_d_reserves_3"

  create_table "d_rss_leaves", :force => true do |t|
    t.integer  "d_rss_trunk_id",                                  :null => false
    t.string   "leaf_id",         :limit => 64
    t.text     "url",                            :default => "0"
    t.text     "content"
    t.text     "title"
    t.datetime "publish"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_rss_leaves", ["d_rss_trunk_id", "leaf_id"], :name => "idx_d_rss_leaves_2"
  add_index "d_rss_leaves", ["d_rss_trunk_id"], :name => "idx_d_rss_leaves_1"

  create_table "d_rss_readers", :force => true do |t|
    t.string   "user_cd",         :limit => 32
    t.integer  "d_rss_trunk_id",                 :default => 0
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_rss_readers", ["user_cd"], :name => "idx_d_rss_readers_1"

  create_table "d_rss_trunks", :force => true do |t|
    t.string   "name",            :limit => 80
    t.string   "url",                            :default => "0"
    t.text     "rss_url"
    t.datetime "upddate"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  create_table "d_schedule_auths", :force => true do |t|
    t.integer  "d_schedule_id",                  :default => 0, :null => false
    t.string   "org_cd",          :limit => 9
    t.string   "user_cd",         :limit => 32
    t.integer  "project_id"
    t.integer  "auth_kbn",        :limit => 2,   :default => 1
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_schedule_auths", ["d_schedule_id"], :name => "idx_d_schedule_auths_1"

  create_table "d_schedule_settings", :force => true do |t|
    t.string   "user_cd",               :limit => 32,                 :null => false
    t.integer  "week_start_flg",                       :default => 0
    t.integer  "set_time_interval_flg",                :default => 0
    t.integer  "other_member_init",                    :default => 0
    t.integer  "etcint1",                              :default => 0
    t.integer  "etcint2",                              :default => 0
    t.integer  "etcdec1",                              :default => 0
    t.integer  "etcdec2",                              :default => 0
    t.string   "etcstr1",               :limit => 200
    t.string   "etcstr2",               :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                  :limit => 2,   :default => 0
    t.string   "deleted_user_cd",       :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",       :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",       :limit => 32
    t.datetime "updated_at"
  end

  create_table "d_schedules", :force => true do |t|
    t.string   "user_cd",                  :limit => 32,                 :null => false
    t.string   "title",                    :limit => 80,                 :null => false
    t.integer  "plan_allday_flg",          :limit => 2,   :default => 0
    t.date     "plan_date_from"
    t.time     "plan_time_from"
    t.date     "plan_date_to"
    t.time     "plan_time_to"
    t.string   "place",                    :limit => 128
    t.text     "memo"
    t.integer  "public_kbn",               :limit => 2,   :default => 0
    t.integer  "plan_kbn",                                :default => 0
    t.integer  "invite_id",                               :default => 0
    t.integer  "invite_flg",               :limit => 2,   :default => 0
    t.string   "invite_user_cd",           :limit => 32
    t.string   "invite_user_name",         :limit => 40
    t.text     "invite_comment"
    t.integer  "invite_checked_index",                    :default => 0
    t.string   "invite_checked_cd",        :limit => 9
    t.integer  "repeat_schedule_id"
    t.integer  "repeat_flg",               :limit => 2,   :default => 0
    t.date     "repeat_date_to"
    t.integer  "repeat_interval_flg",      :limit => 2,   :default => 0
    t.integer  "repeat_month_value",       :limit => 2,   :default => 0
    t.integer  "repeat_week_sun_flg",      :limit => 2,   :default => 0
    t.integer  "repeat_week_mon_flg",      :limit => 2,   :default => 0
    t.integer  "repeat_week_tue_flg",      :limit => 2,   :default => 0
    t.integer  "repeat_week_wed_flg",      :limit => 2,   :default => 0
    t.integer  "repeat_week_thu_flg",      :limit => 2,   :default => 0
    t.integer  "repeat_week_fri_flg",      :limit => 2,   :default => 0
    t.integer  "repeat_week_sat_flg",      :limit => 2,   :default => 0
    t.integer  "reminder_flg",             :limit => 2,   :default => 0
    t.integer  "reminder_day_flg",         :limit => 2,   :default => 0
    t.integer  "reminder_day_value",       :limit => 2,   :default => 0
    t.integer  "reminder_week_flg",        :limit => 2,   :default => 0
    t.integer  "reminder_week_value",      :limit => 2,   :default => 0
    t.integer  "reminder_month_flg",       :limit => 2,   :default => 0
    t.integer  "reminder_month_value",     :limit => 2,   :default => 0
    t.integer  "reminder_specify_flg",     :limit => 2,   :default => 0
    t.date     "reminder_specify_date"
    t.integer  "reminder_mypage_flg",      :limit => 2,   :default => 0
    t.integer  "reminder_email_flg",       :limit => 2,   :default => 0
    t.integer  "reminder_mobile_mail_flg", :limit => 2,   :default => 0
    t.string   "secretary_cd",             :limit => 32
    t.integer  "etcint1",                                 :default => 0
    t.integer  "etcint2",                                 :default => 0
    t.integer  "etcdec1",                                 :default => 0
    t.integer  "etcdec2",                                 :default => 0
    t.string   "etcstr1",                  :limit => 200
    t.string   "etcstr2",                  :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                     :limit => 2,   :default => 0
    t.string   "deleted_user_cd",          :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",          :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",          :limit => 32
    t.datetime "updated_at"
  end

  add_index "d_schedules", ["plan_date_from", "plan_date_to", "user_cd"], :name => "idx_d_schedules_2"
  add_index "d_schedules", ["repeat_schedule_id"], :name => "idx_d_schedules_3"
  add_index "d_schedules", ["user_cd"], :name => "idx_d_schedules_1"

  create_table "m_action_groups", :force => true do |t|
    t.string   "action_group_cd",   :limit => 4,   :default => ""
    t.string   "action_group_name", :limit => 40,  :default => ""
    t.integer  "sort_no",                          :default => 1
    t.text     "memo"
    t.integer  "etcint1",                          :default => 0
    t.integer  "etcint2",                          :default => 0
    t.integer  "etcdec1",                          :default => 0
    t.integer  "etcdec2",                          :default => 0
    t.string   "etcstr1",           :limit => 200
    t.string   "etcstr2",           :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",              :limit => 2,   :default => 0
    t.string   "deleted_user_cd",   :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",   :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",   :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_action_groups", ["action_group_cd"], :name => "idx_m_action_groups_1"

  create_table "m_action_targets", :force => true do |t|
    t.string   "action_target_cd",   :limit => 4,                  :null => false
    t.string   "action_target_name", :limit => 40
    t.integer  "sort_no",                           :default => 1
    t.text     "memo"
    t.integer  "etcint1",                           :default => 0
    t.integer  "etcint2",                           :default => 0
    t.integer  "etcdec1",                           :default => 0
    t.integer  "etcdec2",                           :default => 0
    t.string   "etcstr1",            :limit => 200
    t.string   "etcstr2",            :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",               :limit => 2,   :default => 0
    t.string   "deleted_user_cd",    :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",    :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",    :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_action_targets", ["action_target_cd"], :name => "idx_m_action_targets_1"

  create_table "m_actions", :force => true do |t|
    t.string   "action_cd",       :limit => 8,   :default => "", :null => false
    t.string   "action_name",     :limit => 40,  :default => ""
    t.string   "action_group_cd", :limit => 4,   :default => ""
    t.integer  "action_kbn",      :limit => 2,   :default => 0
    t.integer  "sort_no",                        :default => 1
    t.integer  "etc_flg",         :limit => 2,   :default => 0
    t.text     "memo"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_actions", ["action_cd"], :name => "idx_m_actions_1"
  add_index "m_actions", ["action_group_cd"], :name => "idx_m_actions_2"

  create_table "m_app_auths", :force => true do |t|
    t.string   "app_cd",          :limit => 16,  :default => "0", :null => false
    t.string   "org_cd",          :limit => 9
    t.string   "user_cd",         :limit => 32
    t.integer  "auth_kbn",        :limit => 2,   :default => 1
    t.integer  "admin_flg",       :limit => 2,   :default => 0
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_app_auths", ["app_cd", "org_cd"], :name => "idx_m_app_auths_1"
  add_index "m_app_auths", ["app_cd", "user_cd"], :name => "idx_m_app_auths_2"

  create_table "m_apps", :force => true do |t|
    t.string   "app_cd",          :limit => 16,  :default => "0", :null => false
    t.string   "title",           :limit => 32,                   :null => false
    t.text     "memo"
    t.integer  "enable_flg",      :limit => 2,   :default => 0
    t.string   "app_folder",      :limit => 32
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_apps", ["app_cd"], :name => "idx_m_apps_1", :unique => true

  create_table "m_bbs_settings", :force => true do |t|
    t.string   "app_cd",          :limit => 16,  :default => "0", :null => false
    t.integer  "new_icon_days",   :limit => 2,   :default => 5
    t.integer  "page_max_count",                 :default => 10
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  create_table "m_blog_settings", :force => true do |t|
    t.string   "app_cd",          :limit => 16,  :default => "0", :null => false
    t.integer  "new_icon_days",   :limit => 2,   :default => 5
    t.integer  "page_max_count",                 :default => 10
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  create_table "m_cabinet_settings", :force => true do |t|
    t.string   "app_cd",             :limit => 16,  :default => "0", :null => false
    t.integer  "new_icon_days",      :limit => 2,   :default => 5
    t.integer  "page_max_count",                    :default => 10
    t.integer  "enable_day_default", :limit => 2,   :default => 30
    t.integer  "etcint1",                           :default => 0
    t.integer  "etcint2",                           :default => 0
    t.integer  "etcdec1",                           :default => 0
    t.integer  "etcdec2",                           :default => 0
    t.string   "etcstr1",            :limit => 200
    t.string   "etcstr2",            :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",               :limit => 2,   :default => 0
    t.string   "deleted_user_cd",    :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",    :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",    :limit => 32
    t.datetime "updated_at"
  end

  create_table "m_calendars", :force => true do |t|
    t.date     "day",                                           :null => false
    t.string   "name",            :limit => 20
    t.integer  "holiday_flg",                    :default => 0
    t.integer  "every_year_flg",                 :default => 0
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_calendars", ["day"], :name => "idx_m_calendars_1"

  create_table "m_companies", :force => true do |t|
    t.string   "term_end1",       :limit => 4,   :default => "", :null => false
    t.string   "term_end2",       :limit => 4,   :default => ""
    t.string   "term_end3",       :limit => 4,   :default => ""
    t.string   "term_end4",       :limit => 4,   :default => ""
    t.string   "scroll_text",     :limit => 200, :default => ""
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  create_table "m_customer_staffs", :force => true do |t|
    t.string   "user_cd",         :limit => 32
    t.string   "name"
    t.string   "name_kana"
    t.string   "company_cd",      :limit => 16
    t.string   "post_name"
    t.string   "position_name"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  create_table "m_customers", :force => true do |t|
    t.string   "company_cd",          :limit => 16,                   :null => false
    t.string   "name",                :limit => 120
    t.string   "short_name",          :limit => 80
    t.string   "kana",                :limit => 120
    t.string   "short_kana",          :limit => 80
    t.integer  "sort_no",                            :default => 0
    t.string   "zip_cd",              :limit => 8
    t.string   "address1",            :limit => 80
    t.string   "address2",            :limit => 80
    t.string   "address3",            :limit => 80
    t.string   "president_name",      :limit => 40
    t.string   "tanto_name",          :limit => 40
    t.string   "tel1",                :limit => 20
    t.string   "tel2",                :limit => 20
    t.string   "fax",                 :limit => 20
    t.string   "mail_address",        :limit => 256
    t.string   "url",                 :limit => 256
    t.string   "number_of_employees", :limit => 100, :default => "0"
    t.string   "nensyo",              :limit => 100, :default => "0"
    t.string   "keijo",               :limit => 100, :default => "0"
    t.string   "yoshin",              :limit => 100, :default => "0"
    t.string   "arari",               :limit => 100, :default => "0"
    t.string   "sales",               :limit => 100, :default => "0"
    t.text     "memo"
    t.integer  "etcint1",                            :default => 0
    t.integer  "etcint2",                            :default => 0
    t.integer  "etcdec1",                            :default => 0
    t.integer  "etcdec2",                            :default => 0
    t.string   "etcstr1",             :limit => 200
    t.string   "etcstr2",             :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                :limit => 2,   :default => 0
    t.string   "deleted_user_cd",     :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",     :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",     :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_customers", ["company_cd"], :name => "idx_m_customers_1"

  create_table "m_facilities", :force => true do |t|
    t.string   "facility_cd",       :limit => 16,                   :null => false
    t.string   "facility_group_cd", :limit => 16,                   :null => false
    t.string   "place_cd",          :limit => 16,                   :null => false
    t.string   "org_cd",            :limit => 9,   :default => "0", :null => false
    t.string   "name",              :limit => 80,  :default => "",  :null => false
    t.integer  "facility_kbn",      :limit => 2
    t.integer  "sort_no",           :limit => 2,   :default => 1
    t.text     "memo"
    t.integer  "enable_flg",        :limit => 2,   :default => 0
    t.integer  "etcint1",                          :default => 0
    t.integer  "etcint2",                          :default => 0
    t.integer  "etcdec1",                          :default => 0
    t.integer  "etcdec2",                          :default => 0
    t.string   "etcstr1",           :limit => 200
    t.string   "etcstr2",           :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",              :limit => 2,   :default => 0
    t.string   "deleted_user_cd",   :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",   :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",   :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_facilities", ["facility_cd"], :name => "idx_m_facilities_1"

  create_table "m_facility_groups", :force => true do |t|
    t.string   "facility_group_cd", :limit => 16,                  :null => false
    t.string   "name",              :limit => 80,  :default => "", :null => false
    t.integer  "sort_no",           :limit => 2,   :default => 1
    t.integer  "etcint1",                          :default => 0
    t.integer  "etcint2",                          :default => 0
    t.integer  "etcdec1",                          :default => 0
    t.integer  "etcdec2",                          :default => 0
    t.string   "etcstr1",           :limit => 200
    t.string   "etcstr2",           :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",              :limit => 2,   :default => 0
    t.string   "deleted_user_cd",   :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",   :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",   :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_facility_groups", ["facility_group_cd"], :name => "idx_m_facility_groups_1"

  create_table "m_kbns", :force => true do |t|
    t.string   "kbn_cd",          :limit => 64,                 :null => false
    t.integer  "kbn_id",                                        :null => false
    t.string   "name",            :limit => 40,                 :null => false
    t.string   "name_short",      :limit => 20
    t.string   "name_kana",       :limit => 40
    t.integer  "value_int"
    t.string   "value_chr",       :limit => 20
    t.integer  "disp_flg",        :limit => 2,   :default => 0
    t.integer  "sort_no",         :limit => 2,   :default => 1
    t.text     "notes"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_kbns", ["kbn_cd", "kbn_id"], :name => "idx_m_kbns_2"
  add_index "m_kbns", ["kbn_cd"], :name => "idx_m_kbns_1"

  create_table "m_menu_auths", :force => true do |t|
    t.integer  "menu_id",                        :default => 0, :null => false
    t.string   "org_cd",          :limit => 9
    t.string   "user_cd",         :limit => 32
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_menu_auths", ["menu_id", "org_cd"], :name => "idx_m_menu_auths_1"
  add_index "m_menu_auths", ["menu_id", "user_cd"], :name => "idx_m_menu_auths_2"

  create_table "m_menus", :force => true do |t|
    t.integer  "parent_menu_id",                                  :null => false
    t.integer  "sort_no",         :limit => 2,   :default => 1
    t.string   "title",           :limit => 32
    t.string   "url"
    t.string   "target",          :limit => 20
    t.integer  "menu_kbn",        :limit => 2,   :default => 0
    t.integer  "folder_flg",      :limit => 2,   :default => 0
    t.integer  "public_flg",      :limit => 2,   :default => 0
    t.string   "app_cd",          :limit => 16,  :default => "0"
    t.string   "icon",            :limit => 64
    t.text     "memo"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_menus", ["parent_menu_id"], :name => "idx_m_menus_1"

  create_table "m_notice_settings", :force => true do |t|
    t.string   "app_cd",          :limit => 16,  :default => "0", :null => false
    t.integer  "new_icon_days",   :limit => 2,   :default => 5
    t.integer  "page_max_count",                 :default => 10
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  create_table "m_orgs", :force => true do |t|
    t.string   "org_cd",          :limit => 9,                  :null => false
    t.integer  "org_lvl",         :limit => 2,   :default => 1
    t.string   "org_cd1",         :limit => 2
    t.string   "org_cd2",         :limit => 2
    t.string   "org_cd3",         :limit => 2
    t.string   "org_cd4",         :limit => 3
    t.string   "org_name1",       :limit => 20
    t.string   "org_name2",       :limit => 20
    t.string   "org_name3",       :limit => 20
    t.string   "org_name4",       :limit => 20
    t.string   "place_cd",        :limit => 16
    t.integer  "sort_no",                        :default => 0
    t.string   "tel",             :limit => 20
    t.string   "fax",             :limit => 20
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_orgs", ["org_cd"], :name => "idx_m_orgs_1"

  create_table "m_places", :force => true do |t|
    t.string   "place_cd",        :limit => 16,                 :null => false
    t.integer  "sort_no",                        :default => 1
    t.string   "name",            :limit => 80
    t.string   "zip_cd",          :limit => 8
    t.string   "address1",        :limit => 60
    t.string   "address2",        :limit => 60
    t.text     "address3"
    t.text     "memo"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_places", ["place_cd"], :name => "idx_m_places_1"

  create_table "m_positions", :force => true do |t|
    t.string   "position_cd",     :limit => 8,                   :null => false
    t.string   "name",            :limit => 30,                  :null => false
    t.integer  "rank",            :limit => 2,   :default => 99, :null => false
    t.integer  "sort_no",         :limit => 2,   :default => 1
    t.text     "memo"
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_positions", ["position_cd"], :name => "idx_m_positions_1"

  create_table "m_project_users", :force => true do |t|
    t.integer  "project_id",                                    :null => false
    t.string   "user_cd",         :limit => 32,                 :null => false
    t.integer  "admin_flg",       :limit => 2,   :default => 0
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_project_users", ["project_id"], :name => "idx_m_project_users_1"
  add_index "m_project_users", ["user_cd"], :name => "idx_m_project_users_2"

  create_table "m_projects", :force => true do |t|
    t.string   "name",             :limit => 80,                 :null => false
    t.string   "name_short",       :limit => 32
    t.date     "enable_date_from",                               :null => false
    t.date     "enable_date_to",                                 :null => false
    t.integer  "enable_flg",       :limit => 2,   :default => 0
    t.text     "memo"
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  create_table "m_secretaries", :force => true do |t|
    t.string   "user_cd",           :limit => 32,                 :null => false
    t.string   "authorize_user_cd", :limit => 32
    t.string   "authorize_org_cd",  :limit => 9
    t.integer  "etcint1",                          :default => 0
    t.integer  "etcint2",                          :default => 0
    t.integer  "etcdec1",                          :default => 0
    t.integer  "etcdec2",                          :default => 0
    t.string   "etcstr1",           :limit => 200
    t.string   "etcstr2",           :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",              :limit => 2,   :default => 0
    t.string   "deleted_user_cd",   :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",   :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",   :limit => 32
    t.datetime "updated_at"
  end

  create_table "m_superiors", :force => true do |t|
    t.string   "user_cd",          :limit => 32,                 :null => false
    t.string   "superior_user_cd", :limit => 32,                 :null => false
    t.integer  "etcint1",                         :default => 0
    t.integer  "etcint2",                         :default => 0
    t.integer  "etcdec1",                         :default => 0
    t.integer  "etcdec2",                         :default => 0
    t.string   "etcstr1",          :limit => 200
    t.string   "etcstr2",          :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",             :limit => 2,   :default => 0
    t.string   "deleted_user_cd",  :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",  :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",  :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_superiors", ["superior_user_cd"], :name => "idx_m_superiors_2"
  add_index "m_superiors", ["user_cd"], :name => "idx_m_superiors_1"

  create_table "m_user_attributes", :force => true do |t|
    t.string   "user_cd",         :limit => 32,                 :null => false
    t.string   "name_kana",       :limit => 40
    t.string   "position_cd",     :limit => 8
    t.integer  "job_kbn"
    t.integer  "authority_kbn"
    t.string   "place_cd",        :limit => 16
    t.date     "joined_date"
    t.text     "memo"
    t.integer  "director_flg",                   :default => 0
    t.integer  "sort_no",                        :default => 0
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
    t.integer  "position_cd_org", :limit => 8
  end

  add_index "m_user_attributes", ["user_cd"], :name => "idx_m_user_attributes_1"

  create_table "m_user_belongs", :force => true do |t|
    t.string   "user_cd",         :limit => 32,                 :null => false
    t.string   "org_cd",          :limit => 9,                  :null => false
    t.integer  "belong_kbn",      :limit => 2,   :default => 0, :null => false
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_user_belongs", ["user_cd", "org_cd", "belong_kbn"], :name => "idx_m_user_belongs_1"

  create_table "m_users", :force => true do |t|
    t.string   "login",                     :limit => 40,                  :null => false
    t.string   "user_cd",                   :limit => 32,                  :null => false
    t.string   "name",                      :limit => 40,  :default => "", :null => false
    t.integer  "admin_flg",                 :limit => 2,   :default => 0
    t.string   "email",                     :limit => 128
    t.string   "passwd",                    :limit => 64
    t.string   "crypted_password",          :limit => 64
    t.string   "salt",                      :limit => 64
    t.string   "remember_token",            :limit => 64
    t.datetime "remember_token_expires_at"
    t.datetime "lastlogin_at"
    t.datetime "last_change_passwd_at"
    t.integer  "etcint1",                                  :default => 0
    t.integer  "etcint2",                                  :default => 0
    t.integer  "etcdec1",                                  :default => 0
    t.integer  "etcdec2",                                  :default => 0
    t.string   "etcstr1",                   :limit => 200
    t.string   "etcstr2",                   :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",                      :limit => 2,   :default => 0
    t.string   "deleted_user_cd",           :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd",           :limit => 32
    t.datetime "created_at"
    t.string   "updated_user_cd",           :limit => 32
    t.datetime "updated_at"
  end

  add_index "m_users", ["login"], :name => "idx_m_users_1"
  add_index "m_users", ["user_cd"], :name => "idx_m_users_2"

  create_table "m_workers", :force => true do |t|
    t.string   "company_cd",      :limit => 16
    t.string   "user_cd",         :limit => 32
    t.integer  "etcint1",                        :default => 0
    t.integer  "etcint2",                        :default => 0
    t.integer  "etcdec1",                        :default => 0
    t.integer  "etcdec2",                        :default => 0
    t.string   "etcstr1",         :limit => 200
    t.string   "etcstr2",         :limit => 200
    t.text     "etctxt1"
    t.text     "etctxt2"
    t.integer  "delf",            :limit => 2,   :default => 0
    t.string   "deleted_user_cd", :limit => 32
    t.datetime "deleted_at"
    t.string   "created_user_cd", :limit => 32
    t.datetime "creatd_at"
    t.string   "updated_user_cd", :limit => 32
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.string   "user_id",    :limit => 32
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

end
