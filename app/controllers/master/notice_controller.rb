class Master::NoticeController < ApplicationController
  layout "portal",
  :except=>[:master_tab, :_master, :save_master, :board_tab, :notice_board_list, :edit_notice_board, :detail_notice_board, :tree_org, :undecided_member]

  def index
    @pankuzu += "お知らせ設定"

  end

  #
  # 共通タブを開く
  #
  def master_tab
    @m_notice_settings = MNoticeSetting.find(:first, :conditions=>{:delf=>0})
  end

  #
  # 共通の詳細を表示する
  #
  def _master
    @result = params[:result]
    @m_notice_settings = MNoticeSetting.find(:first, :conditions=>{:delf=>0})
  end

  #
  # 共通タブの内容で更新する
  #
  def save_master
    new_icon_days = params[:m_notice_settings][:new_icon_days]
    page_max_count = params[:m_notice_settings][:page_max_count]

    m_notice_settings = MNoticeSetting.find(:first, :conditions=>{:delf=>0})
    m_notice_settings.new_icon_days = new_icon_days
    m_notice_settings.page_max_count = page_max_count
    begin
      m_notice_settings.save
      result = 1
    end

    redirect_to :action=>:_master, :result=>result
  end

  #
  # お知らせ編集タブを開く
  #
  def board_tab
    #1階層目のデータを取得する
    @first_notice_list = DNoticeIndex.get_notice_board_list 0
  end

  #
  # 該当のお知らせデータを取得する
  # 1,2階層のデータをクリックした際に次の階層データを取得する
  #
  def notice_board_list
    parent_id = params[:parent_id].to_i
    @target_level = params[:target_level].to_i
    if @target_level == 2
      #2階層目のデータを取得する
      @second_notice_list = DNoticeIndex.get_notice_board_list parent_id
    elsif @target_level == 3
      #3階層目のデータを取得する
      @third_notice_list = DNoticeIndex.get_notice_board_list parent_id
    end
  end

  #
  # 編集ボードの階層データを取得する(階層データ全て)
  #
  def edit_notice_board
    parent_id = params[:parent_id].to_i
    if parent_id == 0
      @parent_index_type = "f"
    else
      parent_index_data = DNoticeIndex.get_noticeindex_by_head_id parent_id
      @parent_index_type = parent_index_data.index_type
    end
    @edit_notice_list = DNoticeIndex.get_notice_board_list parent_id
  end

  #
  # 編集ボードの詳細情報を取得する(該当データ1件のみ)
  #
  def detail_notice_board
    @head_id = params[:head_id].to_i #編集するデータのhead_id
    #お知らせインデックス
    @target_notice_data = DNoticeIndex.find(:first, :conditions=>["d_notice_head_id = ? and delf = ?", @head_id, 0])
    #お知らせ権限データ
    @org_auth_decide_r = DNoticeAuth.get_notice_auth_list @head_id, 1, 0   #参照可能組織
    @user_auth_decide_r = DNoticeAuth.get_notice_auth_list @head_id, 1, 1  #参照可能社員
    @org_auth_decide_w = DNoticeAuth.get_notice_auth_list @head_id, 2, 0   #書き込み可能組織
    @user_auth_decide_w = DNoticeAuth.get_notice_auth_list @head_id, 2, 1  #書き込み可能社員
  end

  #
  # お知らせ編集タブの内容を保存する
  #
  def save_notice_board
    begin
      submit_flg = params[:submit_flg].to_i  #1:登録,2:更新,3:削除
      head_id = params[:head_id].to_i #ヘッダID(更新,削除の場合のみ値が入っている)

      #** データチェック **
      #更新の場合
      if submit_flg == 2
        err_msg = "更新しようとしたボードの下階層にデータが存在する為、階層を変更できません。"
        index_type_old = params[:index_type_old]
        index_type_new = params[:index_type]

        #index_typeをfからbに変更する場合
        if index_type_old == "f" and index_type_new == "b"
          #更新するボードを親とするデータがないかチェック
          child_data = DNoticeIndex.find(:all, :conditions=>["parent_notice_head_id = ? and delf = ?", head_id, 0])
          if !child_data.nil? && child_data.size > 0
            flash[:notice_board_err_msg] = err_msg
            redirect_to :action=>:index
            return
          end

        #index_typeをbからfに変更する場合
        #更新するボードに登録しているデータがないかチェック
        elsif index_type_old == "b" and index_type_new == "f"
          body_data = DNoticeBody.find(:all, :conditions=>["d_notice_head_id = ? and delf = ?", head_id, 0])
          if !body_data.nil? && body_data.size > 0
            flash[:notice_board_err_msg] = err_msg
            redirect_to :action=>:index
            return
          end
        end

      #削除の場合
      elsif submit_flg == 3
        err_msg = "削除しようとしたボードの下階層にデータが存在する為、削除できませんでした。"

        #削除するボードを親とするデータがないかチェック
        child_data = DNoticeIndex.find(:all, :conditions=>["parent_notice_head_id = ? and delf = ?", head_id, 0])
        if !child_data.nil? && child_data.size > 0
          flash[:notice_board_err_msg] = err_msg
          redirect_to :action=>:index
          return
        end
        #削除するボードに登録しているデータがないかチェック
        body_data = DNoticeBody.find(:all, :conditions=>["d_notice_head_id = ? and delf = ?", head_id, 0])
        if !body_data.nil? && body_data.size > 0
          flash[:notice_board_err_msg] = err_msg
          redirect_to :action=>:index
          return
        end
      end

      #** データ登録 **
      #お知らせヘッダ
      if submit_flg == 3  #削除
        DNoticeHead.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["id = ?", head_id])
      else
        if submit_flg == 1  #登録
          m_notice = DNoticeHead.new
        elsif submit_flg == 2 #更新
          m_notice = DNoticeHead.find(:first, :conditions=>["id = ? and delf = ?", head_id, 0])
        end
        m_notice.title = params[:target_notice_data][:title]
        m_notice.default_top_disp_kbn = 99
        m_notice.created_user_cd = current_m_user.user_cd
        m_notice.updated_user_cd = current_m_user.user_cd
        m_notice.save!
        head_id = m_notice.id  #ヘッダID
      end

      #お知らせインデックス
      if submit_flg == 3  #削除
        DNoticeIndex.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["d_notice_head_id = ?", head_id])
      else
        if submit_flg == 1  #登録
          m_notice = DNoticeIndex.new
        elsif submit_flg == 2 #更新
          m_notice = DNoticeIndex.find(:first, :conditions=>["d_notice_head_id = ? and delf = ?", head_id, 0])
        end
        m_notice.index_type = params[:index_type]
        m_notice.parent_notice_head_id = params[:parent_id]
        m_notice.d_notice_head_id = head_id
        m_notice.title = params[:target_notice_data][:title]
        m_notice.sort_no = params[:target_notice_data][:sort_no]
        m_notice.etcint2 = params[:target_notice_data][:etcint2]
        m_notice.created_user_cd = current_m_user.user_cd
        m_notice.updated_user_cd = current_m_user.user_cd
        m_notice.save
      end

      #お知らせ権限データ
      if submit_flg == 3  #削除
        DNoticeAuth.update_all("delf=1, deleted_user_cd='#{current_m_user.user_cd}', deleted_at=current_date", ["d_notice_head_id = ?", head_id])
      else
        if submit_flg == 2  #更新
          DNoticeAuth.delete_all(["d_notice_head_id = ?", head_id])
        end

        #参照可能データ,書き込み可能データを作成する
        for i in 1..2
          orgs = '0'  #組織
          users = ''  #社員
          if i == 1 #参照権限
            if !params[:decided_auth_org_all_r].nil? && params[:decided_auth_org_all_r] != ""
              orgs = params[:decided_auth_org_all_r].split(",")
            end
            if !params[:decided_auth_user_all_r].nil? && params[:decided_auth_user_all_r] != ""
              users = params[:decided_auth_user_all_r].split(",")
            end
          else  #書き込み権限
            if !params[:decided_auth_org_all_w].nil? && params[:decided_auth_org_all_w] != ""
              orgs = params[:decided_auth_org_all_w].split(",")
            end
            if !params[:decided_auth_user_all_w].nil? && params[:decided_auth_user_all_w] != ""
              users = params[:decided_auth_user_all_w].split(",")
            end
          end
          #組織
          if !(orgs == '0' && users != '')  #不要なデータを作らない為の制御
            orgs.each { |org|
              m_notice = DNoticeAuth.new
              m_notice.d_notice_head_id = head_id
              m_notice.org_cd = org
              m_notice.user_cd = ''
              m_notice.auth_kbn = i
              m_notice.created_user_cd = current_m_user.user_cd
              m_notice.updated_user_cd = current_m_user.user_cd
              m_notice.save
            }
          end
          #社員
          users.each { |user|
            m_notice = DNoticeAuth.new
            m_notice.d_notice_head_id = head_id
            m_notice.org_cd = '0'
            m_notice.user_cd = user
            m_notice.auth_kbn = i
            m_notice.created_user_cd = current_m_user.user_cd
            m_notice.updated_user_cd = current_m_user.user_cd
            m_notice.save
          }
        end
      end

    rescue => ex
      flash[:notice_board_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "DNoticeHead Err => #{ex}"
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
