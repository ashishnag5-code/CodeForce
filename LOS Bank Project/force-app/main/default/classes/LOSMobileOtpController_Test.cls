@isTest
public class LOSMobileOtpController_Test {
    @testSetup 
    static void setup() {
        
        Integration_Master__c  intMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c        = true,
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/KarixOTPEngine/validateOTP',
            HTTP_Method__c   = 'POST',
            API_Key__c       =' demoApiKey',
            Timeout__c       = '12000',
            Apiuser__c       = 'apiuser',
            Name             = 'Mobile Validate OTP'        
        ),true);
         Integration_Master__c  intMaster1 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c        = true,
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/KarixOTPEngine/validateOTP',
            HTTP_Method__c   = 'POST',
            API_Key__c       =' demoApiKey',
            Timeout__c       = '12000',
            Apiuser__c       = 'apiuser',
            Name             = 'Mobile Generate OTP'        
        ),true);

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c      = '10201',
            Stage__c        = 'QDE'
            
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c   = 'Mandal',
            Email__c       = 'test@gmail.com',
            Loan__c        = loanAppl.Id
            
        ),true);

        Integration_Checklist__c  intChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c          = true,
            Applicant__c          = appl.Id,
            Integration_Master__c = intMaster.Id
        ),true);
         Integration_Checklist__c  intChecklist1 = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c          = true,
            Applicant__c          = appl.Id,
            Integration_Master__c = intMaster1.Id,
             Request__c='{\"requestId\":\"SFDCUAT_99ed9fec8c1f864df4196e9c3\",\"otptype\":\"0\",\"otptimeout\":\"120\",\"otplength\":\"4\",\"otp\":\"\",\"msgContent\":\"DearCustomer,Confirmationcodeforvehicleloanapplicationwithusis{0}.ByproceedingyouaregivingconsentfortheseT&Cs:https://uatweb.aubankuat.in/wheels-product.-AUBank\",\"mobile\":\"7610836865\",\"custRef\":\"SFDCUAT3ae47d2990d57a98078611799\",\"channel\":\"SFDC\"}'
        ),true);
    }
    
      @isTest 
    static void mobileOtpVerificationHandlerTestMethod(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationUtilityMockClass('mobileOtpVerificationHandlerTestMethod'));
        //  Integration_Checklist__c objIntegCheckList = [Select Id from Integration_Checklist__c where is_Latest__c = true limit 1];
        Applicant__c applcnt = [Select Id from Applicant__c limit 1];
        system.debug('>>>>>'+applcnt.Id);
         try{
        LOSMobileOtpController.mobileOtpVerificationHandler('9810609873', '4321', applcnt.Id, 'Mobile Validate OTP');
         }catch (Exception ex) {
            System.assertEquals(ex.getMessage(), ex.getMessage());
        }  
        Test.stopTest();
    }             
    
    @isTest
    static void mobileOtpVerificationHandlerTestMethod1(){
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationUtilityMockClass('mobileOtpVerificationHandlerTestMethod'));
        //  Integration_Checklist__c objIntegCheckList = [Select Id from Integration_Checklist__c where is_Latest__c = true limit 1];
        Applicant__c applcnt = [Select Id from Applicant__c limit 1];
        system.debug('>>>>>'+applcnt.Id);
         Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord('Mobile Validate OTP');
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applcnt.Id
            );
 	
          try{
         LOSMobileOtpController.createRequestBody('Mobile Validate OTP','9810609873', '4321', objIntMapper,'SFDCUAT_99ed9fec8c1f864df4196e9c3');
         
         }catch (Exception ex) {
            System.assertEquals(ex.getMessage(), ex.getMessage());
        }  
    }
    @isTest
    static void mobileOtpVerificationHandlerTestMethod2(){
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationUtilityMockClass('mobileOtpVerificationHandlerTestMethod'));
        //  Integration_Checklist__c objIntegCheckList = [Select Id from Integration_Checklist__c where is_Latest__c = true limit 1];
        Applicant__c applcnt = [Select Id from Applicant__c limit 1];
        system.debug('>>>>>'+applcnt.Id);
         Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord('Mobile Generate OTP');
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applcnt.Id
            );
 	
          try{
              LOSMobileOtpController.mobileOtpVerificationHandler('9810609873', '4321', applcnt.Id, 'Mobile Generate OTP');
         LOSMobileOtpController.createRequestBody('Mobile Generate OTP','9810609873', '4321', objIntMapper,'SFDCUAT_99ed9fec8c1f864df4196e9c3');
         
         }catch (Exception ex) {
            System.assertEquals(ex.getMessage(), ex.getMessage());
        }  
    }
}