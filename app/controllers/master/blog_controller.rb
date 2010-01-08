class Master::BlogController < ApplicationController
  layout "portal",
  :except=>[:_blog_settings, :save_blog_settings]
  
  def index
    @pankuzu += "ブログ設定"
    @m_blog_settings = MBlogSetting.find(:first, :conditions=>{:delf=>0})
    
  end
  
  def _blog_settings
    
    @result = params[:result]
    @m_blog_settings = MBlogSetting.find(:first, :conditions=>{:delf=>0})
  end
  
  def save_blog_settings
    
    new_icon_days = params[:m_blog_settings][:new_icon_days]
    page_max_count = params[:m_blog_settings][:page_max_count]
    
    m_blog_settings = MBlogSetting.find(:first, :conditions=>{:delf=>0})
    m_blog_settings.new_icon_days = new_icon_days
    m_blog_settings.page_max_count = page_max_count
    begin
      m_blog_settings.save
      result = 1
    end
    
    redirect_to :action=>:_blog_settings, :result=>result
  end
end
