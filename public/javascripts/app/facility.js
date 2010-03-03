/*
 * ダイアログの初期化
 */
//追加用
function dialog_reserve_ins(){
    jQuery("#dialog_ins").dialog({
        autoOpen:  false,
        modal:  true,
        width:  800,
        height: 500,
        close:
          function() {
            jQuery("#select_button").val(99);
            jQuery("#form_reserve").submit();
          }
    });
}

//更新用
function dialog_reserve_edit(){
    jQuery("#dialog_edit").dialog({
        autoOpen:  false,
        modal:  true,
        width:  800,
        height: 500,
        close:
          function() {
            jQuery("#select_button").val(99);
            jQuery("#form_reserve").submit();
          }
    });
}

/*
* ダイアログ表示
*/
//追加用
function dialog_reserve_open_ins(date, facility_cd){
    //一覧で施設のリンクをクリックされた場合
    if (facility_cd != "") {
      select_facility_cd = facility_cd;
      back_facility_cd = "";
    //遷移元のリストボックス選択情報(月,リスト)
    } else if ($("#facility_cd_h").val() != undefined) {
      select_facility_cd = $("#facility_cd_h").val();
      back_facility_cd = $("#facility_cd_h").val();
    } else {
      select_facility_cd = "";
      back_facility_cd = "";
    }
    //遷移元のリストボックス選択情報(週,日)
    if ($("#facility_group_list_h").val() != undefined) {
      back_group_checked_id = $("#facility_group_list_h").val();
    } else {
      back_group_checked_id = "";
    }

    //画面遷移
    jQuery("#dialog_ins").load(base_uri + "/facility/reserve/new?date=" + encodeURIComponent(date)
        + "&select_facility_cd=" + select_facility_cd
        + "&back_facility_cd=" + back_facility_cd + "&back_group_checked_id=" + back_group_checked_id);
    jQuery("#dialog_ins").dialog("open");
    return false;
}
//更新用
function dialog_reserve_open_edit(id, repeat_flg){
    //遷移元のリストボックス選択情報(月,リスト)
    if ($("#facility_cd_h").val() != undefined) {
      back_facility_cd = $("#facility_cd_h").val();
    } else {
      back_facility_cd = "";
    }
    //遷移元のリストボックス選択情報(週,日)
    if ($("#facility_group_list_h").val() != undefined) {
      back_group_checked_id = $("#facility_group_list_h").val();
    } else {
      back_group_checked_id = "";
    }

    //画面遷移
    jQuery("#dialog_edit").load(base_uri + "/facility/reserve/" + id + "/edit?repeat_flg=" + repeat_flg
        + "&back_facility_cd=" + back_facility_cd + "&back_group_checked_id=" + back_group_checked_id);
    jQuery("#dialog_edit").dialog("open");
    return false;
}

function displayError(){
    alert("ファイルの取得に失敗しました");
}

/*
 * 入力チェック
 */
