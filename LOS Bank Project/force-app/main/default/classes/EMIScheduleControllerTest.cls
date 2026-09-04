@isTest
public with sharing class EMIScheduleControllerTest {
    /*
    public class EMIScheduleCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"TransactionStatus" : {"ResponseCode" : null,"ResponseMessage" : null,"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {"messages" : [ {"code" : "0","message" : null} ]}},"PostingDate" : "20230215","Response" : [ {"StageNumber" : "1","InstallmentCounter" : "1","InstallmentStartDate" : "20230215","InstallmentDate" : "20230218","InterestRate" : "10.6","PrincipalAmount" : "41481.0000000000","InterestAmount" : "318.0000000000","SubsidyAmount" : "0","PremiumAmount" : "0","ServiceChargeAmount" : "0","CapitalizedAmount" : "0","InstallmentAmount" : "41799","PrincipalBalanceAmount" : "318622.0000000000","TotalInstallmentAmount" : "41799","NumberOfDays" : "3"}]}');
            return res;
        }
        
    }

    @TestSetup
    static void makeData(){

        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'EMI Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaAddressMatchServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);

        

        Generic_Master__c rateChartCode = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            Rate_Chart_Code__c='101', 
            CBS_Pricing__c=9.0,
            Product__c='10203',
            Rate_Type__c='Fixed',
            Schedule_Code__c='909',
            RecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByDeveloperName().get('Rate_Chart_Code').getRecordTypeId()

        ),true);

        Account branchMaster = new Account(Account_Name__c= 'Pune-Dealer', Account_Code__c  = '097', Name = 'Pune-Dealer');
        insert branchMaster;

        Loan_Application__c loanApplChild = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Loan_Amount__c  = 120000,
            Product__c = '10203',
            Tenure__c = 8,
            Type_of_Rate__c = 'Fixed',
            ROI__c=9.0,
            Schedule_Type__c='VPI',
            Branch_Master__c=branchMaster.Id,
            EMI_Frequency__c='MONTHLY',
            EMI_Date__c='10'

        ),true); 

        EMI_Schedule__c emiSchedule = new EMI_Schedule__c(stage_number__c=1, installment_number__c=4,installment_amount__c=1200, loan_application__c=loanApplChild.Id, isInactive__c=false);
        insert emiSchedule;

        Integration_Checklist__c ic = new Integration_Checklist__c();
        ic.Response__c='{"TransactionStatus" : {"ResponseCode" : null,"ResponseMessage" : null,"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {"messages" : [ {"code" : "0","message" : null} ]}},"PostingDate" : "20230215","Response" : [ {"StageNumber" : "1","InstallmentCounter" : "1","InstallmentStartDate" : "20230215","InstallmentDate" : "20230218","InterestRate" : "10.6","PrincipalAmount" : "41481.0000000000","InterestAmount" : "318.0000000000","SubsidyAmount" : "0","PremiumAmount" : "0","ServiceChargeAmount" : "0","CapitalizedAmount" : "0","InstallmentAmount" : "41799","PrincipalBalanceAmount" : "318622.0000000000","TotalInstallmentAmount" : "41799","NumberOfDays" : "3"}]}';
        ic.Request_id__c='ABC';
        ic.Integration_Master__c=intmassearch1.Id;
        ic.Loan_Application__c=loanApplChild.Id;
        insert ic;
        
    }

    @isTest
    public static void testMethod1(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EMIScheduleCallout());        
        Loan_Application__c loan = [Select Id,Name,Application_Number__c,Schedule_Code__c,EMI_Date__c,EMI_Frequency__c, Loan_Amount__c,Product__c,Tenure__c,Type_of_Rate__c,ROI__c,Schedule_Type__c,Branch_Master__c, Branch_Master__r.Account_Code__c from Loan_Application__c];
        EMIScheduleAPIController.callEMIScheduleAPI(loan);
        EMIScheduleAPIController.getPDFData(loan,'ABC');
        EMIScheduleAPIController.getLatestEmiSchedule(loan);

        EMIScheduleAPIHandler.MessageWrapper wrap1 = new EMIScheduleAPIHandler.MessageWrapper();
        wrap1.code = '101';
        wrap1.message = 'Hello World';

        EMIScheduleAPIHandler.TransactionStatusWrapper wrap2 = new EMIScheduleAPIHandler.TransactionStatusWrapper();
        wrap2.ResponseCode = '101';
        wrap2.ResponseMessage = 'Hello World';

        EMIScheduleAPIHandler.ExtendedErrorDetailsWrapper wrap3 = new EMIScheduleAPIHandler.ExtendedErrorDetailsWrapper();
        wrap3.messages=new List<EMIScheduleAPIHandler.MessageWrapper>();
        wrap3.messages.add(wrap1);

        wrap2.ExtendedErrorDetails =  wrap3;
        Integration_Checklist__c ic = [Select Id, Response__c from Integration_Checklist__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', String.valueOf(ic.Id));
        EMISchedulePageController newController = new EMISchedulePageController();
        EMISchedulePageController.getResponse();
        Test.stopTest();
    }
    */
}