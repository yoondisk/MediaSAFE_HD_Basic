/**
@file KISA_SEED_CBC.java
@brief SEED CBC 암호 알고리즘
@author Copyright (c) 2013 by KISA
@remarks http://seed.kisa.or.kr/
*/

public class KISA_SEED_CBC {

	// DEFAULT : JAVA = BIG_ENDIAN
	private static int ENDIAN = Common.BIG_ENDIAN;

	// S-BOX
	private static final int SS0[] =
	{
		0x2989a1a8, 0x05858184, 0x16c6d2d4, 0x13c3d3d0, 0x14445054, 0x1d0d111c, 0x2c8ca0ac, 0x25052124,
		0x1d4d515c, 0x03434340, 0x18081018, 0x1e0e121c, 0x11415150, 0x3cccf0fc, 0x0acac2c8, 0x23436360,
		0x28082028, 0x04444044, 0x20002020, 0x1d8d919c, 0x20c0e0e0, 0x22c2e2e0, 0x08c8c0c8, 0x17071314,
		0x2585a1a4, 0x0f8f838c, 0x03030300, 0x3b4b7378, 0x3b8bb3b8, 0x13031310, 0x12c2d2d0, 0x2ecee2ec,
		0x30407070, 0x0c8c808c, 0x3f0f333c, 0x2888a0a8, 0x32023230, 0x1dcdd1dc, 0x36c6f2f4, 0x34447074,
		0x2ccce0ec, 0x15859194, 0x0b0b0308, 0x17475354, 0x1c4c505c, 0x1b4b5358, 0x3d8db1bc, 0x01010100,
		0x24042024, 0x1c0c101c, 0x33437370, 0x18889098, 0x10001010, 0x0cccc0cc, 0x32c2f2f0, 0x19c9d1d8,
		0x2c0c202c, 0x27c7e3e4, 0x32427270, 0x03838380, 0x1b8b9398, 0x11c1d1d0, 0x06868284, 0x09c9c1c8,
		0x20406060, 0x10405050, 0x2383a3a0, 0x2bcbe3e8, 0x0d0d010c, 0x3686b2b4, 0x1e8e929c, 0x0f4f434c,
		0x3787b3b4, 0x1a4a5258, 0x06c6c2c4, 0x38487078, 0x2686a2a4, 0x12021210, 0x2f8fa3ac, 0x15c5d1d4,
		0x21416160, 0x03c3c3c0, 0x3484b0b4, 0x01414140, 0x12425250, 0x3d4d717c, 0x0d8d818c, 0x08080008,
		0x1f0f131c, 0x19899198, 0x00000000, 0x19091118, 0x04040004, 0x13435350, 0x37c7f3f4, 0x21c1e1e0,
		0x3dcdf1fc, 0x36467274, 0x2f0f232c, 0x27072324, 0x3080b0b0, 0x0b8b8388, 0x0e0e020c, 0x2b8ba3a8,
		0x2282a2a0, 0x2e4e626c, 0x13839390, 0x0d4d414c, 0x29496168, 0x3c4c707c, 0x09090108, 0x0a0a0208,
		0x3f8fb3bc, 0x2fcfe3ec, 0x33c3f3f0, 0x05c5c1c4, 0x07878384, 0x14041014, 0x3ecef2fc, 0x24446064,
		0x1eced2dc, 0x2e0e222c, 0x0b4b4348, 0x1a0a1218, 0x06060204, 0x21012120, 0x2b4b6368, 0x26466264,
		0x02020200, 0x35c5f1f4, 0x12829290, 0x0a8a8288, 0x0c0c000c, 0x3383b3b0, 0x3e4e727c, 0x10c0d0d0,
		0x3a4a7278, 0x07474344, 0x16869294, 0x25c5e1e4, 0x26062224, 0x00808080, 0x2d8da1ac, 0x1fcfd3dc,
		0x2181a1a0, 0x30003030, 0x37073334, 0x2e8ea2ac, 0x36063234, 0x15051114, 0x22022220, 0x38083038,
		0x34c4f0f4, 0x2787a3a4, 0x05454144, 0x0c4c404c, 0x01818180, 0x29c9e1e8, 0x04848084, 0x17879394,
		0x35053134, 0x0bcbc3c8, 0x0ecec2cc, 0x3c0c303c, 0x31417170, 0x11011110, 0x07c7c3c4, 0x09898188,
		0x35457174, 0x3bcbf3f8, 0x1acad2d8, 0x38c8f0f8, 0x14849094, 0x19495158, 0x02828280, 0x04c4c0c4,
		0x3fcff3fc, 0x09494148, 0x39093138, 0x27476364, 0x00c0c0c0, 0x0fcfc3cc, 0x17c7d3d4, 0x3888b0b8,
		0x0f0f030c, 0x0e8e828c, 0x02424240, 0x23032320, 0x11819190, 0x2c4c606c, 0x1bcbd3d8, 0x2484a0a4,
		0x34043034, 0x31c1f1f0, 0x08484048, 0x02c2c2c0, 0x2f4f636c, 0x3d0d313c, 0x2d0d212c, 0x00404040,
		0x3e8eb2bc, 0x3e0e323c, 0x3c8cb0bc, 0x01c1c1c0, 0x2a8aa2a8, 0x3a8ab2b8, 0x0e4e424c, 0x15455154,
		0x3b0b3338, 0x1cccd0dc, 0x28486068, 0x3f4f737c, 0x1c8c909c, 0x18c8d0d8, 0x0a4a4248, 0x16465254,
		0x37477374, 0x2080a0a0, 0x2dcde1ec, 0x06464244, 0x3585b1b4, 0x2b0b2328, 0x25456164, 0x3acaf2f8,
		0x23c3e3e0, 0x3989b1b8, 0x3181b1b0, 0x1f8f939c, 0x1e4e525c, 0x39c9f1f8, 0x26c6e2e4, 0x3282b2b0,
		0x31013130, 0x2acae2e8, 0x2d4d616c, 0x1f4f535c, 0x24c4e0e4, 0x30c0f0f0, 0x0dcdc1cc, 0x08888088,
		0x16061214, 0x3a0a3238, 0x18485058, 0x14c4d0d4, 0x22426260, 0x29092128, 0x07070304, 0x33033330,
		0x28c8e0e8, 0x1b0b1318, 0x05050104, 0x39497178, 0x10809090, 0x2a4a6268, 0x2a0a2228, 0x1a8a9298
	};

	private static final int SS1[] =
	{
		0x38380830, 0xe828c8e0, 0x2c2d0d21, 0xa42686a2, 0xcc0fcfc3, 0xdc1eced2, 0xb03383b3, 0xb83888b0,
		0xac2f8fa3, 0x60204060, 0x54154551, 0xc407c7c3, 0x44044440, 0x6c2f4f63, 0x682b4b63, 0x581b4b53,
		0xc003c3c3, 0x60224262, 0x30330333, 0xb43585b1, 0x28290921, 0xa02080a0, 0xe022c2e2, 0xa42787a3,
		0xd013c3d3, 0x90118191, 0x10110111, 0x04060602, 0x1c1c0c10, 0xbc3c8cb0, 0x34360632, 0x480b4b43,
		0xec2fcfe3, 0x88088880, 0x6c2c4c60, 0xa82888a0, 0x14170713, 0xc404c4c0, 0x14160612, 0xf434c4f0,
		0xc002c2c2, 0x44054541, 0xe021c1e1, 0xd416c6d2, 0x3c3f0f33, 0x3c3d0d31, 0x8c0e8e82, 0x98188890,
		0x28280820, 0x4c0e4e42, 0xf436c6f2, 0x3c3e0e32, 0xa42585a1, 0xf839c9f1, 0x0c0d0d01, 0xdc1fcfd3,
		0xd818c8d0, 0x282b0b23, 0x64264662, 0x783a4a72, 0x24270723, 0x2c2f0f23, 0xf031c1f1, 0x70324272,
		0x40024242, 0xd414c4d0, 0x40014141, 0xc000c0c0, 0x70334373, 0x64274763, 0xac2c8ca0, 0x880b8b83,
		0xf437c7f3, 0xac2d8da1, 0x80008080, 0x1c1f0f13, 0xc80acac2, 0x2c2c0c20, 0xa82a8aa2, 0x34340430,
		0xd012c2d2, 0x080b0b03, 0xec2ecee2, 0xe829c9e1, 0x5c1d4d51, 0x94148490, 0x18180810, 0xf838c8f0,
		0x54174753, 0xac2e8ea2, 0x08080800, 0xc405c5c1, 0x10130313, 0xcc0dcdc1, 0x84068682, 0xb83989b1,
		0xfc3fcff3, 0x7c3d4d71, 0xc001c1c1, 0x30310131, 0xf435c5f1, 0x880a8a82, 0x682a4a62, 0xb03181b1,
		0xd011c1d1, 0x20200020, 0xd417c7d3, 0x00020202, 0x20220222, 0x04040400, 0x68284860, 0x70314171,
		0x04070703, 0xd81bcbd3, 0x9c1d8d91, 0x98198991, 0x60214161, 0xbc3e8eb2, 0xe426c6e2, 0x58194951,
		0xdc1dcdd1, 0x50114151, 0x90108090, 0xdc1cccd0, 0x981a8a92, 0xa02383a3, 0xa82b8ba3, 0xd010c0d0,
		0x80018181, 0x0c0f0f03, 0x44074743, 0x181a0a12, 0xe023c3e3, 0xec2ccce0, 0x8c0d8d81, 0xbc3f8fb3,
		0x94168692, 0x783b4b73, 0x5c1c4c50, 0xa02282a2, 0xa02181a1, 0x60234363, 0x20230323, 0x4c0d4d41,
		0xc808c8c0, 0x9c1e8e92, 0x9c1c8c90, 0x383a0a32, 0x0c0c0c00, 0x2c2e0e22, 0xb83a8ab2, 0x6c2e4e62,
		0x9c1f8f93, 0x581a4a52, 0xf032c2f2, 0x90128292, 0xf033c3f3, 0x48094941, 0x78384870, 0xcc0cccc0,
		0x14150511, 0xf83bcbf3, 0x70304070, 0x74354571, 0x7c3f4f73, 0x34350531, 0x10100010, 0x00030303,
		0x64244460, 0x6c2d4d61, 0xc406c6c2, 0x74344470, 0xd415c5d1, 0xb43484b0, 0xe82acae2, 0x08090901,
		0x74364672, 0x18190911, 0xfc3ecef2, 0x40004040, 0x10120212, 0xe020c0e0, 0xbc3d8db1, 0x04050501,
		0xf83acaf2, 0x00010101, 0xf030c0f0, 0x282a0a22, 0x5c1e4e52, 0xa82989a1, 0x54164652, 0x40034343,
		0x84058581, 0x14140410, 0x88098981, 0x981b8b93, 0xb03080b0, 0xe425c5e1, 0x48084840, 0x78394971,
		0x94178793, 0xfc3cccf0, 0x1c1e0e12, 0x80028282, 0x20210121, 0x8c0c8c80, 0x181b0b13, 0x5c1f4f53,
		0x74374773, 0x54144450, 0xb03282b2, 0x1c1d0d11, 0x24250521, 0x4c0f4f43, 0x00000000, 0x44064642,
		0xec2dcde1, 0x58184850, 0x50124252, 0xe82bcbe3, 0x7c3e4e72, 0xd81acad2, 0xc809c9c1, 0xfc3dcdf1,
		0x30300030, 0x94158591, 0x64254561, 0x3c3c0c30, 0xb43686b2, 0xe424c4e0, 0xb83b8bb3, 0x7c3c4c70,
		0x0c0e0e02, 0x50104050, 0x38390931, 0x24260622, 0x30320232, 0x84048480, 0x68294961, 0x90138393,
		0x34370733, 0xe427c7e3, 0x24240420, 0xa42484a0, 0xc80bcbc3, 0x50134353, 0x080a0a02, 0x84078783,
		0xd819c9d1, 0x4c0c4c40, 0x80038383, 0x8c0f8f83, 0xcc0ecec2, 0x383b0b33, 0x480a4a42, 0xb43787b3
	};

