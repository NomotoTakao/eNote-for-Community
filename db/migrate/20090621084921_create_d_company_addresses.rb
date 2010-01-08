class CreateDCompanyAddresses < ActiveRecord::Migration
  def self.up
    create_table "d_company_addresses", :force => true do |t|
      t.string   "company_cd",   :limit => 16,                                                :null => false
      t.integer  "company_kbn",  :limit => 2,                                  :default => 1, :null => false
      t.string   "name",         :limit => 100
      t.string   "name_kana",    :limit => 100
      t.string   "name_short",   :limit => 100
      t.string   "zip_cd",       :limit => 8
      t.string   "address1",     :limit => 60
      t.string   "address2",     :limit => 60
      t.text     "address3"
      t.string   "tel1",         :limit => 20
      t.string   "tel2",         :limit => 20
      t.string   "fax",          :limit => 20
      t.string   "homepage_url"
      t.text     "memo"
      t.integer  "etcint1",                                                    :default => 0
      t.integer  "etcint2",                                                    :default => 0
      t.integer  "etcdec1",      :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  "etcdec2",      :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   "etcstr1",      :limit => 200
      t.string   "etcstr2",      :limit => 200
      t.text     "etctxt1"
      t.text     "etctxt2"
      t.integer  "delf",         :limit => 2,                                  :default => 0
      t.string   "deleted_user_cd", :limit => 32
      t.datetime "deleted_at"
      t.string   "created_user_cd", :limit => 32
      t.datetime "created_at"
      t.string   "updated_user_cd", :limit => 32
      t.datetime "updated_at"
    end
    add_index "d_company_addresses", ["company_cd"], :name => "idx_d_company_addresses_1"
  
  end
  
  def self.down
    drop_table :d_company_addresses
  end
end
