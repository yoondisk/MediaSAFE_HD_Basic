<%

'@file KISA_SEED_CTR.asp
'@brief SEED CTR 암호 알고리즘
'@author Copyright (c) 2013 by KISA
'@remarks http://seed.kisa.or.kr/


Const OFFSET_4 = 4294967296
Const MAXINT_4 = 2147483647
Const OFFSET_2 = 65536
Const MAXINT_2 = 32767
Const HFF = 255
Const HFFFF = 65535
Const HFFFFFFFF = -1
Const HFF00FF = 16711935
Const HFFFFFF = 16777215
Const HFF00FF00 = -16711936
Const BIG_ENDIAN = 0
Const LITTLE_ENDIAN = 1

Dim ENDIAN
ENDIAN = BIG_ENDIAN

CLASS KISA_SEED_KEY_4CTR
public key_data(31)

private SUB Class_Initialize
Call arrayinit(key_data, 0, 32)
END SUB

END CLASS

CLASS KISA_SEED_INFO_4CTR
public encrypt
public ctr(3)
public seed_key
public ctr_buffer(3)
public buffer_length
public ctr_last_block(3)
public last_block_flag

private SUB Class_Initialize
encrypt = 0
Call arrayinit(ctr, 0, 4)
Set seed_key = NEW KISA_SEED_KEY_4CTR
Call arrayinit(ctr_buffer, 0, 4)
buffer_length = 0
Call arrayinit(ctr_last_block, 0, 4)
last_block_flag = 0
END SUB

public FUNCTION memcpy_byte2ctr(byref src, length)
Call memcpy_byte2int(ctr, src, length)
end FUNCTION

public FUNCTION memcpy_int2ctr_buffer(byref src, src_offset, length)
Call memcpy_int2int(ctr_buffer, src, src_offset, length)
end FUNCTION

public FUNCTION memcpy_int2ctr(byref src, src_offset, length)
Call memcpy_int2int(ctr, src, src_offset, length)
end FUNCTION

public FUNCTION memcpy_int2ctr_last_block(byref src, src_offset, length)
Call memcpy_int2int(ctr_last_block, src, src_offset, length)
end FUNCTION

public FUNCTION set_byte_for_int_ctr_buffer(b_offset, value)
Call set_byte_for_int(ctr_buffer, b_offset, value)
end FUNCTION

public FUNCTION BLOCK_XOR_CTR_ctr_buffer(byref IN_VALUE2)
Call KISA_SEED_CTR.BLOCK_XOR_CTR(ctr_buffer, 0, ctr_buffer, 0, IN_VALUE2, 0)
end FUNCTION

public FUNCTION KISA_SEED_Encrypt_Block_forCTR_ctr_buffer(byref v_out, out_offset, byref ks)
Call KISA_SEED_CTR.KISA_SEED_Encrypt_Block_forCTR(ctr_buffer, 0, v_out, out_offset, ks)
end FUNCTION


END CLASS

CLASS KISA_SEED_CTR_C

private LR_L0
private LR_L1
private LR_R0
private LR_R1
Public  BLOCK_SIZE_CTR
Public  BLOCK_SIZE_CTR_INT
private KC0
private KC1
private KC2
private KC3
private KC4
private KC5
private KC6
private KC7
private KC8
private KC9
private KC10
private KC11
private KC12
private KC13
private KC14
private KC15

private ABCD_A
private ABCD_B
private ABCD_C
private ABCD_D

private SS0
private SS1
private SS2
private SS3
Public KISA_DECRYPT
Public KISA_ENCRYPT

private SUB Class_Initialize

LR_L0 = 0
LR_L1 = 1
LR_R0 = 2
LR_R1 = 3
BLOCK_SIZE_CTR = 16
BLOCK_SIZE_CTR_INT = 4
KISA_DECRYPT = 0
KISA_ENCRYPT = 1

KC0 = &H9e3779b9
KC1 = &H3c6ef373
KC2 = &H78dde6e6
KC3 = &Hf1bbcdcc
KC4 = &He3779b99
KC5 = &Hc6ef3733
KC6 = &H8dde6e67
KC7 = &H1bbcdccf
KC8 = &H3779b99e
KC9 = &H6ef3733c
KC10 = &Hdde6e678
KC11 = &Hbbcdccf1
KC12 = &H779b99e3
KC13 = &Hef3733c6
KC14 = &Hde6e678d
KC15 = &Hbcdccf1b

ABCD_A = 0
ABCD_B = 1
ABCD_C = 2
ABCD_D = 3

