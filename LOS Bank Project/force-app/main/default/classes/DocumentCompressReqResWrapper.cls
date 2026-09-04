/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 12-15-2022
 * @last modified by  : Harshit Goyal | Salesforce
**/
public class DocumentCompressReqResWrapper {
    public class LOSDocCompressReqWrapper {
        public String RequestId;
        public String OriginatingChannel;
        public String Filename;
        public String Base64string;
    }
    public class LOSDocCompressResWrapper {
        public String OutputFileBase64string;
        public String OutputStatus;
        public Integration_Checklist__c checklistRecord;
        public Decimal statusCode;

    }
    public static LOSDocCompressResWrapper parse(String json) {
        return (LOSDocCompressResWrapper) System.JSON.deserialize(json, LOSDocCompressResWrapper.class);
    }
}