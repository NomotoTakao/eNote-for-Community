require "date"
class Master::CalendarController < ApplicationController
  layout "portal", :except => [:master_list]
  PANKUZU = "カレンダーマスタ"

  def index
    #パンくずリストに表示させる
    @pankuzu += PANKUZU
  end

  #一覧を表示
  def master_list
    #カレンダーマスタ
    @m_calendars = MCalendar.get_calendar_all_list()
  end

  #登録画面を表示
  def new
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #カレンダーマスタ
    @m_calendars = MCalendar.new
    @m_calendars.day = Date.today
  end

  #登録処理
  def create
    begin
      #カレンダーマスタ
      data = MCalendar.new(params[:m_calendars])
      data.delf = 0
      data.holiday_flg = params[:select_holiday_flg].to_i
      data.created_user_cd = current_m_user.user_cd
      data.updated_user_cd = current_m_user.user_cd
      data.save

    rescue => ex
      flash[:calendar_err_msg] = "登録処理中に異常が発生しました。"
      logger.error "MCalendar Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #編集画面を表示
  def edit
    #パンくずリストに表示させる
    @pankuzu += PANKUZU

    #カレンダーマスタ
    @m_calendars = MCalendar.find(params[:id])
  end

  #更新処理
  def update
    begin
      #カレンダーマスタ
      data = MCalendar.find(:first, :conditions => ['id = ? and delf = ?', params[:m_calendars]["id"], 0])
      data.holiday_flg = params[:select_holiday_flg].to_i
      data.updated_user_cd = current_m_user.user_cd
      data.update_attributes(params[:m_calendars])

    rescue => ex
      flash[:calendar_err_msg] = "更新処理中に異常が発生しました。"
      logger.error "MCalendar Err => #{ex}"
    end
    redirect_to :action => "index"
  end

  #削除処理
  def delete
    begin
      #カレンダーマスタ
      MCalendar.update(params[:id], {:delf=>1, :deleted_user_cd=>current_m_user.user_cd, :deleted_at=>Time.now})

    rescue => ex
      flash[:calendar_err_msg] = "削除処理中に異常が発生しました。"
      logger.error "MCalendar Err => #{ex}"
    end
    redirect_to :action => "index"
  end
end