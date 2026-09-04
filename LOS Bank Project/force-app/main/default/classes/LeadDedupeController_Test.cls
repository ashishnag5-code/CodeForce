/*****
 * Class Name: LeadDedupeController_Test
 * Class Name: LeadDedupeController
 * Logs ---- 
 * LastModified Date    -   Last Modified By    -   Description / Bug
 * Aug-26-2023          -   Mohit M.            -   Work on Code Coverage
 */
@isTest
public class LeadDedupeController_Test {
    @testSetup 
    static void setup() {
        
        List<Document_Master__c> lstDocumentMaster = new List<Document_Master__c>();
        Document_Master__c docuMaster1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Id__c = 'AUWheels0001',
            Document_Name__c = 'Pan Card/Form 60'
        ), false);
        lstDocumentMaster.add(docuMaster1);
        
        docuMaster1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Id__c = 'AUWheels0003',
            Document_Name__c = 'Aadhaar Card'
        ), false);
        lstDocumentMaster.add(docuMaster1);
        insert lstDocumentMaster;
       
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c='PSD',
            Total_Loan_Amount__c = 100000,
            recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Four_Wheeler').getRecordTypeId()
            
        ), false);
        Loan_Application__c loanAppl3 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c='PSD',
            Total_Loan_Amount__c = 100000,
            recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Four_Wheeler').getRecordTypeId()
            
        ), false);
        Loan_Application__c loanAppl1 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10202',
            Stage__c='QDE',
            recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Four_Wheeler').getRecordTypeId()
        ),false);
        Loan_Application__c loanAppl2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c='Cancelled',
            Total_Loan_Amount__c = 100000,
            recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Four_Wheeler').getRecordTypeId()
            
        ),false);
        insert new List<Loan_Application__c> {loanAppl, loanAppl3, loanAppl1, loanAppl2};
        List<Applicant__c> lstApp = new List<Applicant__c>();
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            Customer_Type__c = 'Individual'
            
        ),false);
        lstApp.add(appl);
        Applicant__c app2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c = loanAppl3.Id,
            Customer_Type__c = 'Individual',
            Voter_Id__c = '1212121212',
            Passport_Number__c = '12121212',
            Driving_License_Id__c = '1212121212',
            NREGA__c = '1212121212'
        ),false);
        lstApp.add(app2);
        
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash1',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal1',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '',
            PAN__c = '',
            Loan__c =loanAppl1.Id,
            Customer_Type__c = 'Individual'
            
        ),false);
        lstApp.add(appl1);
        Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash2',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal2',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '',
            Loan__c =loanAppl1.Id,
            Customer_Type__c = 'Individual'
            
        ),false);
        lstApp.add(appl2);
        Applicant__c appl3 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash3',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal3',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            Customer_Type__c = 'Individual'
            
        ),false);
        lstApp.add(appl3);
        Applicant__c appl4 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash1',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal1',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '',
            PAN__c = '',
            Loan__c =loanAppl2.Id,
            Customer_Type__c = 'Individual'
            
        ),false);
        lstApp.add(appl4);
        insert lstApp;
        
        List<Document_Checklist__c> lstInsertDocCheck = new List<Document_Checklist__c>();
        for (Applicant__c objApp : lstApp) {
            for (Document_Master__c objDocM : lstDocumentMaster) {
                Document_Checklist__c doc = new Document_Checklist__c(Active__c  = true, Applicant__c = objApp.Id, Document_Master__c = objDocM.Id);
                lstInsertDocCheck.add(doc);
            }
        }
        if (lstInsertDocCheck.size()>0)
            insert lstInsertDocCheck;
        
        
        Integration_Master__c intmassearch = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Customer Dedupe',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/CustomerService/SearchCustomer',
            HTTP_Method__c = 'GET',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),false);
        Integration_Master__c intloanODDetail = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Loan OD Detail',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/CustomerService/SearchCustomer',
            HTTP_Method__c = 'GET',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),false);
        Integration_Master__c intmasdetail = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Customer Dedupe Detail',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/CustomerService/getCustomer360Details',
            HTTP_Method__c = 'GET',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),false);
        Integration_Master__c intmasquery = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Lead to Lead Dedupe',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/CustomerService/getCustomer360Details',
            HTTP_Method__c = 'GET',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),false);
        Integration_Master__c intmasdetailCC = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Customer Dedupe Credit Card',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/CustomerService/getCustomer360Details',
            HTTP_Method__c = 'GET',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),false);
        Integration_Master__c intmasdetailSF = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Lead Dedupe SF',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/CustomerService/getCustomer360Details',
            HTTP_Method__c = 'GET',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),false);
        insert new List<Integration_Master__c>{intmasdetailCC, intmasquery, intmasdetail, intmassearch, intloanODDetail, intmasdetailSF};
        Integration_Checklist__c intChkLst= (Integration_Checklist__c)TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Applicant__c= appl.Id,
            Request_Id__c='IC001001002',
            Integration_Master__c = intmassearch.Id,
            Loan_Application__c = loanAppl.Id,
            Callback_Request__c = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":{"code":"0"}}},"ErrorCode":"0","MatchFound":{"Customer":[{"CustomerID":"27987636","PAN":"AJGPC1504N","MobileNumber":"7777777777","LandlineResidenceNumber":"2532532532","CustomerFullName":"MAYANT SHARMA","DateOfBirth":"2000-06-03","DateOfIncorporation":"2000-06-03","MotherMaidenName":"ASFASFASFA","Address":{"Line1":"DSFAF","Line2":"ASFAF","Line3":"AFAFAFA","City":"DELHI","State":"DELHI","Country":"INDIA","Zip":"110001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28582366","AadhaarNumber":"297396052345","MobileNumber":"7777777777","CustomerFullName":"Ritesh Keshiya","DateOfBirth":"2001-06-21","DateOfIncorporation":"2001-06-21","Address":{"Line1":"kjhkjhkjhhjnull","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28582808","AadhaarNumber":"786767576567","MobileNumber":"7777777777","CustomerFullName":"Applicant LastName","DateOfBirth":"1993-06-10","DateOfIncorporation":"1993-06-10","Address":{"Line1":"hgjhgkgkgkjhjhnull","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28582887","AadhaarNumber":"251317415353","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"1981-06-04","DateOfIncorporation":"1981-06-04","Address":{"Line1":"gjghhjghjghjnull","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28582890","AadhaarNumber":"736985739745","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"1979-05-31","DateOfIncorporation":"1979-05-31","Address":{"Line1":"khkhkjhkjhkjhnull","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28583018","AadhaarNumber":"394759837495","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"1995-06-01","DateOfIncorporation":"1995-06-01","Address":{"Line1":"kjhkjhhkjhkjnull","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28583412","AadhaarNumber":"938479857394","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"1996-06-01","DateOfIncorporation":"1996-06-01","Address":{"Line1":"hgjhgkgkgkjhjhnull","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28583653","AadhaarNumber":"349875837495","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"1998-06-01","DateOfIncorporation":"1998-06-01","Address":{"Line1":"hgjhgkgkgkjhjhnull","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28583840","AadhaarNumber":"394759374598","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"2001-06-01","DateOfIncorporation":"2001-06-01","Address":{"Line1":"hgjhgkgkgkjhjhnull","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28584262","AadhaarNumber":"347593874958","MobileNumber":"7777777777","CustomerFullName":"COApplicant Last","DateOfBirth":"2001-07-13","DateOfIncorporation":"2001-07-13","Address":{"Line1":"Current address line 1 CoAppl","Line2":"icantCurrent address line 2 Co","Line3":"Applicantnull","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380002"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28584733","AadhaarNumber":"394875938479","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"2004-07-01","DateOfIncorporation":"2004-07-01","Address":{"Line1":"Permanent Line 1Permanent Lin","Line2":"e 2","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28584734","AadhaarNumber":"934753875983","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"2000-06-26","DateOfIncorporation":"2000-06-26","Address":{"Line1":"Permanent Line 1Permanent Lin","Line2":"e 2","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28584743","AadhaarNumber":"345353645645","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"1995-06-01","DateOfIncorporation":"1995-06-01","Address":{"Line1":"khkjhkjhkhj","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28584744","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"2001-07-05","DateOfIncorporation":"2001-07-05","Address":{"Line1":"Permanent Line 1Permanent Lin","Line2":"e 2","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28584745","PAN":"EDFPN7890R","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"2001-07-05","DateOfIncorporation":"2001-07-05","Address":{"Line1":"Permanent Line 1Permanent Lin","Line2":"e 2","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28584754","AadhaarNumber":"293768236874","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"1996-07-04","DateOfIncorporation":"1996-07-04","Address":{"Line1":"Permanent Line 1Permanent Lin","Line2":"e 2","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28584802","AadhaarNumber":"394875934753","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"2003-07-02","DateOfIncorporation":"2003-07-02","Address":{"Line1":"Permanent Line 1Permanent Lin","Line2":"e 2","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28584961","AadhaarNumber":"394875938745","MobileNumber":"7777777777","CustomerFullName":"Applicant Last","DateOfBirth":"1996-07-05","DateOfIncorporation":"1996-07-05","Address":{"Line1":"Permanent Line 1Permanent Lin","Line2":"e 2","City":"AHMEDABAD","State":"GUJARAT","Country":"INDIA","Zip":"380001"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28585243","PAN":"AAACH0812J","MobileNumber":"7777777777","CustomerFullName":"HERO MOTOCORP LIMITED","DateOfBirth":"2000-06-22","DateOfIncorporation":"2000-06-22","Address":{"Line1":"Hero MotoCorp Limited, Sy No. 01","Line2":"Industrial Area, Satyavedu Cherivi","Line3":"Road, Madanapalem, Andhra Pradesh,","City":"CHITTOOR","State":"ANDHRA PRADESH","Country":"INDIA","Zip":"517588"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null},{"CustomerID":"28585292","PAN":"ARJPD4883A","AadhaarNumber":"191294231995","MobileNumber":"7777777777","CustomerFullName":"Anita Kumar Dhaigude","DateOfBirth":"1970-05-14","DateOfIncorporation":"1970-05-14","Address":{"Line1":"bhangarwadishrlram appartment","Line2":"bhangarwadi","City":"PUNE","State":"MAHARASHTRA","Country":"INDIA","Zip":"410401"},"BlockStatus":"N","NPAStatus":null,"CustomerType":"100","CustomerTypeDesc":"INDIVIDUAL - FULL KYC","KYCDate":null}]}}'
        ),true);
        
        Profile prof = [select id from profile where name LIKE '%TCU%' limit 1];
        
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1',
            lastName = 'test2',
            profileId = prof.id,
            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
    }
    
    @isTest 
    static void testDedupeSearchCallout(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LeadDedupeSearchCalloutMock());
        Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' limit 1];
        LeadDedupeWrapper.leadCBSDedupeWrapper objWrapper = LeadDedupeController.getCBSApplicantList(objApp.Id,true);
        System.assertEquals(0,objWrapper.applicantList_fullMatch.size(),'No full Match');
        Test.stopTest();
    }
    
    @isTest 
    static void testDedupeDetailCallout(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new LeadDedupeDetailCalloutMock());
        	try {
                LeadDedupeController.getCBSApplicantDetail(null,null,null, null);
            }
            catch(Exception ex){}
            Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' AND Loan__r.Stage__c <> 'PDD' LIMIT 1];
            LeadDedupeWrapper.CustomerDetailWrapper objWrapper;
            try {
                objWrapper = LeadDedupeController.getCBSApplicantDetail('12345',objApp.Id,'full', 2);
            }catch(Exception ex){}
            List<LeadDedupeController.CustomerODResponseWrapper>  objWrapper11;
            try{
                objWrapper11 = LeadDedupeController.getCustomerODResponse('12345',objApp.Id);
            }catch(Exception ex){}
            LeadDedupeWrapper.leadCBSCreditCardWrapper objWrapper1;
            try{
                objWrapper1 = LeadDedupeController.getCCResponse('12345', objApp.Id);
            }catch(Exception ex){}
            try{
                Applicant__c objAppKYCPending = LeadDedupeController.updateKYCPending(JSON.serialize(objApp));
            }catch(Exception ex){}
            objWrapper.boolIsKYCDone = true;
            //objWrapper.lstAccountWrapper = new List<LeadDedupeWrapper.AccountWrapper>();
            system.debug('%% '+objWrapper);
            Applicant__c objAppCopy = LeadDedupeController.copyApplicantfromCBS(objWrapper,objWrapper11,objWrapper1,objApp,false);
            objWrapper.boolIsKYCDone = false;
            objAppCopy = LeadDedupeController.copyApplicantfromCBS(objWrapper,objWrapper11,objWrapper1,objApp,false);
            LeadDedupeController.copyApplicantfromCBSExposure(objWrapper,objWrapper11,objWrapper1,objApp,false);
        Test.stopTest();
    }
    
    @isTest 
    static void testDedupeCBSDetailCallout(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LeadDedupeDetailCalloutMock());
        Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' AND Loan__r.Stage__c <> 'PDD' LIMIT 1];
        LeadDedupeWrapper.CustomerDetailWrapper objWrapper;
        try{
            objWrapper = LeadDedupeController.getCBSApplicantDetail('12345',objApp.Id,'full', 2);
        }catch(Exception ex){}
        List<LeadDedupeController.CustomerODResponseWrapper>  objWrapper11;
        try{
            objWrapper11 = LeadDedupeController.getCustomerODResponse('12345',objApp.Id);
        }catch(Exception ex){}
        LeadDedupeWrapper.leadCBSCreditCardWrapper objWrapper1;
        try{
            objWrapper1 = LeadDedupeController.getCCResponse('12345', objApp.Id);
        }catch(Exception ex){}
        system.debug('%% '+objWrapper);
        Applicant__c objAppCopy;
        try{
            objAppCopy = LeadDedupeController.copyApplicantfromCBS(objWrapper,objWrapper11,objWrapper1,objApp,false);
        }catch(Exception ex){}
        objWrapper.boolIsKYCDone = false;
        try{
            objAppCopy = LeadDedupeController.copyApplicantfromCBS(objWrapper,objWrapper11,objWrapper1,objApp,false);
        }catch(Exception ex){}
        try{
            LeadDedupeController.copyApplicantfromCBSExposure(objWrapper,objWrapper11,objWrapper1,objApp,false);
        }catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest 
    static void testDedupeODDetailCallout(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LeadDedupeDetailCalloutMock());
        Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' AND Loan__r.Stage__c <> 'PDD' LIMIT 1];
        List<LeadDedupeController.CustomerODResponseWrapper>  objWrapper11 = LeadDedupeController.getCustomerODResponse('12345',objApp.Id);
        Test.stopTest();
    }

    @isTest 
    static void testDedupeCCDetailCalloutTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LeadDedupeDetailCalloutMock());
        Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' AND Loan__r.Stage__c <> 'PDD' LIMIT 1];
        try{
            LeadDedupeWrapper.leadCBSCreditCardWrapper objWrapper1 = LeadDedupeController.getCCResponse('12345', objApp.Id);
        }catch (Exception ex){}
        Test.stopTest();
    }
    
    @isTest 
    static void testGetCRMApplicantList(){
        Test.startTest();
        Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' limit 1];
        list<LeadDedupeController.LeadCRMDedupeWrapper> objWrapper = LeadDedupeController.getCRMApplicantList(objApp.Id,true);
        system.debug('%% '+objWrapper.size());
       // System.assertEquals(4,objWrapper.size(),'Size Match');
        LeadDedupeController.LeadCRMDedupeWrapper objWrap = LeadDedupeController.copyApplicantfromCRM(objWrapper[0],objApp);
        User usr = [Select Id from User where isActive = true limit 1];
        System.runAs(usr){
            list<LeadDedupeController.LeadCRMDedupeWrapper> objWrapper1 = LeadDedupeController.getCRMApplicantList(objApp.Id,true);
        }
        Test.stopTest();
    }

    @isTest 
    static void testGetLeadtoLeadAppList(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LeadDedupeDetailCalloutMock());
        Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' limit 1];
        try{
            List<LeadDedupeWrapper.LeadtoLeadWrapper> objWrapper1 = LeadDedupeController.getLeadtoLeadAppList(objApp.Id,true);
        }
        catch (Exception ex){}
        try{
            List<LeadDedupeWrapper.LeadtoLeadWrapper> objWrapper2 = LeadDedupeController.getLeadtoLeadAppList(objApp.Id,false);
        }
        catch (Exception ex){}
        try {
            LeadDedupeController.getCustomerODResponse('12345',objApp.Id);
        }
        catch(Exception ex){}//LeadDedupeController.copyApplicantfromLeadtoLead(objWrapper1[0], objApp);
        Test.stopTest();
    }

    @isTest 
    static void testGetLeadtoLeadAppList2(){
        Test.startTest();
        Applicant__c objApp = [Select Id, RecordTypeId, Loan__c, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' limit 1];
        LeadDedupeWrapper.LeadtoLeadWrapper wrapperInst = new LeadDedupeWrapper.LeadtoLeadWrapper();
        wrapperInst.strCustomerName = 'Blah bloh';
        wrapperInst.strCustomerMobileNumber = '9120910291';
        wrapperInst.strApplicationNumber = '1291020';
        wrapperInst.strApplicationstatus = 'Approved';
        wrapperInst.strLeadId = '120129';
        wrapperInst.strLoanAmount = '100000';
        wrapperInst.strProductName = 'Two Wheels';
        LeadDedupeController.copyApplicantfromLeadtoLead(wrapperInst, objApp);
        LeadDedupeController.getMessage(objApp.Loan__c, 'Test Cust', 'Test Branch');
        
        Set<Id> setId = new Set<Id>();
        setId.add(objApp.Loan__c);
        //LeadDedupeController.createApprovalRecords(setId);
        Test.stopTest();
    }

    @isTest 
    static void updateNPAFieldOnApplicanttest(){
        Test.startTest();
        Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' limit 1];
        LeadDedupeController.updateNPAFieldOnApplicant(objApp.Id,true);
        Test.stopTest();
    }

    @isTest 
    static void getLoanDetailsTest(){
        Test.startTest();
        Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c, Loan__c from Applicant__c where First_Name__c = 'Vikash' limit 1];
        LeadDedupeController.getLoanDetails(objApp.Loan__c);
        Test.stopTest();
    }

    @isTest 
    static void testDedupeDetailCalloutODDetails(){
        Test.startTest();
            Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' AND Loan__r.Stage__c <> 'PDD' LIMIT 1];
            Test.setMock(HttpCalloutMock.class, new LoanODCalloutMock());
            List<LeadDedupeController.CustomerODResponseWrapper>  objWrapper11 = LeadDedupeController.getCustomerODResponse('12345',objApp.Id);
        Test.stopTest();
    }

    @isTest 
    static void testDedupeCCDetailCallout(){
        Test.startTest();
            Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' AND Loan__r.Stage__c <> 'PDD' LIMIT 1];
            String strCustomerDetailWrap = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":"0"}]}},"CustomerResponse":{"CustomerBasicInquiry":{"CustomerId":"21738937","NationalIdentificationCode":"21738937","CustomerName":{"Prefix":"Mr ","FirstName":"Parvez","MidName":"M","LastName":"Parmar","ShortName":"BHANUMATI S PARMAR","FormattedFullName":"Parvez#M#Parmar","FullName":"Parvez M Parmar"},"CustomerFullName":"Parvez M Parmar","CustomerAddress":{"Line1":"No 27 5th Main","Line2":"Nehru Road","Line3":"Patel Nagar","City":"AHMEDABAD","State":"GUJARAT","Country":"India","Zip":"380008"},"BirthDateText":"1957-11-25","CategoryType":"INDIVIDUAL SENIOR CITIZEN - FULL KYC","Sex":"F","IsImageAvailable":"false","IsSignatureAvailable":"false","CombWithdrawBal":"0.0","AgeOfCustRel":"2017-06-15","AadhaarDetail":{"AadhaarNumber":"835980598238"},"HomeBranch":"9045","MobileNumber":"9405809196","EmailAddress":"21738937@axc.com","IcType":"L","IcTypeDesc":"Lead Number","BankShortName":"Ahmedabad_Sarthik","PAN":"CSQPP5959P","CustomerType":"129"}},"AccountDetails":{"CustomerAccount":[{"ModuleCode":"C","ProductName":"20101-AU Savings Account","AccountId":"1711216011297197","CASAAccountName":"21738940","CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"JOO","BalanceBook":"0.00","UnclearFunds":"0.00","Classification":"NORMAL","Reason":"UNBLOCKED ","BillAmount":"0.00","OriginalBalance":"0.00","CurrentStatus":"7","CurrentStatusDescription":"ACCOUNT DORMANT","AcyAmount":"0.00","AvailableBalance":"0.00","LcyAmount":"0.00","TotalAcyAmount":"0.00","TotalLcyAmount":"0.00","BranchName":"Ahmedabad_Relief Road","ExternalAccountId":"0","FutureDatedAmount":"0.00","SafeDepositBoxId":"0","DateAccountOpen":"2017-06-15","DateRelation":"2017-06-15","MonthsSinceActive":"64","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"0.00","DateValue":"2017-06-15","BalPrincipal":"0","IntRate":"0","LienAmount":"0","InstallmentAmount":"0","OtherArrear":"0","BranchCode":"2160","IsTDLinkage":"N  ","HoldAmount":"27","ODLimitSactioned":"0","ODLimitUtilized":"0","OperationMode":"EITHER OR SURVIVORnull","SmallClearingAccountNo":"000708","CASARelationshipDetails":[{"CustomerId":"21738940","Emailid":"21738940@axc.com","JointHolderName":"MAHENDRABHAI S PARMAR","MobileNo":"21738940","Relationship":"JOF"}],"AmtGoal":"0","ProductCode":"20101","Tenure":"0 Months 0 Days 0 Years "},{"ModuleCode":"L","ProductName":"10601-MSME Business Funding","AccountId":"9001060127032470","CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"COB","BalanceBook":"1415400.00","UnclearFunds":"0.00","Classification":"NORMAL","Reason":"          ","BillAmount":"0.00","OriginalBalance":"1400000.00","CurrentStatus":"8","CurrentStatusDescription":"ACCOUNT OPEN REGULAR","AcyAmount":"1415400.00","AvailableBalance":"1415400.00","LcyAmount":"1415400.00","TotalAcyAmount":"1582205.80","TotalLcyAmount":"1582205.80","BranchName":"Jaipur_Asset Center","LoanApplicationNumber":"8603332","FutureDatedAmount":"0.00","SafeDepositBoxId":"0","Iban":"IN36109990010601270","DateAccountOpen":"2022-10-13","MonthsSinceActive":"0","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"1582205.80","BalPrincipal":"0","IntRate":"18","MaturityDate":"2032-09-05","LienAmount":"0","InstallmentAmount":"0","OtherArrear":"0","BranchCode":"9000","IsTDLinkage":"N  ","DisbursedAmount":"1400000","EmiTenure":"118","LoanAccountName":"Dandiya Store","AmtGoal":"0","ProductCode":"10601","Tenure":"118 Months 0 Days 0 Years "},{"ModuleCode":"L","ProductName":"10601-MSME Business Funding","AccountId":"9001060100000114","CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"SOW","BalanceBook":"166805.80","UnclearFunds":"0.00","Classification":"NORMAL","Reason":"          ","BillAmount":"0.00","OriginalBalance":"500000.00","CurrentStatus":"8","CurrentStatusDescription":"ACCOUNT OPEN REGULAR","AcyAmount":"166805.80","AvailableBalance":"166805.80","LcyAmount":"166805.80","TotalAcyAmount":"1582205.80","TotalLcyAmount":"1582205.80","BranchName":"Ahmedabad Asset_Center","LoanApplicationNumber":"9001060100000114              ","FutureDatedAmount":"0.00","SafeDepositBoxId":"0","DateAccountOpen":"2011-07-31","MonthsSinceActive":"0","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"1582205.80","BalPrincipal":"0","IntRate":"20","MaturityDate":"2018-08-15","LienAmount":"0","InstallmentAmount":"0","OtherArrear":"60659.8","BranchCode":"9045","IsTDLinkage":"N  ","DisbursedAmount":"500000","EmiTenure":"84","LoanAccountName":"BHANUMATI S PARMAR","AmtGoal":"0","ProductCode":"10601","Tenure":"84 Months 0 Days 0 Years "}],"IsCustomerSchemeAvailable":"false"}}';
            String strODWrap = '{\"TransactionStatus\":{\"ResponseCode\":\"0\",\"ResponseMessage\":\"Success\",\"ExtendedErrorDetails\":{\"messages\":[{\"code\":0}]}},\"AccountDetail\":[{\"ModuleCode\":\"L\",\"ProductName\":\"10705-HomeTopup\",\"AccountId\":\"9001070530341114\",\"CurrencyCode\":1,\"CurrencyShortName\":\"INR\",\"CustomerRelationship\":\"SOW\",\"BalanceBook\":1015417.00,\"UnclearFunds\":0.00,\"Classification\":\"NORMAL\",\"Reason\":\"\",\"BillAmount\":0.00,\"OriginalBalance\":1000000.00,\"CurrentStatus\":\"8\",\"CurrentStatusDescription\":\"ACCOUNTOPENREGULAR\",\"AcyAmount\":1015417.00,\"AvailableBalance\":1015417.00,\"LcyAmount\":1015417.00,\"TotalAcyAmount\":1015417.00,\"TotalLcyAmount\":1015417.00,\"BranchName\":\"JaipurCentralOffice_Mansarovar\",\"LoanApplicationNumber\":\"111898799\",\"FutureDatedAmount\":0.00,\"SafeDepositBoxId\":0,\"Iban\":\"IN71109990010705303\",\"DateAccountOpen\":\"2023-01-30\",\"MonthsSinceActive\":0,\"BalUncollectedPrinc\":0.00,\"BalUncollectedInt\":0.00,\"TotalBalUncollecPrinc\":0.00,\"TotalBalUncollecInt\":0.00,\"TotalBalBook\":1015417.00,\"BalPrincipal\":0,\"IntRate\":17,\"MaturityDate\":\"2033-01-30\",\"LienAmount\":0,\"InstallmentAmount\":0,\"OtherArrear\":0,\"BalCombinedAcy\":0,\"BalCombinedLcy\":0,\"BranchCode\":\"2011\",\"IsTDLinkage\":\"N\",\"LoanAccountDetails\":[{\"CustomerId\":27972650,\"AccountNo\":\"9001070530341114\",\"BranchName\":\"JaipurCentralOffice_Mansarovar\",\"ProdCode\":\"10705\",\"ProdName\":\"HomeTopup\",\"CurrencyName\":\"1\",\"LoanTerm\":120,\"SanctionedAmount\":1000000,\"MaturityDate\":\"2033-01-30\",\"AcctOpenDate\":\"2023-01-30\",\"DisbAmount\":1000000,\"PaidInstallment\":984583,\"NextDueDate\":\"2023-03-30\",\"OutStandingLoanAmount\":1015417.0000000000,\"UnpaidInstallment\":15417,\"InterestRateVariance\":4.0,\"InterestRate\":20.0,\"LoanRepaymentMode\":\"3\",\"AccountCurrency\":\"1\",\"AccountStatus\":\"8\",\"NextInstallmentDue\":\"16667.00\",\"PrincipalBalance\":1000000.00,\"UnbilledPrincipalBalance\":1000000.00,\"AmountDisbursedToday\":0.00,\"FutureInterest\":0,\"InstallmentArrears\":15417.00,\"OtherArrears\":0.00,\"MinAmountDue\":16667.00,\"UncollectedInterest\":0.00,\"UnbilledPenaltyInterest\":274.00,\"UnbilledServiceCharge\":0.00,\"AmountPaidToday\":0.00,\"RpaBalance\":0.00,\"UnbilledInterest\":10000.00,\"UnbilledAdditionalPenaltyInterest\":0,\"UnclearedFunds\":0.00,\"AvailableBalance\":0.00,\"TotalOutstandings\":1015417.00,\"InterestOnArrears\":0,\"PmiArrears\":0.00,\"SuspenededPMIArrears\":0.00,\"CompoundingInterestArrears\":0.00,\"DivertingInterestArrears\":0.00,\"DatAgrmntSign\":\"2023-01-30\",\"CodAgrmntNo\":\"344121123\",\"InstallamentFrequency\":\"1\",\"TotalInstallmentNo\":84,\"TotalNoOfInstallmentsReceived\":0,\"InstallmentsOverDue\":1,\"InstallmentsReceivedAdv\":0,\"ProductCategory\":\"HOMELOAN\",\"BounceCheque\":0,\"LoanPurpose\":\"home\",\"RateType\":\"1\",\"FlagInsured\":\"N\",\"FlagRepo\":\"N\",\"TotalPrinciplePaid\":0,\"TotalInterestPaid\":0}]},{\"ModuleCode\":\"L\",\"ProductName\":\"10614-PradhanMantriMudraYojanaTermL\",\"AccountId\":\"9001061430341093\",\"CurrencyCode\":1,\"CurrencyShortName\":\"INR\",\"CustomerRelationship\":\"SOW\",\"BalanceBook\":0.00,\"UnclearFunds\":0.00,\"Classification\":\"NORMAL\",\"Reason\":\"\",\"BillAmount\":0.00,\"OriginalBalance\":1000000.00,\"CurrentStatus\":\"8\",\"CurrentStatusDescription\":\"ACCOUNTOPENREGULAR\",\"AcyAmount\":0.00,\"AvailableBalance\":0.00,\"LcyAmount\":0.00,\"TotalAcyAmount\":1015417.00,\"TotalLcyAmount\":1015417.00,\"BranchName\":\"JhandewalanDelhiAssetCenter\",\"LoanApplicationNumber\":\"4921621\",\"FutureDatedAmount\":0.00,\"SafeDepositBoxId\":0,\"Iban\":\"IN61109990010614303\",\"DateAccountOpen\":\"2023-01-30\",\"MonthsSinceActive\":0,\"BalUncollectedPrinc\":0.00,\"BalUncollectedInt\":0.00,\"TotalBalUncollecPrinc\":0.00,\"TotalBalUncollecInt\":0.00,\"TotalBalBook\":1015417.00,\"BalPrincipal\":0,\"IntRate\":18,\"MaturityDate\":\"1950-01-01\",\"LienAmount\":0,\"InstallmentAmount\":0,\"OtherArrear\":0,\"BalCombinedAcy\":0,\"BalCombinedLcy\":0,\"BranchCode\":\"9109\",\"IsTDLinkage\":\"N\",\"LoanAccountDetails\":[{\"CustomerId\":27972650,\"AccountNo\":\"9001061430341093\",\"BranchName\":\"JhandewalanDelhiAssetCenter\",\"ProdCode\":\"10614\",\"ProdName\":\"PradhanMantriMudraYojanaTermLoan\",\"CurrencyName\":\"1\",\"LoanTerm\":20,\"SanctionedAmount\":1000000,\"MaturityDate\":\"1950-01-01\",\"AcctOpenDate\":\"2023-01-30\",\"DisbAmount\":0,\"PaidInstallment\":1000000,\"NextDueDate\":\"1800-01-01\",\"OutStandingLoanAmount\":0,\"UnpaidInstallment\":0,\"InterestRateVariance\":16.0,\"InterestRate\":34.0,\"LoanRepaymentMode\":\"3\",\"AccountCurrency\":\"1\",\"AccountStatus\":\"8\",\"NextInstallmentDue\":\"0.00\",\"PrincipalBalance\":0.00,\"UnbilledPrincipalBalance\":0.00,\"AmountDisbursedToday\":0.00,\"FutureInterest\":0,\"InstallmentArrears\":0.00,\"OtherArrears\":0.00,\"MinAmountDue\":0.00,\"UncollectedInterest\":0.00,\"UnbilledPenaltyInterest\":0.00,\"UnbilledServiceCharge\":0.00,\"AmountPaidToday\":0.00,\"RpaBalance\":0.00,\"UnbilledInterest\":0.00,\"UnbilledAdditionalPenaltyInterest\":0,\"UnclearedFunds\":0.00,\"AvailableBalance\":1000000.00,\"TotalOutstandings\":0.00,\"InterestOnArrears\":0,\"PmiArrears\":0.00,\"SuspenededPMIArrears\":0.00,\"CompoundingInterestArrears\":0.00,\"DivertingInterestArrears\":0.00,\"DatAgrmntSign\":\"2023-01-30\",\"CodAgrmntNo\":\"4921621\",\"InstallamentFrequency\":\"1\",\"TotalInstallmentNo\":0,\"TotalNoOfInstallmentsReceived\":0,\"InstallmentsOverDue\":0,\"InstallmentsReceivedAdv\":0,\"ProductCategory\":\"Agri\",\"BounceCheque\":0,\"LoanPurpose\":\"workingcaptial\",\"RateType\":\"0\",\"FlagInsured\":\"N\",\"FlagRepo\":\"N\",\"TotalPrinciplePaid\":0,\"TotalInterestPaid\":0}]}]}';
            
            LeadDedupeWrapper.CustomerDetailWrapper objWrapper = (LeadDedupeWrapper.CustomerDetailWrapper)JSON.deserialize(strCustomerDetailWrap,LeadDedupeWrapper.CustomerDetailWrapper.class);
            List<LeadDedupeController.CustomerODResponseWrapper> objWrapper11 = new List<LeadDedupeController.CustomerODResponseWrapper>();
            LeadDedupeController.CustomerODResponseWrapper objWrapper11Temp = (LeadDedupeController.CustomerODResponseWrapper)JSON.deserialize(strODWrap,LeadDedupeController.CustomerODResponseWrapper.class);
            objWrapper11.add(objWrapper11Temp);

            LeadDedupeWrapper.leadCBSCreditCardWrapper objWrapper1 = new LeadDedupeWrapper.leadCBSCreditCardWrapper();
            objWrapper1.CreditCardResponse = new List<LeadDedupeWrapper.cls_CreditCardResponse>();
            LeadDedupeWrapper.cls_CreditCardResponse objCCWrap = new LeadDedupeWrapper.cls_CreditCardResponse();
            objCCWrap.CustomerID = '987636';
            objCCWrap.AccountOpenDate = '2011-01-01';
            objCCWrap.SanctionedAmount = '10000';
            objWrapper1.CreditCardResponse.add(objCCWrap);

            
            objWrapper.boolIsKYCDone = false;
            objWrapper.lstAccountWrapper = new List<LeadDedupeWrapper.AccountWrapper>();
            try{
                Applicant__c objAppCopy = LeadDedupeController.copyApplicantfromCBS(objWrapper,objWrapper11,objWrapper1,objApp,false);
            }
            catch(Exception ex){}
        Test.stopTest();
    }

    @isTest 
    static void testDedupeBureau(){
        List<Applicant__c> lstApp = new List<Applicant__c>();
        for (Applicant__c obj : [Select Id, Bureau_Score__c from Applicant__c]) {
            obj.Bureau_Score__c = '720';
            lstApp.add(obj);
        }
        update lstApp;
        Test.startTest();
            Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' AND Loan__r.Stage__c <> 'PDD' LIMIT 1];
            String strCustomerDetailWrap = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":"0"}]}},"CustomerResponse":{"CustomerBasicInquiry":{"CustomerId":"21738937","NationalIdentificationCode":"21738937","CustomerName":{"Prefix":"Mr ","FirstName":"Parvez","MidName":"M","LastName":"Parmar","ShortName":"BHANUMATI S PARMAR","FormattedFullName":"Parvez#M#Parmar","FullName":"Parvez M Parmar"},"CustomerFullName":"Parvez M Parmar","CustomerAddress":{"Line1":"No 27 5th Main","Line2":"Nehru Road","Line3":"Patel Nagar","City":"AHMEDABAD","State":"GUJARAT","Country":"India","Zip":"380008"},"BirthDateText":"1957-11-25","CategoryType":"INDIVIDUAL SENIOR CITIZEN - FULL KYC","Sex":"F","IsImageAvailable":"false","IsSignatureAvailable":"false","CombWithdrawBal":"0.0","AgeOfCustRel":"2017-06-15","AadhaarDetail":{"AadhaarNumber":"835980598238"},"HomeBranch":"9045","MobileNumber":"9405809196","EmailAddress":"21738937@axc.com","IcType":"L","IcTypeDesc":"Lead Number","BankShortName":"Ahmedabad_Sarthik","PAN":"CSQPP5959P","CustomerType":"129"}},"AccountDetails":{"CustomerAccount":[{"ModuleCode":"C","ProductName":"20101-AU Savings Account","AccountId":"1711216011297197","CASAAccountName":"21738940","CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"JOO","BalanceBook":"0.00","UnclearFunds":"0.00","Classification":"NORMAL","Reason":"UNBLOCKED ","BillAmount":"0.00","OriginalBalance":"0.00","CurrentStatus":"7","CurrentStatusDescription":"ACCOUNT DORMANT","AcyAmount":"0.00","AvailableBalance":"0.00","LcyAmount":"0.00","TotalAcyAmount":"0.00","TotalLcyAmount":"0.00","BranchName":"Ahmedabad_Relief Road","ExternalAccountId":"0","FutureDatedAmount":"0.00","SafeDepositBoxId":"0","DateAccountOpen":"2017-06-15","DateRelation":"2017-06-15","MonthsSinceActive":"64","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"0.00","DateValue":"2017-06-15","BalPrincipal":"0","IntRate":"0","LienAmount":"0","InstallmentAmount":"0","OtherArrear":"0","BranchCode":"2160","IsTDLinkage":"N  ","HoldAmount":"27","ODLimitSactioned":"0","ODLimitUtilized":"0","OperationMode":"EITHER OR SURVIVORnull","SmallClearingAccountNo":"000708","CASARelationshipDetails":[{"CustomerId":"21738940","Emailid":"21738940@axc.com","JointHolderName":"MAHENDRABHAI S PARMAR","MobileNo":"21738940","Relationship":"JOF"}],"AmtGoal":"0","ProductCode":"20101","Tenure":"0 Months 0 Days 0 Years "},{"ModuleCode":"L","ProductName":"10601-MSME Business Funding","AccountId":"9001060127032470","CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"COB","BalanceBook":"1415400.00","UnclearFunds":"0.00","Classification":"NORMAL","Reason":"          ","BillAmount":"0.00","OriginalBalance":"1400000.00","CurrentStatus":"8","CurrentStatusDescription":"ACCOUNT OPEN REGULAR","AcyAmount":"1415400.00","AvailableBalance":"1415400.00","LcyAmount":"1415400.00","TotalAcyAmount":"1582205.80","TotalLcyAmount":"1582205.80","BranchName":"Jaipur_Asset Center","LoanApplicationNumber":"8603332","FutureDatedAmount":"0.00","SafeDepositBoxId":"0","Iban":"IN36109990010601270","DateAccountOpen":"2022-10-13","MonthsSinceActive":"0","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"1582205.80","BalPrincipal":"0","IntRate":"18","MaturityDate":"2032-09-05","LienAmount":"0","InstallmentAmount":"0","OtherArrear":"0","BranchCode":"9000","IsTDLinkage":"N  ","DisbursedAmount":"1400000","EmiTenure":"118","LoanAccountName":"Dandiya Store","AmtGoal":"0","ProductCode":"10601","Tenure":"118 Months 0 Days 0 Years "},{"ModuleCode":"L","ProductName":"10601-MSME Business Funding","AccountId":"9001060100000114","CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"SOW","BalanceBook":"166805.80","UnclearFunds":"0.00","Classification":"NORMAL","Reason":"          ","BillAmount":"0.00","OriginalBalance":"500000.00","CurrentStatus":"8","CurrentStatusDescription":"ACCOUNT OPEN REGULAR","AcyAmount":"166805.80","AvailableBalance":"166805.80","LcyAmount":"166805.80","TotalAcyAmount":"1582205.80","TotalLcyAmount":"1582205.80","BranchName":"Ahmedabad Asset_Center","LoanApplicationNumber":"9001060100000114              ","FutureDatedAmount":"0.00","SafeDepositBoxId":"0","DateAccountOpen":"2011-07-31","MonthsSinceActive":"0","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"1582205.80","BalPrincipal":"0","IntRate":"20","MaturityDate":"2018-08-15","LienAmount":"0","InstallmentAmount":"0","OtherArrear":"60659.8","BranchCode":"9045","IsTDLinkage":"N  ","DisbursedAmount":"500000","EmiTenure":"84","LoanAccountName":"BHANUMATI S PARMAR","AmtGoal":"0","ProductCode":"10601","Tenure":"84 Months 0 Days 0 Years "}],"IsCustomerSchemeAvailable":"false"}}';
            String strODWrap = '{\"TransactionStatus\":{\"ResponseCode\":\"0\",\"ResponseMessage\":\"Success\",\"ExtendedErrorDetails\":{\"messages\":[{\"code\":0}]}},\"AccountDetail\":[{\"ModuleCode\":\"L\",\"ProductName\":\"10705-HomeTopup\",\"AccountId\":\"9001070530341114\",\"CurrencyCode\":1,\"CurrencyShortName\":\"INR\",\"CustomerRelationship\":\"SOW\",\"BalanceBook\":1015417.00,\"UnclearFunds\":0.00,\"Classification\":\"NORMAL\",\"Reason\":\"\",\"BillAmount\":0.00,\"OriginalBalance\":1000000.00,\"CurrentStatus\":\"8\",\"CurrentStatusDescription\":\"ACCOUNTOPENREGULAR\",\"AcyAmount\":1015417.00,\"AvailableBalance\":1015417.00,\"LcyAmount\":1015417.00,\"TotalAcyAmount\":1015417.00,\"TotalLcyAmount\":1015417.00,\"BranchName\":\"JaipurCentralOffice_Mansarovar\",\"LoanApplicationNumber\":\"111898799\",\"FutureDatedAmount\":0.00,\"SafeDepositBoxId\":0,\"Iban\":\"IN71109990010705303\",\"DateAccountOpen\":\"2023-01-30\",\"MonthsSinceActive\":0,\"BalUncollectedPrinc\":0.00,\"BalUncollectedInt\":0.00,\"TotalBalUncollecPrinc\":0.00,\"TotalBalUncollecInt\":0.00,\"TotalBalBook\":1015417.00,\"BalPrincipal\":0,\"IntRate\":17,\"MaturityDate\":\"2033-01-30\",\"LienAmount\":0,\"InstallmentAmount\":0,\"OtherArrear\":0,\"BalCombinedAcy\":0,\"BalCombinedLcy\":0,\"BranchCode\":\"2011\",\"IsTDLinkage\":\"N\",\"LoanAccountDetails\":[{\"CustomerId\":27972650,\"AccountNo\":\"9001070530341114\",\"BranchName\":\"JaipurCentralOffice_Mansarovar\",\"ProdCode\":\"10705\",\"ProdName\":\"HomeTopup\",\"CurrencyName\":\"1\",\"LoanTerm\":120,\"SanctionedAmount\":1000000,\"MaturityDate\":\"2033-01-30\",\"AcctOpenDate\":\"2023-01-30\",\"DisbAmount\":1000000,\"PaidInstallment\":984583,\"NextDueDate\":\"2023-03-30\",\"OutStandingLoanAmount\":1015417.0000000000,\"UnpaidInstallment\":15417,\"InterestRateVariance\":4.0,\"InterestRate\":20.0,\"LoanRepaymentMode\":\"3\",\"AccountCurrency\":\"1\",\"AccountStatus\":\"8\",\"NextInstallmentDue\":\"16667.00\",\"PrincipalBalance\":1000000.00,\"UnbilledPrincipalBalance\":1000000.00,\"AmountDisbursedToday\":0.00,\"FutureInterest\":0,\"InstallmentArrears\":15417.00,\"OtherArrears\":0.00,\"MinAmountDue\":16667.00,\"UncollectedInterest\":0.00,\"UnbilledPenaltyInterest\":274.00,\"UnbilledServiceCharge\":0.00,\"AmountPaidToday\":0.00,\"RpaBalance\":0.00,\"UnbilledInterest\":10000.00,\"UnbilledAdditionalPenaltyInterest\":0,\"UnclearedFunds\":0.00,\"AvailableBalance\":0.00,\"TotalOutstandings\":1015417.00,\"InterestOnArrears\":0,\"PmiArrears\":0.00,\"SuspenededPMIArrears\":0.00,\"CompoundingInterestArrears\":0.00,\"DivertingInterestArrears\":0.00,\"DatAgrmntSign\":\"2023-01-30\",\"CodAgrmntNo\":\"344121123\",\"InstallamentFrequency\":\"1\",\"TotalInstallmentNo\":84,\"TotalNoOfInstallmentsReceived\":0,\"InstallmentsOverDue\":1,\"InstallmentsReceivedAdv\":0,\"ProductCategory\":\"HOMELOAN\",\"BounceCheque\":0,\"LoanPurpose\":\"home\",\"RateType\":\"1\",\"FlagInsured\":\"N\",\"FlagRepo\":\"N\",\"TotalPrinciplePaid\":0,\"TotalInterestPaid\":0}]},{\"ModuleCode\":\"L\",\"ProductName\":\"10614-PradhanMantriMudraYojanaTermL\",\"AccountId\":\"9001061430341093\",\"CurrencyCode\":1,\"CurrencyShortName\":\"INR\",\"CustomerRelationship\":\"SOW\",\"BalanceBook\":0.00,\"UnclearFunds\":0.00,\"Classification\":\"NORMAL\",\"Reason\":\"\",\"BillAmount\":0.00,\"OriginalBalance\":1000000.00,\"CurrentStatus\":\"8\",\"CurrentStatusDescription\":\"ACCOUNTOPENREGULAR\",\"AcyAmount\":0.00,\"AvailableBalance\":0.00,\"LcyAmount\":0.00,\"TotalAcyAmount\":1015417.00,\"TotalLcyAmount\":1015417.00,\"BranchName\":\"JhandewalanDelhiAssetCenter\",\"LoanApplicationNumber\":\"4921621\",\"FutureDatedAmount\":0.00,\"SafeDepositBoxId\":0,\"Iban\":\"IN61109990010614303\",\"DateAccountOpen\":\"2023-01-30\",\"MonthsSinceActive\":0,\"BalUncollectedPrinc\":0.00,\"BalUncollectedInt\":0.00,\"TotalBalUncollecPrinc\":0.00,\"TotalBalUncollecInt\":0.00,\"TotalBalBook\":1015417.00,\"BalPrincipal\":0,\"IntRate\":18,\"MaturityDate\":\"1950-01-01\",\"LienAmount\":0,\"InstallmentAmount\":0,\"OtherArrear\":0,\"BalCombinedAcy\":0,\"BalCombinedLcy\":0,\"BranchCode\":\"9109\",\"IsTDLinkage\":\"N\",\"LoanAccountDetails\":[{\"CustomerId\":27972650,\"AccountNo\":\"9001061430341093\",\"BranchName\":\"JhandewalanDelhiAssetCenter\",\"ProdCode\":\"10614\",\"ProdName\":\"PradhanMantriMudraYojanaTermLoan\",\"CurrencyName\":\"1\",\"LoanTerm\":20,\"SanctionedAmount\":1000000,\"MaturityDate\":\"1950-01-01\",\"AcctOpenDate\":\"2023-01-30\",\"DisbAmount\":0,\"PaidInstallment\":1000000,\"NextDueDate\":\"1800-01-01\",\"OutStandingLoanAmount\":0,\"UnpaidInstallment\":0,\"InterestRateVariance\":16.0,\"InterestRate\":34.0,\"LoanRepaymentMode\":\"3\",\"AccountCurrency\":\"1\",\"AccountStatus\":\"8\",\"NextInstallmentDue\":\"0.00\",\"PrincipalBalance\":0.00,\"UnbilledPrincipalBalance\":0.00,\"AmountDisbursedToday\":0.00,\"FutureInterest\":0,\"InstallmentArrears\":0.00,\"OtherArrears\":0.00,\"MinAmountDue\":0.00,\"UncollectedInterest\":0.00,\"UnbilledPenaltyInterest\":0.00,\"UnbilledServiceCharge\":0.00,\"AmountPaidToday\":0.00,\"RpaBalance\":0.00,\"UnbilledInterest\":0.00,\"UnbilledAdditionalPenaltyInterest\":0,\"UnclearedFunds\":0.00,\"AvailableBalance\":1000000.00,\"TotalOutstandings\":0.00,\"InterestOnArrears\":0,\"PmiArrears\":0.00,\"SuspenededPMIArrears\":0.00,\"CompoundingInterestArrears\":0.00,\"DivertingInterestArrears\":0.00,\"DatAgrmntSign\":\"2023-01-30\",\"CodAgrmntNo\":\"4921621\",\"InstallamentFrequency\":\"1\",\"TotalInstallmentNo\":0,\"TotalNoOfInstallmentsReceived\":0,\"InstallmentsOverDue\":0,\"InstallmentsReceivedAdv\":0,\"ProductCategory\":\"Agri\",\"BounceCheque\":0,\"LoanPurpose\":\"workingcaptial\",\"RateType\":\"0\",\"FlagInsured\":\"N\",\"FlagRepo\":\"N\",\"TotalPrinciplePaid\":0,\"TotalInterestPaid\":0}]}]}';
            
            LeadDedupeWrapper.CustomerDetailWrapper objWrapper = (LeadDedupeWrapper.CustomerDetailWrapper)JSON.deserialize(strCustomerDetailWrap,LeadDedupeWrapper.CustomerDetailWrapper.class);
            List<LeadDedupeController.CustomerODResponseWrapper> objWrapper11 = new List<LeadDedupeController.CustomerODResponseWrapper>();
            LeadDedupeController.CustomerODResponseWrapper objWrapper11Temp = (LeadDedupeController.CustomerODResponseWrapper)JSON.deserialize(strODWrap,LeadDedupeController.CustomerODResponseWrapper.class);
            objWrapper11.add(objWrapper11Temp);

            LeadDedupeWrapper.leadCBSCreditCardWrapper objWrapper1 = new LeadDedupeWrapper.leadCBSCreditCardWrapper();
            objWrapper1.CreditCardResponse = new List<LeadDedupeWrapper.cls_CreditCardResponse>();
            LeadDedupeWrapper.cls_CreditCardResponse objCCWrap = new LeadDedupeWrapper.cls_CreditCardResponse();
            objCCWrap.CustomerID = '987636';
            objCCWrap.AccountOpenDate = '2011-01-01';
            objCCWrap.SanctionedAmount = '10000';
            objWrapper1.CreditCardResponse.add(objCCWrap);

            
            objWrapper.boolIsKYCDone = false;
            objWrapper.lstAccountWrapper = new List<LeadDedupeWrapper.AccountWrapper>();
            Applicant__c objAppCopy = LeadDedupeController.copyApplicantfromCBS(objWrapper,objWrapper11,objWrapper1,objApp,false);
        Test.stopTest();
    }

    @isTest 
    static void testExceptionData(){
        Test.startTest();
            try{
                Applicant__c objApp = [Select Id, RecordTypeId, KYC_Status__c from Applicant__c where First_Name__c = 'Vikash' AND Loan__r.Stage__c <> 'PDD' LIMIT 1];
                String strCustomerDetailWrap = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":"0"}]}},"CustomerResponse":{"CustomerBasicInquiry":{"CustomerId":"21738937","NationalIdentificationCode":"21738937","CustomerName":{"Prefix":"Mr ","FirstName":"Parvez","MidName":"M","LastName":"Parmar","ShortName":"BHANUMATI S PARMAR","FormattedFullName":"Parvez#M#Parmar","FullName":"Parvez M Parmar"},"CustomerFullName":"Parvez M Parmar","CustomerAddress":{"Line1":"No 27 5th Main","Line2":"Nehru Road","Line3":"Patel Nagar","City":"AHMEDABAD","State":"GUJARAT","Country":"India","Zip":"380008"},"BirthDateText":"1957-11-25","CategoryType":"INDIVIDUAL SENIOR CITIZEN - FULL KYC","Sex":"F","IsImageAvailable":"false","IsSignatureAvailable":"false","CombWithdrawBal":"0.0","AgeOfCustRel":"2017-06-15","AadhaarDetail":{"AadhaarNumber":"835980598238"},"HomeBranch":"9045","MobileNumber":"9405809196","EmailAddress":"21738937@axc.com","IcType":"L","IcTypeDesc":"Lead Number","BankShortName":"Ahmedabad_Sarthik","PAN":"CSQPP5959P","CustomerType":"129"}},"AccountDetails":{"CustomerAccount":[{"ModuleCode":"C","ProductName":"20101-AU Savings Account","AccountId":"1711216011297197","CASAAccountName":"21738940","CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"JOO","BalanceBook":"0.00","UnclearFunds":"0.00","Classification":"NORMAL","Reason":"UNBLOCKED ","BillAmount":"0.00","OriginalBalance":"0.00","CurrentStatus":"7","CurrentStatusDescription":"ACCOUNT DORMANT","AcyAmount":"0.00","AvailableBalance":"0.00","LcyAmount":"0.00","TotalAcyAmount":"0.00","TotalLcyAmount":"0.00","BranchName":"Ahmedabad_Relief Road","ExternalAccountId":"0","FutureDatedAmount":"0.00","SafeDepositBoxId":"0","DateAccountOpen":"2017-06-15","DateRelation":"2017-06-15","MonthsSinceActive":"64","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"0.00","DateValue":"2017-06-15","BalPrincipal":"0","IntRate":"0","LienAmount":"0","InstallmentAmount":"0","OtherArrear":"0","BranchCode":"2160","IsTDLinkage":"N  ","HoldAmount":"27","ODLimitSactioned":"0","ODLimitUtilized":"0","OperationMode":"EITHER OR SURVIVORnull","SmallClearingAccountNo":"000708","CASARelationshipDetails":[{"CustomerId":"21738940","Emailid":"21738940@axc.com","JointHolderName":"MAHENDRABHAI S PARMAR","MobileNo":"21738940","Relationship":"JOF"}],"AmtGoal":"0","ProductCode":"20101","Tenure":"0 Months 0 Days 0 Years "},{"ModuleCode":"L","ProductName":"10601-MSME Business Funding","AccountId":"9001060127032470","CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"COB","BalanceBook":"1415400.00","UnclearFunds":"0.00","Classification":"NORMAL","Reason":"          ","BillAmount":"0.00","OriginalBalance":"1400000.00","CurrentStatus":"8","CurrentStatusDescription":"ACCOUNT OPEN REGULAR","AcyAmount":"1415400.00","AvailableBalance":"1415400.00","LcyAmount":"1415400.00","TotalAcyAmount":"1582205.80","TotalLcyAmount":"1582205.80","BranchName":"Jaipur_Asset Center","LoanApplicationNumber":"8603332","FutureDatedAmount":"0.00","SafeDepositBoxId":"0","Iban":"IN36109990010601270","DateAccountOpen":"2022-10-13","MonthsSinceActive":"0","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"1582205.80","BalPrincipal":"0","IntRate":"18","MaturityDate":"2032-09-05","LienAmount":"0","InstallmentAmount":"0","OtherArrear":"0","BranchCode":"9000","IsTDLinkage":"N  ","DisbursedAmount":"1400000","EmiTenure":"118","LoanAccountName":"Dandiya Store","AmtGoal":"0","ProductCode":"10601","Tenure":"118 Months 0 Days 0 Years "},{"ModuleCode":"L","ProductName":"10601-MSME Business Funding","AccountId":"9001060100000114","CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"SOW","BalanceBook":"166805.80","UnclearFunds":"0.00","Classification":"NORMAL","Reason":"          ","BillAmount":"0.00","OriginalBalance":"500000.00","CurrentStatus":"8","CurrentStatusDescription":"ACCOUNT OPEN REGULAR","AcyAmount":"166805.80","AvailableBalance":"166805.80","LcyAmount":"166805.80","TotalAcyAmount":"1582205.80","TotalLcyAmount":"1582205.80","BranchName":"Ahmedabad Asset_Center","LoanApplicationNumber":"9001060100000114              ","FutureDatedAmount":"0.00","SafeDepositBoxId":"0","DateAccountOpen":"2011-07-31","MonthsSinceActive":"0","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"1582205.80","BalPrincipal":"0","IntRate":"20","MaturityDate":"2018-08-15","LienAmount":"0","InstallmentAmount":"0","OtherArrear":"60659.8","BranchCode":"9045","IsTDLinkage":"N  ","DisbursedAmount":"500000","EmiTenure":"84","LoanAccountName":"BHANUMATI S PARMAR","AmtGoal":"0","ProductCode":"10601","Tenure":"84 Months 0 Days 0 Years "}],"IsCustomerSchemeAvailable":"false"}}';
                String strODWrap = '{\"TransactionStatus\":{\"ResponseCode\":\"0\",\"ResponseMessage\":\"Success\",\"ExtendedErrorDetails\":{\"messages\":[{\"code\":0}]}},\"AccountDetail\":[{\"ModuleCode\":\"L\",\"ProductName\":\"10705-HomeTopup\",\"AccountId\":\"9001070530341114\",\"CurrencyCode\":1,\"CurrencyShortName\":\"INR\",\"CustomerRelationship\":\"SOW\",\"BalanceBook\":1015417.00,\"UnclearFunds\":0.00,\"Classification\":\"NORMAL\",\"Reason\":\"\",\"BillAmount\":0.00,\"OriginalBalance\":1000000.00,\"CurrentStatus\":\"8\",\"CurrentStatusDescription\":\"ACCOUNTOPENREGULAR\",\"AcyAmount\":1015417.00,\"AvailableBalance\":1015417.00,\"LcyAmount\":1015417.00,\"TotalAcyAmount\":1015417.00,\"TotalLcyAmount\":1015417.00,\"BranchName\":\"JaipurCentralOffice_Mansarovar\",\"LoanApplicationNumber\":\"111898799\",\"FutureDatedAmount\":0.00,\"SafeDepositBoxId\":0,\"Iban\":\"IN71109990010705303\",\"DateAccountOpen\":\"2023-01-30\",\"MonthsSinceActive\":0,\"BalUncollectedPrinc\":0.00,\"BalUncollectedInt\":0.00,\"TotalBalUncollecPrinc\":0.00,\"TotalBalUncollecInt\":0.00,\"TotalBalBook\":1015417.00,\"BalPrincipal\":0,\"IntRate\":17,\"MaturityDate\":\"2033-01-30\",\"LienAmount\":0,\"InstallmentAmount\":0,\"OtherArrear\":0,\"BalCombinedAcy\":0,\"BalCombinedLcy\":0,\"BranchCode\":\"2011\",\"IsTDLinkage\":\"N\",\"LoanAccountDetails\":[{\"CustomerId\":27972650,\"AccountNo\":\"9001070530341114\",\"BranchName\":\"JaipurCentralOffice_Mansarovar\",\"ProdCode\":\"10705\",\"ProdName\":\"HomeTopup\",\"CurrencyName\":\"1\",\"LoanTerm\":120,\"SanctionedAmount\":1000000,\"MaturityDate\":\"2033-01-30\",\"AcctOpenDate\":\"2023-01-30\",\"DisbAmount\":1000000,\"PaidInstallment\":984583,\"NextDueDate\":\"2023-03-30\",\"OutStandingLoanAmount\":1015417.0000000000,\"UnpaidInstallment\":15417,\"InterestRateVariance\":4.0,\"InterestRate\":20.0,\"LoanRepaymentMode\":\"3\",\"AccountCurrency\":\"1\",\"AccountStatus\":\"8\",\"NextInstallmentDue\":\"16667.00\",\"PrincipalBalance\":1000000.00,\"UnbilledPrincipalBalance\":1000000.00,\"AmountDisbursedToday\":0.00,\"FutureInterest\":0,\"InstallmentArrears\":15417.00,\"OtherArrears\":0.00,\"MinAmountDue\":16667.00,\"UncollectedInterest\":0.00,\"UnbilledPenaltyInterest\":274.00,\"UnbilledServiceCharge\":0.00,\"AmountPaidToday\":0.00,\"RpaBalance\":0.00,\"UnbilledInterest\":10000.00,\"UnbilledAdditionalPenaltyInterest\":0,\"UnclearedFunds\":0.00,\"AvailableBalance\":0.00,\"TotalOutstandings\":1015417.00,\"InterestOnArrears\":0,\"PmiArrears\":0.00,\"SuspenededPMIArrears\":0.00,\"CompoundingInterestArrears\":0.00,\"DivertingInterestArrears\":0.00,\"DatAgrmntSign\":\"2023-01-30\",\"CodAgrmntNo\":\"344121123\",\"InstallamentFrequency\":\"1\",\"TotalInstallmentNo\":84,\"TotalNoOfInstallmentsReceived\":0,\"InstallmentsOverDue\":1,\"InstallmentsReceivedAdv\":0,\"ProductCategory\":\"HOMELOAN\",\"BounceCheque\":0,\"LoanPurpose\":\"home\",\"RateType\":\"1\",\"FlagInsured\":\"N\",\"FlagRepo\":\"N\",\"TotalPrinciplePaid\":0,\"TotalInterestPaid\":0}]},{\"ModuleCode\":\"L\",\"ProductName\":\"10614-PradhanMantriMudraYojanaTermL\",\"AccountId\":\"9001061430341093\",\"CurrencyCode\":1,\"CurrencyShortName\":\"INR\",\"CustomerRelationship\":\"SOW\",\"BalanceBook\":0.00,\"UnclearFunds\":0.00,\"Classification\":\"NORMAL\",\"Reason\":\"\",\"BillAmount\":0.00,\"OriginalBalance\":1000000.00,\"CurrentStatus\":\"8\",\"CurrentStatusDescription\":\"ACCOUNTOPENREGULAR\",\"AcyAmount\":0.00,\"AvailableBalance\":0.00,\"LcyAmount\":0.00,\"TotalAcyAmount\":1015417.00,\"TotalLcyAmount\":1015417.00,\"BranchName\":\"JhandewalanDelhiAssetCenter\",\"LoanApplicationNumber\":\"4921621\",\"FutureDatedAmount\":0.00,\"SafeDepositBoxId\":0,\"Iban\":\"IN61109990010614303\",\"DateAccountOpen\":\"2023-01-30\",\"MonthsSinceActive\":0,\"BalUncollectedPrinc\":0.00,\"BalUncollectedInt\":0.00,\"TotalBalUncollecPrinc\":0.00,\"TotalBalUncollecInt\":0.00,\"TotalBalBook\":1015417.00,\"BalPrincipal\":0,\"IntRate\":18,\"MaturityDate\":\"1950-01-01\",\"LienAmount\":0,\"InstallmentAmount\":0,\"OtherArrear\":0,\"BalCombinedAcy\":0,\"BalCombinedLcy\":0,\"BranchCode\":\"9109\",\"IsTDLinkage\":\"N\",\"LoanAccountDetails\":[{\"CustomerId\":27972650,\"AccountNo\":\"9001061430341093\",\"BranchName\":\"JhandewalanDelhiAssetCenter\",\"ProdCode\":\"10614\",\"ProdName\":\"PradhanMantriMudraYojanaTermLoan\",\"CurrencyName\":\"1\",\"LoanTerm\":20,\"SanctionedAmount\":1000000,\"MaturityDate\":\"1950-01-01\",\"AcctOpenDate\":\"2023-01-30\",\"DisbAmount\":0,\"PaidInstallment\":1000000,\"NextDueDate\":\"1800-01-01\",\"OutStandingLoanAmount\":0,\"UnpaidInstallment\":0,\"InterestRateVariance\":16.0,\"InterestRate\":34.0,\"LoanRepaymentMode\":\"3\",\"AccountCurrency\":\"1\",\"AccountStatus\":\"8\",\"NextInstallmentDue\":\"0.00\",\"PrincipalBalance\":0.00,\"UnbilledPrincipalBalance\":0.00,\"AmountDisbursedToday\":0.00,\"FutureInterest\":0,\"InstallmentArrears\":0.00,\"OtherArrears\":0.00,\"MinAmountDue\":0.00,\"UncollectedInterest\":0.00,\"UnbilledPenaltyInterest\":0.00,\"UnbilledServiceCharge\":0.00,\"AmountPaidToday\":0.00,\"RpaBalance\":0.00,\"UnbilledInterest\":0.00,\"UnbilledAdditionalPenaltyInterest\":0,\"UnclearedFunds\":0.00,\"AvailableBalance\":1000000.00,\"TotalOutstandings\":0.00,\"InterestOnArrears\":0,\"PmiArrears\":0.00,\"SuspenededPMIArrears\":0.00,\"CompoundingInterestArrears\":0.00,\"DivertingInterestArrears\":0.00,\"DatAgrmntSign\":\"2023-01-30\",\"CodAgrmntNo\":\"4921621\",\"InstallamentFrequency\":\"1\",\"TotalInstallmentNo\":0,\"TotalNoOfInstallmentsReceived\":0,\"InstallmentsOverDue\":0,\"InstallmentsReceivedAdv\":0,\"ProductCategory\":\"Agri\",\"BounceCheque\":0,\"LoanPurpose\":\"workingcaptial\",\"RateType\":\"0\",\"FlagInsured\":\"N\",\"FlagRepo\":\"N\",\"TotalPrinciplePaid\":0,\"TotalInterestPaid\":0}]}]}';
                
                LeadDedupeWrapper.CustomerDetailWrapper objWrapper = (LeadDedupeWrapper.CustomerDetailWrapper)JSON.deserialize(strCustomerDetailWrap,LeadDedupeWrapper.CustomerDetailWrapper.class);
                List<LeadDedupeController.CustomerODResponseWrapper> objWrapper11 = new List<LeadDedupeController.CustomerODResponseWrapper>();
                LeadDedupeController.CustomerODResponseWrapper objWrapper11Temp = (LeadDedupeController.CustomerODResponseWrapper)JSON.deserialize(strODWrap,LeadDedupeController.CustomerODResponseWrapper.class);
                objWrapper11.add(objWrapper11Temp);

                LeadDedupeWrapper.leadCBSCreditCardWrapper objWrapper1 = new LeadDedupeWrapper.leadCBSCreditCardWrapper();
                objWrapper1.CreditCardResponse = new List<LeadDedupeWrapper.cls_CreditCardResponse>();
                LeadDedupeWrapper.cls_CreditCardResponse objCCWrap = new LeadDedupeWrapper.cls_CreditCardResponse();
                objCCWrap.CustomerID = '987636';
                objCCWrap.AccountOpenDate = '2011-01-01';
                objCCWrap.SanctionedAmount = '10000';
                objWrapper1.CreditCardResponse.add(objCCWrap);

                
                objWrapper.boolIsKYCDone = false;
                objWrapper.lstAccountWrapper = new List<LeadDedupeWrapper.AccountWrapper>();
                Applicant__c objAppCopy = LeadDedupeController.copyApplicantfromCBS(objWrapper,objWrapper11,objWrapper1,NULL,false);
            }
            catch(Exception ex) {}
            
        Test.stopTest();
    }
}