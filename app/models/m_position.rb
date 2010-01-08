class MPosition < ActiveRecord::Base

  #
  # 職位マスタの全データを返す
  #
  def self.get_position_all_list()

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_positions t1
      WHERE
        t1.delf = 0
      ORDER BY
        t1.sort_no
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数の職位コードに該当するデータを返す
  # 但し引数のid指定の場合は、id以外のデータで検索する
  #
  def self.duplicate_check_data(id, position_cd)

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_positions t1
      WHERE
        t1.delf = 0
      AND
        t1.position_cd = '#{position_cd}'
    SQL

    if id != 0
      sql += <<-SQL
        AND
          t1.id != #{id}
      SQL
    end

    sql += <<-SQL
      LIMIT 1
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 社員CDに紐付くランクを返す
  # @param user_cd - 社員CD
  #
  def self.get_rank(user_cd)

    sql = <<-SQL
      SELECT
        t1.rank
      FROM m_positions t1,
           m_user_attributes t2
      WHERE
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t1.position_cd = t2.position_cd
      AND
        t2.user_cd = '#{user_cd}'
    SQL

    recs = find_by_sql(sql)
    return recs
  end

end
