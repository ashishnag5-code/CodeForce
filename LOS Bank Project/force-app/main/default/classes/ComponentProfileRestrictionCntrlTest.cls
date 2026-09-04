@isTest
public class ComponentProfileRestrictionCntrlTest {
@testSetup static void setup() {  
    
        Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                                        Application_Number__c = 'AP-12345',Adhar_Card__c = 123456,
                                        Loan_Amount__c = 1000,Product__c='10201'),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                            First_Name__c = 'Vikash',Middle_Name__c = 'Kumar',Last_Name__c = 'Mandal',Loan__c =loanApp.Id,
                            Customer_Name__c='Vikas',Customer_Type__c='Individual'),true);

        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        Opportunity opp = new Opportunity(Name='Opp',CloseDate=System.today().addDays(30),AccountId=branchMaster.Id,StageName='New');
        insert opp;
        Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
                                Loan__c = loanApp.Id,Vehicle_Usage__c='Personal'),true);
        Document_Master__c docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
                                        Name = 'Test Document', Document_Category__c = 'Vehicle Document', 
                                        Document_Sub_Category__c = 'Vehicle Document', Document_ID__c = 'AUWheels0008'),true);
        Document_Checklist__c docChecklist = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
                                            Applicant__c = appl.Id, Collateral__c = collat.Id, Document_Master__c = docMaster.Id, 
                                            Loan_Application__c =loanApp.Id),true);
        
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Disbursement Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDC'           
        ),true);
        
        Integration_Master__c integrationMast = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'EMI Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '123454',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDCf'           
        ),true);
        
        Integration_Checklist__c intChild = new Integration_Checklist__c();
        intChild.Response__c  = '{ "TransactionStatus" : {"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {},    "ValidationErrors" : [ null ]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChild.Loan_Application__c  = loanApp.Id; 
        intChild.Loan__c  = opp.Id; 
        intChild.Integration_Master__c  = integrationMast.Id; 
        intChild.Request_Id__c = '644a0f30c76c5a00e823e11e';
        insert intChild;
        
        Integration_Checklist__c intChild2 = new Integration_Checklist__c();
        intChild.Response__c  = '{ "TransactionStatus" : {"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {},    "ValidationErrors" : [ null ]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChild.Loan_Application__c  = loanApp.Id; 
        intChild.Loan__c  = opp.Id; 
        intChild.Integration_Master__c  = intmassearch2.Id; 
        intChild.Request_Id__c = '644a0f30c76c5a00e823e11e';
        insert intChild2;

    }
    
    @IsTest
    static void restricAccessTest() {
        List<Profile> prof = [select Id,Name from profile where name = 'Credit Manager'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'credapp1',
                                                                lastName = 'test2',
                                                                profileId = prof[0].id,
                                                                username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test@test.com',
                                                                Branch_Code__c  = '2103',
                                                                Authority_Level__c = 'L2'
                                                               ),true);         
        System.runAs(usr) {
            Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                                        Application_Number__c = 'AP-12345',Adhar_Card__c = 123456,
                                        Loan_Amount__c = 1000,Product__c='10201'),true);
            ComponentProfileRestrictionController.restricAccess('ComponentProfileRestrictionController', loanApp.Id);
            ComponentProfileRestrictionController.validateRecordEdit('ComponentProfileRestrictionController', loanApp.Id);
        }
    }
     @IsTest
    static void restritcAccessTest() {
        List<Profile> prof = [select Id,Name from profile where name = 'Operations'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'ops',
                                                                lastName = 'manager',
                                                                profileId = prof[0].id,
                                                                username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test1@test.com',
                                                                Branch_Code__c  = '2103',
                                                                Authority_Level__c = 'L2',
                                                                Ops_User_Type__c='Ops Maker'
                                                               ),true);      
        
        System.runAs(usr) {
            Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                                        Application_Number__c = 'AP-12343',Adhar_Card__c = 123457,
                                        Loan_Amount__c = 1000,Product__c='10201'),true);
            Assignment__c objAssignment = new Assignment__c(Loan_Application__c=loanApp.Id,Name ='TestAssignment',Status__c='Pending');
        	insert objAssignment;
            Deviation__c devs= new Deviation__c(
            Deviation_Type__c = 'Charges - Min Level Breached',
            Active__c=true  ,Loan_application__c=  loanApp.Id
            );      
            insert devs;
            
            ComponentProfileRestrictionController.restricAccess('ComponentProfileRestrictionController', loanApp.Id);
            ComponentProfileRestrictionController.restricAccess('ComponentProfileRestrictionController', objAssignment.Id);
            ComponentProfileRestrictionController.restricAccess('ComponentProfileRestrictionController', devs.Id);
            ComponentProfileRestrictionController.validateRecordEdit('ComponentProfileRestrictionController', loanApp.Id);
        }
    }
    
    @IsTest
    static void restritcAccessAdminTest() {
        Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c = 'AP-12343',Adhar_Card__c = 123457,
            Loan_Amount__c = 1000,Product__c='10201'),true);
        
        Test.startTest();
        ComponentProfileRestrictionController.restricAccess('ComponentProfileRestrictionController', loanApp.Id);
        ComponentProfileRestrictionController.validateRecordEdit('ComponentProfileRestrictionController', loanApp.Id);
        Test.stopTest();
    }

    @isTest
    static void restritOpsAuthor() {
        List<Profile> prof = [select Id,Name from profile where name = 'Operations'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'ops',
                                                                lastName = 'manager',
                                                                profileId = prof[0].id,
                                                                username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test1@test.com',
                                                                Branch_Code__c  = '2103',
                                                                Authority_Level__c = 'L2',
                                                                Ops_User_Type__c='Ops Author'
                                                               ),true);      
        Test.startTest();
        System.runAs(usr) {
            Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                                        Application_Number__c = 'AP-12343',Adhar_Card__c = 123457,
                                        Loan_Amount__c = 1000,Product__c='10201'),true);
            Assignment__c assignment = (Assignment__c)TestFactory.createSObject(new Assignment__c(
                                Loan_Application__c = loanApp.Id, Name ='TestAssignment',Status__c='Pending'),true);
            Deviation__c deviation = (Deviation__c)TestFactory.createSObject(new Deviation__c(
                                    Loan_Application__c = loanApp.Id),true);
            ComponentProfileRestrictionController.restricAccess('ComponentProfileRestrictionController', assignment.Id);
            Boolean resp = ComponentProfileRestrictionController.restricAccess('ComponentProfileRestrictionController', deviation.Id);
            System.assertEquals(resp, false, 'Success');
        }
        
        Test.stopTest();
    }
    
     @IsTest
    static void validateRecordEditTest() {
        Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c = 'AP-12343',Adhar_Card__c = 123457,
            Loan_Amount__c = 1000,Product__c='10201'),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                            First_Name__c = 'Vikash',Middle_Name__c = 'Kumar',Last_Name__c = 'Mandal',Loan__c =loanApp.Id,
                            Customer_Name__c='Vikas',Customer_Type__c='Individual'),true);
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
            Type__c='Bungalow',
             Stability__c ='7',
            Latest_Cibil_Address_Match_Score__c=100
        ),true);
        
        Test.startTest();
        ComponentProfileRestrictionController.validateRecordEdit('addressInformationComponent', appl.Id);
        ComponentProfileRestrictionController.validateRecordEdit('addressInformationComponent', addInstance.Id);
        Test.stopTest();
    }
}