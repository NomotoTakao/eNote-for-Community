/*
 * マスタメンテナンス
 */

/*
 * 入力チェック(施設グループマスタ)
 */
function CheckValidateFacilityGroup(){
  /*施設グループ名の必須チェック*/
  if (!inValueChk($("#m_facility_groups_name").val(),99,0,1,0,0,"施設グループ名")) {
    return false;
  }
  /*表示順の半角数値チェック*/
  if (!inValueChk($("#m_facility_groups_sort_no").val(),0,0,0,0,0,"表示順")) {
    return false;
  }
  return true;
}

/*
* 入力チェック(施設マスタ)
*/
function CheckValidateFacility(){
 /*施設グループコードの必須チェック*/
 if (!inValueChk($("#select_facility_group_cd").val(),99,0,1,0,0,"施設グループコード")) {
   return false;
 }
 /*拠点コードの必須チェック*/
 if (!inValueChk($("#select_place_cd").val(),99,0,1,0,0,"拠点")) {
   return false;
 }
 /*組織コードの必須チェック*/
 if (!inValueChk($("#select_org_cd").val(),99,0,1,0,0,"組織")) {
   return false;
 }
 /*施設名の必須チェック*/
 if (!inValueChk($("#m_facilities_name").val(),99,0,1,0,0,"施設名")) {
   return false;
 }
 /*表示順の半角数値チェック*/
 if (!inValueChk($("#m_facilities_sort_no").val(),0,0,0,0,0,"表示順")) {
   return false;
 }
 return true;
}

/*
 * 入力チェック(職位マスタ)
 */
function CheckValidatePosition(){
  /*職位コードの必須チェック*/
  if (!inValueChk($("#m_positions_position_cd").val(),99,0,1,0,0,"職位コード")) {
    return false;
  }
  /*職位名の必須チェック*/
  if (!inValueChk($("#m_positions_name").val(),99,0,1,0,0,"職位名")) {
    return false;
  }
  /*職位順位の必須・半角数値チェック*/
  if (!inValueChk($("#m_positions_rank").val(),0,0,1,0,0,"職位順位")) {
    return false;
  }
  /*表示順の半角数値チェック*/
  if (!inValueChk($("#m_positions_sort_no").val(),0,0,0,0,0,"表示順")) {
    return false;
  }
  return true;
}

/*
 * 入力チェック(プロジェクトマスタ)
 */
function CheckValidateProject(){
  /*プロジェクト名称の必須チェック*/
  if (!inValueChk($("#m_projects_name").val(),99,0,1,0,0,"プロジェクト名称")) {
    return false;
  }
  /*開始日の必須チェック*/
  if (!inValueChk($("#m_projects_enable_date_from").val(),99,0,1,0,0,"開始日")) {
    return false;
  }
  /*終了日の必須チェック*/
  if (!inValueChk($("#m_projects_enable_date_to").val(),99,0,1,0,0,"終了日")) {
    return false;
  }
  /*開始日の妥当性チェック*/
  result = checkDateFormat($("#m_projects_enable_date_from").val(), "#m_projects_enable_date_from", "開始日");
  if (!result) {
    return result;
  }
  /*終了日の妥当性チェック*/
  result = checkDateFormat($("#m_projects_enable_date_to").val(), "#m_projects_enable_date_to", "終了日");
  if (!result) {
    return result;
  }
  /*開始日と終了日の大小チェック*/
  if ($("#m_projects_enable_date_from").val() > $("#m_projects_enable_date_to").val()) {
    alert("開始日と終了日の大小関係を正しく指定してください。");
    return false;
  }
  return true;
}

/*
 * 入力チェック(プロジェクトユーザマスタ)
 */
function CheckValidateProjectUser(){
  /*メンバーの必須チェック*/
  if (!inValueChk($("#decided_member_all").val(),99,0,1,0,0,"メンバー")) {
    return false;
  }
  return true;
}

/*
 * 入力チェック(カレンダーマスタ)
 */
function CheckValidateCalendar(){
  /*日付の必須チェック*/
  if (!inValueChk($("#m_calendars_day").val(),99,0,1,0,0,"日付")) {
   return false;
  }
  /*日付の妥当性チェック*/
  result = checkDateFormat($("#m_calendars_day").val(), "#m_calendar_day", "日付");
  if (!result) {
    return result;
  }
  return true;
}

