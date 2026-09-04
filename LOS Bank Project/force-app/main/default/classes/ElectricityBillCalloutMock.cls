@isTest
public with sharing class ElectricityBillCalloutMock implements HttpCalloutMock{

    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status_code": "101","request_id": "4112f27e-f41f-43c9-825a-02c226de50c5","result": {"address": "SHOP IN-217-A G/F F/P SHAHPUR JAT NEW DELHI 110049","amount_payable": "2730.00","bill_amount": "","bill_date": "","bill_due_date": "20-05-2019","bill_issue_date": "","bill_no": "","consumer_name": "SHRI BHAGWAN","consumer_number": "102452589","email_address": "rahulpanwar04@gmail.com","mobile_number": "9268920233","total_amount": ""}}');
        res.setStatusCode(200);
        return res;
    }

}