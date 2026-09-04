public with sharing class LosKYCController {
    
    @AuraEnabled
    public static String updateRecords(String applicant, String response){
        try{
            System.debug('applicant:'+applicant);
            System.debug('response:'+response);
            SObjectAccessDecision decision;
            
            Map<String, Object> applicantDetails = (Map<String, Object>) JSON.deserializeUntyped( applicant  );
            Map<String, Object> applicantDetails2 = applicantDetails;
    
            for(String key : applicantDetails.keySet()){
              if(applicantDetails.get(key) == null || String.isBlank( String.valueOf(applicantDetails.get(key)) )){
                applicantDetails2.remove(key);
              }
            }
            
            Applicant__c app = (Applicant__c)JSON.deserialize(JSON.serialize(applicantDetails2), Applicant__c.class);            System.debug('applicant: '+app);
            
            LOSAdharKycInfoData kycData = (LOSAdharKycInfoData) JSON.deserialize(response, LOSAdharKycInfoData.class);
            System.debug('kycdata: '+kycData);
            mapAadhaarData(app.Id, kycData);
            
            List<Document_Checklist__c> docChckLst = getDocumentCheckList(app, 'Aadhaar Card');
            if(docChckLst.size() > 0) {
                docChckLst[0].Document_Verification_Status__c = 'Verified';
                if (Schema.sObjectType.Document_Checklist__c.isUpdateable()) {
                    DatabaseUtility.updateRecords(docChckLst, 'Document_Checklist__c');
                }
            }           
 
            return 'Success';
        }catch(Exception e){
            System.debug('error: '+e);
            return 'Error:'+e.getMessage();
        }
    }

    public static void mapAadhaarData(Id applicantId, LOSAdharKycInfoData data){
        System.debug('applicant:'+applicantId);
        System.debug('data:'+data);
        SObjectAccessDecision decision;
        
        Applicant__c app = new applicant__c(Id= applicantId);
        app.KYC_Status__c = 'Complete';
        app.KYC_Completion_Time__c = Date.today();    
        app.KYC_Type__c = 'Aadhaar - OTP';
        if(data.dob!= null && data.dob.contains('-')){
            List<String> dobValues = data.dob.split('-');
            app.dob__c = Date.newInstance(Integer.valueOf(dobValues[2]),Integer.valueOf(dobValues[1]),Integer.valueOf(dobValues[0]));
        }

        //bug fix SFAU-1090 start
        if(data.gender == 'F'){
            app.Gender__c = 'Female';
        }else if(data.gender == 'M'){
            app.Gender__c = 'Male';
        }else{
            app.Gender__c = data.gender;
        }
        //bug fix SFAU-1090 end

    	app.Customer_Name__c = data.name;
        app.Aadhaar_Name__c = data.name;
        List<String> nameList = data.name.split(' ');
        app.First_Name__c = nameList[0];
        
        //SFAU-5247 Start
        if(nameList.size() == 2){
            app.Last_Name__c = nameList[1];
        }else if(nameList.size() > 2){
            app.Middle_Name__c = nameList[1];
            nameList.remove(0);
            nameList.remove(0);
            //app.Last_Name__c = nameList[2];
            // R2-2808
            app.Last_Name__c = String.join(nameList, ' ');
            // R2-2808
        }
        //SFAU-5247 End

        String careOf = String.valueOf(data.co);
        String removeTitle = '';
        if(String.isNotBlank(careOf)){
            removeTitle = careOf.substring(4, careOf.length());
        }        
        if(data.co.containsIgnoreCase('W/O')) {
            app.Spouse_Name__c = removeTitle;
        }
        else {
            app.Father_Name__c = removeTitle;
        }

        app.KYC_Status__c = 'Complete'; 
        app.KYC_Type__c = 'Aadhaar - OTP';
        app.KYC_Completion_Time__c = date.today();
        
        Id appId = applicantId;
        List<Address__c> lstAddress = [Select Id, Applicant__c, Source_Type__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Source__c, Address_Type__c, City__c, District__c, Land_mark__c, Pincode__c, State__c from Address__c where Address_Type__c = 'Permanent' and Applicant__c =: applicantId];
        Address__c add = lstAddress != NULL && lstAddress.size()>0 ? lstAddress[0] : new Address__c(Applicant__c = applicantId);
    	/*add.District__c = data.dist;
    	add.Address_Line_1__c = data.house;
        add.Address_Line_2__c = data.loc;
        add.Address_Line_3__c = data.street;
        add.Taluka__c = data.vtc;
    	add.State__c = data.state;
        add.Address_Type__c = 'Permanent';
        add.Address_Source__c = 'Aadhaar Card';
        add.Pincode__c = data.pc;*/
        String addressLine1='' ;
         //Address Line 1 Mapping
         if((data.house !=null && (data.street !=null && data.street!='' ))){
            addressLine1 = + data.house + ',' + data.street; 
        } else if( (data.street !=null) && (data.house =='' || data.house == null )){
            addressLine1 = data.street; 
        } else if( (data.house !=null) && (data.street =='' || data.street == null )){
            addressLine1 = data.house; 
        } else if( (data.house ==null || data.house == '') && (data.street =='' || data.street == null )){
            addressLine1 = data.vtc;
        }
     
    	add.Address_Line_1__c =String.isNotBlank(addressLine1) ? addressLine1 :'' ;
        add.Address_Line_2__c = data.vtc;
        add.Address_Line_3__c = data.lm+' '+data.loc; // SFAU-5616
        add.Taluka__c = data.loc;
    	add.State__c = data.state;
        add.Address_Type__c = 'Permanent';
        add.Address_Source__c = 'Aadhaar Card';
        add.Pincode__c = data.pc;
        add.City__c = data.dist;
        add.District__c = data.dist;
      
        if(add.Source_Type__c==null && add.Address_Type__c!=null && add.Pincode__c!=null){
                List<Location_Master__c> negativeAreaMasterRecords = [Select Id, Zip_Code__c, Area_Status__c, Working_Area__c FROM Location_Master__c WHERE Zip_Code__c=: add.Pincode__c];

                if(negativeAreaMasterRecords!=null && negativeAreaMasterRecords.size()>0){
                    if(negativeAreaMasterRecords[0].Working_Area__c.equalsIgnoreCase('Yes')){
                        add.Geo_Limit__c = 'Acceptable';
                    }
                    if(negativeAreaMasterRecords[0].Working_Area__c.equalsIgnoreCase('No')){
                        add.Geo_Limit__c = 'Not Acceptable';
                    }
                    if(negativeAreaMasterRecords[0].Area_Status__c.equalsIgnoreCase('Positive')){
                        add.Negative_Area_Status__c = 'Positive';
                        //app.Negative_Area_Status__c='Posititve';
                    }
                    if(negativeAreaMasterRecords[0].Area_Status__c.equalsIgnoreCase('Negative')){
                        add.Negative_Area_Status__c = 'Negative';
                        //app.Negative_Area_Status__c='Negative';
                    }
        
                }
            } 
        
        if(Schema.sObjectType.Applicant__c.isUpdateable()){
            update app;
        }
        
        String serializedAddress = JSON.serializePretty(add, true);
        
        if (Schema.sObjectType.Address__c.isUpdateable() && lstAddress.size()==0) {
        	upsert add;
        }

        List<Document_Checklist__c> docChckLst = getDocumentCheckList(app, 'Aadhaar Card');
        if(docChckLst.size() > 0) {
            //docChckLst[0].Document_Verification_Status__c = 'Verified';
            docChckLst[0].Address__c = serializedAddress;
            if (Schema.sObjectType.Document_Checklist__c.isUpdateable()) {
                DatabaseUtility.updateRecords(docChckLst, 'Document_Checklist__c');
            }
        }       
        System.debug('updated:'+add.Id);
    }
    
    @AuraEnabled
    public static String updatePAN(String applicant){
        try{
            SObjectAccessDecision decision;
            Applicant__c app = (Applicant__c)JSON.deserialize(applicant, Applicant__c.class);
            System.debug('applicant: '+app);
            
            decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{app});
            update decision.getRecords();
            updatePANDocCheckList(app);
            
            return 'Success';
        }
        catch(Exception e){
            System.debug('error: '+e);
            return 'Error:'+e.getMessage();
        }
    }

    private static void updatePANDocCheckList(Applicant__c appl){
        try{
            List<Document_Checklist__c> panDocCheckList = [SELECT Id, Document_Verification_Status__c, Document_Master__r.Document_Name__c FROM Document_Checklist__c
                                                           WHERE 
                                                           Document_Master__r.Document_Name__c = 'Pan Card/Form 60' AND Applicant__c = :appl.Id 
                                                           LIMIT 1];
            panDocCheckList[0].Document_Verification_Status__c = appl.PAN_verification_Status__c;
            update panDocCheckList;
        }catch(Exception ex){
            system.debug('error '+ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String updateLoanApp(String loanApp){
        try{
            SObjectAccessDecision decision;
            Loan_Application__c app = (Loan_Application__c)JSON.deserialize(loanApp, Loan_Application__c.class);
            System.debug('applicant: '+app);
            
            decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{app});
            update decision.getRecords();
           //Call DDE Submission Notification
            if(app.Stage__c == 'DDE'){
                NotificationHandler.sendNotification('DDE Submission',app.Id,'');
            }
            return 'Success';
        }
        catch(Exception e){
            System.debug('error: '+e);
            return 'Error:'+e.getMessage();
        }
    }

    @AuraEnabled
    public static List<Document_Checklist__c> getDocumentCheckList(Applicant__c app, String docmasterName) {
        List<Document_Checklist__c> docCheckLst = [SELECT Id, Document_Verification_Status__c
                                                   FROM Document_Checklist__c where (Applicant__c =: app.Id and Document_Master__r.Document_Name__c =: docmasterName)  WITH SECURITY_ENFORCED];
        
        return docCheckLst;
    }
    
    @AuraEnabled
    public static String getApplicantData(Id applicantId){
        Applicant__c app = [SELECT Id, First_Name__c, Last_Name__c, PAN__c, Pan_Form60__c, Aadhaar_Number__c, Driving_License_Id__c, 
         Passport_Number__c, Voter_Id__c, KYC_Type__c, KYC_Status__c, PAN_verification_Status__c FROM Applicant__c where Id=: applicantId  WITH SECURITY_ENFORCED];
        
        return JSON.serialize(app);
    }

    @AuraEnabled
    public static void verifyKYC(Id applicantId){
        String docCheckId = LosSubKycController.getDocumentChecklistId(applicantId);
        if(String.isBlank(docCheckId)){
            return;
        }
        List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: docCheckId AND ContentDocument.LatestPublishedVersion.isActive__c=TRUE WITH SECURITY_ENFORCED];
       // if(!cdlList.isEmpty()){
            Applicant__c app = new Applicant__c(Id = applicantId, Kyc_Status__c = 'Complete');
            update app;
            // New condition added to update doc checklist record.
            Document_Checklist__c aadharDocRecord = new Document_Checklist__c(Id=docCheckId, Document_Verification_Status__c = 'Verified');
            update aadharDocRecord;
       // }
    }
}