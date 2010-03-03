class Common::PublicOrgController < ApplicationController

  def index
    @org_list = MOrg.find(:all, :conditions=>{:delf=>0, :org_lvl=>1}, :order=>" org_cd ASC")
  end

  def tmp
    org_cd = params[:org_cd]
    m_org = MOrg.find(:first, :conditions=>{:delf=>0, :org_cd=>org_cd})

    @org_list = []

    #3,4階層目がクリックされた場合
    if m_org.org_lvl.to_i >= 3
      @org_list = MOrg.get_org_list m_org.org_lvl.to_i + 1, org_cd

    #1,2階層目がクリックされた場合
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
  end

end
