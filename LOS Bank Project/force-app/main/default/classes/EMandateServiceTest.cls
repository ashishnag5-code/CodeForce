@isTest
public class EMandateServiceTest {
    @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            EMI_Date__c = '10',
            Repayment_Account_Number__c = '10000364844',
            Customer_Type__c='Individual',
            Repayment_Bank_Name__c = 'JIO PAYMENTS BANK LTD',
            Repayment_Account_Type__c = 'SB',
            Stage__c ='DDE'
        ),true);
        
        Id GMRecordTypeIdpf = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Bank Master').getRecordTypeId();
   /*     Generic_Master__c genericMasterpf = new Generic_Master__c(RecordTypeId = GMRecordTypeIdpf, Bank_Name__c  = 'JIO PAYMENTS BANK LTD');
        insert genericMasterpf;       */ 
        
        Generic_Master__c genericMasterpf1 = new Generic_Master__c(RecordTypeId = GMRecordTypeIdpf, Bank_Name__c  = 'SBIN');
        insert genericMasterpf1;
        
        Generic_Master__c genericMasterpf2 = new Generic_Master__c(RecordTypeId = GMRecordTypeIdpf, Bank_Name__c  = 'AUSF');
        insert genericMasterpf2;
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321',
            Loan__c =loanAppl.Id,
            PAN__c = 'CZFPS4078H',
            Email__c = 'thomsan@gmail.com.invalid',
            Mobile_Number__c = '9910287104',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Integration_Master__c  intMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='https://service.aubank.in/SFDCEmandateRegistrationService',
            HTTP_Method__c ='POST',
            //API_Key__c ='SFDC',
            Timeout__c ='12000',
            Apiuser__c='SFDC',
            Name = 'E-Mandate Registration'),true);
        
        Integration_Master__c  intMaster2 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='https://service.aubank.in/SFDCEmandateUserRegistrationService/withoutUserConfirmation',
            HTTP_Method__c ='POST',
            //API_Key__c ='SFDC',
            Timeout__c ='12000',
            Channel__c =  'LOS',
            Apiuser__c='SFDC',
            Name = 'E-Mandate Registration Without User'),true);
            
            Id usedRecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Bank Master').getRecordTypeId();
        
        Generic_Master__c grMaster = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            Address_Type__c='Permanent',
            Product__c = loanAppl.product__c,
            Residence_Status__c='Owned',  
            Residence_Type__c='Bungalow',           
            recordTypeId = usedRecordTypeId,
            Bank_Name__c = 'JIO PAYMENTS BANK LTD',
            Bank_Code__c = 'JIO'
        ),true);
        
      /*  grMaster.Bank_Name__c = 'JIO PAYMENTS BANK LTD';
        grMaster.Bank_Code__c = '123';
        update grMaster; */
    }
    
    @isTest
    public static void saveDetailsTest(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        String pdcList = '[{"index":1,"countPDC":"213","pdcChequeNumber":"213BSR123","bankName":"SBIN","pdcChequeNumberFrom":"123SBR123","pdcChequeNumberTo":"123SBR125"},{"index":2,"countPDC":"12","pdcChequeNumber":"23HGV213","bankName":"AUSF","pdcChequeNumberFrom":"123SBR123","pdcChequeNumberTo":"123SBR125"}]';
        String spdcList = '[{"index":1,"countSPDC":"23","spdcChequeNumber":"123GHVHG1234","bankName":"SBIN","bankNumber":"123434","spdcChequeNumberFrom":"123SBR123","spdcChequeNumberTo":"123SBR125"}]';
        Boolean result = EMandateService.saveDetails(pdcList,spdcList,loanObj.Id,'PDC','E mandate with PDC',3);
        System.assertEquals(true, result);
        result = EMandateService.saveDetails(pdcList,spdcList,loanObj.Id,'SPDC','E mandate with PDC',3);
    }
    
    @isTest
    public static void sendRegistrationDetailsTest(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EMandateCalloutMock());
        Object response = EMandateService.sendRegistrationDetails(loanObj.Id,'Yes','DebitCard');
        Test.stopTest();
        response = EMandateService.sendRegistrationDetails(loanObj.Id,'No','DebitCard');
        //System.assertNotEquals(null, response);
    }
    
  /*  @isTest
    public static void generateRequestTest(){
        Loan_Application__c loanObj = [SELECT Id,EMI_Date__c,Repayment_Bank_Name__c, Repayment_Account_Number__c, Repayment_Account_Type__c, Application_Id__c FROM Loan_Application__c LIMIT 1];
        Applicant__c appl =  [SELECT Id,Email__c,Mobile_Number__c,First_Name__c,Last_Name__c,Middle_Name__c,Loan__c,CIF_No__c,PAN__c FROM Applicant__c LIMIT 1];
        Integration_Master__c Im = [SELECT Id,name,Active__c,Timeout__c,End_Point_URL__c,HTTP_Method__c,Apiuser__c,Channel__c FROM Integration_Master__c limit 1];
        EMandateService.generateRequest(loanObj,appl,Im,'DebitCard','Yes');
    }*/
    
    
}