@IsTest
public class AMLWrapperTest {
    
    @IsTest
    public static void testFields() {
        AMLWrapper.Fields field1 = new AMLWrapper.Fields();
        field1.name = 'Field 1';
        field1.value = 'Value 1';
        
        AMLWrapper.Fields field2 = new AMLWrapper.Fields();
        field2.name = 'Field 2';
        field2.value = 'Value 2';
        
        AMLWrapper wrapper = new AMLWrapper();
        wrapper.fields = new List<AMLWrapper.Fields>{ field1, field2 };
        
        System.assertEquals(2, wrapper.fields.size());
        System.assertEquals('Field 1', wrapper.fields[0].name);
        System.assertEquals('Value 2', wrapper.fields[1].value);
    }
    
    @IsTest
    public static void testStatus() {
        AMLWrapper.Status status = new AMLWrapper.Status();
        status.errorDetails = 'Error Details';
        status.status = 'In Progress';
        
        AMLWrapper wrapper = new AMLWrapper();
        wrapper.status = status;
        
        System.assertEquals('Error Details', wrapper.status.errorDetails);
        System.assertEquals('In Progress', wrapper.status.status);
    }
    
    @IsTest
    public static void testGettersAndSetters() {
        AMLWrapper wrapper = new AMLWrapper();
        wrapper.userid = 'User123';
        wrapper.refid = 'Ref123';
        wrapper.referenceid = 'Reference123';
        wrapper.callbackurl = 'https://example.com/callback';
        wrapper.batchmode = 'Batch';
        wrapper.systemname = 'System';
        wrapper.datetimex = '2023-07-12T10:00:00Z';
        wrapper.MATCH = 'Match';
        wrapper.AML_ACTION = 'Action';
        wrapper.errorMessage = 'Error Message';
        wrapper.errorCode = '123';
        
        System.assertEquals('User123', wrapper.userid);
        System.assertEquals('Ref123', wrapper.refid);
        System.assertEquals('Reference123', wrapper.referenceid);
        System.assertEquals('https://example.com/callback', wrapper.callbackurl);
        System.assertEquals('Batch', wrapper.batchmode);
        System.assertEquals('System', wrapper.systemname);
        System.assertEquals('2023-07-12T10:00:00Z', wrapper.datetimex);
        System.assertEquals('Match', wrapper.MATCH);
        System.assertEquals('Action', wrapper.AML_ACTION);
        System.assertEquals('Error Message', wrapper.errorMessage);
        System.assertEquals('123', wrapper.errorCode);
    }
}