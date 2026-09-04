@isTest
public class DelegatedAuthServiceHandlerTest {
    @isTest
    public static void DelegatedAuthServiceHandlerTest1(){
         Map<String, String> mapServiceParams = new Map<String,String>();
         mapServiceParams.put('Channel','SFDC');
         mapServiceParams.put('UserId','test1234');
         mapServiceParams.put('Password','abcd');
         Integration_Master__c LDAPMaster=new Integration_Master__c();
         LDAPMaster.Name='LDAP_IDAM';
         LDAPMaster.Active__c=true;
         LDAPMaster.Encryption_Key__c='testEncrypt12345';
         LDAPMaster.End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/LDAPLoginServiceV1/login';
         LDAPMaster.HTTP_Method__c='POST';
         LDAPMAster.Channel__c='SFDC';
         insert LDAPMaster;
         Test.startTest();
         DelegatedAuthServiceHandler.generateRequest(mapServiceParams);
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse();
         req.addHeader('httpMethod', 'POST');
         req.requestUri = '/services/apexrest/delegatedauth/';
         //req.requestBody = Blob.valueOf('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><Authenticate xmlns="urn:authentication.soap.sforce.com"></Authenticate></soapenv:Body></soapenv:Envelope>');
         req.requestBody = Blob.valueOf('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><Authenticate xmlns="urn:authentication.soap.sforce.com"><username>113949@aubank.in.uat</username><password>Bank@1234</password><sourceIp>104.161.246.4</sourceIp></Authenticate></soapenv:Body></soapenv:Envelope>');
         RestContext.request = req; 
         RestContext.response= res;
         Test.setMock(HttpCalloutMock.class, new DelegatedAuthMock());
         DelegatedAuthService.doPost();
         Test.stopTest();
    }

}