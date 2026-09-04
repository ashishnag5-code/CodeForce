@isTest
public class DealerDetailControllerTest {
    @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id,
            Purchase_State__c = 'Raj',
            Product__c = '4W',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);
        
        Contact conInstance = (Contact )TestFactory.createSObject(new Contact (
            AccountId=accInstance.Id,
            LastName = 'Test12',
            Type__c = 'DSE'
        ),true);
        Contact conInstance12 = (Contact )TestFactory.createSObject(new Contact (
            AccountId=accInstance.Id,
            LastName = 'Test22',
            Type__c = 'DSM'
        ),true);
        
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Dealer_Master__c = accInstance.Id,
            Sourcing_channel__c  = 'Commercial Associate With Rc Limit',
            Branch_Master__c = accInstance.Id
        ),true);
        Loan_Application__c loanApplTractor = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-1234566',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10501',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Dealer_Master__c = accInstance.Id,
            Sourcing_channel__c  = 'Commercial Associate With Rc Limit',
            Branch_Master__c = accInstance.Id
        ),true);
        
        
        Loan_Application__c loanAppl2W = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12346',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Two_Wheeler').getRecordTypeId()
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Payment__c payRec = (Payment__c)TestFactory.createSObject(new Payment__c(
            Inactive__c  = false,
            Partial_Payment_Condition__c  = 'Test Condition',
            Loan_Application__c  =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Dealer_Payout').getRecordTypeId()
        ),true);
        
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', Vehicle_Category__c ='TestCat'
        ),true);
        Deviation__c  dev = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Loan_Application__c  = loanAppl.id , Active__c  = true,Deviation_Type__c  ='COW-No HPN-Customer'
        ),true);
        
        Id ltvRecordTypeId = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('LTV').getRecordTypeId();
        Depreciated_Grid__c dep = (Depreciated_Grid__c)TestFactory.createSObject(new Depreciated_Grid__c(
            RecordTypeId= ltvRecordTypeId ,Customer_Grade__c = 'NIB' , Vehicle_Usage__c = 'Personal',Category__c ='A;B',
            Scheme__c = scheme1.Id
        ),true);
        Collateral__c coll = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'TestCat',
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId()
            
        ),true);
        
        Collateral__c coll1 = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppl2W.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'TestCat',
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId()
            
        ),true);     
        MMV_Master__c  master = (MMV_Master__c )TestFactory.createSObject(new MMV_Master__c (
            Name='Tata Hitachi',
            RecordTypeId=Schema.SObjectType.MMV_Master__c .getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId()             
        ),true);    
        Account  accmaster = (Account )TestFactory.createSObject(new Account (
            Name='Test',MFG__c=master.Id,Product__c ='ALL',Purchase_State__c ='Karnataka',Purchase_City__c='Bangalore',
            Dealer_Class__c ='New Dealer'                        
        ),true);    
    }
    @isTest
    public static void getLoanApplTest(){
        Loan_Application__c loanAppl = [SELECT Id,Application_Number__c from Loan_Application__c WHERE Application_Number__c = 'AP-12345' LIMIT 1];
        Test.startTest();
        DealerDetailController.getLoanAppl(loanAppl.Id);
        System.assertEquals('AP-12345', loanAppl.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest
    public static void dealerDetailHandlerTest(){
        Loan_Application__c loanAppl = [SELECT Id,Application_Number__c from Loan_Application__c WHERE Application_Number__c = 'AP-12345' LIMIT 1];
        Test.startTest();
        DealerDetailController.dealerDetailHandler(loanAppl.Id);
        loanAppl.Product__c = '10501';
        update loanAppl;
        DealerDetailController.dealerDetailHandler(loanAppl.Id);
        System.assertEquals('AP-12345', loanAppl.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }
    /*  @isTest
public static void dealerDetailHandlerTest1(){
Loan_Application__c loanAppl = [SELECT Id,Application_Number__c from Loan_Application__c WHERE Application_Number__c = 'AP-1234566' LIMIT 1];
Test.startTest();
DealerDetailController.dealerDetailHandler(loanAppl.Id);
System.assertEquals('AP-12345', loanAppl.Application_Number__c,'AssertMsg');
Test.stopTest();
}*/
    @isTest
    public static void saveDealerAndUpdatLoanApplEditTest(){
        Loan_Application__c loanAppl = [SELECT Id,Application_Number__c from Loan_Application__c WHERE Application_Number__c = 'AP-12345' LIMIT 1];
        Payment__c payRec= [SELECT Id from Payment__c LIMIT 1];
        Test.startTest();
        DealerDetailController.saveDealerAndUpdatLoanAppl(loanAppl,payRec,'edit');
        System.assertEquals('AP-12345', loanAppl.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest
    public static void saveDealerAndUpdatLoanApplSaveTest(){
        Loan_Application__c loanAppl = [SELECT Id,Application_Number__c from Loan_Application__c WHERE Application_Number__c = 'AP-12345' LIMIT 1];
        Payment__c payRec = new Payment__c();
        payRec.Partial_Payment_Condition__c = 'test';
        payRec.Loan_Application__c = loanAppl.Id;
        Test.startTest();
        DealerDetailController.saveDealerAndUpdatLoanAppl(loanAppl,payRec,'Save');
        System.assertEquals('AP-12345', loanAppl.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest
    public static void saveDealerAndUpdatLoanApplNULLTest(){
        Loan_Application__c loanAppl = [SELECT Id,Application_Number__c from Loan_Application__c WHERE Application_Number__c = 'AP-12345' LIMIT 1];
        Test.startTest();
        DealerDetailController.saveDealerAndUpdatLoanAppl(loanAppl,NULL,'Save');
        System.assertEquals('AP-12345', loanAppl.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest
    public static void genericFetchForDealerTest(){
        Loan_Application__c loanAppl = [SELECT Id,Application_Number__c from Loan_Application__c WHERE Application_Number__c = 'AP-12346' LIMIT 1];
        Test.startTest();
        DealerDetailController.dealerDetailHandler(loanAppl.Id);
        System.assertEquals('AP-12346', loanAppl.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest
    public static void dealerSave(){
        Loan_Application__c loanAppl = [SELECT Id,Application_Number__c from Loan_Application__c WHERE Application_Number__c = 'AP-12346' LIMIT 1];
        MMV_Master__c  master = [SELECT id,Name from MMV_Master__c WHERE Name='Tata Hitachi'];
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account accInstance = new Account();
        accInstance.Account_Name__c = 'TestAcc13';
        accInstance.RecordTypeId = dealerRecordTypeId;
        accInstance.Outlet_Name__c = 'Bangalore';
        Test.startTest();
        DealerDetailController.dealerSave(accInstance,master.Name,loanAppl.Id,'Dealer New Vehicle');
        System.assertEquals('AP-12346', loanAppl.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }     
    
    @isTest
    public static void checkBodyFunding(){
        Loan_Application__c loanAppl = [SELECT Id,Application_Number__c from Loan_Application__c WHERE Application_Number__c = 'AP-12346' LIMIT 1];
        Account acc = [SELECT id,Name,MFG__r.Name,Product__c ,Purchase_State__c ,Purchase_City__c,Dealer_Class__c  FROM Account WHERE Name = 'Test'];
        Test.startTest();
        DealerDetailController.checkBodyFundingRequired(acc.MFG__r.Name,acc.Purchase_City__c,acc.Purchase_State__c,acc.Dealer_Class__c,'4W');
        System.assertEquals('AP-12346', loanAppl.Application_Number__c,'AssertMsg');
        Test.stopTest();
        
    }
    @isTest
    public static void testfetch(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c WHERE Application_Number__c = 'AP-12346' LIMIT 1];
        loanAppl.Product__c ='10301';
        update loanAppl;
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            Purchase_State__c='Rajasthan',                 
            Product__c ='2W',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);
        
        // Test parameters
        Object testParams = new Map<String, Object>{
            'Category__c' => 'Commercial',
                'Product__c' => '2W',
                'Purchase_City__c'=>'Jaipur',
                'Purchase_State__c'=>'Rajasthan'
                // Add other test parameters as needed
                };
                    
                    
                    Test.startTest();
        // Call the method with appropriate parameters
        DealerDetailController.genericFetchForDealer(testParams,loanAppl.Id);
        Test.stopTest();
        
        
    }
    
    
}