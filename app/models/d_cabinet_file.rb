require 'digest/md5'
class DCabinetFile < ActiveRecord::Base
  belongs_to :d_cabinet_body
  
  #
  # ファイルをアップロードします。
  # @param params - 
  # @param  current_m_user -
  # @param head_id - 
  # @param body_id - 
  # @param dir - データを保存するディレクトリ　例)"/cabinet_public"
  #
  def self.save_upload(params, current_m_user, head_id, body_id, dir)
    
    dirname = "#{RAILS_ROOT}/data/" + dir
    
    attachments = params[:attachment]
    attachments.each do |key, attachment|
      org_filename = attachment.original_filename

      real_file_name = Time.now.strftime('%Y%m%d%H%M%S') + Digest::MD5.hexdigest(org_filename + Time.now.to_s + current_m_user.user_cd.to_s)

      File.open("#{dirname}/#{real_file_name}", "wb") do |f|
        f.write(attachment.read)
      end

      file_rec = self.new
      file_rec.d_cabinet_head_id = head_id
      file_rec.d_cabinet_body_id = body_id
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
  # 指定されたIDの添付ファイル情報を取得します。
  #
  # @param cabinet_id - 添付ファイル情報ID
  # @return 添付ファイル情報
  #
  def get_cabinetfile_by_id cabinet_id
    
    conditions_sql = ""
    conditions_param = {}
    
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    conditions_sql += " AND id = :id "
    conditions_param[:id] = cabinet_id
    DCabinetFile.find(:first, :conditions=>[conditions_sql, conditions_param])
  end
  
  #
  # 指定されたキャビネット詳細IDに紐づけられた添付ファイル情報の配列を取得します。
  #
  # @param body_id - キャビネット詳細ID
  # @return 添付ファイル情報の配列
  #
  def get_cabinetfile_by_cabinet_body_id body_id
    
    conditions_sql = ""
    conditions_param = {}
    
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND d_cabinet_body_id = :body_id "
    conditions_param[:body_id] = body_id
    
    DCabinetFile.find(:all, :conditions=>[conditions_sql, conditions_param])
  end
  
  #
  # 指定されたキャビネットの添付ファイルを削除します
  #
  # @param id - ファイルのID
  # @param user_cd - 削除するユーザーCD
  #
  def delete_by_id id, user_cd
    
    cabinetfile = get_cabinetfile_by_id id
    
    unless cabinetfile.nil?
      cabinetfile.delf = 1
      cabinetfile.deleted_user_cd = user_cd
      cabinetfile.deleted_at = Time.now
      
      cabinetfile.save
    end
  end
  
end
