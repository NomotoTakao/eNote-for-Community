class MCompany < ActiveRecord::Base

  #
  # 会社マスタの全データを返す
  #
  def self.get_company_all_list()

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_companies t1
      WHERE
        t1.delf = 0
    SQL

    recs = find_by_sql(sql)
    return recs
  end

end
