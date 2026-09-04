@isTest
public class AUSFPreApprovedCheckControllerTest {
 	@testSetup static void setup() {
         Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            ROI__c=3,
            Total_Loan_Amount__c=2000
        ),true);
        Pre_Approved_Offer__c preApproved = (Pre_Approved_Offer__c)TestFactory.createSObject(new Pre_Approved_Offer__c(
            Loan_Application__c   = loanAppl.Id,
            Is_Selected__c   = true,
            MinLoanTenureinMonths__c  = 5,
            RateofInterest__c=2
        ),true);
        Pre_Approved_Offer__c preApproved1 = (Pre_Approved_Offer__c)TestFactory.createSObject(new Pre_Approved_Offer__c(
            Loan_Application__c   = loanAppl.Id,
            Is_Selected__c   = true,
            MinLoanTenureinMonths__c  = 5,
            RateofInterest__c=3,
            MaxLoanTenureinMonths__c=10,
            FirstOfferAmount__c=2000
        ),true);
        //Id existingColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Existing Collateral').getRecordTypeId();

        Collateral__c coll2 = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId()
            
        ),true);
        
 	}
    @IsTest
    static void getLoanApplicationStageTest(){
         Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
         AUSFPreApprovedCheckController.getLoanApplicationStage(loanObj.id);
    }
    @isTest static void testPreApprovedWrapper(){
        AUSFPreApprovedCheckController.PreApprovedWrapper preApproved = new AUSFPreApprovedCheckController.PreApprovedWrapper();
        preApproved.isdetailInComplete=false;
        preApproved.isPriceStage=false;
    }
}