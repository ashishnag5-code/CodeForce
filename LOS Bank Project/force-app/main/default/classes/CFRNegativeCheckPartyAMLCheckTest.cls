@isTest
public class CFRNegativeCheckPartyAMLCheckTest {
    @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            RC_Limit_Amount__c = 1000,
            RC_Limit_Used_Amount__c = 100,
            Ad_Hoc_Date__c = System.today().addDays(1),
            RC_Limit_Used_Count__c = 0,
            Branch_Queue__c=grp.Id
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10202',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Sourcing_Channel_Name__c = accInstance.Id,
            Total_Loan_Amount__c = 100,
            Branch_Master__c =accInstance.Id
        ),true);
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103'
                                                           ),true);
        list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id 
        ),false);
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id 
        ),false);
        lstLoanAppApproval.add(loanAppApproval);
        insert lstLoanAppApproval;
        
        //List<Applicant__c> lstApp = new List<Applicant__c>();
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            IsInactive__c = false,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name ='Test',
            Document_Name__c  ='Customers Signature'
        ),false);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            //Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Customers Signature'
        ),false);
        
        List<Applicant__c> lstApplicant = new List<Applicant__c>();
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash1',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Existing_Customer__c = 'Yes',
            PAN__c = 'AAACB5343E',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),false);
        lstApplicant.add(appl1);
        
        Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vik',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Existing_Customer__c = 'Yes',
            PAN__c = 'AFQPA8916A',
            Aadhaar_Number__c = 'AFQPA8916A',
            Passport_Number__c = 'AFQPA8916',
            Voter_Id__c = 'AFQPA8916A',
            Customer_Type__c = 'Individual',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),false);
        lstApplicant.add(appl2);
        
        Applicant__c appl3 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vik',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Existing_Customer__c = 'Yes',
            PAN__c = 'AFQPA8939A',
            Customer_Type__c = 'Individual',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),false);
        lstApplicant.add(appl3);
        
        Applicant__c appl4 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vik',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIN__c = '576321', 
            Loan__c =loanAppl.Id,
            Existing_Customer__c = 'Yes',
            PAN__c = 'AFQPA8939P',
            Customer_Type__c = 'Non Individual',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),false);
        lstApplicant.add(appl4);
        
        Applicant__c appl5 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vik',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CFR_Status__c = 'No match', 
            Negative_Check_Status__c = 'No match', 
            Related_Party_Status__c = 'No match', 
            Loan__c =loanAppl.Id,
            Existing_Customer__c = 'Yes',
            PAN__c = 'AFQPA9939P',
            Customer_Type__c = 'Individual',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
        ),false);
        lstApplicant.add(appl5);
       
        insert lstApplicant;
        
        Document_Checklist__c docChkRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c    = appl.Id
        ),true);
        
        Payment__c paymentRecord = (Payment__c)TestFactory.createSObject(new Payment__c(
            Payment_Recipient__c ='Customer',
            Loan_Application__c  = loanAppl.Id,
            Inactive__c = false,
            isVerified__c = true
        ),true);
        
        Sanction_Condition__c sanctionRecord = (Sanction_Condition__c)TestFactory.createSObject(new Sanction_Condition__c(
            Loan_Application__c  = loanAppl.Id,
            Status__c = 'Compliant'
        ),true);
        //MMV Insertion
        MMV_Master__c mmvMaster = (MMV_Master__c )TestFactory.createSObject(new MMV_Master__c (
            Name ='Test',
            //            Collateral_Name__c ='Car',
            Collateral_Type__c ='Automobile'
        ),true);
        
        //Negative Check Insertion
        Negative_Check_Master__c negativeCheckMaster = (Negative_Check_Master__c )TestFactory.createSObject(new Negative_Check_Master__c (
            PAN__c = 'AFQPA8916A',
            Aadhaar_Number__c = '544746955509',
            PASSPORT_NUMBER__c = 'NLN0198291',
            VOTER_ID__c = '1234'
        ),true);
        
        //Releted Party Insertion
        Related_Party_Master__C relatedCheckMaster = (Related_Party_Master__C )TestFactory.createSObject(new Related_Party_Master__C (
            PAN__c = 'AFQPA8939A',
            Aadhaar_Number__c = '544746955510'
        ),true);
        
        // Collateral Insertion
        Collateral__c  collateral = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppl.Id,
            // Name ='CollateralTest',
            
            MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10108',
            Deferral_Category__c = 'RC Limit Deferral'
        ),true);
        
        //SMS Integration Master
            Integration_Master__c inMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
                Name ='SMS Notification',
                End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/SFDCCcommunication/SendSMS',
                Apiuser__c ='SFDC',
                API_Key__c ='epikey',
                HTTP_Method__c='POST',
                Timeout__c='120000',
                Active__c = true
            ),true);
            
            //EMAIL Integration Master
            Integration_Master__c emailMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
                Name ='Email Notification',
                End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/SFDCCommunication/Email',
                Apiuser__c ='SFDC',
                API_Key__c ='epikey',
                HTTP_Method__c='POST',
                Timeout__c='120000',
                Active__c = true
            ),true);
            
            //Whatsapp Integration Master
            Integration_Master__c whatsappMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
                Name ='Whatsapp Notification',
                End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/WhatsappCongoService/SingleEvent',
                Apiuser__c ='SFDC',
                API_Key__c ='epikey',
                HTTP_Method__c='POST',
                Timeout__c='120000',
                Active__c = true
            ),true);
        
         CFR_Master__c cfrMaster = (CFR_Master__c )TestFactory.createSObject(new CFR_Master__c (
            Name_of_Perpetrator__c ='Vikash Kumar Mandal',
            PAN__c = 'AMETG7643T'
        ),true);
    } 
    
    @isTest
    public static void checkCFRTEst(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c 
                              where CIF_No__c = '576321' LIMIT 1];
        
        test.StartTest();
        CFRNegativeCheckRelatedPartyAMLCheck.pan = 'AMETG7643T';
        CFRNegativeCheckRelatedPartyAMLCheck.customerType ='Individual';
        CFRNegativeCheckRelatedPartyAMLCheck.aadharNumber ='123412341234';
        CFRNegativeCheckRelatedPartyAMLCheck.passportNumber ='J6756325';
        CFRNegativeCheckRelatedPartyAMLCheck.voterId ='123456789';
        CFRNegativeCheckRelatedPartyAMLCheck.cinNo = '13434';
        CFRNegativeCheckRelatedPartyAMLCheck.applcntRecordTypeName = 'Applicant';
        CFRNegativeCheckRelatedPartyAMLCheck.completeName = 'Vikash Kumar Mandal';
        CFRNegativeCheckRelatedPartyAMLCheck.checkNegativeCheck();
        CFRNegativeCheckRelatedPartyAMLCheck.checkRelatedParty();
        CFRNegativeCheckRelatedPartyAMLCheck.checkCFR();
        CFRNegativeCheckRelatedPartyAMLCheck.genericDynamicSoql('Name' , 'Account' , '');
        CFRNegativeCheckRelatedPartyAMLCheck.checkCFRByName();
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl1.Id);
        CFRNegativeCheckRelatedPartyAMLCheck.updateHandler(new List<Applicant__c> {appl1} );
        CFRNegativeCheckRelatedPartyAMLCheck.updateApplcnt(new List<Applicant__c> {appl1} );
        CFRNegativeCheckRelatedPartyAMLCheck.updateLoanApplction( loanObj.Id);
        Applicant__c appl4 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c 
                              where CIF_No__c = '576321' LIMIT 1];
        
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl4.Id);
        appl4.CFR_Status__c = 'Match';
        update appl4;
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl4.Id);
        appl4.CFR_Status__c = 'No match';
        appl4.Negative_Check_Status__c = 'Match';
        update appl4;
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl4.Id);
        appl4.CFR_Status__c = 'No match';
        appl4.Negative_Check_Status__c = 'No match';
        appl4.Related_Party_Status__c = 'Match';
        update appl4;
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl4.Id);
        CFRNegativeCheckRelatedPartyAMLCheck.updateHandler(new List<Applicant__c> {appl4} );
        test.StopTest();
    }
    
   @isTest
    public static void checkCFRTEst1(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c LIMIT 1];
        
        test.StartTest();
        CFRNegativeCheckRelatedPartyAMLCheck.pan = 'AMETG7643T';
        CFRNegativeCheckRelatedPartyAMLCheck.customerType ='Non Individual';
        CFRNegativeCheckRelatedPartyAMLCheck.aadharNumber ='123412341234';
        CFRNegativeCheckRelatedPartyAMLCheck.passportNumber ='J6756325';
        CFRNegativeCheckRelatedPartyAMLCheck.voterId ='123456789';
        CFRNegativeCheckRelatedPartyAMLCheck.cinNo = '13434';
        CFRNegativeCheckRelatedPartyAMLCheck.applcntRecordTypeName = 'Co-Applicant';
        CFRNegativeCheckRelatedPartyAMLCheck.checkNegativeCheck();
        CFRNegativeCheckRelatedPartyAMLCheck.checkRelatedParty();
        CFRNegativeCheckRelatedPartyAMLCheck.checkCFR();
        CFRNegativeCheckRelatedPartyAMLCheck.genericDynamicSoql('Name' , 'Account' , '');
        CFRNegativeCheckRelatedPartyAMLCheck.checkCFRByName();
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl1.Id);
        CFRNegativeCheckRelatedPartyAMLCheck.updateHandler(new List<Applicant__c> {appl1} );
        CFRNegativeCheckRelatedPartyAMLCheck.updateApplcnt(new List<Applicant__c> {appl1} );
        CFRNegativeCheckRelatedPartyAMLCheck.updateLoanApplction( loanObj.Id);
        test.StopTest();
    }
    
    @isTest
    public static void checkCFRTEst2(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c where PAN__c = 'AAACB5343E' LIMIT 1];
        
        test.StartTest();
        CFRNegativeCheckRelatedPartyAMLCheck.pan = 'AAACB5343E';
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl1.Id);
        test.StopTest();
    }
    
    @isTest
    public static void checkCFRTEst3(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c where PAN__c = 'AFQPA8916A' LIMIT 1];
        
        test.StartTest();
        CFRNegativeCheckRelatedPartyAMLCheck.pan = 'AFQPA8916A';
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl1.Id);
        test.StopTest();
    }
    
    @isTest
    public static void checkCFRTEst4(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c where PAN__c = 'AFQPA8916A' LIMIT 1];
        
        test.StartTest();
        CFRNegativeCheckRelatedPartyAMLCheck.pan = 'AFQPA8916A';
        CFRNegativeCheckRelatedPartyAMLCheck.aadharNumber = 'AFQPA8939A';
        CFRNegativeCheckRelatedPartyAMLCheck.passportNumber = 'AFQPA8939A';
        CFRNegativeCheckRelatedPartyAMLCheck.voterId = 'AFQPA8939A';
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl1.Id);
        test.StopTest();
    }
    
    @isTest
    public static void checkCFRTEst5(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c where CIN__c = '576321' LIMIT 1];
        
        test.StartTest();
        CFRNegativeCheckRelatedPartyAMLCheck.cinNo = '576321';
        CFRNegativeCheckRelatedPartyAMLCheck.pan = 'AFQPA8939A';
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl1.Id);
        test.StopTest();
    }
    
    @isTest
    public static void checkCFRTEst6(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c where PAN__c = 'AFQPA8939A' LIMIT 1];
        
        test.StartTest();
        CFRNegativeCheckRelatedPartyAMLCheck.pan = 'AFQPA8939A';
        CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl1.Id);
        test.StopTest();
    }
    
    @isTest
    public static void checkCFRTEst7(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c where PAN__c = 'AFQPA9939P' LIMIT 1];
        
        test.StartTest();
        CFRNegativeCheckRelatedPartyAMLCheck.updateHandler(new List<Applicant__c> {appl1} );
        test.StopTest();
    }
    
}