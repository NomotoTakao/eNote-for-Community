//
// JavaScriptライブラリ  by Lighthouse
//

function GetRSSReader(){
  var trunk_id = "0";
  $("#trunk_id option:selected").each(function(){
    trunk_id = $(this).val();
  })
  var trunk_date = "0";
  $("#trunk_date option:selected").each(function(){
    trunk_date = $(this).val();
  })
    jQuery("#mypage_rss").load(base_uri + "/home/rss/rss_reader?trunk_id=" + trunk_id + "&trunk_date=" + trunk_date);
}

function ClickRssRegistButton(){
//	if ($("#rss_url_new").val().match(/xml$|rss|rdf|atom|feed|syndicate/)) {
    $.ajax({
      type: "GET",
      url: base_uri + "/home/rss/new_rss",
      data: {
        url: $("#rss_url_new").val()
      },
      success: function(result){
        if(result == "true"){
          window.open(base_uri + "/home/rss/setting", "_self");
        } else {
          alert(result);
        }
      }
    });
}

/*
* スケジュール登録画面表示
*/
//追加用
function dialog_reserve_open_ins(date){
  //画面遷移
  document.location = base_uri + "/schedule/reserve/new?date=" + encodeURIComponent(date);
  return false;
}

//更新用
function dialog_reserve_open_edit(id, repeat_flg){
  //画面遷移
  document.location = base_uri + "/schedule/reserve/" + id + "/edit?repeat_flg=" + repeat_flg;
  return false;
}
