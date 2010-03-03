class Master::ReportController < ApplicationController
  layout "portal", :except => [:action_group_list, :action_list, :input_action_group, :input_action,
                               :action_group_add, :action_group_update, :action_group_delete,
                               :action_add, :action_update, :action_delete,
                               :action_group_cd_auto_number, :action_cd_auto_number,
                               :action_group_exists, :action_exists]
  skip_before_filter :verify_authenticity_token, :action_group_add, :action_group_update, :action_group_delete, :action_add, :action_update, :action_delete

  #
  # 日報設定のTOP画面を表示するアクション
  #
  def index
    @pankuzu += "活動内容マスタ"
  end

  #
  # 活動内容グループの一覧を取得するアクション
  #
  def action_group_list
    @m_action_groups = MActionGroup.find(:all, :conditions=>{:delf=>0}, :order=>:action_group_cd)
  end

  #
  # 活動内容詳細の一覧を取得するアクション
  #
  def action_list
    action_group_cd = params[:action_group_cd]
    @m_actions = MAction.find(:all, :conditions=>{:delf=>0, :action_group_cd=>action_group_cd}, :order=>:action_cd)
  end

  #
  # 活動内容グループの入力フォームを表示するアクション
  #
  def input_action_group
    action_group_cd = params[:action_group_cd]
    unless action_group_cd.nil?
      @m_action_groups = MActionGroup.find(:first, :conditions=>{:delf=>0, :action_group_cd=>action_group_cd})
    else
      @m_action_groups = MActionGroup.new
    end
  end

  #
  # 登録しようとしている活動内容グループが存在しているかを確認するアクション
  #
  def action_group_exists
    m_action_group = MActionGroup.find(:first, :conditions=>{:delf=>0, :action_group_cd=>params[:action_group_cd]})
    unless m_action_group.nil?
      @msg = "指定された活動内容グループCDは既に登録されています。"
    end
  end

  #
  # 活動内容グループフォームの「追加」ボタンが押下されたときのアクション
  #
  def action_group_add
    MActionGroup.create_action_group params, current_m_user.user_cd
    redirect_to :action=>:action_group_list
  end

  #
  # 活動内容グループフォームの「更新」ボタンが押下された時のアクション
  #
  def action_group_update
    MActionGroup.update_action_group params, current_m_user.user_cd
    redirect_to :action=>:action_group_list
  end

  #
  # 活動内容グループフォームの「削除」ボタンが押下されたときのアクション
  #
  def action_group_delete
    MActionGroup.delete_action_group params, current_m_user.user_cd
    redirect_to :action=>:action_group_list
  end

  #
  # 活動内容の入力フォームを表示するアクション
  #
  def input_action
    action_group_cd = params[:action_group_cd]
    action_cd = params[:action_cd]
    unless action_group_cd.nil? or action_cd.nil?
      @m_actions = MAction.find(:first, :conditions=>{:delf=>0, :action_group_cd=>action_group_cd, :action_cd=>action_cd})
    else
      @m_actions = MAction.new
    end
  end

  #
  #　入力フォームに入力された活動内容CDが既に登録されていないかを調べるアクション
  #
  def action_exists
    m_action = MAction.find(:first, :conditions=>{:delf=>0, :action_group_cd=>params[:action_group_cd], :action_cd=>params[:action_cd]})
    unless m_action.nil?
      @msg = "指定された活動内容CDは既に登録されています。"
    end
  end

  #
  # 活動内容詳細を追加するアクション
  #
  def action_add
    m_action = MAction.find(:first, :conditions=>{:delf=>0, :action_group_cd=>params[:action_group_cd], :action_cd=>params[:action_cd]})
    if m_action.nil?
      MAction.create_action params, current_m_user.user_cd
    end
    redirect_to :action=>:action_list, :action_group_cd=>params[:action_group_cd]
  end

  #
  # 活動内容詳細を更新するアクション
  #
  def action_update
    MAction.update_action params, current_m_user.user_cd
    redirect_to :action=>:action_list, :action_group_cd=>params[:action_group_cd]
  end

  #
  # 活動内容詳細を削除するアクション
  #
  def action_delete
    MAction.delete_action params, current_m_user.user_cd
    redirect_to :action=>:action_list, :action_group_cd=>params[:action_group_cd]
  end

  #
  # 活動内容グループCDを自動採番するアクション
  #
  def action_group_cd_auto_number
    @next_action_group_cd = MActionGroup.get_space_action_group_cd
  end

  #
  # 活動内容詳細CDを自動採番するアクション
  #
  def action_cd_auto_number
    @next_action_cd = MAction.get_space_action_cd params[:action_group_cd]
  end
end
