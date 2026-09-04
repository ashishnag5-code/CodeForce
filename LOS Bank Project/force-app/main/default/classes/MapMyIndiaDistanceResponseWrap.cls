/**
 * Name: MapMyIndiaDistanceResponseWrap
 * Test Class: MapMyIndiaDistanceControllerTest
 * CreatedBy: Mohit M.
 * Description: Wrapper to get Distance using MapMyIndiaDistrace API
 */
public with sharing class MapMyIndiaDistanceResponseWrap {
    @AuraEnabled
	public String Server {get;set;}
    @AuraEnabled
    public String version {get;set;}
    @AuraEnabled
    public String responseCode {get;set;}
    @AuraEnabled
    public ResultsWrap results {get;set;}
	
    public class ResultsWrap {
        @AuraEnabled
        public Double[] distances {get;set;}
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public Double[] durations {get;set;}
    }
    

}