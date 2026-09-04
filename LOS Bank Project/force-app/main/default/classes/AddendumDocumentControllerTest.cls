@istest
public class AddendumDocumentControllerTest {
    
     @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
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
        Collateral__c  collRec = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Collateral_ID__c ='102010000000001',
            Loan__c   = loanAppl.Id,
            Collateral_Id_in_CBS__c='102010000000001',
            Vahaan_Response__c='{"registrationNumber":null,"registrationCity":null,"ownerSerialNumber":null,"hpnFinancer":null,"engineNo":null,"currentOwnerName":null,"chasisNumber":null}'
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',Aadhaar_Number__c = '123412341234',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Collateral Modification',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CollateralModificationRestService/Modification',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
    }
    
    @isTest
    public static void AddendumDocumentControllerTest1(){
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c];
        ApexPages.currentPage().getParameters().put('applicationId', loanAppl.Id);
        ApexPages.currentPage().getParameters().put('selectedEMIDate', String.valueOf(Date.today()));
        AddendumDocumentController cntrl = new AddendumDocumentController();
        AddendumDocumentController.RecordId = loanAppl.id;
        AddendumDocumentController.selectedDate = '15';
        AddendumDocumentController.numberVsMonth = new Map<Integer, String>{1 => 'January', 2 => 'February', 3 => 'March',
                                                    4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July',
                                                    8 => 'August', 9 => 'September', 10 => 'October',
                                                    11 => 'November', 12 => 'December'};
        AddendumDocumentController.getLoan();
        Test.stopTest();
    }
    

}