public class CINAuthHandler {

    public class CompanyInfo {
        public String companyID { get; set; }
        public String companyName { get; set; }
    }
    public class DirectorDetails {
        public String date_of_appointment { get; set; }
        public String designation { get; set; }
        public String dsc_expiry_date { get; set; }
        public String wheather_dsc_registered { get; set; }
        public String DIN_DPIN_PAN { get; set; }
        public String full_name { get; set; }
        public String address { get; set; }
    }
    
    public class DirectorDetailsResponse {
        public List<DirectorDetails> result { get; set; }
        public String request_id { get; set; }
        public String status_code { get; set; }
    }
    
    public class JsonResponse {
        public List<CompanyInfo> result { get; set; }
        public String request_id { get; set; }
        public String status_code { get; set; }
    }
    

    public class CINRequestWrapper{
        public String requestId;
        public String channel;
        public String consent;
        public String cin;
    }

    public class CINResponseWrapper{
        @AuraEnabled public CINResponseWrapperResult result;
        @AuraEnabled public String statusCode;
        @AuraEnabled public String statusMessage;
    }
    
    public class CINResponseWrapperResult{
        @AuraEnabled public String cin;
        @AuraEnabled public String company_Name;
        @AuraEnabled public String class_of_Company;
        @AuraEnabled public String company_Category;
        @AuraEnabled public String registered_Address;
        @AuraEnabled public String email_Id;
        @AuraEnabled public String company_Status;
        @AuraEnabled public String authorised_Capital;
        @AuraEnabled public String paid_up_Capital;
    }
    public class UIResponse{
        public CINResponseWrapperResult Response;
        public Object[] metadata;
        public Integer statusCode;
    }
    
    public static String generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        String url = 'requestId='+IntegrationUtility.getReferenceId()+'&channel=' + Label.CINAuthLabel + '&consent=Y&company_name='+String.valueOf(paramsMap.get('companyName'));
       /* CINRequestWrapper requestWrapper = new CINRequestWrapper();
        requestWrapper.requestId = IntegrationUtility.getReferenceId();
        requestWrapper.Channel = 'SFDC';
        requestWrapper.cin = String.valueOf(paramsMap.get('cinNo'));
        requestWrapper.Consent = 'Y';
        lstString.add(JSON.serialize(requestWrapper));   
        return lstString;*/
        return url;
    }
    

    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public static CINResponseWrapper parse(String json) {
        json = json.replace('"Authorised_Capital(Rs)":', '"authorised_Capital":');
        json = json.replace('"Paid_up_Capital(Rs)":',    '"paid_up_Capital":');
		return (CINResponseWrapper) System.JSON.deserialize(json, CINResponseWrapper.class);
	}
    public static String parseCmpResponse(String jsonString) {
        String jsonResponseString = '{ "result": [ { "companyID": "L36911RJ1996PLC011381", "companyName": "AU SMALL FINANCE BANK LIMITED" } ], "request_id": "050fc5ba-dce3-4c8d-93bd-00fad1e91251", "status-code": "101" }';
        String cinNum;
        JsonResponse responseObj = (JsonResponse)JSON.deserialize(jsonString, JsonResponse.class);
        
        // Accessing parsed data
        if (responseObj != null) {
            List<CompanyInfo> companies = responseObj.result;
            String requestId = responseObj.request_id;
            String statusCode = responseObj.status_code;
        
            if (companies != null && !companies.isEmpty()) {
                for (CompanyInfo company : companies) {
                    cinNum = company.companyID;
                    System.debug('Company ID: ' + company.companyID);
                    System.debug('Company Name: ' + company.companyName);
                }
            }
        
            System.debug('Request ID: ' + requestId);
            System.debug('Status Code: ' + statusCode);
        } else {
            System.debug('Failed to parse JSON response');
        }
		return cinNum;
	}
    public static DirectorDetailsResponse  parseDirResponse(String jsonString) {
        DirectorDetailsResponse responseObj = (DirectorDetailsResponse)JSON.deserialize(jsonString, DirectorDetailsResponse.class);
        System.debug('DirectorDetailsResponse::'+responseObj);
        return responseObj;
    }
   
}