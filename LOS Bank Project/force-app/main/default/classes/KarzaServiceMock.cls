@isTest
public with sharing class KarzaServiceMock {
    public class AddressSplitServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "result": { "C/O": "", "House": "", "Floor": "", "Building": "", "Complex": "", "Street": "ROAD NO 9", "Untagged": "ABC , KAILASH HILLS", "locality": "GAJULARAMARAM", "State": "TELANGANA", "District": "HYDERABAD", "City": "HYDERABAD", "Landmark": "", "Pin": 500055 }, "request_id": "601548d7-120c-4c3f-aa56-97dab965eaa9", "status-code": "101" }');
            res.setStatusCode(200);
            return res;
        }
    }
    public class FaceMatchServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requestId":"b5850041-b5bc-44d0-847d-b1568716e333","result":{"match":"yes","matchScore":96.74665217391305,"reviewNeeded":"no","confidence":95.44194340705872},"statusCode":101}');
           res.setStatusCode(200);
            return res;
        }
    }
    public class FaceMatchServiceNoMatchMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requestId":"b5850041-b5bc-44d0-847d-b1568716e333","result":{"match":"no","matchScore":96.74665217391305,"reviewNeeded":"no","confidence":95.44194340705872},"statusCode":101}');
           res.setStatusCode(200);
            return res;
        }
    }
    public class FaceMatchServiceErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requestId":"b5850041-b5bc-44d0-847d-b1568716e333","result":{"match":"no","matchScore":96.74665217391305,"reviewNeeded":"no","confidence":95.44194340705872},"statusCode":401}');
           res.setStatusCode(200);
            return res;
        }
    }

}