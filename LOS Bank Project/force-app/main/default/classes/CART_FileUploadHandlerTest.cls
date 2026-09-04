@isTest
public class CART_FileUploadHandlerTest {
    static testmethod void testGenerateRequest(){
        Map<String,Object> reqParam = new Map<String,Object>();
        reqParam.put('filename','Loan');
        reqParam.put('base64',EncodingUtil.base64Encode(blob.valueOf('loan')));
        reqParam.put('password','loan');
        CART_FileUploadHandler.generateRequest(reqParam);
        CART_FileUploadHandler.AnalysisData analysisList = CART_FileUploadHandler.parseAnalysisData('{"monthlyCreditsDetailsGrandTotal":{"Salary Credit":25650,"Month-Year":null,"Credit":37344},"monthlyBalancesDetailsGrandTotal":{"averageBalanceOn5th":0,"averageBalanceOn25th":1,"Month-Year":null,"averageBalanceOn20th":1,"AMB":1319.594193548387,"averageBalanceOn10th":101,"Average of Custom Day":2892.1666666666665,"averageBalanceOn15th":6,"averageBalanceOn1st":17244},"monthlyCreditsDetails":[{"Salary Credit":25650,"Month-Year":"Oct-2022","Credit":37344}],"monthlyBalancesDetails":[{"averageBalanceOn5th":0,"averageBalanceOn25th":1,"Month-Year":"Oct-2022","averageBalanceOn20th":1,"AMB":1319.594193548387,"averageBalanceOn10th":101,"Average of Custom Day":2892.1666666666665,"averageBalanceOn15th":6,"averageBalanceOn1st":17244}]}');
        CART_FileUploadHandler objFUH = new CART_FileUploadHandler();
        objFUH.generateJSONResponse(null);
        
    }
}