SS0 = Array( _
                &H02989a1a8, &H005858184, &H016c6d2d4, &H013c3d3d0, &H014445054, &H01d0d111c, &H02c8ca0ac, &H025052124, _
                &H01d4d515c, &H003434340, &H018081018, &H01e0e121c, &H011415150, &H03cccf0fc, &H00acac2c8, &H023436360, _
                &H028082028, &H004444044, &H020002020, &H01d8d919c, &H020c0e0e0, &H022c2e2e0, &H008c8c0c8, &H017071314, _
                &H02585a1a4, &H00f8f838c, &H003030300, &H03b4b7378, &H03b8bb3b8, &H013031310, &H012c2d2d0, &H02ecee2ec, _
                &H030407070, &H00c8c808c, &H03f0f333c, &H02888a0a8, &H032023230, &H01dcdd1dc, &H036c6f2f4, &H034447074, _
                &H02ccce0ec, &H015859194, &H00b0b0308, &H017475354, &H01c4c505c, &H01b4b5358, &H03d8db1bc, &H001010100, _
                &H024042024, &H01c0c101c, &H033437370, &H018889098, &H010001010, &H00cccc0cc, &H032c2f2f0, &H019c9d1d8, _
                &H02c0c202c, &H027c7e3e4, &H032427270, &H003838380, &H01b8b9398, &H011c1d1d0, &H006868284, &H009c9c1c8, _
                &H020406060, &H010405050, &H02383a3a0, &H02bcbe3e8, &H00d0d010c, &H03686b2b4, &H01e8e929c, &H00f4f434c, _
                &H03787b3b4, &H01a4a5258, &H006c6c2c4, &H038487078, &H02686a2a4, &H012021210, &H02f8fa3ac, &H015c5d1d4, _
                &H021416160, &H003c3c3c0, &H03484b0b4, &H001414140, &H012425250, &H03d4d717c, &H00d8d818c, &H008080008, _
                &H01f0f131c, &H019899198, &H000000000, &H019091118, &H004040004, &H013435350, &H037c7f3f4, &H021c1e1e0, _
                &H03dcdf1fc, &H036467274, &H02f0f232c, &H027072324, &H03080b0b0, &H00b8b8388, &H00e0e020c, &H02b8ba3a8, _
                &H02282a2a0, &H02e4e626c, &H013839390, &H00d4d414c, &H029496168, &H03c4c707c, &H009090108, &H00a0a0208, _
                &H03f8fb3bc, &H02fcfe3ec, &H033c3f3f0, &H005c5c1c4, &H007878384, &H014041014, &H03ecef2fc, &H024446064, _
                &H01eced2dc, &H02e0e222c, &H00b4b4348, &H01a0a1218, &H006060204, &H021012120, &H02b4b6368, &H026466264, _
                &H002020200, &H035c5f1f4, &H012829290, &H00a8a8288, &H00c0c000c, &H03383b3b0, &H03e4e727c, &H010c0d0d0, _
                &H03a4a7278, &H007474344, &H016869294, &H025c5e1e4, &H026062224, &H000808080, &H02d8da1ac, &H01fcfd3dc, _
                &H02181a1a0, &H030003030, &H037073334, &H02e8ea2ac, &H036063234, &H015051114, &H022022220, &H038083038, _
                &H034c4f0f4, &H02787a3a4, &H005454144, &H00c4c404c, &H001818180, &H029c9e1e8, &H004848084, &H017879394, _
                &H035053134, &H00bcbc3c8, &H00ecec2cc, &H03c0c303c, &H031417170, &H011011110, &H007c7c3c4, &H009898188, _
                &H035457174, &H03bcbf3f8, &H01acad2d8, &H038c8f0f8, &H014849094, &H019495158, &H002828280, &H004c4c0c4, _
                &H03fcff3fc, &H009494148, &H039093138, &H027476364, &H000c0c0c0, &H00fcfc3cc, &H017c7d3d4, &H03888b0b8, _
                &H00f0f030c, &H00e8e828c, &H002424240, &H023032320, &H011819190, &H02c4c606c, &H01bcbd3d8, &H02484a0a4, _
                &H034043034, &H031c1f1f0, &H008484048, &H002c2c2c0, &H02f4f636c, &H03d0d313c, &H02d0d212c, &H000404040, _
                &H03e8eb2bc, &H03e0e323c, &H03c8cb0bc, &H001c1c1c0, &H02a8aa2a8, &H03a8ab2b8, &H00e4e424c, &H015455154, _
                &H03b0b3338, &H01cccd0dc, &H028486068, &H03f4f737c, &H01c8c909c, &H018c8d0d8, &H00a4a4248, &H016465254, _
                &H037477374, &H02080a0a0, &H02dcde1ec, &H006464244, &H03585b1b4, &H02b0b2328, &H025456164, &H03acaf2f8, _
                &H023c3e3e0, &H03989b1b8, &H03181b1b0, &H01f8f939c, &H01e4e525c, &H039c9f1f8, &H026c6e2e4, &H03282b2b0, _
                &H031013130, &H02acae2e8, &H02d4d616c, &H01f4f535c, &H024c4e0e4, &H030c0f0f0, &H00dcdc1cc, &H008888088, _
                &H016061214, &H03a0a3238, &H018485058, &H014c4d0d4, &H022426260, &H029092128, &H007070304, &H033033330, _
                &H028c8e0e8, &H01b0b1318, &H005050104, &H039497178, &H010809090, &H02a4a6268, &H02a0a2228, &H01a8a9298 _
)

SS1 = Array( _
                &H038380830, &H0e828c8e0, &H02c2d0d21, &H0a42686a2, &H0cc0fcfc3, &H0dc1eced2, &H0b03383b3, &H0b83888b0, _
                &H0ac2f8fa3, &H060204060, &H054154551, &H0c407c7c3, &H044044440, &H06c2f4f63, &H0682b4b63, &H0581b4b53, _
                &H0c003c3c3, &H060224262, &H030330333, &H0b43585b1, &H028290921, &H0a02080a0, &H0e022c2e2, &H0a42787a3, _
                &H0d013c3d3, &H090118191, &H010110111, &H004060602, &H01c1c0c10, &H0bc3c8cb0, &H034360632, &H0480b4b43, _
                &H0ec2fcfe3, &H088088880, &H06c2c4c60, &H0a82888a0, &H014170713, &H0c404c4c0, &H014160612, &H0f434c4f0, _
                &H0c002c2c2, &H044054541, &H0e021c1e1, &H0d416c6d2, &H03c3f0f33, &H03c3d0d31, &H08c0e8e82, &H098188890, _
                &H028280820, &H04c0e4e42, &H0f436c6f2, &H03c3e0e32, &H0a42585a1, &H0f839c9f1, &H00c0d0d01, &H0dc1fcfd3, _
                &H0d818c8d0, &H0282b0b23, &H064264662, &H0783a4a72, &H024270723, &H02c2f0f23, &H0f031c1f1, &H070324272, _
                &H040024242, &H0d414c4d0, &H040014141, &H0c000c0c0, &H070334373, &H064274763, &H0ac2c8ca0, &H0880b8b83, _
                &H0f437c7f3, &H0ac2d8da1, &H080008080, &H01c1f0f13, &H0c80acac2, &H02c2c0c20, &H0a82a8aa2, &H034340430, _
                &H0d012c2d2, &H0080b0b03, &H0ec2ecee2, &H0e829c9e1, &H05c1d4d51, &H094148490, &H018180810, &H0f838c8f0, _
                &H054174753, &H0ac2e8ea2, &H008080800, &H0c405c5c1, &H010130313, &H0cc0dcdc1, &H084068682, &H0b83989b1, _
                &H0fc3fcff3, &H07c3d4d71, &H0c001c1c1, &H030310131, &H0f435c5f1, &H0880a8a82, &H0682a4a62, &H0b03181b1, _
                &H0d011c1d1, &H020200020, &H0d417c7d3, &H000020202, &H020220222, &H004040400, &H068284860, &H070314171, _
                &H004070703, &H0d81bcbd3, &H09c1d8d91, &H098198991, &H060214161, &H0bc3e8eb2, &H0e426c6e2, &H058194951, _
                &H0dc1dcdd1, &H050114151, &H090108090, &H0dc1cccd0, &H0981a8a92, &H0a02383a3, &H0a82b8ba3, &H0d010c0d0, _
                &H080018181, &H00c0f0f03, &H044074743, &H0181a0a12, &H0e023c3e3, &H0ec2ccce0, &H08c0d8d81, &H0bc3f8fb3, _
                &H094168692, &H0783b4b73, &H05c1c4c50, &H0a02282a2, &H0a02181a1, &H060234363, &H020230323, &H04c0d4d41, _
                &H0c808c8c0, &H09c1e8e92, &H09c1c8c90, &H0383a0a32, &H00c0c0c00, &H02c2e0e22, &H0b83a8ab2, &H06c2e4e62, _
                &H09c1f8f93, &H0581a4a52, &H0f032c2f2, &H090128292, &H0f033c3f3, &H048094941, &H078384870, &H0cc0cccc0, _
                &H014150511, &H0f83bcbf3, &H070304070, &H074354571, &H07c3f4f73, &H034350531, &H010100010, &H000030303, _
                &H064244460, &H06c2d4d61, &H0c406c6c2, &H074344470, &H0d415c5d1, &H0b43484b0, &H0e82acae2, &H008090901, _
                &H074364672, &H018190911, &H0fc3ecef2, &H040004040, &H010120212, &H0e020c0e0, &H0bc3d8db1, &H004050501, _
                &H0f83acaf2, &H000010101, &H0f030c0f0, &H0282a0a22, &H05c1e4e52, &H0a82989a1, &H054164652, &H040034343, _
                &H084058581, &H014140410, &H088098981, &H0981b8b93, &H0b03080b0, &H0e425c5e1, &H048084840, &H078394971, _
                &H094178793, &H0fc3cccf0, &H01c1e0e12, &H080028282, &H020210121, &H08c0c8c80, &H0181b0b13, &H05c1f4f53, _
                &H074374773, &H054144450, &H0b03282b2, &H01c1d0d11, &H024250521, &H04c0f4f43, &H000000000, &H044064642, _
                &H0ec2dcde1, &H058184850, &H050124252, &H0e82bcbe3, &H07c3e4e72, &H0d81acad2, &H0c809c9c1, &H0fc3dcdf1, _
                &H030300030, &H094158591, &H064254561, &H03c3c0c30, &H0b43686b2, &H0e424c4e0, &H0b83b8bb3, &H07c3c4c70, _
                &H00c0e0e02, &H050104050, &H038390931, &H024260622, &H030320232, &H084048480, &H068294961, &H090138393, _
                &H034370733, &H0e427c7e3, &H024240420, &H0a42484a0, &H0c80bcbc3, &H050134353, &H0080a0a02, &H084078783, _
                &H0d819c9d1, &H04c0c4c40, &H080038383, &H08c0f8f83, &H0cc0ecec2, &H0383b0b33, &H0480a4a42, &H0b43787b3 _
)

