public with sharing class LOSAddressSplitHandler implements IntegrationHandlerInterface{

    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        AddressSplitRequestWrapper objAddressSplitRequestWrapper = new AddressSplitRequestWrapper();

        objAddressSplitRequestWrapper.address = String.valueOf(paramsMap.get('Address'));
        objAddressSplitRequestWrapper.consent='Y';
        objAddressSplitRequestWrapper.ReqId=IntegrationUtility.getReferenceId();
        objAddressSplitRequestWrapper.Channel=System.Label.Integration_Channel;//'SFDC';
        objAddressSplitRequestWrapper.version='2.1';
        lstString.add(JSON.serialize(objAddressSplitRequestWrapper));   
        return lstString;
    }

    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class AddressSplitRequestWrapper{
        public string address;
        public string consent;
        public string ReqId;
        public string Channel;
        public string version;
    }

    public class AddressSplitResponseWrapper{
        public AddressSplitResponseResultWrapper result;
        public string request_id;
        public string status_code;
    }
    public class AddressSplitResponseResultWrapper{
        public string Care_Of;
        public string House;
        public string Floor;
        public string Building;
        public string Complex;
        public string Street;
        public string Untagged;

        public string locality;
        public string State;
        public string District;
        public string City;
        public string Landmark;
        public Integer Pin;

        public AddressSplitResponseResultWrapper(){
            Care_Of='';
            House='';
            Floor='';
            Building='';
            Complex='';
            Street='';
            Untagged='';
            locality='';
            State='';
            District='';
            City='';
            Landmark='';
        }


    }
}