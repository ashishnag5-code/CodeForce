/* Source Class1 : CreateFieldInvestigatiionRecord
*  Source Class2 : FieldInvestigationService
*/
@isTest
private with sharing class CreateFieldInvestigatiionRecordTest {
    @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name = 'Credit Manager'];
        
        Document_Master__c master = (Document_Master__c )TestFactory.createSObject(new Document_Master__c (
            Document_Name__c ='FI Photos' 
        ),true);
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Credit_User'];
        
        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            
            Account accInstance = (Account )TestFactory.createSObject(new Account (
                Name ='TestAccount',
                Account_Code__c='2103',
                Branch_Queue__c=grp.Id
            ),true); 
            
            
            User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                                lastName = 'test2',
                                                                profileId = prof.id,
                                                                username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test@test.com',
                                                                Branch_Code__c  = '2103'
                                                               ),true);
            
            AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id,
                UserId=usr.Id,
                TeamMemberRole ='FI',
                Zip_Code__c='110051'
                
            ),true);
            AccountTeamMember atm2 = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id,
                UserId=usr.Id,
                TeamMemberRole ='FI',
                Zip_Code__c='110052'
                
            ),true);
            AccountTeamMember atm3 = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id,
                UserId=usr.Id,
                TeamMemberRole ='FI',
                Zip_Code__c='110053'
                
            ),true);
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
            
            Location_Master__c  lcMaster = (Location_Master__c )TestFactory.createSObject(new Location_Master__c (
                Name ='110053',
                Area_Name__c ='JAGJIT NAGAR',
                Area_Type__c ='Urban',  
                City__c ='EAST DELHI',
                State__c ='MAHARASHTRA',
                Taluka__c ='NA'
            ),true);
            
            Account accInstance2 = (Account )TestFactory.createSObject(new Account (
                Name ='TestAccount',
                Pincode__c = lcMaster.Id
            ),true);
            
            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                Application_Number__c  = 'AP-12345',
                Adhar_Card__c   = 123456,
                Loan_Amount__c  = 1000,
                Product__c='10301',
                Branch_Master__c =accInstance2.Id,
                Application_FI_Status__c='Negative'
                
            ),true);
            Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                First_Name__c = 'Vikash',
                Middle_Name__c = 'Kumar',
                Last_Name__c = 'Mandal',
                Loan__c =loanAppl.Id,
                Customer_Name__c='Vikas',
                Customer_Type__c='Individual'
                
            ),true);
            
            Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
                Address_Line_1__c ='TestAddressline1',
                Address_Line_2__c ='TestAddressline2',
                Address_Line_3__c ='TestAddressline3',
                State__c='MAHARASHTRA',
                City__c='EAST DELHI',
                Area_Name__c='JAGJIT NAGAR',
                Area_Type__c='Urban',
                Taluka__c='NA',
                Pincode__c='110051',
                Land_mark__c='Testing',
                Applicant__c =appl.Id,
                Status__c='Owned',
                Address_Type__c='Permanent',
                Type__c='Bungalow',
                Fi_Required__c = false
            ),true);
            
            Address__c  addInstance1 = (Address__c)TestFactory.createSObject(new Address__c(
                Address_Line_1__c ='TestAddressline11',
                Address_Line_2__c ='TestAddressline22',
                Address_Line_3__c ='TestAddressline34',
                State__c='MAHARASHTRA',
                City__c='EAST DELHI',
                Area_Name__c='JAGJIT NAGAR',
                Area_Type__c='Urban',
                Taluka__c='NA',
                Pincode__c='110052',
                Land_mark__c='Testing',
                Applicant__c =appl.Id,
                Status__c='Owned',
                Address_Type__c='Current',
                Type__c='Bungalow',
                Fi_Required__c = false
            ),true);
            Address__c  addInstanc2 = (Address__c)TestFactory.createSObject(new Address__c(
                Address_Line_1__c ='TestAddressline112',
                Address_Line_2__c ='TestAddressline222',
                Address_Line_3__c ='TestAddressline332',
                State__c='MAHARASHTRA',
                City__c='EAST DELHI',
                Area_Name__c='JAGJIT NAGAR',
                Area_Type__c='Urban',
                Taluka__c='NA',
                Pincode__c='110053',
                Land_mark__c='Testing',
                Applicant__c =appl.Id,
                Status__c='Owned',
                Address_Type__c='Office',
                Type__c='Bungalow',
                Fi_Required__c = false
            ),true);
            Address__c  addInstanc3 = (Address__c)TestFactory.createSObject(new Address__c(
                Address_Line_1__c ='TestAddressline112',
                Address_Line_2__c ='TestAddressline222',
                Address_Line_3__c ='TestAddressline333',
                State__c='MAHARASHTRA',
                City__c='EAST DELHI',
                Area_Name__c='JAGJIT NAGAR',
                Area_Type__c='Urban',
                Taluka__c='NA',
                Pincode__c='110054',
                Land_mark__c='Testing',
                Applicant__c =appl.Id,
                Status__c='Owned',
                Address_Type__c='Touch Point',
                Type__c='Bungalow',
                Fi_Required__c = false
            ),true);
            Id recId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId();
            
            Applicant_Financials_Details__c applFinancialInsta=(Applicant_Financials_Details__c)TestFactory.createSObject((new Applicant_Financials_Details__c(Type_Of_Employment__c='Salaried - Private',Monthly_Obligation__c=1000,
                                                                                                                                                               RecordTypeId=recId,Company_Name__c='AU',
                                                                                                                                                               Method_Of_Assesment__c='Salaried', Applicant__c=appl.Id)),true);
            
            
            
            
              Field_Investigation__c fieldInvestigationObj = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
                Name = appl.Customer_Name__c,
                Loan_Application__c =loanAppl.Id,
                Address_lookup__c=addInstance.id,
                Applicant__c=appl.Id,
                FI_Status__c ='Negative',
                Applicant_Type__c='Applicant',
              	Address_Negative_Reason__c = 'Test1 Negative; Test2 Negative', Profile_Negative_Reasons__c = 'Test1 Negative;')),true);
                
                Field_Investigation__c fieldInvestigationObj2 = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
                Name = appl.Customer_Name__c,
                Loan_Application__c =loanAppl.Id,
                Address_lookup__c=addInstance1.id,
                Applicant__c=appl.Id,
                FI_Profile_Status__c ='Cancelled',
                Credit_Manager__c =UserInfo.getUserId(),
                Applicant_Type__c='Applicant' )),true);
        }
    }
    @isTest static void testMethodUsingloanApplication() {
        Test.startTest();
        system.runAs([select Id from User where Id = :UserInfo.getUserId()][0]){
            List<Field_Investigation__c> fieldList = [SELECT Id FROM Field_Investigation__c WHERE FI_Status__c ='Negative' LIMIT 1];
            Loan_Application__c loanApplication =[SELECT id FROM Loan_Application__c Limit 1];
            List<String> addressIds = new List<String>();
            Map<String, List<String>> mapAppIdAndAddIdType = new Map<String, List<String>>();
            for(Address__c add : [SELECT Id,Applicant__r.Name,Address_Type__c FROM Address__c])
            {
                addressIds.add(add.Id);
                if(!mapAppIdAndAddIdType.containsKey(add.Applicant__r.Name)){
                    mapAppIdAndAddIdType.put(add.Applicant__r.Name, new List<String>());
                }
                mapAppIdAndAddIdType.get(add.Applicant__r.Name).add(add.Address_Type__c.toUpperCase());
            }
            List<Field_Investigation__c> fiList=CreateFieldInvestigatiionRecord.fetchRelatedApplicantAddress(loanApplication.Id,true,new List<String>(), addressIds);
            System.assertEquals(fiList[0].Name == 'Vikas',true,'AssertMsg');
        }
        Test.stopTest();
    }
    
    @isTest static void testMethodUsingApplicant() {
        Test.startTest();
        CreateFieldInvestigatiionRecord.getVFOrigin();
        system.runAs([select Id from User where Id = :UserInfo.getUserId()][0]){
            
            Applicant__c appl =[SELECT id  FROM Applicant__c limit 1];
            Address__c address = [SELECT Id FROM Address__c WHERE Applicant__c = :appl.Id LIMIT 1];
            try{
            List<Field_Investigation__c> fiList=CreateFieldInvestigatiionRecord.fetchRelatedApplicantAddress(appl.Id,false,null, new List<String>{address.Id});
            System.assertEquals(fiList[0].Name == 'Vikas',true,'AssertMsg'); 
            }
            catch(Exception ex){
                System.debug('Exception'+ex.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    @isTest static void testMethodtoFetchBREApp() 
    {
        List<Field_Investigation__c> fieldList = [SELECT Id FROM Field_Investigation__c WHERE FI_Status__c = 'Negative' LIMIT 1];
        Loan_Application__c loanApplication =[SELECT id FROM Loan_Application__c Limit 1];
        Map<String, List<String>> mapAppIdAndAddIdType = new Map<String, List<String>>();
        for(Address__c add : [SELECT Id,Applicant__r.Name,Address_Type__c FROM Address__c])
        {
            if(!mapAppIdAndAddIdType.containsKey(add.Applicant__r.Name)){
                mapAppIdAndAddIdType.put(add.Applicant__r.Name, new List<String>());
            }
            mapAppIdAndAddIdType.get(add.Applicant__r.Name).add(add.Address_Type__c.toUpperCase());
        }
        try{
            Test.startTest();
        	List<Field_Investigation__c> fieldInvList = CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndAddIdType,loanApplication.Id,true,new List<String>{fieldList[0].Id});
        	List<Field_Investigation__c> fieldInvList1 = CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndAddIdType,loanApplication.Id,false,new List<String>());
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('Exception'+ex.getMessage());
        }
    }

    @isTest static void testMethodtoFetchBREAppInsert() 
    {
        List<Field_Investigation__c> fieldList = [SELECT Id FROM Field_Investigation__c WHERE FI_Status__c = 'Negative' LIMIT 1];
        Loan_Application__c loanApplication =[SELECT id FROM Loan_Application__c Limit 1];
        Map<String, List<String>> mapAppIdAndAddIdType = new Map<String, List<String>>();
        for(Address__c add : [SELECT Id,Applicant__r.Name,Address_Type__c FROM Address__c])
        {
            if(!mapAppIdAndAddIdType.containsKey(add.Applicant__r.Name)){
                mapAppIdAndAddIdType.put(add.Applicant__r.Name, new List<String>());
            }
            mapAppIdAndAddIdType.get(add.Applicant__r.Name).add(add.Address_Type__c.toUpperCase());
        }
        try{
            Test.startTest();
        	//List<Field_Investigation__c> fieldInvList = CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndAddIdType,loanApplication.Id,true,new List<String>{fieldList[0].Id});
        	List<Field_Investigation__c> fieldInvList1 = CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndAddIdType,loanApplication.Id,false,new List<String>());
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('Exception'+ex.getMessage());
        }
    }

    @isTest static void testMethodtoFetchBREAppUpdate() 
    {
        List<Field_Investigation__c> fieldList = [SELECT Id FROM Field_Investigation__c WHERE FI_Status__c = 'Negative' LIMIT 1];
        fieldList = [SELECT Id FROM Field_Investigation__c];
        delete fieldList;
        Loan_Application__c loanApplication =[SELECT id FROM Loan_Application__c Limit 1];
        Map<String, List<String>> mapAppIdAndAddIdType = new Map<String, List<String>>();
        for(Address__c add : [SELECT Id,Applicant__r.Name,Address_Type__c FROM Address__c])
        {
            if(!mapAppIdAndAddIdType.containsKey(add.Applicant__r.Name)){
                mapAppIdAndAddIdType.put(add.Applicant__r.Name, new List<String>());
            }
            mapAppIdAndAddIdType.get(add.Applicant__r.Name).add(add.Address_Type__c.toUpperCase());
        }
        try{
            Test.startTest();
        	//List<Field_Investigation__c> fieldInvList = CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndAddIdType,loanApplication.Id,true,new List<String>{fieldList[0].Id});
        	List<Field_Investigation__c> fieldInvList1 = CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndAddIdType,loanApplication.Id,false,new List<String>());
            fieldList = [SELECT Id, Stage__c, FI_Status__c FROM Field_Investigation__c LIMIT 1];
            system.assertEquals(true, fieldList.size()>0);
            fieldList[0].Stage__c = 'Assigned';
            update fieldList;
            fieldList[0].Stage__c = 'In Progress';
            update fieldList;
            fieldList[0].Stage__c = 'Closed';
            fieldList[0].FI_Status__c = 'Positive';
            update fieldList;
            //List<Field_Investigation__c> fieldInvList1 = CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndAddIdType,loanApplication.Id,false,new List<String>());
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('Exception'+ex.getMessage());
        }
    }

    @isTest static void testMethodtoFetchBREAppUpdateNegative() 
    {
        List<Field_Investigation__c> fieldList = [SELECT Id FROM Field_Investigation__c WHERE FI_Status__c = 'Negative' LIMIT 1];
        fieldList = [SELECT Id FROM Field_Investigation__c];
        delete fieldList;
        Test.startTest();
        Loan_Application__c loanApplication =[SELECT id, Stage__c, BRE_Decision__c FROM Loan_Application__c Limit 1];
        loanApplication.Stage__c = 'Credit';
        loanApplication.BRE_Decision__c = 'STP';
        Update loanApplication;
        Map<String, List<String>> mapAppIdAndAddIdType = new Map<String, List<String>>();
        for(Address__c add : [SELECT Id,Applicant__r.Name,Address_Type__c FROM Address__c])
        {
            if(!mapAppIdAndAddIdType.containsKey(add.Applicant__r.Name)){
                mapAppIdAndAddIdType.put(add.Applicant__r.Name, new List<String>());
            }
            mapAppIdAndAddIdType.get(add.Applicant__r.Name).add(add.Address_Type__c.toUpperCase());
        }
        try{
            
            
        	//List<Field_Investigation__c> fieldInvList = CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndAddIdType,loanApplication.Id,true,new List<String>{fieldList[0].Id});
        	List<Field_Investigation__c> fieldInvList1 = CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndAddIdType,loanApplication.Id,false,new List<String>());
            
            List<Field_Investigation__c> lstQuery = FieldInvestigationService.getFieldInvestigationRecords ('');
            lstQuery = FieldInvestigationService.getFieldInvestigationRecords (' Re_Trigger__c = false ');

            // Method Not in Use - created because of implement interface
            FieldInvestigationService obj = new FieldInvestigationService();
            obj.beforeInsert (new List<sObject>());
            obj.beforeUpdate (new List<sObject>(), new Map<Id,sObject>(), new Map<Id,sObject>());
            obj.beforeDelete ( new Map<Id,sObject>());
            obj.afterDelete ( new Map<Id,sObject>());
            obj.afterUndelete ( new Map<Id,sObject>());


            User objCreditUser = [Select Id from User where profile.Name = 'Credit Manager' limit 1];
            system.assertEquals(true,objCreditUser != NULL);
            
            fieldList = [SELECT Id, Stage__c, FI_Status__c, Credit_Manager__c FROM Field_Investigation__c LIMIT 1];
            fieldList[0].Credit_Manager__c = objCreditUser.Id;
            update fieldList;

            fieldList[0].Credit_Manager__c = NULL;
            update fieldList;

            system.assertEquals(true, fieldList.size()>0);
            fieldList[0].Stage__c = 'Closed';
            fieldList[0].FI_Status__c = 'Negative';
            update fieldList;
            //List<Field_Investigation__c> fieldInvList1 = CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndAddIdType,loanApplication.Id,false,new List<String>());
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('Exception'+ex.getMessage());
        }
    }

    @isTest static void updateFieldInvDeviatons()
    {
        List<Field_Investigation__c> fieldList = [SELECT Id,FI_Status__c,Address_Negative_Reason__c,Loan_Application__c, Address_lookup__c 
                                                  FROM Field_Investigation__c WHERE FI_Status__c = 'Negative' LIMIT 1];
       Test.startTest();
       CreateFieldInvestigatiionRecord.FieldInvestigationWrap wrap = CreateFieldInvestigatiionRecord.updateFieldInvestigationRecord(JSON.serialize(fieldList[0]), fieldList[0].Id, false, true);

       List<String> lstFI = new List<String>();
       lstFI.add(fieldList[0].Id);
       List<Address__c> objAdd = [Select Id from Address__c where Id =: fieldList[0].Address_lookup__c limit 1];
       system.assertEquals(true, objAdd.size()>0);
       List<String> lstAddId = new List<String>();
       lstAddId.add(objAdd[0].Id);
       List<Field_Investigation__c> lstReTrigger = CreateFieldInvestigatiionRecord.fetchRelatedApplicantAddress(NULL, true, lstFI, lstAddId);
       fieldList = [SELECT Id, Stage__c, FI_Status__c, Credit_Manager__c FROM Field_Investigation__c where FI_Status__c != 'Negative' and Address_Lookup__c =: objAdd[0].Id LIMIT 1];
        system.assertEquals(true, fieldList.size()>0);
        fieldList[0].Stage__c = 'Closed';
        fieldList[0].FI_Status__c = 'Positive';
        try {
            update fieldList;
        }
        catch (Exception ex) {}
       Test.stopTest();
    }
    
    @isTest static void updateFieldInvMethod()
    {
        List<Field_Investigation__c> fieldList = [SELECT Id,FI_Status__c,Address_Negative_Reason__c,Profile_Negative_Reasons__c,Loan_Application__c
                                                  FROM Field_Investigation__c WHERE FI_Status__c = 'Negative' LIMIT 1];
       Test.startTest();
       CreateFieldInvestigatiionRecord.FieldInvestigationWrap wrap = CreateFieldInvestigatiionRecord.updateFieldInvestigationRecord(JSON.serialize(fieldList[0]), fieldList[0].Id, false, true);
       Test.stopTest();
    }

    
    
    @isTest static void summaryViewTestMethod() {
        Test.startTest();
        User objuser =[Select Id from User WHERE IsActive = true limit 1];
        system.runAs(objuser){
            Loan_Application__c loanApplication =[SELECT id FROM Loan_Application__c Limit 1];
            FISummaryViewController.fiSummaryView(loanApplication.Id,'');
        }
        Test.stopTest();
    }
    
    @isTest static void permissionTestMethod(){
        Test.startTest();
        CreateFieldInvestigatiionRecord.PermissionWrapper premissionWrap = CreateFieldInvestigatiionRecord.getUserAssignedPermissions();
        System.assert(premissionWrap != null);
        Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<CreateFieldInvestigatiionRecord.ReTriggerAddressWrapper> addressWrapper = CreateFieldInvestigatiionRecord.getApplicantRelatedAddress(loanAppl.Id);
        System.assert(addressWrapper.size() != 0);
        Test.stopTest();
    }
    
    @isTest static void fiRecordRejectTest()
    {
        Test.startTest();
        Field_Investigation__c fieldInv = [SELECT Id FROM Field_Investigation__c LIMIT 1];
        CreateFieldInvestigatiionRecord.RejectResponseWrapper wrap = CreateFieldInvestigatiionRecord.handleFIRecordReject(fieldInv.Id,UserInfo.getUserId());
        System.assert(wrap != null);
        CreateFieldInvestigatiionRecord.FieldInvestigationWrap wrap1 = CreateFieldInvestigatiionRecord.sendBackFIRecord(fieldInv.Id,'Send Back Comments Test');
        System.assert(wrap1 != null);
        CreateFieldInvestigatiionRecord.NegativeReasonWrapper wrap2 = CreateFieldInvestigatiionRecord.getProfileAddressNegativePicklistValues('Four Wheeler');
        System.assert(wrap2 != null);
        Test.stopTest();
    }
    
    @isTest static void getRelatedProductCodeTest()
    {
        Test.startTest();
        String prodName = CreateFieldInvestigatiionRecord.getRelatedProductCode('Auto Loan (New)');
        Test.stopTest();
    }
}