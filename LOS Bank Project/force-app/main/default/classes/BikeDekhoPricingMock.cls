@isTest
public with sharing class BikeDekhoPricingMock implements HttpCalloutMock{
	public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"data":{"insurance":44360,"antitheftcharges":0,"autocardcharges":0,"othermcdcharges":0,"warehousingcharges":0,"is_near_by_city_price":0,"non_mandatory_misc_charges":0,"numberplate":0,"secure":0,"non_mandatory_total":0,"standardaccessoriescharges":0,"city_name":"Delhi","essentialkit":0,"variant_id":84,"smartcardcharges":0,"mandatory_total":16,"date_time":"2023-04-30T23:51:43.000Z","price":1690000,"variant_slug":"hayabusa-1300","displacement":1340,"id":3128990,"helment_charges":0,"logesticcharges":0,"driveassure":0,"stockyardcharges":0,"mandatory_other_charges":0,"extendedwarranty":0,"variant_name":"STD","on_road_price":1886460,"rto":135200,"polish_charges":0,"tefloncoating":0,"mandatory_handling_charges":0,"price_type":"orp","handlingcharges":0,"city_id":475},"message":"Variant price","status":200}');
        res.setStatusCode(200);
        return res;
    }

}