module Home::MypageHelper

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
