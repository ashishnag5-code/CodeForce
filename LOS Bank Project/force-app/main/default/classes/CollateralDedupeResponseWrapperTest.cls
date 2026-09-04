@IsTest
public class CollateralDedupeResponseWrapperTest {
    
    @isTest
    static void testWrapperstructures(){
        Test.startTest();
        CollateralDedupeResponseWrapper.Messages message = new CollateralDedupeResponseWrapper.Messages();
        CollateralDedupeResponseWrapper.CollateralDetails collateralWrapper = new CollateralDedupeResponseWrapper.CollateralDetails();
        CollateralDedupeResponseWrapper.TransactionStatus transactionWrapper = new CollateralDedupeResponseWrapper.TransactionStatus();
        CollateralDedupeResponseWrapper.ExtendedErrorDetails errorWrapper = new CollateralDedupeResponseWrapper.ExtendedErrorDetails();
        Test.stopTest();
    }

}