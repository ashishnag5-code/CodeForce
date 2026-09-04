@isTest
public class LOSMobileOtpHandlerTest{
@testSetup 
    static void setup() {
            Integration_Master__c inMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Adhar OCR',
            End_Point_URL__c='https://service.aubank.in/SFDCKarzaPinCodeService/getDistance',
            Encryption_Key__c='testEncrypt12345',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
            ),true);  
    }
    @isTest
    static void TestM1(){
        Map < String, Object > reqParam = new Map < String, Object >();
        reqParam.put('MobileNumber', '9910287108');
        reqParam.put('otp','4576');
        
        Blob data = Blob.valueOf('XYZ DAt');
        Blob cryptoValue = Crypto.generateAesKey(128);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoValue, data);
        reqParam.put('encryptionKey','0xasdfasdfasdfas0xasdfasdfasdfas');
        reqParam.put('iv','0000087oiu7yu8i9');
        LOSMobileOtpHandler.generateRequest(reqParam);
        
        LOSMobileOtpHandler.generateOTPWrapper otpObj = new LOSMobileOtpHandler.generateOTPWrapper('9910287188', 'valid', '4', '10', 'ddssdf' , 'rre', 'erer' , 'wrwerew' , '9943');
    }
}