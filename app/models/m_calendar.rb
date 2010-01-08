class MCalendar < ActiveRecord::Base

  #
  # カレンダーマスタの全データを返す
  #
  def self.get_calendar_all_list()

    sql = <<-SQL
      SELECT
        t1.*
      FROM m_calendars t1
      WHERE
        t1.delf = 0
      ORDER BY
        t1.day
    SQL

    recs = find_by_sql(sql)
    return recs
  end

  #
  # 休日のハッシュを作成
  # @return ハッシュ[日付, 名称]
  #
  def self.get_holiday_hash()
    holiday_hash = Hash.new{|hash,key| hash[key]=[]}
    #カレンダーマスタ
    m_calendar = MCalendar.find(:all, :conditions => ["holiday_flg = ? and delf = ?", 0, 0])

    m_calendar.each { |holiday|
      holiday_hash[holiday.day] << holiday.name
    }

    return holiday_hash
  end

  #
  # イベントのハッシュを作成
  # @return ハッシュ[日付, 名称]
  #
  def self.get_event_hash()
    event_hash = Hash.new{|hash,key| hash[key]=[]}
    #カレンダーマスタ
    m_calendar = MCalendar.find(:all, :conditions => ["holiday_flg = ? and delf = ?", 1, 0])

    m_calendar.each { |event|
      event_hash[event.day] << event.name
    }

    return event_hash
  end
end
