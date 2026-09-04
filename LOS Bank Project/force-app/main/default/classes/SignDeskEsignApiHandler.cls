public with sharing class SignDeskEsignApiHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,String> paramsMap=(Map<String,String>)reqParam;
        SignDeskEsignApiRequestWrapper wrapper = new SignDeskEsignApiRequestWrapper();
        Id loanId = paramsMap.get('Id');
        String journey = paramsMap.get('JourneyType');
        String esignType = paramsMap.get('EsignType');
        List<Applicant__c> applicantList = (List<Applicant__c>) JSON.deserialize(paramsMap.get('Applicants'),List<Applicant__c>.class);
        Loan_Application__c loanApp = [SELECT Name FROM Loan_Application__c WHERE Id=:loanId];
        /*[SELECT Id, Customer_Name__c, Email__c, First_Name__c, Middle_Name__c, Last_Name__c,
        Gender__c, Aadhaar_Number__c, Dob__c, RecordType.DeveloperName from Applicant__c WHERE Loan__c=:loanId 
            AND RecordType.DeveloperName in ('Co_Applicant','Primary_Applicant','Guarantor')  WITH SECURITY_ENFORCED];*/
        //('Co_Applicant','Primary_Applicant','Guarantor')

        List<String> appearanceList = Esign_Appearance__mdt.getInstance('SignDesk').Appearance_Position__c.split(',');  
        WidgetConfigurationWrapper config = new WidgetConfigurationWrapper();
        config.button_color = '#F37435';
        wrapper.widget_configuration = config;

        List<SignersInfoWrapper> signersInfoList = new List<SignersInfoWrapper>();
        List<DocumentsWrapper> documentsList = new List<DocumentsWrapper>();

        Integer counter = 1;
        
        String documentToBeSignedId = paramsMap.get('RequestId');//IntegrationUtility.getReferenceId();
        for(Applicant__c app: applicantList){
            SignersInfoWrapper wrap = new SignersInfoWrapper();
            if(journey == 'RO'){
                wrap.trigger_esign_request = false;
            }
            if(journey == 'Customer'){
                wrap.trigger_esign_request = true;
            }
            if(app.Middle_Name__c!=null){
                wrap.signer_name = app.First_Name__c+' '+app.Middle_Name__c+' '+app.Last_Name__c;
            }else{
                wrap.signer_name = app.First_Name__c+' '+app.Last_Name__c;
            }
            wrap.sequence = String.valueOf(counter);
            counter++;
            wrap.document_to_be_signed = documentToBeSignedId;
            wrap.signer_remarks='';
            wrap.page_number='all';
            wrap.signer_ref_id=IntegrationUtility.getReferenceId();
            SignerPosition position = new SignerPosition();
            position.appearance = appearanceList[counter-1];
            wrap.signer_position=position;
            wrap.esign_type=Label.Esign_type;
            wrap.signer_email = app.Email__c!=null?app.Email__c:'';
            wrap.signer_mobile = app.Mobile_Number__c!=null?app.Mobile_Number__c.replaceAll('\\D',''):'';
            
            SignerValidationInputs inpValidations = new SignerValidationInputs();
            inpValidations.name_as_per_aadhaar = app.Customer_Name__c;
            if(app.Gender__c == 'Female'){
                inpValidations.gender='F';
            }else if(app.Gender__c == 'Male'){
                inpValidations.gender='M';
            }
            if(app.Aadhaar_Number__c!=null){
                inpValidations.last_four_digits_of_aadhaar=String.valueOf(app.Aadhaar_Number__c).subString(8,12);
            }
            if(app.RecordType.DeveloperName == 'Primary_Applicant'){
                DocumentsWrapper docWrap = new DocumentsWrapper();
                docWrap.reference_doc_id = documentToBeSignedId; 
                docWrap.docket_title = wrap.signer_name;
                docWrap.content_type = 'pdf';
                docWrap.signature_sequence = 'parallel';
                docWrap.custom = new CustomWrapper();
                docWrap.custom.reference_doc_id = documentToBeSignedId;
                //docWrap.content = paramsMap.get('DocContents');
                if(esignType=='SI'){
                    ContentVersion cv = [SELECT Id, isActive__c, VersionData, Title, ContentDocumentId FROM ContentVersion WHERE Title='Repayment_SI.pdf' AND Loan_Application__c=:loanApp.Name AND isActive__c=true WITH SECURITY_ENFORCED Order by CreatedDate DESC LIMIT 1];
                    docWrap.content = EncodingUtil.base64Encode(cv.VersionData);
                    documentsList.add(docWrap);
                }
                else if(esignType=='Addendum Document'){
                    ContentVersion cv = [SELECT Id, isActive__c, VersionData, Title, ContentDocumentId FROM ContentVersion WHERE Title='Addendum Document.pdf' AND Loan_Application__c=:loanApp.Name AND isActive__c=true WITH SECURITY_ENFORCED Order by CreatedDate DESC LIMIT 1];
                    docWrap.content = EncodingUtil.base64Encode(cv.VersionData);
                    documentsList.add(docWrap);
                }
                else{
                    PageReference pdf = new pagereference('/apex/SystemGeneratedDocumentsForEsign?id='+loanId);
                    pdf.getParameters().put('id', loanId);
                    Blob body;
                    try {
                        // returns page as a PDF
                        if(Test.isRunningTest()){
                            body = Blob.valueOf('Some Content');
                        }else{
                            body = pdf.getContent();
                        }
                        docWrap.content = EncodingUtil.base64Encode(body);
                    }catch(Exception objException){
                        Log.error(objException,Log.SeverityType.valueOf('High'),loanId);
                    }
                    documentsList.add(docWrap);
                }
                
            }
            inpValidations.year_of_birth=String.valueOf(app.Dob__c.year());
            wrap.signer_validation_inputs = inpValidations;
            wrap.signature_type='aadhaar';
            signersInfoList.add(wrap);
        }
        

        wrapper.signers_info = signersInfoList;
        wrapper.return_url='';
        wrapper.reference_id=IntegrationUtility.getReferenceId();
        wrapper.RequestId= wrapper.reference_id;
        wrapper.OriginatingChannel=paramsMap.get('Channel');//'ADS';
        wrapper.documents = documentsList;
        if(journey == 'RO'){
            wrapper.enable_email_notification = false;
        }
        if(journey == 'Customer'){
            wrapper.enable_email_notification = true;
        }
        lstString.add(JSON.serializePretty(wrapper,false));   
        return lstString;
    }

    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public class SignDeskEsignApiRequestWrapper{
        public WidgetConfigurationWrapper widget_configuration;
        public List<SignersInfoWrapper> signers_info;
        public String return_url;
        public String reference_id;//
        public String RequestId;
        public String OriginatingChannel;
        public List<DocumentsWrapper> documents;
        public Boolean enable_email_notification;
    }

    public class WidgetConfigurationWrapper{
        public String button_color;
    }

    public class SignersInfoWrapper{
        public Boolean trigger_esign_request;
        public String signer_name;
        public String sequence;
        public String document_to_be_signed; //
        public String signer_remarks;
        public String page_number;
        public String signer_ref_id;
        public SignerPosition signer_position;
        public String esign_type;
        public String signer_email;
        public String signer_mobile;
        public SignerValidationInputs signer_validation_inputs;
        public String signature_type;
    }

    public class SignerPosition{
        public String appearance;
    }

    public class SignerValidationInputs{
        public String name_as_per_aadhaar;
        public String gender;
        public String last_four_digits_of_aadhaar;
        public String year_of_birth;
    }

    public class DocumentsWrapper{
        public String reference_doc_id;//
        public String docket_title;
        public String content_type;
        public String signature_sequence;
        public CustomWrapper custom;
        public String content;
    }

    public class CustomWrapper{
        public String reference_doc_id;
    }

    public class SignDeskEsignApiResponseWrapper{
        @AuraEnabled public String api_response_id{get;set;}
        //@AuraEnabled public String esign_url{get;set;}
        //@AuraEnabled public String error_code{get;set;}
        @AuraEnabled public String docket_id{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public String error{get;set;}
        //@AuraEnabled public CustomWrapper custom{get;set;}
        @AuraEnabled public List<SignerInfoWrapper> signer_info{get;set;}
        @AuraEnabled public String response_time_stamp{get;set;}
        @AuraEnabled public String status{get;set;}
    }

    /*public class CustomWrapper{
        public String parameter_name{get;set;}
        public String document_id{get;set;}
    }*/

    public class SignerInfoWrapper{
        @AuraEnabled public String signer_ref_id{get;set;}
        @AuraEnabled public String signer_id{get;set;}
        @AuraEnabled public String document_id{get;set;}
        @AuraEnabled public String invitation_link{get;set;}
        @AuraEnabled public String reference_doc_id{get;set;}

    }
}