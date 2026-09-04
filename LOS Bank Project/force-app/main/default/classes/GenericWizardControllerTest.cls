@isTest
public class GenericWizardControllerTest {
    @testSetup static void setup() {
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
            Name ='TestAccount',
            Account_Code__c='2103',
            RC_Limit_Increased__c=true,
            RC_Limit_Amount__c = 10000,
            RC_Limit_Used_Amount__c=1000,
            Ad_Hoc_Limit_Amount__c = 9000,
            Ad_Hoc_Limit_Used_Amount__c = 10,
            RC_Limit_Used_Count__c=1,
            Ad_Hoc_Limit_Count__c=10,
            Ad_Hoc_Limit_Used_Count__c=1,
            Ad_Hoc_Date__c = System.today()+30,
            Purchase_City__c='Jaipur'),true);
        
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='PSD',
            Draft_Stage__c = 'QuickLoan',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            RC_Limit_On_Hold__c= true,
            Total_Loan_Amount__c=10,
            Dealer_Master__c = dealerMaster.Id

        ),true);
                //Applicant Insertion
        /*Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321',
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);*/
                //Loan Application Insertion
        Loan_Application__c loanAppl2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12346',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            RC_Limit_On_Hold__c= true,
            Total_Loan_Amount__c=10,
            Dealer_Master__c = dealerMaster.Id
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl3 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12347',
            Adhar_Card__c   = 123457,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='DDE',
            Draft_Stage__c = 'Repayment',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            RC_Limit_On_Hold__c= true,
            Total_Loan_Amount__c=10,
            Dealer_Master__c = dealerMaster.Id
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl4 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12348',
            Adhar_Card__c   = 123458,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='Lead',
            Draft_Stage__c = '',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            RC_Limit_On_Hold__c= true,
            Total_Loan_Amount__c=10,
            Dealer_Master__c = dealerMaster.Id
        ),false);
        Id RecordTypeIdContact = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        loanAppl4.RecordTypeId = RecordTypeIdContact;
        insert loanAppl4;
        //Loan Application Insertion
        Loan_Application__c loanAppl5 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12349',
            Adhar_Card__c   = 123459,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='PSD',
            Draft_Stage__c = 'Repayment',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            RC_Limit_On_Hold__c= true,
            Total_Loan_Amount__c=10,
            Dealer_Master__c = dealerMaster.Id
        ),true);
    }
    testmethod static void getRecordtypeName(){
        String loanId = [Select Id from Loan_Application__c Order by Createddate limit 1].Id;
        GenericWizardController.getRecordtypeName(loanId);
    }
    testmethod static void getRecordtypeNameException(){
        String loanId = [Select Id from Account limit 1].Id;
        GenericWizardController.getRecordtypeName(loanId);
    }
    testmethod static void getWizardSettings(){
        GenericWizardController.getWizardSettings('Parent_Flow','DDE','Auto Loan');
        GenericWizardController.getWizardSettingsWire('Parent_Flow','DDE');
    }
    testmethod static void fetchWizardState1(){
        String loanId = [Select Id from Loan_Application__c Order by Createddate limit 1].Id;
        GenericWizardController.fetchWizardState(loanId);
    }
    /*testmethod static void fetchWizardState(){
        String loanId1 = [Select Id from Applicant__c Order by Createddate limit 1].Id;
        GenericWizardController.fetchWizardState(loanId1);
    }*/
    testmethod static void testGenericWizardCurrentConfigList(){
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        GenericWizardCurrentConfigList obj = new GenericWizardCurrentConfigList(context);
        obj.getDefaultValue();
        obj.getValues();
    }
    testmethod static void testGenericWizardScreenConfigList(){
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        GenericWizardScreenConfigList obj = new GenericWizardScreenConfigList(context);
        obj.getDefaultValue();
        obj.getValues();
    }
    testmethod static void testFetchDraftStage(){
        Loan_Application__c loanId = [Select Id,Stage__c from Loan_Application__c Order by Createddate limit 1];
        try{
            GenericWizardController.FetchDraftStage(loanId.id);
            loanid.Stage__c ='QDE';
            loanid.Draft_Stage__c = 'Repayment';
            //loanid.recordtypeid = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Lead').getRecordTypeId();
            update loanid;
            GenericWizardController.FetchDraftStage(loanId.id);
            test.starttest();
            loanid.Stage__c ='Lead';
            loanid.Draft_Stage__c = 'QuickLoan';
            loanid.recordtypeid = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Lead').getRecordTypeId();
            update loanid;
            GenericWizardController.FetchDraftStage(loanId.id);
            test.stoptest();
        }
        catch(exception ex){
            
        }
    }
    testmethod static void testFetchDraftStage2(){
        String loanId = [Select Id from Loan_Application__c Where Draft_Stage__c = null Order by Createddate limit 1].Id;
        try{
            GenericWizardController.FetchDraftStage(loanId);
        }
        catch(exception ex){
            
        }
    }
    testmethod static void testFetchDraftStage3(){
        String loanId = [Select Id,Stage__c,Draft_Stage__c from Loan_Application__c Where Draft_Stage__c = 'Repayment' and Stage__c='DDE' Order by Createddate limit 1].Id;
        try{
            GenericWizardController.FetchDraftStage(loanId);
        }
        catch(exception ex){
            
        }
    }
    testmethod static void testFetchDraftStage4(){
        String loanId = [Select Id,Stage__c,Draft_Stage__c from Loan_Application__c Where Stage__c='PSD' Order by Createddate limit 1].Id;
        try{
            GenericWizardController.FetchDraftStage(loanId);
        }
        catch(exception ex){
            
        }
    }
    
    testmethod static void testFetchDraftStage5(){
        String loanId = [Select Id,Stage__c,Draft_Stage__c from Loan_Application__c Where Stage__c='Lead' Order by Createddate limit 1].Id;
        try{
            GenericWizardController.FetchDraftStage(loanId);
        }
        catch(exception ex){
            
        }
    }
    
    testmethod static void testSaveDraftStage(){
        String loanId = [Select Id from Loan_Application__c Order by Createddate limit 1].Id;
        try{
            GenericWizardController.saveDraftStage(loanId,'QuickLoan');
            GenericWizardController.getWizardSettingsWire('test','test');
        }
        catch(exception ex){
            
        }
    }
    
}