	private static final int SS2[] =
	{
		0xa1a82989, 0x81840585, 0xd2d416c6, 0xd3d013c3, 0x50541444, 0x111c1d0d, 0xa0ac2c8c, 0x21242505,
		0x515c1d4d, 0x43400343, 0x10181808, 0x121c1e0e, 0x51501141, 0xf0fc3ccc, 0xc2c80aca, 0x63602343,
		0x20282808, 0x40440444, 0x20202000, 0x919c1d8d, 0xe0e020c0, 0xe2e022c2, 0xc0c808c8, 0x13141707,
		0xa1a42585, 0x838c0f8f, 0x03000303, 0x73783b4b, 0xb3b83b8b, 0x13101303, 0xd2d012c2, 0xe2ec2ece,
		0x70703040, 0x808c0c8c, 0x333c3f0f, 0xa0a82888, 0x32303202, 0xd1dc1dcd, 0xf2f436c6, 0x70743444,
		0xe0ec2ccc, 0x91941585, 0x03080b0b, 0x53541747, 0x505c1c4c, 0x53581b4b, 0xb1bc3d8d, 0x01000101,
		0x20242404, 0x101c1c0c, 0x73703343, 0x90981888, 0x10101000, 0xc0cc0ccc, 0xf2f032c2, 0xd1d819c9,
		0x202c2c0c, 0xe3e427c7, 0x72703242, 0x83800383, 0x93981b8b, 0xd1d011c1, 0x82840686, 0xc1c809c9,
		0x60602040, 0x50501040, 0xa3a02383, 0xe3e82bcb, 0x010c0d0d, 0xb2b43686, 0x929c1e8e, 0x434c0f4f,
		0xb3b43787, 0x52581a4a, 0xc2c406c6, 0x70783848, 0xa2a42686, 0x12101202, 0xa3ac2f8f, 0xd1d415c5,
		0x61602141, 0xc3c003c3, 0xb0b43484, 0x41400141, 0x52501242, 0x717c3d4d, 0x818c0d8d, 0x00080808,
		0x131c1f0f, 0x91981989, 0x00000000, 0x11181909, 0x00040404, 0x53501343, 0xf3f437c7, 0xe1e021c1,
		0xf1fc3dcd, 0x72743646, 0x232c2f0f, 0x23242707, 0xb0b03080, 0x83880b8b, 0x020c0e0e, 0xa3a82b8b,
		0xa2a02282, 0x626c2e4e, 0x93901383, 0x414c0d4d, 0x61682949, 0x707c3c4c, 0x01080909, 0x02080a0a,
		0xb3bc3f8f, 0xe3ec2fcf, 0xf3f033c3, 0xc1c405c5, 0x83840787, 0x10141404, 0xf2fc3ece, 0x60642444,
		0xd2dc1ece, 0x222c2e0e, 0x43480b4b, 0x12181a0a, 0x02040606, 0x21202101, 0x63682b4b, 0x62642646,
		0x02000202, 0xf1f435c5, 0x92901282, 0x82880a8a, 0x000c0c0c, 0xb3b03383, 0x727c3e4e, 0xd0d010c0,
		0x72783a4a, 0x43440747, 0x92941686, 0xe1e425c5, 0x22242606, 0x80800080, 0xa1ac2d8d, 0xd3dc1fcf,
		0xa1a02181, 0x30303000, 0x33343707, 0xa2ac2e8e, 0x32343606, 0x11141505, 0x22202202, 0x30383808,
		0xf0f434c4, 0xa3a42787, 0x41440545, 0x404c0c4c, 0x81800181, 0xe1e829c9, 0x80840484, 0x93941787,
		0x31343505, 0xc3c80bcb, 0xc2cc0ece, 0x303c3c0c, 0x71703141, 0x11101101, 0xc3c407c7, 0x81880989,
		0x71743545, 0xf3f83bcb, 0xd2d81aca, 0xf0f838c8, 0x90941484, 0x51581949, 0x82800282, 0xc0c404c4,
		0xf3fc3fcf, 0x41480949, 0x31383909, 0x63642747, 0xc0c000c0, 0xc3cc0fcf, 0xd3d417c7, 0xb0b83888,
		0x030c0f0f, 0x828c0e8e, 0x42400242, 0x23202303, 0x91901181, 0x606c2c4c, 0xd3d81bcb, 0xa0a42484,
		0x30343404, 0xf1f031c1, 0x40480848, 0xc2c002c2, 0x636c2f4f, 0x313c3d0d, 0x212c2d0d, 0x40400040,
		0xb2bc3e8e, 0x323c3e0e, 0xb0bc3c8c, 0xc1c001c1, 0xa2a82a8a, 0xb2b83a8a, 0x424c0e4e, 0x51541545,
		0x33383b0b, 0xd0dc1ccc, 0x60682848, 0x737c3f4f, 0x909c1c8c, 0xd0d818c8, 0x42480a4a, 0x52541646,
		0x73743747, 0xa0a02080, 0xe1ec2dcd, 0x42440646, 0xb1b43585, 0x23282b0b, 0x61642545, 0xf2f83aca,
		0xe3e023c3, 0xb1b83989, 0xb1b03181, 0x939c1f8f, 0x525c1e4e, 0xf1f839c9, 0xe2e426c6, 0xb2b03282,
		0x31303101, 0xe2e82aca, 0x616c2d4d, 0x535c1f4f, 0xe0e424c4, 0xf0f030c0, 0xc1cc0dcd, 0x80880888,
		0x12141606, 0x32383a0a, 0x50581848, 0xd0d414c4, 0x62602242, 0x21282909, 0x03040707, 0x33303303,
		0xe0e828c8, 0x13181b0b, 0x01040505, 0x71783949, 0x90901080, 0x62682a4a, 0x22282a0a, 0x92981a8a
	};

	private static final int SS3[] =
	{
		0x08303838, 0xc8e0e828, 0x0d212c2d, 0x86a2a426, 0xcfc3cc0f, 0xced2dc1e, 0x83b3b033, 0x88b0b838,
		0x8fa3ac2f, 0x40606020, 0x45515415, 0xc7c3c407, 0x44404404, 0x4f636c2f, 0x4b63682b, 0x4b53581b,
		0xc3c3c003, 0x42626022, 0x03333033, 0x85b1b435, 0x09212829, 0x80a0a020, 0xc2e2e022, 0x87a3a427,
		0xc3d3d013, 0x81919011, 0x01111011, 0x06020406, 0x0c101c1c, 0x8cb0bc3c, 0x06323436, 0x4b43480b,
		0xcfe3ec2f, 0x88808808, 0x4c606c2c, 0x88a0a828, 0x07131417, 0xc4c0c404, 0x06121416, 0xc4f0f434,
		0xc2c2c002, 0x45414405, 0xc1e1e021, 0xc6d2d416, 0x0f333c3f, 0x0d313c3d, 0x8e828c0e, 0x88909818,
		0x08202828, 0x4e424c0e, 0xc6f2f436, 0x0e323c3e, 0x85a1a425, 0xc9f1f839, 0x0d010c0d, 0xcfd3dc1f,
		0xc8d0d818, 0x0b23282b, 0x46626426, 0x4a72783a, 0x07232427, 0x0f232c2f, 0xc1f1f031, 0x42727032,
		0x42424002, 0xc4d0d414, 0x41414001, 0xc0c0c000, 0x43737033, 0x47636427, 0x8ca0ac2c, 0x8b83880b,
		0xc7f3f437, 0x8da1ac2d, 0x80808000, 0x0f131c1f, 0xcac2c80a, 0x0c202c2c, 0x8aa2a82a, 0x04303434,
		0xc2d2d012, 0x0b03080b, 0xcee2ec2e, 0xc9e1e829, 0x4d515c1d, 0x84909414, 0x08101818, 0xc8f0f838,
		0x47535417, 0x8ea2ac2e, 0x08000808, 0xc5c1c405, 0x03131013, 0xcdc1cc0d, 0x86828406, 0x89b1b839,
		0xcff3fc3f, 0x4d717c3d, 0xc1c1c001, 0x01313031, 0xc5f1f435, 0x8a82880a, 0x4a62682a, 0x81b1b031,
		0xc1d1d011, 0x00202020, 0xc7d3d417, 0x02020002, 0x02222022, 0x04000404, 0x48606828, 0x41717031,
		0x07030407, 0xcbd3d81b, 0x8d919c1d, 0x89919819, 0x41616021, 0x8eb2bc3e, 0xc6e2e426, 0x49515819,
		0xcdd1dc1d, 0x41515011, 0x80909010, 0xccd0dc1c, 0x8a92981a, 0x83a3a023, 0x8ba3a82b, 0xc0d0d010,
		0x81818001, 0x0f030c0f, 0x47434407, 0x0a12181a, 0xc3e3e023, 0xcce0ec2c, 0x8d818c0d, 0x8fb3bc3f,
		0x86929416, 0x4b73783b, 0x4c505c1c, 0x82a2a022, 0x81a1a021, 0x43636023, 0x03232023, 0x4d414c0d,
		0xc8c0c808, 0x8e929c1e, 0x8c909c1c, 0x0a32383a, 0x0c000c0c, 0x0e222c2e, 0x8ab2b83a, 0x4e626c2e,
		0x8f939c1f, 0x4a52581a, 0xc2f2f032, 0x82929012, 0xc3f3f033, 0x49414809, 0x48707838, 0xccc0cc0c,
		0x05111415, 0xcbf3f83b, 0x40707030, 0x45717435, 0x4f737c3f, 0x05313435, 0x00101010, 0x03030003,
		0x44606424, 0x4d616c2d, 0xc6c2c406, 0x44707434, 0xc5d1d415, 0x84b0b434, 0xcae2e82a, 0x09010809,
		0x46727436, 0x09111819, 0xcef2fc3e, 0x40404000, 0x02121012, 0xc0e0e020, 0x8db1bc3d, 0x05010405,
		0xcaf2f83a, 0x01010001, 0xc0f0f030, 0x0a22282a, 0x4e525c1e, 0x89a1a829, 0x46525416, 0x43434003,
		0x85818405, 0x04101414, 0x89818809, 0x8b93981b, 0x80b0b030, 0xc5e1e425, 0x48404808, 0x49717839,
		0x87939417, 0xccf0fc3c, 0x0e121c1e, 0x82828002, 0x01212021, 0x8c808c0c, 0x0b13181b, 0x4f535c1f,
		0x47737437, 0x44505414, 0x82b2b032, 0x0d111c1d, 0x05212425, 0x4f434c0f, 0x00000000, 0x46424406,
		0xcde1ec2d, 0x48505818, 0x42525012, 0xcbe3e82b, 0x4e727c3e, 0xcad2d81a, 0xc9c1c809, 0xcdf1fc3d,
		0x00303030, 0x85919415, 0x45616425, 0x0c303c3c, 0x86b2b436, 0xc4e0e424, 0x8bb3b83b, 0x4c707c3c,
		0x0e020c0e, 0x40505010, 0x09313839, 0x06222426, 0x02323032, 0x84808404, 0x49616829, 0x83939013,
		0x07333437, 0xc7e3e427, 0x04202424, 0x84a0a424, 0xcbc3c80b, 0x43535013, 0x0a02080a, 0x87838407,
		0xc9d1d819, 0x4c404c0c, 0x83838003, 0x8f838c0f, 0xcec2cc0e, 0x0b33383b, 0x4a42480a, 0x87b3b437
	};

	private static final int BLOCK_SIZE_SEED = 16;
	private static final int BLOCK_SIZE_SEED_INT = 4;

