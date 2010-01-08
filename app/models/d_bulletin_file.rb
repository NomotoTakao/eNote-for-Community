class DBulletinFile < ActiveRecord::Base
  belongs_to :d_bulletin_body
  
  #
  #
  #
  def self.save_upload(params, current_m_user, head_id)
    
    dirname = "#{RAILS_ROOT}/data/bulletin"
    
    attachments = params[:attachment]
    
    attachments.each do |key, file|
      org_filename = file.original_filename
    
      real_file_name = Time.now.strftime('%Y%m%d%H%M%S') + Digest::MD5.hexdigest(org_filename + Time.now.to_s + current_m_user.user_cd.to_s)

      File.open("#{dirname}/#{real_file_name}", "wb") do |f|
        f.write(file.read)
      end

      file_rec = self.new
      file_rec.d_bulletin_head_id = head_id
    #file_rec.post_org_cd = current_m_user.org_cd
#    file_rec.post_org_cd = (MUserBelong.new.get_main_org current_m_user.user_cd).org_cd
      file_rec.post_user_cd = current_m_user.user_cd
#    file_rec.post_user_name = current_m_user.name
      file_rec.post_date = Time.now
      file_rec.real_file_name = real_file_name
      file_rec.file_name = org_filename
      file_rec.file_size = file.size
      file_rec.mime_type = file.content_type
      file_rec.created_user_cd = current_m_user.user_cd
      file_rec.updated_user_cd = current_m_user.user_cd
      file_rec.save!
    end
  end
  
  
  def find_by_id file_id
    
    conditions_sql = ""
    conditions_param = {}
    
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND id = :id "
    conditions_param[:id] = file_id
    
    DBulletinFile.find(:first, :conditions=>[conditions_sql, conditions_param])
  end
end
