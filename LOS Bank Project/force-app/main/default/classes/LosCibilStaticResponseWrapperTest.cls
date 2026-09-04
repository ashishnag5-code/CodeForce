@IsTest
public class LosCibilStaticResponseWrapperTest {
    
    @IsTest
    static void testLOSCibilStaticResponseWrappers(){
        Test.startTest();
        LosCibilStaticResponseWrapper.cls_messages messagesWrapper = new LosCibilStaticResponseWrapper.cls_messages();
        messagesWrapper.code = '200';
        messagesWrapper.message = 'Success';
        LosCibilStaticResponseWrapper.cls_ExtendedErrorDetails errorDetails = new LosCibilStaticResponseWrapper.cls_ExtendedErrorDetails();
        errorDetails.messages = messagesWrapper;
        LosCibilStaticResponseWrapper.cls_TransactionStatus statusWrapper = new LosCibilStaticResponseWrapper.cls_TransactionStatus();
        statusWrapper.ExtendedErrorDetails = errorDetails;
        statusWrapper.ResponseCode = '200';
        statusWrapper.ResponseMessage = 'Success';
        LosCibilStaticResponseWrapper classData = new LosCibilStaticResponseWrapper();
        classData.TransactionStatus = statusWrapper;
        Test.stopTest();
        
    }

}