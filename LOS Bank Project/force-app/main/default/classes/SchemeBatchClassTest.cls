@isTest
public with sharing class SchemeBatchClassTest {
    
    @TestSetup
    static void makeData(){
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Scheme1'
        ),true);
        start = Date.newInstance(1999, 12, 1);
        endDate = Date.newInstance(2000, 12, 31);
        Scheme_Master__c scheme2 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Scheme2'
        ),true);
        start = Date.newInstance(2022, 11, 31);
        endDate = Date.newInstance(2050, 12, 1);
        Scheme_Master__c scheme3 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Scheme3'
        ),true);
        
    }

    @isTest
    public static void testSchemeBatchMethod(){
        List<Scheme_Master__c> newlist = [Select Id, START_DATE__c, EXPIRY_DATE__c, Is_InActive__c From Scheme_Master__c];
        //String sch = '0 0 0 15 * ? 2023'; 
         String sch = '0 0 0 * * ?';

        Test.startTest();
        String jobId = System.schedule('isInactive', sch, new ScheduleSchemeBatch()); 
        Test.stopTest();        
    }
}