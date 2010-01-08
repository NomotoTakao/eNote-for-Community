class Common::AddressSearchController < ApplicationController
  
  def index
    @type = params[:type].to_i
    @count = params[:count]
    @cd_field = params[:cd_field]
    @name_field = params[:name_field]
    
    if @type == 1
      @title = "推進担当"
    elsif @type == 2
      @title = "営業部長"
    elsif @type == 3
      @title = "支店長"
    elsif @type == 4
      @title = "課長"
    end
    @title += "名検索"
  end
  
  def address_list
    gid = params[:gid]
    keyword = params[:keyword]
    
    @address_list = DAddress.get_address_list_by_group_with_keyword gid, keyword
  end
  
end
