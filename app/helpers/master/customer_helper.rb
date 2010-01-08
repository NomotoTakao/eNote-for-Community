module Master::CustomerHelper

  #
  # 金額の表示を整えます。
  #
  # @param money - DB上の金額の値
  #
  def format_money money
    result = ""

    #TODO ３桁ごとにカンマ区切り
    result += money

    return result
  end

  #
  # 社員数の表示を整えます。
  #
  # @param number - DB上の社員数の値
  #
  def format_person number
    result = ""

    #TODO ３桁ごとにカンマ区切り
    result += number

    return result
  end

  #
  # 削除状態を表示します。
  #
  # @parm flg - DB上の削除フラグの値
  #
  def delete_flag flg
    result = ""
    if flg == 0
      result = "未"
    else
      result = "済"
    end
    return result
  end

end
