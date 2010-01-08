class MBbsSetting < ActiveRecord::Base
  def get_bbs_settings
    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"

    MBbsSetting.find(:first, :conditions=>[conditions_sql, conditions_param])
  end
end
