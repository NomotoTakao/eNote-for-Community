require 'jcode'

module Home::TopHelper

  def datetime_strftime(indate)
    if indate.nil? 
      return '---'
    else
      w_date = indate
      if w_date.strftime('%y%m%d') == Date::today.strftime('%y%m%d')
        return w_date.strftime('%H:%M').to_s
      elsif w_date.strftime('%y') == Date::today.strftime('%y')
        return w_date.strftime('%m月%d日').to_s
      else      
        return w_date.strftime('%y/%m/%d').to_s
      end
    end
  end
  
  def _rendering_paginate(leaves, controller, params, element, trunk_id)
    expression = ""
    
    if leaves
      expression += "<table stye='width: 940px;'><tr><td style='width: 40px; text-align: center;'>"
      expression += link_to_remote("前へ", :update => element, :url => {:action => controller, :page => leaves.previous_page, :trunk_id => trunk_id}) if leaves.previous_page
      expression += "&nbsp;</td><td style='width: 860px; text-align: center;'>"
      
#      remote_tags = pagination_link_remotes(leaves, :params => { :update => element, :url => { :action => controller, :trunk_id => trunk_id }})
#      expression += remote_tags if remote_tags
      
      expression += "</td><td style='width: 40px; text-align: center;'>"
      expression += link_to_remote("次へ", :update => element, :url => {:action => controller, :page => leaves.next_page, :trunk_id => trunk_id}) if leaves.next_page
      expression += "&nbsp;</td></tr></table>"
    end
    
    return expression
    
  end 
  
  def _rendering_setting_data(mode, data)
    expression = ""
  
    expression += "<ul class='list'>"
    
    data.each do |d|
      expression += "<li id='enote_rss_#{mode}_list_#{d}' class='rss_#{mode}'>\n"
      expression += EnDRssTrunk.get_trunk_name(d.to_s) + "\n"
      expression += "<script type='text/javascript'>new Draggable('enote_rss_#{mode}_list_#{d}', {revert:true})</script>\n"
      expression += "</li>"
    end 
    
    expression += "</ul>" 
          
    return expression
  end
  
#  def _rendering_setting_data(data)
#    expression = ""
#  
#    expression += "<ul class='list'>"
#    
#    data.each do |d|
#      expression += "<li id='enote_rss_setting_list_#{d}' class='rss_list'>\n"
#      expression += d.name + "\n"
#      expression += "<script type='text/javascript'>new Draggable('enote_rss_setting_list_#{d}', {revert:true})</script>\n"
#      expression += "</li>"
#    end 
#    
#    expression += "</ul>" 
#          
#    return expression
#  end

  def _link_to_detail(text, ccd, html_options = nil)
    expression = ""
    expression += "if($('enote_info_ccd')) Element.remove($('enote_info_ccd'));"
    expression += "                  var f = document.createElement('form');"
    expression += "                  var h = document.createElement('input');"

    #    expression += "                  h.type='hidden';"
    expression += "                  h.value = '#{ccd.to_s}';"

    expression += "                  h.id = 'enote_info_ccd';"
    expression += "                  h.name = 'enote_info[ccd]';"

    expression += "                   f.appendChild(h);"
    expression += "                   this.parentNode.appendChild(f);"
    expression += " h.style.display = 'none';"
    expression += "                   f.method = 'POST';"
    expression += "                   f.action = this.href;"
    expression += "                    f.target = '_blank';"
    expression += "                    f.submit();"

    expression += "                    return false;"
    html_options = {} unless html_options
    html_options[:onclick] = expression

    link_to text, "/customer/information/detail", html_options
  end

  def jslice (s, n, length = nil)
    chars = s.each_char
    if length then
      sliced = chars.slice(n, length)
    else
      sliced = chars.slice(n) # n.type is Integer or Range.
      if sliced and n.is_a?(Integer) then
	codes = sliced.unpack("CC") # Change to char code array from string.
	sliced = (codes.last.nil?) ? codes.first : sliced
      end
    end
    sliced = sliced.join if sliced.is_a?(Array)

    if sliced then
      return sliced
    else
      return nil
    end
  end
  
  def check_regited_trunk(trunk_id)
    @rcnt = EnDRssReader.count(:conditions => ["scd = ? AND trunk_id = ?", session[:scd], trunk_id])
    
    return (@rcnt > 0)? true : false
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
  
end
