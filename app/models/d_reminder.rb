class DReminder < ActiveRecord::Base

  #
  # アラート指定日のリマインダーデータを返す
  # reminder_kbn 1:メール, 2:携帯メール
  #
  def self.get_today_mail_list(reminder_kbn)

    sql = <<-SQL
      SELECT
        t1.*,
        t2.email_address1,
        t2.mobile_address,
        t3.*
      FROM d_reminders t1,
           d_addresses t2,
           d_schedules t3
      WHERE
        t1.user_cd = t2.user_cd
      AND
        t1.d_schedule_id = t3.id
      AND
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        t3.delf = 0
      AND
        t1.reminder_kbn = #{reminder_kbn}
      AND
        CAST(t1.notice_date_from as date) = current_date
      ORDER BY
        t1.id
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # スケジュール当日のリマインダーデータを返す
  # (メールまたは携帯メールがアラート対象だった場合のみ)
  #
  def self.get_reserve_from_mail_list()

    sql = <<-SQL
      SELECT
        t1.email_address1,
        t1.mobile_address,
        t2.*
      FROM d_addresses t1,
           d_schedules t2
      WHERE
        t1.user_cd = t2.user_cd
      AND
        t1.delf = 0
      AND
        t2.delf = 0
      AND
        (t2.reminder_email_flg = 1
      OR
        t2.reminder_mobile_mail_flg = 1)
      AND
        CAST(t2.plan_date_from as date) = current_date
      ORDER BY
        t1.id
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # メールの送信
  # reminder_kbn - 1:メール, 2:携帯メール
  # data - get_today_mail_listの返却値
  # create_mode - 1:アラート指定日, 2:スケジュール当日
  #
  def mail_send(reminder_kbn, data, create_mode)
    begin
      if reminder_kbn == 1  #メール
        address = data.email_address1
        if address.nil? || address == ""
          return "email_address is empty"
        end
      else  #携帯メール
        address = data.mobile_address
        if address.nil? || address == ""
          return "mobile_address is empty"
        end
      end

      mail_from = "test@abc.com"
      mail_to = address

      if create_mode == 1 #アラーム指定日(画面で指定した日 cf.何日前,何週間前等)
        date_from = data.plan_date_from.to_date.strftime("%Y年%m月%d日")
        subject = "【スケジュールアラーム通知】" + date_from + "の予定について"
        mail_body = data.body
      else  #スケジュール当日
        date_from = data.plan_date_from.to_date.strftime("%Y年%m月%d日")
        date_to = data.plan_date_to.to_date.strftime("%Y年%m月%d日")
        time_from = (data.plan_date_from + " " + data.plan_time_from).to_datetime.strftime("%H:%M")
        time_to = (data.plan_date_to + " " + data.plan_time_to).to_datetime.strftime("%H:%M")
        subject = "【スケジュールアラーム通知】" + date_from + "の予定について"
        contents = ""
        contents += "以下のスケジュールのアラームメールです。\n確認をお願い致します。\n\n"
        contents += "---------------------------------------------------------------------" + "\n"
        contents += "タイトル  ：  " + data.title + "\n"
        if data.plan_allday_flg.to_s == "0"  #終日以外
          contents += "開始日時 ：  " + date_from + " " + time_from  + "\n"
          contents += "終了日時 ：  " + date_to + " " + time_to  + "\n"
        else  #終日
          contents += "開始日時 ：  " + date_from + "  終日\n"
          contents += "終了日時 ：  " + date_to + "\n"
        end
        contents += "---------------------------------------------------------------------"
        mail_body = contents
      end

      #送信するメールを作成
      mbody = Hash.new
      mbody[:subject] = subject
      mbody[:to_addrs] = mail_to
      mbody[:from_addrs] = mail_from

      #テキストメール
      mbody[:content_type] = "text/plain"
      mbody[:mail_body] = mail_body

      #CC
      mbody[:cc_addrs] = ""
      #BCC
      mbody[:bcc_addrs] = ""

      #その他のヘッダー情報
      headers = Hash.new
      headers['X-Mailer'] = 'eNote WebMail v0.3'
      headers['X-Priority'] = 3
      headers['MIME-Version'] = '1.0'

      #その他のヘッダー情報をセット
      mbody[:headers] = headers

      #添付ファイルの数
      mbody[:attach_cnt] = 0

      #メールを送信
      @newmail = Webmail::MailMessage.create_newmail_multi(mbody)

      #メールを送信
      Webmail::MailMessage.deliver(@newmail)

      return "success"
    rescue => ex
      return "error(" + ex + ")"
    end
  end

end
