@IsTest
public class PreApprovedDetailsRequestWrapperTest {
    @IsTest
    static void testPreApprovedDetailsRequestWrapper() {
        // Create test data
        PreApprovedDetailsRequestWrapper requestWrapper = new PreApprovedDetailsRequestWrapper();
        requestWrapper.RequestId = '12345';
        requestWrapper.OriginatingChannel = 'Web';
        requestWrapper.Customerid = '9876543210';
        requestWrapper.MobileNumber = '9876543210';
        requestWrapper.Scheme_code = 'ABC123';
        
        // Test the getter methods
        System.assertEquals('12345', requestWrapper.RequestId);
        System.assertEquals('Web', requestWrapper.OriginatingChannel);
        System.assertEquals('9876543210', requestWrapper.Customerid);
        System.assertEquals('9876543210', requestWrapper.MobileNumber);
        System.assertEquals('ABC123', requestWrapper.Scheme_code);
        
        // Test the setter methods
        requestWrapper.RequestId = '54321';
        requestWrapper.OriginatingChannel = 'Mobile';
        requestWrapper.Customerid = '0123456789';
        requestWrapper.MobileNumber = '0123456789';
        requestWrapper.Scheme_code = 'XYZ789';
        
        System.assertEquals('54321', requestWrapper.RequestId);
        System.assertEquals('Mobile', requestWrapper.OriginatingChannel);
        System.assertEquals('0123456789', requestWrapper.Customerid);
        System.assertEquals('0123456789', requestWrapper.MobileNumber);
        System.assertEquals('XYZ789', requestWrapper.Scheme_code);
    }
}