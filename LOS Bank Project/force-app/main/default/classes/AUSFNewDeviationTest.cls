@isTest
public class AUSFNewDeviationTest {
    @testSetup static void setup() {
         Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
        ),true);
        
        Deviation__c devRec = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Actual_Value__c  = 123,
            Department__c   = 'test department',
            Details__c  = 'test details',
            Loan_Application__c = loanAppl.Id
        ),true);
        
        Manual_Deviation_Master__c  manDevRec = (Manual_Deviation_Master__c)TestFactory.createSObject(new Manual_Deviation_Master__c(
            Department__c = 'Credit',
            Product__c  = 'Four Wheeler',
             Remarks__c = 'test remarks',
             Deviation_Level__c  = 'S3',
            Deviation_Description__c  = 'Duplicate RC'
        ),true);
    }
       @IsTest
    static void getUserDetailsTest() {
        User userRec = [SELECT Id, Profile.Name, Ops_User_Type__c FROM User WHERE Id=:UserInfo.getUserId()];
        User u = AUSFNewDeviation.getUserDetails();
        system.assertEquals(userRec.Profile.Name,u.Profile.Name);
    }    
     @IsTest
    static void getDeviationRecordsTest(){
        Deviation__c devRec = [SELECT Id,Department__c from Deviation__c];
        Test.startTest();
        Deviation__c res = AUSFNewDeviation.getDeviationRecords(devRec.Id);
        system.assertEquals(devRec.Department__c, res.Department__c);
        Test.stopTest();
    }
     @IsTest
    static void getDeviationRecordsExceptionTest(){
        Test.startTest();
        try{
            Deviation__c res = AUSFNewDeviation.getDeviationRecords(NULL);
        }
        catch(Exception e){
            
        }
        Test.stopTest();
    }
       @IsTest
    static void getRecordsTest(){
        Manual_Deviation_Master__c manDevRec = [SELECT Id,Product__c,Department__c from Manual_Deviation_Master__c];
        Test.startTest();
        Loan_Application__c loanAppl = [Select id from Loan_Application__c limit 1];
        List<Manual_Deviation_Master__c> res = AUSFNewDeviation.getRecords(loanAppl.Id,manDevRec.Department__c);
        system.assertEquals(manDevRec.Product__c, res[0].Product__c);
        Test.stopTest();
    }
    
    @IsTest
    static void getRecordsTest2(){
        Manual_Deviation_Master__c manDevRec = [SELECT Id,Product__c,Department__c from Manual_Deviation_Master__c];
        Test.startTest();
        Loan_Application__c loanAppl = [Select id from Loan_Application__c limit 1];
        List<Manual_Deviation_Master__c> res = AUSFNewDeviation.getRecords(loanAppl.Id,manDevRec.Department__c);
        system.assertEquals(manDevRec.Product__c, res[0].Product__c);
        Test.stopTest();
    }
    
}