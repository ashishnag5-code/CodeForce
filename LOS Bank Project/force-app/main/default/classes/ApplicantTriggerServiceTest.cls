@isTest
public class ApplicantTriggerServiceTest {
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
            CIBIL_Status__c ='Completed',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            Dob__c = Date.parse('09/01/1989'),
            Mobile_Number__c='1234567890',
            PAN__c='BKDPK4370H',
            KYC_Status__c = 'Pending',
            
            
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
            
            
        ),true);
        
          Document_Master__c docMasterRecord1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
           Document_Name__c = 'EKYC PDF',
           Constitiution__c = 'Partnership Firms',
           Individual_NI__c='NI'
        ),true);
        
          Document_Checklist__c docCheckRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
           Document_Master__c = docMasterRecord1.Id,
           Active__c =true,
           Applicant__c = appl.Id
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
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'TestCat'
        ),true);
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'IBB',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaAddressMatchServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Collateral Dedupe API',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CollateralSearchService/CollateralDedupe',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
      
        
        ID modelRecTypeId=Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        ID makeRecTypeId=Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        ID varRecTypeId=Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Variant').getRecordTypeId();
        MMV_Master__c  modelmvM = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c (
            Name='ZX MT_DIESEL1', RecordTypeId = modelRecTypeId
        ),true); 
        MMV_Master__c  makemvM = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c (
            Name='ZX MT_DIESEL2', RecordTypeId = makeRecTypeId
        ),true);
        
        MMV_Master__c  mmvM = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c (
            Name='ZX MT_DIESEL3',Make__c = makemvM.Id , Model__c = modelmvM.Id , RecordTypeId= varRecTypeId
        ),true);
        
        ID ibbRecTypeId=Schema.SObjectType.MMV_Mapping_Master__c.getRecordTypeInfosByDeveloperName().get('IBB').getRecordTypeId();
        MMV_Mapping_Master__c  mmvMs = (MMV_Mapping_Master__c)TestFactory.createSObject(new MMV_Mapping_Master__c (
            MMV__c=mmvM.Id, RecordTypeId = ibbRecTypeId
        ),true);
    }
    @isTest 
    public static void applicantUpdateTest(){
        List<Applicant__c> applist = [SELECT Id,CIBIL_Status__c,First_Name__c,Middle_Name__c,Last_Name__c  from Applicant__c];
        List<Applicant__c> updatedAppList = new List<Applicant__c>();
        for(Applicant__c app : applist){
            app.First_Name__c = 'test';
            updatedAppList.add(app);
        }
        update updatedAppList;
        
    }
      @isTest 
    public static void updateLoanNameTest(){
        List<Applicant__c> recordList = [SELECT Id,CIBIL_Status__c,First_Name__c,Middle_Name__c,Last_Name__c,Loan__c  from Applicant__c];
        Map<Id, Applicant__c> myMap = new Map<Id, Applicant__c>(); 
        for(Applicant__c objCS : recordList)
        myMap.put(objCS.Id, objCS);
         Test.startTest();
        ApplicantTriggerService appService = new ApplicantTriggerService();
        appService.updateLoanName(recordList, myMap);
        Test.stopTest();
    }
        @isTest 
    public static void coverOtherTest(){
        List<Applicant__c> recordList = [SELECT Id,CIBIL_Status__c,First_Name__c,Middle_Name__c,Last_Name__c,Loan__c  from Applicant__c];
        Map<Id, Applicant__c> myMap = new Map<Id, Applicant__c>(); 
        for(Applicant__c objCS : recordList)
        myMap.put(objCS.Id, objCS);
         Test.startTest();
        ApplicantTriggerService appService = new ApplicantTriggerService();
        appService.beforeDelete(myMap);
        appService.afterDelete(myMap);
        appService.afterUndelete(myMap);
        Test.stopTest();
    }
       @isTest 
    public static void saveEKYCPdfTest(){
        List<Applicant__c> recordList = [SELECT Id,CIBIL_Status__c,First_Name__c,Middle_Name__c,Last_Name__c,Loan__c,Email__c,KYC_Status__c ,RecordTypeId,RecordType.Name,Dob__c  from Applicant__c];
        Map<Id, Applicant__c> myMap = new Map<Id, Applicant__c>(); 
        for(Applicant__c objCS : recordList)
            
        myMap.put(objCS.Id, objCS);
        
         Test.startTest();
        ApplicantTriggerService appService = new ApplicantTriggerService();
        appService.saveEKYCPdf(recordList,myMap,myMap,recordList);
        Test.stopTest();
    }
    
    @isTest 
    public static void updateDocChecklistsTest(){
        Applicant__c applicantRec = [SELECT Id,Constitution_Type__c  from Applicant__c LIMIT 1];
        Applicant__c appRec = applicantRec;
        applicantRec.Constitution_Type__c = 'Sole Proprietary';
        update  applicantRec;       
        Map<Id,Applicant__c> oldApplicantMap = new Map<Id,Applicant__c>();
        Map<Id,Applicant__c> newApplicantMap = new Map<Id,Applicant__c>();
        oldApplicantMap.put(applicantRec.Id,applicantRec);
        
        List<Applicant__c> newApplicantList = new List<Applicant__c>();
        appRec.Constitution_Type__c = 'Partnership Firms';
        update appRec;
        newApplicantList.add(appRec);
        newApplicantMap.put(appRec.Id,appRec);
        test.startTest();
            ApplicantTriggerService appTrigger = new ApplicantTriggerService();
            appTrigger.updateDocChecklists(newApplicantList,oldApplicantMap,newApplicantMap);
        test.stopTest();
    }    
    @isTest 
    public static void updateCustomerGradeTest(){
        Applicant__c priAppl = [SELECT Id, Loan__c, Customer_Grade__c  from Applicant__c LIMIT 1];
        Loan_Application__c loan = new Loan_Application__c(Id=priAppl.Loan__c, Product__c = '10201', Customer_Grade__c='NIB');
        update loan;
        Applicant__c coAppl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Nikesh',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Existing_Customer__c  = 'Yes',
            CIBIL_Status__c ='Completed',
            CIF_No__c = '576321',
            Customer_Grade__c = 'IB',
            Loan__c =priAppl.Loan__c,
            Type_of_Employment__c = 'Business',
            Dob__c = Date.parse('09/01/1990'),
            Mobile_Number__c='1234567890',
            PAN__c='BKDPK4370L',
            KYC_Status__c = 'Pending',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
        ),true);
        List<Applicant_Financials_Details__c> appFinList = new List<Applicant_Financials_Details__c>();
        Applicant_Financials_Details__c af1 = new Applicant_Financials_Details__c();
        af1.RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId();
        af1.Applicant__c = priAppl.Id;
        af1.Monthly_Income__c = 2000;
        af1.Monthly_Obligation__c = 1000;
        af1.Consider_Income_for_Eligibility__c = 'Yes';
        Applicant_Financials_Details__c af2 = new Applicant_Financials_Details__c();
        af2.RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId();
        af2.Applicant__c = coAppl.Id;
        af2.Monthly_Income__c = 2000;
        af2.Monthly_Obligation__c = 5000;
        af2.Consider_Income_for_Eligibility__c = 'Yes';
        appFinList.add(af1);
        appFinList.add(af2);
        insert appFinList;
        coAppl.Customer_Grade__c = 'Premium';
        priAppl.Customer_Grade__c = 'IB';
        test.startTest();
        update new List<Applicant__c>{coAppl,priAppl};
        coAppl.Customer_Grade__c = 'NIB';
        priAppl.Customer_Grade__c = 'Premium';
        update new List<Applicant__c>{coAppl,priAppl};
        priAppl.Customer_Grade__c = 'NIB';
        update priAppl;
        test.stopTest();
    }
    
}