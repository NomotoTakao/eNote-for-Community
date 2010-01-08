class Master::BbsController < ApplicationController
  layout "portal",
  :except=>[:master_tab, :_master_info, :save_master_info, :board_tab, :detail_bbs_board, :save_bbs_board, :tree_org, :undecided_member]

  def index
    @pankuzu += "掲示板設定"
  end

  #
  # 「共通」タブを押下した時のアクション
  #
  def master_tab
    @m_bbs_settings = MBbsSetting.find(:first, :conditions=>{:delf=>0})
  end

  #
  # マスタ情報を取得するアクション
  #
  def _master_info
    @result = params[:result]
    @m_bbs_settings = MBbsSetting.find(:first, :conditions=>{:delf=>0})
  end

  #
  # マスタ情報を保存するアクション
  #
  def save_master_info

    new_icon_days = params[:m_bbs_settings][:new_icon_days]
    page_max_count = params[:m_bbs_settings][:page_max_count]

    m_bbs_setting = MBbsSetting.find(:first, :conditions=>{:delf=>0})
    m_bbs_setting.new_icon_days = new_icon_days
    m_bbs_setting.page_max_count = page_max_count
    m_bbs_setting.updated_user_cd = current_m_user.user_cd
    begin
      m_bbs_setting.save
      result = 1
    end

    redirect_to :action=>:_master_info, :result=>result
  end

  #
  # 掲示板編集タブを開く
  #
  def board_tab
    #全掲示板のデータを取得する
    @bbs_list = DBbsBoard.find(:all, :conditions=>{:delf=>0}, :order=>"sort_no")
  end

  #
  # 編集ボードの詳細情報を取得する(該当データ1件のみ)
  #
  def detail_bbs_board
    @board_id = params[:board_id].to_i #編集するデータのboard_id
    #掲示板インデックス
    @target_bbs_data = DBbsBoard.find(:first, :conditions=>["id = ? and delf = ?", @board_id, 0])
    #掲示板権限データ
    @org_auth_decide = DBbsAuth.get_bbs_auth_list @board_id, 2, 0   #参照/書き込み可能組織
    @user_auth_decide = DBbsAuth.get_bbs_auth_list @board_id, 2, 1  #参照/書き込み可能社員
  end

  #
  # 掲示板編集タブの内容を保存する
  #
  def save_bbs_board
    begin
      submit_flg = params[:submit_flg].to_i  #1:登録,2:更新,3:削除
      board_id = params[:board_id].to_i #ボードID(更新,削除の場合のみ値が入っている)

      #** データチェック **
      #削除の場合
      if submit_flg == 3
        err_msg = "削除しようとしたボードの下階層にデータが存在する為、削除できませんでした。"

        #削除するボードに登録しているデータがないかチェック
        thread_data = DBbsThread.find(:all, :conditions=>["d_bbs_board_id = ? and delf = ?", board_id, 0])
        if !thread_data.nil? && thread_data.size > 0
          flash[:bbs_board_err_msg] = err_msg
          redirect_to :action=>:index
          return
        end
      end

      #** データ登録 **
      #掲示板ボード
      if submit_flg == 3  #削除
        DBbsBoard.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["id = ?", board_id])
      else
        if submit_flg == 1  #登録
          m_bbs = DBbsBoard.new
        elsif submit_flg == 2 #更新
          m_bbs = DBbsBoard.find(:first, :conditions=>["id = ? and delf = ?", board_id, 0])
        end
        m_bbs.title = params[:target_bbs_data][:title]
        m_bbs.sort_no = params[:target_bbs_data][:sort_no]
        m_bbs.memo = params[:target_bbs_data][:memo]
        m_bbs.created_user_cd = current_m_user.user_cd
        m_bbs.updated_user_cd = current_m_user.user_cd
        m_bbs.save!
        board_id = m_bbs.id  #ボードID
      end

      #掲示板権限データ
      if submit_flg == 3  #削除
        DBbsAuth.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["d_bbs_board_id = ?", board_id])
      else
        if submit_flg == 2  #更新
          DBbsAuth.delete_all(["d_bbs_board_id = ?", board_id])
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
            m_bbs = DBbsAuth.new
            m_bbs.d_bbs_board_id = board_id
            m_bbs.org_cd = org
            m_bbs.user_cd = ''
            m_bbs.auth_kbn = 2
            m_bbs.created_user_cd = current_m_user.user_cd
            m_bbs.updated_user_cd = current_m_user.user_cd
            m_bbs.save
          }
        end
        #社員
        users.each { |user|
          m_bbs = DBbsAuth.new
          m_bbs.d_bbs_board_id = board_id
          m_bbs.org_cd = '0'
          m_bbs.user_cd = user
          m_bbs.auth_kbn = 2
          m_bbs.created_user_cd = current_m_user.user_cd
          m_bbs.updated_user_cd = current_m_user.user_cd
          m_bbs.save
        }
      end

    rescue => ex
      flash[:bbs_board_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "DBbsBoard Err => #{ex}"
      redirect_to :action=>:index
      return
    end

    redirect_to :action=>:index
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
end
