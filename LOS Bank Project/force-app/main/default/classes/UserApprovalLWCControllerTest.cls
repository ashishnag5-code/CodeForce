/*****
 * Class Name: UserApprovalLWCControllerTest
 * Description: UserApprovalLWCController
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-04-2023          -   Mohit M.            -   
 */
@isTest
public class UserApprovalLWCControllerTest {
    
     @testSetup static void setup() {
         Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true
            
        ),true);
         
         Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Sanction Tatkal' , Approver__c = UserInfo.getUserId(),
            Archived__c = false,Document_Name__c = 'Voter id Card',Approval_Status__c ='Pending',
            Approver_Level__c  = 'P1',Remarks__c='Testing'
        ),true);
     }
    
    @isTest
    public static void getUserRelatedRecordsTest(){
        Loan_Application__c loanAppl=[Select Id from Loan_Application__c LIMIT 1];
        Test.startTest();
           UserApprovalLWCController.getUserRelatedRecords(loanAppl.Id, 'SystemGeneratedDocs');
        Test.stopTest();
        
    }
    
    @isTest
    public static void createCustomFeedRecordsTest(){
        Loan_Application__c loanAppl=[Select Id from Loan_Application__c LIMIT 1];
        Test.startTest();
           UserApprovalLWCController.createCustomFeedRecords(loanAppl.Id, null, 'Testing');
        Test.stopTest();
        
    }
    
    @isTest
    public static void sendBackDocumentsTest(){
        Loan_Application__c loanAppl=[Select Id from Loan_Application__c LIMIT 1];
        Test.startTest();
           	UserApprovalLWCController.sendBackDocuments (loanAppl.Id, '','Loan Suraksha Charges has been rejected.',false);
        	UserApprovalLWCController.sendBackDocuments (loanAppl.Id, '','Loan Suraksha Charges has been rejected.',true);
        Test.stopTest();
        
    }
    
    @isTest
    public static void approveDocumentLettersTest(){
        Loan_Application__c loanAppl=[Select Id from Loan_Application__c LIMIT 1];
        Test.startTest();
           	UserApprovalLWCController.approveDocumentLetters (loanAppl.Id, '','Loan Suraksha Charges has been rejected.',false, 'RBMTatkal');
        	UserApprovalLWCController.approveDocumentLetters (loanAppl.Id, '','Loan Suraksha Charges has been rejected.',true, 'RBMTatkal');
        Test.stopTest();
        
    }

}