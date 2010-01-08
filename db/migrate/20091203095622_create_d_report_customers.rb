class CreateDReportCustomers < ActiveRecord::Migration
  def self.up
    create_table :d_report_customers do |t|
      t.integer :d_report_id
      # 以下の2項目はd_reportsに記述するので、d_report_customersには記述しない。
#      t.string   "post_user_cd",          :limit => 32,        :null => false
#      t.date     "action_date",           :null => false
      t.string   :company_cd,           :limit => 32
      # コードと名前が不一致になるような状況が生まれる場合があるのなら、マスタを世代管理する。
#      t.string   "customer_name",         :limit => 120, :default => ""
      t.string   :action_target_cd,      :limit => 4
#      t.string   "action_target_name",    :limit => 40, :default => ""
      t.string   :action_group_cd,       :limit => 4
#      t.string   "action_group_name",     :limit => 40, :default => ""
      t.string   :action_cd,             :limit => 8
#      t.string   "action_name",           :limit => 40, :default => ""
      t.text     :comment
      t.float    :action_time,           :limit => 4, :default => 0.0
      t.float    :sale_amount,           :limit => 14, :default => 0.0
      t.integer  :etcint1,                                                        :default => 0
      t.integer  :etcint2,                                                        :default => 0
      t.integer  :etcdec1,          :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer  :etcdec2,          :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string   :etcstr1,          :limit => 200
      t.string   :etcstr2,          :limit => 200
      t.text     :etctxt1
      t.text     :etctxt2
      t.integer  :delf,             :limit => 2,                                  :default => 0
      t.string   :deleted_user_cd,  :limit => 32
      t.datetime :deleted_at
      t.string   :created_user_cd,  :limit => 32
      t.datetime :created_at
      t.string   :updated_user_cd,  :limit => 32
      t.datetime :updated_at
    end
#    add_index "d_report_customers", ["post_user_cd"], :name => "idx_d_report_customers_1"
    add_index "d_report_customers", ["company_cd"], :name => "idx_d_report_customers_1"
#    add_index "d_report_customers", ["action_date"], :name => "idx_d_report_customers_3"
  end

  def self.down
    drop_table :d_report_customers
  end
end
