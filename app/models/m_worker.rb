class MWorker < ActiveRecord::Base

  #
  # ある得意先の作業担当者として登録されている社員の一覧を取得します。
  #
  # @param company_cd - 得意先CD
  # @return 得意先の作業担当者一覧
  #
  def self.get_worker company_cd
    result = Array.new

    unless company_cd.nil? or company_cd.empty?
      m_worker_list = MWorker.find(:all, :conditions=>{:delf=>0, :company_cd=>company_cd}, :order=>"user_cd ASC")
      unless m_worker_list.nil?
        m_worker_list.each do |m_worker|
          result << m_worker.user_cd
        end
      end
    end

    return result
  end

  #
  # ある社員が作業担当となっている得意先の一覧を取得します。
  #
  # @param user_cd - ユーザーCD
  # @return 社員が作業となっている得意先の一覧
  #
  def self.get_assign user_cd
    result = Array.new

    unless user_cd.nil? or user_cd.empty?
      m_worker_list = MWorker.find(:all, :conditions=>{:delf=>0, :user_cd=>user_cd}, :order=>"company_cd ASC")
      unless m_worker_list.nil?
        m_worker_list.each do |m_worker|
          result << m_worker.company_cd
        end
      end
    end

    return result
  end

  #
  # 作業担当者の登録・削除をおこないます。
  #
  # @param params -
  # @param use_cd - ログインユーザーのユーザーCD
  #
  def self.register params, user_cd

    company_cd = params[:company_cd]
    selected_list = params[:selected_list]
    deleted_list = params[:deleted_list]

    # 指定された得意先の作業対応者として登録されているユーザーの一覧を取得
    unless company_cd.nil?
      worker_array = get_worker company_cd
    end

    unless deleted_list.nil?
      deleted_array = deleted_list.split(",")
      unless worker_array.length==0 or deleted_array.length==0
        # 得意先の作業対応者一覧中に、プロジェクトから離れるメンバーのユーザーCDがある場合は削除フラグを立てる。
        deleted_array.each do |delete_user_cd|
          if worker_array.include? delete_user_cd
            m_worker = MWorker.find(:first, :conditions=>{:delf=>0, :company_cd=>company_cd, :user_cd=>delete_user_cd})
            m_worker.delf = 1
            m_worker.deleted_user_cd = user_cd
            m_worker.deleted_at = Time.now
            begin
              m_worker.save!
            rescue
              p $!
              raise
            end
          end
        end
      end
    end

    unless selected_list.nil?
      selected_array = selected_list.split(",")
      unless worker_array.length==0 and selected_array.length==0
        # 得意先作業対応者の一覧に、プロジェクトに加わるユーザーのユーザーCDがなければ追加する。
        selected_array.each do |select_user_cd|
          if select_user_cd == ""
            next
          end
          assign_array = get_assign select_user_cd
          unless assign_array.include? company_cd
            m_worker = MWorker.new
            m_worker.company_cd = company_cd
            m_worker.user_cd = select_user_cd
            m_worker.created_user_cd = user_cd
            m_worker.updated_user_cd = user_cd
            begin
              m_worker.save!
            rescue
              p $!
              raise
            end
          end
        end
      end
    end
  end

end
