/*
 * 入力チェック(アドレス帳)
 */
function CheckValidate(){
  //名前の必須チェック
  if ($("#d_address_name").val().length == 0) {
    alert("名前を入力してください。");
    return false;
  }
  //メールアドレスの形式チェック
  if (!inValueChk($("#d_address_email_address1").val(),14,0,0,0,0,"メールアドレス")) {
    return false;
  }
  //メールアドレス(その他)の形式チェック
  if (!inValueChk($("#d_address_email_address2").val(),14,0,0,0,0,"メールアドレス(その他)")) {
    return false;
  }
  //メールアドレス(その他)の形式チェック
  if (!inValueChk($("#d_address_email_address3").val(),14,0,0,0,0,"メールアドレス(その他)")) {
    return false;
  }
  //携帯電話の形式チェック
  if (!inValueChk($("#d_address_mobile_no").val(),6,0,0,0,0,"携帯電話")) {
    return false;
  }
  //携帯メールアドレスの形式チェック
  if (!inValueChk($("#d_address_mobile_address").val(),14,0,0,0,0,"携帯メールアドレス")) {
    return false;
  }
  //勤務先郵便番号の形式チェック
  if (!inValueChk($("#d_address_company_zip_cd").val(),15,0,0,0,0,"勤務先郵便番号")) {
    return false;
  }
  //勤務先電話番号１の形式チェック
  if (!inValueChk($("#d_address_company_tel1").val(),6,0,0,0,0,"勤務先電話番号１")) {
    return false;
  }
  //勤務先電話番号２の形式チェック
  if (!inValueChk($("#d_address_company_tel2").val(),6,0,0,0,0,"勤務先電話番号２")) {
    return false;
  }
  //勤務先ＦＡＸの形式チェック
  if (!inValueChk($("#d_address_company_fax").val(),6,0,0,0,0,"勤務先ＦＡＸ")) {
    return false;
  }
  return true;
}

/*
* 入力チェック(グループ)
*/
function CheckGroupValidate(){
  //グループ名の必須チェック
  if ($("#d_address_group_title").val().length == 0) {
    alert("グループ名を入力してください。");
    return false;
  }
  //選択決定エリアの必須チェック
  if (document.getElementById("decided_member_").length == 0) {
    alert("メンバーを選択してください。");
    return false;
  }
  return true;
}

/*
* 入力チェック(グループ:追加のみ)
*/
function CheckGroupNewData(){
//  //既に同じグループ名が登録されていないかチェック
//  for (var i = 0; i < document.getElementById("address_condition").length; i++) {
//    if (document.getElementById("address_condition").options[i].text == $("#d_address_group_title").val()) {
//      alert("このグループ名は既に登録されています。");
//      return false;
//    }
//  }
  return true;
}

/*
* 入力チェック(グループ:更新のみ)
*/
function CheckGroupUpdateData(){
//  //グループ名を変更された場合
//  if ($("#title_old").val() != $("#d_address_group_title").val()) {
//    //既に同じグループ名が登録されていないかチェック
//    for (var i = 0; i < document.getElementById("address_condition").length; i++) {
//      if (document.getElementById("address_condition").options[i].text == $("#d_address_group_title").val()) {
//        alert("このグループ名は既に登録されています。");
//        return false;
//      }
//    }
//  }
  return true;
}

/*
 * メールの編集画面（ウィンドウ）を表示する
 */
function open_mail_edit_window(url) {
  window.open(url,'_blank','width=820,height=680,toolbar=no,scrollbars=yes');
}

/*
 * 矢印クリック時の処理
 */
function ClickMoveMember(moveMode) {
  var undBox = document.getElementById("undecided_member_");
  var dBox = document.getElementById("decided_member_");
  var leftBox = undBox;
  var rightBox = dBox;
  var fromBox, toBox;

  //移動元と移動先を決定する
  if (moveMode == 0) {
    fromBox = leftBox;
    toBox = rightBox;
  } else if (moveMode == 1) {
    fromBox = rightBox;
    toBox = leftBox;
  }

  //メンバーの移動を行う
  if ((fromBox != null) && (toBox != null)) {
    if(fromBox.length < 1 || fromBox.selectedIndex == -1) {
      alert("移動するメンバーを選択してください。");
      return false;
    }
    while (fromBox.selectedIndex >= 0) {
      var newOption = new Option();
      //選択値のチェック
      if (moveMode == 0) {
        for (var i = 0; i <dBox.length; i++) {
          if (fromBox.options[fromBox.selectedIndex].value == dBox.options[i].value) {
            alert("既に選択されているメンバーです。");
            return false;
          }
        }
      }
      newOption.text = fromBox.options[fromBox.selectedIndex].text;
      newOption.value = fromBox.options[fromBox.selectedIndex].value;
      toBox.options[toBox.length] = newOption;
      fromBox.remove(fromBox.selectedIndex);
    }
  }
  //選択決定エリアのデータを全て取得
  var member = new Array(dBox.length);
  for (var i = 0; i < dBox.options.length; i++) {
    member[i] = dBox.options[i].value;
  }
  document.getElementById("decided_member_new").value = member;
}

/*
 * 矢印クリック時の処理(全て)
 */
function ClickMoveAllMember(moveMode) {
  var undBox = document.getElementById("undecided_member_");
  var dBox = document.getElementById("decided_member_");
  var leftBox = undBox;
  var rightBox = dBox;
  var fromBox, toBox;

  //移動元と移動先を決定する
  if (moveMode == 0) {
    fromBox = leftBox;
    toBox = rightBox;
  } else if (moveMode == 1) {
    fromBox = rightBox;
    toBox = leftBox;
  }
  //全てを選択状態にする
  for (var i = 0; i < fromBox.options.length; i++) {
    fromBox.options[i].selected = true;
  }
  //矢印クリック時の処理(選択データのみ)
  ClickMoveMember(moveMode);
}

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