@isTest
public class GenericUIFrameworkUtilityTest {
    testmethod static void getIconName(){
        GenericUIFrameworkUtility.getIconName('Account');
        GenericUIFrameworkUtility.getIconName('Loan_Application__c');
    }
    testmethod static void getAllFields(){
        GenericUIFrameworkUtility.getAllFields('Account');
    }
    testmethod static void getDataTableColumns(){
        GenericUIFrameworkUtility.getDataTableColumns('Account',new List<String>{'Name','RC_Limit_Increased__c','Website','Phone','Email__c','AnnualRevenue','Branch_Opening_Date__c'});
    }
    testmethod static void getRecordUrl(){
        GenericUIFrameworkUtility.getRecordUrl(null,'Account');
    }
    testmethod static void testDataTableColumnTypeAttributeWrapper(){
        DataTableColumnTypeAttributeWrapper objWrapper = new DataTableColumnTypeAttributeWrapper();
        objWrapper.weekday = 'Monday';
        objWrapper.year = '2023';
        objWrapper.month = 'July';
        objWrapper.day = '3rd';
        objWrapper.hour = '15';
        objWrapper.minute = '04';
        objWrapper.currencyCode = 'INR';
        objWrapper.label = new DataTableColumnTypeAttributeWrapper.FieldName();
        objWrapper.label.fieldName = 'Name';
    }
    
}