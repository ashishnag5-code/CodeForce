/*******************************************************************************************
* @Name         NotepadComponentController
* @Author       Shivani Kulkarni
* @Description   Controller Class for Notepad Screen
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Shivani Kulkarni         27/02/2023         Initial Creation 
*******************************************************************************************/
public class NotepadComponentController implements IntegrationHandlerInterface {
    
    public static List<String> generateRequest(List<Object> recordList){
     	return null;
    }
    public static String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
	@AuraEnabled
    public static List<Applicant__c> getApplicantData(String applicantId){
        System.debug('id '+applicantId);
        List<Applicant__c> records = [SELECT Id,CIF_No__c 
                                      	FROM Applicant__c 
                                        WHERE  Id =:applicantId WITH SECURITY_ENFORCED];
        System.debug('list '+records);
        return records;
    }
    @AuraEnabled
    public static List<Applicant__c> getRelatedApplicants(String loanId){
        Id recId = (Id)loanId;
        String sObjName = recId.getSObjectType().getDescribe().getName();
        if(sObjName == 'Assignment__c'){
            List<Assignment__c> assignmentRec = [SELECT Id, Loan_Application__c FROM Assignment__c WHERE Id=:loanId];
            loanId = assignmentRec[0].Loan_Application__c;

        }
        List<Applicant__c> records = [SELECT Id,First_Name__c,Last_Name__c,Existing_Customer__c
                                      	FROM Applicant__c 
                                        WHERE Loan__c =:loanId AND (RecordType.Name='Applicant' OR RecordType.Name='Co-Applicant'
                                                                   OR RecordType.Name='Guarantor' OR RecordType.Name='BO') WITH SECURITY_ENFORCED];
        return records;
    }
    @AuraEnabled
    public static String saveRecord(Map<String,String> notepadData){
        System.debug('notepad '+notepadData);
        Notepad__c note = new Notepad__c();
        try{
            for(String data: notepadData.keySet()){
                if((data=='Notes_Start_Date__c' || data=='Notes_End_Date__c') && notepadData.get(data)!=null){
                    note.put(data,Date.valueOf(notepadData.get(data)));
                }
                else{
                    note.put(data,notepadData.get(data));
                }  
            }
            insert note;
            return note.Id;
        }
        catch(Exception e){
            System.debug('error '+e.getMessage());
            System.debug('error '+e.getStackTraceString());
        }
        return '';
    }
    
    @AuraEnabled
    public static String deleteRecord(String recordId){
        System.debug('recordid '+recordId);
        try{
            Notepad__c note = [SELECT Id FROM Notepad__c WHERE Id=:recordId];
            delete note;
        }
        catch(Exception e){
            System.debug('error '+e.getMessage());
        }
        return '';
    }
    
    @AuraEnabled
    public static List<Notepad__c> getNotes(String loanId){
        
        List<Notepad__c> noteList = new List<Notepad__c>();
        if(loanId!=null || loanId!=''){

            noteList = [SELECT Customer_ID__c ,Applicant__c ,Loan_Application__c ,Note_Type__c ,Name ,Notes__c ,Notes_Start_Date__c ,Notes_End_Date__c, Severity__c,
                                         Reason_for_Notes__c ,Emp_Code_Name__c,CreatedDate, Source__c, Loan_Number__c  FROM Notepad__c WHERE Loan_Application__c=:loanId];
        }
        System.debug('list of notes '+noteList);
        Map<Id,Applicant__c> appList = new Map<Id,Applicant__c>([SELECT Id FROM Applicant__c WHERE Loan__c =:loanId]);
        List<Notepad__c> notepadList = new List<Notepad__c>();
        if(appList!=null){
            notepadList = [SELECT Customer_ID__c ,Applicant__c ,Loan_Application__c ,Note_Type__c ,Name ,Notes__c ,Notes_Start_Date__c ,Notes_End_Date__c, Severity__c,
                                  Reason_for_Notes__c ,Emp_Code_Name__c,CreatedDate, Source__c  FROM Notepad__c WHERE Applicant__c IN :appList.keySet()];
        }
        System.debug('list of notes '+notepadList);
        Set<Notepad__c> result = new Set<Notepad__c>();
        result.addAll(noteList);
        result.addAll(notepadList);
        return new List<Notepad__c>(result);
    }
    
