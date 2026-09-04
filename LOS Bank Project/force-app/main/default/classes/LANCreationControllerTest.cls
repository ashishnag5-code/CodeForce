@isTest
public class LANCreationControllerTest {
    @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12346',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id
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
            Branch_Master__c = accInstance.Id
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Document_Master__c docMasterRecord1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Name__c = 'EKYC PDF'
        ),true);
        
        Document_Checklist__c docCheckRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Document_Master__c = docMasterRecord1.Id,
            Applicant__c = appl.Id
        ),true);
        Document_Master__c docMasterRecord2 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Name__c = 'Disbursement Voucher',Name='AUWheels0072'
        ),true);
        Document_Checklist__c docCheckRecord2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Document_Master__c = docMasterRecord2.Id,
            Loan_Application__c = loanApp.Id
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
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',Collateral_Id__c = '12324353',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'TestCat',Collateral_Name__c ='10108',RecordTypeId = GlobalConstants.newColRecordTypeId
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
            Address_Type__c='Current',
            Source_Type__c = 'CBS',
            Type__c='Bungalow'
        ),true);
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'LAN Creation ',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CBSLoanAccountCreationService',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
    }
    @isTest
    public static void getLoanApplicationDetailsTest(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c WHERE Application_Number__c = 'AP-12345'];
        LANCreationController.getLoanApplicationDetails(loanAppl.Id);
        LANCreationController.sendSIotification(loanAppl.Id);
    }
    @isTest
    public static void getLoanApplicationDetailsExceptionTest(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c WHERE Application_Number__c = 'AP-12346'];
        try{
            LANCreationController.getLoanApplicationDetails(loanAppl.Id);
        }
        catch (Exception e) {
        }
    }
    @isTest
    public static void callLANCreationCalloutTest(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c WHERE Application_Number__c = 'AP-12346'];
        
        test.setMock(HttpCalloutMock.class, new LANServiceMock());
        try{
            LANCreationController.checkIfLANAlreadyExists(loanAppl.Id);
            Test.startTest();
            LANCreationController.callLANCreationCallout(loanAppl.Id,'reason');
            Test.stopTest();
        }
        catch(Exception e){
            
        }
        
    }
    @isTest
    public static void callLANCreationCalloutTest2(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c WHERE Application_Number__c = 'AP-12345'];
        test.setMock(HttpCalloutMock.class, new LANServiceMock());
        try{
            LANCreationController.checkIfLANAlreadyExists(loanAppl.Id);
            Test.startTest();  
            LANCreationController.callLANCreationCallout(loanAppl.Id,'reason');
            Test.stopTest();
        }
        catch(Exception e){
            
        } 
    }
        @isTest
    public static void callLANCreationCalloutTest3(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c WHERE Application_Number__c = 'AP-12345'];
        test.setMock(HttpCalloutMock.class, new LANServiceMock());
        try{
            LANCreationController.checkIfLANAlreadyExists(loanAppl.Id);
            Test.startTest();  
            LANCreationController.callLANCreationCallout(loanAppl.Id,'CollateralCreation');
            Test.stopTest();
        }
        catch(Exception e){
            
        } 
    }
            @isTest
    public static void callLANCreationCalloutTest4(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c WHERE Application_Number__c = 'AP-12345'];
        test.setMock(HttpCalloutMock.class, new LANServiceMock());
        try{
            LANCreationController.checkIfLANAlreadyExists(loanAppl.Id);
            Test.startTest();  
            LANCreationController.callLANCreationCallout(loanAppl.Id,'CollateralLinkage');
            Test.stopTest();
        }
        catch(Exception e){
            
        } 
    }
                @isTest
    public static void callLANCreationCalloutTest5(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c WHERE Application_Number__c = 'AP-12345'];
        test.setMock(HttpCalloutMock.class, new LANServiceMock());
        try{
            LANCreationController.checkIfLANAlreadyExists(loanAppl.Id);
            Test.startTest();  
            LANCreationController.callLANCreationCallout(loanAppl.Id,'Incomplete');
            Test.stopTest();
        }
        catch(Exception e){
            
        } 
    }
    @isTest
    public static void getVisibleFieldsForLoanDetailsTest(){
        LANCreationController.getVisibleFieldsForLoanDetails('Assessed No Documented','Credit','System Administrator');
    }
    @isTest
    public static void generateDoTest(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c WHERE Application_Number__c = 'AP-12346'];
        try{
            LANCreationController.generateDisbursalVoucher(loanAppl.Id);
            
        }
        catch (Exception e) {
        }
    }
    @isTest
    public static void lanAlreadyExistTest(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c WHERE Application_Number__c = 'AP-12346'];
        try{
            LANCreationController.checkIfLANAlreadyExists(loanAppl.Id);
            
        }
        catch (Exception e) {
        }
    }
    
}