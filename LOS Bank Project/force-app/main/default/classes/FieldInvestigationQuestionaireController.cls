/**
 * @description       : This class for Field Investigation LWC component
 * @author            : Vikas Singhal | Salesforce
 * @last modified on  : Jan-20-2023
**/
public with sharing class FieldInvestigationQuestionaireController {
    private static Boolean isCVProduct(String proposedVehicle) {
        if (String.isNotBlank(proposedVehicle)) {
            return false;
        }
        if (proposedVehicle.contains('CV Loading') || proposedVehicle.contains('CV Passenger') || proposedVehicle.contains('Car Taxi')) {
            return true;
        }
        return false;
    }

    /**
     * @description       : This method is used to query all the custom metadata related to Questionaire to display on Questionaire Screen
     * @author            : Vikas Singhal | Salesforce
     * @last modified on  : Jan-20-2023
    **/
    @AuraEnabled
    public static QuestionaireWrapperListData Questionaire(String proposedVehicle,String applicantType, Boolean blnMandatory, Boolean blnFromMobile){
        try {
            Map<String,String> QuestionaireMap = new Map<String,String>();
            List<FieldDefinition> lstFieldInvDef = [Select Label, QualifiedApiName, Description
            from FieldDefinition Where EntityDefinition.QualifiedApiName='Field_Investigation__c' WITH SECURITY_ENFORCED];
            for(FieldDefinition fieldAPI : lstFieldInvDef) {
                QuestionaireMap.put(fieldAPI.QualifiedApiName,fieldAPI.Description);
            }
            String strWhereClasuse = '';
            Boolean isTwoWheeler =false;
            String vehicleWhereCls;
            System.debug(LoggingLevel.Info,'proposedVehicle--' + proposedVehicle);
            if (proposedVehicle == GlobalConstants.AUTOLOANNEW || proposedVehicle == GlobalConstants.AUTOLOANUSED || proposedVehicle == GlobalConstants.AUTOLOANCASH 
            || System.label.AutoLoanCowLabel.contains(proposedVehicle) || isCVProduct(proposedVehicle)) { // SFAU-5584 Cow Product
                vehicleWhereCls = ' WHERE Vehicle__c = true AND Active__c = \'Yes\'' + ' ORDER BY Order__c';
                if (applicantType == GlobalConstants.APPLICANT) {
                    strWhereClasuse = ' Borrower__c = true AND Active__c = \'Yes\'';
                }
                else if (applicantType == GlobalConstants.GUARANTOR) {
                    strWhereClasuse = ' Guarantor__c = true AND Active__c = \'Yes\'';
                }
                else if (applicantType == GlobalConstants.COAPPLICANT) {
                    strWhereClasuse =  ' Co_Borrower__c = true AND Active__c = \'Yes\'';
                }
            } 
            else if (proposedVehicle == GlobalConstants.TWOWHEELERNEW || proposedVehicle == GlobalConstants.TWOWHEELERUSED
            || proposedVehicle == GlobalConstants.TWOWHEELERCASH || System.label.TWCowLabel.contains(proposedVehicle)) {
                isTwoWheeler =true;
                if (applicantType == GlobalConstants.APPLICANT) {
                    strWhereClasuse = ' isBorroweTwoWheeler__c = true AND Active__c = \'Yes\'';
                    vehicleWhereCls = ' WHERE Vehicle__c = true AND Vehicle2WBorrower__c = false AND Active__c = \'Yes\'' + ' ORDER BY Order__c';
                }
                else if (applicantType == GlobalConstants.GUARANTOR) {
                    strWhereClasuse = ' isGuarantorTwoWheeler_c__c = true AND Active__c = \'Yes\'';
                    vehicleWhereCls = ' WHERE Vehicle__c = true AND Vehicle2WGuarantor__c = false AND Active__c = \'Yes\'' + ' ORDER BY Order__c';
                }
                else if (applicantType == GlobalConstants.COAPPLICANT) {
                    strWhereClasuse =  ' isCoBorroweTwoWheeler_c__c = true AND Active__c = \'Yes\'';
                    vehicleWhereCls = ' WHERE Vehicle__c = true AND Vehicle2WCoBorrower__c = false AND Active__c = \'Yes\'' + ' ORDER BY Order__c';
                }
            } else {
                vehicleWhereCls = ' WHERE Vehicle__c = true AND Active__c = \'Yes\'' + ' ORDER BY Order__c';
                if (applicantType == GlobalConstants.APPLICANT) {
                    strWhereClasuse = ' Borrower__c = true AND Active__c = \'Yes\'';
                }
                else if (applicantType == GlobalConstants.GUARANTOR) {
                    strWhereClasuse = ' Guarantor__c = true AND Active__c = \'Yes\'';
                }
                else if (applicantType == GlobalConstants.COAPPLICANT) {
                    strWhereClasuse =  ' Co_Borrower__c = true AND Active__c = \'Yes\'';
                }
            }
        String strquery = 'Select Id,IsNotToBeRenderedFirstTime__c ,Is_Form_Detail__c, Vehicle2WCoBorrower__c,Vehicle__c,IsMandatoryForVehicle__c,IsMandatoryForBorrower__c,IsMandatoryForCoBorrower__c,IsMandatoryForGuarantor__c,Two_Wheeler__c,Auto_Loan__c,Order__c,Field_API_Name__c,Section__c,Type_of_Address__c,Active__c,Borrower__c,Co_Borrower__c,Current__c,Guarantor__c,Office__c,Permanent__c,IsMobileNumberField__c  ';
        String strqueryApp = strquery + 'FROM Fi_questionnaire__mdt ';// added new metadata field IsMobileNumberField__c 
        if (String.isBlank(strWhereClasuse)) {
            strqueryApp = strqueryApp + ' ORDER BY Order__c';
        } else {
            strqueryApp = strqueryApp + ' WHERE ' + strWhereClasuse + ' ORDER BY Order__c';
        }
        System.debug(LoggingLevel.Info,'Query ' + strqueryApp);
        List<FI_questionnaire__mdt> QuestionnaireList = new List<FI_questionnaire__mdt>();
        QuestionnaireList = Database.Query(strqueryApp);
        String strQueryVehicle = strquery + 'FROM Fi_questionnaire__mdt ';
        if (String.isNotBlank(vehicleWhereCls)) {
            strQueryVehicle = strQueryVehicle + vehicleWhereCls;
        }
        List<FI_questionnaire__mdt> lstVehicle = new List<FI_questionnaire__mdt>();
        lstVehicle = Database.Query(strQueryVehicle);
        QuestionnaireList.addAll(lstVehicle);
        QuestionaireWrapperListData objQuesWrapData = new QuestionaireWrapperListData();
        for(FI_questionnaire__mdt FiQuestionnaire:QuestionnaireList){
            QuestionaireWrapper QuestionaireWrapperObj = new QuestionaireWrapper();
            if(QuestionaireMap.containskey(FiQuestionnaire.Field_API_Name__c)){
                QuestionaireWrapperObj.helpText =QuestionaireMap.get(FiQuestionnaire.Field_API_Name__c);
            }
            QuestionaireWrapperObj.isMobileNumberField = FiQuestionnaire.IsMobileNumberField__c;//new added
            QuestionaireWrapperObj.isNotFirstTimeRendered = FiQuestionnaire.IsNotToBeRenderedFirstTime__c;
            QuestionaireWrapperObj.apiName =FiQuestionnaire.Field_API_Name__c;
            QuestionaireWrapperObj.addressType =FiQuestionnaire.Type_of_Address__c;
            QuestionaireWrapperObj.borrower =FiQuestionnaire.Borrower__c;
            QuestionaireWrapperObj.guarantor =FiQuestionnaire.Guarantor__c;
            QuestionaireWrapperObj.coBorrower =FiQuestionnaire.Co_Borrower__c;
            QuestionaireWrapperObj.current =FiQuestionnaire.Current__c;
            QuestionaireWrapperObj.office =FiQuestionnaire.Office__c;
            QuestionaireWrapperObj.permanent =FiQuestionnaire.Permanent__c;
            QuestionaireWrapperObj.autoLoan =FiQuestionnaire.Auto_Loan__c;
            QuestionaireWrapperObj.twoWheeler =FiQuestionnaire.Two_Wheeler__c;
            QuestionaireWrapperObj.section =FiQuestionnaire.Section__c;  
            QuestionaireWrapperObj.vehicle =FiQuestionnaire.Vehicle__c;
            if (applicantType == 'Applicant') {
                QuestionaireWrapperObj.isMandatory = blnMandatory ? FiQuestionnaire.IsMandatoryForBorrower__c : false;
            }
            else if (applicantType == 'Co-Applicant') {
                QuestionaireWrapperObj.isMandatory = blnMandatory ? FiQuestionnaire.IsMandatoryForCoBorrower__c : false;
            }
            else if (applicantType == 'Guarantor') {
                QuestionaireWrapperObj.isMandatory = blnMandatory ? FiQuestionnaire.IsMandatoryForGuarantor__c : false;
            }
            if (!FiQuestionnaire.vehicle__c && !FiQuestionnaire.Is_Form_Detail__c)
                objQuesWrapData.BorrowerList.add(QuestionaireWrapperObj);
            if(FiQuestionnaire.vehicle__c && !FiQuestionnaire.Is_Form_Detail__c){
                QuestionaireWrapperObj.isMandatoryForVehicle = blnMandatory ? FiQuestionnaire.IsMandatoryForVehicle__c : false;
                    objQuesWrapData.VehicleList.add(QuestionaireWrapperObj);  
            }
            if (FiQuestionnaire.Is_Form_Detail__c)
                objQuesWrapData.FIRecordList.add(QuestionaireWrapperObj);
        }
        for (QuestionaireWrapper obj : objQuesWrapData.VehicleList) {
            obj.isMandatory = obj.IsMandatoryForVehicle;
        }
        return objQuesWrapData;
            
    } catch (Exception e) {
            system.debug(LoggingLevel.Error,'Exception>>>>'+e.getMessage()+'  line number>>>'+e.getLineNumber());
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class QuestionaireWrapperListData{
        @AuraEnabled
        public List<QuestionaireWrapper> BorrowerList = new List<QuestionaireWrapper>();
        @AuraEnabled
        public List<QuestionaireWrapper> FIRecordList = new List<QuestionaireWrapper>();
        @AuraEnabled
        public List<QuestionaireWrapper> VehicleList = new List<QuestionaireWrapper>();
    }

    public class QuestionaireWrapper{
        @AuraEnabled
        public Boolean isMobileNumberField{get;set;}// added new requirement
        @AuraEnabled
        public Boolean isNotFirstTimeRendered{get;set;}
        @AuraEnabled
        public String counter {get;set;}
        @AuraEnabled
        public String helpText {get;set;}
        @AuraEnabled
        public String apiName {get;set;}
        @AuraEnabled
        public String addressType {get;set;}
        @AuraEnabled
        public Boolean borrower = false;
        @AuraEnabled
        public Boolean coBorrower = false;
        @AuraEnabled
        public Boolean guarantor = false;
        @AuraEnabled
        public Boolean office = false;
        @AuraEnabled
        public Boolean permanent = false;
        @AuraEnabled
        public Boolean current = false;
        @AuraEnabled
        public Boolean twoWheeler =false;
        @AuraEnabled 
        public Boolean autoLoan = false;
        @AuraEnabled 
        public String section {get;set;}
        @AuraEnabled 
        public Boolean isMandatory = false;
        @AuraEnabled 
        public Boolean isDisabled = false;
        @AuraEnabled 
        public Boolean isMandatoryForVehicle = false;
        @AuraEnabled 
        public Boolean vehicle = false;
        @AuraEnabled 
        public Object data {get;set;}
    }
}