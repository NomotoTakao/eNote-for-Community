module Bbs::BbsHelper

  def disp_body_str(inStr)
    unless inStr.nil?
      auto_link(CGI.escapeHTML(inStr).gsub(/\r\n/,"<br/>").gsub(/\r/, "<br/>").gsub(/\n/,"<br/>") , :urls, :target => '_blank')
    end
  end

  #
  # データベースより取得した文字列をブラウザに表示させるのに適切な変換を行います。
  #
  # @param str - 変換対象の文字列
  #
  def display(str)
    unless str.nil?
      str.gsub(/\r\n/, "<br />").gsub(/\r/, "<br />").gsub(/\n/, "<br />")
    end
  end

  def _rendering_paginate(pages, controller, params, element)
    expression = ""
    
    if pages
      expression += "<table align='center' stye='width: 640px;'><tr><td style='width: 40px; text-align: center;'>"
      expression += link_to_remote("前へ", :update => element, :url => {:action => controller, :bid => params[:bid], :mode => params[:mode], :page => pages.previous_page}, :complete => "URLBreakerUser()") if pages.previous_page
      expression += "&nbsp;</td><td style='width: 560px; text-align: center;'>"
      
      #      remote_tags = pagination_link_remotes(pages, :params => { :update => element, :url => { :action => controller, :bid => params[:bid], :mode => params[:mode] }, :complete => "URLBreakerUser()"})
      #      expression += remote_tags if remote_tags
      
      expression += "</td><td style='width: 40px; text-align: center;'>"
      expression += link_to_remote("次へ", :update => element, :url => {:action => controller, :bid => params[:bid], :mode => params[:mode], :page => pages.next_page}, :complete => "URLBreakerUser()") if pages.next_page
      expression += "&nbsp;</td></tr></table>"
    end
    
    return expression
    
  end 
  
  #
  # 一定文字数以上の文字列の末尾を"…"で置き換えます。
  #
  # @param text - 検査対象の文字列
  # @param len - 最大文字数
  #
  def cut_off(text, len)
    
#    p text.jlength
    
    if text != nil
      if text.jlength < len
        text
      else
        text.scan(/^.{#{len}}/m)[0] + "…"
      end
    else
      ''
    end
  end
  
  #
  # 日付を整形します。 "%m月j%d日"
  # 
  # @param date - Timeオブジェクト
  #
  def formatMD(date)
    
    unless date.nil?
      date.strftime("%m月%d日")
    end
  end
  
  #
  # ユーザーIDからユーザー名への変換を行います。
  #
  # @param user_hash - ユーザーIDとユーザー名のハッシュテーブル 
  # @param uid - ユーザーID
  #
  def convertName(user_hash,uid)
    unless uid.nil?
      user_hash[uid.to_s]
    end
  end
end
