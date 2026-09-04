@isTest
public class CustomerRequestLetterDeferralCtrlTest {
    @testSetup static void makeData(){
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
        Name ='TestAccount',
        Account_Code__c='2103',
        Purchase_City__c='Jaipur'),true);
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Loan_Amount__c  = 12000,
            Product__c='10201',
            Tenure__c=12,
            EMI__c=100,
            ROI__c=0,
            Repayment_Bank_Name__c='HDFC',
            Dealer_Master__c = dealerMaster.Id
        ),true); 

        BSR_PSL_Details__c psl = (BSR_PSL_Details__c)TestFactory.createSObject(new BSR_PSL_Details__c(
            Loan_Application__c  = loanAppl.Id,
            RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByDeveloperName().get('PSL').getRecordTypeId()
        ),true); 
        
        Map<String,Object> callBackMap = new Map<String,Object>();
        callBackMap.put('MndtReqId','1234567');
        callBackMap.put('Accptd','1234567');
        callBackMap.put('AccptRefNo','1234567');
        callBackMap.put('MndtReqId','1234567');
        callBackMap.put('ReasonCode','1234567');
        callBackMap.put('ReasonDesc','1234567');
        callBackMap.put('RejectBy','1234567');
        Integration_Master__c icmaster = new Integration_Master__c();
        icmaster.Name = 'E-Mandate Registration';
        insert icmaster;
        Integration_Checklist__c ic = new Integration_Checklist__c();
        ic.Integration_Master__c = icmaster.Id;
        ic.Loan_Application__c = loanAppl.Id;
        ic.Callback_Request__c = JSON.serialize(callBackMap);
        insert ic;
        
        Id recId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId();
        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loanAppl.Id,
            First_Name__c   = 'Caroline',
            Last_Name__c  = 'Forbes',
            RecordTypeId = recId
        ),true);
        
         Payment__c paymentRecord = (Payment__c)TestFactory.createSObject(new Payment__c(
            //Payment_Recipient__c ='Customer',
            Loan_Application__c  = loanAppl.Id,
            Payment_Recipient__c='UCD',
            RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId()
        ),true);
        
        Payment__c paymentRecord1 = (Payment__c)TestFactory.createSObject(new Payment__c(
            //Payment_Recipient__c ='Customer',
            Loan_Application__c  = loanAppl.Id,
            Payment_Recipient__c='UCD',
            RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId()
        ),true);
        
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = UserInfo.getUserId(),
            Archived__c = false, Type__c ='Highest'
        ),true);
        Loan_Application_Approval__c loanAppApproval2 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Pricing' , Approver__c = UserInfo.getUserId(),
            Archived__c = false
        ),false);
        
        Document_Master__c master = new Document_Master__c(Document_Name__c  = 'Electricity Bill', Name='Electricity Bill');
        insert master;
        
        Document_Checklist__c doc = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Status__c  = 'Received',
            Amount__c   = 1000,
            Applicant__c  = applicant.Id,
            Document_Master__c = master.Id,
            Document_Verification_Status__c=GlobalConstants.VERIFIED
        ),true);
        Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=doc.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCV;
        Id devRecordTypeId = Schema.SObjectType.Generic_Master__c .getRecordTypeInfosByName().get('Restricted Domains').getRecordTypeId();
        Generic_Master__c    genMaster = (Generic_Master__c )TestFactory.createSObject(new Generic_Master__c (
           	Letter_Name__c = 'Customer Request Letter for Deferral Amount Lien Marking',
            Domain_Name__c  = 'zoemail.net',
            RecordtypeId = devRecordTypeId
        ),true);
        Generic_Master__c  bankMaster = (Generic_Master__c )TestFactory.createSObject(new Generic_Master__c (
            Bank_Name__c = 'HDFC BANK',
            Bank_Code__c  = '1099',
            RecordtypeId = Schema.SObjectType.Generic_Master__c .getRecordTypeInfosByName().get('Bank Master').getRecordTypeId()
     ),true);
    }
    testmethod static void main(){
       Loan_Application__c loan = [Select Id from Loan_Application__c limit 1];      
      //AccountNew is the Visualforce page created
       PageReference testPage = Page.LoanChargesDeductionLetterPDFPage; 
       Test.setCurrentPage(testPage);
       testPage.getParameters().put('applicationId', String.valueOf(loan.Id));
       CustomerRequestLetterDeferralController obj = new CustomerRequestLetterDeferralController();
    }
    testmethod static void testCustomerSearchRequestWrapper(){
        CustomerSearchRequestWrapper obj = new CustomerSearchRequestWrapper();
        obj.RequestId = '231231';
        obj.Channel ='OK';
        obj.PanNumber = '132321';
        obj.ReferenceNumber = '1312';
        obj.TransactionBranch = '2312';
        obj.CustomerId = '2312';
        obj.MobileNumber = '2312';
        obj.AadhaarNumber = '2312';
    }
    @isTest static void testPDCDetails(){
        /*
        CustomerRequestLetterDeferralController.PDCDetails pdcDetails = new CustomerRequestLetterDeferralController.PDCDetails();
        pdcDetails.spdcChequeNumberFrom='';
        pdcDetails.spdcChequeNumberTo='';
        pdcDetails.pdcChequeNumberFrom='';
        pdcDetails.pdcChequeNumberTo='';
        */
        
        CustomerRequestLetterDeferralController.objGenericMaster=null;
        CustomerRequestLetterDeferralController.sourcingChannel=null;
        //CustomerRequestLetterDeferralController.chequeNumbersSPDC=null;
        
    }
}