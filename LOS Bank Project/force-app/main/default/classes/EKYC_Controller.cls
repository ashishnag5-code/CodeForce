public with sharing class EKYC_Controller {

    public Datetime Today { get { return DateTime.now(); }}
    public List<Address__c> addressRec   {get; set;}
    public String currentRecordId 	     {get; set;}
    public string applcntAddress  	     {get; set;}
    public string getCustomerPhotoId     {get; set;}
    public string genericUrlPathForImage {get; set;}
    public ApplicantDetails applicantDetails {get; set;}
    
    public class ApplicantDetails {
        public String applicantName {get; set;}
        public String pin {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String maskAadhaarNo {get; set;}
    }
    
    public EKYC_Controller(ApexPages.StandardController stdController) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id').escapeHtml4();
        genericUrlPathForImage = '/sfc/servlet.shepherd/version/download/';
        if(String.isNotBlank(currentRecordId)) {                  
       	   initializeApplcntAddress(currentRecordId);
           getCustomerPhotograph(currentRecordId);
           initializeApplicantDetails(currentRecordId);
        }       
    }

    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
    public void initializeApplcntAddress(String currentRecordId) {
        addressRec = [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, City__c, 
                      	     State__c, Pincode__c 
                      FROM Address__c 
                      WHERE Applicant__r.Id =: currentRecordId and Address_Type__c = 'Permanent' WITH SECURITY_ENFORCED limit 1];
        
        if(addressRec.size() > 0) {
            String address1 = addressRec[0].Address_Line_1__c !=null ? addressRec[0].Address_Line_1__c : '';
            String address2 = addressRec[0].Address_Line_2__c !=null ? addressRec[0].Address_Line_2__c : '';
            String address3 = addressRec[0].Address_Line_3__c !=null ? addressRec[0].Address_Line_3__c : '';
            String cty      = addressRec[0].City__c !=null ? addressRec[0].City__c : '';
            String pincde  	= addressRec[0].Pincode__c !=null ? addressRec[0].Pincode__c : '';
            
            applcntAddress  = address1 + ', ' + address2 + ', ' + address3 + ', ' + addressRec[0].City__c + ', ' + 
                			  addressRec[0].Pincode__c; 
            
        }       			 
    }
    
    public List<Applicant__c> getApplicnt(String applcntRecordId) {
	   List<Applicant__c> applcntLst = [SELECT id, First_Name__c , Middle_Name__c , Last_Name__c, Aadhaar_Number__c  
                                        FROM Applicant__c
                                        WHERE id =:applcntRecordId];
       return applcntLst;
    }
    
    public void initializeApplicantDetails(String applcntRecordId) {
        ApplicantDetails applObj = new ApplicantDetails();
        Applicant__c applcntLst = getApplicnt(applcntRecordId).size() > 0 ? getApplicnt(applcntRecordId)[0] : new Applicant__c();
        
        String firstName = String.isNotBlank(applcntLst.First_Name__c) ? applcntLst.First_Name__c : '';
        String middleName = String.isNotBlank(applcntLst.Middle_Name__c) ? applcntLst.Middle_Name__c : '';
        String lastName = String.isNotBlank(applcntLst.Last_Name__c) ? applcntLst.Last_Name__c : '';
        
        String fullName = firstName + middleName + lastName;
        String pin = String.isNotBlank(addressRec[0].Pincode__c) ? addressRec[0].Pincode__c : '';
        String city = String.isNotBlank(addressRec[0].City__c) ? addressRec[0].City__c : '';
        String state = String.isNotBlank(addressRec[0].State__c) ? addressRec[0].State__c : '';
      //	String aadhaarNo = AadharTokenUtil.getAddharNumberViaToken(applcntRecordId, applcntLst.Aadhaar_Number__c);
        String response =  AadharTokenUtil.getAddharNumberViaToken(applcntRecordId, applcntLst.Aadhaar_Number__c);
        IntegrationUtility.ResponseWrapper wrapper = (IntegrationUtility.ResponseWrapper) JSON.deserialize(response,IntegrationUtility.ResponseWrapper.class);
        String aadhaarNo = wrapper.additionalResponse;
    	system.debug('aadhaarNo--'+aadhaarNo+ ' '+applcntLst.Aadhaar_Number__c);
        Long df = Long.valueOf(aadhaarNo);
        String maskAadhaarNo = maskNumber(df, 4);
        applObj.applicantName = fullName;
        applObj.pin = pin;
        applObj.city = city;
        applObj.state = state;
        applObj.maskAadhaarNo = maskAadhaarNo;
        applicantDetails = applObj;

    }
    
    public static String maskNumber(Long numberToMask, Integer visibleDigits) {
        String numberString = String.valueOf(numberToMask);
        if (visibleDigits >= numberString.length()) {
            return numberString;
        } 
        else {
            String visiblePart = numberString.substring(numberString.length() - visibleDigits);
            String maskedPart = '';
            for (Integer i = 0; i < numberString.length() - visibleDigits; i++) {
                maskedPart += '*';
            }
            return maskedPart + visiblePart;
        }
}

    
    public void getCustomerPhotograph(String currentRecordId) {//Application Aadhaar Picture
    
    	List<Document_Checklist__c> getDocChecklstId = [SELECT Id 
                                                        FROM Document_Checklist__c 
                                                        WHERE Applicant__r.Id =: currentRecordId 
                                                        AND Document_Master__r.Document_Name__c = 'Application Aadhaar Picture' WITH SECURITY_ENFORCED]; // SFAU-5653 - Application Aadhaar Picture instead of Live Photo
        
        if(getDocChecklstId.size() > 0) {
           getContentVersionId(getDocChecklstId); 
        }        
    }
    
    public void getContentVersionId(List<Sobject> sobj) {
        
        List<ContentDocumentLink> contDocLinkId = [SELECT ContentDocumentId 
                                             	   FROM ContentDocumentLink 
                                             	   WHERE LinkedEntityId =: sobj[0].Id AND ContentDocument.LatestPublishedVersion.isActive__c=TRUE WITH SECURITY_ENFORCED LIMIT 1]; // SFAU-5653
        if(contDocLinkId.size() > 0) {
            List<ContentVersion> contVerId          = [SELECT Id 
                                                       FROM  ContentVersion 
                                                       WHERE ContentDocumentId =: contDocLinkId[0].ContentDocumentId AND isActive__c = TRUE WITH SECURITY_ENFORCED LIMIT 1]; // SFAU-5653
            
            getCustomerPhotoId = contVerId[0].Id;
        }
    }
}