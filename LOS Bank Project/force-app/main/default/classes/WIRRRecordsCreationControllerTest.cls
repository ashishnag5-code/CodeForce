@isTest
public class WIRRRecordsCreationControllerTest {
    
    @testSetup static void setup() {  
        
        // Test data setup
        Profile prof = [select Id,Name from profile where name like '%Credit%'];

        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            Account bmAcc = (Account)TestFactory.createSObject(new Account(IFSC_Code__c = 'TEST01234', 
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId(), 
                    Account_Name__c = 'Account Test', Name = 'Account Test', Bank_Name__c = 'Test Bank LoanApp Acc'),true);

            Account branch = (Account)TestFactory.createSObject(
                new Account(IFSC_Code__c = 'TEST01234', 
                    RecordTypeId = Utility.getRecordTypeId( SObjectType.Account.getSObjectType(), 'Branch' ), 
                    Account_Name__c = 'Pratap Nagar', Name = 'Pratap Nagar'
                )
            ,true);
            
            Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                    Customer_Name__c = 'Test Customer 1', Stage__c = 'Pricing', Product__c = '10301', Branch_Master__c = bmAcc.Id, 
                    RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId(),
                    ROI__c = 12.4, Total_Loan_Amount__c = 10000, Disbursed_Tranche__c = 5),true);
        
            Loan_Application__c commercialLoanApp = (Loan_Application__c)TestFactory.createSObject(
                new Loan_Application__c(
                    Customer_Name__c = 'Test Customer 1', Stage__c = 'Pricing', Product__c = '10204', Branch_Master__c = branch.Id, 
                    RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), GlobalConstants.COMMERCIALVEHICLE ),
                    ROI__c = 10, Total_Loan_Amount__c = 10000, Disbursed_Tranche__c = 5
                )
            ,true);
            
            Loan_Application__c ceLoanApp = (Loan_Application__c)TestFactory.createSObject(
                new Loan_Application__c(
                    Customer_Name__c = 'Test Customer 1', Stage__c = 'Pricing', Product__c = '10403', Branch_Master__c = branch.Id, Collateral_Type__c = '10103',
                    RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), GlobalConstants.CONSTRUCTIONEQUIP ),
                    ROI__c = 10, Total_Loan_Amount__c = 20000, Disbursed_Tranche__c = 5
                )
            ,true);

            Payment__c paym = (Payment__c)TestFactory.createSObject(new Payment__c(
                    RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId(), 
                    Name__c = 'Test Payment 1', Tranche_Number__c = 5, Disbursed__c = false, Loan_Application__c = loanApp.Id, 
           		 	Disbursement_Amount__c = 200),true);
            
            User usr = (User)TestFactory.createSObject(
                new User(firstName = 'test1', lastName = 'test2', profileId = prof.id,
                username = 'test'+UserInfo.getOrganizationId()+'@test.com', 
                email = 'test@test.com', Branch_Code__c  = '2103',Product_Accessible__c = 'All New'),true);
            
            DateTime dt = Datetime.now();
            String currentYear = dt.format('YYYY');
            String currentMonth = dt.format('MMM');
            WIRR__c wirr = (WIRR__c)TestFactory.createSObject(new WIRR__c(
                    Branch__c = bmAcc.Id, User__c = usr.Id, Record_Key__c = bmAcc.Id+'_' + currentMonth + '_' +currentYear ),true);
        }
    }
    
    @isTest
    static void testhandleFullDisbursedWIRRRecordUpsertion() {
        
        Loan_Application__c loanApp = [SELECT Id, Product__c, Branch_Master__c, ROI__c, OwnerId, Total_Loan_Amount__c, Collateral_Type__c FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.TWOWHEELER LIMIT 1];
        Set<Loan_Application__c> loanAppSet = new Set<Loan_Application__c>{loanApp};
        
        Test.startTest();
        // Call the handleFullDisbursedWIRRRecordUpsertion method
        WIRRRecordsCreationController.handleFullDisbursedWIRRRecordUpsertion(loanAppSet);       
        Test.stopTest();
        
    }
    
    @isTest
    static void testhandleTrancheWIRRRecordUpsertion(){
        Loan_Application__c loanApp = [SELECT Id, Product__c, Branch_Master__c, ROI__c, OwnerId, Total_Loan_Amount__c, Collateral_Type__c FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.TWOWHEELER LIMIT 1];
        Set<Id> loanAppSet = new Set<Id>{loanApp.Id};
        
        Test.startTest();
        // Call the handleTrancheWIRRRecordUpsertion method
        WIRRRecordsCreationController.handleTrancheWIRRRecordUpsertion(loanAppSet);       
        Test.stopTest();

    }

    @isTest static void verifyCommercialWirrCalculation(){
        Test.startTest();

        Loan_Application__c loan = [ SELECT Id, Product__c, ROI__c, OwnerId, Branch_Master__c, Collateral_Type__c, Total_Loan_Amount__c FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.COMMERCIALVEHICLE LIMIT 1 ];
        WIRRRecordsCreationController.handleFullDisbursedWIRRRecordUpsertion(
            new Set<Loan_Application__c>{ loan }
        );
        Test.stopTest();

        Decimal wirr = ( loan.Total_Loan_Amount__c * loan.ROI__c ) / loan.Total_Loan_Amount__c;

        for( WIRR__c wirrRecord: [ SELECT Car_Taxi_New_WIRR__c, Record_Key__c FROM WIRR__c WHERE Branch__c =: loan.Branch_Master__c ] ){
            Assert.areEqual( wirr, wirrRecord.Car_Taxi_New_WIRR__c, 'The WIRR calculation for Commercial Vehicle [ key = ' + wirrRecord.Record_Key__c + ' ] is not correct' );
        }
    }

    @isTest static void verifyCommercialCollateralBasedWirrCalculation(){
        Test.startTest();

        Loan_Application__c loan = [ SELECT Id, Product__c, ROI__c, OwnerId, Branch_Master__c, Collateral_Type__c, Total_Loan_Amount__c FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.CONSTRUCTIONEQUIP LIMIT 1 ];
        WIRRRecordsCreationController.handleFullDisbursedWIRRRecordUpsertion(
            new Set<Loan_Application__c>{ loan }
        );
        Test.stopTest();

        Decimal wirr = ( loan.Total_Loan_Amount__c * loan.ROI__c ) / loan.Total_Loan_Amount__c;

        for( WIRR__c wirrRecord: [ SELECT CE_COW_WIRR__c, HCV_COW_WIRR__c, Record_Key__c FROM WIRR__c WHERE Branch__c =: loan.Branch_Master__c ] ){
            Assert.areEqual( wirr, wirrRecord.CE_COW_WIRR__c, 'The WIRR calculation for Construction Equipment Vehicle [ key = ' + wirrRecord.Record_Key__c + ' ] is not correct based on Product' );
            Assert.areEqual( wirr, wirrRecord.HCV_COW_WIRR__c, 'The WIRR calculation for Construction Equipment Vehicle [ key = ' + wirrRecord.Record_Key__c + ' ] is not correct based on Collateral Type' );
        }
        
    }
}