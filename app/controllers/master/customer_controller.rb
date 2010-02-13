class Master::CustomerController < ApplicationController
  layout "portal",
  :except=>[:customer_list, :customer_info, :customer_register, :register, :delete, :search_tab, :register_tab, :customer_employee_register, :select_day_birthday, :register_staff,
            :info_tab, :reference_tab, :staff_tab, :search_index, :edit_index, :customer_edit, :staff_list, :action_list, :activity_reference_list, :tmp_list,
            :basic_info_tab, :basic_info, :activity_reference_tab, :activity_reference, :customer_employee_tab, :customer_employee_list, :customer_employee]

  skip_before_filter :verify_authenticity_token

  def index
    @pankuzu += "得意先設定"
    @org_list = MOrg.find(:all, :conditions=>{:delf=>0, :org_lvl=>1}, :order=>:org_cd)
  end


  def search_index

  end

  def edit_index
    @company_cd = params[:company_cd]
    # 一覧では、削除済みの得意先も検索されるので、この時点では検索条件に削除フラグを入れない。
    @m_customer = MCustomer.find(:first, :conditions=>{:company_cd=>params[:company_cd]});
#    @company_name = m_customer.name
  end

  #
  # 得意先一覧を検索するアクション
  #
  def customer_list

    @org_cd = params[:org_cd]
    @user_cd = params[:user_cd]
    @company_cd = params[:company_cd]
    @check_deleted = params[:check_deleted]
    @customer_name = params[:customer_name]
    @customer_name_kana = params[:customer_name_kana]
    @tel = params[:tel]

    @customer_list = MCustomer.customer_list params
  end

  def customer_info

    company_cd = params[:company_cd]
    @edit_flg = params[:edit_flg]

    unless company_cd.nil? or company_cd.empty?
      # 一覧では削除済みの得意先が検索されることもあるので、ここでは検索条件に削除フラグは入れない。
      @m_customer = MCustomer.find(:first, :conditions=>{:company_cd=>company_cd})
      @worker_list = MUser.get_worker_list company_cd
    else
      @m_customer = MCustomer.new
    end

  end

  #
  # 得意先編集画面を表示するアクション
  #
  def customer_register

    company_cd = params[:company_cd]
    @staff_list = MUser.find(:all, :conditions=>{:delf=>0}, :order=>"user_cd ASC")

    unless company_cd.nil? or company_cd.empty?
      @m_customer = MCustomer.find(:first, :conditions=>{:delf=>0, :company_cd=>company_cd})
    else
      @m_customer = MCustomer.new
    end
  end

  #
  # 得意先の追加・編集をおこなうアクション
  #
  def register

    MCustomer.register params, current_m_user.user_cd

    redirect_to :action=>:index
  end

  #
  # 得意先を削除するアクション
  #
  def delete

    id = params[:id]
    unless id.nil? or id.empty?
      m_customer = MCustomer.find(:first, :conditions=>{:delf=>0, :id=>id})
      unless m_customer.nil?
        m_customer.delf = 1
        begin
          m_customer.deleted_user_cd = current_m_user.user_cd
          m_customer.deleted_at = Time.now
          m_customer.save
        rescue
          p $!
        end
      end
    end

    redirect_to :action=>:index
  end

  def search_tab

    @org_list = MOrg.find(:all, :conditions=>{:delf=>0, :org_lvl=>1}, :order=>:org_cd)
  end

  def edit_tab

  end

  def into_tab

  end

  #
  # 得意先に関数する情報を表示するタブ
  #
  def basic_info_tab
