@IsTest
public class PDCDetailsWrapperTest {
    
    @IsTest
    static void testPDCDetailsWrapper(){
        Test.startTest();
        PDCDetailsWrapper wrapper = new PDCDetailsWrapper();
        wrapper.spdcChequeNumberFrom = 'test';
        wrapper.spdcChequeNumberTo = 'test1';
        wrapper.pdcChequeNumberFrom = 'test1';
        wrapper.pdcChequeNumberTo = 'test1';
        Test.stopTest();
    }

}