SS2 = Array( _
                &H0a1a82989, &H081840585, &H0d2d416c6, &H0d3d013c3, &H050541444, &H0111c1d0d, &H0a0ac2c8c, &H021242505, _
                &H0515c1d4d, &H043400343, &H010181808, &H0121c1e0e, &H051501141, &H0f0fc3ccc, &H0c2c80aca, &H063602343, _
                &H020282808, &H040440444, &H020202000, &H0919c1d8d, &H0e0e020c0, &H0e2e022c2, &H0c0c808c8, &H013141707, _
                &H0a1a42585, &H0838c0f8f, &H003000303, &H073783b4b, &H0b3b83b8b, &H013101303, &H0d2d012c2, &H0e2ec2ece, _
                &H070703040, &H0808c0c8c, &H0333c3f0f, &H0a0a82888, &H032303202, &H0d1dc1dcd, &H0f2f436c6, &H070743444, _
                &H0e0ec2ccc, &H091941585, &H003080b0b, &H053541747, &H0505c1c4c, &H053581b4b, &H0b1bc3d8d, &H001000101, _
                &H020242404, &H0101c1c0c, &H073703343, &H090981888, &H010101000, &H0c0cc0ccc, &H0f2f032c2, &H0d1d819c9, _
                &H0202c2c0c, &H0e3e427c7, &H072703242, &H083800383, &H093981b8b, &H0d1d011c1, &H082840686, &H0c1c809c9, _
                &H060602040, &H050501040, &H0a3a02383, &H0e3e82bcb, &H0010c0d0d, &H0b2b43686, &H0929c1e8e, &H0434c0f4f, _
                &H0b3b43787, &H052581a4a, &H0c2c406c6, &H070783848, &H0a2a42686, &H012101202, &H0a3ac2f8f, &H0d1d415c5, _
                &H061602141, &H0c3c003c3, &H0b0b43484, &H041400141, &H052501242, &H0717c3d4d, &H0818c0d8d, &H000080808, _
                &H0131c1f0f, &H091981989, &H000000000, &H011181909, &H000040404, &H053501343, &H0f3f437c7, &H0e1e021c1, _
                &H0f1fc3dcd, &H072743646, &H0232c2f0f, &H023242707, &H0b0b03080, &H083880b8b, &H0020c0e0e, &H0a3a82b8b, _
                &H0a2a02282, &H0626c2e4e, &H093901383, &H0414c0d4d, &H061682949, &H0707c3c4c, &H001080909, &H002080a0a, _
                &H0b3bc3f8f, &H0e3ec2fcf, &H0f3f033c3, &H0c1c405c5, &H083840787, &H010141404, &H0f2fc3ece, &H060642444, _
                &H0d2dc1ece, &H0222c2e0e, &H043480b4b, &H012181a0a, &H002040606, &H021202101, &H063682b4b, &H062642646, _
                &H002000202, &H0f1f435c5, &H092901282, &H082880a8a, &H0000c0c0c, &H0b3b03383, &H0727c3e4e, &H0d0d010c0, _
                &H072783a4a, &H043440747, &H092941686, &H0e1e425c5, &H022242606, &H080800080, &H0a1ac2d8d, &H0d3dc1fcf, _
                &H0a1a02181, &H030303000, &H033343707, &H0a2ac2e8e, &H032343606, &H011141505, &H022202202, &H030383808, _
                &H0f0f434c4, &H0a3a42787, &H041440545, &H0404c0c4c, &H081800181, &H0e1e829c9, &H080840484, &H093941787, _
                &H031343505, &H0c3c80bcb, &H0c2cc0ece, &H0303c3c0c, &H071703141, &H011101101, &H0c3c407c7, &H081880989, _
                &H071743545, &H0f3f83bcb, &H0d2d81aca, &H0f0f838c8, &H090941484, &H051581949, &H082800282, &H0c0c404c4, _
                &H0f3fc3fcf, &H041480949, &H031383909, &H063642747, &H0c0c000c0, &H0c3cc0fcf, &H0d3d417c7, &H0b0b83888, _
                &H0030c0f0f, &H0828c0e8e, &H042400242, &H023202303, &H091901181, &H0606c2c4c, &H0d3d81bcb, &H0a0a42484, _
                &H030343404, &H0f1f031c1, &H040480848, &H0c2c002c2, &H0636c2f4f, &H0313c3d0d, &H0212c2d0d, &H040400040, _
                &H0b2bc3e8e, &H0323c3e0e, &H0b0bc3c8c, &H0c1c001c1, &H0a2a82a8a, &H0b2b83a8a, &H0424c0e4e, &H051541545, _
                &H033383b0b, &H0d0dc1ccc, &H060682848, &H0737c3f4f, &H0909c1c8c, &H0d0d818c8, &H042480a4a, &H052541646, _
                &H073743747, &H0a0a02080, &H0e1ec2dcd, &H042440646, &H0b1b43585, &H023282b0b, &H061642545, &H0f2f83aca, _
                &H0e3e023c3, &H0b1b83989, &H0b1b03181, &H0939c1f8f, &H0525c1e4e, &H0f1f839c9, &H0e2e426c6, &H0b2b03282, _
                &H031303101, &H0e2e82aca, &H0616c2d4d, &H0535c1f4f, &H0e0e424c4, &H0f0f030c0, &H0c1cc0dcd, &H080880888, _
                &H012141606, &H032383a0a, &H050581848, &H0d0d414c4, &H062602242, &H021282909, &H003040707, &H033303303, _
                &H0e0e828c8, &H013181b0b, &H001040505, &H071783949, &H090901080, &H062682a4a, &H022282a0a, &H092981a8a _
)

