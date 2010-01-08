class MFacilityGroup < ActiveRecord::Base

  #
  # 施設グループマスタの全データを返す
  #
  def self.get_facility_group_all_list()

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_facility_groups t1
      WHERE
        t1.delf = 0
      ORDER BY
        t1.sort_no
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数の施設グループコードに該当するデータを返す
  # 但し引数のid指定の場合は、id以外のデータで検索する
  #
  def self.duplicate_check_data(id, facility_group_cd)

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_facility_groups t1
      WHERE
        t1.delf = 0
      AND
        t1.facility_group_cd = '#{facility_group_cd}'
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
