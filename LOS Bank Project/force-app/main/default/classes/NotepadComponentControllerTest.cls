@isTest
public class NotepadComponentControllerTest {
    @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE'
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321',
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Integration_Master__c  intMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='https://service.aubank.in/CBSMemoMntService/CustomerMemo',
            HTTP_Method__c ='POST',
            API_Key__c ='SFDC',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Name = 'CBS Customer Memo Service'),true);
        
        Integration_Master__c  intMaster2 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='https://service.aubank.in/CBSMemoMntService/AccountMemo',
            HTTP_Method__c ='POST',
            API_Key__c ='SFDC',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Name = 'CBS Account Memo Service'),true);
    }
    
    @isTest
    public static void getApplicantDataTest(){
        Applicant__c app = [SELECT Id FROM Applicant__c LIMIT 1];
        List<Applicant__c> appList = NotepadComponentController.getApplicantData(app.id);
        System.assertEquals('576321', appList[0].CIF_No__c,'test');
    }
    
    @isTest
    public static void getRelatedApplicantsTest(){
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Applicant__c> appList = NotepadComponentController.getRelatedApplicants(loan.id);
        //System.assertEquals('Vikash', appList[0].First_Name__c,'test');
    }
    
    @isTest
    public static void saveDeleteRecordTest(){
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Map<String,String> noteMap = new Map<String,String>();
        noteMap.put('Loan_Application__c',loan.Id);
        noteMap.put('Notes__c','Test');
        String result = NotepadComponentController.saveRecord(noteMap);
        System.assertNotEquals(null,result);
        
        String result2 = NotepadComponentController.deleteRecord(result);
        System.assertEquals('',result2);
    }
    
    @isTest
    public static void getNotesTest(){
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Notepad__c> noteList = NotepadComponentController.getNotes(loan.Id);
        System.assertEquals(0,noteList.size());
    }
    
    @isTest
    public static void sendNotepadDetailsTest(){
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c app = [SELECT Id FROM Applicant__c LIMIT 1];
        Map<String,String> noteMap = new Map<String,String>();
        noteMap.put('Loan_Application__c',loan.Id);
        noteMap.put('Customer_ID__c','23310962');
        noteMap.put('Notes__c','Test');
        List<Object> objList = new List<Object>();
        objList.add(loan);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FetchNotepadCalloutMock());
        NotepadComponentController.generateRequest(objList);
        NotepadComponentController.generateJSONResponse(objList);
        NotepadResponseWrapper wrap = NotepadComponentController.sendNotepadDetails(noteMap,'i',loan.Id,app.Id);
        Test.stopTest();
        System.assertNotEquals(null,wrap);
    }
    
    @isTest
    public static void sendNotepadDetailsOfLoanTest(){
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c app = [SELECT Id FROM Applicant__c LIMIT 1];
        Map<String,String> noteMap = new Map<String,String>();
        noteMap.put('Loan_Application__c',loan.Id);
        noteMap.put('Customer_ID__c','23310962');
        noteMap.put('Notes__c','Test');
        List<Object> objList = new List<Object>();
        objList.add(loan);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FetchNotepadCalloutForAccountMock());
        NotepadResponseWrapper wrap2 = NotepadComponentController.sendNotepadDetails(noteMap,'i',loan.Id,null);
        Test.stopTest();
        System.assertNotEquals(null,wrap2);
    }
    @isTest
    public static void getLatestNoteTest(){
    Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
     Notepad__c note = new Notepad__c();
                note.Notes_Start_Date__c = Date.today();
                note.Notes_End_Date__c = Date.today()+2;
                note.Memo_Number__c = '1234';
                note.Notes__c = 'notes Test';
                note.Severity__c = 'L';
                note.Source__c = 'CBS';
                note.Reason_for_Notes__c = 'reason for memo';
                note.Loan_Application__c = loan.Id;
                note.Note_Type__c = 'Loan ID';
                insert note;
    NotepadComponentController.getLatestNote(loan.Id);
    }
}