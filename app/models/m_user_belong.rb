class MUserBelong < ActiveRecord::Base

  #
  # 指定されたユーザーコードのユーザーが所属する組織を配列で取得します。
  #
  # @param user_cd - ユーザーコード
  # @return 指定されたユーザーが所属する組織の配列
  #
  def get_belong_org user_cd

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd

    MUserBelong.find(:all, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # 指定されたユーザーの主所属の組織情報を取得します。
  #
  # @param user_cd - ユーザーコード
  # @return ユーザーの所属組織情報
  #
  def get_main_org user_cd

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND belong_kbn = :belong_kbn "
    conditions_param[:belong_kbn] = "0"
    conditions_sql += " AND user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd

    MUserBelong.find(:first, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # 指定されたユーザーの主所属の組織情報を取得します。（クラスメソッドとして定義）
  #
  # @param user_cd - ユーザーコード
  # @return ユーザーの所属組織情報
  #
  def self.get_main_org user_cd

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND belong_kbn = :belong_kbn "
    conditions_param[:belong_kbn] = "0"
    conditions_sql += " AND user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd

    find(:first, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # ユーザーがアクセス可能なキャビネットの存在する組織情報を取得する
  #
  # @param user_cd - ユーザーCD
  #
  def get_belong_org_info_for_cabinet user_cd

    result = []

    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = {}

    select_sql = " m_user_belongs.*,m_orgs.org_name1, m_orgs.org_name2, m_orgs.org_name3, m_orgs.org_name4, m_orgs.org_lvl"

    joins_sql = "INNER JOIN m_orgs ON m_orgs.org_cd = m_user_belongs.org_cd"

    conditions_sql = " m_user_belongs.delf = :delf"
    conditions_sql += " AND m_orgs.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND m_user_belongs.user_cd = :user_cd"
    conditions_param[:user_cd] = user_cd

    belong_orgs = MUserBelong.find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param])
    belong_orgs.each do |belong_org|
      if belong_org.org_lvl == 4
        # 上位階層の組織情報を求める。
      else
        tmp = {}
        tmp[:cd] = belong_org.org_cd
        if belong_org.org_lvl == 1
          tmp[:name] = belong_org.org_name1
        elsif belong_org.org_lvl == 2
          tmp[:name] = belong_org.org_name2
        elsif belong_org.org_lvl == 3
          tmp[:name] = belong_org.org_name3
        end
        result[result.length] = belong_org
      end
    end

    return result
  end

  #
  # 引数の組織コードに含まれる、ユーザー所属マスタのデータを返す
  #
  def self.get_belong_member_list(org_cd)

    sql = <<-SQL
      SELECT
        t1.*,
        t2.name as user_name
      FROM
        m_user_belongs t1,
        m_users t2
      WHERE
        t1.user_cd = t2.user_cd
      AND
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t1.org_cd = '#{org_cd}'
      ORDER BY
        t1.id
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数のユーザーコードに含まれる、ユーザー所属マスタのデータを返す
  # 組織名は該当組織名のみを返却
  #
  def self.get_belong_org_list(user_cd)

    sql = <<-SQL
      SELECT
        t1.*,
        t2.org_lvl,
        t2.org_cd4,
        t2.org_cd3,
        t2.org_cd2,
        t2.org_cd1,
        t2.org_name4,
        t2.org_name3,
        t2.org_name2,
        t2.org_name1,
        case
          when trim(t2.org_name4) != '' then t2.org_name4
          when trim(t2.org_name3) != '' then t2.org_name3
          when trim(t2.org_name2) != '' then t2.org_name2
          when trim(t2.org_name1) != '' then t2.org_name1
        end
      FROM
        m_user_belongs t1,
        m_orgs t2
      WHERE
        t1.org_cd = t2.org_cd
      AND
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t1.user_cd = '#{user_cd}'
      ORDER BY
        belong_kbn
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 引数のユーザーコードに含まれる、ユーザー所属マスタのデータを返す
  # 組織名は表示用に加工して返却
  #
  def self.get_belong_org_list_disp(user_cd)

    sql = <<-SQL
      SELECT
        t1.*,
        t2.org_lvl,
        t2.org_cd4,
        t2.org_cd3,
        t2.org_cd2,
        t2.org_cd1,
        t2.org_name4,
        t2.org_name3,
        t2.org_name2,
        t2.org_name1,
        replace(t2.org_name2, '-', '') || ' ' || replace(t2.org_name3, '-', '') || ' ' || t2.org_name4 as org_name
      FROM
        m_user_belongs t1,
        m_orgs t2
      WHERE
        t1.org_cd = t2.org_cd
      AND
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t1.user_cd = '#{user_cd}'
      ORDER BY
        belong_kbn
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  #
  #
  def self.register params

    unless params[:m_user_belongs].nil?

      m_user_belong = find(:first, :conditions=>{:delf=>0, :user_cd=>params[:m_user_belong][:user_cd]})
      unless m_user_belong.nil?
        m_user_belong = MUserBelong.new
        m_user_belong.created_user_cd = params[:m_user_belongs][:created_user_cd]
      end
      unless params[:m_user_belongs][:org_cd].nil?
        m_user_belong.org_cd = params[:m_user_belongs][:org_cd]
      end
      unless params[:m_user_belongs][:belong_kbn].nil?
        m_user_belong.belong_kbn = params[:m_user_belongs][:belong_kbn]
      end
      unless params[:m_user_belongs][:updated_user_cd]
        m_user_belong.updated_user_cd = params[:m_user_belongs][:updated_user_cd]
      end
      begin
        m_user_belong.save!
      rescue
        p $!
        raise
      end
    end
  end
end
