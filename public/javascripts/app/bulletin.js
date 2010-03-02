// JavaScriptライブラリ  by Lighthouse
// 回覧板（bulletin.js）

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
 * 指定されたクラス属性をもつオブジェクトのフォルダアイコンを変更します。
 *
 * @param element - 操作対象のjQueryオブジェクト
 * @param prefix - 接頭辞
 * @param target_value - 操作対象のオブジェクト番号
 */
function folderChange(element, prefix, target_value){
  // 操作対象フォルダを開いた状態にする
  document.getElementById(element).className = "open_folder";
  // その他のフォルダを閉じた状態にする
  for (i=0;i<4;i++) {
    // 操作対象フォルダ以外の場合
    if (i != target_value) {
      other_id = prefix + i;
      document.getElementById(other_id).className = "close_folder";
    }
  }
}

/*
 * 回覧板の詳細画面を表示する
 */
function disp_bulletin_detail(id){
  $("#bulletin_area").load("main/detail?id=" + id);
}

/*
 * 編集画面：">>"クリック時の処理
 */
function ClickAddAllUser(){
  $("#org_users option").each(function(){
        $(this).attr("selected", false);
    $("#decided_users").append($(this));
  });
}

/*
 * 編集画面:">"クリック時の処理
 */
function ClickAddUser(){
    $("#org_users option:selected").each(function(){
        $(this).attr("selected", false);
        $("#decided_users").append($(this));
    });
}

/*
 * 編集画面:"<"クリック時の処理
 */
function ClickDeleteUser(){
    $("#decided_users option:selected").each(function(){
        $(this).attr("selected", false);
        $("#org_users").append($(this));
    });
}

/*
 * 編集画面:"<<"クリック時の処理
 */
function ClickDeleteAllUser(){
  $("#decided_users option").each(function(){
        $(this).attr("selected", false);
    $("#org_users").append($(this));
  });
}

function SaveBulletin(){
//	var user_cds = ""
//	$("#decided_users").each(function(){
//		if(user_cds == ""){
//			user_cds = $(this).val();
//		} else {
//			user_cds += "-" + $(this).val();
//		}
//	});
//	$("#decided_user_cds").val(user_cds);

    //確認ダイアログ
    result = confirm("登録して宜しいですか？");
    if (!result) {
      return result;
    }

    //選択された社員を退避
    dBox = document.getElementById("decided_users");
    var member = new Array(dBox.length);
    for (var i = 0; i < dBox.options.length; i++) {
      member[i] = dBox.options[i].value;
    }
    $("#decided_user_cds").val(member);

    //入力チェック
    result = CheckValidate();
    if (!result) {
      return result;
    }
    //submit
  $("#form_bulletin").submit();
//	$("#form_bulletin").submit(function(){
//		if($("#bulletin_head_title").val() == ""){
//			alert("タイトルは必須入力です");
//			return false;
//		} else {
//			alert($("#bulletin_head_title").val());
//		}
//		return true;
//	});
}

function SaveAnswerBulletin(){
  //確認ダイアログ
  result = confirm("登録して宜しいですか？");
  if (!result) {
    return result;
  }
  $("#form_bulletin_checked").submit();
}

/*
* 入力チェック
*/
function CheckValidate(){
 /*タイトルの必須チェック*/
 if (!inValueChk($("#bulletin_head_title").val(),99,0,1,0,0,"タイトル")) {
   return false;
 }
 /*回覧先の社員の必須チェック*/
 if (!inValueChk($("#decided_user_cds").val(),99,0,1,0,0,"回覧先の社員")) {
   return false;
 }
 /*回覧期間(開始日)の必須チェック*/
 if (!inValueChk($("#bulletin_head_bulletin_date_from").val(),99,0,1,0,0,"回覧期間(開始日)")) {
     return false;
 }
 /*回覧期間(終了日)の必須チェック*/
 if (!inValueChk($("#bulletin_head_bulletin_date_to").val(),99,0,1,0,0,"回覧期間(終了日)")) {
     return false;
 }
 /*回覧期間(開始日)の妥当性チェック*/
 result = checkDateFormat($("#bulletin_head_bulletin_date_from").val(), "#bulletin_head_bulletin_date_from", "回覧期間(開始日)");
 if (!result) {
   return result;
 }
 /*回覧期間(終了日)の妥当性チェック*/
 result = checkDateFormat($("#bulletin_head_bulletin_date_to").val(), "#bulletin_head_bulletin_date_to", "回覧期間(終了日)");
 if (!result) {
   return result;
 }
 /*回覧期間(開始日)と回覧期間(終了日)の大小チェック*/
 result = compareDate(
     true,
     $("#bulletin_head_bulletin_date_from").val(), "", "",
     $("#bulletin_head_bulletin_date_to").val(), "", "",
     "回覧期間");
 if (!result) {
   return result;
 }
 return true;
}

/*
 * あいまい検索を行う
 *
 * @param sword - 検索したいキーワード
 */
function bulletin_search(sword){
  if(sword == ""){
    alert("検索キーワードを指定してください。")
  } else {
    $("#bulletin_area").load("main/bulletin_list?kbn_id=9&sword=" + encodeURIComponent(sword));
  }
  return false;
}

/*
 * 新規作成画面における、キャンセルボタンの処理
 * 押下されると一覧画面に戻る。
 */
function CancelBulletin(){
  $("a:contains('回覧板一覧')").click();
}
