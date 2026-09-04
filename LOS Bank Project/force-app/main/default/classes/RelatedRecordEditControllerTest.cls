@isTest
public with sharing class RelatedRecordEditControllerTest {
    @testSetup static void makeData(){
        Group grp = (Group)TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ), true ); 
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c = '2103',
            Branch_Queue__c = grp.Id
        ),true);
        
        Loan_Application__c loan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id,
            RecordTypeId = Utility.getRecordTypeId( SOBjectType.Loan_Application__c.getSObjectType(), GlobalConstants.FOURWHEELER )
        ),true);

        Deviation__c  deviation = (Deviation__c)TestFactory.createSObject(
            new Deviation__c(
                Loan_Application__c = loan.Id,
                Active__c  = true,
                Deviation_Type__c  = 'COW-No HPN-Customer'
        ),true);

        MMV_Master__c mmvMaster = (MMV_Master__c )TestFactory.createSObject(new MMV_Master__c (
            Name ='Test',
            Collateral_Type__c = 'Automobile'
        ),true);

        Collateral__c  collateral = (Collateral__c)TestFactory.createSObject(new Collateral__c (
            Loan__c = loan.Id,
            MMV_Master__c = mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10108',
            Deferral_Category__c = 'RC Limit Deferral'
        ),true);

        Document_Master__c docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
           Document_Name__c = 'Registration Certificate',
           Constitiution__c = 'Partnership Firms',
           Individual_NI__c = 'NI'
        ),true);
        
        Document_Checklist__c docCheckRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
           Document_Master__c = docMaster.Id,
           Active__c =true,
           Collateral__c = collateral.Id
        ),true);
    }
    @isTest static void verifyFieldNames(){
        Id checklistId = [ SELECT Id FROM Document_CheckList__c ].Id;

        Test.startTest();
        RelatedRecordEditController.ReturnWrapper result = RelatedRecordEditController.getFieldNames(
            checklistId,
            'NewVehicle',
            'Collateral__c'
        );
        Test.stopTest();

        Assert.isTrue( result.fieldList.size() > 0, 'Field from FieldSet should be returned' );
    }

    @isTest static void verifyRelatedRecords(){
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE REcordType.Name =: GlobalConstants.FOURWHEELER ].Id;

        Test.startTest();
        RelatedRecordEditController.QueryResponseWrapper result = RelatedRecordEditController.getRelatedRecords(
            JSON.serialize(
                new map<String, Object>{
                    'recordId' => loanId,
                    'childAPIName' => 'Deviation__c',
                    'relationshipName' => 'Deviations__r',
                    'whereClause' => 'Archived__c = false',
                    'fields' => 'Department__c,Deviation_Type__c,Details__c,Policy_Value__c,Actual_Value__c,Variance__c,Level__c,Mitigates__c,id',
                    'sortBy' => 'Name',
                    'numberOfRecords' => 10,
                    'sortOrder' => 'ASC',
                    'viewAll' => false
                })
        );

        Test.stopTest();

        Assert.areEqual( 1, result.data.size(), 'Deviation record should have been returned' );
    }


}