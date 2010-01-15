class Report::MainController < ApplicationController
  layout "portal", :except=>[:input_tab, :search_tab, :comment_tab, :report_tab, :summary_tab, :customer_list, :tmp_list, :summary_comment, :get_next_unconfirmed_date,
                   :detail_list, :register_report, :delete_report, :report_list, :search_list, :comment_list, :action_list, :register_superior_comment,
                   :setting_tab, :setting_admin, :setting_superior, :user_tree, :selected_tree, :edit_report, :get_superior]

  skip_before_filter :verify_authenticity_token, :register_report, :register_summary

  #
  # 日報画面を表示する時のアクション
  #
  def index
    @pankuzu += "日報"
    # ログインユーザーがだれの上司でもない場合は、「上司確認コメント」のタブは表示しない。
    @subordinate_count = MSuperior.find(:all, :conditions=>{:delf=>'0', :superior_user_cd=>current_m_user.user_cd}).length;
  end

  #
  # 「日報入力」タブを表示する時のアクション
  #
  def input_tab

  end

  #
  # 「日報検索」タブを表示する時のアクション
  #
  def search_tab

    @customer_list = MCustomer.get_customer_list current_m_user.user_cd
    @action_target_list = MActionTarget.find(:all, :conditions=>{:delf=>'0'}, :order=>:sort_no)
    @action_group_list = MActionGroup.find(:all, :conditions=>{:delf=>'0'}, :order=>:sort_no)

    #
    @org_list = MOrg.find(:all, :conditions=>{:delf=>0, :org_lvl=>1}, :order=>:org_cd)
  end

  #
  # [上司確認コメント」タブを表示する時のアクション
  #
  def comment_tab
    @subordinate_list = MSuperior.find(:all, :conditions=>{:delf=>'0', :superior_user_cd=>current_m_user.user_cd}, :order=>"user_cd ASC")
  end

  #
  # 活動内容のタブを表示するアクション
  #
  def report_tab
    # リストの内容を取得
    @customer_list = MCustomer.get_customer_list current_m_user.user_cd
    @action_target_list = MActionTarget.find(:all, :conditions=>{:delf=>'0'}, :order=>:sort_no)
    @action_group_list = MActionGroup.find(:all, :conditions=>{:delf=>'0'}, :order=>:sort_no)
  end

  #
  # 総括コメントのタブを表示するアクション
  #
  def summary_tab

  end

  #
  # 日報を登録するアクション
  #
  def register_report

    d_report = DReport.find(:first, :conditions=>{:delf=>0, :user_cd=>current_m_user.user_cd, :action_date=>params[:date]})

    if d_report.nil?
      d_report = DReport.new
      d_report.user_cd = current_m_user.user_cd
      d_report.action_date = params[:date]
      d_report.created_user_cd = current_m_user.user_cd
      d_report.updated_user_cd = current_m_user.user_cd
    end

    begin
      d_report.updated_user_cd = current_m_user.user_cd
      d_report.save

      d_report_customer = nil
      d_report.d_report_customers.each do |report_customer|
        if report_customer.id.to_s == params[:id]
          d_report_customer = report_customer
        end
      end

      if d_report_customer.nil?
        d_report_customer = DReportCustomer.new
        d_report_customer.created_user_cd = current_m_user.user_cd
      end

      d_report_customer.d_report_id = d_report.id
      d_report_customer.company_cd = params[:c]
      d_report_customer.action_target_cd = params[:t]
      d_report_customer.action_group_cd = params[:a]
      d_report_customer.action_cd = params[:d]
      d_report_customer.comment = params[:cmt]
      d_report_customer.action_time = params[:time]
      d_report_customer.sale_amount = params[:sales]
      d_report_customer.updated_user_cd = current_m_user.user_cd

      begin
        d_report_customer.save
      rescue
        p $!
      end
    rescue
      p $!
    end

    redirect_to :action=>:report_tab
  end

  #
  # 日報を削除するアクション
  #
  def delete_report
    ids = params[:ids]
    unless ids.nil? or ids.empty?
      id_array = ids.split(",")
      id_array.each do |id|
        d_report_customer = DReportCustomer.find(:first, :conditions=>{:delf=>0, :id=>id})
        unless d_report_customer.nil?
          d_report_customer.delf = '1'
          begin
            d_report_customer.save
          rescue
            p $!
          end
        end
      end
    end

    redirect_to :action=>:report_list
  end

  #
  # 総括コメントを登録する時のアクション
  #
  def register_summary

    comment = params[:cmt]
    superior_comment = params[:s_cmt]
    action_date = params[:d]

    d_report = DReport.find(:first, :conditions=>{:delf=>0, :action_date=>action_date})
    if d_report.nil?
      d_report = DReport.new
      d_report.user_cd = current_m_user.user_cd
      d_report.action_date = action_date
      d_report.created_user_cd = current_m_user.user_cd
    end
    d_report.comment = comment
    d_report.superior_comment = superior_comment
    d_report.updated_user_cd = current_m_user.user_cd

    begin
      d_report.save
    rescue
      p $!
    end

    redirect_to :action=>:summary_tab
  end

  #
  # 「日報入力」タブの一覧を取得するアクション
  #
  def report_list

    date = params[:date]

    conditions_sql = ""
    conditions_param = Hash.new

    conditions_sql += " d_reports.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND d_reports.action_date = :action_date"
    conditions_param[:action_date] = date
    conditions_sql += " AND d_reports.user_cd = :user_cd"
    conditions_param[:user_cd] = current_m_user.user_cd

    @d_report = DReport.find(:first, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # 「日報検索」タブの一覧を取得するアクション
  #
  def search_list
    # 列ソートのときに、検索条件を画面から拾うので、インスタンス変数で画面に送り、hidden項目として画面に持たせる。
    @org_cd = params[:org_cd]
    @user_cd = params[:user_cd]
    @date_from = params[:date_from]
    @date_to = params[:date_to]
    @comment = params[:comment]
    @action_target_cd = params[:target_cd]
    @action_group_cd = params[:group_cd]
    @action_cd = params[:action_cd]


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
      @current_order = "d_reports.action_date ASC, d_reports.user_cd ASC, d_report_customers.company_cd ASC"
    end
    @search_list = DReportCustomer.get_search_list(params, @current_order)
  end

  #
  # 「上司確認コメtント」タブの一覧を取得するアクション
  #
  def comment_list
    @superior_user_cd = current_m_user.user_cd
    @subordinate_user_cd = params[:person]

    @d_report = DReport.get_comment_list current_m_user.user_cd, params
    @next_unconfirmed_report = DReport.get_next_unconfirmed_date params[:date], params[:person]
  end

  #
  # 活動詳細の一覧を取得するアクション
  #
  def action_list

    action_group_cd = params[:action_group_cd]
    @action_list = MAction.find(:all, :conditions=>{:delf=>0, :action_group_cd=>action_group_cd}, :order=>:sort_no)
  end

  #
  # 上司確認コメントを登録するアクション
  #
  def register_superior_comment

    action_date = params[:date]
    user_cd = params[:p]
    superior_comment = params[:cmt]

    d_report = DReport.find(:first, :conditions=>{:delf=>0, :user_cd=>user_cd, :action_date=>action_date})
    unless d_report.nil?
      d_report.superior_user_cd = current_m_user.user_cd
      d_report.confirm_date = Date.today
      d_report.superior_comment = superior_comment
      d_report.updated_user_cd = current_m_user.user_cd
      begin
        d_report.save
      rescue
        p $!
      end
    end

    redirect_to :action=>:comment_tab
  end

  #
  #
  #
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
    if params[:caller] == "superior"
      render :action=>:tmp_list2
    end
  end

  #
  #
  #
  def output_csv

    date_from = params[:date_from]
    date_to   = params[:date_to]
    comment   = params[:comment]
    action_target_cd = params[:target_cd]
    action_group_cd = params[:group_cd]
    action_cd = params[:action_cd]

    csv_data = DReportCustomer.get_search_list(params)

    buf = "日付,社員CD,社員名,得意先CD,得意先名,得意先対象者CD,得意先対象者名,活動分類CD,活動分類名,活動詳細CD,活動詳細名,活動時間,売上金額,コメント" + "\r\n"
    csv_data.each do |d_report_customer|
      buf += d_report_customer.d_report.action_date.to_s + ","
      buf += d_report_customer.d_report.user_cd.to_s + ","
      buf += ","
      buf += d_report_customer.company_cd.to_s + ","
      buf += ","
      buf += d_report_customer.action_target_cd.to_s + ","
      buf += ","
      buf += d_report_customer.action_group_cd.to_s + ","
      buf += ","
      buf += d_report_customer.action_cd.to_s + ","
      buf += ","
      buf += d_report_customer.action_time.to_s + ","
      buf += d_report_customer.sale_amount.to_s + ","
      buf += d_report_customer.comment.to_s + "\r\n"
    end

    require 'kconv'
    send_data buf.tosjis, :filename => 'act.csv', :type => 'text/csv ;charset = Shift_JIS'
  end

  #
  #
  #
  def summary_comment

    date = params[:date]
    @d_report = DReport.find(:first, :conditions=>{:delf=>0, :action_date=>date})
  end

  #
  # 次の未読日報を取得するアクション
  #
  def get_next_unconfirmed_date
    date = params[:date]
    user_cd = params[:user_cd]

    @d_report = DReport.get_next_unconfirmed_date date, user_cd
  end

  #
  # 日報の設定タブを表示するアクション
  #
  def setting_tab

  end

  #
  # 日報の設定画面を表示するアクション
  #
  def setting_superior
    @org_list = MOrg.find(:all, :conditions=>{:delf=>0, :org_lvl=>1}, :order=>:org_cd)
  end


  #
  # 日報入力者と確認者の組み合わせを登録するアクション
  #
  def register_superior

    superior_cd = params[:user_cd]
    user_cd = current_m_user.user_cd

    m_superior = MSuperior.find(:first, :conditions=>{:delf=>0, :user_cd=>user_cd})
    if m_superior.nil?
      m_superior = MSuperior.new
      m_superior.user_cd = user_cd
      m_superior.created_user_cd = user_cd
    end
    m_superior.superior_user_cd = superior_cd
    m_superior.updated_user_cd = user_cd

    begin
      m_superior.save!
    rescue
      p $!
      raise
    end

    redirect_to :action=>:setting_superior
  end

  #
  #
  #
  def edit_report
    id = params[:id]
    @d_report_customer = DReportCustomer.find(:first, :conditions=>{:delf=>0, :id=>id})

    @customer_list = MCustomer.get_customer_list current_m_user.user_cd
    @action_target_list = MActionTarget.find(:all, :conditions=>{:delf=>'0'}, :order=>:sort_no)
    @action_group_list = MActionGroup.find(:all, :conditions=>{:delf=>'0'}, :order=>:sort_no)
  end

  #
  # ログインユーザーに設定されている上司を取得するアクション
  #
  def get_superior
    @superior = MSuperior.find(:first, :conditions=>{:delf=>0, :user_cd=>current_m_user.user_cd})
    if @superior.nil?
      @superior = MSuperior.new
    end
  end
end
