require 'digest/sha1'

#メールアカウント設定用変数
IMAP_QUOTA = "*:storage="

class MUser < ActiveRecord::Base
#  belongs_to :m_org, :foreign_key => "org_cd", :finder_sql => "SELECT * FROM m_orgs WHERE org_cd = '#{self.org_cd}'"
#  belongs_to :m_org, :conditions => ["org_cd = ?", self.org_cd]
  has_one :d_cabinet_head, :foreign_key=>"private_user_cd", :conditions=>{:delf=>0, :cabinet_kbn=>0}

  include Authentication
#  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
#  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

#  validates_presence_of     :email
#  validates_length_of       :email,    :within => 6..100 #r@a.wk
#  validates_uniqueness_of   :email
#  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message



  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :user_cd, :email, :name, :password, :password_confirmation, :passwd, :last_change_passwd_at, :updated_user_cd



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    #プレインパスワードでの認証を行う
#    u = find_by_login(login.downcase) # need to get the salt
#    u && u.authenticated?(password) ? u : nil
    u = find(:first, :conditions => ["login = ? AND delf = '0'", login])
    u && u.passwd == password ? u :nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  #
  #最終ログイン日時を更新する
  #
  #@param id - 更新対象のid
  #
  def update_lastlogin(id)
    data = MUser.find(id)
    data.update_attribute(:lastlogin_at, Time.now)
  end


  #
  # ユーザーCDをキーとしたユーザー名のハッシュテーブルを取得します。
  #
  # @return ユーザーCDをキーとしたユーザー名のハッシュテーブル
  #
  def get_hash_cd_and_name

    result = {}
    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"

    m_users = MUser.find(:all, :conditions=>[conditions_sql, conditions_param])
    m_users.each do |user|
      result[user.user_cd] = user.name
    end

    result
  end

  #
  # 指定された組織に属するユーザーの一覧を取得する。
  #
  # @param org_cd - 組織CD
  # @return ユーザー一覧
  #
  def get_user_list_by_org_cd org_cd

    select_sql = ""
    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""
    order_sql = ""

    select_sql = " m_users.user_cd AS user_cd, m_users.name AS user_name, m_user_belongs.org_cd AS org_cd"
    joins_sql = " LEFT JOIN m_user_belongs ON m_user_belongs.user_cd = m_users.user_cd "
    conditions_sql = " m_users.delf = :delf "
    conditions_sql += " AND m_user_belongs.delf = :delf "
    conditions_param[:delf] = 0
