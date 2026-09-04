/*****
 * Class Name: AUSFIBBCalloutController
 * Description: Create IBB Request
 * Test Class Name: AUSFIBBCalloutTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-22-2023          -   Mohit M.            -   SFAU-5581 - Replace and Add attributes to IBB
 */
public class AUSFIBBCalloutController {
    
    public static String getRequestBody(Map<String,String> param,Collateral__c coll){
        system.debug('coll '+coll);
        system.debug('param '+param);
        MMV_Mapping_Master__c objMMV = [Select Id,RecordType.Name,MMV__c, MMV__r.Name, MMV__r.Make__r.Name, MMV__r.Model__r.Name,Mapped_Make__c,Mapped_Model__c,Mapped_Variant__c from MMV_Mapping_Master__c 
            where RecordType.Name='IBB' AND MMV__c = :param.get('variant') AND MMV__r.Make__r.Name = :param.get('make') AND MMV__r.Model__r.Name = :param.get('model') limit 1];
        
        IBBRequestWrapper req = new IBBRequestWrapper();
            req.owner = coll.Owner_Serial_number__c;
            req.month = param.get('month');
            req.color = coll.vehicle_color__c;
            req.year = param.get('year');
            req.requestId = IntegrationUtility.getReferenceId();
            req.channel = Label.IBBChannel;
            //SFAU-5581
            req.xfor = Label.IBB_Callout_XFor;
            //req.xfor = 'comprehensivePrice'; 
            req.variant = objMMV.Mapped_Variant__c;
            req.kilometer = coll.Kilometer__c;
            req.model = objMMV.Mapped_Model__c;
            req.location = param.get('location');
            req.make_asset = objMMV.Mapped_Make__c;
        String reqBody = JSON.serialize(req);
        Map<String, String> replacements = new Map<String, String> {
            'xfor' => 'for'
        };
        String actualResp = IntegrationUtility.mogrifyJSON(reqBody,replacements);
        return actualResp;
    }
    
    public class IBBResponseWrapper{
        public List<Integer> ForTradeinPrice;
        public List<Integer> ComPriceID;
        public List<Integer> ForCPOPrice;
        public List<Integer> ForRetailPrice;
        public List<Integer> ForPrivatePrice;
        public String message;
        public Integer status;
    }
    public class IBBRequestWrapper{
        public String owner;
        public String month;
        public String color;
        public String year;
        public String requestId;
        public String channel;
        public String xfor;
        public String variant;
        public String kilometer;
        public String model;
        public String location;
        // SFAU-5581 - change attribute
        // public String make;
        public String make_asset;
        // Add Attributes
        public String tag = Label.IBB_Callout_Tag;
        public String pricefor = Label.IBB_Callout_PriceFor;
        public String state = '';
        public String fuel_type = '';
    }
}