    @AuraEnabled  
    public static NotepadResponseWrapper sendNotepadDetails(Map<String,String> notepadData, String action,String loanId,String appId) {
        System.debug('Note data '+notepadData);
        System.debug('appId '+appId);
        Loan_Application__c loanObj =[SELECT Id,Loan_Number__c FROM Loan_Application__c WHERE Id=:loanId]; 
        Integration_Master__c objIntMaster = IntegrationUtility.getIntegrationMasterRecord(Label.CBS_Customer_Memo_Service_Integration_Name);
        if(appId==null || appId==''){
            objIntMaster = IntegrationUtility.getIntegrationMasterRecord(Label.CBS_Account_Memo_Service_Integration_Name);
        }
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c();
        checklistRecord.Id = NULL;
        String strResponse;
        NotepadResponseWrapper responseWrap;
        try{
          String strRequest = generateRequest(notepadData, objIntMaster, action,loanObj.Loan_Number__c);
            system.debug(LoggingLevel.DEBUG,'Request :: ' + strRequest);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = strRequest;
            calloutRequestWrapper.method = objIntMaster.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMaster;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            strResponse = calloutResponseWrapper.response;
            system.debug(LoggingLevel.Info,'resp is >> ' + strResponse);
            if(calloutResponseWrapper.statusCode!=200){
                return null;
            }
            if(strResponse != null) {
                strResponse = strResponse.replace('[[','[');
				strResponse = strResponse.replace(']]',']');
                system.debug(LoggingLevel.Info,'resp is >> ' + strResponse);
                responseWrap = (NotepadResponseWrapper) JSON.deserialize(strResponse, NotepadResponseWrapper.class);
                if(responseWrap!=null && responseWrap.TransactionStatusType.ResponseCode=='0'){
                    if(action=='i'){
                    	addRecords(responseWrap,loanId,appId);
                	}
                }
                else if(responseWrap!=null && responseWrap.TransactionStatusType.ResponseCode=='99'){
                    System.debug(responseWrap.TransactionStatusType.ExtendedErrorDetails.messages.message);
                }
            }
        } catch(Exception objException) {
            System.debug(LoggingLevel.Error,'error '+objException.getStackTraceString());
            System.debug(LoggingLevel.Error,'error '+objException.getMessage());
            System.debug(LoggingLevel.Error,'response---'+objException);
            System.debug(LoggingLevel.Error,'response-Line--'+objException.getLineNumber());
        }
        System.debug(LoggingLevel.Info,'response---'+responseWrap);
        return responseWrap;  
	}
    
    public static void addRecords(NotepadResponseWrapper responseWrap,String loanId,String appId){
        List<Notepad__c> notesList = new List<Notepad__c>();
        if(responseWrap.CustMemoDetails!=null){
            for(NotepadResponseWrapper.CustMemoDetails cust: responseWrap.CustMemoDetails){
                Notepad__c note = new Notepad__c();
                note.Notes_Start_Date__c = Date.valueOf(cust.StartDate.substring(0,4)+'-'+cust.StartDate.substring(4,6)+'-'+cust.StartDate.substring(6,8));
                note.Notes_End_Date__c = Date.valueOf(cust.EndDate.substring(0,4)+'-'+cust.EndDate.substring(4,6)+'-'+cust.EndDate.substring(6,8));
                //note.Memo_Number__c = cust.MemoNumber;
				note.Customer_Memo_Number__c = cust.MemoNumber;
                note.Notes__c = cust.MemoText;
                note.Severity__c = cust.Severity;
                note.Source__c = 'CBS';
                note.Reason_for_Notes__c = cust.ReasonForMemo;
                note.Applicant__c = appId;
                note.Note_Type__c = 'Customer ID';
                System.debug('Note object in addrecords '+note);
                notesList.add(note);
            }
            upsert notesList Customer_Memo_Number__c;
        }
        else if(responseWrap.MemoDetails!=null){
            for(NotepadResponseWrapper.MemoDetails cust: responseWrap.MemoDetails){
                Notepad__c note = new Notepad__c();
                note.Notes_Start_Date__c = Date.valueOf(cust.StartDate.substring(0,4)+'-'+cust.StartDate.substring(4,6)+'-'+cust.StartDate.substring(6,8));
                note.Notes_End_Date__c = Date.valueOf(cust.EndDate.substring(0,4)+'-'+cust.EndDate.substring(4,6)+'-'+cust.EndDate.substring(6,8));
                note.Memo_Number__c = cust.MemoNumber;
                note.Notes__c = cust.MemoText;
                note.Severity__c = cust.Severity;
                note.Source__c = 'CBS';
                note.Reason_for_Notes__c = cust.ReasonForMemo;
                note.Loan_Application__c = loanId;
                note.Note_Type__c = 'Loan ID';
                System.debug('Note object in addrecords '+note);
                notesList.add(note);
            }
            upsert notesList Memo_Number__c;
        }
        System.debug('notesList '+notesList);
        //upsert notesList Memo_Number__c;
    }
    
