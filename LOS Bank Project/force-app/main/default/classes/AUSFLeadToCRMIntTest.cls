@isTest
public with sharing class AUSFLeadToCRMIntTest {
    @TestSetup
    static void makeData(){
        Integration_Master__c master = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c( Name = AUSFLeadToCRMInt.LEAD_TO_CRM_INT_MASTER_NAME, End_Point_URL__c = 'https://service.aubank.in/Service/LeadCreation', Channel__c = 'SFDC', HTTP_Method__c = 'POST', Active__c = true ), true);
    }

    @isTest static void verifyLeadToCRMSuccess(){
        Loan_Application__c loan = new Loan_Application__c(
            Primary_Applicant__r = new Applicant__c( Existing_Customer__c = 'No' ),
            Customer_Name__c = 'User Test #1',
            Mobile__c = '9897897989987',
            Product__c = '10104'
        );

        map<String, Object> successMockResponse = new map<String, Object>{
            'TransactionStatus' => new map<String, Object>{ 'ResponseMessage' => 'Success', 'ResponseCode' => '00' },
            'IsSuccess' => 'true',
            'Message' => 'Item has been created successfully',
            'LeadID' => '632135'
        };
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new AUSFLeadToCRMIntMock( 200, new map<Integer, Object>{ 200 => successMockResponse } ));
        map<String, Object> response = AUSFLeadToCRMInt.validateAndCallCRMApi( loan, false );
        Test.stopTest();

        Assert.areEqual( '632135', response.get( 'leadIdExt' ), 'Lead should get successfully created in External system' );
    }

    @isTest static void verifyLeadToCRMFailure(){
        Loan_Application__c loan = new Loan_Application__c(
            Primary_Applicant__r = new Applicant__c( Existing_Customer__c = 'No' ),
            Customer_Name__c = 'User Test #1',
            Mobile__c = '9897897989987',
            Product__c = '10104'
        );

        Object failureMockResponse = JSON.deserialize( '{ "TransactionStatus" : { "ResponseCode" : "99", "ResponseMessage" : "Error", "ExtendedErrorDetails" : { "messages" : [ { "code" : "0", "message" : "CIF mandatory for Existing Customers." } ] } }, "IsSuccess" : "true", "Message" : "CIF mandatory for Existing Customers.", "LeadID" : "" }', AUSFLeadToCRMIntHandler.LeadToCRMFailureResopnse.class );
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new AUSFLeadToCRMIntMock( 400, new map<Integer, Object>{ 400 => failureMockResponse } ));
        map<String, Object> response = AUSFLeadToCRMInt.validateAndCallCRMApi( loan, false );
        Test.stopTest();

        Assert.isNull( (String)response.get( 'leadIdExt' ), 'API call should fail since CIF was not provided for an existing customer' );
    }

    @isTest static void verifyLeadToCRMException(){
        Loan_Application__c loan = new Loan_Application__c(
            Primary_Applicant__r = new Applicant__c( Existing_Customer__c = 'No' ),
            Customer_Name__c = 'User Test #1',
            Mobile__c = '9897897989987',
            Product__c = '10104'
        );

        Object failureMockResponse = JSON.deserialize( '{ "ServiceExecutionStatus" : "ERROR", "Errors" : { "Error" : { "Code" : "AUF-ESB-Err-02", "Message" : "The formatter threw an exception while trying to deserialize the message:" } } }', AUSFLeadToCRMIntHandler.LeadToCRMFailureResopnse.class );
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new AUSFLeadToCRMIntMock( 400, new map<Integer, Object>{ 400 => failureMockResponse } ));
        map<String, Object> response = AUSFLeadToCRMInt.validateAndCallCRMApi( loan, false );
        Test.stopTest();

        Assert.isNull( (String)response.get( 'leadIdExt' ), 'API call should fail since the server should throw an exception based on the req' );
    }

    public class AUSFLeadToCRMIntMock implements HttpCalloutMock{
        public Integer statusCode = 200;
        public map<Integer, Object> statusCodeToResponse;

        public AUSFLeadToCRMIntMock( Integer statusCode, map<Integer, Object> statusCodeToResponse ){
            this.statusCodeToResponse = statusCodeToResponse;
            this.statusCode = statusCode;
        }

        public HttpResponse respond( HttpRequest request ){
            HttpResponse response = new HttpResponse();
            Object responseBody = statusCodeToResponse.get( this.statusCode );
            response.setBody( JSON.serialize( responseBody ) );
            return response;
        }
    }
}