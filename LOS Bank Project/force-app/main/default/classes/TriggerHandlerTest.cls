@isTest
public class TriggerHandlerTest {

    @isTest
    static void testIncrement() {
        Test.startTest();
        TriggerHandler.LoopCount loopCount = new TriggerHandler.LoopCount();
        System.assertEquals(0, loopCount.getCount());
        System.assertEquals(false, loopCount.exceeded());
        System.assertEquals(5, loopCount.getMax());

        for (Integer i = 0; i < loopCount.getMax(); i++) {
            System.assertEquals(false, loopCount.exceeded());
            System.assertEquals(false, loopCount.increment());
            System.assertEquals(i + 1, loopCount.getCount());
        }

        System.assertEquals(false, loopCount.exceeded());
        System.assertEquals(true, loopCount.increment());
        System.assertEquals(6, loopCount.getCount());
        Test.stopTest();
    }

    @isTest
    static void testExceeded() {
        Test.startTest();
        TriggerHandler.LoopCount loopCount = new TriggerHandler.LoopCount();
        System.assertEquals(false, loopCount.exceeded());
        loopCount.setMax(0);
        System.assertEquals(false, loopCount.exceeded());
        loopCount.setMax(1);
        loopCount.increment();
        System.assertEquals(false, loopCount.exceeded());
        Test.stopTest();
    }

    @isTest
    static void validateMethods() {
        Test.startTest();
        Account acc = (Account)TestFactory.createSObject(new Account(
        			Type = 'Location', Name = 'Western Mumbai'),'TestFactoryDefaults.AccountDefaults', true);
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103'
                                                           ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='Credit',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
        ),true);  
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
         Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Customer_Grade__c ='NIB',
            Type_Of_Employment__c='Business',
            Bureau_Score__c='200',
            Applicant_FI_Status__c='Positive',
            Dob__c =Date.newInstance(2016, 12, 9),
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Loan__c =loanAppl.Id,
            Mobile_Number__c ='8106255685',
            PAN__c ='EXFPK4321K',
            CIF_No__c ='12345678',
            Voter_Id__c='1241214',
            Passport_Number__c='12411414',
            Driving_License_Id__c='3555535xfr',
            Aadhaar_Number__c='60123214141',
            Customer_Type__c='Individual',
            SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
            
        ),true);
        
        delete appl2;
        undelete appl2;
        
        TriggerHandler.LoopCount loopCount = new TriggerHandler.LoopCount(5);
        TriggerHandler trigObj = new TriggerHandler();
        Business_Unit_Data__mdt loanAppData = Business_Unit_Data__mdt.getInstance('Loan_Application__c');
        Business_Unit_Data__mdt applicantData = Business_Unit_Data__mdt.getInstance('Applicant_Service');	
       // Business_Unit_Data__mdt pssDeviationData = Business_Unit_Data__mdt.getInstance('PSSDeviation');
        
        trigObj.beforeInsert();
        trigObj.beforeUpdate();
        trigObj.beforeDelete();
        trigObj.afterInsert();
        trigObj.afterUpdate();
        trigObj.afterUndelete();
        trigObj.afterDelete();
        trigObj.clearMaxLoopCount();
        trigObj.getBusinessUnitData();
        TriggerHandler.bypass('TestHandlerName');
        TriggerHandler.isBypassed('TestHandlerName');
        TriggerHandler.clearAllBypasses();
        TriggerHandler.clearBypass('TestHandlerName');

        trigObj.objectName = 'Applicant__c';        
        trigObj.getRecordTypeName('RecordType.DeveloperName', appl.RecordTypeId);
        trigObj.getRecordTypeName('RecordType.Name', appl.RecordTypeId);
        trigObj.getRecordTypeName('RecordType.DeveloperName', appl.RecordTypeId);
        trigObj.getRecordTypeName('', appl.RecordTypeId);
        trigObj.businessUnitDataList = new List<Business_Unit_Data__mdt>();
        trigObj.businessUnitDataList.add(loanAppData);
        trigObj.businessUnitDataList.add(applicantData);
        trigObj.populateBusinessUnitMaps();
        trigObj.getBusinessUnitOldMap('');
        trigObj.getBusinessUnitNewMap('');
        trigObj.getBusinessUnitNewList('');
        trigObj.getBusinessUnitOldMap('Loan_Application__c');
        trigObj.getBusinessUnitNewMap('Applicant_Service');
        trigObj.getBusinessUnitNewList('');
        Test.stopTest();        
    }
    @isTest
    static void populateBusinessUnitMapsTest() {
        Business_Unit_Data__mdt loanAppData = Business_Unit_Data__mdt.getInstance('Loan_Application__c');
        Business_Unit_Data__mdt applicantData = Business_Unit_Data__mdt.getInstance('Applicant_Service');	
       // Business_Unit_Data__mdt pssDeviationData = Business_Unit_Data__mdt.getInstance('PSSDeviation');
        
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103'
                                                           ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='Credit',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
        ),true);    
        TriggerHandler trigObj = new TriggerHandler();
        trigObj.businessUnitDataList = new List<Business_Unit_Data__mdt>();
        trigObj.businessUnitDataList.add(loanAppData);
        trigObj.businessUnitDataList.add(applicantData);
        //trigObj.businessUnitDataList.add(pssDeviationData);
        //trigObj.newTriggerRecordList = new List<SObject>();
        trigObj.populateBusinessUnitMaps();
    }
    @isTest
    static void populateBusinessUnitMapsNegativeTest() {
        Business_Unit_Data__mdt loanAppData = Business_Unit_Data__mdt.getInstance('Loan_Application__c');
        Business_Unit_Data__mdt applicantData = Business_Unit_Data__mdt.getInstance('Applicant_Service');	
       
        TriggerHandler trigObj = new TriggerHandler();
        trigObj.businessUnitDataList = new List<Business_Unit_Data__mdt>();
        trigObj.populateBusinessUnitMaps();
    }
    @isTest static void testSetMaxLoopCount() {
        TriggerHandler handler = new TriggerHandler();
        handler.setMaxLoopCount(5);
        handler.setMaxLoopCount(10);
        
    }

    @isTest static void testClearMaxLoopCount() {
        TriggerHandler handler = new TriggerHandler();
        handler.setMaxLoopCount(5);
        handler.clearMaxLoopCount();
        
    }

    @isTest static void testBypassAndClearBypass() {
        String handlerName = 'SampleHandler';

        TriggerHandler.bypass(handlerName);

        TriggerHandler.clearBypass(handlerName);
        
    }

    @isTest static void testIsBypassed() {
        String handlerName = 'SampleHandler';
		TriggerHandler.bypass(handlerName);
        
    }

    @isTest static void testClearAllBypasses() {
        TriggerHandler.bypass('HandlerOne');
        TriggerHandler.bypass('HandlerTwo');
        TriggerHandler.clearAllBypasses();
    }
    @isTest
    static void testAfterDelete() {
        Account acc = (Account)TestFactory.createSObject(new Account(
        			Type = 'Location', Name = 'Western Mumbai'),'TestFactoryDefaults.AccountDefaults', true);
        
        Test.startTest();
        delete acc; 
        Test.stopTest();
    }
    
    @isTest
    static void testAfterUndelete() {
        Account acc = (Account)TestFactory.createSObject(new Account(
        			Type = 'Location', Name = 'Western Mumbai'),'TestFactoryDefaults.AccountDefaults', true);
        delete acc;
        
        Test.startTest();
        undelete acc; 
        Test.stopTest();
    }


}