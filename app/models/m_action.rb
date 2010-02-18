class MAction < ActiveRecord::Base

  # サポートする最大の活動内容CD
  @@MAX_ACTION_CD = "99"
  # 活動内容CDは10単位で番号を付ける
  @@INTERVAL = 1
  # 活動内容グループコードは４桁
  @@CD_LENGTH = 4

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

  #
  # 活動内容テーブル(m_action_groups)で使われていない活動内容CDを取得します。
  #
  # @return 使用されていない最小の活動内容CD(削除済のものもカウントする)
  #         未使用のCDがない場合は、"-1"
  #
  def self.get_space_action_cd action_group_cd

    result = "-1"

    m_actions = MAction.find(:all, :conditions=>{:delf=>0, :action_group_cd=>action_group_cd}, :order=>:action_cd)
    # 最小のレコードから順に活動内容CDを走査し空き番号を取得する。
    # 現在のCDと直前のCDを比較して、差がINTERVALに指定した値以上であれば、
    # 直前のCDにINTERVALを加えたものを採用する。
    # 使用されていない最大のCDを採用すると、空き番号が生まれてしまう可能性がある。
    unless m_actions.length == 0
      current_cd = -1
      previous_cd = -1
      m_actions.each do |m_action|
        current_cd = m_action.action_cd.to_i
        if previous_cd > 0
          if current_cd - previous_cd > @@INTERVAL
            candidate_cd = (previous_cd + @@INTERVAL).to_s
            if candidate_cd[candidate_cd.length-2].to_i <= @@MAX_ACTION_CD.to_i
              result = candidate_cd.to_s
              break
            end
          end
        end
        previous_cd = current_cd
      end

      # 最終レコードまで走査して空きが無い場合
      if previous_cd == current_cd
        candidate_cd = (previous_cd + @@INTERVAL).to_s
        if candidate_cd[candidate_cd.length-2].to_i <= @@MAX_ACTION_CD.to_i
          result = candidate_cd.to_s
        end
      end
    else
      tmp = action_group_cd.to_i + @@INTERVAL
      result = tmp.to_s
    end
    # ゼロサプレス処理
    if result.to_s.length < @@CD_LENGTH
      tmp = ""
     (@@CD_LENGTH - result.to_s.length).times do
       tmp += "0"
     end
      result = tmp + result.to_s
    end

    return result
  end

end
