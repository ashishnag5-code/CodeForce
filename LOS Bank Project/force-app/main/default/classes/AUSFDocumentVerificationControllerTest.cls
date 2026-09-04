/*****
 * Test Class Name: AUSFDocumentVerificationControllerTest
 * Description: 
 * Class Name: AUSFDocumentVerificationController
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-27-2023          -   Mohit M.            -   remove dob from static value
 */
@isTest
public class AUSFDocumentVerificationControllerTest {
    @testSetup static void setup() {
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
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
            Branch_Master__c = branchMaster.Id
        ),true);

        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Non Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE',
            Type_Of_Employment__c='Business',
            PAN_verification_Status__c='Verified',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),true);

        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'AUWheels0008',
            Document_Name__c = 'Voter id Card',
            OCR_Document_Type__c = Label.KYC_OCR_Type_Aadhaar,
            Document_Sub_Category__c = Label.BRE_Karza_Verification_Type_KYC
        ),true);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Voter id Card',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
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
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Permanent',
            Type__c='Bungalow',
             Stability__c ='7',
            Latest_Cibil_Address_Match_Score__c=100
        ),true);
        
        //CanDo Lead Integration Master
        Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='VoterCard API',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        //CanDo Lead Integration Master
        Integration_Master__c CanDOIntegrationMaster2 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='DrivingLicenseVerification',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        //CanDo Lead Integration Master
        Integration_Master__c CanDOIntegrationMaster3 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='PassportVerification',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        Integration_Master__c CanDOIntegrationMaster4 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Karza CIN Authentication',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
    }

    static testmethod void testGetDetails(){
        Id ApplicantId = [Select Id from Applicant__c].Id;
        AUSFDocumentVerificationController.getDetails(ApplicantId);
    }
    
    static testmethod void testVerifyVoterId(){
        test.setMock(HttpCalloutMock.class, new IntegrationUtilityMockClass('nsdlVerificationHandlerUITestMethod'));
        Id ApplicantId = [Select Id from Applicant__c].Id;
        Test.startTest();
        AUSFDocumentVerificationController.verifyVoterId(ApplicantId,ApplicantId,'VoterCard API');
        Test.stopTest();
    }
    
    static testmethod void testVerifyVoterIdNegative(){
        test.setMock(HttpCalloutMock.class, new IntegrationUtilityMockClass('nsdlVerificationHandlerUITestMethodNegative'));
        Id ApplicantId = [Select Id from Applicant__c].Id;
        Test.startTest();
        AUSFDocumentVerificationController.verifyVoterId(ApplicantId,ApplicantId,'VoterCard API');
        Test.stopTest();
    }
    
    static testmethod void testVerifyDL(){
        test.setMock(HttpCalloutMock.class, new IntegrationUtilityMockClass('nsdlVerificationHandlerUITestMethod'));
        Id ApplicantId = [Select Id from Applicant__c].Id;
        Test.startTest();
        AUSFDocumentVerificationController.verifyDL(ApplicantId,ApplicantId,'DrivingLicenseVerification','01-01-1990');
        Test.stopTest();
    }
    
    static testmethod void testVerifyDLNegative(){
        test.setMock(HttpCalloutMock.class, new IntegrationUtilityMockClass('nsdlVerificationHandlerUITestMethodNegative'));
        Id ApplicantId = [Select Id from Applicant__c].Id;
        Test.startTest();
        AUSFDocumentVerificationController.verifyDL(ApplicantId,ApplicantId,'DrivingLicenseVerification','01-01-1990');
        Test.stopTest();
    }
    
    static testmethod void testVerifyPassport(){
        test.setMock(HttpCalloutMock.class, new PassportMock());
        Id ApplicantId = [Select Id from Applicant__c].Id;
        Test.startTest();
        AUSFDocumentVerificationController.verifyPassport('Passport','P8406708','01-01-1990',ApplicantId,'PassportVerification');
        Test.stopTest();
    }
    
    static testmethod void testVerifyPassportNegative(){
        test.setMock(HttpCalloutMock.class, new PassportMockNegative());
        Id ApplicantId = [Select Id from Applicant__c].Id;
        Test.startTest();
        AUSFDocumentVerificationController.verifyPassport('Passport','P8406708','01-01-1990',ApplicantId,'PassportVerification');
        Test.stopTest();
    }
    
    static testmethod void testUpdateDocumentChecklist(){
        Document_Checklist__c docC = [Select Id,Api_Response__c,Applicant__c,Document_Master__c from Document_Checklist__c];//Updated on 20 SEP
        AUSFDocumentVerificationController.updateDocumentChecklist(docC,'Verified','Jaipur, RJ, 302026');
        AUSFDocumentVerificationController.updateDocumentRetryChecklist(docC,'Not Verified','Jaipur, RJ, 302026'); //Added on 20 SEP
    }
    static testmethod void testUpdateDocumentChecklistException(){
        Document_Checklist__c docC = [Select Id,Api_Response__c,Applicant__c,Document_Master__c from Document_Checklist__c];//Updated on 20 SEP
        docC.Id=null;
        AUSFDocumentVerificationController.updateDocumentChecklist(docC,'Verified','Jaipur, RJ, 302026');
        AUSFDocumentVerificationController.updateDocumentRetryChecklist(docC,'Not Verified','Jaipur, RJ, 302026');//Added on 20 SEP
        AUSFDocumentVerificationController.getCount(docC);//Added on 20 SEP
    }
    
    static testmethod void testMapUdhyamAddress(){
        Document_Checklist__c docC = [Select Id,Api_Response__c from Document_Checklist__c];
        UdyamAuthHandler.OfficialAddress address = new UdyamAuthHandler.OfficialAddress();
        address.city='Jaipur';
        address.state='Rajasthan';
        address.pincode='302026';
        address.district='Jaipur';
        address.flat='F1';
        address.premises='Manglam Ananda';
        address.block='B Block';
        address.road='Muhana Mandi';
        address.village='Sanganer';
        address.mobile='';
        address.email='';
        AUSFDocumentVerificationController.mapUdhyamAddress(docC,'Verified',address);
    }
    
    static testmethod void testMapVoterIdAddress(){
        Document_Checklist__c docC = [Select Id,Api_Response__c from Document_Checklist__c];
        AUSFVoterResponseWrapper.Result result = new AUSFVoterResponseWrapper.Result();
        result.house_no = '5';
        result.state='Rajasthan';
        result.pin='302026';
        result.district='Jaipur';
        AUSFDocumentVerificationController.mapVoterIdAddress(docC,'Verified',result);
    }
    static testmethod void testMapAddresses(){
        Document_Checklist__c docC = [Select Id,Api_Response__c from Document_Checklist__c];
        Id ApplicantId = [Select Id from Applicant__c].Id;
        AUSFDocumentVerificationController.mapAddresses(docC,'Verified','Jaipur, RJ, 302026',ApplicantId,'');
    }
    static testmethod void testUpdateResponseOnDocument(){
        Id ApplicantId = [Select Id from Applicant__c].Id;
        Id loanAppId = [Select Id from Loan_Application__c].Id;
        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'AUWheels0009',
            Document_Name__c = 'Pan Card/Form 60'
        ),true);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppId,
            Applicant__c = ApplicantId,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Pan Card/Form 60',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),true);
        AUSFDocumentVerificationController.updateResponseOnDocument(JSON.serialize(docChkRecord));
        docChkRecord.Id=null;
        AUSFDocumentVerificationController.updateResponseOnDocument(JSON.serialize(docChkRecord));
    }
    
    static testmethod void testUpdatePassportKYCDetails(){
        Applicant__c applicant = [Select Id from Applicant__c];
        AUSFPassportResponseWrapper.Result result = new AUSFPassportResponseWrapper.Result();
        AUSFPassportResponseWrapper.Name nameObj = new AUSFPassportResponseWrapper.Name();
        nameObj.nameFromPassport='JS';
        nameObj.surnameFromPassport='BS';
        result.name = nameObj;
        AUSFDocumentVerificationController.updatePassportKYCDetails(JSON.serialize(result),applicant.Id);
        applicant.First_Name__c=null;
        applicant.Last_Name__c=null;
        update applicant;
        AUSFDocumentVerificationController.updatePassportKYCDetails(JSON.serialize(result),applicant.Id);
        applicant.Aadhaar_number__c = '123412341242';
        update applicant;
        AUSFDocumentVerificationController.updatePassportKYCDetails(JSON.serialize(result),applicant.Id); 
    }
    
    static testmethod void testUpdateDLKYCDetails(){
        Applicant__c applicant = [Select Id from Applicant__c];
        AUSFDrivingLicenseResponseWrapper.Result result = new AUSFDrivingLicenseResponseWrapper.Result();
        result.name ='JJ JK JJ';
        result.dob = '01-01-1990';
        result.dl_number = '1231213';
        result.fatherhusband = 'lkskef';
        result.issue_date = '01-01-2020';
        result.blood_group = 'B-';
        result.address = 'jaipur, rj';
        try{
          AUSFDocumentVerificationController.updateDLKYCDetails(JSON.serialize(result),applicant.Id);  
        }catch(Exception exp){}
        applicant.First_Name__c=null;
        applicant.Last_Name__c=null;
        update applicant;
        try{
          AUSFDocumentVerificationController.updateDLKYCDetails(JSON.serialize(result),applicant.Id);  
        }catch(Exception exp){}
        applicant.Aadhaar_number__c = '123412341242';
        update applicant;
        AUSFDocumentVerificationController.updateDLKYCDetails(JSON.serialize(result),applicant.Id); 
        
    }
    
    
    static testmethod void testGetMetadataRecord(){
        AUSFDocumentVerificationController.getMetadataRecord('Gas Bill');
    }
    
    static testmethod void testUpdateKYCDetails(){
        Applicant__c applicant = [Select Id from Applicant__c];
        AUSFVoterResponseWrapper.Result result = new AUSFVoterResponseWrapper.Result();
        result.name = 'dfs sdf sd';
        result.rln_name = 'sdfs sd';
        result.gender = 'M';
        result.dob = '01-01-1990';
        AUSFDocumentVerificationController.updateKYCDetails(JSON.serialize(result),applicant.Id);
        applicant.Aadhaar_number__c = '123412341242';
        update applicant;
        AUSFDocumentVerificationController.updateDLKYCDetails(JSON.serialize(result),applicant.Id); 
    }
    
    static testmethod void testUpdateKYCDetailsNoAddress(){
        delete [Select Id from Address__c];
        Applicant__c applicant = [Select Id from Applicant__c];
        AUSFVoterResponseWrapper.Result result = new AUSFVoterResponseWrapper.Result();
        result.name = 'dfs sdf sd';
        result.rln_name = 'sdfs sd';
        result.gender = 'M';
        result.dob = '01-01-1990';
        AUSFDocumentVerificationController.updateKYCDetails(JSON.serialize(result),applicant.Id);
    }
    
    static testmethod void testVerifyGST(){
        test.setMock(HttpCalloutMock.class, new IntegrationUtilityMockClass('nsdlVerificationHandlerUITestMethod'));
        try{
            Applicant__c applicant = [Select Id from Applicant__c];
            Loan_Application__c loanAppl = [Select Id from Loan_Application__c];
            //CanDo Lead Integration Master
            Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
                Name ='Karza GST Authentication',
                End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
                Apiuser__c ='SFDC',
                API_Key__c ='epikey',
                HTTP_Method__c='POST',
                Timeout__c='120000',
                Active__c = true
            ),true);
            Integration_Checklist__c  intChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
                is_Latest__c = true,
                Applicant__c= applicant.Id,
                Request_Id__c='IC001001002',
                Integration_Master__c = CanDOIntegrationMaster.Id,
                Loan_Application__c = loanAppl.Id,
                Callback_Request__c = '{"message":{"requestTime":"Jun 23, 2023 12:48:46.873 PM IST","dmElapsedTime":90,"responseStatus":"ERROR","error":[{"errorCode":"401","description":"Bad Request"}]}}'
            ),true);
            Test.startTest();
            AUSFDocumentVerificationController.verifyGST('22AAAAA0000A1Z5',applicant.Id);
            Test.stopTest();
        } catch(Exception exp){}
        
    }
    
    static testmethod void testVerifyCIN(){
        Test.setMock(HttpCalloutMock.class, new CINMock());
        try{
            Applicant__c applicant = [Select Id from Applicant__c];
            Test.startTest();
            AUSFDocumentVerificationController.verifyCIN('L17110MH1973PLC019786',applicant.Id);
            Test.stopTest();
            new CINAuthHandler().generateJSONResponse(null);
        } catch(Exception exp){}
    }
    
    static testmethod void testVerifyUdyam(){
        Test.setMock(HttpCalloutMock.class, new CINMock());
        try{
            Applicant__c applicant = [Select Id from Applicant__c];
            Test.startTest();
            AUSFDocumentVerificationController.verifyUdyam('UDYAM-UP-00-0123456',applicant.Id);
            Test.stopTest();
        } catch(Exception exp){}
    }
    static testmethod void testAUSFDrivingLicenseResponseWrapper(){
        AUSFDrivingLicenseResponseWrapper.parse('{"request_id":"123123123","statusCode":200}');
    }
    
    static testmethod void testAUSFPassportResponseWrapper(){
        AUSFPassportResponseWrapper.parse('{"request_id":"123123123","statusCode":200}');
    }
    
    static testmethod void testAUSFVoterResponseWrapper(){
        AUSFVoterResponseWrapper.parse('{"requestId":"123123123","statusCode":200}');
    }
    
    static testmethod void testUdyamAuthHandler(){
        UdyamAuthHandler.parse('{"request_id":"123123123","statusCode":200}');
        Map<String,String> reqParam = new Map<String,String>();
        reqParam.put('udyamNo','123213');
        UdyamAuthHandler.generateRequest(reqParam);
        UdyamAuthHandler obj = new UdyamAuthHandler();
        obj.generateJSONResponse(null);
    }

    private class CINMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            CINAuthHandler.CINResponseWrapper objResponse = new CINAuthHandler.CINResponseWrapper();
            CINAuthHandler.CINResponseWrapperResult cinRW = new CINAuthHandler.CINResponseWrapperResult();
            cinRW.cin='213123';
            cinRW.authorised_Capital='ok';
            cinRW.class_of_Company='ok';
            cinRW.company_Category='ok';
            cinRW.company_Name='ok';
            cinRW.company_Status='Active';
            cinRW.email_Id='ok@ok.ok';
            cinRW.paid_up_Capital='ok';
            cinRW.registered_Address='ok';
            objResponse.statusCode='200';
            objResponse.statusMessage='SUCCESS';
            objResponse.result = cinRW;
            String strBody = JSON.serialize(objResponse);
            strBody = strBody.replace('"authorised_Capital":','"Authorised_Capital(Rs)":');
            strBody = strBody.replace('"paid_up_Capital":','"Paid_up_Capital(Rs)":');
            res.setBody(strBody);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class PassportMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            AUSFPassportResponseWrapper objResponse = new AUSFPassportResponseWrapper();
            AUSFPassportResponseWrapper.Result result = new AUSFPassportResponseWrapper.Result();
            AUSFPassportResponseWrapper.DateOfIssue doi = new AUSFPassportResponseWrapper.DateOfIssue();
            doi.dateOfIssueMatch = true;
            doi.dispatchedOnFromSource = '01-01-2023';
            AUSFPassportResponseWrapper.PassportNumber pn = new AUSFPassportResponseWrapper.PassportNumber();
            pn.passportNumberFromSource = 'P120453';
            pn.passportNumberMatch = true;
            AUSFPassportResponseWrapper.Name name = new AUSFPassportResponseWrapper.Name();
            name.surnameFromPassport = 'Ku';
            name.nameScore = 100;
            name.nameFromPassport = 'AKN';
            name.nameMatch = true;
            result.typeOfApplication = 'OK';
            result.applicationDate = '01-01-2023';
            result.passportNumber = pn;
            result.name = name;
            result.dateOfIssue = doi;
            objResponse.requestId='123';
            objResponse.statusCode=200;
            objResponse.result = result;
            String strBody = JSON.serialize(objResponse);
            res.setBody(strBody);
            res.setStatusCode(200);
            return res;
        }
        
        
    }
    
    private class PassportMockNegative implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            AUSFPassportResponseWrapper objResponse = new AUSFPassportResponseWrapper();
            AUSFPassportResponseWrapper.Result result = new AUSFPassportResponseWrapper.Result();
            AUSFPassportResponseWrapper.DateOfIssue doi = new AUSFPassportResponseWrapper.DateOfIssue();
            doi.dateOfIssueMatch = true;
            doi.dispatchedOnFromSource = '01-01-2023';
            AUSFPassportResponseWrapper.PassportNumber pn = new AUSFPassportResponseWrapper.PassportNumber();
            pn.passportNumberFromSource = 'P120453';
            pn.passportNumberMatch = true;
            AUSFPassportResponseWrapper.Name name = new AUSFPassportResponseWrapper.Name();
            name.surnameFromPassport = 'Ku';
            name.nameScore = 100;
            name.nameFromPassport = 'AKN';
            name.nameMatch = true;
            result.typeOfApplication = 'OK';
            result.applicationDate = '01-01-2023';
            result.passportNumber = pn;
            result.name = name;
            result.dateOfIssue = doi;
            objResponse.requestId='123';
            objResponse.statusCode=400;
            objResponse.result = result;
            String strBody = JSON.serialize(objResponse);
            res.setBody(strBody);
            res.setStatusCode(400);
            return res;
        }
        
        
    }

}