	private static final byte GetB0(int A) { return (byte)(A & 0x0ff); }
	private static final byte GetB1(int A) { return (byte)((A>>8) & 0x0ff); }
	private static final byte GetB2(int A) { return (byte)((A>>16) & 0x0ff); }
	private static final byte GetB3(int A) { return (byte)((A>>24) & 0x0ff); }

	// Round function F and adding output of F to L.
	// L0, L1 : left input values at each round
	// R0, R1 : right input values at each round
	// K : round keys at each round
	private static final void SeedRound(int[] T, int LR[], int L0, int L1, int R0, int R1, int[] K, int K_offset) {
		T[0] = LR[R0] ^ K[K_offset+0];
		T[1] = LR[R1] ^ K[K_offset+1];
		T[1] ^= T[0];
		T[1] = SS0[GetB0(T[1])&0x0ff] ^ SS1[GetB1(T[1])&0x0ff] ^
				SS2[GetB2(T[1])&0x0ff] ^ SS3[GetB3(T[1])&0x0ff];
		T[0] += T[1];
		T[0] = SS0[GetB0(T[0])&0x0ff] ^ SS1[GetB1(T[0])&0x0ff] ^
				SS2[GetB2(T[0])&0x0ff] ^ SS3[GetB3(T[0])&0x0ff];
		T[1] += T[0];
		T[1] = SS0[GetB0(T[1])&0x0ff] ^ SS1[GetB1(T[1])&0x0ff] ^
				SS2[GetB2(T[1])&0x0ff] ^ SS3[GetB3(T[1])&0x0ff];
		T[0] += T[1];
		LR[L0] ^= T[0]; LR[L1] ^= T[1];
	}



	private static final int EndianChange(int dwS) { return ( (/*ROTL(dwS,8)*/(((dwS) << (8)) | (((dwS) >> (32-(8)))&0x000000ff)) & 0x00ff00ff) | (/*ROTL(dwS,24)*/(((dwS) << (24)) | (((dwS) >> (32-(24)))&0x00ffffff)) & 0xff00ff00) ); }

	/************************ Constants for Key schedule **************************/
	private static final int KC0 = 0x9e3779b9;
	private static final int KC1 = 0x3c6ef373;
	private static final int KC2 = 0x78dde6e6;
	private static final int KC3 = 0xf1bbcdcc;
	private static final int KC4 = 0xe3779b99;
	private static final int KC5 = 0xc6ef3733;
	private static final int KC6 = 0x8dde6e67;
	private static final int KC7 = 0x1bbcdccf;
	private static final int KC8 = 0x3779b99e;
	private static final int KC9 = 0x6ef3733c;
	private static final int KC10 = 0xdde6e678;
	private static final int KC11 = 0xbbcdccf1;
	private static final int KC12 = 0x779b99e3;
	private static final int KC13 = 0xef3733c6;
	private static final int KC14 = 0xde6e678d;
	private static final int KC15 = 0xbcdccf1b;

	
	
	
	private static final int ABCD_A = 0;
	private static final int ABCD_B = 1;
	private static final int ABCD_C = 2;
	private static final int ABCD_D = 3;
	
	private static final void RoundKeyUpdate0(int T[], int[] K, int K_offset, int ABCD[], int KC) {
		T[0] = ABCD[ABCD_A] + ABCD[ABCD_C] - KC;
		T[1] = ABCD[ABCD_B] + KC - ABCD[ABCD_D];
		K[K_offset+0] = SS0[GetB0(T[0])&0x0ff] ^ SS1[GetB1(T[0])&0x0ff] ^ SS2[GetB2(T[0])&0x0ff] ^ SS3[GetB3(T[0])&0x0ff];
		K[K_offset+1] = SS0[GetB0(T[1])&0x0ff] ^ SS1[GetB1(T[1])&0x0ff] ^ SS2[GetB2(T[1])&0x0ff] ^ SS3[GetB3(T[1])&0x0ff];
		T[0] = ABCD[ABCD_A]; 
		ABCD[ABCD_A] = ((ABCD[ABCD_A]>>8)&0x00ffffff) ^ (ABCD[ABCD_B]<<24);
		ABCD[ABCD_B] = ((ABCD[ABCD_B]>>8)&0x00ffffff) ^ (T[0]<<24);
	}

	private static final void RoundKeyUpdate1(int T[], int []K, int K_offset, int ABCD[], int KC) {
		T[0] = ABCD[ABCD_A] + ABCD[ABCD_C] - KC;
		T[1] = ABCD[ABCD_B] + KC - ABCD[ABCD_D];
		K[K_offset+0] = SS0[GetB0(T[0])&0x0ff] ^ SS1[GetB1(T[0])&0x0ff] ^ SS2[GetB2(T[0])&0x0ff] ^ SS3[GetB3(T[0])&0x0ff];
		K[K_offset+1] = SS0[GetB0(T[1])&0x0ff] ^ SS1[GetB1(T[1])&0x0ff] ^ SS2[GetB2(T[1])&0x0ff] ^ SS3[GetB3(T[1])&0x0ff];
		T[0] = ABCD[ABCD_C];
		ABCD[ABCD_C] = (ABCD[ABCD_C]<<8) ^ ((ABCD[ABCD_D]>>24)&0x000000ff);
		ABCD[ABCD_D] = (ABCD[ABCD_D]<<8) ^ ((T[0]>>24)&0x000000ff);
	}

	private static void BLOCK_XOR_CBC(int[] OUT_VALUE, int out_value_offset, int[] IN_VALUE1, int in_value1_offset, int[] IN_VALUE2, int in_value2_offset) {
		OUT_VALUE[out_value_offset+0] = (in_value1_offset<IN_VALUE1.length?IN_VALUE1[in_value1_offset+0]:0) ^ (in_value2_offset<IN_VALUE2.length?IN_VALUE2[in_value2_offset+0]:0);
		OUT_VALUE[out_value_offset+1] = (in_value1_offset+1<IN_VALUE1.length?IN_VALUE1[in_value1_offset+1]:0) ^ (in_value2_offset+1<IN_VALUE2.length?IN_VALUE2[in_value2_offset+1]:0);
		OUT_VALUE[out_value_offset+2] = (in_value1_offset+2<IN_VALUE1.length?IN_VALUE1[in_value1_offset+2]:0) ^ (in_value2_offset+2<IN_VALUE2.length?IN_VALUE2[in_value2_offset+2]:0);
		OUT_VALUE[out_value_offset+3] = (in_value1_offset+3<IN_VALUE1.length?IN_VALUE1[in_value1_offset+3]:0) ^ (in_value2_offset+3<IN_VALUE2.length?IN_VALUE2[in_value2_offset+3]:0);
	}

