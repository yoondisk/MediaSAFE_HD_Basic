//replaceAll prototype 선언
String.prototype.replaceAll_ = function(org, dest) {
    return this.split(org).join(dest);
}

function numFormat(variable) { variable = Number(variable).toString(); if(Number(variable) < 10 && variable.length == 1) variable = "0" + variable; return variable; }
	
function rpad(str, padLen, padStr) {
		if (padStr.length > padLen) {
			return str + "";
		}
		str += ""; // 문자로
		padStr += ""; // 문자로
		while (str.length < padLen)
			str += padStr;
		str = str.length >= padLen ? str.substring(0, padLen) : str;
		return str;
}

function log_(a){
		let today = new Date();   
		let hours = today.getHours(); // 시
		let minutes = today.getMinutes();  // 분
		let seconds = today.getSeconds();  // 초
		let milliseconds = today.getMilliseconds(); // 밀리초
		let stamp=numFormat(hours) + ':' + numFormat(minutes) + ':' + numFormat(seconds) + '.' + milliseconds;
		$('#info').val($('#info').val()+"[VideoJs Event] "+rpad(a,10," ")+" ("+stamp+")\r\n");	
}

var TimeFormat_str = function(totalsecond) {
		var second = Math.floor(totalsecond % 60);
		var minute = Math.floor(Math.floor(totalsecond / 60) % 60) ;
		var hour = Math.floor(totalsecond / 3600);
		if (second<0){second=0;}
		if (minute<0){minute=0;}
		if (hour<0){hour=0;}

		return hour+":"+((minute < 10)?"0":"")+minute+":" + ((second < 10)?"0":"")+second;
}

var getCookie_str = function(check_value) {
		check_value = check_value + "=";
		var x = 0;
		while (x <= document.cookie.length) {
			var y = (x + check_value.length);
			if (document.cookie.substring(x, y) == check_value) {
				if ((endOfCookie = document.cookie.indexOf(";", y)) == -1) {
					endOfCookie = document.cookie.length;
				}
				return unescape(document.cookie.substring(y, endOfCookie));
			}
			x = document.cookie.indexOf(" ", x) + 1;
			if (x == 0) {
				break;
			}
		}
		return "";
}

var setCookie_str = function(check_value, set_value, day_value) {
		var todayDate = new Date();
		todayDate.setDate(todayDate.getDate() + day_value);
		document.cookie = check_value + "=" + escape(set_value) + "; path=/; expires=" + todayDate.toGMTString() + ";"
}

var setMediaBookMarkStyle = function(objMediaBox, objMediaPlayer, strBookmarkName, objThis, intThisIndex, intBookmarkValue) {
		$.data(objThis,"BookmarkValue",intBookmarkValue);
		$(objThis).html(TimeFormat_str(intBookmarkValue));
		objMediaBox.find(".aBookMarkReSet_" + intThisIndex).remove();
		$(objThis).parent().append(" <a href=\"javascript:void(0)\" class=\"aBookMarkReSet_" + intThisIndex + "\">[수정]</a>");
		objMediaBox.find(".aBookMarkReSet_" + intThisIndex).click(function() {
			intBookmarkValue = player.currentTime();  
			setCookie_str(strBookmarkName + intThisIndex, intBookmarkValue, 365);
			setMediaBookMarkStyle(objMediaBox, objMediaPlayer, strBookmarkName, objThis, intThisIndex, intBookmarkValue);
		});
		$(objThis).unbind("click");
		$(objThis).click(function() {
			exeMediaMoveBookMark(objMediaBox, objMediaPlayer, objThis);
		});
}

var exeMediaMoveBookMark = function(objMediaBox, objMediaPlayer, objThis) {
		var intBookmarkValue = parseInt($.data(objThis,"BookmarkValue"));
		player.currentTime(intBookmarkValue);
}
