class DCabinetIndex < ActiveRecord::Base
  belongs_to :d_cabinet_head, :foreign_key=>:d_cabinet_head_id


  #
  # 指定されたキャビネット区分のキャビネット一覧を取得します。
  #
  # @param kbn_id - キャビネット区分ID
  # @return キャビネット一覧
  #
  def get_cabinet_list_by_kbn kbn_id

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    if kbn_id == 3
      joins_sql = "INNER JOIN d_cabinet_heads ON d_cabinet_heads.id = d_cabinet_indices.d_cabinet_head_id "
      joins_sql += "INNER JOIN m_projects ON m_projects.id = d_cabinet_heads.private_project_id "
    end

    conditions_sql = " d_cabinet_indices.delf = :delf "
    if kbn_id == 3
      conditions_sql += " AND d_cabinet_heads.delf = :delf"
      conditions_sql += " AND m_projects.delf = :delf"
    end
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_head_id != :head_id "
    conditions_param[:head_id] = 0
    conditions_sql += " AND d_cabinet_indices.cabinet_kbn = :cabinet_kbn "
    conditions_param[:cabinet_kbn] = kbn_id

    order_sql = " id "

    DCabinetIndex.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 全社キャビネットを取得する
  #
  # @return 全社キャビネット
  #
  def get_company_cabinet

    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND cabinet_kbn = :cabinet_kbn "
    conditions_param[:cabinet_kbn] = 1

    order_sql = " order_display ASC "

    DCabinetIndex.find(:all, :conditions=>[conditions_sql, conditions_apram], :order=>order_sql)
  end


  #
  # 指定されたユーザーが所属する組織の部内キャビネットを配列として取得します。
  #　ユーザーが複数の組織に所属している場合、そのすべての組織について取得します。」
  #
  # @param usr_cd - ユーザーCD
  #
  def get_sectional_cabinet_by_usesr_cd user_cd

    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    joins_sql = " INNER JOIN d_cabinet_heads ON d_cabinet_indices.d_cabinet_head_id = d_cabinet_heads.id "
    joins_sql = " INNER JOIN m_user_belongs ON m_user_belongs.org_cd = d_cabinet_heads.private_org_cd "

    conditions_sql = " d_cabinet_indices.delf = :delf "
    conditions_sql += " AND d_cabinet_heads.delf = :delf "
    conditions_sql += " AND m_user_belongs.delf = :delf"
    conditions_param[:delf] = 0
    condisions_sql += " AND d_cabinet_indices.cabinet_kbn = :cabinet_kbn"
    conditions_param[:cabinet_kbn] = 2
    conditions_sql += " AND m_user_belongs.user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd

    order_sql = " d_cabinet_indices.order_display ASC"

    DCabinetIndex.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 指定された組織が管理組織となっているキャビネットを取得します。
  #
  # @param org_cd - 管理組織コード
  # @return キャビネット配列
  #
  def get_sectional_cabinet_list_by_org_cd org_cd

    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    # 共有キャビネットのツリーでは、3階層までの組織しか対象としないので、
    # 渡された組織コードの組織レベルをチェックして'4'ならば上位の組織コードを求める
    org = MOrg.new.get_org_info org_cd
    if org.org_lvl > 3
      org_cd = org.org_cd1 + org.org_cd2 + org.org_cd3
    end

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0

    joins_sql = " INNER JOIN d_cabinet_heads ON d_cabinet_heads.id = d_cabinet_indices.d_cabinet_head_id "

    conditions_sql = " d_cabinet_indices.delf = :delf "
    conditions_sql += " AND d_cabinet_heads.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_heads.cabinet_kbn = :cabinet_kbn "
    conditions_param[:cabinet_kbn] = -1
    conditions_sql += " AND d_cabinet_heads.private_org_cd = :org_cd "
    conditions_param[:org_cd] = org_cd

    order_sql = " d_cabinet_indices.order_display ASC"

    DCabinetIndex.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # プロジェクトキャビネットを取得する
  #
  # @return プロジェクトキャビネット
  #
  def get_project_cabinet

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""

    conditions_sql = " delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND dcabinet_kbn = :cabinet_kbn "
    conditions_param[:cabinet_kbn] = 3

    DCabinetIndex.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 指定された管理組織コードのキャビネットの最終の表示順を取得する
  #
  # @param parent_cabinet_head_id - 上位キャビネットID
  # @return 指定された組織の管理するキャビネットの最終の表示順
  #
  def get_last_order_display_by_parent_cabinet_head_id parent_cabinet_head_id

    conditions_sql = ""
    conditions_param = {}
    order_sql = ""
    joins_sql = ""

    joins_sql = " INNER JOIN d_cabinet_heads ON d_cabinet_heads.id = d_cabinet_indices.d_cabinet_head_id "

    conditions_sql = " d_cabinet_indices.delf = :delf "
    conditions_sql += " AND d_cabinet_heads.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_indices.parent_cabinet_head_id = :parent_cabinet_head_id "
    conditions_param[:parent_cabinet_head_id] = parent_cabinet_head_id

    order_sql = " order_display ASC"

    indices = DCabinetIndex.find(:last, :joins=>joins_sql,:conditions=>[conditions_sql, conditions_param], :order=>order_sql)
    if indices.nil?
      last_order = 1
    else
      last_order = indices.order_display + 1
    end
  end

  #
  # 指定されたユーザーが所属する組織の部内キャビネットを求める(第一階層)
  #
  # @param user_cd - ユーザーCD
  #
  def get_sectional_cabinet_list user_cd

    joins_sql = ""
    conditions_sql = ""
    belong_orgs_sql = ""
    conditions_param = {}

    # ユーザーが所属する組織の組織CDを求める
    belong_orgs = MUserBelong.new.get_belong_org user_cd

    # 所属するすべての組織について、部門キャビネットを求める
    joins_sql = "INNER JOIN d_cabinet_heads ON d_cabinet_heads.id = d_cabinet_indices.d_cabinet_head_id"

    conditions_sql = " d_cabinet_indices.delf = :delf"
    conditions_sql += " AND d_cabinet_heads.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_indices.cabinet_kbn = :cabinet_kbn"
    conditions_param[:cabinet_kbn] = -1
    conditions_sql += " AND("
    belong_orgs.each do |belong_org|
      unless belong_orgs_sql.empty?
        belong_orgs_sql += " OR "
      end
      org_cd = belong_org.org_cd
      # 共有キャビネットのツリーでは、3階層までの組織しか対象としないので、
      # 渡された組織コードの組織レベルをチェックして'4'ならば上位の組織コードを求める
      org = MOrg.new.get_org_info org_cd
      if org.org_lvl > 3
        org_cd = org.org_cd1 + org.org_cd2 + org.org_cd3
      end
      belong_orgs_sql += " d_cabinet_heads.private_org_cd = '" + org_cd + "'"
    end

    conditions_sql += belong_orgs_sql
    conditions_sql += ")"

    DCabinetIndex.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # 第一階層のキャビネットの下に作られたキャビネットを取得する。
  #
  # @param head_id - 第一階層の部内キャビネットのID
  #
  def get_child_cabinet_list head_id

    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""

    joins_sql = "INNER JOIN d_cabinet_heads ON d_cabinet_heads.id = d_cabinet_indices.d_cabinet_head_id"

    conditions_sql = " d_cabinet_indices.delf = :delf"
    conditions_sql += " AND d_cabinet_heads.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_indices.cabinet_kbn = :cabinet_kbn"
    conditions_sql += " AND d_cabinet_heads.cabinet_kbn = :cabinet_kbn"
    conditions_param[:cabinet_kbn] = 2
    conditions_sql += " AND d_cabinet_indices.parent_cabinet_head_id = :head_id"
    conditions_param[:head_id] = head_id

    DCabinetIndex.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param])
  end


  def create_authority cabinet_head
    d_cabinet_index = DCabinetIndex.new

    d_cabinet_index.cabinet_kbn = -1
    d_cabinet_index.parent_cabinet_head_id = 0
    d_cabinet_index.d_cabinet_head_id = cabinet_head.id
    d_cabinet_index.index_type = "f"
    d_cabinet_index.title = cabinet_head.title
    d_cabinet_index.created_user_cd = cabinet_head.created_user_cd
    d_cabinet_index.updated_user_cd = cabinet_head.updated_user_cd

    d_cabinet_index.save
  end

  #
  # 指定されたキャビネットの一覧を取得する。
  #
  # @param cabinet_kbn - キャビネット区分
  # @param parent_cabinet_head_id - 親キャビネットID
  # @param auth_kbn - 1:参照可能、2:書き込み可能
  # @param user_cd - ログインユーザーCD(権限の判定に利用)
  #
  def self.get_cabinet_indices cabinet_kbn, parent_cabinet_head_id, auth_kbn, user_cd

    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    select_sql += " DISTINCT d_cabinet_indices.*"

    joins_sql = " INNER JOIN d_cabinet_heads ON d_cabinet_heads.id = d_cabinet_indices.d_cabinet_head_id"
    joins_sql += " INNER JOIN d_cabinet_auths ON d_cabinet_auths.d_cabinet_head_id = d_cabinet_heads.id"

    conditions_sql = " d_cabinet_indices.delf = :delf"
    conditions_sql += " AND d_cabinet_heads.delf = :delf"
    conditions_sql += " AND d_cabinet_auths.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_indices.cabinet_kbn = :cabinet_kbn"
    conditions_param[:cabinet_kbn] = cabinet_kbn
    unless parent_cabinet_head_id.nil?
      conditions_sql += " AND d_cabinet_indices.parent_cabinet_head_id = :parent_cabinet_head_id"
      conditions_param[:parent_cabinet_head_id] = parent_cabinet_head_id
    else
      conditions_sql += " AND d_cabinet_indices.index_type = :index_type"
      conditions_param[:index_type] = 'b'
    end
    belong_orgs = MUserBelong.find(:all, :conditions=>{:delf=>0, :user_cd=>user_cd})
    belong_sql = ""
    tmp_sql = ""
    unless belong_orgs.length == 0
      belong_orgs.each do |org|
        unless tmp_sql.empty?
          tmp_sql += " OR "
        end
        tmp_sql += "d_cabinet_auths.org_cd = SUBSTR(':org_cd', 0, LENGTH(d_cabinet_auths.org_cd)+1)".gsub(":org_cd", org.org_cd)
      end
      unless tmp_sql.empty?
        belong_sql = " AND (#{tmp_sql}"
      end
    end
    conditions_sql += " AND ((d_cabinet_auths.org_cd != '' #{belong_sql} OR d_cabinet_auths.org_cd = '0')) OR d_cabinet_auths.user_cd = :user_cd)"
    conditions_param[:user_cd] = user_cd
    unless auth_kbn.nil?
      if auth_kbn == 1
        conditions_sql += " AND d_cabinet_auths.auth_kbn IN (1, 2)"
      else
        conditions_sql += " AND d_cabinet_auths.auth_kbn = :auth_kbn"
        conditions_param[:auth_kbn] = auth_kbn
      end
    end

    order_sql = " d_cabinet_indices.cabinet_kbn"
    order_sql += " ,d_cabinet_indices.parent_cabinet_head_id"
    order_sql += " ,d_cabinet_indices.order_display ASC"

    result = DCabinetIndex.find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 共有キャビネットの一覧を取得します。
  #
  # @param cabinet_kbn - キャビネット区分(1:全社キャビネット、2:プロジェクトキャビネット、3:部内キャビネット)
  # @param parent_cabinet_head_id - 親キャビネットID
  #
