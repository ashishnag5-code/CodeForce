public with sharing class LOSKarzaNameMatchController {
    @AuraEnabled
    public static String validateNameMatch(String strName, String strType, String strApplicantId, String strRecordId) {
        String respBody;
        try{
            Boolean boolFromPan = false;
            Boolean boolFromCBS = false;
            Applicant__c objApplicant = [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Customer_Name__c, Name, Aadhaar_Name__c, Aadhaar_Number__c, CBS_Name__c, Loan__c, RecordType.Name, Existing_Customer__c, is_Non_Compliant_ETB_Customer__c FROM Applicant__c where Id=:strApplicantId  WITH SECURITY_ENFORCED limit 1];
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Karza Name Match');
            Map<String,Object> reqParam = new Map<String,Object>();
            /*reqParam.put('name1',objApplicant.Aadhaar_Name__c);
            // from CBS - compare with CBS else Pan.
            if(strType == 'Pan' && !String.isBlank(objApplicant.CBS_Name__c)){
                boolFromCBS = true;
                reqParam.put('name2',objApplicant.CBS_Name__c);
            }
            else if(strType == 'Pan'){
                boolFromPan = true;
                reqParam.put('name2',strName);
            }*/
            if(strType == 'Collateral' || strType == 'Vahaan'){
                reqParam.put('name1',objApplicant.Customer_Name__c);                
            }
            else{
                //R2-41 Name match for existing customer to be done incase of Non Compliance found
                if(!String.isBlank(objApplicant.CBS_Name__c) && objApplicant.Existing_Customer__c=='Yes' && objApplicant.is_Non_Compliant_ETB_Customer__c==true){
                    boolFromCBS = true;
                    reqParam.put('name1',objApplicant.CBS_Name__c);
                }else if(objApplicant.Existing_Customer__c!='Yes'){
                    if(!String.isBlank(objApplicant.Aadhaar_Name__c)) {
                        boolFromPan = true;
                        reqParam.put('name1',objApplicant.Aadhaar_Name__c);
                    }else{
                        String applicantFullName = (objApplicant.First_Name__c!=null?objApplicant.First_Name__c+' ':'')+(objApplicant.Middle_Name__c!=null?objApplicant.Middle_Name__c+' ':'')+(objApplicant.Last_Name__c!=null?objApplicant.Last_Name__c:'');
                        reqParam.put('name1',applicantFullName);
                    }
                }
                
            }
            if(reqParam.get('name1')!=null && reqParam.get('name1')!=''){
                reqParam.put('name2',strName);
                String requestBody = LOSKarzaNameMatchIntHandler.generateRequest(reqParam)[0];
                String objectId = '';
                system.debug('%%'+requestBody);
                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = requestBody;
                calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                calloutRequestWrapper.masterRecord = objIntMapper;
                calloutRequestWrapper.checklistRecord = checklistRecord;
                IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
                respBody = calloutResponseWrapper.response;
                LOSKarzaNameMatchIntHandler.NameMatchResponseWrapper objResultWrapper
                    = (LOSKarzaNameMatchIntHandler.NameMatchResponseWrapper) System.JSON.deserialize(respBody, LOSKarzaNameMatchIntHandler.NameMatchResponseWrapper.class);
                //saveNameMatch(respBody,strApplicantId,boolFromPan);
                if(strType == 'Collateral'){
                    Collateral__c objCollateral = new Collateral__c(Id = strRecordId);
                    objCollateral.Collateral_Name_Match_Percentage__c = objResultWrapper.result.score;
                    update objCollateral;
                }
                else if(strType == 'Vahaan'){
                    Collateral__c objCollateral = new Collateral__c(Id = strRecordId);
                    objCollateral.Vahaan_Name_Match_Percentage__c = objResultWrapper.result.score;
                    update objCollateral;
                }
                else if(strType == 'Electricity bill'){
                    Utility.storeMatchResults('Name',strType,'Electricity Bill',objResultWrapper.result.score,strApplicantId,false);
                }
                else if(strType == 'PNG bill'){
                    Utility.storeMatchResults('Name',strType,'PNG bill',objResultWrapper.result.score,strApplicantId,false);
                }
                else if(strType == 'Gas bill'){
                    Utility.storeMatchResults('Name',strType,'Gas bill',objResultWrapper.result.score,strApplicantId,false);
                }
                else if(strType=='Driving Licence'){
                    Utility.storeMatchResults('Name',strType,'Driving Licence',objResultWrapper.result.score,strApplicantId,false);
                }
                else if(strType=='Passport'){
                    Utility.storeMatchResults('Name',strType,'Passport',objResultWrapper.result.score,strApplicantId,false);
                }
                else if(strType=='Voter ID Card'){
                    Utility.storeMatchResults('Name',strType,'Voter ID Card',objResultWrapper.result.score,strApplicantId,false);
                }
                else if(strType=='Pan'){
                    Utility.storeMatchResults('Name',strType,'Pan Card/Form 60',objResultWrapper.result.score,strApplicantId,false);
                }
                else if(strType=='Bank Statement'){
                    Utility.storeMatchResults('Name',strType,'Bank Statement',objResultWrapper.result.score,strApplicantId,false);
                }
                else{
                   if(boolFromPan && objResultWrapper != null && objResultWrapper.result != null && objResultWrapper.result.score != null){
                        Utility.storeMatchResults('Name',strType,'Aadhar Card Copy',objResultWrapper.result.score,strApplicantId,false);
                    }
                    else if(boolFromCBS && objResultWrapper != null && objResultWrapper.result != null && objResultWrapper.result.score != null){
                        Utility.storeMatchResults('Name','CBS','Aadhar Card Copy',objResultWrapper.result.score,strApplicantId,false);
                    }
                    else if(objResultWrapper != null && objResultWrapper.result != null && objResultWrapper.result.score != null){
                        Utility.storeMatchResults('Name','Aadhar Card Copy',strType ,objResultWrapper.result.score,strApplicantId,false);
                    } 
                }
                if(strType == 'Pan' && objApplicant.Aadhaar_Number__c!=null && objApplicant.Aadhaar_Name__c!=null){
                    if(objResultWrapper!=null && objResultWrapper.result!=null){
                        if((objResultWrapper.result.score*100)<Double.valueOf(System.Label.Min_PAN_Name_Match_Score)){
                            List<Deviation__c> deviationsToUpsert = new List<Deviation__c>();
                            List<Deviation__c> deviations = [SELECT Id, Archived__c, Active__c FROM Deviation__c WHERE 
                                Deviation_Type__c=:GlobalConstants.NAME_MATCH_LESS_THAN_THRESHOLD AND Applicant__c=:strApplicantId AND Archived__c=false];
                            Deviation__c objDeviation = new Deviation__c();
                            objDeviation.Level__c = '';
                            objDeviation.Variance__c = objResultWrapper.result.score*100;
                            objDeviation.Applicant__c = strApplicantId;
                            //objDeviation.Details__c =GlobalConstants.NAME_MATCH_LESS_THAN_THRESHOLD;
                            //objDeviation.Details__c = '('+objApplicant.RecordType.Name+') - '+'PAN Name : '+reqParam.get('name1')+', Aadhaar Name : '+reqParam.get('name2');
                            objDeviation.Details__c = '('+objApplicant.RecordType.Name+') - '+'PAN Name : '+strName+', Aadhaar Name : '+objApplicant.Aadhaar_Name__c;
                            objDeviation.Loan_Application__c = objApplicant.Loan__c;
                            objDeviation.Deviation_Type__c = GlobalConstants.NAME_MATCH_LESS_THAN_THRESHOLD;
                            objDeviation.Source__c = 'SF';
                            objDeviation.Active__c = true;
                            deviationsToUpsert.add(objDeviation);
                            if(!deviations.isEmpty()){
                                for(Deviation__c dev: deviations){
                                    dev.Archived__c=true;
                                    dev.Active__c=false;
                                    deviationsToUpsert.add(dev);
                                }
                            }
                            upsert deviationsToUpsert;
                            //insert objDeviation;
                        }
                    }
                }
            }
            
           
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),strApplicantId);
        }
        return respBody;
    }
    /*
    private static void saveNameMatch(String respBody,String applicantId, Boolean boolFromPan){
        LOSKarzaNameMatchIntHandler.NameMatchResponseWrapper objResultWrapper
                = (LOSKarzaNameMatchIntHandler.NameMatchResponseWrapper) System.JSON.deserialize(respBody, LOSKarzaNameMatchIntHandler.NameMatchResponseWrapper.class);
        //Save logic 
        List<Document_Checklist__c> lstDocChecklisttoUpdate = new List<Document_Checklist__c>();
        List<Document_Checklist__c> lstDocChecklist = [Select Id,Document_Master__c,Document_Master__r.Document_Name__c,Applicant__c from Document_Checklist__c
                                        where Document_Master__r.Document_Name__c = 'Aadhar Card Copy' and Applicant__c =:applicantId WITH SECURITY_ENFORCED];
        if(objResultWrapper != null && objResultWrapper.result != null && objResultWrapper.result.score != null && !lstDocChecklist.isEmpty()){
            Document_Checklist__c objDocChecklist = lstDocChecklist[0];
            objDocChecklist.Match_Type__c = 'Name';
            objDocChecklist.Match_Percentage__c = objResultWrapper.result.score;
            if(boolFromPan){
                objDocChecklist.Match_From__c = 'Pan';
            }
            else{
                objDocChecklist.Match_From__c = 'CBS';
            }
            lstDocChecklisttoUpdate.add(objDocChecklist);
        }
        DatabaseUtility.updateRecords(lstDocChecklisttoUpdate,'');
    }*/
}