class MAction < ActiveRecord::Base

  #
  # 渡された活動内容の項目を登録/更新します。
  # 渡された項目がまだ登録されていないとは登録操作を、
  # 既に登録されたいる場合は更新操作をおこないます。
  #
  # @param params  - 操作対象の活動内容の項目内容
  # @param user_cd - 操作をおこなっユーザーのCD
  #
  def self.register params, user_cd

    action_id = params[:m_action][:id]
    unless action_id.nil?
      m_action = MAction.find(:first, :conditions=>{:delf=>0, :id=>action_id})
    else
      m_action = MAction.new
      m_action.created_user_cd = user_cd
      m_action.created_at = Time.now
    end
    unless params[:m_action][:action_cd].nil?
      m_action.action_cd = params[:m_action][:action_cd]
    end
    unless params[:m_action][:action_name].nil?
      m_action.action_name = params[:m_action][:action_name]
    end
    m_action.updated_user_cd = user_cd
    m_action.updated_at = Time.now

    begin
      m_action.save!
    rescue
      p $!
      raise
    end
  end

  #
  # 渡された活動内容の項目を新規に登録します。
  #
  # @param params  - 新規作成する活動内容の項目内容
  # @param user_cd - 新規作成操作をおこなったユーザーのCD
  #
  def self.create_action params, user_cd

    m_action = MAction.new

    unless params[:action_cd].nil?
      m_action.action_cd = params[:action_cd]
    end
    unless params[:action_name].nil?
      m_action.action_name = params[:action_name]
    end
    unless params[:action_group_cd].nil?
      m_action.action_group_cd = params[:action_group_cd]
    end
    unless params[:sort_no].nil?
      m_action.sort_no = params[:sort_no]
    end
    unless params[:memo].nil?
      m_action.memo = params[:memo]
    end
    m_action.created_user_cd = user_cd
    m_action.created_at = Time.now
    m_action.updated_user_cd = user_cd
    m_action.updated_at = Time.now

    begin
      m_action.save!
    rescue
      p $!
      raise
    end
  end

  #
  # 渡された活動内容の項目を更新します。
  #
  # @param params  - 更新する活動内容の項目内容
  # @param user_cd - 更新操作をおこなったユーザーのCD
  #
  def self.update_action params, user_cd

    m_action = MAction.find(:first, :conditions=>{:delf=>0, :id=>params[:id]})
    unless m_action.nil?
      unless params[:action_cd].nil?
        m_action.action_cd = params[:action_cd]
      end
      unless params[:action_name].nil?
        m_action.action_name = params[:action_name]
      end
      unless params[:sort_no].nil?
        m_action.sort_no = params[:sort_no]
      end
      unless params[:memo].nil?
        m_action.memo = params[:memo]
      end

      m_action.created_user_cd = user_cd
      m_action.created_at = Time.now
      m_action.updated_user_cd = user_cd
      m_action.updated_at = Time.now

      begin
        m_action.save!
      rescue
        p $!
        raise
      end
    end
  end

  #
  # 渡された活動内容の項目を削除状態にします。
  #
  # @param params  - 削除する活動内容の項目内容
  # @param user_cd - 削除操作をおこなったユーザーのCD
  #
  def self.delete_action params, user_cd

    m_action = MAction.find(:first, :conditions=>{:delf=>0, :id=>params[:id]})
    unless m_action.nil?
      m_action.delf = 1
      m_action.deleted_user_cd = user_cd
      m_action.deleted_at = Time.now
      begin
        m_action.save!
      rescue
        p $!
        raise
      end
    end
  end
end