/*
 * 入力チェック(拠点マスタ)
 */
function CheckValidatePlace(){
  /*拠点コードの必須チェック*/
  if (!inValueChk($("#m_places_place_cd").val(),99,0,1,0,0,"拠点コード")) {
   return false;
  }
  /*表示順の半角数値チェック*/
  if (!inValueChk($("#m_places_sort_no").val(),0,0,0,0,0,"表示順")) {
    return false;
  }
  /*郵便番号の形式チェック*/
  if (!inValueChk($("#m_places_zip_cd").val(),15,0,0,0,0,"郵便番号")) {
    return false;
  }
  return true;
}

/*
 * 入力チェック(会社マスタ)
 */
function CheckValidateCompany(){
  term1 = $("#m_companies_term_end1").val();
  term2 = $("#m_companies_term_end2").val();
  term3 = $("#m_companies_term_end3").val();
  term4 = $("#m_companies_term_end4").val();

  /*期末日１の必須チェック*/
  if (!inValueChk(term1,99,0,1,0,0,"期末日１")) {
   return false;
  }
  /*期末日１から順番に入力されているかチェック*/
  if (CheckNotEmpty(term2)) {
    if (!CheckNotEmpty(term1)) {
      alert("期末日１から順番に入力してください。");
      return false;
    }
  }
  if (CheckNotEmpty(term3)) {
    if (!CheckNotEmpty(term2)) {
      alert("期末日１から順番に入力してください。");
      return false;
    }
  }
  if (CheckNotEmpty(term4)) {
    if (!CheckNotEmpty(term3)) {
      alert("期末日１から順番に入力してください。");
      return false;
    }
  }

  /*半角数値, 4桁, 妥当性チェック*/
  if (!inValueChk(term1,0,0,0,0,0,"期末日１")) {
    return false;
  } else if (term1.length != 4) {
    alert("期末日１はMMDDの形式で入力してください。");
    return false;
  } else if (!CheckMMDDFormat(term1)) {
    alert("期末日１に正しい値を入力してください。");
    return false;
  }
  if (CheckNotEmpty(term2)) {
    if (!inValueChk(term2,0,0,0,0,0,"期末日２")) {
      return false;
    } else if (term2.length != 4) {
      alert("期末日２はMMDDの形式で入力してください。");
      return false;
    } else if (!CheckMMDDFormat(term2)) {
      alert("期末日２に正しい値を入力してください。");
      return false;
    }
  }
  if (CheckNotEmpty(term3)) {
    if (!inValueChk(term3,0,0,0,0,0,"期末日３")) {
      return false;
    } else if (term3.length != 4) {
      alert("期末日３はMMDDの形式で入力してください。");
      return false;
    } else if (!CheckMMDDFormat(term3)) {
      alert("期末日３に正しい値を入力してください。");
      return false;
    }
  }
  if (CheckNotEmpty(term4)) {
    if (!inValueChk(term4,0,0,0,0,0,"期末日４")) {
      return false;
    } else if (term4.length != 4) {
      alert("期末日４はMMDDの形式で入力してください。");
      return false;
    } else if (!CheckMMDDFormat(term4)) {
      alert("期末日４に正しい値を入力してください。");
      return false;
    }
  }

  /*日付の大小チェック*/
  if (CheckNotEmpty(term2)){
    if (term1 >= term2) {
      alert("期末日１ ＜期末日２ で入力してください。");
      return false;
    }
  }
  if (CheckNotEmpty(term3)){
    if (term2 >= term3) {
      alert("期末日２ ＜期末日３ で入力してください。");
      return false;
    }
  }
  if (CheckNotEmpty(term4)){
    if (term3 >= term4) {
      alert("期末日３ ＜期末日４ で入力してください。");
      return false;
    }
  }

  return true;
}

/*
 * 入力チェック(秘書マスタ)
 */
function CheckValidateSecretary(){
  //選択決定エリア(認証者)のデータを全て取得
  document.getElementById("decided_auth_user_all").value = GetAllSelectBox("decided_auth_user");
  //選択決定エリア(認証組織)のデータを全て取得
  document.getElementById("decided_auth_org_all").value = GetAllSelectBox("decided_auth_org");

  /*社員の必須チェック*/
  if (!inValueChk($("#decided_user_cd").val(),99,0,1,0,0,"社員")) {
    return false;
  }
  /*認証者、認証組織の必須チェック*/
  if (($("#decided_auth_user_all").val() == null || $("#decided_auth_user_all").val() == "")
      && ($("#decided_auth_org_all").val() == null || $("#decided_auth_org_all").val() == "")) {
    alert("認証者または認証組織のどちらかを指定してください。");
    return false;
  }
  return true;
}

