public class DelegatedAuthMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) 
    {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('');
        res.setStatusCode(200);
        System.assertEquals('POST', req.getMethod());
        return res;
    }

}