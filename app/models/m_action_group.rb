class MActionGroup < ActiveRecord::Base

  # サポートする最大の活動内容グループCD
  @@MAX_ACTION_GROUP_CD = "9900"
  # 活動内容グループCDは100単位で番号を付ける
  @@INTERVAL = 100
  # 活動内容グループコードは４桁
  @@CD_LENGTH = 4

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

  #
  # 活動内容グループテーブル(m_action_groups)で使われていない活動内容グループCDを取得します。
  #
  # @return 使用されていない最小の活動内容グループCD
  #         未使用のCDがない場合は、"-1"
  #
  def self.get_space_action_group_cd

    result = "-1"

    m_action_groups = MActionGroup.find(:all, :conditions=>{:delf=>0}, :order=>:action_group_cd)
    # 最小のレコードから順に活動内容グループCDを走査し空き番号を取得する。
    # 現在のCDと直前のCDを比較して、差がINTERVALに指定した値以上であれば、
    # 直前のCDにINTERVALを加えたものを採用する。
    # 使用されていない最大のCDを採用すると、空き番号が生まれてしまう可能性がある。
    unless m_action_groups.length == 0
      current_cd = -1
      previous_cd = -1

      m_action_groups.each do |m_action_group|
        current_cd = m_action_group.action_group_cd.to_i

        if previous_cd > 0
          if current_cd - previous_cd > @@INTERVAL
            candidate_cd = previous_cd + @@INTERVAL
            if candidate_cd <= @@MAX_ACTION_GROUP_CD.to_i
              result = candidate_cd.to_s
              break
            end
          end
        end

        previous_cd = current_cd
      end

      # 最終レコードまで走査して空きが無い場合
      if previous_cd == current_cd
        candidate_cd = previous_cd + @@INTERVAL
        if candidate_cd <= @@MAX_ACTION_GROUP_CD.to_i
          result = candidate_cd.to_s
        end
      end
    else
      result = @@INTERVAL
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
