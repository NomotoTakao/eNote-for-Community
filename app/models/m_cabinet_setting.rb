class MCabinetSetting < ActiveRecord::Base
  
  def get_cabinet_settings
    conditions_sql = ""
    conditions_param = {}
    
    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"
    
    MCabinetSetting.find(:first, :conditions=>[conditions_sql, conditions_param])
  end
end
