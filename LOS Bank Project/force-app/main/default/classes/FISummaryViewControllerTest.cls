@isTest
public with sharing class FISummaryViewControllerTest {
    @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];

        Location_Master__c  lcMaster = (Location_Master__c )TestFactory.createSObject(new Location_Master__c (
            Name ='110053',
            Area_Name__c ='JAGJIT NAGAR',
            Area_Type__c ='Urban',  
            City__c ='EAST DELHI',
            State__c ='MAHARASHTRA',
            Taluka__c ='NA'
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
            Branch_Master__c =accInstance.Id,
            Application_FI_Status__c='In Progress'
            
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Loan__c =loanAppl.Id,
            Customer_Name__c='Vikas',
            Customer_Type__c='Individual'
            
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
            Pincode__c='110051',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Permanent',
            Type__c='Bungalow'
        ),true);
        
        Address__c  addInstance1 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline11',
            Address_Line_2__c ='TestAddressline22',
            Address_Line_3__c ='TestAddressline34',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110052',
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
            Address_Line_3__c ='TestAddressline333',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110054',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Touch Point',
            Type__c='Bungalow'
        ),true);
        Id recId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId();

        Applicant_Financials_Details__c applFinancialInsta=(Applicant_Financials_Details__c)TestFactory.createSObject((new Applicant_Financials_Details__c(Type_Of_Employment__c='Salaried - Private',Monthly_Obligation__c=1000,
                                                            RecordTypeId=recId,Company_Name__c='AU',
                                                            Method_Of_Assesment__c='Salaried', Applicant__c=appl.Id)),true);


                                                            User usr = (User)TestFactory.createSObject(new User(
                                                                firstName = 'test13',
                                                                lastName = 'test2',
                                                                profileId = prof.id,
                                                                username = 'test124'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test123@test.com',
                                                                Branch_Code__c  = '1111'
                                                            ),true);
                                                 //           system.runAs(usr){

                                                            Field_Investigation__c fieldInvestigationObj = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
                                                               Name = appl.Customer_Name__c,
                                                           Loan_Application__c =loanAppl.Id,
                                                            Address_lookup__c=addInstance.id,
                                                            Applicant__c=appl.Id,
                                                            FI_Status__c ='Negative',
                                                            Applicant_Type__c='Applicant' )),true);
                                                            
                                                            Field_Investigation__c fieldInvestigationObj2 = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
                                                                Name = appl.Customer_Name__c,
                                                            Loan_Application__c =loanAppl.Id,
                                                            Address_lookup__c=addInstance1.id,
                                                            Applicant__c=appl.Id,
                                                            FI_Status__c ='Positive',
                                                            Credit_Manager__c =usr.Id,
                                                            Applicant_Type__c='Applicant' )),true);
                                                            Field_Investigation__c fieldInvestigationObj3 = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
                                                                Name = appl.Customer_Name__c,
                                                            Loan_Application__c =loanAppl.Id,
                                                            Address_lookup__c=addInstanc2.id,
                                                            Applicant__c=appl.Id,
                                                            FI_Status__c ='Positive',
                                                            Applicant_Type__c='Applicant' )),true);
                                                            Field_Investigation__c fieldInvestigationObj4 =(Field_Investigation__c) TestFactory.createSObject((new Field_Investigation__c( 
                                                                Name = appl.Customer_Name__c,
                                                            Loan_Application__c =loanAppl.Id,
                                                            Address_lookup__c=addInstanc3.id,
                                                            Applicant__c=appl.Id,
                                                           FI_Status__c ='Positive',
                                                            Applicant_Type__c='Applicant' )),true);
                                                      //      }
                                                           
     

    }
    @isTest static void fiSummaryViewTest() {
        Test.startTest();
        Loan_Application__c loanApplication =[Select Id from Loan_Application__c limit 1];
        Applicant__c applicant =[Select Id from Applicant__c limit 1];
        List<FiSummaryViewWrapper>  FiSummaryViewWrapper=FISummaryViewController.fiSummaryView(loanApplication.Id,applicant.id);
        System.assertEquals(FiSummaryViewWrapper.size()!= 0,true,'AssertMsg');

        Test.stopTest();
    }
    @isTest static void exeptionCoverTest() {
        Test.startTest();
        try{
            List<FiSummaryViewWrapper>  FiSummaryViewWrapper=FISummaryViewController.fiSummaryView(' ','');
            System.assertEquals(FiSummaryViewWrapper.size()== 0,true,'AssertMsg');
        }catch(exception e){}
        Test.stopTest();
    }
}