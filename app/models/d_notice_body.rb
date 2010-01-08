class DNoticeBody < ActiveRecord::Base
  belongs_to :d_notice_head
  has_many :d_notice_public_orgs, :conditions=> " delf = 0 "
  has_many :d_notice_files, :conditions=>"delf=0"

  #
  # 指定されたIDのお知らせ詳細を取得します。
  #
  # @param id - お知らせID
  # @return お知らせ詳細
  #
  def get_body_by_id id

    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
# JOIN区をつけると、レコードは読み取り専用となる
#    joins_sql = " INNER JOIN d_notice_public_orgs ON d_notice_bodies.id = d_notice_public_orgs.d_notice_body_id "

    conditions_sql = " d_notice_bodies.delf = :delf "
#    conditions_sql += " AND d_notice_public_orgs.delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_notice_bodies.id = :id"
    conditions_param[:id] = id

    DNoticeBody.find(:all, :conditions=>[conditions_sql, conditions_param])[0]
  end

  #
  # 指定されたIDのお知らせ詳細を削除します。
  #
  # @param id - お知らせ詳細ID
  # @param user_cd - 削除ユーザーCD
  #
  def delete_body_by_id id, user_cd

    record = get_body_by_id id

    # 紐付けられている添付ファイルを削除
    files = record.d_notice_files
    files.each do |file|
      file.delf = 1
      file.deleted_user_cd = user_cd
      file.deleted_at = Time.now

      file.save
    end


    # お知らせ詳細に紐付いている公開対象組織を削除
    orgs = record.d_notice_public_orgs
    orgs.each do |org|
      org.delf = 1
      org.deleted_user_cd = user_cd
      org.deleted_at = Time.now

      org.save
    end

    # お知らせ詳細レコードを削除
    record.delf = "1"
    record.deleted_user_cd = user_cd
    record.deleted_at = Time.now
    record.updated_user_cd = user_cd
    record.save

  end

  #
  # お知らせ一覧を取得します。
  #
  # @param user_cd - ログインユーザーCD
  # @param disp_kbn - 表示区分
  # @param hot_topic_flg - ホットトピックを抽出する時は、trueを指定する。
  # @return お知らせ一覧
  #
  def get_notice_list user_cd, disp_kbn, hot_topic_flg

    list_limit = 5

    # お知らせ一覧の取得
    select_sql = " DISTINCT d_notice_bodies.* "
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""

    joins_sql = " INNER JOIN d_notice_heads ON d_notice_heads.id = d_notice_bodies.d_notice_head_id "
    joins_sql += " INNER JOIN d_notice_public_orgs ON d_notice_bodies.id = d_notice_public_orgs.d_notice_body_id "
    joins_sql += " LEFT JOIN d_notice_files ON d_notice_bodies.id = d_notice_files.d_notice_body_id "

    if hot_topic_flg
      conditions_sql = " hottopic_flg = :hottopic_flg"
      conditions_param[:hottopic_flg] = 0
    end

    unless disp_kbn.nil?
      conditions_sql = " top_disp_kbn = :top_disp_kbn"
      conditions_param[:top_disp_kbn] = disp_kbn
    end
    # 削除フラグを確認する。
    conditions_sql += " AND d_notice_bodies.delf = :delf "
    conditions_sql += " AND d_notice_public_orgs.delf = :delf "
    conditions_param[:delf] = '0'

    # ログインユーザの所属する組織の組織コードが公開対象組織になっているかを確認する。
    conditions_sql += " AND (d_notice_public_orgs.org_cd = '0' "
    user_org_list = MUserBelong.new.get_belong_org user_cd
    # 複数組織に所属するときは、そのすべてに対して閲覧が可能
    user_org_list.each do |user_org|
      conditions_sql += " OR d_notice_public_orgs.org_cd = SUBSTR(':public_org_cd', 0, LENGTH(d_notice_public_orgs.org_cd) + 1) "
      conditions_sql.gsub!(":public_org_cd", user_org.org_cd)
    end
    conditions_sql += " OR d_notice_public_orgs.etcstr1 = :user_cd "
    conditions_sql += "  OR d_notice_public_orgs.created_user_cd = :user_cd)"
    conditions_param[:user_cd] = user_cd
    # 公開前ではないかをチェック(但し、投稿者については公開期間を考慮しない。)
    conditions_sql += " AND (d_notice_bodies.public_date_from <= cast(:public_date_from as date) OR d_notice_bodies.public_date_from ISNULL OR d_notice_bodies.post_user_cd = :post_user_cd) "
    conditions_param[:public_date_from] = Time.now
    # 公開終了でないかをチェック(但し、投稿者については公開期間を考慮しない。)
    conditions_sql += " AND (d_notice_bodies.public_date_to >= cast(:public_date_to as date) OR d_notice_bodies.public_date_to ISNULL OR d_notice_bodies.post_user_cd = :post_user_cd ) "
    conditions_param[:public_date_to] = Time.now
    conditions_param[:post_user_cd] = user_cd

    conditions_sql += " AND (d_notice_bodies.public_flg = 0 OR (d_notice_bodies.public_flg = 1 AND d_notice_bodies.post_user_cd = cast(:post_user_cd as varchar)))"
    conditions_param[:post_user_cd] = user_cd

    order_sql = " post_date DESC"

    DNoticeBody.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql, :limit=>list_limit)
  end

  #
  # TOP画面に表示するTOP表示区分が'99'のお知らせ一覧を取得する。
  #
  # @param page - 表示するページ番号
  # @param per_page - 1ページあたりの最大表示件数
  # @param user_cd - ログインユーザーCD
  #
  def self.get_gadget_kbn99 page, per_page, user_cd

    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    select_sql = " DISTINCT d_notice_bodies.*"

    joins_sql = "INNER JOIN d_notice_heads on d_notice_heads.id = d_notice_bodies.d_notice_head_id"
    joins_sql += " INNER JOIN d_notice_auths on d_notice_auths.d_notice_head_id = d_notice_heads.id"
    joins_sql += " INNER JOIN d_notice_public_orgs on d_notice_public_orgs.d_notice_body_id = d_notice_bodies.id"

    conditions_sql = "d_notice_bodies.delf = :delf"
    conditions_sql += " AND d_notice_heads.delf = :delf"
    conditions_sql += " AND d_notice_auths.delf = :delf"
    conditions_sql += " AND d_notice_public_orgs.delf = :delf"
    conditions_param[:delf] = 0
    # 公開または非公開の場合ログインユーザが作成者の場合のみ取得する条件
    conditions_sql += " AND d_notice_bodies.public_flg = 0 "
    conditions_param[:post_user_cd] = user_cd
    belong_orgs = MUserBelong.find(:all, :conditions=>{:delf=>0, :user_cd=>user_cd})
    belong_sql = ""
    tmp_sql = ""
    unless belong_orgs.length == 0
      belong_orgs.each do |org|
        unless tmp_sql.empty?
          tmp_sql += " OR "
        end
        tmp_sql += "d_notice_auths.org_cd = SUBSTR(':org_cd', 0, LENGTH(d_notice_auths.org_cd)+1)".gsub(":org_cd", org.org_cd)
      end
      unless tmp_sql.empty?
        belong_sql = " AND (#{tmp_sql})"
      end
    end
    conditions_sql += " AND ((d_notice_auths.org_cd != '' #{belong_sql}) OR d_notice_auths.org_cd = '0' OR d_notice_auths.user_cd = :user_cd)"
    conditions_param[:user_cd] = user_cd


    # ログインユーザの所属する組織の組織コードが公開対象組織になっているかを確認する。
    conditions_sql += " AND (d_notice_public_orgs.org_cd = '0' "
    user_org_list = MUserBelong.new.get_belong_org user_cd
    # 複数組織に所属するときは、そのすべてに対して閲覧が可能
    user_org_list.each do |user_org|
      # ※ ツリーで指示できる組織の階層に、ユーザーの所属組織コードを合わせている。
      user_org_cd = user_org.org_cd
      if user_org_cd.length > 6
        user_org_cd = user_org_cd[0...6]
      end
      #conditions_sql += " OR d_notice_public_orgs.org_cd = ':public_org_cd' "
      conditions_sql += " OR d_notice_public_orgs.org_cd = SUBSTR(':public_org_cd', 0, LENGTH(d_notice_public_orgs.org_cd) + 1) "
      conditions_sql.gsub!(":public_org_cd", user_org_cd)
    end
    conditions_sql += " OR d_notice_public_orgs.etcstr1 = :user_cd "
    conditions_sql += "  OR d_notice_public_orgs.created_user_cd = :user_cd)"
    conditions_param[:user_cd] = user_cd
    # 公開前ではないかをチェック(但し、投稿者については公開期間を考慮しない。)
    conditions_sql += " AND (d_notice_bodies.public_date_from <= cast(:public_date_from as date) OR d_notice_bodies.public_date_from ISNULL) "
    conditions_param[:public_date_from] = Time.now
    # 公開終了でないかをチェック(但し、投稿者については公開期間を考慮しない。)
    conditions_sql += " AND (d_notice_bodies.public_date_to >= cast(:public_date_to as date) OR d_notice_bodies.public_date_to ISNULL) "
    conditions_param[:public_date_to] = Time.now

    conditions_sql += " AND d_notice_bodies.top_disp_kbn = ':top_disp_kbn'"
    conditions_param[:top_disp_kbn] = 9

    conditions_sql += " AND d_notice_bodies.post_date >= :post_date"
    conditions_param[:post_date] = Date.today - 14

    order_sql = " post_date DESC"

    DNoticeBody.paginate(:page=>page, :per_page=>per_page, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end
end
