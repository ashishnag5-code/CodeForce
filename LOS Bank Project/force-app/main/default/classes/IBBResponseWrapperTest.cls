@isTest 
public class IBBResponseWrapperTest 
{
    
     static testMethod void testEx1() 
     {
        String jsonVal ='{"status": 200,"pricefor": "retail","prices": {"fairprice":868831,"marketprice": 893296,"bestprice": 911108},"match_details": {"Overall_Match_type": "Exact","MMV_Match_Type": "Exact","IBB_make": "HONDA","IBB_model":"CITY(2019-2023)","IBB_variant": "VX PETROL BS-VI","Location_Match_type": "Exact Match","IBB_location": "DELHI","IBB_color": "White Red"},"message": "success"}' ; 
        IBBResponseWrapper.parse(jsonVal);
        
     }
}