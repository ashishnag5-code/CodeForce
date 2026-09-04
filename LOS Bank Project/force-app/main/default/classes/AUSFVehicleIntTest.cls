/*****
 * Class Name: AUSFVehicleIntTest
 * Description: Test class for AUSFVehicleController
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-21-2023          -   Mohit Maheshwari    -   SFAU-5240
 * Oct-09-2023          -   Mohit M.            -   SFAU-5163
 * Dec-07-2023          -   Mohit M.            -   SFAU-5706 - IBB Value not getting in any application
 */
@isTest
public class AUSFVehicleIntTest {
    @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 

        Document_Master__c docMasterRecord1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
           Document_Name__c = 'Vahaan Master'
        ),true);
        
        Id stateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('State').getRecordTypeId();
        Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Id regionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        
        Account dealerInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount1',
            Account_Code__c='21051',
            Branch_Queue__c=grp.Id,
            RecordTypeId = dealerRecordTypeId
        ),true);
        
        Account stateInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount1',
            Account_Code__c='2105',
            Branch_Queue__c=grp.Id,
            RecordTypeId = stateRecordTypeId
        ),true);
        
        Account regInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount2',
            Account_Code__c='2104',
            Branch_Queue__c=grp.Id,
            RecordTypeId = regionRecordTypeId
        ),true);

        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id,
            State__c=stateInstance.Id,
            Region__c=regInstance.Id,
            RecordTypeId = branchRecordTypeId
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
            Customer_Grade__c = 'IB',
            Vehicle_use__c = 'Personal',
            Branch_Master__c = accInstance.Id,
            Dealer_Master__c = dealerInstance.Id
        ),true);
        Loan_Application__c fourWheelerLoan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12346',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Customer_Grade__c = 'NIB',
            Vehicle_use__c = 'Personal',
            Branch_Master__c = accInstance.Id,
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get(GlobalConstants.FOUR_WHEELER).getRecordTypeId()
        ),true);
        Loan_Application__c tractorLoan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12347',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10501',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Customer_Grade__c = 'NIB',
            Vehicle_use__c = 'Personal',
            Branch_Master__c = accInstance.Id,
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Tractor').getRecordTypeId()
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Farmer',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);

        TestFactory.createSObject(
            new Applicant_Financials_Details__c(
                Type_Of_Employment__c='Salaried - Private',
                Monthly_Obligation__c = 1000,
                RecordTypeId = Utility.getRecordTypeId(SObjectType.Applicant_Financials_Details__c.getSOBjectType(), 'Financial Parent' ),
                Method_Of_Assesment__c='Salaried',
                Applicant__c = appl.Id
            ),
            true
        );

        Bureau_Results__c bresult = (Bureau_Results__c)TestFactory.createSObject(new Bureau_Results__c(
            Applicant__c = appl.Id,
            Bureau_Score_Date__c = Date.today(),
            Bureau_Score__c = 777
        ),true);
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(2999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', 
            Vehicle_Category__c ='A; B; C; D; E',
            Scheme_Code__c = 'Scheme 0001',
            CIBIL_Min__c = 100,
            CIBIL_Max__c = 900,
            MAXROI__c = 30.00,
            MINROI__c = 7.00,
            MAXTENURE__c = 84.00,
            MINTENURE__c = 6.00,
            MAXLOANAMOUNT__c = 10000000.00,
            MINLOANAMOUNT__c = 25000.00,
            Is_Dealer_Scheme__c = 'True',
            Is_Location_General_Scheme__c = 'True',
            Is_Make_model_Scheme__c = 'True',
            Profile__c = 'IB;NIB;Premium',
            Scheme_Type__c = 'Non-Pricing',
            Type_of_Customer__c = 'NTB;ETB;ETV',
            Type_of_employment__c = 'Farmer;Salaried;Self Employed',
            Type_of_loan__c = 'New;Used;Cash on Wheels',
            Vehicle_Usage__c = 'Personal',
            Customer_Type__c = 'I;NI',
            Collateral__c = '10101;10102;10108;10103;10104;10105;10106;10107;10109;10113;10111;10112;10114;10115;10116;10120;10121;10122;10123;10124;10125;10126;10127;10128;10117;10118;10119;10130;10131'
        ),true);

        Id recordTypeIdValue = Schema.SObjectType.Master_Junction_Mapping__c.getRecordTypeInfosByName().get('Scheme').getRecordTypeId();        
        Master_Junction_Mapping__c mjm1 = (Master_Junction_Mapping__c)TestFactory.createSObject(new Master_Junction_Mapping__c(
            Scheme__c = scheme1.Id,
            Territory__c = accInstance.Id,
            RecordTypeId = recordTypeIdValue
        ),true);  
        Master_Junction_Mapping__c state1 = (Master_Junction_Mapping__c)TestFactory.createSObject(new Master_Junction_Mapping__c(
            Scheme__c = scheme1.Id,
            Territory__c = stateInstance.Id,
            RecordTypeId = recordTypeIdValue
        ),true);  
        Master_Junction_Mapping__c reg1 = (Master_Junction_Mapping__c)TestFactory.createSObject(new Master_Junction_Mapping__c(
            Scheme__c = scheme1.Id,
            Territory__c = regInstance.Id,
            RecordTypeId = recordTypeIdValue
        ),true);  
        Master_Junction_Mapping__c dealer1 = (Master_Junction_Mapping__c)TestFactory.createSObject(new Master_Junction_Mapping__c(
            Scheme__c = scheme1.Id,
            Dealer__c = dealerInstance.Id,
            RecordTypeId = recordTypeIdValue
        ),true);    
        Master_Junction_Mapping__c mmvMap = (Master_Junction_Mapping__c)TestFactory.createSObject(new Master_Junction_Mapping__c(
            RecordTypeId = recordTypeIdValue
        ),true);    
        
        Deviation__c  dev = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Loan_Application__c  = loanAppl.id , Active__c  = true,Deviation_Type__c  ='COW-No HPN-Customer'
        ),true);
        
        ID modelRecTypeId=Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        ID makeRecTypeId=Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        ID varRecTypeId=Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Variant').getRecordTypeId();
        
        MMV_Master__c  makemvM = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c (
            Name='ZX MT_DIESEL2', RecordTypeId = makeRecTypeId
        ),true);
        
        MMV_Master__c  modelmvM = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c (
            Name='ZX MT_DIESEL1', RecordTypeId = modelRecTypeId , Make__c = makemvM.Id
        ),true); 
        
        MMV_Master__c  mmvM = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c (
            Name='ZX MT_DIESEL3',Make__c = makemvM.Id , Model__c = modelmvM.Id , RecordTypeId= varRecTypeId
        ),true);
        
        Id ltvRecordTypeId = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('LTV').getRecordTypeId();
        Id recordTypeIdValueExceptionDep = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('Territory Exception').getRecordTypeId();
        Id recordTypeIdValueDep = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
        Depreciated_Grid__c dep = (Depreciated_Grid__c)TestFactory.createSObject(new Depreciated_Grid__c(
            RecordTypeId= ltvRecordTypeId ,Customer_Grade__c = 'NIB' , Vehicle_Usage__c = 'Personal',Category__c ='A;B',
            Scheme__c = scheme1.Id, MMV__c = mmvM.Id
        ),true);
        
        Depreciated_Grid__c dep1 = (Depreciated_Grid__c)TestFactory.createSObject(new Depreciated_Grid__c(
            RecordTypeId= recordTypeIdValueExceptionDep ,Customer_Grade__c = 'NIB' , Vehicle_Usage__c = 'Personal',Category__c ='A;B',
            Scheme__c = scheme1.Id, MMV__c = mmvM.Id,Territory__c= accInstance.Id
        ),true);
        Depreciated_Grid__c dep2 = (Depreciated_Grid__c)TestFactory.createSObject(new Depreciated_Grid__c(
            RecordTypeId= recordTypeIdValueExceptionDep ,Customer_Grade__c = 'NIB' , Vehicle_Usage__c = 'Personal',Category__c ='A;B',
            Scheme__c = scheme1.Id, MMV__c = mmvM.Id,Territory__c= stateInstance.Id
        ),true);
        Depreciated_Grid__c dep3 = (Depreciated_Grid__c)TestFactory.createSObject(new Depreciated_Grid__c(
            RecordTypeId= recordTypeIdValueExceptionDep ,Customer_Grade__c = 'NIB' , Vehicle_Usage__c = 'Personal',Category__c ='A;B',
            Scheme__c = scheme1.Id, MMV__c = mmvM.Id,Territory__c= regInstance.Id
        ),true);
        Depreciated_Grid__c dep4 = (Depreciated_Grid__c)TestFactory.createSObject(new Depreciated_Grid__c(
            RecordTypeId= recordTypeIdValueExceptionDep ,Customer_Grade__c = 'NIB' , Vehicle_Usage__c = 'Personal',Category__c ='A;B',
            Scheme__c = scheme1.Id, MMV__c = mmvM.Id,Territory__c= dealerInstance.Id
        ),true);
        
        
        Collateral__c coll = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', Collateral_Name__c = '10103',
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'A', Ex_Showroom_Price_API__c = 1000,Valuation_Amount__c = '900',
            Vehicle_Cost__c = 1000, Other_Funding_Total__c = 100, MMV_Master__c = mmvM.Id, Fuel_Type__c = 'Petrol'
        ),true);
        Collateral__c fwLoan = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', Collateral_Name__c = '10103',
            Loan__c = fourWheelerLoan.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'A', Ex_Showroom_Price_API__c = 1000,Valuation_Amount__c = '900',
            Vehicle_Cost__c = 1000, Other_Funding_Total__c = 100, MMV_Master__c = mmvM.Id, Fuel_Type__c = 'Petrol', Collateral_Id__c = '10201123456789'
        ),true);
        
        Collateral__c tractorLoanColl = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', Collateral_Name__c = '10103',
            Loan__c = tractorLoan.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'A', Ex_Showroom_Price_API__c = 1000,Valuation_Amount__c = '900',
            Vehicle_Cost__c = 1000, Other_Funding_Total__c = 100, MMV_Master__c = mmvM.Id, Fuel_Type__c = 'Petrol'
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
        Integration_Master__c vahanIntMaster = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Vahaan API',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/Karza/VahanPaid',
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
        
        
        ID ibbRecTypeId=Schema.SObjectType.MMV_Mapping_Master__c.getRecordTypeInfosByDeveloperName().get('IBB').getRecordTypeId();
        MMV_Mapping_Master__c  mmvMs = (MMV_Mapping_Master__c)TestFactory.createSObject(new MMV_Mapping_Master__c (
            MMV__c=mmvM.Id, RecordTypeId = ibbRecTypeId
        ),true);

        Id recordTypeIdValueltv = Schema.SObjectType.LTV_Master__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
        Id recordTypeIdValueExceptionltv = Schema.SObjectType.LTV_Master__c.getRecordTypeInfosByName().get('Territory Exception').getRecordTypeId();        
        
        LTV_Master__c ltvMS = (LTV_Master__c)TestFactory.createSObject(new LTV_Master__c (
            MMV__c =mmvM.Id,
            RecordTypeId = recordTypeIdValueExceptionltv,
            Vehicle_Usage__c = 'Personal', 
            Scheme__c = scheme1.Id,
            Fuel_Type__c = 'Petrol',
            Territory__c = accInstance.Id,
            Category__c = 'A'
        ),true);
        
        LTV_Master__c ltvMS1 = (LTV_Master__c)TestFactory.createSObject(new LTV_Master__c (
            MMV__c =mmvM.Id,
            RecordTypeId = recordTypeIdValueExceptionltv,
            Vehicle_Usage__c = 'Personal', 
            Scheme__c = scheme1.Id,
            Fuel_Type__c = 'Petrol',
            Territory__c = stateInstance.Id,
            Category__c = 'A'
        ),true);
        
        LTV_Master__c ltvMS2 = (LTV_Master__c)TestFactory.createSObject(new LTV_Master__c (
            MMV__c =mmvM.Id,
            RecordTypeId = recordTypeIdValueExceptionltv,
            Vehicle_Usage__c = 'Personal', 
            Scheme__c = scheme1.Id,
            Fuel_Type__c = 'Petrol',
            Territory__c = regInstance.Id,
            Category__c = 'A'
        ),true);
        
        LTV_Master__c ltvMS3 = (LTV_Master__c)TestFactory.createSObject(new LTV_Master__c (
            MMV__c =mmvM.Id,
            RecordTypeId = recordTypeIdValueExceptionltv,
            Vehicle_Usage__c = 'Personal', 
            Scheme__c = scheme1.Id,
            Fuel_Type__c = 'Petrol',
            Territory__c = dealerInstance.Id,
            Category__c = 'A'
        ),true);
        
        Id recordTypeIdValuedlp = Schema.SObjectType.DLP_FMP_Master__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
        Id recordTypeIdValueExceptiondlp = Schema.SObjectType.DLP_FMP_Master__c.getRecordTypeInfosByName().get('Territory Exception').getRecordTypeId();        
        
        DLP_FMP_Master__c ltvDLP = (DLP_FMP_Master__c)TestFactory.createSObject(new DLP_FMP_Master__c (
            MMV__c =mmvM.Id,
            RecordTypeId = recordTypeIdValueExceptiondlp,
            Collateral_Type__c = '10103', 
            Fuel_Type__c = 'Petrol',
            Territory__c = accInstance.Id,
            Asset_Category__c = 'A'
        ),true);
        
        DLP_FMP_Master__c ltvDLP1 = (DLP_FMP_Master__c)TestFactory.createSObject(new DLP_FMP_Master__c (
            MMV__c =mmvM.Id,
            RecordTypeId = recordTypeIdValueExceptiondlp,
            Collateral_Type__c = '10103', 
            Fuel_Type__c = 'Petrol',
            Territory__c = stateInstance.Id,
            Asset_Category__c = 'A'
        ),true);
        
        DLP_FMP_Master__c ltvDLP2 = (DLP_FMP_Master__c)TestFactory.createSObject(new DLP_FMP_Master__c (
            MMV__c =mmvM.Id,
            RecordTypeId = recordTypeIdValueExceptiondlp,
            Collateral_Type__c = '10103', 
            Fuel_Type__c = 'Petrol',
            Territory__c = regInstance.Id,
            Asset_Category__c = 'A'
        ),true);
        
        DLP_FMP_Master__c ltvDLP3 = (DLP_FMP_Master__c)TestFactory.createSObject(new DLP_FMP_Master__c (
            MMV__c =mmvM.Id,
            RecordTypeId = recordTypeIdValueExceptiondlp,
            Collateral_Type__c = '10103', 
            Fuel_Type__c = 'Petrol',
            Territory__c = dealerInstance.Id,
            Asset_Category__c = 'A'
        ),true);
        
        Valuation__c val = (Valuation__c)TestFactory.createSObject(new Valuation__c (
            Reference_ID__c='12345'
        ),true);
        
        Address__c add = (Address__c)TestFactory.createSObject(new Address__c (
            Address_Type__c='Current',
            Applicant__c = appl.Id
        ),true);
        
         Integration_Master__c intmassearch3 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Bike Dekho Pricing',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaAddressMatchServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
    }
    @isTest
    public static void getLADetailsTest(){
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Collateral__c coll = [SELECT Id, Loan__c, Owner_Serial_number__c ,vehicle_color__c,Kilometer__c FROM Collateral__c LIMIT 1];
        test.startTest();
        AUSFVehicleController.deleteCollateral(coll.Id);
        AUSFVehicleController.getLoanApplicationDetails(loan.id);
        AUSFVehicleController.getTypeScreen('Auto Loan (Used)');
        AUSFVehicleController.getTypeScreen('Auto Loan (New)');
        //AUSFVehicleController.getVisibleFields('test','test','test','2-Wheeler');
        AUSFVehicleController.fetchBranchMasterRecord(loan.id);
        AUSFVehicleController.getVehicleDetails(coll.id,loan.Id);
        AUSFVehicleController.createVahanReport(loan.id);
        test.stopTest();
    }
    @isTest
    public static void getLADetailsTest1(){
        MMV_Mapping_Master__c objMMV = [Select Id,RecordType.Name,MMV__c, MMV__r.Name, MMV__r.Make__r.Name, MMV__r.Model__r.Name,Mapped_Make__c,Mapped_Model__c,Mapped_Variant__c from MMV_Mapping_Master__c WHERE MMV__c != ''];
        Collateral__c coll = [SELECT Id, Loan__c, Owner_Serial_number__c ,vehicle_color__c,Kilometer__c FROM Collateral__c LIMIT 1];
        Map<String,String> param = new Map<String,String>{'month'=>'April', 'year'=>'2011', 'location'=>'Mumbai', 'variant' =>objMMV.MMV__c,'make' => 'ZX MT_DIESEL2' , 'model' => 'ZX MT_DIESEL1'};
            test.startTest();
        test.setMock(HttpCalloutMock.class, new IBBCalloutMock());
        AUSFVehicleController.getIBBValue(param,coll);
        test.stopTest();
    }
    @isTest
    public static void getLADetailsTest3(){
        MMV_Mapping_Master__c objMMV = [Select Id,RecordType.Name,MMV__c, MMV__r.Name, MMV__r.Make__r.Name, MMV__r.Model__r.Name,Mapped_Make__c,Mapped_Model__c,Mapped_Variant__c from MMV_Mapping_Master__c WHERE MMV__c != ''];
        Collateral__c coll = [SELECT Id, Loan__c, Owner_Serial_number__c ,vehicle_color__c,Kilometer__c FROM Collateral__c LIMIT 1];
        Map<String,String> param = new Map<String,String>{'month'=>'April', 'year'=>'2011', 'location'=>'Mumbai', 'variant' =>objMMV.MMV__c,'make' => 'ZX MT_DIESEL2' , 'model' => 'ZX MT_DIESEL1'};
            test.startTest();
        test.setMock(HttpCalloutMock.class, new IBBCalloutMockFail());
        try{
            AUSFVehicleController.getIBBValue(param,coll);
        }Catch(Exception e){
            
        }
        test.stopTest();
    }
    @isTest
    public static void getLADetailsTest2(){
        Collateral__c coll = [SELECT Id, Loan__c, Owner_Serial_number__c, Chasis_Number__c ,Engine_Number__c, Vehicle_Number__c  ,vehicle_color__c,Kilometer__c FROM Collateral__c LIMIT 1];
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CollateralDedupeMock());
        AUSFVehicleController.getCollateralList(coll,loan.id);
        test.stopTest();
    }
    @isTest
    public static void getLADetailsTest4(){
        MMV_Mapping_Master__c objMMV = [Select Id,RecordType.Name,MMV__c, MMV__r.Name, MMV__r.Make__r.Name, MMV__r.Model__r.Name,Mapped_Make__c,Mapped_Model__c,Mapped_Variant__c from MMV_Mapping_Master__c WHERE MMV__c != ''];
        Collateral__c coll = [SELECT Id, Collateral_Name__c, Fuel_Type__c,Loan__c,IBB_Value__c, Other_Funding_Total__c, Valuation_Amount__c, Certified_Value__c, Vehicle_Cost__c,Owner_Serial_number__c ,vehicle_color__c,Kilometer__c, Scheme__c, Vehicle_Usage__c , Vehicle_Category__c, MMV_Master__c, Product__c FROM Collateral__c LIMIT 1];
        MMV_Master__c  mmvM = [SELECT ID FROM MMV_Master__c WHERE NAME ='ZX MT_DIESEL3'];
        Loan_Application__c loan = [SELECT Id,Branch_Master__c, Product__c , Customer_Type__c,Vehicle_use__c  FROM Loan_Application__c LIMIT 1];
        Applicant__c app = [SELECT Id,Type_of_Employment__c,Customer_Grade__c,Existing_Customer__c FROM Applicant__c LIMIT 1];
        Depreciated_Grid__c dep = [SELECT ID, Territory__r.recordTypeId FROM Depreciated_Grid__c LIMIT 1];
        Scheme_Master__c scheme1 =[SELECT ID FROM Scheme_Master__c LIMIT 1];
        Account acc = [SELECT ID,Account_Code__c FROM Account LIMIT 1];
        Valuation__c val = [SELECT ID,Reference_ID__c FROM Valuation__c LIMIT 1];
        test.startTest();
        AUSFVehicleController.getMmvRecord('ZX MT_DIESEL3');
        AUSFVehicleController.getSchemePickListValues(loan, app,'A','10103');
        AUSFVehicleController.getLtvMasterRecord(loan, JSON.serialize(coll));
        AUSFVehicleController.getLtvMasterRecordAgainstFMV(loan, JSON.serialize(coll));
        AUSFVehicleController.getDLPFMPMasterRecord(loan, JSON.serialize(coll));
        AUSFVehicleController.getDepreciatedObj (coll, app);
        AUSFVehicleController.getDepreciatedValue (coll, loan, '2023');
        AUSFVehicleController.getDepreciatedQuery('2023', dep.Id);
        AUSFVehicleController.getMatchAccCodeWithLoanCode(acc, dep);
        AUSFVehicleController.getSchemeMasterRecord(scheme1.Id);
        AUSFVehicleController.handleUpdateValuation(val.Reference_ID__c, 'Trigger', 10000);
        AUSFVehicleController.getApplicant(loan.Id);
        AUSFVehicleController.getCurrentAddressDetails(app.Id);
        AUSFVehicleController.getRegistrationCityPickListValues('Delhi');
        AUSFVehicleController.getUsedCategoryPickListValues('Maruti');
        //AUSFVehicleController.getVehicalCategory('Auto Loan (New)');
        AUSFVehicleController.getValueMasterDetails(loan.Id);
        AUSFVehicleController.getLoanSchemeMasterDetails(loan.Id);
        AUSFVehicleController.getCollateralDetails(coll.Id);
        AUSFVehicleController.getVariantIds(coll, new Set<ID>{mmvM.Id});
        Test.setMock(HttpCalloutMock.class, new BikeDekhoPricingMock());
        AUSFVehicleController.getPriceDetailsViaApiCall(loan.Id, '84', '784');
        AUSFVehicleController.getProductVsPriceTagConfigs();
        AUSFVehicleController.CollateralData collData = new AUSFVehicleController.CollateralData();
        AUSFVehicleController.getNewCategoryPickListValues(JSON.serialize(coll));
        AUSFVehicleController.calculateVehicleCost(coll);
        test.stopTest();
    }
    
    @isTest
    public static void getNewCategoryPickListValues4WTest(){
        Collateral__c coll = [SELECT Id, Loan__r.Product__c, Collateral_Name__c, Fuel_Type__c,Loan__c,IBB_Value__c, Other_Funding_Total__c, Valuation_Amount__c, 
                Certified_Value__c, Vehicle_Cost__c,Owner_Serial_number__c ,vehicle_color__c,Kilometer__c, Scheme__c, Vehicle_Usage__c , Vehicle_Category__c, 
                MMV_Master__c, Product__c FROM Collateral__c where Loan__r.Product__c = '10201' LIMIT 1]; 
        test.startTest();
        AUSFVehicleController.getNewCategoryPickListValues(JSON.serialize(coll));
        test.stopTest();
    }
    
    @isTest
    public static void getNewCategoryPickListValuesTractorTest(){
        Collateral__c coll = [SELECT Id, Loan__r.RecordType.Name, Collateral_Name__c, Fuel_Type__c,Loan__c,IBB_Value__c, Other_Funding_Total__c, Valuation_Amount__c, 
                Certified_Value__c, Vehicle_Cost__c,Owner_Serial_number__c ,vehicle_color__c,Kilometer__c, Scheme__c, Vehicle_Usage__c , Vehicle_Category__c, 
                MMV_Master__c, Product__c FROM Collateral__c where Loan__r.RecordType.Name = 'Tractor' LIMIT 1]; 
        test.startTest();
        AUSFVehicleController.getNewCategoryPickListValues(JSON.serialize(coll));
        test.stopTest();
    }

    @isTest static void verifyMmvRecordInvalidValue(){
        Test.startTest();
        AUSFVehicleController.getMmvRecord('^&*SOME_RANDOM_VALUE%^&*');
        Test.stopTest();
    }
    
    @isTest static void verifyCollateralCreationWithGUID(){
        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1].Id;
        
        Test.startTest();
        Collateral__c collateral = AUSFVehicleController.createCollateral( loanId, 'New' );
        Test.stopTest();
        
        Assert.isNotNull(collateral.Collateral_ID__c, 'Collateral Id should be generated');
        Assert.areEqual(16, collateral.Collateral_ID__c.length(), '16 digit unique GUID should be generated');
    }

    @isTest static void verifyCollateralCreationExistingNew(){
        
        Test.startTest();
        Loan_Application__c fourWheelerLoan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get(GlobalConstants.FOUR_WHEELER).getRecordTypeId()
        ),true);
        AUSFVehicleController.createCollateral( fourWheelerLoan.Id, 'New' );

        Test.stopTest();

    }

    @isTest static void verifyCollateralCreationExistingUsed(){
        
        Test.startTest();
        Loan_Application__c fourWheelerLoan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get(GlobalConstants.FOUR_WHEELER).getRecordTypeId()
        ),true);
        AUSFVehicleController.createCollateral( fourWheelerLoan.Id, 'Used' );

        Test.stopTest();

    }

    @isTest static void verifyCollateralCreation4WExisting(){
        
        Test.startTest();
        Loan_Application__c fourWheelerLoan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get(GlobalConstants.FOUR_WHEELER).getRecordTypeId()
        ),true);
        AUSFVehicleController.createCollateral( fourWheelerLoan.Id, 'Existing' );

        Test.stopTest();

    }
    
    @isTest static void verifyCollateralUpdates(){
        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1].Id;
        
        Test.startTest();
        Collateral__c collateral = AUSFVehicleController.createCollateral( loanId, 'New' );
        
        CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper enquiryInfo = new CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper();
        enquiryInfo.strCollateralUnusedValue = 100;
        enquiryInfo.strAmountCollValueCollCcy = 100;
        enquiryInfo.strLastValue = 100;
        enquiryInfo.strTotalArea = 100;
        enquiryInfo.strTotalCollateralValue = 1000000;
        enquiryInfo.isSelected = true;
        
        map<String, Object> respMap = AUSFVehicleController.upsertCollateral(
            new Collateral__c( Id = collateral.Id, Loan__c = collateral.Loan__c, Collateral_ID__c = collateral.Collateral_ID__c ),
            'New',
            new CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper[]{ enquiryInfo},null
        );
        Test.stopTest();
    }

    @isTest static void verifyCollateralUpdatesUsed(){
        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1].Id;
        
        Test.startTest();
        Collateral__c collateral = AUSFVehicleController.createCollateral( loanId, 'Used' );
        
        CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper enquiryInfo = new CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper();
        enquiryInfo.strCollateralUnusedValue = 100;
        enquiryInfo.strAmountCollValueCollCcy = 100;
        enquiryInfo.strLastValue = 100;
        enquiryInfo.strTotalArea = 100;
        enquiryInfo.strTotalCollateralValue = 1000000;
        enquiryInfo.isSelected = true;
        
        map<String, Object> respMap = AUSFVehicleController.upsertCollateral(
            new Collateral__c( Id = collateral.Id, Loan__c = collateral.Loan__c, Collateral_ID__c = collateral.Collateral_ID__c, Ex_Showroom_Price__c = 10, Ex_Showroom_Price_API__c = 10000 ),
            'Used',
            new CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper[]{ enquiryInfo },null
        );
        Test.stopTest();
    }
    
    @isTest static void verifyCollateralSoftDelete(){
        Test.startTest();
        Id collateralId = [ SELECT Id FROM Collateral__c WHERE Is_Deleted__c = FALSE LIMIT 1 ].Id;
        AUSFVehicleController.deleteCollateral( collateralId );
        Test.stopTest();
        
        Assert.isTrue( [ SELECT Is_Deleted__c FROM Collateral__c WHERE Id =: collateralId ].Is_Deleted__c, 'Collateral should be soft deleted' );
    }

    @isTest static void verifyCollateralSoftDeleteFail(){
        Test.startTest();
        try {
            AUSFVehicleController.deleteCollateral( [ SELECT Id FROM Loan_Application__c LIMIT 1].Id );
        } catch (Exception ex) {}
        Test.stopTest();
        
    }
    
    @isTest static void verifyCollateralHardDelete(){
        Test.startTest();
        Id collateralId = [ SELECT Id FROM Collateral__c WHERE Is_Deleted__c = FALSE LIMIT 1 ].Id;
        AUSFVehicleController.deleteCollateralRecord( collateralId );
        Test.stopTest();
        Assert.isTrue( [ SELECT Is_Deleted__c FROM Collateral__c WHERE Id =: collateralId ].isEmpty(), 'Collateral should be deleted from database' );
    }
    
    @isTest static void verifyGeneratedNumber(){
        String randomNumber = AUSFVehicleController.GenerateRandomNumber(15);
        AUSFVehicleController.getCollateralId('10201');
        Assert.areEqual(15, randomNumber.length(), '15 digit random number should be generated');
    }
    
    @isTest static void verifyVahanDetails(){
        
        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1 ].Id;
        HttpResponse resp = new HttpResponse();
        resp.setBody('{}');
        resp.setStatusCode( 200 );
        
        Test.setMock( HttpCalloutMock.class, new CalloutResponseMock( new map<String,HttpResponse>{
            'https://service.aubank.in/Karza/VahanPaid' => resp
                }) );
        
        Test.startTest();
        AUSFVahaanResponseWrapper vahanResponse = AUSFVehicleController.getVahaanDetail( 'HR12P0007', loanId );
        Test.stopTest();
    }
    @isTest static void verifyGeneratedCollateralID(){
        Collateral__c collateralRecord = [ SELECT Name, Loan__r.Product__c FROM Collateral__c LIMIT 1 ];
        Assert.areEqual(
            16,
            AUSFVehicleController.generateCollateralId( collateralRecord.Loan__r.Product__c, collateralRecord.Name ).length(),
            'Invalid collateral Id was generated'
        );
    }
    @isTest static void verifyNewFourWheelerCategoryValues(){
        Test.startTest();
        Collateral__c collateral = [ SELECT Product__c FROM Collateral__c WHERE Loan__r.RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ];

        AUSFVehicleController.getNewCategoryPickListValues(JSON.serialize(collateral));
        Test.stopTest();
    }
    @isTest static void verifyVisibleFields(){
        Test.startTest();
        AUSFVehicleController.getVisibleFields('New', 'QDE', 'Sales', 'Four Wheeler');
        Test.stopTest();
    }
    
    @isTest static void populateApplicationRelatedFieldsTest(){
        Test.startTest();
        Collateral__c collateral = [ SELECT Id FROM Collateral__c WHERE Loan__r.RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ];
        AUSFVehicleController.populateApplicationRelatedFields(collateral.Id);
        Test.stopTest();
    }
    
    @isTest static void createCollateralForCBSDataTest(){
        Test.startTest();
        Scheme_Master__c scheme1 = [Select id from Scheme_Master__c limit 1];
        MMV_Master__c mmvM = [Select id from MMV_Master__c limit 1];
        Loan_Application__c loan = [Select id from Loan_Application__c limit 1];
        
        Collateral__c collateral = new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', Collateral_Name__c = '10103',
            Loan__c = loan.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'A', Ex_Showroom_Price_API__c = 1000,Valuation_Amount__c = '900',
            Vehicle_Cost__c = 1000, Other_Funding_Total__c = 100, MMV_Master__c = mmvM.Id, Fuel_Type__c = 'Petrol'
        );
        AUSFVehicleController.createCollateralForCBSData(collateral);
        Test.stopTest();
    }
    
    @isTest static void createValuationDeviationTest(){
        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1 ].Id;
        Test.startTest();
        AUSFVehicleController.createValuationDeviation(new Deviation__c(Loan_Application__c = loanId), loanId, '');
        insert new Deviation__c(Loan_Application__c = loanId,Deviation_Type__c='S4-Valuation',Archived__c=false,Active__c=true);
        AUSFVehicleController.createValuationDeviation(new Deviation__c(Loan_Application__c = loanId), loanId, 'New');
        insert new Deviation__c(Loan_Application__c = loanId,Deviation_Type__c='S4-Valuation',Archived__c=false,Active__c=true);
        AUSFVehicleController.createValuationDeviation(new Deviation__c(Loan_Application__c = loanId), loanId, 'Archive');
        Test.stopTest();
    }
    
    @isTest static void getTypeOfWheelerTest(){
        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1 ].Id;
        Test.startTest();
        AUSFVehicleController.getTypeOfWheeler('10103');
        AUSFVehicleController.getTypeOfWheeler('10202');
        AUSFVehicleController.getTypeOfWheeler('10502');
        AUSFVehicleController.getTypeOfWheeler('10301');
        //AUSFVehicleController.getTypeOfWheeler('1030112');
        AUSFVehicleController.getScreenType('New');
        AUSFVehicleController.getScreenType('Used');
        AUSFVehicleController.getScreenType('Other');
        AUSFVehicleController.getScreenType('New',false);
        AUSFVehicleController.getScreenType('Used',false);
        AUSFVehicleController.getScreenType('Cash on Wheels',false);
        AUSFVehicleController.getScreenType('Other',false);
        AUSFGenericApiFailureResponse obj = new AUSFGenericApiFailureResponse();
        Test.stopTest();
    }
    
    @IsTest
    static void testGenerateLeadRequest(){
        Map < String, Object > reqParam = new Map < String, Object > ();
        
        reqParam.put('channel', 'SFDC');  //cbs //June14
        reqParam.put('vehicle_cat', '1'); //1
        reqParam.put('cus_veh_regno', 'TN717251414'); //TN717251414 //valuationRecord.Vehicle_Number__c
        reqParam.put('cus_mobile', '9078123456'); //9078123456
        reqParam.put('cus_name', 'Test'); //Test
        reqParam.put('cus_pincode', '600041'); //600041
        reqParam.put('cus_address', 'Chennai'); //Chennai
        reqParam.put('executive_name', 'Test'); //Test
        reqParam.put('executive_mobile', '9089123490'); //9089123490
        reqParam.put('cus_email', 'Test@gm.com'); //Test@gm.com
        reqParam.put('veh_mmv', 'test');
        reqParam.put('prospect_no','KKK191278186514'); //KKK191278186514  //'SFDC'+randomNumber
        reqParam.put('valuator_name', '12345'); // federationId
        reqParam.put('requestId','12345');
        Test.startTest();
        List<String> testString = AUSFVehicleHandler.generateLeadRequest(reqParam);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testGenerateRejectRequest(){
        Map < String, Object > reqParam = new Map < String, Object > ();
        
        reqParam.put('channel', 'SFDC');  //cbs //June14
        reqParam.put('RequestNo', 'SFDC');  //cbs //June14
        reqParam.put('channel', 'SFDC');  //cbs //June14
        
        reqParam.put('RejectedRemark','12345');
        Test.startTest();
        List<String> testString = AUSFVehicleHandler.generateRejectRequest(reqParam);
        Test.stopTest();
        
    }
    @isTest static void getMMV(){
        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1 ].Id;
        MMV_Master__c makeinstnace = [SELECT id,Name FROM MMV_Master__c WHERE Name = 'ZX MT_DIESEL2'];
        Test.startTest();
        String vehicle = GlobalConstants.COMMERCIALVEHICLE;
        AUSFVehicleController.getPickListCVValues(makeinstnace.Name,'',vehicle,'Make','10103','','','10104');
        Test.stopTest(); 
    }
     @isTest static void getMMV1(){
        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1 ].Id;
        MMV_Master__c makeinstnace = [SELECT id,Name FROM MMV_Master__c WHERE Name = 'ZX MT_DIESEL2'];
        Test.startTest();
        String vehicle = GlobalConstants.COMMERCIALVEHICLE;
        AUSFVehicleController.getPickListCVValues(makeinstnace.Name,'',vehicle,'Make','10103','','','10101');
        Test.stopTest(); 
    }
    @isTest static void vehicle(){
        Loan_Application__c loan = [ SELECT Id FROM Loan_Application__c LIMIT 1 ];
        
        Test.startTest();
        String vehicle = GlobalConstants.COMMERCIALVEHICLE;
        AUSFVehicleController.getApplicantFinancials(loan);
        Test.stopTest(); 
    }
     @isTest static void vehicleInt(){
        Collateral__c collateralInstance = [ SELECT Id FROM Collateral__c LIMIT 1 ];
        List<String> collateralList = new List<String>();
         collateralList.add(collateralInstance.Id);
        Test.startTest();
        String vehicle = GlobalConstants.COMMERCIALVEHICLE;
        AUSFVehicleController.deleteExistingCollateral(collateralList);
         AUSFVehicleController.populateApplicationRelatedFields(collateralInstance.Id);
        Test.stopTest(); 
    }
    @isTest static void getApplicantCurrentCityTest(){
        Test.startTest();
        AUSFVehicleController.getApplicantCurrentCity( new Set<Id>() );
        Test.stopTest();
    }
    @isTest static void verifyOtherTypeOfVehicle(){
        Test.startTest();
        AUSFVehicleController.TypeOfWheeler typeOfWheeler = AUSFVehicleController.getTypeOfWheeler( '12305' );
        Test.stopTest();
        Assert.isTrue( typeOfWheeler.isOther, ' 12305 is Product code for Other (Agri Loan)' );
    }

    @isTest static void validateChargeAmountExceedingFunding(){

        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1 ].Id;
        String[] lsCharges = Label.LoanSurakshaChargeCode.split(';\\s*');
        Charge__c chargeIns  = (Charge__c)TestFactory.createSObject(new Charge__c (
            Charges_Name__c = 'LS Charge',
            Sequence_NO__c = 1,
            Total_Amount__c = 3000,
            Charge_Amount__c = 6000,
            SC_Code__c = lsCharges[0],
            Loan_Application__c = loanId
        ),true);

        Collateral__c newCollateral = new Collateral__c( LS__c = 'Yes', LS_Value__c = '5000' );
        Collateral__c oldCollateral = new Collateral__c( LS__c = 'Yes', LS_Value__c = '10000' );

        Test.startTest();
        AUSFVehicleController.validateIfChargeAmountExceedsFunding( loanId, newCollateral, oldCollateral, Label.AUSFNewScreen );
        Test.stopTest();
    }

    @isTest static void validateFundingAmountExceedingCharges(){

        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1 ].Id;
        String[] lsCharges = Label.LoanSurakshaChargeCode.split(';\\s*');
        Charge__c chargeIns  = (Charge__c)TestFactory.createSObject(new Charge__c (
            Charges_Name__c = 'LS Charge',
            Sequence_NO__c = 1,
            Total_Amount__c = 3000,
            Charge_Amount__c = 3000,
            SC_Code__c = lsCharges[0],
            Loan_Application__c = loanId
        ),true);

        Collateral__c newCollateral = new Collateral__c( LS__c = 'Yes', LS_Value__c = '5000' );
        Collateral__c oldCollateral = new Collateral__c( LS__c = 'Yes', LS_Value__c = '10000' );

        Test.startTest();
        try{
            AUSFVehicleController.validateIfChargeAmountExceedsFunding( loanId, newCollateral, oldCollateral, Label.AUSFNewScreen );
        } catch(Exception ex){
            Assert.areEqual( String.format( Label.ChargeAmountExceededMessage, new String[]{ 'Loan Suraksha' } ), ex.getMessage(), 'Funding should not exceed LS Charges' );
        }
        Test.stopTest();
    }

    @isTest static void verifyIfLoanSourcedInSF(){
        Test.startTest();
        Collateral__c collateral = AUSFVehicleController.checkIfLoanSourcedInSF( '10201123456789' );
        Test.stopTest();

        Assert.isNotNull(collateral, 'Collateral matching CBS Id should be returned');
    }
    @isTest static void verifyIfLoanSourcedInSFFailure(){
        Test.startTest();
        Collateral__c collateral = AUSFVehicleController.checkIfLoanSourcedInSF( '12312323' );
        Test.stopTest();

        Assert.isNull(collateral, 'Collateral should have been null since invalid id was passed' );
    }

    @isTest static void verifyAddressWhenInvalidDetailsArePassed(){
        Test.startTest();
        Address__c[] addresses = AUSFVehicleController.getCurrentAddressDetails( null );
        Test.stopTest();

        Assert.isNull( addresses, 'No addresses should be returned because invalid details were passed' );
    }
    @isTest static void getDepricatedTractorMasterRecordTest(){
        Test.startTest();
        Depreciated_Grid__c ltvMaster = AUSFVehicleController.getDepricatedTractorMasterRecord( new Loan_Application__c(), JSON.serialize( new Collateral__c()) );
        Test.stopTest();
        //Assert.isNotNull( ltvMaster, 'LTV - Record from Depreciated Master should be returned' );
    }


    public class CalloutResponseMock implements HttpCalloutMock{
        map<String, HttpResponse> responseMap;
        public CalloutResponseMock(map<String, HttpResponse> responseMap){
            this.responseMap = responseMap;
        }
        
        public HttpResponse respond( HttpRequest req ){
            return responseMap.get( req.getEndpoint() );
        }
    }
    
    @isTest static void checkForExistingLeadCollateralTest(){
        Collateral__c coll = [SELECT Id, Loan__r.Product__c, Collateral_Name__c, Fuel_Type__c,Loan__c,IBB_Value__c, Other_Funding_Total__c, Valuation_Amount__c, 
                Certified_Value__c, Vehicle_Cost__c,Owner_Serial_number__c ,vehicle_color__c,Kilometer__c, Scheme__c, Vehicle_Usage__c , Vehicle_Category__c, 
                MMV_Master__c, Product__c FROM Collateral__c where Loan__r.Product__c = '10201' LIMIT 1]; 
        test.startTest();
            AUSFVehicleController.checkForExistingLeadCollateral(coll.Loan__c, false);
        test.stopTest();
    }
    
    @isTest
    public static void getLADetailsFailureTest(){
        Collateral__c coll = [SELECT Id, Loan__c, Owner_Serial_number__c, Chasis_Number__c ,Engine_Number__c, Vehicle_Number__c  ,vehicle_color__c,Kilometer__c FROM Collateral__c LIMIT 1];
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        test.startTest();
        test.setMock(HttpCalloutMock.class, new CollateralDedupeMockFailure());
        AUSFVehicleController.getCollateralList(coll,loan.id);
        test.stopTest();
    }
}