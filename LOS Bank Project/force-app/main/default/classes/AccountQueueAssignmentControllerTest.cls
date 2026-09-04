@isTest
public class AccountQueueAssignmentControllerTest {
    @testSetup static void setup() {
           Account acc = (Account)TestFactory.createSObject(new Account(
               Name = 'Test'
        ),true);
    }
      @isTest
    public static void getAccountDetailsTest(){
        Account accObj = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        	try{
        		Account response = AccountQueueAssignmentController.getAccountDetails(accObj.Id);
            	system.assertEquals('Test', response.Name);
        		Account responseNull = AccountQueueAssignmentController.getAccountDetails(NULL);
        	}
        	catch(Exception e){
            
        	}
        Test.stopTest();
    }
}