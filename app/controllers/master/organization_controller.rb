class Master::OrganizationController < ApplicationController
  layout "portal",
  :except => [:select_org, :input_form, :org_exists]

  skip_before_filter :verify_authenticity_token, :input_form

  #
  # 組織マスタのトップ画面を表示するアクション
  #
  def index
    @pankuzu += "組織マスタ"
  end

  #
  # 階層毎の組織リストを表示するアクション
  #
  def select_org
    @org_lvl = params[:org_lvl]
    org_cd = params[:org_cd]

    if @org_lvl.to_i == 1
      tmp_m_org = MOrg.find(:first, :order=>:sort_no)
    else
      # 削除操作を行った場合、delf=0を条件に含めると検索出来ないので、delf=0は条件から外している。
      tmp_m_org = MOrg.find(:first, :conditions=>{:org_cd=>org_cd}, :order=>:sort_no)
    end

    unless tmp_m_org.nil?
      if @org_lvl.to_i == 2
        tmp_org_cd = tmp_m_org.org_cd1
      elsif @org_lvl.to_i == 3
        tmp_org_cd = tmp_m_org.org_cd2
      elsif @org_lvl.to_i == 4
        tmp_org_cd = tmp_m_org.org_cd3
      end
    end

    sql  = "select * "
    sql += "from m_orgs "
    sql += "where delf=0 "
    sql += "  and org_lvl = :org_lvl "
    if @org_lvl.to_i > 1
      sql += "  and org_cd:target_lvl = ':org_cd' "
    end
    sql += "order by sort_no"

    sql.gsub!(':org_lvl', @org_lvl)
    sql.gsub!(':target_lvl', (@org_lvl.to_i - 1).to_s)
    sql.gsub!(':org_cd', tmp_org_cd.to_s)

    @m_orgs = MOrg.find_by_sql(sql)
  end

  #
  # 組織の入力/編集画面を表示するアクション
  #
  def input_form
    # どの階層の「選択」ボタンが押下されたのかを判断するためのパラメータ
    @org_lvl = params[:org_lvl]
    # 組織コードを取得し、その組織のレコードを返す
    org_cd = params[:org_cd]
    unless org_cd.nil? or org_cd.empty?
      @m_org = MOrg.find(:first, :conditions=>{:delf=>0, :org_cd=>org_cd})
    else
      @m_org = MOrg.new
    end
  end

  def org_exists

    m_org = MOrg.find(:first, :conditions=>{:delf=>0, :org_cd=>params[:org_cd]})
    unless m_org.nil?
      @msg = "指定されたCDの組織は既に登録されているので、登録できません。"
    end
  end

  #
  # 入力フォームの「追加」ボタンのアクション
  #
  def org_add
    MOrg.create_org params, current_m_user.user_cd

    if params[:org_lvl].to_i == 1
      parent_org_cd = ""
    elsif params[:org_lvl].to_i == 2
      parent_org_cd = params[:org_cd][0..3]
    elsif params[:org_lvl].to_i == 3
      parent_org_cd = params[:org_cd][0..5]
    end

    redirect_to :action=>:select_org, :org_lvl=>params[:org_lvl], :org_cd=>parent_org_cd
  end

  #
  # 入力フォームの「更新」ボタンのアクション
  #
  def org_update
    MOrg.update_org params, current_m_user.user_cd

    if params[:org_lvl].to_i == 1
      parent_org_cd = ""
    elsif params[:org_lvl].to_i == 2
      parent_org_cd = params[:org_cd][0..3]
    elsif params[:org_lvl].to_i == 3
      parent_org_cd = params[:org_cd][0..5]
    end

    redirect_to :action=>:select_org, :org_lvl=>params[:org_lvl], :org_cd=>parent_org_cd
  end

  #
  # 入力フォームの「削除」ボタンのアクション
  # 選択されている組織を論理削除する。
  #
  def org_delete
    MOrg.delete_org params, current_m_user.user_cd

    if params[:org_lvl].to_i == 1
      parent_org_cd = ""
    elsif params[:org_lvl].to_i == 2
      parent_org_cd = params[:org_cd][0..3]
    elsif params[:org_lvl].to_i == 3
      parent_org_cd = params[:org_cd][0..5]
    end

    redirect_to :action=>:select_org, :org_lvl=>params[:org_lvl], :org_cd=>parent_org_cd
  end

end
