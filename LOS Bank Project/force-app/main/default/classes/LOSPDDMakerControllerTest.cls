/*****
 * Class Name: LOSPDDMakerControllerTest
 * Description: Test Class for LOSPDDMakerController
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-12-2023          -   Mohit M.            -   SFAU-5711 - Deffral Issue
 */
@IsTest
private class LOSPDDMakerControllerTest {
    @testSetup
    static void testDataSetup(){
        Location_Master__c locMaster = new Location_Master__c(Name = '441601', State__c = 'MAHARASHTRA');
        insert locMaster;
        
         Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
     Id AccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account account = new Account (RecordTypeId = AccRecordTypeId, Account_Name__c = 'Account Test', 
                                Name = 'Account Test', Bank_Name__c = 'Test Bank LoanApp Acc', Dealer_Class__c ='Commercial Associate With Rc Limit',
                                IFSC_Code__c = 'TEST01234', Pincode__c = locMaster.Id,Branch_Queue__c = grp.Id);
        insert account;
        
        AccountTeamMember accTeamMember = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Credit Manager', accountId = account.id, Active__c = true, UserId =UserInfo.getUserId()
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10202',
            Stage__c = 'QDE', Dealer_Master__c = account.Id, Branch_Master__c = account.Id
            
        ),true);
        Document_Master__c docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
                Name = 'str', Document_Name__c = 'Test Doc 1', Consider_for_E_Sign__c = true),true);
       
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            Customer_Type__c = 'Non Individual',
            Constitution_Type__c = 'Sole Proprietary'
            
        ),true);
        
        Collateral__c coll = (Collateral__c)TestFactory.createSObject(new Collateral__c(
           Loan__c = loanAppl.id
            ),true);
        
         Document_Checklist__c docChecklist = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Loan_Application__c = loanAppl.Id, Document_Master__c = docMaster.Id, Collateral__c = coll.Id),true);
        
        insert new Deferral_Register__c(Collateral__c = coll.Id);

           Id ASSIGNMENT_RECORD_TYPE_ID = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - Disbursement').getRecordTypeId();
        Assignment__c assgnmnt = (Assignment__c)TestFactory.createSObject(new Assignment__c(
            Loan_Application__c = loanAppl.id ,RecordTypeId = ASSIGNMENT_RECORD_TYPE_ID,Status__c = 'Pending'
            ),true);
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name ='SMS Notification',
            End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/SFDCCcommunication/SendSMS',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
    }
     @IsTest
    static void testMainMethod() {
        Loan_Application__c loanAppl = [Select Id, Product__c, Dealer_Master__c, Sourcing_channel__c, Sourcing_Channel_Name__c, Mobile__c, Customer_Type__c from Loan_Application__c limit 1];
        Assignment__c assgnmnt = [Select Id from Assignment__c Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        LOSPDDMakerController.fetchPicklistValues();
        LOSPDDMakerController.fetchPicklist('Loan_Application__c', 'Name');
        Map<String,object> response = LOSPDDMakerController.getData(loanAppl.Id);
        LOSPDDMakerController.getDealerRCDetails(loanAppl.Id);
        try {
            LOSPDDMakerController.saveData(setSaveDataWrapper(loanAppl), 'Loan_Application__c');
        } catch (Exception ex) {
            // this will return an approver not found error
        }
        LOSPDDMakerController.saveOpsDetailsOnLoan(loanAppl.Id, 'Rework', 'opsRemark', assgnmnt.Id);
        LOSPDDMakerController.reSubmitRecord(loanAppl.Id,assgnmnt.Id);
        LOSPDDMakerController.getRecordInfo(assgnmnt.Id);
        LOSPDDMakerController.sendNotification(loanAppl.Id,'9899112233');
        LOSPDDMakerController.getAgentInfobyId(loanAppl.Id,'12121212');
        LOSPDDMakerController.ResponseListWrapper testWrapper = new LOSPDDMakerController.ResponseListWrapper();
        Test.stopTest();
    }
    
    private static String setSaveDataWrapper(Loan_Application__c loanRecord){
        LOSPDDMakerController.VahaanWrapper vahanWrapper = new LOSPDDMakerController.VahaanWrapper();
        vahanWrapper.hpnFinancer = 'testFinacer';
        vahanWrapper.currentOwnerName = 'testowner';
        vahanWrapper.ownerSerialNumber = '123456';
        vahanWrapper.registrationCity = 'Delhi';
        LOSDocumentManagerController.DocumentCheckListRecord wrapp = New LOSDocumentManagerController.DocumentCheckListRecord();
        Document_Checklist__c doc = [Select id from Document_Checklist__c];
        wrapp.docName = doc;
 
        LOSPDDMakerController.PDDMakerWrapper pddSaveWrapper = new LOSPDDMakerController.PDDMakerWrapper();
        pddSaveWrapper.loanAppId = loanRecord.Id;
        pddSaveWrapper.isUsedOrCOW = true;
        pddSaveWrapper.vehicleDelivery = 'Yes';
        pddSaveWrapper.invoiceStatus = 'Pending';
        pddSaveWrapper.taxReceiptStatus = 'Pending';
        pddSaveWrapper.assignmentCase = 'Yes';
        pddSaveWrapper.deferralCategory = 'RC Limit Deferral';
        pddSaveWrapper.invoiceNumber = 'TestInvoice';
        pddSaveWrapper.invoiceDate = System.today();
        pddSaveWrapper.invoiceAmount = 100.00;
        pddSaveWrapper.hpnInvoice = 'Yes';
        pddSaveWrapper.vahanData = vahanWrapper;
        pddSaveWrapper.deviationNeeded = true;
        pddSaveWrapper.docChkRecords = new List<LOSDocumentManagerController.DocumentCheckListRecord>();
    pddSaveWrapper.deviationNeeded = true;
        LOSPDDMakerController.DeferralRegisterWrapper defWrapper = new LOSPDDMakerController.DeferralRegisterWrapper();
        pddSaveWrapper.deferralRegister = defWrapper;
        return JSON.serializePretty(pddSaveWrapper);
    }
    
    @isTest
    public static void testcoverage(){
        LOSPDDMakerController.ResponseListWrapper wrap = new LOSPDDMakerController.ResponseListWrapper();
        wrap.fileName = '';
        wrap.docName = '';
        wrap.url = '';
        wrap.contentDocId='';
        wrap.contentVerId='';
        wrap.downloadurl='';
        wrap.fileName='';
        wrap.fileType='';
        wrap.recordId='';
        LOSPDDMakerController.SelectOptionWrapper wrp= new LOSPDDMakerController.SelectOptionWrapper('test','test');
    }
}