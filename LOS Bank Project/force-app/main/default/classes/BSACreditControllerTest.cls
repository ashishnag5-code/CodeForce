@isTest
public with sharing class BSACreditControllerTest {
    @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c ='DDE',
            Wheels_Exposure__c=500,
            Final_Exposure__c =1000
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Loan__c =loanAppl.Id,
            Mobile_Number__c ='8106255685',
            PAN__c ='EXFPK4321K',
            CIF_No__c ='12345678',
            Voter_Id__c='1241214',
            Passport_Number__c='12411414',
            Driving_License_Id__c='3555535xfr',
            Aadhaar_Number__c='60123214141',
            Customer_Type__c='Individual',
            SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]'
            
        ),true);
        
        //CART Loan Type
        Id cartRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get(GlobalConstants.CART_RECORDTYPE_NAME).getRecordTypeId();
        
        Bank_Account_Records__c cbsAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'Loan',
            Loan_Amount__c =10000,
            EMI_Amount__c =2000,
            RecordTypeId = cartRecordTypeId,
            Analysis_Data__c='{\"monthlyBalancesDetails\":[{\"averageBalanceOn1st\":357256.46,\"averageBalanceOn5th\":1144903.5,\"averageBalanceOn10th\":161435.87,\"averageBalanceOn15th\":1471593.46,\"averageBalanceOn20th\":216153.1,\"averageBalanceOn25th\":642820.71,\"AverageofCustomDays\":1331387.7,\"AMB\":693989.2910714283,\"Month-Year\":\"Feb-2022\"}],\"monthlyBalancesDetailsGrandTotal\":{\"averageBalanceOn1st\":1186785.5557142857,\"averageBalanceOn5th\":672105.6414285719,\"averageBalanceOn10th\":256056.13714285727,\"averageBalanceOn15th\":655324.6942857142,\"averageBalanceOn20th\":528625.2400000002,\"averageBalanceOn25th\":623810.5285714281,\"AverageofCustomDays\":1307569.265714286,\"AMB\":726157.724807439},\"monthlyCreditsDetails\":[{\"Credit\":3.774733521E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Feb-2022\"},{\"Credit\":3.2398132259999998E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Mar-2022\"},{\"Credit\":3.050600395E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Apr-2022\"},{\"Credit\":2.036545407E7,\"SalaryCredit\":0.0,\"Month-Year\":\"May-2022\"},{\"Credit\":2.431529362E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Jun-2022\"},{\"Credit\":2.652291799E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Jul-2022\"},{\"Credit\":1.190241869E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Aug-2022\"}],\"monthlyCreditsDetailsGrandTotal\":{\"Credit\":2.625107939857143E7,\"SalaryCredit\":0.0}}',
            Account_Opening_Date__c = System.today()-368
        ),true);
    }
    
    @isTest 
    public static void bankRecords(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSACreditController.getBankRecords(appl.Id);
        Test.stopTest();
    }
    
    @isTest 
    public static void bsaRecordCreation(){
        Bank_Account_Records__c record =[SELECT id,Product_Code__c,POS__c,Sanctioned_Amount__c,  Applicant__c,Account_Number__c,Account_Type__c,Loan_Amount__c,EMI_Amount__c,Account_Opening_Date__c
                                         FROM  Bank_Account_Records__c WHERE Loan_Amount__c =10000 LIMIT 1];
        Test.startTest();
        BSACreditController.createBSARecord(record);
        Test.stopTest();
        
    }
    
    @isTest
    public static void ambRecordCreation(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        List<BSACreditController.bankRecordsWrapper> bankrecords = BSACreditController.getBankRecords(appl.Id);
        String ambRecord= JSON.serialize(bankrecords[0]);
        String applicantId = String.valueOf(appl.Id);
        Test.startTest();
        BSACreditController.createAmbRecord(ambRecord,100,appl.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void amcCreation(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        List<BSACreditController.bankRecordsWrapper> bankrecords = BSACreditController.getBankRecords(appl.Id);
        String ambRecord= JSON.serialize(bankrecords[0]);
        String applicantId = String.valueOf(appl.Id);
        Test.startTest();
        BSACreditController.createAmcRecord(ambRecord,100,appl.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void ambUpdation(){
        Bank_Account_Records__c record =[SELECT id,Product_Code__c,POS__c,Sanctioned_Amount__c,  Applicant__c,Account_Number__c,Account_Type__c,Loan_Amount__c,EMI_Amount__c,Account_Opening_Date__c
                                         FROM  Bank_Account_Records__c WHERE Loan_Amount__c =10000 LIMIT 1];
        String updatedRecord ='{\"monthlyBalancesDetails\":[{\"averageBalanceOn1st\":357256.46,\"averageBalanceOn5th\":1144903.5,\"averageBalanceOn10th\":161435.87,\"averageBalanceOn15th\":1471593.46,\"averageBalanceOn20th\":216153.1,\"averageBalanceOn25th\":642820.71,\"AverageofCustomDays\":1331387.7,\"AMB\":693989.2910714283,\"Month-Year\":\"Feb-2022\"}],\"monthlyBalancesDetailsGrandTotal\":{\"averageBalanceOn1st\":1186785.5557142857,\"averageBalanceOn5th\":672105.6414285719,\"averageBalanceOn10th\":256056.13714285727,\"averageBalanceOn15th\":655324.6942857142,\"averageBalanceOn20th\":528625.2400000002,\"averageBalanceOn25th\":623810.5285714281,\"AverageofCustomDays\":1307569.265714286,\"AMB\":2222.724807439},\"monthlyCreditsDetails\":[{\"Credit\":3.774733521E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Feb-2022\"},{\"Credit\":3.2398132259999998E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Mar-2022\"},{\"Credit\":3.050600395E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Apr-2022\"},{\"Credit\":2.036545407E7,\"SalaryCredit\":0.0,\"Month-Year\":\"May-2022\"},{\"Credit\":2.431529362E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Jun-2022\"},{\"Credit\":2.652291799E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Jul-2022\"},{\"Credit\":200,\"SalaryCredit\":0.0,\"Month-Year\":\"Aug-2022\"}],\"monthlyCreditsDetailsGrandTotal\":{\"Credit\":2.625107939857143E7,\"SalaryCredit\":0.0}}';
        Test.startTest();
        BSACreditController.updateAmbRecord(updatedRecord,record.Id,200,true);
        Test.stopTest();
    }
    
    @isTest
    public static void amcUpdation(){
        Bank_Account_Records__c record =[SELECT id,Product_Code__c,POS__c,Sanctioned_Amount__c,  Applicant__c,Account_Number__c,Account_Type__c,Loan_Amount__c,EMI_Amount__c,Account_Opening_Date__c
                                         FROM  Bank_Account_Records__c WHERE Loan_Amount__c =10000 LIMIT 1];
        String updatedRecord ='{\"monthlyBalancesDetails\":[{\"averageBalanceOn1st\":357256.46,\"averageBalanceOn5th\":1144903.5,\"averageBalanceOn10th\":161435.87,\"averageBalanceOn15th\":1471593.46,\"averageBalanceOn20th\":216153.1,\"averageBalanceOn25th\":642820.71,\"AverageofCustomDays\":1331387.7,\"AMB\":693989.2910714283,\"Month-Year\":\"Feb-2022\"}],\"monthlyBalancesDetailsGrandTotal\":{\"averageBalanceOn1st\":1186785.5557142857,\"averageBalanceOn5th\":672105.6414285719,\"averageBalanceOn10th\":256056.13714285727,\"averageBalanceOn15th\":655324.6942857142,\"averageBalanceOn20th\":528625.2400000002,\"averageBalanceOn25th\":623810.5285714281,\"AverageofCustomDays\":1307569.265714286,\"AMB\":2222.724807439},\"monthlyCreditsDetails\":[{\"Credit\":3.774733521E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Feb-2022\"},{\"Credit\":3.2398132259999998E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Mar-2022\"},{\"Credit\":3.050600395E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Apr-2022\"},{\"Credit\":2.036545407E7,\"SalaryCredit\":0.0,\"Month-Year\":\"May-2022\"},{\"Credit\":2.431529362E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Jun-2022\"},{\"Credit\":2.652291799E7,\"SalaryCredit\":0.0,\"Month-Year\":\"Jul-2022\"},{\"Credit\":200,\"SalaryCredit\":0.0,\"Month-Year\":\"Aug-2022\"}],\"monthlyCreditsDetailsGrandTotal\":{\"Credit\":2.625107939857143E7,\"SalaryCredit\":0.0}}';
        Test.startTest();
        BSACreditController.updateAmbRecord(updatedRecord,record.Id,200,false);
        Test.stopTest();
    }
    
    @isTest static void bsaRecordDeletion(){
        Bank_Account_Records__c record =[SELECT id,Product_Code__c,POS__c,Sanctioned_Amount__c,  Applicant__c,Account_Number__c,Account_Type__c,Loan_Amount__c,EMI_Amount__c,Account_Opening_Date__c
                                         FROM  Bank_Account_Records__c WHERE Loan_Amount__c =10000 LIMIT 1];
        Test.startTest();
        BSACreditController.removeBSARecord(record.Id);
        Test.stopTest();
    }
    
}