/*
 * 入力チェック(ＮＧワードマスタ)
 */
function CheckValidateNgword(){
  /*ＮＧワードの必須チェック*/
  if (!inValueChk($("#m_ngwords_ng_word").val(),99,0,1,0,0,"ＮＧワード")) {
    return false;
  }
  return true;
}

/*
 * 入力チェック(ユーザマスタ)
 */
function CheckValidateUser(){
  //選択決定エリア(兼任所属)のデータを全て取得
  document.getElementById("decided_sub_org_all").value = GetAllSelectBox("decided_sub_org");

  /*ログインIDの必須チェック*/
  if (!inValueChk($("#m_users_login").val(),99,0,1,0,0,"ログインID")) {
    return false;
  }
  /*社員コードの必須チェック*/
  if (!inValueChk($("#m_users_user_cd").val(),99,0,1,0,0,"社員コード")) {
    return false;
  }
  /*社員名の必須チェック*/
  if (!inValueChk($("#m_users_name").val(),99,0,1,0,0,"社員名")) {
    return false;
  }
  /*パスワードの必須チェック*/
  if (!inValueChk($("#m_users_passwd").val(),99,0,1,0,0,"パスワード")) {
    return false;
  }
  /*パスワードの半角英数字チェック*/
  if (!inValueChk($("#m_users_passwd").val(),2,0,0,0,0,"パスワード")) {
    return false;
  }
  /*パスワードの形式チェック(全て同じ文字はNG)*/
  check = new RegExp("[^" + $("#m_users_passwd").val().charAt(0) + "]");
  if (!$("#m_users_passwd").val().match(check)) {
    alert("パスワードを正しく入力してください。\n(同じ文字のみの使用は避けてください。)");
    return false;
  }
  /*職種区分の半角数値チェック*/
  if (!inValueChk($("#m_users_job_kbn").val(),0,0,0,0,0,"職種区分")) {
    return false;
  }
  /*権限区分の半角数値チェック*/
  if (!inValueChk($("#m_users_authority_kbn").val(),0,0,0,0,0,"権限区分")) {
    return false;
  }
  /*入社日の妥当性チェック*/
  result = checkDateFormat($("#m_users_joined_date").val(), "#m_users_joined_date", "入社日");
  if (!result) {
    return result;
  }
  /*メールアドレスの形式チェック*/
  if (!inValueChk($("#m_users_email_address1").val(),14,0,0,0,0,"メールアドレス")) {
    return false;
  }
  /*携帯電話番号の形式チェック*/
  if (!inValueChk($("#m_users_mobile_no").val(),6,0,0,0,0,"携帯電話番号")) {
    return false;
  }
  /*携帯メールアドレスの形式チェック*/
  if (!inValueChk($("#m_users_mobile_address").val(),14,0,0,0,0,"携帯メールアドレス")) {
    return false;
  }
  /*主所属の必須チェック*/
  if (!inValueChk($("#m_users_main_belong_cd").val(),99,0,1,0,0,"主所属")) {
    return false;
  }

  return true;
}

/*
* 入力チェック(共用アドレス帳)
*/
function CheckValidatePublic(){
  //選択決定エリアのデータを全て取得
  document.getElementById("decided_member_all").value = GetAllSelectBox("decided_member");

  /*共用グループ名の必須チェック*/
  if (!inValueChk($("#title").val(),99,0,1,0,0,"共用グループ名")) {
    return false;
  }

  /*メンバーの必須チェック*/
  if (!inValueChk($("#decided_member_all").val(),99,0,1,0,0,"メンバー")) {
    return false;
  }
}

