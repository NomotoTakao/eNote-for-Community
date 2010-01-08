class CreateDReports < ActiveRecord::Migration
  def self.up
    create_table :d_reports do |t|
      t.string    :user_cd,           :limit => 32,           :null => false
      #何のための項目なのか不明。日報提出者の日報提出時点での所属組織が必要な場合は、ユーザーCDから求める。
      # ユーザーが他の部署へ配属された場合のことを考えるなら、ユーザーの所属組織を世代管理する必要がある。
#      t.string    :org_cd,            :limit => 9,   :null => false
      t.date      :action_date,        :null => false
      t.text      :comment
      # superior_user_cdは、上司が確認コメントを入力した時点で設定されるので、NULLの状態を許可しなければならない。
#      t.string    :superior_user_cd,             :limit => 32,           :null => false
      t.string    :superior_user_cd,             :limit => 32
      t.date      :confirm_date
      t.text      :superior_comment
      t.integer   :etcint1,                                                        :default => 0
      t.integer   :etcint2,                                                        :default => 0
      t.integer   :etcdec1,          :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.integer   :etcdec2,          :limit => 14,  :precision => 14, :scale => 0, :default => 0
      t.string    :etcstr1,          :limit => 200
      t.string    :etcstr2,          :limit => 200
      t.text      :etctxt1
      t.text      :etctxt2
      t.integer   :delf,             :limit => 2,                                  :default => 0
      t.string    :deleted_user_cd,  :limit => 32
      t.datetime  :deleted_at
      t.string    :created_user_cd,  :limit => 32
      t.datetime  :created_at
      t.string    :updated_user_cd,  :limit => 32
      t.datetime  :updated_at
    end
    add_index "d_reports", ["user_cd","action_date"], :name => "idx_d_reports_1"
  end

  def self.down
    drop_table :d_reports
  end
end
