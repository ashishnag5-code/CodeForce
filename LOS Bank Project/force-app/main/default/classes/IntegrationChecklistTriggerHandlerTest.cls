@IsTest
private class IntegrationChecklistTriggerHandlerTest {
    @IsTest
    static void testAfterUpdate() {
        
        List<Integration_Checklist__c> records = new List<Integration_Checklist__c>();
        for (Integer i = 0; i < 5; i++) {
            records.add(new Integration_Checklist__c(Missing_Pre_requisites__c = 'Test Pre-requisites' + i));
        }
        
        
        
        insert records;
        
        for (Integration_Checklist__c record : records) {
            record.Missing_Pre_requisites__c = 'Updated Pre-requisites';
        }
        update records;
        
       
        List<Integration_Checklist__c> updatedRecords = [SELECT Id, Missing_Pre_requisites__c, LastModifiedDate FROM Integration_Checklist__c];
        System.assertEquals(5, updatedRecords.size(), 'Number of records should match');
        for (Integration_Checklist__c record : updatedRecords) {
            System.assertNotEquals(null, record.LastModifiedDate, 'Last Modified Date should not be null');
            System.assertEquals('Updated Pre-requisites', record.Missing_Pre_requisites__c, 'Name should be updated');
        }
    }
    
    @IsTest
    static void testAfterInsert() {
        
        List<Integration_Checklist__c> records = new List<Integration_Checklist__c>();
        for (Integer i = 0; i < 3; i++) {
            records.add(new Integration_Checklist__c(Missing_Pre_requisites__c = 'Test Checklist ' + i));
        }
        
        
        Test.startTest();
        insert records;
        Test.stopTest();
        
        
        List<Integration_Checklist__c> insertedRecords = [SELECT Id, Name FROM Integration_Checklist__c];
        System.assertEquals(3, insertedRecords.size(), 'Number of records should match');
        for (Integration_Checklist__c record : insertedRecords) {
            
            System.assertNotEquals(null, record.Id, 'Record should have an Id');
        }
    }
}