/*
* 入力チェック(パスワード変更)
*/
function CheckValidatePassword(){
  //現在のパスワードの必須チェック
  if ($("#password_old").val().length == 0) {
    alert("現在のパスワードを入力してください。");
    return false;
  }
  //新規パスワードの必須チェック
  if ($("#password_new").val().length < 4) {
    alert("新規パスワードは4桁以上で入力してください。");
    return false;
  }
  //新規パスワードの形式チェック(全て同じ文字はNG)
  check = new RegExp("[^" + $("#password_new").val().charAt(0) + "]");
  if (!$("#password_new").val().match(check)) {
    alert("新規パスワードを正しく入力してください。\n(同じ文字のみの使用は避けてください。)");
    return false;
  }
  //確認用パスワードの必須チェック
  if ($("#password_confirm").val().length == 0) {
    alert("確認用パスワードを入力してください。");
    return false;
  }
  //現在のパスワードと登録パスワードの妥当性チェック
  if ($("#password_old").val() != $("#password").val()) {
    alert("現在のパスワードを正しく入力してください。");
    return false;
  }
  //新規パスワードと確認用パスワードの妥当性チェック
  if ($("#password_new").val() != $("#password_confirm").val()) {
    alert("確認用パスワードを正しく入力してください。");
    return false;
  }
}

/*
 * 入力チェック(全社キャビネット)
 */
function CheckCompanyCabinet(){
  /*親index_typeが'f'であるかチェック*/
  if ($("#parent_index_type").val() != "f") {
    alert("1階層上の「階層」が'f (下階層にキャビネットが存在する)'でない為\nキャビネットを追加／更新できません。");
    return false;
  }
  /*タイトルの必須チェック*/
  if (!inValueChk($("#target_cabinet_data_title").val(),99,0,1,0,0,"タイトル")) {
    return false;
  }
  /*表示順の必須チェック*/
  if (!inValueChk($("#target_cabinet_data_order_display").val(),99,0,1,0,0,"表示順")) {
    return false;
  }
  return true;
}

/*
 * 入力チェック(お知らせ)
 */
function CheckNoticeBoard(){
  /*親index_typeが'f'であるかチェック*/
  if ($("#parent_index_type").val() != "f") {
    alert("1階層上の「階層」が'f (下階層にボードが存在する)'でない為\nボードを追加／更新できません。");
    return false;
  }
  /*タイトルの必須チェック*/
  if (!inValueChk($("#target_notice_data_title").val(),99,0,1,0,0,"タイトル")) {
    return false;
  }
  /*表示順(参照用)の必須チェック*/
  if (!inValueChk($("#target_notice_data_sort_no").val(),99,0,1,0,0,"表示順(参照用)")) {
    return false;
  }
  /*表示順(新規作成用)の必須チェック*/
  if (!inValueChk($("#target_notice_data_etcint2").val(),99,0,1,0,0,"表示順(新規作成用)")) {
    return false;
  }
  /*表示順(新規作成用)の妥当性チェック*/
  if ($("#index_type").val() == "f" && $("#target_notice_data_etcint2").val() != 0) {
    alert("階層が'f (下階層にボードが存在する)'の場合\n表示順(新規作成用)は'0'を指定してください。");
    return false;
  }
  if ($("#index_type").val() == "b" && $("#target_notice_data_etcint2").val() == 0) {
    alert("階層が'b (下階層にボードが存在しない)'の場合\n表示順(新規作成用)は'0'以外を指定してください。");
    return false;
  }
  return true;
}

/*
 * 入力チェック(掲示板)
 */