SS3 = Array( _
                &H008303838, &H0c8e0e828, &H00d212c2d, &H086a2a426, &H0cfc3cc0f, &H0ced2dc1e, &H083b3b033, &H088b0b838, _
                &H08fa3ac2f, &H040606020, &H045515415, &H0c7c3c407, &H044404404, &H04f636c2f, &H04b63682b, &H04b53581b, _
                &H0c3c3c003, &H042626022, &H003333033, &H085b1b435, &H009212829, &H080a0a020, &H0c2e2e022, &H087a3a427, _
                &H0c3d3d013, &H081919011, &H001111011, &H006020406, &H00c101c1c, &H08cb0bc3c, &H006323436, &H04b43480b, _
                &H0cfe3ec2f, &H088808808, &H04c606c2c, &H088a0a828, &H007131417, &H0c4c0c404, &H006121416, &H0c4f0f434, _
                &H0c2c2c002, &H045414405, &H0c1e1e021, &H0c6d2d416, &H00f333c3f, &H00d313c3d, &H08e828c0e, &H088909818, _
                &H008202828, &H04e424c0e, &H0c6f2f436, &H00e323c3e, &H085a1a425, &H0c9f1f839, &H00d010c0d, &H0cfd3dc1f, _
                &H0c8d0d818, &H00b23282b, &H046626426, &H04a72783a, &H007232427, &H00f232c2f, &H0c1f1f031, &H042727032, _
                &H042424002, &H0c4d0d414, &H041414001, &H0c0c0c000, &H043737033, &H047636427, &H08ca0ac2c, &H08b83880b, _
                &H0c7f3f437, &H08da1ac2d, &H080808000, &H00f131c1f, &H0cac2c80a, &H00c202c2c, &H08aa2a82a, &H004303434, _
                &H0c2d2d012, &H00b03080b, &H0cee2ec2e, &H0c9e1e829, &H04d515c1d, &H084909414, &H008101818, &H0c8f0f838, _
                &H047535417, &H08ea2ac2e, &H008000808, &H0c5c1c405, &H003131013, &H0cdc1cc0d, &H086828406, &H089b1b839, _
                &H0cff3fc3f, &H04d717c3d, &H0c1c1c001, &H001313031, &H0c5f1f435, &H08a82880a, &H04a62682a, &H081b1b031, _
                &H0c1d1d011, &H000202020, &H0c7d3d417, &H002020002, &H002222022, &H004000404, &H048606828, &H041717031, _
                &H007030407, &H0cbd3d81b, &H08d919c1d, &H089919819, &H041616021, &H08eb2bc3e, &H0c6e2e426, &H049515819, _
                &H0cdd1dc1d, &H041515011, &H080909010, &H0ccd0dc1c, &H08a92981a, &H083a3a023, &H08ba3a82b, &H0c0d0d010, _
                &H081818001, &H00f030c0f, &H047434407, &H00a12181a, &H0c3e3e023, &H0cce0ec2c, &H08d818c0d, &H08fb3bc3f, _
                &H086929416, &H04b73783b, &H04c505c1c, &H082a2a022, &H081a1a021, &H043636023, &H003232023, &H04d414c0d, _
                &H0c8c0c808, &H08e929c1e, &H08c909c1c, &H00a32383a, &H00c000c0c, &H00e222c2e, &H08ab2b83a, &H04e626c2e, _
                &H08f939c1f, &H04a52581a, &H0c2f2f032, &H082929012, &H0c3f3f033, &H049414809, &H048707838, &H0ccc0cc0c, _
                &H005111415, &H0cbf3f83b, &H040707030, &H045717435, &H04f737c3f, &H005313435, &H000101010, &H003030003, _
                &H044606424, &H04d616c2d, &H0c6c2c406, &H044707434, &H0c5d1d415, &H084b0b434, &H0cae2e82a, &H009010809, _
                &H046727436, &H009111819, &H0cef2fc3e, &H040404000, &H002121012, &H0c0e0e020, &H08db1bc3d, &H005010405, _
                &H0caf2f83a, &H001010001, &H0c0f0f030, &H00a22282a, &H04e525c1e, &H089a1a829, &H046525416, &H043434003, _
                &H085818405, &H004101414, &H089818809, &H08b93981b, &H080b0b030, &H0c5e1e425, &H048404808, &H049717839, _
                &H087939417, &H0ccf0fc3c, &H00e121c1e, &H082828002, &H001212021, &H08c808c0c, &H00b13181b, &H04f535c1f, _
                &H047737437, &H044505414, &H082b2b032, &H00d111c1d, &H005212425, &H04f434c0f, &H000000000, &H046424406, _
                &H0cde1ec2d, &H048505818, &H042525012, &H0cbe3e82b, &H04e727c3e, &H0cad2d81a, &H0c9c1c809, &H0cdf1fc3d, _
                &H000303030, &H085919415, &H045616425, &H00c303c3c, &H086b2b436, &H0c4e0e424, &H08bb3b83b, &H04c707c3c, _
                &H00e020c0e, &H040505010, &H009313839, &H006222426, &H002323032, &H084808404, &H049616829, &H083939013, _
                &H007333437, &H0c7e3e427, &H004202424, &H084a0a424, &H0cbc3c80b, &H043535013, &H00a02080a, &H087838407, _
                &H0c9d1d819, &H04c404c0c, &H083838003, &H08f838c0f, &H0cec2cc0e, &H00b33383b, &H04a42480a, &H087b3b437 _
)
END SUB

private function GetB0(A)
	GETB0 = MASK(A, HFF)
end function

private function GetB1(A)
	GETB1 = HFF and SRShift(A,8)
end function

private function GetB2(A)
	GETB2 = HFF and SRShift(A,16)
end function

private function GetB3(A)
	GETB3 = HFF and SRShift(A,24)
end function


private function Round(byref x, i7,i6,i5,i4,i3,i2,i1,i0, byref key,key_offset)
	x(i1) = (x(i1) + ((F1(x(i0)) xor key(key_offset+0)) and HFF)) and HFF
	x(i3) = (x(i3) xor ((F0(x(i2)) + key(key_offset+1)) and HFF)) and HFF
	x(i5) = (x(i5) + ((F1(x(i4)) xor key(key_offset+2)) and HFF)) and HFF
	x(i7) = (x(i7) xor ((F0(x(i6)) + key(key_offset+3)) and HFF)) and HFF
end function


private function SeedRound(byref T, byref LR, L0, L1, R0, R1, byref K, K_offset)
	T(0) = LR(R0) xor K(K_offset+0)
	T(1) = LR(R1) xor K(K_offset+1)
	T(1) = T(1) xor T(0)
	T(1) = SS0(GetB0(T(1)) and HFF) xor SS1(GetB1(T(1)) and HFF) xor SS2(GetB2(T(1)) and HFF) xor SS3(GetB3(T(1)) and HFF)
	T(0) = MASK((T(0) + T(1)), HFFFFFFFF)
	T(0) = SS0(GetB0(T(0)) and HFF) xor SS1(GetB1(T(0)) and HFF) xor SS2(GetB2(T(0)) and HFF) xor SS3(GetB3(T(0)) and HFF)
	T(1) = MASK((T(1) + T(0)), HFFFFFFFF)
	T(1) = SS0(GetB0(T(1)) and HFF) xor SS1(GetB1(T(1)) and HFF) xor SS2(GetB2(T(1)) and HFF) xor SS3(GetB3(T(1)) and HFF)
	T(0) = MASK((T(0) + T(1)), HFFFFFFFF)
	LR(L0) = LR(L0) xor T(0)
	LR(L1) = LR(L1) xor T(1)
