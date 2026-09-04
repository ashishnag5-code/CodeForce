@isTest
public class EmailVerificationHandler_Test {
    @testSetup 
    static void setup() {
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c='QDE'
            
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Email__c = 'test@gmail.com',
            Loan__c =loanAppl.Id
            
        ),true);
        
        Integration_Master__c  intMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='emailendpoint',
            HTTP_Method__c ='GET',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Name = 'Email Domain Verification'
            
        ),true);
        
        Integration_Master__c  intMaster1 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='Email Verification',
            HTTP_Method__c ='GET',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Name = 'Email Verification'
            
        ),true);
        
            Integration_Checklist__c  intChecklist2 = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Applicant__c= appl.Id,
            Request_Id__c='IC001001002',
            Integration_Master__c = intMaster1.Id,
            Loan_Application__c = loanAppl.Id,
            Callback_Request__c = '{"message":{"requestTime":"Jun 23, 2023 12:48:46.873 PM IST","dmElapsedTime":90,"responseStatus":"ERROR","error":[{"errorCode":"401","description":"Bad Request"}]}}'
        ),true);
    }
    
    @isTest 
    static void doRestCalloutTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailVerificationCallout());
        Applicant__c objApp = [Select Id,Email__c from Applicant__c where First_Name__c = 'Vikash' limit 1];
        String emailId = 'email@gmail.com';
        EmailVerificationResponseWrapper objEmailVerificationResponse = EmailVerificationHandler.doRestCallout(emailId,objApp.Id,'',null);
        List<Object> recordList = new List<Object>();
        List<String> listOfRes = EmailVerificationHandler.generateRequest(recordList);
        String resp = EmailVerificationHandler.generateJSONResponse(recordList);
        system.debug('resp is '+objEmailVerificationResponse.result.data.regexp);
        Assert.areEqual(true,objEmailVerificationResponse.result.data.regexp);
        Test.stopTest();
    }
        /*@isTest  static void getApplicantTest2(){
        Test.startTest();
         Applicant__c appl = [SELECT Id from Applicant__c LIMIT 1];
        EmailVerificationHandler.applcntName(appl.Id);
        Test.stopTest();
        }*/
        
        @isTest  static void EmailVerificationTest2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailVerificationCallout());
        Applicant__c appl1 = [SELECT id from Applicant__c LIMIT 1];
        EmailVerificationHandler.emailVerificationApi('email@email.com',appl1.id);
        Test.stopTest();
        }
        
        @isTest static void TestM(){
        Test.startTest();
        EmailVerificationWrapper ob = new EmailVerificationWrapper();
            EmailVerificationWrapper.GenerateOtpWrapper ob1 = new EmailVerificationWrapper.GenerateOtpWrapper();
            ob1.requestId = 'rrreeerere';
            ob1.channel = 'channel';
            ob1.email = 'dummyTest@gmail.com.invalid';
            
            EmailVerificationWrapper.Result ob3 = new EmailVerificationWrapper.Result();
            ob3.message = 'Messsage is futile';
            
            EmailVerificationWrapper.ResponseWrapper ob2 = new EmailVerificationWrapper.ResponseWrapper();
            ob2.result = ob3;
            ob2.requestId = '34343';
            ob2.statuscode = '101';
            
            EmailVerificationWrapper.VerifyOtpWrapper ob4 = new EmailVerificationWrapper.VerifyOtpWrapper();
            ob4.requestId = 'rrwioweh4';
            ob4.channel = '443';
            ob4.Otp = '234';
            
        Test.stopTest();
        }
                                                      
    /*@isTest 
    static void doRestCalloutTest2(){
        Test.startTest();
        String strResponse = '{"result":{"meta":{"params":{"email":"meenakshigoyal286@gmail.com"}},"data":{"disposable":false,"webmail":true,"result":true,"accept_all":false,"smtp_check":true,"regexp":true,"mx_records":true,"email":"meenakshigoyal286@gmail.com"}},"request_id":"822c0fb2-f46e-4184-b7fc-a5eb0d01bda3","status-code":"101"}';

        SingleRequestMock fakeResponse = new SingleRequestMock(400,'success',strResponse,null);
                                                               
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        //Applicant__c objApp = [Select Id,Email__c from Applicant__c where First_Name__c = 'Vikash' limit 1];
        String emailId = 'email@gmail.com';
        EmailVerificationResponseWrapper objEmailVerificationResponse = EmailVerificationHandler.doRestCallout(emailId,'');
        List<Object> recordList = new List<Object>();
        List<String> listOfRes = EmailVerificationHandler.generateRequest(recordList);
        String resp = EmailVerificationHandler.generateJSONResponse(recordList);
        Test.stopTest();
        
    }*/

}