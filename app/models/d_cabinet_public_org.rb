class DCabinetPublicOrg < ActiveRecord::Base
  belongs_to :d_cabinet_body

  ADMIN_USER_CD = '9999999'

  #
  # 共有キャビネットの公開対象組織のレコードを作成する
  #
  # @param body_id - キャビネットID
  # @param org_cd  - 公開対象組織CD
  # @param user_cd - 登録ユーザーCD
  #
  def create_public_org body_id, org_cd, user_cd

    org = DCabinetPublicOrg.new

    org.d_cabinet_body_id = body_id
    org.org_cd = org_cd
    #org.etcstr1 = ADMIN_USER_CD
    org.delf = 0
    org.created_user_cd = user_cd
    org.updated_user_cd = user_cd

    org.save
  end

  #
  # 指定されたキャビネットの指定された公開対象組織を削除する
  #
  # @param body_id - キャビネットID
  # @param org_cd  - 公開対象組織CD
  # @param user_cd - 削除者CD
  #
  def delete_public_org body_id, org_cd, user_cd

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_body_id = :body_id"
    conditions_param[:body_id] = body_id
    unless org_cd.nil?
      conditions_sql += " AND org_cd = :org_cd"
      conditions_param[:org_cd] = org_cd
    end

    orgs = DCabinetPublicOrg.find(:all, :conditions=>[conditions_sql, conditions_param])

    orgs.each do |org|
      org.delf = 1
      org.deleted_user_cd = user_cd
      org.deleted_at = Time.now

      org.save
    end
  end

  #
  # 指定されたキャビネットの公開対象組織一覧を取得します。
  #
  # @param body_id - キャビネットID
  #
  def get_by_body_id body_id

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_body_id = :body_id "
    conditions_param[:body_id] = body_id

    DCabinetPublicOrg.find(:all, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # 指定された公開対象組織のレコードを取得する。
  #
  # @param org_cd      - 公開対象組織CD
  #
  def get_public_org_by_cd org_cd
    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = "0"
    conditions_sql += " AND org_cd = :org_cd"
    conditions_param[:org_cd] = org_cd

    DCabinetPublicOrg.find(:first, :conditions=>[conditions_sql, conditions_param])
  end

end
