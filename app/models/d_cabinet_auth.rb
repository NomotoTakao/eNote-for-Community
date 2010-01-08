class DCabinetAuth < ActiveRecord::Base

  #
  # キャビネット権限テーブルのIDをキーとする権限区分のハッシュを取得します。
  #
  def get_hash_id_and_kbn user_cd, org_cd

    result = {}
    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND user_cd = :user_cd OR org_cd = :org_cd"
    conditions_param[:user_cd] = user_cd
    conditions_param[:org_cd] = org_cd
    cabinet_auths = DCabinetAuth.find(:all, :order=>:id, :conditions=>[conditions_sql, conditions_param])

    cabinet_auths.each do |auth|
      result[auth.id] = auth.auth_kbn
    end

    result
  end

  #
  # キャビネット権限テーブルから条件に当てはまるデータのハッシュを取得します。
  # @param head_id - ヘッダID
  # @param auth_kbn - 権限区分
  # @param mode - 取得モード(0:組織が指定されているデータ, 1:社員が指定されているデータ)
  #
  def self.get_cabinet_auth_list head_id, auth_kbn, mode

    result = {}
    select_sql = ""
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""

    select_sql = "d_cabinet_auths.*"

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
      joins_sql = "INNER JOIN m_orgs ON m_orgs.org_cd = d_cabinet_auths.org_cd and m_orgs.delf = 0"
    elsif mode == 1  #社員
      select_sql += ",m_users.name as user_name"
      joins_sql = "INNER JOIN m_users ON m_users.user_cd = d_cabinet_auths.user_cd and m_users.delf = 0"
    end

    conditions_sql = " d_cabinet_auths.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_cabinet_head_id = :head_id"
    conditions_sql += " AND auth_kbn = :auth_kbn"
    conditions_param[:head_id] = head_id
    conditions_param[:auth_kbn] = auth_kbn

    #SQL発行
    cabinet_auths = DCabinetAuth.find(:all, :select=>select_sql, :joins=>joins_sql, :order=>:id, :conditions=>[conditions_sql, conditions_param])

    cabinet_auths.each do |auth|
      if mode == 0  #組織
        result[auth.org_cd] = auth.org_name
      elsif mode == 1  #社員
        result[auth.user_cd] = auth.user_name
      end
    end

    result
  end
end
