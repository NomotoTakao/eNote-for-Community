class MNoticeSetting < ActiveRecord::Base

  def get_notice_settings
    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"

    MNoticeSetting.find(:first, :conditions=>[conditions_sql, conditions_param])
  end
end