#    conditions_sql += " AND m_user_belongs.belong_kbn = :belong_kbn "
#    conditions_param[:belong_kbn] = 0
    conditions_sql += " AND m_user_belongs.org_cd = :org_cd "
    conditions_param[:org_cd] = org_cd

    order_sql = " m_users.user_cd ASC"

    MUser.find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #引数の社員CDから名前を返す
  def self.get_user_name(user_cd)
    rec = find(:first, :conditions => ["user_cd = ?", user_cd])
    if rec.nil?
      return ""
    else
      return rec.name
    end
  end

  #
  # 引数に渡された文字列を名前に含むユーザーを取得する。
  #
  # @param user_name - ユーザー名の一部
  #
  def self.get_user_by_name user_name

    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    conditions_sql = " m_users.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND m_users.name like :user_name"
    conditions_param[:user_name] = "%" + user_name + "%"

    order_sql = " user_cd ASC"

    MUser.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)

  end

  protected

  #
  # 指定されたユーザーCDのユーザー情報を取得する。
  #
  # @param user_id - ユーザーCD
  # @return ユーザー情報
  #
  def get_user user_id

    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND id = :id"
    conditions_param[:id] = user_id

    MUser.find(:first, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # キーワードにあてはまるユーザーを取得する。
  #
  # @param keyword - ユーザーCDまたは名前
  #
  def get_user_by_keyword keyword

  end





  #
  # キーワードにあてはまるユーザーを取得する。
  #
  # @param keyword - ユーザーCDまたは名前
  #
  def self.get_user_by_keyword keyword

    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    conditions_sql = " m_users.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND (m_users.user_cd like :keyword"
    conditions_sql += " OR m_users.name like :keyword)"
    conditions_param[:keyword] = "%" + keyword + "%"

    order_sql = " m_users.user_cd ASC"

    MUser.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # ユーザーマスタ/ユーザ属性マスタ/ユーザ所属マスタのデータを返す
  # @param org_cd - 組織CD
  # @param sword - あいまい検索キーワード
  # @param user_cd - ユーザーCD
  # @return ユーザー情報
  #
  def self.get_user_relation_list(org_cd, sword, user_cd)

    sql = <<-SQL
      SELECT
        t1.*,
        t2.name_kana, t2.position_cd, t2.job_kbn, t2.authority_kbn, t2.joined_date, t2.memo,
        t3.org_cd, t3.belong_kbn,
        case
          when trim(t4.org_name4) != '' then t4.org_name4
          when trim(t4.org_name3) != '' then t4.org_name3
          when trim(t4.org_name2) != '' then t4.org_name2
          when trim(t4.org_name1) != '' then t4.org_name1
        end as org_name,
        t5.email_address1, t5.mobile_no, t5.mobile_address, t5.mobile_company, t5.mobile_kind
      FROM m_users t1,
           m_user_attributes t2,
           m_user_belongs t3,
           m_orgs t4,
           d_addresses t5
      WHERE
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t3.delf = 0
      AND
        t4.delf = 0
      AND
        t5.delf = 0
      AND
        t1.user_cd = t2.user_cd
      AND
        t1.user_cd = t3.user_cd
      AND
        t3.org_cd = t4.org_cd
      AND
        t1.user_cd = t5.user_cd
    SQL

    #組織CDが指定されている場合
    if org_cd != ""
      sql += <<-SQL
        AND
          t3.org_cd IN (#{org_cd})
      SQL
    end

    #あいまい検索キーワードが指定されている場合
    if sword != ""
      sql += <<-SQL
        AND
          (t1.user_cd like '%#{sword}%'
        OR
          t1.name like '%#{sword}%')
      SQL
    end

    #ユーザーCDが指定されている場合
    if user_cd != ""
      sql += <<-SQL
        AND
          t1.user_cd = '#{user_cd}'
      SQL
    end

    sql += <<-SQL
      ORDER BY
        t1.id,t1.user_cd
    SQL

    #SQL実行
    recs = find_by_sql(sql)

    return recs
  end

  #
  # 引数の社員コード,ログインIDに該当するデータを返す
  # 但し引数のid指定の場合は、id以外のデータで検索する
  #
  def self.duplicate_check_data(id, user_cd, login)

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_users t1
      WHERE
        t1.delf = 0
      AND
        (t1.user_cd = '#{user_cd}'
      OR
        t1.login = '#{login}')
    SQL

    if id != 0
      sql += <<-SQL
        AND
          t1.id != #{id}
      SQL
    end

    sql += <<-SQL
      LIMIT 1
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # ユーザーマスタ/ユーザ属性マスタ/ユーザ所属マスタの項目を初期化する
  # ※項目はget_user_relation_list()のSELECT項目に対応
  # @return ユーザー情報を初期化したリスト
  #
  def self.data_init()
    #ユーザーマスタ
    data = MUser.new
    #ユーザー属性マスタ
    data[:name_kana]=""
    data[:position_cd]=""
    data[:job_kbn]=""
    data[:authority_kbn]=""
    data[:joined_date]=""
    data[:memo]=""
    #ユーザー所属マスタ
    data[:org_cd]=""
    data[:org_name]=""
    data[:belong_kbn]=""
    #アドレス帳
    data[:email_address1]=""
    data[:mobile_no]=""
    data[:mobile_address]=""
    data[:mobile_company]=""
    data[:mobile_kind]=""
    #メールアカウント設定
    data[:imap_quota]=""

    return data
  end

  #
  # 指定された職位のユーザー一覧を取得する。
  #
  # @param org_cd - 組織コード
  # @param position_cd - 職位コード
  # @param keyword - ユーザー名またはCD
  # @return 指定職位のユーザー一覧
  #
  def self.get_user_list_by_position_and_keword org_cd, position_cd, keyword

    select_sql = ""
    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    select_sql += " m_users.*, d_addresses.email_address1 "
    joins_sql = " INNER JOIN m_user_attributes on m_user_attributes.user_cd = m_users.user_cd "
    joins_sql += " INNER JOIN m_positions on m_positions.position_cd = cast(m_user_attributes.position_cd as varchar) "
    joins_sql += " INNER JOIN m_user_belongs on m_user_belongs.user_cd = m_users.user_cd "
    joins_sql += " INNER JOIN d_addresses on d_addresses.user_cd =  m_users.user_cd"
    conditions_sql = " m_users.delf = :delf "
    conditions_sql += " AND m_user_attributes.delf = :delf "
    conditions_sql += " AND m_user_belongs.delf = :delf "
    conditions_sql += " AND m_positions.delf = :delf "
    conditions_sql += " AND d_addresses.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND m_user_belongs.belong_kbn = :belong_kbn "
    conditions_param[:belong_kbn] = 0
    unless position_cd.nil? or position_cd.empty?
      conditions_sql += " AND m_positions.position_cd = :position_cd "
      conditions_param[:position_cd] = position_cd
    end
    unless org_cd.nil? or org_cd.empty?
      conditions_sql += " AND m_user_belongs.org_cd = :org_cd"
      conditions_param[:org_cd] = org_cd
    end
    unless keyword.nil? or keyword.empty?
      conditions_sql += " AND (m_users.user_cd like :keyword OR m_users.name like :keyword)"
      conditions_param[:keyword] = "%" + keyword + "%"
    end
    order_sql = " m_user_attributes.sort_no, m_positions.sort_no, m_user_attributes.joined_date ASC "

    return MUser.find(:all, :select=>select_sql, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 特定の得意先の作業者として登録されているユーザーの一覧を取得する。
  #
  # @param company_cd - 得意先CD
  #
  def self.get_worker_list company_cd

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    joins_sql += " INNER JOIN m_workers on m_workers.user_cd = m_users.user_cd "
    joins_sql += " INNER JOIN m_customers on m_customers.company_cd = m_workers.company_cd "
    conditions_sql += " m_users.delf = :delf "
    conditions_sql += " AND m_workers.delf = :delf "
    conditions_sql += " AND m_customers.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND m_customers.company_cd = :company_cd "
    conditions_param[:company_cd] = company_cd
    order_sql += " m_users.user_cd ASC "

    return MUser.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  #
  #
  def self.register params

    unless params[:m_users].nil?

      m_user = find(:first, :conditions=>{:delf=>0, :user_cd=>params[:m_users][:user_cd]})
      if m_user.nil?
        m_user = MUser.new
      end
      m_user.user_cd = params[:m_users][:user_cd]
      unless params[:m_users][:name].nil?
        m_user.name = params[:m_users][:name]
      end
      unless params[:m_users][:admin_flg].nil?
        m_user.admin_flg = params[:m_users][:admin_flg]
      end
      unless params[:m_users][:email].nil?
        m_user.email = params[:m_users][:email]
      end
      unless params[:m_users][:passwd].nil?
        m_user.passwd = params[:m_users][:passwd]
      end
      unless params[:m_users][:crypted_password].nil?
        m_user.crypted_password = params[:m_users][:crypted_password]
      end
#      unless params[:m_users][:salt].nii?
#        m_user.salt = params[:m_users][:salt]
#      end
      unless params[:m_users][:remember_token_expires_at].nil?
        m_user.remember_token_expires_at = params[:m_users][:remember_token_expires_at]
      end
      unless params[:m_users][:lastlogin_at].nil?
        m_user.lastlogin_at = params[:m_users][:lastlogin_at]
      end
      unless params[:m_users][:last_change_password_at].nil?
        m_user.last_change_password_at = params[:m_users][:last_change_password_at]
      end

      begin
        m_user.save!
        MUserAttribute.register params
        MUserBelong.register params
      rescue
        p $!
        raise
      end
    end
  end

end
