@isTest
public class ShareRecordsAccessUpateBatchTest {
    @testSetup static void setup() {
        
        
               Profile prof = [select Id,Name from profile where name like '%Credit%'];
 
        Location_Master__c  lcMaster = (Location_Master__c )TestFactory.createSObject(new Location_Master__c (
            Name ='110053',
            Area_Name__c ='JAGJIT NAGAR',
            Area_Type__c ='Urban',  
            City__c ='EAST DELHI',
            State__c ='MAHARASHTRA',
            Taluka__c ='NA',
            Zip_Code__c = '110053'  
        ),true);
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Pincode__c = lcMaster.Id
        ),true);
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Product_Accessible__c='All 2W'	,                                              
                                                            Branch_Code__c  = '2103'
                                                           ),true);        
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301 ',
            Branch_Master__c =accInstance.Id
            
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Customer_Type__c ='Individual',
            Residential_Status__c ='Resident',
            Loan__c =loanAppl.Id
            
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
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Permanent',
            Type__c='Bungalow'
        ),true);
        
        Address__c  addInstance1 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline11',
            Address_Line_2__c ='TestAddressline22',
            Address_Line_3__c ='TestAddressline33',
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
            Address_Type__c='Touch Point',
            Type__c='Bungalow'
        ),true);
        
        
        
        
        
        
    }
    
    @isTest static void loactionsMethod1() {
        User u=[select id from user where email='test@test.com'];
        Account a=[select id from account where Name ='TestAccount' ];
        Map<Id,List<Id>> branchUserMap=new Map<Id,List<Id>>();
        List<Id> userIds=new List<Id>();
        userIds.add(u.Id);
        branchUserMap.put(a.Id,userIds);
        Test.startTest();
        ShareRecordsAccessUpateBatch sh=new ShareRecordsAccessUpateBatch(branchUserMap,new Map<Id,List<Id>>());
        Database.executeBatch(sh);
        Test.stopTest();
        
        
    }

    @isTest static void loactionsMethod2() {
        User u=[select id from user where email='test@test.com'];
        Account a=[select id from account where Name ='TestAccount' ];
        Map<Id,List<Id>> branchUserMap=new Map<Id,List<Id>>();
        List<Id> userIds=new List<Id>();
        userIds.add(u.Id);
        branchUserMap.put(a.Id,userIds);
        Test.startTest();
        ShareRecordsAccessUpateBatch sh=new ShareRecordsAccessUpateBatch(new Map<Id,List<Id>>(),branchUserMap);
        Database.executeBatch(sh);
        Test.stopTest();
        
        
    }    
    
}