function CheckBbsBoard(){
  /*タイトルの必須チェック*/
  if (!inValueChk($("#target_bbs_data_title").val(),99,0,1,0,0,"タイトル")) {
    return false;
  }
  /*表示順の必須チェック*/
  if (!inValueChk($("#target_bbs_data_sort_no").val(),99,0,1,0,0,"表示順")) {
    return false;
  }
  return true;
}

  /*
   * 入力チェック(メニュー)
   */
  function CheckValidateMenu(){
    /*名称の必須チェック*/
    if (!inValueChk($("#m_menus_title").val(),99,0,1,0,0,"名称")) {
      return false;
    }
    /*表示順の必須チェック*/
    if (!inValueChk($("#m_menus_sort_no").val(),99,0,1,0,0,"表示順")) {
      return false;
    }

    /*表示順の妥当性チェック*/
    //重複チェック
    sort_no_old = $("#sort_no_old").val();
    sort_no_new = $("#m_menus_sort_no").val();
    sort_no_array = $("#sort_no_colon").val().split(",");
    err_flg = false;
    for (i=0; i<sort_no_array.length; i++) {
      //表示順が変更されて、他のデータと重複する場合
      if ($("#submit_flg").val() == 2) {  //更新
        if (sort_no_old != sort_no_new && sort_no_new == sort_no_array[i]) {
          err_flg = true;
          break;
        }
      } else {  //新規
        if (sort_no_new == sort_no_array[i]) {
          err_flg = true;
          break;
        }
      }
    }
    if (err_flg) {
      alert("表示順は、他のデータと異なる値を指定してください。");
      return false;
    }
    return true;
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

/*
 * 矢印クリック時の処理(候補→決定エリア：社員)
 *
 * @param fromElement - 移動元のオブジェクト
 * @param toElement - 移動先のオブジェクト
 */
function ClickAddDecided(fromElement, toElement){
  fromBox = document.getElementById(fromElement);
  toBox = document.getElementById(toElement);
  //メンバーの移動を行う
  if ((fromBox != null) && (toBox != null)) {
    while (fromBox.selectedIndex >= 0) {
      var newOption = new Option();
      //選択値のチェック
      for (var i = 0; i <toBox.length; i++) {
        if (fromBox.options[fromBox.selectedIndex].value == toBox.options[i].value) {
          alert("既に選択されているメンバーです。");
          return false;
        }
      }
      newOption.text = fromBox.options[fromBox.selectedIndex].text;
      newOption.value = fromBox.options[fromBox.selectedIndex].value;
      toBox.options[toBox.length] = newOption;
      fromBox.remove(fromBox.selectedIndex);
    }
  }
}

/*
 * 矢印クリック時の処理(決定→候補エリア：社員)
 */
function ClickAddUnDecided(){
  //メンバー移動
  $("#decided_member option:selected").each(function(){
    $("#undecided_member").append($(this));
  });
}

 /*
  * 矢印クリック時の処理(候補→決定エリア：組織)
  *
  * @param orgCd - 移動元の組織コード
  * @param orgName - 移動元の組織名称
  * @param toElement - 移動先のオブジェクト
  */
 function ClickAddDecidedOrg(orgCd, orgName, toElement){
    toBox = document.getElementById(toElement);
   //組織の移動を行う
   if ((orgCd != null && orgCd != "") && (toBox != null)) {
     var newOption = new Option();
     //選択値のチェック
     for (var i = 0; i <toBox.length; i++) {
       if (orgCd == toBox.options[i].value) {
         alert("既に選択されている組織です。");
         return false;
       }
     }
     newOption.text = orgName;
     newOption.value = orgCd;
     toBox.options[toBox.length] = newOption;
   }
 }

/*
 * 選択された要素を全て取得する(セレクトボックスのみ対象)
 *
 * @param element - 対象のオブジェクト
 * @return member - 対象のオブジェクトに含まれる全ての要素
 */
function GetAllSelectBox(element){
  var dBox = document.getElementById(element);
  var member = new Array(dBox.length);
  for (var i = 0; i < dBox.options.length; i++) {
    member[i] = dBox.options[i].value;
  }
  return member;
}

/*
 * nullまたは空チェック
 * nullまたは空でない場合にtrueを返却する
 */
function CheckNotEmpty(value){
  if (value == null || value == "") {
    return false;
  }
  return true;
}

/*
 * 指定された要素を削除する(セレクトボックスのみ対象)
 */
function DeleteElement(fromElement){
  //選択された要素を削除する
  fromBox = document.getElementById(fromElement);
  if (fromBox.selectedIndex >= 0) {
    fromBox.remove(fromBox.selectedIndex);
  }
}

/*
 * 月日の妥当性チェック
 * (年は閏年の2000年を使用してチェック)
 */
function CheckMMDDFormat(date_mmdd){
  vYear = 2000
  vMonth = date_mmdd.substring(0,2) - 1
  vDay = date_mmdd.substring(2,4)
  if(vMonth >= 0 && vMonth <= 11 && vDay >= 1 && vDay <= 31){
    var vDt = new Date(vYear, vMonth, vDay);
    if(isNaN(vDt)){
      return false;
    }else if(vDt.getFullYear() == vYear && vDt.getMonth() == vMonth && vDt.getDate() == vDay){
      return true;
    }else{
      return false;
    }
  }else{
    return false;
  }
  return true;
}

/*
 * マスタ一覧へ戻る
 */
function ClickBackToMasterList(){
  document.location = base_uri + "/master/maintenance";
}