    @TestVisible
    private static String generateRequest(Map<String,String> note, Integration_Master__c objIntMaster,String action,String LoanNumber){
        
        NotepadRequestWrapper objRequest = new NotepadRequestWrapper();
        //objRequest.AccountID = '9001010617266485';
        //objRequest.CustomerID = '23310962';
        if(note.get('Customer_ID__c')!=null){
            objRequest.CustomerID = note.get('Customer_ID__c');
        }
        else{
            objRequest.AccountID = LoanNumber;
        }
        //objRequest.AccountID = '9001010617266485';
        //objRequest.EndDate = String.valueOf(note.get('Notes_End_Date__c'));
        objRequest.RequestId = IntegrationUtility.getReferenceId();   
        objRequest.MaintenanceMode = action;
        objRequest.TransactionBranch = '2011';  
        objRequest.OriginatingChannel = Label.Notepad_Channel;
        objRequest.ReferenceNumber = IntegrationUtility.getReferenceId();
        if(action=='a'){
            //objRequest.AccountID = note.get('Loan_Application__c');
            objRequest.ReasonForMemo = '0';
            Date startDate = date.valueOf(note.get('Notes_Start_Date__c'));
            String month=''+startDate.month();
            String day=''+startDate.day();
            if(startDate.month()<10){
                month = '0'+startDate.month();
            }
            if(startDate.day()<10){
                day = '0'+startDate.day();
            }
            String dateStr = startDate.year()+''+ month +''+day;
            objRequest.StartDate = dateStr;
            System.debug('date start '+objRequest.StartDate);
            Date endDate = date.valueOf(note.get('Notes_End_Date__c'));
            month = ''+endDate.month();
            day = ''+endDate.day();
            if(endDate.month()<10){
                month = '0'+endDate.month();
            }
            if(endDate.day()<10){
                day = '0'+endDate.day();
            }
            dateStr = endDate.year()+''+ month +''+day;
            objRequest.EndDate = dateStr;
            System.debug('date end '+objRequest.EndDate);
            objRequest.Severity = 'L';
            objRequest.OriginatingChannel = Label.Notepad_Channel;
            objRequest.MemoText = note.get('Notes__c');
        }
        System.debug('Request '+JSON.serialize(objRequest));
      	return JSON.serialize(objRequest);
    }
    
    @AuraEnabled
    public static NotepadResponseWrapper getLatestNote(String loanId){
        List<Notepad__c> notes = [SELECT Id,Customer_Memo_Number__c,Memo_Number__c,Customer_ID__c,Notes_Start_Date__c,Notes_End_Date__c,Notes__c,Loan_Number__c,CreatedDate,Applicant__c FROM Notepad__c WHERE Loan_Application__c=:loanId OR Applicant__r.Loan__c=:loanId ORDER BY CreatedDate DESC LIMIT 1];
        Map<String,String> notesMap = new Map<String,String>();
        if(notes.size()!=0){
            Notepad__c note = notes[0];
        	notesMap.put('Customer_ID__c',note.Customer_ID__c);
          	notesMap.put('Notes__c',note.Notes__c);
            notesMap.put('Loan_Number__c',note.Loan_Number__c);
            notesMap.put('Notes_Start_Date__c',String.valueOf(note.Notes_Start_Date__c));
            notesMap.put('Notes_End_Date__c',String.valueOf(note.Notes_End_Date__c));
            NotepadResponseWrapper responseObj;
            try{
                responseObj = sendNotepadDetails(notesMap,'a',loanId,note.Applicant__c);
                if(responseObj!=null && responseObj?.TransactionStatusType?.ResponseMessage=='Success'){
                    System.debug(responseObj.MemoNumber);
                    if(note.Customer_ID__c!=null || note.Customer_ID__c!=''){
                        note.Customer_Memo_Number__c = responseObj.MemoNumber;
                    }
                    else{
                        note.Memo_Number__c = responseObj.MemoNumber;
                    }
                    //note.Memo_Number__c = responseObj.MemoNumber;
                    update note;
                    Loan_Application__c loanObj = new Loan_Application__c(Id=loanId,isNoteSynced__c=true);
                    update loanObj;
                    return responseObj;
                }
            }
            catch(Exception e){
                System.debug('Error '+e.getMessage());
                return responseObj;
            }
        }
        return null;
    }
}