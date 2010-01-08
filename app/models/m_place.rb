class MPlace < ActiveRecord::Base

  #
  # 拠点マスタの全データを返す
  #
  def self.get_place_all_list()

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_places t1
      WHERE
        t1.delf = 0
      ORDER BY
        t1.sort_no
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数の拠点コードに該当するデータを返す
  # 但し引数のid指定の場合は、id以外のデータで検索する
  #
  def self.duplicate_check_data(id, place_cd)

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_places t1
      WHERE
        t1.delf = 0
      AND
        t1.place_cd = '#{place_cd}'
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
end
