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
* 入力チェック
*/
function CheckValidate(){
 /*お知らせボードの選択の必須チェック*/
 if (!inValueChk($("#d_notice_body_d_notice_head_id").val(),99,0,1,0,0,"お知らせボードの選択")) {
   return false;
 }
 /*公開対象組織の選択の必須チェック*/
 if (!inValueChk($("#selected_public_org_list").val(),99,0,1,0,0,"公開対象組織の選択")) {
   return false;
 }
 /*タイトルの必須チェック*/
 if (!inValueChk($("#d_notice_body_title").val(),99,0,1,0,0,"タイトル")) {
   return false;
 }
 /*公開期間(開始日)の必須チェック*/
 if (!inValueChk($("#d_notice_body_public_date_from").val(),99,0,1,0,0,"公開期間(開始日)")) {
     return false;
 }
 /*公開期間(終了日)の必須チェック*/
 if (!inValueChk($("#d_notice_body_public_date_to").val(),99,0,1,0,0,"公開期間(終了日)")) {
     return false;
 }
 /*公開期間(開始日)の妥当性チェック*/
 result = checkDateFormat($("#d_notice_body_public_date_from").val(), "#d_notice_body_public_date_from", "公開期間(開始日)");
 if (!result) {
   return result;
 }
 /*公開期間(終了日)の妥当性チェック*/
 result = checkDateFormat($("#d_notice_body_public_date_to").val(), "#d_notice_body_public_date_to", "公開期間(終了日)");
 if (!result) {
   return result;
 }
 /*公開期間(開始日)と公開期間(終了日)の大小チェック*/
 result = compareDate(
     true,
     $("#d_notice_body_public_date_from").val(), "", "",
     $("#d_notice_body_public_date_to").val(), "", "",
     "公開期間");
 if (!result) {
   return result;
 }
 return true;
}