	private static final int LR_L0 = 0;
	private static final int LR_L1 = 1;
	private static final int LR_R0 = 2;
	private static final int LR_R1 = 3;
	private static void KISA_SEED_Encrypt_Block_forCBC( int[] in, int in_offset, int[] out, int out_offset, KISA_SEED_KEY ks ) {
		int LR[] = new int[4];		// Iuput/output values at each rounds
		int T[] = new int[2];		// Temporary variables for round function F
		int K[] = ks.key_data;		// Pointer of round keys

		// Set up input values for first round
		LR[LR_L0] = in[in_offset+0];
		LR[LR_L1] = in[in_offset+1];
		LR[LR_R0] = in[in_offset+2];
		LR[LR_R1] = in[in_offset+3];

		// Reorder for big endian
		// Because SEED use little endian order in default
		if(Common.BIG_ENDIAN != ENDIAN) {
			LR[LR_L0] = EndianChange(LR[LR_L0]);
			LR[LR_L1] = EndianChange(LR[LR_L1]);
			LR[LR_R0] = EndianChange(LR[LR_R0]);
			LR[LR_R1] = EndianChange(LR[LR_R1]);
		}

		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K,  0);    // Round 1
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K,  2);    // Round 2
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K,  4);    // Round 3
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K,  6);    // Round 4
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K,  8);    // Round 5
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 10);    // Round 6
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 12);    // Round 7
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 14);    // Round 8
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 16);    // Round 9
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 18);    // Round 10
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 20);    // Round 11
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 22);    // Round 12
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 24);    // Round 13
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 26);    // Round 14
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 28);    // Round 15
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 30);    // Round 16

		if(Common.BIG_ENDIAN != ENDIAN) {
			LR[LR_L0] = EndianChange(LR[LR_L0]);
			LR[LR_L1] = EndianChange(LR[LR_L1]);
			LR[LR_R0] = EndianChange(LR[LR_R0]);
			LR[LR_R1] = EndianChange(LR[LR_R1]);
		}

		// Copying output values from last round to pbData
		out[out_offset+0] = LR[LR_R0];
		out[out_offset+1] = LR[LR_R1];
		out[out_offset+2] = LR[LR_L0];
		out[out_offset+3] = LR[LR_L1];

	}

	private static void KISA_SEED_Decrypt_Block_forCBC( int[] in, int in_offset, int[] out, int out_offset, KISA_SEED_KEY ks ) {
		int LR[] = new int[4];				// Iuput/output values at each rounds
		int T[] = new int[2];				// Temporary variables for round function F
		int K[] = ks.key_data;				// Pointer of round keys

		// Set up input values for first round
		LR[LR_L0] = in[in_offset+0];
		LR[LR_L1] = in[in_offset+1];
		LR[LR_R0] = in[in_offset+2];
		LR[LR_R1] = in[in_offset+3];

		// Reorder for big endian
		if(Common.BIG_ENDIAN != ENDIAN) {
			LR[LR_L0] = EndianChange(LR[LR_L0]);
			LR[LR_L1] = EndianChange(LR[LR_L1]);
			LR[LR_R0] = EndianChange(LR[LR_R0]);
			LR[LR_R1] = EndianChange(LR[LR_R1]);
		}

		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 30);    // Round 1
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 28);    // Round 2
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 26);    // Round 3
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 24);    // Round 4
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 22);    // Round 5
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 20);    // Round 6
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 18);    // Round 7
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 16);    // Round 8
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 14);    // Round 9
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K, 12);    // Round 10
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K, 10);    // Round 11
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K,  8);    // Round 12
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K,  6);    // Round 13
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K,  4);    // Round 14
		SeedRound(T, LR, LR_L0, LR_L1, LR_R0, LR_R1, K,  2);    // Round 15
		SeedRound(T, LR, LR_R0, LR_R1, LR_L0, LR_L1, K,  0);    // Round 16

		if(Common.BIG_ENDIAN != ENDIAN) {
			LR[LR_L0] = EndianChange(LR[LR_L0]);
			LR[LR_L1] = EndianChange(LR[LR_L1]);
			LR[LR_R0] = EndianChange(LR[LR_R0]);
			LR[LR_R1] = EndianChange(LR[LR_R1]);
		}

		// Copy output values from last round to pbData
		out[out_offset+0] = LR[LR_R0];
		out[out_offset+1] = LR[LR_R1];
		out[out_offset+2] = LR[LR_L0];
		out[out_offset+3] = LR[LR_L1];

	}


	public static int[] chartoint32_for_SEED_CBC(byte[] in, int inLen) {
		int[] data;
		int len, i;

		if(inLen % 4 > 0)
			len = (inLen/4)+1;
		else
			len = (inLen/4);

		data = new int[len];

		for(i=0;i<len;i++)
		{
			Common.byte_to_int(data, i, in, i*4, ENDIAN);
		}

		return data;
	}
	

	public static byte[] int32tochar_for_SEED_CBC(int in[], int inLen) {
		byte[] data;
		int i;

		data = new byte[inLen];
		if(ENDIAN != Common.BIG_ENDIAN) {
			for(i=0;i<inLen;i++)
			{
				data[i] = (byte)(in[i/4] >> ((i%4)*8));
			}
		} else {
			for(i=0;i<inLen;i++)
			{
				data[i] = (byte)(in[i/4] >> ((3-(i%4))*8));
			}			
		}

		return data;
	}


	public static int SEED_CBC_init( KISA_SEED_INFO pInfo, KISA_ENC_DEC enc, byte[] pbszUserKey, byte[] pbszIV ) {
		int ABCD[] = new int[4];			// Iuput/output values at each rounds(각 라운드 입/출력)
		int T[] = new int[2];				// Temporary variable
		int K[];

		if( null == pInfo ||
				null == pbszUserKey ||
				null == pbszIV )
			return 0;

		K = pInfo.seed_key.key_data;										// Pointer of round keys
		pInfo.encrypt = enc.value;											// 
		Common.memcpy(pInfo.ivec, pbszIV, 16, ENDIAN);
		pInfo.last_block_flag = pInfo.buffer_length = 0;

		// Set up input values for Key Schedule
		ABCD[ABCD_A] = Common.byte_to_int(pbszUserKey, 0*4, ENDIAN);
		ABCD[ABCD_B] = Common.byte_to_int(pbszUserKey, 1*4, ENDIAN);
		ABCD[ABCD_C] = Common.byte_to_int(pbszUserKey, 2*4, ENDIAN);
		ABCD[ABCD_D] = Common.byte_to_int(pbszUserKey, 3*4, ENDIAN);
		
		// Reorder for big endian
		if(Common.BIG_ENDIAN != ENDIAN) {
			ABCD[ABCD_A] = EndianChange(ABCD[ABCD_A]);
			ABCD[ABCD_B] = EndianChange(ABCD[ABCD_B]);
			ABCD[ABCD_C] = EndianChange(ABCD[ABCD_C]);
			ABCD[ABCD_D] = EndianChange(ABCD[ABCD_D]);
		}

		// i-th round keys( K_i,0 and K_i,1 ) are denoted as K[2*(i-1)] and K[2*i-1], respectively
		RoundKeyUpdate0(T, K,  0, ABCD, KC0 );    // K_1,0 and K_1,1
		RoundKeyUpdate1(T, K,  2, ABCD, KC1 );    // K_2,0 and K_2,1
		RoundKeyUpdate0(T, K,  4, ABCD, KC2 );    // K_3,0 and K_3,1
		RoundKeyUpdate1(T, K,  6, ABCD, KC3 );    // K_4,0 and K_4,1
		RoundKeyUpdate0(T, K,  8, ABCD, KC4 );    // K_5,0 and K_5,1
		RoundKeyUpdate1(T, K, 10, ABCD, KC5 );    // K_6,0 and K_6,1
		RoundKeyUpdate0(T, K, 12, ABCD, KC6 );    // K_7,0 and K_7,1
		RoundKeyUpdate1(T, K, 14, ABCD, KC7 );    // K_8,0 and K_8,1
		RoundKeyUpdate0(T, K, 16, ABCD, KC8 );    // K_9,0 and K_9,1
		RoundKeyUpdate1(T, K, 18, ABCD, KC9 );    // K_10,0 and K_10,1
		RoundKeyUpdate0(T, K, 20, ABCD, KC10);    // K_11,0 and K_11,1
		RoundKeyUpdate1(T, K, 22, ABCD, KC11);    // K_12,0 and K_12,1
		RoundKeyUpdate0(T, K, 24, ABCD, KC12);    // K_13,0 and K_13,1
		RoundKeyUpdate1(T, K, 26, ABCD, KC13);    // K_14,0 and K_14,1
		RoundKeyUpdate0(T, K, 28, ABCD, KC14);    // K_15,0 and K_15,1

		T[0] = ABCD[ABCD_A] + ABCD[ABCD_C] - KC15;
		T[1] = ABCD[ABCD_B] - ABCD[ABCD_D] + KC15;
		
		K[30] = SS0[GetB0(T[0])&0x0ff] ^ SS1[GetB1(T[0])&0x0ff] ^   // K_16,0
				SS2[GetB2(T[0])&0x0ff] ^ SS3[GetB3(T[0])&0x0ff];
		K[31] = SS0[GetB0(T[1])&0x0ff] ^ SS1[GetB1(T[1])&0x0ff] ^   // K_16,1
				SS2[GetB2(T[1])&0x0ff] ^ SS3[GetB3(T[1])&0x0ff];

		return 1;


	}


	public static int SEED_CBC_Process( KISA_SEED_INFO pInfo, int[] in, int inLen, int[] out, int[] outLen ) {
		int nCurrentCount = BLOCK_SIZE_SEED;		
		int[] pdwXOR = null;
		int in_offset = 0;
		int out_offset = 0;
		int pdwXOR_offset = 0;

		if( null == pInfo ||
				null == in ||
				null == out ||
				0 > inLen )
			return 0;


		if( KISA_ENC_DEC._KISA_ENCRYPT == pInfo.encrypt ) {
			pdwXOR = pInfo.ivec;
			in_offset = 0;
			out_offset = 0;
			pdwXOR_offset = 0;
				

			while( nCurrentCount <= inLen )
			{
				BLOCK_XOR_CBC( out, out_offset, in, in_offset, pdwXOR, pdwXOR_offset );

				KISA_SEED_Encrypt_Block_forCBC( out, out_offset, out, out_offset, pInfo.seed_key );

				pdwXOR = out;
				pdwXOR_offset = out_offset;

				nCurrentCount += BLOCK_SIZE_SEED;
				in_offset += BLOCK_SIZE_SEED_INT;		
				out_offset += BLOCK_SIZE_SEED_INT;		
			}

			outLen[0] = nCurrentCount - BLOCK_SIZE_SEED; 
			pInfo.buffer_length = (inLen - outLen[0]);

			Common.memcpy( pInfo.ivec, pdwXOR, pdwXOR_offset, BLOCK_SIZE_SEED );
			Common.memcpy( pInfo.cbc_buffer, in, in_offset, pInfo.buffer_length );
		}
		else {
			pdwXOR = pInfo.ivec;
			in_offset = 0;
			out_offset = 0;
			pdwXOR_offset = 0;

			while( nCurrentCount <= inLen )			
			{
				KISA_SEED_Decrypt_Block_forCBC( in, in_offset, out, out_offset, pInfo.seed_key );

				BLOCK_XOR_CBC( out, out_offset, out, out_offset, pdwXOR, pdwXOR_offset );

				pdwXOR = in;
				pdwXOR_offset = in_offset;

				nCurrentCount += BLOCK_SIZE_SEED;
				in_offset += BLOCK_SIZE_SEED_INT;		
				out_offset += BLOCK_SIZE_SEED_INT;		
			}

			outLen[0] = nCurrentCount - BLOCK_SIZE_SEED;

 

			Common.memcpy( pInfo.ivec, pdwXOR, pdwXOR_offset, BLOCK_SIZE_SEED );		 	
			Common.memcpy( pInfo.cbc_last_block, out, out_offset-BLOCK_SIZE_SEED_INT, BLOCK_SIZE_SEED );	

			
		}

		return 1;

	}


	public static int SEED_CBC_Close( KISA_SEED_INFO pInfo, int[] out, int out_offset, int[] outLen ) {
		int nPaddngLeng;
		int i;

		outLen[0] = 0;

		if( null == out )
			return 0;

		if( KISA_ENC_DEC._KISA_ENCRYPT == pInfo.encrypt ) {
			nPaddngLeng = BLOCK_SIZE_SEED - pInfo.buffer_length;

			for( i = pInfo.buffer_length; i<BLOCK_SIZE_SEED; i++ ) {
				Common.set_byte_for_int(pInfo.cbc_buffer, i, (byte)nPaddngLeng, ENDIAN);
			}
			BLOCK_XOR_CBC( pInfo.cbc_buffer, 0, pInfo.cbc_buffer, 0, pInfo.ivec, 0 );

			KISA_SEED_Encrypt_Block_forCBC( pInfo.cbc_buffer, 0, out, out_offset, pInfo.seed_key );

			outLen[0] = BLOCK_SIZE_SEED;

			return 1;
		}
		

		else {
			nPaddngLeng = Common.get_byte_for_int(pInfo.cbc_last_block, BLOCK_SIZE_SEED-1, ENDIAN);			
	

			if( nPaddngLeng > 0 && nPaddngLeng <= BLOCK_SIZE_SEED )   
			{
				for(i=nPaddngLeng; i>0; i--)
				{
					Common.set_byte_for_int(out, out_offset-i, (byte)0x00, ENDIAN);
				}

				outLen[0] = nPaddngLeng;
			}
			else
				return 0;

			
		}
		return 1;


	}



	
	
	
	
	public static byte[] SEED_CBC_Encrypt( byte[] pbszUserKey, byte[] pbszIV, byte[] message, int message_offset, int message_length ) {
		KISA_SEED_INFO info = new KISA_SEED_INFO();
		int[] outbuf;
		int[] data;
		byte[] cdata;
		int outlen;
		int nRetOutLeng[] = new int[] { 0 };
		int nPaddingLeng[] = new int[] { 0 };
		
		byte[] pbszPlainText = new byte[message_length];
		System.arraycopy(message, message_offset, pbszPlainText, 0, message_length);
		int nPlainTextLen = pbszPlainText.length;
		

		int nPlainTextPadding = BLOCK_SIZE_SEED - (nPlainTextLen % BLOCK_SIZE_SEED);
		byte []newpbszPlainText = new byte[nPlainTextLen+nPlainTextPadding];
		Common.arraycopy(newpbszPlainText, pbszPlainText, nPlainTextLen);
		
		byte[] pbszCipherText = new byte[newpbszPlainText.length];
		

		SEED_CBC_init( info, KISA_ENC_DEC.KISA_ENCRYPT, pbszUserKey, pbszIV );

		outlen = ((newpbszPlainText.length/BLOCK_SIZE_SEED) ) * BLOCK_SIZE_SEED_INT ;
		outbuf = new int[outlen];
		data = chartoint32_for_SEED_CBC(newpbszPlainText, nPlainTextLen);

		SEED_CBC_Process( info, data, nPlainTextLen, outbuf, nRetOutLeng );
		SEED_CBC_Close( info, outbuf, (nRetOutLeng[0]/4), nPaddingLeng );

		cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]+nPaddingLeng[0]);
		Common.arraycopy(pbszCipherText, cdata, nRetOutLeng[0]+nPaddingLeng[0]);

		data = null;
		cdata = null;
		outbuf = null;

		return pbszCipherText;
	}
	
	
	
	
	
	
	
	
	


	public static byte[] SEED_CBC_Decrypt( byte[] pbszUserKey, byte[] pbszIV, byte[] message, int message_offset, int message_length ) {
		KISA_SEED_INFO info = new KISA_SEED_INFO();
		int[] outbuf;
		int[] data;
		byte[] cdata;
		int outlen;
		int nRetOutLeng[] = new int[] { 0 };
		int nPaddingLeng[] = new int[] { 0 };
		
		
		
		byte[] pbszCipherText = new byte[message_length];
		System.arraycopy(message, message_offset, pbszCipherText, 0, message_length);
		int nCipherTextLen = pbszCipherText.length;
		
		if( (nCipherTextLen%BLOCK_SIZE_SEED) != 0 )
		{
			byte result[] = null;
			return result;
		}
		

		byte []newpbszCipherText = new byte[nCipherTextLen];
		Common.arraycopy(newpbszCipherText, pbszCipherText, nCipherTextLen);		

		nCipherTextLen = newpbszCipherText.length;


		SEED_CBC_init( info, KISA_ENC_DEC.KISA_DECRYPT, pbszUserKey, pbszIV );

		outlen = ((nCipherTextLen/16)) *4 ;
		outbuf = new int[outlen];
		data = chartoint32_for_SEED_CBC(newpbszCipherText, nCipherTextLen);

		SEED_CBC_Process( info, data, nCipherTextLen, outbuf, nRetOutLeng );
		
		
		if( SEED_CBC_Close( info, outbuf, (nRetOutLeng[0]), nPaddingLeng ) == 1 )
		{
			cdata = int32tochar_for_SEED_CBC( outbuf, nRetOutLeng[0]-nPaddingLeng[0] );
			
			byte[] pbszPlainText = new byte[nRetOutLeng[0]-nPaddingLeng[0]];
						
			Common.arraycopy(pbszPlainText, cdata, nRetOutLeng[0]-nPaddingLeng[0]);
			
			int pdmessage_length = nRetOutLeng[0]-nPaddingLeng[0];
			byte[] result = new byte[pdmessage_length];
			System.arraycopy(pbszPlainText, 0, result, 0, pdmessage_length);
			
			data = null;
			cdata = null;
			outbuf = null;

			return result;
			
		}
		else
		{
			byte result[] = null;
			return result;
		}


	}
	
	
	
	
	
	
	
	



	public static final class KISA_ENC_DEC {
		public static final int _KISA_DECRYPT = 0;
		public static final int _KISA_ENCRYPT = 1;

		public int value;

		public KISA_ENC_DEC(int value ) {
			this.value = value;
		}

		public static final KISA_ENC_DEC KISA_ENCRYPT = new KISA_ENC_DEC(_KISA_ENCRYPT);
		public static final KISA_ENC_DEC KISA_DECRYPT = new KISA_ENC_DEC(_KISA_DECRYPT);

	}

	public static final class KISA_SEED_KEY {
		public int[] key_data = new int[32];

		public void init() {
			for(int i=0; i<key_data.length; i++) {
				key_data[i] = 0;
			}
		}
	}

	public static final class KISA_SEED_INFO {
		public int encrypt;
		public int ivec[] = new int[4];
		public KISA_SEED_KEY seed_key = new KISA_SEED_KEY();
		public int cbc_buffer[] = new int[4];
		public int buffer_length;
		public int[] cbc_last_block = new int[4];
		public int last_block_flag;

		public KISA_SEED_INFO() {
			encrypt = 0;
			ivec[0] = ivec[1] = ivec[2] = ivec[3] = 0;
			seed_key.init();
			cbc_buffer[0] = cbc_buffer[1] = cbc_buffer[2] = cbc_buffer[3] = 0;
			buffer_length = 0;
			cbc_last_block[0] = cbc_last_block[1] = cbc_last_block[2] = cbc_last_block[3] = 0;
			last_block_flag = 0;
		}


	}
	
	
	
	

	public static class Common {
		
		public static final int BIG_ENDIAN = 0;
		public static final int LITTLE_ENDIAN = 1;

		public static void arraycopy(byte[] dst, byte[] src, int length) {
			for(int i=0; i<length; i++) {
				dst[i] = src[i];
			}
		}

		public static void arraycopy_offset(byte[] dst, int dst_offset, byte[] src, int src_offset, int length) {
			for(int i=0; i<length; i++) {
				dst[dst_offset+i] = src[src_offset+i];
			}
		}

		public static void arrayinit(byte[] dst, byte value, int length) {
			for(int i=0; i<length; i++) {
				dst[i] = value;
			}
		}
		
		public static void arrayinit_offset(byte[] dst, int dst_offset, byte value, int length) {
			for(int i=0; i<length; i++) {
				dst[dst_offset+i] = value;
			}
		}

		public static void memcpy(int[] dst, byte[] src, int length, int ENDIAN) {
			int iLen = length / 4;
			for(int i=0; i<iLen; i++) {
				byte_to_int(dst, i, src, i*4, ENDIAN);
			}
		}

		public static void memcpy(int[] dst, int[] src, int src_offset, int length) {
	    	int iLen = length / 4 + ((length % 4 != 0)?1:0);
			for(int i=0; i<iLen; i++) {
				dst[i] = src[src_offset+i];
			}
		}

		public static void set_byte_for_int(int[] dst, int b_offset, byte value, int ENDIAN) {
			if(ENDIAN == BIG_ENDIAN) {
				int shift_value = (3-b_offset%4)*8;
				int mask_value =  0x0ff << shift_value;
				int mask_value2 = ~mask_value;
				int value2 = (value&0x0ff) << shift_value;
				dst[b_offset/4] = (dst[b_offset/4] & mask_value2) | (value2 & mask_value);    
			} else {
				int shift_value = (b_offset%4)*8;
				int mask_value =  0x0ff << shift_value;
				int mask_value2 = ~mask_value;
				int value2 = (value&0x0ff) << shift_value;
				dst[b_offset/4] = (dst[b_offset/4] & mask_value2) | (value2 & mask_value);    
			}
		}
		
		public static byte get_byte_for_int(int[] src, int b_offset, int ENDIAN) {
			if(ENDIAN == BIG_ENDIAN) {
				int shift_value = (3-b_offset%4)*8;
				int mask_value =  0x0ff << shift_value;
				int value = (src[b_offset/4] & mask_value) >> shift_value;
				return (byte)value;
			} else {
				int shift_value = (b_offset%4)*8;
				int mask_value =  0x0ff << shift_value;
				int value = (src[b_offset/4] & mask_value) >> shift_value;
				return (byte)value;
			}
			
		}
		
		public static byte[] get_bytes_for_ints(int[] src, int offset, int ENDIAN) {
			int iLen = src.length-offset;
			byte[] result = new byte[(iLen)*4];
			for(int i=0; i<iLen; i++) {
				int_to_byte(result, i*4, src, offset+i, ENDIAN);
			}
			
			return result;
		}

		public static void byte_to_int(int[] dst, int dst_offset, byte[] src, int src_offset, int ENDIAN) {
			if(ENDIAN == BIG_ENDIAN) {
				dst[dst_offset] = ((0x0ff&src[src_offset]) << 24) | ((0x0ff&src[src_offset+1]) << 16) | ((0x0ff&src[src_offset+2]) << 8) | ((0x0ff&src[src_offset+3]));
			} else {
				dst[dst_offset] = ((0x0ff&src[src_offset])) | ((0x0ff&src[src_offset+1]) << 8) | ((0x0ff&src[src_offset+2]) << 16) | ((0x0ff&src[src_offset+3]) << 24);
			}
		}
		
		public static int byte_to_int(byte[] src, int src_offset, int ENDIAN) {
			if(ENDIAN == BIG_ENDIAN) {
				return ((0x0ff&src[src_offset]) << 24) | ((0x0ff&src[src_offset+1]) << 16) | ((0x0ff&src[src_offset+2]) << 8) | ((0x0ff&src[src_offset+3]));
			} else {
				return ((0x0ff&src[src_offset])) | ((0x0ff&src[src_offset+1]) << 8) | ((0x0ff&src[src_offset+2]) << 16) | ((0x0ff&src[src_offset+3]) << 24);
			}
		}

		public static int byte_to_int_big_endian(byte[] src, int src_offset) {
			return ((0x0ff&src[src_offset]) << 24) | ((0x0ff&src[src_offset+1]) << 16) | ((0x0ff&src[src_offset+2]) << 8) | ((0x0ff&src[src_offset+3]));
		}

		public static void int_to_byte(byte[] dst, int dst_offset, int[] src, int src_offset, int ENDIAN) {
			int_to_byte_unit(dst, dst_offset, src[src_offset], ENDIAN);
		}
		
		public static void int_to_byte_unit(byte[] dst, int dst_offset, int src, int ENDIAN) {
			if(ENDIAN == BIG_ENDIAN) {
				dst[dst_offset] = (byte)((src>> 24) & 0x0ff);
				dst[dst_offset+1] = (byte)((src >> 16) & 0x0ff);
				dst[dst_offset+2] = (byte)((src >> 8) & 0x0ff);
				dst[dst_offset+3] = (byte)((src) & 0x0ff);
			} else {
				dst[dst_offset] = (byte)((src) & 0x0ff);
				dst[dst_offset+1] = (byte)((src >> 8) & 0x0ff);
				dst[dst_offset+2] = (byte)((src >> 16) & 0x0ff);
				dst[dst_offset+3] = (byte)((src >> 24) & 0x0ff);
			}
			
		}

		public static void int_to_byte_unit_big_endian(byte[] dst, int dst_offset, int src) {
			dst[dst_offset] = (byte)((src>> 24) & 0x0ff);
			dst[dst_offset+1] = (byte)((src >> 16) & 0x0ff);
			dst[dst_offset+2] = (byte)((src >> 8) & 0x0ff);
			dst[dst_offset+3] = (byte)((src) & 0x0ff);
		}

		public static int URShift(int x, int n) {
			if(n == 0)
				return x;
			if(n >= 32)
				return 0;
			int v = x >> n;
			int v_mask = ~(0x80000000 >> (n-1));
			return v & v_mask;
		}
		
		public static final long INT_RANGE_MAX = (long)Math.pow(2, 32);

		public static long intToUnsigned(int x) {
			if(x >= 0)
				return x;
			return x + INT_RANGE_MAX;
		}
		
		//Padding : PKSC #7
		//출력 : PADDING 후 길이(바이트단위)
		public static int Padding(byte[] pbData, byte[] padData, int length) {
			int i;
			int padvalue = 16 - (length%16);
			Common.arraycopy(padData, pbData, length);
			i = length;
			do {
				padData[i] = (byte)(padvalue);
				i++;
			}while((i%16) != 0);
			return i;
		}
		
		
		//1블럭(128비트 XOR)
		public static void BLOCK_XOR_PROPOSAL(int[] OUT_VALUE, int out_value_offset, int[] IN_VALUE1, int in_value1_offset, int[] IN_VALUE2, int in_value2_offset) {
			OUT_VALUE[out_value_offset+0] = (in_value1_offset<IN_VALUE1.length?IN_VALUE1[in_value1_offset+0]:0) ^ (in_value2_offset<IN_VALUE2.length?IN_VALUE2[in_value2_offset+0]:0);
			OUT_VALUE[out_value_offset+1] = (in_value1_offset+1<IN_VALUE1.length?IN_VALUE1[in_value1_offset+1]:0) ^ (in_value2_offset+1<IN_VALUE2.length?IN_VALUE2[in_value2_offset+1]:0);
			OUT_VALUE[out_value_offset+2] = (in_value1_offset+2<IN_VALUE1.length?IN_VALUE1[in_value1_offset+2]:0) ^ (in_value2_offset+2<IN_VALUE2.length?IN_VALUE2[in_value2_offset+2]:0);
			OUT_VALUE[out_value_offset+3] = (in_value1_offset+3<IN_VALUE1.length?IN_VALUE1[in_value1_offset+3]:0) ^ (in_value2_offset+3<IN_VALUE2.length?IN_VALUE2[in_value2_offset+3]:0);
		}
		
		
	}
	
	

	public static int SeedRoundKey( KISA_SEED_INFO pInfo, KISA_ENC_DEC enc, byte[] pbszUserKey, byte[] pbszIV ) {
		int ABCD[] = new int[4];			// Iuput/output values at each rounds(각 라운드 입/출력)
		int T[] = new int[2];				// Temporary variable
		int K[];

		if( null == pInfo ||
				null == pbszUserKey ||
				null == pbszIV )
			return 0;

		K = pInfo.seed_key.key_data;										// Pointer of round keys
		pInfo.encrypt = enc.value;											// 
		Common.memcpy(pInfo.ivec, pbszIV, 16, ENDIAN);
		pInfo.last_block_flag = pInfo.buffer_length = 0;

		// Set up input values for Key Schedule
		ABCD[ABCD_A] = Common.byte_to_int(pbszUserKey, 0*4, ENDIAN);
		ABCD[ABCD_B] = Common.byte_to_int(pbszUserKey, 1*4, ENDIAN);
		ABCD[ABCD_C] = Common.byte_to_int(pbszUserKey, 2*4, ENDIAN);
		ABCD[ABCD_D] = Common.byte_to_int(pbszUserKey, 3*4, ENDIAN);
		
		// Reorder for big endian
		if(Common.BIG_ENDIAN != ENDIAN) {
			ABCD[ABCD_A] = EndianChange(ABCD[ABCD_A]);
			ABCD[ABCD_B] = EndianChange(ABCD[ABCD_B]);
			ABCD[ABCD_C] = EndianChange(ABCD[ABCD_C]);
			ABCD[ABCD_D] = EndianChange(ABCD[ABCD_D]);
		}

		// i-th round keys( K_i,0 and K_i,1 ) are denoted as K[2*(i-1)] and K[2*i-1], respectively
		RoundKeyUpdate0(T, K,  0, ABCD, KC0 );    // K_1,0 and K_1,1
		RoundKeyUpdate1(T, K,  2, ABCD, KC1 );    // K_2,0 and K_2,1
		RoundKeyUpdate0(T, K,  4, ABCD, KC2 );    // K_3,0 and K_3,1
		RoundKeyUpdate1(T, K,  6, ABCD, KC3 );    // K_4,0 and K_4,1
		RoundKeyUpdate0(T, K,  8, ABCD, KC4 );    // K_5,0 and K_5,1
		RoundKeyUpdate1(T, K, 10, ABCD, KC5 );    // K_6,0 and K_6,1
		RoundKeyUpdate0(T, K, 12, ABCD, KC6 );    // K_7,0 and K_7,1
		RoundKeyUpdate1(T, K, 14, ABCD, KC7 );    // K_8,0 and K_8,1
		RoundKeyUpdate0(T, K, 16, ABCD, KC8 );    // K_9,0 and K_9,1
		RoundKeyUpdate1(T, K, 18, ABCD, KC9 );    // K_10,0 and K_10,1
		RoundKeyUpdate0(T, K, 20, ABCD, KC10);    // K_11,0 and K_11,1
		RoundKeyUpdate1(T, K, 22, ABCD, KC11);    // K_12,0 and K_12,1
		RoundKeyUpdate0(T, K, 24, ABCD, KC12);    // K_13,0 and K_13,1
		RoundKeyUpdate1(T, K, 26, ABCD, KC13);    // K_14,0 and K_14,1
		RoundKeyUpdate0(T, K, 28, ABCD, KC14);    // K_15,0 and K_15,1

		T[0] = ABCD[ABCD_A] + ABCD[ABCD_C] - KC15;
		T[1] = ABCD[ABCD_B] - ABCD[ABCD_D] + KC15;
		
		K[30] = SS0[GetB0(T[0])&0x0ff] ^ SS1[GetB1(T[0])&0x0ff] ^   // K_16,0
				SS2[GetB2(T[0])&0x0ff] ^ SS3[GetB3(T[0])&0x0ff];
		K[31] = SS0[GetB0(T[1])&0x0ff] ^ SS1[GetB1(T[1])&0x0ff] ^   // K_16,1
				SS2[GetB2(T[1])&0x0ff] ^ SS3[GetB3(T[1])&0x0ff];

		return 1;


	}
	
	
	
	
	public static void main(String[] args)
	{


		byte pbUserKey[]  = {(byte)0x88, (byte)0xE3, (byte)0x4F, (byte)0x8F, (byte)0x08, (byte)0x17, (byte)0x79, (byte)0xF1, (byte)0xE9, (byte)0xF3, (byte)0x94, (byte)0x37, (byte)0x0A, (byte)0xD4, (byte)0x05, (byte)0x89};

		byte pbData[]     = {(byte)0x08, (byte)0x09, (byte)0x0A, (byte)0x0B, (byte)0x0C, (byte)0x0D, (byte)0x0E, (byte)0x0F,
							(byte)0x08, (byte)0x09, (byte)0x0A, (byte)0x0B, (byte)0x0C, (byte)0x0D, (byte)0x0E, (byte)0x0F,
							(byte)0x08, (byte)0x09, (byte)0x0A, (byte)0x0B, (byte)0x0C, (byte)0x0D, (byte)0x0E, (byte)0x0F,
                			(byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00};
		
		byte pbData1[]     = {(byte)0x00, (byte)0x01};
		
//		byte pbData2[]     = {(byte)0x00, (byte)0x01, (byte)0x02, (byte)0x03, (byte)0x04, (byte)0x05, (byte)0x06, (byte)0x07,
//                (byte)0x08, (byte)0x09, (byte)0x0A, (byte)0x0B, (byte)0x0C, (byte)0x0D, (byte)0x0E, (byte)0x0F};

		byte pbData2[]     = {(byte)0xD7, (byte)0x6D, (byte)0x0D, (byte)0x18, (byte)0x32, (byte)0x7E, (byte)0xC5, (byte)0x62,
                (byte)0xB1, (byte)0x5E, (byte)0x6B, (byte)0xC3, (byte)0x65, (byte)0xAC, (byte)0x0C, (byte)0x0F};

		
		byte pbData3[]     = {(byte)0x00, (byte)0x01, (byte)0x02, (byte)0x03, (byte)0x04, (byte)0x05, (byte)0x06, (byte)0x07,
                (byte)0x08, (byte)0x09, (byte)0x0A, (byte)0x0B, (byte)0x0C, (byte)0x0D, (byte)0x0E, (byte)0x0F, (byte)0x00, (byte)0x01};
		
		byte bszIV[] = {
				(byte)0x026, (byte)0x08d, (byte)0x066, (byte)0x0a7,
				(byte)0x035, (byte)0x0a8, (byte)0x01a, (byte)0x081,
				(byte)0x06f, (byte)0x0ba, (byte)0x0d9, (byte)0x0fa,
				(byte)0x036, (byte)0x016, (byte)0x025, (byte)0x001
		};
		


		
	    int PLAINTEXT_LENGTH = 14;
	    int CIPHERTEXT_LENGTH = 16;		
		
		System.out.print("\n");
		System.out.print("[ Test SEED reference code CBC]"+"\n");
		System.out.print("\n\n");
		
		
		
		System.out.print("[ Test Encrypt mode : 방법 1 ]"+"\n");
		System.out.print("Key\t\t\t\t: ");
	    for (int i=0; i<16; i++)	System.out.print(Integer.toHexString(0xff&pbUserKey[i])+" ");
	    System.out.print("\n");
		System.out.print("Plaintext\t\t\t: ");
	    for (int i=0; i<PLAINTEXT_LENGTH; i++)	System.out.print(Integer.toHexString(0xff&pbData[i])+" ");
	    System.out.print("\n");

	    

	    
	    byte[] defaultCipherText = SEED_CBC_Encrypt(pbUserKey, bszIV, pbData, 0, PLAINTEXT_LENGTH);
	    
	    
	    byte[] PPPPP = SEED_CBC_Decrypt(pbUserKey, bszIV, defaultCipherText, 0, CIPHERTEXT_LENGTH);
	    
	    
	    System.out.print("\nIV\t\t\t\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&bszIV[i])+" ");
	    System.out.print("\n");
	    
		System.out.print("Ciphertext(SEED_CBC_Encrypt)\t: ");
	    for (int i=0; i<CIPHERTEXT_LENGTH; i++)
	    	System.out.print(Integer.toHexString(0xff&defaultCipherText[i])+" ");
	    System.out.print("\n");
	    
	    System.out.print("Plaintext(SEED_CBC_Decrypt)\t: ");
	    for (int i=0; i<PLAINTEXT_LENGTH; i++)
	    	System.out.print(Integer.toHexString(0xff&PPPPP[i])+" ");
	    System.out.print("\n\n");
	    
	    
	    byte[] Cipher1 = SEED_CBC_Encrypt(pbUserKey, bszIV, pbData1,0, 2);
	    
	    byte[] Plain1 = SEED_CBC_Decrypt(pbUserKey, bszIV, Cipher1, 0, 16);
	    
	    System.out.print("IV\t\t\t\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&bszIV[i])+" ");
	    System.out.print("\n");
	    
		System.out.print("Ciphertext(SEED_CBC_Encrypt1)\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&Cipher1[i])+" ");
	    System.out.print("\n");
	    
	    System.out.print("Plaintext(SEED_CBC_Decrypt1)\t: ");
	    for (int i=0; i<2; i++)
	    	System.out.print(Integer.toHexString(0xff&Plain1[i])+" ");
	    System.out.print("\n\n");

	    
	    byte[] Cipher2 = SEED_CBC_Encrypt(pbUserKey, bszIV, pbData2,0, 16);
	    
	    byte[] Plain2 = SEED_CBC_Decrypt(pbUserKey, bszIV, Cipher2, 0, 32);
	    
	    System.out.print("IV\t\t\t\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&bszIV[i])+" ");
	    System.out.print("\n\n");
	    
		System.out.print("Ciphertext(SEED_CBC_Encrypt)\t: ");
	    for (int i=0; i<32; i++)
	    	System.out.print(Integer.toHexString(0xff&Cipher2[i])+" ");
	    System.out.print("\n");
	    
	    System.out.print("Plaintext(SEED_CBC_Decrypt)\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&Plain2[i])+" ");
	    System.out.print("\n\n\n");
	    
	
	    
	    
	    byte[] Cipher3 = SEED_CBC_Encrypt(pbUserKey, bszIV, pbData3, 0, 18);
	    
	    byte[] Plain3 = SEED_CBC_Decrypt(pbUserKey, bszIV, Cipher3, 0, 32);
	    
	    System.out.print("IV\t\t\t\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&bszIV[i])+" ");
	    System.out.print("\n");
	    
		System.out.print("Ciphertext(SEED_CBC_Encrypt3)\t: ");
	    for (int i=0; i<32; i++)
	    	System.out.print(Integer.toHexString(0xff&Cipher3[i])+" ");
	    System.out.print("\n");
	    
	    System.out.print("Plaintext(SEED_CBC_Decrypt3)\t: ");
	    for (int i=0; i<18; i++)
	    	System.out.print(Integer.toHexString(0xff&Plain3[i])+" ");
	    System.out.print("\n");

		   
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    /*****************************************************************
	    /*****************************************************************
	    /*****************************************************************
	    /*****************************************************************
	    /*****************************************************************
	     * 방법2
	     ******************************************************************/
	        
	    
	    PLAINTEXT_LENGTH = 14;
	    
		System.out.print("\n\n[ Test Encrypt mode : 방법 2 ]"+"\n");
		System.out.print("Key\t\t\t\t: ");
	    for (int i=0; i<16; i++)	System.out.print(Integer.toHexString(0xff&pbUserKey[i])+", ");
	    System.out.print("\n");
		System.out.print("Plaintext\t\t\t: ");
	    for (int i=0; i<PLAINTEXT_LENGTH; i++)	System.out.print(Integer.toHexString(0xff&pbData[i])+", ");
	    System.out.print("\n");
	    
	    

	    
	    
	    /************************************************************************************************
	     * 첫번째
	     */
	    
	    // 암호화
	    
	    KISA_SEED_INFO info = new KISA_SEED_INFO();
		int[] data;
		byte[] cdata;
		int nRetOutLeng[] = new int[] { 0 };
		int nPaddingLeng[] = new int[] { 0 };
		int j;
		
		

		int nPlainTextPadding = BLOCK_SIZE_SEED - (PLAINTEXT_LENGTH % BLOCK_SIZE_SEED);
		byte []newpbszPlainText = new byte[PLAINTEXT_LENGTH+nPlainTextPadding];
		Common.arraycopy(newpbszPlainText, pbData, PLAINTEXT_LENGTH);		
		
		
		byte[] pbszCipherText = new byte[newpbszPlainText.length];			
		

		SEED_CBC_init( info, KISA_ENC_DEC.KISA_ENCRYPT, pbUserKey, bszIV );
		
		int process_blockLeng = BLOCK_SIZE_SEED * 2;								//한번에 처리할 BLOCK
		
		int[] outbuf = new int[process_blockLeng/4];
		
		for(j=0; j<PLAINTEXT_LENGTH-process_blockLeng; )
		{			
			System.arraycopy(pbData, j, newpbszPlainText, 0, process_blockLeng);
			data = chartoint32_for_SEED_CBC(newpbszPlainText, process_blockLeng);			
			SEED_CBC_Process( info, data, process_blockLeng, outbuf, nRetOutLeng );			
			cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);			
			System.arraycopy(cdata, 0, pbszCipherText, j, nRetOutLeng[0]);			
			j += nRetOutLeng[0];
		}
		
		int remainleng = PLAINTEXT_LENGTH % process_blockLeng;
		if(remainleng == 0)
		{
			remainleng = process_blockLeng;
		}
		System.arraycopy(pbData, j, newpbszPlainText, 0, remainleng);
		data = chartoint32_for_SEED_CBC(newpbszPlainText, remainleng);
		SEED_CBC_Process( info, data, remainleng, outbuf, nRetOutLeng);
		cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);
		System.arraycopy(cdata, 0, pbszCipherText, j, nRetOutLeng[0]);
		j += nRetOutLeng[0];
		
		
		
		
		SEED_CBC_Close( info, outbuf, 0, nPaddingLeng );		
		cdata = int32tochar_for_SEED_CBC(outbuf, nPaddingLeng[0]);		
		System.arraycopy(cdata, 0, pbszCipherText, j, nPaddingLeng[0]);
		


	    
	    System.out.print("IV\t\t\t\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&bszIV[i])+", ");
	    System.out.print("\n");
	    
		System.out.print("Ciphertext(SEED_CBC_Encrypt 1)\t: ");
	    for (int i=0; i<CIPHERTEXT_LENGTH; i++)
	    	System.out.print(Integer.toHexString(0xff&pbszCipherText[i])+", ");
	    System.out.print("\n");
	    
	    
		data = null;
		cdata = null;
		info = null;

	    
	    
	    
	    
	    
	    
	    
	    // 복호화
	    
	    info = new KISA_SEED_INFO();
	    CIPHERTEXT_LENGTH = 16;
	    
	    int pbszCipherText_offset = 0;
    
	    
	    byte[] message = new byte[CIPHERTEXT_LENGTH];
		System.arraycopy(pbszCipherText, pbszCipherText_offset, message, 0, CIPHERTEXT_LENGTH);
		
		int nCipherTextLen = message.length;
		
		if( (nCipherTextLen%BLOCK_SIZE_SEED) != 0 )
		{
			System.out.print("Decryption_FAIL! \n\n");	
		}
		
	

		SEED_CBC_init( info, KISA_ENC_DEC.KISA_DECRYPT, pbUserKey, bszIV );
		
		process_blockLeng = BLOCK_SIZE_SEED * 2;
		

		outbuf = new int[process_blockLeng/4];
		
		byte []newpbszCipherText = new byte[nCipherTextLen];
		byte []pbszPlainText = new byte[nCipherTextLen];
		
		
		for(j=0; j<nCipherTextLen - process_blockLeng; )
		{
			System.arraycopy(message, j, newpbszCipherText, 0, process_blockLeng);
			data = chartoint32_for_SEED_CBC(newpbszCipherText, process_blockLeng);	
			SEED_CBC_Process( info, data, process_blockLeng, outbuf, nRetOutLeng );			
			cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);			
			System.arraycopy(cdata, 0, pbszPlainText, j, nRetOutLeng[0]);			
			j += nRetOutLeng[0];
		}
		
		remainleng =  nCipherTextLen%process_blockLeng;
		if(remainleng == 0)
		{
			remainleng = process_blockLeng;
		}
		System.arraycopy(message, j, newpbszCipherText, 0, remainleng);
		data = chartoint32_for_SEED_CBC(newpbszCipherText, remainleng);	
		SEED_CBC_Process( info, data, remainleng, outbuf, nRetOutLeng );			
		cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);			
		System.arraycopy(cdata, 0, pbszPlainText, j, nRetOutLeng[0]);			
		j += nRetOutLeng[0];
		
		byte[] result = new byte[100];///////////////////////////////////////////////////////////////////////////////
		
		if(SEED_CBC_Close( info, outbuf, (nRetOutLeng[0]), nPaddingLeng ) == 1)
		{
			cdata = int32tochar_for_SEED_CBC( outbuf, remainleng-nPaddingLeng[0] );
			
			byte[] newpbszPlainTexts = new byte[remainleng-nPaddingLeng[0]];
						
			Common.arraycopy(newpbszPlainTexts, cdata, remainleng-nPaddingLeng[0]);
			
			int message_length = remainleng-nPaddingLeng[0];
			
			result = new byte[message_length];
			System.arraycopy(newpbszPlainTexts, 0, result, 0, message_length);
			
			data = null;
			cdata = null;
			outbuf = null;

		}
		else
		{
			System.out.print("DECRYPT FAIL! ");
		}
	    
	
	    
	    
	    System.out.print("Plaintext(SEED_CBC_Decrypt 1)\t: ");
	    for (int i=0; i<PLAINTEXT_LENGTH; i++)
	    	System.out.print(Integer.toHexString(0xff&result[i])+", ");
	    System.out.print("\n\n");
	    
		data = null;
		cdata = null;
		outbuf = null;
		info = null;		
		
		
		pbszCipherText = null;
		result = null;
		
		
		
		
		
		
	    
	    
	    
	    
	    
	    
	    
	    /*******************************************************************************************************
	     * 두번째 t.v
	     */    
		
		info = new KISA_SEED_INFO();
		
	    
	    PLAINTEXT_LENGTH = 2;
	    

		nPlainTextPadding = BLOCK_SIZE_SEED - (PLAINTEXT_LENGTH % BLOCK_SIZE_SEED);
		newpbszPlainText = new byte[PLAINTEXT_LENGTH+nPlainTextPadding];
		Common.arraycopy(newpbszPlainText, pbData1, PLAINTEXT_LENGTH);		
		
		
		pbszCipherText = new byte[newpbszPlainText.length];			
		

		SEED_CBC_init( info, KISA_ENC_DEC.KISA_ENCRYPT, pbUserKey, bszIV );
		
		process_blockLeng = BLOCK_SIZE_SEED * 2;								//한번에 처리할 BLOCK
		

		outbuf = new int[process_blockLeng/4];
		pbszPlainText = new byte[process_blockLeng];
		
		for(j=0; j<PLAINTEXT_LENGTH-process_blockLeng; )
		{			
			System.arraycopy(pbData1, j, newpbszPlainText, 0, process_blockLeng);
			data = chartoint32_for_SEED_CBC(newpbszPlainText, process_blockLeng);
			
			SEED_CBC_Process( info, data, process_blockLeng, outbuf, nRetOutLeng );
			
			cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);
			
			System.arraycopy(cdata, 0, pbszCipherText, j, nRetOutLeng[0]);
			
			j += nRetOutLeng[0];
		}
		
		remainleng = PLAINTEXT_LENGTH % process_blockLeng;
		if(remainleng == 0)
		{
			remainleng = process_blockLeng;
		}
		System.arraycopy(pbData1, j, newpbszPlainText, 0, remainleng);
		data = chartoint32_for_SEED_CBC(newpbszPlainText, remainleng);
		SEED_CBC_Process( info, data, remainleng, outbuf, nRetOutLeng);
		cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);
		System.arraycopy(cdata, 0, pbszCipherText, j, nRetOutLeng[0]);
		j += nRetOutLeng[0];		
		
		SEED_CBC_Close( info, outbuf, 0, nPaddingLeng );		
		cdata = int32tochar_for_SEED_CBC(outbuf, nPaddingLeng[0]);		
		System.arraycopy(cdata, 0, pbszCipherText, j, nPaddingLeng[0]);
		

		
		
	    
	    System.out.print("\n\nIV\t\t\t\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&bszIV[i])+" ");
	    System.out.print("\n");
	    
		System.out.print("Ciphertext(SEED_CBC_Encrypt)\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&pbszCipherText[i])+" ");
	    System.out.print("\n");
	    

	    	    
		data = null;
		cdata = null;
		outbuf = null;
		
		
		
		
		
		/**
		 * 복호화
		 */
		
	    // 복호화
	    
	    info = new KISA_SEED_INFO();
	    CIPHERTEXT_LENGTH = 16;
	    
	    pbszCipherText_offset = 0;
    
	    
	    message = new byte[CIPHERTEXT_LENGTH];
		System.arraycopy(pbszCipherText, pbszCipherText_offset, message, 0, CIPHERTEXT_LENGTH);
		
		nCipherTextLen = message.length;
		
		if( (nCipherTextLen%BLOCK_SIZE_SEED) != 0 )
		{
			System.out.print("Decryption_FAIL! \n\n");	
		}
		
	

		SEED_CBC_init( info, KISA_ENC_DEC.KISA_DECRYPT, pbUserKey, bszIV );
		
		process_blockLeng = BLOCK_SIZE_SEED * 2;
		

		outbuf = new int[process_blockLeng/4];
		
		newpbszCipherText = new byte[nCipherTextLen];
		pbszPlainText = new byte[nCipherTextLen];
		
		
		for(j=0; j<nCipherTextLen - process_blockLeng; )
		{
			System.arraycopy(message, j, newpbszCipherText, 0, process_blockLeng);
			data = chartoint32_for_SEED_CBC(newpbszCipherText, process_blockLeng);	
			SEED_CBC_Process( info, data, process_blockLeng, outbuf, nRetOutLeng );			
			cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);			
			System.arraycopy(cdata, 0, pbszPlainText, j, nRetOutLeng[0]);			
			j += nRetOutLeng[0];
		}
		
		remainleng =  nCipherTextLen%process_blockLeng;
		if(remainleng == 0)
		{
			remainleng = process_blockLeng;
		}
		System.arraycopy(message, j, newpbszCipherText, 0, remainleng);
		data = chartoint32_for_SEED_CBC(newpbszCipherText, remainleng);	
		SEED_CBC_Process( info, data, remainleng, outbuf, nRetOutLeng );			
		cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);			
		System.arraycopy(cdata, 0, pbszPlainText, j, nRetOutLeng[0]);			
		j += nRetOutLeng[0];
		

		
		if(SEED_CBC_Close( info, outbuf, (nRetOutLeng[0]), nPaddingLeng ) == 1)
		{
			cdata = int32tochar_for_SEED_CBC( outbuf, remainleng-nPaddingLeng[0] );
			
			byte[] newpbszPlainTexts = new byte[remainleng-nPaddingLeng[0]];
						
			Common.arraycopy(newpbszPlainTexts, cdata, remainleng-nPaddingLeng[0]);
			
			int message_length = remainleng-nPaddingLeng[0];
			
			result = new byte[message_length];
			System.arraycopy(newpbszPlainTexts, 0, result, 0, message_length);
			
			data = null;
			cdata = null;
			outbuf = null;

		}
		else
		{
			System.out.print("DECRYPT FAIL! ");
		}
	    
	
	    
	    
	    System.out.print("Plaintext(SEED_CBC_Decrypt 1)\t: ");
	    for (int i=0; i<PLAINTEXT_LENGTH; i++)
	    	System.out.print(Integer.toHexString(0xff&result[i])+" ");
	    System.out.print("\n\n");
	    
		data = null;
		cdata = null;
		outbuf = null;
		
		pbszCipherText = null;
		result = null;
		
		
		
	    /*******************************************************************************************************
	     * 세번째 t.v
	     */    
	    
	    PLAINTEXT_LENGTH = 16;
	    

		nPlainTextPadding = BLOCK_SIZE_SEED - (PLAINTEXT_LENGTH % BLOCK_SIZE_SEED);
		newpbszPlainText = new byte[PLAINTEXT_LENGTH+nPlainTextPadding];
		Common.arraycopy(newpbszPlainText, pbData2, PLAINTEXT_LENGTH);		
		
		
		pbszCipherText = new byte[newpbszPlainText.length];			
		

		SEED_CBC_init( info, KISA_ENC_DEC.KISA_ENCRYPT, pbUserKey, bszIV );
		
		process_blockLeng = BLOCK_SIZE_SEED * 2;								//한번에 처리할 BLOCK
		

		outbuf = new int[process_blockLeng/4];
		pbszPlainText = new byte[process_blockLeng];
		
		for(j=0; j<PLAINTEXT_LENGTH-process_blockLeng; )
		{			
			System.arraycopy(pbData2, j, newpbszPlainText, 0, process_blockLeng);
			data = chartoint32_for_SEED_CBC(newpbszPlainText, process_blockLeng);
			
			SEED_CBC_Process( info, data, process_blockLeng, outbuf, nRetOutLeng );
			
			cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);
			
			System.arraycopy(cdata, 0, pbszCipherText, j, nRetOutLeng[0]);
			
			j += nRetOutLeng[0];
		}
		
		remainleng = PLAINTEXT_LENGTH % process_blockLeng;
		if(remainleng == 0)
		{
			remainleng = process_blockLeng;
		}
		System.arraycopy(pbData2, j, newpbszPlainText, 0, remainleng);
		data = chartoint32_for_SEED_CBC(newpbszPlainText, remainleng);
		SEED_CBC_Process( info, data, remainleng, outbuf, nRetOutLeng);
		cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);
		System.arraycopy(cdata, 0, pbszCipherText, j, nRetOutLeng[0]);
		j += nRetOutLeng[0];		
		
		SEED_CBC_Close( info, outbuf, 0, nPaddingLeng );		
		cdata = int32tochar_for_SEED_CBC(outbuf, nPaddingLeng[0]);		
		System.arraycopy(cdata, 0, pbszCipherText, j, nPaddingLeng[0]);
		

		
		
	    
	    System.out.print("\n\nIV\t\t\t\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&bszIV[i])+" ");
	    System.out.print("\n");
	    
		System.out.print("Ciphertext(SEED_CBC_Encrypt)\t: ");
	    for (int i=0; i<32; i++)
	    	System.out.print(Integer.toHexString(0xff&pbszCipherText[i])+" ");
	    System.out.print("\n");
	    
   
	    	    
		data = null;
		cdata = null;
		outbuf = null;
		
		
		
		
		
		/**
		 * 복호화
		 */
		
	    // 복호화
	    
	    info = new KISA_SEED_INFO();
	    CIPHERTEXT_LENGTH = 32;
	    
	    pbszCipherText_offset = 0;
    
	    
	    message = new byte[CIPHERTEXT_LENGTH];
		System.arraycopy(pbszCipherText, pbszCipherText_offset, message, 0, CIPHERTEXT_LENGTH);
		
		nCipherTextLen = message.length;
		
		if( (nCipherTextLen%BLOCK_SIZE_SEED) != 0 )
		{
			System.out.print("Decryption_FAIL! \n\n");	
		}
		


		SEED_CBC_init( info, KISA_ENC_DEC.KISA_DECRYPT, pbUserKey, bszIV );
		
		process_blockLeng = BLOCK_SIZE_SEED * 2;

		outbuf = new int[process_blockLeng/4];
		
		newpbszCipherText = new byte[nCipherTextLen];
		pbszPlainText = new byte[nCipherTextLen];
		
		
		for(j=0; j<nCipherTextLen - process_blockLeng; )
		{
			System.arraycopy(message, j, newpbszCipherText, 0, process_blockLeng);
			data = chartoint32_for_SEED_CBC(newpbszCipherText, process_blockLeng);	
			SEED_CBC_Process( info, data, process_blockLeng, outbuf, nRetOutLeng );			
			cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);			
			System.arraycopy(cdata, 0, pbszPlainText, j, nRetOutLeng[0]);			
			j += nRetOutLeng[0];
		}
		
		remainleng =  nCipherTextLen%process_blockLeng;
		if(remainleng == 0)
		{
			remainleng = process_blockLeng;
		}
		System.arraycopy(message, j, newpbszCipherText, 0, remainleng);
		data = chartoint32_for_SEED_CBC(newpbszCipherText, remainleng);	
		SEED_CBC_Process( info, data, remainleng, outbuf, nRetOutLeng );			
		cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);			
		System.arraycopy(cdata, 0, pbszPlainText, j, nRetOutLeng[0]);			
		j += nRetOutLeng[0];
		

		
		if(SEED_CBC_Close( info, outbuf, (nRetOutLeng[0]), nPaddingLeng ) == 1)
		{
			cdata = int32tochar_for_SEED_CBC( outbuf, remainleng-nPaddingLeng[0] );
			
			byte[] newpbszPlainTexts = new byte[remainleng-nPaddingLeng[0]];
						
			Common.arraycopy(newpbszPlainTexts, cdata, remainleng-nPaddingLeng[0]);
			
			int message_length = remainleng-nPaddingLeng[0];
			
			result = new byte[message_length];
			System.arraycopy(newpbszPlainTexts, 0, result, 0, message_length);
			
			data = null;
			cdata = null;
			outbuf = null;

		}
		else
		{
			System.out.print("DECRYPT FAIL! ");
		}
	    
	
	    
	    
	    System.out.print("Plaintext(SEED_CBC_Decrypt 1)\t: ");
	    for (int i=0; i<PLAINTEXT_LENGTH; i++)
	    	System.out.print(Integer.toHexString(0xff&result[i])+" ");
	    System.out.print("\n\n");
	    
		data = null;
		cdata = null;
		outbuf = null;		
		
		pbszCipherText = null;
		result = null;
		
		
		
		
		
	    /*******************************************************************************************************
	     * 네번째 t.v
	     */    
	    
	    PLAINTEXT_LENGTH = 18;
	    

		nPlainTextPadding = BLOCK_SIZE_SEED - (PLAINTEXT_LENGTH % BLOCK_SIZE_SEED);
		newpbszPlainText = new byte[PLAINTEXT_LENGTH+nPlainTextPadding];
		Common.arraycopy(newpbszPlainText, pbData3, PLAINTEXT_LENGTH);		
		
		
		pbszCipherText = new byte[newpbszPlainText.length];			
		

		SEED_CBC_init( info, KISA_ENC_DEC.KISA_ENCRYPT, pbUserKey, bszIV );
		
		process_blockLeng = BLOCK_SIZE_SEED * 2;								//한번에 처리할 BLOCK
		

		outbuf = new int[process_blockLeng/4];
		pbszPlainText = new byte[process_blockLeng];
		
		for(j=0; j<PLAINTEXT_LENGTH-process_blockLeng; )
		{			
			System.arraycopy(pbData3, j, newpbszPlainText, 0, process_blockLeng);
			data = chartoint32_for_SEED_CBC(newpbszPlainText, process_blockLeng);
			
			SEED_CBC_Process( info, data, process_blockLeng, outbuf, nRetOutLeng );
			
			cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);
			
			System.arraycopy(cdata, 0, pbszCipherText, j, nRetOutLeng[0]);
			
			j += nRetOutLeng[0];
		}
		
		remainleng = PLAINTEXT_LENGTH % process_blockLeng;
		if(remainleng == 0)
		{
			remainleng = process_blockLeng;
		}
		System.arraycopy(pbData3, j, newpbszPlainText, 0, remainleng);
		data = chartoint32_for_SEED_CBC(newpbszPlainText, remainleng);
		SEED_CBC_Process( info, data, remainleng, outbuf, nRetOutLeng);
		cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);
		System.arraycopy(cdata, 0, pbszCipherText, j, nRetOutLeng[0]);
		j += nRetOutLeng[0];		
		
		SEED_CBC_Close( info, outbuf, 0, nPaddingLeng );		
		cdata = int32tochar_for_SEED_CBC(outbuf, nPaddingLeng[0]);		
		System.arraycopy(cdata, 0, pbszCipherText, j, nPaddingLeng[0]);
		

		
		
	    
	    System.out.print("\n\nIV\t\t\t\t: ");
	    for (int i=0; i<16; i++)
	    	System.out.print(Integer.toHexString(0xff&bszIV[i])+" ");
	    System.out.print("\n");
	    
		System.out.print("Ciphertext(SEED_CBC_Encrypt)\t: ");
	    for (int i=0; i<32; i++)
	    	System.out.print(Integer.toHexString(0xff&pbszCipherText[i])+" ");
	    System.out.print("\n");
	    
   
	    	    
		data = null;
		cdata = null;
		outbuf = null;
		
		
		
		
		
		/**
		 * 복호화
		 */
		
	    // 복호화
	    
	    info = new KISA_SEED_INFO();
	    CIPHERTEXT_LENGTH = 32;
	    
	    pbszCipherText_offset = 0;
    
	    
	    message = new byte[CIPHERTEXT_LENGTH];
		System.arraycopy(pbszCipherText, pbszCipherText_offset, message, 0, CIPHERTEXT_LENGTH);
		
		nCipherTextLen = message.length;
		
		if( (nCipherTextLen%BLOCK_SIZE_SEED) != 0 )
		{
			System.out.print("Decryption_FAIL! \n\n");	
		}
		



		SEED_CBC_init( info, KISA_ENC_DEC.KISA_DECRYPT, pbUserKey, bszIV );
		
		process_blockLeng = BLOCK_SIZE_SEED * 2;

		outbuf = new int[process_blockLeng/4];
		
		newpbszCipherText = new byte[nCipherTextLen];
		pbszPlainText = new byte[nCipherTextLen];
		
		
		for(j=0; j<nCipherTextLen - process_blockLeng; )
		{
			System.arraycopy(message, j, newpbszCipherText, 0, process_blockLeng);
			data = chartoint32_for_SEED_CBC(newpbszCipherText, process_blockLeng);	
			SEED_CBC_Process( info, data, process_blockLeng, outbuf, nRetOutLeng );			
			cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);			
			System.arraycopy(cdata, 0, pbszPlainText, j, nRetOutLeng[0]);			
			j += nRetOutLeng[0];
		}
		
		remainleng =  nCipherTextLen%process_blockLeng;
		if(remainleng == 0)
		{
			remainleng = process_blockLeng;
		}
		System.arraycopy(message, j, newpbszCipherText, 0, remainleng);
		data = chartoint32_for_SEED_CBC(newpbszCipherText, remainleng);	
		SEED_CBC_Process( info, data, remainleng, outbuf, nRetOutLeng );			
		cdata = int32tochar_for_SEED_CBC(outbuf, nRetOutLeng[0]);			
		System.arraycopy(cdata, 0, pbszPlainText, j, nRetOutLeng[0]);			
		j += nRetOutLeng[0];
		

		
		if(SEED_CBC_Close( info, outbuf, (nRetOutLeng[0]), nPaddingLeng ) == 1)
		{
			cdata = int32tochar_for_SEED_CBC( outbuf, remainleng-nPaddingLeng[0] );
			
			byte[] newpbszPlainTexts = new byte[remainleng-nPaddingLeng[0]];
						
			Common.arraycopy(newpbszPlainTexts, cdata, remainleng-nPaddingLeng[0]);
			
			int message_length = remainleng-nPaddingLeng[0];
			
			result = new byte[message_length];
			System.arraycopy(newpbszPlainTexts, 0, result, 0, message_length);
			
			data = null;
			cdata = null;
			outbuf = null;

		}
		else
		{
			System.out.print("DECRYPT FAIL! ");
		}
	    
	
	    
	    
	    System.out.print("Plaintext(SEED_CBC_Decrypt 1)\t: ");
	    for (int i=0; i<PLAINTEXT_LENGTH; i++)
	    	System.out.print(Integer.toHexString(0xff&result[i])+" ");
	    System.out.print("\n\n");
	    
		data = null;
		cdata = null;
		outbuf = null;			
		
		
		pbszCipherText = null;
		result = null;
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	    
	    
	    


	}	
	
	
}










