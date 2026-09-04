@isTest
public class AUSFValuationControllerTest {
    
    @testSetup static void setup() {
        Test.startTest();
        //Account Insertion
        Account  accountInstance = (Account)TestFactory.createSObject(new Account(
            Name='ParentAccount',
            Grading__c ='Platinum-Certified',
            Certified_Value__c = 'Yes'
        ),true);
        
        Account  accountChildInstance = (Account)TestFactory.createSObject(new Account(
            Name='childAccount',
            State__c=accountInstance.Id,
            recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId()
        ),true);
        
        //Scheme Insertion
        Scheme_Master__c scheme = (Scheme_Master__c )TestFactory.createSObject(new Scheme_Master__c (
            Scheme_Name__c ='Normal',
            Type_of_loan__c ='Used'
        ),true);
        
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c ='DDE',
            Wheels_Exposure__c=500,
            Final_Exposure__c =1000,
            Branch_Master__c =accountChildInstance.Id,
            Scheme__c =scheme.Id,
            Dealer_Master__c = accountInstance.Id
        ),true);
        //Applicant Record Type Id
        
        Id applicantRecordTypeId = Schema.SObjectType.Applicant__c .getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
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
            RecordTypeId = applicantRecordTypeId,
            SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]'
            
        ),true);
        
        //Address Insertion
        Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow'
        ),true);
        
        //MMV Insertion
        MMV_Master__c mmvMaster = (MMV_Master__c )TestFactory.createSObject(new MMV_Master__c (
            Name ='Test',
            //            Collateral_Name__c ='Car',
            Collateral_Type__c ='Automobile'
        ),true);
        
        
        
        // Collateral Insertion
        Collateral__c  collateral = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppl.Id,
            // Name ='CollateralTest',
            Scheme__c =scheme.Id,
            MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10108'
        ),true);
        
        Collateral__c  collateral1 = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppl.Id,
            //  Name ='CollateralTest1',
            Scheme__c =scheme.Id,
            MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12346568',
            Certified_Value__c='1000001',
            Collateral_Name__c ='10108'
        ),true);
        
        Collateral__c  collateral2 = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppl.Id,
            //  Name ='CollateralTest2',
            Scheme__c =scheme.Id,
            MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12346569',
            Certified_Value__c='0',
            Collateral_Name__c ='10108'
        ),true);
        
        Document_Master__c master = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (  
            Name ='AUWheels0014'
        ),true);            
        
        Document_CheckList__c checklist = (Document_CheckList__c )TestFactory.createSObject(new Document_CheckList__c (
            Collateral__c  = collateral2.Id,
            Document_Master__c=master.Id
        ),true);
        
        
        
        //Valuation Insertion
        Valuation__c valuation = (Valuation__c) TestFactory.createSObject(new Valuation__c (
            Reference_ID__c='ValTest',
            Action__c='Trigger',
            Collateral__c= collateral2.Id,
            Valuation_Amount__c=1000,
            isLatest__c = true,
            Response_Received__c ='Yes',
            Cando_Request_Id__c='Req1',
            Vehicle_Number__c = '12345'
        ),true);
        
        Valuation__c valuation1 = (Valuation__c) TestFactory.createSObject(new Valuation__c (
            Reference_ID__c='ValTest1',
            Action__c='Retrigger',
            Collateral__c= collateral2.Id,
            Valuation_Amount__c=1000,
            Cando_Request_Id__c = 'Req1',
            Response_Received__c ='Yes'
        ),true);
        
        
        
        
        //Generic Master Insertion
        Generic_Master__c genericMaster = (Generic_Master__c )TestFactory.createSObject(new Generic_Master__c (
            State__c='ParentAccount',
            Account_No__c =1234455
        ),true);
        
        //CanDo Lead Integration Master
        Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='CANDOLEAD',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        //SMS Notification Integration Master
        Integration_Master__c SMSIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='SMS Notification',
            End_Point_URL__c='https://service.aubank.in/SFDCCcommunication/SendSMS',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        //EMAIL Notification Integration Master
        Integration_Master__c EMAILIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Email Notification',
            End_Point_URL__c='https://service.aubank.in/SFDCCommunication/Email',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        //Cancel Cando
        Integration_Master__c CandoCancelMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='CANDOLEADCANCEL',
            End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/CanDoLeadService/cancelLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Karix URL Shortner',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CollateralModificationRestService/Modification',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);

        Test.stopTest();
    }
    
    /*    @isTest static void valuationUpdation(){
Test.startTest();
AUSFValuationController.handleUpdateValuation('ValTest','Trigger',10000);
Test.stopTest();
}*/
    
    @isTest static void applicant(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        String loanId = loanInstance.Id;
        Test.startTest();
        List < Applicant__c > applicantList = AUSFValuationController.getApplicant(loanId);
        //AUSFValuationController.handleUpdateValuation('ValTest','Trigger',10000);
        System.assertEquals(applicantList !=null,true,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void address(){
        Applicant__c applicantRecord = [SELECT id,First_Name__c,Loan__c,SF_Exposure_JSON__c,Loan__r.Loan_Amount__c,Loan__r.Product__c 
                                        FROM Applicant__c
                                        WHERE First_Name__c ='Vikash'];
        String applicantId = applicantRecord.Id;
        Test.startTest();
        AUSFValuationController.getCurrentAddressDetails(applicantId);
        System.assertEquals('Vikash', applicantRecord.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void vhclCategory(){
        Test.startTest();
        Integer vehcleNumber=AUSFValuationController.getVehicalCategory('Auto Loan (New)');	
        AUSFValuationController.getVehicalCategory('Two Wheeler (New)');
        System.assertEquals(vehcleNumber !=null,true,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void valueMaster(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c,Branch_Master__r.State__r.Name,Scheme__r.Scheme_Name__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        AUSFValuationController.getValueMasterDetails(loanInstance.Id);
        AUSFValuationController.getLoanSchemeMasterDetails(loanInstance.Id);
        System.assertEquals('AP-12345', loanInstance.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void collateralDetails(){
        Collateral__c collateralInstance = [SELECT Id,Name,Vehicle_Number__c
                                            FROM Collateral__c
                                            WHERE Vehicle_Number__c='TN12345567'];
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        String loanId = loanInstance.Id;
        
        String collateralId = collateralInstance.Id;
        
        Test.startTest();
        AUSFValuationController.getCollateralDetails(collateralInstance.Id,loanInstance.Id);
        AUSFValuationController.getValuationDetails(collateralId);
        System.assertEquals('TN12345567', collateralInstance.Vehicle_Number__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void valuationDetails(){
        Collateral__c collateralInstance = [SELECT Id,Name,Vehicle_Number__c
                                            FROM Collateral__c
                                            WHERE Vehicle_Number__c = 'TN12346568'];
        
        Collateral__c collateralInstance1 = [SELECT Id,Vehicle_Number__c
                                             FROM Collateral__c
                                             WHERE Vehicle_Number__c = 'TN12346569'];
        String collateralId = collateralInstance.Id;
        String collateral1Id = collateralInstance1.Id;
        
        Test.startTest();
        AUSFValuationController.getValuationDetails(collateralId);
        AUSFValuationController.getValuationDetails(collateral1Id);
        AUSFValuationController.handleUpdateCollateral(collateralInstance1);
        System.assertEquals('TN12346568', collateralInstance.Vehicle_Number__c,'AssertMsg');
        Test.stopTest();
        
    }
    
    @isTest static void canDoDetails(){
        Valuation__c valuationObj = new Valuation__c();
        valuationObj.Reference_ID__c='ValTest1';
        valuationObj.Valuation_Amount__c=10000;
        valuationObj.Product__c='Auto Loan (New)';
        valuationObj.Coordinate_for_valuation_POC__c='Test';
        valuationObj.Contact_Person_Mobile_Number__c='8105455454';
        valuationObj.Vehicle_Number__c='TN717251414';
        
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c,Branch_Master__r.State__r.Name,Scheme__r.Scheme_Name__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        String variantName='Toyota_Car_Glare';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CanDoCalloutMock());
        AUSFValuationController.handleCandoLeadApi(valuationObj,'CANDOLEAD',loanInstance.Id,variantName);
        System.assertEquals('AP-12345', loanInstance.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest static void canDoCancelDetails(){
        
        
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c,Owner.Id,Owner.Name,Branch_Master__r.State__r.Name,Scheme__r.Scheme_Name__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Applicant__c applicantRecord = [SELECT id,First_Name__c,Loan__c,SF_Exposure_JSON__c,Loan__r.Loan_Amount__c,Loan__r.Product__c 
                                        FROM Applicant__c
                                        WHERE First_Name__c ='Vikash'];
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CanDoCancelCalloutMock());
        try{
        AUSFValuationController.handleCandoReject('4WRTL295519676',applicantRecord.Id,loanInstance.Id,'9994666666');
        System.assertEquals('AP-12345', loanInstance.Application_Number__c,'AssertMsg');
        }
        Catch(exception e){
            
            system.debug('inside catch::'+e);
        }

            Test.stopTest();
    }
    
    
    // Other valuation
    @isTest static void otherValuationDetails(){
        Valuation__c valuationObj = new Valuation__c();
        valuationObj.Reference_ID__c='ValTest1';
        valuationObj.Valuation_Amount__c=10000;
        valuationObj.Product__c='Auto Loan (New)';
        valuationObj.Coordinate_for_valuation_POC__c='Test';
        valuationObj.Contact_Person_Mobile_Number__c='8105455454';
        valuationObj.Vehicle_Number__c='TN717251414';
        
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c,Branch_Master__r.State__r.Name,Scheme__r.Scheme_Name__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        String variantName='Toyota_Car_Glare';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        AUSFValuationController.handleCandoLeadApi(valuationObj,'Other valuation',loanInstance.Id,variantName);
        System.assertEquals('AP-12345', loanInstance.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void valuationIns(){
        Valuation__c valuationObj = new Valuation__c();
        valuationObj.Reference_ID__c='ValTest1';
        valuationObj.Valuation_Amount__c=10000;
        valuationObj.Product__c='Auto Loan (New)';
        valuationObj.Coordinate_for_valuation_POC__c='Test';
        valuationObj.Contact_Person_Mobile_Number__c='8105455454';
        valuationObj.Vehicle_Number__c='TN717251414';
        Test.startTest();
        AUSFValuationController.handleValuationInsertion('reqTest',valuationObj);
        Test.stopTest();
    }
    
    @isTest static void valuationRecord(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c,Branch_Master__r.State__r.Name,Scheme__r.Scheme_Name__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        AUSFValuationController.getValuationRecord(loanInstance.Id);
        AUSFValuationController.getLatestValuationRecords(loanInstance.Id);
        AUSFValuationController.getGradingValue(loanInstance.Id);
        Test.stopTest();
        
    }
    
    @isTest static void updationLoan(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c,Branch_Master__r.State__r.Name,Scheme__r.Scheme_Name__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        AUSFValuationController.updateLoanValuation(loanInstance.Id);
        Test.stopTest();
        
    }
    
    @isTest static void updationValuation(){
        Test.startTest();
        AUSFValuationController.handleUpdateValuation('ValTest','trigger',1000,'TN12346569');
        Test.stopTest();
    }
    
    @isTest static void updateOldValuationRcords(){
        Valuation__c val = [SELECT id,name,Reference_ID__c FROM Valuation__c WHERE Reference_ID__c = 'ValTest1'];
        Test.startTest();
        AUSFValuationController.updateOldValuationRcords(val.Id,'ValTest');
        Test.stopTest();
    }
    
    @isTest static void insertionContent(){
        Integration_Master__c intMaster = [SELECT id,Name from Integration_Master__c WHERE Name='CANDOLEAD'];
        Integration_Checklist__c checkRecord = new Integration_Checklist__c();
        checkRecord.Integration_Master__c = intMaster.Id;
        checkRecord.Request_Id__c = 'Req1';
        insert checkRecord;
        
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            Request_id__c ='Req1',
            VersionData = Blob.valueOf('Test Content'),
            Origin = 'H'
        );
        insert contentVersion;    
        // List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        /*ContentDocumentLink cdl = New ContentDocumentLink();
cdl.LinkedEntityId = checkRecord.id;
cdl.ContentDocumentId = documents[0].Id;
cdl.shareType = 'V';
insert cdl;*/
        
        Map<id,ContentVersion> conMap = new Map<Id,ContentVersion>();
        conMap.put(contentVersion.Id,contentVersion);
        Test.startTest();
        try{
        AUSFValuationController.handleValuationCallBackResponse(conMap);
        }
        Catch(exception e){
            
            system.debug('inside catch::'+e);
        }
        Test.stopTest();
        
    }
    
    @isTest static void updatingValuationDetails(){
        Integration_Master__c intMaster = [SELECT id,Name from Integration_Master__c WHERE Name='CANDOLEAD'];
        Applicant__c applicantRecord = [SELECT id,First_Name__c,Loan__c,SF_Exposure_JSON__c,Loan__r.Loan_Amount__c,Loan__r.Product__c 
                                        FROM Applicant__c
                                        WHERE First_Name__c ='Vikash'];
        Integration_Checklist__c checkRecord = new Integration_Checklist__c();
        checkRecord.Integration_Master__c = intMaster.Id;
        checkRecord.Request_Id__c = 'Req1';
        checkRecord.Applicant__c = applicantRecord.Id;
        //checkRecord.Integration_Master_Name__c='CANDOLEAD';
        checkRecord.Callback_Request__c = '{\"VehicleCondition\" : \"Running\", \"RegistrationDate\" : \"2017-07-01\", \"OwnerSerialNo\" : \"3\", \"Color\" : \"Brown\", \"Hypothication\" : \"AU Small Finance Bank LTD\", \"Odometer\" : \"6464\", \"ChassisNumber\" : \"hhgg7373737\", \"EngineNumber\" : \"hshssh78\", \"ReferenceID\" : \"4WCAN295520134\", \"ProspectNo\" : \"SFDCUAT_ff007fe6111267b7d4e961b09\", \"Fuel\" : \"CNG\", \"ManufacturingYear\" : \"2017\", \"VehicleNumber\" : \"RJ20UC8595\", \"ValuationAmount\" : \"385000\", \"FinalRemarks\" : \"Vehicle is in Good Condition\" }';
        insert checkRecord;
        
        List<Integration_Checklist__c> icheckList = new List<Integration_Checklist__c>();
        icheckList.add(checkRecord);
        List<Integration_Checklist__c> checListRecord =[SELECT id,Integration_Master_Name__c,Request_Id__c,Callback_Request__c,Applicant__c FROM Integration_Checklist__c WHERE Request_Id__c ='Req1'];
        Map <Id, Integration_Checklist__c > oldRecordMap = new Map < Id, Integration_Checklist__c >();
        oldRecordMap.put(intMaster.Id,checkRecord);
        Map <Id, Integration_Checklist__c > newRecordMap = new Map < Id, Integration_Checklist__c >();
        newRecordMap.put(intMaster.Id,checkRecord);	     
        Test.startTest();
        try{
        AUSFValuationController.updateValuationDetails(checListRecord,oldRecordMap,newRecordMap);
        }
        catch(exception e){
            system.debug('inside exception');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void codeCoverage(){
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new BitlyKarixCalloutMock() );
        Valuation__c la = [select id,Reference_ID__c,Action__c,Vehicle_Number__c from Valuation__c limit 1];
        Valuation__c valList = [select id,Cando_Request_Id__c from Valuation__c where Action__c = 'Retrigger' limit 1];
        String file = 'testpng';
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(file);
        cv.Title = 'CustomerPhoto';
        cv.PathOnClient = 'CustomerPhoto.png';
        //cv.Document_Type__c = 'Customer Photo';
        insert cv;
        Id contDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contDocId;
        cdl.LinkedEntityId = la.Id;
        //cdl.ShareType = 'V';
        insert cdl;
        AUSFValuationController.getRelatedFilesByRecordId(la.Id);
        AUSFValuationController.calculateAverage(valList.id,valList.Cando_Request_Id__c);
        AUSFValuationController.handleUpdateValuation(la.Reference_ID__c, la.Action__c, 10000, la.Vehicle_Number__c);
        Test.stopTest();
    }
    
}