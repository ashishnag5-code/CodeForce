@isTest
public class LoanDisbursementOpsControllerTest {
    @testSetup static void setup() {
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
            Name ='TestAccount',
            Account_Code__c='2103',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10203',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10',
            Tenure__c = 10,
            Dealer_Master__c = dealerMaster.Id,
            Branch_Master__c = branchMaster.Id,
            Schedule_Code__c='10201',
            recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
       Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id);
      coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();
        coll.Insurance_Expiry_Date__c = Date.today().adddays(30);
      insert coll;
        Deviation__c deviation = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Deviation_Type__c  = 'Motor Insurance',
            Loan_Application__c   = loanAppl.Id
        ),true);
        Assignment__c assignment = new Assignment__c();
        assignment.Loan_Application__c = loanAppl.Id;
        insert assignment;
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Non Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Dob__c = System.today().addYears(-30),
            Education_qualification__c='GRADUATE',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Payment__c paymentTranche = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Account_Number__c = '1312312312312',
            IFSC_Code__c = 'HDFC0004444',
            Loan_Application__c  = loanAppl.Id,
            Inactive__c = false,
            Tranche_Number__c = 1,
            Payment_Recipient__c = 'Customer',
            Recordtypeid=Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Tranche').getRecordTypeId()
        ),true);
        Payment__c paymentRec = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Account_Number__c = '1312312312312',
            IFSC_Code__c = 'HDFC0004444',
            Loan_Application__c  = loanAppl.Id,
            Tranche__c = paymentTranche.Id,
            Payment_Mode__c = 'NEFT',
            Payment_Recipient__c = 'Customer',
            Recordtypeid=Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Payment_Favouring').getRecordTypeId()
            
        ),true);
        Payment__c paymentRec2 = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Account_Number__c = '1312312312312',
            IFSC_Code__c = 'HDFC0004444',
            Loan_Application__c  = loanAppl.Id,
            Payment_Mode__c = 'Cheque',
            Recordtypeid=Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Payment_Favouring').getRecordTypeId(),
            Payment_Recipient__c = 'Customer'
        ),true);
        Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow',
            Stability__c ='7',
            Latest_Cibil_Address_Match_Score__c=100
        ),true);
        Generic_Master__c objGM = new Generic_Master__c(Status__c ='Active', State__c='Rajasthan', Stage_Type__c='Kuch', Stage_Number__c =13123,Product__c='10201',Schedule_Code__c='10201',
                                                        Recordtypeid=Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByDeveloperName().get('EMI_Schedule').getRecordTypeId());
        insert objGM;
        
        Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Disbursement Schedule',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        Integration_Checklist__c  intChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Applicant__c= appl.Id,
            Request_Id__c='IC001001002',
            Integration_Master__c = CanDOIntegrationMaster.Id,
            Loan_Application__c = loanAppl.Id,
            Callback_Request__c = '{"message":{"requestTime":"Jun 23, 2023 12:48:46.873 PM IST","dmElapsedTime":90,"responseStatus":"ERROR","error":[{"errorCode":"401","description":"Bad Request"}]}}'
        ),true);
        
        Integration_Master__c bsrpslIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='CBS PSL/BSR Creation',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        Integration_Checklist__c  bsrpslLoanChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Request_Id__c='IC001001010',
            Integration_Master__c = bsrpslIntegrationMaster.Id,
            Loan_Application__c = loanAppl.Id,
            Status__c='Completed'
        ),true);
        Integration_Checklist__c  bsrpslApplChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Applicant__c= appl.Id,
            Request_Id__c='IC001001099',
            Integration_Master__c = bsrpslIntegrationMaster.Id,
            Status__c='Completed'
        ),true);
        
           Integration_Master__c intmasIFT = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Payment IFT ',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CBSFundTransferService',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
         PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper requestWrapper = new PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper();
         requestWrapper.ReferenceNumber = 'SFDC80a1a1c7b220b61e65225ef762151722';
         Integration_Checklist__c  icChecklistIFT = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Loan_Application__c = loanAppl.Id,
            Request_Id__c='IC001001088',
            Integration_Master__c = intmasIFT.Id,
            Status__c='Completed',
             Request__c = JSON.serialize(requestWrapper),
            Response__c = '{"TransactionStatus": {"ResponseCode": "0","ResponseMessage": "Success"},"ErrorCode": "0","TransactionReferenceNo": "IFT722432123331236"}',
            Call_Type__c = GlobalConstants.PAYMENT_CALL_TYPE_CHEQUE
        ),true);
        
        Integration_Checklist__c  icChecklistIFT2 = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Loan_Application__c = loanAppl.Id,
            Request_Id__c='IC001001089',
            Integration_Master__c = intmasIFT.Id,
            Status__c='Completed',
             Request__c = JSON.serialize(requestWrapper),
            Response__c = '{"TransactionStatus": {"ResponseCode": "0","ResponseMessage": "Success"},"ErrorCode": "0","TransactionReferenceNo": "IFT722432123331236"}',
            Call_Type__c = GlobalConstants.PAYMENT_CALL_TYPE_NEFT
        ),true);
        
        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'Welcome Letter',
            Document_Name__c = 'Welcome Letter'
        ),true);
        
        Document_Master__c  docMaster2 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'Addendum Document',
            Document_Name__c = 'Addendum Document'
        ),true);
        
        
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Loan_Application__c = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Welcome Letter',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),true);
        
        Generic_Master__c genericRecord = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            Product__c = loanAppl.Product__c,
            Schedule_Code__c = loanAppl.Schedule_Code__c,
            RecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByDeveloperName().get('EMI_Schedule').getRecordTypeId()
        
        ),true);
    }
    
    testmethod static void getLoanDetails(){
        String loanId = [Select Id from Loan_Application__c].Id;
        LoanDisbursementOpsController.getLoanDetails(loanId);
    }
    testmethod static void getLoanDetailsMultiplePayments(){
        String loanId = [Select Id from Loan_Application__c].Id;
        Payment__c paymentRec = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Account_Number__c = '1312312312312',
            IFSC_Code__c = 'HDFC0004444',
            Loan_Application__c  = loanId
        ),true);
        LoanDisbursementOpsController.getLoanDetails(loanId);
    }
    testmethod static void getUserDetails(){
        LoanDisbursementOpsController.getUserDetails();
    }
    testmethod static void getRepaymentSchedule(){
        String loanId = [Select Id from Loan_Application__c].Id;
        String applicantId = [Select Id from Applicant__c].Id;
        LoanDisbursementOpsController.getRepaymentSchedule(loanId, 'Disbursement Schedule', 2000);
        LoanDisbursementOpsController.getRepaymentSchedule(loanId, 'EMI Schedule', 2000);
        LoanDisbursementOpsController.getRepaymentSchedule(applicantId, 'EMI Schedule', 2000);
    }
    /*
testmethod static void getICAPIRecord(){
String loanId = [Select Id from Loan_Application__c].Id;
LoanDisbursementOpsController.getICAPIRecord('IC001001002',loanId);
}
*/
    testmethod static void getTrancheDetails(){
        String loanId = [Select Id from Loan_Application__c].Id;
        LoanDisbursementOpsController.getTrancheDetails(loanId,1);
    }
    testmethod static void getAssignmentRecordDetailsTest(){
        String loanId = [Select Id from Loan_Application__c].Id;
        Assignment__c assignmentRecord = [Select Id, RecordTypeId from Assignment__c Where Loan_Application__c =: loanId];
        assignmentRecord.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByDeveloperName().get('Ops_Disbursement').getRecordTypeId();
        update assignmentRecord;
        LoanDisbursementOpsController.getAssignmentRecordDetails(assignmentRecord.Id);
        LoanDisbursementOpsController.getAssignmentRecordDetailsByLoan(loanId);
        LoanDisbursementOpsController.sendNotificationToRO(loanId);
    }
    testmethod static void getTrancheDetailsMultiplePayment(){
        String loanId = [Select Id from Loan_Application__c].Id;
        String tranchId = [Select Id from Payment__c Where RecordType.DeveloperName='Tranche' limit 1].Id;
        Payment__c paymentRec = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Account_Number__c = '1312312312312',
            IFSC_Code__c = 'HDFC0004444',
            Loan_Application__c  = loanId,
            Tranche__c = tranchId
        ),true);
        LoanDisbursementOpsController.getTrancheDetails(loanId,1);
    }
    testmethod static void getPaymentFavourings(){
        String loanId = [Select Id from Loan_Application__c].Id;
        String tranchId = [Select Id from Payment__c Where RecordType.DeveloperName!='Tranche' limit 1].Id;
        String applicantId = [Select Id from Applicant__c].Id;
        List<Payment__c> payments =LoanDisbursementOpsController.getPaymentFavourings(loanId);
        LoanDisbursementOpsController.getPaymentFavourings(tranchId);
        LoanDisbursementOpsController.getPaymentFavourings(applicantId);
    }
    
    testmethod static void updatePaymentParent(){
        String loanId = [Select Id from Loan_Application__c].Id;
        String tranchId = [Select Id from Payment__c Where RecordType.DeveloperName!='Tranche' limit 1].Id;
        Test.startTest();
        try{
            LoanDisbursementOpsController.updatePaymentParent(tranchId,loanId);
        }catch(Exception exp){}
        Test.stopTest();
    }
    testmethod static void updatePaymentParentLoan(){
        String loanId = [Select Id from Loan_Application__c].Id;
        String tranchId = [Select Id from Payment__c Where RecordType.DeveloperName!='Tranche' limit 1].Id;
        Test.startTest();
        try{
            LoanDisbursementOpsController.updatePaymentParent(loanId,loanId); 
        }catch(Exception exp){}
        Test.stopTest();
    }
    testmethod static void validatePaymentFavTest(){
        Test.startTest();
        Id payFavId = [Select Id from Payment__c Where RecordType.DeveloperName!='Tranche'][0].Id;
        LoanDisbursementOpsController.validatePaymentFavouring(payFavId); 
        Test.stopTest();
    }
    testmethod static void updatePayFavTest(){
        Test.startTest();
        Id payFavId = [Select Id from Payment__c Where RecordType.DeveloperName!='Tranche'][0].Id;
        LoanDisbursementOpsController.updatePaymentRecord(payFavId); 
        try{
             LoanDisbursementOpsController.updatePaymentRecord('test'); 
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    testmethod static void createAddendumtest(){
        Test.startTest();
        try{
            Id loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
            Id assignmentId = [SELECT Id FROM Assignment__c LIMIT 1].Id;
            LoanDisbursementOpsController.createAddendumDocument(loanId,JSON.serialize(Date.today()),assignmentId);
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    testmethod static void testIsBSRPSLComplete(){
        Test.startTest();
        try{
            Id loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
            LoanDisbursementOpsController.isBSRPSLComplete(loanId);
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    testmethod static void testCheckIfPaymentAlreadyDisbursed(){
        Test.startTest();
        try{
            Id paymentId = [SELECT Id FROM Payment__c WHERE RecordType.DeveloperName='Payment_Favouring' LIMIT 1].Id;
            LoanDisbursementOpsController.checkIfPaymentAlreadyDisbursed(paymentId);
            LoanDisbursementOpsController.checkIfPaymentAlreadyDisbursed('');
            LoanDisbursementOpsController.checkIfPaymentAlreadyDisbursed('test');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    testmethod static void testCheckIfDibursePaymentDone(){
        Test.startTest();
        try{
            Id loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
            LoanDisbursementOpsController.checkIfDibursePaymentDone(loanId,'disburseBtn');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    testmethod static void testCheckIfDibursePaymentDone2(){
        Test.startTest();
        try{
            Id loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
            LoanDisbursementOpsController.sendPaymentNotification(loanId);
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    testmethod static void testCheckIfDibursePaymentChequeDone(){
        Test.startTest();
        try{
            Id loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
            LoanDisbursementOpsController.checkIfDibursePaymentDone(loanId,'disbursePaymentCheque');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    testmethod static void testCheckIfDibursePaymentChequeDone2(){
        Test.startTest();
        try{
            Id loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
            List<Payment__c> payments = [SELECT Id from Payment__c WHERE  Loan_Application__c =:loanId AND Payment_Mode__c = 'NEFT'];
            payments[0].Is_Pool_Disbursement_Successful__c = true;
            update payments[0];
            LoanDisbursementOpsController.checkIfDibursePaymentDone(loanId,'disbursePaymentCheque');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    testmethod static void testUpdateMotorInsDevRecord(){
        Test.startTest();
        try{
            Id loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
            LoanDisbursementOpsController.updateMotorInsDevRecord(loanId,false);
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    testmethod static void testCheckMotorInsurance(){
        Test.startTest();
        try{
            Id loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
            LoanDisbursementOpsController.checkMotorInsurance(loanId);
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    testmethod static void updateDisbursementDateTimeTest(){
        Test.startTest();
        try{
            Id loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
            LoanDisbursementOpsController.updateDisbursementDateTime('Disbursement Details',loanId);
            LoanDisbursementOpsController.updateDisbursementDateTime('Do Disbursement',loanId);
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    testmethod static void updateLoanApplicationRecordTest(){
        Test.startTest();
        try{
            Loan_Application__c objLoan = [SELECT Id FROM Loan_Application__c LIMIT 1];
            LoanDisbursementOpsController.updateLoanApplicationRecord(JSON.serialize(objLoan));
            LoanDisbursementOpsController.updateLoanApplicationRecord('');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    testmethod static void updatePaymentTrancheRecordTest(){
        Test.startTest();
        try{
            Payment__c objPayment = [SELECT Id FROM Payment__c LIMIT 1];
            LoanDisbursementOpsController.updatePaymentTrancheRecord(JSON.serialize(objPayment));
            LoanDisbursementOpsController.updatePaymentTrancheRecord('');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
}