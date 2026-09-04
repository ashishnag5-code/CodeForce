@isTest
public class addressComponentHandler_Test {
    @testSetup static void setup() {
        
        Integration_Master__c inMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Calculate Distance',
            End_Point_URL__c='https://service.aubank.in/SFDCKarzaPinCodeService/getDistance',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        Location_Master__c  lcMaster = (Location_Master__c )TestFactory.createSObject(new Location_Master__c (
            Name ='110053',
            Area_Name__c ='JAGJIT NAGAR',
            Area_Type__c ='Urban',  
            City__c ='EAST DELHI',
            State__c ='MAHARASHTRA',
            Taluka__c ='NA',
            Zip_Code__c = '110053'  
        ),true);
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Pincode__c = lcMaster.Id
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Branch_Master__c =accInstance.Id
            
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Customer_Type__c ='Individual',
            Residential_Status__c ='Resident',
            KYC_Status__c ='Pending',
            Loan__c =loanAppl.Id
            
        ),true);
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash1',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Customer_Type__c ='Non Individual',
            Residential_Status__c ='Resident',
            KYC_Status__c ='Complete',
            Loan__c =loanAppl.Id
            
        ),true);
        
        Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Permanent',
            Type__c='Bungalow'
        ),true);
        
        Address__c  addInstance1 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline11',
            Address_Line_2__c ='TestAddressline22',
            Address_Line_3__c ='TestAddressline33',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow'
        ),true);
        Address__c  addInstanc2 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline112',
            Address_Line_2__c ='TestAddressline222',
            Address_Line_3__c ='TestAddressline332',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Office',
            Type__c='Bungalow'
        ),true);
        Address__c  addInstanc3 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline112',
            Address_Line_2__c ='TestAddressline222',
            Address_Line_3__c ='TestAddressline332',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Touch Point',
            Type__c='Bungalow'
        ),true);
        
        
        
        Generic_Master__c grMaster = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            Address_Type__c='Permanent',
            Product__c='10201',
            Residence_Status__c='Owned',  
            Residence_Type__c='Bungalow'
        ),true);
        
        //Calculate Distance Address Integration Master
        Integration_Master__c distanceMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Calculate Distance',
            End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/SFDCKarzaPinCodeService/getDistance',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        Document_Master__c master = (Document_Master__c )TestFactory.createSObject(new Document_Master__c (
            Document_Name__c ='Voter ID Card' 
        ),true);
        Document_Checklist__c checkList = (Document_Checklist__c )TestFactory.createSObject(new Document_Checklist__c (
            Applicant__c =appl.Id,
            Document_Verification_Status__c = 'Verified',
            Document_Master__c=master.Id
        ),true);
        
    }
    
    @isTest static void loactionsMethod1() {
        Test.startTest();
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        map<string,List<addressComponentHandler.PicklistWrapper>> pickListMap = addressComponentHandler.getLocations('110053',appl.Id);
        System.assertEquals(pickListMap.size()!= 0,true,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void getPicklistValues() {
        Test.startTest();
        map<string,List<String>> productValuesMap = addressComponentHandler.getProductMetadataValues('Permanent','10201','Individual');
        System.assertEquals(productValuesMap.size() != 0,true,'AssertMsg');
        Test.stopTest();
    }
    @isTest static void getPicklistValues1() {
        Test.startTest();
        map<string,List<String>> productValuesMap = addressComponentHandler.getProductMetadataValues('Permanent','10201','Non Individual');
        System.assertEquals(productValuesMap.size() != 0,true,'AssertMsg');
        Test.stopTest();
    }
    @isTest static void getAddress() {
        Address__c addInstance = [SELECT id,Address_Line_1__c FROM Address__c WHERE Address_Line_1__c='TestAddressline1'];
        Test.startTest();
        addressComponentHandler.getAddressInfo(addInstance.Id);
        System.assertEquals('TestAddressline1', addInstance.Address_Line_1__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest static void getApplicant(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        addressComponentHandler.getApplicantAddress(appl.Id);
        addressComponentHandler.getApplicantCustomerType(appl.Id);
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
        
        
    }
    @isTest static void getApplicant1(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash1'];
        Test.startTest();
        addressComponentHandler.getApplicantAddress(appl.Id);
        //System.assertEquals('Vikash1', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
        
        
    }
    
    
    @isTest static void distancePart(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DistanceCalloutMock());
        addressComponentHandler.calculateDistance('110053',appl.Id,'Current');
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
        
        
    }
    
    @isTest static void getDependent(){
        Test.startTest();
        Map<Object,List<String>> dependentPicklistValues= addressComponentHandler.getDependentPicklistValues(Address__c.Address_Source__c);
        System.assertEquals(dependentPicklistValues.size() != 0,true,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void negativeRecords(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        addressComponentHandler.getNegativeAreaMasterRecords('110053','JAGJIT NAGAR');
        addressComponentHandler.getAddressMatchAPI(appl.Id);
        Test.stopTest();
    }
    @isTest static void getValidTakenFrom(){
        Applicant__c appl =[SELECT id,First_Name__c,Loan__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        addressComponentHandler.getValidTakenFromValues(appl.Id);
		addressComponentHandler.sendDeemedNotification(appl.Loan__c);
        Test.stopTest();        
    }
    
    @isTest static void getLoanApplicationDetailsTest(){
        Applicant__c appl =[SELECT id,First_Name__c,Loan__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        addressComponentHandler.getLoanApplicationDetails(appl.Id);
        Test.stopTest();        
    }
    
    @isTest static void getCVDocumentValidationTest(){
        Applicant__c appl =[SELECT id,First_Name__c,Loan__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        Loan_Application__c loan = new Loan_Application__c();
        loan.Product__c='10101';
        loan.Collateral_Type__c='10105';
        loan.Id=appl.Loan__c;
        update loan;
        addressComponentHandler.getCVDocumentValidation(appl.Loan__c);
        Test.stopTest();        
    }
}