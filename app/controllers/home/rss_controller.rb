require "rss/1.0"
require "rss/2.0"
require "rss/dublincore"
require "rss/content"
require 'jcode'
require "open-uri"

class Home::RssController < ApplicationController
  layout "portal", :except => [:rss_reader]
 
  def rss_reader
    if params[:trunk_date] && params[:trunk_date].to_i != 0
      @trunk_date = params[:trunk_date].to_i    
    else
      @trunk_date = 7      
    end
    from_date = Date.today - @trunk_date

    if params[:trunk_id].nil? || params[:trunk_id].to_i < 1
      sql = ["SELECT * FROM d_rss_leaves WHERE d_rss_trunk_id IN (SELECT d_rss_trunk_id FROM d_rss_readers WHERE user_cd = ?) AND publish >= ? ORDER BY publish desc", current_m_user.user_cd,from_date]
    else
      sql = ["SELECT * FROM d_rss_leaves WHERE d_rss_trunk_id = ? AND publish >= ? ORDER BY publish desc", params[:trunk_id],from_date]
      @trunk_id = params[:trunk_id].to_i
    end
        
    params[:page] = "1" unless params[:page]
        
    @leaves = DRssLeaf.paginate_by_sql sql, :page => params[:page], :per_page => 10
    
    #購読RSSリスト
    sql = ["SELECT * FROM d_rss_trunks WHERE id IN (SELECT d_rss_trunk_id FROM d_rss_readers WHERE user_cd = ?)", current_m_user.user_cd]
    @rss_trunks = DRssTrunk.find_by_sql(sql)
    
    render :layout => false
  end
  
  #RSSを新規登録
  def new_rss
    http_proxy = HTTP_PROXY_URI.blank? ? nil : HTTP_PROXY_URI
    
    #入力されたRSSのURLが正しく開けるかチェック
    begin 
      unless(open(params[:url], :proxy => http_proxy))
        render :text => "URLが正しいか確認してください"
      end      
    rescue => e
      render :text => e.to_s
    end
    
    @trunk = DRssTrunk.find(:first, :conditions => ["rss_url = ?", params[:url]]) 
      
    unless @trunk 
      trunk = DRssTrunk.new 
      trunk.rss_url = params[:url]
      
      begin
        rss = RSS::Parser.parse(open(params[:url], :proxy => http_proxy){ |fd| fd.read })
      rescue RSS::InvalidRSSError 
        rss = RSS::Parser.parse(open(params[:url], :proxy => http_proxy){ |fd| fd.read })
      end 

      trunk.name = rss.channel.title
      trunk.url = rss.channel.link
      trunk.created_user_cd = current_m_user.user_cd
      trunk.updated_user_cd = current_m_user.user_cd
      trunk.save!
    end

    @trunk = DRssTrunk.find(:first, :conditions => ["rss_url = ?", params[:url]]) 
        
    @reader = DRssReader.find(:first, :conditions => ["d_rss_trunk_id = ? AND user_cd = ?", @trunk.id, current_m_user.user_cd.to_s]) || 
        DRssReader.new(:d_rss_trunk_id => @trunk.id, :user_cd => current_m_user.user_cd.to_s)

    @reader.user_cd = current_m_user.user_cd
    @reader.d_rss_trunk_id = @trunk.id
    @reader.created_user_cd = current_m_user.user_cd
    @reader.updated_user_cd = current_m_user.user_cd
    @reader.save

    #最初のRSSデータを取得する
    ret = @trunk.sync_rss_leaves
    if ret
      render :text => "true"     
    else
      render :text => ret.to_s
    end
  end
  
  #RSS設定画面
  def setting
    @trunks = DRssTrunk.find(:all, :conditions => ["id IN (SELECT d_rss_trunk_id FROM d_rss_readers WHERE user_cd = ?)",current_m_user.user_cd])
  end
  
  #RSSの削除    
  def rss_delete
    begin 
      rec = DRssReader.find(:first, :conditions => ["d_rss_trunk_id = ? AND user_cd = ?",params[:id],current_m_user.user_cd])
      rec.destroy

      redirect_to :action => "setting"
    
    rescue => e
      render :text => e
    end
    
  end

end
