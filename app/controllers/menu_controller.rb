class MenuController < ApplicationController
  
#  def get_menu_data
#    data = {}
#    
#    if request.method == :get
#      menu_structure = Struct.new("Menu", :id, :name, :path, :alt, :bikou, :col_id, :row_id)
#     
#      menu_id = EnMUser.find(:first, :conditions => ["id = ?", session[:uid]]).menuid   
#      menu = EnMMenu.find(:all, :conditions => ["menuid = ? AND delf = '0'", menu_id], :order => "row_id")
#      
#      data["0"] = menu_structure.new("0", "ROOT",         "", "", "", "0", "0")
#      data["1"] = [menu_structure.new("1", "トップ",       "/home/top/main", "", "", "1", "0")]
#      data["2"] = [menu_structure.new("2", "マイページ",    "/en_m_action/list", "", "", "2", "0")]
#      data["3"] = [menu_structure.new("3", "お知らせ",       "/topic/main/index", "", "", "3", "0")]
#      data["4"] = [menu_structure.new("4", "ｺﾐｭﾆｹｰｼｮﾝ",       "/webmail/webmail/message", "", "", "4", "0")]
#      data["5"] = [menu_structure.new("5", "情報共有",     "/en_m_action/list", "", "", "5", "0")]
#      data["6"] = [menu_structure.new("6", "各種業務",         "/nippou/doing/main", "", "", "6", "0")]
#      data["7"] = [menu_structure.new("7", "業務情報",   "/customer/information/main", "", "", "7", "0")]
#      data["8"] = [menu_structure.new("8", "設定",         "/en_m_action/list", "", "", "8", "0")]
#
#      menu.each do |m|
#        data[m.col_id.to_s] << [menu_structure.new(m.id, m.name, m.path, m.alt, m.bikou, m.col_id, m.row_id)]       
#      end
#          
#    end
#    
#    render :inline => "<%= blit_menu_data(data) %>", :locals => { :data => data }
#  #  render :text => session[:scd]
#  end
#  
#  def set_selected_menu  
#    render :text => "true"
#  end
  
end
