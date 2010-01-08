class DCabinetHead < ActiveRecord::Base
  belongs_to :m_project
  belongs_to :m_user
  has_one :d_cabinet_index, :conditions=>"delf=0"
  has_many :d_cabinet_bodies,  :conditions=>"delf=0"

  #
  # 共有キャビネットの部門キャビネットにキャビネットを作成する権利を与える。
  #
  # @param org_cd - 権利を与えられる組織のCD
  #
  def self.create_authority org_cd, user_cd
    # 渡された組織コードのキャビネットが既に作られていた場合は処理をスキップする。
    d_cabinet_head = DCabinetHead.find(:first, :conditions=>{:delf=>0, :cabinet_kbn=>-1, :private_org_cd=>org_cd})

    if d_cabinet_head.nil?
      d_cabinet_head = DCabinetHead.new
      org = MOrg.new.get_org_info org_cd
      unless org.org_name3.empty?
        org_name = org.org_name3
      else
        unless org.org_name2.empty?
          org_name = org.org_name2
        else
          unless org.org_name1.empty?
            org_name = org.org_name1
          end
        end
      end
      d_cabinet_head.title = org_name
      d_cabinet_head.cabinet_kbn = -1
      d_cabinet_head.private_org_cd = org_cd
      d_cabinet_head.created_user_cd = user_cd
      d_cabinet_head.updated_user_cd = user_cd

      begin
        d_cabinet_head.save
        DCabinetIndex.new.create_authority d_cabinet_head

        d_cabinet_auth = DCabinetAuth.new
        d_cabinet_auth.d_cabinet_head_id = d_cabinet_head.id
        d_cabinet_auth.org_cd = d_cabinet_head.private_org_cd
        d_cabinet_auth.auth_kbn = "2"
        d_cabinet_auth.created_user_cd = user_cd
        d_cabinet_auth.updated_user_cd = user_cd
        d_cabinet_auth.save
      rescue
        # 保存エラー
      end
    end
  end

  #
  # 共有キャビネットの指定された部門キャビネットの使用を停止する。(削除フラグを立てる)
  #
  def self.delete_authority org_cd, user_cd

    d_cabinet_head = DCabinetHead.find(:first, :conditions=>{:delf=>0, :cabinet_kbn=>-1, :private_org_cd=>org_cd})

    not_delete_org_cd = ""  #下階層にフォルダが存在する組織CD
    unless d_cabinet_head.nil?
      d_child_cabinet = DCabinetIndex.find(:first, :conditions=>{:delf=>0, :parent_cabinet_head_id=>d_cabinet_head.id, :cabinet_kbn=>2})

      #下階層にフォルダが存在する場合は、テーブル更新は行わない
      if !d_child_cabinet.nil?
        not_delete_org_cd = org_cd

      else
        #テーブルを更新する
  #      d_cabinet_index = DCabinetIndex
        d_cabinet_head.d_cabinet_index.delf = "1"
        d_cabinet_head.d_cabinet_index.deleted_user_cd = user_cd
        d_cabinet_head.d_cabinet_index.deleted_at = Time.now
        d_cabinet_head.d_cabinet_index.save
        d_cabinet_head.delf = "1"
        d_cabinet_head.deleted_user_cd = user_cd
        d_cabinet_head.deleted_at = Time.now
        d_cabinet_head.save
      end
    end

    return not_delete_org_cd
  end


  #
  # 指定された共有キャビネットヘッダレコードを取得します。
  #
  # @param id - ヘッダID
  # @return 共有キャビネットヘッダレコード
  #
  def get_cabinethead_by_id id

    conditions_sql = ""
    conditions_param = {}
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND id = :id "
    conditions_param[:id] = id

    DCabinetHead.find(:first, :conditions=>[conditions_sql, conditions_param]);
  end

  #
  # 指定されたユーザーのキャビネット戸田を取得します。
  #
  # @param user_cd - ユーザーCD
  #
  def self.get_cabinethead_by_user_cd user_cd

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND cabinet_kbn = :cabinet_kbn "
    conditions_param[:cabinet_kbn] = 0
    conditions_sql += " AND private_user_cd = :private_user_cd "
    conditions_param[:private_user_cd ] = user_cd

    DCabinetHead.find(:first, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # 指定されたユーザーのWebメモリ用ヘッダレコードを作成する。
  #
  # @param user_cd - ユーザーCD
  #
  def create_private_cabinet user_cd

    d_cabinet_head = DCabinetHead.new

    d_cabinet_head.title = ""
    d_cabinet_head.private_user_cd = user_cd
    # Webメモリのデータ保持期間
    d_cabinet_head.default_enable_day = 30
    # Webメモリの最大データサイズ
    d_cabinet_head.max_disk_size = 100
    d_cabinet_head.created_user_cd = user_cd
    d_cabinet_head.updated_user_cd = user_cd

    d_cabinet_head.save
  end

  #
  # プロジェクトキャビネットを作成する。
  #
  # @param - id プロジェクトマスタに作成したレコードのID
  # @param - user_cd ログインユーザーコード
  #
  def self.create_project_cabinet id, user_cd

    m_projects = MProject.find(:first, :conditions=>{:delf=>0, :id=>id})

    begin
      # d_cabinet_headsテーブルにレコードを作成する。
      d_cabinet_head = DCabinetHead.new

      d_cabinet_head.cabinet_kbn = 3
      d_cabinet_head.title = m_projects.name
      d_cabinet_head.private_project_id = id
      d_cabinet_head.created_user_cd = user_cd
      d_cabinet_head.updated_user_cd = user_cd

      d_cabinet_head.save

      # d_cabinet_indicesテーブルにレコードを作成する。
      d_cabinet_index = DCabinetIndex.new

      d_cabinet_index.cabinet_kbn = 3
      d_cabinet_index.title = m_projects.name
      d_cabinet_index.d_cabinet_head_id = d_cabinet_head.id
      d_cabinet_index.created_user_cd = user_cd
      d_cabinet_index.updated_user_cd = user_cd

      d_cabinet_index.save

      # d_cabinet_authsテーブルにレコードを作成する。
      d_cabinet_auth = DCabinetAuth.new
      d_cabinet_auth.d_cabinet_head_id = d_cabinet_head.id
      d_cabinet_auth.org_cd = 0

      d_cabinet_auth.save
    end
  end

  #
  # 部内キャビネットが使用できる組織の一覧を取得する。
  #
  def self.get_sectional_cabinet_section

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    joins_sql = "INNER JOIN m_orgs ON m_orgs.org_cd = d_cabinet_heads.private_org_cd"

    conditions_sql = " d_cabinet_heads.delf = :delf"
    conditions_sql += " AND m_orgs.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_heads.cabinet_kbn = :cabinet_kbn"
    conditions_param[:cabinet_kbn] = -1

    order_sql = " m_orgs.org_cd ASC"

    DCabinetHead.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  def self.create_company_cabinet id, title, parent_cabinet_head_id, user_cd

    if id.nil? or id.empty?
      d_cabinet_head = DCabinetHead.new
    else
      d_cabinet_head = DCabinetHead.find(:first, :conditions=>{:id=>id, :delf=>0})
    end
    d_cabinet_head.title = title
    begin
      d_cabinet_head.save
      if id.nil? or id.empty?
        d_cabinet_index = DCabinetIndex.new
      else
        d_cabinet_index = DCabinetIndex.find(:first, :conditions=>{:id=>id, :delf=>0})
      end
      d_cabinet_index.parent_cabinet_head_id = parent_cabinet_head_id
      d_cabinet_index.d_cabinet_head_id = d_cabinet_head.id
      d_cabinet_index.title = title
      begin
        d_cabinet_index.save
      rescue
p "★" + $!
      end
    rescue
p "★"+$! #DEBUG
    end
  end


  def self.delete_company_info id

    d_cabinet_head = DCabinetHead.find(:first, :conditions=>{:id=>id, :delf=>0})
    unless d_cabinet_head.nil?
      d_cabinet_head.delf = 1
      begin
        d_cabinet_head.save
        d_cabinet_index = DCabinetIndex.find(:first, :conditions=>{:id=>id, :delf=>0})
        d_cabinet_index.delf = 1
        begin
          d_cabinet_index.save
        rescue
p "★" + $!
        end
      rescue
p "★" + $!
      end
    end
  end

end
