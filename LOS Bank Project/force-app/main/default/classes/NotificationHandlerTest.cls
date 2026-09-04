@isTest
public class NotificationHandlerTest {
    @testSetup static void setup() {
        //Account Insertion
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            
            Account accInstance = (Account )TestFactory.createSObject(new Account (
                Name ='TestAccount',
                Account_Code__c='2103',
                Branch_Queue__c=grp.Id
            ),true); 
            
            User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                                lastName = 'test2',
                                                                profileId = prof.id,
                                                                username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test@test.com',
                                                                Branch_Code__c  = '2103'
                                                               ),true);
            AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id,
                UserId=usr.Id,
                TeamMemberRole = 'Branch Manager'
            ),true);   
            AccountTeamMember atm1 = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id,
                UserId=usr.Id,
                TeamMemberRole = 'Team Lead'
            ),true);   
            
            AccountTeamMember atm2 = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id,
                UserId=usr.Id,
                TeamMemberRole = 'FI'
            ),true);   
            //Scheme Insertion
            Scheme_Master__c scheme = (Scheme_Master__c )TestFactory.createSObject(new Scheme_Master__c (
                Scheme_Name__c ='Normal',
                Type_of_loan__c ='Used'
            ),true);
            
            //Loan Application Insertion
            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                Application_Number__c  = 'AP-12345',
                Adhar_Card__c   = 123456,
                Loan_Amount__c  = 1000,
                Product__c='10201',
                Stage__c ='Credit',
                Wheels_Exposure__c=500,
                Scheme__c =scheme.Id,
                Branch_Master__c =accInstance.Id,
                Final_Exposure__c =1000
            ),true);
            
            
            
            
            
            /*AccountTeamMember teamMember = (AccountTeamMember)TestFactory.createSObject(new Account(
AccountId = accountInstance.Id,
TeamMemberRole = 'Branch Manager'
),true);*/
            
            
            //Applicant Insertion
            Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                First_Name__c = 'Vikash',
                Middle_Name__c = 'Kumar',
                Last_Name__c = 'Mandal',
                Loan__c =loanAppl.Id,
                Mobile_Number__c ='8106255555',
                PAN__c ='EXFPK4321K',
                CIF_No__c ='12345678',
                Voter_Id__c='1241214',
                Passport_Number__c='12411414',
                Driving_License_Id__c='3555535xfr',
                Aadhaar_Number__c='60123214141',
                Customer_Type__c='Individual',
                Email__c ='ashish@gmail.com',
                SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]'
                
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
                Type__c='Bungalow'
            ),true);
            
            //MMV Insertion
            MMV_Master__c mmvMaster = (MMV_Master__c )TestFactory.createSObject(new MMV_Master__c (
                Name ='Test',
                //            Collateral_Name__c ='Car',
                Collateral_Type__c ='Automobile'
            ),true);
            
            
            
            // Collateral Insertion
            Collateral__c  collateral = (Collateral__c )TestFactory.createSObject(new Collateral__c (
                Loan__c =loanAppl.Id,
                // Name ='CollateralTest',
                Scheme__c =scheme.Id,
                MMV_Master__c =mmvMaster.Id,
                Vehicle_Number__c='TN12345567',
                Certified_Value__c='1234',
                Collateral_Name__c ='10108'
            ),true);
            
            Collateral__c  collateral1 = (Collateral__c )TestFactory.createSObject(new Collateral__c (
                Loan__c =loanAppl.Id,
                //  Name ='CollateralTest1',
                Scheme__c =scheme.Id,
                MMV_Master__c =mmvMaster.Id,
                Vehicle_Number__c='TN12346568',
                Certified_Value__c='1000001',
                Collateral_Name__c ='10108'
            ),true);
            
            Collateral__c  collateral2 = (Collateral__c )TestFactory.createSObject(new Collateral__c (
                Loan__c =loanAppl.Id,
                //  Name ='CollateralTest2',
                Scheme__c =scheme.Id,
                MMV_Master__c =mmvMaster.Id,
                Vehicle_Number__c='TN12346569',
                Certified_Value__c='0',
                Collateral_Name__c ='10108'
            ),true);
            
            Document_Master__c master = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (  
                Name ='AUWheels0014'
            ),true);            
            
            Document_CheckList__c checklist = (Document_CheckList__c )TestFactory.createSObject(new Document_CheckList__c (
                Collateral__c  = collateral2.Id,
                Document_Master__c=master.Id
            ),true);
            
            
            
            //Valuation Insertion
            Valuation__c valuation = (Valuation__c) TestFactory.createSObject(new Valuation__c (
                Reference_ID__c='ValTest',
                Action__c='Trigger',
                Collateral__c= collateral2.Id,
                Valuation_Amount__c=1000,
                isLatest__c = true,
                Response_Received__c ='Yes',
                Cando_Request_Id__c='Req1'
            ),true);
            
            Valuation__c valuation1 = (Valuation__c) TestFactory.createSObject(new Valuation__c (
                Reference_ID__c='ValTest1',
                Action__c='Trigger',
                Collateral__c= collateral2.Id,
                Valuation_Amount__c=1000,
                Cando_Request_Id__c = 'Req1',
                Response_Received__c ='Yes'
            ),true);
            
            
            
            
            //Generic Master Insertion
            Generic_Master__c genericMaster = (Generic_Master__c )TestFactory.createSObject(new Generic_Master__c (
                State__c='ParentAccount',
                Account_No__c =1234455
            ),true);
            
            //CBS Loan Type
            Id cbsRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CBS').getRecordTypeId();
            Bank_Account_Records__c cbsAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
                Applicant__c = appl.Id,
                Account_Type__c = 'Loan',
                Loan_Amount__c =10000,
                EMI_Amount__c =2000,
                RecordTypeId = cbsRecordTypeId,
                Account_Opening_Date__c = System.today()-368
            ),true);
            Bank_Account_Records__c cbsAccountInstance1 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
                Applicant__c = appl.Id,
                Account_Type__c = 'Loan',
                Loan_Amount__c =20000,
                Account_Number__c='AC-123',
                EMI_Amount__c =2000,
                POS__c=100,
                Sanctioned_Amount__c=100,
                Product_Code__c='10201',
                RecordTypeId = cbsRecordTypeId,
                Account_Opening_Date__c = System.today()-368
            ),true);
            
            //ODCC Account
            Bank_Account_Records__c odccAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
                Applicant__c = appl.Id,
                Account_Type__c = 'ODCC',
                Loan_Amount__c =1000,
                EMI_Amount__c =200,
                RecordTypeId = cbsRecordTypeId,
                Account_Opening_Date__c = System.today()
            ),true);
            Bank_Account_Records__c odccAccountInstance2 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
                Applicant__c = appl.Id,
                Account_Type__c = 'ODCC',
                Loan_Amount__c =1000,
                EMI_Amount__c =200,
                RecordTypeId = cbsRecordTypeId,
                Account_Opening_Date__c = System.today()
            ),true);
            
            //CASA Account
            Bank_Account_Records__c casaAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
                Applicant__c = appl.Id,
                Account_Type__c = 'CASA',
                Loan_Amount__c =1000,
                EMI_Amount__c =200,
                RecordTypeId = cbsRecordTypeId,
                Account_Opening_Date__c = System.today()
            ),true);
            Bank_Account_Records__c casaAccountInstance2 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
                Applicant__c = appl.Id,
                Account_Type__c = 'CASA',
                Loan_Amount__c =1000,
                EMI_Amount__c =200,
                RecordTypeId = cbsRecordTypeId,
                Account_Opening_Date__c = System.today()
            ),true);
            
            //CC Account
            Bank_Account_Records__c ccAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
                Applicant__c = appl.Id,
                Account_Type__c = 'CC',
                Loan_Amount__c =5000,
                EMI_Amount__c =200,
                RecordTypeId = cbsRecordTypeId,
                Sanctioned_Amount__c=100,
                Product_Code__c='10201',
                Account_Number__c='CC-123',
                Account_Opening_Date__c = System.today()
            ),true);
            Bank_Account_Records__c ccAccountInstance2 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
                Applicant__c = appl.Id,
                Account_Number__c ='9001070130327270',
                Account_Type__c = 'CC',
                Loan_Amount__c =1000,
                EMI_Amount__c =200,
                RecordTypeId = cbsRecordTypeId,
                Account_Opening_Date__c = System.today()
            ),true);
            
            //SMS Integration Master
            Integration_Master__c inMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
                Name ='SMS Notification',
                End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/SFDCCcommunication/SendSMS',
                Apiuser__c ='SFDC',
                API_Key__c ='epikey',
                HTTP_Method__c='POST',
                Timeout__c='120000',
                Active__c = true
            ),true);
            
            //EMAIL Integration Master
            Integration_Master__c emailMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
                Name ='Email Notification',
                End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/SFDCCommunication/Email',
                Apiuser__c ='SFDC',
                API_Key__c ='epikey',
                HTTP_Method__c='POST',
                Timeout__c='120000',
                Active__c = true
            ),true);
            
            //Whatsapp Integration Master
            Integration_Master__c whatsappMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
                Name ='Whatsapp Notification',
                End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/WhatsappCongoService/SingleEvent',
                Apiuser__c ='SFDC',
                API_Key__c ='epikey',
                HTTP_Method__c='POST',
                Timeout__c='120000',
                Active__c = true
            ),true);
            
        }
    }
    
    @isTest
    public static void notification(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        List<AccountTeamMember> teamlist =[SELECT id, TeamMemberRole, User.Name, User.Phone, UserId, User.MobilePhone, User.Email
                                           FROM AccountTeamMember
                                          ];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Lead Create',loanInstance.Id,'');
        Test.stopTest();
    }
    
    @isTest
    public static void DONotification(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        List<AccountTeamMember> teamlist =[SELECT id, TeamMemberRole, User.Name, User.Phone, UserId, User.MobilePhone, User.Email
                                           FROM AccountTeamMember
                                          ];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('DO Cancellation',loanInstance.Id,'');
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void credit(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        String msg = UserInfo.getUserId() +'@'+ 'L1' + '@' +UserInfo.getUserId();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Credit Manual assignment', loanInstance.Id , msg);
        Test.stopTest();
        
    }
    
    @isTest
    public static void CreditNotification(){
        
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        List<Loan_Application_Approval__c> approvalList = new List<Loan_Application_Approval__c>();
        
        
        
        Loan_Application_Approval__c approvalInstance = new Loan_Application_Approval__c();
        approvalInstance.Loan_Application__c =loanInstance.Id;
        approvalInstance.Type__c ='Base';
        approvalInstance.Approver__c =Userinfo.getUserId();
        insert approvalInstance;
        approvalList.add(approvalInstance);
        
        Loan_Application_Approval__c approvalInstance1 = new Loan_Application_Approval__c();
        approvalInstance1.Loan_Application__c =loanInstance.Id;
        approvalInstance1.Type__c ='Middle';
        approvalInstance1.Approver__c =Userinfo.getUserId();
        insert approvalInstance1;
        approvalList.add(approvalInstance1);
        
        
        Loan_Application_Approval__c approvalInstance2 = new Loan_Application_Approval__c();
        approvalInstance2.Loan_Application__c =loanInstance.Id;
        approvalInstance2.Type__c ='Highest';
        approvalInstance2.Approver__c =Userinfo.getUserId();
        insert approvalInstance2;
        approvalList.add(approvalInstance2);
        String approvers = JSON.serialize(approvalList);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Credit Submission(L0)',loanInstance.Id,approvers);
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void CreditNotification1(){
        
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        String userId =Userinfo.getUserId();
        User user = [SELECT id,Name FROM user where id=:userId];
        List<Loan_Application_Approval__c> approvalList = new List<Loan_Application_Approval__c>();
        
        
        
        
        
        Loan_Application_Approval__c approvalInstance1 = new Loan_Application_Approval__c();
        approvalInstance1.Loan_Application__c =loanInstance.Id;
        approvalInstance1.Type__c ='Middle';
        approvalInstance1.Approver__c =user.Id;
        insert approvalInstance1;
        approvalList.add(approvalInstance1);
        
        
        Loan_Application_Approval__c approvalInstance2 = new Loan_Application_Approval__c();
        approvalInstance2.Loan_Application__c =loanInstance.Id;
        approvalInstance2.Type__c ='Highest';
        approvalInstance2.Approver__c =user.Id;
        insert approvalInstance2;
        approvalList.add(approvalInstance2);
        String approvers = JSON.serialize(approvalList);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Credit Submission (N)',loanInstance.Id,approvers);
        Test.stopTest();
        
        
    }
    
    
    
    @isTest
    public static void PricingNotification1(){
        
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        String userId =Userinfo.getUserId();
        User user = [SELECT id,Name FROM user where id=:userId];
        List<Loan_Application_Approval__c> approvalList = new List<Loan_Application_Approval__c>();
        
        
        
        
        
        Loan_Application_Approval__c approvalInstance1 = new Loan_Application_Approval__c();
        approvalInstance1.Loan_Application__c =loanInstance.Id;
        approvalInstance1.Type__c ='Middle';
        approvalInstance1.Approver__c =user.Id;
        insert approvalInstance1;
        approvalList.add(approvalInstance1);
        
        
        Loan_Application_Approval__c approvalInstance2 = new Loan_Application_Approval__c();
        approvalInstance2.Loan_Application__c =loanInstance.Id;
        approvalInstance2.Type__c ='Highest';
        approvalInstance2.Approver__c =user.Id;
        
        insert approvalInstance2;
        approvalList.add(approvalInstance2);
        String approvers = JSON.serialize(approvalList);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Pricing (N-1)',loanInstance.Id,'Highest');
        Test.stopTest();
        
        
    }
    
  /*  @isTest
    public static void welcomeletter(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Document_Checklist__c checklist = new Document_Checklist__c();
        checklist.Document_Name__c = 'Welcome Letter';
        checklist.Loan_Application__c  = loanInstance.Id;
        insert checklist;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            Request_id__c ='Req1',
            VersionData = Blob.valueOf('Test Content'),
            Origin = 'H'
        );
       // insert contentVersion;    
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = checklist.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        
        Test.startTest();
       NotificationHandler.getWelcomeLetter(loanInstance.Id);
        Test.stopTest();
        
    }*/
    
    @isTest
    public static void notification2(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        String msg = UserInfo.getUserId() +'@'+ 'L1' + '@' +UserInfo.getUserId();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Lead assigned to RO', loanInstance.Id , '');
        NotificationHandler.sendNotification('Valuation initiate', loanInstance.Id , '');
        
        NotificationHandler.sendNotification('Valuation Submission', loanInstance.Id , '');
        NotificationHandler.sendNotification('Valuation Query', loanInstance.Id , '');
        NotificationHandler.sendNotification('Valuation Retrigger', loanInstance.Id , '');  
        Test.stopTest();
        
    }
    @isTest
    public static void notification222(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        String msg = UserInfo.getUserId() +'@'+ 'L1' + '@' +UserInfo.getUserId();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        
        
        NotificationHandler.sendNotification('Valuation Submission', loanInstance.Id , '');
       
        Test.stopTest();
        
    }
    
    @isTest
    public static void creditSendback(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        String userId =Userinfo.getUserId();
        User user = [SELECT id,Name FROM user where id=:userId];
        List<Loan_Application_Approval__c> approvalList = new List<Loan_Application_Approval__c>();
        
        
        
        
        
        Loan_Application_Approval__c approvalInstance1 = new Loan_Application_Approval__c();
        approvalInstance1.Loan_Application__c =loanInstance.Id;
        approvalInstance1.Type__c ='Middle';
        approvalInstance1.Approver__c =user.Id;
        approvalInstance1.Remarks__c ='Testing';
        insert approvalInstance1;
        approvalList.add(approvalInstance1);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Credit sendback', loanInstance.Id , '');  
        Test.stopTest();        
    }
    
    @isTest 
    public static void notification3(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        String msg ='test'+'@@@'+'test1' +'@@@'+ 'test2';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Partial Disbursment', loanInstance.Id , 'Test');  
        NotificationHandler.sendNotification('FI Stage Completion', loanInstance.Id , msg);  
        
        Test.stopTest();
        
        
    }
    
    @isTest 
    public static void notification4(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('FI Revoke', loanInstance.Id , '');  
        NotificationHandler.sendNotification('SI intiation', loanInstance.Id , '');  
        
        Test.stopTest();
        
        
    }    
    
    @isTest
    public static void notification5(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('ON loan sanction', loanInstance.Id , '');  
        Test.stopTest();
    }
    
    @isTest
    public static void notification6(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Other Valuation initiate', loanInstance.Id , '');
        Test.stopTest();
    }
    @isTest
    public static void notification62(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('PDD Rejection', loanInstance.Id , '');
        Test.stopTest();
    }
    @isTest
    public static void notification7(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('PDD COMPLETION', loanInstance.Id , '');
        Test.stopTest();
    }
    @isTest
    public static void notification81(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('DO generation', loanInstance.Id , '');
        Test.stopTest();
    }
    @isTest
    public static void notification8(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Case Rejection', loanInstance.Id , '');
        Test.stopTest();
    }
    @isTest
    public static void notification9(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Valuation Revoke', loanInstance.Id , '');
        Test.stopTest();
    }
    @isTest
    public static void notification10(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('FI Retrigger', loanInstance.Id , '');
        Test.stopTest();
    }
    
    @isTest
    public static void notification11(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Ops submission', loanInstance.Id , '');
        Test.stopTest();
    }
    @isTest
    public static void notification12(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('E-mandate/eNach', loanInstance.Id , '');
        Test.stopTest();
    }
     @isTest
    public static void notification13(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('ON Disbursement', loanInstance.Id , '');
        Test.stopTest();
    }
     @isTest
    public static void notification14(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Payment release', loanInstance.Id , '');
        Test.stopTest();
    }
	
	//recent

	 @isTest
    public static void notification15(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Trigger Approval', loanInstance.Id , '');
        Test.stopTest();
    }    
     @isTest
    public static void notification16(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('DDE Submission', loanInstance.Id , '');
        Test.stopTest();
    } 
    
     @isTest
    public static void notification17(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('if Case under STP', loanInstance.Id , '');
        Test.stopTest();
    }    
     @isTest
    public static void notification178(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Pricing Approval', loanInstance.Id , '');
        Test.stopTest();
    }   
    @isTest
    public static void notification18(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('PDD stage', loanInstance.Id , '');
        Test.stopTest();
    }  
    @isTest
    public static void notification199(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('PDD Pending', loanInstance.Id , '');
        Test.stopTest();
    } 
    @isTest
    public static void notification19(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('SI intiation', loanInstance.Id , '');
        Test.stopTest();
    }  
    @isTest
    public static void notification20(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('E-sign initiation', loanInstance.Id , '');
        Test.stopTest();
    }  
    @isTest
    public static void notification21(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('E sign', loanInstance.Id , '');
        Test.stopTest();
    }  
     @isTest
    public static void notification22(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('ON vehicle delivery', loanInstance.Id , '');
        Test.stopTest();
    }  
    @isTest
    public static void notification23(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailCalloutMock());
        Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
        NotificationHandler.sendNotification('Welcome letter (NEW)', loanInstance.Id , '');
        Test.stopTest();
    }  

    
   
    
    
    
}