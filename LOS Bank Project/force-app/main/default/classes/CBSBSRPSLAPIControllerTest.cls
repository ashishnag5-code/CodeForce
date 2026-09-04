@isTest
public class CBSBSRPSLAPIControllerTest {
    @testSetup static void setup() {
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true);
        
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = branchMaster.Id
        ),true);
        
        Assignment__c objAssignment = new Assignment__c(Loan_Application__c=loanAppl.Id,Name ='TestAssignment',Status__c='Pending');
        insert objAssignment;
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE',
            Dob__c = System.today().addYears(-50),
            Gender__c='Female',
            Marital_Status__c='Single',
            Mobile_Number__c ='7070707070',
            AU_Employee_ID__c='AU123',
            Title__c='Mr',
            Total_Monthly_Income_Sum__c = 10000
            
        ),true);
        
        //Address Insertion
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
        
        //Applicant Insertion
        Applicant__c applNonInd = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Non Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE',
            Dob__c = System.today().addYears(-50),
            Gender__c='Female',
            Marital_Status__c='Single',
            Mobile_Number__c ='7070707070',
            AU_Employee_ID__c='AU123',
            Title__c='Mr',
            Constitution_Type__c='HUF'
        ),true);
        
        //Address Insertion
        Address__c  addInstanceapplNonInd = (Address__c)TestFactory.createSObject(new Address__c(
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
            Applicant__c =applNonInd.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow',
            Stability__c ='7',
            Latest_Cibil_Address_Match_Score__c=100
        ),true);
        //CIF Creation Integration Master
        Integration_Master__c imCIFCreation = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name =CBSBSRPSLAPIController.CBS_BSR_PSL,
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
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
            RecordTypeId = occupationRecordTypeId
        ),true);
        
        Id employmentTypeRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Employment Type').getRecordTypeId();
        Profiling_Master__c employmentTypeMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
            Name='Salaried - Private',
            Sector__c = profMaster.Id,
            Industry__c = industryMaster.Id,
            Sub_Industry__c =subIndustryMaster.Id,
            Occupation__c = occupationMaster.Id,
            RecordTypeId = employmentTypeRecordTypeId
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
            Sector__c = 'Manufacturer',
            Industry__c = 'Construction & Civil Engineering',
            Sub_Industry__c = 'Metal Cutlery',
            Occupation__c = 'Manufacturer',
            Consider_Income_for_Eligibility__c='Yes'
        ),true);
        
        // Salaried
        Id salariedRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Salaried Document').getRecordTypeId();
        Applicant_Financials_Details__c applChildFinancials = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c = appl.Id,
            RecordTypeId = salariedRecordTypeId,
            isActive__c = true,
            Applicant_Financials__c =applParentFinancials.Id
        ),true);
        
    }
    
    static testmethod  void testSubmitCIFDetails(){
        Applicant__c loanApplicant = [Select Id from Applicant__c WHERE Customer_Type__c = 'Individual'];
        CBSBSRPSLAPIController.submitCIFDetails(loanApplicant.Id);
    }
    static testmethod void testsubmitLANDetails(){
        Loan_Application__c loanApplication = [Select Id from Loan_Application__c];
        CBSBSRPSLAPIController.submitLANDetails(loanApplication.Id);
    }
    static testmethod void testisComplete(){
        Applicant__c loanApplicant = [Select Id,Loan__c from Applicant__c WHERE Customer_Type__c = 'Individual'];
        CBSBSRPSLAPIController.isComplete(loanApplicant.Loan__c,null);
    }
    static testmethod void testisComplete2(){
        Applicant__c loanApplicant = [Select Id,Loan__c from Applicant__c WHERE Customer_Type__c = 'Individual'];
        CBSBSRPSLAPIController.isComplete(null,loanApplicant.Id);
    }
    static testmethod void exceptionTest(){
        try{
            Applicant__c loanApplicant = [Select Id,Loan__c from Applicant__c WHERE Customer_Type__c = 'Individual'];
            Integration_Master__c im = [Select Id, Active__c FROM Integration_Master__c Where Name = :CBSBSRPSLAPIController.CBS_BSR_PSL];
            im.Active__c = false;
            upsert im;
            CBSBSRPSLAPIController.submitCIFDetails(loanApplicant.Id);  
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }

    }
    static testmethod void submitLANDetailsExceptionTest2(){
        try{
			Loan_Application__c loanApplication = [Select Id from Loan_Application__c];
            Integration_Master__c im = [Select Id, Active__c FROM Integration_Master__c Where Name = :CBSBSRPSLAPIController.CBS_BSR_PSL];
            im.Active__c = false;
            upsert im;
            CBSBSRPSLAPIController.submitLANDetails(loanApplication.Id);  
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }

    }
}