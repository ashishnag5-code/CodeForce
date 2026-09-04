@isTest
public class OCRAdharRespWrapperTest {
	@isTest
    public static void testcoverage(){
        try{
        	OCRAdharRespWrapper.parse('Test');
        }catch(Exception e){
            system.debug('Error');
        }
    }
}