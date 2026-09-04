/*****
 * Class Name: AUSFVehicleController
 * Description: 
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-21-2023          -   Mohit Maheshwari    -   SFAU-5240
 * Oct-09-2023          -   Mohit M.            -   SFAU-5163
 * Dec-07-2023          -   Mohit M.            -   SFAU-5706 - IBB Value not getting in any application
 * Dec-08-2023          -   Mohit M.            -   SFAU-5665 - POS Update - Collateral Linkage
 * Dec-13-2023          -   Mohit M.            -   SFAU-5608 - Collateral Dedupe for Partner Leads
 * Dec-22-2023          -   Mohit M.            -   SFAU-5715 - Add IBB_API_Value__c
 */
public with sharing class AUSFVehicleController {
    
    public static final String[] VEHICLE_RECORD_TYPES =  new String[]{ 'New', 'Used_Cash_on_Wheels' };
    public static final String BIKE_DEKHO_MAPPING_MASTER_RT = 'Bike_Dekho';
    public static final String CAR_DEKHO_MAPPING_MASTER_RT = 'Car_Dekho';
    public static final String VEHICLE_SCREEN_PLACEHOLDER = 'Vehicle - {0}';
    public static final String MMV_MASTER_2W_FILTER_FIELD = 'Active_in_2W_Vehicle__c';
    public static final String MMV_MASTER_4W_FILTER_FIELD = 'Active_in_4W_Vehicle__c';
    public static final String MMV_MASTER_COMMERCIAL_FILTER_FIELD = 'Active_in_Commercial__c';
    public static final String MMV_MASTER_TRACTOR_FILTER_FIELD = 'Active_in_Tractor__c';
    public static final String APPORTIONED_LOAN_AMOUNT_FIELD_API = 'Apportioned_Loan_Amount__c';
    public static final String LTV_EX_SHOWROOM_FIELD_API = 'LTV_offered_Ex_showroom__c';
    public static final String LTV_Offered_FIELD_API = 'LTV_offered__c';
    public static final String LTV_ON_ROAD_FIELD_API = 'LTV_offered_On_road__c';
    public static final String FUEL_TYPE_FIELD_API = 'Fuel_Type__c';
    public static final String VALUATION_AMOUNT_FIELD_API = 'Valuation_Amount__c';
    public static final String IDV_FIELD_API = 'IDV__c';
    public static final String VEHICLE_VARIANCE_DEVIATION_TYPE = 'CAR_BIKE_DEKHO_VARIANCE';
    public static final String[] X3W_COLLATERAL_TYPES = new String[]{ '10106', '10107' };
    public static final map<String, String> VEHICLE_TYPE_TO_MMV_FILTER_FIELD = new map<String, String>{
        GlobalConstants.TWOWHEELER => MMV_MASTER_2W_FILTER_FIELD,
        GlobalConstants.FOURWHEELER => MMV_MASTER_4W_FILTER_FIELD,
        GlobalConstants.COMMERCIALVEHICLE => MMV_MASTER_COMMERCIAL_FILTER_FIELD,
        GlobalConstants.TRACTOR => MMV_MASTER_TRACTOR_FILTER_FIELD,
        GlobalConstants.CONSTRUCTIONEQUIP => MMV_MASTER_COMMERCIAL_FILTER_FIELD
    };
    public static String strCollateralName;
    public static String strScreenName;
    public static String strImplementName;
    public static String strLoanProduct {get;set;} //R2-2462
    public static String strLoanIdForCategory;

    @AuraEnabled
    public static void deleteCollateral(String collId) {
        try{
            Collateral__c  coll =[SELECT Id,Is_Deleted__c FROM Collateral__c WHERE Id=:collId LIMIT 1];
            coll.Is_Deleted__c = true;
            update coll;

            update new Loan_Application__c( Id = coll.Loan__c, Parent_Loan__c = null );
        }catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        
    }
    @AuraEnabled
    public static IBBResponse getIBBValue(Map<String,String> param,Collateral__c coll) {
        IBBResponseWrapper resp = new IBBResponseWrapper();
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = NULL;
        IBBResponse returnResp = new IBBResponse(); 
        try {
            String respBody;  
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('IBB');
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = coll.loan__c, Integration_Master__c =objIntMapper.Id);
            String requestBody = AUSFIBBCalloutController.getRequestBody(param,coll);
            system.debug('%%'+requestBody);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
                calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);  
            respBody = calloutResponseWrapper.response;
            system.debug('statuscode '+calloutResponseWrapper.statusCode);
            /* Change IBB Response - SFAU-5581
            if(calloutResponseWrapper.statusCode==200){
                resp = IBBResponseWrapper.parse(respBody);
                system.debug('resp '+resp);
                List<Integer> retailPrices = resp.ForRetailPrice;
                    // SFAU-5706 - IBB Value not getting in any application
                    if(retailPrices != NULL && retailPrices.size()>0 &&retailPrices.size()>=2){
                    system.debug('retailPrices[0] '+retailPrices[0]);
                    system.debug('retailPrices[1] '+retailPrices[1]);
                    returnResp.ibbValue =String.valueOf(retailPrices[1]);
                    }else if(retailPrices!= NULL && retailPrices.size()>0 &&retailPrices.size()==1){
                    returnResp.ibbValue =String.valueOf(retailPrices[0]);
                }else{
                        returnResp.errorMsg = Utility.getApiCustomError(
                            calloutResponseWrapper.checklistNumber,
                            calloutResponseWrapper.response,
                            'Retail Prices are not found',
                            calloutResponseWrapper.statusCode,
                            'AUSFVehicleController.getIBBValue'
                        );
                }
            }
            */
            /* Start - Change IBB Response */
            if(calloutResponseWrapper.statusCode==200){
                resp = IBBResponseWrapper.parse(respBody);
                system.debug('resp '+resp);
                if (resp != NULL && resp.prices != NULL && resp.prices.marketprice != NULL) {
                    returnResp.ibbValue = String.valueOf(resp.prices.marketprice);
                }
                else{
                        returnResp.errorMsg = Utility.getApiCustomError(
                            calloutResponseWrapper.checklistNumber,
                            calloutResponseWrapper.response,
                            'Retail Prices are not found',
                            calloutResponseWrapper.statusCode,
                            'AUSFVehicleController.getIBBValue'
                        );
                }
            }
            else{
                System.debug(respBody?.containsIgnoreCase('Not found') ? '{ "Errors": { "Error": { "Message": "Not found.", "Code": "500" } }}' : respBody);
                IBBErrorResponseWrapper err = (IBBErrorResponseWrapper)System.JSON.deserialize(
                    respBody?.containsIgnoreCase('Not found') ? '{ "Errors": { "Error": { "Message": "Not found.", "Code": "500" } }}' : respBody,
                    IBBErrorResponseWrapper.class
                );
                system.debug('err '+err);
                returnResp.errorMsg = Utility.getApiCustomError(
                    calloutResponseWrapper.checklistNumber,
                    err.Errors.Error.Code,
                    err.Errors.Error.Message,
                    calloutResponseWrapper.statusCode,
                    'AUSFVehicleController.getIBBValue'
                );
            }
        }
        catch (Exception ex) {
            // SFAU-5706 - IBB Value not getting in any application
            if (calloutResponseWrapper != NULL && calloutResponseWrapper.checklistRecord != NULL){
                upsert calloutResponseWrapper.checklistRecord;
            }
            Log.error('Error in AUSFVehicleController IBB :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),coll.Id);
            returnResp.errorMsg = 'Something went wrong.';
        }
        return returnResp;
    }
    
    public class IBBResponse{
        @AuraEnabled public String ibbValue;
        @AuraEnabled public String errorMsg;
    }
    
    @AuraEnabled
    public static AUSFVehicleHandler.CollateralResponseWrapper getCollateralList(Collateral__c obj,String loanAppId) {
        CollateralDedupeResponseWrapper objWrapper = new CollateralDedupeResponseWrapper();
        AUSFVehicleHandler.CollateralResponseWrapper resp = new AUSFVehicleHandler.CollateralResponseWrapper();
        String respBody;  
        
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Collateral Dedupe API');
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = loanAppId, Integration_Master__c =objIntMapper.Id);
        String branchCode = [ SELECT Branch_Master__r.Account_Code__c FROM Loan_Application__c WHERE Id =: loanAppId ].Branch_Master__r.Account_Code__c;
        if(branchCode != null){
            obj.Loan__r = new Loan_Application__c( Branch_Master__r = new Account( Account_Code__c = branchCode ) );
        }
        String requestBody = AUSFVehicleHandler.generateRequest(obj)[0];
        String objectId = '';
        // respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,strApplicantId);
        system.debug('%%'+requestBody);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);  
        respBody = calloutResponseWrapper.response;
        
        system.debug('%%respBody '+respBody);
        If(calloutResponseWrapper.statusCode == 200){
            AUSFCollateralSearchErrorWrapper obj2 = AUSFCollateralSearchErrorWrapper.parse(respBody);
            If(obj2.TransactionStatus.ResponseMessage=='Failure' && obj2.TransactionStatus.ResponseCode=='99'){
                // resp.message=obj2.TransactionStatus.ExtendedErrorDetails.messages[0].message;
                resp.responseCode =calloutResponseWrapper.statusCode;     
                resp.responseMessage =obj2.TransactionStatus.ResponseMessage;
                resp.message= Utility.getApiCustomError(
                    calloutResponseWrapper.checklistNumber,
                    obj2.TransactionStatus.ResponseMessage,
                    obj2.TransactionStatus.ExtendedErrorDetails?.messages[0].message,
                    calloutResponseWrapper.statusCode,
                    'AUSFVehicleController.getCollateralList'
                );
                                resp.collaterals = new List<Collateral__c>();
            }else{
                objWrapper = (CollateralDedupeResponseWrapper) System.JSON.deserialize(respBody, CollateralDedupeResponseWrapper.class);
                resp.collaterals = AUSFVehicleHandler.mapSearchIntWraptoUIWrap(objWrapper);
                resp.responseMessage=obj2.TransactionStatus.ResponseMessage;
                resp.responseCode =calloutResponseWrapper.statusCode;
                resp.message =obj2.TransactionStatus.ExtendedErrorDetails.messages[0].message;
            }
            system.debug('obj2'+obj2.TransactionStatus.ResponseMessage);
            
        }else{
            resp.collaterals = new List<Collateral__c>();
            resp.responseMessage= Utility.getApiCustomError(
                calloutResponseWrapper.checklistNumber,
                calloutResponseWrapper.response,
                calloutResponseWrapper.response,
                calloutResponseWrapper.statusCode,
                'AUSFVehicleController.getCollaterList'
            );
            resp.responseCode =calloutResponseWrapper.statusCode;
        }
        
        
        return resp;
    }
    
    @AuraEnabled
    public static LoanAppWrapper getLoanApplicationDetails(Id loanAppId) {
        LoanAppWrapper lwrap = new LoanAppWrapper();
        Loan_Application__c loanApp= [SELECT Id,Product__c,Collateral_Type__c,Vehicle_use__c,Stage__c,Customer_Type__c,ROI__c,Tenure__c,Loan_Amount__c, 
                                      Branch_Master__r.Region_Code__c,Branch_Master__r.State_Code__c,Branch_Master__r.Hub_Code__c,
                                      Branch_Master__r.Branch_location_State__c FROM Loan_Application__c WHERE Id=:loanAppId];
        if(loanApp!=null || loanApp.Product__c!=null){
            ProductRTMap__mdt prdRTP = ProductRTMap__mdt.getInstance('A_'+loanApp.Product__c);
            lwrap.screenType = getTypeScreen(prdRTP.Sub_Product__c);
            lwrap.loanApp = loanApp;
            lwrap.typeOfWheeler=getTypeOfWheeler(loanApp.Product__c);
        }
        
        return lwrap;
    }
    
    Public Class LoanAppWrapper{
        @AuraEnabled public Loan_Application__c loanApp;
        @AuraEnabled public TypeOfScreen screenType;
        @AuraEnabled public TypeOfWheeler typeOfWheeler;
    }
    
    public class TypeOfScreen{
        @AuraEnabled public Boolean isUsed=false;
        @AuraEnabled public Boolean isNew=false;
    }
    
    public static AUSFVehicleController.TypeOfScreen getTypeScreen(String productValue){
        AUSFVehicleController.TypeOfScreen typeOfScreen = new AUSFVehicleController.TypeOfScreen();
        if(productValue!=null){
            if(productValue.contains(System.label.AUSFNewScreen)){
                typeOfScreen.isNew = true;
            }else{
                if(productValue.contains(System.label.AUSFUsedScreen) || System.label.AUSFCowScreen.toUpperCase().contains(productValue.toUpperCase()) || System.label.AUSFCowScreenR2.toUpperCase().contains(productValue.toUpperCase())){ // SFAU-5584
                    typeOfScreen.isUsed = true;
                }
            }
        }
        return typeOfScreen;
    }
    
    
    // SFAU-3486
    @AuraEnabled
    public static String createVahanReport(Id loanId){
        system.debug('@@loanId'+loanId);
        if(loanId != null){
            List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
             List<Document_Master__c> docMaster = [SELECT Id,Document_Name__c,Document_Sub_Category__c,Document_Category__c FROM Document_Master__c Where Document_Name__c = 'Vahaan Master'];
            dcList = [SELECT Id FROM Document_Checklist__c WHERE Loan_Application__c=:loanId AND Document_Master__c =: docMaster[0].Id];
            system.debug('@@dcList'+dcList);
            Document_Checklist__c docCheck= new Document_Checklist__c();
            if(dcList!= null && dcList.size()>0){
                docCheck.Id = dcList[0].Id;
            }
            
            docCheck.Loan_Application__c = loanId;
            docCheck.Document_Master__c = docMaster[0].Id;
            docCheck.Document_Name__c = docMaster[0].Document_Name__c;
            docCheck.Active__c = true;
            docCheck.Category__c = docMaster[0].Document_Category__c;
            docCheck.Sub_Category__c = docMaster[0].Document_Sub_Category__c;
            upsert docCheck;
            List<ContentVersion> cvList = [Select Id,contentDocumentId,VersionData From ContentVersion WHERE FirstPublishLocationId =: docCheck.Id and Title = 'Vahaan Report'];
        
            Blob pdfData;
            if(Test.isRunningTest()) {
                pdfData = blob.valueOf('Unit.Test');
            }
            else{
                
                pdfData = new PageReference('/apex/vahanPdf?loanid='+loanId).getContent();
                
                
            }
            system.debug('@@pdfData'+pdfData);
            if(pdfData != null){
                Contentversion cvData = new ContentVersion();
                cvData.VersionData = pdfData;
                cvData.Title = 'Vahaan Report';
                cvData.PathOnClient = '.pdf';
                cvData.isActive__c = true;
                
                if(cvList.size()>0){
                    cvData.ContentDocumentId = cvList[0].ContentDocumentId;
                }
                else{
                    cvData.FirstPublishLocationId = docCheck.Id;
                }
                insert cvData;   
                Id documentId = cvList.isEmpty() ? [ SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvData.Id ].ContentDocumentId : cvList[0].ContentDocumentId;
                return URL.getSalesforceBaseUrl().toExternalForm().replace('my.salesforce','lightning.force') + '/lightning/r/ContentDocument/' + documentId + '/view';
            }
        }
        return null;
    }
    /*
    // SFAU-3486
    @AuraEnabled
    public static String createVahanReport(Id loanId){
        system.debug('@@loanId'+loanId);
        if(loanId != null){
            List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
             List<Document_Master__c> docMaster = [SELECT Id,Document_Name__c,Document_Sub_Category__c,Document_Category__c FROM Document_Master__c Where Document_Name__c = 'Vahaan Master'];
            dcList = [SELECT Id FROM Document_Checklist__c WHERE Loan_Application__c=:loanId AND Document_Master__c =: docMaster[0].Id];
            system.debug('@@dcList'+dcList);
            Document_Checklist__c docCheck= new Document_Checklist__c();
            if(dcList!= null && dcList.size()>0){
                docCheck.Id = dcList[0].Id;
            }
            
            docCheck.Loan_Application__c = loanId;
            docCheck.Document_Master__c = docMaster[0].Id;
            docCheck.Document_Name__c = docMaster[0].Document_Name__c;
            docCheck.Active__c = true;
            docCheck.Category__c = docMaster[0].Document_Category__c;
            docCheck.Sub_Category__c = docMaster[0].Document_Sub_Category__c;
            upsert docCheck;
            List<ContentVersion> cvList = [Select Id,contentDocumentId,VersionData From ContentVersion WHERE FirstPublishLocationId =: docCheck.Id and Title = 'Vahaan Report'];
        
            Blob pdfData;
            if(Test.isRunningTest()) {
                pdfData = blob.valueOf('Unit.Test');
            }
            else{
                
                pdfData = new PageReference('/apex/vahanPdf?loanid='+loanId).getContent();
                
                
            }
            system.debug('@@pdfData'+pdfData);
            if(pdfData != null){
                Contentversion cvData = new ContentVersion();
                cvData.VersionData = pdfData;
                cvData.Title = 'Vahaan Report';
                cvData.PathOnClient = '.pdf';
                cvData.isActive__c = true;
                
                if(cvList.size()>0){
                    cvData.ContentDocumentId = cvList[0].ContentDocumentId;
                }
                else{
                    cvData.FirstPublishLocationId = docCheck.Id;
                }
                insert cvData;   
                Id documentId = cvList.isEmpty() ? [ SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvData.Id ].ContentDocumentId : cvList[0].ContentDocumentId;
                return URL.getSalesforceBaseUrl().toExternalForm().replace('my.salesforce','lightning.force') + '/lightning/r/ContentDocument/' + documentId + '/view';
            }
        }
        return null;
    }
    */
    
    @AuraEnabled
    public static AUSFVahaanResponseWrapper getVahaanDetail(String registrationNumber, Id loanApplicationId) {
        AUSFVahaanResponseWrapper objWrapper = new AUSFVahaanResponseWrapper();
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = NULL;
        try {
            String vehicleData;
            String respBody;
            String endPointUrl;
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Vahaan API');

            Integration_Checklist__c checklistRecord = new Integration_Checklist__c( Loan_Application__c = loanApplicationId );
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;

            calloutRequestWrapper.request = JSON.serialize(new map<String, Object>{
                'requestId' => IntegrationUtility.getReferenceId(),
                'channel' => objIntMapper.Apiuser__c,
                'regNo' => registrationNumber,
                'consent' => 'Y',
                'blackListInfo' => true,
                'challanDetails' => true,
                'filename' => '',
                'vahanUsername' => '',
                'vahanPassword' => ''
            });

            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            respBody=calloutResponseWrapper.response;
            //String respBody = response.getBody();  
            if(calloutResponseWrapper.statusCode == 200){
                objWrapper = AUSFVahaanResponseWrapper.parse(respBody);
                if( objWrapper.result?.metadata == NULL ){
                    AUSFGenericApiFailureResponse failureResponse = (AUSFGenericApiFailureResponse)JSON.deserialize( respBody, AUSFGenericApiFailureResponse.class );
                    
                    if( failureResponse.Errors?.Error.Message != NULL ){
                        objWrapper.errorMessage = Utility.getApiCustomError(
                            calloutResponseWrapper.checklistNumber,
                            failureResponse.Errors.Error.Code,
                            failureResponse.Errors.Error.Message,
                            calloutResponseWrapper.statusCode,
                            'AUSFVehicleController.getVahaanDetail'
                        );
                    } else {
                        objWrapper.errorMessage = Utility.getApiCustomError(
                            calloutResponseWrapper.checklistNumber,
                            'Failure',
                            'Unexpected response returned from Vahan',
                            calloutResponseWrapper.statusCode,
                            'AUSFVehicleController.getVahaanDetail'
                        );
                    }
                }
            } else {
                objWrapper.errorMessage = objWrapper.result?.metadata != null ? '' : Utility.getApiCustomError(
                    calloutResponseWrapper.checklistNumber,
                    'Failure',
                    'Unexpected response returned from Vahan',
                    calloutResponseWrapper.statusCode,
                    'AUSFVehicleController.getVahaanDetail'
                );
            }
        }
        catch(Exception ex){
            // SFAU-5706 - IBB Value not getting in any application
            if (calloutResponseWrapper != NULL && calloutResponseWrapper.checklistRecord != NULL){
                upsert calloutResponseWrapper.checklistRecord;
            }
            Log.error('Error in AUSFVehicleController getVahaanDetail :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanApplicationId);
            objWrapper.errorMessage = 'Something went wrong.';
        }
                    system.debug('objWrapper '+objWrapper);
        return objWrapper;
    }
    
    /*
@description :  Get Fetch Visible fields from custom metadata based on Screen Type, Stage, Profile  
@param :  String Screen Type, Stage, Profile
@return : List<String>
*/
    @AuraEnabled
    public static List<String> getVisibleFields(String strScreen, String strStage, String strProfile,String typeOfWheeler) {
        return AUSFVehicleHelper.getVisibleFields(strScreen,strStage,strProfile,typeOfWheeler);
    } 
    
    
    
    /*
@description :  Fetch Branch,State,Stage,Vehcile Usage,ScreenName 
@param :  String Screen Type, Stage, Profile
@return : MasterWrapper
*/
    @AuraEnabled
    public static MasterWrapper fetchBranchMasterRecord(Id loanAppId){
        Id recordTypeIdValue = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        String userBranchCode = [Select Branch_Code__c  From User Where Id = :UserInfo.getUserId() Limit 1]?.Branch_Code__c;
        system.debug('userBranchCode'+userBranchCode);
        String loggedInUserProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1 ]?.Name;
        //String loggedInUserProfileName = profile.Name;
        //String state =  [Select Id,State__c from Branch_Master__c  where Name =: userBranchCode]?.State__c;
        String state =  [Select Id,State__r.Account_Name__c from Account  where Account_Code__c =: userBranchCode WITH SECURITY_ENFORCED limit 1]?.State__r?.Account_Name__c;
        //Loan_Application__c loanApp =[SELECT Vehicle_use__c,Stage__c,Customer_Type__c,Loan_Amount__c, Product__c FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED Limit 1];
        Applicant__c app =[SELECT Customer_Grade__c,Existing_Customer__c,Type_Of_Employment__c,loan__r.Vehicle_use__c,loan__r.Stage__c,Loan__r.Name_Of_Customer__c, loan__r.Customer_Type__c,loan__r.ROI__c,loan__r.Tenure__c,loan__r.Loan_Amount__c, Loan__r.Customer_Grade__c,Loan__r.Sub_Grade__c, //R2-752 - Added Customer_Grade__c col.
                           loan__r.Product__c,loan__r.Collateral_Type__c,loan__r.Branch_Master__r.Region_Code__c,loan__r.Branch_Master__r.State_Code__c, loan__r.Branch_Master__r.Hub_Code__c,Loan__r.RecordType.Name, Loan__r.Repo_Sale_Vehicle__c, //R2-758 - Dealer Repo Funding 
                           Loan__r.Total_Loan_Amount__c, loan__r.Branch_Master__r.Branch_location_State__c,Loan__r.Purchase_City__c,Loan__r.Dealer_Master__r.Grading__c , Loan__r.Dealer_Master__r.Certified_Value__c, Loan__r.Original_Vehicle_Usage__c  FROM Applicant__c WHERE loan__c=:loanAppId AND recordTypeId=:recordTypeIdValue WITH SECURITY_ENFORCED Limit 1]; // SFAU-5163
        Loan_Application__c loan = [SELECT id, Name, Dealer_Master__r.Certified_Value__c,Stage__c,LAN__c, toLabel(Product__c), Collateral_Type__c  FROM Loan_Application__c WHERE id=:loanAppId];  //SFAU-3522                         
        system.debug('app>> '+app);
        system.debug('app loan>> '+app.loan__r);
        system.debug('app branch master>> '+app.Loan__r.Branch_Master__c);

        //START - SFAU-5163
        if (String.isBlank(app.Loan__r.Original_Vehicle_Usage__c)) {
            app.Loan__r.Original_Vehicle_Usage__c = app.Loan__r.Vehicle_use__c;
        }
        //END - SFAU-5163
        
        CollateralData coldata = getCollateralNames(app.loan__r.Product__c);
        MasterWrapper masterWrapper = new MasterWrapper();
        masterWrapper.userProfile =loggedInUserProfileName;
        masterWrapper.typeOfWheeler =getTypeOfWheeler(app.loan__r.Product__c);
        masterWrapper.loanApp = app;
        masterWrapper.certifiedVal = loan.Dealer_Master__r!=null ? loan.Dealer_Master__r.Certified_Value__c :''; //SFAU-3522
                masterWrapper.state =state;
        masterWrapper.productName = AUSFVehicleHelper.getPicklistLabel(app.loan__r.Product__c);
        masterWrapper.screenName =getScreenType(AUSFVehicleHelper.getPicklistLabel(app.loan__r.Product__c));
        masterWrapper.loanStage = loan.Stage__c;
        masterWrapper.isLanCreated = loan.LAN__c;
        
        if(masterWrapper.screenName==System.label.AUSFNewScreen){
            masterWrapper.onRoadPrice = getOnRoadPriceFields();
            String purchaseCity = app.Loan__r.Purchase_City__c == NULL ? getApplicantCurrentCity( new Set<Id>{ app.Id } ) : app.Loan__r.Purchase_City__c;
            String cityId = getCityId( app.Loan__r.Purchase_City__c );
            masterWrapper.cityId = String.isNotBlank(cityId) ? cityId : getCityId(getApplicantCurrentCity( new Set<Id>{ app.Id } ));
        }
        
        map<Id, Boolean> wasCollateralUpdated = new map<Id, Boolean>();
        masterWrapper.collateralList = getVehicles( loanAppId, wasCollateralUpdated );
        masterWrapper.collateralNames = coldata.collateralNames;
        masterWrapper.collateralNames.put( 'Vehicle_Type__c', Utility.getPicklistValuesByProductAndCollateralType( 'Vehicle_Type__c', app.Loan__r.Product__c, app.Loan__r.Collateral_Type__c ) ); //R2-765 - Vehicle Type based on Collateral Type and Product
        masterWrapper.collateralNames.put( 'Body_Type__c', Utility.getPicklistValuesByProductAndCollateralType( 'Body_Type__c', app.Loan__r.Product__c, app.Loan__r.Collateral_Type__c ) ); //R2-768 - Body Type based on Collateral Type and Product
        masterWrapper.mapOfCollateralNameVsId = coldata.mapOfCollateralNameVsId;
        masterWrapper.wasCollateralUpdated = wasCollateralUpdated;
        strCollateralName = app.loan__r.Collateral_Type__c;
        strScreenName = masterWrapper.screenName;
        strLoanProduct = app.loan__r.Product__c; //R2-2462
        //masterWrapper.strCollateralIdForNew = getCollateralId(app?.loan__r?.Product__c);//GenerateRandomNumber(15);
        system.debug('masterWrapper data is '+masterWrapper);
        return masterWrapper;
    }
    
    public static String getCollateralId(String productCode){
        String autoNumber = [select Id,Name from Collateral__c order by CreatedDate desc limit 1]?.Name;
        system.debug('autoNumber '+autoNumber);
        Integer nextAutoNumber = Integer.valueOf(autoNumber)+1;
        system.debug('nextAutoNumber '+nextAutoNumber);
        String num = String.valueOf(nextAutoNumber);
        String num1='';
        for(Integer i=0; i<10-num.length(); i++){ //the 4 is the number of digits you want. adjust accordingly
            num1+='0';
        }
        system.debug('num1 '+num1);
        String finalNum = num1+String.valueOf(nextAutoNumber);
        system.debug('finalNum '+finalNum);
        system.debug('autoNumber length'+autoNumber.length());
        system.debug('finalNum length'+finalNum.length());
        String collateralId = productCode + finalNum;
        return collateralId;
    }
    
    public class MasterWrapper{
        @AuraEnabled public map<string,List<PicklistWrapper>> collateralNames;
        @AuraEnabled public Map<String,String> mapOfCollateralNameVsId;
        @AuraEnabled public String userProfile; 
        @AuraEnabled public Applicant__c loanApp;
        @AuraEnabled public String state;
        @AuraEnabled public String screenName;
        @AuraEnabled public String productName;
        @AuraEnabled public String strCollateralIdForNew;
        @AuraEnabled public TypeOfWheeler typeOfWheeler;
        @AuraEnabled public List<Collateral__c> collateralList;
        @AuraEnabled public String cityId;
        @AuraEnabled public Map<String,On_Road_Price_Calculation__mdt> onRoadPrice;
        @AuraEnabled public Integer lastCreatedAutoNumber;
        @AuraEnabled public String certifiedVal;
        @AuraEnabled public map<Id, Boolean> wasCollateralUpdated;
        @AuraEnabled public String loanStage;
        @AuraEnabled public String isLanCreated;
        public MasterWrapper(){
            
        }
    }
    
    @AuraEnabled
    public static Map<String,On_Road_Price_Calculation__mdt> getOnRoadPriceFields(){
        Map<String,On_Road_Price_Calculation__mdt> mapOfOnRoadPrice = On_Road_Price_Calculation__mdt.getAll();
        return mapOfOnRoadPrice;
    }

    public static String getApplicantCurrentCity(Set<Id> applicantIds){
        if(!applicantIds.isEmpty()){
            Address__c[] currentAddress = [
                SELECT City__c FROM Address__c
                WHERE Applicant__c IN: applicantIds AND Address_Type__c = 'Current' AND Source_type__c IN ('', 'CBS')
                 LIMIT 1
            ];
            return !currentAddress.isEmpty() ? currentAddress[0].City__c : null;
        }
        return null;
    }

    @AuraEnabled
    public Static String getCityId(String purchaseCity) {
        Id cityMappingRecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('City Mapping').getRecordTypeId();
        return [SELECT City_Id__c FROM Generic_Master__c WHERE Name__c=:purchaseCity AND recordTypeId=:cityMappingRecordTypeId Limit 1]?.City_Id__c;
        //return cityId;
    }
    
    @AuraEnabled
    public static string GenerateRandomNumber(integer length) {
        string result = '';
        while(result.length() < length){
            blob privateKey = crypto.generateAesKey(256);
            string randomString = EncodingUtil.base64Encode(crypto.generateMac('hmacSHA512',privateKey,privateKey));
            result += randomString.replaceAll('[^0-9]','');
        }
        result = result.substring(0,length);
        return result;
    }
    
    public static AUSFVehicleController.TypeOfWheeler getTypeOfWheeler(String productCode){
        AUSFVehicleController.TypeOfWheeler typeOfWhelr = new AUSFVehicleController.TypeOfWheeler();
        if(productCode!=null){
            ProductRTMap__mdt prdRTP = ProductRTMap__mdt.getInstance('A_'+productCode);
            if(prdRTP.RecordType__c == 'Four Wheeler'){
                typeOfWhelr.isFourWheeler = true;
            }else if(prdRTP.RecordType__c == 'Two Wheeler'){
                    typeOfWhelr.isTwoWheeler = true;
            } else if(prdRTP.RecordType__c == 'Tractor'){// R2-17
                typeOfWhelr.isTractor = true;
            } else if(prdRTP.RecordType__c == 'Commercial Vehicle' || prdRTP.RecordType__c == 'Construction Equipment'){
                typeOfWhelr.isCommercialVehicle = true;
            } else {
                typeOfWhelr.isOther = true;
            }
        }
        return typeOfWhelr;
    }
    
    public static String getScreenType(String productValue){
        if(productValue.contains(System.label.AUSFNewScreen)){
            return System.label.AUSFNewScreen;
        }else if(productValue.contains(System.label.AUSFUsedScreen) || System.label.AUSFCowScreen.contains(productValue) || System.label.AUSFCowScreenR2.contains(productValue)){ //SFAU-5584
            return System.label.AUSFUsedScreen; 
        }else{
            return System.label.AUSFNewScreen;
        }
        
    } 

    public static String getScreenType(String productValue,Boolean boolfromScheme){
        if(productValue.contains(System.label.AUSFNewScreen)){
            return System.label.AUSFNewScreen;
        }else if(productValue.contains(System.label.AUSFUsedScreen)){
            return System.label.AUSFUsedScreen;
        }else if(System.label.AUSFCowScreen.contains(productValue) || System.label.AUSFCowScreenR2.contains(productValue)){ // SFAU-5584
            return System.Label.COW; // SFAU-5584
        }else{
            return System.label.AUSFNewScreen;
        }
        
    } 
    
    
    /*
@description :  Get Collateral__c based on Loan Application Record  
@param :  Loan Application Record Id
@return : List<Collateral__c>
*/
    @AuraEnabled
    public static List<Collateral__c> getVehicles(Id loanAppRecId, map<Id, Boolean> wasCollateralUpdated){
        Id newRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        system.debug('loanAppId is>>' +loanAppRecId);//,
        // SFAU-5608 - Add Collateral_From_Lead_Api__c, Engine_Number__c, Chasis_Number__c, Apportioned_Loan_Amount__c in query
        // SFAU-5715 - Add IBB_API_Value__c
        Collateral__c[] collaterals = [
            Select Id, Name,Collateral_ID__c, Certified_Value__c ,CBS_Response__c, Vehicle_Usage__c, Loan__r.Total_Loan_Amount__c,
                Vahaan_Response__c,toLabel(Collateral_Name__c),MMV_Master__r.Name,Vehicle_Number__c,Collateral_Type__c,
                toLabel(Loan__r.Product__c),Variant__c, Apportioned_Loan_Amount__c, Approved_LTV__c,Type_Of_Existing_Collateral__c,
                Linked_Account_Number__c,LTV_offered__c,Implement_Type__c,CustomerId__c, EX_showroom_Price_API__c, POS__c, LTV_offered_On_final_cost__c, Final_Cost__c,
                LTV_offered_On_road__c, LTV_offered_Ex_showroom__c, CreatedDate, SystemModStamp, BT_Loan_Status__c, Original_Vehicle_Usage__c, Loan__r.Original_Vehicle_Usage__c, Is_Collateral_Updated_Post_Creation__c, Collateral_From_Lead_Api__c, Engine_Number__c, Chasis_Number__c, Valuation_Amount__c, Make__c, Model__c, Ex_Showroom_Price__c, Current_Owner_Name__c, Owner_Serial_number__c, Engine_Category__c, Vehicle_Color__c, Registration_City__c, IBB_API_Value__c
                FROM  Collateral__c  where Loan__c  =: loanAppRecId AND Is_Deleted__c =false AND
                (recordTypeId=:newRecordTypeId OR recordTypeId=:usedColRecordTypeId)
            ];//AND recordTypeId!=:existingColRecordTypeId AND 
        
        for(Collateral__c collateral: collaterals){
            //START - SFAU-5163
            if (String.isNotBlank(collateral.Loan__r.Original_Vehicle_Usage__c) && collateral.Original_Vehicle_Usage__c != collateral.Loan__r.Original_Vehicle_Usage__c) {
                collateral.Original_Vehicle_Usage__c = collateral.Loan__r.Original_Vehicle_Usage__c;
            }
            else if (String.isBlank(collateral.Loan__r.Original_Vehicle_Usage__c) && String.isBlank(collateral.Original_Vehicle_Usage__c)) {
                collateral.Original_Vehicle_Usage__c = collateral.Vehicle_Usage__c;
            }
            //END - SFAU-5163
            wasCollateralUpdated.put( collateral.Id, collateral.SystemModStamp != collateral.CreatedDate );
        }
        return collaterals;
    }    

    /**
     * SFAU-4091
     * 11th Sept 23
     * Calculates vehicle cost based on the valuation amount received from callback
     */
    public static Collateral__c calculateVehicleCost( Collateral__c collateralRecord ){

        if( String.isBlank(collateralRecord.Valuation_Amount__c) ){
            // throw exception valuation amount not received
            throw new AuraHandledException('Valuation amount is not present');
        }

        Double vehicleCost = collateralRecord.Vehicle_Cost__c,
            ibbValue = String.isNotBlank(collateralRecord.IBB_Value__c) ? ( Double.valueOf( Label.VehicleCostMultiplicand ) / 100 ) * Double.valueOf(collateralRecord.IBB_Value__c) : GlobalConstants.POSITIVE_INFINITY,
            valuationAmount = String.isNotBlank(collateralRecord.Valuation_Amount__c) ? Double.valueOf(collateralRecord.Valuation_Amount__c) : GlobalConstants.POSITIVE_INFINITY;

        // least among 120 % of IBB / Valuation has to be considered
        System.debug(String.isBlank(collateralRecord.Certified_Value__c) && valuationAmount < vehicleCost);
        if( String.isBlank(collateralRecord.Certified_Value__c) && valuationAmount < vehicleCost ){
            Double[] vehicleCostArgs = new Double[]{ ibbValue, valuationAmount };
            vehicleCostArgs.sort();

            Double applicableCost = vehicleCostArgs[0];
            if( applicableCost != GlobalConstants.POSITIVE_INFINITY && applicableCost != vehicleCost ){
                // update vehicle cost & BRE Re Run flag..
                collateralRecord.Vehicle_Cost__c = applicableCost;
            }
        }

        collateralRecord.Final_Cost__c = collateralRecord.Vehicle_Cost__c + collateralRecord.Other_Funding_Total__c;


        return collateralRecord;
    }

    /*
@description :  Get Collateral__c based on Screen Type, Stage, Profile  
@param :  String Screen Type, Stage, Profile
@return : Collateral__c
*/
    
    @AuraEnabled
    public static CollateralEditWrapper getVehicleDetails(Id collateralId,Id loanAppId ){
        CollateralEditWrapper collDetail = new CollateralEditWrapper();
        Id recordTypeIdValue = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        //String userBranchCode = [Select Branch_Code__c  From User Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED Limit 1]?.Branch_Code__c;
        //system.debug('userBranchCode'+userBranchCode);
        String strProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1 ]?.Name;
        //String loggedInUserProfileName = profile.Name;
        //String state =  [Select Id,State__c from Branch_Master__c  where Name =: userBranchCode WITH SECURITY_ENFORCED]?.State__c;
        //String state =  [Select Id,State__r.Account_Name__c from Account  where Account_Code__c =: userBranchCode WITH SECURITY_ENFORCED]?.State__r?.Account_Name__c;
        Applicant__c app =[SELECT Customer_Grade__c,Existing_Customer__c,Type_Of_Employment__c,loan__r.Vehicle_use__c,loan__r.Stage__c,loan__r.Customer_Type__c,loan__r.ROI__c,loan__r.Tenure__c,loan__r.Loan_Amount__c, 
                           loan__r.Product__c,loan__r.Collateral_Type__c,loan__r.Branch_Master__r.Region_Code__c,loan__r.Branch_Master__r.State_Code__c, loan__r.Branch_Master__r.Hub_Code__c, Loan__r.RecordType.Name,
                           loan__r.Branch_Master__r.Branch_location_State__c FROM Applicant__c WHERE loan__c=:loanAppId AND recordTypeId=:recordTypeIdValue WITH SECURITY_ENFORCED Limit 1];
        system.debug('app>> '+app);
        Loan_Application__c loanApp =app.loan__r;
        String strScreen = getScreenType(AUSFVehicleHelper.getPicklistLabel(app.loan__r.Product__c));
        String strStage  = app.loan__r.Stage__c;
        strLoanProduct = loanApp.Product__c; //R2-2462
        /*
        * Logic moved to static query - getVehicleQuery
        List<String> fieldList = new List<String>();
        if(strScreen == 'Used' && loanApp.Product__c =='10502'){
            fieldList = Utility.getVisibleFields(strScreen,strStage,strProfile,'Tractor','');
        }else{
        fieldList = Utility.getVisibleFields(strScreen,strStage,strProfile);
        }
        if(!fieldList.contains('RC_is_on_name_of_Applicant__c') && !fieldList.contains(' RC_is_on_name_of_Applicant__c') && !fieldList.contains('RC_is_on_name_of_Applicant__c ') && !fieldList.contains(' RC_is_on_name_of_Applicant__c ')){
            fieldList.add('RC_is_on_name_of_Applicant__c');
        }
        if(!fieldList.contains('BT_Loan_Status__c')){
            fieldList.add('BT_Loan_Status__c');
        }
        
        Set<String> fieldListSet = new Set<String>(fieldList);
        fieldListSet.addAll( new Set<String>{ 'Id','CBS_Response__c','IntegrationReadOnlyData__c','Vahaan_Response__c', 'EX_showroom_Price_API__c', 'Final_Cost__c', 'Loan__r.Total_Loan_Amount__c', 'Vehicle_Usage__c' }); // - Vehicle Usage moved here since it might not be in the visble fields*/
        /*system.debug('loanAppId is>>' +collateralId);
        String vehicleQuery = 'SELECT Id,Attachment__c,Engine_Number__c,Chasis_Number__c,Max_Funding_Cap__c,Implement_Type__c,Date_of_Delivery__c,LS_API__c,Loan_suruksha_to_Whom__c,Product_of_Loan_suraksha__c,Company_of_Loan_suraksha__c,CBS_Response__c,IntegrationReadOnlyData__c,Vahaan_Response__c, EX_showroom_Price_API__c, Loan__r.Total_Loan_Amount__c,Loan__r.Collateral_Type__c, Loan__r.Original_Vehicle_Usage__c,Hours_Meter_Reading__c,Product_Sub_Type__c, Original_Vehicle_Usage__c, '+ String.join(fieldList, ',')+' FROM Collateral__c where Id  =:collateralId ORDER BY CreatedDate DESC'; // SFAU-5163
        //Engine_Number__c,Chasis_Number__c
        */
        String vehicleQuery = getVehicleQuery() +' where Id  =:collateralId ORDER BY CreatedDate DESC';
        String actualQuery = String.escapeSingleQuotes(vehicleQuery);
        List<Collateral__c> vehicleDetailList = Database.query(actualQuery);
        Collateral__c coll = new Collateral__c();
        coll=vehicleDetailList[0];
        //START - SFAU-5163
        if (String.isNotBlank(coll.Loan__r.Original_Vehicle_Usage__c) && coll.Loan__r.Original_Vehicle_Usage__c != coll.Original_Vehicle_Usage__c) {
            coll.Original_Vehicle_Usage__c = coll.Loan__r.Original_Vehicle_Usage__c;
        }
        else if (String.isBlank(coll.Original_Vehicle_Usage__c)) {
            coll.Original_Vehicle_Usage__c = coll.Vehicle_Usage__c;
        }

        //END - SFAU-5163
        collDetail.collateralName = getPicklistLabel(coll.Collateral_Name__c);
        Map<string,List<PicklistWrapper>> implementPickListVal = new Map<string,List<PicklistWrapper>>();
        if(coll.Collateral_Name__c == Label.Implement_Collateral_Code){ //Check for Implement
            implementPickListVal = getPickListValues('','',loanApp.RecordType.Name,'Implement','','','');
        }
        Map<string,List<PicklistWrapper>> makePickListVal = getPickListValues('','',loanApp.RecordType.Name,'Make', loanApp.Collateral_Type__c,strScreen,'');
        Map<string,List<PicklistWrapper>> modelPickListVal = getPickListValues(coll.Make__c,'',loanApp.RecordType.Name,'Model',loanApp.Collateral_Type__c,strScreen,'');
        Map<string,List<PicklistWrapper>> variantPickListVal = getPickListValues(coll.Make__c,coll.Model__c,loanApp.RecordType.Name,'Variant',loanApp.Collateral_Type__c,strScreen,'');
        
        Map<string,List<PicklistWrapper>> categoryPickListVal;
        Map<string,List<PicklistWrapper>> regCityPickListVal;
        if(strScreen =='Used'){
            categoryPickListVal = getUsedCategoryPickListValuesR2(coll.MMV_Master__c,loanAppId);  
             regCityPickListVal= getRegistrationCityPickListValues(coll.Vehicle_Number__c);
        }
        
        if(strScreen =='New'){
            system.debug('in new '+coll.MMV_Master__c);
            categoryPickListVal = getNewCategoryPickListValues( JSON.serialize(coll) );  
        }
        
        SchemeWrapper sch = getSchemePickListValues(loanApp,app,coll.vehicle_category__c,coll.Collateral_Name__c);
        Map<string,List<PicklistWrapper>> schemePickListVal = sch.schemeValues;
        
        Map<string,List<PicklistWrapper>> allPickList = new Map<string,List<PicklistWrapper>>();
        allPickList.putAll(implementPickListVal);
        allPickList.putAll(makePickListVal);
        allPickList.putAll(modelPickListVal);
        allPickList.putAll(variantPickListVal);
        allPickList.putAll(categoryPickListVal);
        allPickList.putAll(schemePickListVal);
        allPickList.put( 'Vehicle_Type__c', Utility.getPicklistValuesByProductAndCollateralType( 'Vehicle_Type__c', loanApp.Product__c, loanApp.Collateral_Type__c ) );
        if(strScreen =='Used'){
        allPickList.putAll(regCityPickListVal);
        }
        collDetail.coll = coll;
        collDetail.picklist =allPickList;
        List<Document_Master__c> docMaster = [SELECT Id,Document_Name__c,Document_Sub_Category__c,Document_Category__c FROM Document_Master__c Where Document_Name__c = 'Vahaan Master'];
        List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
        if(!docMaster.isEmpty()){
            dcList = [SELECT Id FROM Document_Checklist__c WHERE Loan_Application__c=:loanAppId AND Document_Master__c =: docMaster[0].Id];
        }
        //List<Document_Checklist__c> 
        if(dcList.size()>0){
            List<ContentDocumentLink> conDocLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:dcList[0].Id and ContentDocument.Title = 'Vahaan Report' order by SystemModstamp desc limit 1];
            if(conDocLink.size() > 0){
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                String baselightningUrl = baseUrl.replace('my.salesforce','lightning.force');
                collDetail.linkForDoc = baselightningUrl+'/lightning/r/ContentDocument/'+ConDocLink[0].ContentDocumentId+'/view';
            }
            //cvList = [Select Id,contentDocumentId,VersionData From ContentVersion WHERE FirstPublishLocationId =: dcList[0].Id and Title = 'Vahaan Report'];
        }
        return collDetail;
    }
    
    public static String getVehicleQuery(){
        return 'SELECT Attachment_Type__c,LTV_Enhancer__c,Accessories_Funding__c,Serial_no_of_Attachment__c, Accessories_Value__c, Accessories__c, Additional_collateral_valid_till_date__c, Address_Line_1__c, Address_Line_2__c,'+
         'Address_Line_3__c, Application_Proceed__c, Apportioned_Loan_Amount__c, Approval_Required__c, Approved_Customer_equity__c, Approved_LTV__c, Assecessories__c,'+ 
         'Assessment_Method__c, Assessories_Value__c, Assessories__c, Assignment_Case__c, Attachment__c, BT_Loan_Status__c, Blacklist_Details__c, Body_Linked_with__c,'+ 
         'Body_Type__c, Body_Value__c, Body__c, Built__c, CBS_Response__c, Case_In_Deferral__c, Certified_Value__c, Challan_Info__c, Challan_Overdue_Amount__c, '+
         'Chasis_Number__c, City__c, Collateral_Code_in_CBS__c, Collateral_ID__c, Collateral_Id_in_CBS__c, Collateral_Name_Match_Percentage__c, Collateral_Name__c,'+ 
         'Collateral_Name_todelete__c, Collateral_Search_Results__c, Collateral_Type__c, Collateral_Value__c, Company_of_Loan_suraksha__c, Cost__c, Cost_to_be_Consider__c,'+ 
         'CreatedById, CreatedDate, Current_Owner_Name__c, CustomerId__c, Customer_equity__c, DO_Auto_Number__c, DO_Cancellation_Date__c, DO_Generation_Date__c, DO_Number__c,'+ 
         'Date_of_Delivery__c, Deferral_Category__c, Discount__c, Engine_Category__c, Engine_Number__c, Estimated_market_value__c, Ex_Showroom_Price_API__c, Ex_Showroom_Price__c,'+ 
         'Existing_Policy_Insurer_Company__c, Existing_Policy_Type__c, Exiting_Policy_Expired__c, External_Lead_Id__c, FD_Number__c, FD_amount__c, FMP__c, Final_Cost__c, '+
         'Final_Vehicle_Cost__c, Fuel_Type__c, Grid_Depreciated_Value__c, HPN_On_Invoice__c, HPN_On_RC__c, HPN_With_Financiers_Name__c, HP__c, Have_you_made_a_claim_Last_year__c,'+ 
         'Hours_Meter_Reading__c, House_No_Plot_No__c, IBB_Value__c, IDV__c, Id, Implement_Type__c, Insurance_Expiry_Date__c, Insurance_Funding__c, Insurance_Value__c, '+
         'Insurance__c, IntegrationReadOnlyData__c, Invoice_Amount__c, Invoice_Date__c, Invoice_Number__c, Invoice_Status__c, Invoice_values_OEM_s__c, IsDeleted, '+
         'IsDetailsFromVahaanApi__c, Is_Deleted__c, Is_Registerable__c, Kilometer__c, LS_API__c, LS_Value__c, LS__c, LTV__c, LTV_offered_Ex_showroom__c, '+
         'LTV_offered_On_final_cost__c, LTV_offered_On_road__c, LTV_offered__c, LTV_on_Vehicle_Cost__c, Land_Area__c, LastModifiedById, LastModifiedDate, Linkage_Type__c,'+ 
         'Linked_Account_Number__c, Loan_Amt_Aprotined__c, Loan_Eligibilty__c, Loan__c, Loan_suruksha_to_Whom__c, Luxury_Non_Luxury__c, MFg__c, MMV_Master__c, Make__c, '+
         'Make_variant__c, Manual_Collateral__c, Manual_Make__c, Manual_Model__c, Manual_Variant__c, Manufacture_Year__c, Manufacture_year_month__c, Manufacturer__c, '+
         'Max_Funding_Cap__c, Model__c, NCB_in_Exisiting_policy__c, Name, Net_of_Discount_Price__c, Occupancy_Type__c, On_Road_Price__c, Original_RC_Details__c, '+
         'Original_Vehicle_Usage__c, Other_Costs__c, Other_Funding_Total__c, Owner_Serial_number__c, Ownership_Transfer_On_RC__c, POS__c, Pincode__c, Product_Name_Code__c,'+ 
         'Product_Sub_Type__c, Product__c, Product_of_Loan_suraksha__c, Quantity__c, RC_Status__c, RC_is_on_name_of_Applicant__c, RTO_Tax_Value__c, RTO_Tax__c, RTO_Taxes__c,'+ 
         'Receipt_Amount__c, Receipt_No__c, RecordTypeId, Registrable__c, Registration_City__c, Registration_Date__c, Registration_Number__c, Relationship__c, '+
         'Repo_Sale_Vehicle_CBS__c, Repo_Sale_Vehicle__c, Rto_Code__c, SVSH_SVOH__c, Scheme_Name__c, Scheme__c, Seating_Capacity__c, Sourcing_Detail__c, State__c,'+ 
         'SystemModstamp, TAR_Customer_Equity_Amount_MMR_paid__c, TAR_Delivery_Date__c, TAR_Place_of_Visit__c, TAR_Sr_No__c, TAR_Status__c, '+
         'TAR_Tractors_Running_Usage_Hour_Meter_Re__c, TAR_if_Other_please_specify__c, Taluka__c, Tax_Receipt_Status__c, Temp_Vehicle_No__c, Total_Collateral_Value__c,'+ 
         'Total_Loan_Amount__c, Total_Pos__c, Total_Utilized_Value__c, Type_Of_Existing_Collateral__c, Vahaan_Name_Match_Percentage__c, Vahaan_Response__c, Valuation_Amount__c,'+ 
         'Valuation_date__c, Variance__c, Variant__c, Vehicle_Category__c, Vehicle_Color__c, Vehicle_Cost__c, Vehicle_Delivery__c, Vehicle_Number__c, Vehicle_Type__c, '+
         'Vehicle_Usage__c, Village__c, isSecondary__c,Loan__r.Original_Vehicle_Usage__c, Capping_Amount__c, Financier_Name__c, ' + 
         'Parent_Collateral__c, ParentCollateral.Name, ParentCollateral.Scheme__c, ParentCollateral.Collateral_Name__c, ParentCollateral.Vehicle_Type__c, ParentCollateral.Body_Type__c, ' + 
         'Loan__r.Parent_Loan__c, ParentLoan.Name, ParentLoan.Scheme__c, ParentLoan.Customer_Grade__c, ParentLoan.Sub_Grade__c, Body_invoice_is_GST_paid__c, NOC_Status__c, ' +
         'VariantMaster.Name, VariantMaster.Model__r.Name, VariantMaster.Make__r.Name, Is_Collateral_Updated_Post_Creation__c, IBB_API_Value__c ' +
         'FROM Collateral__c collateral, Loan__r.Parent_Loan__r ParentLoan, collateral.Parent_Collateral__r ParentCollateral, collateral.MMV_Master__r VariantMaster';
    }
    
    public class CollateralEditWrapper{
        @AuraEnabled public Map<String,List<PicklistWrapper>> picklist;
        @AuraEnabled public Collateral__c coll;
        @AuraEnabled public String collateralName;
        @AuraEnabled public String linkForDoc;
    }
    
    public static List<MMV_Master__c> getRecords(String fieldName,String make,String model,String collateralName) {
        String query='';
        String strNew = 'New';
        String strUsedCOW = 'Used / Cash on Wheels';
        String strAll = 'All';
        Id recordTypeIdValue;
        if(fieldName == 'Implement'){
            recordTypeIdValue = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        }
        else{
            recordTypeIdValue = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get(fieldName).getRecordTypeId();            
        }
        system.debug('collateralName>> '+collateralName);
        /*Id modelRecordTypeId = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get(system.label.ModelMMVMaster).getRecordTypeId();
Id variantRecordTypeId = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get(system.label.VariantMMVMaster).getRecordTypeId();*/
        
        if (fieldName == System.Label.MakeMMVMaster){//recordTypeId=:recordTypeIdValue AND
            query = 'SELECT Name,Collateral_Name__c FROM MMV_Master__c WHERE  recordTypeId=:recordTypeIdValue' + (VEHICLE_TYPE_TO_MMV_FILTER_FIELD.containsKey(collateralName) ? ' AND ' + VEHICLE_TYPE_TO_MMV_FILTER_FIELD.get( collateralName ) + ' = TRUE' : '');//AND Collateral_Name__c =:collateralName
        }
        
        if (fieldName == System.Label.ModelMMVMaster){
            query = 'SELECT Name,Collateral_Name__c FROM MMV_Master__c WHERE  recordTypeId=:recordTypeIdValue AND Make__r.Name=:make' + (VEHICLE_TYPE_TO_MMV_FILTER_FIELD.containsKey( collateralName ) ? (' AND ' + VEHICLE_TYPE_TO_MMV_FILTER_FIELD.get( collateralName ) + ' = TRUE') : '');//AND Collateral_Name__c =:collateralName
        }
        
        if (fieldName == System.Label.VariantMMVMaster){
            query = 'SELECT Name,Id,Collateral_Name__c FROM MMV_Master__c WHERE  recordTypeId=:recordTypeIdValue AND Make__r.Name=:make AND Model__r.Name=:model' + (VEHICLE_TYPE_TO_MMV_FILTER_FIELD.containsKey(collateralName) ? ' AND Model__r.' + VEHICLE_TYPE_TO_MMV_FILTER_FIELD.get( collateralName ) + ' = TRUE' : '');//AND Collateral_Name__c =:collateralName
            // query = 'SELECT Name,Id,Collateral_Name__c FROM MMV_Master__c WHERE  recordTypeId=:recordTypeIdValue AND Make__r.Name=:make AND Model__r.Name=:model';//AND Collateral_Name__c =:collateralName
        }
        
        if (fieldName == 'Implement'){
            query = 'SELECT Name,Collateral_Name__c,Implement_Type__c FROM MMV_Master__c WHERE  recordTypeId=:recordTypeIdValue' + (VEHICLE_TYPE_TO_MMV_FILTER_FIELD.containsKey(collateralName) ? ' AND ' + VEHICLE_TYPE_TO_MMV_FILTER_FIELD.get( collateralName ) + ' = TRUE' : '');//AND Collateral_Name__c =:collateralName
        }
        query = query + (!String.isBlank(strScreenName) && strScreenName == 'New' ? ' AND (Applicable_for__c = :strNew OR Applicable_for__c = :strAll)' : '');
        query = query + (!String.isBlank(strScreenName) && strScreenName == 'Used' ? ' AND (Applicable_for__c = :strUsedCOW OR Applicable_for__c = :strAll)' : '');
        if(collateralName == 'Tractor' && strCollateralName != '10132'){
            query = query + (!String.isBlank(strCollateralName) ? ' AND Collateral_Name__c = :strCollateralName' : '');
        }
        else if(collateralName == 'Tractor' && strCollateralName == '10132'){
            query = query + (!String.isBlank(strCollateralName) ? ' AND Collateral_Name__c = :strCollateralName' : '');
            query = query + (!String.isBlank(strImplementName) ? ' AND Implement_Type__c = :strImplementName' : '');
        } else if( String.isNotBlank(strCollateralName) && collateralName == GlobalConstants.COMMERCIALVEHICLE ){
            query += ' AND Collateral_Name__c =: strCollateralName';
            // R2-2462 || START
            if(strCollateralName == '10103' || strCollateralName == '10104' || strCollateralName == '10105'){
              String type='';
              String colName = strCollateralName =='10103' ? 'HCV' : strCollateralName =='10104'? 'LCV' : 'SCV';
              if(strLoanProduct == '10104' || strLoanProduct == '10105' || strLoanProduct == '10106' || strLoanProduct == '10108' || strLoanProduct == '10109' || strLoanProduct == '10110'){
                type = colName+' '+'Loading';
              }else if (strLoanProduct == '10101' || strLoanProduct == '10102' || strLoanProduct == '10103' || strLoanProduct == '10111' || strLoanProduct == '10112' || strLoanProduct == '10113'){
                type = colName+' '+'Passenger';
              }
              System.debug('type-->' +type);
                query += ' AND Type_Loading_passenger__c =: type';
            }
             // R2-2462 || END
        }
        query += ' ORDER BY Name ASC'; //MMVs to be sorted by default
        system.debug('query is '+query);
        String actualQuery = String.escapeSingleQuotes(query);
        List<MMV_Master__c> listOfMMVMasterData = Database.query(actualQuery);
        return listOfMMVMasterData;
    }
    
    /*
@description :  Get Picklist Values of Make,Model,Vairant based on Collateral Name  
@param :  String make model, collateralName, fielName
@return : Map<string,List<PicklistWrapper>>
*/
    @AuraEnabled(cacheable=true)
    public static  Map<string,List<PicklistWrapper>> getPickListValues(String make,String model,String collateralName,String fieldName,String collateralType,String screenType,String implementType) {
        Map<string,List<PicklistWrapper>>  mapOfMake = new  Map<string,List<PicklistWrapper>>();
        try{
            strScreenName = screenType;
            strCollateralName = collateralType;
            strImplementName = implementType;
            Id recordTypeIdValue;
            if(fieldName == 'Implement'){
                recordTypeIdValue = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
            }
            else{
                recordTypeIdValue = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get(fieldName).getRecordTypeId();            
            }
            mapOfMake.put(fieldName,new List<PicklistWrapper>());
            Set<String> myset = new Set<String>();
            for(MMV_Master__c obj:getRecords(fieldName,make,model,collateralName)){
                if(fieldName=='Variant'){
                    if(obj.Name!=null){
                        //if(myset.add(obj.Name)) {
                            mapOfMake.get(fieldName).add(new PicklistWrapper(obj.Name,obj.Id)) ;
                        //}
                    }
                }
                else if(fieldName=='Implement'){
                    system.debug('%%% '+obj);
                    system.debug('%%% '+obj.Implement_Type__c);
                    if(obj.Implement_Type__c!=null){
                        mapOfMake.get(fieldName).add(new PicklistWrapper(obj.Implement_Type__c,obj.Implement_Type__c)) ;
                    }
                }
                else{
                    if(obj.Name!=null){
                            mapOfMake.get(fieldName).add(new PicklistWrapper(obj.Name,obj.Name));
                    }
                }                
            }  
        }   
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        return mapOfMake; 
        
    }
    
      /*
@description :  Get Picklist Values of Make,Model,Vairant based on Collateral Name for CV 
@param :  String make model, collateralName, fielName
@return : Map<string,List<PicklistWrapper>>
*/
@AuraEnabled(cacheable=true)
public static  Map<string,List<PicklistWrapper>> getPickListCVValues(String make,String model,String collateralName,String fieldName,String collateralType,String screenType,String implementType,String loanProduct) {
    Map<string,List<PicklistWrapper>>  mapOfMake = new  Map<string,List<PicklistWrapper>>();
    try{
        strScreenName = screenType;
        strCollateralName = collateralType;
        strImplementName = implementType;
        strLoanProduct = loanProduct;
        Id recordTypeIdValue;
        if(fieldName == 'Implement'){
            recordTypeIdValue = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        }
        else{
            recordTypeIdValue = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get(fieldName).getRecordTypeId();            
        }
        mapOfMake.put(fieldName,new List<PicklistWrapper>());
        Set<String> myset = new Set<String>();
        for(MMV_Master__c obj:getRecords(fieldName,make,model,collateralName)){
            if(fieldName=='Variant'){
                if(obj.Name!=null){
                        mapOfMake.get(fieldName).add(new PicklistWrapper(obj.Name,obj.Id)) ;
                }
            }
            else if(fieldName=='Implement'){
                system.debug('%%% '+obj);
                system.debug('%%% '+obj.Implement_Type__c);
                if(obj.Implement_Type__c!=null){
                    mapOfMake.get(fieldName).add(new PicklistWrapper(obj.Implement_Type__c,obj.Implement_Type__c)) ;
                }
            }
            else{
                if(obj.Name!=null){
                    mapOfMake.get(fieldName).add(new PicklistWrapper(obj.Name,obj.Name));
                    }
                }                
            }  
        }   
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        return mapOfMake; 
        
    }
    
    /*
@description :  Get MMV_Master__c record based on Variant  
@param :  String Variant
@return : MMV_Master__c
*/
    @AuraEnabled(cacheable=true)
    public static MMV_Master__c getMmvRecord(String variant) {
        MMV_Master__c mmvRecord;
        try{
            Id recordTypeIdValue = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get('Variant').getRecordTypeId();
            mmvRecord = [SELECT ID,Make__c,Model__c,Collateral_Name__c,HP__c FROM MMV_Master__c WHERE Id=:variant];
        }   
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        return mmvRecord;    
    }
    
    public class SchemeWrapper{
        @AuraEnabled public Map<String,List<PicklistWrapper>> schemeValues;
        @AuraEnabled public Scheme_Master__c schemeMaster;
        /*@AuraEnabled public Map<String,Scheme_Master__c> mapOfLocationSepcificSchemVsRecord;
@AuraEnabled public Map<String,Scheme_Master__c > mapOfDealerSepcificSchemVsRecord;
@AuraEnabled public Map<String,Scheme_Master__c > mapOfMakeModelSepcificSchemVsRecord;*/
    }
    
    /*
@description :  Get Picklist Values of Make,Model,Vairant based on Collateral Name  
@param :  String make model, collateralName, fielName
@return : Map<string,List<PicklistWrapper>> Collateral__c coll
*/
    @AuraEnabled(cacheable=true)
    public static SchemeWrapper getSchemePickListValues(Loan_Application__c loanApp,Applicant__c app,String category,String collCode) {
        system.debug('loanApp '+loanApp);
        //system.debug('coll '+coll);
        SchemeWrapper scheme = new SchemeWrapper();
        Scheme_Master__c schemeMaster = new Scheme_Master__c();
        String typeOfEmp ;
        For(Income_Profiling__mdt  prof: Income_Profiling__mdt.getAll().values()){
            if(prof.Type_of_Employment__c  ==app.Type_Of_Employment__c){
                if(prof.Category__c!=null){
                    typeOfEmp = prof.Category__c;
                }else{
                    typeOfEmp = app.Type_Of_Employment__c;
                }
            }
        }
        Decimal  cibilScore = [SELECT Bureau_Score__c FROM Bureau_Results__c WHERE Applicant__c=:app.Id ORDER BY Bureau_Score_Date__c LIMIT 1]?.Bureau_Score__c;  
        if(cibilScore >= 0 && cibilScore <= 300){
            cibilScore = -1;
        }
        Map<string,List<PicklistWrapper>>  schemePickListValues = new  Map<string,List<PicklistWrapper>>();
        Map<String,Scheme_Master__c> mapOfLocationSepcificSchemVsRecord = new Map<String,Scheme_Master__c >();
        Map<String,Scheme_Master__c> mapOfDealerSepcificSchemVsRecord = new Map<String,Scheme_Master__c >();
        Map<String,Scheme_Master__c> mapOfMakeModelSepcificSchemVsRecord = new Map<String,Scheme_Master__c >();
        try{
            //Loan_Application__c loanApp =loanApp1;
            //Applicant__c app = app1;
            //Collateral__c coll=coll1;
            String loanType =getScreenType(AUSFVehicleHelper.getPicklistLabel(loanApp.Product__c),true);
            String typeOfCustomer = app.Existing_Customer__c=='Yes'?'ETB':'NTB';
            String custType = loanApp.Customer_Type__c=='Individual'?'I':'NI';
            system.debug('loanType>> '+loanType);
            system.debug('typeOfCustomer>> '+typeOfCustomer);
            schemePickListValues.put('Scheme',new List<PicklistWrapper>());
            Set<String> myset = new Set<String>();//AND Scheme__c='Normal'
            //String typeOfLoan ='All';//(Type_of_loan__c=:loanApp.Type_of_loan__c OR Type_of_loan__c=:typeOfLoan) (Type_of_employment__c=:app.Type_Of_Employment__c OR Type_of_employment__c=:typeOfLoan)  
            String query = 'SELECT Scheme_Name__c,MAXROI__c,MINROI__c,MAXLOANAMOUNT__c,MINLOANAMOUNT__c,MAXTENURE__c,MINTENURE__c,Is_Location_General_Scheme__c,Is_Make_model_Scheme__c,Is_Dealer_Scheme__c,Scheme_Code__c FROM Scheme_Master__c WHERE Vehicle_Usage__c =:loanApp.Vehicle_use__c AND Vehicle_category__c=:coll.Vehicle_Category__c AND (Type_of_loan__c=:typeOfLoan OR Type_of_loan__c=:loanType) AND  Profile__c=:app.Customer_Grade__c AND Customer_Type__c=:loanApp.Customer_Type__c AND Type_of_Customer__c=:typeofCustomer AND (Type_of_employment__c=:app.Type_Of_Employment__c OR Type_of_employment__c=:typeOfLoan) AND Is_InActive__c =false';            
            system.debug('laonApp >>'+loanApp);
            system.debug('app '+app);
            //system.debug('coll '+coll);
            String actualQuery =String.escapeSingleQuotes(query);
            for(Scheme_Master__c obj:[SELECT Vehicle_Usage__c,Collateral__c,Type_of_employment__c,Type_of_Customer__c,Customer_Type__c,Type_of_loan__c,Profile__c,Vehicle_category__c,Scheme_Name__c,MAXROI__c,MINROI__c,MAXLOANAMOUNT__c,MINLOANAMOUNT__c,MAXTENURE__c,MINTENURE__c,Is_Location_General_Scheme__c,Is_Make_model_Scheme__c,Is_Dealer_Scheme__c,Scheme_Code__c 
                                      FROM Scheme_Master__c WHERE Vehicle_Usage__c!=null AND Type_of_employment__c!=null AND Type_of_Customer__c!=null AND Customer_Type__c!=null 
                                      AND Type_of_loan__c!=null AND Profile__c!=null AND Vehicle_category__c!=null AND Is_InActive__c =false AND ((CIBIL_Min__c<=:cibilScore AND CIBIL_Max__c>=:cibilScore) OR Include__c=:cibilScore)]){
                                          system.debug('obj '+obj);
                                          if(obj!=null){
                                              List<String> vehicleUsage = obj.Vehicle_Usage__c.split(';');
                                              List<String> vehicleCategory = obj.Vehicle_category__c.split(';');
                                              List<String> typeOfLoan = obj.Type_of_loan__c.split(';');
                                              List<String> profileValue = obj.Profile__c.split(';');
                                              List<String> customerType = obj.Customer_Type__c.split(';');
                                              List<String> typeOfEmployment = obj.Type_of_employment__c.split(';');
                                              List<String> typeOfCustomerList = obj.Type_of_Customer__c.split(';');
                                              List<String> typeOfCollateral = obj.Collateral__c.split(';');
                                                                                            if(vehicleUsage.contains(loanApp.Vehicle_use__c) && vehicleCategory.contains(category) && typeOfLoan.contains(loanType) && profileValue.contains(app.Customer_Grade__c) && customerType.contains(custType) && typeOfEmployment.contains(typeOfEmp) && typeOfCustomerList.contains(typeofCustomer) && typeOfCollateral.contains(collCode)){
                                                  if(obj.Is_Location_General_Scheme__c=='False' && obj.Is_Make_model_Scheme__c=='False' && obj.Is_Dealer_Scheme__c=='False'){
                                                      system.debug('in if '+obj.Scheme_Name__c);
                                                      if(obj.Scheme_Name__c!=null){
                                                          if (myset.add(obj.Scheme_Name__c)) {
                                                              schemeMaster =obj;
                                                              schemePickListValues.get('Scheme').add(new PicklistWrapper(obj.Scheme_Name__c,obj.Id)) ;
                                                              system.debug('schemePickListValues in loop'+schemePickListValues);
                                                          }
                                                      }
                                                  }else{
                                                      if(obj.Is_Location_General_Scheme__c=='True'){
                                                          system.debug('in if Is_Location_General_Scheme__c '+obj.Scheme_Name__c);
                                                          //mapOfLocationSepcificSchemVsRecord.put(obj.Scheme_Name__c ,obj);
                                                          mapOfLocationSepcificSchemVsRecord.put(obj.Id ,obj);
                                                      }
                                                      if(obj.Is_Make_model_Scheme__c=='True'){
                                                          //mapOfDealerSepcificSchemVsRecord.put(obj.Scheme_Name__c ,obj);
                                                          mapOfMakeModelSepcificSchemVsRecord.put(obj.Id ,obj);
                                                      }
                                                      if(obj.Is_Dealer_Scheme__c=='True'){
                                                          //mapOfMakeModelSepcificSchemVsRecord.put(obj.Scheme_Name__c ,obj);
                                                          mapOfDealerSepcificSchemVsRecord.put(obj.Id ,obj);
                                                      }
                                                      /*if(obj.Is_Location_General_Scheme__c=='False' && obj.Is_Make_model_Scheme__c=='False' && obj.Is_Dealer_Scheme__c=='False'){
                                                          mapOfMakeModelSepcificSchemVsRecord.put(obj.Scheme_Name__c ,obj);
                                                      }*/
                                                  }
                                              } 
                                          }
                                       }
                                          
                                          system.debug('schemePickListValues>> '+schemePickListValues);
                                          if(!mapOfMakeModelSepcificSchemVsRecord.isEmpty()){
                                              schemePickListValues.putAll(getMasterJunctionMapping(mapOfMakeModelSepcificSchemVsRecord.keyset(),loanApp,schemePickListValues));
                                              //scheme.mapOfMakeModelSepcificSchemVsRecord = mapOfMakeModelSepcificSchemVsRecord;
                                          }
                                          if(!mapOfLocationSepcificSchemVsRecord.isEmpty()){
                                              schemePickListValues.putAll(getMasterJunctionMapping(mapOfLocationSepcificSchemVsRecord.keyset(),loanApp,schemePickListValues));   
                                          }
                                          if(!mapOfDealerSepcificSchemVsRecord.isEmpty()){
                                              schemePickListValues.putAll(getMasterJunctionMapping(mapOfDealerSepcificSchemVsRecord.keyset(),loanApp,schemePickListValues));
                                          }
                                          system.debug('mapOfMakeModelSepcificSchemVsRecord>> '+mapOfMakeModelSepcificSchemVsRecord);
                                          system.debug('mapOfLocationSepcificSchemVsRecord>> '+mapOfLocationSepcificSchemVsRecord);
                                          system.debug('mapOfDealerSepcificSchemVsRecord>> '+mapOfDealerSepcificSchemVsRecord);
                                      
            
            system.debug('schemePickListValues>> '+schemePickListValues);
            system.debug('schemeMaster>> '+schemeMaster);
            if(schemePickListValues.get('Scheme').size()==0){
                for(Scheme_Master__c obj:[SELECT Scheme_Name__c,Id FROM Scheme_Master__c WHERE Scheme_Name__c='Normal' Limit 1]){
                    if(obj.Scheme_Name__c!=null){
                        //if (myset.add(obj.Scheme_Name__c)) {
                            schemeMaster =obj;
                            schemePickListValues.get('Scheme').add(new PicklistWrapper(obj.Scheme_Name__c,obj.Id)) ;
                            system.debug('schemePickListValues in loop'+schemePickListValues);
                        //}
                    }
                }
            }
            scheme.schemeValues = schemePickListValues;
            scheme.schemeMaster = schemeMaster;
            
        }   
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        system.debug('scheme>> '+scheme);
        return scheme; 
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Applicant_Financials_Details__c getApplicantFinancials(Loan_Application__c loanApp){
        List<Applicant_Financials_Details__c> objFinancials = [Select Id,Size_of_Agri_Land__c,RecordType.Name,Applicant__r.Loan__c,Applicant__r.Loan__r.Customer_Grade__c,Applicant__r.Loan__r.Net_Land_Holding_in_Acre__c,Applicant__r.RecordType.Name from Applicant_Financials_Details__c 
                                                        where RecordType.Name = 'Financial Parent' AND Applicant__r.RecordType.Name = 'Applicant' AND Applicant__r.Loan__c =:loanApp.Id limit 1];
        if(!objFinancials.isEmpty()){
            return objFinancials[0];
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static DLP_FMP_Master__c getDLPFMPMasterRecord(Loan_Application__c loanApp,String mapOfColl){
        Collateral__c coll =(Collateral__c)JSON.deserialize(mapOfColl, Collateral__c.class);
        DLP_FMP_Master__c ltv = new  DLP_FMP_Master__c();
        system.debug('loanApp '+loanApp);
        system.debug('coll '+coll);//AND LTV__r.Make__c=:coll.Make__c AND LTV__r.Model__c=:coll.Model__c AND LTV__r.Variant__c=:coll.Variant__c
        Set<String> myset = new Set<String>();//AND LTV__r.MMV__r.Collateral_Name__c=:coll.Collateral_Name__c
        String strIsGeneral = 'False';
        Id recordTypeIdValue = Schema.SObjectType.DLP_FMP_Master__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
        Id recordTypeIdValueException = Schema.SObjectType.DLP_FMP_Master__c.getRecordTypeInfosByName().get('Territory Exception').getRecordTypeId();
        List<Account> acc = [SELECT RecordTypeId,Account_Code__c,State__r.Account_Code__c,Region__r.Account_Code__c FROM Account Where Id=:loanApp.Branch_Master__c Limit 1];
        For(DLP_FMP_Master__c  mjp:[SELECT Id,Dealer_MRP_DLP__c,FMV_Price_AU_Grid_Price__c,Max_Caping__c,Territory__r.recordTypeId,Territory__r.Account_Code__c FROM DLP_FMP_Master__c WHERE
                                             recordTypeId=:recordTypeIdValueException 
                                             AND MMV__c=:coll.MMV_Master__c AND Collateral_Type__c=:coll.Collateral_Name__c
                                             AND Fuel_Type__c =:coll.Fuel_Type__c AND (Asset_Category__c=:coll.Vehicle_Category__c OR Asset_Category__c = 'NA')
                                             ]){
                                                strIsGeneral = 'True';
                                                 system.debug('mjp '+mjp);
                                                 if(!acc.isEmpty()){
                                                     if(getMatchAccCodeWithLoanCode(acc[0],mjp)){//
                                                         if(mjp.Id!=null){
                                                             myset.add(mjp.Id);
                                                             ltv = mjp;
                                                         }  
                                                     }
                                                 }
                                                 
                                             }
        system.debug('myset>> '+myset);
        if(myset.size()>0){
            //ltv = [Select Id,IB__c,NIB__c,Premium__c,Assessment_Method__c FROM LTV_Master__c WHERE Id In:myset Limit 1];//
        }else{
            List<DLP_FMP_Master__c> lstLtv = [Select Id,Dealer_MRP_DLP__c,FMV_Price_AU_Grid_Price__c,Max_Caping__c FROM DLP_FMP_Master__c  WHERE Fuel_Type__c =:coll.Fuel_Type__c AND (Asset_Category__c=:coll.Vehicle_Category__c OR Asset_Category__c = 'NA')
                   AND MMV__c=:coll.MMV_Master__c AND Collateral_Type__c=:coll.Collateral_Name__c AND recordTypeId=:recordTypeIdValue Limit 1 ];
            if(!lstLtv.isEmpty()){
                ltv = lstLtv[0];
            }
        }
        system.debug('myset>> '+ltv);
        return ltv;
    }
    
    @AuraEnabled(cacheable=true)
    public static Depreciated_Grid__c getDepricatedTractorMasterRecord(Loan_Application__c loanApp,String mapOfColl){
        Id recordTypeIdValue = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('LTV').getRecordTypeId();
        Collateral__c coll =(Collateral__c)JSON.deserialize(mapOfColl, Collateral__c.class);
        String collateralId = '10109';
        System.debug('coll-->' +coll.Vehicle_Category__c);
        if(coll.Vehicle_Category__c!=null){
             Depreciated_Grid__c  mjp =[SELECT Id,recordTypeId,MMV__c,Collateral__c,Category__c,Agri_0_Land__c,Agri_Less_than_3_Land__c,Agri_More_than_3_Land__c,Commercial_Captive__c,Commercial_FTB__c,Commercial_FTU__c,Commercial_Transporter__c 
                                   FROM Depreciated_Grid__c 
                                   WHERE recordTypeId=:recordTypeIdValue AND Collateral__c =:collateralId AND Category__c =:coll.Vehicle_Category__c LIMIT 1];
         if(mjp!=null){
            return mjp;       
        }else{
            return null;
        }
        }else{
            return null;
        }
       
        
    }
        
    @AuraEnabled(cacheable=true)
    public static LTV_Master__c getLtvMasterRecordAgainstFMV(Loan_Application__c loanApp,String mapOfColl){
        Collateral__c coll =(Collateral__c)JSON.deserialize(mapOfColl, Collateral__c.class);
        LTV_Master__c  ltv = new  LTV_Master__c();
        system.debug('loanApp '+loanApp);
        system.debug('coll '+coll);//AND LTV__r.Make__c=:coll.Make__c AND LTV__r.Model__c=:coll.Model__c AND LTV__r.Variant__c=:coll.Variant__c
        Set<String> myset = new Set<String>();//AND LTV__r.MMV__r.Collateral_Name__c=:coll.Collateral_Name__c
        String strIsGeneral = 'False';
        Id recordTypeIdValue = Schema.SObjectType.LTV_Master__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
        Id recordTypeIdValueException = Schema.SObjectType.LTV_Master__c.getRecordTypeInfosByName().get('Territory Exception').getRecordTypeId();
        List<Account> acc = [SELECT RecordTypeId,Account_Code__c,State__r.Account_Code__c,Region__r.Account_Code__c FROM Account Where Id=:loanApp.Branch_Master__c Limit 1];
        For(LTV_Master__c  mjp:[SELECT Id,Agri_0_Land__c,Agri_Less_than_3_Land__c,Agri_More_than_3_Land__c,Commercial_Captive__c,Commercial_FTB__c,Commercial_FTU__c,Commercial_Transporter__c,Territory__r.recordTypeId,Territory__r.Account_Code__c FROM LTV_Master__c WHERE
                                             recordTypeId=:recordTypeIdValueException AND Collateral_Type__c=:coll.Collateral_Name__c
                                             /*AND MMV__c=:coll.MMV_Master__c*/
                                             AND (Category__c=:coll.Vehicle_Category__c OR Category__c = 'NA')
                                             ]){
                                                strIsGeneral = 'True';
                                                 system.debug('mjp '+mjp);
                                                 if(!acc.isEmpty()){
                                                     if(getMatchAccCodeWithLoanCode(acc[0],mjp)){//
                                                         if(mjp.Id!=null){
                                                             myset.add(mjp.Id);
                                                             ltv = mjp;
                                                         }  
                                                     }
                                                 }
                                                 
                                             }
        system.debug('myset>> '+myset);
        if(myset.size()>0){
            //ltv = [Select Id,IB__c,NIB__c,Premium__c,Assessment_Method__c FROM LTV_Master__c WHERE Id In:myset Limit 1];//
        }else{
            List<LTV_Master__c> lstLtv = [Select Id,Agri_0_Land__c,Agri_Less_than_3_Land__c,Agri_More_than_3_Land__c,Commercial_Captive__c,Commercial_FTB__c,Commercial_FTU__c,Commercial_Transporter__c FROM LTV_Master__c  WHERE (Category__c=:coll.Vehicle_Category__c OR Category__c = 'NA')
                   /*AND MMV__c=:coll.MMV_Master__c*/ AND Collateral_Type__c=:coll.Collateral_Name__c AND recordTypeId=:recordTypeIdValue Limit 1 ];
            if(!lstLtv.isEmpty()){
                ltv = lstLtv[0];
            }
        }
        system.debug('myset>> '+ltv);
        return ltv;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static LTV_Master__c getLtvMasterRecord(Loan_Application__c loanApp,String mapOfColl){
        Collateral__c coll =(Collateral__c)JSON.deserialize(mapOfColl, Collateral__c.class);
        LTV_Master__c  ltv = new  LTV_Master__c();
        system.debug('loanApp '+loanApp);
        system.debug('coll '+coll);//AND LTV__r.Make__c=:coll.Make__c AND LTV__r.Model__c=:coll.Model__c AND LTV__r.Variant__c=:coll.Variant__c
        Set<String> myset = new Set<String>();//AND LTV__r.MMV__r.Collateral_Name__c=:coll.Collateral_Name__c
        String strIsGeneral = 'False';
        Id recordTypeIdValue = Schema.SObjectType.LTV_Master__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
        Id recordTypeIdValueException = Schema.SObjectType.LTV_Master__c.getRecordTypeInfosByName().get('Territory Exception').getRecordTypeId();
        List<Account> acc = [SELECT RecordTypeId,Account_Code__c,State__r.Account_Code__c,Region__r.Account_Code__c FROM Account Where Id=:loanApp.Branch_Master__c WITH SECURITY_ENFORCED Limit 1];
        // R2-752 - Added new fields for Commercial Customer grade
        For(LTV_Master__c  mjp:[SELECT Id,IB__c,NIB__c,Premium__c, Commercial_Captive__c, Commercial_FTB__c, Commercial_FTU__c, Commercial_Transporter_SFO__c, Commercial_Transporter_MFO__c, Commercial_Transporter_LFO__c, Commercial_Captive_With_financials__c, Commercial_Captive_Without_financials__c, Commercial_Transporter__c, Approved_CE__c,Assessment_Method__c,Territory__r.recordTypeId,Territory__r.Account_Code__c,Scheme__r.Name FROM LTV_Master__c WHERE
                                             recordTypeId=:recordTypeIdValueException AND Scheme__c=:coll.Scheme__c 
                                             AND MMV__c=:coll.MMV_Master__c
                                             AND Fuel_Type__c =:coll.Fuel_Type__c AND (Category__c=:coll.Vehicle_Category__c OR Category__c = 'NA')
                                             WITH SECURITY_ENFORCED]){
                                                strIsGeneral = 'True';
                                                 system.debug('mjp '+mjp);
                                                 if(!acc.isEmpty()){
                                                     if(getMatchAccCodeWithLoanCode(acc[0],mjp)){//
                                                         if(mjp.Id!=null){
                                                             myset.add(mjp.Id);
                                                             ltv = mjp;
                                                         }  
                                                     }
                                                 }
                                                 
                                             }
        system.debug('myset>> '+myset);
        if(myset.size()>0){
            // R2-752 - Added new fields for Commercial Customer grade
            //ltv = [Select Id,IB__c,NIB__c,Premium__c, Commercial_Captive__c, Commercial_FTB__c, Commercial_FTU__c, Commercial_Transporter__c, Approved_CE__c, Assessment_Method__c FROM LTV_Master__c WHERE Id In:myset Limit 1];//
        }else{
            // R2-752 - Added new fields for Commercial Customer grade
            List<LTV_Master__c> lstLtv = [Select Id,IB__c,NIB__c,Premium__c, Commercial_Captive__c, Commercial_FTB__c, Commercial_FTU__c, Commercial_Transporter__c,Commercial_Transporter_SFO__c, Commercial_Transporter_MFO__c, Commercial_Transporter_LFO__c, Commercial_Captive_With_financials__c, Commercial_Captive_Without_financials__c, Approved_CE__c, Assessment_Method__c,CE_Captive_With_Financial__c,CE_Captive_Without_Financial__c,CE_Contractor_Large__c,CE_Contractor_Medium__c,CE_Contractor_Small__c,CE_FTB__c,CE_FTU__c,CE_Mine_owner_Large__c,CE_Mine_owner_Medium__c,CE_Mine_owner_Small__c   FROM LTV_Master__c  WHERE Scheme__c=:coll.Scheme__c AND Fuel_Type__c =:coll.Fuel_Type__c AND (Category__c=:coll.Vehicle_Category__c OR Category__c = 'NA')
                   AND MMV__c=:coll.MMV_Master__c AND Collateral_Type__c=:coll.Collateral_Name__c AND recordTypeId=:recordTypeIdValue Limit 1 ];
            if(!lstLtv.isEmpty()){
                ltv = lstLtv[0];
            }
        }
        system.debug('myset>> '+ltv);
        if(ltv==null || ltv.Id == null){
            // R2-752 - Added new fields for Commercial Customer grade //AND Vehicle_Usage__c =:coll.Vehicle_Usage__c
            List<LTV_Master__c> lstLtv = [Select Id,IB__c,NIB__c,Premium__c, Commercial_Captive__c, Commercial_FTB__c, Commercial_FTU__c, Commercial_Transporter__c, Commercial_Transporter_SFO__c, Commercial_Transporter_MFO__c, Commercial_Transporter_LFO__c, Commercial_Captive_With_financials__c, Commercial_Captive_Without_financials__c, Approved_CE__c, Assessment_Method__c,CE_Captive_With_Financial__c,CE_Captive_Without_Financial__c,CE_Contractor_Large__c,CE_Contractor_Medium__c,CE_Contractor_Small__c,CE_FTB__c,CE_FTU__c,CE_Mine_owner_Large__c,CE_Mine_owner_Medium__c,CE_Mine_owner_Small__c   FROM LTV_Master__c WHERE Scheme__r.Scheme_Name__c='Normal' AND Fuel_Type__c =:coll.Fuel_Type__c AND (Category__c=:coll.Vehicle_Category__c OR Category__c = 'NA')
            AND MMV__c=:coll.MMV_Master__c AND Collateral_Type__c=:coll.Collateral_Name__c AND recordTypeId=:recordTypeIdValue Limit 1];
            if(!lstLtv.isEmpty()){
                ltv = lstLtv[0];
            }
        }
        return ltv;
    }
    
    public static Map<string,List<PicklistWrapper>> getMasterJunctionMapping(Set<String> schemeIds,Loan_Application__c loanApp, Map<string,List<PicklistWrapper>>  mapOfScheme){
        //Map<string,List<PicklistWrapper>>  mapOfScheme = new  Map<string,List<PicklistWrapper>>();
        //mapOfScheme.put('Scheme',new List<PicklistWrapper>());
        if(loanApp.Branch_Master__c == NULL) return mapOfScheme;

        Set<String> myset = new Set<String>();
        Account acc = [SELECT RecordTypeId,Account_Code__c,State__r.Account_Code__c,Region__r.Account_Code__c FROM Account Where Id=:loanApp.Branch_Master__c WITH SECURITY_ENFORCED Limit 1];
        Loan_Application__c loanAppObj = [Select Id, Dealer_Master__c, Dealer_Master__r.Account_Code__c,(Select Id,Make__c,Model__c FROM Collaterals__r Where Is_Deleted__c = false AND RecordTypeId IN: GlobalConstants.colRecordTypeIds Order By CreatedDate Desc) from Loan_Application__c where Id =: loanApp.Id limit 1];
        Id recordTypeIdValue = Schema.SObjectType.Master_Junction_Mapping__c.getRecordTypeInfosByName().get('Scheme').getRecordTypeId();
        For(Master_Junction_Mapping__c  mjp:[SELECT Scheme__r.Name, Scheme__r.Scheme_Name__c, Territory__r.Account_Code__c,Territory__r.recordType.Name,Dealer__r.Account_Code__c,Make_Model__r.recordType.Name,Make_Model__r.Name  FROM Master_Junction_Mapping__c WHERE
                                             recordTypeId=:recordTypeIdValue AND Scheme__c In:schemeIds WITH SECURITY_ENFORCED]){
                                                 if(getMatchAccCodeWithLoanCode(acc,mjp,loanAppObj)){
                                                     if(mjp.Scheme__r.Name!=null){
                                                         if (myset.add(mjp.Scheme__r.Name)) {
                                                             mapOfScheme.get('Scheme').add(new PicklistWrapper(mjp.Scheme__r.Scheme_Name__c,mjp.Scheme__r.Id)) ;
                                                         }
                                                     }  
                                                 }
                                                 
                                                }
        
        return mapOfScheme;
    }
    
    @AuraEnabled
    public static Depreciated_Grid__c getDepreciatedValue(Collateral__c coll,Loan_Application__c loanApp,String manufactureYear){
        String depId;
        Depreciated_Grid__c depreObj;
        List<Account> acc = new List<Account>();
        acc = [SELECT RecordTypeId,Account_Code__c,State__r.Account_Code__c,Region__r.Account_Code__c FROM Account Where Id=:loanApp.Branch_Master__c WITH SECURITY_ENFORCED Limit 1];
        String strIsGeneral = 'False';
        Id recordTypeIdValueException = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('Territory Exception').getRecordTypeId();
        Id recordTypeIdValue = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
        if(acc.size()>0){
           For(Depreciated_Grid__c  mjp:[SELECT Id,Scheme__r.Name, Territory__r.Account_Code__c,Territory__r.recordType.Name  FROM Depreciated_Grid__c WHERE
                                             recordTypeId=:recordTypeIdValueException AND (Scheme__c=:coll.Scheme__c OR Scheme__c='') AND MMV__c=:coll.MMV_Master__c WITH SECURITY_ENFORCED]){
                                                strIsGeneral = 'True'; 
                                                if(getMatchAccCodeWithLoanCode(acc[0],mjp)){
                                                     depId =  mjp.Id;
                                                 }
                                                 
                                             } 
        }
        if(depId!=null && acc.size()>0){
            depreObj = getDepreciatedQuery(manufactureYear,depId);
        }else{
            List<Depreciated_Grid__c> depList =[SELECT ID FROM Depreciated_Grid__c  WHERE (Scheme__c=:coll.Scheme__c OR Scheme__c='') AND MMV__c =:coll.MMV_Master__c AND recordTypeId=:recordTypeIdValue  WITH SECURITY_ENFORCED Limit 1 ];
            if(depList.size()>0){
                depreObj = getDepreciatedQuery(manufactureYear,depList[0].Id);
            }else{
                List<Depreciated_Grid__c> depList2 =[SELECT ID FROM Depreciated_Grid__c  WHERE (Scheme__r.Scheme_Name__c='Normal' OR Scheme__c='') AND recordTypeId=:recordTypeIdValue WITH SECURITY_ENFORCED Limit 1 ];
                if(depList2.size()>0){
                    depreObj = getDepreciatedQuery(manufactureYear,depList2[0].Id);                   
                }
                
            }
        }
        
        return depreObj;
    }
    
    public static Depreciated_Grid__c getDepreciatedQuery(String yearValue,String deprecatedId){
        system.debug('recordid '+ deprecatedId);
        String recordid = deprecatedId;
        String query ='SELECT Id, X'+yearValue+'__c from Depreciated_Grid__c Where id=:recordid WITH SECURITY_ENFORCED';
        String myQuery = String.escapeSingleQuotes(query);
        Depreciated_Grid__c dep = Database.query(myQuery);
        return dep;
    }

    public static Boolean getMatchAccCodeWithLoanCode(Account acc,Depreciated_Grid__c mjp){
        Boolean isTrue=false;
        Id stateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('State').getRecordTypeId();
        Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Id regionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        system.debug('mjp.Territory__r.recordTypeId '+mjp.Territory__r.recordTypeId);
        system.debug('stateRecordTypeId >'+stateRecordTypeId);
        system.debug('acc >'+acc);
        if(mjp.Territory__r.recordTypeId==stateRecordTypeId && acc.State__r.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==branchRecordTypeId && acc.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==regionRecordTypeId && acc.Region__r.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==dealerRecordTypeId && acc.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }
        system.debug('getMatchAccCodeWithLoanCode isTrue '+isTrue);
        return isTrue;
    }

    public static Boolean getMatchAccCodeWithLoanCode(Account acc,LTV_Master__c mjp){
        Boolean isTrue=false;
        Id stateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('State').getRecordTypeId();
        Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Id regionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        system.debug('mjp.Territory__r.recordTypeId '+mjp.Territory__r.recordTypeId);
        system.debug('stateRecordTypeId >'+stateRecordTypeId);
        system.debug('acc >'+acc);
        if(mjp.Territory__r.recordTypeId==stateRecordTypeId && acc.State__r.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==branchRecordTypeId && acc.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==regionRecordTypeId && acc.Region__r.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==dealerRecordTypeId && acc.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }
        system.debug('getMatchAccCodeWithLoanCode isTrue '+isTrue);
        return isTrue;
    }
    
    public static Boolean getMatchAccCodeWithLoanCode(Account acc,DLP_FMP_Master__c mjp){
        Boolean isTrue=false;
        Id stateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('State').getRecordTypeId();
        Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Id regionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        system.debug('mjp.Territory__r.recordTypeId '+mjp.Territory__r.recordTypeId);
        system.debug('stateRecordTypeId >'+stateRecordTypeId);
        system.debug('acc >'+acc);
        if(mjp.Territory__r.recordTypeId==stateRecordTypeId && acc.State__r.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==branchRecordTypeId && acc.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==regionRecordTypeId && acc.Region__r.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==dealerRecordTypeId && acc.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }
        system.debug('getMatchAccCodeWithLoanCode isTrue '+isTrue);
        return isTrue;
    }
    
    public static Boolean getMatchAccCodeWithLoanCode(Account acc,Master_Junction_Mapping__c mjp,Loan_Application__c loanApp){
        Boolean isTrue=false;
        Id stateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('State').getRecordTypeId();
        Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Id regionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        system.debug('mjp.Territory__r.recordTypeId '+mjp.Territory__r.recordTypeId);
        system.debug('stateRecordTypeId >'+stateRecordTypeId);
        system.debug('acc >'+acc);
        if(mjp.Territory__r.recordTypeId==stateRecordTypeId && acc.State__r.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==branchRecordTypeId && acc.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==regionRecordTypeId && acc.Region__r.Account_Code__c==mjp.Territory__r.Account_Code__c){
            isTrue = true;
        }else if(mjp.Territory__r.recordTypeId==dealerRecordTypeId && loanApp.Dealer_Master__r.Account_Code__c==mjp.Dealer__r.Account_Code__c){
            isTrue = true;
        }
        else if(mjp.Make_Model__r.recordType.Name=='Make' && loanApp.Collaterals__r != NULL && loanApp.Collaterals__r.size() > 0 && loanApp.Collaterals__r[0].Make__c==mjp.Make_Model__r.Name){
            isTrue = true;
        }else if(mjp.Make_Model__r.recordType.Name=='Model' && loanApp.Collaterals__r != NULL && loanApp.Collaterals__r.size() > 0 && loanApp.Collaterals__r[0].Model__c==mjp.Make_Model__r.Name){
            isTrue = true;
        }
        system.debug('getMatchAccCodeWithLoanCode isTrue '+isTrue);
        return isTrue;
    } 
    
    /*
@description :  Get Picklist Values of Make,Model,Vairant based on Collateral Name  
@param :  String make model, collateralName, fielName
@return : Map<string,List<PicklistWrapper>>
*/
    @AuraEnabled(cacheable=true)
    public static Depreciated_Grid__c getDepreciatedObj(Collateral__c coll,Applicant__c app) {
        List<Depreciated_Grid__c>  deprObj = new  List<Depreciated_Grid__c>();
        Id ltvRecordTypeId = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('LTV').getRecordTypeId();
        system.debug('coll '+coll);
        system.debug('app '+app);
        try{
            For (Depreciated_Grid__c obj :[SELECT Sub_Grade__c,Category__c, LTV_Approved__c
                                           FROM Depreciated_Grid__c 
                                           WHERE recordTypeId=:ltvRecordTypeId AND Customer_Grade__c=:app.Customer_Grade__c AND (Scheme__c=:coll.Scheme__c OR Scheme__c='') AND Vehicle_Usage__c =:coll.Vehicle_Usage__c  WITH SECURITY_ENFORCED])
            {
                List<String> depCategory = obj.Category__c.split(';');
                system.debug('depCategory>> '+depCategory);
                if(depCategory.contains(coll.Vehicle_Category__c)){
                    deprObj.add(obj);
                }
            }
            
            if(deprObj.size()==0){
                deprObj =[SELECT LTV_Approved__c FROM Depreciated_Grid__c WHERE recordTypeId=:ltvRecordTypeId AND Scheme__r.Scheme_Name__c='Normal' WITH SECURITY_ENFORCED];
            }
            
            
        }   
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        return deprObj[0]; 
        
    }
    
    /*
@description :  Get Picklist Values of Make,Model,Vairant based on Collateral Name  
@param :  String make model, collateralName, fielName
@return : Map<string,List<PicklistWrapper>>
*/
    @AuraEnabled(cacheable=true)
    public static Scheme_Master__c getSchemeMasterRecord(String schemeId) {
        system.debug('recordId >> '+schemeId);
        Scheme_Master__c  schemeMaster = new  Scheme_Master__c();
        //try{
        schemeMaster = [SELECT MAXROI__c,MINROI__c,MAXLOANAMOUNT__c,MINLOANAMOUNT__c,MAXTENURE__c,MINTENURE__c 
                        FROM Scheme_Master__c WHERE Id=:schemeId WITH SECURITY_ENFORCED];  
        /*}   
catch(Exception objException) {
Log.error(objException,Log.SeverityType.valueOf('High'),null);
}*/
        return schemeMaster; 
        
    }
    
    /*
@description :  Get Picklist Values of Make,Model,Vairant based on Collateral Name  
@param :  String make model, collateralName, fielName
@return : Map<string,List<PicklistWrapper>>
*/
@AuraEnabled(cacheable=true)
public static Map<string,List<PicklistWrapper>> getNewCategoryPickListValues(String coll ) {
    Collateral__c vehicle =(Collateral__c)JSON.deserialize(coll, Collateral__c.class);
    Map<string,List<PicklistWrapper>>  mapOfCategory = new  Map<string,List<PicklistWrapper>>();
    try{
        mapOfCategory.put('Category',new List<PicklistWrapper>());
        mapOfCategory.put('FuelType',new List<PicklistWrapper>());
        mapOfCategory.put('VariantId',new List<PicklistWrapper>());
        mapOfCategory.put('MaxAmount',new List<PicklistWrapper>());
        mapOfCategory.put('CollateralName',new List<PicklistWrapper>());
        mapOfCategory.put('LuxuryVehicle',new List<PicklistWrapper>());
        mapOfCategory.put('Registrable',new List<PicklistWrapper>());
        Set<String> myset = new Set<String>();//AND Scheme__c='Normal'
        Set<String> collateralSet = new Set<String>();
        system.debug('vehicle '+vehicle);
        String mmvValue = vehicle.MMV_Master__c;
        system.debug('');

        TypeOfWheeler vehicleType = getTypeOfWheeler(vehicle.Product__c);
        if(vehicleType.isTwoWheeler){
            Id variantRTId = Utility.getRecordTypeId(SObjectType.MMV_Master__c.getSobjectType(), 'Variant');
            MMV_Master__c variantMaster = [SELECT Id, Collateral_Name__c, Fuel_Type__c, (SELECT Id, Central_Variant_Id__c FROM MMV_Mapping_Masters__r WHERE RecordType.DeveloperName =: BIKE_DEKHO_MAPPING_MASTER_RT LIMIT 1) FROM MMV_Master__c WHERE Id =: mmvValue AND RecordTypeId =: variantRTId WITH SECURITY_ENFORCED ];
            mapOfCategory.get('CollateralName').add( new PicklistWrapper( getPicklistLabel( variantMaster.Collateral_Name__c ), variantMaster.Collateral_Name__c ) );
            mapOfCategory.get('FuelType').add( new PicklistWrapper( variantMaster.Fuel_Type__c?.toUpperCase(), variantMaster.Fuel_Type__c?.toUpperCase()) );

            if(!variantMaster.MMV_Mapping_Masters__r.isEmpty()){
                MMV_Mapping_Master__c bikeDekhoMMVMapping = variantMaster.MMV_Mapping_Masters__r[0];
                mapOfCategory.get('VariantId').add( new PicklistWrapper( bikeDekhoMMVMapping.Central_Variant_Id__c, bikeDekhoMMVMapping.Central_Variant_Id__c ) );
            }
            return mapOfCategory;
        }
        if(vehicleType.isTwoWheeler || vehicleType.isFourWheeler || vehicleType.isCommercialVehicle){
            Id recordTypeIdValue = Schema.SObjectType.LTV_Master__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
            Id recordTypeIdValueException = Schema.SObjectType.LTV_Master__c.getRecordTypeInfosByName().get('Territory Exception').getRecordTypeId();
            List<LTV_Master__c> ltvMasters = new List<LTV_Master__c>();
            Loan_Application__c objLoanApp = [Select Id,Branch_Master__c,Branch_Master__r.Business_HUB__c,Branch_Master__r.Region__c from Loan_Application__c where Id=:vehicle.Loan__c limit 1];
            ltvMasters = [ SELECT Category__c,Fuel_Type__c,MMV__c, MMV__r.RecordTypeId, MMV__r.Collateral_Name__c,MMV__r.Variant_Id__c,MMV__r.Maximum_Accessories_Amount__c, Luxury_Non_Luxury__c FROM LTV_Master__c WHERE MMV__c =:mmvValue AND RecordTypeId =:recordTypeIdValueException AND Territory__c =:objLoanApp.Branch_Master__c ]; 
            if(ltvMasters.isEmpty()){
                ltvMasters = [ SELECT Category__c,Fuel_Type__c,MMV__c, MMV__r.RecordTypeId, MMV__r.Collateral_Name__c,MMV__r.Variant_Id__c,MMV__r.Maximum_Accessories_Amount__c, Luxury_Non_Luxury__c FROM LTV_Master__c WHERE MMV__c =:mmvValue AND RecordTypeId =:recordTypeIdValueException AND Territory__c =:objLoanApp.Branch_Master__r.Business_HUB__c];
                if(ltvMasters.isEmpty()){
                    ltvMasters = [ SELECT Category__c,Fuel_Type__c,MMV__c, MMV__r.RecordTypeId, MMV__r.Collateral_Name__c,MMV__r.Variant_Id__c,MMV__r.Maximum_Accessories_Amount__c, Luxury_Non_Luxury__c FROM LTV_Master__c WHERE MMV__c =:mmvValue AND RecordTypeId =:recordTypeIdValueException AND Territory__c =:objLoanApp.Branch_Master__r.Region__c];
                    if(ltvMasters.isEmpty()){
                        ltvMasters = [ SELECT Category__c,Fuel_Type__c,MMV__c, MMV__r.RecordTypeId, MMV__r.Collateral_Name__c,MMV__r.Variant_Id__c,MMV__r.Maximum_Accessories_Amount__c, Luxury_Non_Luxury__c FROM LTV_Master__c WHERE MMV__c =:mmvValue AND RecordTypeId =:recordTypeIdValue];
                    }
                }
            }
            Set<Id> mmvIds = new Set<Id>();
            for(LTV_Master__c obj: ltvMasters){
                if(obj.Category__c!=null){
                    if (myset.add(obj.Category__c)) {
                        mapOfCategory.get('Category').add(new PicklistWrapper(obj.Category__c,obj.Category__c)) ;
                    }
                }
                if(obj.Fuel_Type__c !=null){
                    if (myset.add(obj.Fuel_Type__c )) {
                        mapOfCategory.get('FuelType').add(new PicklistWrapper(obj.Fuel_Type__c.toUpperCase() ,obj.Fuel_Type__c.toUpperCase() )) ;
                    }
                }
                if(String.isNotBlank(obj.Luxury_Non_Luxury__c)){
                    mapOfCategory.get('LuxuryVehicle').add(new PicklistWrapper(obj.Luxury_Non_Luxury__c ,obj.Luxury_Non_Luxury__c )) ;
                }
                system.debug('obj '+obj);
                /*
                * new logic that picks from MMV_Mapping_Master in getVariantIds
                if(obj.MMV__r.Variant_Id__c !=null){
                    if (myset.add(obj.MMV__r.Variant_Id__c )) {
                        system.debug('in 2nd if');
                        mapOfCategory.get('VariantId').add(new PicklistWrapper(obj.MMV__r.Variant_Id__c,obj.MMV__r.Variant_Id__c )) ; 
                    }
                }*/
                if(obj.MMV__r.Collateral_Name__c !=null){
                    if (collateralSet.add(obj.MMV__r.Collateral_Name__c )) {
                        mapOfCategory.get('CollateralName').add(new PicklistWrapper(getPicklistLabel(obj.MMV__r.Collateral_Name__c),obj.MMV__r.Collateral_Name__c )) ; 
                    }
                }
                if(obj.MMV__r.Maximum_Accessories_Amount__c!=null){
                    mapOfCategory.get('MaxAmount').add(new PicklistWrapper(String.ValueOf(obj.MMV__r.Maximum_Accessories_Amount__c),String.ValueOf(obj.MMV__r.Maximum_Accessories_Amount__c) )) ; 
                }
                mmvIds.add( obj.MMV__c );
                           //CE PART
                     Id variantRTId = Utility.getRecordTypeId(SObjectType.MMV_Master__c.getSobjectType(), 'Variant');
                     MMV_Master__c variantMaster = [SELECT Id, Collateral_Name__c,Registrable_Non_registrable_CE__c FROM MMV_Master__c WHERE Id =: mmvValue AND RecordTypeId =: variantRTId];
                     String strRegister='';
                     strRegister = variantMaster.Registrable_Non_registrable_CE__c == 'Registrable' ? 'Yes' : 'No';
                     mapOfCategory.get('Registrable').add(new PicklistWrapper(strRegister,strRegister)) ; 
                     //END
            }
            
            mmvIds.remove( null );
            if(!mmvIds.isEmpty()){
                PicklistWrapper variantIdOption = getVariantIds( vehicle, mmvIds );
                if(variantIdOption != NULL){
                    mapOfCategory.get('VariantId').add(variantIdOption );
                }
            }
        }   
            if(vehicleType.isTractor){
                Id recordTypeIdValue = Schema.SObjectType.DLP_FMP_Master__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
                Id recordTypeIdValueException = Schema.SObjectType.DLP_FMP_Master__c.getRecordTypeInfosByName().get('Territory Exception').getRecordTypeId();
                List<DLP_FMP_Master__c> dlpMasters = new List<DLP_FMP_Master__c>();
                Loan_Application__c objLoanApp = [Select Id,Branch_Master__c,Branch_Master__r.Business_HUB__c,Branch_Master__r.Region__c from Loan_Application__c where Id=:vehicle.Loan__c limit 1];
                dlpMasters = [ SELECT Asset_Category__c,Fuel_Type__c,MMV__c,RecordTypeId, MMV__r.RecordTypeId, MMV__r.Collateral_Name__c,MMV__r.Variant_Id__c,MMV__r.Maximum_Accessories_Amount__c FROM DLP_FMP_Master__c WHERE MMV__c =:mmvValue AND RecordTypeId =:recordTypeIdValueException AND Territory__c =:objLoanApp.Branch_Master__c];
                if(dlpMasters.isEmpty()){
                    dlpMasters = [ SELECT Asset_Category__c,Fuel_Type__c,MMV__c,RecordTypeId, MMV__r.RecordTypeId, MMV__r.Collateral_Name__c,MMV__r.Variant_Id__c,MMV__r.Maximum_Accessories_Amount__c FROM DLP_FMP_Master__c WHERE MMV__c =:mmvValue AND RecordTypeId =:recordTypeIdValueException AND Territory__c =:objLoanApp.Branch_Master__r.Business_HUB__c];
                    if(dlpMasters.isEmpty()){
                        dlpMasters = [ SELECT Asset_Category__c,Fuel_Type__c,MMV__c,RecordTypeId, MMV__r.RecordTypeId, MMV__r.Collateral_Name__c,MMV__r.Variant_Id__c,MMV__r.Maximum_Accessories_Amount__c FROM DLP_FMP_Master__c WHERE MMV__c =:mmvValue AND RecordTypeId =:recordTypeIdValueException AND Territory__c =:objLoanApp.Branch_Master__r.Region__c];
                        if(dlpMasters.isEmpty()){
                            dlpMasters = [ SELECT Asset_Category__c,Fuel_Type__c,MMV__c,RecordTypeId, MMV__r.RecordTypeId, MMV__r.Collateral_Name__c,MMV__r.Variant_Id__c,MMV__r.Maximum_Accessories_Amount__c FROM DLP_FMP_Master__c WHERE MMV__c =:mmvValue AND RecordTypeId =:recordTypeIdValue];
                        }
                    }
                }
                
                Set<Id> mmvIds = new Set<Id>();
                for(DLP_FMP_Master__c obj: dlpMasters){
                    if(obj.Asset_Category__c!=null){
                        if (myset.add(obj.Asset_Category__c)) {
                            mapOfCategory.get('Category').add(new PicklistWrapper(obj.Asset_Category__c,obj.Asset_Category__c)) ;
                        }
                    }
                    if(obj.Fuel_Type__c !=null){
                        if (myset.add(obj.Fuel_Type__c )) {
                            mapOfCategory.get('FuelType').add(new PicklistWrapper(obj.Fuel_Type__c.toUpperCase() ,obj.Fuel_Type__c.toUpperCase() )) ;
                        }
                    }
                    if(obj.MMV__r.Maximum_Accessories_Amount__c!=null){
                        mapOfCategory.get('MaxAmount').add(new PicklistWrapper(String.ValueOf(obj.MMV__r.Maximum_Accessories_Amount__c),String.ValueOf(obj.MMV__r.Maximum_Accessories_Amount__c) )) ; 
                    }
                    mmvIds.add( obj.MMV__c );
                }
                mmvIds.remove( null );
                if(!mmvIds.isEmpty()){
                    PicklistWrapper variantIdOption = getVariantIds( vehicle, mmvIds );
                    if(variantIdOption != NULL){
                        mapOfCategory.get('VariantId').add(variantIdOption );
                    }
                }
            }
        }   
    catch(Exception objException) {
        Log.error(objException,Log.SeverityType.valueOf('High'),null);
    }
    return mapOfCategory; 
    
}
    
    public static String getPicklistLabel(String product){
        String picklistLabel;
        Schema.DescribeFieldResult fieldResult = Collateral__c.Collateral_Name__c.getDescribe(); 
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues(); 
        for(Schema.PicklistEntry v : values){ 
            if(product ==v.getValue()){
                picklistLabel = v.getLabel();
            System.debug('Picklist Value Label:' + v.getLabel()); 
            System.debug('Picklist API Name:' + v.getValue()); 
            }
        }
        return picklistLabel;
    }
    
    /*
@description :  Get Picklist Values of Make,Model,Vairant based on Collateral Name  
@param :  String make model, collateralName, fielName
@return : Map<string,List<PicklistWrapper>>
*/
    @AuraEnabled(cacheable=true)
    public static Map<string,List<PicklistWrapper>> getRegistrationCityPickListValues(String rtoCode) {
        Map<string,List<PicklistWrapper>>  mapOfRtoName = new  Map<string,List<PicklistWrapper>>();
        try{
            mapOfRtoName.put('RTOName',new List<PicklistWrapper>());
            String s = rtoCode?.SubString(0,2);
            system.debug('s>>>'+s);
            if(String.isBlank(s)) return mapOfRtoName;

            Set<String> myset = new Set<String>();
            for(Generic_Master__c obj:[SELECT RTOCode__c,RTOName__c FROM Generic_Master__c WHERE RTOCode__c LIKE :(s+'%') WITH SECURITY_ENFORCED]){
                if(obj.RTOName__c!=null){
                    if (myset.add(obj.RTOName__c)) {
                        mapOfRtoName.get('RTOName').add(new PicklistWrapper(obj.RTOName__c,obj.RTOName__c)) ;
                    }
                    if(obj.RTOCode__c!=null){
                        if(mapOfRtoName.containsKey(obj.RTOName__c)){
                            mapOfRtoName.get(obj.RTOName__c).add(new PicklistWrapper(obj.RTOCode__c,obj.RTOCode__c)) ;
                        }else{
                            List<PicklistWrapper> listOfCodes = new List<PicklistWrapper>();
                            listOfCodes.add(new PicklistWrapper(obj.RTOCode__c,obj.RTOCode__c));
                            mapOfRtoName.put(obj.RTOName__c,listOfCodes);
                        }
                    }
                }
            }  
        }   
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        return mapOfRtoName; 
        
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Map<string,List<PicklistWrapper>> getUsedCategoryPickListValuesR2(String variant, String loanId) {
        strLoanIdForCategory = loanId;
        Map<string,List<PicklistWrapper>> mapOfCategory = new  Map<string,List<PicklistWrapper>>();
        mapOfCategory = getUsedCategoryPickListValues(variant);
        return mapOfCategory; 
    }
    
    /*
@description :  Get Picklist Values of Make,Model,Vairant based on Collateral Name  
@param :  String make model, collateralName, fielName
@return : Map<string,List<PicklistWrapper>>
*/
    @AuraEnabled(cacheable=true)
    public static Map<string,List<PicklistWrapper>> getUsedCategoryPickListValues(String variant) {
        Map<string,List<PicklistWrapper>>  mapOfCategory = new  Map<string,List<PicklistWrapper>>();
        try{
            mapOfCategory.put('Category',new List<PicklistWrapper>());
            mapOfCategory.put('FuelType',new List<PicklistWrapper>());
            mapOfCategory.put('CollateralName',new List<PicklistWrapper>());
            mapOfCategory.put('LuxuryVehicle',new List<PicklistWrapper>());
            //Id recordTypeIdValue = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
            //AND Scheme__r.Scheme_Name__c=:schemeName
            String schemeName ='Normal';
            Set<String> myset = new Set<String>();//AND Scheme__c='Normal'
            Set<String> collateralSet = new Set<String>();
            //String query = 'SELECT Category__c,Fuel_Type__c,MMV__r.Collateral_Name__c, Luxury_Non_Luxury__c FROM Depreciated_Grid__c WHERE MMV__c =:variant AND recordTypeid=:recordTypeIdValue  WITH SECURITY_ENFORCED';
            //String actualQuery = String.escapeSingleQuotes(query);
            
            //Added Fix for Territory - Mayur
            Id recordTypeIdValue = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
            Id recordTypeIdValueException = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('Territory Exception').getRecordTypeId();
            List<Depreciated_Grid__c> depMaster = new List<Depreciated_Grid__c>();
            Loan_Application__c objLoanApp = [Select Id,Branch_Master__c,Branch_Master__r.Business_HUB__c,Branch_Master__r.Region__c from Loan_Application__c where Id=:strLoanIdForCategory limit 1];
            depMaster = [ SELECT Category__c,Fuel_Type__c,MMV__r.Collateral_Name__c, Luxury_Non_Luxury__c FROM Depreciated_Grid__c WHERE MMV__c =:variant AND RecordTypeId =:recordTypeIdValueException AND Territory__c =:objLoanApp.Branch_Master__c];
            if(depMaster.isEmpty()){
                depMaster = [ SELECT Category__c,Fuel_Type__c,MMV__r.Collateral_Name__c, Luxury_Non_Luxury__c FROM Depreciated_Grid__c WHERE MMV__c =:variant AND RecordTypeId =:recordTypeIdValueException AND Territory__c =:objLoanApp.Branch_Master__r.Business_HUB__c];
                if(depMaster.isEmpty()){
                    depMaster = [ SELECT Category__c,Fuel_Type__c,MMV__r.Collateral_Name__c, Luxury_Non_Luxury__c FROM Depreciated_Grid__c WHERE MMV__c =:variant AND RecordTypeId =:recordTypeIdValueException AND Territory__c =:objLoanApp.Branch_Master__r.Region__c];
                    if(depMaster.isEmpty()){
                        depMaster = [ SELECT Category__c,Fuel_Type__c,MMV__r.Collateral_Name__c, Luxury_Non_Luxury__c FROM Depreciated_Grid__c WHERE MMV__c =:variant AND RecordTypeId =:recordTypeIdValue];
                    }
                }
            }
            
            //for(Depreciated_Grid__c obj:Database.query(actualQuery)){
            for(Depreciated_Grid__c obj:depMaster){
                if(obj.Category__c!=null){
                    if (myset.add(obj.Category__c)) {
                        mapOfCategory.get('Category').add(new PicklistWrapper(obj.Category__c,obj.Category__c)) ;
                    }
                }
                if(obj.Fuel_Type__c !=null){
                    if (myset.add(obj.Fuel_Type__c )) {
                        mapOfCategory.get('FuelType').add(new PicklistWrapper(obj.Fuel_Type__c.toUpperCase() ,obj.Fuel_Type__c.toUpperCase() )) ;
                    }
                }
                if(obj.MMV__r.Collateral_Name__c !=null){
                    if (collateralSet.add(obj.MMV__r.Collateral_Name__c )) {
                        mapOfCategory.get('CollateralName').add(new PicklistWrapper(getPicklistLabel(obj.MMV__r.Collateral_Name__c) ,obj.MMV__r.Collateral_Name__c)) ;
                    }
                }
                if(String.isNotBlank(obj.Luxury_Non_Luxury__c)){
                    mapOfCategory.get('LuxuryVehicle').add(new PicklistWrapper(obj.Luxury_Non_Luxury__c, obj.Luxury_Non_Luxury__c));
                }
            }  
        }   
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        return mapOfCategory; 
        
    }
    
    
    @AuraEnabled
    public static Collateral__c createCollateral(String loanId,String collateralType){
        Id newRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        Id usedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        Id existingColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Existing Collateral').getRecordTypeId();
        List<Collateral__c> listOfCollaterals = new List<Collateral__c>();
        listOfCollaterals = [SELECT Id,Name FROM Collateral__c WHERE Loan__c=:loanId AND (recordTypeId=:newRecordTypeId OR recordTypeId=:usedRecordTypeId) AND Is_Deleted__c=false];
        if(listOfCollaterals.size()==0){
            Collateral__c coll = new Collateral__c();
            coll.Loan__c = loanId;
            coll.Engine_Category__c = GlobalConstants.DEFAULT_COLLATERAL_ENGINE_CATEGORY;
            coll.Assessment_Method__c = GlobalConstants.DEFAULT_COLLATERAL_METHOD_OF_ASSESSMENT;
            if(collateralType =='New'){
                coll.recordTypeId=newRecordTypeId;
                coll.Collateral_Type__c = 'New';
            }else if(collateralType =='Used'){
                coll.recordTypeId=usedRecordTypeId;
                coll.Collateral_Type__c = 'New';
            }else if(collateralType =='Existing'){
                coll.recordTypeId=existingColRecordTypeId;
            }
            listOfCollaterals.add(coll);
            insert listOfCollaterals;
            
        }
        // SFAU-5715 - Add IBB_API_Value__c
        Collateral__c collateral = [ SELECT Id,Name, Product__c, Loan__r.Product__c, Loan__r.Loan_Amount__c, Loan__r.Vehicle_use__c, Loan__r.Original_Vehicle_Usage__c, Original_Vehicle_Usage__c, Loan__r.Collateral_Type__c, IBB_API_Value__c FROM Collateral__c WHERE Id=:listOfCollaterals[0].Id ];
        collateral.Collateral_ID__c = collateral.Loan__r.Product__c + collateral.Name + Integer.valueof((Math.random() * 10));
        collateral.Vehicle_Usage__c = collateral.Loan__r.Vehicle_use__c;

        // R2-751 - Populate Collateral Type if already populated on 1st Screen
        if( String.isNotBlank(collateral.Loan__r.Collateral_Type__c) ){
            collateral.Collateral_Name__c =  collateral.Loan__r.Collateral_Type__c;
        }
        //SFAU-5163
        //START - SFAU-5163
        if (String.isBlank(collateral.Original_Vehicle_Usage__c)) {
            collateral.Original_Vehicle_Usage__c = String.isNotBlank(collateral.Loan__r.Original_Vehicle_Usage__c) ? collateral.Loan__r.Original_Vehicle_Usage__c : collateral.Vehicle_Usage__c;
        }
        else if (String.isNotBlank(collateral.Original_Vehicle_Usage__c) && String.isNotBlank(collateral.Loan__r.Original_Vehicle_Usage__c) && collateral.Original_Vehicle_Usage__c != collateral.Loan__r.Original_Vehicle_Usage__c) {
            collateral.Original_Vehicle_Usage__c = collateral.Loan__r.Original_Vehicle_Usage__c;
        }
        //END - SFAU-5163
        collateral.Apportioned_Loan_Amount__c = collateral.Loan__r.Loan_Amount__c;
        update collateral;

        return collateral;
    }
    
    @AuraEnabled 
    public static void deleteCollateralRecord(String collateralId){
        List<Collateral__c> coll =[Select Id from Collateral__c where Id=:collateralId];
        if(coll.size()>0){
            Delete coll;
        }
    }
    
    @AuraEnabled 
    public static void deleteExistingCollateral(List<String> collateralId){
        List<Collateral__c> coll =[Select Id from Collateral__c where Collateral_ID__c=:collateralId];
        if(coll.size()>0){
            Delete coll;
        }
    }
    
    @AuraEnabled
    public static map<String, Object>  upsertCollateral(Collateral__c  collateral,String screen,List<CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper> cbsCollateralList, map<String, Object> additionalParams){
        system.debug('colla >> '+collateral);
        collateral.Collateral_From_Lead_Api__c = false;
        List<Collateral__c> listOfCollaterals = new List<Collateral__c>();
        Id newRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        Id usedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        Id existingColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Existing Collateral').getRecordTypeId();
        // SFAU-5715 - Add IBB_API_Value__c
        Collateral__c oldCollateral = collateral.Id != null ? [ SELECT LS_Value__c, LS__c, Insurance_Value__c, Insurance_Funding__c, Insurance_Expiry_Date__c, Vehicle_Category__c, Vehicle_Usage__c, Collateral_Name__c, MMV_Master__c, Scheme__c, Fuel_Type__c, Vehicle_Delivery__c, Collateral_From_Lead_Api__c, IBB_API_Value__c FROM Collateral__c WHERE Id =: collateral.Id ] : null;
        // Start - SFAU-5608
        if (oldCollateral != NULL) {
            oldCollateral.Collateral_From_Lead_Api__c = false;
        }
        // End - SFAU-5608
        // SFAU-4471
        validateIfChargeAmountExceedsFunding( collateral.Loan__c, collateral, oldCollateral, screen );

        List<Collateral__c> upsertCollateralList = new List<Collateral__c>();
        map<String, Boolean> wasCollateralUpdated = new map<String, Boolean>();
        Loan_Application__c loanApp = [SELECT Id, Stage__c, Loan_Amount__c, RecordType.Name, Product__c, Customer_Grade__c, Sub_Grade__c, Branch_Master__c, Base_Credit_Verification__c FROM Loan_Application__c WHERE Id=:collateral.loan__c];

        // if(!Utility.canCreditUserEdit(loanApp, UserInfo.getUserId())){
        //     throw new Utility.ActionNotAllowedException(Label.Edit_Not_Allowed_Error);
        // }
        
        Collateral__c  appObj = new Collateral__c ();
        Loan_Application__c  loanObj = new Loan_Application__c ();
        loanObj.id=collateral.loan__c;

        // Should only be executed for 2W Used else it will deduct some cents from the loan amount :P
        if( loanApp.RecordType.Name == GlobalConstants.TWOWHEELER && screen == System.label.AUSFUsedScreen ){
                        loanObj.Total_Loan_Amount__c = collateral.LTV_offered_On_final_cost__c != null && collateral.LTV_offered_On_final_cost__c != 0 && collateral.Final_Cost__c != null ? ( collateral.Final_Cost__c * ( collateral.LTV_offered_On_final_cost__c / 100 ) ) : collateral.Final_Cost__c;
            loanObj.Loan_Amount__c = (loanObj.Total_Loan_Amount__c != null ? loanObj.Total_Loan_Amount__c : 0 ) -  (collateral.Other_Funding_Total__c != null ? collateral.Other_Funding_Total__c : 0);
        }
        else if( loanApp.RecordType.Name == GlobalConstants.TRACTOR && screen == System.label.AUSFNewScreen ){
            loanObj.Total_Loan_Amount__c = collateral.Apportioned_Loan_Amount__c;
            loanObj.Loan_Amount__c = (loanObj.Total_Loan_Amount__c != null ? loanObj.Total_Loan_Amount__c : 0 ) -  (collateral.Other_Funding_Total__c != null ? collateral.Other_Funding_Total__c : 0);
        }
        else {
            loanObj.Total_Loan_Amount__c=loanApp.Loan_Amount__c + (collateral.Other_Funding_Total__c != null ? collateral.Other_Funding_Total__c : 0);
        }

        //SFAU-4473 start
        ProductRTMap__mdt productRT = ProductRTMap__mdt.getInstance('A_'+loanApp.Product__c);
        Boolean triggerMotorInsDeviationCall=false;
        List<Loan_Application_Approval__c> sobjectsToUpdate = new List<Loan_Application_Approval__c>();
        List<Id> loanIdListTemp = new List<Id>();
        String COWProducts = System.Label.COW_Product_Names;//R2-1693,1691
        if(productRT.Sub_Product__c == 'Used' || COWProducts.toUpperCase().contains(productRT.Sub_Product__c.toUpperCase())){
            //productRT.Sub_Product__c == 'Cash on Wheels'){
            if(collateral.Insurance_Expiry_Date__c!=null && (oldCollateral == null || oldCollateral.Insurance_Expiry_Date__c!=collateral.Insurance_Expiry_Date__c) ){
                if(loanApp.Stage__c=='PSD'){     
                    loanObj.Is_Charge_Changed__c = true;
                }else if(loanApp.Stage__c=='Credit' || loanApp.Stage__c=='DDE'){
                    List<Loan_Application_Approval__c> pricingApprovals = [SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c= :loanObj.Id AND Approval_Type__c=:GlobalConstants.APPROVAL_TYPE_PRICING AND Archived__c=false];
                    if(pricingApprovals!=null && pricingApprovals.size()>0){
                        for(Loan_Application_Approval__c pricingApproval: pricingApprovals){
                            pricingApproval.Archived__c=true;
                            sobjectsToUpdate.add(pricingApproval);
                        }
                    }
                    loanObj.No_Pricing_Deviation__c=false;
                    loanIdListTemp.add(loanObj.Id);
                    system.debug('loanIdListTemp '+loanIdListTemp);
                    triggerMotorInsDeviationCall=true;
                }
                
            }
        }
        //SFAU-4473 end
        
        if(productRT.RecordType__c == 'Tractor'){
            loanObj.Collateral_Type__c =collateral.Collateral_Name__c;
        }

        if( collateral.Scheme__c != null ){
            loanObj.Scheme__c = collateral.Scheme__c;
        }

        if(additionalParams != null && ( Label.Commercial_Body_Funding_Collateral_Codes.contains( collateral.Collateral_Name__c ) ||Label.Tractor_Implement_Collateral_Codes.contains( collateral.Collateral_Name__c ) ) ){
            loanObj.Parent_Loan__c = (Id)additionalParams.get('parentLoanId');
            collateral.Parent_Collateral__c = (Id)additionalParams.get('parentCollateralId');
        }

        if(loanApp.RecordType.Name=='Tractor' && productRT.Sub_Product__c=='New' && loanApp.Base_Credit_Verification__c!=null ){
            Map<String, Boolean> baseCreditVerification = (Map<String, Boolean>) JSON.deserialize(loanApp.Base_Credit_Verification__c, Map<String, Boolean>.class);
            if(oldCollateral.Vehicle_Delivery__c!='Yes' && collateral.Vehicle_Delivery__c=='Yes'){
                baseCreditVerification.put('TAR',false);
                loanObj.Base_Credit_Verification__c = JSON.serialize(baseCreditVerification);
            }else if(oldCollateral.Vehicle_Delivery__c!='No' && collateral.Vehicle_Delivery__c=='No'){
                baseCreditVerification.put('TAR',true);
                loanObj.Base_Credit_Verification__c = JSON.serialize(baseCreditVerification);
            }
            
        }
        update loanObj;
        
        //SFAU-4473 start
        if(sobjectsToUpdate!=null && sobjectsToUpdate.size()>0){
            // CUG -- #15098 If the records were in approval process they will be locked
            AUSFLoanApplication_WithoutSharing.unlockApprovals( sobjectsToUpdate );
            update sobjectsToUpdate;
        }
        //SFAU-4473 end

        // validates fields that were edited & updates BREReRun on Loan Application
        validateMaterialFields(screen, collateral,loanApp.RecordType.Name,loanApp.Product__c);

        collateral = getApprovedLTV( loanApp, oldCollateral, collateral, screen );
    
        collateral.Is_Collateral_Updated_Post_Creation__c = true; //If the collateral was updated after it got created
        collateral.Variance__c = collateral.Ex_Showroom_Price__c != NULL && collateral.Ex_Showroom_Price_API__c != NULL ? Utility.calculatePercentageDiff(collateral.Ex_Showroom_Price_API__c, collateral.Ex_Showroom_Price__c) : null;
        collateral.Engine_Category__c = String.isNotBlank(collateral.Engine_Category__c) ? collateral.Engine_Category__c : GlobalConstants.DEFAULT_COLLATERAL_ENGINE_CATEGORY;
        collateral.Assessment_Method__c = String.isNotBlank(collateral.Assessment_Method__c) ? collateral.Assessment_Method__c : GlobalConstants.DEFAULT_COLLATERAL_METHOD_OF_ASSESSMENT;

        appObj = collateral;
        
        if(screen!=null && screen==System.label.AUSFNewScreen){
            appObj.RecordTypeId = newRecordTypeId;
            
        }
        
        if(screen!=null && screen==System.label.AUSFUsedScreen){
            appObj.RecordTypeId =usedRecordTypeId;
        }
        //Collateral__c exCol ;
        for(CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper col :cbsCollateralList){
            Collateral__c exCol = new Collateral__c();
            exCol.Collateral_ID__c =col.strCollateralId;
            exCol.Loan__c =collateral.loan__c;
            exCol.RecordTypeId =existingColRecordTypeId;
            exCol.Linkage_Type__c  = col.strCollateralType;
            exCol.Product_Name_Code__c = col.strProductNameCode;
            exCol.Collateral_Value__c= String.valueof(col.strTotalCollateralValue);
            exCol.POS__c=String.valueof(col.strCollateralUnusedValue);
            exCol.Total_Utilized_Value__c=String.valueof(col.strAmountCollValueCollCcy);
            exCol.Apportioned_Loan_Amount__c=col.strApportionedAmount;
            exCol.Occupancy_Type__c =col.strPropertyType;
            exCol.Current_Owner_Name__c = col.strPropertyOwnerName;
            exCol.Relationship__c= col.strAccountCustomerRelation;
            exCol.Linked_Account_Number__c = col.strAccountNumber;
            exCol.House_No_Plot_No__c  =col.strKhasaraPlotNo;
            exCol.Manual_Make__c =col.strMake;
            exCol.Manual_Model__c=col.strModel;
            exCol.Manufacture_year_month__c=col.strManufactureYear;
            exCol.Chasis_Number__c =col.strChassisNumber;
            exCol.Engine_Number__c=col.strEngineNumber;
            exCol.Vehicle_Number__c=col.strRegistrationNumber;
            //exCol. =col.strPropertyDesc1
            exCol.Taluka__c =col.strTehsilTaluka;
            exCol.Address_Line_1__c=col.strAddress;
            exCol.Valuation_date__c=col.strLastValuationDate;
            exCol.Valuation_Amount__c=String.valueof(col.strLastValue);
            //exCol.=col.strAreaUnit 
            //exCol.Total_Pos__c=col.strTotalPos;
            exCol.Land_Area__c=String.valueof(col.strTotalArea);
            exCol.Cost__c=col.strCostPrice;
            exCol.Village__c=col.strVillage;
            exCol.Collateral_Type__c =col.strCollateralName;
           // exCol.Is_Deleted__c = !col.isSelected;
            exCol.Type_Of_Existing_Collateral__c = 'CBS';
            exCol.Collateral_From_Lead_Api__c = false;
            upsertCollateralList.add(exCol);
        }
        
        //appObj.Collateral_ID__c = getCollateralId(collateral.Product__c);
        // R2-2517
        appObj.Loan_Eligibilty__c = appObj.Loan_Eligibilty__c == null ? null : String.valueOf(appObj.Loan_Eligibilty__c);
        upsertCollateralList.add(appObj);
        try{
            system.debug('vehicle data is >'+appObj);
            system.debug('vehicle data is >'+appObj.loan__c);
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, upsertCollateralList);
            System.debug('securityDecision '+securityDecision.getRemovedFields());
            //upsert securityDecision.getRecords();
            //upsert appObj;
            Set<Id> collateralIds = new Set<Id>();
            List<Database.upsertResult> uResults = Database.upsert(securityDecision.getRecords(),false);
            system.debug('uResults >> '+uResults);
            // SFAU-5715 - Add IBB_API_Value__c
            listOfCollaterals =[
                SELECT Id, Name, Collateral_ID__c, LTV_offered__c,Collateral_Id_in_CBS__c, Loan__r.Total_Loan_Amount__c, // SFAU-4476 -- 1st Aug 23 - Added column Loan__r.Total_Loan_Amount__c
                Approved_LTV__c, MMV_Master__c, Certified_Value__c, MMV_Master__r.Name, Variance__c,
                Vehicle_Number__c, Collateral_Type__c, toLabel(Loan__r.Product__c), toLabel(Collateral_Name__c),
                Variant__c, Apportioned_Loan_Amount__c, Final_Cost__c, LTV_offered_On_final_cost__c,
                LTV_offered_Ex_showroom__c, CustomerId__c, Linked_Account_Number__c, BT_Loan_Status__c, Loan__c,
                CreatedDate, SystemModStamp, POS__c, Is_Collateral_Updated_Post_Creation__c, Collateral_From_Lead_Api__c, IBB_API_Value__c 
                FROM Collateral__c
                WHERE loan__c =:collateral.Loan__c AND Is_Deleted__c=false AND
                recordTypeId!=:existingColRecordTypeId
                ORDER BY CreatedDate DESC
            ];
            //listOfCollaterals =[Select Collateral_ID__c,MMV_Master__c,MMV_Master__r.Name,Variance__c,Vehicle_Number__c,Collateral_Type__c,toLabel(Loan__r.Product__c),toLabel(Collateral_Name__c),Variant__c,Apportioned_Loan_Amount__c,Final_Cost__c FROM Collateral__c WHERE loan__c =:collateral.Loan__c AND recordTypeId!=:existingColRecordTypeId AND Is_Deleted__c=false];
            if(listOfCollaterals.size()>0 && listOfCollaterals[0].Variance__c!=null){
                if(listOfCollaterals[0].Variance__c > 5){
                    Deviation__c  dev = new Deviation__c();
                    dev.Loan_Application__c = collateral.Loan__c; 
                    dev.Actual_Value__c = collateral.Ex_Showroom_Price_API__c;
                    dev.Policy_Value__c = collateral.Ex_Showroom_Price__c;
                    dev.Details__c = Label.VehiclePricingDeviation;
                    dev.Deviation_Type__c = VEHICLE_VARIANCE_DEVIATION_TYPE;
                    dev.Source__c = 'SF';
                    insert dev;
                } 
            }
            /* Commented As part of SFAU-5665
            if( screen == System.label.AUSFUsedScreen ){
                Collateral__c[] collaterals = new Collateral__c[0];
                for(Collateral__c collateralRecord: listOfCollaterals){
                    if(collateralRecord.Collateral_ID__c == collateralRecord.Collateral_ID_in_CBS__c){
                        collaterals.add(
                            new Collateral__c(
                                Id = collateralRecord.Id,
                                Collateral_ID__c = generateCollateralId( loanApp.Product__c, collateralRecord.Name )
                            )
                        );
                    }
                    wasCollateralUpdated.put( collateralRecord.Id, collateralRecord.SystemModStamp != collateralRecord.CreatedDate );
                }
                upsert collaterals;
            }
            */
            /* START SFAU-5665 - POS Update - Collateral Linkage */
            if( screen == System.label.AUSFUsedScreen ){
                Map<String,Collateral__c> mapCollIdWithCollateral = new Map<String,Collateral__c>();
                Map<String,Collateral__c> mapLinkAccountWithColleral = new Map<String,Collateral__c>();
                Id objCollLoanId = NULL;
                for(Collateral__c collateralRecord: listOfCollaterals){
                    if(collateralRecord.Collateral_ID__c == collateralRecord.Collateral_ID_in_CBS__c || Test.isRunningTest()){
                        objCollLoanId = collateralRecord.Loan__c;
                        Collateral__c objNewCollateral = new Collateral__c();
                        objNewCollateral.Id = collateralRecord.Id;
                        objNewCollateral.POS__c = String.isBlank(collateralRecord.POS__c) ? '0' : collateralRecord.POS__c;
                        objNewCollateral.Collateral_ID__c = generateCollateralId( loanApp.Product__c, collateralRecord.Name );
                        objNewCollateral.Collateral_From_Lead_Api__c = false;
                        if (!String.isEmpty(collateralRecord.Linked_Account_Number__c)) {
                            mapLinkAccountWithColleral.put(collateralRecord.Linked_Account_Number__c,objNewCollateral);
                        }
                        mapCollIdWithCollateral.put(objNewCollateral.Collateral_ID__c,objNewCollateral);
                    }
                    wasCollateralUpdated.put( collateralRecord.Id, collateralRecord.SystemModStamp != collateralRecord.CreatedDate );
                }
                if (mapLinkAccountWithColleral.size() > 0) {
                    Map<String,Decimal> mapCollateralWithPos = new Map<String,Decimal>();
                    List<Bank_Account_Records__c> lstBAR = [Select Id, Account_Number__c, POS__c from Bank_Account_Records__c where RecordType.DeveloperName = 'CBS' and Account_Number__c in: mapLinkAccountWithColleral.keySet() AND Account_Type__c = 'Loan' AND Applicant__r.Loan__c =: objCollLoanId AND Applicant__r.RecordType.DeveloperName = 'Primary_Applicant' AND Applicant__r.IsInactive__c = false];
                    for (Bank_Account_Records__c objBank : lstBAR) {
                        Collateral__c objNewCollateral = mapLinkAccountWithColleral.get(objBank.Account_Number__c);
                        objNewCollateral.POS__c = objBank.POS__c != NULL ? String.valueOf(objBank.POS__c) : '0';
                        mapCollIdWithCollateral.put(objNewCollateral.Collateral_ID__c,objNewCollateral);
                    }    
                }
                upsert mapCollIdWithCollateral.values();
            }
            /* END SFAU-5665 - POS Update - Collateral Linkage */
        } catch(DmlException objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        if(triggerMotorInsDeviationCall){
            Map<Id, Loan_Application__c> loanApplications = new Map<Id, Loan_Application__c>([SELECT Id, Branch_Master__r.Region__c, Branch_Master__r.National__c FROM Loan_Application__c WHERE Id IN :loanIdListTemp]);
            LosPricingApproval.insertApprovalsForMotorInsurance(LosPricingApproval.createMotorInsuranceDeviations(loanIdListTemp), loanApplications, true);    
        }
        return new map<String, Object>{
            'collaterals' => listOfCollaterals,
            'wasCollateralUpdated' => wasCollateralUpdated
        };
    }
    
    public static String generateCollateralId( String collateralId, String productNumber ){
        return productNumber + collateralId + Integer.valueof((Math.random() * 10));
    }

    public static CollateralData getCollateralNames(String productCode){
        CollateralData colData= new CollateralData();
        map<string,List<PicklistWrapper>> collateralNames = new map<string,List<PicklistWrapper>>();
        Map<String,String> mapOfCollateralNameVsId = new Map<String,String>();
        Set<String> myset = new Set<String>();
        collateralNames.put('Collateral_Name__c',new List<PicklistWrapper>());
        List<Product_vs_Collateral_Master__mdt > productVsCollIds = new List<Product_vs_Collateral_Master__mdt >(); //Product_vs_Collateral_Master__mdt.getAll().values();
        for(Product_vs_Collateral_Master__mdt obj: [SELECT Id, Collateral_Code__c, Collateral_Name__c, Max_Amount__c, Order__c, Product_Code__c, 
            Product_Name__c FROM Product_vs_Collateral_Master__mdt WHERE Product_Code__c = :productCode ORDER BY Order__c]){
            //if(obj.Product_Code__c == productCode){
                system.debug('in if Product_Code__c'+obj.Product_Code__c);
                system.debug('in if Collateral_Name__c '+obj.Collateral_Name__c);
                system.debug('myset '+myset);
                if(myset.add(obj.Collateral_Name__c)){
                    system.debug('in 2nd if');
                    collateralNames.get('Collateral_Name__c').add(new PicklistWrapper(obj.Collateral_Name__c,obj.Collateral_Code__c)) ;
                    if(obj.Max_Amount__c!=null){
                        mapOfCollateralNameVsId.put(obj.Collateral_Code__c,obj.Max_Amount__c);
                    }
                }
            //}
        }
        colData.collateralNames = collateralNames;
        colData.mapOfCollateralNameVsId = mapOfCollateralNameVsId;
        return colData;
    }
    
    
    @AuraEnabled
    public static void handleUpdateValuation(String referenceNo, String actionName,Decimal valuationAmount){
        try {
            Valuation__c valuationObj = [SELECT Id,Reference_ID__c,Action__c,Valuation_Identifier__c
                                         FROM Valuation__c
                                         WHERE Reference_ID__c=:referenceNo];
            if(String.isNotBlank(actionName)){
                valuationObj.Action__c = actionName;
            }                                                
            
            if(valuationAmount!=0){
                valuationObj.Valuation_Amount__c  = valuationAmount;
                valuationObj.Valuation_Identifier__c = 'Manual';
            }
            if(Schema.sObjectType.Valuation__c.isUpdateable()){
                update valuationObj;
                System.debug('valuationObjUpdation-->' +valuationObj);
            }
            
            
        } catch (Exception e) {
            System.debug('exception--->' +e.getMessage() +'---' +e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    public static List<Applicant__c> getApplicant(String loanApplicationId){
        try {
            List<Applicant__c> applicantList = [SELECT id,First_Name__c,Middle_Name__c,Last_Name__c,Mobile_Number__c,Email__c,Loan__c,RecordType.Name
                                                FROM Applicant__c
                                                WHERE Loan__c=:loanApplicationId
                                                AND RecordType.Name='Applicant' 
                                                WITH SECURITY_ENFORCED];
            if(!applicantList.isEmpty()){
                return applicantList;
            }else{
                return null;
            }
            
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    
    public static List<Address__c> getCurrentAddressDetails(String applicantId){
        try{
            List<Address__c> addressList =[SELECT id,Name,Distance_from_Branch__c,District__c,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c
                                           FROM Address__c
                                           WHERE Applicant__c=:applicantId 
                                           AND Address_Type__c != null
                                           AND Address_Type__c ='Current'
                                           AND Source_Type__c != 'Cibil'  WITH SECURITY_ENFORCED];
            
            if(!addressList.isEmpty()){
                return addressList;
            }else{
                return null;
            }
            
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    
    /*public static Integer getVehicalCategory(String productName){
        
        List<ProductRTMap__mdt> productData = [SELECT MasterLabel,RecordType__c 
                                               FROM ProductRTMap__mdt
                                               WHERE  MasterLabel=:productName];
        Integer productCode=0;
        
        if(!productData.isEmpty()){
            String CommercialVehicle ='CV';
            if(productData[0].RecordType__c =='Two Wheeler'){
                productCode=1;
            }
            else if(productData[0].RecordType__c =='Three Wheeler'){
                productCode=2;
            }
            else if(productData[0].RecordType__c =='Four Wheeler'){
                productCode=3;
            }
            else if(productData[0].RecordType__c =='CV'){
                productCode=4;
            }
            else if(productData[0].RecordType__c =='FE'){
                productCode=5;
            }
            else if(productData[0].RecordType__c =='CE'){
                productCode=6;
            }
        }
        
        return productCode;
    }*/
    
    
    @AuraEnabled
    public static List<Generic_Master__c>  getValueMasterDetails(Id loanId){
        try {
            List<Generic_Master__c> valueMasterList = new List<Generic_Master__c>();
            List<Loan_Application__c> loanApplication = [SELECT id,Branch_Master__r.State__r.Name
                                                         FROM Loan_Application__c
                                                         WHERE id=:loanId  WITH SECURITY_ENFORCED];
            
            String state = (loanApplication[0].Branch_Master__r.State__c !=null) ? loanApplication[0].Branch_Master__r.State__r.Name  : '';
            
            System.debug('state-->' +state);
            if(String.isNotBlank(state)){
                valueMasterList = [SELECT id,Agency_Name__c,State__c,Phone_No__c
                                   FROM Generic_Master__c
                                   WHERE State__c=:state];
                
            }
            return valueMasterList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getLoanSchemeMasterDetails(Id loanId){
        String schemeName='';
        try {
            List<Loan_Application__c> loanApplication = [SELECT id,Scheme__r.Scheme_Name__c
                                                         FROM Loan_Application__c
                                                         WHERE id=:loanId  WITH SECURITY_ENFORCED];
            if(String.isNotBlank(loanApplication[0].Scheme__r.Scheme_Name__c)){
                schemeName = loanApplication[0].Scheme__r.Scheme_Name__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return schemeName;
    }
    
    @AuraEnabled
    public static Collateral__c getCollateralDetails( Id collateralId){
        Collateral__c collateralInstance;
        try {
            // SFAU-5715 - Add IBB_API_Value__c
            collateralInstance = [SELECT Id, Vehicle_Number__c,Make__c,Model__c,Engine_Number__c,Chasis_Number__c,Manufacture_Year__c,Owner_Serial_number__c,Vehicle_Color__c,Fuel_Type__c,Valuation_Amount__c, BT_Loan_Status__c, IBB_API_Value__c 
                                  FROM Collateral__c
                                  WHERE id=:collateralId  WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return collateralInstance;
    }

    public static PicklistWrapper getVariantIds( Collateral__c vehicle, Set<Id> mmvIds ){
        String loanApplicationType = vehicle.Product__c, productBasedRT;
        
        if(mmvIds.isEmpty() || String.isBlank(loanApplicationType) ) return null;

        TypeOfWheeler vehicleType = getTypeOfWheeler( loanApplicationType );
        if( vehicleType.isTwoWheeler ){
            productBasedRT = BIKE_DEKHO_MAPPING_MASTER_RT;
        } else if( vehicleType.isFourWheeler || vehicleType.isCommercialVehicle ){
            productBasedRT = CAR_DEKHO_MAPPING_MASTER_RT;
        }
        MMV_Mapping_Master__c[] mmvMappingMasters = [ SELECT Id, Central_Variant_Id__c FROM MMV_Mapping_Master__c WHERE MMV__c IN: mmvIds AND Central_Variant_Id__c != NULL AND RecordType.DeveloperName =: productBasedRT LIMIT 1 ];
        if( !mmvMappingMasters.isEmpty() ){
            return new PicklistWrapper( mmvMappingMasters[0].Central_Variant_Id__c, mmvMappingMasters[0].Central_Variant_Id__c );
        }
        return null;
    }

    @AuraEnabled
    public static Object getPriceDetailsViaApiCall(Id loanApplicationId, String variantId, String cityId){
        String loanApplicationType = [ SELECT Id, Product__c FROM Loan_Application__c WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED ].Product__c;
        if(String.isBlank( loanApplicationType )) return null;

        TypeOfWheeler vehicleType = getTypeOfWheeler( loanApplicationType );
        if( vehicleType.isTwoWheeler ){
            return AUSFVehicleBikeDekhoInt.callBikeDekhoAPI( variantId, cityId );
        } else if( vehicleType.isFourWheeler || vehicleType.isCommercialVehicle ){
            // call car dekho api
            return AUSFVehicleCarDekhoInt.callCarDekhoAPI( variantId, cityId );
        }
        return null;
    }

    @AuraEnabled(cacheable = true)
    public static Product_vs_PriceTag_Master__mdt[] getProductVsPriceTagConfigs(){
        return Product_vs_PriceTag_Master__mdt.getAll().values();
    }

    public static void validateMaterialFields(String screen, Collateral__c collateralWithDraftValues, String strProductType, String strProduct){
        if(collateralWithDraftValues.Id != null){
            Id collateralId = collateralWithDraftValues.Id;
            String vehicleScreen = String.format(VEHICLE_SCREEN_PLACEHOLDER, new String[]{ screen });
            String strVehicleScreen;
            ProductRTMap__mdt productRT = ProductRTMap__mdt.getInstance('A_'+strProduct);            
            if(strProductType == GlobalConstants.TRACTOR){
                strVehicleScreen = vehicleScreen + '_' + GlobalConstants.TRACTOR;
            }
            else if(strProductType == 'Construction Equipment'){
                strVehicleScreen = vehicleScreen + '_CE';
            }
            else if(strProductType == 'Commercial Vehicle' && productRT.Product_Name__c == 'Car Taxi'){
                strVehicleScreen = vehicleScreen + '_CarTaxi';
            }
            else if(strProductType == 'Commercial Vehicle'){
                strVehicleScreen = vehicleScreen + '_CV';
            }
            else{
                strVehicleScreen = vehicleScreen;
            }
            String[] materialFields = new String[0];
            // :TODO - getting all fields for now once checkMaterialFields logic is updated the method can be used directly
            for(Material_Field_Settings__mdt mfSetting: [Select Field_API__c from Material_Field_Settings__mdt where Screen__c=: strVehicleScreen AND Field_API__c != null ]){
                materialFields.add(mfSetting.Field_API__c);
            }
            
            materialFields.addAll(
                new String[]{
                    APPORTIONED_LOAN_AMOUNT_FIELD_API
                }
            );
            String[] fieldsToQuery = new List<String>(new Set<String>(materialFields));
            fieldsToQuery.addAll( new String[]{
                'MMV_Master__c',
                'Vehicle_Cost__c',
                'CreatedDate',
                'SystemModStamp'
            } );
            // String[] materialFields = Utility.getMaterialFields( vehicleScreen, collateral.Loan__c );
            Collateral__c oldCollateralRecord = Database.query(String.format( 'SELECT {0} FROM Collateral__c WHERE Id =: collateralId', new String[]{ String.join( fieldsToQuery, ',')}));
            if(oldCollateralRecord.CreatedDate != oldCollateralRecord.SystemModStamp){
                System.debug(JSON.serializePretty(oldCollateralRecord) + '\n New : ' + JSON.serializePretty(collateralWithDraftValues) + ' \n== Fields => ' + materialFields);
                String[] dirtyFields = Utility.getSObjectDirtyFields(oldCollateralRecord, collateralWithDraftValues, materialFields);
                dirtyFields = new List<String>(validateConditionalMaterialFields(dirtyFields, collateralWithDraftValues, oldCollateralRecord));
                Utility.checkMaterialFields(vehicleScreen, collateralWithDraftValues.loan__c, dirtyFields);
            }
        }
    }

    public static Set<String> validateConditionalMaterialFields(String[] dirtyFields, Collateral__c collateralWithDraftValues, Collateral__c oldCollateralRecord){
        Set<String> draftedFields = new Set<String>(dirtyFields);

        draftedFields.removeAll( new String[]{ 'Make__c', 'Model__c', 'Variant__c' });

        // If Apportioned Loan Amount is changed by value in the label - Bre should rerun
        if(draftedFields.contains(APPORTIONED_LOAN_AMOUNT_FIELD_API) && collateralWithDraftValues.Apportioned_Loan_Amount__c != null && oldCollateralRecord.Apportioned_Loan_Amount__c != null && (collateralWithDraftValues.Apportioned_Loan_Amount__c - oldCollateralRecord.Apportioned_Loan_Amount__c) <= Decimal.valueOf(Label.MaterialBREApportionedLoanAmount)){
            draftedFields.remove(APPORTIONED_LOAN_AMOUNT_FIELD_API);
        }

        // If LTV Showroom Price is changed by value greater than the label - Bre should rerun
        if(draftedFields.contains(LTV_EX_SHOWROOM_FIELD_API) && collateralWithDraftValues.LTV_offered_Ex_showroom__c != null && oldCollateralRecord.LTV_offered_Ex_showroom__c != null && ((collateralWithDraftValues.LTV_offered_Ex_showroom__c - oldCollateralRecord.LTV_offered_Ex_showroom__c) <= Decimal.valueOf(Label.MaterialBREExShowroomDiff))){
            draftedFields.remove(LTV_EX_SHOWROOM_FIELD_API);
        }

        if(draftedFields.contains(LTV_Offered_FIELD_API) && collateralWithDraftValues.LTV_offered__c != null && oldCollateralRecord.LTV_offered__c != null && ((collateralWithDraftValues.LTV_offered__c - oldCollateralRecord.LTV_offered__c) <= Decimal.valueOf(Label.MaterialBREExShowroomDiff))){
            draftedFields.remove(LTV_Offered_FIELD_API);
        }

        // If LTV On road Price is changed by value greater than the label - Bre should rerun
        if(draftedFields.contains(LTV_ON_ROAD_FIELD_API) && collateralWithDraftValues.LTV_offered_On_road__c != null && oldCollateralRecord.LTV_offered_On_road__c != null && ((collateralWithDraftValues.LTV_offered_On_road__c - oldCollateralRecord.LTV_offered_On_road__c) <= Decimal.valueOf(Label.MaterialBREVehicleCostDiff))){
            draftedFields.remove(LTV_ON_ROAD_FIELD_API);
        }
        
        // If Fuel Type is among values in the label consider BRE ReRun as false
        if(draftedFields.contains(FUEL_TYPE_FIELD_API) && Label.MaterialBREFuelTypes.toUpperCase().split(';').contains(collateralWithDraftValues.Fuel_Type__c)){
            draftedFields.remove(FUEL_TYPE_FIELD_API);
        }
        
        // Yes- in case of lower than 95% of vehicle cost else "no". (Funding can not exceed valuation amount)
        if(draftedFields.contains(VALUATION_AMOUNT_FIELD_API) && String.isNotBlank(collateralWithDraftValues.Valuation_Amount__c) && Decimal.valueOf(collateralWithDraftValues.Valuation_Amount__c) != 0 && Utility.calculatePercentageDiff(Decimal.valueOf(collateralWithDraftValues.Valuation_Amount__c), (oldCollateralRecord.Vehicle_Cost__c != null ? oldCollateralRecord.Vehicle_Cost__c : 0)) > Decimal.valueOf(Label.MaterialBREValuationAmount)){
            draftedFields.remove(VALUATION_AMOUNT_FIELD_API);
        }

        //"Yes if IDV reduced below Loan amount. If IDV already lower than Loan amount, then if reduce by > 10%."
        if(draftedFields.contains(IDV_FIELD_API) && collateralWithDraftValues.IDV__c != null && oldCollateralRecord.Apportioned_Loan_Amount__c != null && oldCollateralRecord.IDV__c != null &&
            ((Decimal.valueOf(collateralWithDraftValues.IDV__c) > oldCollateralRecord.Apportioned_Loan_Amount__c) &&
                (Utility.calculatePercentageDiff(Decimal.valueOf(collateralWithDraftValues.IDV__c), Decimal.valueOf(oldCollateralRecord.IDV__c)) < Decimal.valueof(Label.MaterialBREIDVDiff))
            || (Decimal.valueOf(collateralWithDraftValues.IDV__c) > Decimal.valueOf(oldCollateralRecord.IDV__c)))){
            draftedFields.remove(IDV_FIELD_API);
        }
        return draftedFields;
    }

    public static void validateIfChargeAmountExceedsFunding( Id loanId, Collateral__c collateral, Collateral__c oldCollateral, String screenName ){
        if( oldCollateral == null || !Utility.getSObjectDirtyFields( oldCollateral, collateral, new String[]{ 'LS_Value__c', 'LS__c', 'Insurance_Value__c', 'Insurance_Funding__c' } ).isEmpty() ){
            String[] lsChargeCodes = Label.LoanSurakshaChargeCode.split(';\\s*'),
                miChargeCodes = Label.MotorInsuranceChargeCode.split(';\\s*');

            Set<String> applicableChargeCodes = new Set<String>();
            applicableChargeCodes.addAll( lsChargeCodes );
            applicableChargeCodes.addAll( miChargeCodes );
            applicableChargeCodes.remove( null );

            Charge__c[] charges = [ SELECT Id, SC_Code__c, Charge_Amount__c FROM Charge__c WHERE SC_Code__c IN: applicableChargeCodes AND Loan_Application__c =: loanId ];
            if( charges.isEmpty() ){
                return;
            }

            map<String, Charge__c> chargesMap = Utility.getChargesMappedByScCode( charges );

            Decimal lsChargeTotal = 0, miChargeTotal = 0;
            for( String scCode: chargesMap.keySet() ){
                if( chargesMap.containsKey( scCode ) && lsChargeCodes.contains( chargesMap.get( scCode ).SC_Code__c ) ){
                    lsChargeTotal += chargesMap.get( scCode ).Charge_Amount__c;
                } else if( chargesMap.containsKey( scCode ) && miChargeCodes.contains( chargesMap.get( scCode ).SC_Code__c ) ){// Applicable for Used / Cow only
                    miChargeTotal += chargesMap.get( scCode ).Charge_Amount__c;
                }
            }
            
            // Throw error if Charges total exceeds funding total
            // SFAU-5240 - add condition of Is LS
            if( (collateral.LS__c == 'Yes' && collateral.LS_Value__c != null && Decimal.valueOf(collateral.LS_Value__c) > lsChargeTotal ) ){
                throw new ChargesController.ChargesException( String.format( Label.ChargeAmountExceededMessage, new String[]{ 'Loan Suraksha' } ) );
            } else if(screenName == System.label.AUSFUsedScreen && ( collateral.Insurance_Value__c != null && getDecimal(collateral.Insurance_Value__c) > miChargeTotal )){
                throw new ChargesController.ChargesException( String.format( Label.ChargeAmountExceededMessage, new String[]{ 'Motor Insurance' } ) );
            }
        }
    }

    static Decimal getDecimal(String strValue) {
        try {
            return Decimal.valueOf(strValue);
        } catch (Exception ex) {
            return 0;
        }
    }

    @AuraEnabled
    public static Collateral__c createCollateralForCBSData( Collateral__c oldCollateral ){
        // Collateral__c[] mappedCollaterals = AUSFVehicleHandler.mapSearchIntWraptoUIWrap((CollateralDedupeResponseWrapper)JSON.deserialize(oldCollateral, CollateralDedupeResponseWrapper.class));
        insert oldCollateral;

        return populateApplicationRelatedFields( oldCollateral.Id );
    }

    public static Collateral__c populateApplicationRelatedFields( Id collateralId ){
        Collateral__c collateral = [ SELECT Id, Name, Product__c, Loan__r.Product__c, Loan__r.Loan_Amount__c, Loan__r.Vehicle_use__c, Loan__r.Original_Vehicle_Usage__c, Original_Vehicle_Usage__c FROM Collateral__c WHERE Id=: collateralId ];

        collateral.Collateral_ID__c = collateral.Loan__r.Product__c + collateral.Name + Integer.valueof((Math.random() * 10));
        collateral.Vehicle_Usage__c = collateral.Loan__r.Vehicle_use__c;
        collateral.Original_Vehicle_Usage__c = collateral.Loan__r.Original_Vehicle_Usage__c;
        collateral.Apportioned_Loan_Amount__c = collateral.Loan__r.Loan_Amount__c;
        update collateral;

        return collateral;
    }

    static map<String, String> ASSESSMENT_METHOD_MAPPING = new map<String, String>{
        'LTVInPercent' => 'LTV',
        'Absolute' => ''
    };

    /**
     * CUG / SFAU-5139
     * 12.09.23
     * Populate Approved LTV based on collateral details since there were few cases for which it was blank even though filter criteria do match
     */
    public static Collateral__c getApprovedLTV( Loan_Application__c loanApp, Collateral__c oldCollateral, Collateral__c newCollateral, String productType ){
        Collateral__c updatedCollateral = newCollateral;
        try{
        if( oldCollateral == NULL || !Utility.getSObjectDirtyFields( oldCollateral, newCollateral, new String[]{ 'Vehicle_Category__c', 'Vehicle_Usage__c', 'Collateral_Name__c', 'MMV_Master__c', 'Scheme__c', 'Fuel_Type__c' } ).isEmpty() ){
            if( productType == Label.AUSFNewScreen ){
                LTV_Master__c ltvMaster = getLtvMasterRecord( loanApp, JSON.serialize( newCollateral ) );
                System.debug(JSON.serializePretty(ltvMaster));
                if(ltvMaster != null && loanApp.Customer_Grade__c != null){
                    
                    String grade = loanApp.Customer_Grade__c,
                            subGrade =  (new String[]{ 'FTU', 'FTB' }).contains( grade ) ? 'All' : loanApp.Sub_Grade__c?.replace(' ', '_'),
                            subGradeApi = Pattern.compile('[^a-zA-Z_]').matcher(subGrade).replaceAll(''),
                            applicableField = 'Commercial_'+ grade + (subGrade == 'All' ? '' : '_' + subGradeApi ) + '__c'; //Commercial_FTU__c / Commercial_FTB__c / Commercial_Transporter_SMO__c
                            String approvedLtv = (String)ltvMaster.get( loanApp.RecordType.Name == GlobalConstants.COMMERCIALVEHICLE ? applicableField : grade + '__c' );

                    updatedCollateral.Assessment_Method__c = ASSESSMENT_METHOD_MAPPING.containsKey( ltvMaster.Assessment_Method__c ) ? ASSESSMENT_METHOD_MAPPING.get( ltvMaster.Assessment_Method__c ) : newCollateral.Assessment_Method__c;
                    updatedCollateral.Approved_LTV__c = String.isNotBlank(approvedLtv) ? approvedLtv : newCollateral.Approved_LTV__c;
                }

            } else {
                    Depreciated_Grid__c gridMaster = loanApp.RecordType.Name == GlobalConstants.COMMERCIALVEHICLE ?
                        AUSFCommercialVehicleController.getDepreciatedMaster( newCollateral, loanApp ) :
                        getDepreciatedObj( newCollateral, new Applicant__c( Customer_Grade__c = loanApp.Customer_Grade__c ) );
                System.debug(JSON.serializePretty(gridMaster));
                if( gridMaster != null ){
                    updatedCollateral.Approved_LTV__c = gridMaster.LTV_Approved__c;
                    updatedCollateral.Assessment_Method__c = GlobalConstants.DEFAULT_COLLATERAL_METHOD_OF_ASSESSMENT;

                }
            }
        }
        } catch(Exception ex){
            System.debug( ex.getMessage() + '\n' + ex.getStackTraceString() + '\n at =' + ex.getLineNumber() );
        }
        return updatedCollateral;
    }
    /**
    * @description Create Valuation Deviation 
    * @author Ashish | 11-7-2023 
    * @param deviationRecord,loanId,operation 
    * @return Id 
    **/
    @AuraEnabled
    public static void createValuationDeviation(Deviation__c  deviationRecord, String loanId, String operation){
        Id deviationId = checkIfDeviationIsAlreadyCreated(loanId);
        if(deviationId == null){
            Deviation__c devRec  = deviationRecord;
            Database.insert(devRec, AccessLevel.USER_MODE);
        }
        else if(deviationId != null && operation =='Archive' ){
            Deviation__c devRec  = new Deviation__c();
            devRec.Id=deviationId;
            devRec.Archived__c = true;
            Database.update(devRec, AccessLevel.USER_MODE);
        }else if(deviationId != null && operation =='New' ){
            //Archive the old Deviation Record
            Deviation__c devRec  = new Deviation__c();
            devRec.Id=deviationId;
            devRec.Archived__c = true;
            Database.update(devRec, AccessLevel.USER_MODE);
            
            // Create the new Deviation Record 
            Deviation__c devNewRec  = deviationRecord;
            Database.insert(devNewRec, AccessLevel.USER_MODE);
        }
    }
    /**
    * @description Check for existing deviation for 
    * @author Ashish | 11-7-2023 
    * @param loanId 
    * @return Id 
    **/
    public static Id checkIfDeviationIsAlreadyCreated(Id loanId){
        try{
            return [SELECT Id FROM Deviation__c WHERE (Deviation_Type__c ='S4-Valuation' OR Deviation_Type__c ='S5-Valuation')  AND Loan_Application__c = :loanId AND Archived__c = false AND Active__c = true WITH SECURITY_ENFORCED].Id;
        }
        catch(Exception e){
            return null;
        }
        
    }

    /*
    @description :  SFAU-5608 - Get Collateral__c based on Loan Application Record and Collateral Inserted by Partner Leads 
    @param :  Loan Application Record Id
    @param : true
    @return : List<Collateral__c>
    */
    @AuraEnabled
    public static List<Collateral__c> checkForExistingLeadCollateral(Id loanAppRecId, Boolean blnIsLeadCollateral){
        List<Collateral__c> lstCollateral = new List<Collateral__c>();
        try {
            lstCollateral = [Select Id, Name,Collateral_ID__c, Certified_Value__c ,CBS_Response__c, Vehicle_Usage__c, Loan__r.Total_Loan_Amount__c,
                Vahaan_Response__c,Collateral_Name__c,MMV_Master__r.Name,Vehicle_Number__c,Collateral_Type__c,
                Loan__r.Product__c,Variant__c, Apportioned_Loan_Amount__c, Approved_LTV__c,Type_Of_Existing_Collateral__c,
                Linked_Account_Number__c,CustomerId__c, EX_showroom_Price_API__c, POS__c, LTV_offered_On_final_cost__c, Final_Cost__c,
                LTV_offered_On_road__c, LTV_offered_Ex_showroom__c, CreatedDate, SystemModStamp, BT_Loan_Status__c, Original_Vehicle_Usage__c, Loan__r.Original_Vehicle_Usage__c, Collateral_From_Lead_Api__c,  Engine_Number__c, Chasis_Number__c, Valuation_Amount__c, Make__c, Model__c, Ex_Showroom_Price__c, Current_Owner_Name__c, Owner_Serial_number__c, Kilometer__c 
                FROM  Collateral__c  where Loan__c  =: loanAppRecId AND Is_Deleted__c =false AND Collateral_From_Lead_Api__c =: blnIsLeadCollateral];
            if (lstCollateral != NULL && lstCollateral.size()>0){
                lstCollateral[0].Collateral_From_Lead_Api__c = false;
                //lstCollateral[0].Is_Deleted__c = true;
                //update lstCollateral;
            }
        }
        catch (Exception ex) {
            Log.error('Error in AUSFVehicleController checkForExistingLeadCollateral :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppRecId);
        }
        return lstCollateral;
    }

    public class CollateralData{
        @AuraEnabled public Map<String,List<PicklistWrapper>> collateralNames;
        @AuraEnabled public Map<String,String> mapOfCollateralNameVsId;
    }
    
    public class PicklistWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistWrapper(String label,String value){
            this.label = label;
            this.value = value;
        }
    }
    public class TypeOfWheeler{
        @AuraEnabled public Boolean isFourWheeler=false;
        @AuraEnabled public Boolean isTwoWheeler=false;
        // R2-17
        @AuraEnabled public Boolean isTractor=false;
        @AuraEnabled public Boolean isCommercialVehicle=false;
        @AuraEnabled public Boolean isOther=false;
    }
    
    public class apiWrapper{
        @AuraEnabled public Boolean boolResponse=false;
        @AuraEnabled public String valuationId='';
        @AuraEnabled public Valuation__c valuationRecord;
    }
    
    @AuraEnabled
    public static Collateral__c checkIfLoanSourcedInSF( String collateralId ){
        try{
            Collateral__c collateral = [SELECT Id, Name, Product__c, Loan__r.Stage__c,Collateral_ID__c,Is_Deleted__c FROM Collateral__c WHERE Collateral_ID__c=: collateralId and Is_Deleted__c=false WITH SECURITY_ENFORCED limit 1];
            return collateral;
        }
        catch(Exception e){
            return null;
        }
    }
    
    
}