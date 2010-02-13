class MActionGroup < ActiveRecord::Base

  #
  # 活動内容グループのレコードの登録/更新をおこなうメソッドです。
  # 入力されたパラメータのレコードが存在するときは更新を、存在しないときは新規登録を行います。
  #
  # @param params  - 操作対象の活動内容グループの項目情報
  # @param user_cd - 操作をおこなったユーザーのCD
  #
  def self.register params, user_cd

    action_group_id = params[:m_action_groups][:action_groups_id]
    unless action_group_id.nil?
      # 更新
      m_action_group = self.find(:first, :conditions=>{:delf=>0, :id=>action_group_id})
    else
      # 追加登録
      m_action_group = MActionGroup.new
      m_action_group.created_user_cd = user_cd
      m_action_group.created_at = Time.now
    end
    m_action_group.action_group_cd = params[:m_action_groups][:action_group_cd]
    m_action_group.action_group_nam = params[:m_action_groups][:action_group_name]
    m_action_group.sort_no = params[:m_action_groups][:sort_no]
    m_action_group.memo = params[:m_action_groups][:memo]
    m_action_group.updated_user_cd = user_cd
    m_action_group.updated_at = Time.now

    begin
      m_action_group.save!
    rescue
      p $!
      raise
    end
  end

  #
  # 渡された活動内容グループの項目を新規登録します。
  #
  # @param params  - 操作対象の活動内容グループの項目情報
  # @param user_cd - 操作をおこなったユーザーのCD
  #
  def self.create_action_group params, user_cd

    m_action_group = MActionGroup.new

    m_action_group.action_group_cd = params[:action_group_cd]
    m_action_group.action_group_name = params[:action_group_name]
    m_action_group.sort_no = params[:sort_no]
    m_action_group.memo = params[:memo]
    m_action_group.created_user_cd = user_cd
    m_action_group.created_at = Time.now
    m_action_group.updated_user_cd = user_cd
    m_action_group.updated_at = Time.now

    begin
      m_action_group.save!
    rescue
      p $!
      raise
    end
  end

  #
  # 渡された活動内容グループの項目を更新します。
  #
  # @param params  - 操作対象の活動内容グループの項目情報
  # @param user_cd - 操作をおこなったユーザーのCD
  #
  def self.update_action_group params, user_cd

    m_action_group = MActionGroup.find(:first, :conditions=>{:delf=>0, :id=>params[:id]})

    unless m_action_group.nil?
      m_action_group.action_group_cd = params[:action_group_cd]
      m_action_group.action_group_name = params[:action_group_name]
      m_action_group.sort_no = params[:sort_no]
      m_action_group.memo = params[:memo]

      begin
        m_action_group.save!
      rescue
        p $!
        raise
      end
    end
  end

  #
  # 渡された活動内容グループの項目を削除状態にします。
  #
  # @param params  - 操作対象の活動内容グループの項目情報
  # @param user_cd - 削除操作をおこなったユーザーのCD
  #
  def self.delete_action_group params, user_cd

    m_action_group = MActionGroup.find(:first, :conditions=>{:delf=>0, :id=>params[:id]})

    unless m_action_group.nil?
      m_action_group.delf = 1
      m_action_group.deleted_user_cd = user_cd
      m_action_group.deleted_at = Time.now

      begin
        m_action_group.save!
      rescue
        p $!
        raise
      end
    end
  end

end
