class CreateMCustomerEmployees < ActiveRecord::Migration
  def self.up
    create_table :m_customer_employees do |t|
      t.string   :user_cd,         :limit=>32
      t.string   :name
      t.string   :name_kana
      t.string   :company_cd,      :limit=>16
      t.string   :post_name
      t.string   :position_name
      t.integer  :etcint1,                                                :default=>0
      t.integer  :etcint2,                                                :default=>0
      t.integer  :etcdec1,         :limit=>14, :precision=>14, :scale=>0, :default=>0
      t.integer  :etcdec2,         :limit=>14, :precision=>14, :scale=>0, :default=>0
      t.string   :etcstr1,         :limit=>200
      t.string   :etcstr2,         :limit=>200
      t.text     :etctxt1
      t.text     :etctxt2
      t.integer  :delf,            :limit=>2,                             :default=>0
      t.string   :deleted_user_cd, :limit=>32
      t.datetime :deleted_at
      t.string   :created_user_cd, :limit=>32
      t.datetime :created_at
      t.string   :updated_user_cd, :limit=>32
      t.datetime :updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :m_customer_staffs
  end
end
