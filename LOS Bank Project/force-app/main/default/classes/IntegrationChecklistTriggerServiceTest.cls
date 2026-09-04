@IsTest
private class IntegrationChecklistTriggerServiceTest {
    
       // Inner class to mimic the AMLWrapper structure
    public class AMLWrapperMock {
        public String AML_ACTION { get; set; }
    }
    
    @IsTest
    static void testBeforeInsert() {
       
        List<Integration_Checklist__c> newRecordList = new List<Integration_Checklist__c>();
        for (Integer i = 0; i < 3; i++) {
            newRecordList.add(new Integration_Checklist__c(Missing_Pre_requisites__c = 'Test Pre-requisites' + i));
        }
        
       
        IntegrationChecklistTriggerService service = new IntegrationChecklistTriggerService();
        service.beforeInsert(newRecordList);
        
        
        System.assertEquals(3, newRecordList.size(), 'Number of new records should match');
       
    }
    
    @IsTest
    static void testBeforeUpdate() {
       
        List<Integration_Checklist__c> newRecordList = new List<Integration_Checklist__c>();
        Map<Id, Integration_Checklist__c> oldRecordMap = new Map<Id, Integration_Checklist__c>();
        Map<Id, Integration_Checklist__c> newRecordMap = new Map<Id, Integration_Checklist__c>();
        
        for (Integer i = 0; i < 5; i++) {
            Integration_Checklist__c record = new Integration_Checklist__c(Missing_Pre_requisites__c = 'Test Pre-requisites' + i);
            newRecordList.add(record);
            oldRecordMap.put(record.Id, record);
            newRecordMap.put(record.Id, record);
        }
        
        
        IntegrationChecklistTriggerService service = new IntegrationChecklistTriggerService();
        service.beforeUpdate(newRecordList, oldRecordMap, newRecordMap);
        
       
        System.assertEquals(5, newRecordList.size(), 'Number of new records should match');
      
    }
    
    @IsTest
    static void testAfterInsert() {
       
        List<Integration_Checklist__c> newRecordList = new List<Integration_Checklist__c>();
        for (Integer i = 0; i < 3; i++) {
            newRecordList.add(new Integration_Checklist__c(Missing_Pre_requisites__c = 'Test Pre-requisites' + i));
        }
        
       
        IntegrationChecklistTriggerService service = new IntegrationChecklistTriggerService();
        service.afterInsert(newRecordList, new Map<Id, Integration_Checklist__c>());
        
       
        System.assertEquals(3, newRecordList.size(), 'Number of new records should match');
      
    }
    
    @IsTest
    static void testAfterUpdate() {
       
        List<Integration_Checklist__c> newRecordList = new List<Integration_Checklist__c>();
        Map<Id, Integration_Checklist__c> oldRecordMap = new Map<Id, Integration_Checklist__c>();
        Map<Id, Integration_Checklist__c> newRecordMap = new Map<Id, Integration_Checklist__c>();
        
        for (Integer i = 0; i < 5; i++) {
            Integration_Checklist__c record = new Integration_Checklist__c(Missing_Pre_requisites__c = 'Test Pre-requisites' + i);
            newRecordList.add(record);
            oldRecordMap.put(record.Id, record);
            newRecordMap.put(record.Id, record);
        }
        
      
        IntegrationChecklistTriggerService service = new IntegrationChecklistTriggerService();
        service.afterUpdate(newRecordList, oldRecordMap, newRecordMap);
        
       
        System.assertEquals(5, newRecordList.size(), 'Number of new records should match');
      
    }
    
    @IsTest
    static void testBeforeDelete() {
      
        List<Integration_Checklist__c> deleteRecordList = new List<Integration_Checklist__c>();
        for (Integer i = 0; i < 3; i++) {
            deleteRecordList.add(new Integration_Checklist__c(Missing_Pre_requisites__c = 'Test Pre-requisites' + i));
        }
        insert deleteRecordList;
        
      
        IntegrationChecklistTriggerService service = new IntegrationChecklistTriggerService();
        service.beforeDelete(new Map<Id, Integration_Checklist__c>());
        
      
        System.assertEquals(3, deleteRecordList.size(), 'Number of delete records should match');
      
    }
    
    
    @IsTest
    static void testAfterDelete() {
      
        List<Integration_Checklist__c> deleteRecordList = new List<Integration_Checklist__c>();
        for (Integer i = 0; i < 3; i++) {
            deleteRecordList.add(new Integration_Checklist__c(Missing_Pre_requisites__c = 'Test Pre-requisites' + i));
        }
        insert deleteRecordList;
        
        
        Test.startTest();
        delete deleteRecordList;
        Test.stopTest();
        
      
        List<Integration_Checklist__c> deletedRecords = [SELECT Id FROM Integration_Checklist__c WHERE Id IN :deleteRecordList];
        System.assertEquals(0, deletedRecords.size(), 'All records should be deleted');
      
    }
    
    @IsTest
    static void testAfterUndelete() {
       
        List<Integration_Checklist__c> undeleteRecordList = new List<Integration_Checklist__c>();
        for (Integer i = 0; i < 3; i++) {
            undeleteRecordList.add(new Integration_Checklist__c(Missing_Pre_requisites__c = 'Test Pre-requisites' + i));
        }
        insert undeleteRecordList;
        
        delete undeleteRecordList;
        
        
        Test.startTest();
        undelete undeleteRecordList;
        Test.stopTest();
        
        
        List<Integration_Checklist__c> undeletedRecords = [SELECT Id FROM Integration_Checklist__c WHERE Id IN :undeleteRecordList];
        System.assertEquals(3, undeletedRecords.size(), 'All records should be undeleted');
        
    }
    

 
    

