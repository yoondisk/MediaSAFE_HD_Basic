public class main
{
    public static void main(String[] args)
    {
        byte[] key = new byte[160];
        byte[] in = new byte[160];
        byte[] out1 = new byte[160];
        byte[] out2 = new byte[160];
        byte[] nonce = new byte[160];
        byte[] aad = new byte[160];

        KISA_SEED_CCM seed_ccm = new KISA_SEED_CCM();
    
        int keyLen = 0, inLen = 0, out1Len = 0, out2Len = 0, nonceLen = 0, aadLen = 0, macLen = 16;

        print_title("Test SEED CCM - 1");

        keyLen = asc2hex(key, "FAB5E5DE4350E5A4E0F1DF63E46A2AA0");
    	nonceLen = asc2hex(nonce, "0C911408A595DF62A99209C2");
    	aadLen = asc2hex(aad, "2C62D1FFF6B7F6687266C2B3C706473644BAE95A014B1C4CC37A6FF52194CA2D");
    	inLen = asc2hex(in, "E546F32BB5B35740F3C408C6E1BF0253091CB232DC94B913997AED01704EA095E89026697E");
    
        macLen = 16;
    
        out1Len = seed_ccm.SEED_CCM_Encryption(out1, in, inLen, macLen, nonce, nonceLen, aad, aadLen, key);
        print_result("SEED CCM Encryption", out1Len);

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("nonce", nonce, nonceLen);
        print_hex("aad", aad, aadLen);
        print_hex("out1", out1, out1Len);
    
        out2Len = seed_ccm.SEED_CCM_Decryption(out2, out1, out1Len, macLen, nonce, nonceLen, aad, aadLen, key);
        print_result("SEED CCM Decryption", out2Len);

        print_hex("in", out1, out1Len);
        print_hex("out2", out2, out2Len);

        print_title("Test SEED CCM - 2");

        keyLen = asc2hex(key, "002B30E20CCC65E95DAE1FDF2411C0D5");
    	nonceLen = asc2hex(nonce, "188CC310D2A428");
    	aadLen = asc2hex(aad, "5CE917AF1AF4732CC220FC022979650E");
    	inLen = asc2hex(in, "559869FF1ADDCC7261CDC9CB40D67626");
    
        macLen = 4;
    
        out1Len = seed_ccm.SEED_CCM_Encryption(out1, in, inLen, macLen, nonce, nonceLen, aad, aadLen, key);
        print_result("SEED CCM Encryption", out1Len);

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("nonce", nonce, nonceLen);
        print_hex("aad", aad, aadLen);
        print_hex("out1", out1, out1Len);
    
        out2Len = seed_ccm.SEED_CCM_Decryption(out2, out1, out1Len, macLen, nonce, nonceLen, aad, aadLen, key);
        print_result("SEED CCM Decryption", out2Len);

        print_hex("in", out1, out1Len);
        print_hex("out2", out2, out2Len);
        
    }

    private static int asc2hex(byte[] dst, String src)
    {
        byte temp = 0x00, hex = 0;
        int i = 0;
    
        for (i = 0; i < src.length(); i++)
        {
            temp = 0x00;
            hex = (byte)src.charAt(i);
    
            if ((hex >= 0x30) && (hex <= 0x39))
                temp = (byte)(hex - 0x30);
            else if ((hex >= 0x41) && (hex <= 0x5A))
                temp = (byte)(hex - 0x41 + 10);
            else if ((hex >= 0x61) && (hex <= 0x7A))
                temp = (byte)(hex - 0x61 + 10);
            else
                temp = 0x00;
            
            if ((i & 1) == 1)
                dst[i >> 1] ^= temp & 0x0F;
            else
                dst[i >> 1] = (byte)(temp << 4);
        }
    
        return ((i + 1) / 2);
    }

    private static void print_hex(String valName, byte[] data, int dataLen)
    {
        int i = 0;

        System.out.printf("%s [%dbyte] :", valName, dataLen);
        for (i = 0; i < dataLen; i++)
        {
            if ((i & 0x0F) == 0)
                System.out.println("");

            System.out.printf(" %02X", data[i]);
        }
        System.out.println("");
    }

    private static void print_title(String title)
    {
        System.out.println("================================================");
        System.out.println("  " + title);
        System.out.println("================================================");
    }

    private static void print_result(String func, int ret)
    {
        if (ret == 1)
        {
            System.out.println("================================================");
            System.out.println("  " + func + " Failure!");
            System.out.println("================================================");

            System.exit(0);
        }
        else
        {
            System.out.println("================================================");
            System.out.println("  " + func + " Success!");
            System.out.println("================================================");
        }
    }
}