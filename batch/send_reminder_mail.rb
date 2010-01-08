require "kconv"
require "open-uri"
require 'rss/1.0'
require 'rss/2.0'
require 'rss/parser'
require 'rss/dublincore'
require 'rss/syndication'
require 'rss/content'
require 'rss/trackback'
require 'rss/image'

require "/app/gw/rails/enote/config/environment"
require 'parsedate'

puts "MAIL SEND IS STARTING ...."

#本日送信分のデータ取得(メール)
@reminders_email = DReminder.get_today_mail_list(1)

#本日送信分のデータ取得(携帯メール)
@reminders_mobile = DReminder.get_today_mail_list(2)

#スケジュール開始日のデータ取得(メールまたは携帯メールがアラート対象だった場合のみ)
@reminders_today = []
reminders_today_list = DReminder.get_reserve_from_mail_list
reminders_today_list.each do |reminders_today|
  #指定日にチェックされている場合
  if reminders_today.reminder_specify_flg.to_s == "1"
    #指定日 ≠ 当日の場合
    if reminders_today.reminder_specify_date != reminders_today.plan_date_from
      @reminders_today << reminders_today
    end
  else
    @reminders_today << reminders_today
  end
end

#アラーム指定日のメールを送信する(画面で指定した日 cf.何日前,何週間前等)
#メール
@reminders_email.each do |email|
  puts "email address => #{email.email_address1}"
  ret = email.mail_send(1, email, 1)
  puts "email result => #{ret}"
end

#携帯メール
@reminders_mobile.each do |mobile|
  puts "mobile address => #{mobile.mobile_address}"
  ret = mobile.mail_send(2, mobile, 1)
  puts "mobile result => #{ret}"
end

#スケジュール当日のメールを送信する
@reminders_today.each do |today|
  #メール
  if today.reminder_email_flg.to_s == "1"
    puts "email address => #{today.email_address1}"
    ret = today.mail_send(1, today, 2)
    puts "email result => #{ret}"
  end
  #携帯メール
  if today.reminder_mobile_mail_flg.to_s == "1"
    puts "email address => #{today.mobile_address}"
    ret = today.mail_send(2, today, 2)
    puts "email result => #{ret}"
  end
end

puts "MAIL SEND IS FINISHED."
