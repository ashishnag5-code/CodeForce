@isTest
public with sharing class AUSFLeadToCRMIntHandlerTest {
    @isTest static void verifyRequest(){
        String[] req = AUSFLeadToCRMIntHandler.generateRequest( new map<String, Object>() );
        Assert.isFalse(req.isEmpty(), 'RequestId should get added to req params');
    }

    @isTest static void generateJSONResponse(){
        Assert.isNull(
            new AUSFLeadToCRMIntHandler().generateJSONResponse( new String[0] ),
            'null should be returned'
        );
    }
}