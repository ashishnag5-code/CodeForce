@isTest
public with sharing class AgricultureIncomeDetailsControllerTest {
    
    @TestSetup
    static void createData(){

        Loan_Application__c newLoan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000000,
            Product__c='10201',//Auto Loan (New)',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Total_Loan_Amount__c =1000000
        ),true);

        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Advik',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =newLoan.Id,
            DOB__c = Date.newInstance(1998,09,09),
            Bureau_Score__c = '728',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);

        Applicant__c coAppl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Anish',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =newLoan.Id,
            DOB__c = Date.newInstance(1998,09,09),
            Bureau_Score__c = '728',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
        ),true);

        Applicant__c coAppl3 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Nihal',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =newLoan.Id,
            DOB__c = Date.newInstance(1998,09,09),
            Bureau_Score__c = '728',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
        ),true);

        Applicant__c bo1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Ravi',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =newLoan.Id,
            DOB__c = Date.newInstance(1998,09,09),
            Bureau_Score__c = '728',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('BO').getRecordTypeId()
        ),true);

        Applicant__c bo = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Veer',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =newLoan.Id,
            DOB__c = Date.newInstance(1998,09,09),
            Bureau_Score__c = '728',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('BO').getRecordTypeId()
        ),true);

        List<Applicant__c> applicantList = new List<Applicant__c>();
        applicantList.add(new Applicant__c(First_Name__c='Caroline', Last_Name__c='Forbes',Loan__c=newLoan.Id));
        applicantList.add(new Applicant__c(First_Name__c='Elena', Last_Name__c='Gilbert',Loan__c=newLoan.Id));
        insert applicantList;
    
        applicantList = [Select Id from Applicant__c order by First_Name__c];
        
        Address__c address1 = new Address__c(State__c='Gujarat',District__c='Ahmedabad',Address_Type__c='Current',Applicant__c=appl.Id);
        insert address1;

        Id recId = Schema.SObjectType.Scale_of_Finance__c.getRecordTypeInfosByDeveloperName().get('Agriculture_Income').getRecordTypeId();
        List<Scale_of_Finance__c> scaleofFinanceRecordList = new List<Scale_of_Finance__c>();
        scaleofFinanceRecordList.add(new Scale_of_Finance__c(Crop__c='Bajra',ew_Market_Price_Quintal__c=1200,Sowing_Month__c='June-Jul',
                                        Harvest_Month__c='Sep-Oct',New_Yield__c=13.5,State__c='Gujarat',Location__c='Ahmedabad',
                                        RecordTypeId=recId));
        recId = Schema.SObjectType.Scale_of_Finance__c.getRecordTypeInfosByDeveloperName().get('Commercial_Income').getRecordTypeId();
        scaleofFinanceRecordList.add(new Scale_of_Finance__c(Income_Source__c='3Wheel',Unit__c='1',Annual_Income_Unit_Rs__c=200000,
                                        Type_of_Income__c='Type_of_Income__c',RecordTypeId=recId));
        insert scaleofFinanceRecordList;

        Id parentRecType = getRecordTypeId('Financial_Parent');
        List<Applicant_Financials_Details__c> afdParentList = new List<Applicant_Financials_Details__c>();
        afdParentList.add(new Applicant_Financials_Details__c(Type_Of_Employment__c='Salaried - Private',Monthly_Obligation__c=1000,
                                                            RecordTypeId=parentRecType,
                                                            Method_Of_Assesment__c='Salaried', Applicant__c=appl.Id));

        afdParentList.add(new Applicant_Financials_Details__c(Type_Of_Employment__c='Self Employed Non-Professional',Monthly_Obligation__c=1000,
                                                            RecordTypeId=parentRecType,
                                                            Method_Of_Assesment__c='Assessed', Applicant__c=bo1.Id));

        afdParentList.add(new Applicant_Financials_Details__c(Type_Of_Employment__c='Self Employed Non-Professional',Monthly_Obligation__c=1000,
                                                            RecordTypeId=parentRecType,
                                                            Method_Of_Assesment__c='Documented - Audited', Applicant__c=coAppl.Id));

        afdParentList.add(new Applicant_Financials_Details__c(Type_Of_Employment__c='Farmer',Monthly_Obligation__c=1000,
                                                            RecordTypeId=parentRecType,
                                                            Method_Of_Assesment__c='NA', Applicant__c=bo.Id));

        insert afdParentList;
        List<Applicant_Financials_Details__c> afdChildList = new List<Applicant_Financials_Details__c>();
        afdChildList.add(new Applicant_Financials_Details__c(First_Month__c=100,Second_Month__c=100,Third_Month__c=100,Salary_Received_in_Cash__c=100,
                            RecordTypeId=getRecordTypeId('Salaried_Document'),Applicant_Financials__c = afdParentList[0].Id,
                            isActive__c = true,applicant__c = afdParentList[0].Applicant__c));

        afdChildList.add(new Applicant_Financials_Details__c(Monthly_Turnover__c=100,isActive__c=true,
                            RecordTypeId=getRecordTypeId('Assessed_No_Document'),Applicant_Financials__c = afdParentList[1].Id,
                            applicant__c = afdParentList[1].Applicant__c));

        afdChildList.add(new Applicant_Financials_Details__c(Monthly_Total_Income__c=100,isActive__c=true,
                            RecordTypeId=getRecordTypeId('Documented_With_Audited_financial'),Applicant_Financials__c = afdParentList[2].Id,
                            applicant__c = afdParentList[2].Applicant__c));

        afdChildList.add(new Applicant_Financials_Details__c(Total_Net_Income__c=100,isActive__c=true,
                            RecordTypeId=getRecordTypeId('Farmer_Dairy_Business'),Applicant_Financials__c = afdParentList[3].Id,
                            applicant__c = afdParentList[3].Applicant__c));

        afdChildList.add(new Applicant_Financials_Details__c(Net_Annual_Income__c=100,isActive__c=true,
                            RecordTypeId=getRecordTypeId('Farmer_Commercial'),Applicant_Financials__c = afdParentList[3].Id,
                            applicant__c = afdParentList[3].Applicant__c));

        afdChildList.add(new Applicant_Financials_Details__c(Net_Revenue__c=100,isActive__c=true,
                            RecordTypeId=getRecordTypeId('Farmer_Agriculture_Own_Land'),Applicant_Financials__c = afdParentList[3].Id,
                            applicant__c = afdParentList[3].Applicant__c));

        afdChildList.add(new Applicant_Financials_Details__c(Net_Revenue__c=100,isActive__c=true,
                            RecordTypeId=getRecordTypeId('Farmer_Agriculture_Rented_Land'),Applicant_Financials__c = afdParentList[3].Id,
                            applicant__c = afdParentList[3].Applicant__c));
        
        afdChildList.add(new Applicant_Financials_Details__c(Monthly_Income__c=100,isActive__c=true,
                            RecordTypeId=getRecordTypeId('Other_Income'),Applicant_Financials__c = afdParentList[3].Id,
                            applicant__c = afdParentList[3].Applicant__c));

        afdChildList.add(new Applicant_Financials_Details__c(Monthly_Income__c=100,isActive__c=true,Method_Of_Assesment__c='Documented',
                            RecordTypeId=getRecordTypeId('Other_Income'),Applicant_Financials__c = afdParentList[3].Id,
                            applicant__c = afdParentList[3].Applicant__c));
       insert afdChildList;
        
    }

    public static Id getRecordTypeId(String devName){
        Id recId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get(devName).getRecordTypeId();
        return recId;
    }

    @isTest
    public static void getCropsDetailsTest(){
        Test.startTest();
        Id applicantId = [Select Id from Applicant__c WHERE First_Name__c='Advik'][0].Id;
        AgricultureIncomeDetailsController.getCropsDetails(applicantId);
        Test.stopTest();
    }

    @isTest
    public static void getIncomeSourceTest(){
        Test.startTest();
        AgricultureIncomeDetailsController.getIncomeSource('Commercial');
        Test.stopTest();
    }

    @isTest
    public static void markRecordsInactiveTest(){
        Test.startTest();
        Applicant_Financials_Details__c record = [select Id, applicant__c from Applicant_Financials_Details__c where RecordTypeId=:getRecordTypeId('Other_Income') LIMIT 1];
        AgricultureIncomeDetailsController.markRecordsInactive(record.Id);
        Test.stopTest();
    }

    @isTest
    public static void upsertIncomeTest(){
        Test.startTest();
        List<Applicant_Financials_Details__c> afdParentList = [select Id, applicant__c from Applicant_Financials_Details__c order by Method_Of_Assesment__c];
        Applicant_Financials_Details__c child = new Applicant_Financials_Details__c(Monthly_Income__c=100,isActive__c=true,
                                        RecordTypeId=getRecordTypeId('Other_Income'),Applicant_Financials__c = afdParentList[0].Id,
                                        applicant__c = afdParentList[0].Applicant__c);
        AgricultureIncomeDetailsController.upsertIncome(child);
        Test.stopTest();
    }

    @isTest
    public static void getParentFinancialRecordTest(){
        Test.startTest(); 

        List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id FROM Applicant_Financials_Details__c WHERE RecordType.DeveloperName='Financial_Parent'];
        for(Applicant_Financials_Details__c appFinancial: applicantFinancials){
            AgricultureIncomeDetailsController.incomeWrapper a = AgricultureIncomeDetailsController.getParentFinancialRecord(appFinancial.Id);
        }
        Test.stopTest();
    }

    @isTest
    public static void getVisibleFieldsForLoanDetailsTest(){
        Test.startTest(); 
        AgricultureIncomeDetailsController.getVisibleFieldsForLoanDetails('Other Income','QDE','');
        Test.stopTest();
    }

    @isTest
    public static void getVisibleFieldsForFinancialsTest(){
        Test.startTest(); 
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        AgricultureIncomeDetailsController.getVisibleFieldsForFinancials('Farmer - Agriculture Own Land','QDE','', loan.Id,'');
        Test.stopTest();
    }

    @isTest
    public static void deleteFinancialRecordsTest(){
        Test.startTest(); 
        List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id FROM Applicant_Financials_Details__c WHERE RecordType.DeveloperName='Other_Income'];
        AgricultureIncomeDetailsController.deleteFinancialRecords(applicantFinancials[0].Id);
        System.assertEquals([SELECT Id FROM Applicant_Financials_Details__c WHERE RecordType.DeveloperName='Other_Income'].size(), applicantFinancials.size()-1, 'Success');
        Test.stopTest();
    }

    @isTest
    public static void renderDeleteActionTest(){
        Test.startTest(); 
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Boolean resp = AgricultureIncomeDetailsController.renderDeleteAction(loan.Id);
        System.assertEquals(resp, true, 'Success');
        Test.stopTest();
    }

    @isTest
    public static void renderDeleteActionSalesTest(){
        Test.startTest(); 
        List<Profile> prof = [select Id,Name from profile where name = 'Sales'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'Sales',
                                                            lastName = 'User',
                                                            profileId = prof[0].id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test1@test.com',
                                                            Branch_Code__c  = '2103',
                                                            Authority_Level__c = 'L2'
                                                           ),true);      
        System.runAs(usr){
            Loan_Application__c newLoan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000000,
            Product__c='10201',//Auto Loan (New)',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Total_Loan_Amount__c =1000000
            ),true);
            Boolean resp = AgricultureIncomeDetailsController.renderDeleteAction(newLoan.Id);
            System.assertEquals(resp, true, 'Success');
        }
        Test.stopTest();
    }

    @isTest
    public static void renderDeleteActionCreditTest(){
        Test.startTest();
        Loan_Application__c newLoan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000000,
            Product__c='10201',//Auto Loan (New)',
            Customer_Type__c='Individual',
            Stage__c ='Credit',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Total_Loan_Amount__c =1000000
        ),true);
        List<Profile> prof = [select Id,Name from profile where name = 'Credit Manager'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'Credit',
                                                            lastName = 'User',
                                                            profileId = prof[0].id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test1@test.com',
                                                            Branch_Code__c  = '2103',
                                                            Authority_Level__c = 'L2'
                                                           ),true);    
        Loan_Application__Share shareRec = new  Loan_Application__Share (ParentId=newLoan.Id, UserOrGroupId=usr.Id, AccessLevel='Edit');
        insert shareRec;
        System.runAs(usr){
            Boolean resp = AgricultureIncomeDetailsController.renderDeleteAction(newLoan.Id);
            System.assertEquals(resp, true, 'Success');
        }
        Test.stopTest();
    }

    

    

    
    
}