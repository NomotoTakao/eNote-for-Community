class MFacility < ActiveRecord::Base

  #
  # 引数の施設グループコード/拠点コードに含まれる、施設マスタのデータを返す
  # (拠点コードは任意)
  #
  def self.get_facility_group_list_by_group(facility_group_cd, place_cd)

    sql = <<-SQL
      --組織の指定なし
      (SELECT
        t1.*,
        t2.name as place_name,
        '指定なし' as org_name
      FROM
        m_facilities t1,
        m_places t2
      WHERE
        t1.place_cd = t2.place_cd
      AND
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t1.facility_group_cd = '#{facility_group_cd}'
    SQL

    #拠点が指定されている場合
    if !place_cd.nil? && place_cd != "" && place_cd != "-1"
      sql += <<-SQL
        AND t1.place_cd = '#{place_cd}'
      SQL
    end

    sql += <<-SQL
      AND
        t1.org_cd = '0')
    SQL

    sql += <<-SQL
      UNION

      --組織の指定あり
      (SELECT
        t1.*,
        t2.name as place_name,
        case
          when trim(t3.org_name4) != '' then t3.org_name4
          when trim(t3.org_name3) != '' then t3.org_name3
          when trim(t3.org_name2) != '' then t3.org_name2
          when trim(t3.org_name1) != '' then t3.org_name1
        end as org_name
      FROM
        m_facilities t1,
        m_places t2,
        m_orgs t3
      WHERE
        t1.place_cd = t2.place_cd
      AND
        t1.org_cd = t3.org_cd
      AND
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t3.delf = 0
    SQL

    #拠点が指定されている場合
    if !place_cd.nil? && place_cd != "" && place_cd != "-1"
      sql += <<-SQL
        AND t1.place_cd = '#{place_cd}'
      SQL
    end

    sql += <<-SQL
      AND
        t1.facility_group_cd = '#{facility_group_cd}')
    SQL

    sql += <<-SQL
      ORDER BY
        sort_no
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数の施設グループコード/拠点コード/組織コードに含まれる、施設マスタのデータを返す
  # (拠点コードは任意)
  #
  def self.get_facility_group_list_by_org(facility_group_cd, place_cd, org_cd)

    #組織が検索条件に指定されている場合
    if !org_cd.nil? && org_cd != "" && org_cd != "-1"
      #組織コード="0"(指定なし)の場合
      if org_cd == "0"
        sql = <<-SQL
          SELECT
            t1.*,
            t2.name as place_name,
            '指定なし' as org_name
          FROM
            m_facilities t1,
            m_places t2
          WHERE
            t1.place_cd = t2.place_cd
          AND
            t1.delf = 0
          AND
            t2.delf = 0
          AND
            t1.facility_group_cd = '#{facility_group_cd}'
          AND
            t1.org_cd = '0'
        SQL

        #拠点が指定されている場合
        if !place_cd.nil? && place_cd != "" && place_cd != "-1"
          sql += <<-SQL
            AND t1.place_cd = '#{place_cd}'
          SQL
        end

        sql += <<-SQL
          ORDER BY
            t1.sort_no
        SQL
      else
        sql = <<-SQL
          SELECT
            t1.*,
            t2.name as place_name,
            case
              when trim(t3.org_name4) != '' then t3.org_name4
              when trim(t3.org_name3) != '' then t3.org_name3
              when trim(t3.org_name2) != '' then t3.org_name2
              when trim(t3.org_name1) != '' then t3.org_name1
            end as org_name
          FROM
            m_facilities t1,
            m_places t2,
            m_orgs t3
          WHERE
            t1.place_cd = t2.place_cd
          AND
            t1.org_cd = t3.org_cd
          AND
            t1.delf = 0
          AND
            t2.delf = 0
          AND
            t3.delf = 0
          AND
            t1.facility_group_cd = '#{facility_group_cd}'
          AND
            t1.org_cd = '#{org_cd}'
        SQL

        #拠点が指定されている場合
        if !place_cd.nil? && place_cd != "" && place_cd != "-1"
          sql += <<-SQL
            AND t1.place_cd = '#{place_cd}'
          SQL
        end

        sql += <<-SQL
          ORDER BY
            t1.sort_no
        SQL
      end
    end

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数の施設コードに該当するデータを返す
  # 但し引数のid指定の場合は、id以外のデータで検索する
  #
  def self.duplicate_check_data(id, facility_cd)

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_facilities t1
      WHERE
        t1.delf = 0
      AND
        t1.facility_cd = '#{facility_cd}'
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
