class Common::EmergencySearchController < ApplicationController

  #
  # 緊急メール送付先選択ウインドウを開きます。
  #
  def index
    @count = params[:count]
    @cd_field = params[:cd_field]
    @name_field = params[:name_field]

  end

  #
  # 組織ツリーの階層ごとの厚生をおこないます。
  #
  def tmp_tree

    @count = params[:count]
    org_cd = params[:org_cd]
    org_lvl = params[:org_lvl]
    if org_lvl.nil? or org_lvl.empty?
      org_lvl = 1
    end
    m_org = MOrg.new.get_org_info org_cd
    @org_list = Array.new
    if m_org.nil?
      @org_list = MOrg.get_org_list org_lvl, org_cd
    else
      #3,4階層目がクリックされた場合
      if m_org.org_lvl.to_i >= 3
        # 選択された組織の下位組織一覧を取得(下位の組織を取得するので、組織レベルをインクリメントしている)
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

  #
  # 指定された組織に所属するユーザーの一覧を構成します。
  #
  def user_list
    org_cd = params[:org_cd]
    @user_list = MUser.get_user_list_by_position_and_keword org_cd, nil, nil
  end

end
