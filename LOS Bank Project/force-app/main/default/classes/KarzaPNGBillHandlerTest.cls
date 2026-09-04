@isTest
private class KarzaPNGBillHandlerTest {
    @isTest
    static void testKarzaPNGBillResponseWrapper_Success() {
        // Create a mock response for a successful request
        KarzaPNGBillHandler.KarzaPNGBillResponseWrapper response = new KarzaPNGBillHandler.KarzaPNGBillResponseWrapper();
        response.status_code = '101';
        response.request_id = '3874jhgp';
        response.result = new KarzaPNGBillHandler.KarzaPNGBillResult();
        response.result.Bill_No = 'kjes327468';
        response.result.Due_Date = '31/10/2017';
        response.result.Bill_Amount = '876';
        response.result.mobile = '8748347854';
        response.result.Customer_Address = 'Goa 887';
        response.result.Bill_Date = '';
        response.result.Email = '';
        response.result.Customer_Name = 'Naruto';

        // Verify the response properties
        System.assertEquals('101', response.status_code, 'Incorrect status code');
        System.assertEquals('3874jhgp', response.request_id, 'Incorrect request ID');
        System.assertEquals('kjes327468', response.result.Bill_No, 'Incorrect bill number');
        System.assertEquals('31/10/2017', response.result.Due_Date, 'Incorrect due date');
        System.assertEquals('876', response.result.Bill_Amount, 'Incorrect bill amount');
        System.assertEquals('8748347854', response.result.mobile, 'Incorrect mobile number');
        System.assertEquals('Goa 887', response.result.Customer_Address, 'Incorrect customer address');
        System.assertEquals('', response.result.Bill_Date, 'Incorrect bill date');
        System.assertEquals('', response.result.Email, 'Incorrect email');
        System.assertEquals('Naruto', response.result.Customer_Name, 'Incorrect customer name');
    }
    /*
    @isTest
    static void testKarzaPNGBillResponseWrapper_NullProperties() {
        // Create a mock response with null property values
        KarzaPNGBillHandler.KarzaPNGBillResponseWrapper response = new KarzaPNGBillHandler.KarzaPNGBillResponseWrapper();
        response.status_code = '200';
        response.request_id = 'REQ123456';
        response.result = new KarzaPNGBillHandler.KarzaPNGBillResult();
        response.result.Bill_No = null;
        response.result.Due_Date = null;
        response.result.Bill_Amount = null;
        response.result.mobile = null;
        response.result.Customer_Address = null;
        response.result.Bill_Date = null;
        response.result.Email = null;
        response.result.Customer_Name = null;
        
        // Verify the response properties
        System.assertEquals('200', response.status_code, 'Incorrect status code');
        System.assertEquals('REQ123456', response.request_id, 'Incorrect request ID');
        System.assertNull(response.result.Bill_No, 'Bill number should be null');
        System.assertNull(response.result.Due_Date, 'Due date should be null');
        System.assertNull(response.result.Bill_Amount, 'Bill amount should be null');
        System.assertNull(response.result.mobile, 'Mobile number should be null');
        System.assertNull(response.result.Customer_Address, 'Customer address should be null');
        System.assertNull(response.result.Bill_Date, 'Bill date should be null');
        System.assertNull(response.result.Email, 'Email should be null');
        System.assertNull(response.result.Customer_Name, 'Customer name should be null');
    }*/
    
    @isTest
    static void testKarzaPNGBillResponseWrapper_Failure() {
        // Create a mock response for a failed request
        KarzaPNGBillHandler.KarzaPNGBillResponseWrapper response = new KarzaPNGBillHandler.KarzaPNGBillResponseWrapper();
        response.status_code = '101';
        response.request_id = '3874jhgp';
        response.result = null;
        
        // Verify the response properties
        System.assertEquals('101', response.status_code, 'Incorrect status code');
        System.assertEquals('3874jhgp', response.request_id, 'Incorrect request ID');
        System.assertEquals(null, response.result, 'Result should be null for a failed request');
    }
}