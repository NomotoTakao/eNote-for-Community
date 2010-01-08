/*
 * 入力チェック(ログイン)
 */
function CheckLoginValidate(){
  //ログインIDの必須チェック
  if ($("#login").val().length == 0) {
    alert("ログインIDを入力してください。");
    return false;
  }
  //パスワードの必須チェック
  if ($("#password").val().length == 0) {
    alert("パスワードを入力してください。");
    return false;
  }
}

  /*
 * 入力チェック(パスワード変更)
 */
function CheckValidate(){
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