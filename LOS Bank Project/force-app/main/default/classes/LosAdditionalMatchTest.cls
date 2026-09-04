@isTest
public class LosAdditionalMatchTest {
    @testSetup static void setup() {
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
           	Account_Code__c='2103',
            RC_Limit_Amount__c = 1000,
            RC_Limit_Used_Amount__c = 100,
            Ad_Hoc_Date__c = System.today().addDays(1),
            RC_Limit_Used_Count__c = 0
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
            Total_Loan_Amount__c = 100
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
        
        Date  cibilReRunDate = System.today().addDays(-31);
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,CIBIL_Rerun__c = true,Last_CIBIL_Run_Date__c = cibilReRunDate, Pan__c = 'AMERT2638K',
            IsInactive__c = false,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
         Bureau_Results__c BureauRes = (Bureau_Results__c)TestFactory.createSObject(new Bureau_Results__c(
           Applicant__c = appl.id,
           Account_High_Credit_Amount__c = 100
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
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash1',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id, Aadhaar_Number__c ='12341234234' , PAN__c ='AMERT2638L',
            Existing_Customer__c = 'Yes', Last_CIBIL_Run_Date__c = Date.today(),
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
        ),true);
        
        TestFactory.createSObject(new Bureau_Results__c(
            Applicant__c = appl1.Id,
            Bureau_Score_Date__c = Date.today(),
            Bureau_Score__c = 777
        ),true);

        Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Test',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id, Aadhaar_Number__c ='12341234234' , PAN__c ='AMERT2638K',
            Existing_Customer__c = 'Yes',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
        ),true);
        
        Bureau_Results__c bresult = (Bureau_Results__c)TestFactory.createSObject(new Bureau_Results__c(
            Applicant__c = appl2.Id,
            Bureau_Score_Date__c = Date.today(),
            Bureau_Score__c = 777
        ),true);
        
        appl2.Bureau_Results__c = bresult.Id;
        update appl2;
        System.debug('appl2: '+appl2);
        
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Cibil Individual	',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/FicoBREService',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        Integration_Checklist__c intCheck = (Integration_Checklist__c)TestFactory.createSObject(new Integration_Checklist__c(
            Request__c = 'Cibil Individual',
            Response__c = '',//{"response_status":{"code":"97","message":"K-100-Resident authentication failed","status":"FAIL","txnID":"UKC:10-USR001-SFDC-20230519130219-"}}',
            Applicant__c = appl1.Id,
            Integration_Master__c = intmassearch2.Id
            
        ),true);


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
    } 
    
    @isTest
    public static void checkCFRTEst(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c LIMIT 1];
        
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CibilHTTPMock());


        LosAdditionalMatchController.getApplicant(appl1.Id);
        LosAdditionalMatchController.createCibilRequest(appl1.Id);
        LosAdditionalMatchController.getLoanDetails(appl1.Id);        
        test.StopTest();
    }
    
    @isTest
    public static void checkCFRTEst1(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c WHERE PAN__c = 'AMERT2638L'];
        
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CibilHTTPMock());


        LosAdditionalMatchController.getApplicant(appl1.Id);
        LosAdditionalMatchController.createCibilRequest(appl1.Id);
        LosAdditionalMatchController.getLoanDetails(appl1.Id);        
        test.StopTest();
    }

    @isTest
    public static void checkCFRWithExistingMatch(){
        Loan_Application__c loanObj = [ SELECT Id FROM Loan_Application__c LIMIT 1 ];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c WHERE PAN__c = 'AMERT2638K' AND RecordType.Name = 'Co-Applicant' ];
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CibilHTTPMock());
        LosAdditionalMatchController.createCibilRequest( appl1.Id );
        Test.StopTest();
    }
    
    @isTest
    public static void checkCFRTEst2(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c, Bureau_Results__c from Applicant__c WHERE PAN__c = 'AMERT2638K' LIMIT 1];
        
        Bureau_Results__c bresult = (Bureau_Results__c)TestFactory.createSObject(new Bureau_Results__c(
            Applicant__c = appl1.Id,
            Bureau_Score_Date__c = Date.today(),
            Bureau_Score__c = 777
        ),true);
        
        appl1.Bureau_Results__c = bresult.Id;
        update appl1;
        
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CibilHTTPMock());


        LosAdditionalMatchController.getApplicant(appl1.Id);
        LosAdditionalMatchController.createCibilRequest(appl1.Id);
        LosAdditionalMatchController.getLoanDetails(appl1.Id);        
        test.StopTest();
    }
    
    @isTest
    public static void checkCFRTEst3(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        List<Applicant__c> appl1 = [select id,(Select Id from Bureau_Results__r), RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Pan__c, Related_Party_Status__c,Negative_Check_Status__c, Last_CIBIL_Run_Date__c from Applicant__c where Pan__c = 'AMERT2638K' ORDER BY Applicant_Type_Priority__c LIMIT 2];
        appl1[0].Last_CIBIL_Run_Date__c = System.today().addDays(-10);
        appl1[1].Last_CIBIL_Run_Date__c = System.today().addDays(-15);
        update appl1;
        test.StartTest();
        system.debug(LoggingLevel.Info,' -- applicant ' + appl1[0].Bureau_Results__r);
        system.debug(LoggingLevel.Info,' -- applicant ' + appl1[1].Bureau_Results__r);
        Test.setMock(HttpCalloutMock.class, new CibilHTTPMock());


        LosAdditionalMatchController.createCibilRequest(appl1[1].Id);
        test.StopTest();
    }
    
//    @isTest
//     public static void checkCFRTEst1(){
//         Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
//         Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
//         List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
//         List<String> recordIds = new List<String>{loanapp[0].Id};
//             User usr = [SELECT Id FROM User LIMIT 1];
//         Applicant__c appl1 = [select id,RecordTypeId,CFR_Status__c,RecordType.Name,Loan__c, Related_Party_Status__c,Negative_Check_Status__c from Applicant__c LIMIT 1];
        
//         test.StartTest();
//         CFRNegativeCheckRelatedPartyAMLCheck.pan = 'AMETG7643T';
//         CFRNegativeCheckRelatedPartyAMLCheck.customerType ='Non Individual';
//         CFRNegativeCheckRelatedPartyAMLCheck.aadharNumber ='123412341234';
//         CFRNegativeCheckRelatedPartyAMLCheck.passportNumber ='J6756325';
//         CFRNegativeCheckRelatedPartyAMLCheck.voterId ='123456789';
//         CFRNegativeCheckRelatedPartyAMLCheck.cinNo = '13434';
//         CFRNegativeCheckRelatedPartyAMLCheck.applcntRecordTypeName = 'Co-Applicant';

//         CFRNegativeCheckRelatedPartyAMLCheck.checkCFR();
//         CFRNegativeCheckRelatedPartyAMLCheck.genericDynamicSoql('Name' , 'Account' , '');
//         CFRNegativeCheckRelatedPartyAMLCheck.checkCFRByName();
//         CFRNegativeCheckRelatedPartyAMLCheck.checkHandler(appl1.Id);
//         CFRNegativeCheckRelatedPartyAMLCheck.updateHandler(new List<Applicant__c> {appl1} );
//         CFRNegativeCheckRelatedPartyAMLCheck.updateApplcnt(new List<Applicant__c> {appl1} );
//         CFRNegativeCheckRelatedPartyAMLCheck.updateLoanApplction( loanObj.Id);
//         test.StopTest();
//     }
    
}