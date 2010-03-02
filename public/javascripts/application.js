// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//
// ヘッダーメニュー
//
function make_header_menu(){
    $(".myMenu").buildMenu({
        template: "menuVoices.html",
        additionalData: "pippo=1",
        menuWidth: 200,
        openOnRight: false,
        menuSelector: ".menuContainer",
        iconPath: "../images/jquery/mbMenu/",
        hasImages: true,
        fadeInTime: 1,
        fadeOutTime: 1,
        adjustLeft: 2,
        minZindex: "auto",
        adjustTop: 10,
        opacity: 1,
        shadow: false,
        closeOnMouseOut: true,
//        closeAfter: 0,
        openOnClick: true
    });
}

/*
 * 検索ボタンクリック時の処理
 * button_flg(1:サイト内検索, 2:Google検索, 3:Yahoo検索)
 */
function click_header_search_button(button_flg){
  //検索キーワードを各フォームのhidden値に設定する
  //サイト内検索
  if (button_flg == 1) {
    $("#site_search_word").val($("#search_word").val());
  //Google検索
  } else if (button_flg == 2) {
    $("#q").val($("#search_word").val());
  //Yahoo検索
  } else if (button_flg == 3) {
    $("#p").val($("#search_word").val());
  }
}
  
//
// カレンダー
// jQuery-ui.datepickerに依存
// elem - カレンダーオブジェクトと連結したいjQueryオブジェクト
//
function setCalendar(elem){
    elem.datepicker({
        showOn: 'button',
        buttonImage: '../images/icons/icon-calendar.gif',
        buttonImageOnly: true,
        prompt: "日付の選択",
        clearText: 'クリア',
        closeText: '閉じる',
        prevText: '<前月',
        nextText: '次月>',
        currentText: '今日',
        monthNames: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
        dayNames: ['日曜', '月曜', '火曜', '水曜', '木曜', '金曜', '土曜'],
        dayNamesMin: ['日', '月', '火', '水', '木', '金', '土'],
        dateFormat: 'yy-mm-dd',
        showMonthAfterYear:true
    });
}
