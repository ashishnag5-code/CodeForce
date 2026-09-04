@isTest
public with sharing class AUSFCommercialVehicleControllerTest {
    @TestSetup
    static void makeData(){
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 

        Id branchRecordTypeId = Utility.getRecordTypeId( SObjectType.Account.getSObjectType(), 'Branch' );
        Id dealerRecordTypeId = Utility.getRecordTypeId( SObjectType.Account.getSObjectType(), 'Dealer' );

        Account dealerInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount1',
            Account_Code__c = '21051',
            Branch_Queue__c = grp.Id,
            RecordTypeId = dealerRecordTypeId
        ),true);

        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c = '2103',
            Branch_Queue__c = grp.Id,
            RecordTypeId = branchRecordTypeId
        ),true);

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10104',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Customer_Grade__c = 'FTU',
            Vehicle_use__c = 'Commercial',
            Collateral_Type__c = '10108',
            RecordTypeId = Utility.getRecordTypeId(SObjectType.Loan_Application__c.getSObjectType(), 'Commercial Vehicle'),
            Branch_Master__c = accInstance.Id,
            Dealer_Master__c = dealerInstance.Id
        ),true);

        Loan_Application__c tractorLoan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10501',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Vehicle_use__c = 'Commercial',
            Collateral_Type__c = '10109',
            RecordTypeId = Utility.getRecordTypeId(SObjectType.Loan_Application__c.getSObjectType(), 'Tractor'),
            Branch_Master__c = accInstance.Id,
            Dealer_Master__c = dealerInstance.Id
        ),true);

        Scheme_Master__c normalScheme = (Scheme_Master__c )TestFactory.createSObject(new Scheme_Master__c (
            Scheme_Name__c ='Normal',
            Type_of_loan__c ='Used'
        ),true);

        Collateral__c collateral = (Collateral__c)TestFactory.createSObject(
            new Collateral__c(
                Loan__c = loanAppl.Id,
                Body_Type__c = 'Goods Carrier',
                RecordTypeId = GlobalConstants.newColRecordTypeId
            ),
            true
        );

        Collateral__c tractorCollateral = (Collateral__c)TestFactory.createSObject(
            new Collateral__c(
                Loan__c = tractorLoan.Id,
                Body_Type__c = 'Goods Carrier',
                RecordTypeId = GlobalConstants.newColRecordTypeId
            ),
            true
        );

        MMV_Master__c variant = (MMV_Master__c)TestFactory.createSObject(
            new MMV_Master__c(
                Name = Label.BodyFundingMMV,
                RecordTypeId = Utility.getRecordTypeId(SObjectType.MMV_Master__c.getSObjectType(), 'Variant')
            ),
            true
        );

        Depreciated_Grid__c gridMaster = (Depreciated_Grid__c)TestFactory.createSObject(
            new Depreciated_Grid__c(
                LTV_Approved__c = '80',
                Category__c = 'A;B',
                Scheme__c = normalScheme.Id,
                RecordTypeId = Utility.getRecordTypeId(SObjectType.Depreciated_Grid__c.getSObjectType(), 'LTV'),
                Applicable_Products__c = 'All'
            ),
            true
        );
    }

    @isTest static void verifyBodyFundingCapAmount(){

        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1 ].Id;
        Test.startTest();
        Body_Funding_Cap_Master__mdt[] capMaster = AUSFCommercialVehicleController.getBodyFundingCapAmount( loanId, new Collateral__c() );
        Test.stopTest();

        Assert.isNotNull( capMaster, 'Capping Master should be returned if configured' ); //cant be a size check because the records are retrieved from mdt & may not exist
    }

    @isTest static void verifyDepreciatedMaster(){
        Test.startTest();
        Depreciated_Grid__c gridMaster = AUSFCommercialVehicleController.getDepreciatedMaster( new Collateral__c( Vehicle_Category__c = 'A', Vehicle_Usage__c = 'Commercial' ), new Loan_Application__c( Customer_Grade__c = 'FTU', Product__c = '10104' ) );
        Test.stopTest();

        Assert.areEqual( '80', gridMaster.LTV_Approved__c, 'Approved LTV should get returned' );
    }

    @isTest static void verifyParentLoanApplicationForStandaloneBodyLoan(){

        Loan_Application__c parentLoan = [ SELECT Id, Name FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.COMMERCIALVEHICLE ];
        Test.startTest();
        map<String, Object> response = AUSFCommercialVehicleController.validateParentLoan( parentLoan );
        Test.stopTest();

        Loan_Application__c parentLoanRes = (Loan_Application__c)response.get( 'parentLoan' );
        MMV_Master__c[] variant = (MMV_Master__c[])response.get('variant'); 

        Assert.isNotNull( parentLoanRes, 'The details of parent loan should be returned because it\'s a valid Primary Asset Loan for Commercial Vehicle' );
        Assert.areEqual( parentLoan.Name, parentLoanRes.Name, 'Details of Parent Loan [ Name = ' + parentLoan.Name +'] should have been returned' );
        Assert.areEqual( 1, variant.size(), 'Variant should have been returned' );
        Assert.areEqual( Label.BodyFundingMMV, variant[0].Name, 'The Configured Body Funding Variant should have been returned' );
    }

    @isTest static void verifyWithInvalidLoanForStandaloneBodyLoan(){

        Loan_Application__c parentLoan = new Loan_Application__c( Name = 'RAJ0000000007' );
        Test.startTest();
        try {
            AUSFCommercialVehicleController.validateParentLoan( parentLoan );
        } catch (AUSFCommercialVehicleController.AUSFCommercialVehicleException ex) {
            Assert.areEqual( String.format( Label.LoanNumberDoesNotExist, new String[]{ parentLoan.Name } ), ex.getMessage(), 'An exception should be thrown when invalid loan number is passed as Parent loan');
        }
        Test.stopTest();
    }

    @isTest static void verifyParentLoanApplicationForStandaloneImplementLoan(){

        Loan_Application__c parentLoan = [ SELECT Id, Name FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.TRACTOR ];
        Test.startTest();
        map<String, Object> response = AUSFCommercialVehicleController.validateParentLoanTractor( parentLoan );
        Test.stopTest();

        Loan_Application__c parentLoanRes = (Loan_Application__c)response.get( 'parentLoan' );
        MMV_Master__c[] variant = (MMV_Master__c[])response.get('variant'); 

        Assert.isNotNull( parentLoanRes, 'The details of parent loan should be returned because it\'s a valid Primary Asset Loan for Tractor' );
        Assert.areEqual( parentLoan.Name, parentLoanRes.Name, 'Details of Parent Loan [ Name = ' + parentLoan.Name +'] should have been returned' );
        }

    @isTest static void verifyWithInvalidLoanForStandaloneImplementLoan(){

        Loan_Application__c parentLoan = new Loan_Application__c( Name = 'RAJ0000000007' );
        Test.startTest();
        try {
            AUSFCommercialVehicleController.validateParentLoanTractor( parentLoan );
        } catch (AUSFCommercialVehicleController.AUSFCommercialVehicleException ex) {
            Assert.areEqual( String.format( Label.LoanNumberDoesNotExist, new String[]{ parentLoan.Name } ), ex.getMessage(), 'An exception should be thrown when invalid loan number is passed as Parent loan');
        }
        Test.stopTest();
    }
}