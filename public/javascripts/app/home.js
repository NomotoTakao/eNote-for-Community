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
    jQuery("#mypage_rss").load("/home/rss/rss_reader?trunk_id=" + trunk_id + "&trunk_date=" + trunk_date);
}

function ClickRssRegistButton(){
//	if ($("#rss_url_new").val().match(/xml$|rss|rdf|atom|feed|syndicate/)) {
    $.ajax({
      type: "GET",
      url: "/home/rss/new_rss",
      data: {
        url: $("#rss_url_new").val()
      },
      success: function(result){
        if(result == "true"){
          window.open("/home/rss/setting", "_self");
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
  document.location = "/schedule/reserve/new?date=" + encodeURIComponent(date);
  return false;
}

//更新用
function dialog_reserve_open_edit(id){
  //画面遷移
  document.location = "/schedule/reserve/" + id + "/edit";
  return false;
}
