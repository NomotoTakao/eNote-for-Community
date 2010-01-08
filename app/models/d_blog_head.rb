class DBlogHead < ActiveRecord::Base
  has_one :d_blog_favorite, :conditions=>"delf=0"
  has_many :d_blog_bodies, :conditions=>"delf=0"

  def get_head_by_user_cd user_cd

    conditions_sql = ""
    conditions_param = Hash.new

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql = " user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd.to_s

    DBlogHead.find(:first, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # 指定された組織に属するブロガー(d_blog_headsテーブルにレコードが存在する人)の一覧を取得します。
  #
  # @param org_cd - 組織CD
  # @return ブロガーのリスト
  #
  def get_blogger_list_by_org_cd org_cd

    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = {}
    order_sql = ""

    select_sql = " m_users.user_cd AS user_cd, m_users.name AS user_name, m_user_belongs.org_cd AS org_cd "

    joins_sql = " INNER JOIN m_users ON m_users.user_cd = d_blog_heads.user_cd "
    joins_sql += " INNER JOIN m_user_belongs ON m_user_belongs.user_cd = m_users.user_cd"
    joins_sql += " INNER JOIN m_user_attributes ON m_user_attributes.user_cd = m_users.user_cd"
    joins_sql += " INNER JOIN m_positions ON m_positions.position_cd = cast(m_user_attributes.position_cd as varchar)"

    conditions_sql = " d_blog_heads.delf = :delf "
    conditions_sql += " AND m_users.delf = :delf "
    conditions_sql += " AND m_user_belongs.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND m_user_belongs.org_cd = :org_cd "
    conditions_param[:org_cd] = org_cd

    order_sql = " m_user_attributes.sort_no, m_positions.sort_no, m_user_attributes.joined_date ASC"

    DBlogHead.find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # ブログヘッダを作成します。
  #
  # @param user_cd - ユーザーCD
  #
  def create_blog_head user_cd

    user_name = MUser.get_user_name user_cd

    d_blog_head = DBlogHead.new
    d_blog_head.title = user_name + "のブログ"
    d_blog_head.user_cd = user_cd
    d_blog_head.user_name = user_name
    d_blog_head.created_user_cd = user_cd
    d_blog_head.updated_user_cd = user_cd

    d_blog_head.save
  end
end
