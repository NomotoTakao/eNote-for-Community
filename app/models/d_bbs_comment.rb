class DBbsComment < ActiveRecord::Base
  belongs_to :d_bbs_thread

  #
  # 新着の投稿記事を取得します。
  #
  # @param board_id - ボードID
  # @param thread_id - スレッドID
  # @param user_cd - ログインユーザーのユーザーCD
  # @param org_cd - ログインユーザーの所属する組織コード
  # @return 新着投稿記事リスト
  #
  def get_newly_list board_id, thread_id, user_cd, org_cd
    
    # 新着投稿記事の最大表示件数
    newly_index_max_count = 10
    
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""

    joins_sql = " INNER JOIN d_bbs_auths ON d_bbs_comments.d_bbs_board_id = d_bbs_auths.d_bbs_board_id "
    joins_sql += " INNER JOIN d_bbs_threads on d_bbs_comments.d_bbs_thread_id = d_bbs_threads.id "
    joins_sql += " INNER JOIN d_bbs_boards on d_bbs_comments.d_bbs_board_id = d_bbs_boards.id "

    conditions_sql = " d_bbs_comments.delf = :delf "
    conditions_sql += " AND d_bbs_threads.delf = :delf "
    conditions_sql += " AND d_bbs_boards.delf = :delf "
    conditions_param[:delf] = "0"
    unless board_id.nil?
      conditions_sql += " AND d_bbs_comments.d_bbs_board_id = :board_id "
      conditions_param[:board_id] = board_id
    end
    unless thread_id.nil?
      conditions_sql += " AND d_bbs_comments.d_bbs_thread_id = :thread_id "
      conditions_param[:thread_id] = thread_id
    end
    conditions_sql += " AND ((d_bbs_auths.org_cd != '' AND d_bbs_auths.org_cd = SUBSTR(:org_cd, 0, LENGTH(d_bbs_auths.org_cd)+1)) OR d_bbs_auths.org_cd = '0' OR d_bbs_auths.user_cd = :user_cd) "
    #conditions_param[:org_cd] = current_m_user.org_cd
    conditions_param[:org_cd] = org_cd
    conditions_param[:user_cd] = user_cd
    conditions_sql += " AND d_bbs_auths.auth_kbn != :auth_kbn "
    conditions_param[:auth_kbn] = 0
    
    order_sql = " d_bbs_comments.post_date DESC "
    @newly_list = DBbsComment.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql, :limit=>newly_index_max_count)
  end
end
