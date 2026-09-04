@isTest
public class MobileCompatibleDataTableControllerTest {
	@isTest
    public static void test1(){
        
        String configDataTableName = 'Applicant_Data';
        Test.startTest();
        List<Object_Data_Table__mdt> oppDataTableResult = MobileCompatibleDataTableController.getCustomMetadataColumns(configDataTableName);
        Test.stopTest();
        System.debug(oppDataTableResult);
        //Retreive custom metadata
        List<Object_Data_Table__mdt> oppDataTableList = [SELECT  HeaderField__c, Icon__c, CheckboxColumn__c, 
                                                        (SELECT FieldApi_Name__c, Sortable__c, Field_Label__c, Order__c  FROM Fields_Data_Tables__r ORDER BY Order__c) 
                                                        FROM Object_Data_Table__mdt WHERE DeveloperName=:configDataTableName LIMIT 1 ];
        System.assertEquals(oppDataTableList[0].HeaderField__c , oppDataTableResult[0].HeaderField__c);
        System.assertEquals(oppDataTableList[0].Icon__c, oppDataTableResult[0].Icon__c);
        System.assertEquals(oppDataTableList[0].CheckboxColumn__c, oppDataTableResult[0].CheckboxColumn__c);
    }
    
    @isTest static void testGetCustomMetadataColumns_QueryException() {
        Test.startTest();
            String invalidMetadataName = '\'';
            MobileCompatibleDataTableController.getCustomMetadataColumns(invalidMetadataName);
            
        Test.stopTest();
    }
   

    
}