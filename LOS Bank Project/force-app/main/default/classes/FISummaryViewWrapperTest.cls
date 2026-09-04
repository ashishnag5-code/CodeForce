@isTest
public class FISummaryViewWrapperTest{
@isTest
    public static void TestMethod1(){
        Test.startTest();
        
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
            SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]'
            
        ),true);
        
        FISummaryViewWrapper ob = new FISummaryViewWrapper();
        ob.entity =
        ob.partyName = 'testParty';
        ob.currentAddress = 'address1';
        ob.bkcurrentAddress = 'bkcurrentAddress1';
        ob.permanentAddress = 'perma1';
        ob.bkpermanentAddress = 'bkpermanentAddress1';
        ob.officeAddress = 'offic Address1';
        ob.bkofficeAddress = 'bkofficeAddress1';
        ob.tpAddress = 'tpaddress1';
        ob.bktpAddress = 'bktpAddress1';
        ob.finalStatus = 'Success';
        ob.bkfinalStatus = 'bkfinalStatus1';
        ob.reportLink = 'reportLink';
        ob.reportLinkForCurrentAddress = 'reportLinkForCurrentAddress11';
        ob.reportLinkForPermanentAddress = 'reportLinkForPermanentAddress1';
        ob.reportLinkForOfficeAddress = 'reportLinkForOfficeAddress1';
        ob.reportLinkForTPAddress = 'reportLinkForTPAddress1';
        ob.applicantName = 'applicantName1';
        ob.currentAddressAgency = 'currentAddressAgency1';
        ob.permanentAddressAgency = 'permanentAddressAgency1';
        ob.officeAddressAgency = 'officeAddressAgency1';
        ob.tpAddressAgency = 'tpAddressAgency1';
        ob.fiRecordId = 'fiRecordId1';
        ob.fiReportLink = 'fiReportLink1';
        ob.applicantId = appl.Id;
        Test.stopTest();
        
    }
}