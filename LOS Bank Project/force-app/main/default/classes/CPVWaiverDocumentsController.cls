public without sharing class CPVWaiverDocumentsController {

    @AuraEnabled
    public static List<Applicant__c> getApplicants(Id applicantId){

        List < Applicant__c > applicantList = new List < Applicant__c > ();
           try {
               applicantList = [SELECT Id,Customer_Name__c, Existing_Customer__c, Bureau_Score__c, First_Name__c, Middle_Name__c, Last_Name__c, Name, Loan__c, Loan_Stage__c, AU_Employee__c, Name_of_Employee_AU__c, Customer_Type__c, Loan__r.EMI__c, Total_Monthly_Income_Sum__c, Current_Obligation__c, Free_Monthly_Cashflow__c, Total_Loan_Amount__c, FOIR__c, Loan__r.Product__c, Loan__r.Stage__c, RecordType.DeveloperName, RecordType.Name,Wheels_Exposure__c,Total_Exposure__c,
                   Relationship_with_applicant__c, KYC_Status__c, CIF_No__c
                   FROM Applicant__c
                   WHERE(Loan__c =: applicantId OR Id =: applicantId)
                   AND RecordType.DeveloperName in ('BO','Primary_Applicant','Co_Applicant','Guarantor') 
                   AND isInactive__c=false
                   WITH SECURITY_ENFORCED
               ];

           } catch (Exception e) {
               Log.error(e, Log.SeverityType.valueOf('High'), '');
           }
           return applicantList;
    }

    @AuraEnabled
    public static Applicant__c getApplicantDetails(String recordId){
        List<Applicant__c> applicants;
        try {
            applicants = [SELECT Id, Loan__r.Stage__c, Loan__c, Loan__r.RecordType.DeveloperName FROM Applicant__c WHERE Id=:recordId];
            if(applicants!=null && applicants.size()>0){
                return applicants[0];
            }     
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static String getProductType(Id recordId){

        List<Loan_Application__c> loanApps = [SELECT Id, Product__c FROM Loan_Application__c WHERE Id=:recordId WITH SECURITY_ENFORCED];
        if(loanApps!=null && loanApps.size()>0){
            String product = 'A_'+loanApps[0].Product__c;
            ProductRTMap__mdt productType = ProductRTMap__mdt.getInstance(product);
            if(productType!=null){
                return productType.RecordType__c;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static List<Document_Checklist__c> getVerifiedRecords(Id recordId, List<String> documentType){

        List<Document_Checklist__c> docCheckListRecords = [SELECT Id, Document_Master__r.Document_Name__c, Status__c,Amount__c,Document_Verification_Status__c, Document_Number__c, Address_Match_Score__c, Api_Response__c
            FROM Document_Checklist__c WHERE 
            Applicant__c=:recordId AND (Document_Verification_Status__c=:GlobalConstants.VERIFIED OR Status__c='Received') AND
            Document_Master__r.Document_Name__c in :documentType with SECURITY_ENFORCED
            ORDER BY CreatedDate DESC];
        
        return docCheckListRecords;
        
    }

    @AuraEnabled 
    public static Document_Checklist__c checkIfAlreadyUploadedForFinancials(Id recordId, List<String> documentType){
        Boolean returnValue;
        List<Document_Checklist__c> docCheckListRecords = [SELECT Id, Status__c,Amount__c,Document_Verification_Status__c, Document_Number__c, Address_Match_Score__c, Api_Response__c
            FROM Document_Checklist__c WHERE 
            Applicant__c=:recordId AND
            Document_Master__r.Document_Name__c IN :documentType WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC LIMIT 1];
        if(docCheckListRecords!=null && docCheckListRecords.size()==1){
            if(docCheckListRecords[0].Status__c=='Received'){
                List<Bank_Account_Records__c> bankRecords = [SELECT Id, Analysis_Data__c FROM Bank_Account_Records__c WHERE Applicant__c=:recordId AND RecordType.DeveloperName='Cart'
                    Order By CreatedDate Desc LIMIT 1];
                if(bankRecords!=null && bankRecords.size()>0 && bankRecords[0].Analysis_Data__c!=null){
                    return docCheckListRecords[0];
                }


            }
        }
        return null;
    }

    @AuraEnabled
    public static string viewLatestUploadedBankStatement(String recordId, String docName){
        try {
            List<Document_Checklist__c> docCheckList = [SELECT Id FROM Document_Checklist__c WHERE Applicant__c=:recordId AND
            Document_Master__r.Name=:docName];
            List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:docCheckList[0].Id];
            List<String> links = new List<String>();
            for(ContentDocumentLink link: cdl){
                links.add(link.ContentDocumentId);
            }
            List<ContentVersion> cvs = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId in: links order by createddate desc];
            return cvs[0].ContentDocumentId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ContentVersion> getUploadedITRS(String recordId, String docName){
        try {
            List<Document_Checklist__c> docCheckList = [SELECT Id FROM Document_Checklist__c WHERE Applicant__c=:recordId AND
            Document_Master__r.Name=:docName];
            List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:docCheckList[0].Id ];
            List<String> links = new List<String>();
            for(ContentDocumentLink link: cdl){
                links.add(link.ContentDocumentId);
            }
            List<ContentVersion> cvs = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId in: links order by createddate desc];
            return cvs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static Decimal getAmount(Id recordId, String documentType){
        Boolean returnValue;
        List<Document_Checklist__c> docCheckListRecords = [SELECT Amount__c,Document_Verification_Status__c, Document_Number__c, Address_Match_Score__c
            FROM Document_Checklist__c WHERE 
            Applicant__c=:recordId AND
            Document_Master__r.Name=:documentType WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC LIMIT 1];
        if(docCheckListRecords!=null && docCheckListRecords.size()==1)
            return docCheckListRecords[0].Amount__c;
        else    
            return null;
    }
    
    @AuraEnabled 
    public static Document_Checklist__c checkIfAlreadyUploaded(Id recordId, String documentType){
        Boolean returnValue;
        List<Document_Checklist__c> docCheckListRecords = [SELECT Id, Status__c,Amount__c,Document_Verification_Status__c, Document_Number__c, Address_Match_Score__c, Api_Response__c
            FROM Document_Checklist__c WHERE 
            Applicant__c=:recordId AND
            Document_Master__r.Document_Name__c=:documentType WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC LIMIT 1];
        if(docCheckListRecords!=null && docCheckListRecords.size()==1)
            return docCheckListRecords[0];
        else    
            return new Document_Checklist__c();
    }

    @AuraEnabled
    public static Document_Checklist__c markVerified(Id recordId, String documentType, String DocumentNumber, String response, Decimal addressMatchScore){
        Boolean returnValue;
        List<Document_Checklist__c> docCheckListRecords = [SELECT Id, Status__c,Amount__c, Document_Number__c, Address_Match_Score__c
            FROM Document_Checklist__c WHERE 
            Applicant__c=:recordId AND
            Document_Master__r.Document_Name__c=:documentType WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC LIMIT 1];
        docCheckListRecords[0].Document_Number__c=DocumentNumber;
        docCheckListRecords[0].Document_Verification_Status__c=GlobalConstants.VERIFIED;
        docCheckListRecords[0].Api_Response__c=response;
        addressMatchScore = addressMatchScore==-101?null:addressMatchScore;
        docCheckListRecords[0].Address_Match_Score__c=addressMatchScore;
        system.debug('documentType '+documentType);
        if(documentType.equalsignoreCase('electricity bill')){
            system.debug('inside if');
            Decimal amt;
            KarzaElectricityBillHandler.KarzaElectricityBillResult responseWrap = 
            (KarzaElectricityBillHandler.KarzaElectricityBillResult) JSON.deserialize (response, KarzaElectricityBillHandler.KarzaElectricityBillResult.class);
            system.debug('responseWrap.amount_payable '+responseWrap.amount_payable);
            if(String.isNotBlank(responseWrap.amount_payable) ){
                if(responseWrap.amount_payable.contains('Rs. ')){
                    amt = Decimal.valueOf(responseWrap.amount_payable.replace('Rs. ',''));
                }else{
                    amt =  Decimal.valueOf(responseWrap.amount_payable);
                }
            }else{
                amt = null;
            }
            docCheckListRecords[0].Amount__c = amt;
        }else if(documentType.equalsignoreCase('gas bill')){
            KarzaLPGBillHandler.KarzaLPGBillResult responseWrap = 
            (KarzaLPGBillHandler.KarzaLPGBillResult) JSON.deserialize (response, KarzaLPGBillHandler.KarzaLPGBillResult.class);
            docCheckListRecords[0].Amount__c = responseWrap.GivenUpSubsidy!=null && responseWrap.GivenUpSubsidy!=''?Decimal.valueOf(responseWrap.GivenUpSubsidy):null;
        }else if(documentType.equalsignoreCase('png bill')){
            KarzaPNGBillHandler.KarzaPNGBillResult responseWrap = 
            (KarzaPNGBillHandler.KarzaPNGBillResult) JSON.deserialize (response, KarzaPNGBillHandler.KarzaPNGBillResult.class);
            docCheckListRecords[0].Amount__c = responseWrap.Bill_Amount!=null && responseWrap.Bill_Amount!=''?Decimal.valueOf(responseWrap.Bill_Amount):null;
        }
        update docCheckListRecords[0];
        return docCheckListRecords[0];
    }

    @AuraEnabled
    public static String addressMatch(String address, Id recordId, Id loanAppId, String type){
        system.debug('inside CPV');
        Address__c newAddress = LOSAddressSplitController.callAddressSplitApi(address, recordId);
        String newAddressToString = JSON.serialize(newAddress);
        return newAddressToString;
        
    }

    @AuraEnabled
    public static Decimal callValidateAddressMatch(String newAddressToString, String recordId, String type){
        
        LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper result = new LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper();
        
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> newAddressSourceWrapper = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        Address__c newAddress = (Address__c) JSON.deserialize(newAddressToString, Address__c.class);
        newAddressSourceWrapper.add(mapWrapperObject(newAddress));

        Address__c objAddress = [SELECT Id , Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Type__c,
        Applicant__c, State__c, City__c, Pincode__c,District__c FROM Address__c 
        where Applicant__c=:recordId and Address_Type__c='Current' and Address_Type__c != null
        AND Source_Type__c != 'Cibil' WITH SECURITY_ENFORCED limit 1];
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> newAddressTargetWrapper = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        newAddressTargetWrapper.add(mapWrapperObject(objAddress));  
        String data = LOSKarzaAddressMatchController.validateAddressMatch(newAddressSourceWrapper,newAddressTargetWrapper,recordId,'CPV',type);
        LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper responseWrapper = (LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper) 
        JSON.deserialize(data, LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper.class);
        if(responseWrapper!=null && responseWrapper.result!=null && responseWrapper.result.flags!=null && responseWrapper.result.flags[0].address.scores!=null && responseWrapper.result.flags[0].address.scores.size()>0){
            return responseWrapper.result.flags[0].address.scores[0].score * 100;
            //docCheckListRecords[0].Address_Match_Score__c=responseWrapper.result.flags[0].address.scores[0].score * 100;
            //sObjectListToUpdate.add(docCheckListRecords[0]);
        }else{
            return null;
            //docCheckListRecords[0].Address_Match_Score__c = null;
            //sObjectListToUpdate.add(docCheckListRecords[0]);
        }
        /*List<Document_Checklist__c> docCheckListRecords = [SELECT Id,Address_Match_Score__c, Document_Number__c, Document_Master__c,Status__c,
        Document_Master__r.Document_Name__c, Applicant__c, Applicant__r.Loan__c,
        Applicant__r.RecordTypeId, Applicant__r.RecordType.DeveloperName
        FROM Document_Checklist__c WHERE 
        Applicant__c=:recordId AND
        Document_Master__r.Document_Name__c=:type
        ORDER BY CreatedDate DESC LIMIT 1];
        system.debug('docCheckListRecords '+docCheckListRecords);
        system.debug('Add Match Score '+docCheckListRecords[0].Address_Match_Score__c);
        if(docCheckListRecords[0].Address_Match_Score__c!=null){
            return String.valueOf(docCheckListRecords[0].Address_Match_Score__c);          
        }else{
            return null;
        }*/
        
    }

    public static LOSKarzaAddressMatchIntHandler.AddressRequestWrapper mapWrapperObject(Address__c address){
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper mappedWrapper = new LOSKarzaAddressMatchIntHandler.AddressRequestWrapper();
        mappedWrapper.addressLine1 = address.Address_Line_1__c;
        mappedWrapper.addressLine2 = address.Address_Line_2__c;
        mappedWrapper.city = address.City__c;
        mappedWrapper.state = address.State__c;
        mappedWrapper.district = address.District__c;
        mappedWrapper.pincode = address.Pincode__c;
        return mappedWrapper;
    }

    @AuraEnabled
    public static List<Generic_Master__c> getServiceProviderInformation(String providerType){
        List<Generic_Master__c> serviceProviders = [SELECT Id, State__c, Service_Provider_Name__c, Service_Provider_Code__c FROM Generic_Master__c 
        WHERE RecordType.DeveloperName=:providerType];
        if(serviceProviders!=null && serviceProviders.size()>0){
            return serviceProviders;
        }else{
            return null;
        }
    }
     // added for 3131
     @AuraEnabled
     public static void deleteBankStatement(String recordId, String conDocId){
         try {
             Id cartRedTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
             // List<Document_Checklist__c> docCheckList = [SELECT Id FROM Document_Checklist__c WHERE Applicant__c=:recordId AND
             // Document_Master__r.Name=:docName];
             // List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:docCheckList[0].Id];
             // List<String> links = new List<String>();
             // for(ContentDocumentLink link: cdl){
             //     links.add(link.ContentDocumentId);
             // }
             database.Delete([SELECT Id FROM ContentDocument WHERE ID=:conDocId]);
             database.Delete([SELECT Id FROM Bank_Account_Records__c WHERE Applicant__c =:recordId AND RecordTypeId =:cartRedTypeId AND Manual_Check__c = false]);
         } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());
         }
     }
}