end function

private function EndianChange(dwS)
	EndianChange = ((  (  SLShift(dwS,8) or ( SRShift(dwS, 32-8) and HFF ) ) and HFF00FF ) or ( ( SLShift(dwS,24) or ( SRShift(dwS, 32-24) and HFFFFFF ) ) and HFF00FF00 ))
end function

private function RoundKeyUpdate0(byref T, byref SK, K_offset, byref ABCD, KC)
	T(0) = MASK(((ABCD(ABCD_A) and HFFFFFFFF) + (ABCD(ABCD_C) and HFFFFFFFF) - (KC and HFFFFFFFF)), HFFFFFFFF)
	T(1) = MASK(((ABCD(ABCD_B) and HFFFFFFFF) + (KC and HFFFFFFFF) - (ABCD(ABCD_D) and HFFFFFFFF)), HFFFFFFFF)
	SK.key_data(K_offset+0) = SS0(GetB0(T(0)) and HFF) xor SS1(GetB1(T(0)) and HFF) xor SS2(GetB2(T(0)) and HFF) xor SS3(GetB3(T(0)) and HFF)
	SK.key_data(K_offset+1) = SS0(GetB0(T(1)) and HFF) xor SS1(GetB1(T(1)) and HFF) xor SS2(GetB2(T(1)) and HFF) xor SS3(GetB3(T(1)) and HFF)
	T(0) = ABCD(ABCD_A)
	ABCD(ABCD_A) = (SRShift(ABCD(ABCD_A),8) and HFFFFFF) xor SLShift(ABCD(ABCD_B), 24)
	ABCD(ABCD_B) = (SRShift(ABCD(ABCD_B),8) and HFFFFFF) xor SLShift(T(0),24)
end function

private function RoundKeyUpdate1(byref T, byref SK, K_offset, byref ABCD, KC)
	T(0) = MASK((ABCD(ABCD_A) + ABCD(ABCD_C) - KC), HFFFFFFFF)
	T(1) = MASK((ABCD(ABCD_B) + KC - ABCD(ABCD_D)), HFFFFFFFF)
	SK.key_data(K_offset+0) = SS0(GetB0(T(0)) and HFF) xor SS1(GetB1(T(0)) and HFF) xor SS2(GetB2(T(0)) and HFF) xor SS3(GetB3(T(0)) and HFF)
	SK.key_data(K_offset+1) = SS0(GetB0(T(1)) and HFF) xor SS1(GetB1(T(1)) and HFF) xor SS2(GetB2(T(1)) and HFF) xor SS3(GetB3(T(1)) and HFF)
	T(0) = ABCD(ABCD_C)
	ABCD(ABCD_C) = SLShift(ABCD(ABCD_C),8) xor (SRShift(ABCD(ABCD_D),24) and HFF)
	ABCD(ABCD_D) = SLShift(ABCD(ABCD_D),8) xor (SRShift(T(0),24) and HFF)
end function

public function BLOCK_XOR_SEED(byref OUT_VALUE, OUT_VALUE_offset, byref IN_VALUE1, IN_VALUE1_offset, byref IN_VALUE2, IN_VALUE2_offset)
	Dim invalue1(3)
	Dim invalue2(3)

	for i=0 to 3
	if IN_VALUE1_offset+i<=uBound(IN_VALUE1) then
		invalue1(i) = IN_VALUE1(IN_VALUE1_offset+i)
	else
		invalue1(i) = 0
	end if
	Next
	
	for i=0 to 3
	if IN_VALUE2_offset+i<=uBound(IN_VALUE2) then
		invalue2(i) = IN_VALUE2(IN_VALUE2_offset+i)
	else
		invalue2(i) = 0
	end if
	next

	OUT_VALUE(OUT_VALUE_offset+0) = invalue1(0) xor invalue2(0)
	OUT_VALUE(OUT_VALUE_offset+1) = invalue1(1) xor invalue2(1)
	OUT_VALUE(OUT_VALUE_offset+2) = invalue1(2) xor invalue2(2)
	OUT_VALUE(OUT_VALUE_offset+3) = invalue1(3) xor invalue2(3)

end function



public function UpdateCounter_for_SEED( byref pbOUT, pbOUT_offset, nIncreaseValue, nMin ) 
	Dim bszBackup
	Dim i
	Dim b

	bszBackup = 0 

	if( 0 > nMin ) then

	Else 

		if( 0 < nMin ) then
			b = get_byte_for_int(pbOUT, pbOUT_offset*4+nMin)
			bszBackup = b and HFF
			Call set_byte_for_int(pbOUT, pbOUT_offset*4+nMin, HFF And (b + nIncreaseValue))
		End if

		For i=nMin To 1 Step -1

			if( bszBackup <= ((Cint(get_byte_for_int(pbOUT, pbOUT_offset*4+i))) and HFF)) Then
				Exit function

			else 
				b = get_byte_for_int(pbOUT, pbOUT_offset*4+i-1)
				bszBackup = b and HFF
				Call set_byte_for_int(pbOUT, pbOUT_offset*4+i-1, HFF And (b + 1))
			End If

		Next
	End if

	b = get_byte_for_int(pbOUT, pbOUT_offset*4+0)
	bszBackup = b and HFF
	Call set_byte_for_int(pbOUT, pbOUT_offset*4+0, HFF And (b + nIncreaseValue))
end function

'chartoint32_for_SEED_CTR
'@brief byte 배열을 int 배열로 변환한다.
'@param v_in :변환할 byte 포인터
'@param nLen : 변환할 byte 배열 갯수
'@return 인자로 받은 byte 배열의 int로 변환된 포인터를 반환한다.
public function chartoint32_for_SEED_CTR(byref v_in, inLen)

	Dim data
	Dim len
	Dim i

	len = 0
	i = 0

	if (inLen mod 4) > 0 then
		len = (HFF and ((int)(inLen/4))) + 1
	else
		len = (HFF and ((int)(inLen/4)))
	end if
	ReDim data(len-1)

	for i=0 to (len-1)
		Call byte_to_int(data, i, v_in, i*4)
	next

	chartoint32_for_SEED_CTR = data
end function

'@brief int 배열을 BYTE 배열로 변환한다.
'@param v_in :변환할 int 포인터
'@param inLen : 변환할 int 배열 갯수
'@return 인자로 받은 int 배열을 char로 변환한 포인터를 반환한다.
public function int32tochar_for_SEED_CTR(byref v_in, inLen)
Dim data
Dim i

i = 0
ReDim data(inLen-1)

if ENDIAN = LITTLE_ENDIAN then
	for i=0 to (inLen-1)
		data(i) = HFF and (SRShift(v_in(FIX(i/4)), ((i mod 4)*8)))
	next
else
	for i=0 to (inLen-1)
		data(i) = HFF and (SRShift(v_in(FIX(i/4)), ((3 - (i mod 4))*8)))
	next
end if

int32tochar_for_SEED_CTR = data

end function




