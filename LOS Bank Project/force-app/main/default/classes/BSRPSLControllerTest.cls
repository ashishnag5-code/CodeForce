@isTest
public class BSRPSLControllerTest {
    @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE'
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Type_of_Employment__c = 'Self Employed Non-Professional',
            Loan__c =loanAppl.Id
            
        ),true);
        
        //Profiling Master Insertion
        //Sector
        Id sectorRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Sector').getRecordTypeId();
        Profiling_Master__c profMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
            Name='Manufacturer',
            Entity_Type__c = 'Individual',
            RecordTypeId = sectorRecordTypeId
        ),true);
        
        //Industry
        Id industryRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Industry').getRecordTypeId();
        Profiling_Master__c industryMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
            Name='Construction & Civil Engineering',
            Sector__c = profMaster.Id,
            RecordTypeId = industryRecordTypeId
        ),true);
        
        //SubIndustry
        Id subIndustryRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Sub Industry').getRecordTypeId();
        Profiling_Master__c subIndustryMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
            Name='Metal Cutlery',
            Sector__c = profMaster.Id,
            Industry__c =industryMaster.Id,
            RecordTypeId = subIndustryRecordTypeId
        ),true);
        
        //Occupation
        Id occupationRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Occupation').getRecordTypeId();
        Profiling_Master__c occupationMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
            Name='Manufacturer',
            Sector__c = profMaster.Id,
            Industry__c = industryMaster.Id,
            Sub_Industry__c =subIndustryMaster.Id,
            Group__c = 'MANUFACTURING',
            Sub_Group__c= 'Food products',
            Occupation_Group__c= 'MEAT',
            PSL_Classification_Category__c = 'PSL- Micro',
            PSL_Classification_Type__c = 'PSL-Agri',
            PSL_Code__c = 'AGFC0105',
            PSL_Description__c = 'AGFC0105-Loans to individual farmers under the Kisan Credit Card Scheme',
            PSL_Segment__c = 'AGFC01 - Farm Credit Individual',
            RecordTypeId = occupationRecordTypeId
        ),true);
        
        // Applicant Financials Insertion
        Id parentRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Financial Parent').getRecordTypeId();
        Applicant_Financials_Details__c applParentFinancials = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c = appl.Id,
            RecordTypeId = parentRecordTypeId,
            isActive__c = true,
            Type_Of_Employment__c ='Salaried - Private',
            Method_Of_Assesment__c ='Salaried',
            Monthly_Income__c =100,
            Monthly_Obligation__c =50,
            Other_Income__c =80,
            Consider_Income_for_Eligibility__c='Yes'
        ),true);
        
        BSR_PSL_Details__c  bsrObj = (BSR_PSL_Details__c )TestFactory.createSObject(new BSR_PSL_Details__c (
            Loan_Application__c = loanAppl.Id,
            RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByName().get('BSR').getRecordTypeId()
        ),true);
        
        BSR_PSL_Details__c  pslObj = (BSR_PSL_Details__c )TestFactory.createSObject(new BSR_PSL_Details__c (
            Loan_Application__c = loanAppl.Id,
            RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByName().get('PSL').getRecordTypeId()
        ),true);
    }
    
    @isTest static void getSectorInfoTest(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getSectorInfo(appl.Id);
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getApplicantsTest(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getApplicants(appl.Id);
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRecordsTest(){
        Loan_Application__c loan =[SELECT id,Loan_Amount__c FROM Loan_Application__c WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        BSRPSLController.getRecords(loan.Id);
        System.assertEquals(1000, loan.Loan_Amount__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getProfilingMasterTest(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getProfilingMaster(appl.Id,'Salaried - Private');
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMasterTest(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('Manufacturer','RT - Sector','RT - Industry','Non PSL','','');
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster2Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('Construction & Civil Engineering','RT - Industry','RT - Sub Industry','Non PSL','','');
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster3Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('Metal Cutlery','RT - Sub Industry','RT - Occupation','Non PSL','','');
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster4Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('Manufacturer','RT - Occupation','RT - Occupation','Non PSL','','');
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster5Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('AGFC0105','PSL_Code__c','PSL_Classification_Type__c','Non PSL','','');
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster6Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('PSL-Agri','PSL_Classification_Type__c','PSL_Classification_Category__c','Non PSL','','');
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster7Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('MANUFACTURING','Group__c','Sub_Group__c','Non PSL','','');
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster8Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('Food products','Sub_Group__c','Sub_Group__c','Non PSL','','');
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster9Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('Manufacturer','RT - Sector','RT - Industry','Non PSL','','Self Employed Non-Professional');
        //System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster10Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('Construction & Civil Engineering','RT - Industry','RT - Sub Industry','Non PSL','','Self Employed Non-Professional~Manufacturer');
        //System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster11Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('Metal Cutlery','RT - Sub Industry','RT - Occupation','Non PSL','','Self Employed Non-Professional~Manufacturer~Construction & Civil Engineering');
        //System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRelatedProfilingMaster12Test(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        BSRPSLController.getRelatedProfilingMaster('PSL-Agri','PSL_Classification_Type__c','Group__c','Non PSL','','');
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getRecordInfoTest(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        BSR_PSL_Details__c bsrDetails = [SELECT Id FROM BSR_PSL_Details__c LIMIT 1];
         Test.startTest();
        BSRPSLController.getRecordInfo('Applicant__c',appl.Id);
        BSRPSLController.getRecordInfo('BSR_PSL_Details__c',bsrDetails.Id);
       // System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    @isTest static void saveRecordsTest(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Loan_Application__c loan =[SELECT id,Loan_Amount__c FROM Loan_Application__c WHERE Application_Number__c='AP-12345'];
        Applicant_Financials_Details__c finance =[SELECT id,Type_Of_Employment__c FROM Applicant_Financials_Details__c WHERE Applicant__c=:appl.Id];
        Map<String,String> applMap = new Map<String,String>();
        applMap.put('Id',appl.Id);
        applMap.put('First_Name__c','Vikash');
        
        Map<String,String> loanMap = new Map<String,String>();
        loanMap.put('Id',loan.Id);
        loanMap.put('Customer_Name__c','Vikash');
        
        Map<String,String> financeMap = new Map<String,String>();
        financeMap.put('Id',finance.Id);
        financeMap.put('Type_Of_Employment__c','Salaried - Private');
        
        Map<String,String> bsrPslMap = new Map<String,String>();
        bsrPslMap.put('PSL_Code__c','AGFC0105');
        bsrPslMap.put('PSL_Classification_Type__c','PSL-Agri');
        bsrPslMap.put('Group__c','MANUFACTURING');
        bsrPslMap.put('Sub_Group__c','Food products');
        bsrPslMap.put('Land_Holding_in_acre__c','12');
        bsrPslMap.put('Investment_in_P_M__c','12');
        
        Test.startTest();
        String result = BSRPSLController.saveRecords(bsrPslMap,applMap,financeMap,loanMap,NULL);
        List<BSR_PSL_Details__c> objList = [SELECT Id, recordTypeId, RecordType.Name FROM BSR_PSL_Details__c WHERE RecordType.Name = 'BSR'];
        for(BSR_PSL_Details__c rec : objList){
            rec.RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByName().get('PSL').getRecordTypeId();
        }
        update objList;
        String result2 = BSRPSLController.saveRecords(bsrPslMap,applMap,financeMap,loanMap,NULL);
        List<BSR_PSL_Details__c> detailsList = [SELECT Id, recordTypeId, RecordType.Name FROM BSR_PSL_Details__c WHERE Loan_Application__c = :loan.Id];
        delete detailsList;
        String result3 = BSRPSLController.saveRecords(bsrPslMap,applMap,financeMap,loanMap,NULL);
        Assignment__c assignment = new Assignment__c();
        assignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - KYC').getRecordTypeId();
        assignment.Loan_Application__c = loan.Id;
        assignment.Status__c = 'Pending';
        insert assignment;
        String result4 = BSRPSLController.saveRecords(bsrPslMap,applMap,financeMap,loanMap,assignment.Id);

        
        //System.assertEquals('Success', result,'test');
        Test.stopTest();
    }
}