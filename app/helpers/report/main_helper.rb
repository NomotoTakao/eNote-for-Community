module Report::MainHelper

  #
  # 得意先コードを得意先名に変換するヘルパメソッド
  #
  def customer_name company_cd
    result = ""

    m_customer = MCustomer.find(:first, :conditions=>{:company_cd=>company_cd, :delf=>0})
    unless m_customer.nil?
      result = m_customer.name
    end

    return result
  end

  #
  # 対象者IDを対象者名に変換するヘルパメソッド
  #
  def action_target_name action_target_cd
    result = ""

    m_action_target = MActionTarget.find(:first, :conditions=>{:delf=>0, :action_target_cd=>action_target_cd})
    unless m_action_target.nil?
      result = m_action_target.action_target_name
    end

    return result
  end

  #
  # 活動分類IDを対象分類名に変換するヘルパメソッド
  #
  def action_group_name action_group_cd
    result = ""

    m_action_group = MActionGroup.find(:first, :conditions=>{:delf=>0, :action_group_cd=>action_group_cd})
    unless m_action_group.nil?
      result = m_action_group.action_group_name
    end

    return result
  end

  #
  # 活動詳細IDを活動詳細名に変換するヘルパメソッド
  #
  def action_name action_cd
    result = ""

    m_action = MAction.find(:first, :conditions=>{:delf=>0, :action_cd=>action_cd})
    unless m_action.nil?
      result = m_action.action_name
    end

    return result
  end

  def time_helper time

    return time
  end

  def sales_helper sales

    return sales
  end

  def user_name user_cd
    result = ""

    m_user = MUser.find(:first, :conditions=>{:delf=>0, :user_cd=>user_cd})
    unless m_user.nil?
      result = m_user.name
    else
      result = user_cd
    end

    return result
  end

  def report_date(indate)
    result = ""
    if indate.nil?
      result =  '---'
    else
      w_date = indate
      result = w_date.strftime('%m月%d日').to_s
    end

    return result
  end
end
