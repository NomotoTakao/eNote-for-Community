class DNoticePublicOrg < ActiveRecord::Base
  belongs_to :d_notice_body

  #
  # お知らせの公開対象組織レコードを作成する
  #
  # @param body_id - お知らせID
  # @param org_cd  - 公開対象組織CD
  # @param user_cd - 登録者ID
  #
  def create_public_org body_id, org_cd, user_cd

    public_org = DNoticePublicOrg.new

    public_org.d_notice_body_id = body_id
    public_org.org_cd = org_cd
    public_org.created_user_cd = user_cd
    public_org.updated_user_cd = user_cd

    public_org.save
  end

  #
  # 指定されたお知らせの指定された公開対象組織レコードを削除する
  #
  # @param body_id - お知らせID
  # @param org_cd  - 公開対象組織CD
  # @param user_cd - 削除者CD
  #
  def delete_public_org body_id, org_cd, user_cd

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND d_notice_body_id = :body_id"
    conditions_param[:body_id] = body_id
    unless org_cd.nil?
      conditions_sql += " AND org_cd = :org_cd"
      conditions_param[:org_cd] = org_cd
    end

    orgs = DNoticePublicOrg.find(:all, :conditions=>[conditions_sql, conditions_param])
    orgs.each do |org|
      org.delf = 1
      org.deleted_user_cd = user_cd
      org.deleted_at = Time.now

      org.save
    end
  end


  #
  # 指定されたIDのお知らせに紐付く公開対象組織の配列を取得します。
  #
  # @param id - お知らせ詳細ID
  # @return お知らせに紐付く公開対象組織の配列
  #
  def get_publicorgs_by_bodyid id

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_notice_body_id = :id "
    conditions_param[:id] = id

    order_sql = " id ASC "

    DNoticePublicOrg.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 指定されたお知らせ詳細に紐付く公開対象組織を削除します。
  #
  # @param id      - お知らせ詳細ID
  # @param user_cd - 削除ユーザーCD
  #
  def delete_public_orgs_by_bodyid id, user_cd

    records = get_publicorgs_by_bodyid id
    records.each do |record|

      record.delf = "1"
      record.deleted_user_cd = user_cd
      record.deleted_at = Time.now
      record.updated_user_cd = user_cd

      record.save
    end
  end
end
