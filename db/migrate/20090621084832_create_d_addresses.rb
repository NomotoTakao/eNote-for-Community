class CreateDAddresses < ActiveRecord::Migration
  def self.up
    create_table "d_addresses", :force => true do |t|
      t.integer  "address_kbn",                :limit => 2,                                  :default => 9, :null => false
      t.string   "user_cd",                    :limit => 32
      t.string   "company_cd",                 :limit => 16
      t.string   "private_user_cd",            :limit => 32
      t.string   "name",                       :limit => 40
      t.string   "name_kana",                  :limit => 40
      t.string   "email_name",                 :limit => 40
      t.string   "email_address1",             :limit => 128
      t.string   "email_address2",             :limit => 128
      t.string   "email_address3",             :limit => 128
      t.string   "zip_cd",                     :limit => 8
      t.string   "address1",                   :limit => 60
      t.string   "address2",                   :limit => 60
      t.text     "address3"
      t.string   "tel",                        :limit => 20
      t.string   "fax",                        :limit => 20
      t.string   "mobile_no",                  :limit => 20
      t.string   "mobile_address",             :limit => 128
      t.string   "mobile_company",             :limit => 10
      t.string   "mobile_kind",                :limit => 20
      t.string   "homepage_url",               :limit => 256
      t.date     "birthday"
      t.string   "employee_cd",                :limit => 32
      t.string   "memorial_name1",             :limit => 40
      t.date     "memorial_date1"
      t.string   "memorial_name2",             :limit => 40
      t.date     "memorial_date2"
      t.string   "memorial_name3",             :limit => 40
      t.date     "memorial_date3"
      t.string   "company_name",               :limit => 100
      t.string   "company_name_kana",          :limit => 100
      t.string   "company_post",               :limit => 100
      t.string   "company_job",                :limit => 40
      t.string   "company_zip_cd",             :limit => 8
      t.string   "company_address1",           :limit => 60
      t.string   "company_address2",           :limit => 60
      t.text     "company_address3"
      t.string   "company_tel1",               :limit => 20
      t.string   "company_tel2",               :limit => 20
      t.string   "company_fax",                :limit => 20
      t.string   "company_homepage_url",       :limit => 256
      t.text     "meta_tag"
      t.text     "memo"
      t.integer  "etcint1",                                                                  :default => 0
      t.integer  "etcint2",                                                                  :default => 0
      t.integer  "etcdec1",                    :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",                    :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",                    :limit => 200
      t.string   "etcstr2",                    :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",                       :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd",            :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd",            :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd",            :limit => 32
      t.datetime "updated_at"
    end

    add_index "d_addresses", ["address_kbn", "company_cd"], :name => "idx_d_addresses_2"
    add_index "d_addresses", ["address_kbn", "private_user_cd"], :name => "idx_d_addresses_3"
    add_index "d_addresses", ["address_kbn", "user_cd"], :name => "idx_d_addresses_1"
    add_index "d_addresses", ["email_address1", "email_address2", "email_address3", "mobile_address"], :name => "idx_d_addresses_4"
  end

  def self.down
    drop_table :d_addresses
  end
end
