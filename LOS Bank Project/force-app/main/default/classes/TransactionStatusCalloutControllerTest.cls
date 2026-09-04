@isTest
public class TransactionStatusCalloutControllerTest {
    static testmethod void testTransactionStatusCallout(){
        test.setMock(HttpCalloutMock.class, new TransactionStatusCalloutMockTest('transactionStatus'));
        TransactionStatusCalloutController.transactionStatusCallout();
    }
    static testmethod void testTransactionStatusCallout2(){
        test.setMock(HttpCalloutMock.class, new TransactionStatusCalloutMockTest());
        TransactionStatusCalloutController.transactionStatusCallout();
    }
}