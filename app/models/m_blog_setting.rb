class MBlogSetting < ActiveRecord::Base
  def get_blog_settings
    conditions_sql = ""
    conditions_param = {}

    conditions_sql = " delf = :delf "
    conditions_param[:delf] = "0"

    MBlogSetting.find(:first, :conditions=>[conditions_sql, conditions_param])
  end
end
