@isTest
global class LeadDedupeSearchCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":{"code":"0"}}},"ErrorCode":"0","MatchFound":{"Customer":[{"CustomerID":"21738937","PAN":"CSQPP5959P","AadhaarNumber":"835980598238","MobileNumber":"9405809196","LandlineResidenceNumber":"9405809196","CustomerFullName":"BHANUMATIBEN M PARMAR","DateOfBirth":"1957-11-25","DateOfIncorporation":"1957-11-25","Address":{"Line1":"21738937","Line2":"21738937","Line3":"21738937","City":"AHMEDABAD","State":"GUJARAT","Country":"India","Zip":"380008"},"BlockStatus":"N"},{"CustomerID":"24090239","PAN":"EOIPP4189D","MobileNumber":"9405809196","CustomerFullName":"Radhakishan Seth ","DateOfBirth":"2019-07-17","DateOfIncorporation":"2019-07-17","Address":{"Line1":"Flat no. 703","Line2":"Regency Estate","City":"JAIPUR","State":"RAJASTHAN","Country":"India","Zip":"303901"},"BlockStatus":"N"},{"CustomerID":"24090453","PAN":"ACIPD6775H","AadhaarNumber":"438333260660","MobileNumber":"9405809196","CustomerFullName":"PURUSHOTAM DASS","DateOfBirth":"1993-08-22","DateOfIncorporation":"1993-08-22","MotherMaidenName":"sita ","Address":{"Line1":"new atish market","Line2":"sunny traders ","City":"JAIPUR","State":"RAJASTHAN","Country":"India","Zip":"303903"},"BlockStatus":"N"},{"CustomerID":"24090454","PAN":"ACDPR7228L","MobileNumber":"9405809196","CustomerFullName":"Mona Bangar","DateOfBirth":"2017-08-22","DateOfIncorporation":"2017-08-22","Address":{"Line1":"new atish market","Line2":"sunny traders ","City":"JAIPUR","State":"RAJASTHAN","Country":"India","Zip":"303903"},"BlockStatus":"N"}]}}');
        res.setStatusCode(200);
        return res;
    }
}