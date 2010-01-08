class DNoticeAuth < ActiveRecord::Base
  belongs_to :d_notice_head
  #
  # お知らせ権限テーブルのうち、ユーザーに読み書きの権限が与えられているお知らせヘッダIDをキーとした組織CDのハッシュテーブルを取得します。
  #
  # @param user_cd - ログインユーザーのユーザーCD
  # @param org_cd -  ログインユーザーの組織CD
  # @return お知らせヘッダIDと組織CDのハッシュテーブル
  #
  def get_hash_headid_and_orgcd user_cd, org_cd

    result = {}
    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND (user_cd = :user_cd OR org_cd = :org_cd) AND auth_kbn = :auth_kbn "
    conditions_param[:user_cd] = user_cd
    conditions_param[:org_cd] = org_cd
    conditions_param[:auth_kbn] = "2"

    d_notice_auth = DNoticeAuth.find(:all, :conditions=>[conditions_sql, conditions_param])
    d_notice_auth.each do |notice_auth|
      result[notice_auth.d_notice_head_id] = [notice_auth.org_cd]
    end

    result
  end

  #
  #
  #
  def get_hash_noticehead_id_and_orgcd_usercd id

    result = {}

    unless id.nil?

      conditions_sql = ""
      conditions_param = {}
      order_sql = ""
      arrays = {}
      arrayOrgs = []
      arrayUsers = []

      conditions_sql = " delf = :delf"
      conditions_param[:delf] = "0"
      conditions_sql += " AND d_notice_head_id = :id "
      conditions_param[:id] = id

      order_sql = " org_cd, user_cd "

      notice_auths = DNoticeAuth.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
      unless notice_auths.nil?
        notice_auths.each do |notice_auth|
          unless notice_auth.nil?
            unless notice_auth.org_cd.empty?
              arrayOrgs[arrayOrgs.length] = notice_auth.org_cd
            end

            unless notice_auth.user_cd.empty?
              arrayUsers[arrayUsers.length] = notice_auth.user_cd
            end
          end
        end
      end

      result["orgs"] = arrayOrgs
      result["users"] = arrayUsers
    end
    result
  end

  #
  # お知らせ権限テーブルから条件に当てはまるデータのハッシュを取得します。
  # @param head_id - ヘッダID
  # @param auth_kbn - 権限区分
  # @param mode - 取得モード(0:組織が指定されているデータ, 1:社員が指定されているデータ)
  #
  def self.get_notice_auth_list head_id, auth_kbn, mode

    result = {}
    select_sql = ""
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""

    select_sql = "d_notice_auths.*"

    if mode == 0  #組織
      select_sql += ",m_orgs.org_name4 as org_name4"
      select_sql += ",m_orgs.org_name3 as org_name3"
      select_sql += ",m_orgs.org_name2 as org_name2"
      select_sql += ",m_orgs.org_name1 as org_name1"
      select_sql += ",case"
      select_sql += "  when trim(org_name4) != '' then org_name4"
      select_sql += "  when trim(org_name3) != '' then org_name3"
      select_sql += "  when trim(org_name2) != '' then org_name2"
      select_sql += "  when trim(org_name1) != '' then org_name1"
      select_sql += " end as org_name "
      joins_sql = "INNER JOIN m_orgs ON m_orgs.org_cd = d_notice_auths.org_cd and m_orgs.delf = 0"
    elsif mode == 1  #社員
      select_sql += ",m_users.name as user_name"
      joins_sql = "INNER JOIN m_users ON m_users.user_cd = d_notice_auths.user_cd and m_users.delf = 0"
    end

    conditions_sql = " d_notice_auths.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_notice_head_id = :head_id"
    conditions_sql += " AND auth_kbn = :auth_kbn"
    conditions_param[:head_id] = head_id
    conditions_param[:auth_kbn] = auth_kbn

    #SQL発行
    notice_auths = DNoticeAuth.find(:all, :select=>select_sql, :joins=>joins_sql, :order=>:id, :conditions=>[conditions_sql, conditions_param])

    notice_auths.each do |auth|
      if mode == 0  #組織
        result[auth.org_cd] = auth.org_name
      elsif mode == 1  #社員
        result[auth.user_cd] = auth.user_name
      end
    end

    result
  end
end
