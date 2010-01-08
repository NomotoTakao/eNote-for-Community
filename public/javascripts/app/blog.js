//
// JavaScriptライブラリ  by Lighthouse
//

/*
 * 「投稿」ボタンが押下された時の処理。
 * 入力チェックを行います。
 */
function ClickContributeButton(){
  //確認ダイアログ
  result = confirm("投稿して宜しいですか？");
  if (!result) {
    return result;
  }
  //入力チェック
  result = CheckValidate();
  if (!result) {
    return result;
  }
}

/*
* 入力チェック
*/
function CheckValidate(){
 /*タイトルの必須チェック*/
 if (!inValueChk($("#d_blog_body_title").val(),99,0,1,0,0,"タイトル")) {
   return false;
 }
 return true;
}

