@isTest
public class EMISchedulePageControllerTest{
@testSetup static void setup() {

Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        date myDate = date.newInstance(2023, 06, 23);
        
Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            Type_of_Rate__c ='Variable',
            EMI_Date__c = '10',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id,
            Schedule_Code__c = '1021',
            ROI__c = 10,
            Disbursement_Session_Id__c = '296805',
            Total_Loan_Amount__c = 600000,
            Disbursement_Date__c = myDate,
            LAN__c = '9001020130397011',
            Schedule_Type__c = 'EPI',
            Emi_Frequency__c = 'MONTHLY'
        ),true);
       
 
        Emi_schedule__c emi = new Emi_schedule__c();
        emi.stage_number__c=1;
        emi.installment_number__c=2;
        emi.installment_amount__c=1000;
        emi.loan_application__c=loanAppl.Id;
        emi.isInactive__c=false;
        insert emi;
        
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c  = loanAppl.Id, response__c = '{"TransactionStatus":{"ResponseCode":"00","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":null,"message":null}]}},"CRMFetchResults":[{"NewDataSet":[{"Table1":[{"Applicationstatus":"Documents Collected","BranchName":"Jaipur_Central Office_Mansarovar","LeadId":"2474","CustomerName":"ASFASFASF ASFASFAS","CustomerMobileNumber":"9679679679","LeadCreationDate":"08-01-2021 14:13:43","ProductName":"Home Construction","BranchCode":"2011","LoanAmount":"324124124"},{"Applicationstatus":"New Lead","BranchName":"Jaipur_Central Office_Mansarovar","LeadId":"6287584","CustomerName":"Krishnan","CustomerMobileNumber":"9679679679","LeadCreationDate":"04-04-2023 10:24:15","ProductName":"Auto Loan (New)","BranchCode":"2011","LoanAmount":"0"},{"Applicationstatus":"Assigned to Executive","BranchName":"Jaipur_Central Office_Mansarovar","LeadId":"2468","CustomerName":"xgsgsdgsdgsdgsd","CustomerMobileNumber":"9679679679","LeadCreationDate":"23-12-2020 15:22:39","ProductName":"Tractor (Refinance)","BranchCode":"2011","LoanAmount":"0"}]}]}]}');
        insert checklistRecord;
        
         Integration_Master__c intmast = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Disbursement Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaAddressMatchServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'            
        ),true);
        
        checklistRecord.Integration_Master__c =intmast.Id;
        UPDATE checklistRecord;
        
        Integration_Master__c intmast1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'EMI Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaAddressMatchServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'            
        ),true);
        
        Integration_Checklist__c checklistRecord1 = new Integration_Checklist__c(Loan_Application__c  = loanAppl.Id, Identifier_Number__c = '22rtt56' , response__c ='{"TransactionStatus" : {"ResponseCode" : null,"ResponseMessage" : null,"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {"messages" : [ {"code" : "0","message" : null} ]}},"PostingDate" : "20230215","Response" : [ {"StageNumber" : "1","InstallmentCounter" : "1","InstallmentStartDate" : "20230215","InstallmentDate" : "20230218","InterestRate" : "10.6","PrincipalAmount" : "41481.0000000000","InterestAmount" : "318.0000000000","SubsidyAmount" : "0","PremiumAmount" : "0","ServiceChargeAmount" : "0","CapitalizedAmount" : "0","InstallmentAmount" : "41799","PrincipalBalanceAmount" : "318622.0000000000","TotalInstallmentAmount" : "41799","NumberOfDays" : "3"}]}');
        insert checklistRecord1;
        
        checklistRecord1.Integration_Master__c =intmast1.Id;
        UPDATE checklistRecord1; 
        }

        private class RestMock implements HttpCalloutMock {       
            public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":"123","message":"Message1"},{"code":"456","message":"message2"}]},"ValidationErrors":[null]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
            }
        }
            
@isTest 
    static void TestMethod2() {
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();       
        Integration_Checklist__c ic = [SELECT id FROM Integration_Checklist__c WHERE Identifier_Number__c = '22rtt56' LIMIT 1];
        Apexpages.currentpage().getparameters().put('id', IC.Id);
        EMISchedulePageController controller = new EMISchedulePageController() ;
        EMISchedulePageController.getResponse();
        EMISchedulePageController.getTruncatedValue(22.4,22);
    Test.stopTest();
    }
    
    @isTest 
    static void TestMethod3(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest(); 
        Integration_Checklist__c ic = [SELECT id FROM Integration_Checklist__c where Integration_Master__r.Name = 'EMI Schedule' LIMIT 1];
        Apexpages.currentpage().getparameters().put('id', IC.Id);
        EMISchedulePageController controller = new EMISchedulePageController() ;
        EMISchedulePageController.getResponse();
    Test.stopTest();
    }
    
    @isTest 
    static void TestMethod4(){
    Test.startTest();
        EMISchedulePageController.getFormattedDate('12/06/2023');
    Test.stopTest();
    }
    


}