class DNoticeHead < ActiveRecord::Base
  has_many :d_notice_bodies
  has_one :d_notice_auth
  has_one :d_notice_index, :conditions=>"delf=0"
  
  #
  # お知らせヘッダテーブルのうち、削除フラグが立っておらず、お知らせ権限テーブルの権限区分が"2"のものを取得する。
  #
  # @param user_cd - ログインユーザーのユーザーコード 
  # @param org_cd - ログインユーザーの所属する組織コード
  #
  def get_list user_cd, org_cd
    
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""
    
#    joins_sql = " INNER JOIN d_notice_auths ON d_notice_heads.id = d_notice_auths.d_notice_head_id "
    
    conditions_sql = " d_notice_heads.delf = :delf "
#    conditions_sql += " AND d_notice_auths.delf = :delf "
    conditions_param[:delf] = "0"
#    conditions_sql += " AND (   d_notice_auths.user_cd = :user_cd "
#    conditions_param[:user_cd] = user_cd
#    conditions_sql +=      " OR d_notice_auths.org_cd = :org_cd) "
#    conditions_param[:org_cd] = org_cd
#    conditions_sql += " AND d_notice_auths.auth_kbn = :kbn"
#    conditions_sql[:kbn] = "2"
    
    order_sql = " id ASC"
    
    DNoticeHead.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end
  
  #
  # 指定されたIDのお知らせを取得する。
  # 指定したIDのお知らせが存在しない、または権限区分が"2"出ない場合はnilを返す。
  #
  # @param id - お知らせヘッダID
  # @param user_cd - ログインユーザーのユーザーコード 
  # @param org_cd - ログインユーザーの所属する組織コード
  #
  def get_by_id id, user_cd, org_cd
    
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    
#    joins_sql = " INNER JOIN d_notice_auths ON d_notice_heads.id = d_notice_auths.d_notice_head_id "
    
    conditions_sql = " d_notice_heads.delf = :delf "
#    conditions_sql += " AND d_notice_auths.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_notice_heads.id = :id "
    conditions_param[:id] = id
#    conditions_sql += " AND (    d_notice_auths.user_cd = :user_cd "
#    conditions_param[:user_cd] = user_cd
#    conditions_sql +=       " OR d_notice_auths.org_cd = :org_cd) "
#    conditions_param[:org_cd] = org_cd
#    conditions_sql += " AND d_notice_auths.auth_kbn = :kbn"
#    conditions_param[:kbn] = 2
    
    DNoticeHead.find(:first, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param])
  end
  
end
