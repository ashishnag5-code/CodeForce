@isTest
public class GenericCustomLookupControllerTest{
@testSetup 
    static void setup() {
    
     Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true);
    
    Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Branch__c = 'Branc',
            Product__c='10201'
            
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Aadhaar_Number__c   ='847972755528',
            Loan__c =loanAppl.Id
            
        ),true);
        Integration_Master__c  intMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='https://service.aubank.in/CIBILServiceV1',
            HTTP_Method__c ='POST',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='SFDC',
            Name = 'Cibil Individual'
            
        ),true);
        
        Id usedRecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Vehicle Color').getRecordTypeId();

        Generic_Master__c genericRec = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            make__c   = 'Test', Color__c = 'RED' , Manufacturer__c = 'Test', Color_Code__c ='RED', recordTypeId = usedRecordTypeId
        ),true);
        
        Id usedRecordTypeId1 = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Previous Insurer').getRecordTypeId();

        Generic_Master__c genericRec1 = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
           Name__c = 'testCompany', make__c   = 'Test', Model__c = 'Test' , Manufacturer__c = 'Test', Collateral_Code__c ='10106', recordTypeId = usedRecordTypeId1
        ),true);
        
    }
    @isTest 
    static void doRestCalloutTest(){
        string str = 'Branch__c LIKE ' + '\'Bran%\'';
        string strPur = 'Purchase_City__c LIKE ' + '\'Bran%\'';
        GenericCustomLookupController.search('Bran',str,'Loan_Application__c','Branch_Name__c','Lead','','');
        GenericCustomLookupController.search('Bran',strPur,'Loan_Application__c','Branch_Name__c','Lead','Branch_Name__c','AND Branch_Name__c != null');
        GenericCustomLookupController.search('Bran',strPur,'Loan_Application__c','Branch_Name__c','','','');
        GenericCustomLookupController.search('',str,'Loan_Application__c','Branch_Name__c','Lead','',''); 
        GenericCustomLookupController.search('',strPur,'Loan_Application__c','Branch_Name__c','Lead','Branch_Name__c','AND Branch_Name__c != null');
        GenericCustomLookupController.search('',str,'Loan_Application__c','Branch_Name__c','Lead','Branch_Name__c','AND Branch_Name__c != null');
    }
    
    @isTest 
    static void fetchLookupDataTest(){
    GenericCustomLookupController.fetchLookupData('Bran','Loan_Application__c');
    }
    
    @isTest 
    static void getIconNameTest(){
        string str = 'Branch__c LIKE ' + '\'Bran%\'';

    GenericCustomLookupController.getIconName('Loan Application');
        GenericCustomLookupController.search('',str,'Loan_Application__c','Branch_Name__c','','','');
    }
    
    @isTest 
    static void fetchDefaultRecordTest(){
    Loan_Application__c loanAppl1 = [SELECT Id from Loan_Application__c LIMIT 1];
    GenericCustomLookupController.fetchDefaultRecord(loanAppl1.Id,'Loan_Application__c');
    }

     
    
    @isTest 
    static void fetchDefaultColorTest(){
    GenericCustomLookupController.fetchDefaultColor('RED');
        GenericCustomLookupController.getRecordTypeId(null, null);
    }
    
    @isTest 
    static void fetchDefaultIssuerCompanyTest(){
    GenericCustomLookupController.fetchDefaultIssuerCompany('testCompany');
    }
    
    @isTest  
    static void doRestCalloutTestSearchTermBlank(){
        string str = 'Branch__c LIKE ' + '\'Bran%\'';       
        GenericCustomLookupController.search('',str,'Group','Branch_Name__c','','','');
        GenericCustomLookupController.search('',str,'Group','Branch_Name__c','Lead','CreatedDate','AND CreatedDate != null');
        GenericCustomLookupController.search('',str,'Assignment__c','Branch_Name__c','Ops - KYC','','');
        GenericCustomLookupController.search('',str,'Assignment__c','Branch_Name__c','Ops - KYC','CreatedDate','AND CreatedDate != null');
    }
    
    @isTest  
    static void doRestCalloutTestSearchTermBlankElse(){
    string str = 'Branch__c LIKE ' + '\'Bran%\'';   
    GenericCustomLookupController.search('',str,'Loan_Application__c','Branch_Name__c','','','');
        GenericCustomLookupController.search('',str,'Loan_Application__c','Branch_Name__c','Lead','Branch_Name__c','');
    }
    
    @isTest 
    static void doRestCalloutTestRecordTypeIdBLANKElse(){
    string str = 'Branch__c LIKE ' + '\'Bran%\'';
    GenericCustomLookupController.search('Bran',str,'Loan_Application__c','Branch_Name__c','Lead','Branch_Name__c','');
    }
    
     @isTest 
    static void doRestCalloutTestRecordTypeIdBLANKElse1(){
    string str = 'Branch__c LIKE ' + '\'Bran%\'';
    GenericCustomLookupController.search('Bran',str,'Loan_Application__c','Branch_Name__c','','Branch_Name__c','');
    }
}