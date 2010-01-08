require "date"
class Master::ProjectUserController < ApplicationController
  layout "portal", :except => [:master_list, :select_member, :decided_member, :undecided_member, :tree_org]
  PANKUZU = "プロジェクトユーザマスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #プロジェクトマスタ
    @m_projects = MProject.get_project_all_enable_list(Date.today.strftime("%Y-%m-%d"))
  end

  #一覧を表示
  def master_list
  end

  #選択メンバーエリアを表示
  def select_member
  end

  #選択決定エリアを表示
  def decided_member
    #プロジェクトユーザマスタより、プロジェクトコードに含まれるデータを取得
    @member_decide = MProjectUser.get_project_user_list(params[:project_id])
  end

  #選択候補エリアを表示
  def undecided_member
    #ユーザー所属マスタより、組織コードに含まれるデータを取得
    @member_undecide = MUserBelong.get_belong_member_list(params[:orgcd])
  end

  #社員ツリーエリアを表示
  def tree_org
    #組織マスタ
    @m_orgs = MOrg.new.get_orgs
  end

  #更新処理
  def update
    begin
      #プロジェクトユーザマスタ
      #削除
      MProjectUser.delete_all(["project_id = ?", params[:project_id]])

      #追加
      decided_member_all = params[:decided_member_all][0].split(",")
      decided_member_all.each { |member|
        data = MProjectUser.new
        data.project_id = params[:project_id]
        data.user_cd = member
        data.delf = 0
        data.created_user_cd = current_m_user.user_cd
        data.updated_user_cd = current_m_user.user_cd
        data.save
      }

    rescue => ex
      flash[:project_user_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MProjectUser Err => #{ex}"
    end
    redirect_to :action => "index"
  end
end