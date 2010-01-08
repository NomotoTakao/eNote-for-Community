//
// JavaScriptライブラリ  by Lighthouse
//
/*
 * 指定されたクラス属性をもつオブジェクトの背景色と前景色を変更します。
 *
 * @param element - 操作対象のjQueryオブジェクト(ID指定))
 * @param cls - 操作対象のjQueryオブジェクト(クラス指定))
 */
function bgChange(element, cls){
  // 背景色と前景色をリセット
  cls.css('background-color', '#FFFFFF');
  cls.css('color', '#000000');
  // クリックされたオブジェクトの背景色と前景色を変更する。
  element.css('background-color', '#0066FF');
  element.css('color', '#FFFFFF');
}

/*
* 入力チェック(Webメモリ)
*/
function CheckMineValidate(){
  /*タイトルの必須チェック*/
  if (!inValueChk($("#title").val(),99,0,1,0,0,"タイトル")) {
    return false;
  }
  /*保存するファイルの必須チェック*/
  if (!inValueChk($("#attachment_0").val(),99,0,1,0,0,"保存するファイル")) {
    return false;
  }
  return true;
}

/*
* 入力チェック(共有キャビネット)
*/
function CheckPublicValidate(){
  /*保存するキャビネットの必須チェック*/
  if (!inValueChk($("#d_cabinet_body_d_cabinet_head_id").val(),99,0,1,0,0,"保存するキャビネット")) {
    return false;
  }
  /*公開対象組織の必須チェック*/
  //全社の場合
  if ($("#selectCabinet").val() == 1) {
      if (!inValueChk($("#selected_public_org_list").val(),99,0,1,0,0,"公開対象組織")) {
          return false;
      }
  }
  /*タイトルの必須チェック*/
  if (!inValueChk($("#d_cabinet_body_title").val(),99,0,1,0,0,"タイトル")) {
    return false;
  }
  /*公開期間(開始日)の妥当性チェック*/
  result = checkDateFormat($("#d_cabinet_body_public_date_from").val(), "#d_cabinet_body_public_date_from", "公開期間(開始日)");
  if (!result) {
    return result;
  }
  /*公開期間(終了日)の妥当性チェック*/
  result = checkDateFormat($("#d_cabinet_body_public_date_to").val(), "#d_cabinet_body_public_date_to", "公開期間(終了日)");
  if (!result) {
    return result;
  }
  /*公開期間(開始日)と公開期間(終了日)の大小チェック*/
  if ($("#d_cabinet_body_public_date_from").val().length > 0 && $("#d_cabinet_body_public_date_to").val().length > 0) {
    result = compareDate(
          true,
          $("#d_cabinet_body_public_date_from").val(), "", "",
          $("#d_cabinet_body_public_date_to").val(), "", "",
          "公開期間");
    if (!result) {
      return result;
    }
  }
  return true;
}
