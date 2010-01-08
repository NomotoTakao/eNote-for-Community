class DBbsBoard < ActiveRecord::Base
  has_many :d_bbs_threads

  #
  # 掲示板の一覧を取得します。
  # 閲覧・書込み権限を有する掲示板のみが検索されます。
  #
  # @param user_cd - ログインユーザーのユーザーコード
  # [param org_cd  - ログインユーザーの所属組織コード
  #
  def get_board_list user_cd, org_cd

    select_sql = ""
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    select_sql = " DISTINCT d_bbs_boards.*"

    joins_sql = " INNER JOIN d_bbs_auths ON d_bbs_boards.id = d_bbs_auths.d_bbs_board_id "

    conditions_sql = " d_bbs_boards.delf = :delf "
    conditions_sql += " AND d_bbs_auths.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND ((d_bbs_auths.org_cd != '' AND d_bbs_auths.org_cd = SUBSTR(:org_cd, 0, LENGTH(d_bbs_auths.org_cd)+1)) OR d_bbs_auths.org_cd = '0' OR d_bbs_auths.user_cd = :user_cd)"
    conditions_param[:org_cd] = org_cd
    conditions_param[:user_cd] = user_cd
    conditions_sql += " AND d_bbs_auths.auth_kbn != :auth_kbn "
    conditions_param[:auth_kbn] = 0

    order_sql = " sort_no ASC"

    DBbsBoard.find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 指定されたIDの掲示板の情報を取得します。
  #
  # @param id - 掲示板ID
  #
  def get_board_by_id id

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = "0"
    conditions_sql += " AND id = :id "
    conditions_param[:id] = id

    DBbsBoard.find(:all, :conditions=>[conditions_sql, conditions_param])[0]
  end
end
