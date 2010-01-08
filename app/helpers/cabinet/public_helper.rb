module Cabinet::PublicHelper
  
  #
  # テーブルの昇順・降順を表す記号を表わす
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