function CheckValidate(){
  /*タイトルの必須チェック*/
  if (!inValueChk($("#reserve_title").val(),99,0,1,0,0,"タイトル")) {
      return false;
  }
  /*開始日の必須チェック*/
  if (!inValueChk($("#d_reserve_plan_date_from").val(),99,0,1,0,0,"開始日")) {
      return false;
  }
  /*終了日の必須チェック*/
  if (!inValueChk($("#d_reserve_plan_date_to").val(),99,0,1,0,0,"終了日")) {
      return false;
  }
  /*開始日の妥当性チェック*/
  result = checkDateFormat($("#d_reserve_plan_date_from").val(), "#d_reserve_plan_date_from", "開始日");
  if (!result) {
    return result;
  }
  /*終了日の妥当性チェック*/
  result = checkDateFormat($("#d_reserve_plan_date_to").val(), "#d_reserve_plan_date_to", "終了日");
  if (!result) {
    return result;
  }
  /*開始日時と終了日時の大小チェック*/
  result = compareDate(
      $("#reserve_plan_allday_flg").attr('checked'),
      $("#d_reserve_plan_date_from").val(), $("#reserve_plan_time_from_4i").val(), $("#reserve_plan_time_from_5i").val(),
      $("#d_reserve_plan_date_to").val(), $("#reserve_plan_time_to_4i").val(), $("#reserve_plan_time_to_5i").val(),
      "開始日付と終了日付");
  if (!result) {
    return result;
  }

  //繰り返し登録する場合
  if ($("#reserve_repeat_flg").attr('checked') == true) {
    /*繰り返し終了日の必須チェック*/
    if (!inValueChk($("#d_reserve_repeat_date_to").val(),99,0,1,0,0,"繰り返し終了日")) {
      return false;
    }
    /*繰り返し終了日の妥当性チェック*/
    result = checkDateFormat($("#d_reserve_repeat_date_to").val(), "#d_reserve_repeat_date_to", "繰り返し終了日");
    if (!result) {
      return result;
    }
    /*繰り返し終了日の指定可能日チェック*/
    //会社Mのデータを基に期のリストを作成する(0:1期末日, 1:2期末日..x:1期末日の1年後)
    term_list_work = $("#term_colon").val().split(",");
    term_list = new Array(term_list_work.length + 1);
    date_s = $("#d_reserve_plan_date_from").val();  //開始日(STRING型:YY-MM-DD)
    date_d = new Date(date_s.substring(0,4), date_s.substring(5,7)-1, date_s.substring(8,10));  //開始日(DATE型)
    //リスト作成
    for (i=0; i<term_list_work.length; i++) {
      term_list[i] = GetTermDate(date_s, term_list_work[i], 0);
    }
    term_list[term_list_work.length] = GetTermDate(date_s, term_list_work[0], 1); //1年後
    //直近の期末日を判定
    term_old = term_list[0];
    term_date = term_old;
    for (i=1; i<term_list.length; i++) {
      term_new = term_list[i];
      if ((term_old <= date_d) && (date_d < term_new)) {
        term_date = term_new;
        break;
      } else {
        term_old = term_new;
      }
    }
    //チェック
    repeat_date_to_s = $("#d_reserve_repeat_date_to").val();	//繰り返し終了日(STRING型:YY-MM-DD)
    repeat_date_to_d = new Date(repeat_date_to_s.substring(0,4), repeat_date_to_s.substring(5,7)-1, repeat_date_to_s.substring(8,10));  //繰り返し終了日(DATE型)
    term_date_disp = term_date.getFullYear() + "年" + (term_date.getMonth() + 1) + "月" + term_date.getDate() + "日";
    if (repeat_date_to_d > term_date) {
        alert("繰り返し終了日は「" + term_date_disp + "」以前の日付を指定してください。");
        return false;
    }
    /*繰り返し間隔の必須チェック*/
    if ($('input:radio[name=reserve[repeat_interval_flg]]:checked').val() == null) {
      alert("繰り返し間隔を指定してください。");
      return false;
    }
    //曜日指定の場合
    /*曜日の必須チェック*/
    if ($('input:radio[name=reserve[repeat_interval_flg]]:checked').val() == 2) {
      if ($("#reserve_repeat_week_sun_flg").attr('checked') == false
          && $("#reserve_repeat_week_mon_flg").attr('checked') == false
          && $("#reserve_repeat_week_tue_flg").attr('checked') == false
          && $("#reserve_repeat_week_wed_flg").attr('checked') == false
          && $("#reserve_repeat_week_thu_flg").attr('checked') == false
          && $("#reserve_repeat_week_fri_flg").attr('checked') == false
          && $("#reserve_repeat_week_sat_flg").attr('checked') == false) {
        alert("曜日を指定してください。");
        return false;
      }
    }
  }

  return true;
}

/*
 * 期末の日付を設定
 */
function GetTermDate(select_date, term_end, over_flg) {
  //年を跨ぐ場合
  if (over_flg == 1) {
    date = new Date(select_date.substring(0,4), select_date.substring(5,7)-1+12, select_date.substring(8,10));
  //年を跨がない場合
  } else {
    date = new Date(select_date.substring(0,4), select_date.substring(5,7)-1, select_date.substring(8,10));
  }
  year = date.getFullYear();
  term_end_work = year + term_end;
  term_end_yymmdd = new Date(term_end_work.substring(0,4), term_end_work.substring(4,6)-1, term_end_work.substring(6,8));
  return term_end_yymmdd;
}

/*
 * 終日のチェックボックスクリック時
 */
function ClickAllDayCheck(){
  //終日がチェックされた場合
  if ($("#reserve_plan_allday_flg").attr('checked') == true) {
    con_flg = true;
  //終日のチェックが外れた場合
  } else {
    con_flg = false;
  }

  //時間プルダウンを非活性にする
  document.getElementById("reserve_plan_time_from_4i").disabled = con_flg;  //開始時間
  document.getElementById("reserve_plan_time_from_5i").disabled = con_flg;
  document.getElementById("reserve_plan_time_to_4i").disabled = con_flg;    //終了時間
  document.getElementById("reserve_plan_time_to_5i").disabled = con_flg;
}