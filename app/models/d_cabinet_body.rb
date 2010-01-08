class DCabinetBody < ActiveRecord::Base
  has_many :d_cabinet_public_orgs, :conditions=>"delf=0"
  belongs_to :d_cabinet_head
  has_many :d_cabinet_files, :conditions=>"delf=0"

  ADMIN_USER_CD = '9999999'

  #
  # キャビネットのIDを指定して、キャビネット情報を取得します。
  #
  # @param cabinet_id - キャビネットのID
  #
#  def get_cabinetbody_by_id cabinet_id
#
#    conditions_sql = ""
#    conditions_param = {}
#
#    conditions_sql = " id = :id "
#    conditions_param[:id] = cabinet_id
#
#    DCabinetBody.find(:first, :conditions=>[conditions_sql, conditions_param])
#  end

  #
  # 指定されたキャビネットのファイルを削除します。
  # ファイルが添付されてい他場合、同時に削除します。
  #
  # @param id -
  # @param user_cd -
  #
  def delete_by_id id, user_cd

    cabinet = DCabinetBody.find(:first, :conditions=>{:delf=>0, :id=>id})

    unless cabinet.nil?

      # 添付ファイルの削除
      files = cabinet.d_cabinet_files
      unless files.length == 0
        files.each do |file|
          file.delf = 1
          file.deleted_user_cd = user_cd
          file.deleted_at = Time.now

          file.save
        end
      end

      # 公開対象組織の削除
      orgs = cabinet.d_cabinet_public_orgs
      orgs.each do |org|
        org.delf = 1
        org.deleted_user_cd = user_cd
        org.deleted_at = Time.now

        org.save
      end

      # 公開キャビネットの削除
      cabinet.delf = 1
      cabinet.deleted_user_cd = user_cd
      cabinet.deleted_at = Time.now

      cabinet.save
    end
  end

  #
  # 指定されたユーザーのWebメモリーのリストを取得します。
  #
  # @param user_cd - ユーザーCD
  # @return 指定ユーザーのWebメモリーのリスト
  #
  def get_webmemory_by_user_cd user_cd

    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    joins_sql = "INNER JOIN d_cabinet_heads ON d_cabinet_heads.id = d_cabinet_bodies.d_cabinet_head_id"
    joins_sql += " INNER JOIN d_cabinet_files ON d_cabinet_files.d_cabinet_body_id = d_cabinet_bodies.id"

    conditions_sql = "d_cabinet_bodies.delf = :delf "
    conditions_sql += " AND d_cabinet_heads.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_heads.private_user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd
    conditions_sql += " AND d_cabinet_heads.cabinet_kbn = :cabinet_kbn"
    conditions_param[:cabinet_kbn] = 0

    order_sql = " d_cabinet_bodies.post_date DESC"

    DCabinetBody.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # マイページの「あなたへの新着メッセージ」に表示するWebメモリーのファイルリストを取得します。
  #
  # @return 有効期限まで5日を切るキャビネットファイルのリスト
  #
  def get_enable_alert_list user_cd
    conditions_sql = ""
    conditions_param = Hash.new
    joins_sql = ""
    order_sql = ""

    joins_sql += " INNER JOIN d_cabinet_heads on d_cabinet_heads.id = d_cabinet_bodies.d_cabinet_head_id "
    joins_sql += " INNER JOIN d_cabinet_files on d_cabinet_files.d_cabinet_body_id = d_cabinet_bodies.id "
    conditions_sql += " d_cabinet_bodies.delf = :delf "
    conditions_sql += " AND d_cabinet_heads.delf = :delf "
    conditions_sql += " AND d_cabinet_files.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_heads.private_user_cd = :user_cd"
    conditions_param[:user_cd] = user_cd
    conditions_sql += " AND d_cabinet_heads.default_enable_day - cast(to_char(now()- d_cabinet_bodies.post_date, 'DD') as int) >= :minimum_days "
    conditions_param[:minimum_days] = 1
    conditions_sql += " AND d_cabinet_heads.default_enable_day - cast(to_char(now()- d_cabinet_bodies.post_date, 'DD') as int) <= :maximum_days "
    conditions_param[:maximum_days] = 5
    order_sql = " (d_cabinet_heads.default_enable_day - cast(to_char(now()- d_cabinet_bodies.post_date, 'DD') as int) <= 5) ASC"

    return DCabinetBody.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end


  #
  # 指定されたキャビネットの一覧を取得する。
  #
  # @param page, - 次ページ番号
  # @param per_page - ページ最大表示件数
  # @param cabinet_kbn - キャビネット区分
  # @param head_id - キャビネットヘッダID
  # @param user_cd - ログインユーザーCD(権限の判定に必要)
  # @param date_from - 公開開始日(検索条件)
  # @param date_to - 公開終了日(検索条件)
  # @param keyword - 検索語(検索条件)
  # @param order - 整列要素
  # @param mode - 昇順/降順
  # @param caller - 呼び出し元
  #
  def self.get_cabinet_bodies page, per_page, cabinet_kbn, head_id, user_cd, date_from, date_to, keyword, order, mode, caller

    select_sql = "DISTINCT d_cabinet_bodies.*"
    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    if cabinet_kbn.nil?
      unless head_id.nil? or head_id.empty?
        cabinet_head = DCabinetHead.find(:first, :conditions=>{:delf=>0, :id=>head_id})
        unless cabinet_head.nil?
          cabinet_kbn = cabinet_head.cabinet_kbn
        end
      end
    end

    joins_sql = " INNER JOIN d_cabinet_heads ON d_cabinet_heads.id = d_cabinet_bodies.d_cabinet_head_id"
    joins_sql += " INNER JOIN d_cabinet_public_orgs ON d_cabinet_public_orgs.d_cabinet_body_id = d_cabinet_bodies.id"

    # 削除フラグ
    conditions_sql = " d_cabinet_bodies.delf = :delf"
    conditions_sql += " AND d_cabinet_public_orgs.delf = :delf"
    conditions_param[:delf] = 0

    unless cabinet_kbn.nil? or cabinet_kbn.to_s.empty?
      conditions_sql += " AND d_cabinet_heads.cabinet_kbn = :cabinet_kbn"
      conditions_param[:cabinet_kbn] = cabinet_kbn
    end

    # ヘッダID
    unless head_id.nil? or head_id.empty?
      conditions_sql += " AND d_cabinet_bodies.d_cabinet_head_id = :head_id"
      conditions_param[:head_id] = head_id
    else
      # 共有キャビネット初期表示時は部内キャビネットのみ表示する。
