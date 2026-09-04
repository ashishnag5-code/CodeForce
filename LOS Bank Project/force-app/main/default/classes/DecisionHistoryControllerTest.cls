@isTest
public class DecisionHistoryControllerTest {
    
    @testSetup static void setup() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name Like '%Admin%' LIMIT 1];
        
        User user = new User(
            LastName = 'Test Code',
            Email = 'test@test.com',
            Alias = 'Tcode',
            Username = 'test1234444@testzsdfsdtfsdf.com',
            CommunityNickname = 'test12',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileID = profileId.Id,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            Employee_Id__c='E0123456'
        );
        insert user;
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true
            
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321',
            Loan__c =loanAppl.Id,
            AML_Verification_Start_Date__c=DateTime.newInstance(1996, 08, 04),
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Loan_TAT__c loanTat= new Loan_TAT__c( 
            Start_Date_Time__c=Datetime.now(),
            End_Date_Time__c=DateTime.newInstance(1996, 08, 04),
            Assigned_To__c='Queue',
            Loan_Application__c=loanAppl.Id,
            Action_Type__c='Loan Submitted',
            Actor__c=user.Id,
            Owner__c = user.Id
        ); 
        insert loanTat;
    }   
    @isTest
    public static void fetchHistoryTest(){
        Loan_TAT__c loanTat=[Select Id,Action_Type__c from Loan_TAT__c LIMIT 1];
        User u=[Select Id,Name from User Where LastName='Test Code' LIMIT 1];
        Loan_Application__c loanAppl=[Select Id from Loan_Application__c LIMIT 1];
        Collateral__c coll = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', Loan__c = loanAppl.id
        ),true);
        Valuation__c valuation = (Valuation__c) TestFactory.createSObject(new Valuation__c (
            Reference_ID__c='ValTest',
            Action__c='Trigger',
            Collateral__c= coll.Id,
            Valuation_Amount__c=1000,
            isLatest__c = true,
            Response_Received__c ='Yes',
            Cando_Request_Id__c='Req1'
        ),true);
        Test.startTest();
        DecisionHistoryController.fetchHistory(loanAppl.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testDecisionHistoryWrapper(){
        Test.startTest();
        Loan_TAT__c tatRecord = [SELECT Id, Owner__c, Owner__r.Name, Owner__r.Employee_Id__c, Action_Type__c, Actor__c, Actor__r.name, 
                                 Actor__r.Employee_Id__c, Loan_Application__c, Loan_Application__r.isAutoRejected__c, Stage_Activity__c 
                                 FROM Loan_TAT__c 
                                 limit 1];
        DecisionHistoryController.DecisionHistoryWrapper testWrapper = new DecisionHistoryController.DecisionHistoryWrapper(tatRecord);
        tatRecord.Owner__c = null;
        update tatRecord;
        DecisionHistoryController.DecisionHistoryWrapper testWrapper1 = new DecisionHistoryController.DecisionHistoryWrapper(tatRecord);
        tatRecord.Action_Type__c = '';
        update tatRecord;
        DecisionHistoryController.DecisionHistoryWrapper testWrapper3 = new DecisionHistoryController.DecisionHistoryWrapper(tatRecord);


        Test.stopTest();
        
    }
    
}