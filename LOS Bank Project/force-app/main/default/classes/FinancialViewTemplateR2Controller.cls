public with sharing class FinancialViewTemplateR2Controller {
    
    @AuraEnabled
    public static List<String> getVisibleFieldsForFinancials(String strScreen, String strStage, String typeOfWheeler){
        try{
            List<String> visibleFields = new List<String>();
            visibleFields = Utility.getVisibleFields(strScreen, strStage, null, typeOfWheeler, null);
            return visibleFields;
        }catch(Exception objException){
            system.debug('Error');
            Log.error(objException,Log.SeverityType.valueOf('High'),'');
        } 
        return null;
    }
    
    @AuraEnabled
    public static FinancialWrapper getFinancialWrapper(String applicantId, List<Applicant__c> applicants){
        FinancialWrapper newFinancialWrapper = new FinancialWrapper();
        try {
            List<Id> applicantIds = new List<Id>();
            Map<Id, Applicant__c> mapOfApplicants = new Map<Id, Applicant__c>();
            Map<Id, List<Applicant_Financials_Details__c>> mapOfApplicantsVsFinancial = new Map<Id, List<Applicant_Financials_Details__c>>();
            for(Applicant__c app: applicants){
                applicantIds.add(app.Id);
                mapOfApplicants.put(app.Id,app);
            }
            List<Applicant_Financials_Details__c> financials = [SELECT Id, Type_Of_Employment__c,Method_Of_Assesment__c, Sector__c, Industry__c, Sub_Industry__c, Customer_Segment__c, Consider_Fleet_for_Eligibility__c, Sub_Grade__c, Agri_Owner_Name__c,Total_Work_Experience__c,
                                                                Occupation__c, Company_Name__c, Consider_Income_for_Eligibility__c, Consider_Land_for_Eligibility__c, Agri_Owned_By__c, Applicant__r.RecordType.DeveloperName,
                                                                Agri_Owned_By_Other__c, Land_Owner_Name__c, Size_of_Agri_Land__c, Unit_Land_Area__c, Agri_Land_in_Acres__c, Annual_Total_Income__c, Total_Income__c, FCF_EMI__c, HireVsBuy_Amt__c,HireVsBuy_Decision__c,Free_Cash_Flow__c,Emi__c,
                                                                Customer_Grade__c, Applicant__r.Loan__c, Applicant__r.Loan__r.Customer_Grade__c, Applicant__r.Relationship_with_applicant__c, RecordType.DeveloperName,Monthly_Income__c,Other_Income__c,
                                                                Company_Master__c, Company_Master__r.Company_Name__c, FCF_Ratio__c FROM Applicant_Financials_Details__c WHERE 
                                                                Applicant__c IN :applicantIds AND isActive__c=true WITH SECURITY_ENFORCED];
            
            if(!financials.isEmpty()){
                newFinancialWrapper.allParentFinancials = new List<Applicant_Financials_Details__c>();
                newFinancialWrapper.allChildFinancials = new List<Applicant_Financials_Details__c>();
                for(Applicant_Financials_Details__c appFinancial : financials){
                    switch on appFinancial.RecordType.DeveloperName{
                        when 'Financial_Parent' {
                            newFinancialWrapper.allParentFinancials.add(appFinancial); 
                            if(appFinancial.Applicant__c == applicantId){
                                newFinancialWrapper.parentFinancial = appFinancial;
                            }
                        } 
                        when else{
                            newFinancialWrapper.allChildFinancials.add(appFinancial);
                        }
                        
                    }
                }
            }
            newFinancialWrapper.relatedLoan = [SELECT Id, Customer_Grade__c, Original_Vehicle_Usage__c, Collateral_Type__c, EMI__c,Parent_Loan__c,Sub_Grade__c,
                                               Product__c, Loan_Amount__c, RecordType.DeveloperName, Stage__c, EMI_Frequency__c FROM Loan_Application__c WHERE 
                                               Id = :applicants[0].Loan__c];
            newFinancialWrapper.profileMasterList = financeController.getEmploymentType(mapOfApplicants.get(applicantId).Customer_Type__c);
            List<Picklist_Value_Mapping__mdt> picklistMappings = Picklist_Value_Mapping__mdt.getAll().values();
            newFinancialWrapper.picklistValues = new Map<String, String>();
            for(Picklist_Value_Mapping__mdt mdt: picklistMappings){
                newFinancialWrapper.picklistValues.put(mdt.DeveloperName, mdt.Picklist_Values__c);
            }
            // BODY FUNDING CHANGES
            if( newFinancialWrapper.relatedLoan.Collateral_Type__c == '10113'){
                //System.debug('newFinancialWrapper.relatedLoan.Parent_Loan__c__.' +newFinancialWrapper.relatedLoan.Parent_Loan__c);
                //System.debug('newFinancialWrapper.parentFinancial.Applicant__r.RecordType.DeveloperName-->' +newFinancialWrapper.parentFinancial.Applicant__r.RecordType.DeveloperName);
                // get the parent applicant financials of loan Parent_Loan__c and record type will   newFinancialWrapper.parentFinancial.Applicant__r.RecordType.DeveloperName 
                if(newFinancialWrapper.relatedLoan.Parent_Loan__c!=null){
                    Applicant_Financials_Details__c applicantParentFinancial = [SELECT id,FCF_EMI__c,HireVsBuy_Decision__c,Emi__c,Free_Cash_Flow__c,Monthly_charges_for_hire__c,Total_Expenses__c,RecordType.DeveloperName
                                                                                FROM Applicant_Financials_Details__c
                                                                                WHERE Applicant__r.Loan__c = :newFinancialWrapper.relatedLoan.Parent_Loan__c
                                                                                AND isActive__c=true 
                                                                                AND RecordType.DeveloperName = 'Financial_Parent'
                                                                                AND Applicant__r.RecordType.DeveloperName=:newFinancialWrapper.parentFinancial.Applicant__r.RecordType.DeveloperName  WITH SECURITY_ENFORCED];
                    
                    if(applicantParentFinancial!=null){
                         List<Applicant_Financials_Details__c>  childFinancial = [SELECT id,RecordType.DeveloperName,Total_Expenses__c,Monthly_charges_for_hire__c FROM Applicant_Financials_Details__c WHERE Applicant_Financials__c = :applicantParentFinancial.Id AND isActive__c = true LIMIT 1]; 
                        if (!childFinancial.isEmpty()) {
                            newFinancialWrapper.parentLoanFinancial = applicantParentFinancial;    
                            newFinancialWrapper.parentLoanChildFinancial = childFinancial[0];    
                        }
                    }
                }
                
            }
            return newFinancialWrapper;
        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),applicantId);
            System.debug('lineNumber' +objException.getLineNumber());
            //throw new AuraHandledException(objException.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static User getCurrentUserDetails(){
        try {
            List<User> currentUser = [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
            if(currentUser!=null && currentUser.size()>0){
                return currentUser[0];
            }
        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),'');
            throw new AuraHandledException(objException.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static Map<String,String> getRevisitScreens(Id loanId){
        try {
            Map<String,String> applicantIdVsScreens = new Map<String,String>();
            List<Applicant__c> applicants = [SELECT Id, Re_Visit_Screens__c, RecordType.Name, Customer_Name__c FROM Applicant__c
                 WHERE isInactive__c=false AND Loan__c=:loanId AND RecordType.DeveloperName IN 
                 ('Primary_Applicant','Co_Applicant','BO','Guarantor') AND Loan__r.RecordType.DeveloperName IN ('Tractor','Commercial_Vehicle','Construction_Equipment')
                 WITH SECURITY_ENFORCED];
            for(Applicant__c app: applicants){
                if(app.Re_Visit_Screens__c!=null){
                    String screenNames='';
                    Map<String, Boolean> screenVsRevisit = (Map<String, Boolean>) JSON.deserialize(app.Re_Visit_Screens__c, Map<String, Boolean>.class);
                    for(String screen: screenVsRevisit.keySet()){
                        if(screenVsRevisit.get(screen)==true){
                            screenNames = screenNames+screen+'; ';
                            applicantIdVsScreens.put(app.RecordType.Name+'_'+app.Customer_Name__c,screenNames);
                        }
                    }
                }
            }
            return applicantIdVsScreens;
            
        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanId);
            throw new AuraHandledException(objException.getMessage());
        }
    }

   /*
@description :  Method to check whether atleast one of the applicant is an working i.e except Housewife,Unemployed and student
@param :  String loanId
@return : Boolean
*/
    @AuraEnabled
        public static Boolean  getWorkingFinancialDetails(String loanId){
        try{
         List<Applicant_Financials_Details__c>  financeDetails = [SELECT Id,Applicant__c,Applicant__r.Loan__c,Type_Of_Employment__c
                                                                 FROM Applicant_Financials_Details__c 
                                                                 WHERE Applicant__r.Loan__c =:loanId 
                                                                 AND Type_Of_Employment__c!='Unemployed'
                                                                 AND  Type_Of_Employment__c!='Housewife' 
                                                                 AND (Applicant__r.RecordType.name = 'Applicant' OR Applicant__r.RecordType.name = 'Co-Applicant') WITH SECURITY_ENFORCED];
        if(financeDetails!=null && !financeDetails.isEmpty() && financeDetails.size()>0 ){
            return true;
        }else{
            return false;
        }
        }catch(exception e){
        Log.error(e,Log.SeverityType.valueOf('High'),'');
        System.debug('exception--->' + e.getMessage() + '---' + e.getLineNumber());
        return null;
        }
    }

    @AuraEnabled
    public static string updateLoanApp(Loan_Application__c loan){
        try {
            String returnValue;
loan.Base_Credit_Verification__c = CreditVerification.setCreditBaseVerification(loan.Id,'Land/Customer Details',false);
            if(Schema.sObjectType.Loan_Application__c.isUpdateable()){
                update loan;
                returnValue='Success';
            }else{
                returnValue='Failure';
            }
            return returnValue;
        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),loan.Id);
            throw new AuraHandledException(objException.getMessage());
        }
    }

    @AuraEnabled
    public static string updateRelatedApplicant(Applicant__c applicant){
        try {
            String returnValue;
            if(Schema.sObjectType.Applicant__c.isUpdateable()){
                update applicant;
                returnValue='Success';
            }else{
                returnValue='Failure';
            }
            return returnValue;
        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),applicant.Id);
            throw new AuraHandledException(objException.getMessage());
        }
    }

    @AuraEnabled
    public static string checkForFinancials(List<Applicant__c> applicantData, Id loanId){
        try {
            String returnValue;
            List<Applicant_Financials_Details__c> financials = [SELECT Id, Applicant__r.Customer_Name__c from Applicant_Financials_Details__c WHERE Applicant__r.Loan__c=:loanId AND 
            Applicant__r.RecordType.DeveloperName IN ('Primary_Applicant','BO','Co_Applicant','Guarantor') AND 
            Applicant__r.isInactive__c=false AND RecordType.DeveloperName='Financial_Parent' WITH SECURITY_ENFORCED];
            if(financials.size()==applicantData.size()){
                returnValue='Success';
            }else{
                returnValue='Incomplete';
            }
            return returnValue;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static List<Viability_Templates_Mapping__mdt> getViabilityTemplatesMapping(){
        try {
            List<Viability_Templates_Mapping__mdt> viabilityList = Viability_Templates_Mapping__mdt.getAll().values();

            return viabilityList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getTractorFinancialValidations(Loan_Application__c loan){
        try {
            Map<Id, List<String>> mapOfApplicantVsRequiredFinancials = new Map<Id, List<String>>();
            Map<Id, String> mapOfApplicantVsErrorMessage = new Map<Id, String>();
            Map<String, Mandatory_Financial_Template_Criteria__mdt> mapOfTypeOfEmpVsTemplates = new Map<String, Mandatory_Financial_Template_Criteria__mdt>();
            
            /*List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id, RecordType.DeveloperName, Applicant__r.Loan__r.Collateral_Type__c, Type_Of_Employment__c,
                Applicant__r.Loan__r.Original_Vehicle_Usage__c, Applicant__r.Customer_Name__c FROM Applicant_Financials_Details__c WHERE Applicant__r.Loan__c=:loan.Id
                AND Applicant__r.RecordType.DeveloperName IN ('Primary_Applicant','Co_Applicant','Guarantor','BO') AND 
                RecordType.DeveloperName='Financial_Parent' AND Applicant__r.isInactive__c=false AND 
                ((Applicant__r.Loan__r.Collateral_Type__c='10109' AND Type_Of_Employment__c='Farmer') OR (Applicant__r.Loan__r.Collateral_Type__c='10133'))
                AND Applicant__r.Loan__r.Original_Vehicle_Usage__c IN ('Agri','Commercial') AND Consider_Income_For_Eligibility__c='Yes'
                WITH SECURITY_ENFORCED];*/
                List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id, RecordType.DeveloperName, Applicant__r.Loan__r.Collateral_Type__c, Type_Of_Employment__c,
                Applicant__r.Loan__r.Original_Vehicle_Usage__c, Applicant__r.Customer_Name__c, Applicant__r.Loan__r.Customer_Grade__c, Applicant__r.RecordType.DeveloperName FROM Applicant_Financials_Details__c WHERE Applicant__r.Loan__c=:loan.Id
                AND Applicant__r.RecordType.DeveloperName IN ('Primary_Applicant','Co_Applicant','Guarantor','BO') AND 
                RecordType.DeveloperName='Financial_Parent' AND Applicant__r.isInactive__c=false AND 
                Applicant__r.Loan__r.Original_Vehicle_Usage__c IN ('Agri','Commercial') AND Consider_Income_For_Eligibility__c='Yes'
                WITH SECURITY_ENFORCED];
                List<Mandatory_Financial_Template_Criteria__mdt> mandatoryTemplates = [SELECT Id, Mandatory_Templates__c, Error_Message__c, Type_Of_Employment__c FROM Mandatory_Financial_Template_Criteria__mdt WHERE 
                Collateral_Type__c=:loan.Collateral_Type__c AND Vehicle_Use__c=:loan.Original_Vehicle_Usage__c WITH SECURITY_ENFORCED];
                for(Mandatory_Financial_Template_Criteria__mdt mandatoryTemp : mandatoryTemplates){
                    List<String> allEmpTypes = mandatoryTemp.Type_Of_Employment__c.split(',');
                    for(String type: allEmpTypes){
                        mapOfTypeOfEmpVsTemplates.put(type, mandatoryTemp);
                    }    
                }
                for(Applicant_Financials_Details__c appFinan: applicantFinancials){
                    List<String> requiredTemplates;
                    List<String> gradesToConsider = new List<String>{'FTU', 'FTB', 'Transporter'};////R2-2849
                    if((appFinan.Applicant__r.Loan__r.Collateral_Type__c=='10109' && appFinan.Applicant__r.Loan__r.Original_Vehicle_Usage__c=='Commercial') && gradesToConsider.contains(appFinan.Applicant__r.Loan__r.Customer_Grade__c) && appFinan.Applicant__r.RecordType.DeveloperName=='Primary_Applicant'){
                        mapOfApplicantVsRequiredFinancials.put(appFinan.Applicant__c, new List<String>{'Viability_Sheet_Small_Commercial_Vehicle'});
                        mapOfApplicantVsErrorMessage.put(appFinan.Applicant__c,'Viability Sheet is Mandatory for'+' '+appFinan.Applicant__r.Customer_Name__c);
                    }else if((appFinan.Applicant__r.Loan__r.Collateral_Type__c=='10109' && appFinan.Type_Of_Employment__c=='Farmer') || (appFinan.Applicant__r.Loan__r.Collateral_Type__c=='10133')){
                    if(mapOfTypeOfEmpVsTemplates.containsKey(appFinan.Type_Of_Employment__c)){
                        mapOfApplicantVsErrorMessage.put(appFinan.Applicant__c,mapOfTypeOfEmpVsTemplates.get(appFinan.Type_Of_Employment__c).Error_Message__c+' '+appFinan.Applicant__r.Customer_Name__c);
                        requiredTemplates = mapOfTypeOfEmpVsTemplates.get(appFinan.Type_Of_Employment__c).Mandatory_Templates__c.split(',');
                        mapOfApplicantVsRequiredFinancials.put(appFinan.Applicant__c, requiredTemplates);
                    }
                }
            }
            List<Applicant_Financials_Details__c> childFinancials = [SELECT Id, Applicant__c, RecordType.DeveloperName FROM Applicant_Financials_Details__c WHERE Applicant__c IN :mapOfApplicantVsRequiredFinancials.keySet()
            AND RecordType.DeveloperName!='Financial_Parent' AND isActive__c=true WITH SECURITY_ENFORCED];
            for(Applicant_Financials_Details__c appFinanc: childFinancials){
                if(mapOfApplicantVsRequiredFinancials.containsKey(appFinanc.Applicant__c) && mapOfApplicantVsRequiredFinancials.get(appFinanc.Applicant__c).contains(appFinanc.RecordType.DeveloperName) && mapOfApplicantVsErrorMessage.containsKey(appFinanc.Applicant__c)){
                    mapOfApplicantVsErrorMessage.remove(appFinanc.Applicant__c); 
                }
            }
            List<String> errorMessages = new List<String>();
            errorMessages = mapOfApplicantVsErrorMessage.values();
            List<Applicant__c> applicants = [SELECT Id, RecordType.Name, RecordType.DeveloperName, Total_Annual_Income__c, Loan__r.Loan_Amount__c, 
                Loan__r.Final_Exposure__c, PAN__c, PAN_verification_Status__c, Customer_Name__c, Customer_Type__c, Loan__r.RecordType.DeveloperName
                FROM Applicant__c WHERE Loan__c=:loan.Id AND RecordType.DeveloperName IN 
                ('Primary_Applicant','Co_Applicant','BO','Guarantor') AND isInactive__c=false WITH SECURITY_ENFORCED];
            Applicant__c primaryApplicant = new Applicant__c();
            for(Applicant__c app: applicants){
                if(app.RecordType.DeveloperName=='Primary_Applicant'){
                    primaryApplicant = app;
                }
            }
            Map<String,Mandatory_Document__mdt> applicantTypeVsPan = new Map<String,Mandatory_Document__mdt>();
            List<Mandatory_Document__mdt> isPanMandatoryMaster = [SELECT Id, Loan_Amount__c, Income__c,
                Exposure__c, Customer_Type__c, Is_Pan_Mandatory__c FROM Mandatory_Document__mdt WHERE Product__c=:loan.Product__c
                WITH SECURITY_ENFORCED];
            system.debug('applicantTypeVsPan '+isPanMandatoryMaster);
            for(Mandatory_Document__mdt mandatorDocs: isPanMandatoryMaster){
                applicantTypeVsPan.put(mandatorDocs.Customer_Type__c,mandatorDocs);
            }
            system.debug('applicantTypeVsPan '+applicantTypeVsPan);
            if(errorMessages==null){
                errorMessages = new List<String>();
            }
            Boolean isGuarntor =false;
            for(Applicant__c app: applicants){
                if(applicantTypeVsPan.containsKey(app.RecordType.Name)){
                    Mandatory_Document__mdt metaDataRec = applicantTypeVsPan.get(app.RecordType.Name);
                    /*if((app.Loan__r.Loan_Amount__c>metaDataRec.Loan_Amount__c || (metaDataRec.Exposure__c!=null && app.Loan__r.Final_Exposure__c>metaDataRec.Exposure__c) ||
                        app.Total_Annual_Income__c>metaDataRec.Income__c) && (app.PAN__c==null || app.PAN_verification_Status__c!='Verified')){
                            errorMessages.add('PAN is Mandatory for '+app.RecordType.Name+' '+app.Customer_Name__c);
                    }*/
                    if(app.Loan__r.Loan_Amount__c>metaDataRec.Loan_Amount__c && (app.PAN__c==null || app.PAN_verification_Status__c!='Verified') && metaDataRec.Is_PAN_mandatory__c==true){
                        if(primaryApplicant.Customer_Type__c == 'Non Individual' && app.RecordType.DeveloperName=='Co_Applicant' && app.Loan__r.RecordType.DeveloperName=='Tractor' && metaDataRec.Is_PAN_Mand_if_App_NI_CoApp_I__c==true){
                            errorMessages.add('PAN is Mandatory for '+app.RecordType.Name+' '+app.Customer_Name__c);
                        }else if(metaDataRec.Is_Pan_Mandatory__c==true){
                            errorMessages.add('PAN is Mandatory for '+app.RecordType.Name+' '+app.Customer_Name__c);
                        }  
                    }
                }
                 if(app.RecordType.Name == 'Guarantor'){
                    isGuarntor = true;
                }
                
            }
            if( loan.Collateral_Type__c == '10133' && loan.Customer_Grade__c == 'FTB' && !isGuarntor  ){
                errorMessages.add('Guarantor is mandatory to proceed further');
            }

            //return mapOfApplicantVsErrorMessage.values();
            return errorMessages;
        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),loan.Id);
            throw new AuraHandledException(objException.getMessage());
        }
    }

    //R2-2525
    @AuraEnabled
    public static List<String> getCommercialFinancialValidations(String loanId){
        Loan_Application__c loan = [SELECT Id, Customer_Grade__c, Original_Vehicle_Usage__c, Collateral_Type__c, EMI__c,Parent_Loan__c,
        Product__c, Loan_Amount__c, RecordType.DeveloperName, Stage__c, EMI_Frequency__c FROM Loan_Application__c WHERE 
        Id = :loanId];
        if(loan.Stage__c=='QDE'){
            return null;
        }
        Map<Id, List<String>> mapOfApplicantVsRequiredFinancials = new Map<Id, List<String>>();
        Map<Id, String> mapOfApplicantVsErrorMessage = new Map<Id, String>();
        Map<String, String> mapOfTypeOfEmpVsTemplates = new Map<String, String>();
        List<String> applicantErrors = new List<String>();
        List<Viability_Templates_Mapping__mdt> viabilityList = getViabilityTemplatesMapping();
        List<Income_Profiling__mdt> profileMasterList = Income_Profiling__mdt.getAll().values();
        Map<String, Income_Profiling__mdt> profileMasterMap = new Map<String, Income_Profiling__mdt>();
        Map<String, String> applicantName = new Map<String, String>();
        Map<String, String> applicantVsFinancials = new Map<String, String>();
        for(Income_Profiling__mdt income: profileMasterList){
            String key = income.Entity_Type__c+'~'+income.Type_of_Employment__c+'~'+income.Method_Assesment__c;
            profileMasterMap.put(key, income);
        }

        List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id, Customer_Grade__c, Sub_Grade__c, RecordType.DeveloperName, Applicant__r.Loan__r.Collateral_Type__c, Type_Of_Employment__c,
                                                                         Applicant__r.Loan__r.Original_Vehicle_Usage__c, Consider_Income_For_Eligibility__c, Method_Of_Assesment__c, Applicant__r.Customer_Name__c, Applicant__r.Customer_Type__c, Applicant__r.RecordType.Name FROM Applicant_Financials_Details__c WHERE Applicant__r.Loan__c=:loan.Id
                                                                         AND Applicant__r.RecordType.DeveloperName IN ('Primary_Applicant') AND //'Co_Applicant','Guarantor','BO'
                                                                         Applicant__r.isInactive__c=false AND isActive__c=true
                                                                         WITH SECURITY_ENFORCED];
        for(Applicant_Financials_Details__c financials: applicantFinancials){
            if(financials.RecordType.DeveloperName=='Financial_Parent' && financials.Consider_Income_For_Eligibility__c=='Yes'){
                applicantName.put(financials.Applicant__c, financials.Applicant__r.RecordType.Name+' '+financials.Applicant__r.Customer_Name__c);
                for(Viability_Templates_Mapping__mdt viability: viabilityList){
                    if(viability.Collateral_Type__c.contains(loan.Collateral_Type__c) && 
                        viability.Product__c.contains(loan.Product__c) && 
                        viability.Customer_Grade__c.contains(financials.Customer_Grade__c) &&
                        (viability.Sub_Grade__c==null || (viability.Sub_Grade__c!=null && viability.Sub_Grade__c.contains(financials.Sub_Grade__c)))){
                            if(mapOfTypeOfEmpVsTemplates.containsKey(financials.Applicant__c)){
                                mapOfTypeOfEmpVsTemplates.put(financials.Applicant__c, mapOfTypeOfEmpVsTemplates.get(financials.Applicant__c)+','+viability.Template_Name__c);
                            }else{
                                mapOfTypeOfEmpVsTemplates.put(financials.Applicant__c, viability.Template_Name__c);
                            }
                            if(viability.Template_Name__c.contains('EmploymentType')){
                                String templateValues =  mapOfTypeOfEmpVsTemplates.get(financials.Applicant__c);
                                mapOfTypeOfEmpVsTemplates.put(financials.Applicant__c, templateValues.replace('EmploymentType',''));
                              
                                String key = financials.Applicant__r.Customer_Type__c+'~'+financials.Type_Of_Employment__c+'~'+financials.Method_Of_Assesment__c;
                                if(mapOfTypeOfEmpVsTemplates.containsKey(financials.Applicant__c)){
                                    mapOfTypeOfEmpVsTemplates.put(financials.Applicant__c, mapOfTypeOfEmpVsTemplates.get(financials.Applicant__c)+','+profileMasterMap.get(key).Financial_Template__c);
                                }else{
                                    mapOfTypeOfEmpVsTemplates.put(financials.Applicant__c, profileMasterMap.get(key).Financial_Template__c);
                                }
                            }
                        }
                }
            }
                if(applicantVsFinancials.containsKey(financials.Applicant__c)){
                    applicantVsFinancials.put(financials.Applicant__c, applicantVsFinancials.get(financials.Applicant__c)+','+financials.RecordType.DeveloperName);
                }else{
                    applicantVsFinancials.put(financials.Applicant__c, financials.RecordType.DeveloperName);
                }
            

        }
        system.debug(' mapOfTypeOfEmpVsTemplates '+mapOfTypeOfEmpVsTemplates);
        system.debug(' applicantVsFinancials '+applicantVsFinancials);
        for(String app: mapOfTypeOfEmpVsTemplates.keySet()){
            for(String template: mapOfTypeOfEmpVsTemplates.get(app).split(',')){
                if(template!=null && template!=''){
                    if(applicantVsFinancials.containsKey(app) && !applicantVsFinancials.get(app).contains(template)){
                        String tempName = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get(template)?.getName();
                        applicantErrors.add('Template '+tempName+' is Mandatory for '+applicantName.get(app));
                    }
                }
            }
        }
        system.debug(applicantErrors);
        return applicantErrors;

    }

    @AuraEnabled
    public static List<String> isPanMandatory(String loanId){
        try {
            List<String> errorMessages = new List<String>();
            
            List<Applicant__c> applicants = [SELECT Id, RecordType.Name,  RecordType.DeveloperName, Total_Annual_Income__c, Loan__r.Loan_Amount__c, Total_Monthly_Income_Sum__c,
                Loan__r.Final_Exposure__c, PAN__c, PAN_verification_Status__c, Customer_Name__c, Customer_Type__c, Loan__r.RecordType.DeveloperName
                FROM Applicant__c WHERE Loan__c=:loanId AND RecordType.DeveloperName IN 
                ('Primary_Applicant','Co_Applicant','BO','Guarantor') AND isInactive__c=false WITH SECURITY_ENFORCED];
            Applicant__c primaryApplicant = new Applicant__c();
            for(Applicant__c app: applicants){
                if(app.RecordType.DeveloperName=='Primary_Applicant'){
                    primaryApplicant = app;
                }
            }
            Map<String,Mandatory_Document__mdt> applicantTypeVsPan = new Map<String,Mandatory_Document__mdt>();
            Loan_Application__c loan = [SELECT id,Product__c FROM Loan_Application__c WHERE Id=:loanId];
            List<Mandatory_Document__mdt> isPanMandatoryMaster = [SELECT Id, Loan_Amount__c, Income__c,
                Exposure__c, Customer_Type__c, Is_Pan_Mandatory__c FROM Mandatory_Document__mdt WHERE Product__c=:loan.Product__c
                WITH SECURITY_ENFORCED];
            system.debug('applicantTypeVsPan '+isPanMandatoryMaster);
            for(Mandatory_Document__mdt mandatorDocs: isPanMandatoryMaster){
                applicantTypeVsPan.put(mandatorDocs.Customer_Type__c,mandatorDocs);
            }
            system.debug('applicantTypeVsPan '+applicantTypeVsPan);
            if(errorMessages==null){
                errorMessages = new List<String>();
            }
            for(Applicant__c app: applicants){
                if(applicantTypeVsPan.containsKey(app.RecordType.Name)){
                    Mandatory_Document__mdt metaDataRec = applicantTypeVsPan.get(app.RecordType.Name);
                    /*if((app.Loan__r.Loan_Amount__c>metaDataRec.Loan_Amount__c || (metaDataRec.Exposure__c!=null && app.Loan__r.Final_Exposure__c>metaDataRec.Exposure__c) ||
                        app.Total_Monthly_Income_Sum__c>metaDataRec.Income__c) && (app.PAN__c==null || app.PAN_verification_Status__c!='Verified')){
                            errorMessages.add('PAN is Mandatory for '+app.RecordType.Name+' '+app.Customer_Name__c);
                    }*/
                    if(app.Loan__r.Loan_Amount__c>metaDataRec.Loan_Amount__c && (app.PAN__c==null || app.PAN_verification_Status__c!='Verified') && metaDataRec.Is_PAN_mandatory__c==true){
                        if(primaryApplicant.Customer_Type__c == 'Non Individual' && app.RecordType.DeveloperName=='Co_Applicant' && app.Loan__r.RecordType.DeveloperName=='Tractor' && metaDataRec.Is_PAN_Mand_if_App_NI_CoApp_I__c==true){
                            errorMessages.add('PAN is Mandatory for '+app.RecordType.Name+' '+app.Customer_Name__c);
                        }else if(metaDataRec.Is_Pan_Mandatory__c==true){
                            errorMessages.add('PAN is Mandatory for '+app.RecordType.Name+' '+app.Customer_Name__c);
                        }  
                    }
                    /*if(app.Loan__r.Loan_Amount__c>metaDataRec.Loan_Amount__c && (app.PAN__c==null || app.PAN_verification_Status__c!='Verified')){
                        errorMessages.add('PAN is Mandatory for '+app.RecordType.Name+' '+app.Customer_Name__c);
                    }*/
                }
                
            }
            return errorMessages;
        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanId);
            throw new AuraHandledException(objException.getMessage());
        }
    }
    @AuraEnabled
    public static string updateParentFinancials(String parentFinancialId){
        try {
            Applicant_Financials_Details__c financial = new Applicant_Financials_Details__c();
            financial.Id = parentFinancialId;
            List<Applicant_Financials_Details__c> parentFinancial = [SELECT Id, Applicant__r.Loan__r.EMI__c, Applicant__r.Loan__r.EMI_Frequency__c, Applicant__c FROM Applicant_Financials_Details__c WHERE Id=:parentFinancialId WITH SECURITY_ENFORCED];
            List<Applicant_Financials_Details__c> allFinancials = [SELECT Id, RecordType.DeveloperName, Total_Net_Income__c, FCF_EMI__c, HireVsBuy_Amt__c, HireVsBuy_Decision__c,
            Monthly_Net_Salary__c, Monthly_Income__c, Monthly_Total_Income__c, Net_Annual_Income__c, Monthly_Turnover__c, Net_Revenue__c,
            Applicant__r.Loan__r.EMI__c, Free_Cash_Flow__c FROM Applicant_Financials_Details__c WHERE Applicant_Financials__c=:parentFinancialId AND 
                isActive__c=true WITH SECURITY_ENFORCED];
            Decimal annualIncomeViability=0;
            Decimal totalIncome=0;
            for(Applicant_Financials_Details__c appFinancial : allFinancials){
                String recordTypeName = appFinancial.RecordType.DeveloperName;
                switch on recordTypeName{
                    when 'Viability_Sheet_Self_Propelled_Harvester' {
                        annualIncomeViability += appFinancial.Total_Net_Income__c;
                    }
                    when 'Viability_Sheet_Small_Commercial_Vehicle' {
                        annualIncomeViability +=(getAmountValue(appFinancial.Free_Cash_Flow__c) * 12);
                    }
                    when 'Salaried_Document'{
                        totalIncome += (getAmountValue(appFinancial.Monthly_Net_Salary__c)*12);
                    }
                    when 'Other_Income'{
                        totalIncome += (getAmountValue(appFinancial.Monthly_Income__c)*12);
                    }
                    when 'Documented_With_Audited_financial'{
                        totalIncome += (getAmountValue(appFinancial.Monthly_Total_Income__c)*12);
                    }
                    when 'Farmer_Dairy_Business'{
                        totalIncome += (getAmountValue(appFinancial.Total_Net_Income__c)*12);
                    }
                    when 'Farmer_Commercial'{
                        totalIncome += (getAmountValue(appFinancial.Net_Annual_Income__c));
                    }
                    when 'Assessed_No_Document'{
                        totalIncome += (getAmountValue(appFinancial.Monthly_Turnover__c)*12);
                    }
                    when 'Farmer_Agriculture_Own_Land'{
                        totalIncome += (getAmountValue(appFinancial.Net_Revenue__c));
                    }
                    when 'Farmer_Agriculture_Rented_Land'{
                        totalIncome += (getAmountValue(appFinancial.Net_Revenue__c));
                    }
                }
            }
            financial.Annual_Total_Income__c = annualIncomeViability;
            financial.Total_Income__c = totalIncome;
            if(parentFinancial[0].Applicant__r.Loan__r.EMI__c!=null && parentFinancial[0].Applicant__r.Loan__r.EMI__c!=0){
                String emiFrequency = parentFinancial[0].Applicant__r.Loan__r.EMI_Frequency__c;
                Decimal emi;
                Decimal factor;
                if(emiFrequency!=null){
                    if(emiFrequency.contains('HALF')){
                        factor=2;
                    }else if(emiFrequency.contains('QUARTERLY')){
                        factor=4;
                    }else if(emiFrequency.contains('MONTHLY')){
                        factor=12;
                    }
                    emi=parentFinancial[0].Applicant__r.Loan__r.EMI__c*factor;
                    financial.FCF_Ratio__c=annualIncomeViability/emi;
                }
                //financial.FCF_Ratio__c=annualIncomeViability/parentFinancial[0].Applicant__r.Loan__r.EMI__c;
            }
            CreditVerification.resetCreditVerificationOnLoan(parentFinancial[0].Applicant__r.Loan__c,'Financial (Income Norms)',false);
            if(Schema.sObjectType.Applicant_Financials_Details__c.isUpdateable()){
                update financial;
                Applicant__c applicant = new Applicant__c(Id=parentFinancial[0].Applicant__c, Total_Monthly_Income_Sum__c=financial.Total_Income__c/12);
                update applicant;
                return 'Success';
            }else{
                return 'Failure';
            }
            
        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),parentFinancialId);
            System.debug('lineNumner-->' +objException.getLineNumber());
            //throw new AuraHandledException(objException.getMessage());
            throw null;
        }
    }

    @AuraEnabled
    public static string updateCommercialParentFinancials(String parentFinancialId){
        try {
            Applicant_Financials_Details__c financial = new Applicant_Financials_Details__c();
            financial.Id = parentFinancialId;
            List<Applicant_Financials_Details__c> parentFinancial = [SELECT Id,Monthly_Income__c, Applicant__r.Loan__r.EMI__c,Method_Of_Assesment__c,  Applicant__r.Loan__c,Applicant__r.Loan__r.Collateral_Type__c FROM Applicant_Financials_Details__c WHERE Id=:parentFinancialId WITH SECURITY_ENFORCED];
            List<Applicant_Financials_Details__c> allFinancials = [SELECT Id, RecordType.DeveloperName, Total_Net_Income__c, FCF_EMI__c, HireVsBuy_Amt__c, HireVsBuy_Decision__c,Free_Cash_Flow__c,Emi__c,Method_Of_Assesment__c,
            Monthly_Net_Salary__c, Monthly_Income__c, Monthly_Total_Income__c, Net_Annual_Income__c, Monthly_Turnover__c, Net_Revenue__c,Salary_Received_in_Bank__c,Salary_Received_in_Cash__c,
            Applicant__r.Loan__r.EMI__c FROM Applicant_Financials_Details__c WHERE Applicant_Financials__c=:parentFinancialId AND 
                isActive__c=true WITH SECURITY_ENFORCED];
            Decimal annualIncomeViability=0;
            Decimal totalIncome=0;
            Decimal fcfEmi=0;
            Decimal freeCashFlow =0;
            Decimal emi =0;
            String hireVSBuyDecision ='';
            Decimal documentedIncome=0;
            Decimal assessedIncome=0;
            for(Applicant_Financials_Details__c appFinancial : allFinancials){
                String recordTypeName = appFinancial.RecordType.DeveloperName;
                switch on recordTypeName{
                  
                    when 'Salaried_Document'{
                        if(appFinancial.Salary_Received_in_Bank__c!=null){
                            documentedIncome = documentedIncome + getAmountValue(appFinancial.Salary_Received_in_Bank__c);
                         }
                         
                        if(appFinancial.Salary_Received_in_Cash__c!=null){
                             assessedIncome = assessedIncome + getAmountValue(appFinancial.Salary_Received_in_Cash__c);
                        }
                    }
                    when 'Other_Income'{
                       // if(parentFinancial[0].Method_Of_Assesment__c == 'Documented'){
                           if(appFinancial.Method_Of_Assesment__c!=null){
                               if(appFinancial.Method_Of_Assesment__c == 'Documented'){
                                 documentedIncome = documentedIncome +  getAmountValue(appFinancial.Monthly_Income__c);
                                }
                                if(appFinancial.Method_Of_Assesment__c == 'Assessed') {
                                 assessedIncome = assessedIncome +  getAmountValue(appFinancial.Monthly_Income__c);
                                 }
                           }  
                    }
                    when 'Documented_With_Audited_financial'{
                        documentedIncome = documentedIncome + getAmountValue(appFinancial.Monthly_Total_Income__c);
                    }
                    when 'Farmer_Dairy_Business'{
                        assessedIncome = assessedIncome + getAmountValue(appFinancial.Total_Net_Income__c);
                    }
                    when 'Farmer_Commercial'{
                        assessedIncome = assessedIncome + getAmountValue(appFinancial.Net_Annual_Income__c);
                    }
                    when 'Assessed_No_Document'{
                        assessedIncome = assessedIncome + getAmountValue(appFinancial.Monthly_Turnover__c);
                    }
                    when 'Farmer_Agriculture_Own_Land'{
                        assessedIncome = assessedIncome +  (getAmountValue(appFinancial.Net_Revenue__c/12));
                    }
                    when 'Farmer_Agriculture_Rented_Land'{
                        assessedIncome = assessedIncome +  (getAmountValue(appFinancial.Net_Revenue__c/12));
                    }
                    when 'Viability_Sheet_Commercial_Equipment' {
                        fcfEmi += appFinancial.FCF_EMI__c;
                        freeCashFlow = appFinancial.Free_Cash_Flow__c;
                        emi = appFinancial.Emi__c;
                    }
                    when 'Viability_Sheet_Small_Commercial_Vehicle' {
                        fcfEmi += appFinancial.FCF_EMI__c;
                        freeCashFlow = appFinancial.Free_Cash_Flow__c;
                        emi = appFinancial.Emi__c;
                    }
                    when 'Viability_Sheet_Commercial_Vehicle' {
                        fcfEmi += appFinancial.FCF_EMI__c;
                        freeCashFlow = appFinancial.Free_Cash_Flow__c;
                        emi = appFinancial.Emi__c;
                    }
                    when 'Hire_VS_Buy' {
                        hireVSBuyDecision = appFinancial.HireVsBuy_Decision__c;
                        freeCashFlow = appFinancial.Free_Cash_Flow__c;
                        emi = appFinancial.Emi__c;
                    }
                }
            }
            
            
                        /* if(parentFinancial != null && !parentFinancial.isEmpty() && parentFinancial[0].Monthly_Income__c!=null){
                            documentedIncome = documentedIncome + parentFinancial[0].Monthly_Income__c;
                        }*/
            if(parentFinancial[0].Applicant__r.Loan__r.Collateral_Type__c  != '10113'){
                financial.FCF_EMI__c = fcfEmi;
                financial.Free_Cash_Flow__c = freeCashFlow;
                financial.Emi__c = emi;
                financial.HireVsBuy_Decision__c = hireVSBuyDecision;
            }            
            financial.Monthly_Income__c = documentedIncome;
            financial.Other_Income__c = assessedIncome;
          

             if(!parentFinancial.isEmpty()){
                foirController.getAllApplicantsFoir(parentFinancial[0].Applicant__r.Loan__c);
            }
            CreditVerification.resetCreditVerificationOnLoan(parentFinancial[0].Applicant__r.Loan__c,'Financial (Income Norms)',false);
            if(Schema.sObjectType.Applicant_Financials_Details__c.isUpdateable()){
                update financial;
                return 'Success';
            }else{
                return 'Failure';
            }
            
        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),parentFinancialId);
            throw new AuraHandledException(objException.getMessage());
        }
    }

    @AuraEnabled
    public static String getActiveFinancialRecord(String applicantId,Decimal rowIndex){
        try {
            List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id, Applicant_Financials__r.Applicant__c,RecordType.DeveloperName,Row_Instance__c
                                                                   FROM Applicant_Financials_Details__c 
                                                                   WHERE Applicant_Financials__r.Applicant__c=:applicantId 
                                                                   AND RecordType.DeveloperName !='Financial_Parent'
                                                                   AND isActive__c=true 
                                                                   AND Row_Instance__c=:rowIndex WITH SECURITY_ENFORCED];
            if(applicantFinancials!=null  && applicantFinancials.size()>0 && !applicantFinancials.isEmpty()){
                return applicantFinancials[0].Id;
            }else{
                return null;
            }
        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),applicantId);
            throw new AuraHandledException(objException.getMessage());
        }
    }
    public static Decimal getAmountValue(Decimal value){
        if(value!=null){
            return value;
        }else{
            return 0;
        }
    }

    @AuraEnabled
    public static List<Applicant_Financials_Details__c> getExistingChildFinancialRecords(String applicantId){
        try {
            List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id, Monthly_Total_Income__c, Monthly_Income__c,Customer_Name__c,Vehicle_Model__c,Monthly_running_in_Km__c,Monthly_revenue__c,Toll_Tax_paid__c,Name_of_Construction_Equipment__c,Fuel_average_in_liter_per_hour__c,Naka_Tempo_stand_Route_detail__c,
            First_Month__c, Second_Month__c, Third_Month__c,Annual_Net_Profit__c,Year__c,Filing_Date__c,Annual_Total_Income__c,Route__c,Nature_of_Goods__c,Distance_in_Km__c,No_of_Trips_per_month__c,Other_Taxes_Misc_Expenses__c,FCF_EMI__c,Type_of_work__c,Monthly_charges_for_hire__c,Cost_of_Ownership__c,Daily_Expense__c,
            Annual_Turnover__c,Annual_Expense__c,Monthly_Expense__c,Salary_Received_in_Cash__c,Monthly_Net_Salary__c,Average_load_in_per_ton__c,Rate_uptrip__c,Rate_Downtrip__c,Total_Round_trip__c,Maintenance_expenses__c,Insurance_Expenses__c,No_of_hours_day__c,Insurance_taxes__c,Repair_Servicing_Miscellaneous_Charges__c,
            Company_Master__c,Company_Master__r.Company_Name__c,Company_Name__c, Total_Work_Experience__c,Fuel_average_in_KM_per_litre__c,Cost_per_liter_of_fuel__c,No_of_tyres__c,Cost_of_1_tyre__c,Life_of_new_tyres_in_Km__c,Free_Cash_Flow__c,No_of_working_days_per_month__c,Rate_per_trip__c,Expense_per_trip__c,Daily_Billing__c,
            RecordType.Name, RecordType.DeveloperName, Monthly_Net_Income__c,Monthly_Turnover__c,Monthly_Net_Profit__c,Fuel_Cost__c,Tyre_Cost__c,Drivers_Salary_Allowances__c,Cleaners_Salary_Allowances__c,RTO_Permit_fitness_charges__c,Emi__c,Monthly_running_in_hours__c,HireVsBuy_Amt__c,Open_Market_Attachment_with__c,
            Average_Monthly_Salary__c,
            Other_Income_Picklist__c, Other_If_Any__c, Method_Of_Assesment__c, Total_Net_Income__c,Applicant_Financials__c, 
            No_of_Cattle__c, Daily_Supply_of_Milk_Ltrs__c, Average_Sale_Price_Per_Liter__c, Daily_Collection__c, 
            Monthly_Receipts__c, Profit_Margin__c, Any_Other_Income__c, Any_Other_Expense__c, Type_of_Income__c,Income_Source__c,
            Unit__c, Annual_Income_Unit_Rs__c, Proof__c, Document_Type__c, Net_Annual_Income__c, Crop_Details__c, 
            MSP__c, Irrigartion_Source__c, Area_under_crop__c,
            Sowing_Month__c, Harvesting_Month__c,Estimated_Yield__c,Estimated_Sale_Value__c,Net_Revenue__c,Sector__c,
            Industry__c,Sub_Industry__c,Occupation__c,Area_under_Crop_Unit__c,Verified_Income__c, No_of_Acres_land_harvest_in_a_year__c,
            Hours_taken_form_01_acre_land__c,Rate_hour__c,Approx_No_of_hours_run_in_a_year__c,Total_Income__c,Per_Hr_Diesel_consumption_in_ltr__c,
            Diesel_cost_per_Ltr__c,Diesel_cost_per_Hr__c,Total_Diesel_Exp_per_Year__c,Driver_Helper_salary__c,Insurance_cost_per_yr__c,
            Yearly_Maintenance_Cost__c,Broker_Commission__c,Total_Expenses__c,
            Final_expenses__c,Yearly_EMI_of_Proposed_loan__c,Net_Surplus__c, Cost_of_Cultivation__c
            FROM Applicant_Financials_Details__c 
            WHERE  Applicant_Financials__r.Applicant__c=:applicantId AND RecordType.DeveloperName!='Financial_Parent' 
            AND isActive__c=true WITH SECURITY_ENFORCED];
            return applicantFinancials;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateRelatedApplicants(String loanId){
        try {
            List<Applicant__c> applicants = [SELECT Id, Re_Visit_Screens__c FROM Applicant__c 
                                                            WHERE  Loan__c=:loanId AND 
                                                            RecordType.DeveloperName NOT IN ('Nominee','Additional_Match','Primary_Applicant')
                                                            AND IsInactive__c=false WITH SECURITY_ENFORCED];

            if(!applicants.isEmpty()){
                Map<String,Boolean> screenVsRevisit = new Map<String,Boolean>();
                List<String> reVisitScreens = System.Label.Re_Visit_Screens.split(',');
                for(String screen: reVisitScreens){
                    screenVsRevisit.put(screen,true);
                }
                for(Applicant__c app : applicants){
                    String reVisitScreensJSON;
                    if(app.Re_Visit_Screens__c==null){
                        screenVsRevisit.put('Financial',true);
                        reVisitScreensJSON = JSON.serialize(screenVsRevisit);
                    }else{
                        Map<String,Boolean> screenVsRevisitTemp = (Map<String,Boolean>) JSON.deserialize(app.Re_Visit_Screens__c, Map<String,Boolean>.class);
                        screenVsRevisitTemp.put('Financial',true);
                        reVisitScreensJSON = JSON.serialize(screenVsRevisitTemp);
                    }
                    app.Re_Visit_Screens__c = reVisitScreensJSON;
                }
            }   
            if(Schema.sObjectType.Applicant__c.isUpdateable()){
                if(!applicants.isEmpty()){
                    ApplicantTriggerHandler.byPassApplicantTrigger=true;
                    update applicants;
                }
            }
           

        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanId);
        }
    }

    @AuraEnabled
    public static void deactiveExistingFinancials(String currentApplicantId){
        try {
            List<Applicant_Financials_Details__c> applicantFinancials = [SELECT id,Applicant_Financials__r.Applicant__c,isActive__c FROM Applicant_Financials_Details__c 
                                                                         WHERE  Applicant_Financials__r.Applicant__c=:currentApplicantId AND RecordType.DeveloperName!='Financial_Parent' 
                                                                         AND isActive__c=true WITH SECURITY_ENFORCED];

            List<Applicant_Financials_Details__c> applicantFinancialList = new List<Applicant_Financials_Details__c>();
            if(applicantFinancials!=null && !applicantFinancials.isEmpty() && applicantFinancials.size()>0){
                for(Applicant_Financials_Details__c applicantFinancialInstance : applicantFinancials){
                    Applicant_Financials_Details__c  appInstance = applicantFinancialInstance;
                    appInstance.isActive__c = false;
                    applicantFinancialList.add(appInstance);
                }
            }   
            if(Schema.sObjectType.Applicant_Financials_Details__c.isUpdateable()){
                if(applicantFinancialList!=null && !applicantFinancialList.isEmpty() && applicantFinancialList.size()>0  ){
                    update applicantFinancialList;
                }
            }
           

        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
        }
    }

    @TestVisible
    public class FinancialWrapper{
        @AuraEnabled public Applicant_Financials_Details__c parentFinancial {get;set;}
        @AuraEnabled public Loan_Application__c relatedLoan {get;set;}
        @AuraEnabled public List<Applicant_Financials_Details__c> allParentFinancials {get;set;}
        @AuraEnabled public List<Income_Profiling__mdt> profileMasterList {get;set;}
        @AuraEnabled public Map<String, String> picklistValues {get;set;}
        @AuraEnabled public List<Applicant_Financials_Details__c> allChildFinancials {get;set;}
        @AuraEnabled public Applicant_Financials_Details__c parentLoanFinancial {get;set;} // this one added to get the financial details of parent loan of current applicant type one applicable for body type funding collateral type
        @AuraEnabled public Applicant_Financials_Details__c parentLoanChildFinancial {get;set;} // to render the fields based on parent loan applicant child financials
    }
}