class DAddress < ActiveRecord::Base
  has_one :d_address_group_list

  class << self
    HUMANIZED_ATTRIBUTE_KEY_NAMES = {
    }

    def human_attribute_name(attribute_key_name)
      HUMANIZED_ATTRIBUTE_KEY_NAMES[attribute_key_name] || super
    end
  end

  #
  # 引数の組織コードに所属する社員のメールアドレスの配列を返す
  # Webメール用
  #
  def self.get_orgs_user_address(org_cd, gkbn)

    sql = <<-SQL
      SELECT
        t1.user_cd,
        t1.name,
        t8.org_cd,
        t1.email_address1,
        t1.email_address2,
        t1.email_address3,
        t1.mobile_address
      FROM d_addresses t1
         ,(SELECT t2.user_cd as user_cd
         , t2.org_cd as org_cd
         , t2.org_name
         , t3.joined_date as joined_date
         , t3.sort_no as u_sort_no
         , t4.sort_no as p_sort_no
         FROM m_user_attributes t3
            , m_positions t4
            ,(SELECT t5.user_cd as user_cd, t9.org_cd as org_cd, t9.org_name
              FROM   m_users t5
              , (SELECT t7.user_cd as user_cd,
                        t7.org_cd as org_cd,
                        t6.org_name4 as org_name4,
                        t6.org_name3 as org_name3,
                        t6.org_name2 as org_name2,
                        t6.org_name1 as org_name1,
                        case
                          when trim(org_name4) != '' and trim(org_name3) != '-' then org_name3 || '<BR>' || org_name4
                          when trim(org_name4) != '' and trim(org_name3) != '' then org_name2 || '<BR>' || org_name4
                          when trim(org_name3) != '' then org_name3
                          when trim(org_name2) != '' then org_name2
                          when trim(org_name1) != '' then org_name1
                        end as org_name
                 FROM  m_orgs t6, m_user_belongs t7
                 WHERE t6.delf = '0'
                 AND   t7.delf = '0'
                 AND   t6.org_cd = t7.org_cd
                 ) t9
              WHERE  t5.delf = '0'
              AND  t5.user_cd = t9.user_cd) t2
         WHERE  t3.delf = '0'
         AND    t4.delf = '0'
         AND    t3.position_cd = t4.position_cd
         AND    t3.user_cd = t2.user_cd) t8
       WHERE
         t1.delf = '0'
       AND t1.user_cd = t8.user_cd
       AND t8.org_cd = '#{org_cd}'
       ORDER BY t8.u_sort_no,t8.p_sort_no,t8.joined_date
    SQL

    recs = find_by_sql(sql)

    result = []
    recs.each do |rec|
      if gkbn == "1"
        unless rec.email_address1.nil? || rec.email_address1.blank?
          result << '"' + rec.name + '" ' + "<#{rec.email_address1}>"
        end
        unless rec.email_address2.nil? || rec.email_address2.blank?
          result << '"' + rec.name + '" ' + "<#{rec.email_address2}>"
        end
        unless rec.email_address3.nil? || rec.email_address3.blank?
          result << '"' + rec.name + '" ' + "<#{rec.email_address3}>"
        end
      elsif gkbn == "11"
        unless rec.mobile_address.nil? || rec.mobile_address.blank?
          result << '"' + rec.name + '" ' + "<#{rec.mobile_address}>"
        end
      end
    end
    result
  end

  #
  # 引数のプロジェクトIDに所属するメールアドレスの配列を返す
  # Webメール用
  #
  def self.get_project_user_address(proid)
    sql = <<-SQL
      SELECT
        t6.user_cd,
        t6.name,
        t6.project_id,
        t6.email_address1,
        t6.email_address2,
        t6.email_address3,
        t6.mobile_address
      FROM
       (SELECT t1.*,
               t5.org_cd,
               t4.project_id
        FROM  d_addresses t1,
             (SELECT t2.user_cd as user_cd
                   , t3.id as project_id
              FROM   m_projects t3
                    ,m_project_users t2
              WHERE  t3.delf = '0'
              AND    t2.delf = '0'
              AND    t3.id = t2.project_id) t4,
              m_user_belongs t5
        WHERE t1.delf = 0
        AND   t5.delf = 0
        AND   t1.user_cd = t4.user_cd
        AND   t1.user_cd = t5.user_cd
        AND   t5.belong_kbn = 0 --主所属
        AND   t4.project_id = #{proid}) t6,
        m_orgs t7,
        (SELECT t8.joined_date,
                t8.sort_no as u_sort_no,
                t9.sort_no as p_sort_no,
                t8.user_cd
         FROM   m_user_attributes t8,
                m_positions t9
         WHERE  t8.delf = 0
         AND    t9.delf = 0
         AND    t8.position_cd = t9.position_cd) t10
      WHERE
        t7.delf = 0
      AND t6.org_cd = t7.org_cd
      AND t6.user_cd = t10.user_cd
      ORDER BY
        t10.u_sort_no, t7.org_cd, t10.p_sort_no,t10.joined_date
    SQL

    recs = find_by_sql(sql)

    result = []
    recs.each do |rec|
      unless rec.email_address1.nil? || rec.email_address1.blank?
        result << '"' + rec.name + '" ' + "<#{rec.email_address1}>"
      end
#      unless rec.email_address2.nil? || rec.email_address2.blank?
#        result << '"' + rec.name + '" ' + "<#{rec.email_address2}>"
#      end
#      unless rec.email_address3.nil? || rec.email_address3.blank?
#        result << '"' + rec.name + '" ' + "<#{rec.email_address3}>"
#      end
# 携帯のアドレスはいらない
#      unless rec.mobile_address.nil? || rec.mobile_address.blank?
#        result << '"' + rec.name + '" ' + "<#{rec.mobile_address}>"
#      end
    end
    result
  end

  #
  # 引数のグループIDに所属するメールアドレスの配列を返す(共用)
  # Webメール用
  #
  def self.get_public_group_address(gid)
    sql = <<-SQL
      SELECT
        t4.name,
        t4.email_address1,
        t4.email_address2,
        t4.email_address3,
        t4.mobile_address
      FROM
        (SELECT
          t2.*,
          t3.org_cd
        FROM d_address_group_lists t1,
             d_addresses t2,
             m_user_belongs t3
        WHERE
            t1.d_address_id = t2.id
        AND t1.private_user_cd = '0'
        AND t1.d_address_group_id = #{gid}
        AND t2.user_cd = t3.user_cd
        AND t3.belong_kbn = 0 --主所属
        AND t1.delf = 0
        AND t2.delf = 0
        AND t3.delf = 0) t4,
        m_orgs t5,
        (SELECT t6.joined_date,
                t6.sort_no as u_sort_no,
                t7.sort_no as p_sort_no,
                t6.user_cd
         FROM   m_user_attributes t6,
                m_positions t7
         WHERE  t6.delf = 0
         AND    t7.delf = 0
         AND    t6.position_cd = t7.position_cd) t8
      WHERE
          t5.delf = 0
      AND t4.org_cd = t5.org_cd
      AND t4.user_cd = t8.user_cd
      ORDER BY
        t8.u_sort_no,t5.org_cd,t8.p_sort_no,t8.joined_date
    SQL
    recs = find_by_sql(sql)

    result = []
    recs.each do |rec|
      unless rec.email_address1.nil? || rec.email_address1.blank?
        result << '"' + rec.name + '" ' + "<#{rec.email_address1}>"
      end
#      unless rec.email_address2.nil? || rec.email_address2.blank?
#        result << '"' + rec.name + '" ' + "<#{rec.email_address2}>"
#      end
#      unless rec.email_address3.nil? || rec.email_address3.blank?
#        result << '"' + rec.name + '" ' + "<#{rec.email_address3}>"
#      end
# 携帯のアドレスは要らない
#      unless rec.mobile_address.nil? || rec.mobile_address.blank?
#        result << '"' + rec.name + '" ' + "<#{rec.mobile_address}>"
#      end
    end
    result
  end

  #
  # 引数のグループIDに所属するメールアドレスの配列を返す(個人)
  # Webメール用
  #
  def self.get_mygroup_address(gid, gkbn, user_cd)

    if gid == 0
      #全てのとき
      recs = self.find(:all, :conditions => ["private_user_cd = ? AND delf = 0", user_cd], :order => "name")
    else
      #グループが選択されたとき
      sql = <<-SQL
        SELECT
          t2.name,
          t2.email_address1,
          t2.email_address2,
          t2.email_address3,
          t2.mobile_address
        FROM d_address_group_lists t1, d_addresses t2
        WHERE
            t1.d_address_id = t2.id
        AND t1.private_user_cd = '#{user_cd}'
        AND t1.d_address_group_id = #{gid}
        AND t1.delf = 0
        AND t2.delf = 0
        ORDER BY
          t2.id
      SQL
      recs = find_by_sql(sql)
    end

    result = []
    recs.each do |rec|
      if gkbn == '9' #パソコンメール
        unless rec.email_address1.nil? || rec.email_address1.blank?
          result << '"' + rec.name + '" ' + "<#{rec.email_address1}>"
        end
        unless rec.email_address2.nil? || rec.email_address2.blank?
          result << '"' + rec.name + '" ' + "<#{rec.email_address2}>"
        end
        unless rec.email_address3.nil? || rec.email_address3.blank?
          result << '"' + rec.name + '" ' + "<#{rec.email_address3}>"
        end

      elsif gkbn == '10' #携帯メール
        unless rec.mobile_address.nil? || rec.mobile_address.blank?
          result << '"' + rec.name + '" ' + "<#{rec.mobile_address}>"
        end
      end
    end
    result
  end

  #
  # 引数の検索単語でのLIKE検索にヒットするメールアドレスの配列を返す
  # LIKE検索対象項目：名前/カナ/メールアドレス/検索キーワード
  # Webメール用
  #
  def self.get_sword_address(sword,user_cd)

    sql = <<-SQL
      SELECT
        t1.name,
        t1.email_address1,
        t1.email_address2,
        t1.email_address3,
        t1.mobile_address
      FROM d_addresses t1
      WHERE
          t1.delf = 0
      AND (t1.name LIKE '%#{sword}%'
      OR   t1.name_kana LIKE '%#{sword}%' --全角カタカナ
      OR   t1.name_kana LIKE '%#{sword.tr('ぁ-ん', 'ァ-ン')}%' --全角ひらがな
      OR   t1.email_address1 LIKE '%#{sword}%'
      OR   t1.meta_tag LIKE '%#{sword}%')
      AND ((t1.address_kbn = 9
      AND  t1.private_user_cd = '#{user_cd}')
      OR   t1.address_kbn != 9)
      ORDER BY
        t1.id
    SQL
    recs = find_by_sql(sql)

    result = []
    recs.each do |rec|
      unless rec.email_address1.nil? || rec.email_address1.blank?
        result << '"' + rec.name + '" ' + "<#{rec.email_address1}>"
      end
      unless rec.email_address2.nil? || rec.email_address2.blank?
        result << '"' + rec.name + '" ' + "<#{rec.email_address2}>"
      end
      unless rec.email_address3.nil? || rec.email_address3.blank?
        result << '"' + rec.name + '" ' + "<#{rec.email_address3}>"
      end
      unless rec.mobile_address.nil? || rec.mobile_address.blank?
        result << '"' + rec.name + '" ' + "<#{rec.mobile_address}>"
      end
    end
    result
  end

  #
  # アドレスが既にテーブルに登録されているかチェックする
  # @return true:登録されているアドレス, false:登録されていないアドレス
  #
  def self.check_already_exist(address, user_cd)

    #グループが選択されたとき
    sql = <<-SQL
      SELECT
        t1.id
      FROM d_addresses t1
      WHERE
          t1.delf = 0
      AND (t1.private_user_cd = '#{user_cd}'
      OR   t1.private_user_cd = '')
      AND (t1.email_address1 = '#{address}'
      OR   t1.email_address2 = '#{address}'
      OR   t1.email_address3 = '#{address}'
      OR   t1.mobile_address = '#{address}')
    SQL
    recs = find_by_sql(sql)
    if recs.size > 0
      return true
    else
      return false
    end
  end

  #
  # 引数のユーザーコードに属するデータを返す
  #
  def self.get_address_by_user(user_cd)

    sql = <<-SQL
      SELECT
        t1.*
      FROM d_addresses t1
      WHERE t1.delf = 0
      AND t1.user_cd = '#{user_cd}'
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数のプロジェクトIDに所属するユーザ情報を返す
  # アドレス帳用
  # @param mode - 0:paginateなし, 1:paginateあり
  #
  def self.get_project_user_info(proid, page, max_page_record, mode)

    sql = <<-SQL
      SELECT t6.*,
        t7.org_name4 as org_name4,
        t7.org_name3 as org_name3,
        t7.org_name2 as org_name2,
        t7.org_name1 as org_name1,
        case
          when trim(org_name4) != '' and trim(org_name3) != '-' then org_name3 || '<BR>' || org_name4
          when trim(org_name4) != '' and trim(org_name3) != '' then org_name2 || '<BR>' || org_name4
          when trim(org_name3) != '' then org_name3
          when trim(org_name2) != '' then org_name2
          when trim(org_name1) != '' then org_name1
        end as org_name
      FROM
       (SELECT t1.*,
               t5.org_cd
        FROM  d_addresses t1,
             (SELECT t2.user_cd as user_cd
                   , t3.id as project_id
              FROM   m_projects t3
                    ,m_project_users t2
              WHERE  t3.delf = '0'
              AND    t2.delf = '0'
              AND    t3.id = t2.project_id) t4,
              m_user_belongs t5
        WHERE t1.delf = 0
        AND   t5.delf = 0
        AND   t1.user_cd = t4.user_cd
        AND   t1.user_cd = t5.user_cd
        AND   t5.belong_kbn = 0 --主所属
        AND   t4.project_id = #{proid}) t6,
        m_orgs t7,
        (SELECT t8.joined_date,
                t8.sort_no as u_sort_no,
                t9.sort_no as p_sort_no,
                t8.user_cd
         FROM   m_user_attributes t8,
                m_positions t9
         WHERE  t8.delf = 0
         AND    t9.delf = 0
         AND    t8.position_cd = t9.position_cd) t10
      WHERE
        t7.delf = 0
      AND t6.org_cd = t7.org_cd
      AND t6.user_cd = t10.user_cd
      ORDER BY
        t10.u_sort_no, t7.org_cd, t10.p_sort_no,t10.joined_date
    SQL

    #paginateなし
    if mode == 0
      recs = DAddress.find_by_sql(sql)
    #paginateあり
    else
      recs = paginate_by_sql(sql, :page => page, :per_page => max_page_record)
    end
    return recs
  end

  #
  # 引数の組織コードに所属する社員のユーザ情報を返す
  # アドレス帳用
  # @param mode - 0:paginateなし, 1:paginateあり
  #
  def self.get_orgs_user_info(org_cd, page, max_page_record, mode)

    sql = <<-SQL
      SELECT t1.*,
             t8.org_name
      FROM d_addresses t1
         ,(SELECT t2.user_cd as user_cd
         , t2.org_cd as org_cd
         , t2.org_name
         , t3.joined_date as joined_date
         , t3.sort_no as u_sort_no
         , t4.sort_no as p_sort_no
         FROM m_user_attributes t3
            , m_positions t4
            ,(SELECT t5.user_cd as user_cd, t9.org_cd as org_cd, t9.org_name
              FROM   m_users t5
              , (SELECT t7.user_cd as user_cd,
                        t7.org_cd as org_cd,
                        t6.org_name4 as org_name4,
                        t6.org_name3 as org_name3,
                        t6.org_name2 as org_name2,
                        t6.org_name1 as org_name1,
                        case
                          when trim(org_name4) != '' and trim(org_name3) != '-' then org_name3 || '<BR>' || org_name4
                          when trim(org_name4) != '' and trim(org_name3) != '' then org_name2 || '<BR>' || org_name4
                          when trim(org_name3) != '' then org_name3
                          when trim(org_name2) != '' then org_name2
                          when trim(org_name1) != '' then org_name1
                        end as org_name
                 FROM  m_orgs t6, m_user_belongs t7
                 WHERE t6.delf = '0'
                 AND   t7.delf = '0'
                 AND   t6.org_cd = t7.org_cd
                 ) t9
              WHERE  t5.delf = '0'
              AND  t5.user_cd = t9.user_cd) t2
         WHERE  t3.delf = '0'
         AND    t4.delf = '0'
         AND    t3.position_cd = t4.position_cd
         AND    t3.user_cd = t2.user_cd) t8
       WHERE
         t1.delf = '0'
       AND t1.user_cd = t8.user_cd
       AND t8.org_cd = '#{org_cd}'
       ORDER BY t8.u_sort_no,t8.p_sort_no,t8.joined_date
    SQL

    #paginateなし
    if mode == 0
      recs = DAddress.find_by_sql(sql)
    #paginateあり
    else
      recs = paginate_by_sql(sql, :page => page, :per_page => max_page_record)
    end

    return recs
  end

  #
  # 引数の検索単語でのLIKE検索にヒットするユーザ情報を返す
  # LIKE検索対象項目：名前/カナ/メールアドレス/検索キーワード/携帯番号
  # アドレス帳用
  # @param mode - 0:paginateなし, 1:paginateあり
  #
  def self.get_sword_user_info(sword, user_cd, page, max_page_record, mode)

    sql = <<-SQL
      SELECT
        t1.*
      FROM d_addresses t1
      WHERE
          t1.delf = 0
      AND (t1.name LIKE '%#{sword}%'
      OR   t1.name_kana LIKE '%#{sword}%' --全角カタカナ
      OR   t1.name_kana LIKE '%#{sword.tr('ぁ-ん', 'ァ-ン')}%' --全角ひらがな
      OR   t1.email_address1 LIKE '%#{sword}%'
      OR   t1.meta_tag LIKE '%#{sword}%'
      OR   REPLACE(t1.mobile_no, '-', '') LIKE '%#{sword.gsub("-", "")}%')
      AND ((t1.address_kbn = 9
      AND  t1.private_user_cd = '#{user_cd}')
      OR   t1.address_kbn != 9)
      ORDER BY
        address_kbn desc,private_user_cd,name_kana
    SQL

    #paginateなし
    if mode == 0
      recs = DAddress.find_by_sql(sql)
    #paginateあり
    else
      recs = paginate_by_sql(sql, :page => page, :per_page => max_page_record)
    end

    return recs
  end

  #
  # 引数のグループIDに所属するユーザ情報を返す(共用)
  # アドレス帳用
  # @param mode - 0:paginateなし, 1:paginateあり
  #
  def self.get_public_group_info(gid, page, max_page_record, mode)
    sql = <<-SQL
      SELECT t4.*,
        t5.org_name4 as org_name4,
        t5.org_name3 as org_name3,
        t5.org_name2 as org_name2,
        t5.org_name1 as org_name1,
        case
          when trim(org_name4) != '' and trim(org_name3) != '-' then org_name3 || '<BR>' || org_name4
          when trim(org_name4) != '' and trim(org_name3) != '' then org_name2 || '<BR>' || org_name4
          when trim(org_name3) != '' then org_name3
          when trim(org_name2) != '' then org_name2
          when trim(org_name1) != '' then org_name1
        end as org_name
      FROM
        (SELECT
          t2.*,
          t3.org_cd
        FROM d_address_group_lists t1,
             d_addresses t2,
             m_user_belongs t3
        WHERE
            t1.d_address_id = t2.id
        AND t1.private_user_cd = '0'
        AND t1.d_address_group_id = #{gid}
        AND t2.user_cd = t3.user_cd
        AND t3.belong_kbn = 0 --主所属
        AND t1.delf = 0
        AND t2.delf = 0
        AND t3.delf = 0) t4,
        m_orgs t5,
        (SELECT t6.joined_date,
                t6.sort_no as u_sort_no,
                t7.sort_no as p_sort_no,
                t6.user_cd
         FROM   m_user_attributes t6,
                m_positions t7
         WHERE  t6.delf = 0
         AND    t7.delf = 0
         AND    t6.position_cd = t7.position_cd) t8
      WHERE
          t5.delf = 0
      AND t4.org_cd = t5.org_cd
      AND t4.user_cd = t8.user_cd
      ORDER BY
        t8.u_sort_no,t5.org_cd,t8.p_sort_no,t8.joined_date
    SQL

    #paginateなし
    if mode == 0
      recs = DAddress.find_by_sql(sql)
    #paginateあり
    else
      recs = paginate_by_sql(sql, :page => page, :per_page => max_page_record)
    end

    return recs
  end

  #
  # 引数のグループIDに所属するユーザ情報を返す(個人)
  # アドレス帳用
  # @param mode - 0:paginateなし, 1:paginateあり
  #
  def self.get_mygroup_info(gid, user_cd, page, max_page_record, mode)

    if gid == 0
      #全てが選択されたとき
      sql = <<-SQL
        SELECT
          t1.*
        FROM d_addresses t1
        WHERE
            t1.private_user_cd = '#{user_cd}'
        AND t1.delf = 0
        ORDER BY
          t1.name
      SQL
    else
      #グループが選択されたとき
      sql = <<-SQL
        SELECT
          t2.*
        FROM d_address_group_lists t1, d_addresses t2
        WHERE
            t1.d_address_id = t2.id
        AND t1.private_user_cd = '#{user_cd}'
        AND t1.d_address_group_id = #{gid}
        AND t1.delf = 0
        AND t2.delf = 0
        ORDER BY
          t1.id
      SQL
    end

    #paginateなし
    if mode == 0
      recs = DAddress.find_by_sql(sql)
    #paginateあり
    else
      recs = paginate_by_sql(sql, :page => page, :per_page => max_page_record)
    end

    return recs
  end

  def self.export_row_head
    ["グループ","名前","名前カナ","Eメール表示名","Eメールアドレス","Eメールアドレス(その他)","Eメールアドレス(その他)","郵便番号",
     "住所1","住所2","住所3","自宅電話番号","自宅FAX","携帯電話番号","携帯電話メールアドレス","ホームページ",
     "誕生日","記念日名称1","記念日1","記念日名称2","記念日2","記念日名称3","記念日3","勤務先名","勤務先名カナ",
     "勤務先部署","勤務先役職","勤務先郵便番号","勤務先住所1","勤務先住所2","勤務先住所3",
     "勤務先電話番号1","勤務先電話番号2","勤務先FAX","勤務先ホームページ","検索キーワード","備考"]
  end
  def export_row
    [grp_name,name,name_kana,email_name,email_address1,email_address2,email_address3,zip_cd,
     address1,address2,address3,tel,fax,mobile_no,mobile_address,homepage_url,
     birthday,memorial_name1,memorial_date1,memorial_name2,memorial_date2,
     memorial_name3,memorial_date3,company_name,company_name_kana,company_post,
     company_job,company_zip_cd,company_address1,company_address2,company_address3,
     company_tel1,company_tel2,company_fax,company_homepage_url,meta_tag,memo]
  end


  #
  # ユーザーのアドレス一覧を取得します。
  #
  # @param group_id - アドレスグループ(1:推進、2:営業部長、3:支店長、4:課長)
  # @param keyword  - 検索語(ユーザー名を走査)
  #
  def self.get_address_list_by_group_with_keyword group_id, keyword

    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    select_sql += " m_users.user_cd"
    select_sql += ",m_users.name"
    select_sql += ",d_address_groups.title"
    select_sql += ",m_orgs.org_name1"
    select_sql += ",m_orgs.org_name2"
    select_sql += ",m_orgs.org_name3"
    select_sql += ",m_orgs.org_name4"
    select_sql += ",d_addresses.email_address1"

    joins_sql += " INNER JOIN m_users on m_users.user_cd = d_addresses.user_cd "
    joins_sql += " INNER JOIN m_user_belongs on m_user_belongs.user_cd = m_users.user_cd "
    joins_sql += " INNER JOIN m_user_attributes on m_user_attributes.user_cd = m_users.user_cd"
    joins_sql += " INNER JOIN m_positions on m_positions.position_cd = m_user_attributes.position_cd"
    joins_sql += " INNER JOIN m_orgs on m_orgs.org_cd = m_user_belongs.org_cd "
    joins_sql += " INNER JOIN d_address_group_lists on d_address_group_lists.d_address_id = d_addresses.id "
    joins_sql += " INNER JOIN d_address_groups on d_address_groups.id = d_address_group_id "

    conditions_sql += " d_addresses.delf = :delf "
    conditions_sql += " AND m_users.delf = :delf "
    conditions_sql += " AND m_user_belongs.delf = :delf "
    conditions_sql += " AND m_user_attributes.delf = :delf "
    conditions_sql += " AND m_positions.delf = :delf "
    conditions_sql += " AND m_orgs.delf = :delf "
    conditions_sql += " AND d_address_group_lists.delf = :delf "
    conditions_sql += " AND d_address_groups.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND m_user_belongs.belong_kbn = :belong_kbn "
    conditions_param[:belong_kbn] = 0
    unless group_id.nil? or group_id.empty?
      conditions_sql += " AND d_address_groups.id = :group_id "
      conditions_param[:group_id] = group_id
    end
    unless keyword.nil? or keyword.empty?
      conditions_sql += " AND m_users.name like :keyword "
      conditions_param[:keyword] = "%" + keyword + "%"
    end

    order_sql += " m_user_attributes.sort_no "
    order_sql += " ,m_positions.sort_no "
    order_sql += " ,m_user_attributes.joined_date"

    return find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # グループに所属するユーザーの名前とメールアドレスを連結した文字列を返す。
  #
  #  @param group_id - グループID
  #
  def self.member_list group_id

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    joins_sql += " INNER JOIN d_address_group_lists on d_address_group_lists.d_address_id = d_addresses.id"
    joins_sql += " INNER JOIN d_address_groups on d_address_groups.id = d_address_group_lists.d_address_group_id"
    conditions_sql += " d_addresses.delf = :delf"
    conditions_sql += " AND d_address_group_lists.delf = :delf"
    conditions_sql += " AND d_address_groups.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND d_address_groups.id = :group_id"
    conditions_param[:group_id] = group_id
    order_sql += " d_addresses.id ASC"

    return find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 引数に渡された得意先CDの得意先に所属する社員の一覧を取得します。
  #
  # @param company_cd - 得意先CD
  #
  def self.get_employee_list company_cd

    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    select_sql += " d_addresses.id,"
    select_sql += " d_addresses.company_cd,"
    select_sql += " d_addresses.company_post,"
    select_sql += " d_addresses.company_job,"
    select_sql += " d_addresses.name,"
    select_sql += " d_addresses.email_address1,"
    select_sql += " d_addresses.mobile_no,"
    select_sql += " m_customers.tel1"

    joins_sql = " INNER JOIN m_customers on m_customers.company_cd = d_addresses.company_cd"

    conditions_sql += " d_addresses.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_addresses.company_cd = :company_cd "
    conditions_param[:company_cd] = company_cd

    order_sql += " d_addresses.id"

    return find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  #
  #
  def self.register params, user_cd

    unless params.nil?
      m_customer = MCustomer.find(:first, :conditions=>{:delf=>0, :company_cd=>params[:company_cd]})
      if params[:id].nil? or params[:id].empty?
        d_address = DAddress.new
        d_address.created_user_cd = user_cd
      else
        d_address = DAddress.find(:first, :conditions=>{:delf=>0, :id=>params[:id]})
      end
      if d_address.nil?
        d_address = DAddress.new
        d_address.created_user_cd = user_cd
      end
      d_address.company_cd = params[:company_cd]
      d_address.company_post = params[:company_post]
      d_address.company_job = params[:company_job]
      d_address.name_kana = params[:name_kana]
      d_address.name = params[:name]
      d_address.email_address1 = params[:email_address1]
      d_address.mobile_no = params[:mobile_no]
      d_address.mobile_address = params[:mobile_address]
      d_address.memo = params[:memo]
      d_address.updated_user_cd = user_cd

      begin
        d_address.save!
      rescue
        p $!
        raise
      end
    end
  end
end
