require "date"
class Facility::ReserveController < ApplicationController
  layout "portal", :except => [:month, :week, :day, :list, :edit, :new]

  FACILITY = "施設予約"
  START_TIME = "07:00"
  END_TIME = "21:00"

  def index
    index_week
    render :action => "index_week"
  end

  def index_month
    #パンくずリストに表示させる
    @pankuzu += FACILITY
    month
  end

  def index_week
    #パンくずリストに表示させる
    @pankuzu += FACILITY
    week
  end

  def index_day
    #パンくずリストに表示させる
    @pankuzu += FACILITY
    day
  end

  def index_list
    #パンくずリストに表示させる
    @pankuzu += FACILITY
    list
  end

  def month
    #基準日の設定
    if params[:month]
      @current_date = (params[:month].to_s[0,4] + "-" + params[:month].to_s[4,2] + "-" + "01").to_date
    else
      @current_date = Date.today
    end
    @month = @current_date.strftime("%Y%m")

    #休日ハッシュを取得
    @holiday_hash_param = MCalendar.get_holiday_hash()
    @holiday_hash = MCalendar.get_holiday_hash()
    #イベントハッシュを取得
    @event_hash_param = MCalendar.get_event_hash()
    @event_hash = MCalendar.get_event_hash()

    #**ログインユーザが所属する部署情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #施設Mよりデータ取得
    org_edit_sql = MOrg.edit_org_consider_lvl(org_list)
    @facility_list = getfacility_list("", org_edit_sql)

    #施設が存在する場合
    if @facility_list.size > 0
      #選択された施設を取得
      if params[:facility_cd].nil? || params[:facility_cd]  == ""
        @select_facility_cd = @facility_list[0].facility_cd
      else
        @select_facility_cd = params[:facility_cd]
      end

      #施設予約データより情報を取得(月単位)
      #基準となる月の前後１か月
      reserves = get_facility_all_list_month()

      #日付に紐付く施設リスト作成
      @cell_reserves = []
      cell_reserves_work1 = []
      cell_reserves_work2 = []

      #配列[日跨りフラグ, 終日フラグ, 開始時間, 日付に紐付く施設リスト](ソート用)を作成
      reserves.each { |reserve|
        #開始日と終了日が異なる場合
        if reserve.plan_date_from.to_date < reserve.plan_date_to.to_date
          term = (reserve.plan_date_to.to_date - reserve.plan_date_from.to_date).to_i
          #途中の期間のデータも作成する
          for i in 0..term
            cell_reserves_work1 << [1, reserve.plan_allday_flg, reserve.plan_time_from.strftime("%H:%M"), reserve.plan_date_from.to_date + i, reserve]
          end
        else
          cell_reserves_work1 << [0, reserve.plan_allday_flg, reserve.plan_time_from.strftime("%H:%M"), reserve.plan_date_from.to_date, reserve]
        end
      }

      #ソート(日跨り>終日>開始時間)
      cell_reserves_work2 = cell_reserves_work1.sort{ |a,b|
        #優先度1:日跨り
        if a[0] == b[0]
          #優先度2:終日
          if a[1] == b[1]
            #優先度3:開始時間
            a[2] <=> b[2]
          else
            b[1] <=> a[1]
          end
        else
          b[0] <=> a[0]
        end
      }
      cell_reserves_work2.each { |reserve2|
        @cell_reserves << [reserve2[3], reserve2[4]]
      }

    #施設が存在しない場合
    else
    end

    #遷移元情報を格納
    session[:from_mode] = '3'
  end

  def week
    #基準日の設定
    if params[:week]
      @current_date = (params[:week].to_s[0,4] + "-" + params[:week].to_s[4,2] + "-" + params[:week].to_s[6,2]).to_date
    else
      @current_date = Date.today
    end

    #**ログインユーザが所属する部署情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #対象日付リストを作成
    @week_list = []
    current_week = @current_date.wday  #0:日曜..6:土曜
    #スケジュール設定テーブル
    setting_data = DScheduleSetting.find(:first, :conditions => ["user_cd = ? and delf = ?", current_m_user.user_cd, 0])
    if setting_data.nil?
      week_start_flg = 0
    else
      week_start_flg = setting_data.week_start_flg
    end
    #日曜開始の場合
    if week_start_flg == 1
      #今日が日曜日の場合
      if current_week == 0
        start_date = @current_date
      else
        start_date = @current_date - (current_week - 0)
      end
    #月曜開始の場合
    elsif week_start_flg == 2
      #今日が日曜日の場合
      if current_week == 1
        start_date = @current_date
      else
        start_date = @current_date - (current_week - 1)
      end
    #本日開始の場合
    else
      start_date = @current_date
    end
    end_date = start_date + 6
    for i in 0..6
      @week_list << [start_date + i]
    end
    session[:week_start_date] = start_date.strftime("%Y%m%d")

    #休日ハッシュを取得
    @holiday_hash = MCalendar.get_holiday_hash()
    #イベントハッシュを取得
    @event_hash = MCalendar.get_event_hash()

    #施設グループMよりデータ取得
    @facility_group_list = MFacilityGroup.find(:all, :conditions => ["delf = ?", 0], :order => "sort_no")

    #選択された施設グループコードを取得
    if params[:group_checked_id].nil? || params[:group_checked_id] == ""
      @group_checked_id = @facility_group_list[0].facility_group_cd
    else
      @group_checked_id = params[:group_checked_id]
    end

    #施設Mよりデータ取得
    org_edit_sql = MOrg.edit_org_consider_lvl(org_list)
    facility_list = getfacility_list(@group_checked_id, org_edit_sql)

    #施設が存在する場合
    if facility_list.size > 0
      #選択された施設を取得
      if params[:facility_cd].nil? || params[:facility_cd]  == ""
        @select_facility_cd = facility_list[0].facility_cd
      else
        @select_facility_cd = params[:facility_cd]
      end

      #配列[施設コード, 施設名, 施設リスト]を作成
      element_list_work = []
      for facility in facility_list
        #施設予約データより情報を取得(週単位)
        reserves = get_other_facility_all_list_week(facility.facility_cd, end_date)
        element_list_work << [facility.facility_cd, facility.name + "<br>" + facility.case, reserves]
      end

      #配列[施設コード, 施設名, 日付に紐付く施設リスト]を作成
      @element_list = []
      for element in element_list_work
        #日付に紐付く施設リスト作成
        cell_reserves = []
        cell_reserves_work1 = []
        cell_reserves_work2 = []
        @reserves = element[2]

        #配列[日跨りフラグ, 終日フラグ, 開始時間, 日付に紐付く施設リスト](ソート用)を作成
        @reserves.each { |reserve|
          #開始日と終了日が異なる場合
          if reserve.plan_date_from.to_date < reserve.plan_date_to.to_date
            term = (reserve.plan_date_to.to_date - reserve.plan_date_from.to_date).to_i
            #途中の期間のデータも作成する
            for i in 0..term
              cell_reserves_work1 << [1, reserve.plan_allday_flg, reserve.plan_time_from, reserve.plan_date_from.to_date + i, reserve]
            end
          else
            cell_reserves_work1 << [0, reserve.plan_allday_flg, reserve.plan_time_from, reserve.plan_date_from.to_date, reserve]
          end
        }

        #ソート(日跨り>終日>開始時間)
        cell_reserves_work2 = cell_reserves_work1.sort{ |a,b|
          #優先度1:日跨り
          if a[0] == b[0]
            #優先度2:終日
            if a[1] == b[1]
              #優先度3:開始時間
              a[2] <=> b[2]
            else
              b[1] <=> a[1]
            end
          else
            b[0] <=> a[0]
          end
        }
        cell_reserves_work2.each { |reserve2|
          cell_reserves << [reserve2[3], reserve2[4]]
        }

        #配列[施設コード, 施設名, 日付に紐付く施設リスト]
        @element_list << [element[0], element[1], cell_reserves]
      end
    else
      @element_list = []
    end

    #遷移元情報を格納
    session[:from_mode] = '2'
  end

  def day
    #基準日の設定
    if params[:day]
      @current_date = (params[:day].to_s[0,4] + "-" + params[:day].to_s[4,2] + "-" + params[:day].to_s[6,2]).to_date
    else
      @current_date = Date.today
    end
    @day = @current_date.strftime("%Y%m%d")

    #休日ハッシュを取得
    @holiday_hash = MCalendar.get_holiday_hash()
    #イベントハッシュを取得
    @event_hash = MCalendar.get_event_hash()

    #**ログインユーザが所属する部署情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #表示時間の設定
    start_time_disp = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + START_TIME)
    end_time_disp = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + END_TIME)

    #施設グループMよりデータ取得
    @facility_group_list = MFacilityGroup.find(:all, :conditions => ["delf = ?", 0], :order => "sort_no")

    #選択された施設グループコードを取得
    if params[:group_checked_id].nil? || params[:group_checked_id] == ""
      @group_checked_id = @facility_group_list[0].facility_group_cd
    else
      @group_checked_id = params[:group_checked_id]
    end

    #施設Mよりデータ取得
    org_edit_sql = MOrg.edit_org_consider_lvl(org_list)
    facility_list = getfacility_list(@group_checked_id, org_edit_sql)

    #施設が存在する場合
    if facility_list.size > 0
      #選択された施設を取得
      if params[:facility_cd].nil? || params[:facility_cd]  == ""
        @select_facility_cd = facility_list[0].facility_cd
      else
        @select_facility_cd = params[:facility_cd]
      end

      #配列[施設コード, 施設名, 終日リスト, 施設リスト(終日以外)]を作成
      facility_list_work = []
      for facility in facility_list
        #施設予約データより情報を取得(日単位)
        reserves_not_allday = get_other_facility_all_list_day(facility.facility_cd, start_time_disp, end_time_disp, 0) #終日以外
        reserves_allday = get_other_facility_all_list_day(facility.facility_cd, start_time_disp, end_time_disp, 1) #終日
        facility_list_work << [facility.facility_cd, facility.name + "<br>" + facility.case, reserves_allday, reserves_not_allday]
      end

      #配列[施設コード, 施設名, 終日リスト, 施設配列[時間, 施設(終日以外), 表示日付]]を作成
      element_list_work = []
      for element in facility_list_work
        #時間に紐付く施設リスト作成
        cell_reserves = []
        reserves = element[3]
        reserves.each { |reserve|
          cell_reserves << [reserve.plan_time_from, reserve, ""]
        }
        element_list_work << [element[0], element[1], element[2], cell_reserves]
      end

      #表示用に、配列[施設コード, 施設名, 行配列[行番号, 施設配列[時間, 施設, 表示日付]]]を作成
      #施設データの開始日時/終了日時は、表示用に上書きする場合あり
      @element_list = []

      #element:施設ごとの施設配列[時間, 施設リスト]
      for element in element_list_work
        #配列[行番号, 時間に紐付く施設リスト, 表示日付]のリスト
        day_row_list = []
        #施設ごとのリスト
        reserve_list = element[3]
        #reserve:格納する施設１件
        for reserve in reserve_list
          #ＤＢに登録されている日時
          start_date_old = reserve[1].plan_date_from
          end_date_old = reserve[1].plan_date_to
          start_time_old = Time.parse(start_date_old + " " + reserve[1].plan_time_from)
          end_time_old = Time.parse(end_date_old + " " + reserve[1].plan_time_to)

          disp_date = start_time_old.strftime("%H:%M") + "-" + end_time_old.strftime("%H:%M")

          #表示用に、開始日時/終了日時を上書きする
          reserve[1].plan_date_from = @current_date
          reserve[1].plan_date_to = @current_date
          if start_time_old < start_time_disp
            reserve[1].plan_time_from = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + start_time_disp.strftime("%H:%M"))
          else
            reserve[1].plan_time_from = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + reserve[1].plan_time_from)
          end
          if end_time_old < end_time_disp
            reserve[1].plan_time_to = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + reserve[1].plan_time_to)
          else
            reserve[1].plan_time_to = Time.parse(@current_date.strftime("%Y-%m-%d") + " " + end_time_disp.strftime("%H:%M"))
          end

          #開始日(終了日は異なる)の場合
          if @current_date == start_date_old.to_date
            if @current_date != end_date_old.to_date
              #終了時間を上書き
              disp_date = start_time_old.strftime("%H:%M") + "-"
              reserve[1].plan_time_to = end_time_disp
            end

          #終了日(開始日は異なる)の場合
          elsif @current_date == end_date_old.to_date
            #開始時間を上書き
            disp_date = "-" + end_time_old.strftime("%H:%M")
            reserve[1].plan_time_from = start_time_disp

          #中間日の場合
          else
            #開始時間/終了時間を上書き
            disp_date = ""
            reserve[1].plan_time_from = start_time_disp
            reserve[1].plan_time_to = end_time_disp
          end

          #表示時間の格納
          reserve[2] = disp_date

          #該当施設をどの行配列に格納するか判断
          ins_flg = 0 #行配列への格納フラグ(0:格納不可, 1:格納可能)
          row_num = 0 #格納する配列の行番号
          #day_row:配列[行番号, 時間に紐付く施設リスト]]
          for day_row in day_row_list
            ins_flg = 1
            row_num = day_row[0]
            row_list = day_row[1] #格納されている施設リスト

            #row_data:格納されている施設１件
            for row_data in row_list
              if !(row_data[1].plan_time_from >= reserve[1].plan_time_to || row_data[1].plan_time_to <= reserve[1].plan_time_from)
                #該当行配列に格納できない
                ins_flg = 0
                break
              end
            end
          end

          #行配列リストの初期化
          if day_row_list.size == 0
            target_row_list = []
            target_row_list << reserve
            day_row_list << [0, target_row_list]
          else
            #既存行配列に格納する場合
            if ins_flg == 1
              target_day_row = day_row_list[row_num]
              target_row_list_work = target_day_row[1]
              target_row_list_work << reserve
              #開始時間でソート
              target_row_list = target_row_list_work.sort{ |a,b|
                a[0] <=> b[0]
              }
              day_row_list[row_num][1] = target_row_list
            else
              #新たな行配列を作成する
              target_row_list = []
              target_row_list << reserve
              day_row_list << [day_row_list.size, target_row_list]
            end
          end
        end

        @element_list << [element[0], element[1], element[2], day_row_list]
      end
    else
      @element_list = []
    end

    #遷移元情報を格納
    session[:from_mode] = '1'
  end

  def list
    #基準日の設定
    if params[:month]
      @current_date = (params[:month].to_s[0,4] + "-" + params[:month].to_s[4,2] + "-"  + params[:month].to_s[6,2]).to_date
    else
      @current_date = Date.today
    end
    session[:list_start_month] = @current_date.strftime("%Y%m%d")

    #休日ハッシュを取得
    @holiday_hash = MCalendar.get_holiday_hash()
    #イベントハッシュを取得
    @event_hash = MCalendar.get_event_hash()

    #**ログインユーザが所属する部署情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #施設Mよりデータ取得
    org_edit_sql = MOrg.edit_org_consider_lvl(org_list)
    @facility_list = getfacility_list("", org_edit_sql)

    #施設が存在する場合
    if @facility_list.size > 0
      #選択された施設を取得
      if params[:facility_cd].nil? || params[:facility_cd]  == ""
        @select_facility_cd = @facility_list[0].facility_cd
      else
        @select_facility_cd = params[:facility_cd]
      end

      #施設予約データより情報を取得(リスト)
      reserves = get_facility_all_list_by_list()

      #日付に紐付く施設リスト作成
      cell_reserves = []
      reserves.each { |reserve|
        #開始日と終了日が異なる場合
        if reserve.plan_date_from.to_date < reserve.plan_date_to.to_date
          term = (reserve.plan_date_to.to_date - reserve.plan_date_from.to_date).to_i
          #途中の期間のデータも作成する
          for i in 0..term
            #表示対象日のみ
            target_date = reserve.plan_date_from.to_date + i
            if (@current_date <= target_date) && (target_date <= (@current_date >> 2))
              cell_reserves << [target_date, reserve]
            end
          end
        else
          cell_reserves << [reserve.plan_date_from.to_date, reserve]
        end
      }

      #日付順にソートする
      @cell_reserves = cell_reserves.sort{ |a,b|
        a[0] <=> b[0]
      }

    #施設が存在しない場合
    else
    end

    #遷移元情報を格納
    session[:from_mode] = '4'
  end

  def new
    #**ログインユーザが所属する部署情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #施設Mよりデータ取得
    org_edit_sql = MOrg.edit_org_consider_lvl(org_list)
    @facility_list = getfacility_list("", org_edit_sql)

    #選択施設コード
    @select_facility_cd = params[:select_facility_cd]
    if @select_facility_cd.nil? || @select_facility_cd == ""
      @select_facility_cd = @facility_list[0].facility_cd
    end

    #**表示するスケジュールデータの準備**
    #期末日を取得
    select_date = params[:date] #選択された日
    #会社M
    company_data = MCompany.find(:first, :conditions => ["delf = ?", 0])
    #期のリスト作成(0:1期末日, 1:2期末日..x:1期末日の1年後)
    term_list = []
    @term_colon = ""  #javaScriptでの入力チェック用
    term_list << get_term_date(select_date, company_data.term_end1, 0)
    @term_colon += company_data.term_end1
    if company_data.term_end2 != ""
      term_list << get_term_date(select_date, company_data.term_end2, 0)
      @term_colon += "," + company_data.term_end2
    end
    if company_data.term_end3 != ""
      term_list << get_term_date(select_date, company_data.term_end3, 0)
      @term_colon += "," + company_data.term_end3
    end
    if company_data.term_end4 != ""
      term_list << get_term_date(select_date, company_data.term_end4, 0)
      @term_colon += "," + company_data.term_end4
    end
    term_list << get_term_date(select_date, company_data.term_end1, 1)

    #直近の期末日を判定
    term_old = term_list[0]
    term_date = term_old
    for i in 1..(term_list.size - 1)
      term_new = term_list[i]
      if (term_old <= select_date.to_date) && (select_date.to_date < term_new)
        term_date = term_new
        break
      else
        term_old = term_new
      end
    end

    #時間の設定
    start_time = Time.now.strftime("%Y-%m-%d") + " 08:30"
    end_time = Time.now.strftime("%Y-%m-%d") + " 09:30"

    #**表示する施設予約データの作成**
    @reserve = DReserve.new
    @reserve.plan_date_from = select_date
    @reserve.plan_date_to = select_date
    @reserve.plan_time_from = start_time.to_datetime
    @reserve.plan_time_to = end_time.to_datetime
    @reserve.repeat_date_to = term_date.strftime("%Y-%m-%d")

    #**設定間隔を取得**
    @time_interval = get_time_interval()

    #遷移元情報を格納
    session[:back_facility_cd] = params[:back_facility_cd]
    session[:back_group_checked_id] = params[:back_group_checked_id]
  end

   # POST
  def create
    @msg = ""
    @duplicate_msg = ""
    from_mode = session[:from_mode]
    select_date = params[:select_date].to_date
    back_facility_cd = session[:back_facility_cd]
    back_group_checked_id = session[:back_group_checked_id]
    @select_button = params[:select_button].to_s
    @repeat_facility_id = 0  #繰り返し予定基本id(基準データidを保持)

    #遷移先を指定
    #**遷移先を指定**
    if from_mode == "1"
      action = "index_day"
      day = select_date.strftime("%Y%m%d")
    elsif from_mode == "2"
      action = "index_week"
      start_date = session[:week_start_date].to_date
      week = start_date.strftime("%Y%m%d")
    elsif from_mode == "3"
      action = "index_month"
      month = select_date.strftime("%Y%m")
    else
      action = "index"
    end

    #中止の場合は処理終了
    if @select_button == "99"
      flash[:schedule_msg] = @msg
      flash[:duplicate_msg] = @duplicate_msg
      redirect_to :action => action, :month => month, :week => week, :day => day, :facility_cd => back_facility_cd, :group_checked_id => back_group_checked_id
      return
    end

    #**データ削除/登録を行う**
    #基準データの作成
    insert_table(0, "")

    #繰り返しデータの作成
    if @reserve.repeat_flg == 1
      #毎月がチェックがされた場合
      if @reserve.repeat_interval_flg == 1
        insert_repeat(1)
      #曜日指定がチェックがされた場合
      elsif @reserve.repeat_interval_flg == 2
        insert_repeat(2)
      end
    end

    #遷移先の制御
    flash[:schedule_msg] = @msg
    flash[:duplicate_msg] = @duplicate_msg
    redirect_to :action => action, :month => month, :week => week, :day => day, :facility_cd => back_facility_cd, :group_checked_id => back_group_checked_id
    return
  end

  def edit
    #**ログインユーザが所属する部署情報取得**
    org_list = MUserBelong.get_belong_org_list(current_m_user.user_cd)
    #部署コードをカンマ区切りに編集
    org_colon_list = edit_org_colon(org_list)

    #施設Mよりデータ取得
    org_edit_sql = MOrg.edit_org_consider_lvl(org_list)
    @facility_list = getfacility_list("", org_edit_sql)

    #**表示する施設予約データの準備**
    #会社M
    company_data = MCompany.find(:first, :conditions => ["delf = ?", 0])
    #期のリスト作成(0:1期末日, 1:2期末日..x:1期末日の1年後)
    @term_colon = ""  #javaScriptでの入力チェック用
    @term_colon += company_data.term_end1
    if company_data.term_end2 != ""
      @term_colon += "," + company_data.term_end2
    end
    if company_data.term_end3 != ""
      @term_colon += "," + company_data.term_end3
    end
    if company_data.term_end4 != ""
      @term_colon += "," + company_data.term_end4
    end

    #**表示する施設予約データの作成**
    @reserve = DReserve.find(params[:id])
    @reserve.plan_time_from = (@reserve.plan_date_from.strftime("%Y-%m-%d") + " " + @reserve.plan_time_from.strftime("%H:%M")).to_datetime
    @reserve.plan_time_to = (@reserve.plan_date_to.strftime("%Y-%m-%d") + " " + @reserve.plan_time_to.strftime("%H:%M")).to_datetime

    #編集フラグ(1:編集可, 0:編集不可)
    @edit_flg = 1
    if !(@reserve.d_schedule_id.nil? || @reserve.d_schedule_id == "")
      @edit_flg = 0
    end

    #選択施設コード
    @select_facility_cd = @reserve.facility_cd

    #**設定間隔を取得**
    @time_interval = get_time_interval()

    #遷移元情報を格納
    session[:back_facility_cd] = params[:back_facility_cd]
    session[:back_group_checked_id] = params[:back_group_checked_id]
  end

  # PUT /user/1
  def update
    @msg = ""
    @duplicate_msg = ""
    from_mode = session[:from_mode]
    select_date = params[:select_date].to_date
    back_facility_cd = session[:back_facility_cd]
    back_group_checked_id = session[:back_group_checked_id]
    @select_button = params[:select_button].to_s

    #**遷移先を指定**
    if from_mode == "1"
      action = "index_day"
      day = select_date.strftime("%Y%m%d")
    elsif from_mode == "2"
      action = "index_week"
      start_date = session[:week_start_date].to_date
      week = start_date.strftime("%Y%m%d")
    elsif from_mode == "3"
      action = "index_month"
      month = select_date.strftime("%Y%m")
    elsif from_mode == "4"
      action = "index_list"
      start_date = session[:list_start_month].to_date
      month = start_date.strftime("%Y%m%d")
    else
      action = "index"
    end

    #中止の場合は処理終了
    if @select_button == "99"
      flash[:schedule_msg] = @msg
      flash[:duplicate_msg] = @duplicate_msg
      redirect_to :action => action, :month => month, :week => week, :day => day, :facility_cd => back_facility_cd, :group_checked_id => back_group_checked_id
      return
    end

    #**データ削除/登録を行う**
    facility_id = params[:id]  #施設予約id
    @repeat_facility_id = 0  #繰り返し予定基本id(基準データidを保持)
    @repeat_facility_id_old = 0  #更新前の繰り返し予定基本id
    @d_reserve_old = DReserve.find(facility_id) #更新前の施設予約データ

    #各テーブルからdelete
    #繰り返しデータがない場合
    if @select_button == '1'
      DReserve.delete(facility_id)

    #繰り返しデータがある場合
    #該当データのみ更新の場合
    elsif @select_button == '2'
      @repeat_facility_id_old = DReserve.find(facility_id).repeat_facility_id #繰り返し予定基本id
      DReserve.delete(facility_id)

    #該当データ以降のデータを更新/削除の場合
    elsif @select_button == '4' || @select_button == '6'
      @repeat_facility_id_old = DReserve.find(facility_id).repeat_facility_id #繰り返し予定基本id
      delete_list = DReserve.find(:all, :conditions => ["repeat_facility_id = ? and plan_date_from >= ?", @repeat_facility_id_old, params[:select_date]])

      for delete_data in delete_list
        DReserve.delete_all(["id = ?", delete_data.id])
      end

    #該当データ削除の場合
    elsif @select_button == '5'
      DReserve.delete(facility_id)
    end

    #データ作成する場合
    if !(@select_button == '5' || @select_button == '6')
      #基準データの作成
      insert_table(0, "")

      #繰り返しデータの作成(該当データのみ更新の場合を除く)
      if @select_button != '2'
        if @reserve.repeat_flg == 1
          #毎月がチェックがされた場合
          if @reserve.repeat_interval_flg == 1
            insert_repeat(1)
          #曜日指定がチェックがされた場合
          elsif @reserve.repeat_interval_flg == 2
            insert_repeat(2)
          end
        end
      end
    end

    #遷移先の制御
    flash[:schedule_msg] = @msg
    flash[:duplicate_msg] = @duplicate_msg
    redirect_to :action => action, :month => month, :week => week, :day => day, :facility_cd => back_facility_cd, :group_checked_id => back_group_checked_id
  end

