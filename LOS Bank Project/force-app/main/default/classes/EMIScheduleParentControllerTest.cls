@isTest
public class EMIScheduleParentControllerTest{

public static TestMethod void testM1() {
    EMIScheduleParentController ob = new EMIScheduleParentController();
    
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
    Apexpages.currentpage().getparameters().put('id',emiSchedule.id);
    
}
}