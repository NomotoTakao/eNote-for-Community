class DReportCustomer < ActiveRecord::Base
  belongs_to :d_report

  #
  # 日報検索画面の一覧を取得するメソッド
  #
  def self.get_search_list params, order_sql

    user_cd = params[:user_cd]
    org_cd = params[:org_cd]
    company_cd = params[:company_cd]
    date_from = params[:date_from]
    date_to = params[:date_to]
    comment = params[:comment]
    action_target_cd = params[:target_cd]
    action_group_cd = params[:group_cd]
    action_cd = params[:action_cd]

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
#    order_sql = ""

    joins_sql = " INNER JOIN d_reports on d_reports.id = d_report_customers.d_report_id"
    joins_sql += " INNER JOIN m_users on m_users.user_cd = d_reports.user_cd "
    joins_sql += " INNER JOIN m_user_belongs on m_user_belongs.user_cd = m_users.user_cd"

    conditions_sql += " d_reports.delf = :delf"
    conditions_sql += " AND d_report_customers.delf = :delf"
    conditions_sql += " AND m_users.delf = :delf"
    conditions_sql += " AND m_user_belongs.delf = :delf"
    conditions_param[:delf] = 0

    conditions_sql += " AND m_user_belongs.belong_kbn = :belong_kbn"
    conditions_param[:belong_kbn] = 0

    unless date_from.nil? or date_from.empty?
      conditions_sql += " AND d_reports.action_date >= :date_from"
      conditions_param[:date_from] = date_from
    end

    unless date_to.nil? or date_to.empty?
      conditions_sql += " AND d_reports.action_date <= :date_to"
      conditions_param[:date_to] = date_to
    end

    unless company_cd.nil? or company_cd.empty?
      conditions_sql += " AND d_report_customers.company_cd = :company_cd"
      conditions_param[:company_cd] = company_cd
    end

    unless comment.nil? or comment.empty?
      conditions_sql += " AND d_report_customers.comment like :comment"
      conditions_param[:comment] = "%" + comment + "%"
    end

    unless action_target_cd.nil? or action_target_cd.empty?
      conditions_sql += " AND d_report_customers.action_target_cd = :action_target_cd"
      conditions_param[:action_target_cd] = action_target_cd
    end

    unless action_group_cd.nil? or action_group_cd.empty?
      conditions_sql += " AND d_report_customers.action_group_cd = :action_group_cd"
      conditions_param[:action_group_cd] = action_group_cd
    end

    unless action_cd.nil? or action_cd.empty?
      conditions_sql += " AND d_report_customers.action_cd = :action_cd"
      conditions_param[:action_cd] = action_cd
    end

    unless user_cd.nil? or user_cd.empty?
      conditions_sql += " AND d_reports.user_cd = :user_cd"
      conditions_param[:user_cd] = user_cd
    end

    unless org_cd.nil? or org_cd.empty?
      conditions_sql += " AND SUBSTR(m_user_belongs.org_cd, 1, LENGTH(:org_cd)) = :org_cd"
      conditions_param[:org_cd] = org_cd
    end

    return DReportCustomer.find(:all, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

end
