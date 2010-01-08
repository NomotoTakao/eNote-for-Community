class Address::GroupController < ApplicationController
  layout "portal", :except => [:decided_member, :undecided_member, :clear_return, :edit, :new, :create, :condition, :update, :tmp_list]

  def index
    #パンくずリストに表示させる
    @pankuzu += "アドレス帳"
  end

  #エリアをクリアするために使用する
  def clear_return
    render :text => ' '
  end

  def decided_member  #グループの追加/更新(個人のみ可能)
    @addresses_undecide = nil  #選択候補エリア用のデータ
    @addresses_decide = nil    #選択決定エリア用のデータ

    #更新モードの場合
    if params[:mode].to_s == '1'
      #選択されたグループに属するメンバーを取得する
      sql = "SELECT a.* "
      sql += " FROM d_addresses a "
      sql += "  LEFT OUTER JOIN d_address_group_lists l "
      sql += "  ON a.id = l.d_address_id "
      sql += " WHERE "
      sql += "      a.delf = '0'"
      sql += " AND  l.delf = '0'"
      #個人用とその他連絡先
      sql += " AND ((a.address_kbn = 9 AND a.private_user_cd = '" + current_m_user.user_cd + "')"
      sql += " OR   a.address_kbn != 9) "
      #選択されたグループ
      sql += " AND l.d_address_group_id = " + params[:gid].to_s

      #並び順
      sql += " ORDER BY l.id"

      @addresses_decide = DAddress.find_by_sql(sql)
      @d_address_group = DAddressGroup.find(:first, :conditions => ['id = ? and delf = ?', params[:gid], 0])
    end
  end

  def undecided_member  #グループ選択/あいまい検索
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
      @addresses = DAddress.get_project_user_info(@proid, page, max_page_record, 0)

    #特定の組織を選択
    elsif !(params[:orgcd].nil? || params[:orgcd] == '')
      @address_kbn = params[:gkbn]
      @orgcd = params[:orgcd]
      @addresses = DAddress.get_orgs_user_info(@orgcd, page, max_page_record, 0)

    #あいまい検索(名前/カナ/メールアドレス/検索キーワード)
    elsif !params[:sword].nil? && params[:sword] != ''
      @address_kbn = 9
      @sword = params[:sword]
      @addresses = DAddress.get_sword_user_info(@sword, current_m_user.user_cd, page, max_page_record, 0)

    #特定の共用グループを選択
    elsif params[:gkbn].to_s == '8'
      @address_kbn = params[:gkbn]
      @gid = params[:gid]
      @addresses = DAddress.get_public_group_info(@gid, page, max_page_record, 0)

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
      @addresses = DAddress.get_mygroup_info(@gid, current_m_user.user_cd, page, max_page_record, 0)
    end

    @addresses_undecide = @addresses
  end

  def condition  #条件選択ボタン
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

  def update  #更新ボタン
    seccess_flg = 1  #処理フラグ(正常終了：1、異常終了：0)

    #アドレス帳グループ/アドレス帳グループリストのdelete処理
    delete_table()

    #アドレス帳グループ/アドレス帳グループリストへのinsert処理
    seccess_flg = insert_table()

    #処理が正常に終了した場合
    if seccess_flg == 1
      redirect_to '/address/main/'
    end
  end

  def delete  #削除ボタン
    #アドレス帳グループ/アドレス帳グループリストのdelete処理
    delete_table()
    redirect_to '/address/main/'
  end

  def create  #追加ボタン
    #アドレス帳グループ/アドレス帳グループリストへのinsert処理
    seccess_flg = insert_table()

    #処理が正常に終了した場合
    if seccess_flg == 1
      redirect_to '/address/main/'
    end
  end

  #2階層目以降の組織ツリー表示
  def tmp_list
    org_cd = params[:org_cd]

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

private

  #アドレス帳グループ/アドレス帳グループリストのdelete処理
  def delete_table()
    #アドレス帳グループ
    DAddressGroup.delete_all(["id = ?", params[:gid]])
    #アドレス帳グループリスト
    DAddressGroupList.delete_all(["d_address_group_id = ?", params[:gid]])
  end

  #アドレス帳グループ/アドレス帳グループリストへのinsert処理
  def insert_table()
    seccess_flg = 1  #処理フラグ(正常終了：1、異常終了：0)

    #アドレス帳グループ
    @d_address_group = DAddressGroup.new(params[:d_address_group])
    @d_address_group.private_user_cd = current_m_user.user_cd
    @d_address_group.created_user_cd = current_m_user.user_cd
    @d_address_group.updated_user_cd = current_m_user.user_cd
    #追加実行
    if @d_address_group.save!  #最新レコード取得
      #アドレス帳グループリスト
      decided_member_new = params[:decided_member_new][0].split(",")
      for address_id in decided_member_new
        rec = DAddressGroupList.new
        rec.private_user_cd = current_m_user.user_cd
        rec.d_address_group_id = @d_address_group.id
        rec.d_address_id = address_id
        rec.created_user_cd = current_m_user.user_cd
        rec.updated_user_cd = current_m_user.user_cd
        #追加実行
        if rec.save
        else
          seccess_flg = 0
        end
      end
    else
      seccess_flg = 0
    end

    return seccess_flg
  end
end