#      conditions_sql += " AND d_cabinet_heads.cabinet_kbn = :cabinet_kbn"
#      conditions_param[:cabinet_kbn] = 2
    end

    # ヘッダID(呼び出し元がトップの場合)
    if caller == "top"
      #月初メッセージは除く
      conditions_sql += " AND (d_cabinet_bodies.d_cabinet_head_id != 4) "
    end

    # 公開対象期間
    conditions_sql += " AND (d_cabinet_bodies.public_date_from <= :public_date_from OR d_cabinet_bodies.public_date_from IS NULL"
    # 呼び出し元がtopでなければ、公開前のお知らせであっても一覧に表示する。
    unless caller == "top"
      conditions_sql += " OR d_cabinet_bodies.post_user_cd = :post_user_cd"
    end
    conditions_sql += ") "
    conditions_param[:public_date_from] = Time.now
    conditions_sql += " AND (d_cabinet_bodies.public_date_to >= :public_date_to OR d_cabinet_bodies.public_date_to IS NULL"
    unless caller == "top"
      conditions_sql += " OR d_cabinet_bodies.post_user_cd = :post_user_cd"
    end
    conditions_sql += ") "
    conditions_param[:public_date_to] = Time.now
    conditions_param[:post_user_cd] = user_cd

    # 投稿日
    unless date_from.nil? or date_from.empty?
      conditions_sql += " AND (cast(d_cabinet_bodies.post_date as date) >= :date_from OR d_cabinet_bodies.post_date IS NULL)"
      conditions_param[:date_from] = date_from
    end
    unless date_to.nil? or date_to.empty?
     conditions_sql += " AND (cast(d_cabinet_bodies.post_date as date) <= :date_to OR d_cabinet_bodies.post_date IS NULL)"
      conditions_param[:date_to] = date_to
    end
    # キーワード
    unless keyword.nil? or keyword.empty?
      conditions_sql += " AND (d_cabinet_bodies.title like :keyword OR d_cabinet_bodies.body like :keyword OR d_cabinet_bodies.meta_tag like :keyword) "
      conditions_param[:keyword] = "%#{keyword}%"
    end
    # ログインユーザの所属する組織の組織コードが公開対象組織になっているかを確認する。
    conditions_sql += " AND (d_cabinet_public_orgs.org_cd = '0' "

    user_org_list = MUserBelong.new.get_belong_org user_cd
    # 複数組織に所属するときは、そのすべてに対して閲覧が可能
    user_org_list.each do |user_org|
      # ※ ツリーで指示できる組織の階層に、ユーザーの所属組織コードを合わせている。
      user_org_cd = user_org.org_cd
      if user_org_cd.length > 6
        user_org_cd = user_org_cd[0...6]
      end
      #conditions_sql += " OR d_notice_public_orgs.org_cd = ':public_org_cd' "
      conditions_sql += " OR cast(d_cabinet_public_orgs.org_cd as varchar) = SUBSTR(':public_org_cd', 0, LENGTH(cast(d_cabinet_public_orgs.org_cd as varchar)) + 1) "
      conditions_sql.gsub!(":public_org_cd", user_org_cd)
  end

  if caller == "top"
    conditions_sql += " AND d_cabinet_bodies.post_date >= :post_date"
    conditions_param[:post_date] = Date.today - 14
  end
