@isTest
public class MapMyIndiaDistanceControllerTest {
	public class MapMyIndiaDistanceResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'Application/json');
            res.setBody('{"Server":"DE-5400","version":"202302.221.5223","results":{"distances":[[0,240531.4]],"code":"Ok","durations":[[0,11872.4]]},"responseCode":200}');
            res.setStatusCode(200);
            return res;    
        }
    }
    @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
           	Account_Code__c='2103',
           	Branch_Queue__c=grp.Id
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
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Map My India Distance',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/FicoBREService',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
    }
     @isTest
    public static void getAadhaarNumApiTest(){
         Test.startTest();
        list<Applicant__c> LA = New list<applicant__c>();
        Applicant__c appl = [SELECT ID FROM Applicant__c LIMIT 1];
        LA.add(appl);
        test.setMock(HttpCalloutMock.class, new MapMyIndiaDistanceResponse());
        MapMyIndiaDistanceResponseWrap wrap=new MapMyIndiaDistanceResponseWrap();
        wrap.Server=null;
        wrap.version=null;
        MapMyIndiaDistanceResponseWrap.ResultsWrap reqwrap=new  MapMyIndiaDistanceResponseWrap.ResultsWrap();
        reqwrap.code=null;
        reqwrap.durations=null;
        MapMyIndiaDistanceController.getLatLongAddressDistance('77.68796549154507,28.96470062944797',appl.id,'Satta guest house, Datta gest house ke samane, Au bank, RAJASTHAN, Bharatpur, 321001',null);
        MapMyIndiaDistanceController.generateRequest(LA);
        MapMyIndiaDistanceController.generateJSONResponse(LA);
    	        Test.stopTest();
    }
    
}