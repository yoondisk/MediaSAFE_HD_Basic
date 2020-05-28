public class main
{
    public static void main(String[] args)
    {
        byte[] key = new byte[160];
        byte[] in = new byte[200];
        byte[] mac = new byte[160];

        KISA_SEED_CMAC seed_cmac = new KISA_SEED_CMAC();
    
        int keyLen = 0, inLen = 0, macLen = 16;

        print_title("Test SEED CMAC - 1");

        keyLen = asc2hex(key, "CAEE9E66F060D74BDA1C7636F765FFB5");
    	inLen = asc2hex(in, "");

    	macLen = 8;
    
    	print_result("SEED Generate_CMAC", seed_cmac.SEED_Generate_CMAC(mac, macLen, in, inLen, key));

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("mac", mac, macLen);
    
        print_result("SEED Verify_CMAC", seed_cmac.SEED_Verify_CMAC(mac, macLen, in, inLen, key));
        
        print_title("Test SEED CMAC - 2");

        keyLen = asc2hex(key, "8F971685675E0FEF6AD570B49EF425A4");
    	inLen = asc2hex(in, "E13197128B9873874F1EADB86233C4B6DF96");

    	macLen = 10;
    
    	print_result("SEED Generate_CMAC", seed_cmac.SEED_Generate_CMAC(mac, macLen, in, inLen, key));

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("mac", mac, macLen);
    
        print_result("SEED Verify_CMAC", seed_cmac.SEED_Verify_CMAC(mac, macLen, in, inLen, key));
        
        print_title("Test SEED CMAC - 3");

        keyLen = asc2hex(key, "06CCB9A76C60EB86B12712DE826C5BF8");
    	inLen = asc2hex(in, "");

    	macLen = 11;
    
    	print_result("SEED Generate_CMAC", seed_cmac.SEED_Generate_CMAC(mac, macLen, in, inLen, key));

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("mac", mac, macLen);
    
        print_result("SEED Verify_CMAC", seed_cmac.SEED_Verify_CMAC(mac, macLen, in, inLen, key));
        
        print_title("Test SEED CMAC - 4");

        keyLen = asc2hex(key, "3549E0153A6D23838BEA96A9D70A6DBF");
    	inLen = asc2hex(in, "0B502FFB0E5D0CA0AF107037DCF1D81C14D0E53D1EA9AE1FFCCB5B221B39F005CC5166ACF8AB00210E44DCDA41DCC93AF19C5859");

    	macLen = 12;
    
    	print_result("SEED Generate_CMAC", seed_cmac.SEED_Generate_CMAC(mac, macLen, in, inLen, key));

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("mac", mac, macLen);
    
        print_result("SEED Verify_CMAC", seed_cmac.SEED_Verify_CMAC(mac, macLen, in, inLen, key));
        
        print_title("Test SEED CMAC - 5");

        keyLen = asc2hex(key, "F5E73BF2243CD9837484A096491EC0A7");
    	inLen = asc2hex(in, "FA9DD5FB8D78C4ECC202E581549D68417B2BF149B5C6869DC6B1ABBCFD8ECB77BAD1DA022D74394C60EDDA8C785DA41C380A198BC60F36EEB2529A7634B7EB48B5937688916415B71CBF5640E389D94D346AFADFE07FB01E3F4FB5EE7501E8C2F4CCEFB542AE20D7FD61A2C41C8BCF7C7735DD6E8A7EBED67590444948D4898E7E628EB0C7BC22510BBB0641ABC94E500A510A604C7426BE5DFE8FB2359897545B3F9BA2A8F4E3D04EB5C9DF19AD1E71F4A8C9DCAEC9B17DFE7FDE4FC5B5");

    	macLen = 13;
    
    	print_result("SEED Generate_CMAC", seed_cmac.SEED_Generate_CMAC(mac, macLen, in, inLen, key));

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("mac", mac, macLen);
    
        print_result("SEED Verify_CMAC", seed_cmac.SEED_Verify_CMAC(mac, macLen, in, inLen, key));
        
        print_title("Test SEED CMAC - 6");

        keyLen = asc2hex(key, "AB0600A3F9673E08AEE04AB764B3350E");
    	inLen = asc2hex(in, "534698D575BDD570E9CE9F5996D1BDCE10170AC7BF7DC12B3E41F7430114696F3B707818FE2B72E5A44D13326F1F");

    	macLen = 14;
    
    	print_result("SEED Generate_CMAC", seed_cmac.SEED_Generate_CMAC(mac, macLen, in, inLen, key));

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("mac", mac, macLen);
    
        print_result("SEED Verify_CMAC", seed_cmac.SEED_Verify_CMAC(mac, macLen, in, inLen, key));
        
        print_title("Test SEED CMAC - 7");

        keyLen = asc2hex(key, "C1098544DE3C907F5F683F1AD66850EB");
    	inLen = asc2hex(in, "97CF602CBED80C17739C57B36C884BEDB40DE4EAAB99299C4FC79C93B9D3D416EA506973C81D1093649507D17E06B40C4B6489FB763F2AC164F3D2C2BC1FF3B427581CF9541E202C400E75FAB45ADA330F773C204515DB182854A94EE635F2EDD34E426769C384098D7167D4146C068886ACC701220383C62252E8E040FD1CE8789CA36410F48354D625A607A9247F333A6CF1");

    	macLen = 15;
    
    	print_result("SEED Generate_CMAC", seed_cmac.SEED_Generate_CMAC(mac, macLen, in, inLen, key));

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("mac", mac, macLen);
    
        print_result("SEED Verify_CMAC", seed_cmac.SEED_Verify_CMAC(mac, macLen, in, inLen, key));
        
        print_title("Test SEED CMAC - 8");

        keyLen = asc2hex(key, "B928C98B0837E887452C420E3607E7B9");
    	inLen = asc2hex(in, "");

    	macLen = 16;
    
    	print_result("SEED Generate_CMAC", seed_cmac.SEED_Generate_CMAC(mac, macLen, in, inLen, key));

        print_hex("key", key, keyLen);
        print_hex("in", in, inLen);
        print_hex("mac", mac, macLen);
    
        print_result("SEED Verify_CMAC", seed_cmac.SEED_Verify_CMAC(mac, macLen, in, inLen, key));
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