#  def self.get_cabinet_list cabinet_kbn, parent_cabinet_head_id
#
#    conditions_sql = ""
#    conditions_param = Hash.new
#    order_sql = ""
#
#    conditions_sql = " d_cabinet_indices.delf = :delf"
#    conditions_param[:delf] = 0
#    conditions_sql += " AND d_cabinet_indices.cabinet_kbn = :cabinet_kbn"
#    conditions_param[:cabinet_kbn] = cabinet_kbn
#    conditions_sql += " AND d_cabinet_indices.d_cabinet_head_id = :parent_cabinet_head_id"
#    conditions_param[:parent_cabinet_head_id] = parent_cabinet_head_id
#    order_sql = " d_cabinet_indices.order_display ASC"
#
#    DCabinetIndex.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
#  end

  #
  #指定された親IDをもつ全社キャビネットデータを返す
  #
  def self.get_company_cabinet_list parent_cabinet_head_id

    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    conditions_sql += " d_cabinet_indices.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_indices.cabinet_kbn = :cabinet_kbn "
    conditions_param[:cabinet_kbn] = 1
    conditions_sql += " AND d_cabinet_indices.parent_cabinet_head_id = :parent_cabinet_head_id "
    unless parent_cabinet_head_id.nil? or parent_cabinet_head_id.to_s.empty?
      conditions_param[:parent_cabinet_head_id] = parent_cabinet_head_id
    else
      conditions_param[:parent_cabinet_head_id] = 0
    end

    order_sql = " order_display ASC"

    return find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 指定された共有キャビネットインデックスレコードを取得します。
  #
  # @param head_id - ヘッダID
  # @return 共有キャビネットインデックスレコード
  #
  def self.get_cabinetindex_by_head_id head_id

    conditions_sql = ""
    conditions_param = {}
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND d_cabinet_head_id = :d_cabinet_head_id "
    conditions_param[:d_cabinet_head_id] = head_id

    DCabinetIndex.find(:first, :conditions=>[conditions_sql, conditions_param]);
  end
end