public function KISA_SEED_Encrypt_Block_forCTR(byref v_in, in_offset, byref v_out, out_offset, byref ks)
	Dim LR(3)
	Dim T(1)

	Call arrayinit(LR, 0, 4)
	Call arrayinit(T, 0, 2)

	LR(LR_L0) = v_in(in_offset+0)
	LR(LR_L1) = v_in(in_offset+1)
	LR(LR_R0) = v_in(in_offset+2)
	LR(LR_R1) = v_in(in_offset+3)

	if ENDIAN = LITTLE_ENDIAN then
		LR(LR_L0) = EndianChange(LR(LR_L0))
		LR(LR_L1) = EndianChange(LR(LR_L1))
		LR(LR_R0) = EndianChange(LR(LR_R0))
		LR(LR_R1) = EndianChange(LR(LR_R1))
	end if

	Call SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, ks.key_data,  0)    ' Round 1
	Call SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, ks.key_data,  2)    ' Round 2
	Call SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, ks.key_data,  4)    ' Round 3
	Call SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, ks.key_data,  6)    ' Round 4
	Call SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, ks.key_data,  8)    ' Round 5
	Call SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, ks.key_data, 10)    ' Round 6
	Call SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, ks.key_data, 12)    ' Round 7
	Call SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, ks.key_data, 14)    ' Round 8
	Call SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, ks.key_data, 16)    ' Round 9
	Call SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, ks.key_data, 18)    ' Round 10
	Call SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, ks.key_data, 20)    ' Round 11
	Call SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, ks.key_data, 22)    ' Round 12
	Call SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, ks.key_data, 24)    ' Round 13
	Call SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, ks.key_data, 26)    ' Round 14
	Call SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, ks.key_data, 28)    ' Round 15
	Call SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, ks.key_data, 30)    ' Round 16

	if ENDIAN = LITTLE_ENDIAN then
		LR(LR_L0) = EndianChange(LR(LR_L0))
		LR(LR_L1) = EndianChange(LR(LR_L1))
		LR(LR_R0) = EndianChange(LR(LR_R0))
		LR(LR_R1) = EndianChange(LR(LR_R1))
	end if

	v_out(out_offset+0) = LR(LR_R0)
	v_out(out_offset+1) = LR(LR_R1)
	v_out(out_offset+2) = LR(LR_L0)
	v_out(out_offset+3) = LR(LR_L1)

end function

'@brief SEED CTR 알고리즘 초기화 함수
'@param pInfo : CBC 내부에서 사용되는 구조체로써 유저가 변경하면 안된다.(메모리 할당되어 있어야 한다.)
'@param enc : 암호화 및 복호화 모드 지정
'@param pbszUserKey : 사용자가 지정하는 입력 키(16 BYTE)
'@param pbszCTR : 사용자가 지정하는 초기화 벡터(16 BYTE)
public function SEED_CTR_init(byref pInfo, enc, byref pbszUserKey, byref pbszCTR )
	Dim ABCD(3)
	Dim T(1)
	Dim SK

	Call arrayinit(ABCD, 0, 4)
	Call arrayinit(T, 0, 2)

	if isempty(pInfo) or isempty(pbszUserKey) or isempty(pbszCTR) then
		SEED_CTR_init = 0
		exit function
	end if

	Set SK = pInfo.seed_key
	pInfo.encrypt = enc
	Call pInfo.memcpy_byte2ctr(pbszCTR, 16)
	pInfo.last_block_flag = pInfo.buffer_length = 0

	ABCD(ABCD_A) = get_byte_to_int(pbszUserKey, 0*4)
	ABCD(ABCD_B) = get_byte_to_int(pbszUserKey, 1*4)
	ABCD(ABCD_C) = get_byte_to_int(pbszUserKey, 2*4)
	ABCD(ABCD_D) = get_byte_to_int(pbszUserKey, 3*4)

	if ENDIAN = LITTLE_ENDIAN then
		ABCD(ABCD_A) = EndianChange(ABCD(ABCD_A))
		ABCD(ABCD_B) = EndianChange(ABCD(ABCD_B))
		ABCD(ABCD_C) = EndianChange(ABCD(ABCD_C))
		ABCD(ABCD_D) = EndianChange(ABCD(ABCD_D))
	end if

	Call RoundKeyUpdate0(T, SK,  0, ABCD, KC0 )    ' K_1,0 and K_1,1
	Call RoundKeyUpdate1(T, SK,  2, ABCD, KC1 )    ' K_2,0 and K_2,1
	Call RoundKeyUpdate0(T, SK,  4, ABCD, KC2 )    ' K_3,0 and K_3,1
	Call RoundKeyUpdate1(T, SK,  6, ABCD, KC3 )    ' K_4,0 and K_4,1
	Call RoundKeyUpdate0(T, SK,  8, ABCD, KC4 )    ' K_5,0 and K_5,1
	Call RoundKeyUpdate1(T, SK, 10, ABCD, KC5 )    ' K_6,0 and K_6,1
	Call RoundKeyUpdate0(T, SK, 12, ABCD, KC6 )    ' K_7,0 and K_7,1
	Call RoundKeyUpdate1(T, SK, 14, ABCD, KC7 )    ' K_8,0 and K_8,1
	Call RoundKeyUpdate0(T, SK, 16, ABCD, KC8 )    ' K_9,0 and K_9,1
	Call RoundKeyUpdate1(T, SK, 18, ABCD, KC9 )    ' K_10,0 and K_10,1
	Call RoundKeyUpdate0(T, SK, 20, ABCD, KC10)    ' K_11,0 and K_11,1
	Call RoundKeyUpdate1(T, SK, 22, ABCD, KC11)    ' K_12,0 and K_12,1
	Call RoundKeyUpdate0(T, SK, 24, ABCD, KC12)    ' K_13,0 and K_13,1
	Call RoundKeyUpdate1(T, SK, 26, ABCD, KC13)    ' K_14,0 and K_14,1
	Call RoundKeyUpdate0(T, SK, 28, ABCD, KC14)    ' K_15,0 and K_15,1

	T(0) = MASK((ABCD(ABCD_A) + ABCD(ABCD_C) - KC15), HFFFFFFFF)
	T(1) = MASK((ABCD(ABCD_B) - ABCD(ABCD_D) + KC15), HFFFFFFFF)

	SK.key_data(30) = SS0(GetB0(T(0)) and HFF) xor SS1(GetB1(T(0)) and HFF) xor _
			SS2(GetB2(T(0)) and HFF) xor SS3(GetB3(T(0)) and HFF)
	SK.key_data(31) = SS0(GetB0(T(1)) and HFF) xor SS1(GetB1(T(1)) and HFF) xor _ 
			SS2(GetB2(T(1)) and HFF) xor SS3(GetB3(T(1)) and HFF)

	SEED_CBC_init = 1

end function


