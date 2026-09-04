@isTest
public class SanctionOverrideControllerTest {
    @isTest
    public static void testReturnCurrentUserLoggedInId() {
        // Set up test data
        String recordId = '005C3000001oGPBIA2'; 

        // Call the method to be tested
        String userId = SanctionOverrideController.returnCurrentUserLoggedInId(recordId);

        // Perform assertions
        System.assertEquals(UserInfo.getUserId(), userId);
    }
}