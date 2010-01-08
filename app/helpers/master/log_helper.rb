module Master::LogHelper
  
  #
  # ログ一覧の表示形式を整える
  # (「いつ、誰が、何に、何をした」の形式)
  #
  # @param log - 1件のログレコード
  #
  def log_format log
    
    result = ""
    
    # 操作の種類を取得する。(操作の種類によって、作成時間と更新時間のどちらを採るか判断する。
    manipulate_name = log.manipulate_name
    
    if manipulate_name == "INSERT"
      # 誰が
      log_who = MUser.get_user_name log.created_user_cd
      # 何を
      log_what = log.table_name + "テーブルにレコード（id：" + log.manipulate_id.to_s + "）"
      # いつ
      log_when = log.created_at.strftime("%Y/%m/%d %H:%M:%S") unless log.created_at.nil?
      # どうした
      log_manipulate = "追加"
    elsif manipulate_name == "UPDATE"
      # 誰が
      log_who = MUser.get_user_name log.created_user_cd
      # 何を
      log_what = log.table_name + "テーブルのレコード（id：" + log.manipulate_id.to_s + "）"
      # いつ
      log_when = log.created_at.strftime("%Y/%m/%d %H:%M:%S") unless log.created_at.nil?
      # どうした
      log_manipulate = "更新"
    elsif manipulate_name == "DELETE"
      # 誰が
      log_who = MUser.get_user_name log.created_user_cd
      # 何を
      log_what = log.table_name + "テーブルのレコード（id：" + log.manipulate_id.to_s + "）"
      # いつ
      log_when = log.created_at.strftime("%Y/%m/%d %H:%M:%S") unless log.created_at.nil?
      # どうした
      log_manipulate = "削除"
    end
    
    if log_who.nil? or log_who.empty?
      log_who = "システム"
    end
    return "#{log_when}に#{log_who}が#{log_what}を#{log_manipulate}しました。"
  end

  #
  # ユーザーCDからユーザー名を取得する
  #
  # @param user_cd - ユーザーCD
  #
  def user_name user_cd
    
   if user_cd.nil?
     return ''
   else
     return MUser.get_user_name user_cd
   end
  end
 
  #
  # テーブルの昇順・降順を表す記号を出力する
  #
  def order_mark(mode)
    
    result = ""
    
    if mode == "2"
      result = "▼"
    elsif mode == "1"
      result = "▲"
    end
    
    result
  end
end
