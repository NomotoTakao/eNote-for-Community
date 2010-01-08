class MProject < ActiveRecord::Base
  has_one :d_cabinet_head, :foreign_key=>"private_project_id", :conditions=>{:delf=>0, :cabinet_kbn=>3}

  #
  # プロジェクトマスタの全データを返す
  # 有効条件：削除フラグ
  #
  def self.get_project_all_list(date)

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_projects t1
      WHERE
        t1.delf = 0
      ORDER BY
        t1.id
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # プロジェクトマスタの有効な全データを返す
  # 有効条件：削除フラグ, 有効期間, 有効フラグ
  #
  def self.get_project_all_enable_list(date)

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_projects t1
      WHERE
        t1.delf = 0
      AND
        t1.enable_flg = 0
      AND
        t1.enable_date_from <= '#{date}'
      AND
        t1.enable_date_to >= '#{date}'
      ORDER BY
        t1.id
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数のユーザコードに含まれる、プロジェクトリストのデータを返す
  # 有効条件：削除フラグ, 有効期間, 有効フラグ
  #
  def self.get_project_list(user_cd)

    sql = <<-SQL
      SELECT
        t1.*
      FROM
        m_projects t1,
        m_project_users t2
      WHERE
        t1.id = t2.project_id
      AND
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t1.enable_flg = 0
      AND
        t1.enable_date_from <= current_date
      AND
        t1.enable_date_to >= current_date
      AND
        t2.user_cd = '#{user_cd}'
      ORDER BY
        t1.id
    SQL

    recs = find_by_sql(sql)
    return recs
  end

end
