@isTest
public class CreditApprovalHandlerTest {

    @testSetup static void setup() {
        List<Loan_Application__c> loanList = new List<Loan_Application__c>();
		RecordType rd=[select id from RecordType where name='Two Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='QDE',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id            
        ),false);
        loanList.add(loanAppl);
        RecordType rd1=[select id from RecordType where name='Four Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl1 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='QDE',
            Final_Exposure__c =10,
            RecordTypeId=rd1.Id            
        ),false);
        loanList.add(loanAppl1);
        Loan_Application__c loanAppl2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='DDE',
            Final_Exposure__c =10,
            RecordTypeId=rd1.Id
        ),false);
        loanList.add(loanAppl2);
         Loan_Application__c loanAppl3 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='Credit',
            Final_Exposure__c =10,
            RecordTypeId=rd1.Id,
            Sanction_Status__c = 'Issued'
        ),false);
        loanList.add(loanAppl3);
        insert loanList;
        Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                First_Name__c = 'Vikash',
                Middle_Name__c = 'Kumar',
                Last_Name__c = 'Mandal',
                Loan__c =loanAppl.Id,
                Customer_Name__c='Vikas',
                Customer_Type__c='Individual',
	            RecordTypeId = applicantRecordTypeId
            ),true);
        Id collateralUsedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        Collateral__c coll1 = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' ,
            Vehicle_Category__c  = 'TestCat', RecordTypeId = collateralUsedRecordTypeId,Manufacture_year_month__c='202304'
        ),true);
        
    }
    
    @isTest static void testCreditApprovalMethod() {
        List<Loan_application__c> loanList = new List<Loan_application__c>();
        for(Loan_application__c loan : [SELECT Id FROM Loan_application__c WHERE Stage__c = 'QDE'])
        {
            loan.Stage__c='Credit';
            loan.BRE_Approval_Level__c = 'L1';
            loan.BRE_Decision__c = 'NSTP';
            loanList.add(loan);
        }
        Loan_application__c loanApp = [SELECT Id FROM Loan_application__c WHERE Stage__c = 'DDE' LIMIT 1];
        loanApp.Stage__c = 'Pricing';
        loanList.add(loanApp);
		Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp.Id,  Approval_Type__c = 'Pricing' , Approver__c = UserInfo.getUserId(), Type__c = 'Base',
            Archived__c = false
        ),true); 
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanList[0].Id,  Approval_Type__c = 'Credit' , Approver__c = UserInfo.getUserId(), Type__c = 'Base',
            Archived__c = false
        ),true); 
        Test.startTest();
            try {
                update loanList;
            }
            catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest static void testRMBApprovers(){
        Loan_application__c loan = [SELECT Id FROM Loan_application__c WHERE Stage__c = 'Credit' LIMIT 1];
        try {
            CreditApprovalHandler.createRBMTatkalApprovers(new Set<Id>{loan.Id});
        }
        catch(Exception ex){}
    }
}