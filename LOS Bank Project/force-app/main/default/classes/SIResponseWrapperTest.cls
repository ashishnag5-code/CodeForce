@isTest
public class SIResponseWrapperTest {
    /*@isTest
     * 
    public static void testSIResponseWrapper() {
        SIResponseWrapper.Messages message = new SIResponseWrapper.Messages();
        message.code = 200;
        message.message = 'Success';

        SIResponseWrapper.ExtendedErrorDetails errorDetails = new SIResponseWrapper.ExtendedErrorDetails();
        errorDetails.messages = new List<SIResponseWrapper.Messages>();
        errorDetails.messages.add(message);

        SIResponseWrapper.TransactionStatus transactionStatus = new SIResponseWrapper.TransactionStatus();
        transactionStatus.ResponseCode = '200';
        transactionStatus.ResponseMessage = 'Transaction successful';
        transactionStatus.ExtendedErrorDetails = errorDetails;

        SIResponseWrapper response = new SIResponseWrapper();
        response.TransactionStatus = transactionStatus;

        System.assertEquals('200', response.TransactionStatus.ResponseCode);
        System.assertEquals('Transaction successful', response.TransactionStatus.ResponseMessage);
        System.assertEquals(1, response.TransactionStatus.ExtendedErrorDetails.messages.size());
        System.assertEquals(200, response.TransactionStatus.ExtendedErrorDetails.messages[0].code);
        System.assertEquals('Success', response.TransactionStatus.ExtendedErrorDetails.messages[0].message);
    }
*/
}