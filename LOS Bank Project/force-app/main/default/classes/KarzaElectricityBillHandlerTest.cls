@isTest
private class KarzaElectricityBillHandlerTest {
    @isTest
    static void testKarzaElectricityBillResponseWrapper_Success() {
       
        KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper response = new KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper();
        response.status_code = '101';
        response.request_id = 'NHY7655';
        response.result = new KarzaElectricityBillHandler.KarzaElectricityBillResult();
        response.result.address = 'SHOP IN-217-A G/F F/P SHAHPUR JAT NEW DELHI 110049';
        response.result.amount_payable = '2730.00';
        response.result.bill_amount = '';
        response.result.bill_date = '';
        response.result.bill_due_date = '20-05-2019';
        response.result.bill_issue_date = '';
        response.result.consumer_name = 'ABC';
        response.result.consumer_number = '2374';
        response.result.email_address = '';
        response.result.mobile_number = '';
        response.result.total_amount = '';

       
        System.assertEquals('101', response.status_code);
        System.assertEquals('NHY7655', response.request_id);
        System.assertEquals('SHOP IN-217-A G/F F/P SHAHPUR JAT NEW DELHI 110049', response.result.address);
        System.assertEquals('2730.00', response.result.amount_payable);
        System.assertEquals('', response.result.bill_amount);
        System.assertEquals('', response.result.bill_date);
        System.assertEquals('20-05-2019', response.result.bill_due_date);
        System.assertEquals('', response.result.bill_issue_date);
        System.assertEquals('ABC', response.result.consumer_name);
        System.assertEquals('2374', response.result.consumer_number);
        System.assertEquals('', response.result.email_address);
        System.assertEquals('', response.result.mobile_number);
        System.assertEquals('', response.result.total_amount);
    }
    
    @isTest
    static void testKarzaElectricityBillResponseWrapper_NullProperties() {
        // Create a mock response with null property values
        KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper response = new KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper();
        response.status_code = '101';
        response.request_id = 'NHY7655';
        response.result = new KarzaElectricityBillHandler.KarzaElectricityBillResult();
        response.result.address = null;
        response.result.amount_payable = null;
        response.result.bill_amount = null;
        response.result.bill_date = null;
        response.result.bill_due_date = null;
        response.result.bill_issue_date = null;
        response.result.bill_no = null;
        response.result.consumer_name = null;
        response.result.consumer_number = null;
        response.result.email_address = null;
        response.result.mobile_number = null;
        response.result.total_amount = null;
        
        // Verify the response properties
        System.assertEquals('101', response.status_code);
        System.assertEquals('NHY7655', response.request_id);
        System.assertEquals(null, response.result.address);
        System.assertEquals(null, response.result.amount_payable);
        System.assertEquals(null, response.result.bill_amount);
        System.assertEquals(null, response.result.bill_date);
        System.assertEquals(null, response.result.bill_due_date);
        System.assertEquals(null, response.result.bill_issue_date);
        System.assertEquals(null, response.result.consumer_number);
        System.assertEquals(null, response.result.consumer_name);
        System.assertEquals(null, response.result.email_address);
        System.assertEquals(null, response.result.mobile_number);
        System.assertEquals(null, response.result.total_amount);
    }
    
}