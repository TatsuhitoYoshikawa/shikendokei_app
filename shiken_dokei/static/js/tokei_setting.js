// alert(list_data[1])


/////////////////// 関数部 /////////////////////

// デジタル時計の表示らしく、常に2桁表示させる
function set2fig(num) {
  // 桁数が1桁だったら先頭に0を加えて2桁に調整する
  var ret;
  if( num < 10 ) { ret = "0" + num; }
  else { ret = num; }
  return ret;
}

// 現在時刻を取得・表示する（デジタル）
function GetTimeDigital() {
  //// 時刻取得
  // new演算子は後に来るコンストラクタのインスタンスを生成する
  // Dateコンストラクタからインスタンスを生成
  // 時間・分・秒をメソッドで取り出す
  var nowtime = new Date();
  var Hour = set2fig(nowtime.getHours());
  var Min = set2fig(nowtime.getMinutes());
  var Sec = set2fig(nowtime.getSeconds());

  // 文字列として結合したいので、最初に空白文字列を置いて、足していく
  var clock = "" + Hour + ":" + Min + ":" + Sec;
  
  //// 時刻表示を追記
  // htmlファイルにある要素を取得
  var target = document.getElementById('show_digi_clock');
  // 取得した要素に時刻表示を追記
  target.innerHTML = clock;
};


// 現在時刻を取得・表示する（アナログ）
function GetTimeAnalogue() {
// 時間を取得
var nowtime = new Date();
var Hour = nowtime.getHours();
var Min = nowtime.getMinutes();
var Sec = nowtime.getSeconds();

// 針の角度
var deg_h = Hour * (360 / 12) + Min * (360 / 12 / 60);
var deg_m = Min * (360 / 60);
var deg_s = Sec * (360 / 60);

// それぞれの針に角度を設定
document.querySelector(".hour").style.transform = `rotate(${deg_h}deg)`;
document.querySelector(".min").style.transform = `rotate(${deg_m}deg)`;
document.querySelector(".sec").style.transform = `rotate(${deg_s}deg)`;
}

// アナログ時計に特定の時刻を設定
function SetTimeAnalogue(s_hour, s_min, s_sec) {
// 針の角度
var deg_h = s_hour * (360 / 12) + s_min * (360 / 12 / 60);
var deg_m = s_min * (360 / 60);
var deg_s = s_sec * (360 / 60);  

// それぞれの針に角度を設定
document.querySelector(".hour").style.transform = `rotate(${deg_h}deg)`;
document.querySelector(".min").style.transform = `rotate(${deg_m}deg)`;
document.querySelector(".sec").style.transform = `rotate(${deg_s}deg)`;
}


// SETボタンを押すと指定の時刻で止める
function SetButtonAction(sh, sm, ss) {
// デジタル時計用の文字列に
const SET_TIME = set2fig(sh) + ":" + set2fig(sm) + ":" + set2fig(ss);
// デジタル時計のdiv要素を取得
var target = document.getElementById('show_digi_clock');
// 取得した要素に時刻をSET
target.innerHTML = SET_TIME;
SetTimeAnalogue(sh, sm, ss);
// setIntervalを止める＝時計の進行を止める
clearInterval(timerId_d);
clearInterval(timerId_a);

return SET_TIME;
}


// STARTボタンを押すと、止まっていた時刻から進み始める
function StartButtonAction(sh, sm, ss) {
  // 準備として、今日の日付を取得して文字列にする
  var tmp_ymd = new Date();
  var yyyy = tmp_ymd.getFullYear();
  var mm = set2fig(tmp_ymd.getMonth() + 1); /* 月は1少ない数で出てくる */
  var dd = set2fig(tmp_ymd.getDate());
  const YMD = yyyy + "-" + mm + "-" + dd + " ";

  // 押されたボタンで設定された時刻と今日の日付を連結して、時刻型に変換
  dt1 = new Date(YMD + SetButtonAction(sh, sm, ss));

  // 指定した時刻から1秒ずつ増やしていく
  let timerId_s = setInterval(function() {
    dt1.setSeconds(dt1.getSeconds() + 1);
    
    // アナログ時計用に数字で取得
    var renew_h = dt1.getHours();
    var renew_m = dt1.getMinutes();
    var renew_s = dt1.getSeconds();

    // デジタル時計用に2桁文字列変換
    var renew_clock = set2fig(renew_h) + ":" + set2fig(renew_m) + ":" + set2fig(renew_s);
    
    // デジタル時計のdiv要素を取得して表示
    var target = document.getElementById('show_digi_clock');
    target.innerHTML = renew_clock;

    // アナログ時計の時刻設定関数を流用
    SetTimeAnalogue(renew_h, renew_m, renew_s);
  }, 1000)
}



// 目標時間に対する残り時間の初期値を計算
function GetTimeDigital_for_nokori_initial(taisho) {
  //// 入力された目標時刻と開始時刻の差をカウントダウンさせていく

  // 今日の日付を取ってきて、それと開始時刻を結合
  var nowtime = new Date();
  var i_year = nowtime.getFullYear();
  var i_month = nowtime.getMonth() + 1;
  var i_day = nowtime.getDate();
  var today_tmp = i_year + "-" + i_month + "-" + i_day + " ";

  // 開始時刻を文字列で作成した後、日付型に変換
  let start_time = today_tmp + list_data[1] + ":" + list_data[2] + ":" + list_data[3];
  start_time = new Date(start_time);
  // 目標時刻も同様
  mokuhyo_time_str = "input_time" + taisho;
  mokuhyo_time = today_tmp + document.getElementById(mokuhyo_time_str).textContent;
  mokuhyo_time = new Date(mokuhyo_time)

  revised_time = (mokuhyo_time.getTime() - start_time.getTime()) / 1000;

  return revised_time;
};

