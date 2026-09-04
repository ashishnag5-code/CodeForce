@IsTest
public class MySQLCrypto2Test {
    @IsTest
    static void testEncrypt() {
        // Test case 1: Valid encryption
        Blob privateKey = Blob.valueOf('1234567890123456');
        Blob plainText = Blob.valueOf('Hello, World!');
        
        Test.startTest();
        Blob cipherText = MySQLCrypto2.encrypt('AES128', privateKey, plainText);
        // Test case 2: Unsupported algorithm
        try {
            Blob unsupportedCipherText = MySQLCrypto2.encrypt('AES256', privateKey, plainText);
            System.assert(false, 'Expected MySQLCryptoException to be thrown');
        } catch (MySQLCrypto2.MySQLCryptoException e) {
            // Expected exception
            System.assert(e.getMessage().contains('Algorithm AES256 not supported'), 'message=' + e.getMessage());
        }
        Test.stopTest();
    }
}