@IsTest
public class FieldInvestigationUtilityTest {
    
    @testSetup
    static void testDataSetup(){

        String profileId = [SELECT Id, Name FROM Profile WHERE Name='Credit Manager' LIMIT 1].Id;
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Credit_User'];
        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            
            Account accInstance = (Account )TestFactory.createSObject(new Account (
                Name ='TestAccount',
                Account_Code__c='1111',
                Branch_Queue__c=grp.Id
            ),true); 

        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1',
            lastName = 'test2',
            profileId = profileId,
            username = 'test'+UserInfo.getOrganizationId()+'@testcredit2.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
            ),true);

            AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id,
                UserId=usr.Id,
                TeamMemberRole ='Credit',
                Zip_Code__c='110053',
                Approver_Level__c = 'L1',
                Deviation_Level__c = 'S0;S1',
                Product__c = '10201;10202;10203;10204;10205;10206;10401;10402;10403;10104;10105;10106;10101;10102;10103;10501;10502;10503'
                
            ),true);

            AccountTeamMember atmUser = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id,
                UserId=UserInfo.getUserId(),
                TeamMemberRole ='Credit',
                Zip_Code__c='110053',
                Approver_Level__c = 'L2',
                Deviation_Level__c = 'S0;S1',
                Product__c = '10201;10202;10203;10204;10205;10206;10401;10402;10403;10104;10105;10106;10101;10102;10103;10501;10502;10503'
                
            ),true);
        
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);

        
        
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10201',
            ROI__c = 17.0,
            EMI__c = 13,
            Branch_Master__c = accInstance.id
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            Customer_Name__c = 'Vikash Kumar Mandal',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),true);
        
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = loanAppl.Id,
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10
        ),true);
        
        Address__c testAddressRec = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'test address1',
            Address_Line_2__c = 'test address2',
            Address_Line_3__c = 'Existing ',
            State__c = '123456Test',
            City__c = 'testcity',
            District__c = 'testDisc',
            Pincode__c = 'testPincode',
            Applicant__c = appl.Id,
            Address_Type__c = 'Current'
            
        ),true);
        Address__c testAddressRecPerm = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'test address1',
            Address_Line_2__c = 'test address2',
            Address_Line_3__c = 'Existing ',
            State__c = '123456Test',
            City__c = 'testcity',
            District__c = 'testDisc',
            Pincode__c = 'testPincode',
            Applicant__c = appl.Id,
            Address_Type__c = 'Permanent'
            
        ),true);

        Address__c testAddressRecTouch = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'test address1',
            Address_Line_2__c = 'test address2',
            Address_Line_3__c = 'Existing ',
            State__c = '123456Test',
            City__c = 'testcity',
            District__c = 'testDisc',
            Pincode__c = 'testPincode',
            Applicant__c = appl.Id,
            Address_Type__c = 'Touch Point'
            
        ),true);
        Field_Investigation__c fieldInvestigationObj = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = appl.Customer_Name__c,
            Loan_Application__c =loanAppl.Id,
            Address_lookup__c=testAddressRec.id,
            Applicant__c=appl.Id,
            FI_Status__c ='In Progress',
            FI_Agent__c = null,
            Type_of_address__c = GlobalConstants.CURRENT,
            //Credit_Manager__c = usr.Id,
            Applicant_Type__c='Applicant' )),true);
        
        Field_Investigation__c fieldInvestigationObj2 = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = appl.Customer_Name__c,
            Loan_Application__c =loanAppl.Id,
            Address_lookup__c=testAddressRecPerm.id,
            Applicant__c=appl.Id,
            FI_Status__c ='In Progress',
            FI_Agent__c = null,
            Type_of_address__c = GlobalConstants.PERMANENT,
            //Credit_Manager__c = usr.Id,
            Applicant_Type__c='Applicant' )),true);
        
        Field_Investigation__c fieldInvestigationObj3 = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = appl.Customer_Name__c,
            Loan_Application__c =loanAppl.Id,
            Address_lookup__c=testAddressRecPerm.id,
            Applicant__c=appl.Id,
            FI_Status__c ='In Progress',
            FI_Agent__c = null,
            Type_of_address__c = GlobalConstants.TOUCHPOINT,
            //Credit_Manager__c = usr.Id,
            Applicant_Type__c='Applicant' )),true);
        }
    }
    
    @IsTest
    public static void testGetFISummary1(){
        
        Test.startTest();
        String loanId = [Select Id From Loan_Application__c LIMIT 1].Id;
        List<FISummaryViewWrapper> retWrapper1 = FieldInvestigationUtility.getFISummary(loanId, '');
        Test.stopTest();
        
    }
    
    @IsTest
    public static void testGetFISummary2(){
        
        Test.startTest();
        String applId = [SELECT Id FROM Applicant__c LIMIT 1].Id;
        List<FISummaryViewWrapper> retWrapper2 = FieldInvestigationUtility.getFISummary('', applId);
        Test.stopTest();
        
    }
    
    @IsTest
    public static void testGetFISummary3(){
        Test.startTest();
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123456',
            Adhar_Card__c   = 1234567,
            Loan_Amount__c  = 10000,
            Product__c = '10202',
            ROI__c = 17.0,
            EMI__c = 13
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Ajay',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            Customer_Name__c = 'Vikash Kumar Mandal',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),true);
        
        Field_Investigation__c fieldInvestigationObj2 = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = appl.Customer_Name__c,
            Loan_Application__c =loanAppl.Id,
            Applicant__c=appl.Id,
            FI_Status__c ='In Progress',
            FI_Agent__c = null,
            Type_of_address__c = GlobalConstants.OFFICE,
            //Credit_Manager__c = usr.Id,
            Applicant_Type__c='Applicant' )),true);
        
        
        
            String loanId = [Select Id From Loan_Application__c LIMIT 1].Id;
            String applId = [SELECT Id FROM Applicant__c LIMIT 1].Id;
            List<FISummaryViewWrapper> retWrapper1 = FieldInvestigationUtility.getFISummary(loanId, '');
        Test.stopTest();
        
    }
    
    @IsTest
    public static void testCreateFiRecord(){
        
        Test.startTest();
        Address__c address = [Select Id,Applicant__r.Loan__c,Applicant__r.Customer_Name__c,
                              Applicant__r.DOB__c, Applicant__r.Gender__c, Applicant__r.Father_Name__c, Applicant__r.Mobile_Number__c, Applicant__c, Applicant__r.Loan__r.Branch_Master__c,
                              Applicant__r.Loan__r.Branch_Master__r.Account_Code__c, Applicant__r.Loan__r.Product__c, Applicant__r.Loan__r.RecordType.DeveloperName,
                              Applicant__r.Loan__r.Loan_Amount__c, Address_Type__c, Pincode__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c,City__c,
                              State__c, District__c, Area_Name__c, Applicant__r.Date_of_Establishment__c, Applicant__r.Key_Contact_Name__c,Applicant__r.RecordType.Name
                              From Address__c LIMIT 1];
        
        Collateral__c collateral = [SELECT Id FROM Collateral__c LIMIT 1];
        Map<String,String> paramMap = new Map<String,String>();
        paramMap.put(address.Applicant__c,'Test Value');
        
        Field_Investigation__c fiRecord = FieldInvestigationUtility.createFiRecord(address, collateral, paramMap);
        //List<FISummaryViewWrapper> retWrapper2 = FieldInvestigationUtility.getFISummary('', applId);
        Test.stopTest();
        system.assertEquals(fiRecord!=null, true);
        
    }
    
    @IsTest
    public static void testMatchAddress(){
        
        Test.startTest();
        List<Address__c> addresses = [Select Id,Applicant__r.Loan__c,Applicant__r.Customer_Name__c,
                                      Applicant__r.DOB__c, Applicant__r.Gender__c, Applicant__r.Father_Name__c, Applicant__r.Mobile_Number__c, Applicant__c, Applicant__r.Loan__r.Branch_Master__c,
                                      Applicant__r.Loan__r.Branch_Master__r.Account_Code__c, Applicant__r.Loan__r.Product__c, 
                                      Applicant__r.Loan__r.Loan_Amount__c, Address_Type__c, Pincode__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c,City__c,
                                      State__c, District__c, Area_Name__c, Applicant__r.Date_of_Establishment__c, Applicant__r.Key_Contact_Name__c,Applicant__r.RecordType.Name
                                      From Address__c];
        Boolean resp = FieldInvestigationUtility.matchAddress(addresses[0], addresses[1]);
        Test.stopTest();
    }
        
    @IsTest
    public static void testgetZipCodeWithAssignUserCreditManager() {
        Set<String> setAccountId = new Set<String>{'1111'};
        
        Test.startTest();
            FieldInvestigationUtility.getZipCodeWithAssignUserCreditManager('', 'Credit', '', setAccountId, true,'10201');
        Test.stopTest();
    }
    
    @IsTest
    public static void testgetZipCodeWithAssignFIAgent() {
        Set<String> zipcode = new Set<String>{'348438'};
        Set<String> setAccountId = new Set<String>{'102102'};
        
        String accountRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account acct1 = new Account();
        acct1.Name = 'Account 1';
        acct1.Account_Code__c = '102102';
        acct1.RecordTypeId = accountRecordTypeID;
        insert acct1;
        
        Profile profId= [Select Id from profile where Name='Field Investigator']; 
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User user = new User(  firstname = 'Test',
                                lastName = '123',
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                IsActive = true,
                             // User.Profile.Name = 'Field Investigator',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId.Id);
        insert user;
        
        String brFldInvMstrRecordTypeID = Schema.getGlobalDescribe().get('Branch_Field_Investigation_Master__c').getDescribe().getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
        Branch_Field_Investigation_Master__c branchFldInvMstr = new Branch_Field_Investigation_Master__c();
        branchFldInvMstr.Pin_Code__c = '348438';
        branchFldInvMstr.Is_Active__c = true;
        branchFldInvMstr.Branch_Name__c = acct1.Id;
        branchFldInvMstr.FI_Agent__c = user.Id;
        branchFldInvMstr.RecordTypeId = brFldInvMstrRecordTypeID;
        insert branchFldInvMstr;
        
        Test.startTest();
            FieldInvestigationUtility.getZipCodeWithAssignFIAgent('Account', zipcode, '32243', setAccountId, false);
            FieldInvestigationUtility.getZipCodeWithAssignFIAgent('Account', zipcode, '32243', setAccountId, false, 'Two_Wheeler');
        Test.stopTest();
    }     

    @IsTest
    public static void testGetFISummaryPositive(){
        
        Test.startTest();
            String loanId = [Select Id From Loan_Application__c LIMIT 1].Id;
            List<Field_Investigation__c> lstFieldInv = new List<Field_Investigation__c>();
            for (Field_Investigation__c obj : [Select Id, FI_Status__c, FI_Profile_Status__c, Stage__c from Field_Investigation__c where Applicant__r.Loan__c =: loanId]) {
                obj.FI_Status__c = 'Positive';
                obj.FI_Profile_Status__c = 'Positive';
                obj.Stage__c = 'Closed';
                lstFieldInv.add(obj);
            }
            update lstFieldInv;   
            List<FISummaryViewWrapper> retWrapper1 = FieldInvestigationUtility.getFISummary(loanId, '');
        Test.stopTest();
        
    }

    @IsTest
    public static void testGetFISummaryWaived(){
        
        Test.startTest();
            String loanId = [Select Id From Loan_Application__c LIMIT 1].Id;
            List<Field_Investigation__c> lstFieldInv = new List<Field_Investigation__c>();
            for (Field_Investigation__c obj : [Select Id, FI_Status__c, FI_Profile_Status__c, Stage__c from Field_Investigation__c where Applicant__r.Loan__c =: loanId]) {
                obj.FI_Status__c = 'Waived Off';
                obj.FI_Profile_Status__c = 'Waived Off';
                obj.Stage__c = 'Closed';
                lstFieldInv.add(obj);
            }
            update lstFieldInv;
             
            List<FISummaryViewWrapper> retWrapper1 = FieldInvestigationUtility.getFISummary(loanId, '');
        Test.stopTest();
        
    }

    @IsTest
    public static void testGetFISummaryAssigned(){
        Test.startTest();
            String loanId = [Select Id From Loan_Application__c LIMIT 1].Id;
            List<Field_Investigation__c> lstFieldInv = new List<Field_Investigation__c>();
            for (Field_Investigation__c obj : [Select Id, FI_Status__c, FI_Profile_Status__c, Stage__c from Field_Investigation__c where Applicant__r.Loan__c =: loanId]) {
                obj.FI_Status__c = '';
                obj.FI_Profile_Status__c = 'Assigned';
                obj.Stage__c = 'Assigned';
                lstFieldInv.add(obj);
            }
            update lstFieldInv;
             
            List<FISummaryViewWrapper> retWrapper1 = FieldInvestigationUtility.getFISummary(loanId, '');
        Test.stopTest();
        
    }
    
    @IsTest
    static void testHandleCaseRejectOnFI(){
        Test.startTest();
        Loan_Application__c loanApp = [Select Id From Loan_Application__c LIMIT 1];
        String fiId = [SELECT Id, Loan_Application__c FROM Field_Investigation__c WHERE Loan_Application__c=:loanApp.Id LIMIT 1].Id;
        Deviation__c appl = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Deviation_Type__c = 'FI Negative',
            Loan_Application__c = loanApp.Id,
            Field_Investigation__c = fiId,
            Source__c = 'Manual',
            Level__c = 'S4'
        ),true);
        Map<Id,Loan_Application__c> loanMap = new Map<Id,Loan_Application__c>();
        loanMap.put(loanApp.Id, loanApp);
        FieldInvestigationUtility.handleCaseRejectOnFI(loanMap);
        Test.stopTest();
    }
        

    /*
    @IsTest
    public static void testsetBaseCMApproverMap(){
        Test.startTest();
            List<AccountTeamMember> lstATM = [Select Id, UserId, Approver_Level__c, Account.Account_Code__c from AccountTeamMember];
            FieldInvestigationUtility.setBaseCMApproverMap (lstATM);
        Test.stopTest();
        
    }
    */
}