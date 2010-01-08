require 'digest/md5'
class DNoticeFile < ActiveRecord::Base
  belongs_to :d_notice_body

  def self.save_upload(params, current_m_user, head_id, body_id)
    
    dirname = "#{RAILS_ROOT}/data/notice"
    
    attachments = params[:attachment]
    attachments.each do |key, attachment|

      org_filename = attachment.original_filename
    
      real_file_name = Time.now.strftime('%Y%m%d%H%M%S') + Digest::MD5.hexdigest(org_filename + Time.now.to_s + current_m_user.user_cd.to_s)

      File.open("#{dirname}/#{real_file_name}", "wb") do |f|
        f.write(attachment.read)
      end

      file_rec = self.new
      file_rec.d_notice_head_id = head_id
      file_rec.d_notice_body_id = body_id
      file_rec.post_org_cd = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
      file_rec.post_user_cd = current_m_user.user_cd
      file_rec.post_user_name = current_m_user.name
      file_rec.post_date = Time.now
      file_rec.real_file_name = real_file_name
      file_rec.file_name = org_filename
      file_rec.file_size = attachment.size
      file_rec.mime_type = attachment.content_type
      file_rec.created_user_cd = current_m_user.user_cd
      file_rec.updated_user_cd = current_m_user.user_cd
      file_rec.save!
    end
  end

  #
  # 添付ファイルの情報を削除します。(ファイルシステムからは削除していません)
  #
  # @param file_id - 削除するファイル情報のID
  # @param user_cd - 削除者CDとして使用するユーザーCD
  #
  def delete_by_id file_id, user_cd
   
    d_notice_file = DNoticeFile.new.find_by_id file_id
    
    unless d_notice_file.nil?
      d_notice_file.delf = 1
      d_notice_file.deleted_user_cd = user_cd
      d_notice_file.deleted_at = Time.now
      
      d_notice_file.save
    end
  end
  
  
  #
  # 添付ファイルの情報を削除します。(ファイルシステムからは削除していません)
  #
  # @param body_id - 削除するファイル情報が紐づけられているお知らせ詳細ID
  # @param user_cd - 削除者CDとして使用するユーザーCD
  #
  def delete_by_body_id body_id, user_cd
    
    d_notice_files = DNoticeFile.new.find_by_body_id body_id
    
    d_notice_files.each do |file|
      
      file.delf = 1
      file.deleted_user_cd = user_cd
      file.deleted_at = Time.now
      
      file.save
    end
  end
  
  #
  # 指定されたIDのファイル情報を取得する
  #
  # @param file_id - ファイルID
  # @return ファイル情報
  #
  def find_by_id file_id
    
    conditions_sql = ""
    conditions_param = {}
    
    conditions_sql = " delf = :delf"
    conditions_param[:delf] = 0
    conditions_sql += " AND id = :id "
    conditions_param[:id] = file_id
    
    DNoticeFile.find(:first, :conditions=>[conditions_sql, conditions_param])
  end
  
  #
  # 指定されたIDのお知らせに紐づけられている添付ファイル情報を取得する。
  #
  # @Param body_id - お知らせID
  # @return ファイル情報
  #
  def find_by_body_id body_id
    
    conditions_sql = ""
    conditions_param = {}
    
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_notice_body_id = :body_id "
    conditions_param[:body_id] = body_id
    
    DNoticeFile.find(:all, :conditions=>[conditions_sql, conditions_param])
  end
end
