# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def _text_field(no_edit_flag, object_name, method, options = {})

    if no_edit_flag == true
      return instance_variable_get("@#{object_name}").send(method)
    else
      return text_field(object_name, method, options)
    end

  end

  def _date_select(non_edit_flag, object_name, method, options = {})
    if non_edit_flag == true
      if instance_variable_get("@#{object_name}").send(method) != nil
        return instance_variable_get("@#{object_name}").send(method).strftime('%Y/%m/%d')
      else
        return ""
      end
    else
      return date_select(object_name, method, options)
    end
  end

  def _text_area(non_edit_flag, object_name, method, options = {})
    if non_edit_flag == true
      return instance_variable_get("@#{object_name}").send(method)
    else
      return text_area(object_name, method, options)
    end
  end

  #datetime型の値を表示用にyyyy/mm/dd hh:mm:ssに変換する
  def format_datetime(in_datetime)
    if in_datetime == nil
      return ''
    else
      return in_datetime.strftime('%Y/%m/%d %H:%M:%I')
    end
  end

  #Datetimeを年月日もしくは月日もしくは時刻を表示
  def datetime_strftime(indate)
    if indate.nil?
      return '---'
    else
      w_date = indate
      if w_date.strftime('%y%m%d') == Date::today.strftime('%y%m%d')
        return w_date.strftime('%H:%M').to_s
      elsif w_date.strftime('%y') == Date::today.strftime('%y')
        return w_date.strftime('%m月%d日').to_s
      else
        return w_date.strftime('%y/%m/%d').to_s
      end
    end
  end

  #Dateを年月日もしくは月日で表示
  def date_strftime(indate)
    if indate.nil?
      return '---'
    else
      w_date = indate
      if w_date.strftime('%y') == Date::today.strftime('%y')
        return w_date.strftime('%m月%d日').to_s
      else
        return w_date.strftime('%y/%m/%d').to_s
      end
    end
  end

end
