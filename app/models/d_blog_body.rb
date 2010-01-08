class DBlogBody < ActiveRecord::Base
  belongs_to :d_blog_head
  has_many :d_blog_tags, :conditions=>"delf=0"
  
  def get_article_by_id id
    
    conditions_sql = ""
    conditions_param = {}
    
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND id = :id"
    conditions_param[:id] = id.to_s
    
    DBlogBody.find(:first, :conditions=>[conditions_sql, conditions_param])
  end
  
  #
  # 指定されたユーザーの新着ブログ一覧を取得します。
  #
  # @param user_cd - ユーザーCD
  # @param limit - 新着記事件数
  # @return 新着ブログリスト
  #
  def get_newly_list user_cd, limit
    
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    joins_sql = " INNER JOIN d_blog_heads ON d_blog_bodies.d_blog_head_id = d_blog_heads.id "

    conditions_sql = " d_blog_bodies.delf = :delf "
    conditions_sql += " AND d_blog_heads.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_blog_heads.user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd
    conditions_sql += " AND d_blog_bodies.public_flg = :public_flg "
    conditions_param[:public_flg] = 0
      
    order_sql = " d_blog_bodies.post_date DESC"
    
    DBlogBody.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql, :limit=>limit)
  end
  
  #
  # 指定ユーザーの月別投稿件数一覧を取得します。
  # 非公開の記事はカウントしてません
  #
  # @param user_cd - ユーザーCD
  # @return 月別投稿数一覧
  #
  def get_monthly_count user_cd
    
    select_sql = ""
    joins_sql = " INNER JOIN d_blog_heads ON d_blog_heads.id = d_blog_bodies.d_blog_head_id "
    conditions_sql = ""
    conditions_param = {}
    group_sql = ""
    order_sql = ""
    
    select_sql = " date_part('year', post_date) AS year, date_part('month', post_date) AS month, count(*) "
    joins_sql = " INNER JOIN d_blog_heads ON d_blog_heads.id = d_blog_bodies.d_blog_head_id "

    conditions_sql = " d_blog_bodies.delf = :delf "
    conditions_sql += " AND d_blog_heads.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_blog_bodies.public_flg = :public_flg"
    conditions_param[:public_flg] = 0
    conditions_sql += " AND d_blog_heads.user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd

    group_sql = " d_blog_heads.user_cd, year, month"

    order_sql = " year, month"

    @monthly_count_list = DBlogBody.find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :group=>group_sql, :order=>order_sql)
  end
end
