@isTest
public class EMIScheduleAPIControllerTest{

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
            Product__c='10503',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            Type_of_Rate__c ='Variable',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(Date.today().year(),Date.today().month(),10).addMonths(1),
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id,
            Schedule_Code__c = '1021',
            Schedule_Name__c = 'Half Yearly Variable',
            ROI__c = 10,
            Disbursement_Session_Id__c = '296805',
            Total_Loan_Amount__c = 600000,
            Disbursement_Date__c = myDate,
            LAN__c = '9001020130397011',
            //Schedule_Type__c = 'EPI',
            Schedule_Type__c = 'VPI',
            Emi_Frequency__c = 'HALF YEARLY'
        ),true);
        
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Disbursement Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDC'           
        ),true);
        
        Integration_Master__c integrationMast = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'EMI Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '123454',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDCf'           
        ),true);
        
        Id usedRecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Rate Chart Code').getRecordTypeId();
        
        Generic_Master__c grMaster = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            Address_Type__c='Permanent',
            Product__c = loanAppl.product__c,
            Residence_Status__c='Owned',  
            Residence_Type__c='Bungalow',
            recordTypeId = usedRecordTypeId
        ),true);
        
        grMaster.Rate_Type__c = 'Variable';
        grMaster.Rate_Chart_Code__c = '10100';
        grMaster.CBS_Pricing__c = 15.00;
        update grMaster;
    
       //    Integration_Master__c intMaster = new Integration_Master__c(Name  = 'Collateral Dedupe API');
       // insert intMaster;

        Integration_Checklist__c intChild = new Integration_Checklist__c();
        intChild.Response__c  = '{ "TransactionStatus" : {"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {},    "ValidationErrors" : [ null ]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChild.Loan_Application__c  = loanAppl.Id; 
        intChild.Integration_Master__c  = intmassearch2.Id; 
        intChild.Request_Id__c = '644a0f30c76c5a00e823e11e';
        insert intChild;
        
        Id branchRecordTypeId = Schema.SObjectType.Emi_schedule__c.getRecordTypeInfosByName().get('VPI').getRecordTypeId();
        Emi_schedule__c emi = new Emi_schedule__c();
        emi.stage_number__c=1;
        emi.installment_number__c=2;
        emi.installment_amount__c=1000;
        emi.loan_application__c=loanAppl.Id;
        emi.isInactive__c=false;
        emi.RecordTypeId = branchRecordTypeId;
        insert emi;
        
        //date 2
        Loan_Application__c loanAppl2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            Type_of_Rate__c ='Variable',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(Date.today().year(),Date.today().month(),10).addMonths(1),
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id,
            Schedule_Code__c = '1021',
            Schedule_Name__c = 'Quarterly Variable',
            ROI__c = 10,
            Disbursement_Session_Id__c = '296805',
            Total_Loan_Amount__c = 600000,
            Disbursement_Date__c = myDate,
            LAN__c = '9001020130397011',
            Schedule_Type__c = 'VPI',
            Emi_Frequency__c = 'QUARTERLY'
        ),true);
        
        Id branchRecordTypeId2 = Schema.SObjectType.Emi_schedule__c.getRecordTypeInfosByName().get('VPI').getRecordTypeId();
        Emi_schedule__c emi2 = new Emi_schedule__c();
        emi2.stage_number__c=1;
        emi2.installment_number__c=2;
        emi2.installment_amount__c=1000;
        emi2.loan_application__c=loanAppl2.Id;
        emi2.isInactive__c=false;
        emi2.RecordTypeId = branchRecordTypeId2;
        insert emi2;
        
        Integration_Master__c intmassearch22 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Disbursement Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDC'           
        ),true);
        
        
        Integration_Checklist__c intChild2 = new Integration_Checklist__c();
        intChild.Response__c  = '{ "TransactionStatus" : {"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {},    "ValidationErrors" : [ null ]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChild.Loan_Application__c  = loanAppl2.Id; 
        intChild.Integration_Master__c  = intmassearch22.Id; 
        intChild.Request_Id__c = '644a0f30c76c5a00e823e11e';
        insert intChild2;
        
        //date 3
        Loan_Application__c loanAppl3 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            Type_of_Rate__c ='Variable',
            EMI_Date__c = '5',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id,
            Schedule_Code__c = '1021',
            ROI__c = 10,
            Disbursement_Session_Id__c = '296805',
            Total_Loan_Amount__c = 600000,
            Disbursement_Date__c = myDate,
            LAN__c = '9001020130397011',
            Schedule_Type__c = 'VPI',
            Emi_Frequency__c = 'HALF YEARLY'
        ),true);
        
        Id branchRecordTypeId3 = Schema.SObjectType.Emi_schedule__c.getRecordTypeInfosByName().get('VPI').getRecordTypeId();
        Emi_schedule__c emi3 = new Emi_schedule__c();
        emi3.stage_number__c=1;
        emi3.installment_number__c=2;
        emi3.installment_amount__c=1000;
        emi3.loan_application__c=loanAppl3.Id;
        emi3.isInactive__c=false;
        emi3.RecordTypeId = branchRecordTypeId3;
        insert emi3;
        
        Integration_Master__c intmassearch3 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Disbursement Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDC'           
        ),true);
        
        Integration_Checklist__c intChild3 = new Integration_Checklist__c();
        intChild.Response__c  = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{},"ValidationErrors":[null]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChild.Loan_Application__c  = loanAppl3.Id; 
        intChild.Integration_Master__c  = intmassearch3.Id; 
        intChild.Request_Id__c = '644a0f30c76c5a00e823e11e';
        insert intChild3;
        
    }
    
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            //String fullJson = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":"123","message":"Message1"},{"code":"456","message":"message2"}]},"ValidationErrors":[null]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
            String fullJson = '{"TransactionStatus":{"ResponseCode":null,"ResponseMessage":null,"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":"0","message":null}]}},"PostingDate":"20240109","Response":[{"StageNumber":"1","InstallmentCounter":"1","InstallmentStartDate":"20240109","InstallmentDate":"20240510","InterestRate":"18","PrincipalAmount":"7698.0000000000","InterestAmount":"17302.0000000000","SubsidyAmount":"0","PremiumAmount":"0","ServiceChargeAmount":"0","CapitalizedAmount":"0","InstallmentAmount":"25000","PrincipalBalanceAmount":"278287.0000000000","TotalInstallmentAmount":"25000","NumberOfDays":"121"},{"StageNumber":"1","InstallmentCounter":"2","InstallmentStartDate":"20240510","InstallmentDate":"20241110","InterestRate":"18","PrincipalAmount":"59954.0000000000","InterestAmount":"25046.0000000000","SubsidyAmount":"0","PremiumAmount":"0","ServiceChargeAmount":"0","CapitalizedAmount":"0","InstallmentAmount":"85000","PrincipalBalanceAmount":"218333.0000000000","TotalInstallmentAmount":"85000","NumberOfDays":"180"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest 
    static void TestMethod1(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();  
        Loan_Application__c loanApp = [Select Id,Application_Number__c,Adhar_Card__c,Type_of_Rate__c,Loan_Amount__c,Product__c,Customer_Type__c,Stage__c,EMI_Date__c,
        Tenure__c,Branch_Master__c,Schedule_Code__c,ROI__c,Branch_Master__r.Account_Code__c,Disbursement_Session_Id__c,Total_Loan_Amount__c,Disbursement_Date__c,
                                       LAN__c,Schedule_Type__c, Schedule_Name__c, Emi_Frequency__c,First_EMI_Date__c,Name  from Loan_Application__c limit 1];
        Decimal netDisbursementAmount = 10.5;
        
        EMIScheduleAPIController.callEMIScheduleAPI(loanApp,'DisbursementOpsMaker',netDisbursementAmount);
        Test.stopTest();
    }
    @isTest 
    static void TestMethod2(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest(); 
    Loan_Application__c loanApp = [Select Id,Application_Number__c,Adhar_Card__c,Loan_Amount__c,Product__c,Customer_Type__c,Stage__c,EMI_Date__c,Type_of_Rate__c
        ,Tenure__c,Branch_Master__c,Schedule_Code__c,ROI__c,Branch_Master__r.Account_Code__c,Disbursement_Session_Id__c,Total_Loan_Amount__c,
                                   Disbursement_Date__c,LAN__c,Schedule_Type__c,Schedule_Name__c,Emi_Frequency__c,First_EMI_Date__c,Name  from Loan_Application__c limit 1];
        Decimal netDisbursementAmount = 10.5;
        EMIScheduleAPIController.callEMIScheduleAPI(loanApp,'DisbursementOpsMaker1',netDisbursementAmount);
    Test.stopTest();
    }
    
    @isTest 
    static void TestMethod3(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest(); 
    Loan_Application__c loanApp = [Select Id,Application_Number__c,Adhar_Card__c,Loan_Amount__c,Product__c,Customer_Type__c,Stage__c,EMI_Date__c,Type_of_Rate__c
        ,Tenure__c,Branch_Master__c,Schedule_Code__c,ROI__c,Branch_Master__r.Account_Code__c,Disbursement_Session_Id__c,Total_Loan_Amount__c,
                                   Disbursement_Date__c,LAN__c,Schedule_Type__c,Schedule_Name__c,Emi_Frequency__c,First_EMI_Date__c,Name  from Loan_Application__c limit 1];
        Decimal netDisbursementAmount = 10.5;
        EMIScheduleAPIController.getPDFData(loanApp,'644a0f30c76c5a00e823e11e','Disbursement Schedule');
    Test.stopTest();
    }
    
    @isTest
    static void TestMethod4(){
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RestMock());
        Loan_Application__c loanApp = [Select Id,name,Application_Number__c,Adhar_Card__c,Loan_Amount__c,Product__c,Customer_Type__c,Stage__c,EMI_Date__c,Type_of_Rate__c
        ,Tenure__c,Branch_Master__c,Schedule_Code__c,ROI__c,Branch_Master__r.Account_Code__c,Disbursement_Session_Id__c,Total_Loan_Amount__c,
                                       Disbursement_Date__c,LAN__c,Schedule_Type__c,Schedule_Name__c,Emi_Frequency__c,First_EMI_Date__c  from Loan_Application__c limit 1];
        Decimal netDisbursementAmount = 10.5;
        
        Integration_Master__c Im = [SELECT Id,name,Active__c,Timeout__c,End_Point_URL__c,HTTP_Method__c,API_Key__c,Include_Certificate__c,Apiuser__c FROM Integration_Master__c limit 1];
        EMIScheduleAPIController.getLatestEmiSchedule(loanApp,Im.name);
    Test.stopTest();
    }
    
     @isTest 
    static void TestMethod5(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest(); 
    Loan_Application__c loanApp = [Select Id,name,Application_Number__c,Adhar_Card__c,Loan_Amount__c,Product__c,Customer_Type__c,Stage__c,EMI_Date__c,Type_of_Rate__c
        ,Tenure__c,Branch_Master__c,Schedule_Code__c,ROI__c,Branch_Master__r.Account_Code__c,Disbursement_Session_Id__c,Total_Loan_Amount__c,
                                   Disbursement_Date__c,LAN__c,Schedule_Type__c,Schedule_Name__c,Emi_Frequency__c,First_EMI_Date__c  from Loan_Application__c limit 1];
        Decimal netDisbursementAmount = 10.5;
        EMIScheduleAPIController.getRepaymentScheduleForAuthor(loanApp.id);
    Test.stopTest();
    }
    
    @isTest 
    static void TestMethod6(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest(); 
    Loan_Application__c loanApp = [Select Id,name,Application_Number__c,Adhar_Card__c,Loan_Amount__c,Product__c,Customer_Type__c,Stage__c,EMI_Date__c,Type_of_Rate__c
        ,Tenure__c,Branch_Master__c,Schedule_Code__c,ROI__c,Branch_Master__r.Account_Code__c,Disbursement_Session_Id__c,Total_Loan_Amount__c,
                                   Disbursement_Date__c,LAN__c,Schedule_Type__c,Schedule_Name__c,Emi_Frequency__c ,First_EMI_Date__c 
        from Loan_Application__c WHERE Emi_Frequency__c = 'QUARTERLY' limit 1];
        Decimal netDisbursementAmount = 10.5;
        EMIScheduleAPIController.callEMIScheduleAPI(loanApp,'DisbursementOpsMaker1',netDisbursementAmount);
        //EMIScheduleAPIController.getRepaymentScheduleForAuthor(loanApp.id);
        
    Test.stopTest();
    }
    
    @isTest 
    static void TestMethod7(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest(); 
    Loan_Application__c loanApp = [Select Id,name,Application_Number__c,Adhar_Card__c,Loan_Amount__c,Product__c,Customer_Type__c,Stage__c,EMI_Date__c,Type_of_Rate__c,Tenure__c,Branch_Master__c,Schedule_Code__c,ROI__c,
    Branch_Master__r.Account_Code__c,Disbursement_Session_Id__c,Total_Loan_Amount__c,Disbursement_Date__c,LAN__c,Schedule_Type__c,Schedule_Name__c,Emi_Frequency__c,
                                   First_EMI_Date__c from Loan_Application__c 
    WHERE Emi_Frequency__c = 'HALF YEARLY' limit 1];
    Decimal netDisbursementAmount = 10.5;
    EMIScheduleAPIController.callEMIScheduleAPI(loanApp,'DisbursementOpsMaker1',netDisbursementAmount);
    EMIScheduleAPIController objEMIScheduleAPIController = new EMIScheduleAPIController();
    EMIScheduleAPIController.refetchEMI(loanApp.Id);
        //EMIScheduleAPIController.getRepaymentScheduleForAuthor(loanApp.id);
    Test.stopTest();
    }
    
    @isTest
    static void TestMethod8(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest(); 
        EMIScheduleAPIHandler.UserModifiedStageParameterWrapper ob = new EMIScheduleAPIHandler.UserModifiedStageParameterWrapper();
        ob.NumberOfInterestRepayments = 18;
        EMIScheduleAPIHandler.EMIScheduleResponseWrapper ob1 = new EMIScheduleAPIHandler.EMIScheduleResponseWrapper();
        ob1.PostingDate = '13';
        
        
        List<EMIScheduleAPIHandler.ResponseWrapper> lstEMISchedRespWrapper = new List<EMIScheduleAPIHandler.ResponseWrapper>();
        
        EMIScheduleAPIHandler.ResponseWrapper Ob3 = new EMIScheduleAPIHandler.ResponseWrapper();
        ob3.StageNumber = 44;
        ob3.InstallmentCounter = 4;
        ob3.InstallmentStartDate = '10/05/2023';
        ob3.InstallmentDate = '10/06/2023';
        ob3.InterestRate = 10.0;
        ob3.PrincipalAmount = 1000.0;
        ob3.InterestAmount = 100.0;
        ob3.SubsidyAmount = 10.0;
        ob3.PremiumAmount = 12.0;
        ob3.ServiceChargeAmount = 10.0;
        ob3.CapitalizedAmount = 10.0;
        ob3.InstallmentAmount = 34.0;
        ob3.PrincipalBalanceAmount = 44.0;
        ob3.TotalInstallmentAmount = 45;
        ob3.NumberOfDays = 43;
       // insert ob3;
        
        lstEMISchedRespWrapper.add(ob3);
    Test.stopTest();  
    }
    
    @isTest
    static void testWrappers(){
        Test.startTest();
        EMIScheduleAPIHandler.RepaymentScheduleResponseWrapper testWrapper = new EMIScheduleAPIHandler.RepaymentScheduleResponseWrapper();
        EMIScheduleAPIHandler.MessageWrapper messageWrapper = new EMIScheduleAPIHandler.MessageWrapper();
        Test.stopTest();
    }
   
}