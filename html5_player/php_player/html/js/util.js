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
