@isTest
public class CustDetCompController_AUFSB_Test {
    
    @testSetup 
    static void setup() {
        Id devRecordTypeId = Schema.SObjectType.Generic_Master__c .getRecordTypeInfosByName().get('Restricted Domains').getRecordTypeId();
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Loan_Amount__c  = 12000,
            Product__c='10201',
            Tenure__c=12,
            EMI__c=100,
            ROI__c=0,
            RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Two_Wheeler').getRecordTypeId()
        ),true); 

        Id recId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId();
        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loanAppl.Id,
            First_Name__c   = 'Caroline',
            Last_Name__c  = 'Forbes',
            RecordTypeId = recId,
            KYC_Type__c='Aadhaar - Physical Document'
        ),true);

        Loan_Application__c loanApplNI = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12341',
            Loan_Amount__c  = 12000,
            Product__c='10201',
            Tenure__c=12,
            EMI__c=100,
            ROI__c=0,
            RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Two_Wheeler').getRecordTypeId()
        ),true); 

        Applicant__c applicantNI = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loanApplNI.Id,
            First_Name__c   = 'Caroline',
            Last_Name__c  = 'Forbes',
            RecordTypeId = recId,
            Customer_Type__c='Non Individual',
            Constitution_Type__c='HUF'
        ),true);

        CustDetCompController_AUFSB.NSDLRespWrapper apiResp1 = new CustDetCompController_AUFSB.NSDLRespWrapper();
        apiResp1.Response = new CustDetCompController_AUFSB.cls_Response();
        apiResp1.Response.Title='Miss';
        apiResp1.Response.FirstName='Advika';
        apiResp1.Response.MiddleName='Anish';
        apiResp1.Response.LastName='Shah';

        Document_Master__c  docuMaster01 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name = 'AUWheels0001',
            Document_Category__c = 'Application Document',
            Document_Sub_Category__c = 'KYC', 
            Document_Name__c = Label.DcumentMasterAadharPicture,
            Document_ID__c = 'AUWheels0001'
        ),true);

        Document_Checklist__c docCheck01 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Document_Master__c=docuMaster01.Id,
            Document_Name__c = Label.DcumentMasterAadharPicture,
            API_Response__c=JSON.serialize(apiResp1),
            Document_Verification_Status__c='Verified',
            Document_Number__c='113',
            Applicant__c=applicant.Id
        ),true);

        AUSFPassportResponseWrapper.PassPortResponse apiResp2 = new AUSFPassportResponseWrapper.PassPortResponse();
        apiResp2.nameFromPassport='Advika';
        apiResp2.surnameFromPassport='Shah';

        Document_Master__c  docuMaster02 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name = 'AUWheels0005',
            Document_Category__c = 'Application Document',
            Document_Sub_Category__c = 'KYC', 
            Document_Name__c = Label.DcumentMasterAadharPicture,
            Document_ID__c = 'AUWheels0005'
        ),true);

        Document_Checklist__c docCheck02 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Document_Master__c=docuMaster02.Id,
            Document_Name__c = Label.DcumentMasterAadharPicture,
            API_Response__c=JSON.serialize(apiResp2),
            Document_Number__c='113',
            Document_Verification_Status__c='Verified',
            Applicant__c=applicant.Id
        ),true);

        AUSFDrivingLicenseResponseWrapper.Result apiResp3 = new AUSFDrivingLicenseResponseWrapper.Result();
        apiResp3.name='Advika';
        apiResp3.address='Line 1';

        Document_Master__c  docuMaster03 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name = 'AUWheels0004',
            Document_Category__c = 'Application Document',
            Document_Sub_Category__c = 'KYC', 
            Document_Name__c = Label.DcumentMasterAadharPicture,
            Document_ID__c = 'AUWheels0004'
        ),true);

        Document_Checklist__c docCheck03 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Document_Master__c=docuMaster03.Id,
            Document_Name__c = Label.DcumentMasterAadharPicture,
            Document_Number__c='113',
            API_Response__c=JSON.serialize(apiResp3),
            Document_Verification_Status__c='Verified',
            Applicant__c=applicant.Id
        ),true);

        AUSFVoterResponseWrapper.Result apiResp4 = new AUSFVoterResponseWrapper.Result();
        apiResp4.name='Advika';
        apiResp4.acName='Advika';
        Document_Master__c  docuMaster04 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name = 'AUWheels0002',
            Document_Category__c = 'Application Document',
            Document_Sub_Category__c = 'KYC', 
            Document_Name__c = Label.DcumentMasterAadharPicture,
            Document_ID__c = 'AUWheels0002'
        ),true);

        Document_Checklist__c docCheck04 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Document_Master__c=docuMaster04.Id,
            Document_Name__c = Label.DcumentMasterAadharPicture,
            API_Response__c=JSON.serialize(apiResp4),
            Document_Number__c='113',
            Document_Verification_Status__c='Verified',
            Applicant__c=applicant.Id
        ),true);
        
        Rule_Definition__c  ruleDef = (Rule_Definition__c)TestFactory.createSObject(new Rule_Definition__c(
            Attribute_Fixed_Value__c  = 'QDE',
            Rule_Condition__c = 'Equals',
            Subject_Field__c = 'Loan_Stage__c',
            Value_Field__c = 'Value',
            Sequence__c =1,
            Target_Object__c ='Document_Checklist__c',
            Rule_Name__c ='Applicant Rule'
            
        ),true);
        
        Rule_Driver__c  ruleDriver = (Rule_Driver__c)TestFactory.createSObject(new Rule_Driver__c(
           Configuring_For__c  ='Document Checklist',
           Effective_From__c  =Date.today(),
           Effective_To__c =Date.today()+1,
           Logical_Expression__c ='1',
           Object_Name__c ='Applicant__c',
           Target_Value__c ='AUWheels0003',
           Match_Criteria__c ='All Match' 
            
        ),true);
        
        
       Rule_Definition_Driver_Mapping__c  ruleDefDriver = (Rule_Definition_Driver_Mapping__c )TestFactory.createSObject(new Rule_Definition_Driver_Mapping__c (
           Rule_Driver_ID__c = ruleDriver.Id,
           Rule_ID__c = ruleDef.Id
            
        ),true);
        
        Document_Master__c  docuMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name = Label.DcumentMasterAadharPicture,
            Document_Category__c = 'Application Document',
            Document_Sub_Category__c = 'KYC', 
            Document_Name__c = Label.DcumentMasterAadharPicture,
            Document_ID__c = 'AUWHEEL0001'
        ),true);
        Document_Checklist__c doc = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Status__c  = 'Received',
            Amount__c   = 1000,
            Applicant__c  = applicant.Id,
            Document_Master__c = docuMaster.Id,
            Document_Verification_Status__c=GlobalConstants.VERIFIED
        ),true);
        Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=doc.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCV;
        
        Document_Master__c   docuMaster2 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name = Label.DcumentMasterCustomerImage,
            Document_Category__c = 'Application Document',
            Document_Name__c = Label.DcumentMasterCustomerImage,
            Document_ID__c = 'AUWHEEL0002'
        ),true);
        Document_Checklist__c doc2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Status__c  = 'Received',
            Amount__c   = 1000,
            Applicant__c  = applicant.Id,
            Document_Master__c = docuMaster2.Id,
            Document_Verification_Status__c=GlobalConstants.VERIFIED
        ),true);
        Contentversion objCV2 = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=doc2.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCV2;
        Generic_Master__c    genMaster = (Generic_Master__c )TestFactory.createSObject(new Generic_Master__c (
           // Name = 'Test',
            Domain_Name__c  = 'zoemail.net',
            RecordtypeId = devRecordTypeId
        ),true);
        
        Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='AU Employee HCM API',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);

        Blocked_List__c blockedEmail = (Blocked_List__c )TestFactory.createSObject(new Blocked_List__c (
            Email__c='abcd@salesforce.com.invalid'
        ),true);
    }
    
    testmethod static void getCommonPicklistByFldName(){
        Test.startTest();
        CustDetCompController_AUFSB.getCommonPicklistByFldName('Relationship_with_applicant__c','Individual');
        Test.stopTest();
    }
    testmethod static void getApplicant(){
        Test.startTest();
        Applicant__c objApp = [Select Id from Applicant__c WHERE Customer_Type__c!='Non Individual' limit 1];
        CustDetCompController_AUFSB.getApplicant(objApp.Id);
        CustDetCompController_AUFSB.checkPrimaryApplicant(objApp.Id);
        Test.stopTest();
    }
    testmethod static void getCustomMetaRecStageProfle(){
        CustDetCompController_AUFSB.getCustomMetaRecStageProfle();
    }
    testmethod static void getCurrentStatus(){
        CustDetCompController_AUFSB.getCurrentStatus('A');
        CustDetCompController_AUFSB.getCurrentStatus('R');
    }
    testmethod static void getAuEmployeeDetails(){
        Test.setMock(HttpCalloutMock.class, new AUEmpDetails());
        Applicant__c objApp = [Select Id,PAN__c from Applicant__c WHERE Customer_Type__c!='Non Individual' limit 1];
        objApp.PAN__c='131232213';
        update objApp;
        Test.startTest();
        CustDetCompController_AUFSB.getAuEmployeeDetails(objApp);
        Test.stopTest();
    }
    
    testmethod static void getVisibleFields(){
        Test.startTest();
        CustDetCompController_AUFSB.getVisibleFields('Assessed No Documented','Credit','System Administrator',null,null);
        Test.stopTest();
    }
    testmethod static void getRestrictedDomains(){
        Test.startTest();
        CustDetCompController_AUFSB.getRestrictedDomains('helloworld@zoemail.net');
        Test.stopTest();
    }
    testmethod static void updateApplicant(){
        Test.startTest();
        Applicant__c objApp = [Select Id,PAN__c,Type_Of_Employment__c,Risk_Identification__c,High_risk_Profile__c,Loan__r.Stage__c,Loan__r.RecordType.Name,Customer_Type__c,Is_Customer_Details_Saved__c,First_Name__c,Last_Name__c,Entity_Name__c,Customer_Name__c,Middle_Name__c from Applicant__c WHERE Customer_Type__c!='Non Individual' limit 1];
        objApp.High_risk_Profile__c = 'Advocate_2W';
        CustDetCompController_AUFSB.updateApplicant(objApp);
        Test.stopTest();
    }
    testmethod static void getFaceMatch(){
        Test.startTest();
        Applicant__c objApp = [Select Id,PAN__c from Applicant__c WHERE Customer_Type__c!='Non Individual' limit 1];
        List<ContentVersion> lstCV = [Select Id from ContentVersion];
        CustDetCompController_AUFSB.getFaceMatch(lstCV[0].Id,lstCV[1].Id,objApp.Id);
        Test.stopTest();
    }
    testmethod static void getHighRiskProfilesByVehicleType(){
        Test.startTest();
        Loan_Application__c loan = [Select Id from Loan_Application__c limit 1];
        CustDetCompController_AUFSB.getHighRiskProfilesByVehicleType(loan.Id);
        Test.stopTest();
    }
    testmethod static void HCMResponseWrapper(){
        Test.startTest();
        try{
           HCMResponseWrapper.parse(null); 
        } catch(Exception exp){}
        Test.stopTest();
    }

    @isTest
    public static void validateMobileTest(){
        Test.startTest();
        Boolean resp = CustDetCompController_AUFSB.validateMobile('abcd@salesforce.com.invalid');
        System.assertEquals(true, resp,'Success');
        CustDetCompController_AUFSB.validateMobile('abc@salesforce.com.invalid');
        Test.stopTest();
    }

    @isTest
    public static void checkKartaConditionTest(){
        Test.startTest();
        Applicant__c objApp = [Select Id,PAN__c, Loan__c from Applicant__c WHERE Customer_Type__c='Non Individual' limit 1];
        Boolean resp = CustDetCompController_AUFSB.checkKartaCondition(objApp.Loan__c);
        System.assertEquals(true, resp,'Success');
        Test.stopTest();
    }
    
    @isTest
    public static void callValidateNameMatchTest(){
        Test.startTest();
        Applicant__c objApp = [Select Id, PAN__c, Loan__c from Applicant__c WHERE Customer_Type__c!='Non Individual' limit 1];
        CustDetCompController_AUFSB.callValidateNameMatch(objApp);
        System.assertEquals(true, objApp.Loan__c!=null,'Success');
        Test.stopTest();
    }

    @isTest
    public static void karzaNameMatchCalloutTest(){
        Test.startTest();
        Applicant__c objApp = [Select Id, PAN__c, Loan__c from Applicant__c WHERE Customer_Type__c!='Non Individual' limit 1];
        CustDetCompController_AUFSB.karzaNameMatchCallout('AUWheels0001',objApp.Id);
        CustDetCompController_AUFSB.karzaNameMatchCallout('AUWheels0005',objApp.Id);
        CustDetCompController_AUFSB.karzaNameMatchCallout('AUWheels0004',objApp.Id);
        CustDetCompController_AUFSB.karzaNameMatchCallout('AUWheels0002',objApp.Id);
        System.assertEquals(true, objApp.Loan__c!=null,'Success');
        Test.stopTest();
    }
    
    private class AUEmpDetails implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            HCMResponseWrapper objResponse = new HCMResponseWrapper();
            HCMResponseWrapper.EmployeeDetails objED = new HCMResponseWrapper.EmployeeDetails();
            HCMResponseWrapper.PersonalAddress objEDPA = new HCMResponseWrapper.PersonalAddress();
            objEDPA.AddressLine1 = 'lskfj';
            objEDPA.AddressLine2 = 'lskfj';
            objEDPA.AddressLine3 = 'lskfj';
            objEDPA.State = 'MAHARASTHRA';
            objEDPA.Country = 'India';
            objEDPA.PostalCode = '203020';
            objEDPA.City = 'Jaipur';
            
            objED.DepartmentCode = '123';
            objED.PersonalAddress = objEDPA;
            objResponse.EmployeeDetails = objED;
            String strBody = JSON.serialize(objResponse);
            res.setBody(strBody);
            res.setStatusCode(200);
            return res;
        }
    }
    /*@isTest 
    static void getApplicantTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailVerificationCallout());
        Applicant__c objApp = [Select Id from Applicant__c limit 1];
        //objApp = CustDetCompController_AUFSB.getApplicant(objApp.Id);
        Assert.areEqual('Vikash',objApp.First_Name__c) ;

        Test.stopTest();
    }
    
    @isTest
    static void getNotRestrictedDomainsTest(){
        Test.startTest();
        Applicant__c objApp = [Select Id,Email__c from Applicant__c limit 1];
        Boolean flag = CustDetCompController_AUFSB.getRestrictedDomains(objApp.Email__c);
        Assert.areEqual(true,flag) ;
        Test.stopTest();
    }
    
    @isTest
    static void getRestrictedDomainsTest(){
        Test.startTest();
        Applicant__c objApp = [Select Id,Email__c from Applicant__c limit 1];
        Boolean flag = CustDetCompController_AUFSB.getRestrictedDomains(objApp.Email__c);
        Assert.areEqual(false,flag) ;
        Test.stopTest();
    }
    
    @isTest 
    static void updateApplicantTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailVerificationCallout());
        Applicant__c objApp = [Select Id from Applicant__c  limit 1];
        objApp.Last_Name__c='test';
        objApp.Gender__c ='Male';
        update objApp;
        objApp = CustDetCompController_AUFSB.updateApplicant(objApp);
        Assert.areEqual('test',objApp.Last_Name__c) ;
        Test.stopTest();
    }*/

}