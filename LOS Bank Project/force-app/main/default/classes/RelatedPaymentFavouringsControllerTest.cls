@isTest
public class RelatedPaymentFavouringsControllerTest {

    @testSetup static void setup() {
        // Create test data
        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tranche1 = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Inactive__c = false,
            Tranche_Number__c = 120);
        insert tranche1;
        
        
    }
    
        @IsTest
    static void testGetPaymentFavouringsTest() {
        // Create test data
        Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 12.34,
            Disbursed__c = false);
        Database.SaveResult sr1 = Database.insert(tr);
        String trancheId = sr1.getId();
        
        IFSC_Master__c ifscMaster = new IFSC_Master__c (Name = 'Test IFSC', ifsc__c = 'TEST01234');
        insert ifscMaster;

        Location_Master__c locMaster = new Location_Master__c(Name = '441601', State__c = 'MAHARASHTRA');
        insert locMaster;
        
        Id AccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account account = new Account (RecordTypeId = AccRecordTypeId, Account_Name__c = 'Account Test', 
                                Name = 'Account Test', Bank_Name__c = 'Test Bank LoanApp Acc', 
                                IFSC_Code__c = 'TEST01234', Pincode__c = locMaster.Id);
        insert account;
        
        //Dealer_Master__c dealMaster = new Dealer_Master__c(Name = 'Test DM');
        //insert dealMaster;

        Id GMRecordTypeIdpf = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Generic_Master__c genericMasterpf = new Generic_Master__c(RecordTypeId = GMRecordTypeIdpf, Bank_Name__c  = 'Test Bank', Type__c = 'CSD');
        insert genericMasterpf;
        
        Id GMRecordTypeIdbm = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Bank Master').getRecordTypeId();
        Generic_Master__c genericMasterbm = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test LoanApp Bank');
        insert genericMasterbm;
       
        Generic_Master__c genericMasterbm1 = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test Bank');
        insert genericMasterbm1;
		List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loanApp1 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, 
            Total_Charges__c = 2500, Dealer_Master__c = account.Id, Branch_Master__c = account.Id,Sourcing_Channel_Name__c=account.Id,
            Promo_Code__c = genericMasterpf.Id);
         loanApps.add(loanApp1);
        
        Loan_Application__c loanApp2 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 2', Product__c = '10303', Loan_Amount__c = 10000, 
            Dealer_Master__c = account.Id, Branch_Master__c = account.Id, Promo_Code__c = genericMasterbm.Id);
         loanApps.add(loanApp2);
        Loan_Application__c loanApp3 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, 
            Total_Charges__c = 2500, Sourcing_Channel_Name__c  = account.Id, Branch_Master__c = account.Id,
            Promo_Code__c = genericMasterpf.Id);
         loanApps.add(loanApp3);
        
        insert loanApps;
        
        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId();
        Payment__c bt = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Tranche__c = trancheId,
            Inactive__c = false,
            BT_Loan_Status__c = 'Fore Closure Refinance',
            Loan_Number__c='979797',
            Loan_Application__c = loanApp1.Id);
        Database.SaveResult sr2 = Database.insert(bt);
        String balTraId = sr2.getId();
        
        Id PaymentRecordTypeId3 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Payment__c pf = new Payment__c(
            RecordTypeId = PaymentRecordTypeId3, 
            Name__c = 'Test Payment', 
            Net_Amount__c = 123.45,
            Payment_Recipient__c = 'Customer',
            Tranche__c = trancheId,
            Account_Number__c = '979797',
            Loan_Application__c = loanApp2.Id,
            Inactive__c = false);
        Database.SaveResult sr3 = Database.insert(pf);
        String payFavId = sr3.getId();
   Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            					Loan__c = loanApp2.Id,Vehicle_Usage__c='Personal'),false);
        collat.HPN_With_Financiers_Name__c = 'NA';
        insert collat;
        // Populate the required fields and other necessary fields for the loan application
        // Set the loanAppRecId to the Id of the loan application record

        Test.startTest();
        // Call the getPaymentFavourings method
        RelatedPaymentFavouringsController.getPaymentFavourings(loanApp1.Id);
         RelatedPaymentFavouringsController.getPaymentFavourings(loanApp3.Id);
        RelatedPaymentFavouringsController.RelatedPaymentFavouringsWrapper wrapper = RelatedPaymentFavouringsController.getPaymentFavourings(loanApp2.Id);    
      //  RelatedPaymentFavouringsController.savePaymentFavouring(wrapper.tranchePymntLst[0], loanApp2.Product__c, new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>(), loanApp2.Id, 'insert', 12.34);
        try{
            RelatedPaymentFavouringsController.checkDeviationRules(loanApp2.Id);  
        }Catch(Exception e){
            
        }

        Test.stopTest();
    }
     @IsTest
    static void testGetPaymentFavouringsTest2() {
        // Create test data
        
        
        IFSC_Master__c ifscMaster = new IFSC_Master__c (Name = 'Test IFSC', ifsc__c = 'TEST01234');
        insert ifscMaster;

        Location_Master__c locMaster = new Location_Master__c(Name = '441601', State__c = 'MAHARASHTRA');
        insert locMaster;
        
        Id AccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account account = new Account (RecordTypeId = AccRecordTypeId, Account_Name__c = 'Account Test', 
                                Name = 'Account Test', Bank_Name__c = 'Test Bank LoanApp Acc', 
                                IFSC_Code__c = 'TEST01234', Pincode__c = locMaster.Id);
        insert account;
        
        //Dealer_Master__c dealMaster = new Dealer_Master__c(Name = 'Test DM');
        //insert dealMaster;

        Id GMRecordTypeIdpf = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Generic_Master__c genericMasterpf = new Generic_Master__c(RecordTypeId = GMRecordTypeIdpf, Bank_Name__c  = 'Test Bank', Type__c = 'CSD',State__c = 'MAHARASHTRA');
        insert genericMasterpf;
        
        Id GMRecordTypeIdbm = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Bank Master').getRecordTypeId();
        Generic_Master__c genericMasterbm = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test Bank LoanApp Acc');
        insert genericMasterbm;
       
        Generic_Master__c genericMasterbm1 = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test Bank');
        insert genericMasterbm1;
		List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loanApp1 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, Sourcing_Channel__c = 'Commercial Associate Without Rc Limit' ,
            Total_Charges__c = 2500, Dealer_Master__c = account.Id, Branch_Master__c = account.Id,
            Promo_Code__c = genericMasterpf.Id);
         loanApps.add(loanApp1);
        
        Loan_Application__c loanApp2 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 2', Product__c = '10303', Loan_Amount__c = 10000,Sourcing_Channel__c = 'Commercial Associate Without Rc Limit' ,
            Dealer_Master__c = account.Id, Branch_Master__c = account.Id, Promo_Code__c = genericMasterpf.Id);
         loanApps.add(loanApp2);
        insert loanApps;
        Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 12.34,
            Loan_Application__c = loanApp2.Id,
            Disbursed__c = false);
        Database.SaveResult sr1 = Database.insert(tr);
        String trancheId = sr1.getId();
        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId();
        Payment__c bt = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Tranche__c = trancheId,
            Inactive__c = false,
            Loan_Application__c = loanApp1.Id);
        Database.SaveResult sr2 = Database.insert(bt);
        String balTraId = sr2.getId();
        
        Id PaymentRecordTypeId3 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Payment__c pf = new Payment__c(
            RecordTypeId = PaymentRecordTypeId3, 
            Name__c = 'Test Payment', 
            Net_Amount__c = 123.45,
            Payment_Recipient__c = 'Customer',
            Tranche__c = trancheId,
            Loan_Application__c = loanApp2.Id,
            Inactive__c = false);
        Database.SaveResult sr3 = Database.insert(pf);
        String payFavId = sr3.getId();
   Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            					Loan__c = loanApp2.Id,Vehicle_Usage__c='Personal'),false);
        collat.HPN_With_Financiers_Name__c = 'NA';
        insert collat;
        // Populate the required fields and other necessary fields for the loan application
        // Set the loanAppRecId to the Id of the loan application record
		RelatedPaymentFavouringsController.TrancheOptionsWrapper tranche = new RelatedPaymentFavouringsController.TrancheOptionsWrapper();
        tranche.label = 'Test Payment';
        tranche.value = 'Test Payment';
        tranche.trancheNumber = '120';
        tranche.disbursementAmount = 123.45;
        Test.startTest();
        // Call the getPaymentFavourings method
        RelatedPaymentFavouringsController.getPaymentFavourings(loanApp1.Id);
        RelatedPaymentFavouringsController.RelatedPaymentFavouringsWrapper wrapper = RelatedPaymentFavouringsController.getPaymentFavourings(loanApp2.Id); 
        wrapper.tranchePymntLst[0].Loan_Application__c = loanApp2.Id;
        wrapper.tranchePymntLst[0].Net_Amount__c = 123.45;
        RelatedPaymentFavouringsController.savePaymentFavouring(wrapper.tranchePymntLst[0], loanApp2.Product__c, new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>{tranche}, loanApp2.Id, 'insert', 12.34);
        RelatedPaymentFavouringsController.savePaymentFavouring(wrapper.tranchePymntLst[0], loanApp2.Product__c, new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>{tranche}, loanApp2.Id, 'update', 12.34);
        RelatedPaymentFavouringsController.validationForTrancheSequence2(pf.Id,new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>{tranche},loanApp2.Id,12.34,'Test',wrapper.tranchePymntLst[0]);
        try{
            RelatedPaymentFavouringsController.checkDeviationRules(loanApp2.Id);  
        }Catch(Exception e){
            
        }

        Test.stopTest();
    }
    @isTest
    static void testGetPaymentFavouringsTest3() {
        // Create test data
        
        
        IFSC_Master__c ifscMaster = new IFSC_Master__c (Name = 'Test IFSC', ifsc__c = 'TEST01234');
        insert ifscMaster;

        Location_Master__c locMaster = new Location_Master__c(Name = '441601', State__c = 'MAHARASHTRA');
        insert locMaster;
        
        Id AccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account account = new Account (RecordTypeId = AccRecordTypeId, Account_Name__c = 'Account Test', 
                                Name = 'Account Test', Bank_Name__c = 'Test Bank LoanApp Acc', 
                                IFSC_Code__c = 'TEST01234', Pincode__c = locMaster.Id);
        insert account;
        
        //Dealer_Master__c dealMaster = new Dealer_Master__c(Name = 'Test DM');
        //insert dealMaster;

        Id GMRecordTypeIdpf = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Generic_Master__c genericMasterpf = new Generic_Master__c(RecordTypeId = GMRecordTypeIdpf, Bank_Name__c  = 'Test Bank', Type__c = 'CSD',State__c = 'MAHARASHTRA');
        insert genericMasterpf;
        
        Id GMRecordTypeIdbm = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Bank Master').getRecordTypeId();
        Generic_Master__c genericMasterbm = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test Bank LoanApp Acc');
        insert genericMasterbm;
       
        Generic_Master__c genericMasterbm1 = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test Bank');
        insert genericMasterbm1;
		List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loanApp1 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, 
            Total_Charges__c = 2500, Dealer_Master__c = account.Id, Branch_Master__c = account.Id,Sourcing_Channel__c = ' Commercial Associate With Rc Limit',
            Promo_Code__c = genericMasterpf.Id);
         loanApps.add(loanApp1);
        
        Loan_Application__c loanApp2 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 2', Product__c = '10303', Loan_Amount__c = 10000, Sourcing_Channel__c = ' Commercial Associate With Rc Limit',
            Dealer_Master__c = account.Id, Branch_Master__c = account.Id, Promo_Code__c = genericMasterpf.Id);
         loanApps.add(loanApp2);
        insert loanApps;
        Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 12.34,
            Loan_Application__c = loanApp2.Id,
            Disbursed__c = false);
        Database.SaveResult sr1 = Database.insert(tr);
        String trancheId = sr1.getId();
        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId();
        Payment__c bt = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Tranche__c = trancheId,
            Inactive__c = false,
            Loan_Application__c = loanApp1.Id);
        Database.SaveResult sr2 = Database.insert(bt);
        String balTraId = sr2.getId();
        
        Id PaymentRecordTypeId3 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Payment__c pf = new Payment__c(
            RecordTypeId = PaymentRecordTypeId3, 
            Name__c = 'Test Payment', 
            Net_Amount__c = 123.45,
            Payment_Recipient__c = '',
            Tranche__c = trancheId,
            Loan_Application__c = loanApp2.Id,
            Inactive__c = false);
        Database.SaveResult sr3 = Database.insert(pf);
        String payFavId = sr3.getId();
   Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            					Loan__c = loanApp2.Id,Vehicle_Usage__c='Personal'),false);
        collat.HPN_With_Financiers_Name__c = 'NA';
        insert collat;
        // Populate the required fields and other necessary fields for the loan application
        // Set the loanAppRecId to the Id of the loan application record
		RelatedPaymentFavouringsController.TrancheOptionsWrapper tranche = new RelatedPaymentFavouringsController.TrancheOptionsWrapper();
        tranche.label = 'Test Payment';
        tranche.value = 'Test Payment';
        tranche.trancheNumber = '120';
        tranche.disbursementAmount = 123.45;
        Test.startTest();
        // Call the getPaymentFavourings method
        RelatedPaymentFavouringsController.getPaymentFavourings(loanApp1.Id);
        RelatedPaymentFavouringsController.RelatedPaymentFavouringsWrapper wrapper = RelatedPaymentFavouringsController.getPaymentFavourings(loanApp2.Id); 
        wrapper.tranchePymntLst[0].Loan_Application__c = loanApp2.Id;
        wrapper.tranchePymntLst[0].Net_Amount__c = 123.45;
        RelatedPaymentFavouringsController.savePaymentFavouring(wrapper.tranchePymntLst[0], loanApp2.Product__c, new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>{tranche}, loanApp2.Id, 'insert', 12.34);
        RelatedPaymentFavouringsController.savePaymentFavouring(wrapper.tranchePymntLst[0], loanApp2.Product__c, new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>{tranche}, loanApp2.Id, 'update', 12.34);
        RelatedPaymentFavouringsController.validationForTrancheSequence2(pf.Id,new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>{tranche},loanApp2.Id,12.34,'Test',wrapper.tranchePymntLst[0]);
        try{
            RelatedPaymentFavouringsController.checkDeviationRules(loanApp2.Id);  
        }Catch(Exception e){
            
        }

        Test.stopTest();
    }
    @isTest
    static void testGetPaymentFavouringsTest4() {
        // Create test data
        
        
        IFSC_Master__c ifscMaster = new IFSC_Master__c (Name = 'Test IFSC', ifsc__c = 'TEST01234');
        insert ifscMaster;

        Location_Master__c locMaster = new Location_Master__c(Name = '441601', State__c = 'MAHARASHTRA');
        insert locMaster;
        
        Id AccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account account = new Account (RecordTypeId = AccRecordTypeId, Account_Name__c = 'Account Test', 
                                Name = 'Account Test', Bank_Name__c = 'Test Bank LoanApp Acc', 
                                IFSC_Code__c = 'TEST01234', Pincode__c = locMaster.Id);
        insert account;
        
        //Dealer_Master__c dealMaster = new Dealer_Master__c(Name = 'Test DM');
        //insert dealMaster;

        Id GMRecordTypeIdpf = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Generic_Master__c genericMasterpf = new Generic_Master__c(RecordTypeId = GMRecordTypeIdpf, Bank_Name__c  = 'Test Bank', Type__c = 'CSD',State__c = 'MAHARASHTRA');
        insert genericMasterpf;
        
        Id GMRecordTypeIdbm = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Bank Master').getRecordTypeId();
        Generic_Master__c genericMasterbm = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test Bank LoanApp Acc');
        insert genericMasterbm;
       
        Generic_Master__c genericMasterbm1 = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test Bank');
        insert genericMasterbm1;
		List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loanApp1 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, 
            Total_Charges__c = 2500, Dealer_Master__c = account.Id, Branch_Master__c = account.Id,Sourcing_Channel__c = ' Commercial Associate With Rc Limit',
            Promo_Code__c = genericMasterpf.Id);
         loanApps.add(loanApp1);
        
        Loan_Application__c loanApp2 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 2', Product__c = '10303', Loan_Amount__c = 10000, Sourcing_Channel__c = ' Commercial Associate With Rc Limit',
            Dealer_Master__c = account.Id, Branch_Master__c = account.Id, Promo_Code__c = genericMasterpf.Id);
         loanApps.add(loanApp2);
        insert loanApps;
        Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 12.34,
            Loan_Application__c = loanApp2.Id,
            Disbursed__c = false);
        Database.SaveResult sr1 = Database.insert(tr);
        String trancheId = sr1.getId();
        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId();
        Payment__c bt = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Tranche__c = trancheId,
            Inactive__c = false,
            Loan_Application__c = loanApp1.Id);
        Database.SaveResult sr2 = Database.insert(bt);
        String balTraId = sr2.getId();
        
        Id PaymentRecordTypeId3 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Payment__c pf = new Payment__c(
            RecordTypeId = PaymentRecordTypeId3, 
            Name__c = 'Test Payment', 
            Net_Amount__c = 123.45,
            Payment_Recipient__c = '',
            Tranche__c = trancheId,
            Loan_Application__c = loanApp2.Id,
            Inactive__c = false);
        Database.SaveResult sr3 = Database.insert(pf);
        String payFavId = sr3.getId();
   Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            					Loan__c = loanApp2.Id,Vehicle_Usage__c='Personal'),false);
        collat.HPN_With_Financiers_Name__c = 'Test';
        insert collat;
        // Populate the required fields and other necessary fields for the loan application
        // Set the loanAppRecId to the Id of the loan application record
		RelatedPaymentFavouringsController.TrancheOptionsWrapper tranche = new RelatedPaymentFavouringsController.TrancheOptionsWrapper();
        tranche.label = 'Test Payment';
        tranche.value = 'Test Payment';
        tranche.trancheNumber = '120';
        tranche.disbursementAmount = 123.45;
        Test.startTest();
        // Call the getPaymentFavourings method
        RelatedPaymentFavouringsController.getPaymentFavourings(loanApp1.Id);
        RelatedPaymentFavouringsController.RelatedPaymentFavouringsWrapper wrapper = RelatedPaymentFavouringsController.getPaymentFavourings(loanApp2.Id); 
        wrapper.tranchePymntLst[0].Loan_Application__c = loanApp2.Id;
        wrapper.tranchePymntLst[0].Net_Amount__c = 123.45;
        RelatedPaymentFavouringsController.savePaymentFavouring(wrapper.tranchePymntLst[0], loanApp2.Product__c, new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>{tranche}, loanApp2.Id, 'insert', 12.34);
        RelatedPaymentFavouringsController.savePaymentFavouring(wrapper.tranchePymntLst[0], loanApp2.Product__c, new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>{tranche}, loanApp2.Id, 'update', 12.34);
        RelatedPaymentFavouringsController.validationForTrancheSequence2(pf.Id,new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>{tranche},loanApp2.Id,12.34,'Test',wrapper.tranchePymntLst[0]);
        try{
            RelatedPaymentFavouringsController.checkDeviationRules(loanApp2.Id);  
        }Catch(Exception e){
            
        }

        Test.stopTest();
    }
    
    @IsTest
    static void testGetPaymentFavourings() {
        // Create test data
        Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 12.34,
            Disbursed__c = false);
        Database.SaveResult sr1 = Database.insert(tr);
        String trancheId = sr1.getId();
        
        IFSC_Master__c ifscMaster = new IFSC_Master__c (Name = 'Test IFSC', ifsc__c = 'TEST01234');
        insert ifscMaster;

        Location_Master__c locMaster = new Location_Master__c(Name = '441601', State__c = 'MAHARASHTRA');
        insert locMaster;
        
        Id AccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account account = new Account (RecordTypeId = AccRecordTypeId, Account_Name__c = 'Account Test', 
                                Name = 'Account Test', Bank_Name__c = 'Test Bank LoanApp Acc', 
                                IFSC_Code__c = 'TEST01234', Pincode__c = locMaster.Id);
        insert account;
        
        //Dealer_Master__c dealMaster = new Dealer_Master__c(Name = 'Test DM');
        //insert dealMaster;

        Id GMRecordTypeIdpf = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Generic_Master__c genericMasterpf = new Generic_Master__c(RecordTypeId = GMRecordTypeIdpf, Bank_Name__c  = 'Test Bank', Type__c = 'CSD');
        insert genericMasterpf;
        
        Id GMRecordTypeIdbm = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Bank Master').getRecordTypeId();
        Generic_Master__c genericMasterbm = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test LoanApp Bank');
        insert genericMasterbm;
       
        Generic_Master__c genericMasterbm1 = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test Bank');
        insert genericMasterbm1;
		List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loanApp1 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, 
            Total_Charges__c = 2500, Dealer_Master__c = account.Id, Branch_Master__c = account.Id,
            Promo_Code__c = genericMasterpf.Id);
         loanApps.add(loanApp1);
        
        Loan_Application__c loanApp2 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 2', Product__c = '10303', Loan_Amount__c = 10000, 
            Dealer_Master__c = account.Id, Branch_Master__c = account.Id, Promo_Code__c = genericMasterbm.Id);
         loanApps.add(loanApp2);
        insert loanApps;
        
        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId();
        Payment__c bt = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Tranche__c = trancheId,
            Inactive__c = false,
            Loan_Application__c = loanApp1.Id);
        Database.SaveResult sr2 = Database.insert(bt);
        String balTraId = sr2.getId();
        
        Id PaymentRecordTypeId3 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Payment__c pf = new Payment__c(
            RecordTypeId = PaymentRecordTypeId3, 
            Name__c = 'Test Payment', 
            Net_Amount__c = 123.45,
            Tranche__c = trancheId,
            Loan_Application__c = loanApp2.Id,
            Inactive__c = false);
        Database.SaveResult sr3 = Database.insert(pf);
        String payFavId = sr3.getId();
   Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            					Loan__c = loanApp2.Id,Vehicle_Usage__c='Personal'),false);
        collat.HPN_With_Financiers_Name__c = 'Other HPN';
        insert collat;
        // Populate the required fields and other necessary fields for the loan application
        // Set the loanAppRecId to the Id of the loan application record

        Test.startTest();
        // Call the getPaymentFavourings method
        RelatedPaymentFavouringsController.getPaymentFavourings(loanApp1.Id);
        RelatedPaymentFavouringsController.RelatedPaymentFavouringsWrapper wrapper = RelatedPaymentFavouringsController.getPaymentFavourings(loanApp2.Id);    
      //  RelatedPaymentFavouringsController.savePaymentFavouring(wrapper.tranchePymntLst[0], loanApp2.Product__c, new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>(), loanApp2.Id, 'insert', 12.34);
        try{
           // RelatedPaymentFavouringsController.checkDeviationRules(loanApp2.Id);  
        }Catch(Exception e){
            
        }

        Test.stopTest();
    }

    @isTest
    static void testGetSubProductName() {

        Test.startTest();
        // Call the getSubProductName method
        String result = RelatedPaymentFavouringsController.getSubProductName('10203');
        RelatedPaymentFavouringsController.getCurrentUserDetails();
        Test.stopTest();
        
        // Perform assertions to verify the expected result
        System.assertEquals('Cash on Wheels', result, 'Sub Product Name should match the expected value');
    }
    
    @isTest
    static void testGetPaymentFavouring() {
        //Create test data
        Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 12.34);
        Database.SaveResult sr1 = Database.insert(tr);
        String trancheId = sr1.getId();
        
        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId();
        Payment__c payment = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Tranche__c = trancheId,
            Inactive__c = false);
        Database.SaveResult sr2 = Database.insert(payment);
        String paymentId = sr2.getId();
       
        Test.startTest();
        // Call the testGetPaymentFavouring method
        Payment__c result = RelatedPaymentFavouringsController.getPaymentFavouring(paymentId);
        Test.stopTest();
        
        // Perform assertions to verify the expected result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('Test Payment', result.Name__c);

        // Clean up test data
        delete payment;
        delete tr;
    }

    @isTest
    static void testFetchDefaultRecordForBank() {
        
        //Create test data
        Id GMRecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('RTO').getRecordTypeId();
        Generic_Master__c genericMaster = new Generic_Master__c(RecordTypeId = GMRecordTypeId, Bank_Name__c  = 'Test Bank');
        insert genericMaster;

        String GMBankName = genericMaster.Bank_Name__c;
        Generic_Master__c fetchedGM = [Select id, RecordTypeId, Bank_Name__c from Generic_Master__c where Bank_Name__c=:GMBankName and RecordTypeId=:GMRecordTypeId];
        String recordId = fetchedGM.Id;
        
        Test.startTest();
        // Call the fetchDefaultRecordForBank method
        Generic_Master__c result1 = RelatedPaymentFavouringsController.fetchDefaultRecordForBank(recordId);
        Generic_Master__c result2 = RelatedPaymentFavouringsController.fetchDefaultRecordForBank('2esdw');
        //RelatedPaymentFavouringsController.fetchDefaultRecordForBank('122');
        //System.debug('Result3: '+result3);
        Test.stopTest();
        
        // Perform assertions to verify the expected result
        System.assertNotEquals(null, result1, 'Result should not be null as bank record exists');
        System.assertEquals(null, result2, 'Result should be null as bank record exists'); 
        //System.assertEquals('System.NullPointerException: Attempt to de-reference a null object', result3); 
    
        // Clean up test data
        delete fetchedGM;
    }

    @isTest
    static void testValidateIFSCWithBank() {

        // Create test data 
        IFSC_Master__c ifscMaster = new IFSC_Master__c (Name = 'Test IFSC', ifsc__c = 'TEST01234');
        insert ifscMaster;
        
        String masterIfsc = ifscMaster.ifsc__c;
        IFSC_Master__c fetchIfsc = [Select id, ifsc__c from IFSC_Master__c where ifsc__c=:masterIfsc];
        String ifsc = fetchIfsc.ifsc__c;
        
        Test.startTest();
        // Call the validateIFSCWithBank method
        IFSC_Master__c result1 = RelatedPaymentFavouringsController.validateIFSCWithBank(ifscMaster.ifsc__c);
        IFSC_Master__c result2 = RelatedPaymentFavouringsController.validateIFSCWithBank(null);
        Test.stopTest();
        
        // Perform assertions to verify the expected result
        System.assertNotEquals(null, result1, 'Result should not be null as one IFSC record exists');        
        System.assertEquals(null, result2, 'Result should be null as bank record exists');      
        
        // Clean up test data
        delete fetchIfsc;
    }

    @isTest
    static void testUpdatePaymentFavouring() {

        //Create test data
        Payment__c payment = new Payment__c(Inactive__c = false);
        insert payment;
        
        // Call the method to update the Payment record
        Test.startTest();
        Id updatedPaymentId = RelatedPaymentFavouringsController.updatePaymentFavouring(payment.Id, 'delete');
        Test.stopTest();
        
        // Retrieve the updated Payment record
        Payment__c updatedPayment = [SELECT Id, Inactive__c FROM Payment__c WHERE Id = :updatedPaymentId];
        
        // Perform assertions to verify the expected result
        System.assertEquals(true, updatedPayment.Inactive__c);

        // Clean up test data
        delete payment;
    }

    @isTest
    static void testGetPaymentFavList2() {
        
        //Create test data
        Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 12.34);
        Database.SaveResult sr1 = Database.insert(tr);
        String trancheId = sr1.getId();

        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c la = new Loan_Application__c(Customer_Name__c = 'Test Customer');
        Database.SaveResult sr3 = Database.insert(la);
        String loanAppId = sr3.getId();

        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId();
        Payment__c payment = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Tranche__c = trancheId,
            Inactive__c = false,
            Loan_Application__c = loanAppId);
        Database.SaveResult sr2 = Database.insert(payment);
        String paymentId = sr2.getId();

        // Call the method to retrieve the list of Payment records
        Test.startTest();
        List<Payment__c> paymentList = RelatedPaymentFavouringsController.getPaymentFavList2(trancheId, loanAppId, 'Balance Transfer', false, tr.Tranche_Number__c);
        Test.stopTest();
        
        // Perform assertions on the returned list of Payment records
        System.assertEquals(1, paymentList.size());
        System.assertEquals('Test Payment', paymentList[0].Name__c);

        // Clean up test data
        delete payment;
        delete tr;
        delete la;
    }

    @isTest
    static void testGetPaymentFavourin3() {
        
        //Create test data
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c la = new Loan_Application__c(Customer_Name__c = 'Test Customer');
        Database.SaveResult sr3 = Database.insert(la);
        String loanAppId = sr3.getId();

        Id PaymentRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId, 
            Name__c = 'Test Payment', 
            Net_Amount__c = 123.45,
            Loan_Application__c = loanAppId);
        Database.SaveResult sr = Database.insert(tr);
        
        // Call the method to retrieve the list of Payment records
        Test.startTest();
        List<Payment__c> paymentList = RelatedPaymentFavouringsController.getPaymentFavourin3(loanAppId);
        RelatedPaymentFavouringsController.getNonChequePaymentFavList(loanAppId, 'Payment Favouring');
        RelatedPaymentFavouringsController.getChequePaymentFavList(loanAppId, 'Payment Favouring');
        Test.stopTest();
        
        // Perform assertions on the returned list of Payment records
        System.assertEquals(1, paymentList.size());
        System.assertEquals(123.45, paymentList[0].Net_Amount__c);

        // Clean up test data
        delete tr;
        delete la;
    }

    @isTest
    static void testGetPaymentFavList4() {
        
        //Create test data
        Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 12.34);
        Database.SaveResult sr1 = Database.insert(tr);
        String trancheId = sr1.getId();

        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c la = new Loan_Application__c(Customer_Name__c = 'Test Customer');
        Database.SaveResult sr3 = Database.insert(la);
        String loanAppId = sr3.getId();

        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId();
        Payment__c payment = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Tranche__c = trancheId,
            Inactive__c = false,
            Loan_Application__c = loanAppId);
        Database.SaveResult sr2 = Database.insert(payment);
        String paymentId = sr2.getId();
        
        // Call the method to retrieve the list of Payment records
        Test.startTest();
        List<Payment__c> paymentList = RelatedPaymentFavouringsController.getPaymentFavList4(trancheId, loanAppId, 'Balance Transfer', false);
        Test.stopTest();
        
        // Perform assertions on the returned list of Payment records
        System.assertEquals(1, paymentList.size());
        System.assertEquals('Test Payment', paymentList[0].Name__c);

        // Clean up test data
        delete payment;
        delete tr;
        delete la;
    }

    /*@isTest
    static void testSavePaymentFavouring() {
        // Create test data or use existing data to set up the scenario
        
        // Call the method to save the Payment record
        Test.startTest();
        Payment__c payment = new Payment__c();
        // Set required fields and any other necessary fields for the test
        Id savedPaymentId = RelatedPaymentFavouringsController.savePaymentFavouring(payment, 'loanType', new List<TrancheOptionsWrapper>(), 'loanApplId', 'context', 1.0);
        Test.stopTest();
        
        // Retrieve the saved Payment record
        Payment__c savedPayment = [SELECT Id FROM Payment__c WHERE Id = :savedPaymentId];
        
        // Perform assertions on the saved Payment record
        // Assert.assertNotNull(savedPayment);
        // Assert.assertEquals(expectedValues,

    }*/

    @isTest
    static void testMainMethod() {
        
        Payment__c tranche = [SELECT id, Tranche_Number__c, Tranche__c, Tranche__r.Tranche_Number__c from Payment__c WHERE Tranche_Number__c = 120 LIMIT 1];
        system.assertEquals(true,tranche != NULL);
        system.assertEquals(true,tranche.Tranche_Number__c == 120);
        Id PaymentRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        
        Payment__c paymentRec = new Payment__c(RecordTypeId = PaymentRecordTypeId, Net_Amount__c = 1000, Tranche__c = tranche.Id);
        insert paymentRec;
        
        List<Payment__c> paymentFavList = new List<Payment__c>();
        Payment__c paymentFav1 = new Payment__c(RecordTypeId = PaymentRecordTypeId, Net_Amount__c = 500, Tranche__c = tranche.Id);
        Payment__c paymentFav2 = new Payment__c(RecordTypeId = PaymentRecordTypeId, Net_Amount__c = 300 );
        paymentFavList.add(paymentFav1);
        paymentFavList.add(paymentFav2);
        insert paymentFavList;
        
        
        List<Payment__c> lstPayFavLst = [Select Id, Tranche__c, Tranche__r.Tranche_Number__c, Net_Amount__c from Payment__c where Id in: paymentFavList and Tranche__c != NULL];
        
        List<RelatedPaymentFavouringsController.TrancheOptionsWrapper> tranchOptionLst = new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>();
        RelatedPaymentFavouringsController.TrancheOptionsWrapper trancheOp1 = new RelatedPaymentFavouringsController.TrancheOptionsWrapper ();
            trancheOp1.label = 'Label 1';
            trancheOp1.value = 'Value 1';
            trancheOp1.trancheNumber = '120';
            trancheOp1.disbursementAmount = 200;
        tranchOptionLst.add(trancheOp1);
        
        // Test the main method
        Test.startTest();
        RelatedPaymentFavouringsController.main(lstPayFavLst, tranchOptionLst, paymentRec, tranche.Tranche_Number__c, 1.0);
        Test.stopTest();
    }
    
    @isTest
    static void testMain2Method() {
        // Create test data
        Id PaymentRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Payment__c paymentRec = new Payment__c(RecordTypeId = PaymentRecordTypeId);
        String loanApplcntionId = 'Test Loan';
        Decimal netAmount = 1000;
        Decimal currTotalAmt = 500;
        String context1 = 'insert';
        String context2 = 'update';
        
        // Test the main2 method
        Test.startTest();
        RelatedPaymentFavouringsController.main2(paymentRec, loanApplcntionId, netAmount, currTotalAmt, context1);
        RelatedPaymentFavouringsController.main2(paymentRec, loanApplcntionId, netAmount, currTotalAmt, context2);
        Test.stopTest();
    }
    
    @isTest
    static void testInsUpdateForFullMethod() {
        // Create test data
        Id PaymentRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        List<Payment__c> paymentFavList = new List<Payment__c>();
        Payment__c paymentFav1 = new Payment__c(RecordTypeId = PaymentRecordTypeId, Net_Amount__c = 500);
        Payment__c paymentFav2 = new Payment__c(RecordTypeId = PaymentRecordTypeId, Net_Amount__c = 300);
        paymentFavList.add(paymentFav1);
        paymentFavList.add(paymentFav2);
        insert paymentFavList;
        Decimal netAmount = 1000;
        Decimal currTotalAmt = 500;
        
        // Test the insUpdateForFull method
        Test.startTest();
        try{
            RelatedPaymentFavouringsController.insUpdateForFull(paymentFavList, netAmount, currTotalAmt);
            System.assert(false, 'Expected an exception.');
        } catch(Exception e) {
            System.debug('AuraHandledException: ' +e.getMessage());
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGetMapOfTrancheNumbToBisbursementAmt() {
        
        // Create test data
        List<RelatedPaymentFavouringsController.TrancheOptionsWrapper> tranchOptions = new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>();
        RelatedPaymentFavouringsController.TrancheOptionsWrapper tranche1 = new RelatedPaymentFavouringsController.TrancheOptionsWrapper();
        tranche1.trancheNumber = '124';
        tranche1.disbursementAmount = 2344;
        tranchOptions.add(tranche1);
        
        RelatedPaymentFavouringsController.TrancheOptionsWrapper tranche2 = new RelatedPaymentFavouringsController.TrancheOptionsWrapper();
        tranche2.trancheNumber = '124';
        tranche2.disbursementAmount = 2346;
        tranchOptions.add(tranche2);
        
        // Populate tranchOptions with test data
        
        // Test the getMapOfTrancheNumbToBisbursementAmt method
        Test.startTest();
        Map<String, Decimal> result = RelatedPaymentFavouringsController.getMapOfTrancheNumbToBisbursementAmt(tranchOptions);
        Test.stopTest();
        
        // Add assertions here to verify the expected behavior
    }
    
    @isTest
    static void testGetMapOfTranchNumToTotalNetAmt() {
        // Create test data
        Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 12.34);
        insert tr;

        Id PaymentRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        List<Payment__c> paymentFavList = new List<Payment__c>();
        Payment__c paymentFav1 = new Payment__c(
            RecordTypeId = PaymentRecordTypeId, Net_Amount__c = 500,Tranche__c = tr.Id);
        Payment__c paymentFav2 = new Payment__c(
            RecordTypeId = PaymentRecordTypeId, Net_Amount__c = 300);
        paymentFavList.add(paymentFav1);
        paymentFavList.add(paymentFav2);
        insert paymentFavList;
        
        // Test the getMapOfTranchNumToTotalNetAmt method
        Test.startTest();
        Map<String, Decimal> result = RelatedPaymentFavouringsController.getMapOfTranchNumToTotalNetAmt(paymentFavList);
        Test.stopTest();
        
        // Perform assertions on the returned list of Payment records
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetPaymentFavList() {
        // Create test data
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c la = new Loan_Application__c(Customer_Name__c = 'Test Customer');
        Database.SaveResult sr3 = Database.insert(la);
        String loanAppId = sr3.getId();

        Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 12.34,
            Inactive__c = false,
            Loan_Application__c = loanAppId);
        Database.SaveResult sr1 = Database.insert(tr);
        String trancheId = sr1.getId();

        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId();
        Payment__c payment = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Tranche__c = trancheId,
            Inactive__c = false,
            Net_Amount__c = 100,
            Loan_Application__c = loanAppId);
        Database.SaveResult sr2 = Database.insert(payment);
        String paymentId = sr2.getId();

        Boolean isInactive = false;
        Decimal tranchNumber = 12.34;
        
        // Test the getPaymentFavList method
        Test.startTest();
        RelatedPaymentFavouringsController.getPaymentFavList(loanAppId, 'Tranche', isInactive, tranchNumber);
        RelatedPaymentFavouringsController.getPaymentFavList(loanAppId, 'Balance Transfer', isInactive, tranchNumber);
        Test.stopTest();
    }
    
    @isTest
    static void testValidationForTrancheSequence2() {
        // Create test data
        String paymentFavId = 'Test Payment Fav';
        List<RelatedPaymentFavouringsController.TrancheOptionsWrapper> tranchOptions = new List<RelatedPaymentFavouringsController.TrancheOptionsWrapper>();
        String loanApplId = 'Test Loan';
        Decimal tranchNumber = 1;
        String errorMessage = 'Test Error Message';
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c la = new Loan_Application__c(Customer_Name__c = 'Test Customer');
        insert la;
       Id PaymentRecordTypeId1 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c tr = new Payment__c(
            RecordTypeId = PaymentRecordTypeId1, 
            Name__c = 'Test Tranche', 
            Tranche_Number__c = 1,
            Disbursed__c = false);
        Database.SaveResult sr1 = Database.insert(tr);
        String trancheId = sr1.getId();
        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Payment__c paymentRec = new Payment__c(Net_Amount__c = 10000,Tranche__c = trancheId,Loan_Application__c = la.Id,Inactive__c = false,RecordTypeId = PaymentRecordTypeId2);
        system.debug('@@paymentRec'+paymentRec);
        insert paymentRec;
        RelatedPaymentFavouringsController.TrancheOptionsWrapper tranche1 = new RelatedPaymentFavouringsController.TrancheOptionsWrapper();
        tranche1.trancheNumber = '1';
        tranche1.disbursementAmount = 2344;
        tranchOptions.add(tranche1);
        // Test the validationForTrancheSequence2 method
        Test.startTest();
        try{
            RelatedPaymentFavouringsController.validationForTrancheSequence2(paymentFavId, tranchOptions, la.Id, tranchNumber, errorMessage, paymentRec);
        }
        Catch(Exception e){
        
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testGetActivePaymentFavouringRule() {

        // Test the method
        Test.startTest();
        Map<String, Payment_Favouring_Rule__mdt> activeRules = RelatedPaymentFavouringsController.getActivePaymentFavouringRule();
        Test.stopTest();

        // Verify the results
        System.assertEquals(4, activeRules.size());
    }

    @IsTest
    static void testGetDeviations() {
        // Test data setup
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loanApp = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, 
            Total_Charges__c = 2500, RecordTypeId = LoanAppRecordTypeId);
        insert loanApp;

        Deviation__c deviation = new Deviation__c(
            Deviation_Type__c = 'Type 1',
            Active__c = true,
            Loan_Application__c = loanApp.Id
        );
        insert deviation;

        // Test the method
        Test.startTest();
        Map<String, Deviation__c> deviations = RelatedPaymentFavouringsController.getDeviations(loanApp.Id);
        Test.stopTest();

        // Verify the results
        System.assertEquals(1, deviations.size());
    }

    @IsTest
    static void testGetCasaDetails() {
        // Test data setup
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loan = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, 
            Total_Charges__c = 2500, RecordTypeId = LoanAppRecordTypeId);
        insert loan;
                   


        Id applRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Applicant__c applicant = new Applicant__c(
            Loan__c = loan.Id,
            RecordTypeId = applRecordTypeId
        );
        insert applicant;
        Test.startTest();
		RelatedPaymentFavouringsController.getCasaDetails(loan.Id);
        Id bankAccRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CBS').getRecordTypeId();
        Bank_Account_Records__c bankRecord = new Bank_Account_Records__c(
            IFSC_Code__c = 'IFSC001',
            Bank_Name__c = 'Bank 1',
            Account_Type__c = 'CASA',
            RecordTypeId = bankAccRecordTypeId,
            Applicant__c = applicant.Id
        );
        insert bankRecord;

        // Test the method
        
        Bank_Account_Records__c result = RelatedPaymentFavouringsController.getCasaDetails(loan.Id);
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testRelatedPaymentFavouringsWrapper1(){
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loan = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, 
            Total_Charges__c = 2500, RecordTypeId = LoanAppRecordTypeId);
        insert loan;
         Assignment__c assignment = new Assignment__c();
        assignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - KYC').getRecordTypeId();
        assignment.Loan_Application__c = loan.Id;
        insert assignment;
        RelatedPaymentFavouringsController.getPaymentFavourings(assignment.Id);
        try{
            RelatedPaymentFavouringsController.fetchDefaultRecordForBank(null);
        	RelatedPaymentFavouringsController.validateIFSCWithBank(null);
        }
        Catch(Exception ex){
            
        }
        
    }

    @IsTest
    static void testGetCasaDetails2() {
        // Test data setup
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loan = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, 
            Total_Charges__c = 2500, RecordTypeId = LoanAppRecordTypeId);
        insert loan;

        Id applRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('BO').getRecordTypeId();
        Applicant__c applicant = new Applicant__c(
            Loan__c = loan.Id,
            RecordTypeId = applRecordTypeId
        );
        insert applicant;

        Id bankAccRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CBS').getRecordTypeId();
        Bank_Account_Records__c bankRecord = new Bank_Account_Records__c(
            IFSC_Code__c = 'IFSC001',
            Bank_Name__c = 'Bank 1',
            Account_Type__c = 'CASA',
            RecordTypeId = bankAccRecordTypeId,
            Applicant__c = applicant.Id
        );
        insert bankRecord;

        // Test the method
        Test.startTest();
        /*try{
            Bank_Account_Records__c result = RelatedPaymentFavouringsController.getCasaDetails(loan.Id);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', RelatedPaymentFavouringsController.getCasaDetails(loan.Id));
        }*/
        try{
            String.valueOf(RelatedPaymentFavouringsController.getCasaDetails(loan.Id));    
            System.assert(false, 'Expected an exception.');
        } catch(Exception e) {
            System.debug('AuraHandledException: ' +e.getMessage());
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void testInternalBTValidation(){
        Test.startTest();
        Loan_Application__c loan = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, 
            Total_Charges__c = 2500);
        insert loan;
        
        
        Payment__c bt = new Payment__c(
            RecordTypeId =  Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId(),
            Name__c = 'Test Payment',
            Inactive__c = false,
            BT_Loan_Status__c = 'Fore Closure Refinance',
            Loan_Number__c='979797',
            Loan_Application__c = loan.Id);
        
        Payment__c pf = new Payment__c(
            RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId(), 
            Name__c = 'Test Payment', 
            Net_Amount__c = 123.45,
            Payment_Recipient__c = 'Customer',
            Account_Number__c = '979796',
            Loan_Application__c = loan.Id,
            Inactive__c = false);
        List<Payment__c> paymentToInsert = new List<Payment__c>{bt, pf};
        insert(paymentToInsert);
        List<Payment__c> payments = [SELECT Id, Loan_Application__c FROM Payment__c WHERE RecordType.Name='Payment Favouring'];
        List<String> validations = RelatedPaymentFavouringsController.internalBTValidation(payments[0].Loan_Application__c);
        System.assertEquals(validations.size()!=0, true,'Success');
        Test.stopTest();

    }
}