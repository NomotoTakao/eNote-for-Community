module Blog::ViewHelper
  
  #
  # 渡された文字列中の改行文字を改行タグに置き換えます。
  #
  def disp_body_str(inStr)
    auto_link(CGI.escapeHTML(inStr).gsub(/\r\n/,"<br/>").gsub(/\r/, "<br/>").gsub(/\n/,"<br/>") , :urls, :target => '_blank')
  end
  
  #
  # 各記事の投稿者がログインユーザと一致するとき、記事の編集が可能となるインターフェイスを提供します。
  #
  def disp_meta(blog)
    
    str = ""
    strCategory = ""
    str = datetime_strftime(blog.send(:post_date).to_datetime)
    arrayCategory = blog.d_blog_tags
    arrayCategory.each do |category|
      strCategory += "[" + category.category + "]"
    end
    str += " | キーワード：" + h(strCategory) 
    str += " | 投稿者：" + h(blog.d_blog_head.send(:user_name))
    
    #if session[:uid] == blog.post_user_cd
    if current_m_user.user_cd == blog.d_blog_head.user_cd.to_s
      str += " | " + link_to_remote('編集', :update=>"right_pane", :url=>{:controller => 'entry', :action =>:article_edit, :id => blog.send(:id)})
      str += " | " + link_to_remote('削除', :update=>"right_pane", :url=>{:controller => 'entry', :action =>:delete, :id => blog.send(:id)},  :confirm=>"削除してよろしいですか？")
      str += " | " + "<font color='red'>【非公開】</font>" if blog.public_flg == 1
    end

    return str
  end

  #
  # 社内ブログの公開/非公開チェックボックスは、'0'のとき公開する、'1'のとき公開しないである。
  # チェックボックスは「公開する」のときにチェックを入れるので、引数が'0'のときにチェックを入れる。
  #
  def public_checkbox(blog)
    if blog != nil and blog.public_flg == 0
      str = "<input type='checkbox' name='d_blog_body[public_flg]' id='d_blog_body_public_flg' checked/>"
    else
      str = "<input type='checkbox' name='d_blog_body[public_flg]' id='d_blog_body_public_flg'/>"
    end
    str
  end
  
  #
  # 組織名が空でない最下層の名称を取得します。
  #
  # @param org - MOrgオブジェクト
  #
  def blogger_org_name org
    
    result = ""
    
    unless org.org_name4.nil? or org.org_name4.empty?
      result = org.org_name4
    else
      unless org.org_name3.nil? or org.org_name3.empty?
        result = org.org_name3
      else
        unless org.org_name2.nil? or org.org_name2.empty?
          result = org.org_name2
        else
          unless org.org_name1.nil? or org.org_name1.empty?
            result = org.org_name1
          end
        end
      end
    end
    
    return result
  end
end
