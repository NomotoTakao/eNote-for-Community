class Common::SosikiTreeController < ApplicationController
  
  def index
    @count = params[:count]
    @cd_field = params[:cd_field]
    @name_field = params[:name_field]
  end

  def tmp_tree
    @org_lvl = params[:org_lvl]
    @count = params[:count]
    @target = params[:target]
    org_cd = params[:cd]
    @type = params[:type]
    
    unless org_cd.nil? or org_cd.empty?
      # 組織コードが取得出来たら、取得したコードの組織情報を取得する。
      m_org = MOrg.find(:first, :conditions=>{:delf=>0, :org_cd=>org_cd})
    else
      @org_list = MOrg.get_org_list(@org_lvl, org_cd)
    end
    
    # 組織情報が取得出来たら、その下位組織とその組織に所属するユーザーを求める。
    unless m_org.nil?
      @org_list = []
      
      if m_org.org_lvl.to_i >= 3
        @org_list = MOrg.get_org_list m_org.org_lvl.to_i + 1, org_cd
      elsif m_org.org_lvl.to_i <= 2

        #次の階層でハイフンでない組織
        tmp_data = MOrg.get_org_list_consider_hyphen m_org.org_lvl.to_i + 1, org_cd, 0
        tmp_data.each do |tmp|
          @org_list << tmp
        end
        #次の階層がハイフンの組織
        tmp_data = MOrg.get_org_list_consider_hyphen m_org.org_lvl.to_i + 2, org_cd, 1
        tmp_data.each do |tmp|
          @org_list << tmp
        end
      end
      
      @user_list = MUser.get_user_list_by_position_and_keword m_org.org_cd, nil, nil
      @user_list_array = Array.new
      unless @org_list.nil?
        @org_list.each do |org|
          array = MUser.new.get_user_list_by_org_cd org.org_cd
          @user_list_array << array
        end
      end
    end
  end
  
end
