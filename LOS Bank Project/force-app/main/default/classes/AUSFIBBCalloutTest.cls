@isTest
public class AUSFIBBCalloutTest {
    @testSetup static void setup() {
        //Loan Application Insertion
        
        
        /*
        * causes unable to lock row
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); */
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103'
            // Branch_Queue__c=grp.Id
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id
        ),true);
        
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103'
                                                           ),true);
        list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id , Approval_Status__c ='Pending' , Is_Assigned_Approver__c = true
        ),false);
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id , Approval_Status__c ='Pending' , Is_Assigned_Approver__c = true
        ),false);
        lstLoanAppApproval.add(loanAppApproval);
        insert lstLoanAppApproval;
         
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id
        ),false);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
         Document_Checklist__c docChkRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c    = appl.Id
        ),true);
         
        /*AccountTeamMember accTeamMember = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Branch Manager', accountId = accInstance.id, Active__c = true, UserId =usr.id
        ),true);*/
        Collateral__c coll = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', Loan__c = loanAppl.id
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
            Name='ZX MT_DIESEL1',Make__c = makemvM.Id , Model__c = modelmvM.Id , RecordTypeId= varRecTypeId
        ),true);
       
        ID ibbRecTypeId=Schema.SObjectType.MMV_Mapping_Master__c.getRecordTypeInfosByDeveloperName().get('IBB').getRecordTypeId();
        MMV_Mapping_Master__c  mmvMs = (MMV_Mapping_Master__c)TestFactory.createSObject(new MMV_Mapping_Master__c (
            MMV__c=mmvM.Id, RecordTypeId = ibbRecTypeId
        ),true);
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'IBB',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/SFDCIBBService/GetIBBValue',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
                                        
    } 
 
    @isTest
    public static void getLADetailsTest(){
        MMV_Mapping_Master__c objMMV = [Select Id,RecordType.Name,MMV__c, MMV__r.Name, MMV__r.Make__r.Name, MMV__r.Model__r.Name,Mapped_Make__c,Mapped_Model__c,Mapped_Variant__c from MMV_Mapping_Master__c WHERE MMV__c != ''];
        Collateral__c coll = [SELECT Id, Owner_Serial_number__c,vehicle_color__c, Kilometer__c FROM Collateral__c LIMIT 1];
        system.debug('objMMV-- '+ JSON.serializePretty(objMMV));
        Map<String,String> param = new Map<String,String>{'month'=>'April', 'year'=>'2011', 'location'=>'Mumbai', 'variant' =>objMMV.MMV__c,'make' => 'ZX MT_DIESEL2' , 'model' => 'ZX MT_DIESEL1'};
        AUSFIBBCalloutController objCls = new AUSFIBBCalloutController();
        AUSFIBBCalloutController.getRequestBody(param,coll);
    }
}