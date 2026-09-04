@isTest
public class CBSSIServiceTest {
    @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', Vehicle_Category__c ='TestCat'
        ),true);
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',LAN__c = 'testLAN',Repayment_Account_Number__c ='32432432',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,BRE_Status__c = Label.BRE_Status_Received,
            Branch_Master__c = accInstance.Id, BRE_Selected_Scheme__c = scheme1.id
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
    } 
    
    @isTest
    public static void getLADetailsTest(){ 
        Loan_Application__c loanAppl = [SELECT ID,BRE_Status__c, Branch_Master__r.Account_Code__c ,LAN__c , Repayment_Account_Number__c FROM Loan_Application__c LIMIT 1];
        Map<String,Loan_Application__c> paramsMap = new Map<String,Loan_Application__c>();
        paramsMap.put('LoanApplication', loanAppl);
        CBSSIService.generateRequest(paramsMap); 
        CBSSIService.CBSSIServiceResponseWrapper obj = new CBSSIService.CBSSIServiceResponseWrapper();
        CBSSIService.ExtendedErrorDetailsWrapper exd = new CBSSIService.ExtendedErrorDetailsWrapper();
        CBSSIService.TransactionStatusWrapper obj1 = new CBSSIService.TransactionStatusWrapper();
        CBSSIService.ValidationErrorWrapper obj2 = new CBSSIService.ValidationErrorWrapper();
        List<CBSSIService.ValidationErrorWrapper> lst2 = new List<CBSSIService.ValidationErrorWrapper>();
        CBSSIService.MessagesWrapper obj3 = new CBSSIService.MessagesWrapper();
        List<CBSSIService.MessagesWrapper> lst3 = new List<CBSSIService.MessagesWrapper>();
        obj3.code  = '10';
        obj3.message = 'test';
        //obj2.ErrorMessage = 'Test Message';
        lst3.add(obj3);
        exd.messages = lst3;
        obj1.ResponseCode = '200';
        obj1.ResponseMessage = 'test';
        obj1.ExtendedErrorDetails = exd;
        obj2.ErrorMessage = 'testMsaage';
        lst2.add(obj2);
        obj1.ValidationErrors = lst2;
    }
}