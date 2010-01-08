class Common::TreeController < ApplicationController

  #組織ツリー
  def disp_org
    #組織M
    @m_orgs = MOrg.get_org_list 1, nil
  end

  #パラメータに指定された組織コードに所属する社員を返す
  def disp_org_user
    @users = MOrg.get_org_user(params[:org_cd])
  end

  #
  # 組織ツリーの子要素をAJAXで取得するときの処理
  #
  def tmp_list
    org_cd = params[:org_cd]

    # ツリーで選択された組織の情報を取得
    m_org = MOrg.find(:first, :conditions=>{:delf=>0, :org_cd=>org_cd})
    @tmp_list = []

    #3,4階層目がクリックされた場合
    if m_org.org_lvl.to_i >= 3
      # 選択された組織の下位組織一覧を取得(下位の組織を取得するので、組織レベルをインクリメントしている)
      @tmp_list = MOrg.get_org_list m_org.org_lvl.to_i + 1, org_cd

    #1,2階層目がクリックされた場合
    elsif m_org.org_lvl.to_i <= 2
      #次の階層でハイフンでない組織
      tmp_data = MOrg.get_org_list_consider_hyphen m_org.org_lvl.to_i + 1, org_cd, 0
      tmp_data.each do |tmp|
        @tmp_list << tmp
      end
      #次の階層がハイフンの組織
      tmp_data = MOrg.get_org_list_consider_hyphen m_org.org_lvl.to_i + 2, org_cd, 1
      tmp_data.each do |tmp|
        @tmp_list << tmp
      end
    end
  end

  #組織ツリー（お知らせ、共有キャビネット）
  def disp_org_for_notice
    disp_org
  end

  # 組織ツリーの子要素をAJAXで取得するときの処理（お知らせ、共有キャビネット）
  def tmp_list_for_notice
    tmp_list
  end


end
