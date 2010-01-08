require 'nkf'
class DSchedule < ActiveRecord::Base
  START_TIME = "07:00"
  END_TIME = "21:00"

  #登録
  def save_ext()
    #必須入力チェック
    errors.clear

    return false unless errors.empty?

    self.save!
  end

  #
  # 参照できる所属リストの作成
  # org_list:メインユーザが所属する組織リスト
  # project_list:メインユーザが所属するプロジェクトリスト
  # space_flg:空白行フラグ(0:空白行なし, 1:空白行あり)
  # proxy_user_cd:メインユーザーCD
  # login_user_cd:ログインユーザーCD
  # secretaries_flg:秘書フラグ(0:秘書機能なし, 1:秘書機能あり)
  #
  def self.get_visible_belong_list(org_list, project_list, space_flg, proxy_user_cd, login_user_cd, secretaries_flg)
    #所属リスト[所属フラグ(0:空白, 1:秘書機能, 2xy:部署, 3:プロジェクト), コード, 名称]
    #x(表示階層)1:1階層下,2:2階層下,3:1階層上,4:課全体,5:部全体    y:ユーザー所属組織の階層(上階層表示の場合のみ使用)
    belong_list = []
    if space_flg == 1
      belong_list << [0, "", ""]
    end

    #**秘書機能**
    #秘書機能を持っている人が、自分のデータを参照している場合
    if secretaries_flg == 1 && (proxy_user_cd.nil? || proxy_user_cd == login_user_cd)
      belong_list << [1, "", "秘書機能"]
    end

    #**組織リスト**
    #メインユーザが所属する組織リストより、表示リストを作成する
    for org in org_list
      #**1階層下の組織情報を取得**
      belong_list << [210, org.org_cd, org.case]

      #**1階層上の組織情報を取得**
      #組織レベルが1のメンバーは除く
      if org.org_lvl.to_s != '1'
        if org.org_lvl.to_s == '2'
          org_high_cd = org.org_cd1
          org_high_name = org.org_name1
        elsif org.org_lvl.to_s == '3'
          org_high_cd = org.org_cd1 + org.org_cd2
          org_high_name = org.org_name2
        elsif org.org_lvl.to_s == '4'
          org_high_cd = org.org_cd1 + org.org_cd2 + org.org_cd3
          org_high_name = org.org_name3
        end
        belong_list << [230, org_high_cd, org_high_name]
      end
    end

    #**プロジェクトリスト**
    for project in  project_list
      belong_list << [3, project.id.to_s, project.name]
    end
    return belong_list
  end

  #
  #メインユーザの所属リスト[所属フラグ(1:部署, 2:プロジェクト, 3:非公開), コード, 名称]の作成
  #org_list:組織リスト
  #project_list:プロジェクトリスト
  #
  def self.get_belong_user_list(org_list, project_list)
    belong_user_list = []
#    for org in  org_list
#      #主所属部署の場合
#      if org.belong_kbn == 0
#        public_org_cd = org.org_cd
#        public_org_name = org.case
#      #兼任部署の場合
#      else
#        #部単位の表示とする
#        public_org_cd = org.org_cd1 + org.org_cd2 + org.org_cd3
#        public_org_name = org.org_name3
#      end
#      belong_user_list << [1, public_org_cd, public_org_name]
#    end
    belong_user_list << [1, "0", "所属部署"]
    for project in  project_list
      belong_user_list << [2, project.id.to_s, project.name]
    end
    belong_user_list << [3, "", "非公開"]
    return belong_user_list
  end

  #
  #スケジュールデータ作成
  #Web日報用
  #today_data:個人ごとのWeb日報データ
  #
  def self.create_web_nippo(today_data)
    begin
      #スケジュールデータ登録
      reserve = DSchedule.new()
      reserve.user_cd = today_data[0].tantocd
      reserve.title = "Web日報の予定"
      reserve.plan_allday_flg = 1
      reserve.plan_date_from = Date.today
      reserve.plan_time_from = (Date.today.strftime("%Y-%m-%d") + " " + START_TIME).to_datetime
      reserve.plan_date_to = Date.today
      reserve.plan_time_to = (Date.today.strftime("%Y-%m-%d") + " " + END_TIME).to_datetime
      reserve.public_kbn = 0
      reserve.plan_kbn = 99 #Web日報

      #備考作成
      memo = ""
      count = 0
      today_data.each do |data|
        if count > 0
          memo += "\n"
        end
        #データ準備
        time_from = ""
        time_to = ""
        rgnmtk = ""
        if !data.hmnjknfr.nil?
          time_from = (Date.today.strftime("%Y%m%d") + " " + data.hmnjknfr.to_s.rjust(4,"0")).to_datetime.strftime("%H:%M")
        end
        if !data.hmnjknto.nil?
          time_to = (Date.today.strftime("%Y%m%d") + " " + data.hmnjknto.to_s.rjust(4,"0")).to_datetime.strftime("%H:%M")
        end
        if !data.rgnmtk.nil?
          rgnmtk = data.rgnmtk
        end
        #本文作成
        if time_from != "" || time_to != ""
          memo += "[" + time_from.to_s + " - " + time_to.to_s + "]"
        end
        if rgnmtk != ""
          memo += rgnmtk
        end
        time_from = " "
        time_to = " "
        if !data.hmnjknfr.nil?
          time_from = data.hmnjknfr
        end
        if !data.hmnjknto.nil?
          time_to = data.hmnjknto
        end
        memo += "[" + time_from.to_s + " - " + time_to.to_s + "]"
        memo += NKF.nkf('-w', data.katnainm)
        count = count + 1
      end
      reserve.memo = memo
      reserve.save
    rescue => ex
      return ex
    end
    return "OK"
  end

  #表示用にデータ加工(週単位/秘書機能の印刷用)
  #配列[社員コード, 社員名, 日付に紐付くスケジュールリスト]を作成
  #member_list:配列[社員コード, 社員名, スケジュールリスト]
  def self.create_disp_week_or_print_list(member_list)
    member_list_disp = []
    for member in member_list
      #日付に紐付くスケジュールリスト作成
      cell_reserves = []
      cell_reserves_work1 = []
      cell_reserves_work2 = []
      reserves = member[2]

      #配列[日跨りフラグ, 終日フラグ, 開始時間, 日付に紐付くスケジュールリスト](ソート用)を作成
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
        cell_reserves << [reserve2[3], reserve2[4]]
      }

      #配列[社員コード, 社員名, 日付に紐付くスケジュールリスト]
      member_list_disp << [member[0], member[1], cell_reserves]
    end
    return member_list_disp
  end
end
