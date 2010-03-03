// JavaScriptライブラリ  by Lighthouse
// ブックマーク（bookmark.js）

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
 * あいまい検索を行う
 *
 * @param sword - 検索したいキーワード
 */
function bookmark_search(sword){
  if(sword == ""){
    alert("検索キーワードを指定してください。")
  } else {
    $("#bookmark_list").load(base_uri + "/bookmark/main/bookmark_search?sword=" + encodeURIComponent(sword));
  }
  return false;
}

 /*
  * ダイアログの初期化(追加用)
  */
 function dialog_bookmark_ins(){
   jQuery("#dialog_ins").dialog({
       autoOpen:  false,
       modal:  true,
       width:  600,
       height: 350
   });
 }

 /*
  * ダイアログの初期化(編集用)
  */
 function dialog_bookmark_upd(){
   jQuery("#dialog_upd").dialog({
       autoOpen:  false,
       modal:  true,
       width:  600,
       height: 350
   });
 }

 /*
 * ダイアログ表示(追加用)
 */
 function dialog_bookmark_open_ins(){
   //画面遷移
   url = space_remove($("#bookmark_url_new").val());
   jQuery("#dialog_ins").load(base_uri + "/bookmark/setting/new?url=" + url + "&categories=" + $("#categories").val());
   jQuery("#dialog_ins").dialog("open");
   return false;
 }

 /*
 * ダイアログ表示(編集用)
 */
 function dialog_bookmark_open_upd(id){
   //画面遷移
   jQuery("#dialog_upd").load(base_uri + "/bookmark/setting/edit?id=" + id);
   jQuery("#dialog_upd").dialog("open");
   return false;
 }

/*
 * 入力チェック
 */
function CheckValidate(){
  /*タイトルの必須チェック*/
  if (!inValueChk($("#bookmark_title").val(),99,0,1,0,0,"タイトル")) {
    return false;
  }
  return true;
}

/*
 * 空白削除
 */
function space_remove(val){
 return_val = val.replace(/(^\s+)|(\s+$)/g, "");
 return return_val;
}

/*
 * マスタ一覧へ戻る
 */
function ClickBackToMasterList(){
  document.location = base_uri + "/master/maintenance";
}