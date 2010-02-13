/**
 * 月の配列
 */
var arrayMonth = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

/**
 * 引数に渡された日付の前日日付を取得する。
 *
 * @param currentDate - 基準となる日付
 * @return - 基準日付の前日日付
 */
function getPreviousDate(currentDate){
  var currentDate_array = currentDate.split("-");
  var objCurrentDate = new Date(Number(currentDate_array[0]), Number(currentDate_array[1])-1, currentDate_array[2]);
  var objPreviousDate = new Date();
  // 前日日付を得るため、日から'1'を引く
  var year = Number(objCurrentDate.getYear()) > 1900 ? objCurrentDate.getYear() : Number(objCurrentDate.getYear()) + 1900;
  objPreviousDate.setYear(year);
  objPreviousDate.setMonth(objCurrentDate.getMonth());
  objPreviousDate.setDate(objCurrentDate.getDate() - 1);
  var arrayPreviousDate = objPreviousDate.toGMTString().split(" ");
  var previousYear = arrayPreviousDate[3];
  var previousMonth = 1;
  for(m in arrayMonth){
    if(arrayMonth[m] == arrayPreviousDate[2]){
      break;
    }
    previousMonth++;
  }
  // 月を2桁で表わすため、１桁だったら先頭に'0'を追加する
  if(String(previousMonth).length<2){
    previousMonth = "0" + previousMonth;
  }

  var previousDay = arrayPreviousDate[1];
  // 日を2桁で表わすため、１桁だったら先頭に'0'を追加する
  if(String(previousDay).length<2){
    previousDay = "0" + previousDay;
  }

  return previousYear + "-" + previousMonth + "-" + previousDay;
}

/**
 * 引数に渡された日付の翌日日付を取得する。
 *
 * @param currentDate - 基準となる日付(yyyy-mm-dd)
 * @return - 基準日付の翌日日付
 */
function getNextDate(currentDate){

  var currentDate_array = currentDate.split("-");
  // Dateオブジェクトの月は0-11で表されるので、引数に渡された月から1を引いている。
  var objCurrentDate = new Date(currentDate_array[0], Number(currentDate_array[1], 10)-1, Number(currentDate_array[2], 10) + 1);
  var objNextDate = new Date();

  // ブラウザによって挙動が異なるため、年が1900より小さいときは、1900を加える。
  var year = Number(objCurrentDate.getYear()) > 1900 ? objCurrentDate.getYear() : Number(objCurrentDate.getYear()) + 1900;
  objNextDate.setYear(year);
  objNextDate.setMonth(objCurrentDate.getMonth());
  objNextDate.setDate(objCurrentDate.getDate());
  var arrayNextDate = objNextDate.toGMTString().split(" ");

  var nextYear = arrayNextDate[3];

  var nextMonth = 1;
  for(m in arrayMonth){
    if(arrayMonth[m] == arrayNextDate[2]){
      break;
    }
    nextMonth++;
  }
  // 月を2桁で表わすため、１桁だったら先頭に'0'を追加する
  if(String(nextMonth).length<2){
    nextMonth = "0" + nextMonth;
  }

  var nextDay = arrayNextDate[1];
  // 日を2桁で表わすため、１桁だったら先頭に'0'を追加する
  if(String(nextDay).length<2){
    nextDay = "0" + nextDay;
  }

  return nextYear + "-" + nextMonth + "-" + nextDay;
}

/**
 * 入力された日付が正当な日付かどうかを確認します。
 *
 *  @param date - チェック対象の日付
 *  @return 引数に渡された日付が正当な日付である場合、trueを返す。
 */
function checkDateValidity(date){
  var result = false;

  if(date != ""){
    var array_date = date.split("-");
    // 日付の構成要素が、年-月-日の３要素で構成されていることを確認
    if(array_date.length==3){
      // 日付のフォーマットが"yyyy-mm-dd"（年４桁、月２桁、日２桁）で構成されていることを確認
      if(array_date[0].length==4 && array_date[1].length==2 && array_date[2].length==2){
        // 年、月、日を１０進数として扱えるかをチェック
        if(parseInt(array_date[0], 10)!=0 && parseInt(array_date[1], 10)!=0 && parseInt(array_date[2], 10)!=0){
          for(i in array_date){
            if(parseInt(array_date[i]) == "NaN"){
              break;
            }
          }
          // すべてのチェックを通過した場合、正当な日付と判定する。
          result = true;
        }
      }
    }
  }

  return result;
}

/**
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


    function get_summary_comment(){

      report_date = $("#input_report_date").val();
      // 総括コメント・上司確認コメントを取得する。
      if(report_date!=""){
        jQuery.ajax(
          {
            type : "GET",
            url  : "/report/main/summary_comment",
            data :
              {
                date : report_date
              },
            success :
              function(data, dataType){
                $("#summary_comment").parent().after(data);
              },
            error :
              function(){
                alert("通信エラー");
              },
            complete :
              function(){}
          }
        );
      }
    }
