module Notice::MainHelper
  
  #
  # 公開期間が設定されているとき、公開前・公開終了を判定してラベルを表示します。
  # 
  # @param notice - お知らせ
  # @return ラベルを付加したお知らせ
  #
  def public_term notice
    
    unless notice.public_date_from.nil? and notice.public_date_to.nil?
      if notice.public_date_from > Date.today
        str = "<font style='color:#FF0000'>【公開前】</font>"
      elsif notice.public_date_to < Date.today
        str = "【公開終了】<br />"
      end
    end
    str
  end
  
  #
  # 非公開のお知らせの場合、ラベルを表示する。
  #
  # @param notice - お知らせ
  # @return ラベルを付加したお知らせ
  #
  def public_flg notice
    
    if notice.public_flg == 1
      str = "<font style='color:#FF0000'>【非公開】</font>"
    end
    str
  end
  
  #
  # ファイルサイズに応じて、単位記号を付加する
  #
  # @param size - ファイルサイズ
  # @return 単位記号を付加したファイルサイズ
  #
  def file_size size
    
    if size < 1000
      result = size.to_s + "Byte"
    elsif size < 1024*1024
      result = sprintf("%10.2f", size / 1024.0).to_s + "KB"
    else
      result = sprintf("%10.2f", size/1024.0/1024.0).to_s + "MB"
    end
    
    result
  end
end
