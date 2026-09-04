@isTest
public class BitlyKarixTest {
    
    @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c ='DDE',
            Wheels_Exposure__c=500,
            Final_Exposure__c =1000
        ),true);
        //Applicant Record Type Id
        
        Id applicantRecordTypeId = Schema.SObjectType.Applicant__c .getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Loan__c =loanAppl.Id,
            Mobile_Number__c ='8106255685',
            PAN__c ='EXFPK4321K',
            CIF_No__c ='12345678',
            Voter_Id__c='1241214',
            Passport_Number__c='12411414',
            Driving_License_Id__c='3555535xfr',
            Aadhaar_Number__c='60123214141',
            Customer_Type__c='Individual',
            RecordTypeId = applicantRecordTypeId,
            SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]'
            
        ),true);
        
        Collateral__c  collateral2 = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppl.Id,
            Vehicle_Number__c='TN12346569',
            Certified_Value__c='0',
            Collateral_Name__c ='10108'
        ),true);
        
        
        
        //Valuation Insertion
        Valuation__c valuation = (Valuation__c) TestFactory.createSObject(new Valuation__c (
            Reference_ID__c='ValTest',
            Action__c='Trigger',
            Collateral__c= collateral2.Id,
            Valuation_Amount__c=1000,
            isLatest__c = true,
            Response_Received__c ='Yes'
        ),true);
        
         //Bitly Karik Integration Master
        Integration_Master__c KarixURLShortner = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Karix URL Shortner',
            End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/KarixURLShortnerRestService',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        
    }
    
    @isTest
    public static void generateReq(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Valuation__c valInstance = [SELECT id,Reference_ID__c
                                    FROM Valuation__c
                                    WHERE Reference_ID__c ='ValTest'];  
        
        Applicant__c applicantRecord = [SELECT id,First_Name__c,Loan__c,SF_Exposure_JSON__c,Loan__r.Loan_Amount__c,Loan__r.Product__c 
                                        FROM Applicant__c
                                        WHERE First_Name__c ='Vikash'];
        
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=valInstance.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        //ContentDistribution cont = new ContentDistribution();
        /*ContentDistribution cont = new ContentDistribution(); 
        cont.RelatedRecordId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title='Header_Picture1'].Id;
        insert cont;*/
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BitlyKarixCalloutMock());
        BitlyKarix.sendKarixRequest('8190000000','www.publicurlctestwttwtw',applicantRecord.Id,content.Id);
        Test.stopTest();
        
        
        
    }
}