@isTest
public with sharing class KarzaAddressMatchTest {
    
    public class AddressMatchCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"result":{"flags":[{"address":{"scores":[{"score":0.19,"match":false,"refernce2":"TARGET_0","refernce1":"SOURCE_0"},{"score":0.17,"match":false,"refernce2":"TARGET_1","refernce1":"SOURCE_0"}],"matchType":"FUZZY_ADDRESS_MATCH"},"relationName":{"scores":[{"score":1,"match":true,"refernce2":"TARGET_0","refernce1":"SOURCE_0"}],"matchType":"FUZZY_INDIVIDUAL_NAME_MATCH"},"dob":{"matchType":"DOB_MATCH","match":true},"name":{"score":1,"matchType":"FUZZY_INDIVIDUAL_NAME_MATCH","match":true},"referenceId":"SFDCSIT_e03f1f47ad25265a9e2b50d54"}]},"requestId":"7900708b-6a5c-4257-9ee5-4f47fcfede2b","statusCode":101}');
            return res;
        }
        
    }
    
    @TestSetup
    public static void makeData(){
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Karza Multiple Address Match',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaAddressMatchServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Product__c = '10202'
        ),true); 
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Caroline',
            Last_Name__c = 'Forbes',
            Loan__c = loanAppl.Id
        ),true); 
        
        Address__c address2 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'A',
            Address_Line_2__c = 'B',
            Address_Line_3__c = 'C',
            Address_Type__c = 'Current',
            State__c = 'Goa',
            City__c = 'Ponda',
            Pincode__c='403404',
            Applicant__c=appl.Id
        ),true);
        Address__c address3 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'A',
            Address_Line_2__c = 'B',
            Address_Line_3__c = 'C',
            Address_Type__c = 'Permanent',
            State__c = 'Goa',
            City__c = 'Ponda',
            Source_Type__c = 'CBS',
            Pincode__c='403404',
            Applicant__c=appl.Id
        ),true);
    }
    
    @isTest
    public static void testPNGControllerMethod2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AddressMatchCallout());        
        Id appl = [SELECT Id FROM Applicant__c].Id;
        String address = 'FLAT NO 101, Warje, Pune';
        Address__c  addressInstance =[SELECT id,Name,Distance_from_Branch__c,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c,District__c
                                      FROM Address__c WHERE Address_Type__c='Current'];
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> sourceAddressList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> targetAddressList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper wrapperinstance = LOSKarzaAddressMatchController.createAddressWrapper(addressInstance);
        sourceAddressList.add(wrapperinstance);
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper targetwrapperinstance = LOSKarzaAddressMatchController.createAddressWrapper(addressInstance);
        targetAddressList.add(targetwrapperinstance);
        String objWrapper = LOSKarzaAddressMatchController.validateAddressMatch(sourceAddressList,targetAddressList,appl,'CIBIL','Current');
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod3(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AddressMatchCallout());        
        Id appl = [SELECT Id FROM Applicant__c].Id;
        String address = 'FLAT NO 101, Warje, Pune';
        Address__c  addressInstance =[SELECT id,Name,Distance_from_Branch__c,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c,District__c
                                      FROM Address__c WHERE Address_Type__c='Current'];
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> sourceAddressList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> targetAddressList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper wrapperinstance = LOSKarzaAddressMatchController.createAddressWrapper(addressInstance);
        sourceAddressList.add(wrapperinstance);
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper targetwrapperinstance = LOSKarzaAddressMatchController.createAddressWrapper(addressInstance);
        targetAddressList.add(targetwrapperinstance);
        String objWrapper = LOSKarzaAddressMatchController.validateAddressMatch(sourceAddressList,targetAddressList,appl,'AADHAR','Current');
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod4(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AddressMatchCallout());        
        Id appl = [SELECT Id FROM Applicant__c].Id;
        String address = 'FLAT NO 101, Warje, Pune';
        Address__c  addressInstance =[SELECT id,Name,Distance_from_Branch__c,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c,District__c
                                      FROM Address__c WHERE Address_Type__c='Current'];
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> sourceAddressList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> targetAddressList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper wrapperinstance = LOSKarzaAddressMatchController.createAddressWrapper(addressInstance);
        sourceAddressList.add(wrapperinstance);
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper targetwrapperinstance = LOSKarzaAddressMatchController.createAddressWrapper(addressInstance);
        targetAddressList.add(targetwrapperinstance);
        String objWrapper = LOSKarzaAddressMatchController.validateAddressMatch(sourceAddressList,targetAddressList,appl,'CART','Current');
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod5(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AddressMatchCallout());        
        Id appl = [SELECT Id FROM Applicant__c].Id;
        String address = 'FLAT NO 101, Warje, Pune';
        Address__c  addressInstance =[SELECT id,Name,Distance_from_Branch__c,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c,District__c
                                      FROM Address__c WHERE Address_Type__c='Current'];
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> sourceAddressList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> targetAddressList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper wrapperinstance = LOSKarzaAddressMatchController.createAddressWrapper(addressInstance);
        sourceAddressList.add(wrapperinstance);
        LOSKarzaAddressMatchIntHandler hd=new LOSKarzaAddressMatchIntHandler();
        hd.generateJSONResponse(sourceAddressList);
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper targetwrapperinstance = LOSKarzaAddressMatchController.createAddressWrapper(addressInstance);
        targetAddressList.add(targetwrapperinstance);
        String objWrapper = LOSKarzaAddressMatchController.validateAddressMatch(sourceAddressList,targetAddressList,appl,'RCOIdentification','Current');
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod6(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AddressMatchCallout()); 
        Id appl = [SELECT Id FROM Applicant__c].Id;
        Set<Id> addressId=new Set<Id>();
        List<Address__c>  addressInstance =[SELECT id,Name,Distance_from_Branch__c,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c,District__c
                                            FROM Address__c];
        for( Address__c add:addressInstance){
            addressId.add(add.id);
        }
        LOSKarzaAddressMatchController.callAddressParsingMethod(addressId,appl);
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod7(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AddressMatchCallout()); 
        Id appl = [SELECT Id FROM Applicant__c].Id;
        LOSAdharKycInfoData kycdate=new LOSAdharKycInfoData();
        kycdate.loc='test';
        kycdate.state='AP';
        LOSKarzaAddressMatchController.addressMatchForAadhar(JSON.serialize(kycdate),appl);
        Test.stopTest();
        
    }
    @isTest
    public static void testPNGControllerMethod8(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AddressMatchCallout()); 
        Id appl = [SELECT Id FROM Applicant__c].Id;
        Address__c  addressInstance =[SELECT id,Name,Distance_from_Branch__c,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c,District__c
                                      FROM Address__c LIMIT 1];        
        LOSKarzaAddressMatchIntHandler.generateRequest(addressInstance);
        LOSKarzaAddressMatchController.addressMatchForCART(appl,JSON.serialize(addressInstance));
        Test.stopTest();
        
    }
    
    @isTest
    public static void testWrapperCoverage(){
        Test.startTest();
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper addMatchWrapper = new LOSKarzaAddressMatchIntHandler.AddressRequestWrapper();
        //addressLine1,addressLine2,city,locality,state,district,pincode,country
        addMatchWrapper.addressLine1 = 'aaa';
        addMatchWrapper.addressLine2 = 'bbb';
        addMatchWrapper.city ='Delhi';
        addMatchWrapper.locality = 'Delhi Cantt';
        addMatchWrapper.state = 'Uttar Pradesh';
        addMatchWrapper.district = 'Delhi';
        addMatchWrapper.pincode = '110001';
        addMatchWrapper.country = 'India';
        
        
        LOSKarzaAddressMatchIntHandler.NameRequestWrapper nameReqWrapper = new LOSKarzaAddressMatchIntHandler.NameRequestWrapper();
        nameReqWrapper.first = 'First';
        nameReqWrapper.middle = 'Middle';
        nameReqWrapper.last = 'Last';
        
        LOSKarzaAddressMatchIntHandler.AddressMatchSourceRequestWrapper addMatchSrcReqWrapper = new LOSKarzaAddressMatchIntHandler.AddressMatchSourceRequestWrapper();
        addMatchSrcReqWrapper.name = nameReqWrapper;
        addMatchSrcReqWrapper.relationNames = null;
        addMatchSrcReqWrapper.addresses = null;
        addMatchSrcReqWrapper.dob = '';
        
        LOSKarzaAddressMatchIntHandler.AddressMatchTargetRequestWrapper addMatchTargetReqWrapper = new LOSKarzaAddressMatchIntHandler.AddressMatchTargetRequestWrapper();
        addMatchTargetReqWrapper.referenceId = 'referenceId';
        addMatchTargetReqWrapper.name = nameReqWrapper;
        addMatchTargetReqWrapper.relationNames = null;
        addMatchTargetReqWrapper.addresses = null;
        addMatchTargetReqWrapper.dob = '';
        
        LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapperScore addMatchResWrapper = new LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapperScore();
        addMatchResWrapper.score = 10.0;
        addMatchResWrapper.refernce1 = 'reference1';
        addMatchResWrapper.match = true;
        addMatchResWrapper.refernce2 = 'reference2';
        
        LOSKarzaAddressMatchIntHandler.ClientDataWrapper clientWrapper = new LOSKarzaAddressMatchIntHandler.ClientDataWrapper();
        clientWrapper.caseId = '';
        
        /*LOSKarzaAddressMatchIntHandler.RelationNameRequestWrapper relNameReqWrapper = new LOSKarzaAddressMatchIntHandler.RelationNameRequestWrapper();
        relNameReqWrapper.relationReference = 'brother';
        relNameReqWrapper.name = nameReqWrapper;*/
        
        Test.stopTest();
    }
}