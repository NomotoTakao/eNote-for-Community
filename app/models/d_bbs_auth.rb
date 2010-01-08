class DBbsAuth < ActiveRecord::Base
  #
  # 掲示板権限テーブルから条件に当てはまるデータのハッシュを取得します。
  # @param board_id - ボードID
  # @param auth_kbn - 権限区分
  # @param mode - 取得モード(0:組織が指定されているデータ, 1:社員が指定されているデータ)
  #
  def self.get_bbs_auth_list board_id, auth_kbn, mode

    result = {}
    select_sql = ""
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""

    select_sql = "d_bbs_auths.*"

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
      joins_sql = "INNER JOIN m_orgs ON m_orgs.org_cd = d_bbs_auths.org_cd and m_orgs.delf = 0"
    elsif mode == 1  #社員
      select_sql += ",m_users.name as user_name"
      joins_sql = "INNER JOIN m_users ON m_users.user_cd = d_bbs_auths.user_cd and m_users.delf = 0"
    end

    conditions_sql = " d_bbs_auths.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_bbs_board_id = :board_id"
    conditions_sql += " AND auth_kbn = :auth_kbn"
    conditions_param[:board_id] = board_id
    conditions_param[:auth_kbn] = auth_kbn

    #SQL発行
    bbs_auths = DBbsAuth.find(:all, :select=>select_sql, :joins=>joins_sql, :order=>:id, :conditions=>[conditions_sql, conditions_param])

    bbs_auths.each do |auth|
      if mode == 0  #組織
        result[auth.org_cd] = auth.org_name
      elsif mode == 1  #社員
        result[auth.user_cd] = auth.user_name
      end
    end

    result
  end
end
