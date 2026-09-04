@isTest
public with sharing class KarzaNameMatchTest {
    
    public class NameMatchCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"requestId" : "34678hYYt","result" : {"score" : 0.0,"result" : true},"statusCode" : 101}');
            return res;
        }
        
    }
    
    @TestSetup
    public static void makeData(){
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Karza Name Match',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/SFDCKarzaService/NameMatch',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345'
        ),true); 
        
        
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Naruto',
            Loan__c = loanAppl.Id,
            Aadhaar_Name__c='Naruto',
            CBS_Name__c='Naruto',
            Aadhaar_Number__c='234234',
            Customer_Name__c = 'Test'
        ),true); 
        
        
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', Vehicle_Category__c ='TestCat'
        ),true);
        Collateral__c coll = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'TestCat'
        ),true);
    }
    
    @isTest
    public static void testPNGControllerMethod1(){
        Applicant__c app = [SELECT Id,CBS_Name__c FROM Applicant__c LIMIT 1];
        app.CBS_Name__c = '';
        update app;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','Bank Statement',applId,collId);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testPNGControllerMethod2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','Collateral',applId,collId);
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod3(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','Vahaan',applId,collId);
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod4(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','Electricity bill',applId,collId);
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod5(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','Gas bill',applId,collId);
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod6(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','Driving Licence',applId,collId);
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod7(){
        Applicant__c app = [SELECT Id,CBS_Name__c FROM Applicant__c LIMIT 1];
        app.CBS_Name__c = '';
        update app;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','null',applId,collId);
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod8(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','Pan',applId,collId);
        Test.stopTest();
    }
    @isTest
    public static void testPNGControllerMethod9(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','PNG bill',applId,collId);
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod10(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','Passport',applId,collId);
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod11(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NameMatchCallout());  
        String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
        String collId = String.valueOf([SELECT Id FROM Collateral__c ].Id);
        String objWrapper = LOSKarzaNameMatchController.validateNameMatch('Naruto','Voter ID Card',applId,collId);
        Test.stopTest();
        
    }
}