require "date"
class Schedule::SettingController < ApplicationController
  layout "portal"

  def index
    #パンくずリストに表示させる
    @pankuzu += "スケジュールの詳細設定"

    #スケジュール設定テーブル
    @d_schedule_setting = DScheduleSetting.find(:first, :conditions => ["user_cd = ? and delf = ?", current_m_user.user_cd, 0])

    #**ログインユーザが所属する部署/プロジェクト情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    project_list = MProject.get_project_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #**秘書マスタよりデータ取得**
    @secretaries_user_list = MSecretary.get_secretary_authorize_list(org_colon_list, current_m_user.user_cd, 0)
    if @secretaries_user_list.size > 0
      @secretaries_flg = 1
    else
      @secretaries_flg = 0
    end

    #参照できる所属リスト[所属フラグ(1:秘書機能, 2xy:部署, 3:プロジェクト), コード, 名称]の作成
    #x(表示階層)1:1階層下,2:2階層下,3:1階層上    y(選択組織)組織の階層
    @belong_list = DSchedule.get_visible_belong_list(org_list, project_list, 0, nil, current_m_user.user_cd, @secretaries_flg)

    #**選択された所属を取得**
    if !@d_schedule_setting.nil? && @d_schedule_setting != ""
      @other_checked_id = @d_schedule_setting.other_member_init
    end
  end

  def create
    begin
      #スケジュール設定データのdelete処理
      delete_table()

      #スケジュール設定データへのinsert処理
      insert_table()

    rescue => ex
      flash[:schedule_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "DSchedule Err => #{ex}"
    end
    redirect_to :action => "index"
  end

private

  #スケジュール設定データのdelete処理
  def delete_table()
    #スケジュール設定データ
    DScheduleSetting.delete_all(["user_cd = ?", current_m_user.user_cd])
  end

  #スケジュール設定データへのinsert処理
  def insert_table()
    #スケジュール設定データ
    @d_schedule_setting = DScheduleSetting.new()
    @d_schedule_setting.week_start_flg = params[:week_start_flg]
    @d_schedule_setting.set_time_interval_flg = params[:set_time_interval_flg]
    @d_schedule_setting.other_member_init = params[:other_member_init]
    @d_schedule_setting.user_cd = current_m_user.user_cd
    @d_schedule_setting.created_user_cd = current_m_user.user_cd
    @d_schedule_setting.updated_user_cd = current_m_user.user_cd
    @d_schedule_setting.save
  end

  #部署リストをカンマ編集する
  #org_list:部署リスト
  def edit_org_colon(org_list)
    org_colon_list = ""
    for i in 0..(org_list.size - 1)
      org = org_list[i]
      if i > 0
        org_colon_list += ","
      end
      org_colon_list += "'"
      org_colon_list += org.org_cd
      org_colon_list += "'"
    end
    return org_colon_list
  end
end
