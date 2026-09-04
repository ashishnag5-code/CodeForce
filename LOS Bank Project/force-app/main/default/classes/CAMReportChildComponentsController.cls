global with sharing class CAMReportChildComponentsController {

    @TestVisible
    public class AddressWrapper{
        public String type{get;set;}
        public List<Address__c> value{get;set;}
    
        AddressWrapper(String typeValue, List<Address__c> addressList){
            type=typeValue;
            value=addressList;
        }
    }
    public static String bureauScor {get;set;}
    public static String ltv {get;set;}
    public static Loan_Application__c loan{get;set;}
    public static Collateral__c collateral{get;set;}
    public static Applicant__c applicant{get;set;}
    public static List<Applicant_Financials_Details__c> financial{get;set;}
    public static List<Applicant_Financials_Details__c> commercialfinancialDetails{get;set;}
    public static List<Applicant_Financials_Details__c> documentedWithOutAuditedFinancial{get;set;}
    public static List<Work_Order__c> workOrderDetails{get;set;}
    public static List<Applicant__c> applicants{get;set;}
    public static List<Id> applicantIdsForAdditionalMatch;
    public static Map<String,String> applicantIdsVsAdditionalMatchId{get;set;}
    public static Map<Id,String> additionalMatches {get;set;}
    public static List<Address__c> addressList{get;set;}
    public static BSR_PSL_Details__c pslDetails {get;set;}
    public static Boolean isSectionEnabledForCV_CE_SCV_Product{get;set;}

    public static List<Bank_Account_Records__c> exposureDetailsForAppBanks{get;set;}
    public static List<Bank_Account_Records__c> cbsRecordsFD{get;set;}
    public static List<Bank_Account_Records__c> cartRecords{get;set;}
    public static Map<Id, List<Bank_Account_Records__c>> exposureBankRecords{get;set;} 
    public static List<Fleet__c> fleetRecords{get;set;}
    public static FFRWrapper ffrDetail{get;set;}
    public static List<TVR__c> tvrRecords{get;set;}
    public static List<Document_Checklist__c> cpvDetails{get;set;}
    public static Map<Id,List<Document_Checklist__c>> cpvDetailsList;
    public static Map<Id,List<Document_Checklist__c>> identifiersList;
    public static Map<Id,Document_Checklist__c> cartBankDetail;
    public static Set<Id> keys;
    public static Map<Id, String> applicantnameMap{get;set;}
    public static Map<Id, Integer> applicantsizeMap{get;set;}
    public static List<Bank_Account_Records__c> applicantExposure{get;set;}
    public static List<Bank_Account_Records__c> exposureCBSAccounts{get;set;}
    public static List<Bank_Account_Records__c> cibilRecords{get;set;}
    public static List<Loan_Application_Approval__c> loanAppApprovalRecords{get;set;}
    public static List<Deviation__c> deviationRecords{get;set;}
    public static List<FiSummaryViewWrapper> fieldInvestigationRecords{get;set;}
    public static List<Sanction_Condition__c> sanctionConditions{get;set;}
    public static List<Query__c> queries{get;set;}
    public static ProductRTMap__mdt productRT{get;set;}
    public static List<Bank_Account_Records__c> cbsCibilLoans{get;set;}

    public static String fiReportsVerifiedForApp{get;set;}
    public static String endUseOfVehicle;
    public static String sentFrom{get;set;}
    public static String subPage{get;set;}
    public static String vehiclededup{get;set;}
    public static Boolean riskScoreVerified;
    public static User currentUser{get;set;}//4733
    public static Applicant_Financials_Details__c financialParent{get;set;} //R2-1170,1769
    public static Map<String,String> reviewTabs{get;set;}
    public static List<String> tabNames;
    
    public static String listSize;
    public static String productDetails{get;set;}
    public static String subProduct{get;set;}
    public static string vahaanPdf{get;set;}
    public static string valReportPdf{get;set;} //R2-1170,1769

    public static Map<Id, String> additionalMatchScore{get;set;}
    public static Map<String, String> applicantVSAadharPhoto;
    public static Map<String, String> applicantVSLivePhoto{get;set;}
    public static Map<String, String> applicantVSLivePhotomatch{get;set;}
    public static Map<String, String> nsdlMatchRec{get;set;}
    public static Map<String, String> cibilReports;
    public static Boolean notverifiedRiskScore{get;set;}
    public static Map<String,String> cartDocDetail;
    public static Map<String,FinancialDetailWrapper> financialRecordR2;
    public static List<Applicant_Financials_Details__c> applicantFinancialsR2{get;set;}
    public static List<Address__c> addressListOfCibilAddress{get;set;}

    public static String loanId;
    public static String cellData{get;set;}
    public static String labelData{get;set;}
    public static String pageBlockSectionCSS{get;set;}
    public static String lcDetails;
    public static String applicantName{get;set;}
    public static String dealerNameAndCode;
    public static Integer counter;
    public static String factor{get;set;}
    public static User RO{get;set;}
    public static String preApprovedOfferAmount;
    public static String tableStyle{get;set;}
    public static String tableStyleForBank{get;set;}

    
    public static String tableRowStyle{get;set;}
    public static String tableHeadStyle{get;set;}
    public static String tableDataStyle{get;set;}
    public static String tableHeadDataStyle{get;set;}
    public static String tableHeadDataStyleForBank{get;set;}
    public static String tableCellDataStyleForBank{get;set;}
    
    public static List<Id> applicantIds{get;set;}
    public static Map<String,String> applicantVsCPVReason;

    public static List<AddressWrapper> addressTypeValues;
    public static String state;
    public static String cbs;
    public static String lead;
    public static String prod;
    public static String creditRemarks{get;set;}
    public static Valuation__c valuation{get;set;}
    // public static String valName{get;set;}
    
    public static Decimal amountRoundOff{get;set;}
    public static boolean isAgriLoan{get;set;}
    public static boolean isBusinessLoan{get;set;}
    public static boolean isPersonalLoan{get;set;}//R2-2634
    // SFAU-4737
    public Decimal loanAmountIncLsAndInsurance{ get {
        return loan.Loan_Amount__c + ( collateral.LS__c == 'Yes' && collateral.LS_Value__c!=null ? Decimal.valueOf(collateral.LS_Value__c) : 0 ) + ( String.isNotBlank(collateral.Insurance_Funding__c) && collateral.Insurance_Value__c != null ? Decimal.valueOf(collateral.Insurance_Value__c) : 0 );
    } set; }

    public static String getCbs(){
        return 'CBS';
   }

    public static String getLead(){
        return 'Lead';
    }

    public static String getProd(){
        return 'Prod';
    }

    public static String getState(){
        state=loan.Dealer_Master__r.State__r.Account_Name__c;
        return state;
    }

    public static String getListSize(){
        if(applicants.size()==1){
            return 'single';
        }
        else{
            return 'multiple';
        }
    }

    public static void handleCreditVerify(){
        notverifiedRiskScore=false;
    }

    public static void trackAppvsFiRecords(){
        List<String> fiReportsVerifiedForAppTemp = new List<String>();
        if(fieldInvestigationRecords!=null && fieldInvestigationRecords.size()>0 ){
            for(FiSummaryViewWrapper wrap: fieldInvestigationRecords){
                fiReportsVerifiedForAppTemp.add(wrap.entity+'_'+wrap.partyName+'_TP');
                fiReportsVerifiedForAppTemp.add(wrap.entity+'_'+wrap.partyName+'_Current');
                fiReportsVerifiedForAppTemp.add(wrap.entity+'_'+wrap.partyName+'_Office');
                fiReportsVerifiedForAppTemp.add(wrap.entity+'_'+wrap.partyName+'_Permanent');
            }
        }
        system.debug('fiReportsVerifiedForApp '+fiReportsVerifiedForApp);
        fiReportsVerifiedForApp = JSON.serialize(fiReportsVerifiedForAppTemp);
    }

    public static String getPreApprovedOfferAmount(){
        List<Pre_Approved_Offer__c> offers = [Select Id, Is_Selected__c, FirstOfferAmount__c FROM Pre_Approved_Offer__c WHERE Is_Selected__c=true AND Loan_Application__c = :loan.Id];
        if(offers!=null && offers.size()>0 && offers[0].FirstOfferAmount__c!=null){
            return String.valueOf(offers[0].FirstOfferAmount__c.setScale(2)); // Change As per Hotline Fix - Case Summary expected String instead of Number - Neha
        }else{
            return '';
        }
    }

    /*public static String getLcDetails(){
        RO.Name = RO.Name!=null?RO.Name+', ':'';
        RO.Employee_Code__c = RO.Employee_Code__c!=null?RO.Employee_Code__c+', ':'';
        RO.MobilePhone = RO.MobilePhone!=null?RO.MobilePhone:'';
        //lcDetails=loan.LC_Code__c+loan.Customer_Name__c+loan.Mobile__c;
        lcDetails=;
        return lcDetails;
    }*/

    public static Map<String,String> getApplicantVSAadharPhoto(){

        applicantVSAadharPhoto = new Map<String,String>();
        applicantVSLivePhoto = new Map<String,String>();
        applicantVSLivePhotomatch = new Map<String,String>();
        for(Id appId: applicantIds){
            applicantVSAadharPhoto.put(appId,'');
            applicantVSLivePhoto.put(appId,'');
            applicantVSLivePhotomatch.put(appId,'');
        }
        Map<Id, Document_Checklist__c> docChecklists = new Map<Id, Document_Checklist__c> ([SELECT Id, Name, Applicant__c, 
            Document_Master__r.Document_Name__c,Match_Percentage__c FROM Document_Checklist__c 
            WHERE Applicant__c in :applicantIds
            AND Document_Master__r.Document_Name__c in ('Application Aadhaar Picture','Live Photo')]);
        if(docChecklists.size()>0){
            for(Document_Checklist__c dc: docChecklists.values()){
                //applicantVSLivePhotomatch.put(dc.Applicant__c,'');
                if(dc.Document_Master__r.Document_Name__c == 'Live Photo' && dc.Match_Percentage__c!=null){
                    applicantVSLivePhotomatch.put(dc.Applicant__c,String.valueOf(dc.Match_Percentage__c.setScale(2)));
                }
            }
        }
        if(docChecklists!=null && docChecklists.keySet()!=null && docChecklists.keySet().size()>0){
            List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in: docChecklists.keySet()];
            Map<Id,Id> cdlVsLinkedEntity = new Map<Id,Id>();
            for(ContentDocumentLink cdl: cdlList){
                cdlVsLinkedEntity.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            }
            if(cdlVsLinkedEntity!=null && cdlVsLinkedEntity.keySet()!=null && cdlVsLinkedEntity.keySet().size()>0){
                //SFAU-5233 : Added by Samridhi
                List<ContentVersion> contentList = [SELECT Id, VersionDataURL, ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId in :cdlVsLinkedEntity.keySet() and isActive__c = true];
                
                for(ContentVersion cv: contentList){
                    if(cdlVsLinkedEntity.keySet().contains(cv.ContentDocumentId) && docChecklists.keySet().contains(cdlVsLinkedEntity.get(cv.ContentDocumentId))){
                        if(docChecklists.get((cdlVsLinkedEntity.get(cv.ContentDocumentId))).Document_Master__r.Document_Name__c == 'Application Aadhaar Picture'){
                            applicantVSAadharPhoto.put(docChecklists.get((cdlVsLinkedEntity.get(cv.ContentDocumentId))).Applicant__c,'/sfc/servlet.shepherd/version/download/'+cv.Id);
                        }
                        if(docChecklists.get((cdlVsLinkedEntity.get(cv.ContentDocumentId))).Document_Master__r.Document_Name__c == 'Live Photo'){
                            applicantVSLivePhoto.put(docChecklists.get((cdlVsLinkedEntity.get(cv.ContentDocumentId))).Applicant__c,'/sfc/servlet.shepherd/version/download/'+cv.Id);
                        }
    
                    }
                }
            }
            
        }
        
        
        return applicantVSAadharPhoto;
    }

    public static Map<String,String> getCibilReports(){

        cibilReports = new Map<String,String>();
        List<Id> appAndAdditionalIds = new List<Id>();
        for(Id appId: applicantIds){
            cibilReports.put(appId,'');
            appAndAdditionalIds.add(appId);
        }
        for(Applicant__c app: applicants){
            if(app.Applicants__r!=null && app.Applicants__r.size()>0 && app.Applicants__r[0].RecordType.DeveloperName=='Additional_Match'){
                cibilReports.put(app.Applicants__r[0].Id,'');
                appAndAdditionalIds.add(app.Applicants__r[0].Id);
            }
        }
        system.debug('cibilReports '+cibilReports);
        Map<Id, Bureau_Results__c> bureauResults = new Map<Id, Bureau_Results__c>();
        //List<Bureau_Results__c> results = [SELECT Id, Applicant__c FROM Bureau_Results__c WHERE Applicant__c in :applicantIds Order by CreatedDate Desc];
        List<Applicant__c> applicantsBureauResults = [SELECT Id, (SELECT Id, Applicant__c FROM Bureau_Results__r WHERE Bureau_Score__c!=null Order By CreatedDate Desc Limit 1) FROM Applicant__c WHERE Id in :appAndAdditionalIds Order by CreatedDate Desc];
        for(Applicant__c resultRecord: applicantsBureauResults){
            if(resultRecord.Bureau_Results__r!=null && resultRecord.Bureau_Results__r.size()>0){
                bureauResults.put(resultRecord.Bureau_Results__r[0].Id,resultRecord.Bureau_Results__r[0]);
            }
        }
        //Map<Id, Bureau_Results__c> bureauResults = new Map<Id, Bureau_Results__c> ([SELECT Id, Applicant__c FROM Bureau_Results__c WHERE Applicant__c in :applicantIds Order by CreatedDate Desc]);
        if(bureauResults!=null && bureauResults.keySet()!=null && bureauResults.keySet().size()>0){
            system.debug('bureauResults '+bureauResults);
            List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in: bureauResults.keySet()];
            system.debug('cdlList '+cdlList);
            Map<Id,Id> cdlVsLinkedEntity = new Map<Id,Id>();
            for(ContentDocumentLink cdl: cdlList){
                cdlVsLinkedEntity.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            }
            system.debug('cdlVsLinkedEntity '+cdlVsLinkedEntity);
            if(cdlVsLinkedEntity!=null && cdlVsLinkedEntity.keySet()!=null && cdlVsLinkedEntity.keySet().size()>0){
                List<ContentVersion> contentList = [SELECT Id, VersionDataURL, ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId in :cdlVsLinkedEntity.keySet() AND Title='Cibil'];
                system.debug('contentList '+contentList);

                for(ContentVersion cv: contentList){
                    if(cdlVsLinkedEntity.keySet().contains(cv.ContentDocumentId) && bureauResults.keySet().contains(cdlVsLinkedEntity.get(cv.ContentDocumentId))){
                        system.debug('bureauResults.get(cdlVsLinkedEntity.get(cv.ContentDocumentId)).Applicant__c '+bureauResults.get(cdlVsLinkedEntity.get(cv.ContentDocumentId)).Applicant__c);
                        if(bureauResults.get(cdlVsLinkedEntity.get(cv.ContentDocumentId)).Applicant__c!=null && cibilReports.get(bureauResults.get(cdlVsLinkedEntity.get(cv.ContentDocumentId)).Applicant__c)==''){
                            cibilReports.put(bureauResults.get((cdlVsLinkedEntity.get(cv.ContentDocumentId))).Applicant__c,cv.VersionDataURL);
                        }
                    }
                }
            }
            
        }
        
        system.debug('cibilReports finally '+cibilReports);

        return cibilReports;
    }

    public static String getDealerNameAndCode(){
        if(loan.Dealer_Master__r!=null){
            loan.Dealer_Master__r.Account_Name__c = loan.Dealer_Master__r.Account_Name__c!=null?loan.Dealer_Master__r.Account_Name__c+', ':'';
            loan.Dealer_Master__r.Account_Code__c = loan.Dealer_Master__r.Account_Code__c!=null?loan.Dealer_Master__r.Account_Code__c:'';
            dealerNameAndCode=loan.Dealer_Master__r.Account_Name__c+loan.Dealer_Master__r.Account_Code__c;
        }else{
            dealerNameAndCode='';
        }
        
        return dealerNameAndCode;
    }
    

    public static String getEndUseOfVehicle(){
        if(loan.BSR_PSL_Details__r!=null && loan.BSR_PSL_Details__r.size()>0){
            endUseOfVehicle=loan.BSR_PSL_Details__r[0].End_use_of_Vehicle__c;
        }else{
            endUseOfVehicle='';
        }
        return endUseOfVehicle;
    }
    

    public static Map<id,String> getApplicantIdsForAdditionalMatch(){
        additionalMatchScore = new Map<Id,String>();
        additionalMatches=new Map<Id,String>();
        applicantIdsForAdditionalMatch = new List<Id>();
        applicantIdsVsAdditionalMatchId = new Map<String,String>();
        nsdlMatchRec = New Map<String, String>();
        cibilReports = getCibilReports();
        system.debug('cibilReports++++ '+cibilReports);
        set<id> apIds = New Set<id>();
        for(Applicant__c app: applicants){
            if(app.Id!=null){
                applicantIdsForAdditionalMatch.add(app.Id);
                if(app.Applicants__r==null || app.Applicants__r.size()==0){
                    additionalMatchScore.put(app.Id, '0');
                    additionalMatches.put(app.Id,'');
                    applicantIdsVsAdditionalMatchId.put(app.Id,'');
                }else if(app.Applicants__r[0].Bureau_Score__c!=null){
                    additionalMatchScore.put(app.Id,app.Applicants__r[0].Bureau_Score__c);
                    additionalMatches.put(app.Id,cibilReports.get(app.Applicants__r[0].Id));
                    applicantIdsVsAdditionalMatchId.put(app.Id,app.Applicants__r[0].Id);
                }else{
                    additionalMatchScore.put(app.Id, '0');
                    additionalMatches.put(app.Id,cibilReports.get(app.Applicants__r[0].Id));
                    applicantIdsVsAdditionalMatchId.put(app.Id,app.Applicants__r[0].Id);
                }
                nsdlMatchRec.put(app.Id,'');
            }
            system.debug('additionalMatches'+additionalMatches);
            apIds.add(app.Id);
            
        }
        Map<Id, Document_Checklist__c> docChecklists = new Map<Id, Document_Checklist__c> ([SELECT Id, Name, Applicant__c, 
            Document_Master__r.Document_Name__c,Match_Percentage__c FROM Document_Checklist__c 
            WHERE Applicant__c in :apIds
            AND Document_Master__r.Document_Name__c in ('Pan Card/Form 60')]);

        if(docChecklists.size()>0){
            for(Document_Checklist__c dc: docChecklists.values()){
                nsdlMatchRec.put(dc.Applicant__c,'');
                if(dc.Document_Master__r.Document_Name__c == 'Pan Card/Form 60' && dc.Match_Percentage__c <> null ){
                    nsdlMatchRec.put(dc.Applicant__c,String.valueOf((dc.Match_Percentage__c*100).setScale(2))+' %');
                }
            }
        }
        system.debug('nsdlMatchRec+++ '+nsdlMatchRec);
        return additionalMatchScore;
    }

    

    public CAMReportChildComponentsController() {
        counter=0;
        notverifiedRiskScore=true;
        pageBlockSectionCSS='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; width:97%; overflow:auto; margin: 13px; !important;background-color:white; text-align:left';
        //tableHeadDataStyleForBank='word-break:break-all;background-color: rgb(233, 233, 233); width:3%;text-align:center;color: rgb(104, 104, 104);font-size: 12.5px;font-weight: bold;padding: 0.5em;border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;';
        //if(productDetails!='Tractor'){
            if(sentFrom == 'PDF'){
                tableCellDataStyleForBank='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif;text-align:center;color: #181818;font-size: 7px;font-weight: normal;padding: 0.5em;border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;border: 1px solid rgb(240, 240, 240) !important;';
                tableHeadDataStyleForBank='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; white-space:normal;word-wrap:break-word;word-break:break-all;background-color: rgb(233, 233, 233); text-align:center;color: #181818;font-size: xx-small;font-weight: bold;padding: 0.5em;border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;';
                tableStyleForBank='font-family:"Segoe UI",  Roboto, Helvetica, sans-serif; overflow-wrap:word-break;width:100%; ;border-collapse: collapse;table-layout:fixed;';
            }else{
                tableCellDataStyleForBank='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; text-align:center; color: #181818; font-size: 13px;font-weight: normal;padding: 0.5em;border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;border: 1px solid rgb(240, 240, 240) !important;';
                tableHeadDataStyleForBank='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; width:40%;word-wrap:break-word;word-break:break-all;background-color: rgb(233, 233, 233); text-align:center;color: #181818;font-size: 12.5px;font-weight: bold;padding: 0.5em;border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;';
                tableStyleForBank='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; width:100%;  ;border-collapse: collapse;';
            }
    
            cellData='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; background-color: white; ; width:20% !important; color: #181818; font-size: 13px;padding: 0.5em;border-bottom: 1px solid rgb(240, 240, 240) !important;text-align: left;font-weight: normal;margin:5px';
            labelData='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; background-color: white; ;  width:13% !important; color: #181818; font-weight:bold; font-size: 12.5px;padding-left: 1.5em;padding-right: 0.5em; padding-top: 0.5em;margin:5px; padding-bottom: 0.5em;border-bottom: 1px solid rgb(240, 240, 240) !important;text-align: left;';//font-weight: bold; 
            tableStyle='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; width:100%;  ;border-collapse: collapse;';
            tableRowStyle='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; page-break-inside: avoid;  !important;';//background-color: #f2f3f3
            tableHeadStyle='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; white-space:normal; word-break:break-word;background-color: rgb(240, 240, 240); width:15% !important; word-wrap:break-word;text-align:right;color: #181818;font-size: 12.5px;font-weight: bold;padding: 0.5em;border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;';
            tableHeadDataStyle='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; white-space:normal; background-color: rgb(240, 240, 240); text-align:center;color: #181818;font-size: 12.5px;font-weight: bold;padding: 0.5em;border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;';
            tableDataStyle='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; text-align:center; border: 1px solid rgb(240, 240, 240) !important; background-color: white; color: #181818; font-size: 13px;font-weight: normal;padding: 0.5em;';//border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;
            
       // }
        trackAppvsFiRecords();
        System.debug('loanId-- '+loanId);
            system.debug('subProduct '+subProduct);
        String subProd = subProduct!=null?subProduct.toUpperCase():null;
        if(subProd==null){
            if(productRT!=null){
                subProd = productRT.Sub_Product__c!=null?productRT.Sub_Product__c.toUpperCase():'';
            }else{
                subProd='';
            }
        }
        System.debug('subProd '+subProd);
        if(subProd==GlobalConstants.AGRI_LOAN_SECURED.toUpperCase()){
            isAgriLoan=true;
        }else if(subProd==GlobalConstants.BUSINESS_LOAN_SECURED.toUpperCase()){
            isBusinessLoan=true;
        }else if(subProd==GlobalConstants.PERSONAL_LOAN_SECURED.toUpperCase()){
            isPersonalLoan=true;
        }
        // R2-2444 - DO NOT UNCOMMENT currentUser - instead, pass the parameter to component. This variable has a value in parent CAM controller too
        //currentUser = [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];//4733 
        //roundOffLoanAmount();
    }

    @RemoteAction
    global static void updateCreditVerification(String loanId, String verificationType){
        CreditVerification.setValidationOnDocument(verificationType,loanId);
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,verificationType+'Verified !'));
    }

    @RemoteAction
    global static void updateCibilReportCheck(String appRecId){
        CreditVerification.updateCibilCheckForApplicant(appRecId);
    }
    
    @RemoteAction
    global static void updateFIReportCheck(String fiRecId){
        CreditVerification.updateFIReportCheckForAddress(fiRecId);
    }


    public static List<AddressWrapper> getAddressTypeValues(){
        addressTypeValues=new List<AddressWrapper>();
        List<Address__c> currentAddresses = new List<Address__c>();
        List<Address__c> permanentAddresses = new List<Address__c>();
        List<Address__c> officeAddresses = new List<Address__c>();
        List<Address__c> touchPointAddresses = new List<Address__c>();
        List<Address__c> landAddresses = new List<Address__c>();//R2-1767
        system.debug('applicantIds'+applicantIds);
        
        if(applicantIds.size()>0){
            Map<Id, List<Address__c>> addressMap = new Map<Id, List<Address__c>>();
            Map<Id, Map<String, Address__c>> addressListMap = new Map<Id, Map<String,Address__c>>();
            for(Id appId: applicantIds){
                addressListMap.put(appId, new Map<String, Address__c>());
            }
            /*List<Address__c> addList = [SELECT Geo_Limit__c, Applicant__c, Stability__c, Distance_from_Branch__c, Address_Type__c,
            Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, City__c, State__c, Pincode__c FROM Address__c WHERE Applicant__c in :applicantIds AND Address_Type__c != null
            AND Source_Type__c != 'Cibil'  WITH SECURITY_ENFORCED Order by Applicant__r.RecordType.Name, CreatedDate Desc];*/
            for(Address__c address: addressList){
                addressListMap.get(address.Applicant__c).put(address.Address_Type__c, address);
            }
            integer i=0;
            for(Id appId: applicantIds){
                Address__c tempAddress;
                if(addressListMap.containsKey(appId)){
                    Map<String, Address__c> tempMap = addressListMap.get(appId);
                    if(tempMap.containsKey('Current')){
                        tempAddress=tempMap.get('Current');
                        currentAddresses.add(tempAddress);
                    }else{
                        currentAddresses.add(new Address__c(Address_Type__c='Current'));
                    }
                    if(tempMap.containsKey('Permanent')){
                        tempAddress=tempMap.get('Permanent');
                        permanentAddresses.add(tempAddress);
                    }else{
                        permanentAddresses.add(new Address__c(Address_Type__c='Permanent'));
                    }
                    if(loan.RecordType.DeveloperName=='Tractor' && tempMap.containsKey('Land')){
                        tempAddress=tempMap.get('Land');
                        landAddresses.add(tempAddress);
                    }else{
                        landAddresses.add(new Address__c(Address_Type__c='Land'));
                    }//R2-1767
                    if(tempMap.containsKey('Office')){
                        tempAddress=tempMap.get('Office');
                        officeAddresses.add(tempAddress);
                    }else{
                        officeAddresses.add(new Address__c(Address_Type__c='Office'));
                    }
                    if(tempMap.containsKey('Touch Point')){
                        tempAddress=tempMap.get('Touch Point');
                        touchPointAddresses.add(tempAddress);
                    }else{
                        touchPointAddresses.add(new Address__c(Address_Type__c='Touch Point'));
                    }

                }else{
                    currentAddresses.add(new Address__c(Address_Type__c='Current'));
                    permanentAddresses.add(new Address__c(Address_Type__c='Permanent'));
                    if(loan.RecordType.DeveloperName=='Tractor'){
                        landAddresses.add(new Address__c(Address_Type__c='Land'));
                    }//R2-1767
                    officeAddresses.add(new Address__c(Address_Type__c='Office'));
                    touchPointAddresses.add(new Address__c(Address_Type__c='Touch Point'));
                }
                
            }
            
        }else{
            currentAddresses.add(new Address__c(Address_Type__c='Current'));
            permanentAddresses.add(new Address__c(Address_Type__c='Permanent'));
            if(loan.RecordType.DeveloperName=='Tractor'){
                landAddresses.add(new Address__c(Address_Type__c='Land'));
            }
            officeAddresses.add(new Address__c(Address_Type__c='Office'));
            touchPointAddresses.add(new Address__c(Address_Type__c='Touch Point'));       
        }
        addressTypeValues.add(new AddressWrapper('Current Address', currentAddresses));
        addressTypeValues.add(new AddressWrapper('Permanent Address / Aadhaar', permanentAddresses));
        if(loan.RecordType.DeveloperName=='Tractor' && loan.Original_Vehicle_Usage__c=='Agri'){
            addressTypeValues.add(new AddressWrapper('Land Address', landAddresses));//R2-1767
        }
        if((subPage!='Credit' && loan.RecordType.DeveloperName!='Tractor') || (loan.Original_Vehicle_Usage__c=='Commercial' && loan.RecordType.DeveloperName=='Tractor')){
            addressTypeValues.add(new AddressWrapper('Office Address', officeAddresses));
        }
        addressTypeValues.add(new AddressWrapper('Touch Point Address', touchPointAddresses)); 
       
        system.debug('addressTypeValues'+addressTypeValues);
        return addressTypeValues;

    }

    public static Map<Id, List<Bank_Account_Records__c>> getKeys(){
        exposureBankRecords = new Map<Id, List<Bank_Account_Records__c>>();
        applicantnameMap = new Map<Id, String>();
        applicantsizeMap = new Map<Id, Integer>();//exposureDetailsForAppBanks
        if(exposureDetailsForAppBanks!=null && exposureDetailsForAppBanks.size()>0){
            for(Bank_Account_Records__c bank: exposureDetailsForAppBanks){
                if(!exposureBankRecords.containsKey(bank.applicant__c)){
                    bank.applicant__r.First_Name__c = bank.applicant__r.First_Name__c!=null?bank.applicant__r.First_Name__c+' ':'';
                    bank.applicant__r.Middle_Name__c = bank.applicant__r.Middle_Name__c!=null?bank.applicant__r.Middle_Name__c+' ':'';
                    bank.applicant__r.Last_Name__c = bank.applicant__r.Last_Name__c!=null?bank.applicant__r.Last_Name__c:'';
                    applicantnameMap.put(bank.applicant__c,bank.applicant__r.First_Name__c+bank.applicant__r.Middle_Name__c+bank.applicant__r.Last_Name__c);
                    applicantsizeMap.put(bank.applicant__c,0);
                    exposureBankRecords.put(bank.applicant__c, new List<Bank_Account_Records__c>());    
                }
                if(bank.RecordType.DeveloperName == 'CBS'){
                    exposureBankRecords.get(bank.applicant__c).add(bank);
                }
            }
            /*for(Bank_Account_Records__c bank: exposureDetailsForAppBanks){
                if(bank.RecordType.DeveloperName == 'CBS'){
                    exposureBankRecords.get(bank.applicant__c).add(bank);
                }
            }*/
            for(Id appId: exposureBankRecords.keySet()){
                List<Bank_Account_Records__c> bankRectemp = exposureBankRecords.get(appId);
                if(bankRectemp==null || bankRectemp.size()==0){
                    exposureBankRecords.remove(appId);
                    applicantnameMap.remove(appId);
                }
            }
            for(Id wrap: applicantnameMap.keySet()){
                applicantsizeMap.put(wrap,exposureBankRecords.get(wrap).size()+1);
            }
        }
        keys = exposureBankRecords.keySet();
        return exposureBankRecords;
    }

    public static Map<Id, List<Document_Checklist__c>> getCpvDetailsList(){
        Integer counter=0;
        List<String> docMasters = new List<String>{'AUWheels0093','AUWheels0091'};
        cpvDetailsList = new Map<Id, List<Document_Checklist__c>>();
        for(Id app: applicantIds){
            cpvDetailsList.put(app,new List<Document_Checklist__c>());
        }
        //if(subPage=='Credit'){
            for(Document_Checklist__c doc: cpvDetails){
                if(cpvDetailsList.keySet().contains(doc.Applicant__c) && docMasters.contains(doc.Document_Master__r.Name)){
                    if(doc.Address_Match_Score__c!=null || doc.Match_Percentage__c!=null){
                        cpvDetailsList.get(doc.Applicant__c).add(doc);
                        counter++;
                    }
                }
            }
        //}
        if(counter!=0){
            return cpvDetailsList;
        }else{
            return null;
        }
        
    }

    public static Boolean getRiskScoreVerified(){
        if(loan.Base_Credit_Verification__c!=null){
            Map<String, Boolean> documentWrapper = (Map<String,Boolean>) JSON.deserialize(loan.Base_Credit_Verification__c, Map<String,Boolean>.class);
            if(documentWrapper.get('Risk Score Sheet') == true){
                return true;
            }else{
                return false;
            }
        }
        return false;
        

    }

    @RemoteAction
    global static void updateCreditRemarks(String loanId, String remarks){
        Loan_Application__c loanApp = new Loan_Application__c();
        loanApp.Id = loanId;
        loanApp.Credit_Remarks__c= remarks;
        update loanApp;
       

    }

    

    public static Map<Id, List<Document_Checklist__c>> getIdentifiersList(){
        Integer counter=0;
        List<String> docMasters = new List<String>{'AUWheels0005','AUWheels0004','AUWheels0002','AUWheels0001'};
        identifiersList = new Map<Id, List<Document_Checklist__c>>();
        for(Id app: applicantIds){
            identifiersList.put(app,new List<Document_Checklist__c>());
        }
        //if(subPage=='Credit'){
            for(Document_Checklist__c doc: cpvDetails){
                if(identifiersList.keySet().contains(doc.Applicant__c) && docMasters.contains(doc.Document_Master__r.Name)){
                    if(doc.Match_Percentage__c!=null){
                        identifiersList.get(doc.Applicant__c).add(doc);
                        counter++;
                    }
                    
                }
            }
        //}
        if(counter!=0){
            return identifiersList;
        }else{
            return null;
        }
        
        
    }

    public static Map<Id,Document_Checklist__c> getCartBankDetail(){
        List<String> docMasters = new List<String>{'AUWheels0107'};
        cartBankDetail = new Map<Id, Document_Checklist__c>();
        for(Id app: applicantIds){
            cartBankDetail.put(app,new Document_Checklist__c());
        }
        //if(subPage=='Credit'){
            for(Document_Checklist__c doc: cpvDetails){
                if(cartBankDetail.keySet().contains(doc.Applicant__c) && docMasters.contains(doc.Document_Master__r.Name)){
                    cartBankDetail.put(doc.Applicant__c,doc);
                }
            }
        //}
        return cartBankDetail;
    }

    public static Map<String,String> getApplicantVsCPVReason(){
        applicantVsCPVReason = new Map<String,String>();
            for(Applicant__c app: applicants){
                String appName='';
                if(app.Middle_Name__c!=null && app.Middle_Name__c!=''){
                    appName = app.First_Name__c+' '+app.Middle_Name__c+' '+app.Last_Name__c;
                }else{
                    appName = app.First_Name__c+' '+app.Last_Name__c;
                }
                if(app.CPV_Waive_off_Reason__c==null){
                    app.CPV_Waive_off_Reason__c='';
                }
                applicantVsCPVReason.put(appName, app.CPV_Waive_off_Reason__c);
            }
            for(FiSummaryViewWrapper wrap: fieldInvestigationRecords){                
                if(!applicantVsCPVReason.keySet().contains(wrap.applicantName)){
                    applicantVsCPVReason.put(wrap.applicantName,'');
                }
            }
        
        
        return applicantVsCPVReason;
    }
    
    /*public static List<Bank_Account_Records__c> getApplicantExposure(){
        List<Applicant__c> newList = new List<Applicant__c>();
        applicantExposure=new List<Bank_Account_Records__c>();
        newList.add(applicant);
        String strQuery = LeadDedupeController.createApplicantQuery(newList,false);
        for(String s : strQuery.split(',')){
            system.debug(s);
            if(s.contains(' ')){
                for(String s1: s.split(' ')){
                    system.debug(s1);
                }
            }
        }
        List<Id> newIdList = new List<Id>();
        for(Applicant__c record : Database.query(strQuery)){
            newIdList.add(record.Id);
        }
        List<Bank_Account_Records__c> bankRecords = CAMReportVFPageController.returnAllBankRecords(newIdList);
        for(Bank_Account_Records__c bank: bankRecords){
            if(bank.RecordType.DeveloperName == 'CBS'){
                if(bank.Account_Type__c=='CASA' || bank.Account_Type__c=='Loan' || bank.Account_Type__c=='ODCC'){
                    applicantExposure.add(bank);
                }
            }
        }
        if(applicantExposure.size()>0)
            return applicantExposure;
        else
            return new List<Bank_Account_Records__c>();
    }*/

    public static Map<String,String> getCartDocDetail(){
        set<id> cartIds = new Set<Id>();
        cartDocDetail = New Map<String,String>();
        for(Bank_Account_Records__c cr: cartRecords){
            cartIds.add(cr.id);
            cartDocDetail.put(cr.id,'');
        }
        if(cartIds.size()>0){
            for(ContentDocumentLink cdl: [select id,ContentDocumentId,  LinkedEntityId, LinkedEntity.type from 
                ContentDocumentLink where LinkedEntityId in: cartIds ]){
                    cartDocDetail.put(cdl.LinkedEntityId,cdl.ContentDocumentId);
            }
        }
        return cartDocDetail;
    }


    // SFAU-4561 - Workaround for Valuation details not getting populated on CAM Report pdf
    public static Valuation__c getValuations(){
        List<Valuation__c> valuations =  [ SELECT Id, Valuer_Name_Code__c, Coordinate_for_valuation_POC__c, Final_remarks__c FROM Valuation__c WHERE Collateral__c =: collateral.Id ORDER BY CreatedDAte DESC LIMIT 1];
        if(!valuations.isEmpty()){
            return valuations[0];
        }else{
            return null;
        }
    }
    // SFAU-5000 | 6th-Oct-2023 | ABQ value mapping missing from deal summary
    public static map<Id, String> getAQBByApplicant(){
        map<Id, String> aqbByApplicant = new map<Id, String>();

        for( Applicant__c applicant: applicants){
            aqbByApplicant.put( applicant.Id, 'NA');
        }

        if( cartRecords == NULL ){
            return aqbByApplicant;
        }

        for(Bank_Account_Records__c rec: cartRecords){
            if( rec.Average_Monthly_Balance__c > 0 ){
                aqbByApplicant.put( rec.Applicant__c, String.valueOf(rec.Average_Monthly_Balance__c.setScale(2)) );
            }
        }
        return aqbByApplicant;
    }

    public static Map<String, FinancialDetailWrapper> getFinancialRecordR2(){
        Map<String, FinancialDetailWrapper> mapOfIdVsFinancialsWrapper = new Map<String, FinancialDetailWrapper>();
        for(Applicant__c app: applicants){
            FinancialDetailWrapper newWrapper = new FinancialDetailWrapper();
            newWrapper.recordTypeName = app.RecordType.Name;
            mapOfIdVsFinancialsWrapper.put(String.valueOf(app.Id), newWrapper);
        }
        for(Applicant_Financials_Details__c financial: applicantFinancialsR2){
            FinancialDetailWrapper newWrapper = new FinancialDetailWrapper();
            newWrapper = mapOfIdVsFinancialsWrapper.get(financial.Applicant__c);
            String recordTypeName = financial.RecordType.DeveloperName;
            system.debug('recordTypeName '+recordTypeName);
            if(recordTypeName == 'Financial_Parent'){
                newWrapper.employmentType = financial.Type_Of_Employment__c;
                newWrapper.emiPattern = financial.Applicant__r.Loan__r.EMI_Frequency__c;
                newWrapper.proposedEMI = financial.Applicant__r.Loan__r.EMI__c;
                newWrapper.existingEMILiability = financial.Monthly_Obligation__c;
                newWrapper.recordTypeName = financial.Applicant__r.RecordType.Name;
                newWrapper.companyName = financial.Company_Name__c;
                newWrapper.considerIncome = financial.Consider_Income_for_Eligibility__c;
                newWrapper.totalIncome = financial.Total_Income__c;//R2-2837
            }else if(recordTypeName == 'Farmer_Agriculture_Own_Land'){
                newWrapper.ownlandIncome = setDefaultValues(newWrapper.ownlandIncome);
                newWrapper.ownlandIncome += financial.Net_Revenue__c;
            }else if(recordTypeName == 'Farmer_Agriculture_Rented_Land'){
                newWrapper.rclIncome = setDefaultValues(newWrapper.rclIncome);
                newWrapper.rclIncome += financial.Net_Revenue__c;
            }else if(recordTypeName == 'Farmer_Commercial'){
                newWrapper.commercialIncome =  setDefaultValues(newWrapper.commercialIncome);
                newWrapper.commercialIncome += financial.Net_Annual_Income__c;
            }else if(recordTypeName == 'Farmer_Dairy_Business'){
                newWrapper.dairyIncome = setDefaultValues(newWrapper.dairyIncome);
                newWrapper.dairyIncome += financial.Total_Net_Income__c;
            }else if(recordTypeName == 'Other_Income'){
                newWrapper.otherIncome = setDefaultValues(newWrapper.otherIncome);
                if(financial.Monthly_Income__c != null){
                    newWrapper.otherIncome += financial.Monthly_Income__c;
                }
            }else if(recordTypeName == 'Viability_Sheet_Self_Propelled_Harvester'){
                newWrapper.netSurplusIncome = setDefaultValues(newWrapper.netSurplusIncome);
                if(financial.Net_Surplus__c != null){
                    newWrapper.netSurplusIncome += financial.Net_Surplus__c;
                }
            }
            if(newWrapper==null){
                newWrapper=new FinancialDetailWrapper();
            }
            mapOfIdVsFinancialsWrapper.put(financial.Applicant__c,newWrapper);
        }

        system.debug('mapOfIdVsFinancialsWrapper '+mapOfIdVsFinancialsWrapper);
        for(String applId: mapOfIdVsFinancialsWrapper.keySet()){
            FinancialDetailWrapper newWrapper = mapOfIdVsFinancialsWrapper.get(applId);
            /*newWrapper.ownlandIncome =  setDefaultValues(newWrapper.ownlandIncome);
            newWrapper.rclIncome =  setDefaultValues(newWrapper.rclIncome);
            newWrapper.commercialIncome =  setDefaultValues(newWrapper.commercialIncome);
            newWrapper.dairyIncome = setDefaultValues(newWrapper.dairyIncome);
            newWrapper.otherIncome = setDefaultValues(newWrapper.otherIncome);
            newWrapper.netSurplusIncome = setDefaultValues(newWrapper.netSurplusIncome);*/
            if(newWrapper.emiPattern!=null){
                if(newWrapper.emiPattern.toUpperCase().contains('MONTHLY')){
                    newWrapper.ownlandIncome = getCalculatedValue(newWrapper.ownlandIncome,12,'D');
                    newWrapper.rclIncome = getCalculatedValue(newWrapper.rclIncome,12,'D');
                    newWrapper.commercialIncome = getCalculatedValue(newWrapper.commercialIncome,12,'D');
                    newWrapper.totalIncome = getCalculatedValue(newWrapper.totalIncome, 12, 'D');//R2-2837
                }else if(newWrapper.emiPattern.toUpperCase().contains('HALF')){
                    newWrapper.ownlandIncome = getCalculatedValue(newWrapper.ownlandIncome,2,'D');
                    newWrapper.rclIncome = getCalculatedValue(newWrapper.rclIncome,2,'D');
                    newWrapper.commercialIncome = getCalculatedValue(newWrapper.commercialIncome,2,'D');
                    newWrapper.dairyIncome = getCalculatedValue(newWrapper.dairyIncome,6,'M');
                    newWrapper.otherIncome = getCalculatedValue(newWrapper.otherIncome,6,'M');
                    newWrapper.netSurplusIncome = getCalculatedValue(newWrapper.netSurplusIncome,6,'M');
                    newWrapper.totalIncome = getCalculatedValue(newWrapper.totalIncome, 2, 'D');//R2-2837
                }else if(newWrapper.emiPattern.toUpperCase().contains('QUARTERLY')){
                    newWrapper.ownlandIncome = getCalculatedValue(newWrapper.ownlandIncome,4,'D');
                    newWrapper.rclIncome = getCalculatedValue(newWrapper.rclIncome,4,'D');
                    newWrapper.commercialIncome = getCalculatedValue(newWrapper.commercialIncome,4,'D');
                    newWrapper.dairyIncome = getCalculatedValue(newWrapper.dairyIncome,3,'M');
                    newWrapper.otherIncome = getCalculatedValue(newWrapper.otherIncome,3,'M');
                    newWrapper.netSurplusIncome = getCalculatedValue(newWrapper.netSurplusIncome,3,'M');
                    newWrapper.totalIncome = getCalculatedValue(newWrapper.totalIncome, 4, 'D');//R2-2837

                }
            }
            
            system.debug('mapOfIdVsFinancialsWrapper3 '+mapOfIdVsFinancialsWrapper);
            /*newWrapper.totalIncome = setDefaultValues(newWrapper.ownlandIncome) + setDefaultValues(newWrapper.rclIncome) + 
                setDefaultValues(newWrapper.commercialIncome) + setDefaultValues(newWrapper.dairyIncome) + 
                setDefaultValues(newWrapper.otherIncome) + setDefaultValues(newWrapper.netSurplusIncome);
            if(newWrapper.totalIncome==0){
                newWrapper.totalIncome = null;
            }*/
            if(newWrapper==null){
                newWrapper=new FinancialDetailWrapper();
            }
            mapOfIdVsFinancialsWrapper.put(applId,newWrapper);
        }
        if(!cbsCibilLoans.isEmpty()){
            for(Bank_Account_Records__c bank: cbsCibilLoans){
                if(mapOfIdVsFinancialsWrapper.containsKey(bank.Applicant__c)){
                    FinancialDetailWrapper newWrapper = mapOfIdVsFinancialsWrapper.get(bank.Applicant__c);
                    newWrapper.existingEMILiability = setDefaultValues(newWrapper.existingEMILiability)+setDefaultValues(bank.EMI_Amount__c);
                    mapOfIdVsFinancialsWrapper.put(bank.Applicant__c,newWrapper);
                }
            }
        }
        
        return mapOfIdVsFinancialsWrapper;
    }

    public static Map<String,String> getTabNames(){
        Map<String,String> tabs = new Map<String,String>();
        system.debug('Applicants '+applicants);
        if(loan.RecordType.DeveloperName == 'Tractor' && loan.Base_Credit_Verification__c!=null){
            Map<String, Boolean> creditVerification = (Map<String, Boolean>) JSON.deserialize(loan.Base_Credit_Verification__c, Map<String, Boolean>.class);
            tabNames = System.Label.TractorCreditReviewTabs.split(',');
            tabNames.add('Lead Dedupe');
            tabNames.add('Customer Dedupe');
            tabNames.add('CIBIL');
            tabNames.add('FI');
            for(String tab: tabNames){
                String status;
                if(creditVerification.containsKey(tab)){
                    if(creditVerification.get(tab) == true){
                        status = 'Verified';
                    }else{
                        status = 'Not Verified';
                    }
                    if(tab == 'TAR'){
                        if(loan.Collaterals__r!=null && loan.Collaterals__r.size()>0 && loan.Collaterals__r[0].Vehicle_Delivery__c=='No'){
                            status = 'NA';
                        }
                    }//R2-2834
                }else{
                    status = '';
                }
                tabs.put(tab, status);
            }
            for(Applicant__c app: applicants){
                String appName = app.RecordType.Name+'_'+app.First_Name__c+' '+app.Last_Name__c;
                System.debug('appName '+appName);
                if(app.Lead_Dedupe_Verified_By_Credit__c==true){
                    String message = tabs.get('Lead Dedupe')+' '+appName+' - '+'Verified; <br>';
                    tabs.put('Lead Dedupe',message);
                }else {
                    String message = tabs.get('Lead Dedupe')+' '+appName+' - '+'Not Verified; <br>';
                    tabs.put('Lead Dedupe',message);
                }
                if(app.Customer_Dedupe_Verified_By_Credit__c==true){
                    String message = tabs.get('Customer Dedupe')+' '+appName+' - '+'Verified; <br>';
                    tabs.put('Customer Dedupe',message);
                }else {
                    String message = tabs.get('Customer Dedupe')+' '+appName+' - '+'Not Verified; <br>';
                    tabs.put('Customer Dedupe',message);
                }
                if(app.Cibil_Report_Verified_by_Credit__c==true){
                    String message = tabs.get('CIBIL')+' '+appName+' - '+'Verified; <br>';
                    tabs.put('CIBIL',message);
                }else{
                    String message = tabs.get('CIBIL')+' '+appName+' - '+'Not Verified; <br>';
                    tabs.put('CIBIL',message);
                }
            }
            List<Field_Investigation__c> lstFieldInvest = new List<Field_Investigation__c>();
            lstFieldInvest = [Select Id, Address_lookup__c, Applicant__c, Address_lookup__r.FI_Report_Verified__c, Address_lookup__r.Address_Type__c, 
                Applicant__r.RecordType.Name, Applicant__r.First_Name__c, Applicant__r.Last_Name__c 
                FROM Field_Investigation__c where Re_Trigger__c = false and Applicant__r.Loan__c =: loan.Id and Applicant__r.isInactive__c = false AND FI_Status__c!='Waived Off' WITH SECURITY_ENFORCED];

            for (Field_Investigation__c objFieldInves : lstFieldInvest) {
                if (!objFieldInves.Address_lookup__r.FI_Report_Verified__c) {
                    String message = tabs.get('FI')+' '+'FI Report for '+objFieldInves.Address_lookup__r.Address_Type__c+' Address ('+objFieldInves.Applicant__r.RecordType.Name+'_'+objFieldInves.Applicant__r.First_Name__c+' '+objFieldInves.Applicant__r.Last_Name__c+') Not Verified; ';
                    tabs.put('FI',message);
                }else{
                    String message = tabs.get('FI')+' '+'FI Report for '+objFieldInves.Address_lookup__r.Address_Type__c+' Address ('+objFieldInves.Applicant__r.RecordType.Name+'_'+objFieldInves.Applicant__r.First_Name__c+' '+objFieldInves.Applicant__r.Last_Name__c+') Verified; ';
                    tabs.put('FI',message);
                }
            }
        }
        reviewTabs=tabs;
        system.debug('reviewTabs '+reviewTabs);
        return reviewTabs;
       
    }

    public class FinancialDetailWrapper{
        public String employmentType{get;set;}
        public String recordTypeName{get;set;}
        public String emiPattern{get;set;}
        public Decimal ownlandIncome{get;set;}
        public Decimal rclIncome{get;set;}
        public Decimal commercialIncome{get;set;}
        public Decimal dairyIncome{get;set;}
        public Decimal otherIncome{get;set;}
        public Decimal netSurplusIncome{get;set;}
        public Decimal totalIncome{get;set;}
        public Decimal proposedEMI{get;set;}
        public Decimal existingEMILiability{get;set;}
        public String companyName{get;set;}
        public String considerIncome{get;set;}
        /*FinancialDetailWrapper(){
            ownlandIncome=0;
            rclIncome=0;
            commercialIncome=0;
            dairyIncome=0;
            otherIncome=0;
            netSurplusIncome=0;
            totalIncome=0;
        }*/
    }

    public static Decimal setDefaultValues(Decimal value){
        return value!=null?value:0;
    }

    public static Decimal getCalculatedValue(Decimal value, Decimal factor, String operation){
        if(operation=='D'){
            return value!=null?value/factor:null;
        }else if(operation=='M'){
            return value!=null?value*factor:null;
        }else{
            return null;
        }
        
    }
}