class Master::MaintenanceController < ApplicationController
  layout "portal", :except => [:master_list]
  PANKUZU = "システム管理メニュー"

  def index
    @pankuzu += PANKUZU
    
    #システム管理用メニューを読み出す
    @menus = MMenu.find(:all, :conditions =>["delf = 0 AND menu_kbn = 9 AND public_flg = 0"], :order => "sort_no")
    
  end
  
  
  
end
