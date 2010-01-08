class Search::MainController < ApplicationController
  layout "portal", :except => [:search_result]

  def index
    #パンくずリストに表示させる
    @pankuzu += "サイト内検索"

    if params[:site_search_word].nil?
      @site_search_word = ""
    else
      @site_search_word = params[:site_search_word]
    end
  end

  def search_result
    #検索キーワード
    site_search_word = params[:site_search_word]
    @notice_list = [] #お知らせ
    @cabinet_list = [] #Webメモリ
    @board_list = []  #掲示板
    @comment_list = []
    @blog_list = [] #社内ブログ
    @public_cabinet_list = [] #共有キャビネット
    @bookmarks = [] #リンク集
    @address_list = [] #アドレス帳

    if !site_search_word.nil? && site_search_word != ""
      #** お知らせ **
      if params[:from_mode].to_s == '0' || !params[:search_check1].nil?
        @owner = ""

        # お知らせ一覧の取得
        select_sql = " DISTINCT d_notice_bodies.* "
        conditions_sql = ""
        conditions_param = {}
        joins_sql = ""

        joins_sql = " INNER JOIN d_notice_heads ON d_notice_heads.id = d_notice_bodies.d_notice_head_id "
        joins_sql += " INNER JOIN d_notice_public_orgs ON d_notice_bodies.id = d_notice_public_orgs.d_notice_body_id "
        joins_sql += " LEFT JOIN d_notice_files ON d_notice_bodies.id = d_notice_files.d_notice_body_id "

        # 削除フラグを確認する。
        conditions_sql = " d_notice_bodies.delf = :delf "
        conditions_sql += " AND d_notice_public_orgs.delf = :delf "
        conditions_param[:delf] = '0'
        # 自分の投稿のみを検索するかどうか。
        if @owner == "on"
          conditions_sql += " AND d_notice_bodies.post_user_cd = :post_user_cd "
          conditions_param[:post_user_cd] = current_m_user.user_cd
        end
        # ログインユーザの所属する組織の組織コードが公開対象組織になっているかを確認する。
        conditions_sql += " AND (d_notice_public_orgs.org_cd = '0' "
        user_org_list = MUserBelong.new.get_belong_org current_m_user.user_cd
        # 複数組織に所属するときは、そのすべてに対して閲覧が可能
        user_org_list.each do |user_org|
          # ※ ツリーで指示できる組織の階層に、ユーザーの所属組織コードを合わせている。
          user_org_cd = user_org.org_cd
          if user_org_cd.length > 6
            user_org_cd = user_org_cd[0...6]
          end
          conditions_sql += " OR d_notice_public_orgs.org_cd = SUBSTR(':public_org_cd', 0, LENGTH(d_notice_public_orgs.org_cd) + 1) "
          conditions_sql.gsub!(":public_org_cd", user_org_cd)
        end
        conditions_sql += "  OR d_notice_public_orgs.created_user_cd = :user_cd)"
        conditions_param[:user_cd] = current_m_user.user_cd
        # 公開前ではないかをチェック(但し、投稿者については公開期間を考慮しない。)
        conditions_sql += " AND (d_notice_bodies.public_date_from <= cast(:public_date_from as date) OR d_notice_bodies.public_date_from ISNULL OR d_notice_bodies.post_user_cd = :post_user_cd) "
        conditions_param[:public_date_from] = Time.now
        # 公開終了でないかをチェック(但し、投稿者については公開期間を考慮しない。)
        conditions_sql += " AND (d_notice_bodies.public_date_to >= cast(:public_date_to as date) OR d_notice_bodies.public_date_to ISNULL OR d_notice_bodies.post_user_cd = :post_user_cd ) "
        conditions_param[:public_date_to] = Time.now
        conditions_param[:post_user_cd] = current_m_user.user_cd

        conditions_sql += " AND (d_notice_bodies.public_flg = 0 OR (d_notice_bodies.public_flg = 1 AND d_notice_bodies.post_user_cd = cast(:post_user_cd as char)))"
        conditions_param[:post_user_cd] = current_m_user.user_cd

        if site_search_word and site_search_word != ""
          conditions_sql += " AND (d_notice_bodies.body like :body OR d_notice_bodies.title like :body OR d_notice_bodies.meta_tag like :body)"
          conditions_param[:body] = "%" + site_search_word + "%"
        end

        @notice_list = DNoticeBody.paginate(:page => params[:page], :select=>select_sql, :joins=>joins_sql,
                                            :conditions=>[conditions_sql, conditions_param], :order=>'post_date')
      end

      #** Webメモリ **
      if params[:from_mode].to_s == '0' || !params[:search_check2].nil?
        conditions_param = {}
        joins_sql = ""

        @m_cabinet_setting = MCabinetSetting.find(:all)[0]
        @head = DCabinetHead.get_cabinethead_by_user_cd current_m_user.user_cd
        if @head.nil?
          # ヘッダレコードを作る
          DCabinetHead.new.create_private_cabinet current_m_user.user_cd
          @head = DCabinetHead.get_cabinethead_by_user_cd current_m_user.user_cd
        end

        joins_sql = " INNER JOIN d_cabinet_files ON d_cabinet_files.d_cabinet_body_id = d_cabinet_bodies.id"
        conditions_sql = " d_cabinet_bodies.delf = :delf "
        conditions_sql += " AND d_cabinet_files.delf = :delf "
        conditions_param[:delf] = "0"
        conditions_sql += " AND d_cabinet_bodies.d_cabinet_head_id = :d_cabinet_head_id "
        conditions_sql += " AND d_cabinet_files.d_cabinet_head_id = :d_cabinet_head_id "
        conditions_param[:d_cabinet_head_id] = @head.id

        if site_search_word and site_search_word != ""
          conditions_sql += " AND (d_cabinet_bodies.body like :body OR d_cabinet_bodies.title like :body)"
          conditions_param[:body] = "%" + site_search_word + "%"
        end

        @cabinet_list = DCabinetBody.paginate(:page=>params[:page], :per_page=>@m_cabinet_setting.page_max_count, :joins=>joins_sql,
                                              :conditions=>[conditions_sql, conditions_param], :order=>"title")
        @total_size = 0
        @cabinet_files = []
        join_sql = ""
        conditions_sql = " d_cabinet_files.delf = :delf "
        conditions_param[:delf] = "0"
        join_sql += " INNER JOIN d_cabinet_heads on d_cabinet_files.d_cabinet_head_id = d_cabinet_heads.id "
        conditions_sql += " AND d_cabinet_heads.delf = :delf "
        conditions_sql += " AND d_cabinet_heads.private_user_cd = :private_user_cd "
        conditions_param[:private_user_cd] = current_m_user.user_cd
        d_cabinet_files = DCabinetFile.find(:all, :joins=>join_sql, :conditions=>[conditions_sql, conditions_param])
        d_cabinet_files.each do |file|
          @cabinet_files[file.d_cabinet_body_id] = {:file_name=>file.file_name, :file_size=>file.file_size}
          @total_size += file.file_size
        end
      end

      #** 掲示板 **
      if params[:from_mode].to_s == '0' || !params[:search_check3].nil?
        @board_list = []
        @board_id = ""
        conditions_sql = ""
        conditions_param = {}
        joins_sql = ""

        conditions_sql = " delf = :delf "
        conditions_param[:delf] = "0"
        boards = DBbsBoard.find(:all, :conditions=>[conditions_sql, conditions_param])
        boards.each do |board|
          @board_list[board.id] = board.title
        end

        joins_sql = " INNER JOIN d_bbs_auths ON d_bbs_comments.d_bbs_board_id = d_bbs_auths.d_bbs_board_id "
        joins_sql += " INNER JOIN d_bbs_boards ON d_bbs_comments.d_bbs_board_id = d_bbs_boards.id"

        conditions_sql = ""
        conditions_param = {}

        conditions_sql = " d_bbs_comments.delf = :delf "
        conditions_sql += " AND d_bbs_auths.delf = :delf "
        conditions_param[:delf] = "0"
        unless @board_id.empty?
          conditions_sql += " AND d_bbs_comments.d_bbs_board_id = :board_id "
          conditions_param[:board_id] = @board_id
        end

        conditions_sql += " AND (d_bbs_auths.org_cd = :org_cd OR d_bbs_auths.org_cd = '0' OR d_bbs_auths.user_cd = :user_cd) "
        conditions_param[:org_cd] = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
        conditions_param[:user_cd] = current_m_user.user_cd
        conditions_sql += " AND d_bbs_auths.auth_kbn != :auth_kbn "
        conditions_param[:auth_kbn] = 0

        unless site_search_word.empty?
          conditions_sql += " AND d_bbs_comments.body like :body "
          conditions_param[:body] = "%" + site_search_word + "%"
        end

        @comment_list = DBbsComment.paginate(:page=>params[:page], :joins=>joins_sql,
                                             :conditions=>[conditions_sql, conditions_param], :order=>"d_bbs_comments.post_date")
      end

      #** 社内ブログ **
      if params[:from_mode].to_s == '0' || !params[:search_check4].nil?
        user_cd = params[:user_cd]
        type = params[:type]
        @favorite_flg = false

        if site_search_word.nil? and type.nil?
          @favorite_flg = true
        end

        select_sql = ""
        conditions_sql = ""
        conditions_param = {}
        joins_sql = ""
        order_sql = ""

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

        unless site_search_word.nil?
          if type == "tag"
            conditions_sql += " AND d_blog_tags.category = :keyword "
           conditions_param[:keyword] = site_search_word
          else
            conditions_sql += " AND (d_blog_bodies.title LIKE :keyword OR d_blog_bodies.body LIKE :keyword OR d_blog_tags.category LIKE :keyword)"
            conditions_param[:keyword] = "%" + site_search_word + "%"
          end
        end

        if site_search_word.nil?
          conditions_sql += " AND d_blog_heads.user_cd = :user_cd "
          conditions_param[:user_cd] = user_cd
        end

        order_sql = " d_blog_bodies.post_date DESC"
        if site_search_word.nil?
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
          @title = title.gsub(":keyword", site_search_word);
        end
        @user_cd = user_cd
        @blog_list = DBlogBody.paginate(:page => params[:page], :select=>select_sql, :joins=>joins_sql,
                                        :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
      end

      #** 共有キャビネット **
      if params[:from_mode].to_s == '0' || !params[:search_check5].nil?
        joins_sql = ""
        conditions_sql = ""
        conditions_param = {}

        id = params[:id]

        conditions_sql += " d_cabinet_bodies.delf = :delf "
        conditions_param[:delf] = '0'

        # 公開開始日が設定されていない、または本日以前(ただし投稿者はすべて見れる)
        conditions_sql += " AND (d_cabinet_bodies.public_date_from is null OR cast(d_cabinet_bodies.public_date_from as date) <= :public_date_from OR post_user_cd = :post_user_cd) "
        conditions_param[:public_date_from] = Time.new

        # 公開終了日が設定されていない、または本日以降(ただし投稿者はすべて見れる)
        conditions_sql += " AND (d_cabinet_bodies.public_date_to is null OR cast(d_cabinet_bodies.public_date_to as date) >= :public_date_to OR post_user_cd = :post_user_cd) "
        conditions_param[:public_date_to] = Time.new
        conditions_param[:post_user_cd] = current_m_user.user_cd

        category_id = params[:category_id]
        if category_id != nil and category_id[0] != "" and category_id != ""
          conditions_sql += " AND d_cabinet_bodies.d_cabinet_head_id = :id "
          conditions_param[:id] = category_id
        end

        if site_search_word != nil and site_search_word != ""
          conditions_sql += " AND (d_cabinet_bodies.title like :title OR d_cabinet_bodies.body like :body OR d_cabinet_bodies.meta_tag like :meta_tag) "
          conditions_param[:title] = "%" + site_search_word + "%"
          conditions_param[:body] = "%" + site_search_word + "%"
          conditions_param[:meta_tag] = "%" + site_search_word + "%"
        end

        joins_sql = " INNER JOIN d_cabinet_heads ON d_cabinet_bodies.d_cabinet_head_id = d_cabinet_heads.id "
        joins_sql += " INNER JOIN d_cabinet_public_orgs ON d_cabinet_bodies.id = d_cabinet_public_orgs.d_cabinet_body_id "

        conditions_sql += " AND d_cabinet_heads.delf = :delf "
        conditions_sql += " AND d_cabinet_heads.cabinet_kbn != :cabinet_kbn "
        conditions_param[:cabinet_kbn] = "0"
        # 一覧表示される共有キャビネットは、全社向け、所属組織または自身が作成したもの、の３種類
        conditions_sql += " AND (d_cabinet_public_orgs.org_cd = '0' "
        user_org_list = MUserBelong.new.get_belong_org current_m_user.user_cd
        user_org_list.each do |user_org|
          user_org_cd = user_org.org_cd
          if user_org_cd.length > 6
            user_org_cd = user_org_cd[0...6]
          end
          conditions_sql += " OR d_cabinet_public_orgs.org_cd = :public_org_cd"
          conditions_sql.gsub!(":public_org_cd", user_org_cd)
        end
        conditions_sql += " OR d_cabinet_bodies.created_user_cd = :created_user_cd)"
        conditions_param[:created_user_cd] = current_m_user.user_cd
        unless id.nil?
          conditions_sql += " AND d_cabinet_heads.id = :id "
          conditions_param[:id] = id
        end

        @public_cabinet_list = DCabinetBody.paginate(:page=>params[:page], :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>"title")
      end

      #** リンク集 **
      if params[:from_mode].to_s == '0' || !params[:search_check6].nil?
        sql = "delf = 0 AND public_flg = 0 "
        sql += " AND (title LIKE '%#{params[:site_search_word]}%' OR memo LIKE '%#{params[:site_search_word]}%') "
        @bookmarks = DBookmark.find(:all, :conditions => sql, :order => "d_bookmark_category_id, sort_no")
      end

      #** アドレス帳 **
      if params[:from_mode].to_s == '0' || !params[:search_check7].nil?
        @address_list = DAddress.get_sword_user_info(params[:site_search_word], current_m_user.user_cd, 0, 0, 0)
      end
    end

    #チェック状態の取得
    @search_check1 = params[:search_check1] #お知らせ
    @search_check2 = params[:search_check2] #Webメモリ
    @search_check3 = params[:search_check3] #掲示板
    @search_check4 = params[:search_check4] #社内ブログ
    @search_check5 = params[:search_check5] #共有キャビネット
    @search_check6 = params[:search_check6] #リンク集
    @search_check7 = params[:search_check7] #アドレス帳
    @from_mode = params[:from_mode] #遷移元(0:ヘッダ部の検索ボタン押下時, 0以外:検索画面の検索ボタン押下時)
  end
end
