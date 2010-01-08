class MMenuAuth < ActiveRecord::Base
  #
  # メニュー権限テーブルから条件に当てはまるデータのハッシュを取得します。
  # @param menu_id - メニューID
  # @param mode - 取得モード(0:組織が指定されているデータ, 1:社員が指定されているデータ)
  #
  def self.get_menu_auth_list menu_id, mode

    result = {}
    select_sql = ""
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""

    select_sql = "m_menu_auths.*"

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
      joins_sql = "INNER JOIN m_orgs ON m_orgs.org_cd = m_menu_auths.org_cd and m_orgs.delf = 0"
    elsif mode == 1  #社員
      select_sql += ",m_users.name as user_name"
      joins_sql = "INNER JOIN m_users ON m_users.user_cd = m_menu_auths.user_cd and m_users.delf = 0"
    end

    conditions_sql = " m_menu_auths.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND menu_id = :menu_id"
    conditions_param[:menu_id] = menu_id

    #SQL発行
    menu_auths = MMenuAuth.find(:all, :select=>select_sql, :joins=>joins_sql, :order=>:id, :conditions=>[conditions_sql, conditions_param])

    menu_auths.each do |auth|
      if mode == 0  #組織
        result[auth.org_cd] = auth.org_name
      elsif mode == 1  #社員
        result[auth.user_cd] = auth.user_name
      end
    end

    result
  end
end
