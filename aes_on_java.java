import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;

public class AESExample{

    // Encrypt the input text using AES
    public static String encrypt( String plainText, SecretKey secretKey ) throws Exception{
        Cipher cipher = Cipher.getInstance( "AES" );
        cipher.init( Cipher.ENCRYPT_MODE, secretKey );
        byte[] encryptedBytes = cipher.doFinal( plainText.getBytes() );
        return Base64.getEncoder().encodeToString( encryptedBytes );
    }

    // Decrypt the input text using AES
    public static String decrypt( String encryptedText, SecretKey secretKey ) throws Exception{
        Cipher cipher = Cipher.getInstance( "AES" );
        cipher.init( Cipher.DECRYPT_MODE, secretKey );
        byte[] decryptedBytes = cipher.doFinal( Base64.getDecoder().decode( encryptedText ) );
        return new String( decryptedBytes );
    }

    // Generate an AES Secret Key
    public static SecretKey generateKey( int keySize ) throws Exception{
        KeyGenerator keyGenerator = KeyGenerator.getInstance( "AES" );
        keyGenerator.init( keySize );
        return keyGenerator.generateKey();
    }

    public static void main( String[] args ){
        try{
            String originalText = "Hello, AES Encryption!";
            
            // Generate a 256-bit AES key
            SecretKey secretKey = generateKey( 256 );

            // Encrypt the text
            String encryptedText = encrypt( originalText, secretKey );
            System.out.println( "Encrypted: " + encryptedText );

            // Decrypt the text
            String decryptedText = decrypt( encryptedText, secretKey );
            System.out.println( "Decrypted: " + decryptedText );
        }catch( Exception e ){
            e.printStackTrace();
        }
    }
}


// Encrypted: OX8+4Qrrh3r1+h0WL8VzWA==
// Decrypted: Hello, AES Encryption!
