@isTest
public with sharing class ChequeOCRMock implements HttpCalloutMock{

    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"result":{"bankDetails":{"address":"C-2/11, ASHOK VIHAR-2, NEW DELHI - 110 052","city":"DELHI","contact":"2662666","district":"DELHI","state":"DELHI","branch":"ASHOK VIHAR BRANCH"},"bank":"KOTAK MAHINDRA BANK LIMITED","chequeNo":"515000","accNo":"2413305345","micr":"110485049","name":["ed Amount","Gaurav Gaur"],"ifsc":"KKBK0000215"},"requestId":"4d36649e-b38e-40c1-a801-ce072891b718","statusCode":101}');
        res.setStatusCode(200);
        return res;
    }

}