class MUserAttribute < ActiveRecord::Base

  #
  # 指定されたユーザーの職位が"1(会長・副会長・顧問・監査役・社長・副社長・専務・常務・本部長・副本部長)"
  # のときにそのレコードを取得する。
  #
  # @param user_cd - ユーザーCD
  #
  def check_user_is_director user_cd

    conditions_sql = ""
    conditions_param = {}
    joins_sql = ""

    joins_sql = " INNER JOIN m_positions ON m_positions.position_cd = cast(m_user_attributes.position_cd AS char(8))"

    conditions_sql = " m_user_attributes.delf = :delf "
    conditions_sql += " AND m_positions.delf = :delf "
    conditions_param[:delf] = 0
    conditions_sql += " AND m_positions.rank = :rank "
    conditions_param[:rank] = 1
    conditions_sql += " AND m_user_attributes.user_cd = :user_cd "
    conditions_param[:user_cd] = user_cd

    MUserAttribute.find(:first, :joins=>joins_sql, :conditions=>[conditions_sql, conditions_param])
  end

  #
  # 引数のユーザーCDに該当するデータを返す
  #
  # @param user_cd - ユーザーCD
  #
  def self.get_data_by_user(user_cd)

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_user_attributes t1
      WHERE
        t1.delf = 0
      AND
        t1.user_cd = '#{user_cd}'
    SQL

    recs = find_by_sql(sql)
    return recs
  end


  #
  # m_user_attributesテーブルにレコードを追加します。
  # すでに、同一のユーザーCDのレコードが存在する場合(削除フラグ=0)、レコードを更新します。
  #
  # @param - params -
  # @param - user_cd -
  #
  def self.register params, user_cd

    unless params[:m_user_attributes].nil?
      m_user_attribute = find(:first, :conditions=>{:delf=>0,:user_cd=>params[:m_user_attributes][:user_cd]})
      if user_attribute.nil?
        m_user_attribute = MUserAttribute.new
        m_user_attribute.created_user_cd = params[:m_user_attributes][:created_user_cd]
      end

      unless params[:m_user_attributes][:name_kana].nil?
        m_user_attribute.name_kana = params[:m_user_attributes][:name_kana]
      end
      unless params[:m_user_attributes][:position_cd].nil?
        m_user_attribute.position_cd = params[:m_user_attributes][:position_cd]
      end
      unless params[:m_user_attributes][:position_cd].nil?
        m_user_attribute.job_kbn = params[:m_user_attributes][:position_cd]
      end
      unless params[:m_user_attributes][:authority_kbn].nil?
        m_user_attribute.authority_kbn = params[:m_user_attributes][:authority_kbn]
      end
      unless params[:m_user_attributes][:place_cd].nil?
        m_user_attribute.place_cd = params[:m_user_attributes][:place_cd]
      end
      unless params[:m_user_attributes][:joined_date].nil?
        m_user_attribute.joined_date = params[:m_user_attributes][:joined_date]
      end
      unless params[:m_user_attributes][:position_cd_org].nil?
        m_user_attribute.position_cd_org = params[:m_user_attributes][:position_cd_org]
      end
      unless params[:m_user_attributes][:updated_user_cd].nil?
        m_user_attribute.updated_user_cd = params[:m_user_attributes][:updated_user_cd]
      end

      begin
        m_user_attribute.save!
      rescue
        p $!
        raise
      end
    end
  end
end