#p "★basic_info_tab"#DEBUG
  end

  #
  # 得意先基本情報を表示するアクション
  #
  def basic_info
    company_cd = params[:company_cd]
    @edit_flg = params[:edit_flg]

    unless company_cd.nil? or company_cd.empty?
      @m_customer = MCustomer.find(:first, :conditions=>{:delf=>0, :company_cd=>company_cd})
    end
    if @m_customer.nil?
      @m_customer = MCustomer.new
    end

    @worker_list = MWorker.find(:all, :conditions=>{:delf=>0, :company_cd=>company_cd}, :order=>" user_cd ASC")
    worker_cd = ""
    unless @worker_list.nil?
      @worker_list.each do |worker|
        unless worker_cd.empty?
          worker_cd += ","
        end
        worker_cd += "'" + worker.user_cd + "'"
      end
    end

    conditions_sql = ""
    conditions_param = Hash.new
    conditions_sql = "delf = :delf"
    conditions_param[:delf] = 0
    unless worker_cd.empty?
      conditions_sql += " AND user_cd NOT IN (:worker_cd)"
      conditions_sql.gsub!(":worker_cd", worker_cd)
    end
    @user_list = MUser.find(:all, :conditions=>[conditions_sql, conditions_param], :order=>" user_cd ASC")
  end

  def activity_reference_tab
  end

  def activity_reference
    @action_target_list = MActionTarget.find(:all, :conditions=>{:delf=>0}, :order=>"action_target_cd ASC")
    @action_group_list = MActionGroup.find(:all, :conditions=>{:delf=>0}, :order=>"action_group_cd ASC")
  end

  def customer_employee_tab
  end

  def customer_employee
  end

  #
  # 得意先に関する活動内容を参照するタブ
  #
  def reference_tab

    @action_target_list = MActionTarget.find(:all, :conditions=>{:delf=>0}, :order=>"action_target_cd ASC")
    @action_group_list = MActionGroup.find(:all, :conditions=>{:delf=>0}, :order=>"action_group_cd ASC")
  end


  def activity_reference_list

    date_from = params[:date_from]
    date_to = params[:date_to]
    comment = params[:comment]
    action_target_cd = params[:target_cd]
    action_group_cd = params[:group_cd]
    action_cd = params[:action_cd]

    # 一覧の昇順/降順に関しては、画面に前回の情報を渡すため、controllerに処理を記述している。
    # モデルで処理すると、インスタンス変数でViewに渡せない。
    # 現在のソート順を取得
    current_order = params[:current_order]
    order = params[:order]
    unless order.nil? or order.empty?
      # ","で分割
      array_current_order = current_order.split(",")
      # params[:order]で取得した列を配列の先頭に移動する。
      array_next_order = Array.new
      for current in array_current_order do
        # params[:order]で取得した列の昇順/降順を入れ替える。
        if current.include? order
          if current.include? "ASC"
            current.gsub!("ASC", "").strip!
            current += " DESC"
          else
            if current.include? "DESC"
              current.gsub!("DESC", "").strip!
            end
            current += " ASC"
          end
          @current_order = current
        else
          array_next_order << current
        end
      end
      unless array_next_order.length == 0
        @current_order = @current_order
        array_next_order.each do |n|
          @current_order += "," + n
        end
      end
    else
      @current_order = "d_reports.action_date ASC, d_reports.user_cd ASC"
    end

    @activity_reference_list = DReportCustomer.get_search_list(params, @current_order)
  end

  #
  # 得意先社員の情報を表示するタブ
  #
  def staff_tab

  end

  #
  # 得意先社員一覧を取得するアクション
  #
  def customer_employee_list

    company_cd = params[:company_cd]

    @customer_employee_list = DAddress.get_employee_list company_cd
  end


  #
  # 得意先編集画面を表示するアクション
  #
  def customer_edit

    company_cd = params[:company_cd]
    @staff_list = MUser.find(:all, :conditions=>{:delf=>0}, :order=>"user_cd ASC")

    unless company_cd.nil? or company_cd.empty?
      @m_customer = MCustomer.find(:first, :conditions=>{:delf=>0, :company_cd=>company_cd})
    else
      @m_customer = MCustomer.new
    end
  end

  def action_list

    action_group_cd = params[:action_group_cd]

    @action_list = MAction.find(:all, :conditions=>{:delf=>0, :action_group_cd=>action_group_cd}, :order=>" action_cd ASC")
  end

  def customer_employee_register

    id = params[:id]
    unless id.nil?
      @d_address = DAddress.find(:first, :conditions=>{:delf=>0, :id=>id})
    else
      @d_address = DAddress.new
    end

    @m_customer = MCustomer.find(:first, :conditions=>{:delf=>0, :company_cd=>params[:company_cd]})
  end

  def select_day_birthday

    year = params[:year]
    month = params[:month]

    @current_day = Date.today.day
    # 現在月１日の日付オブジェクトを取得
    date = Date.new(year.to_i, month.to_i, 1)
    # 翌月1日の日付オブジェクトを取得

    date = date >> 1
    # 翌月1日の日付オブジェクトの前日は当月の最終日
    date = date - 1
    @current_month_last_day = date.day
  end

  def tmp_list

    org_lvl = params[:org_lvl]
    org_cd = params[:org_cd]

    @user_list = MUser.new.get_user_list_by_org_cd org_cd

    select_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    if org_lvl == "1"
      select_sql += " org_lvl, org_cd, org_name2 as org_name"
    elsif org_lvl == "2"
      select_sql += " org_lvl, org_cd, org_name3 as org_name"
    elsif org_lvl == "3"
      select_sql += " org_lvl, org_cd, org_name4 as org_name"
    end

    conditions_sql += " m_orgs.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND m_orgs.org_lvl = :org_lvl"
    conditions_param[:org_lvl] = org_lvl.to_i + 1
    conditions_sql += " AND m_orgs.org_cd like :org_cd"
    conditions_param[:org_cd] = org_cd + "%"
    order_sql += " m_orgs.org_cd ASC"

    @tmp_list = MOrg.find(:all, :select=>select_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)

  end

  #
  # 得意先社員の登録をおこなう
  #
  def register_employee

    begin
      DAddress.register params, current_m_user.user_cd
    rescue
      p $!
      raise
    end

    redirect_to :action=>"customer_employee_register", :company_cd=>params[:company_cd]
  end

end
