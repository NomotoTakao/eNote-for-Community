class Bbs::MainController < ApplicationController
  layout "portal", :except=>[:bbs_tab, :bbs_create_tab, :bbs_create, :board_pane, :board_list, :create_tab, :thread_pane, :thread_list, :thread_create, :comment_pane, :comment_list, :comment_create, :newly_list, :comment_search_pane, :comment_search_list]

  def index
    #パンくずリストに表示させる
    @pankuzu += "掲示板"

    @default_board_id = params[:board_id]
    @default_thread_id = params[:thread_id]

    @boards = DBbsBoard.new.get_board_list current_m_user.user_cd, (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
  end

  #
  # 掲示板領域を表示するアクション
  #
  def board_pane
  end

  #
  # 「掲示板」タブを表示するときのアクション
  #
  def bbs_tab
  end

  #
  # 「掲示板を新規作成」タブを表示するときのアクション
  #
  def bbs_create_tab
    @orgs = MOrg.new.get_orgs
  end

  #
  # 掲示板を新規作成するときのアクション
  #
  def bbs_create
    params[:d_bbs_boards][:created_user_cd] = current_m_user.user_cd
    params[:d_bbs_boards][:updated_user_cd] = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd

    d_bbs_boards = DBbsBoard.new(params[:d_bbs_boards])

    begin
      d_bbs_boards.save();

      d_bbs_auths = DBbsAuth.new
      d_bbs_auths.org_cd = params[:d_bbs_auths][:org_cd]
      d_bbs_auths.user_cd = current_m_user.user_cd
      d_bbs_auths.d_bbs_board_id = d_bbs_boards.id
      d_bbs_auths.auth_kbn = "2"
      d_bbs_auths.created_user_cd = current_m_user.user_cd
      d_bbs_auths.updated_user_cd = current_m_user.user_cd
      d_bbs_auths.save
    rescue
      #TODO 例外発生時の処理
    end

    redirect_to :action=>:bbs_tab
  end

  #
  # 掲示板タブに表示する情報を取得するアクション
  #
  def board_list
    setting = MBbsSetting.find(:first)

    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    joins_sql = " INNER JOIN d_bbs_auths ON d_bbs_boards.id = d_bbs_auths.d_bbs_board_id "

    conditions_sql = " d_bbs_boards.delf = :delf "
    conditions_sql += " AND d_bbs_auths.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND ((d_bbs_auths.org_cd != '' AND d_bbs_auths.org_cd = SUBSTR(:org_cd, 0, LENGTH(d_bbs_auths.org_cd)+1)) OR d_bbs_auths.org_cd = '0' OR d_bbs_auths.user_cd = :user_cd)"
    #conditions_param[:org_cd] = current_m_user.org_cd
    conditions_param[:org_cd] = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
    conditions_param[:user_cd] = current_m_user.user_cd
    conditions_sql += " AND d_bbs_auths.auth_kbn != :auth_kbn "
    conditions_param[:auth_kbn] = 0
    order_sql += " sort_no ASC"
    @board_list = DBbsBoard.paginate(:page=>params[:page], :per_page=>setting.page_max_count, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    user_list = MUser.find(:all, :conditions=>[conditions_sql, conditions_param])
    @users = {}
    user_list.each do |user|
      @users[user.user_cd] = user.name
    end
  end

  #
  # スレッド画面を表示するアクション
  #
  def thread_pane
    board_id = params[:board_id]

    conditions_sql = ""
    conditions_param = {}

    @board = DBbsBoard.new.get_board_by_id board_id

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    user_list = MUser.find(:all, :conditions=>[conditions_sql, conditions_param])
    @users = {}
    user_list.each do |user|
      @users[user.user_cd] = user.name
    end
  end

  #
  # スレッドの一覧を取得するアクション
  #
  def thread_list
    board_id = params[:board_id]

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""

    setting = MBbsSetting.find(:all)[0]
    @mode = params[:mode]

    if @mode == "1"
      order_sql = " post_date ASC "
    else
      order_sql = " post_date DESC "
    end

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_bbs_board_id = :d_bbs_board_id "
    conditions_param[:d_bbs_board_id] = board_id

    @thread_list = DBbsThread.paginate(:page=>params[:page], :per_page=>setting.page_max_count, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # スレッドを新規作成するアクション
  #
  def thread_create

    params[:d_bbs_threads][:post_user_cd] = current_m_user.user_cd
    params[:d_bbs_threads][:post_user_name] = current_m_user.name
    params[:d_bbs_threads][:post_date] = Time.now
    params[:d_bbs_threads][:created_user_cd] = current_m_user.user_cd
    params[:d_bbs_threads][:updated_user_cd] = current_m_user.user_cd

    thread = DBbsThread.new(params[:d_bbs_threads])

    begin
      thread.save
    else
      #TODO 例外発生時の処理
    end
    
    redirect_to :action=>:thread_list, :board_id=>thread.d_bbs_board_id
  end

  #
  # コメント一覧画面を表示するアクション
  #
  def comment_pane
    board_id = params[:board_id]
    thread_id = params[:thread_id]

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND id = :id "
    conditions_param[:id] = board_id
    @board = DBbsBoard.find(:all, :conditions=>[conditions_sql, conditions_param])[0]

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND id = :id "
    conditions_param[:id] = thread_id
    @thread = DBbsThread.find(:all, :conditions=>[conditions_sql, conditions_param])[0]
  end

  #
  # コメント一覧を取得するアクション
  #
  def comment_list
    board_id = params[:board_id]
    thread_id = params[:thread_id]

    setting = MBbsSetting.find(:all)[0]
    @mode = params[:mode]

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND id = :id "
    conditions_param[:id] = board_id
    @lastpost_date = DBbsBoard.find(:all, :conditions=>[conditions_sql, conditions_param])[0].lastpost_date

    if @mode == "1"
      order_sql = " post_date ASC "
    else
      order_sql = " post_date DESC "
    end

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_bbs_board_id = :d_bbs_board_id "
    conditions_param[:d_bbs_board_id] = board_id
    conditions_sql += " AND d_bbs_thread_id = :d_bbs_thread_id "
    conditions_param[:d_bbs_thread_id] = thread_id
    
    @comment_list = DBbsComment.paginate(:page=>params[:page], :per_page=>setting.page_max_count, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # コメントを新規作成するアクション
  #
  def comment_create
    
    params[:d_bbs_comments][:d_bbs_board_id] = params[:board_id][0]
    params[:d_bbs_comments][:d_bbs_thread_id] = params[:thread_id][0]
    params[:d_bbs_comments][:post_user_cd] = current_m_user.user_cd
    params[:d_bbs_comments][:post_user_name] = current_m_user.name
    params[:d_bbs_comments][:post_date] = Time.now
    params[:d_bbs_comments][:created_user_cd] = current_m_user.user_cd
    params[:d_bbs_comments][:updated_user_cd] = current_m_user.user_cd

    comment = DBbsComment.new(params[:d_bbs_comments])
    begin
      comment.save
      # 最終投稿日を更新する
      conditions_sql = ""
      conditions_param = {}
      conditions_sql = " delf = :delf"
      conditions_param[:delf] = "0"
      conditions_sql += " AND id = :id"
      conditions_param[:id] = comment.d_bbs_board_id
      board = DBbsBoard.find(:all, :conditions=>[conditions_sql, conditions_param])[0]
      board.lastpost_date = Time.now
      board.lastpost_body_id = comment.id
      board.updated_user_cd = current_m_user.user_cd
      board.save
    ensure
      #TODO 例外発生時の処理
    end
    
    redirect_to :action=>:comment_list, :board_id=>comment.d_bbs_board_id, :thread_id=>comment.d_bbs_thread_id
  end

  #
  # 新規記事一覧に表示する情報を取得します。
  #
  def newly_list
    board_id = params[:board_id]
    thread_id = params[:thread_id]
    @newly_list = DBbsComment.new.get_newly_list board_id, thread_id, current_m_user.user_cd, (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
  end

  #
  # コメント検索結果画面を表示するアクション
  #
  def comment_search_pane
    @board_id = params[:form_board_id]
    @thread_id = params[:form_thread_id]
    @date_from = params[:date_from]
    @date_to = params[:date_to]
    @keyword = params[:keyword]

    conditions_sql = ""
    conditions_param = {}
    @board_list = []
    @thread_list = []

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    boards = DBbsBoard.find(:all, :conditions=>[conditions_sql, conditions_param])
    boards.each do |board|
      @board_list[board.id] = board.title
    end

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = "0"
    threads = DBbsThread.find(:all, :conditions=>[conditions_sql, conditions_param])
    threads.each do |thread|
      @thread_list[thread.id] = thread.title
    end
  end

  #
  # コメント検索結果一覧を取得するアクション 
  #
  def comment_search_list
    @board_list = []
    @thread_list = []
    @board_id = params[:board_id]
    @thread_id = params[:thread_id]
    @date_from = params[:date_from]
    @date_to = params[:date_to]
    @keyword = params[:keyword]
    mode = params[:mode]
    setting = MBbsSetting.find(:all)[0]
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    boards = DBbsBoard.find(:all, :conditions=>[conditions_sql, conditions_param])
    boards.each do |board|
      @board_list[board.id] = board.title
    end

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = "0"
    threads = DBbsThread.find(:all, :conditions=>[conditions_sql, conditions_param])
    threads.each do |thread|
      @thread_list[thread.id] = thread.title
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

    unless @thread_id.empty?
      conditions_sql += " AND d_bbs_comments.d_bbs_thread_id = :thread_id "
      conditions_param[:thread_id] = @thread_id
    end
    conditions_sql += " AND (d_bbs_auths.org_cd = :org_cd OR d_bbs_auths.org_cd = '0' OR d_bbs_auths.user_cd = :user_cd) "
    #conditions_param[:org_cd] = current_m_user.org_cd
    conditions_param[:org_cd] = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
    conditions_param[:user_cd] = current_m_user.user_cd
    conditions_sql += " AND d_bbs_auths.auth_kbn != :auth_kbn "
    conditions_param[:auth_kbn] = 0

    unless @date_from.empty?
      conditions_sql += " AND cast(d_bbs_comments.post_date as date) >= :post_date_from "
      conditions_param[:post_date_from] = @date_from
    end

    unless @date_to.empty?
      conditions_sql += " AND cast(d_bbs_comments.post_date as date) <= :post_date_to "
      conditions_param[:post_date_to] = @date_to
    end

    unless @keyword.empty?
      conditions_sql += " AND d_bbs_comments.body like :body "
      conditions_param[:body] = "%" + @keyword + "%"
    end

    if mode == "1"
      order_sql = " d_bbs_comments.post_date ASC "
    else
      order_sql = " d_bbs_comments.post_date DESC "
    end

    @comment_list = DBbsComment.paginate(:page=>params[:page], :per_page=>setting.page_max_count, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end
end
