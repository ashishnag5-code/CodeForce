@RestResource(urlMapping='/delegatedauth/*')
global with sharing class DelegatedAuthService {
    
    static final Blob AUTH_TRUE = Blob.valueOf('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><AuthenticateResponse xmlns="urn:authentication.soap.sforce.com"><Authenticated>true</Authenticated></AuthenticateResponse></soapenv:Body></soapenv:Envelope>');
    static final Blob AUTH_FALSE = Blob.valueOf('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><AuthenticateResponse xmlns="urn:authentication.soap.sforce.com"><Authenticated>false</Authenticated></AuthenticateResponse></soapenv:Body></soapenv:Envelope>');
    
    static final String IDENTITY_CONNECT = 'https://YOUR_HOST_AND_PORT/openidm/info/login';
    
    @HttpPost
    global static void doPost() {
    
        Blob responseBody = AUTH_FALSE;
        
        RestRequest req = RestContext.request;
        Dom.Document doc = new Dom.Document();
        doc.load(req.requestBody.toString());
        system.debug('%% '+req.requestBody.toString());
        Dom.XMLNode authRequest = doc.getRootElement();
        
        Dom.XMLNode body = authRequest.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XMLNode authenticate = body.getChildElement('Authenticate', 'urn:authentication.soap.sforce.com');
        String username = authenticate.getChildElement('username', 'urn:authentication.soap.sforce.com').getText();
        String password = authenticate.getChildElement('password', 'urn:authentication.soap.sforce.com').getText();
        String sourceIp = authenticate.getChildElement('sourceIp', 'urn:authentication.soap.sforce.com').getText();
        if(username.contains('@')){
            username = username.split('@')[0];
        }
        
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('LDAP_IDAM');
        //String strPwd = 'Bank@123';
        String strPwd = password;
        //String strPrivateKey = 'APuZKpRBPv8aEenc';
        String strPrivateKey = objIntMapper.Encryption_Key__c;
        Blob key = Blob.valueOf(strPrivateKey);
        Blob blobPwd = Blob.valueOf(strPwd);
        String strIv = EncodingUtil.convertToHex(key);
        Blob ivfinal = EncodingUtil.convertFromHex(strIv.left(32));
        Blob encrypted = Crypto.encrypt('AES128', key, ivfinal, blobPwd);
        String strPasswordEncrypted = EncodingUtil.base64Encode(encrypted);
        System.debug(LoggingLevel.debug, 'Encrypted PwD ' + strPasswordEncrypted);
        
        Map<String, String> mapServiceParams = new Map<String,String>();
        mapServiceParams.put('Channel',Label.Auth_Service_Channel);
        //mapServiceParams.put('UserId','983602');
        mapServiceParams.put('UserId',username);
        mapServiceParams.put('Password',strPasswordEncrypted);
        //DelegatedAuthServiceHandler.generateRequest(mapServiceParams);
        
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c();
        
        String requestBody = DelegatedAuthServiceHandler.generateRequest(mapServiceParams)[0];
        String objectId = '';
        // respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,strApplicantId);
        system.debug('%%'+requestBody);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
        String respBody = calloutResponseWrapper.response; 
        system.debug('%%% '+respBody);
        String returnValue;
        //String strResponse = '{"return" : "true"}';
        JSONParser parser = JSON.createParser(respBody);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'return')) {
                // Get the value.
                parser.nextToken();
                // Compute the grand total price for all invoices.
                system.debug('%%' + parser.getText());
                returnValue = parser.getText();
            }
        }
        
        system.debug('%%% '+returnValue);
        /*    
        Http h = new Http();
        HttpRequest hr = new HttpRequest();
        hr.setEndpoint(IDENTITY_CONNECT);
        hr.setHeader('X-OpenIDM-Username',username);
        hr.setHeader('X-OpenIDM-Password',password);
        system.debug('%%% '+username);
        system.debug('%%% '+password);
        hr.setMethod('GET');
        HttpResponse hrs = h.send(hr);
        if (hrs.getStatusCode() == 200)  {
            responseBody = AUTH_TRUE;
        } */

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/soap+xml');
        res.statusCode = 200;
        if(returnValue == 'true'){
            res.responseBody = AUTH_TRUE;
        }
        else{
            res.responseBody = AUTH_FALSE;
        }
        /*if(password == 'Seven92@920'){
            res.responseBody = AUTH_TRUE;
        }
        else{
            res.responseBody = AUTH_FALSE;
        }*/
            
    }
  
  
}