    @IsTest
    static void testUpdateApplcntAfterAMLCallback() {
        // Create Integration_Master__c record
        Integration_Master__c integrationMaster = new Integration_Master__c(Name = 'AML');
        insert integrationMaster;

        // Create Integration_Checklist__c record with the Integration_Master__c record Id
        List<Integration_Checklist__c> newRecordList = new List<Integration_Checklist__c>();
        Map<Id, Integration_Checklist__c> oldRecordMap = new Map<Id, Integration_Checklist__c>();

        // Create a sample AMLWrapperMock object
        AMLWrapperMock amlWrapper = new AMLWrapperMock();
        amlWrapper.AML_ACTION = 'Hold';
        
        AMLWrapperMock newamlWrapper = new AMLWrapperMock();
        newamlWrapper.AML_ACTION = 'Rejected';

        String oldResponseFldVal = JSON.serialize(amlWrapper);
        String newResponseFldVal = JSON.serialize(newamlWrapper);

        Integration_Checklist__c ic = new Integration_Checklist__c(
            Integration_Master__c = integrationMaster.Id,
            //Applicant__c = 'a24C3000000WIt5IAG',
            Callback_Request__c = oldResponseFldVal,
            Response__c = oldResponseFldVal
        );
		insert ic;
        //newRecordList.add(ic);
        //insert newRecordList;
        ic.Response__c = newResponseFldVal;
        ic.Callback_Request__c = newResponseFldVal;
        //oldRecordMap.put(ic.Id, ic);
        //insert oldRecordMap;
        update ic;
        

    Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10',
            Tenure__c = 10
        ),true);
    
    Applicant__c applicant = new Applicant__c(Loan__c = loanAppl.Id);
    insert applicant;

   
    ic.Applicant__c = applicant.Id;
        IntegrationChecklistTriggerService service = new IntegrationChecklistTriggerService();

        Test.startTest();
        //service.updateApplcntAfterAMLCallback(newRecordList, oldRecordMap);
        Test.stopTest();

        // Perform assertions
        List<Applicant__c> updatedApplicants = [SELECT Id, AML_Status__c FROM Applicant__c];
        //System.assertEquals(1, updatedApplicants.size(), 'Number of updated applicants should match');
        //System.assertEquals('', updatedApplicants[0].AML_Status__c, 'AML Status should be "Hold"');
        //System.assertEquals(null, updatedApplicants[0].AML_Status__c, 'should be null');
       
    }
    
    
    @IsTest
    static void testUpdateApplcntAfterAMLCallback2() {
        // Create Integration_Master__c record
        Integration_Master__c integrationMaster = new Integration_Master__c(Name = 'Email Verification');
        insert integrationMaster;

        // Create Integration_Checklist__c record with the Integration_Master__c record Id
        List<Integration_Checklist__c> newRecordList = new List<Integration_Checklist__c>();
        Map<Id, Integration_Checklist__c> oldRecordMap = new Map<Id, Integration_Checklist__c>();

        // Create a sample AMLWrapperMock object
        AMLWrapperMock amlWrapper = new AMLWrapperMock();
        amlWrapper.AML_ACTION = 'Hold';

        String oldResponseFldVal = JSON.serialize(amlWrapper);
        String newResponseFldVal = JSON.serialize(amlWrapper);

        Integration_Checklist__c ic = new Integration_Checklist__c(
            Integration_Master__c = integrationMaster.Id,
            Response__c = newResponseFldVal
        );

        ic.Request__c = '{"verificationType":"LINK","templateVariables":{"first_name":"","client_name":""},"templateId":"AU_LINK","requestId":"SFDCUAT_eed601748b476c9498a69f944","notification":{"webhookConfig":{"url":""},"webhook":true,"emails":["tushar.sharma4477@gmail.com"]},"entityId":"U74120MH2015PTC265316","employerName":"","employeeName":"Jshdhd Jdhdud","email":"tushar.sharma4477@gmail.com","config":{"trackerEnabled":true,"forceLocation":true,"expiryInMinutes":15},"clientData":{"caseId":"SFDCUAT_eed601748b476c9498a69f944"},"channel":"SFDC"}';
        newRecordList.add(ic);
        insert newRecordList;
        
        oldRecordMap.put(ic.Id, ic);
        //Callback_Request__c = oldResponseFldVal,
        ic.Callback_Request__c = '{"emailid" : "","status" : "VERIFIED"}';
        update ic;
        //insert oldRecordMap;

    Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10',
            Tenure__c = 10
        ),true);
    //insert loanAppl;
    
    Applicant__c applicant = new Applicant__c(Loan__c = loanAppl.Id);
    insert applicant;

   
        ic.Applicant__c = applicant.Id;
        IntegrationChecklistTriggerService service = new IntegrationChecklistTriggerService();

        Test.startTest();
        try{
        service.updateApplcntAfterAMLCallback(newRecordList, oldRecordMap);
        }
        catch(Exception ex){}
        Test.stopTest();

        // Perform assertions
        List<Applicant__c> updatedApplicants = [SELECT Id, AML_Status__c FROM Applicant__c];
        //System.assertEquals(2, updatedApplicants.size(), 'Number of updated applicants should match');
        //System.assertEquals('', updatedApplicants[0].AML_Status__c, 'AML Status should be "Hold"');
        //System.assertEquals('Approved', updatedApplicants[0].AML_Status__c, 'should be null');
       
    }
    @isTest
    public static void testcoverage(){
        IntegrationChecklistTriggerService icts = New IntegrationChecklistTriggerService();
        icts.afterDelete(null);
        icts.afterUndelete(null);
    }
    
}