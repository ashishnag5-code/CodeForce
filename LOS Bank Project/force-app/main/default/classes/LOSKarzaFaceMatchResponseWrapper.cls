/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-23-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class LOSKarzaFaceMatchResponseWrapper{
    
    public String requestId;
    public Result result;
    public Integer statusCode;
    public String statusMessage;

    public class Result {
        public String match;
        public Double matchScore;
        public String reviewNeeded;
        public Double confidence;
    }

    
    public static LOSKarzaFaceMatchResponseWrapper parse(String json) {
        return (LOSKarzaFaceMatchResponseWrapper) System.JSON.deserialize(json, LOSKarzaFaceMatchResponseWrapper.class);
    }
    
}