public function SEED_CTR_Process( byref pInfo, byref v_in, inLen, byref v_out, byref outLen )

	Dim pbszCounter 
	Dim pdwCounter 
	Dim nCurrentCount 
	Dim in_offset 
	Dim out_offset 
	Dim loop_first

	nCurrentCount = 0 
	in_offset = 0 
	out_offset = 0
	loop_first = 0

	if isempty(pInfo) or isempty(v_in) or isempty(v_out) or inLen < 0 then
		SEED_CTR_Process = 0
		exit function
	end If
	
	pdwCounter = pInfo.ctr
	Do While nCurrentCount < inLen 
		Call KISA_SEED_Encrypt_Block_forCTR( pdwCounter, 0, v_out, out_offset, pInfo.seed_key )			
		Call BLOCK_XOR_SEED( v_out, out_offset, v_in, in_offset, v_out, out_offset )

		Call UpdateCounter_for_SEED( pdwCounter, 0, 1, (BLOCK_SIZE_CTR-1) )

		nCurrentCount = nCurrentCount + BLOCK_SIZE_CTR
		in_offset = in_offset + BLOCK_SIZE_CTR_INT
		out_offset = out_offset + BLOCK_SIZE_CTR_INT
		loop_first = 1
	Loop
	If loop_first > 0 then
		Call pInfo.memcpy_int2ctr( pdwCounter, 0, BLOCK_SIZE_CTR )
	End If
	outLen = nCurrentCount
	pInfo.buffer_length = inLen - outLen

	SEED_CTR_Process = 1

end Function

public function SEED_CTR_Close( byref pInfo, byref v_out, out_offset, byref outLen )
	Dim nEncRmainLeng
	Dim i

	nEncRmainLeng = - pInfo.buffer_length
	i = nEncRmainLeng
	Do While i > 0
		Call set_byte_for_int(v_out, out_offset-i,0)
			i = i - 1
	Loop
	outLen = nEncRmainLeng
	SEED_CBC_Close = 1

end function

public function SEED_CTR_Encrypt( byref pbszUserKey, byref pbszCTR, byref message, message_offset, message_length )

	Dim nOutLeng
	Dim nPaddingLeng
	Dim info
	Dim outbuf
	Dim data
	Dim outlen
	Dim cdata
	Dim pbszCipherText
	Dim pbszPlainText
	Dim nPlainTextLen

	Set info = new KISA_SEED_INFO_4CTR
	outlen = 0
	nOutLeng = 0
	nPaddingLeng = 0

	Dim newpbszPlainText

	ReDim pbszPlainText(message_length-1)
	Call arraycopy_system(message, message_offset, pbszPlainText, 0, message_length)

	nPlainTextLen = UBound(pbszPlainText)+1
		
	nPlainTextPadding = DMOD((BLOCK_SIZE_CTR - (DMOD(nPlainTextLen,BLOCK_SIZE_CTR))), BLOCK_SIZE_CTR)

	ReDim newpbszPlainText(nPlainTextLen+nPlainTextPadding-1)
	Call arraycopy(newpbszPlainText, pbszPlainText, nPlainTextLen)

	ReDim pbszCipherText(nPlainTextLen-1)

	Call SEED_CTR_init( info, KISA_ENCRYPT, pbszUserKey, pbszCTR )

	outlen = ((int)((UBound(newpbszPlainText)+1)/16)) *4

	ReDim outbuf(outlen-1)
	Call arrayinit(outbuf, 0, outlen)

	data = chartoint32_for_SEED_CTR(newpbszPlainText, nPlainTextLen)

	Call SEED_CTR_Process( info, data, nPlainTextLen, outbuf, nOutLeng )
	Call SEED_CTR_Close( info, outbuf, nOutLeng,nEncRmainLeng )

	cdata = int32tochar_for_SEED_CTR(outbuf, nOutLeng- nEncRmainLeng)

	Call arraycopy(pbszCipherText, cdata, nOutLeng- nEncRmainLeng)

	SEED_CTR_Encrypt = pbszCipherText

end function

public function SEED_CTR_Decrypt( byref pbszUserKey, byref pbszCTR, byref message, message_offset, message_length )

	Dim nOutLeng
	Dim nPaddingLeng
	Dim info
	Dim outbuf
	Dim data
	Dim outlen
	Dim cdata
	Dim pbszCipherText
	Dim pbszPlainText
	Dim nPlainTextLen

	Set info = new KISA_SEED_INFO_4CTR
	outlen = 0
	nOutLeng = 0
	nPaddingLeng = 0

	Dim newpbszPlainText

	ReDim pbszPlainText(message_length-1)
	Call arraycopy_system(message, message_offset, pbszPlainText, 0, message_length)

	nPlainTextLen = UBound(pbszPlainText)+1
		
	nPlainTextPadding = DMOD((BLOCK_SIZE_CTR - (DMOD(nPlainTextLen,BLOCK_SIZE_CTR))), BLOCK_SIZE_CTR)

	ReDim newpbszPlainText(nPlainTextLen+nPlainTextPadding-1)
	Call arraycopy(newpbszPlainText, pbszPlainText, nPlainTextLen)

	ReDim pbszCipherText(nPlainTextLen-1)

	Call SEED_CTR_init( info, KISA_ENCRYPT, pbszUserKey, pbszCTR )

	outlen = ((int)((UBound(newpbszPlainText)+1)/16)) *4

	ReDim outbuf(outlen-1)
	Call arrayinit(outbuf, 0, outlen)

	data = chartoint32_for_SEED_CTR(newpbszPlainText, nPlainTextLen)

	Call SEED_CTR_Process( info, data, nPlainTextLen, outbuf, nOutLeng )
	Call SEED_CTR_Close( info, outbuf, nOutLeng,nEncRmainLeng )

	cdata = int32tochar_for_SEED_CTR(outbuf, nOutLeng- nEncRmainLeng)

	Call arraycopy(pbszCipherText, cdata, nOutLeng- nEncRmainLeng)

	SEED_CTR_Encrypt = pbszCipherText

end function

END CLASS

public FUNCTION arraycopy(byref dst, byref src, length)
	Dim i
	for i=0 to (length-1)
		dst(i) = src(i)
	next
	END Function

public FUNCTION arraycopy_system(byref src, src_offset, byref dst, dst_offset, length)
	Dim i

	for i=0 to (length-1)
		dst(dst_offset+i) = src(src_offset+i)
	next
END Function


public FUNCTION arrayinit_offset(byref dst, dst_offset, byref value, length)
	Dim i
	for i=0 to (length-1)
		dst(dst_offset+i) = value
	next
END Function


public FUNCTION arrayinit(byref dst, value, length)
	Dim i
	for i=0 to (length-1)
		dst(i) = value
	next
END FUNCTION

public FUNCTION memcpy_byte2int(byref dst, byref src, length)
	Dim iLen
	iLen = FIX(length / 4)
	for i=0 to (iLen-1)
		Call byte_to_int(dst, i, src, i*4)
	next
END FUNCTION

public FUNCTION memcpy_int2int(byref dst, byref src, src_offset, length)
	Dim iLen
	iLen = (int)(length / 4)
	for i=0 to (iLen-1)
		dst(i) = src(src_offset + i)
	next
END FUNCTION

