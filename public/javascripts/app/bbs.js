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
 * 指定されたクラス属性をもつオブジェクトの背景色と前景色を変更します。
 * 背景色がブルー用
 *
 * @param element - 操作対象のjQueryオブジェクト(ID指定))
 * @param cls - 操作対象のjQueryオブジェクト(クラス指定))
 */
function bgChange2(element, cls){
  // 背景色と前景色をリセット
  cls.css('background-color', '#F3F3F3');
  cls.css('color', '#000000');
  // クリックされたオブジェクトの背景色と前景色を変更する。
  element.css('background-color', '#0066FF');
  element.css('color', '#FFFFFF');
}

/*
* 入力チェック(トピック)
*/
function CheckTopicValidate(){
 /*タイトルの必須チェック*/
 if (!inValueChk($("#d_bbs_threads_title").val(),99,0,1,0,0,"タイトル")) {
   return false;
 }
 return true;
}

/*
* 入力チェック(スレッド)
*/
function CheckThreadValidate(){
 /*コメントの必須チェック*/
 if (!inValueChk($("#d_bbs_comments_body").val(),99,0,1,0,0,"コメント")) {
   return false;
 }
 return true;
}
