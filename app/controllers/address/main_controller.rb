class Address::MainController < ApplicationController
  layout "portal", :except => [:addrs_list, :clear_return, :edit, :new, :create, :condition, :update, :tmp_list]

  def index
    #パンくずリストに表示させる
    @pankuzu += "アドレス帳"

    #id取得(サイト内検索から遷移してきた場合のみ値が入っている)
    @adr_id = params[:adr_id]
    addrs_list()
  end

  #エリアをクリアするために使用する
  def clear_return
    render :text => ' '
  end

  def addrs_list  #初期表示/あいまい検索/(プルダウン下のエリアから)特定の条件を選択時
    #改ページの行数
    max_page_record = 20
    page = params[:page]
    @proid = 0
    @orgcd = ''
    @sword = ''
    @address_kbn = '9'

    #特定のプロジェクトを選択
    if !(params[:proid].nil? || params[:proid].to_s == '' || params[:proid].to_s == '0')
      @address_kbn = params[:gkbn]
      @proid = params[:proid]
      @addresses = DAddress.get_project_user_info(@proid, page, max_page_record, 1)

    #特定の組織を選択
    elsif !(params[:orgcd].nil? || params[:orgcd] == '')
      @address_kbn = params[:gkbn]
      @orgcd = params[:orgcd]
      @addresses = DAddress.get_orgs_user_info(@orgcd, page, max_page_record, 1)

    #あいまい検索(名前/カナ/メールアドレス/検索キーワード)
    elsif !params[:sword].nil? && params[:sword] != ''
      @address_kbn = 9
      @sword = params[:sword]
      @addresses = DAddress.get_sword_user_info(@sword, current_m_user.user_cd, page, max_page_record, 1)

    #特定の共用グループを選択
    elsif params[:gkbn].to_s == '8'
      @address_kbn = params[:gkbn]
      @gid = params[:gid]
      @addresses = DAddress.get_public_group_info(@gid, page, max_page_record, 1)

    #特定の個人用グループを選択
    elsif params[:gkbn].nil? || params[:gkbn] == '' || params[:gkbn].to_s == '9'
      @address_kbn = 9
      #初期状態 or グループ「全て」を選択
      if params[:gid].nil? || params[:gid] == '' || params[:gid].to_s == '0'
        @gid = 0
      #特定の個人グループを選択
      else
        @gid = params[:gid]
      end
      @addresses = DAddress.get_mygroup_info(@gid, current_m_user.user_cd, page, max_page_record, 1)
    end

    @result_flg = params[:result_flg]
    @result_mode = params[:result_mode]
  end

  def condition  #プルダウンで「メーカー/社員/プロジェクト/共用グループ/個人用」を選択した場合
    @address_kbn = params[:gkbn]

    #有効なデータを取得
    if @address_kbn == '1'    #社員
      #組織M(最上位の組織だけを取得)
      @m_orgs = MOrg.get_org_list 1, nil

    elsif @address_kbn == '2'    #プロジェクト
      #プロジェクトM
      @m_projects = MProject.get_project_all_enable_list(Date.today.strftime("%Y-%m-%d"))

    elsif @address_kbn == '8'    #共用グループ
      #アドレス帳グループ
      @d_address_group = DAddressGroup.get_all_user_group('0')

    elsif @address_kbn == '9'    #個人用
      #アドレス帳グループ
      @d_address_group = DAddressGroup.get_all_user_group(current_m_user.user_cd)
    end
  end

  def edit  #編集リンク
    @d_address = DAddress.find(:first, :conditions => ['id = ? and delf = ?', params[:adr_id], 0])
    @d_address_group = DAddressGroup.find(:all, :conditions => ['private_user_cd = ? and delf = ?', current_m_user.user_cd, 0])
    @member_address_kbn = @d_address.address_kbn
    m_user = MUser.find(:first, :conditions => ["user_cd = ? and delf = ?", @d_address.created_user_cd.to_s, 0])
    if m_user.nil?
      @create_user_name = ""
    else
      @create_user_name = m_user.name
    end

    #社員の場合
    if @member_address_kbn == 1
      #組織を取得
      @org_list = get_org_list(@d_address.user_cd)
    end

    #更新、削除ボタン制御
    if @d_address.address_kbn == 9
        @no_edit_mode = false
    else
        @no_edit_mode = true
    end

  end

  def update  #更新ボタン
    begin
      #アドレス帳データ
      @d_address = DAddress.find(:first, :conditions => ['id = ? and delf = ?', params[:id], 0])
      params[:d_address][:updated_user_cd] = current_m_user.user_cd

      @d_address.update_attributes(params[:d_address])
      redirect_to :action => 'addrs_list', :result_flg => 1, :result_mode => 2
    rescue => ex
      flash[:address_err_msg] = "処理中に異常が発生しました。"
      logger.error "DAddress Err => #{ex}"
      redirect_to :action => 'index'
    end
  end

  def delete  #削除ボタン
    begin
      #アドレス帳データ
      rec = DAddress.find(:first, :conditions => ['id = ? and delf = ?', params[:id], 0])
      rec.delf = '1'
      rec.deleted_user_cd = current_m_user.user_cd
      rec.save
      redirect_to :action => 'addrs_list', :result_flg => 1, :result_mode => 3
    rescue => ex
      flash[:address_err_msg] = "処理中に異常が発生しました。"
      logger.error "DAddress Err => #{ex}"
      redirect_to :action => 'index'
    end
  end

  def new  #連絡先追加ボタン
    @d_address = DAddress.new
    @read_kbn = false
    @result_flg = params[:result_flg]
  end

  def create  #追加ボタン
    begin
      @d_address = DAddress.new(params[:d_address])
      @d_address.address_kbn = 9
      @d_address.private_user_cd = current_m_user.user_cd
      @d_address.created_user_cd = current_m_user.user_cd
      @d_address.updated_user_cd = current_m_user.user_cd

      @d_address.save
      if params[:next_form].to_s == "2"  #新規画面へ
        redirect_to :action => 'new', :result_flg => 1
      else  #一覧画面へ
        redirect_to :action => 'addrs_list', :result_flg => 1, :result_mode => 1
      end
    rescue => ex
      flash[:address_err_msg] = "処理中に異常が発生しました。"
      logger.error "DAddress Err => #{ex}"
      redirect_to :action => 'index'
    end
  end

  #ユーザが所属する部署情報を取得
  def get_org_list(user_cd)
    #所属M/組織M
    sql =  " SELECT a.* "
    sql += " , b.org_lvl "
    sql += " , b.org_name4 "
    sql += " , b.org_name3 "
    sql += " , b.org_name2 "
    sql += " , b.org_name1 "
    sql += " , case "
    sql += "     when trim(b.org_name4) != '' and trim(b.org_name3) != '-' then b.org_name3 || ' ' || b.org_name4"
    sql += "     when trim(b.org_name4) != '' and trim(b.org_name3) != '' then b.org_name2 || ' ' || b.org_name4"
    sql += "     when trim(b.org_name3) != '' then b.org_name3"
    sql += "     when trim(b.org_name2) != '' then b.org_name2"
    sql += "     when trim(b.org_name1) != '' then b.org_name1"
    sql += "   end "
    sql += " FROM m_user_belongs a "
    sql += "    , m_orgs b "
    sql += " WHERE a.delf = '0'"
    sql += " AND b.delf = '0'"
    sql += " AND a.org_cd = b.org_cd"
    sql += " AND a.user_cd = '" + user_cd + "'"

    org_list = MUserBelong.find_by_sql(sql)
    return org_list
  end

  #2階層目以降の組織ツリー表示
  def tmp_list
    org_cd = params[:org_cd]
    @address_kbn = params[:gkbn]

    m_org = MOrg.find(:first, :conditions=>{:delf=>0, :org_cd=>org_cd})
    @tmp_list = []

    #3,4階層目がクリックされた場合
    if m_org.org_lvl.to_i >= 3
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

end
