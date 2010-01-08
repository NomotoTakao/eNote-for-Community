class DReport < ActiveRecord::Base
  has_many :d_report_customers, :conditions=>"delf=0"

  #
  # 日報確認画面の一覧を取得するためのメソッド
  #
  def self.get_comment_list superior_user_cd, params

    subordinate_user_cd = params[:person]
    action_date = params[:date]

    joins_sql = ""
    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    joins_sql += " INNER JOIN m_superiors on m_superiors.user_cd = d_reports.user_cd"

    conditions_sql += " d_reports.delf = :delf"
    conditions_sql += " AND m_superiors.delf = :delf"
    conditions_param[:delf] = '0'
    conditions_sql += " AND d_reports.action_date = :action_date"
    conditions_param[:action_date] = action_date
    conditions_sql += " AND d_reports.user_cd = :user_cd"
    conditions_param[:user_cd] = subordinate_user_cd
    conditions_sql += " AND m_superiors.superior_user_cd = :superior_user_cd"
    conditions_param[:superior_user_cd] = superior_user_cd

    order_sql = "d_reports.action_date DESC"

    return DReport.find(:first, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

  #
  # 引数に渡された日付以降で、日報確認をしていない最初の日付を取得する。
  #
  # @param date -　現在表示されている日付
  # @param user_cd - 日報の提出者のユーザーCD
  #
  def self.get_next_unconfirmed_date date, user_cd

    conditions_sql = ""
    conditions_param = Hash.new
    order_sql = ""

    conditions_sql = " d_reports.delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND d_reports.user_cd = :user_cd"
    conditions_param[:user_cd] = user_cd
    conditions_sql += " AND d_reports.action_date > :action_date"
    conditions_param[:action_date] = date
    conditions_sql += " AND confirm_date IS NULL"

    order_sql = " d_reports.action_date ASC"

    DReport.find(:first, :conditions=>[conditions_sql, conditions_param], :order=>order_sql)
  end

end
