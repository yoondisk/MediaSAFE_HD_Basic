<%!
/* ==========================================================
   String Hex Util
 ========================================================== */
public static byte[] hexToByteArray(String hex) {
  if (hex == null || hex.length() == 0) {
   return null;
  }
  
  byte[] ba = new byte[hex.length() / 2];
   for (int i = 0; i < ba.length; i++) {
   ba[i] = (byte) Integer.parseInt(hex.substring(2 * i, 2 * i + 2), 16);
  }
  return ba;
}

public String toHex(int b) {
	char c[] = new char[2];
	c[0] = toHexNibble((b>>4) & 0x0f);
	c[1] = toHexNibble(b & 0x0f);
	return new String(c);
}

public char toHexNibble(int b) {
	if(b >= 0 && b <= 9)
		return (char)(b + '0');
	if(b >= 0x0a && b <= 0x0f)
		return (char)(b + 'A' - 10);
	return '0';
}

public String getString(byte[] data) {
	String result = "";
	for(int i=0; i<data.length; i++) {
		result = result + toHex(data[i]);
		if(i<data.length-1)
			result = result + ",";
	}
	return result;
}

/* ==========================================================
   ENCRYPT encrypt(byte[] iv, byte[] key, String str)
   Orgin string => Timestamp|String => String to hex => SEED ENCRYPT => Hex to String => Base64_encode => Encrypt String
 ========================================================== */
public String encrypt(byte[] iv, byte[] key, String str){
	Integer intUnixTime = (int)((long) System.currentTimeMillis()/1000) ;
	str= Integer.toString(intUnixTime)+"|"+str;
	byte[] strtobyte =str.getBytes();
	String cipherTextStr = getString(SEED_CBC_Encrypt(key, iv, strtobyte, 0, strtobyte.length));
	String hexStr=cipherTextStr.replaceAll(",","");
	byte[] bytes = hexToByteArray(hexStr);
	String encString = Base64.getEncoder().encodeToString(bytes);
	return encString;
}

/* ==========================================================
   ENCRYPT decrypt(byte[] iv, byte[] key, String str)
   Encrypt String => Base64_decode => String to hex  => SEED DECRYPT => Hex to String => TimeStamp Remove => Decrypt String
 ========================================================== */
public String decrypt(byte[] iv, byte[] key, String str){
	byte[] strtobyte =str.getBytes();
	byte[] decodedBytes = Base64.getDecoder().decode(strtobyte);
	String decString=new String(SEED_CBC_Decrypt(key, iv, decodedBytes, 0, decodedBytes.length));
	String[] arrurl = decString.split("\\|"); 
	return arrurl[1];
}
%>