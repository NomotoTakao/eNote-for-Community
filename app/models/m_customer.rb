class MCustomer < ActiveRecord::Base

  #
  # 引数に渡されたキーワードを、得意先CDまたは得意先名に含む得意先の一覧を取得する。
  #
  # @param keyword - キーワード
  #
  def self.find_by_keyword keyword

    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    conditions_sql += " m_customers.delf = :delf"
    conditions_param[:delf] = 0
    unless keyword.nil?
      conditions_sql += " AND (m_customers.company_cd like :keyword OR m_customers.name like :keyword)"
      conditions_param[:keyword] = "%" + keyword + "%"
    end
    order_sql += " m_customers.sort_no ASC"

    MCustomer.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 得意先の一覧を取得する。
  #
  # @param params - 検索パラメータのハッシュテーブル
  #
  def self.customer_list params

    org_cd = params[:org_cd]
    user_cd = params[:user_cd]
    company_cd = params[:company_cd]
    check_deleted = params[:check_deleted]
    customer_name = params[:customer_name]
    customer_name_kana = params[:customer_name_kana]
    tel = params[:tel]

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    if check_deleted.nil? or check_deleted.empty? or check_deleted == "false"
      conditions_sql += " m_customers.delf = :delf"
      conditions_param[:delf] = 0
    end

    unless user_cd.nil? or user_cd.empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end
      joins_sql += " INNER JOIN m_workers on m_workers.company_cd = m_customers.company_cd "
      conditions_sql += " m_workers.delf = :delf"
      conditions_param[:delf] = 0
      conditions_sql += " AND m_workers.user_cd = :user_cd "
      conditions_param[:user_cd] = user_cd
    end

    unless company_cd.nil? or company_cd.empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end

      conditions_sql += " m_customers.company_cd like :company_cd"
      conditions_param[:company_cd] = "%" + company_cd + "%"
    end

    unless customer_name.nil? or customer_name.empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end

      conditions_sql += " (m_customers.name like :customer_name OR m_customers.short_name like :customer_name)"
      conditions_param[:customer_name] = "%" + customer_name + "%"
    end

    unless customer_name_kana.nil? or customer_name_kana.empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end

      conditions_sql += " (m_customers.kana like :kana OR m_customers.short_kana like :kana)"
      conditions_param[:kana] = "%" + customer_name_kana + "%"
    end

    unless tel.nil? or tel.empty?
      unless conditions_sql.empty?
        conditions_sql += " AND "
      end

      conditions_sql += " (m_customers.tel1 like :tel OR m_customers.tel2 like :tel)"
      conditions_param[:tel] = "%" + tel + "%"
    end

    order_sql = " m_customers.company_cd ASC"

    MCustomer.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # アサインしているプロジェクトの得意先一覧を取得する。
  #
  # @param user_cd - ユーザーCD
  #
  def self.get_customer_list user_cd

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    joins_sql += " INNER JOIN m_workers on m_workers.company_cd = m_customers.company_cd "
    joins_sql += " INNER JOIN m_users on m_users.user_cd = m_workers.user_cd "
    conditions_sql += " m_customers.delf = :delf"
    conditions_sql += " AND m_workers.delf = :delf "
    conditions_sql += " AND m_users.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND m_users.user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd
    order_sql += "m_customers.sort_no ASC "

    return MCustomer.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  #
  #
  #
  #
  def self.register params, user_cd

    id = params[:customer_id]
    if id.nil? or id.empty?
      m_customer = MCustomer.new
    else
      m_customer = MCustomer.find(:first, :conditions=>{:delf=>0, :id=>id})
    end

    if m_customer.nil?
      m_customer = MCustomer.new
      m_customer.created_user_cd = user_cd
    end

    m_customer.company_cd          = params[:company_cd]
    m_customer.name                = params[:name]
    m_customer.kana                = params[:kana]
    m_customer.short_name          = params[:short_name]
    m_customer.president_name      = params[:president_name]
    m_customer.tanto_name          = params[:tanto_name]
    m_customer.number_of_employees = params[:number_of_employees]
    m_customer.zip_cd              = params[:zip_cd]
    m_customer.address1            = params[:address1]
    m_customer.tel1                = params[:tel1]
    m_customer.tel2                = params[:tel2]
    m_customer.fax                 = params[:fax]
    m_customer.mail_address        = params[:mail_address]
    m_customer.url                 = params[:url]
    m_customer.nensyo              = params[:nensyo]
    m_customer.keijo               = params[:keijo]
    m_customer.sales               = params[:sales]
    m_customer.arari               = params[:arari]
    m_customer.yoshin              = params[:yoshin]
    m_customer.memo                = params[:memo]


    begin
      m_customer.updated_user_cd = user_cd
      m_customer.save

      # 作業対応者の登録・削除
      MWorker.register params, user_cd
    rescue
      p $!
      raise
    end
  end
end
