@isTest
public class CkycInsertApiTest {
    @testSetup static void setup() {
        
        Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();       
        Account branchMaster = new Account(Account_Name__c= 'Pune-Dealer', Account_Code__c  = '097', Name = 'Pune-Dealer',RecordTypeId=branchRecordTypeId);
        insert branchMaster;
        
        AccountTeamMember accTeamMember = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Team Leader', accountId = branchMaster.id, Active__c = true, UserId =userinfo.getUserId(),Zip_Code__c='302026'
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            RC_Limit_On_Hold__c= true,
            Total_Loan_Amount__c=10,
            //Dealer_Master__c = dealerMaster.Id,
            Branch_Master__c = branchMaster.Id
        ),true);
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Father_Name__c = 'Ankit',
            Spouse_Name__c = 'XYZ',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Non Individual',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE',
            Driving_License_Id__c='LMKN132312',
            KYC_Type__c='Driving License',
            DOB__c = System.today().addYears(-30)
        ),false);
        
          Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Non Individual',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE',
            Driving_License_Id__c='LMKN132312',
            KYC_Type__c='Aadhaar - Otp',
            DOB__c = System.today().addYears(-30)
        ),false);
        insert new List<Applicant__c>{appl,appl2};
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
            Address_Type__c='Permanent',
            Type__c='Bungalow',
            Stability__c ='7',
            Address_Source__c='Aadhaar - OTP',
            Latest_Cibil_Address_Match_Score__c=100
        ),false);
        
        
        Address__c  addInstance1 = (Address__c)TestFactory.createSObject(new Address__c(
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
            Type__c='Bungalow',
            Stability__c ='7',
            Address_Source__c='Aadhaar - OTP',
            Latest_Cibil_Address_Match_Score__c=100
        ),false);
        Address__c  addInstancePerm = (Address__c)TestFactory.createSObject(new Address__c(
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
            Applicant__c =appl2.Id,
            Status__c='Owned',
            Address_Type__c='Permanent',
            Type__c='Bungalow',
            Stability__c ='7',
            Address_Source__c='Voter Id',
            Latest_Cibil_Address_Match_Score__c=100
        ),false);
        
        
        Address__c  addInstanceCurr = (Address__c)TestFactory.createSObject(new Address__c(
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
            Applicant__c =appl2.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow',
            Stability__c ='7',
            Address_Source__c='Voter Id',
            Latest_Cibil_Address_Match_Score__c=100
        ),false);
        

        
        //CanDo Lead Integration Master
        Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='CKYC Insert',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),false);
        
        //CanDo Lead Integration Master
        Integration_Master__c CanDOIntegrationMaster2 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='CkycInsertAPI',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),false);

        
        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'Live Photo',
            Document_Name__c = 'Live Photo'
        ),false);
                
        Document_Master__c  docMasterDL = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'Driving Licence',
            Document_Name__c = 'Driving Licence'
        ),false);
        Document_Master__c  docMasterAadhaar = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'Aadhaar Card',
            Document_Name__c = 'Aadhaar Card'
        ),false);
        Document_Master__c  docMasterVoter = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'Voter Card',
            Document_Name__c = 'Voter Card'
        ),false);
        
        Document_Master__c  docMasterPassport = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'Passport',
            Document_Name__c = 'Passport'
        ),false);
        
        insert new List<sObject>{docMasterVoter,docMasterPassport,docMaster,docMasterDL,docMasterAadhaar,addInstance,addInstance1,addInstancePerm,addInstanceCurr,CanDOIntegrationMaster,CanDOIntegrationMaster2};

      // insert new List<Document_Master__c>{docMaster,docMasterDL,docMasterAadhaar};

        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Live Photo',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
        Document_Checklist__c docChkRecord2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl2.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Live Photo',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
                Document_Checklist__c docChkRecordDL = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMasterDL.Id,
            Document_Name__c ='Driving Licence',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
        Document_Checklist__c docChkRecordDL2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl2.Id,
            Document_Master__c = docMasterDL.Id,
            Document_Name__c ='Driving Licence',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
         Document_Checklist__c docChkRecordAadhaar = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMasterAadhaar.Id,
            Document_Name__c ='Aadhaar Card',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
        
        Document_Checklist__c docChkRecordAadhaar2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl2.Id,
            Document_Master__c = docMasterAadhaar.Id,
            Document_Name__c ='Aadhaar Card',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
          
        Document_Checklist__c docChkRecordVoter = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMasterVoter.Id,
            Document_Name__c ='Voter Card',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
        
        Document_Checklist__c docChkRecordPassport = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMasterPassport.Id,
            Document_Name__c ='Passport',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
        
        insert new List<Document_Checklist__c>{docChkRecord,docChkRecord2,docChkRecordDL,docChkRecordDL2,docChkRecordAadhaar,docChkRecordAadhaar2,docChkRecordVoter,docChkRecordPassport};

        Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecord.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
       // insert objCV;
        Contentversion objCV2 = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecord2.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
       // insert objCV2;

        Contentversion objCVDL = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecordDL2.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        //insert objCVDL;
        Contentversion objCVAadhar = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecordAadhaar.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        Contentversion objCVAadhar2 = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecordAadhaar2.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        Contentversion objCVDL2 = new Contentversion(Title = 'ABC',IsActive__c = true, PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecordDL.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
    Contentversion objCVDLVoter = new Contentversion(Title = 'ABC',IsActive__c = true, PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecordVoter.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        Contentversion objCVDLPass = new Contentversion(Title = 'ABC',IsActive__c = true, PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecordPassport.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
    
        List<Contentversion> conVersionList = new List<Contentversion>{objCV,objCV2,objCVDL,objCVAadhar,objCVAadhar2,objCVDL2,objCVDLVoter,objCVDLPass};
        ContentVersionTriggerService.boolRunCallback = false;
        insert conVersionList;
        
       // insert new List<ContentVersion>{objCVAadhar,objCVAadhar2,objCVDL2};
       /*
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objCVDL2.Id].ContentDocumentId;
        Id conDocId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objCVDL.Id].ContentDocumentId;
        
        Id conDocIdLive = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objCV.Id].ContentDocumentId;
        Id conDocId2Live = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objCV2.Id].ContentDocumentId;
        
        Id conDocIdAadhaar = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objCVAadhar.Id].ContentDocumentId;
        Id conDocId2Aadhaar = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objCVAadhar2.Id].ContentDocumentId;

    Id conDocId2Voter = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objCVDLVoter.Id].ContentDocumentId;

        Id conDocId2Pass = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objCVDLPass.Id].ContentDocumentId; 
        */
        Map<Id, ContentVersion> conMap = new Map<Id, ContentVersion>([Select ContentDocumentId FROM ContentVersion WHERE Id in: conVersionList]);
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = docChkRecordDL2.Id;
        cdl.ContentDocumentId = conMap.get(objCVDL2.Id).ContentDocumentId;
        cdl.shareType = 'V';
       // Insert cdl;
        
         //Create ContentDocumentLink 
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = docChkRecordDL.Id;
        cdl2.ContentDocumentId = conMap.get(objCVDL.Id).ContentDocumentId;
        cdl2.shareType = 'V';
       // Insert cdl2;
        ContentDocumentLink cdl3 = New ContentDocumentLink();
        cdl3.LinkedEntityId = docChkRecord.Id;
        cdl3.ContentDocumentId = conMap.get(objCV.Id).ContentDocumentId;
        cdl3.shareType = 'V';
        
        ContentDocumentLink cdl4 = New ContentDocumentLink();
        cdl4.LinkedEntityId = docChkRecord2.Id;
        cdl4.ContentDocumentId = conMap.get(objCV2.Id).ContentDocumentId;
        cdl4.shareType = 'V';
        
        ContentDocumentLink cdl5 = New ContentDocumentLink();
        cdl5.LinkedEntityId = docChkRecordAadhaar.Id;
        cdl5.ContentDocumentId = conMap.get(objCVAadhar.Id).ContentDocumentId;
        cdl5.shareType = 'V';
        
        ContentDocumentLink cdl6 = New ContentDocumentLink();
        cdl6.LinkedEntityId = docChkRecordAadhaar2.Id;
        cdl6.ContentDocumentId = conMap.get(objCVAadhar2.Id).ContentDocumentId;
        cdl6.shareType = 'V';
        
        ContentDocumentLink cdl7 = New ContentDocumentLink();
        cdl7.LinkedEntityId = docChkRecordVoter.Id;
        cdl7.ContentDocumentId = conMap.get(objCVDLVoter.Id).ContentDocumentId;
        cdl7.shareType = 'V';
        
        ContentDocumentLink cdl8 = New ContentDocumentLink();
        cdl8.LinkedEntityId = docChkRecordPassport.Id;
        cdl8.ContentDocumentId = conMap.get(objCVDLPass.Id).ContentDocumentId;
        cdl8.shareType = 'V';
        
        new List<ContentDocumentLink>{cdl,cdl2,cdl3,cdl4,cdl5,cdl6,cdl7,cdl8};
    }
    testmethod static void getLoanAppList(){
        Loan_Application__c objLoanAppl = [SELECT id, Branch_Master__r.Account_Code__c, Branch_Master__c
                                           FROM Loan_Application__c limit 1];
    Test.startTest();
        CkycInsertApi.getLoanAppList(objLoanAppl.Id);
        Test.stopTest();
    }
    testmethod static void ckycInsertApiHandlerTest(){
        Test.startTest();
        Loan_Application__c objLoanAppl = [SELECT id, Branch_Master__r.Account_Code__c, Branch_Master__c
                                           FROM Loan_Application__c limit 1];
        Applicant__c appRec = [SELECT id FROM Applicant__c Where Loan__c =: objLoanAppl.Id limit 1];
        
        CkycInsertApi.ckycInsertApiHandler(appRec.Id,objLoanAppl.Id);
        CkycInsertApi.isCKYCComplete(objLoanAppl.Id,appRec.Id);
        CkycInsertApi.isCKYCComplete('',appRec.Id);
        CkycInsertApi.delegateCKYCAPICall(appRec.Id, objLoanAppl.Id);
        Test.stopTest();
    }
    testmethod static void getApplicant(){
        Applicant__c objLoanAppl = [SELECT id FROM Applicant__c limit 1];
        Test.startTest();
        CkycInsertApi.getApplicant(objLoanAppl.Id);
        Test.stopTest();
    }
    testmethod static void getAddress(){
        Applicant__c objLoanAppl = [SELECT id FROM Applicant__c limit 1];
        Test.startTest();
        CkycInsertApi.getAddress(objLoanAppl.Id,'Permanent');
        Test.stopTest();
    }
    testmethod static void ckycInsertApi(){
        Test.setMock(HttpCalloutMock.class, new CKYCInsertMock());
        Applicant__c objLoanAppl = [SELECT id,KYC_Type__c,Aadhaar_Number__c,Voter_Id__c,Passport_Number__c,Driving_License_Id__c,Mobile_Number__c,Title__c,First_Name__c,Middle_Name__c,Last_Name__c,Father_Name__c,Spouse_Name__c,Mother_Name__c,Gender__c,Dob__c,PAN__c,Pan_Form60__c,CIF_No__c FROM Applicant__c limit 1];
        Test.startTest();
        CkycInsertApi.loanApplRec = [SELECT id, Branch_Master__c,Branch_Master__r.Account_Code__c,LAN_Created_By__c,LAN_Created_By__r.Name,LAN_Created_By__r.UserRole.Name,LAN_Creation_Date__c,Branch_Master__r.City__c FROM Loan_Application__c limit 1];
        CkycInsertApi.permanentAdd = [Select Id,Address_Source__c,Same_As__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,District__c,State__c,Pincode__c from Address__c limit 1];
        CkycInsertApi.currentAddress = [Select Id,Address_Source__c,Same_As__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,District__c,State__c,Pincode__c from Address__c limit 1];
        CkycInsertApi.appicantRec = objLoanAppl;
        try{
            new CkycInsertApi().ckycInsertApi(objLoanAppl.Id,'CkycInsertAPI');  
        } catch(Exception exp){}
        Test.stopTest();
    }
        testmethod static void ckycInsertApi2(){
        Test.setMock(HttpCalloutMock.class, new CKYCInsertMock());
        Applicant__c objLoanAppl = [SELECT id,KYC_Type__c,Aadhaar_Number__c,Voter_Id__c,Passport_Number__c,Driving_License_Id__c,Mobile_Number__c,Title__c,First_Name__c,Middle_Name__c,Last_Name__c,Father_Name__c,Spouse_Name__c,Mother_Name__c,Gender__c,Dob__c,PAN__c,Pan_Form60__c,CIF_No__c FROM Applicant__c Where KYC_Type__c = 'Aadhaar - OTP' limit 1];
        Test.startTest();
        CkycInsertApi.loanApplRec = [SELECT id, Branch_Master__c,Branch_Master__r.Account_Code__c,LAN_Created_By__c,LAN_Created_By__r.Name,LAN_Created_By__r.UserRole.Name,LAN_Creation_Date__c,Branch_Master__r.City__c FROM Loan_Application__c limit 1];
        CkycInsertApi.permanentAdd = [Select Id,Address_Source__c,Same_As__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,District__c,State__c,Pincode__c from Address__c Where Address_Source__c = 'Voter Id' limit 1];
        CkycInsertApi.currentAddress = [Select Id,Address_Source__c,Same_As__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,District__c,State__c,Pincode__c from Address__c Where Address_Source__c = 'Voter Id' limit 1];
        CkycInsertApi.appicantRec = objLoanAppl;
        try{
            new CkycInsertApi().ckycInsertApi(objLoanAppl.Id,'CkycInsertAPI');  
        } catch(Exception exp){}
        Test.stopTest();
    }
    
    testmethod static void ckycInsertUpdatedAddressTest(){
        Test.setMock(HttpCalloutMock.class, new CKYCInsertMock());
        Applicant__c objLoanAppl = [SELECT id,KYC_Type__c,Aadhaar_Number__c,Voter_Id__c,Passport_Number__c,Driving_License_Id__c,Mobile_Number__c,Title__c,First_Name__c,Middle_Name__c,Last_Name__c,Father_Name__c,Spouse_Name__c,Mother_Name__c,Gender__c,Dob__c,PAN__c,Pan_Form60__c,CIF_No__c FROM Applicant__c limit 1];
        Test.startTest();
        
        objLoanAppl.KYC_Type__c = 'Voter Id';
        update objLoanAppl;
        
        CkycInsertApi.loanApplRec = [SELECT id, Branch_Master__c,Branch_Master__r.Account_Code__c,LAN_Created_By__c,LAN_Created_By__r.Name,LAN_Created_By__r.UserRole.Name,LAN_Creation_Date__c,Branch_Master__r.City__c FROM Loan_Application__c limit 1];
        CkycInsertApi.permanentAdd = [Select Id,Address_Source__c,Same_As__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,District__c,State__c,Pincode__c from Address__c limit 1];
        CkycInsertApi.currentAddress = [Select Id,Address_Source__c,Same_As__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,District__c,State__c,Pincode__c from Address__c limit 1];
        CkycInsertApi.currentAddress.Address_Source__c = 'Voter Id';
        CkycInsertApi.appicantRec = objLoanAppl;
        try{
            new CkycInsertApi().ckycInsertApi(objLoanAppl.Id,'CkycInsertAPI');  
        } catch(Exception exp){}
        Test.stopTest();
    }
    
    testmethod static void ckycAddressProofTest(){
        CKYCInsertApi.appicantRec = [Select id, Aadhaar_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, Utility_Bills_Electricity__c,
                                     Utility_Bills_Landline_Phone__c, Utility_Bills_Water__c, NPR__c, NREGA__c from Applicant__c limit 1];
        CKYCInsertApi.setAddressProof('Aadhaar', 'ADDRESS_PROOF_POI_POA_NUMBER', 'Permanent');
        CKYCInsertApi.setAddressProof('Voter', 'ADDRESS_PROOF_POI_POA_NUMBER', 'Permanent');
        CKYCInsertApi.setAddressProof('Passport', 'ADDRESS_PROOF_POI_POA_NUMBER', 'Permanent');
        CKYCInsertApi.setAddressProof('Driving', 'ADDRESS_PROOF_POI_POA_NUMBER', 'Permanent');
        CKYCInsertApi.setAddressProof('Electricity Bill','ADDRESS_PROOF_CURRENT_ADDRESS_NUMBER', 'Current');
        CKYCInsertApi.setAddressProof('Telephone Bill', 'ADDRESS_PROOF_CURRENT_ADDRESS_NUMBER', 'Current');
        CKYCInsertApi.setAddressProof('Water Bill', 'ADDRESS_PROOF_CURRENT_ADDRESS_NUMBER', 'Current');
        CKYCInsertApi.setAddressProof('NPR', 'ADDRESS_PROOF_CURRENT_ADDRESS_NUMBER', 'Current');
        CKYCInsertApi.setAddressProof('NREGA', 'ADDRESS_PROOF_CURRENT_ADDRESS_NUMBER', 'Current');
    }
    
    testmethod static void ckycIdentityTest(){
        CKYCInsertApi.appicantRec = [Select id, Aadhaar_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, Utility_Bills_Electricity__c,
                                     Utility_Bills_Landline_Phone__c, Utility_Bills_Water__c, NPR__c, NREGA__c, KYC_Type__c from Applicant__c limit 1];
        CKYCInsertApi.setIdentityDetails('Aadhaar');
        CKYCInsertApi.setIdentityDetails('Voter');
        CKYCInsertApi.setIdentityDetails('Passport');
        CKYCInsertApi.setIdentityDetails('Driving');
        CKYCInsertApi.setIdentityDetails('NPR');
        CKYCInsertApi.setIdentityDetails('NREGA');
    }
    
    private class CKYCInsertMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            CkycInsertWrapper objResponse = new CkycInsertWrapper();
            CkycInsertWrapper.CUSTOMERS_DETAILS cD = new CkycInsertWrapper.CUSTOMERS_DETAILS();
            CkycInsertWrapper.CONTACT_DETAILS contactDetails = new CkycInsertWrapper.CONTACT_DETAILS();
            CkycInsertWrapper.ADDRESS_DETAILS addressDetails = new CkycInsertWrapper.ADDRESS_DETAILS();
            CkycInsertWrapper.PERSONAL_ENTITY_DETAILS ped = new CkycInsertWrapper.PERSONAL_ENTITY_DETAILS();
            CkycInsertWrapper.IDENTITY_DETAILS idenDetails = new CkycInsertWrapper.IDENTITY_DETAILS();
            CkycInsertWrapper.UPDATION_MODULE updattionModule = new CkycInsertWrapper.UPDATION_MODULE();
            CkycInsertWrapper.ADDRESS_DETAILS_IMG adI = new CkycInsertWrapper.ADDRESS_DETAILS_IMG();
            CkycInsertWrapper.SYSTEM_USE systemUse = new CkycInsertWrapper.SYSTEM_USE();
            CkycInsertWrapper.IMAGE_DETAILS imageDetails = new CkycInsertWrapper.IMAGE_DETAILS();
            CkycInsertWrapper.KYC_VERIFICATION kycVeri = new CkycInsertWrapper.KYC_VERIFICATION();
            
            contactDetails.MOBILE_NO = '7070707070';
            contactDetails.OFFICE_TEL_NO_STDCODE = '7070707070';
            contactDetails.OFFICE_TEL_NO = '7070707070';
            contactDetails.RESIDENCE_TEL_NO = '7070707070';
            contactDetails.MOBILE_NO_ISDCODE = '7070707070';
            contactDetails.RESIDENCE_TEL_NO_STDCODE = '7070707070';
            cD.CONTACT_DETAILS = contactDetails;
            
            addressDetails.CURRENT_ADDRESS_COUNTRY = '1312';
            addressDetails.FLAG_POI_POA_ADDR_SAME_CURRENT_ADDR = '1312';
            addressDetails.ADDRESS_PROOF_POI_POA_OTHERS = '1312';
            addressDetails.CURRENT_ADDRESS_LINE1 = '1312';
            addressDetails.ADDRESS_PROOF_POI_POA = '1312';
            addressDetails.CURRENT_ADDRESS_LINE2 = '1312';
            addressDetails.POI_POA_ADDRESS_PINCODE = '1312';
            addressDetails.CURRENT_ADDRESS_LINE3 = '1312';
            addressDetails.POI_POA_ADDRESS_COUNTRY = '1312';
            addressDetails.CURRENT_ADDRESS_C_T_V = '1312';
            addressDetails.POI_POA_ADDRESS_STATE = '1312';
            addressDetails.CURRENT_ADDRESS_DISTRICT = '1312';
            addressDetails.POI_POA_ADDRESS_DISTRICT = '1312';
            addressDetails.CURRENT_ADDRESS_STATE = '1312';
            addressDetails.POI_POA_ADDRESS_C_T_V = '1312';
            addressDetails.CURRENT_ADDRESS_PINCODE = '1312';
            addressDetails.POI_POA_ADDRESS_LINE3 = '1312';
            addressDetails.ADDRESS_PROOF_CURRENT_ADDRESS = '1312';
            addressDetails.POI_POA_ADDRESS_LINE2 = '1312';
            addressDetails.SELF_DECLARATION = '1312';
            addressDetails.POI_POA_ADDRESS_LINE1 = '1312';
            cD.ADDRESS_DETAILS = addressDetails;
            
            ped.NUMBER_OF_RELATED_PERSON = '13';
            ped.AADHAR = '13';
            ped.GENDER = '13';
            ped.DOB = '13';
            ped.MOTHER_LNAME = '13';
            ped.PAN_FORM60 = '13';
            ped.MOTHER_MNAME = '13';
            ped.MOTHER_PREFIX = '13';
            ped.FATHER_SPOUSE_LNAME = '13';
            ped.MOTHER_FNAME = '13';
            ped.FATHER_SPOUSE_MNAME = '13';
            ped.MNAME = '13';
            ped.LNAME = '13';
            ped.FNAME = '13';
            ped.NAME_OF_THE_ENTITY = '13';
            ped.PREFIX = '13';
            ped.FATHER_SPOUSE_FLAG = '13';
            ped.CKYC_FI_REF_NO = '13';
            ped.FATHER_SPOUSE_PREFIX = '13';
            ped.ACC_TYPE = '13';
            ped.FATHER_SPOUSE_FNAME = '13';
            ped.CONSTI_TYPE = '13';
            cD.PERSONAL_ENTITY_DETAILS = ped;
            
            idenDetails.IDENT_TYPE='qwe';
            idenDetails.IDPROOF_SUB_IMG_TYPE='qwe';
            idenDetails.IDPROOF_SUBMITTED='qwe';
            //idenDetails.IDPROOF_SUB_IMG_DATA=Blob.valueOf('Hello World');
            idenDetails.IDPROOF_SUB_IMG_DATA='Hello World';
            idenDetails.IDENT_NUM='qwe';
            cd.IDENTITY_DETAILS = new List<CkycInsertWrapper.IDENTITY_DETAILS>{idenDetails};
                
                updattionModule.IDENTITY_DETAILS_UPDATE_FLAG = '1243';
            updattionModule.KYC_VERIFICATION_UPDATE_FLAG = '1243';
            updattionModule.RELATED_PERSON_DETAILS_UPDATE_FLAG = '1243';
            updattionModule.REMARKS_UPDATE_FLAG = '1243';
            updattionModule.IMAGE_DETAILS_UPDATE_FLAG = '1243';
            updattionModule.CONTACT_DETAILS_UPDATE_FLAG = '1243';
            updattionModule.APPLICANT_ENTITY_UPDATE_FLAG = '1243';
            updattionModule.ADDRESS_DETAILS_UPDATE_FLAG = '1243';
            updattionModule.PERSONAL_ENTITY_DETAILS_UPDATE_FLAG = '1243';
            cD.UPDATION_MODULE = updattionModule;
            
            adI.ADDRESS_PROOF_POI_POA_NUMBER = '13';
            adI.ADDRESS_PROOF_CURRENT_ADDRESS_NUMBER = '13';
            adI.ADDRESS_PROOF_CURRENT_ADDRESS_IMG_TYPE = '13';
            //adI.ADDRESS_PROOF_POI_POA_IMGDATA = blob.valueOf('13');
            //adI.ADDRESS_PROOF_CURRENT_ADDRESS_IMGDATA = blob.valueOf('13');
            adI.ADDRESS_PROOF_POI_POA_IMGDATA = '13';
            adI.ADDRESS_PROOF_CURRENT_ADDRESS_IMGDATA = '13';
            adI.ADDRESS_PROOF_POI_POA_IMG_TYPE = '13';
            cD.ADDRESS_DETAILS_IMG = adI;    
            
            systemUse.CKYCNumber = '13213';
            systemUse.BRANCH_CODE = '13213';
            systemUse.APPLICATION_TYPE = '13213';
            cD.SYSTEM_USE = systemUse;
            
            imageDetails.IMAGE_TYPE = '132';
            imageDetails.IMAGE_CODE = '132';
            //imageDetails.IMAGE_DATA = blob.valueOf('132');
            imageDetails.IMAGE_DATA = '132';
            imageDetails.IMAGE_EXTENTION = '132';
            cD.IMAGE_DETAILS = new List<CkycInsertWrapper.IMAGE_DETAILS>{imageDetails};
                
                kycVeri.DATE_OF_DECLARATION = '1321';
            kycVeri.KYC_VERIFICATION_BRANCH = '1321';
            kycVeri.KYC_VERIFICATION_DESIGNATION = '1321';
            kycVeri.KYC_VERIFICATION_EMP_CODE = '1321';
            kycVeri.KYC_VERIFICATION_NAME = null;
            kycVeri.ORGANISATION_NAME = '1321';
            kycVeri.TYPE_OF_DOC_SUBMITTED = '1321';
            kycVeri.ORGANISATION_CODE = '1321';
            kycVeri.KYC_VERIFICATION_DATE = '1321';
            kycVeri.CUSTOMER_IDENTIFICATION_FLAG = '1321';
            kycVeri.PLACE_OF_DECLARATION = '1321';
            kycVeri.SRC_APPLICATION = '1321';
            cD.KYC_VERIFICATION = kycVeri;
            
            objResponse.CUSTOMERS_DETAILS = cD;
            objResponse.UNIQUE_REQUEST_ID = '21341414';
            objResponse.CUSTOMERS_DETAILS = null;
            String strBody = JSON.serialize(objResponse);
            res.setBody(strBody);
            res.setStatusCode(200);
            return res;
        }
    }
}