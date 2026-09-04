@isTest
public class AUSFVahaanResponseWrapperTest {
    testmethod static void testAUSFVahaanResponseWrapper(){
        AUSFVahaanResponseWrapper obj = new AUSFVahaanResponseWrapper();
        String body = '{"pdf":"HelloWorld","nocCcDetails":{"Name":"OK"},"ownerDetails":{"Name":"OK"},"financersDetails":{"Name":"OK"},"insuranceDetails":{"Name":"OK"}';
        body+=',"metadata":{"amountBeforePayment":10000,"crawlerLogs":"crawlerLogs","searchBy":"Name","amountAfterPayment":10000,"user":"Test"}';
        body+=',"vehicleDetails":{"bodyType":"bodyType","horsePower":"horsePower","color":"color","registrationDt":"registrationDt"';
        body+=',"fuel":"fuel","purchaseDt":"purchaseDt","noOfCylinders":"noOfCylinders","fitnessUpto":"fitnessUpto","manufacturer":"m"';
        body+=',"cubicCap":"cubicCap","seatingCap":"s","vehicleClass":"vc","makerModel":"2021","panGirNo":"12","ownerSrNo":"ownerSrNo"';
        body+=',"saleAmount":"12","engineNo":"2","gvw":"s","standingCap":"s","wheelbase":"w","registrationNo":"1","chassisNo":"cccccc"';
        body+=',"dealer":"dealer","wtUnladen":"wtUnladen","blackListDetails":"blackListDetails"}';
        body+=',"challanDetails":null';
        body+='}';
        AUSFVahaanResponseWrapper.Result objResult = new AUSFVahaanResponseWrapper.Result(JSON.createParser(body));
        AUSFVahaanResponseWrapper.consumeObject(JSON.createParser(body));
        obj.statusCode = '200';
        obj.request_id = '1312323';
        //obj.totalOverdueAmount = 100000;
        obj.result = objResult;
    }
    testmethod static void parse(){
        String body = '{"statusCode":"200","request_id":"1232312321","totalOverdueAmount":100000,';
        body+= '"result":{"pdf":"HelloWorld","nocCcDetails":null,"ownerDetails":null,"financersDetails":null,"insuranceDetails":null';
        body+='}}';
        AUSFVahaanResponseWrapper.parse(body);
    }
    testmethod static void getChallanOverdueAmount(){
        /*
        AUSFVahaanResponseWrapper.ChallanDetail obj = new AUSFVahaanResponseWrapper.ChallanDetail();
        obj.status = 'PENDING';
        obj.totalAmount = 1000;
        AUSFVahaanResponseWrapper.getChallanOverdueAmount(new List<AUSFVahaanResponseWrapper.ChallanDetail>{obj});
        */
    }
}