// GetTimeDigital_for_nokori_initialで計算した残り時間の初期値（秒）をカウントダウンする
function MokuhyoCountDown(nokori, taisho) {
  // 1秒引く
  nokori = nokori - 1; 
  // 残り時間数を求める。3600秒で割った時の商の切り捨てが時間数
  nokori_hour = Math.floor(nokori / 3600);
  // 残り分数を求める。時間数を引いた後、60秒で割った時の商の切り捨てが分数
  nokori_min = Math.floor((nokori - Math.floor(nokori_hour * 3600) ) / 60);
  // 残り秒数を求める。更に分数を引いたものが残り秒数
  nokori_sec = nokori - nokori_hour * 3600 - nokori_min * 60;
  // 残り時間を文字列に
  nokori_hms = set2fig(nokori_hour) + ":" + set2fig(nokori_min) + ":" + set2fig(nokori_sec);

  // innerHTMLで表示する文字を塗り替え
  count_down_str = "last_time" + taisho;
  var nokori_jikan = document.getElementById(count_down_str);
  nokori_jikan.innerHTML = nokori_hms;

  // グローバル変数であるnokori_time1からも1引いておく
  // nokori_time1をsetIntervalでサイド参照することで、1秒ずつ減らしていく
  nokori_time1 = nokori_time1 - 1;
  console.log(nokori_time1);
}



//////////////////////// 関数部終了 ///////////////////////////



// アナログ時計の目盛り作成
// 5分ごとの太い目盛り
window.onload = function () {
  for (let i = 1; i <= 60; i++) {
      // scaleクラスの要素の最後にdiv要素を追加
      let scaleElem = document.querySelector(".scale");
      let addElem = document.createElement("div");
      // 5分、10分、15分、・・・の時とそれ以外で別のクラス名を付与
      if (i % 5 === 0) {
        addElem.className = 'sc_class1';
      } else {
        addElem.className = 'sc_class2';
      }
      scaleElem.appendChild(addElem);
  
      // 角度をつける
      // scaleクラスの下にあるdiv要素をforで60回追加（分の目盛り）するので、nth-child()でそれぞれを回転させる
      document.querySelector(".scale div:nth-child(" + i + ")").style.transform = `rotate(${i * 6}deg)`;
    }
  }


  //////////// 時刻表示を秒刻みで更新する /////////////////
let timerId_d = setInterval(GetTimeDigital, 100);
let timerId_a = setInterval(GetTimeAnalogue, 100);

// ユーザが選択した科目の開始時間に時計を合わせる
// index.htmlでユーザが入力した情報を、views.py->index.html(tojsonによる)を介してjavascriptに持ってくる
// pythonでlistのものはjavascriptで配列としてそのまま扱える
const time1_1 = list_data;
SetButtonAction(time1_1[1], time1_1[2], time1_1[3]);

//// STARTボタンを押すと、SETした時刻から時計が進み始める
start_button.addEventListener("click", function() {StartButtonAction(time1_1[1], time1_1[2], time1_1[3]);});


//// 切り替え表示の作成
// 要素取得
let digital_button = document.getElementById('digital_button');
let analogue_button = document.getElementById('analogue_button');
let show_digi_clock = document.getElementById('show_digi_clock');
let show_ana_clock = document.getElementById('show_ana_clock');

// 状態の初期化関数
reset_styles = function() {
    digital_button.classList.remove("active");
    analogue_button.classList.remove("active");
    show_digi_clock.classList.remove("active");
    show_ana_clock.classList.remove("active");
  };

// ボタンクリックに対する挙動
// クリックされたボタンのスタイルが活性になる
digital_button.addEventListener("click", function() {
    reset_styles();
    if (this.classList.toggle("active")) {
      show_digi_clock.classList.toggle("active");
    }
  })
analogue_button.addEventListener("click", function() {
    reset_styles();
    if (this.classList.toggle("active")) {
      show_ana_clock.classList.toggle("active");
    }
  });

// デフォルトではアナログ時計のみ表示
show_ana_clock.classList.toggle("active");
analogue_button.classList.toggle("active")

// 設定した目標時間に対する残り時間を表示
// 開始ボタンを押すとカウントダウンが始まる
let nokori_time1 = GetTimeDigital_for_nokori_initial(1) 

// 残り時間の初期値を表示する（別の場所でも使っているので関数化する）
nokori_hour = Math.floor(nokori_time1 / 3600);
nokori_min = Math.floor((nokori_time1 - Math.floor(nokori_hour * 3600) ) / 60);
nokori_sec = nokori_time1 - nokori_hour * 3600 - nokori_min * 60;
nokori_hms = set2fig(nokori_hour) + ":" + set2fig(nokori_min) + ":" + set2fig(nokori_sec);
var nokori_jikan = document.getElementById("last_time1");
nokori_jikan.innerHTML = nokori_hms;




start_button.addEventListener("click", function() {
          setInterval(function() {MokuhyoCountDown(nokori_time1, 1)}, 1000)
        });




