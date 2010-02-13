require "rss/1.0"
require "rss/2.0"
require "rss/dublincore"
require "rss/content"
require 'jcode'
require "open-uri"

class DRssTrunk < ActiveRecord::Base
  belongs_to :d_rss_reader
  
  def self.get_trunk_name(id)
    @data = DRssTrunk.find(:first, :conditions => ["id = ?", id])
    unless @data.nil?
      if @data.name?
        return @data.name
      else
        return ""
      end
    else
      return ""
    end
  end
  
  #RSSの記事を更新する
  def sync_rss_leaves
    
    http_proxy = HTTP_PROXY_URI.blank? ? nil : HTTP_PROXY_URI
    rss = nil 
 
    begin
      rss = RSS::Parser.parse(open(self.rss_url, :proxy => http_proxy){ |fd| fd.read })

      self.upddate = rss.channel.date.nil? ? DateTime.now : rss.channel.date.to_datetime 
      self.name = rss.channel.title
      self.url = rss.channel.link
      self.updated_user_cd = "9999999"
      self.save!

      leaf_id = 1
      rss.items.each do |item|
        leaf = DRssLeaf.find(:first, :conditions => ["url = ?", item.link]) || DRssLeaf.new(:url => item.link)

        leaf.title = item.title

        begin 
          leaf.content = item.content_encoded
        rescue 
          leaf.content = item.description
        end

        if item.date == nil
          leaf.publish = ""
        else
          leaf.publish = item.date.to_datetime
        end
        leaf.leaf_id = leaf_id
        leaf.d_rss_trunk_id = self.id
        leaf.save
        leaf_id += 1
      end

    rescue OpenURI::HTTPError 
      return "RSS ERROR => OpenURI::HTTPError" 
#      tree.destroy
  #      rss = RSS::Parser.parse(open(self.rss_url){ |fd| fd.read }, false)
    rescue RSS::InvalidRSSError 
      return "RSS ERROR => RSS::InvalidRSSError" 
#      rss = RSS::Parser.parse(open(self.rss_url){ |fd| fd.read }, false)
    rescue Exception => exc
      return "RSS ERROR => #{exc.message}" 
    end     
    return true
  end

end
