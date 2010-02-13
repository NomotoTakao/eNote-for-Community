class Master::ReportController < ApplicationController
  layout "portal", :except => [:action_group_list, :action_list, :input_action_group, :input_action,
                               :action_group_add, :action_group_update, :action_group_delete,
                               :action_add, :action_update, :action_delete]
skip_before_filter :verify_authenticity_token, :action_group_add, :action_group_update, :action_group_delete, :action_add, :action_update, :action_delete
  def index
    @pankuzu += "日報設定"
  end

  def action_group_list
    @m_action_groups = MActionGroup.find(:all, :conditions=>{:delf=>0}, :order=>:action_group_cd)
  end

  def action_list
    action_group_cd = params[:action_group_cd]
    @m_actions = MAction.find(:all, :conditions=>{:delf=>0, :action_group_cd=>action_group_cd}, :order=>:action_cd)
  end

  #
  #
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
  #
  #
  def action_group_add
    MActionGroup.create_action_group params, current_m_user.user_cd

    redirect_to :action=>:action_group_list
  end

  #
  #
  #
  def action_group_update
    MActionGroup.update_action_group params, current_m_user.user_cd

    redirect_to :action=>:action_group_list
  end

  #
  #
  #
  def action_group_delete
    MActionGroup.delete_action_group params, current_m_user.user_cd

    redirect_to :action=>:action_group_list
  end

  #
  #
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
  #
  #
  def action_add
    MAction.create_action params, current_m_user.user_cd

    redirect_to :action=>:action_list, :action_group_cd=>params[:action_group_cd]
  end

  #
  #
  #
  def action_update
    MAction.update_action params, current_m_user.user_cd

    redirect_to :action=>:action_list, :action_group_cd=>params[:action_group_cd]
  end

  #
  #
  #
  def action_delete
    MAction.delete_action params, current_m_user.user_cd

    redirect_to :action=>:action_list, :action_group_cd=>params[:action_group_cd]
  end

end
