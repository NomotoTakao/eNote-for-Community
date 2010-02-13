class CreateMCompanies < ActiveRecord::Migration
  def self.up
    create_table :m_companies do |t|
      t.string   :express, :limit => 7, :default => "0"
      t.string   :client_cd, :limit => 7
      t.string   :client_name,          :limit => 255
      t.string   :client_name_kana,     :limit => 255
      t.string   :client_url,           :limit => 255
      t.string   :client_mailaddress,   :limit => 255
      t.string   :client_telephone,     :limit => 14
      t.string   :client_database_name, :limit => 16
      t.string   :client_database_host, :limit => 64
      t.integer  :client_database_port
      t.string   :client_database_username, :limit => 64
      t.string   :client_database_password, :limit => 64
      t.string   :admin_user_cd,         :limit => 32
      t.string   :admin_user_name,       :limit => 40
      t.string   :client_prefix,        :limit => 14
      t.integer  :service_kbn,          :limit => 2,                      :default => 0
      t.date     :service_start_date
      t.date     :service_end_date
      t.integer  :max_disk_space,                                         :default => 1024
      t.integer  :current_disk_space,                                     :default => 0
      t.integer  :job_kind,             :limit => 2
      t.integer  :prefectures,          :limit => 2
      t.integer  :max_user_count,                                                     :default => 0
      t.integer  :max_customer_count,                                                 :default => 0
      t.string   :zipcd,                :limit => 8
      t.string   :address1,             :limit => 255
      t.string   :address2,             :limit => 255
      t.string   :address3,             :limit => 255
      t.string   :president,            :limit => 128
      t.string   :term_end1,       :limit => 4,  :null => false,               :default => ""
      t.string   :term_end2,       :limit => 4,                                :default => ""
      t.string   :term_end3,       :limit => 4,                                :default => ""
      t.string   :term_end4,       :limit => 4,                                :default => ""
      t.string   :scroll_text,     :limit => 200,                              :default => ""
      t.text     :note
      t.text     :retire_reason
      t.integer  :etcint1,                                                            :default => 0
      t.integer  :etcint2,                                                            :default => 0
      t.integer  :etcdec1,              :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  :etcdec2,              :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   :etcstr1,              :limit => 200
      t.string   :etcstr2,              :limit => 200
      t.text     :etctxt1
      t.text     :etctxt2
      t.integer  :delf,                 :limit => 2,                                  :default => 0
      t.string   :deleted_user_cd,      :limit => 32
      t.datetime :deleted_at
      t.string   :created_user_cd,      :limit => 32
      t.datetime :created_at
      t.string   :updated_user_cd,      :limit => 32
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :m_companies
  end
end
