module Cabinet::MineHelper

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
  # テーブルの昇順・降順を表す記号を表わす(有効期限用)
  #
  def order_mark2(mode)

    result = ""

    if mode == "2"
      result = "▲"
    elsif mode == "1"
      result = "▼"
    end

    result
  end

  #
  # 引数に渡されたファイルサイズに適切な単位を付加します。
  #
  # @param size - ファイルサイズ
  # @return 単位を付加したファイルサイズ
  #
  def format_file_size(size)

    result = ""

    if size < 1000
      result = size.to_s + " Byte"
    elsif size < 1024 * 1024
      result = sprintf("%10.2f", size/1024.0) + " KB"
    else
      result = sprintf("%10.2f", size/1024.0/1024.0) + " MB"
    end

    result
  end

  #
  # 合計のファイルサイズを計算します。
  #
  def total_file_size(size)

    result = sprintf("%10.2f", size)
  end

  #
  # 有効期限を計算して、文字色を変更します。
  # 憂苦期限が5日以下になると、文字色を赤にします。
  #
  # @param enable_date - 有効期限の日数
  # @param post_date - マイメモリの登録日
  # @return 有効期限までの残り日数
  #
  def expiration(enable_day, post_date)

    result = ""

    expiration_at = (enable_day - (Time.now.to_i - post_date.to_i)/60/60/24)
    expiration_color = expiration_at<=5 ? "red" : "black"
    expiration_at = "残り" + expiration_at.to_s + "日"
    result = '<td class="enote_general_table1_cell_bordered" style="text-align:center;color:' + expiration_color + ';">' + expiration_at + '</td>'
  end

end
