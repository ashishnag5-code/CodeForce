@isTest
public class IntegrationUtilityTest {
    @testSetup 
    static void setup() {
        
        Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c = 'AP-12345',Adhar_Card__c = 123456,
            Loan_Amount__c = 1000,Product__c='10201'),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',Middle_Name__c = 'Kumar',Last_Name__c = 'Mandal',Loan__c =loanApp.Id,
            Customer_Name__c='Vikas',Customer_Type__c='Individual'),true);
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        Opportunity opp = new Opportunity(Name='Opp',CloseDate=System.today().addDays(30),AccountId=branchMaster.Id,StageName='New');
        insert opp;
        Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Loan__c = loanApp.Id,Vehicle_Usage__c='Personal'),true);
        Document_Master__c docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name = 'Test Document', Document_Category__c = 'Vehicle Document', 
            Document_Sub_Category__c = 'Vehicle Document', Document_ID__c = 'AUWheels0008'),true);
        Document_Checklist__c docChecklist = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c = appl.Id, Collateral__c = collat.Id, Document_Master__c = docMaster.Id, 
            Loan_Application__c =loanApp.Id),true);
        
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
        
        Integration_Master__c imocr = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Cheque OCR',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/ChequeOCR/Cheque',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC',
            Static_Response__c = 'MyResource'
        ),true);
        
        Integration_Checklist__c intChild = new Integration_Checklist__c();
        intChild.Response__c  = '{ "TransactionStatus" : {"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {},    "ValidationErrors" : [ null ]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChild.Loan_Application__c  = loanApp.Id; 
        intChild.Integration_Master__c  = integrationMast.Id; 
        intChild.Request_Id__c = '644a0f30c76c5a00e823e11e';
        insert intChild;
        
        Integration_Checklist__c intChild2 = new Integration_Checklist__c();
        intChild.Response__c  = '{ "TransactionStatus" : {"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {},    "ValidationErrors" : [ null ]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChild.Loan_Application__c  = loanApp.Id; 
        intChild.Integration_Master__c  = intmassearch2.Id; 
        intChild.Request_Id__c = '644a0f30c76c5a00e823e11e';
        insert intChild2;
    }
    
    /*@isTest
static void testDecryptData() {
Test.startTest();
IntegrationUtility.decryptData('AES256','key','iv','cleartext');
Test.stopTest();
}*/
    
    @isTest
    static void testGetApplicationRelatedReferenceId() {
        Applicant__c appList = [SELECT Id From Applicant__c WHERE First_Name__c = 'Vikash' LIMIT 1]; 
        Test.startTest();
        IntegrationUtility.getApplicationRelatedReferenceId(appList.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetDocumentMasterRecord() {
        Document_Master__c docList = [SELECT Id, Name From Document_Master__c WHERE Name = 'Test Document' LIMIT 1]; 
        Test.startTest();
        IntegrationUtility.getDocumentMasterRecord(docList.Name);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateIntegrationChecklist1() {
        Integration_Checklist__c intList = [SELECT Id, Response__c, Integration_Master__c From Integration_Checklist__c LIMIT 1]; 
        Test.startTest();
        IntegrationUtility.updateIntegrationChecklist(intList.Id, intList.Response__c, 200, intList.Integration_Master__c, '');
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateIntegrationChecklist2() {
        Integration_Checklist__c intList = [SELECT Id, Response__c, Integration_Master__c From Integration_Checklist__c LIMIT 1]; 
        Test.startTest();
        IntegrationUtility.updateIntegrationChecklist(intList.Id, intList.Response__c, 201, intList.Integration_Master__c, '');
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateIntegrationChecklistException() {
        Integration_Checklist__c intList = [SELECT Id, Response__c, Integration_Master__c From Integration_Checklist__c LIMIT 1]; 
        Test.startTest();
        try{
            IntegrationUtility.updateIntegrationChecklist('****', intList.Response__c, 201, '****', '');
        } catch(Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDoRestCallout() {
        Test.startTest();
        try{
            IntegrationUtility.doRestCallout(null);
        }
        catch(Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDoRestCallout2() {
        Test.startTest();
        try{
            IntegrationUtility.RequestWrapper wrapper = new IntegrationUtility.RequestWrapper();
            Map<String,String> headersMap = new Map<String,String>();
            headersMap.put('test','test');
            wrapper.headersMap = headersMap;
            IntegrationUtility.doRestCallout(wrapper);
        }
        catch(Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getLADetailsTest(){ 
        Loan_Application__c loanAppl = [SELECT ID,BRE_Status__c FROM Loan_Application__c LIMIT 1];
        ChecqueOCRController obj = new ChecqueOCRController();
        test.setMock(HttpCalloutMock.class, new ChequeOCRMock());
        Test.startTest();
        String str = ChecqueOCRController.chequeOcrCallOut(loanAppl.Id, 'Test String');
        Map<String, String> mapTem = new map<String, String>{
            'requestId' => 'abc'
                };
                    IntegrationUtility.mogrifyJSON (str,mapTem);
        IntegrationUtility.getApplicationRelatedReferenceId (loanAppl.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getLADetailsDisableTest(){ 
        Loan_Application__c loanAppl = [SELECT ID,BRE_Status__c FROM Loan_Application__c LIMIT 1];
        Integration_Master__c objIM = [Select Id, Disable_Api__c, End_Point_URL__c from Integration_Master__c where Name = 'Cheque OCR'];
        objIM.Disable_Api__c = true;
        update objIM;
        ChecqueOCRController obj = new ChecqueOCRController();
        test.setMock(HttpCalloutMock.class, new ChequeOCRMock());
        Test.startTest();
        try{
            ChecqueOCRController.chequeOcrCallOut(loanAppl.Id, 'Test String');
        }
        catch(Exception ex) {}
        Test.stopTest();
    }
    @isTest
    public static void getLADetailsDisableTestNegetive(){ 
        Loan_Application__c loanAppl = [SELECT ID,BRE_Status__c FROM Loan_Application__c LIMIT 1];
        
        ChecqueOCRController obj = new ChecqueOCRController();
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());
        Test.startTest();
        try{
            ChecqueOCRController.chequeOcrCallOut(loanAppl.Id, 'Test String');
        }
        catch(Exception ex) {}
        Test.stopTest();
    }
    
    @isTest
    public static void getLADetailsExceptionTest(){ 
        Loan_Application__c loanAppl = [SELECT ID,BRE_Status__c FROM Loan_Application__c LIMIT 1];
        Integration_Master__c objIM = [Select Id, Disable_Api__c, End_Point_URL__c, HTTP_Method__c from Integration_Master__c where Name = 'Cheque OCR'];
        objIM.HTTP_Method__c = '';
        update objIM;
        ChecqueOCRController obj = new ChecqueOCRController();
        test.setMock(HttpCalloutMock.class, new ChequeOCRMock());
        Test.startTest();
        try{
            ChecqueOCRController.chequeOcrCallOut(loanAppl.Id, 'Test String');
        }
        catch(Exception ex) {}
        Test.stopTest();
    }
    
    @isTest
    public static void encryptDataTest(){ 
        try{
            IntegrationUtility.encryptData('',Blob.valueOf(''),Blob.valueOf(''),Blob.valueOf(''));
        }Catch(Exception e){
            
        }
    }
    @isTest
    public static void encryptDataTest2(){ 
        try{
            IntegrationUtility.decryptData('',Blob.valueOf(''),Blob.valueOf(''),Blob.valueOf(''));
        }Catch(Exception e){
            
        }
    }
    
    @isTest
    public static void generateURLQueryParamsTest(){ 
        Test.startTest();
        try{
            Map<String, String> mapTem = new map<String, String>{
                'requestId' => IntegrationUtility.getReferenceId(),
                    'channel' => 'temp',
                    'regNo' => 'temp',
                    'consent' => 'Y',
                    'blackListInfo' => 'true',
                    'challanDetails' => 'true',
                    'filename' => '',
                    'vahanUsername' => '',
                    'vahanPassword' => ''
                    };
                        IntegrationUtility.generateURLQueryParams (mapTem);
        }
        catch(Exception ex) {}
        Test.stopTest();
    }
}