private

  #エラーメッセージを出力します
  def return_error_message(ar_obj)
    msg = ""
    unless ar_obj.errors.empty?
      ar_obj.errors.each{|attr,str|
        msg += str + "\n"
      }
    end
    return msg
  end

  #各テーブルへのinsert用メソッド
  #rep_flg：繰り返しデータフラグ(0：基準データ、1：繰り返しデータ)
  #start_date：施設開始日(繰り返しデータの場合のみ使用)
  def insert_table(rep_flg, start_date)
    #施設Mより情報を取得
    m_facility = MFacility.find(:first, :conditions => ["facility_cd = ? and enable_flg = ? and delf = ?", params[:facility_cd], 0, 0])

    #**予定開始日時,終了日時を設定**
    @reserve = DReserve.new(params[:reserve])
    #基準データ
    if rep_flg == 0
      plan_date_from = params[:d_reserve]["plan_date_from"]
      plan_date_to = params[:d_reserve]["plan_date_to"]
    #繰り返しデータ
    else
      plan_date_from = start_date.strftime("%Y-%m-%d")
      plan_date_to = (start_date + (params[:d_reserve]["plan_date_to"].to_date - params[:d_reserve]["plan_date_from"].to_date).to_i).strftime("%Y-%m-%d")
    end
    #終日
    if @reserve.plan_allday_flg == 1
      plan_time_from = (plan_date_from + " " + START_TIME).to_datetime
      plan_time_to = (plan_date_to + " " + END_TIME).to_datetime
    else
      plan_time_from = (plan_date_from + " " + @reserve.plan_time_from.strftime("%H:%M")).to_datetime
      plan_time_to = (plan_date_to + " " + @reserve.plan_time_to.strftime("%H:%M")).to_datetime
    end

    #**重複データチェック**
    #登録する情報
    plan_allday_flg_new = @reserve.plan_allday_flg
    if plan_allday_flg_new == 1 #終日
      date_from_new = plan_date_from.to_date.strftime("%Y%m%d") + "0000"
      date_to_new = (plan_date_to.to_date + 1).strftime("%Y%m%d") + "0000"
    else
      date_from_new = plan_time_from.strftime("%Y%m%d%H%M")
      date_to_new = plan_time_to.strftime("%Y%m%d%H%M")
    end

    #テーブルの情報(既に登録されているデータ)
    duplicate_flg = 0
    d_reserve_list = DReserve.find(:all, :conditions => ["facility_cd = ? and delf = ?", m_facility.facility_cd, 0])
    for d_reserve in d_reserve_list
      plan_allday_flg_old = d_reserve.plan_allday_flg
      if plan_allday_flg_old == 1 #終日
        date_from_old = d_reserve.plan_date_from.strftime("%Y%m%d") + "0000"
        date_to_old = (d_reserve.plan_date_to + 1).strftime("%Y%m%d") + "0000"
      else
        date_from_old = d_reserve.plan_date_from.strftime("%Y%m%d") + d_reserve.plan_time_from.strftime("%H%M")
        date_to_old = d_reserve.plan_date_to.strftime("%Y%m%d") + d_reserve.plan_time_to.strftime("%H%M")
      end
      #日時の重複チェック
      if !(date_from_old >= date_to_new || date_to_old <= date_from_new)
        duplicate_flg = 1
        break
      end
    end

    #**施設予約データ登録の準備**
    @reserve.repeat_month_value = params[:repeat_month_value]
    @reserve.plan_date_from = plan_date_from
    @reserve.plan_date_to = plan_date_to
    #繰り返しデータ
    if rep_flg == 1
      @reserve.repeat_facility_id = @repeat_facility_id
    end
    @reserve.plan_time_from = plan_time_from
    @reserve.plan_time_to = plan_time_to
    #繰り返しがチェックされた場合
    if @reserve.repeat_flg == 1
      @reserve.repeat_date_to = params[:d_reserve]["repeat_date_to"]
    else
      @reserve.repeat_date_to = params[:repeat_date_to].to_date
    end
    @reserve.memo = params[:memo]
    @reserve.facility_cd = m_facility.facility_cd
    @reserve.place_cd = m_facility.place_cd
    @reserve.org_cd = m_facility.org_cd
    @reserve.d_schedule_id = params[:schedule_id]
    @reserve.reserve_user_cd = current_m_user.user_cd
    @reserve.reserve_user_name = current_m_user.name
    @reserve.created_user_cd = current_m_user.user_cd
    @reserve.updated_user_cd = current_m_user.user_cd

    #登録者と更新者が異なる場合
    if !@d_reserve_old.nil?
      if @reserve.reserve_user_cd != @d_reserve_old.reserve_user_cd
        #**メッセージデータ登録**
        @message = DMessage.new()
        @message.user_cd = @d_reserve_old.reserve_user_cd
        @message.message_kbn = 3
        @message.from_user_cd = current_m_user.user_cd
        @message.from_user_name = current_m_user.name
        @message.title = @d_reserve_old.plan_date_from.strftime("%Y年%m月%d日")  + "の予約が、" + current_m_user.name + "さんに変更されました"
        @message.post_date = Time.now
        @message.body = ""
        @message.etcint1 = 2  #マイページからの遷移先(施設)
        @message.etctxt1 = date_from_new.to_date.strftime("%Y%m%d")
        @message.created_user_cd = current_m_user.user_cd
        @message.updated_user_cd = current_m_user.user_cd
        @message.save
      end
    end

    #重複エラーの場合
    if duplicate_flg == 1
      #**メッセージデータ登録**
      #本文作成
      contents = ""
      contents += "タイトル  ：  " + @reserve.title + "<BR>"
      contents += "施設名  ：  " + m_facility.name + "<BR>"
      contents += "開始日 ：  " + date_from_new.to_date.strftime("%Y年%m月%d日") + "<BR>"
      contents += "終了日  ：  " + date_to_new.to_date.strftime("%Y年%m月%d日") + "<BR>"

      @duplicate_msg += "●施設名 ：  " + m_facility.name + "、"
      @duplicate_msg += "開始日 ：  " + date_from_new.to_date.strftime("%Y年%m月%d日") + "<br>"

      @message = DMessage.new()
      @message.user_cd = current_m_user.user_cd
      @message.message_kbn = 2
      @message.from_user_cd = current_m_user.user_cd
      @message.from_user_name = current_m_user.name
      @message.title = date_from_new.to_date.strftime("%Y年%m月%d日")  + "の予約(" + m_facility.name + ")が重複しました"
      @message.post_date = Time.now
      @message.body = contents
      @message.etcint1 = 2  #マイページからの遷移先(施設)
      @message.etctxt1 = date_from_new.to_date.strftime("%Y%m%d")
      @message.created_user_cd = current_m_user.user_cd
      @message.updated_user_cd = current_m_user.user_cd
      @message.save

    #**施設予約データ登録**
    else
      @reserve.save!

      #**繰り返しの基となる値の設定**
      #繰り返しデータありの場合
      if @reserve.repeat_flg == 1
        #繰り返し予定基本idが設定されていない場合(直前データまでが重複エラーの場合)
        if @repeat_facility_id == 0
          #繰り返し予定基本idの設定
          @repeat_facility_id = @reserve.id  #繰り返し予定基本id
          @reserve.repeat_facility_id = @repeat_facility_id
          @reserve.save
        end
      end
    end
  end

  #繰り返しデータ作成用メソッド
  #int_flg：繰り返し間隔フラグ(1:毎月、2:曜日指定)
  def insert_repeat(int_flg)
    plan_from = @reserve.plan_date_from
    plan_from_s = plan_from.strftime("%Y%m%d")
    plan_week = @reserve.plan_date_from.wday  #0:日曜..6:土曜

    #毎月がチェックがされた場合
    if int_flg == 1
      after_one_month = (plan_from >> 1).strftime("%Y%m%d")  #予定開始日の1ヶ月後
      begin
        next_date1 = (plan_from_s[0, 4] + plan_from_s[4, 2] + sprintf("%0#{2}d",@reserve.repeat_month_value)).to_date   #指定日(予定開始月が基準)
      rescue
        #該当月の月末日に置換する
        next_date1 = Date.new(plan_from_s[0, 4].to_i, plan_from_s[4, 2].to_i, -1)
      end
      begin
        next_date2 = (after_one_month[0, 4] + after_one_month[4, 2] + sprintf("%0#{2}d",@reserve.repeat_month_value)).to_date   #指定日(予定開始 + 1か月後の月が基準)
      rescue
        #該当月の月末日に置換する
        next_date1 = Date.new(after_one_month[0, 4].to_i, after_one_month[4, 2].to_i, -1)
      end

      #先頭日付(最初の繰り返し日)を設定
      date = next_date1
      #次の指定日 <= 予定開始日の場合
      if next_date1 <= plan_from
        date = next_date2
      end

      date_list = [] #追加する日付
      #先頭日付が、終了日より大きい場合
      if @reserve.repeat_date_to >= date
        #終了日まで処理を繰り返す
        while date <= @reserve.repeat_date_to
          date_list << date
          date = (date >> 1)
        end
      end

      #各テーブルへのinsert
      for date in date_list
        insert_table(1, date)
      end

    #曜日指定がチェックがされた場合
    elsif int_flg == 2
      week_list = []  #選択された曜日
      if @reserve.repeat_week_sun_flg == 1  #日曜
        week_list << 0
      end
      if @reserve.repeat_week_mon_flg == 1  #月曜
        week_list << 1
      end
      if @reserve.repeat_week_tue_flg == 1  #火曜
        week_list << 2
      end
      if @reserve.repeat_week_wed_flg == 1  #水曜
        week_list << 3
      end
      if @reserve.repeat_week_thu_flg == 1  #木曜
        week_list << 4
      end
      if @reserve.repeat_week_fri_flg == 1  #金曜
        week_list << 5
      end
      if @reserve.repeat_week_sat_flg == 1  #土曜
        week_list << 6
      end

      #選択された曜日の分、処理を繰り返す
      for next_week in week_list
        add_date = 0   #該当曜日までの日数

        #該当曜日を過ぎている場合
        if plan_week >= next_week
          add_date = 7 - (plan_week - next_week)
        else
          add_date = next_week - plan_week
        end

        #先頭日付(最初の繰り返し日)を設定
        date = plan_from + add_date

        date_list = [] #追加する日付
        #先頭日付が、終了日より大きい場合
        if @reserve.repeat_date_to >= date
          #終了日まで処理を繰り返す
          while date <= @reserve.repeat_date_to
            date_list << date
            date = (date + 7)
          end
        end

        #各テーブルへのinsert
        for date in date_list
          insert_table(1, date)
        end
      end
    end
  end

  #施設Mのデータを取得
  #group_cd:施設グループコード
  #org_edit_sql:メインユーザが所属する部署リスト
  def getfacility_list(group_cd, org_edit_sql)
    #施設M/所属M/組織M
    #(1)組織コード='0' かつ拠点コード=ユーザの拠点コード
    sql =  " SELECT a.*"
    sql += "     , '' as org_name4"
    sql += "     , '' as org_name3"
    sql += "     , '' as org_name2"
    sql += "     , '' as org_name1"
    sql += "     , '(' || f.name || ')' as case"
    sql += " FROM m_facilities a "
    sql += "  ,(SELECT DISTINCT(c.place_cd) "
    sql += "    FROM m_user_belongs b "
    sql += "       , m_orgs c "
    sql += "    WHERE b.delf = '0'"
    sql += "    AND c.delf = '0'"
    sql += "    AND b.org_cd = c.org_cd"
    sql += "    AND b.user_cd = '" + current_m_user.user_cd + "') d"
    #施設グループが選択されている場合
    if group_cd != ""
      sql += " ,m_facility_groups e "
    end
    sql += "  ,m_places f "
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  a.org_cd = '0'"
    sql += " AND  a.place_cd = d.place_cd "
    sql += " AND  a.enable_flg = 0 "
    #施設グループが選択されている場合
    if group_cd != ""
      sql += " AND e.delf = '0'"
      sql += " AND e.facility_group_cd = a.facility_group_cd"
      sql += " AND e.facility_group_cd = '" + group_cd + "'"
    end
    sql += " AND f.delf = '0'"
    sql += " AND d.place_cd = f.place_cd"

    #(2)組織コード=ユーザの組織コード かつ拠点コード=ユーザの拠点コード
    sql += " UNION "
    sql += " SELECT a.*"
    sql += "     , e.org_name4 as org_name4"
    sql += "     , e.org_name3 as org_name3"
    sql += "     , e.org_name2 as org_name2"
    sql += "     , e.org_name1 as org_name1"
    sql += "     , case "
    sql += "         when trim(org_name4) != '' then '(' || org_name4 || ')'"
    sql += "         when trim(org_name3) != '' then '(' || org_name3 || ')'"
    sql += "         when trim(org_name2) != '' then '(' || org_name2 || ')'"
    sql += "         when trim(org_name1) != '' then '(' || org_name1 || ')'"
    sql += "       end "
    sql += " FROM m_facilities a "
    sql += "  ,(SELECT DISTINCT(c.place_cd)"
    sql += "    FROM m_user_belongs b "
    sql += "       , m_orgs c "
    sql += "    WHERE b.delf = '0'"
    sql += "    AND c.delf = '0'"
    sql += "    AND b.org_cd = c.org_cd"
    sql += "    AND b.user_cd = '" + current_m_user.user_cd + "') d"
    sql += "  , m_orgs e "
    #施設グループが選択されている場合
    if group_cd != ""
      sql += " ,m_facility_groups f "
    end
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  e.delf = '0'"
    sql += " AND  a.org_cd = e.org_cd"
    sql += " AND  a.org_cd in (" + org_edit_sql + ")"
    sql += " AND  a.place_cd = d.place_cd "
    sql += " AND  a.enable_flg = 0 "
    #施設グループが選択されている場合
    if group_cd != ""
      sql += " AND f.delf = '0'"
      sql += " AND f.facility_group_cd = a.facility_group_cd"
      sql += " AND f.facility_group_cd = '" + group_cd + "'"
    end

    sql += "ORDER BY sort_no"

    place_list = MFacility.find_by_sql(sql)
    return place_list
  end

  #施設予約データより情報を取得(月単位)
  def get_facility_all_list_month()
    month_before = (@current_date << 1) - 7 #(1か月+1週間)前
    month_after = (@current_date >> 1) + 7  #(1か月+1週間)後

    #施設M/施設予約データ
    sql = "SELECT a.*, b.name as create_user_name"
    sql += " FROM d_reserves a "
    sql += "  , m_users b "
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  b.delf = '0'"
    sql += " AND  a.created_user_cd = b.user_cd "
    sql += " AND ((a.plan_date_from >= CAST('" + month_before.to_s + "' AS DATE) AND a.plan_date_from <= CAST('" + month_after.to_s + "' AS DATE))"
    sql += " OR   (a.plan_date_from < CAST('" + month_before.to_s + "' AS DATE) AND a.plan_date_to >= CAST('" + month_before.to_s + "' AS DATE))"
    sql += " OR   (a.plan_date_from < CAST('" + month_after.to_s + "' AS DATE) AND a.plan_date_to >= CAST('" + month_after.to_s + "' AS DATE)))"
    sql += " AND  a.facility_cd = '" + @select_facility_cd + "'"
    sql += " ORDER BY a.plan_date_from, a.plan_time_from, a.id"

    reserves = DReserve.find_by_sql(sql)
    return reserves
  end

  #施設予約データより情報を取得(週単位)
  #facility_cd:施設コード
  #end_date:表示終了日
  def get_other_facility_all_list_week(facility_cd, end_date)
    #施設M/施設予約データ
    sql = "SELECT a.name as name, b.*, c.name as create_user_name"
    sql += " FROM m_facilities a "
    sql += "  , d_reserves b "
    sql += "  , m_users c "
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  b.delf = '0'"
    sql += " AND  c.delf = '0'"
    sql += " AND  a.facility_cd = b.facility_cd "
    sql += " AND  b.created_user_cd = c.user_cd "
    sql += " AND  a.enable_flg = 0 "
    sql += " AND (b.plan_date_from >= CAST('" + @current_date.to_s + "' AS DATE)"
    sql += " OR  (b.plan_date_from < CAST('" + @current_date.to_s + "' AS DATE)"
    sql += "       AND b.plan_date_to >= CAST('" + @current_date.to_s + "' AS DATE)))"
    sql += " AND  b.plan_date_from <= CAST('" + end_date.to_s + "' AS DATE)"
    sql += " AND  b.facility_cd = '" + facility_cd + "'"
    sql += " ORDER BY b.plan_date_from, b.plan_time_from, b.id"

    reserves = MFacility.find_by_sql(sql)
    return reserves
  end

  #施設予約データより情報を取得(日単位)
  #facility_cd:施設コード
  #start_time_disp:表示開始時間
  #end_time_disp:表示終了時間
  #allday_flg:終日フラグ(0:終日以外, 1:終日)
  def get_other_facility_all_list_day(facility_cd, start_time_disp, end_time_disp, allday_flg)
    #施設M/施設予約データ
    sql = "SELECT a.name as name, b.*, c.name as create_user_name"
    sql += " FROM m_facilities a "
    sql += "  , d_reserves b "
    sql += "  , m_users c "
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  b.delf = '0'"
    sql += " AND  c.delf = '0'"
    sql += " AND  a.facility_cd = b.facility_cd "
    sql += " AND  b.created_user_cd = c.user_cd "
    sql += " AND  a.enable_flg = 0 "
    sql += " AND (b.plan_date_from = CAST('" + @current_date.to_s + "' AS DATE)"
    sql += " OR  (b.plan_date_from < CAST('" + @current_date.to_s + "' AS DATE)"
    sql += "       AND b.plan_date_to >= CAST('" + @current_date.to_s + "' AS DATE)))"
    sql += " AND (b.plan_time_from < CAST('" + end_time_disp.strftime("%H:%M").to_s + "' AS TIME)"
    sql += " AND  b.plan_time_to > CAST('" + start_time_disp.strftime("%H:%M").to_s + "' AS TIME))"
    sql += " AND  b.facility_cd = '" + facility_cd + "'"
    sql += " AND  b.plan_allday_flg = " + allday_flg.to_s
    sql += " ORDER BY b.plan_date_from, b.plan_time_from, b.id"

    reserves = MFacility.find_by_sql(sql)
    return reserves
  end

  #施設予約データより情報を取得(リスト)
  def get_facility_all_list_by_list()
    end_date = @current_date >> 2

    #施設M/施設予約データ
    sql = "SELECT a.*, b.name as create_user_name"
    sql += " FROM d_reserves a "
    sql += "  , m_users b "
    sql += " WHERE "
    sql += "      a.delf = '0'"
    sql += " AND  b.delf = '0'"
    sql += " AND  a.created_user_cd = b.user_cd "
    sql += " AND (a.plan_date_from >= CAST('" + @current_date.to_s + "' AS DATE)"
    sql += " OR  (a.plan_date_from < CAST('" + @current_date.to_s + "' AS DATE) AND a.plan_date_to >= CAST('" + @current_date.to_s + "' AS DATE)))"
    sql += " AND  a.plan_date_from <= CAST('" + end_date.to_s + "' AS DATE)"
    sql += " AND  a.facility_cd = '" + @select_facility_cd + "'"
    sql += " ORDER BY a.plan_date_from, a.plan_time_from, a.id"

    reserves = DReserve.find_by_sql(sql)
    return reserves
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

  #設定時間の間隔を取得
  def get_time_interval()
    #スケジュール設定テーブル
    setting_data = DScheduleSetting.find(:first, :conditions => ["user_cd = ? and delf = ?", current_m_user.user_cd, 0])
    #時間の設定間隔フラグを取得
    if setting_data.nil?
      set_time_interval_flg = 0
    else
      set_time_interval_flg = setting_data.set_time_interval_flg
    end

    #時間の設定間隔を設定
    if set_time_interval_flg == 0
      time_interval = 5
    elsif set_time_interval_flg == 1
      time_interval = 10
    else
      time_interval = 15
    end

    return time_interval
  end

  #期末の日付を設定
  #select_date:選択された日付(MMDD)
  #term_end:期末日付(MMDD)
  #over_flg:年を跨ぐフラグ(0:年を跨がない, 1:年を跨ぐ)
  def get_term_date(select_date, term_end, over_flg)
    #対象の年
    current_year = select_date.to_date.strftime("%Y")
    #年を跨ぐ場合
    if over_flg == 1
      term_end_yymmdd = ((select_date.to_date >> 12).strftime("%Y") + term_end).to_date
    else
      term_end_yymmdd = (current_year + term_end).to_date
    end
   return term_end_yymmdd
  end
end
