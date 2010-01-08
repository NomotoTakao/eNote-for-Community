module Bulletin::MainHelper
  
  
  def datetime_strftime_bulletin(indate)
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
  
  #
  # 回覧板一覧において、回覧前・回覧終了のラベルを付加します。(投稿者に対してのみ)
  #
  def bulletin_marker bulletin, user
    result = ""
    
    result += bulletin.title
    if bulletin.d_bulletin_head.post_user_cd = user.user_cd
      if bulletin.d_bulletin_head.bulletin_date_from > Date.today
        result += "&nbsp;<font style='color:red;'>【回覧前】</font>"
      elsif bulletin.d_bulletin_head.bulletin_date_to < Date.today
        result += "&nbsp;<font style='color:red;'>【回覧期間終了】</font>"
      end
    end
    
    return result
  end
  
  #
  # 公開開始日のヘルパメソッド
  # DBから値が取得できなかったときは、本日を公開開始日として表示
  #
  # @param date - DBから取得した公開開始日
  # 
  def bulletin_date_from date
    result = nil
    if date.nil?
      result = Date.today
    else
      result = date
    end
    
    return result
  end
  
  #
  # 公開終了日のヘルパメソッド
  # DBから値が取得できなかったときは、本日より14日後の日付を公開終了日として表示
  #
  # @param date - DBから取得した公開終了日
  #
  def bulletin_date_to date
    result = nil
    if date.nil?
      result = Date.today + 14
    else
      result = date
    end
    
    return result
  end
end
