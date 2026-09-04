@isTest
private class KarzaPennyDropHandlerTest {
    @isTest
    static void testKarzaPennyDropResponseWrapper_Success() {
    	KarzaPennyDropHandler handler = new KarzaPennyDropHandler();
        KarzaPennyDropHandler.KarzaPennyDropResponseWrapper response = new KarzaPennyDropHandler.KarzaPennyDropResponseWrapper();
        response.statuscode = '101';
        response.request_id = '1e5a875e-e590-11e7-a842-373db1bff361';
        response.result = new KarzaPennyDropHandler.BankTransactionResult();
        response.result.bankTxnStatus = true;
        response.result.accountNumber = '2111249333316222';
        response.result.ifsc = 'AUBL0002493';
        response.result.accountName = 'Mr AUBANK';
        response.result.bankResponse = 'Transaction Successful';

       
        System.assertEquals('101', response.statuscode);
        System.assertEquals('1e5a875e-e590-11e7-a842-373db1bff361', response.request_id);
        System.assertEquals(true, response.result.bankTxnStatus);
        System.assertEquals('2111249333316222', response.result.accountNumber);
        System.assertEquals('AUBL0002493', response.result.ifsc);
        System.assertEquals('Mr AUBANK', response.result.accountName);
        System.assertEquals('Transaction Successful', response.result.bankResponse);
    }
    /*
    @isTest
    static void testKarzaPennyDropResponseWrapper_NullProperties() {
       
        KarzaPennyDropHandler.KarzaPennyDropResponseWrapper response = new KarzaPennyDropHandler.KarzaPennyDropResponseWrapper();
        response.statuscode = '101';
        response.request_id = '1e5a875e-e590-11e7-a842-373db1bff361';
        response.result = new KarzaPennyDropHandler.BankTransactionResult();
        response.result.bankTxnStatus = null;
        response.result.accountNumber = null;
        response.result.ifsc = null;
        response.result.accountName = null;
        response.result.bankResponse = null;
        
    
        System.assertEquals('101', response.statuscode);
        System.assertEquals('1e5a875e-e590-11e7-a842-373db1bff361', response.request_id);
        
System.assertEquals(null,response.result.bankTxnStatus);
System.assertEquals(null, response.result.accountNumber);
System.assertEquals(null, response.result.ifsc);
        System.assertEquals(null, response.result.accountName);
        System.assertEquals(null, response.result.bankResponse);
    }
*/    
    @isTest
    static void testKarzaPennyDropResponseWrapper_Failure() {
      
        KarzaPennyDropHandler.KarzaPennyDropResponseWrapper response = new KarzaPennyDropHandler.KarzaPennyDropResponseWrapper();
        response.statuscode = '101';
        response.request_id = '1e5a875e-e590-11e7-a842-373db1bff361';
        response.result = null;
        
      
        System.assertEquals('101', response.statuscode);
        System.assertEquals('1e5a875e-e590-11e7-a842-373db1bff361', response.request_id);
        System.assertEquals(null, response.result);
    }
}