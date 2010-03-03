class Blog::ViewController < ApplicationController
  layout "portal", :except => [:header, :blog_list, :detail, :menu_new_article, :menu_month_list, :menu_category_list, :menu_bloger_list, :menu_favorite_list, :menu_search_list,:article_comment, :tag_list, :tmp_list]

  #新着の記事の表示
  def top
    #パンくずリストに表示させる
    @pankuzu += "社内ブログ"

    @default_user_cd = params[:user_cd]
  end

  def header
  end

  #
  # ブログ記事一覧を取得するアクション
  #
  # 右領域に表示する一覧は、ログインユーザーごとのブログの一覧です。
  # 基本的のは、公開されている記事を一覧表示しますが、ログインユーザー自身が投稿した
  # 記事一覧を表示する場合は、非公開の記事も一覧に表示します。
  # これは、非公開の記事も編集可能とするための処置です。
  #
  def blog_list
    user_cd = params[:user_cd]
    year = params[:year]
    month = params[:month]
    @keyword = params[:keyword]
    type = params[:type]
    @favorite_flg = false

    if @keyword.nil? and type.nil?
      @favorite_flg = true
    end

    select_sql = ""
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    @setting = MBlogSetting.find(:first)

    if user_cd.nil?
      user_cd = current_m_user.user_cd
    end

    select_sql = " DISTINCT d_blog_bodies.* "

    joins_sql = " INNER JOIN d_blog_heads ON d_blog_bodies.d_blog_head_id = d_blog_heads.id "
    joins_sql += " LEFT JOIN d_blog_tags ON d_blog_bodies.id = d_blog_tags.d_blog_body_id "

    conditions_sql = " d_blog_bodies.delf = :delf "
    conditions_sql += " AND d_blog_heads.delf = :delf "

    conditions_param[:delf] = "0"

    conditions_sql += " AND ((d_blog_bodies.public_flg = :public_flg AND d_blog_heads.user_cd = :user_cd ) "
    conditions_param[:public_flg] = "0"
    conditions_param[:user_cd] = user_cd

    if user_cd == current_m_user.user_cd
      conditions_sql += " OR (d_blog_bodies.public_flg = 1 AND d_blog_heads.user_cd = :current_m_user)) "
      conditions_param[:current_m_user] = current_m_user.user_cd
    else
      conditions_sql += ")"
    end

    unless @keyword.nil?
      if type == "tag"
        conditions_sql += " AND d_blog_tags.category = :keyword "
       conditions_param[:keyword] = @keyword
      else
        conditions_sql += " AND (d_blog_bodies.title LIKE :keyword OR d_blog_bodies.body LIKE :keyword OR d_blog_tags.category LIKE :keyword)"
        conditions_param[:keyword] = "%" + @keyword + "%"
      end
    end

    if @keyword.nil?
      conditions_sql += " AND d_blog_heads.user_cd = :user_cd "
      conditions_param[:user_cd] = user_cd
    end

    unless year.nil?
      conditions_sql += " AND date_part('year', d_blog_bodies.post_date) = :year "
      conditions_param[:year] = year
    end

    unless month.nil?
      conditions_sql += " AND date_part('month', d_blog_bodies.post_date) = :month"
      conditions_param[:month] = month
    end

    order_sql = " d_blog_bodies.post_date DESC"
    if @keyword.nil?
      @blog_head = DBlogHead.new.get_head_by_user_cd user_cd
      unless @blog_head.nil?
        @title = @blog_head.title
      end
    else
      if type == "tag"
        title = "「:keyword」のタグが付けられたブログ";
      else
        title = "「:keyword」の検索結果"
      end
      @title = title.gsub(":keyword", @keyword);
    end
    @user_cd = user_cd
    @blog_list = DBlogBody.paginate(:page => params[:page], :per_page => @setting.page_max_count, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #記事を単独で表示
  def detail
    @blog = DBlogBody.find(params[:id])
    @writer_id = @blog.d_blog_head.user_cd
    head = DBlogHead.new.get_head_by_user_cd @writer_id
    @title = head.title
  end

  #
  # メニュー部の新着記事リスト
  #
  # 新着記事一覧に表示する条件は、"公開フラグが'0'になっている記事"です。
  # 右領域の一覧には、非公開でも投稿者が本人の記事を表示していますが、新着記事一覧には非公開の記事は表示しません。
  # 新着記事一覧は純粋に公開されているブログの新着一覧であるべきだという考えに基づいてこのようにしています。
  #
  def menu_new_article
#    conditions_sql = ""
#    conditions_param = {}
#    order_sql = ""
#    joins_sql = ""
#
#    if params[:uid] == nil || params[:uid] == ""
#
#      joins_sql = " INNER JOIN d_blog_heads ON d_blog_bodies.d_blog_head_id = d_blog_heads.id "
#
#      conditions_sql = " d_blog_bodies.delf = :delf "
#      conditions_param[:delf] = "0"
##      conditions_sql += " AND (d_blog_bodies.public_flg = :public_flg OR d_blog_bodies.created_user_cd = :created_user_cd) "
#            conditions_sql += " AND d_blog_bodies.public_flg = :public_flg "
#      conditions_param[:public_flg] = "0"
#      conditions_param[:created_user_cd] = current_m_user.user_cd.to_s
#
#      order_sql = " d_blog_bodies.post_date DESC"
#
#      @newly_list = DBlogBody.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql, :limit=>10)
#    else
#
#      joins_sql = " INNER JOIN d_blog_heads ON d_blog_bodies.d_blog_head_id = d_blog_heads.id "
#
#      conditions_sql = " d_blog_bodies.delf = :delf "
#      conditions_param[:delf] = "0"
#      conditions_sql += " AND d_blog_bodies.created_user_cd = :created_user_cd "
#      conditions_param[:created_user_cd] = current_m_user.user_cd.to_s
#      conditions_sql += " AND (d_blog_bodies.public_flg = :public_flg OR d_blog_bodies.created_user_cd = :created_user_cd) "
#      conditions_param[:public_flg] = "0"
#      conditions_param[:created_user_cd] = current_m_user.user_cd.to_s
#
#      order_sql = " d_blog_bodies.post_date DESC"
#
#      @newly_list = DBlogBody.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
#    end
    user_cd = params[:uid]
    if user_cd.nil?
      user_cd = @current_m_user.user_cd
    end

    @newly_list = DBlogBody.new.get_newly_list user_cd, 5
  end

  #
  # お気に入りリスト
  #
  def menu_favorite_list
    @favorite_list = DBlogFavorite.new.get_favorite_list current_m_user.user_cd
  end

  #
  # ブログを書いた人のリスト
  # ツリーはajaxで取得します。このメソッドでは、最上位の組織だけを取得しています。
  #
  def menu_bloger_list
    @org_list = MOrg.get_org_list 1, ""
  end

  #書き手一人分のブログ表示
  def user
    @writer_id = params[:id]
    usr = EnMUser.find(@writer_id)
    @title = usr.sname.to_s + "のブログ"
    @blog_article = EnDBlogArticle.paginate :conditions => ["delf = '0' AND post_user_cd = ? AND (published_flg = '1' OR post_user_cd = ?)", @writer_id, session[:uid]], :order => "post_date desc", :page => params[:page], :per_page => 10
  end

  #月ごとの件数リスト
  def menu_month_list
    @user_cd = params[:uid]
    @monthly_count_list = DBlogBody.new.get_monthly_count @user_cd
  end

  #ひと月分のブログ
  def month
    sql = ["delf = '0' AND to_char(post_date,'YYYYMM') = ? AND post_user_cd = ? AND (published_flg = '1' OR post_user_cd = ?)", params[:id], params[:uid], session[:uid]]

    @writer_id = params[:uid]

    @blog_article = EnDBlogArticle.find(:all, :conditions => sql, :order => "post_date desc")

    usr = EnMUser.find(@writer_id)
    @title = usr.sname.to_s + "のブログ（#{params[:id].to_s[0,4]}/#{params[:id].to_s[4,2]}）"

  end

  #検索機能
  def menu_search_list
    @user_cd = params[:uid]
  end

  #
  # キーワード一覧を表示します。
  #
  def tag_list
    @user_cd = params[:uid]
    @tag_list = DBlogTag.new.get_categorylist_with_count @user_cd
  end

  #
  #
  #
  def tmp_list

    tmp_id = params[:tmp_id]
    org_cd = tmp_id.gsub("o_", "")
    m_org = MOrg.new.get_org_info org_cd

    @tmp_o_list = Array.new
    @tmp_u_list = Array.new
    @tmp_u_hash = Hash.new

    unless m_org.nil?
      @tmp_o_list = []

      #3,4階層目がクリックされた場合
      if m_org.org_lvl.to_i >= 3
        @tmp_o_list = MOrg.get_org_list m_org.org_lvl.to_i + 1, org_cd

      #1,2階層目がクリックされた場合
      elsif m_org.org_lvl.to_i <= 2
        #次の階層でハイフンでない組織
        tmp_data = MOrg.get_org_list_consider_hyphen m_org.org_lvl.to_i + 1, org_cd, 0
        tmp_data.each do |tmp|
          @tmp_o_list << tmp
        end
        #次の階層がハイフンの組織
        tmp_data = MOrg.get_org_list_consider_hyphen m_org.org_lvl.to_i + 2, org_cd, 1
        tmp_data.each do |tmp|
          @tmp_o_list << tmp
        end
      end

      @tmp_u_list = DBlogHead.new.get_blogger_list_by_org_cd m_org.org_cd

      @tmp_o_list.each do |org|
        @tmp_u_hash[org.org_cd] = DBlogHead.new.get_blogger_list_by_org_cd org.org_cd
      end
    end
  end

end
