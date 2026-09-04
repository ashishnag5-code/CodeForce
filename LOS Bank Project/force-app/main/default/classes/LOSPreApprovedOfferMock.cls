@isTest
public class LOSPreApprovedOfferMock {
	public class LOSPreApprovedOfferResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'Application/json');
            res.setBody('{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":0,"message":null}]}},"CRMQueryResults":[{"RowNumber":1,"CustomerId":"26521729","OfferId":"726493","OfferName":"Auto Loan (New)","ProductId":10201,"FirstOfferAmount":300000,"ValidFrom":"2023-04-13T00:00:00+05:30","ValidTill":"2024-04-13T23:59:00+05:30","RatingID":1,"OfferDescription":"Auto Loan (New)","Image_Offers":"plbanner","Avail":null,"CurrencyID":null,"TermsAndCondition":"TEST TERMS AND CONDITIONS APPLIED","OfferIsActive":"true","MaxLoanTenureinMonths":"9","MinLoanTenureinMonths":"9","RateofInterest":"25.000000","Scheme":"TEST SCHEME","Royale":null,"Employee":null,"OfferType":null,"Occupation":null,"Location":null,"RepaymentMode":null,"CustomerNameinBankAccount":"TEST CUSTOMER","IFSCcode":"AUBL0002299","BankBranch":"Mumbai","BankName":"Bank Name","off_ex1_8":"TEST CUSTOMER","Mobile":"9988774410"}]}');
            res.setStatusCode(200);
            return res;    
        }
    }
    public class LOSPreApprovedOfferUpdateResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'Application/json');
            res.setBody('{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":0,"message":"Item has been updated successfully."}]}},"OfferId":"726435"}');
            res.setStatusCode(200);
            return res;    
        }
    }
}