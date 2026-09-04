@isTest
public class AUSFOEMApprovalAssignmentTest {

    @testSetup static void setup() 
    {
        Profile prof = [select Id,Name from profile where name like '%Sales Manager%'];
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        List<User> loanUser = new List<User>();
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
          lastName = 'test2',
          profileId = prof.id,
          username = 'test'+UserInfo.getOrganizationId()+'@test.com',
          email = 'test@test.com',
          Branch_Code__c  = '2103'
      ),false);
      loanUser.add(usr);
      /*
      User usr1 = (User)TestFactory.createSObject(new User(firstName = 'test1',
          lastName = 'test2',
          profileId = prof.id,
          username = 'test1'+UserInfo.getOrganizationId()+'@test.com',
          email = 'test@test.com',
          Branch_Code__c  = '2103'
      ),false);
      loanUser.add(usr1);*/
      insert loanUser;
        
        Id regionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        Account regInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount1',
            Account_Code__c='2104',
            Branch_Queue__c=grp.Id,
            RecordTypeId = regionRecordTypeId
        ),true);
        
        List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();
        AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
          AccountId =regInstance.Id,
          UserId=loanUser[0].Id,
          Collateral__c = '10101;10102;10108;10103;10104;10105;10106;10107;10109;10110;10113;10111;10112;10114;10115;10116;10120;10121;10122;10123;10124;10125;10126;10127;10128;10117;10118;10119;10130;10131;10134;10132;10133',
          Customer_Grade__c = 'IB;NIB;Premium;CIBIL Surrogate;Banking Surrogate;Marginal Farmer;Small Farmer;Large Farmer;FTU;FT;Transporter;Captive;FTB;Contractor;Hirer;Mining',
          Product__c = '10201;10202;10203;10301;10302;10303;10204;10205;10206;10401;10402;10403;10104;10105;10106;10101;10102;10103;10501;10502;10503',
          Type_of_Employment__c = 'Business;Salaried - Private;Salaried - Government;Unemployed;Retired - Pensioner;Housewife;Retired - Non-Pensioner;Farmer;Self Employed Non-Professional;Self Employed Professional',
          Approver_Level__c = 'P6',
          TeamMemberRole = 'Region Head (RBM)'
         ),false);   
         lstAccountTeamMember.add(atm);
         /*
         AccountTeamMember atm2 = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
          AccountId =regInstance.Id,
          UserId=loanUser[1].Id,
          Collateral__c = '10101;10102;10108;10103;10104;10105;10106;10107;10109;10110;10113;10111;10112;10114;10115;10116;10120;10121;10122;10123;10124;10125;10126;10127;10128;10117;10118;10119;10130;10131;10134;10132;10133',
          Customer_Grade__c = 'IB;NIB;Premium;CIBIL Surrogate;Banking Surrogate;Marginal Farmer;Small Farmer;Large Farmer;FTU;FT;Transporter;Captive;FTB;Contractor;Hirer;Mining',
          Product__c = '10201;10202;10203;10301;10302;10303;10204;10205;10206;10401;10402;10403;10104;10105;10106;10101;10102;10103;10501;10502;10503',
          Type_of_Employment__c = 'Business;Salaried - Private;Salaried - Government;Unemployed;Retired - Pensioner;Housewife;Retired - Non-Pensioner;Farmer;Self Employed Non-Professional;Self Employed Professional',
          Approver_Level__c = 'P6',
          TeamMemberRole = 'Region Head (RBM)'
         ),false);      
         lstAccountTeamMember.add(atm2);  */ 
         insert lstAccountTeamMember;
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id,
            Region__c=regInstance.Id
        ),true);
        
        List<Loan_Application__c> loanList = new List<Loan_Application__c>();
        RecordType rd=[select id from RecordType where name='Two Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='QDE',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id ,
            Customer_Grade__c = 'NIB',
            Branch_Master__c = accInstance.Id
        ),false);
        loanList.add(loanAppl);
        RecordType rd1=[select id from RecordType where name='Four Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl1 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='QDE',
            Final_Exposure__c =10,
            RecordTypeId=rd1.Id            
        ),false);
        loanList.add(loanAppl1);
        Loan_Application__c loanAppl2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='DDE',
            Final_Exposure__c =10,
            RecordTypeId=rd1.Id
        ),false);
        loanList.add(loanAppl2);
         Loan_Application__c loanAppl3 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='Credit',
            Final_Exposure__c =10,
            RecordTypeId=rd1.Id,
            Sanction_Status__c = 'Issued'
        ),false);
        loanList.add(loanAppl3);
        insert loanList;
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanList[0].Id,Type_of_Employment__c = 'Farmer',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Collateral__c coll = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', Collateral_Name__c = '10103',
            Loan__c = loanList[0].id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' ,
            Vehicle_Category__c  = 'A', Ex_Showroom_Price_API__c = 1000,Valuation_Amount__c = '900',
            Vehicle_Cost__c = 1000, Other_Funding_Total__c = 100, Fuel_Type__c = 'Petrol'
        ),true);
    }
    
    @isTest
    static void assignmentTest()
    {
        List<String> loanList = new List<String>();
        Map<String,String> loanId_LetterTypeMap = new Map<String,String>();
        List<Loan_Application__c> loanAppList = [SELECT Id FROM Loan_Application__c];
        
        for(Loan_Application__c loanApp : [SELECT Id FROM Loan_Application__c])
        {
            loanList.add(loanApp.Id);
            loanId_LetterTypeMap.put(loanApp.Id,'Customer Signatures');
        }
        
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppList[0].Id,  Approval_Type__c = 'Pricing' , Approver__c = UserInfo.getUserId(), Type__c = 'Base',
            Archived__c = false
        ),true); 
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppList[1].Id,  Approval_Type__c = 'Credit' , Approver__c = UserInfo.getUserId(), Type__c = 'Base',
            Archived__c = false
        ),true);
        Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                First_Name__c = 'Vikash',
                Middle_Name__c = 'Kumar',
                Last_Name__c = 'Mandal',
                Loan__c =loanAppList[0].Id,
                Customer_Name__c='Vikas',
                Customer_Type__c='Individual',
                Type_Of_Employment__c = 'Farmer',
                Customer_Grade__c = 'IB',
                RecordTypeId = applicantRecordTypeId
            ),true);
        Id collateralUsedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        Collateral__c coll1 = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppList[0].id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Collateral_Name__c = '10102',
            Vehicle_Category__c  = 'TestCat', RecordTypeId = collateralUsedRecordTypeId,Manufacture_year_month__c='202304'
        ),true);
        AUSFOEMApprovalAssignment.getListOfRBMApprovals(loanList);
    }
    /*
    @isTest static void verifyListOfApprovals(){
        AccountTeamMember atm = new AccountTeamMember( Approver_Level__c = 'L7', Deviation_Level__c = 'S6', UserId = UserInfo.getUserId() );
        Test.startTest();
        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1 ].Id;

        Loan_Application_Approval__c[] approvals = AUSFOEMApprovalAssignment.getListOfApprovals( atm, new String[]{ loanId }, new map<String, AccountTeamMember>(), null, new map<String, String>(), null, true );
        Test.stopTest();
        
        Assert.areEqual(
            1,
            approvals.size(),
            'An Approval should be raised to the NBM / RBM'
        );
    }*/
}