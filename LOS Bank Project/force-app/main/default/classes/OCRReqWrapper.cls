/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 12-19-2022
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class OCRReqWrapper {
    // Added by Harshit for Document Upload- START
    public String file {get; set;}
    public String url {get; set;}
    public String fileBase64 {get; set;}
    public String pdfPassword{get; set;}
    public Boolean requiredConfidence{get; set;}
    public Boolean requiredOcr{get; set;}
    public List<String> returnQualityChecks{get; set;}
    public String maskAadhaarImage{get; set;}
    public String maskAadhaarText{get; set;}
    public String responseFormat{get; set;}
    public String responseType{get; set;}
    public List<String> docTypes{get; set;}
    // Added by Harshit for Document Upload- END
}