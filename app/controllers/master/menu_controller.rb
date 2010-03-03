require "date"
class Master::MenuController < ApplicationController
  layout "portal", :except => [:master_list, :master_click_list, :detail, :tree_org, :undecided_member]
  PANKUZU = "メニューマスタ"

  #
  # メニューを表示する
  #
  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU
  end

  #
  # 該当のメニューデータを取得する
  # 1～4階層のデータをクリックした際に次の階層データを取得する
  #
  def master_click_list
    parent_id = params[:parent_id].to_i #親ID
    @menu_kbn = params[:menu_kbn].to_i  #メニュー区分
    @target_level = params[:target_level].to_i  #対象の階層

    #該当データを取得する
    menu_list = MMenu.get_item_by_parent_menuid_menukbn @menu_kbn, parent_id

    if @target_level == 2
      #2階層目のデータを取得する
      @second_menu_list = menu_list
    elsif @target_level == 3
      #3階層目のデータを取得する
      @third_menu_list = menu_list
    elsif @target_level == 4
      #4階層目のデータを取得する
      @fourth_menu_list = menu_list
    elsif @target_level == 5
      #5階層目のデータを取得する
      @fifth_menu_list = menu_list
    end
  end

  #
  # 編集メニューの階層データを取得する(階層データ全て)
  #
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    @parent_id = params[:parent_id].to_i #親ID
    @menu_kbn = params[:menu_kbn].to_i  #メニュー区分
    @target_level = params[:target_level].to_i  #対象の階層

    #選択された階層の全データ取得
    @edit_menu_list = MMenu.get_item_by_parent_menuid_menukbn @menu_kbn, @parent_id

    #表示順のカンマ区切りリストを作成(重複チェックの為)
    @sort_no_colon = get_sort_no_colon()
  end

  #
  # 編集メニューの詳細情報を取得する(該当データ1件のみ)
  #
  def detail
    @target_level = params[:target_level].to_i  #階層
    @id = params[:id].to_i #編集するデータのid

    #必要な情報を設定する
    if @id == 0
      #メニューマスタ
      @m_menus = MMenu.new
      @m_menus.sort_no = ""
    else
      #メニューマスタ
      @m_menus = MMenu.find(:first, :conditions=>["id = ? and delf = ?", @id, 0])
    end
    #メニュー権限マスタ
    @org_auth_decide = MMenuAuth.get_menu_auth_list @id, 0   #参照/書き込み可能組織
    @user_auth_decide = MMenuAuth.get_menu_auth_list @id, 1  #参照/書き込み可能社員

  end

  #
  # 登録処理(メニュー)
  #
  def save
    begin
      submit_flg = params[:submit_flg].to_i     #1:登録,2:更新,3:削除
      id = params[:id].to_i                     #ID(更新,削除の場合のみ値が入っている)
      target_level = params[:target_level].to_i #階層
      menu_kbn = params[:menu_kbn].to_i         #メニュー区分
      parent_id = params[:parent_id].to_i       #親ID

      #** データチェック **
      if submit_flg == 3
        err_msg = "削除しようとしたメニューの下階層にデータが存在する為、削除できませんでした。"

        #削除するメニューに登録しているデータがないかチェック
        #2階層目
        if target_level >= 2
          child_data = MMenu.get_item_by_parent_menuid_menukbn menu_kbn, id
        end
        if !child_data.nil? && child_data.size > 0
          flash[:menu_err_msg] = err_msg
          responds_to_parent do
            render :update do |page|
              page << "location.href='#{@base_uri}/master/menu/index'"
            end
          end
          return
        end
      end

      #** データ登録 **
      #メニュー
      if submit_flg == 3  #削除
        MMenu.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["id = ?", id])
      else
        if submit_flg == 1  #登録
          m_menu = MMenu.new
        elsif submit_flg == 2 #更新
          m_menu = MMenu.find(:first, :conditions=>["id = ? and delf = ?", id, 0])
        end
        m_menu.parent_menu_id = parent_id
        m_menu.sort_no = params[:m_menus][:sort_no]
        m_menu.title = params[:m_menus][:title]
        m_menu.url = params[:m_menus][:url]
        if params[:m_menus][:target].to_i == 1
          m_menu.target = "_self"
        else
          m_menu.target = "_blank"
        end
        m_menu.menu_kbn = menu_kbn
        m_menu.memo = params[:m_menus][:memo]
        m_menu.created_user_cd = current_m_user.user_cd
        m_menu.updated_user_cd = current_m_user.user_cd
        m_menu.save!
      end

      #メニュー権限
      if submit_flg == 3  #削除
        MMenuAuth.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["menu_id = ?", id])
      else
        if submit_flg == 2  #更新
          MMenuAuth.delete_all(["menu_id = ?", m_menu.id])
        end

        #参照/書き込み可能データを作成する
        orgs = '0'  #組織
        users = ''  #社員
        if !params[:decided_auth_org_all].nil? && params[:decided_auth_org_all] != ""
          orgs = params[:decided_auth_org_all].split(",")
        end
        if !params[:decided_auth_user_all].nil? && params[:decided_auth_user_all] != ""
          users = params[:decided_auth_user_all].split(",")
        end
        #組織
        if !(orgs == '0' && users != '')  #不要なデータを作らない為の制御
          orgs.each { |org|
            m_menu_auth = MMenuAuth.new
            m_menu_auth.menu_id = m_menu.id
            m_menu_auth.org_cd = org
            m_menu_auth.user_cd = ''
            m_menu_auth.created_user_cd = current_m_user.user_cd
            m_menu_auth.updated_user_cd = current_m_user.user_cd
            m_menu_auth.save
          }
        end
        #社員
        users.each { |user|
          m_menu_auth = MMenuAuth.new
          m_menu_auth.menu_id = m_menu.id
          m_menu_auth.org_cd = ''
          m_menu_auth.user_cd = user
          m_menu_auth.created_user_cd = current_m_user.user_cd
          m_menu_auth.updated_user_cd = current_m_user.user_cd
          m_menu_auth.save
        }
      end

    rescue => ex
      flash[:menu_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "MMenu Err => #{ex}"
      responds_to_parent do
        render :update do |page|
          page << "location.href='#{@base_uri}/master/menu/index'"
        end
      end
      return
    end

    responds_to_parent do
      render :update do |page|
        page << "location.href='#{@base_uri}/master/menu/index'"
      end
    end
  end

  #
  #社員ツリーエリアを表示
  #
  def tree_org
    #組織マスタ
    @m_orgs = MOrg.new.get_orgs
  end

  #
  #選択候補エリアを表示
  #
  def undecided_member
    @org_cd = params[:orgcd]
    @org_name = params[:orgnm]
    #ユーザー所属マスタより、組織コードに含まれるデータを取得
    @member_undecide = MUserBelong.get_belong_member_list(params[:orgcd])
  end

private

  #選択した階層の表示順リスト(カンマ区切り)を作成
  def get_sort_no_colon()
    sort_no_colon = ""
    @edit_menu_list.each { |edit_menu|
      sort_no_colon += edit_menu.sort_no.to_s + ","
    }

    return sort_no_colon
  end

end