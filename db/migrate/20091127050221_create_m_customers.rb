class CreateMCustomers < ActiveRecord::Migration
  def self.up
    create_table :m_customers do |t|
      t.string    :company_cd,          :limit => 16,  :null=>false
      t.string    :name,                :limit => 120
      t.string    :short_name,          :limit => 80
      t.string    :kana,                :limit => 120
      t.string    :short_kana,          :limit => 80
      t.integer   :sort_no,                                                          :default => 0
      t.string    :zip_cd,              :limit => 8
      t.string    :address1,            :limit => 80
      t.string    :address2,            :limit => 80
      t.string    :address3,            :limit => 80
      t.string    :president_name,      :limit => 40
      t.string    :tanto_name,          :limit => 40
      t.string    :tel1,                :limit => 20
      t.string    :tel2,                :limit => 20
      t.string    :fax,                 :limit => 20
      t.string    :mail_address,        :limit => 256
      t.string    :url,                 :limit => 256
      t.string    :number_of_employees, :limit => 100,                               :default=>0
      t.string    :nensyo,              :limit => 100,                               :default=>0
      t.string    :keijo,               :limit => 100,                               :default=>0
      t.string    :yoshin,              :limit => 100,                               :default=>0
      t.string    :arari,               :limit => 100,                               :default=>0
      t.string    :sales,               :limit => 100,                               :default=>0
      t.text      :memo
      t.integer   :etcint1,                                                          :default => 0
      t.integer   :etcint2,                                                          :default => 0
      t.integer   :etcdec1,             :limit => 14, :precision => 14, :scale => 0, :default => 0
      t.integer   :etcdec2,             :limit => 14, :precision => 14, :scale => 0, :default => 0
      t.string    :etcstr1,             :limit => 200
      t.string    :etcstr2,             :limit => 200
      t.text      :etctxt1
      t.text      :etctxt2
      t.integer   :delf,                :limit => 2,                                 :default => 0
      t.string    :deleted_user_cd,     :limit => 32
      t.datetime  :deleted_at
      t.string    :created_user_cd,     :limit => 32
      t.datetime  :created_at
      t.string    :updated_user_cd,     :limit => 32
      t.datetime  :updated_at
    end
    add_index "m_customers", ["company_cd"], :name => "idx_m_customers_1"
  end

  def self.down
    drop_table :m_customers
  end
end
