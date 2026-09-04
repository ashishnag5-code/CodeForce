/*****
 * Class Name: PricingSummaryPageControllerTest
 * Description: Test Class for PricingSummaryPageController
 * 
 * LastModified Date    -   Last Modified By    -   Description / Bug
 * Dec-06-2023          -   Mohit M.            -   
 */
@IsTest
public class PricingSummaryPageControllerTest {
    @testsetup
    static void testDataSetup() {
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10201',
            Collateral_Type__c = '10105',
            Total_Loan_Amount__c =2000,
            Tenure__c =4,
            RBP__c=2.0,
            ROI__c = 17.0,
            EMI__c = 13
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),true);
        
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = loanAppl.Id,
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10
        ),true);
        
        Address__c testAddressRec = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'test address1',
            Address_Line_2__c = 'test address2',
            Address_Line_3__c = 'Existing ',
            State__c = '123456Test',
            City__c = 'testcity',
            Pincode__c = 'testPincode',
            Applicant__c = appl.Id,
            Address_Type__c = 'Current'
            
        ),true);
        
        Bureau_Results__c  resultRec = (Bureau_Results__c )TestFactory.createSObject(new Bureau_Results__c (
            Applicant__c  = appl.Id,
            Bureau_Score__c  = 100
            
        ),true);
        
        /*Loan_Application_Approval__c applicationAppTest = (Loan_Application_Approval__c  )TestFactory.createSObject(new Loan_Application_Approval__c  (
            Loan_Application__c   = loanAppl.Id,
            Approver__c   = UserInfo.getUserId(),
            Approval_Type__c = 'Credit',
            Approver_Level__c  = 'L0',
            Type__c = 'Highest'
            
        ),true);*/
    }
    
    @isTest
    public static void testGetPricingApplicantDetails() {
        String applicationId = [SELECT Id from Loan_Application__c LIMIT 1][0].Id;
        Test.startTest();
        SummaryPageWrapperController.PricingApplicantDetails returnWrapper = PricingSummaryPageController.getPricingApplicantDetails(applicationId);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }
    
    @isTest
    public static void testGetPricingVehicleDetails() {
        String applicationId = [SELECT Id from Loan_Application__c LIMIT 1][0].Id;
        Test.startTest();
        SummaryPageWrapperController.PricingVehicleDetails returnWrapper = PricingSummaryPageController.getPricingVehicleDetails(applicationId);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }
    
    @IsTest
    public static void testGetPricingLoanDetails() {
        String applicationId = [SELECT Id from Loan_Application__c LIMIT 1][0].Id;
        List<Charge__c> chargeRec = new List<Charge__c>();
        for(Integer i=0;i<4;i++) {
            Charge__c chg = new Charge__c();
            chg.Total_Amount__c = 100;
            chg.Loan_Application__c = applicationId;
            chg.Charges_Name__c = (i==0)?'Processing Fees':(i==1)?'Documentation Charges':(i==2)?'LS Charges':'Other Charges';
            chargeRec.add(chg);
        }
        insert chargeRec;
        Test.startTest();
        SummaryPageWrapperController.PricingLoanDetails returnWrapper = PricingSummaryPageController.getPricingLoanDetails(applicationId);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }
    
    @IsTest
    public static void testSetPricingLoanDetails() {
        Loan_Application__c loanApplication = [SELECT Id from Loan_Application__c LIMIT 1];
        Collateral__c  collateral = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanApplication.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10108',
            LTV_offered_On_road__c=20
        ),true);
        List<Collateral__c> collateralList = new List<Collateral__c>();
        collateralList.add(collateral);
        
        Decimal pf = 0.00, dc = 0.00, ls = 0.00, otherCharges = 0.00;
        List<Charge__c> chargeRec = new List<Charge__c>();
        Charge__c  chg = (Charge__c)TestFactory.createSObject(new Charge__c (
            Loan_Application__c =loanApplication.Id,
            Total_Amount__c=1000,
            Charges_Name__c='Other Charges'
        ),true);
        chargeRec.add(chg);
        
        /*for(Integer i=0;i<4;i++) {
            Charge__c chg = new Charge__c();
            chg.Total_Amount__c = 100;
            chg.Loan_Application__c = loanApplication.Id;
            chg.Charges_Name__c = (i==0)?'Processing Fees':(i==1)?'Documentation Charges':(i==2)?'LS Charges':'Other Charges';
            chargeRec.add(chg);
        }
        insert chargeRec;*/
        Test.startTest();
        SummaryPageWrapperController.PricingLoanDetails returnWrapper = PricingSummaryPageController.getPricingLoanDetails(loanApplication.Id);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }
    @IsTest
    public static void testGetApplicantDetailsProduct() {
        Test.startTest();
        Loan_Application__c application = [SELECT Id,Product__c,Collateral_Type__c, Branch_Master__c, OwnerId from Loan_Application__c LIMIT 1];
        application.Product__c = '10104';
        application.Collateral_Type__c = '10103';
        update application;
        DateTime dt = Datetime.now();
        String currentMonth = dt.format('MMM');
        String lastMonth = dt.addMonths(-1).format('MMM');
        WIRR__c wirrRec = new WIRR__c(User__c = application.OwnerId, Month__c = currentMonth, Branch__c = application.Branch_Master__c);
        insert wirrRec;
        
        PricingSummaryPageController.getPricingPerformanceDetails(application.Id);
        application.Product__c = '10105';
        application.Collateral_Type__c = '10104';
        update application;
        PricingSummaryPageController.getPricingPerformanceDetails(application.Id);
        application.Product__c = '10106';
        application.Collateral_Type__c = '10105';
        update application;
        PricingSummaryPageController.getPricingPerformanceDetails(application.Id);
        application.Product__c = '10204';
        update application;
        PricingSummaryPageController.getPricingPerformanceDetails(application.Id);
        application.Product__c = '10401';
        update application;
        PricingSummaryPageController.getPricingPerformanceDetails(application.Id);
        application.Product__c = '10501';
        update application;
        PricingSummaryPageController.getPricingPerformanceDetails(application.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetPricingPerformanceDetails() {
        Account accRecRegion = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId(),
            Name = 'Test Account'
            //Branch_Queue__c = groupId//'00G6s000001TiSyEAK'
        ),true);
        
        Account accRecHub = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hub').getRecordTypeId(),
            Name = 'Test Account',
             Region__c = accRecRegion.Id
            //Branch_Queue__c = groupId//'00G6s000001TiSyEAK'
        ),true);
        
        Account accRecBranch = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId(),
            Name = 'Test Account',
            Business_HUB__c  = accRecHub.Id//'00G6s000001TiSyEAK'
        ),true);
        
        Loan_Application__c appl = [SELECT Id, Branch_Master__c FROM Loan_Application__c LIMIT 1];
        appl.Branch_Master__c = accRecBranch.Id;
        update appl;
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(
                new User(firstName = 'test1', lastName = 'test2', profileId = prof.id,
                username = 'test'+UserInfo.getOrganizationId()+'@test.com', 
                email = 'test@test.com', Branch_Code__c  = '2103',Product_Accessible__c = 'All New'),true);
        
        WIRR__c wirr = (WIRR__c)TestFactory.createSObject(new WIRR__c(
                    Branch__c = accRecBranch.Id, User__c = usr.Id, Record_Key__c = appl.Id+'_'+System.Now().format( 'MMMM' ).subString(0,3) + '_' + System.today().year(),Month__c=System.Now().format( 'MMMM' ).subString(0,3),
                                Year__c=System.today().year()+''),true);
        
        Test.startTest();
        SummaryPageWrapperController.PSD_DDEPricingInformation returnWrapper = PricingSummaryPageController.getPricingPerformanceDetails(appl.Id);
        Test.stopTest();
        //System.assertEquals(returnWrapper!=null, true);
    }
    
    @isTest
    public static void testGetPricingSourcingDetails() {
        Account accRecDealer = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId(),
            Name = 'Test Account'
            //Branch_Queue__c = groupId//'00G6s000001TiSyEAK'
        ),true);
        
        Account accRecBranch = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId(),
            Name = 'Test Account'
        ),true);
        
        Loan_Application__c appl = [SELECT Id, Branch_Master__c, Dealer_Master__c FROM Loan_Application__c LIMIT 1];
        appl.Branch_Master__c = accRecBranch.Id;
        appl.Dealer_Master__c = accRecDealer.Id;
        update appl;
        Test.startTest();
        SummaryPageWrapperController.PricingSourcingDetails returnWrapper = PricingSummaryPageController.getPricingSourcingDetails(appl.Id);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
        
    }
    @isTest
    public static void testGetPricingPerformanceDetails1() {
        Account accRecRegion = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId(),
            Name = 'Test Account'
            //Branch_Queue__c = groupId//'00G6s000001TiSyEAK'
        ),true);
        
        Account accRecHub = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hub').getRecordTypeId(),
            Name = 'Test Account',
             Region__c = accRecRegion.Id
            //Branch_Queue__c = groupId//'00G6s000001TiSyEAK'
        ),true);
        
        Account accRecBranch = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId(),
            Name = 'Test Account',
            Business_HUB__c  = accRecHub.Id//'00G6s000001TiSyEAK'
        ),true);
        
        Loan_Application__c appl = [SELECT Id, Branch_Master__c FROM Loan_Application__c LIMIT 1];
        appl.Branch_Master__c = accRecBranch.Id;
         update appl;
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(
                new User(firstName = 'test1', lastName = 'test2', profileId = prof.id,
                username = 'test'+UserInfo.getOrganizationId()+'@test.com', 
                email = 'test@test.com', Branch_Code__c  = '2103',Product_Accessible__c = 'All New'),true);
        
        WIRR__c wirr = (WIRR__c)TestFactory.createSObject(new WIRR__c(
                    Branch__c = accRecBranch.Id, User__c = usr.Id, Record_Key__c = appl.Id+'_'+System.Now().format( 'MMMM' ).subString(0,3) + '_' + System.today().year(),Month__c=System.Now().format( 'MMMM' ).subString(0,3),
                                Year__c=System.today().year()+''),true);
        
        Test.startTest();
        SummaryPageWrapperController.PSD_DDEPricingInformation returnWrapper = PricingSummaryPageController.getPricingPerformanceDetails(appl.Id);
        Test.stopTest();
        //System.assertEquals(returnWrapper!=null, true); 
    }
    
     @isTest
    public static void testSetPricingSourcingDetails() {
        Account accRecDealer = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId(),
            Name = 'Test Account'
            //Branch_Queue__c = groupId//'00G6s000001TiSyEAK'
        ),true);
        
        Account accRecBranch = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId(),
            Name = 'Test Account'
        ),true);
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        AccountTeamMember  atm1;
        List<AccountTeamMember> accTeamMembers = new List<AccountTeamMember>();
    System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
    
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
             Account_Code__c='2103',
             Branch_Queue__c=grp.Id,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId()
        ),true); 
     Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
          lastName = 'test2',
          profileId = prof.id,
          username = 'test'+UserInfo.getOrganizationId()+'@test.com',
          email = 'test@test.com',
          Branch_Code__c  = '2103',
            MobilePhone = '1234567890'                                                
      ),true);
      AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
          AccountId =accInstance.Id,
          UserId=usr.Id,
          TeamMemberRole = 'Branch Manager'
         ),true); 
        atm1 = atm;
      }
        
        
        //accTeamMembers.add(atm1);
        
        Loan_Application__c appl = [SELECT Id, Branch_Master__c, Dealer_Master__c FROM Loan_Application__c LIMIT 1];
        appl.Branch_Master__c = accRecBranch.Id;
        appl.Dealer_Master__c = accRecDealer.Id;
        update appl;
        
        Payment__c paymentRecord = (Payment__c)TestFactory.createSObject(new Payment__c(
            //Payment_Recipient__c ='Customer',
            Loan_Application__c  = appl.Id,
            Dealer_Payout_amt__c='2000',
            Source_Payout_amt__c='2000',
            Inactive__c = false,
            isVerified__c = true,
            DSM_Payout__c='Yes',
            DSE_Payout__c='Yes',
            RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Dealer Payout').getRecordTypeId()
        ),true);
        
        List<Payment__c> paymentList = new List<Payment__c>();
        paymentList.add(paymentRecord);
        
        
        Test.startTest();
        SummaryPageWrapperController.PricingSourcingDetails returnWrapper = PricingSummaryPageController.getPricingSourcingDetails(appl.Id);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
        
    }
    
    @isTest public static void checkApplicationIdTest(){
        String applicationId = '';
        PricingSummaryPageController.getPricingPerformanceDetails(applicationId);
        PricingSummaryPageController.getPricingSourcingDetails(applicationId);
        PricingSummaryPageController.getPricingLoanDetails(applicationId);
        PricingSummaryPageController.getPricingVehicleDetails(applicationId);
    }
    @isTest
    public static void testPricingApplicantDetails() {
        Applicant__c app = [SELECT Id from Applicant__c LIMIT 1];
        Test.startTest();
        SummaryPageWrapperController.PricingApplicantDetails returnWrapper = PricingSummaryPageController.getPricingApplicantDetails(app.Id);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }
    
    @isTest
    public static void testGetPricingPerformanceDetailsLastMonth() {
        Account accRecRegion = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId(),
            Name = 'Test Account'
            //Branch_Queue__c = groupId//'00G6s000001TiSyEAK'
        ),true);
    
        Account accRecHub = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hub').getRecordTypeId(),
            Name = 'Test Account',
             Region__c = accRecRegion.Id
            //Branch_Queue__c = groupId//'00G6s000001TiSyEAK'
        ),true);
        
        Account accRecBranch = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId(),
            Name = 'Test Account',
            Business_HUB__c  = accRecHub.Id//'00G6s000001TiSyEAK'
        ),true);
        
        Loan_Application__c appl = [SELECT Id, Branch_Master__c FROM Loan_Application__c LIMIT 1];
        appl.Branch_Master__c = accRecBranch.Id;
        update appl;
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(
                new User(firstName = 'test1', lastName = 'test2', profileId = prof.id,
                username = 'test'+UserInfo.getOrganizationId()+'@test.com', 
                email = 'test@test.com', Branch_Code__c  = '2103',Product_Accessible__c = 'All New'),true);
        
        Integer d = Date.Today().day();
        Integer mo = Date.Today().addMonths(-1).month();
        Integer yr = Date.Today().year();
        
        DateTime dtime = DateTime.newInstance(yr, mo, d);
    
        WIRR__c wirr = (WIRR__c)TestFactory.createSObject(new WIRR__c(
                    Branch__c = accRecBranch.Id, User__c = usr.Id, Record_Key__c = appl.Id+'_'+dtime.format( 'MMMM' ).subString(0,3) + '_' + System.today().year(),Month__c=dtime.format( 'MMMM' ).subString(0,3),
                                Year__c=System.today().year()+''),true);
        
        Test.startTest();
        SummaryPageWrapperController.PSD_DDEPricingInformation returnWrapper = PricingSummaryPageController.getPricingPerformanceDetails(appl.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testSetAddress() {
        Address__c objAddress = [Select id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, City__c, State__c, Pincode__c from Address__c limit 1];
        Test.startTest();
            String strAddress = PricingSummaryPageController.setAddress(objAddress);
        Test.stopTest();
    }
    


}