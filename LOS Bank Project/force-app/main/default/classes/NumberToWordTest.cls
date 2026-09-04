@isTest
public class NumberToWordTest {
    @isTest
    public static void getNumberTOWordTest(){
        Test.startTest();
        NumberToWord.getNumberTOWord(1234);
        NumberToWord.getNumberTOWord(1234567890.123);
        Test.stopTest();
        
    }

}