public FUNCTION set_byte_for_int(byref dst, b_offset, value)
	i_offset = (int)(b_offset / 4)
	if ENDIAN <> LITTLE_ENDIAN then
		shift_value = (3-(b_offset mod 4)) * 8
		mask_value = CLng(UnsignedToLong(HFF * (2^shift_value)))
		mask_value2 = not mask_value
		value2 = UnsignedToLong((value and HFF) * (2^shift_value))
		dst(i_offset) = (dst(i_offset) and mask_value2) or (value2 and mask_value)
	else
		shift_value = (b_offset mod 4) * 8
		mask_value = CLng(UnsignedToLong(HFF * (2^shift_value)))
		mask_value2 = not mask_value
		value2 = UnsignedToLong((value and HFF) * (2^shift_value))
		dst(i_offset) = (dst(i_offset) and mask_value2) or (value2 and mask_value)
	end if
END FUNCTION

public FUNCTION get_byte_for_int(byref src, b_offset)
	i_offset = (int)(b_offset / 4)
	value = 0
	if ENDIAN <> LITTLE_ENDIAN then
		shift_value = (3-(b_offset mod 4)) * 8
		mask_value = CLng(UnsignedToLong(HFF * (2^shift_value)))
		value = (int)((src(i_offset) and mask_value) / (2^shift_value))
	else
		shift_value = (b_offset mod 4) * 8
		mask_value = CLng(UnsignedToLong(HFF * (2^shift_value)))
		value = (int)((src(i_offset) and mask_value) / (2^shift_value))
	end if
	get_byte_for_int = value
END FUNCTION

public FUNCTION byte_to_int(byref dst, dst_offset, byref src, src_offset)
	if ENDIAN <> LITTLE_ENDIAN then
		dst(dst_offset) = CLng(UnsignedToLong((HFF and src(src_offset)) * 2^24)) or CLng(UnsignedToLong((HFF and src(src_offset+1)) * 2^16)) or CLng(UnsignedToLong((HFF and src(src_offset+2)) * 2^8)) or CLng(UnsignedToLong((HFF and src(src_offset+3))))
	else
		dst(dst_offset) = CLng(UnsignedToLong((HFF and src(src_offset)))) or CLng(UnsignedToLong((HFF and src(src_offset+1)) * 2^8)) or CLng(UnsignedToLong((HFF and src(src_offset+2)) * 2^16)) or CLng(UnsignedToLong((HFF and src(src_offset+3)) * 2^24))
	end if
END FUNCTION

public FUNCTION get_byte_to_int(byref src, src_offset)
	value = 0
	if ENDIAN <> LITTLE_ENDIAN then
		value = SLShift(MASK(src(src_offset),HFF),24) or SLShift(MASK(src(src_offset+1),HFF),16) or SLShift(MASK(src(src_offset+2),HFF),8) or SLShift(MASK(src(src_offset+3),HFF),0)
	else
		value = UnsignedToLong( _
				LongToUnsigned(SLShift(MASK(src(src_offset),HFF),0)) + _
				LongToUnsigned(SLShift(MASK(src(src_offset+1),HFF),8)) + _
				LongToUnsigned(SLShift(MASK(src(src_offset+2),HFF),16)) + _
				LongToUnsigned(SLShift(MASK(src(src_offset+3),HFF),24)) _
			)

		value2 = LongToUnsigned(SLShift(MASK(src(src_offset),HFF),0)) + _
			LongToUnsigned(SLShift(MASK(src(src_offset+1),HFF),8)) + _
			LongToUnsigned(SLShift(MASK(src(src_offset+2),HFF),16)) + _
			LongToUnsigned(SLShift(MASK(src(src_offset+3),HFF),24))
		value3 = LongToUnsigned(value)
	end if
	get_byte_to_int = value
END FUNCTION

public FUNCTION int_to_byte(byref dst, dst_offset, byref src, src_offset)
	if ENDIAN <> LITTLE_ENDIAN then
		dst(dst_offset) = (((int)(src(src_offset) / 2^24)) and HFF)
		dst(dst_offset+1) = (((int)(src(src_offset) / 2^16)) and HFF)
		dst(dst_offset+2) = (((int)(src(src_offset) / 2^8)) and HFF)
		dst(dst_offset+3) = (((int)(src(src_offset))) and HFF)
	else
		dst(dst_offset) = (((int)(src(src_offset))) and HFF)
		dst(dst_offset+1) = (((int)(src(src_offset) / 2^8)) and HFF)
		dst(dst_offset+2) = (((int)(src(src_offset) / 2^16)) and HFF)
		dst(dst_offset+3) = (((int)(src(src_offset) / 2^24)) and HFF)
	end if
END Function

public FUNCTION int_to_byte_unit(byref dst, dst_offset, src_offset)
	if ENDIAN <> LITTLE_ENDIAN then
		dst(dst_offset) = (((int)(src_offset / 2^24)) and HFF)
		dst(dst_offset+1) = (((int)(src_offset / 2^16)) and HFF)
		dst(dst_offset+2) = (((int)(src_offset / 2^8)) and HFF)
		dst(dst_offset+3) = (((int)(src_offset)) and HFF)
	else
		dst(dst_offset) = (((int)(src_offset)) and HFF)
		dst(dst_offset+1) = (((int)(src_offset / 2^8)) and HFF)
		dst(dst_offset+2) = (((int)(src_offset / 2^16)) and HFF)
		dst(dst_offset+3) = (((int)(src_offset / 2^24)) and HFF)
	end if
END FUNCTION

public Function UnsignedToLong(Value)
	If Value < 0 Or Value >= OFFSET_4 Then
		UnsignedToLong = Value
	Else
		If Value <= MAXINT_4 Then
			UnsignedToLong = Value
		Else
			UnsignedToLong = Value - OFFSET_4
		End If
	End If
End Function

Public Function LongToUnsigned(Value)
	If Value < 0 Then
		LongToUnsigned = Value + OFFSET_4
	Else
		LongToUnsigned = Value
	End If
End Function

Public Function UnsignedToInteger(Value)
	If Value < 0 Or Value >= OFFSET_2 Then
		UnsignedToInteger = Value
	Else
		If Value <= MAXINT_2 Then
			UnsignedToInteger = Value
		Else
			UnsignedToInteger = Value - OFFSET_2
		End If
	End If
End Function

Public Function IntegerToUnsigned(Value)
	If Value < 0 Then
		IntegerToUnsigned = Value + OFFSET_2
	Else
		IntegerToUnsigned = Value
	End If
End Function

public function LShift(v, s)
	if s = 0 then
		LShift = v
		exit function
	elseif s > 31 then
		LShift = 0
		exit function
	end if

	m = 1
	for i=1 to (s-1)
	m = m * 2 + 1
	next

	m2 = not m
	m3 = LongToUnsigned(m2)
	m4 = FIX(m3 / 2^s) + 1
	m5 = DMOD(v, m4)

	LShift = m5 * 2^s
end function

public function RShift(v, s)
	RShift = FIX(v / (2^s))
end function

public function SLShift(v, s)
	SLShift = UnsignedToLong(LShift(LongToUnsigned(v), s))
end function

public function SRShift(v, s)
	SRShift = UnsignedToLong(RShift(LongToUnsigned(v), s))
end function

public function DMOD(v, d)
	Dim result
	result = v - (FIX(v / d) * d)
	DMOD = result
end function

public function MASK(v, m)
	MASK = UnsignedToLong(DMOD(LongToUnsigned(v), LongToUnsigned(m)+1))
end Function

Set KISA_SEED_CTR = NEW KISA_SEED_CTR_C
%>