# etcstr1にユーザーコードがあれば、その他の条件を無視する。
#    conditions_sql += " OR d_cabinet_public_orgs.etcstr1 = :user_cd "
#    conditions_param[:user_cd] = user_cd
    conditions_sql += ")"
    if order.nil? or order.empty?
      order_sql += " updated_at"
    else
      order_sql += order
    end

    if mode.nil? or mode.empty? or mode == "1"
      order_sql += " DESC"
    else
      order_sql += " ASC"
    end

    DCabinetBody.paginate(:page=>page, :per_page=>per_page, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end


#  def get_newly_list page, per_page, user_cd
#
#    joins_sql = ""
#    conditions_sql = ""
#    conditions_param = Hash.new
#    order_sql = ""
#
#    joins_sql += " INNER JOIN d_cabinet_heads ON d_cabinet_heads.id = d_cabinet_bodies.d_cabinet_head_id "
#    joins_sql += " INNER JOIN d_cabinet_auths ON d_cabinet_auths.d_cabinet_head_id = d_cabinet_heads.id"
#
#    DCabinetBody.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
#    DCabinetBody
#  end

  #
  # 渡されたキャビネットに格納されているファイルの一覧を取得する。
  #
  def self.get_cabinet_bodies_list head_id

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    joins_sql = " INNER JOIN d_cabinet_heads on d_cabinet_heads.id = d_cabinet_bodies.d_cabinet_head_id "
    conditions_sql += " d_cabinet_bodies.delf = :delf "
    conditions_sql += " AND d_cabinet_heads.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_bodies.d_cabinet_head_id = :head_id "
    conditions_param[:head_id] = head_id
    order_sql = " d_cabinet_heads.id"

    return DCabinetBody.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end
end
