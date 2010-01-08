class MSecretary < ActiveRecord::Base

  #
  # 秘書マスタの全データを返す
  #
  def self.get_secretary_all_list()

    sql = <<-SQL
      SELECT
        t1.*,
        t2.name as user_name
      FROM m_secretaries t1,
           m_users t2
      WHERE
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t1.user_cd = t2.user_cd
      ORDER BY
        t1.user_cd, t1.authorize_user_cd, t1.authorize_org_cd
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数の社員コードに該当するデータを返す
  # @param user_cd - 秘書機能を受ける社員（社長など）
  #
  def self.get_secretary_data(user_cd)

    sql = <<-SQL
      --ユーザマスタと結合
      SELECT
        t3.*,
        t4.user_cd as authorize_user_cd,
        t4.name as authorize_user_name,
        '' as authorize_org_cd,
        '' as authorize_org_name
      FROM
        (SELECT
          t1.*,
          t2.name as user_name
        FROM m_secretaries t1,
          m_users t2
        WHERE
          t1.user_cd = '#{user_cd}'
        AND
          t1.delf = 0
        AND
          t2.delf = 0
        AND
          t1.user_cd = t2.user_cd) t3,
        m_users t4
      WHERE
        t3.authorize_user_cd = t4.user_cd

      UNION

      --組織マスタと結合
      SELECT
        t3.*,
        '' as authorize_user_cd,
        '' as authorize_user_name,
        t4.org_cd as authorize_org_cd,
        case
          when trim(t4.org_name4) != '' then org_name4
          when trim(t4.org_name3) != '' then org_name3
          when trim(t4.org_name2) != '' then org_name2
          when trim(t4.org_name1) != '' then org_name1
        end as authorize_org_name
      FROM
        (SELECT
          t1.*,
          t2.name as user_name
        FROM m_secretaries t1,
          m_users t2
        WHERE
          t1.user_cd = '#{user_cd}'
        AND
          t1.delf = 0
        AND
          t2.delf = 0
        AND
          t1.user_cd = t2.user_cd) t3,
        m_orgs t4
      WHERE
        t3.authorize_org_cd = t4.org_cd
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 秘書マスタの社員情報を返す
  # 同じ社員に対する重複データは１つにまとめる
  #
  def self.get_secretary_user_list()

    sql = <<-SQL
      SELECT
        t1.name as user_name,
        t2.user_cd,
        MAX(t2.updated_at) as updated_at,
        MAX(t2.id) as id
      FROM
         m_users t1,
         m_secretaries t2
      WHERE
        t1.user_cd = t2.user_cd
      AND
        t1.delf = 0
      AND
        t2.delf = 0
      GROUP BY
        t2.user_cd, t1.name
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数の社員コードに該当するデータを返す（重複チェック用）
  # 但し引数のid指定の場合は、id以外のデータで検索する
  # @param id - シーケンスid
  # @param user_cd - 社員CD
  #
  def self.duplicate_check_data(id, user_cd)

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_secretaries t1
      WHERE
        t1.delf = 0
      AND
        t1.user_cd = '#{user_cd}'
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
  # 秘書マスタより社員に該当するデータを取得
  # 引数の社員が秘書認定者（認定組織）かどうかを判定する為に使用する
  # @param user_cd:社員CD
  # @param org_colon_list:社員が所属する組織リスト(カンマ区切り)
  # @param pname_flg:名前に職位名を結合するか(0:結合しない, 1:結合する)
  # @return 秘書担当リスト[ユーザコード, ユーザ名]
  #
  def self.get_secretary_authorize_list(org_colon_list, user_cd, pname_flg)

    sql = <<-SQL
      SELECT
        t1.name, t1.user_cd, t5.name as position_name, t5.sort_no, t4.joined_date
      FROM m_users t1
          ,m_user_attributes t4
          ,m_positions t5
          ,(SELECT *
            FROM m_secretaries t2
            WHERE t2.delf = '0'
            AND t2.authorize_user_cd = '#{user_cd}') t3
      WHERE t1.delf = '0'
      AND   t4.delf = '0'
      AND   t5.delf = '0'
      AND   t1.user_cd = t3.user_cd
      AND   t1.user_cd = t4.user_cd
      AND   t4.position_cd = t5.position_cd 

      UNION

      SELECT t1.name, t1.user_cd, t5.name as position_name, t5.sort_no, t4.joined_date
      FROM m_users t1
          ,m_user_attributes t4
          ,m_positions t5
          ,(SELECT *
            FROM m_secretaries t2
            WHERE t2.delf = '0'
            AND t2.authorize_org_cd in (#{org_colon_list})) t3
      WHERE t1.delf = '0'
      AND   t4.delf = '0'
      AND   t5.delf = '0'
      AND   t1.user_cd = t3.user_cd
      AND   t1.user_cd = t4.user_cd
      AND   t4.position_cd = t5.position_cd 
      ORDER BY sort_no, joined_date
    SQL

    user_data = find_by_sql(sql)

    #秘書担当リスト[ユーザコード, ユーザ名]
    user_list = []
    for data in user_data
      if pname_flg == 0
        user_list << [data.user_cd, data.name]
      else
        user_list << [data.user_cd, data.name + " " + data.position_name]
      end
    end

    return user_list

  end
end
