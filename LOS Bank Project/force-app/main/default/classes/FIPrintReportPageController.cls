public with sharing class FIPrintReportPageController {
    private FieldInvestigationQuestionaireController.QuestionaireWrapperListData questionWrap;
    public List<FieldInvestigationQuestionaireController.QuestionaireWrapper> lstUpdatedApplicant {get;set;}
    public List<FieldInvestigationQuestionaireController.QuestionaireWrapper> lstUpdatedVehicle {get;set;}
    public List<FieldInvestigationQuestionaireController.QuestionaireWrapper> FIRecordList {get;set;}
    
    public Field_Investigation__c objFI {get;set;}
    public List<String> lstImage {get;set;}
    public String txtfield {get;set;}
    
    
    public FIPrintReportPageController(){
        
        String recId = ApexPages.currentPage().getParameters().get('recId');
        System.debug('recId ::  '+recId);
        recId = String.isBlank(recId) ? 'a0i6s000000G6SmAAK' : recId;
        String blnm = ApexPages.currentPage().getParameters().get('blnm');
        Boolean blnFromMobile = blnm == NULL || blnm == '1' ? true : false;
        Set<String> SobjectFields = Schema.getGlobalDescribe().get('Field_Investigation__c').getDescribe().fields.getMap().keySet();    
        List<String> fieldsInList = new List<String>(SobjectFields);
        Field_Investigation__c objFI = Database.query('SELECT ' + String.join(fieldsInList, ',') + ' FROM Field_Investigation__c where Id = \'' + recId + '\'');
        System.debug('objFI ::  '+objFI);
        Integer counter = 0;
        questionWrap = FieldInvestigationQuestionaireController.Questionaire(objFI.Proposed_vehicle__c,objFI.Applicant_Type__c,true, blnFromMobile);
        lstUpdatedApplicant = new List<FieldInvestigationQuestionaireController.QuestionaireWrapper>();
        for (FieldInvestigationQuestionaireController.QuestionaireWrapper o : questionWrap.BorrowerList) {
            FieldInvestigationQuestionaireController.QuestionaireWrapper newwrapborrower = o;
            newwrapborrower.data = objFI.get(o.apiName);
            newwrapborrower.counter = ++counter + '. ';
            lstUpdatedApplicant.add(newwrapborrower);
            system.debug(':: newwrapborrower  ' + newwrapborrower);
        }
        lstUpdatedVehicle = new List<FieldInvestigationQuestionaireController.QuestionaireWrapper>();
        counter = 0;
        for (FieldInvestigationQuestionaireController.QuestionaireWrapper o : questionWrap.VehicleList) {
            FieldInvestigationQuestionaireController.QuestionaireWrapper newwrapvehicle = o;
            newwrapvehicle.data = objFI.get(o.apiName);
            newwrapvehicle.counter = ++counter + '. ';
            lstUpdatedVehicle.add(newwrapvehicle);
            system.debug(':: newwrapvehicle  ' + newwrapvehicle);
        }
        
        FIRecordList = new List<FieldInvestigationQuestionaireController.QuestionaireWrapper>();
        counter = 0;
        system.debug(':: questionWrap.FIRecordList  ' + questionWrap.FIRecordList);
        for (FieldInvestigationQuestionaireController.QuestionaireWrapper o : questionWrap.FIRecordList) {
            FieldInvestigationQuestionaireController.QuestionaireWrapper firecord = o;
            if(o.apiName == 'FI_Submission_Date_Time__c'|| o.apiName == 'FI_Allocation_Date_Time__c' || o.apiName == 'FI_Conducted_Date_Time__c'){
                firecord.data = getDateInUserLocale(String.valueOf(objFI.get(o.apiName)));
            }
            else{
                firecord.data = String.valueOf(objFI.get(o.apiName));
            }
            //firecord.data = String.valueOf(objFI.get(o.apiName));
            //firecord.counter = ++counter + '. ';
            FIRecordList.add(firecord);
            system.debug(':: FIRecordList  ' + firecord);
        }
        
        List<Document_Checklist__c> lstDocChecklist = [Select Id from Document_Checklist__c where Document_Master__r.Document_Id__c = 'AUWheels0053' and Field_Investigation__c =: recId];
        system.debug(':: lstDocChecklist  ' + lstDocChecklist);
        if (!lstDocChecklist.isempty()) {
            Id docCheckId = lstDocChecklist[0].Id;
            Set<Id> setContentDocId = new Set<Id>();
            system.debug(':: docCheckId  ' + docCheckId);
            for (ContentDocumentLink obj : [Select id, ContentDocumentId from ContentDocumentLink where LinkedEntityId =: docCheckId])
                setContentDocId.add(obj.ContentDocumentId);
            
            system.debug(':: setContentDocId  ' + setContentDocId);
            lstImage = new List<String>();
            for (ContentVersion objConVer : [Select id from ContentVersion where ContentDocumentId in: setContentDocId]) {
                lstImage.add('/sfc/servlet.shepherd/version/download/'+objConVer.Id);    
            }
        }
        system.debug(':: lstImage  ' + lstImage);
    }
    
    public void getRecordDetails(){
    }
    
    public static String getDateInUserLocale(String dateTimeValue){
        if(String.isnotBlank(dateTimeValue)){
            Datetime now =Datetime.valueOf(dateTimeValue);
            Integer offset = UserInfo.getTimezone().getOffset(now);
            Datetime local = now.addSeconds(offset/1000);
            return String.valueOf(local);
        }
        else{
            return '';
        }
        
        
    }
}