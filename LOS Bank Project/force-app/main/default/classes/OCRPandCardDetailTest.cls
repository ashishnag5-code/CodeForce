@isTest
public class OCRPandCardDetailTest {
    @isTest
    static void testOCRPandCardDetail1() {
        Test.startTest();
        OCRPandCardDetail controller = new OCRPandCardDetail();
        controller.date_Z = '2023-01-10';
        controller.dateOfIssue = '2023-01-10';
		controller.father = 'Father';
		controller.name = 'Name';
		controller.panNo = 'ABCDE1234R';
        //OCRPandCardDetail controller1 = new OCRPandCardDetail('2023-01-10','2023-01-10','Father','Name','ABCDE1234R');
        /*String date_Z = '2023-01-10'; // in json: date
		String dateOfIssue = '2023-01-10';
		String father = 'Father';
		String name = 'Name';
		String panNo = 'ABCDE1234R';*/
        Test.stopTest();
    }
    
    @isTest
    static void testOCRPandCardDetail2() {
        Test.startTest();
        //OCRPandCardDetail controller = new OCRPandCardDetail(date_Z='2023-01-10', dateOfIssue='2023-01-10', father='Father', name='Name', panNo='ABCDE1234R');
        //OCRPandCardDetail controller1 = new OCRPandCardDetail('2023-01-10','2023-01-10','Father','Name','ABCDE1234R');
        /*String date_Z = '2023-01-10'; // in json: date
		String dateOfIssue = '2023-01-10';
		String father = 'Father';
		String name = 'Name';
		String panNo = 'ABCDE1234R';*/
        Test.stopTest();
    }
    /*OCRPandCardDetail() {
        String date_Z = '2023-01-10'; // in json: date
		String dateOfIssue = '2023-01-10';
		String father = 'Father';
		String name = 'Name';
		String panNo = 'ABCDE1234R';
    }*/
}