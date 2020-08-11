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

        KISA_SEED_GCM seed_gcm = new KISA_SEED_GCM();
    
        int keyLen = 0, inLen = 0, out1Len = 0, out2Len = 0, nonceLen = 0, aadLen = 0, macLen = 16;

        print_title("Test SEED GCM - 1");

        keyLen = asc2hex(key, "1032F990B76B0686C0CF9BBB80AEE08C");
        nonceLen = asc2hex(nonce, "75E2534A34F65F85A28E318A");
        aadLen = asc2hex(aad, "9DEA72038744675F026877F23C1F6056F77700BA38ADB2E33F50DB71BCA4C06440459BDEF20CED2A833615FE64C322FD361DE68082FA4B96AA83EB4A1FB6DA24D509C6F2F45043C7D1E060451CF57E185B5162C39626889F5436BA20C739E25B447F1DC5F6D6103ED2AE7F4ECD7B1BAE4D5B9C0ADEF9100527B1737E1CF57F11");
        inLen = asc2hex(in, "6702C72AA04D49BDD4269D672A6C369AD9C72CDCDF8D92CBF6E2045EC4247F6D52867574BFFA2194365519DA1DAD22C48F0647010D2E2D7970E6A18D224273A08E5387D6D503291BC33FA168015C07418CB35983658FCB5C8B4A5E9B26B2B42A05B123D84A2E085C642E5E973E3F8F1AB61689E85177157D2D55640F373BEB13");

    	macLen = 12;
    
    	out1Len = seed_gcm.SEED_GCM_Encryption(out1, in, inLen, macLen, nonce, nonceLen, aad, aadLen, key);
        print_result("SEED GCM Encryption", out1Len);

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("nonce", nonce, nonceLen);
        print_hex("aad", aad, aadLen);
        print_hex("out1", out1, out1Len);
    
        out2Len = seed_gcm.SEED_GCM_Decryption(out2, out1, out1Len, macLen, nonce, nonceLen, aad, aadLen, key);
        print_result("SEED GCM Decryption", out2Len);

        print_hex("in", out1, out1Len);
        print_hex("out2", out2, out2Len);

        print_title("Test SEED CCM - 2");

        keyLen = asc2hex(key, "11B13AD70556009DA9D0A8A8C11E4199");
    	nonceLen = asc2hex(nonce, "FC80175A2ADF87A8A96911CF207CAFB5");
    	aadLen = asc2hex(aad, "");
    	inLen = asc2hex(in, "");
    
        macLen = 16;
    
        out1Len = seed_gcm.SEED_GCM_Encryption(out1, in, inLen, macLen, nonce, nonceLen, aad, aadLen, key);
        print_result("SEED GCM Encryption", out1Len);

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("nonce", nonce, nonceLen);
        print_hex("aad", aad, aadLen);
        print_hex("out1", out1, out1Len);
    
        out2Len = seed_gcm.SEED_GCM_Decryption(out2, out1, out1Len, macLen, nonce, nonceLen, aad, aadLen, key);
        print_result("SEED GCM Decryption", out2Len);

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