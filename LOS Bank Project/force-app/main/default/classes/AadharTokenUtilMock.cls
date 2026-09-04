@isTest
public class AadharTokenUtilMock implements HttpCalloutMock{
      public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"value":"234323454321"}');
        res.setStatusCode(200);
        return res;
    }


}