/**
 * @Name: CreateFieldInvestigatiionRecord
 * @Test Class: 
 * @description : This class is for initiate FI records from BRE, Re-Trigger FI records
 * @author            : Vikas Singhal | Salesforce
 * @last modified on  : Jan-20-2023
 * @Logs
 * Last Modified By     :       Last Modified Date      :       Bug/US/Description
 * Mohit M.             :       June-6-2023             :       fetchRelatedApplicantAddress - Initiate FI records for Agency based on Loan Record Type
 * Mohit M.             :       June-14-2023            :       SFAU-2999 - sendBackFIRecord   
 * Yash S               :       Dec-08-2023             :       SFAU-4789 Changes
 * Yash S               :       Dec-18-2023             :       SFAU-5751 Changes

 **/
public without sharing class CreateFieldInvestigatiionRecord {
    /**
     * @description       : It will fetch address based on Loan Application or Applicant
     * @author            : Vikas Singhal | Salesforce
     * @last modified on  : Jan-20-2023
    **/
    @AuraEnabled
    public static List<Field_Investigation__c> fetchRelatedApplicantAddress(Id recordId, Boolean blnRetriggerFI,List<String> lstFiIds, List<Id> lstAddressIds){
    //public static List<Field_Investigation__c> fetchRelatedApplicantAddress(Id recordId, Boolean blnRetriggerFI,List<String> lstFiIds){//
        InitiateFieldCreationWrapper objIniFieldCreateWrap = new InitiateFieldCreationWrapper();
        List<Field_Investigation__c> lstReTrigger = new List<Field_Investigation__c>();
        try {
            //List<Id> lstAddressIds = new List<Id>();
            Id applicantRecordTypeId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.APPLICANT);
            Id coApplicantRecordTypeId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.COAPPLICANT);
            Id guarantorRecordTypeId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.GUARANTOR);
            List<Applicant__c> applicantList = new List<Applicant__c>();
            List<Address__c> addressList = new List<Address__c>();
            Map<Id,List<Address__c>> applicantIdVsAddressMap = new Map<Id,List<Address__c>>();
            Set<Id> setAddressIds = new Set<Id>();
            String objectName = '';
            /*
            @ Check For Re-Trigger
            @ Update Existing Records - Re-Trigger
            */
            if (blnRetriggerFI) {
                List<Field_Investigation__c> lstExistingFIRecords = new List<Field_Investigation__c>();
                lstExistingFIRecords = [Select Id,OwnerId,Owner.Name,Stage__c,FI_Allocation_Date_Time__c,FI_Agent__c,Address_lookup__c,Credit_Manager__c, Re_Trigger__c from Field_Investigation__c where (Id in:lstFiIds OR Address_lookup__c in: lstAddressIds) AND Re_Trigger__c = false];
                for (Field_Investigation__c obj : lstExistingFIRecords) {
                    Field_Investigation__c objReTrigger = new Field_Investigation__c(Id=obj.Id);
                    objReTrigger.Re_Trigger__c = true;
                    objReTrigger.Stage__c = Label.FI_Stage_Closed;
                    objReTrigger.OwnerId = (obj.Credit_Manager__c != NULL ? obj.Credit_Manager__c : obj.OwnerId);
                    lstReTrigger.add(objReTrigger);
                    setAddressIds.add(obj.Address_lookup__c);
                }
                
                    addressList = [Select Id,Fi_Required__c, Applicant__r.Key_Contact_Name__c,Applicant__r.Date_of_Establishment__c, City__c,
                    Applicant__r.Loan__r.Branch_Master__r.Account_Code__c,toLabel(Applicant__r.Loan__r.Product__c), Applicant__r.Loan__r.RecordType.DeveloperName, 
                    Applicant__r.Customer_Type__c, Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,District__c, Applicant__r.RecordType.Name,Applicant__c, 
                    Pincode__c, Area_Name__c,Address_Type__c,Applicant__r.DOB__c,Applicant__r.Gender__c,Applicant__r.Father_Name__c,Applicant__r.Mobile_Number__c, 
                    Applicant__r.Name, Applicant__r.Loan__c ,Applicant__r.Customer_Name__c,Applicant__r.Loan__r.Loan_Amount__c 
                    FROM Address__c where (Id in: setAddressIds OR Id in: lstAddressIds) AND Address_Type__c != '' AND Source_Type__c !=:GlobalConstants.CIBIL AND Source_Type__c != 'CART'];
            
                // Set Re-Trigger = true and Stage = Closed
                if (lstReTrigger.size()>0)
                    update lstReTrigger;
            }
            else {
                objectName=String.valueOf(recordId.getsobjecttype());
                if(objectName=='Loan_Application__c'){
                    addressList =[Select Id,Applicant__r.Key_Contact_Name__c,Applicant__r.Date_of_Establishment__c,Applicant__r.Loan__r.Branch_Master__r.Account_Code__c,toLabel(Applicant__r.Loan__r.Product__c),Applicant__r.Customer_Type__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,District__c, City__c
                                  ,Applicant__r.RecordType.Name,Applicant__c,Pincode__c,Area_Name__c,Address_Type__c,Applicant__r.DOB__c,Applicant__r.Gender__c,Applicant__r.Father_Name__c,Applicant__r.Mobile_Number__c,Applicant__r.Name, Applicant__r.Loan__r.RecordType.DeveloperName
                                  ,Applicant__r.Loan__c ,Applicant__r.Customer_Name__c,Applicant__r.Loan__r.Loan_Amount__c from Address__c where  Applicant__r.Loan__c =:recordId and Source_Type__c !=:GlobalConstants.CIBIL and Source_Type__c != 'CART' AND Fi_Required__c = true AND
                                  (Applicant__r.RecordTypeId =:applicantRecordTypeId or Applicant__r.RecordTypeId =:coApplicantRecordTypeId  or Applicant__r.RecordTypeId =:guarantorRecordTypeId )];
                }
                if(objectName=='Applicant__c'){
                    addressList =[Select Applicant__r.Key_Contact_Name__c,Applicant__r.Date_of_Establishment__c,Applicant__r.Customer_Type__c,Applicant__r.Loan__r.Branch_Master__r.Account_Code__c,toLabel(Applicant__r.Loan__r.Product__c),Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,District__c,City__c
                                  ,Applicant__c,Applicant__r.RecordType.Name,Id,Pincode__c,Area_Name__c,Address_Type__c,Applicant__r.DOB__c,Applicant__r.Gender__c,Applicant__r.Father_Name__c,Applicant__r.Mobile_Number__c,Applicant__r.Name, Applicant__r.Loan__r.RecordType.DeveloperName
                                  ,Applicant__r.Loan__c ,Applicant__r.Customer_Name__c,Applicant__r.Loan__r.Loan_Amount__c from Address__c where  Applicant__c =:recordId and Source_Type__c !=:GlobalConstants.CIBIL and Source_Type__c != 'CART' AND Fi_Required__c = true AND
                                  (Applicant__r.RecordTypeId =:applicantRecordTypeId or Applicant__r.RecordTypeId =:coApplicantRecordTypeId  or Applicant__r.RecordTypeId =:guarantorRecordTypeId )];
                }
            }
            String loanApplicationId;
            String applicationProduct = '';
            String applicationproductCode = '';
            List<Address__c> lstAddressFIInitiate = new List<Address__c>();
            if(addressList.size()>0){
                String strLoanRecordType = '';
                for(Address__c addressObject:addressList){
                    strLoanRecordType = addressObject.Applicant__r.Loan__r.RecordType.DeveloperName;
                    loanApplicationId =addressObject.Applicant__r.Loan__c;
                    if(!applicantIdVsAddressMap.containskey(addressObject.Applicant__c)){
                        applicantIdVsAddressMap.put(addressObject.Applicant__c,new list<Address__c>());
                    }
                    applicantIdVsAddressMap.get(addressObject.Applicant__c).add(addressObject);
                    if (!addressObject.Fi_Required__c) {
                        Address__c objFIReq = new Address__c();
                        objFIReq.Fi_Required__c = true;
                        objFIReq.Id = addressObject.Id;
                        lstAddressFIInitiate.add(objFIReq);
                    }

                    applicationProduct = addressObject.Applicant__r.Loan__r.Product__c;// 5751 Changes getting the Prod Code from Metadata

                    if (!lstAddressFIInitiate.isEmpty())
                        update lstAddressFIInitiate;
                }
                applicationproductCode = getRelatedProductCode(applicationProduct);// 5751 Changes getting the Prod Code from Metadata
                objIniFieldCreateWrap.addressList = addressList;
                objIniFieldCreateWrap.applicantIdVsAddressMap = applicantIdVsAddressMap;
                objIniFieldCreateWrap.applicantIdVsBussinessNameMap = getApplicantFinancialsDetails(loanApplicationId,applicantIdVsAddressMap.keySet());
                objIniFieldCreateWrap = createAddressMapForFieldCreation(applicantIdVsAddressMap, objIniFieldCreateWrap);
                system.debug('map '+objIniFieldCreateWrap.mapZipWithAddress);
                // Map of Application Branch PinCode With FI Id
                objIniFieldCreateWrap.mapAccAndPinWithOwner = FieldInvestigationUtility.getZipCodeWithAssignFIAgent('Field_Investigation',objIniFieldCreateWrap.mapZipWithAddress.keySet(),GlobalConstants.OWNERID,objIniFieldCreateWrap.setAccountCode, true, strLoanRecordType);
                system.debug(LoggingLevel.DEBUG,':: mapAccAndPinWithOwner ' + objIniFieldCreateWrap.mapAccAndPinWithOwner);
                // Map of Pincode With FI Id
                objIniFieldCreateWrap.mapPinWithOwner = FieldInvestigationUtility.getZipCodeWithAssignFIAgent('Field_Investigation',objIniFieldCreateWrap.mapZipWithAddress.keySet(),GlobalConstants.OWNERID,new Set<String>(), true, strLoanRecordType);//new Set<String>()
                system.debug(LoggingLevel.DEBUG,':: mapPinWithOwner ' + objIniFieldCreateWrap.mapPinWithOwner);
                // Map of Pincode with CM Id
                Map<String,String> mapPinWithCM = new Map<String,String>();
                objIniFieldCreateWrap.mapPinWithCM = FieldInvestigationUtility.getZipCodeWithAssignUserCreditManager('Field_Investigation',Label.AccountTeamMemberRole_Credit,GlobalConstants.OWNERID,objIniFieldCreateWrap.setAccountCode, false, applicationproductCode);// New parameter Added for 5751 to find on the basis of Product Code
                system.debug(LoggingLevel.DEBUG,':: mapPinWithCM ' + objIniFieldCreateWrap.mapPinWithCM);
                
                objIniFieldCreateWrap.lstField = setFieldInvestigationRecords (objIniFieldCreateWrap.lstField, objIniFieldCreateWrap.mapAccAndPinWithOwner, objIniFieldCreateWrap.mapPinWithOwner, objIniFieldCreateWrap.mapPinWithCM, !blnRetriggerFI, objIniFieldCreateWrap.addressIdVsPincodeMap);
                system.debug('lstField>>'+objIniFieldCreateWrap.lstField.size());
                insert objIniFieldCreateWrap.lstField;

                /*
                // Set Re-Trigger = true and Stage = Closed
                if (lstReTrigger.size()>0)
                    update lstReTrigger;
                */

                system.debug('lstFiIds$$>>'+lstFiIds);
                system.debug('blnRetriggerFI%>>'+blnRetriggerFI);
                //Calling FI Retrigger Notification
                if(objectName=='Loan_Application__c'){
                    NotificationHandler.sendNotification('FI Retrigger',recordId,'');
                }
            }
            else {
                throw new CustomException(Label.FI_Creation_No_Address_Msg);
            }
        } catch (Exception e) {
            system.debug('Exception>>>>'+e.getMessage()+'  line number>>>'+e.getLineNumber());
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
            throw new AuraHandledException(e.getMessage());
        }
        return objIniFieldCreateWrap.lstField;
    }

    /*
    method : getRelatedProductCode to retrieve the Product Code from the Product Name
     * @author            : Yash SHukla | Salesforce
    */

    public static String getRelatedProductCode(String prodName){
        String prodCode = '';
        List<ProductRTMap__mdt> productMetadaRecords = ProductRTMap__mdt.getAll().values();
        for(ProductRTMap__mdt metadataRec : productMetadaRecords){
            if(metadataRec.Product_Label__c	== prodName){
                prodCode = metadataRec.Product__c;
                break;
            }
        }
        return prodCode;
    } 

    /*
    * method: fetchBRERelatedApplicantAddress
    * purpose: Create FI Records from BRE Response
    * param1: Map of Applicant Name with List of Address Type
    * param2: Loan Application Record Id
    * param3: Boolean retrigger FI
    * param4: List of FI Record Ids for retrigger
    */
    @AuraEnabled
    public static List<Field_Investigation__c> fetchBRERelatedApplicantAddress(Map<String, List<String>> mapAppIdAndAddIdType, Id recordId, Boolean blnRetriggerFI,List<String> lstFiIds){
        InitiateFieldCreationWrapper objIniFieldCreateWrap = new InitiateFieldCreationWrapper();
        try {
            List<Applicant__c> applicantList = new List<Applicant__c>();
            List<Address__c> addressList = new List<Address__c>();
            List<Address__c> fiTypeAddressList = new List<Address__c>();
            Map<Id,List<Address__c>> applicantIdVsAddressMap = new Map<Id,List<Address__c>>();
            String objectName=String.valueOf(recordId.getsobjecttype());
            if(objectName=='Loan_Application__c'){
                addressList =[Select Id,Fi_Required__c, Applicant__r.Key_Contact_Name__c,Applicant__r.Date_of_Establishment__c,Applicant__r.Loan__r.Branch_Master__r.Account_Code__c,toLabel(Applicant__r.Loan__r.Product__c),Applicant__r.Customer_Type__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,District__c,City__c
                              ,Applicant__r.RecordType.Name,Applicant__c,Pincode__c,Area_Name__c,Address_Type__c,Applicant__r.DOB__c,Applicant__r.Gender__c,Applicant__r.Father_Name__c,Applicant__r.Mobile_Number__c,Applicant__r.Name, Applicant__r.Loan__r.RecordType.DeveloperName
                              ,Applicant__r.Loan__c ,Applicant__r.Customer_Name__c,Applicant__r.Loan__r.Loan_Amount__c from Address__c where  Applicant__r.Loan__c =:recordId AND Applicant__r.Name IN: mapAppIdAndAddIdType.keySet() AND Source_Type__c != 'Cibil' AND Source_Type__c != 'CART' AND Address_Type__c != ''];
            }
            Set<String> setStringApplicantWithType = new Set<String>();
            for(Address__c add : addressList){
                if(mapAppIdAndAddIdType.containsKey(add.Applicant__r.Name) && add.Fi_Required__c == false){
                    if(mapAppIdAndAddIdType.get(add.Applicant__r.Name).contains(add.Address_Type__c.toUpperCase())){
                        fiTypeAddressList.add(add);
                    }
                }
            }
            
            String loanApplicationId;
            String strLoanRecordType = '';
            String applicationProduct = '';
            String applicationproductCode = '';
            if(fiTypeAddressList.size()>0){
                for(Address__c addressObject : fiTypeAddressList){
                    strLoanRecordType = addressObject.Applicant__r.Loan__r.RecordType.DeveloperName;
                    loanApplicationId =addressObject.Applicant__r.Loan__c;
                    if(!applicantIdVsAddressMap.containskey(addressObject.Applicant__c)){
                        applicantIdVsAddressMap.put(addressObject.Applicant__c,new list<Address__c>());
                    }
                    applicantIdVsAddressMap.get(addressObject.Applicant__c).add(addressObject);
                    addressObject.Fi_Required__c=true;
                    applicationProduct = addressObject.Applicant__r.Loan__r.Product__c;
                }
                update fiTypeAddressList;
                applicationproductCode = getRelatedProductCode(applicationProduct);
                objIniFieldCreateWrap.addressList = fiTypeAddressList;
                objIniFieldCreateWrap.applicantIdVsAddressMap = applicantIdVsAddressMap;
                objIniFieldCreateWrap.applicantIdVsBussinessNameMap = getApplicantFinancialsDetails(loanApplicationId,applicantIdVsAddressMap.keySet());
                objIniFieldCreateWrap = createAddressMapForFieldCreation(applicantIdVsAddressMap, objIniFieldCreateWrap);
                // Map of Application Branch PinCode With FI Id
                objIniFieldCreateWrap.mapAccAndPinWithOwner = FieldInvestigationUtility.getZipCodeWithAssignFIAgent('Field_Investigation',objIniFieldCreateWrap.mapZipWithAddress.keySet(),GlobalConstants.OWNERID,objIniFieldCreateWrap.setAccountCode, true, strLoanRecordType);
                system.debug(LoggingLevel.DEBUG,':: mapAccAndPinWithOwner ' + objIniFieldCreateWrap.mapAccAndPinWithOwner);
                // Map of Pincode With FI Id
                objIniFieldCreateWrap.mapPinWithOwner = FieldInvestigationUtility.getZipCodeWithAssignFIAgent('Field_Investigation',objIniFieldCreateWrap.mapZipWithAddress.keySet(),GlobalConstants.OWNERID,new Set<String>(), true, strLoanRecordType);
                system.debug(LoggingLevel.DEBUG,':: mapPinWithOwner ' + objIniFieldCreateWrap.mapPinWithOwner);
                // Map of Pincode with CM Id
                Map<String,String> mapPinWithCM = new Map<String,String>();
                objIniFieldCreateWrap.mapPinWithCM = FieldInvestigationUtility.getZipCodeWithAssignUserCreditManager('Field_Investigation',Label.AccountTeamMemberRole_Credit,GlobalConstants.OWNERID,objIniFieldCreateWrap.setAccountCode, false, applicationproductCode);// New parameter added as part of 5751
                system.debug(LoggingLevel.DEBUG,':: mapPinWithCM ' + objIniFieldCreateWrap.mapPinWithCM);
                if (!blnRetriggerFI) {
                    objIniFieldCreateWrap.lstField = setFieldInvestigationRecords (objIniFieldCreateWrap.lstField, objIniFieldCreateWrap.mapAccAndPinWithOwner, objIniFieldCreateWrap.mapPinWithOwner, objIniFieldCreateWrap.mapPinWithCM, !blnRetriggerFI, objIniFieldCreateWrap.addressIdVsPincodeMap);
                    system.debug(LoggingLevel.Debug,'New FI Records ... ');
                    insert objIniFieldCreateWrap.lstField;
                }
                else {
                    system.debug(LoggingLevel.Debug,' Retrigger FI Records '+lstFiIds);
                    List<Field_Investigation__c> lstFi=[Select Id,OwnerId,Owner.Name,Stage__c,FI_Allocation_Date_Time__c,FI_Agent__c,Address_lookup__c,Credit_Manager__c from Field_Investigation__c where Id in:lstFiIds];
                    objIniFieldCreateWrap.lstField = setReTriggerFieldInvestigationRecords (lstFi, objIniFieldCreateWrap.mapAccAndPinWithOwner, objIniFieldCreateWrap.mapPinWithOwner, objIniFieldCreateWrap.mapPinWithCM, blnRetriggerFI, objIniFieldCreateWrap.addressIdVsPincodeMap);
                    system.debug(LoggingLevel.Info, 'objIniFieldCreateWrap.lstField $$>>'+ objIniFieldCreateWrap.lstField );
                    update objIniFieldCreateWrap.lstField;
                }
                //Calling Notification FI Initiation
                system.debug('Id that is sent '+objIniFieldCreateWrap.lstField[0].FI_Agent__c);
                NotificationHandler.sendNotification('FI Initiation',recordId,objIniFieldCreateWrap.lstField[0].FI_Agent__c);
            }
            else {
                system.debug(LoggingLevel.Info,'Warning : ' + Label.FI_Creation_No_Address_Msg);
                Log.error(Label.FI_Creation_No_Address_Msg,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
                //throw new CustomException(Label.FI_Creation_No_Address_Msg);
            }
            
        } catch (Exception e) {
            system.debug('Exception>>>>'+e.getMessage()+'  line number>>>'+e.getLineNumber());
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
            throw new AuraHandledException(e.getMessage());
        }
        return objIniFieldCreateWrap.lstField;
    }

    /*
    * Method added to identify the VF Origin to Pass event from LWC TO VF Page for iFrame 
    */
    @AuraEnabled(Cacheable=true)
    public static string getVFOrigin(){
        String vfOrigin = '';
        String baseurl = URL.getOrgDomainUrl().toExternalForm();

        // PLEASE CROSS VERIFY THIS URL FOR EVERY SANDBOX
        vfOrigin = baseurl.split('.sandbox.my.')[0] + '--c.sandbox.vf.force.com';

        return vfOrigin;
    }

    /**
     * @description       : It will create fi based on address matching 
     * @author            : Vikas Singhal | Salesforce
     * @last modified on  : Jan-20-2023
    **/
    public static Map<String,String>  getApplicantFinancialsDetails(String loanApplicationId, Set<Id> setApplicantIdVsAddress){
        Map<String,String> applicantIdVsBussinessNameMap = new Map<String,String>();
        try {
            Collateral__c  collateralObj = new Collateral__c();
            //  collateralObj = [select id,Make__c,Model__c, Variant__c from Collateral__c where Loan__c =:loanApplicationId limit 1 ];
            List<Applicant_Financials_Details__c> applicantFinancialsDetailsList=[select id,Company_Name__c,Applicant__c
                                                                                  from Applicant_Financials_Details__c where Applicant__c in: setApplicantIdVsAddress];
            for(Applicant_Financials_Details__c applicantFinancialsDetailObject:applicantFinancialsDetailsList){
                if(!applicantIdVsBussinessNameMap.containskey(applicantFinancialsDetailObject.Applicant__c)){
                    applicantIdVsBussinessNameMap.put(applicantFinancialsDetailObject.Applicant__c,applicantFinancialsDetailObject.Company_Name__c);
                }
            }
        }
        catch (Exception ex){
            throw new CustomException(ex);
        }
        return applicantIdVsBussinessNameMap;
    } 

    public static InitiateFieldCreationWrapper createAddressMapForFieldCreation (Map<Id,List<Address__c>> applicantIdVsAddressMap, InitiateFieldCreationWrapper objIniFieldCreateWrap) {
        Boolean addressCheck;
        List<Field_Investigation__c> FiList = new List<Field_Investigation__c>();
        Map<Id,Address__c> applicantIdVsAddressObjectMap = new Map<Id,Address__c>();
        Map<Id,String> addressIdVsPincodeMap = new Map<Id,String>();
        Set<String> mapFISecond = new Set<String>();
        Map<String,List<Id>> mapZipWithAddress = new Map<String,List<Id>>();
        Set<String> setAccountId = new Set<String>();
        integer a=0;
        system.debug('applicantIdVsAddressMap'+applicantIdVsAddressMap);
        try {
            for(Id applicantId:applicantIdVsAddressMap.keySet()){
                for(Address__c addressMapObject:applicantIdVsAddressMap.get(applicantId)){
                    Field_Investigation__c fiObj = new Field_Investigation__c();
                    system.debug(LoggingLevel.Info,'addressMapObject ' + addressMapObject);
                    String strtype = applicantId + '+' + addressMapObject.Address_Type__c.toUpperCase();
                    system.debug(LoggingLevel.Info,'strtype at 205 ' + strtype);
                    
                    if (!applicantIdVsAddressObjectMap.containskey(applicantId) ) {
                        if(!mapZipWithAddress.containskey(addressMapObject.Pincode__c)){
                            mapZipWithAddress.put(addressMapObject.Pincode__c,new list<Id>());
                        }
                        mapZipWithAddress.get(addressMapObject.Pincode__c).add(addressMapObject.Id);
                        applicantIdVsAddressObjectMap.put(applicantId,addressMapObject);
                        mapFISecond.add(strtype);
                        addressIdVsPincodeMap.put(addressMapObject.Id,addressMapObject.Pincode__c);
                        fiObj =FieldInvestigationUtility.createFiRecord(addressMapObject,objIniFieldCreateWrap.collateralObj,objIniFieldCreateWrap.applicantIdVsBussinessNameMap);
                        setAccountId.add(addressMapObject.Applicant__r.Loan__r.Branch_Master__r.Account_Code__c);
                        FiList.add(fiObj);  
                        continue;
                    }
                    else if(applicantIdVsAddressObjectMap.containskey(applicantId) &&  
                            ((mapFISecond.contains(applicantId + '+' + GlobalConstants.CURRENT) && strtype == applicantId + '+' + GlobalConstants.PERMANENT) 
                                || (mapFISecond.contains(applicantId + '+' + GlobalConstants.PERMANENT) && strtype == applicantId + '+' +GlobalConstants.CURRENT)))
                    {
                        addressCheck = FieldInvestigationUtility.matchAddress(addressMapObject,applicantIdVsAddressObjectMap.get(applicantId));
                        if (addressCheck==false) {
                            if(!mapZipWithAddress.containskey(addressMapObject.Pincode__c)){
                                mapZipWithAddress.put(addressMapObject.Pincode__c,new list<Id>());
                            }
                            mapZipWithAddress.get(addressMapObject.Pincode__c).add(addressMapObject.Id);
                            addressIdVsPincodeMap.put(addressMapObject.Id,addressMapObject.Pincode__c);
                            mapFISecond.add(strtype);
                            fiObj= FieldInvestigationUtility.createFiRecord(addressMapObject,objIniFieldCreateWrap.collateralObj,objIniFieldCreateWrap.applicantIdVsBussinessNameMap);
                            FiList.add(fiObj);
                            setAccountId.add(addressMapObject.Applicant__r.Loan__r.Branch_Master__r.Account_Code__c);
                        }
                    }
                    else if(applicantIdVsAddressObjectMap.containskey(applicantId) && 
                            ((mapFISecond.contains(applicantId + '+' + GlobalConstants.TOUCHPOINT) && strtype == applicantId + '+' +GlobalConstants.OFFICE) 
                                || (mapFISecond.contains(applicantId + '+' + GlobalConstants.OFFICE) && strtype == applicantId + '+' +GlobalConstants.TOUCHPOINT)))
                    {
                        addressCheck = FieldInvestigationUtility.matchAddress(addressMapObject,applicantIdVsAddressObjectMap.get(applicantId));
                        if (addressCheck==false) {
                            if(!mapZipWithAddress.containskey(addressMapObject.Pincode__c)){
                                mapZipWithAddress.put(addressMapObject.Pincode__c,new list<Id>());
                            }
                            mapZipWithAddress.get(addressMapObject.Pincode__c).add(addressMapObject.Id);
                            mapFISecond.add(strtype);
                            addressIdVsPincodeMap.put(addressMapObject.Id,addressMapObject.Pincode__c); 
                            fiObj= FieldInvestigationUtility.createFiRecord(addressMapObject,objIniFieldCreateWrap.collateralObj,objIniFieldCreateWrap.applicantIdVsBussinessNameMap);
                            FiList.add(fiObj);
                            setAccountId.add(addressMapObject.Applicant__r.Loan__r.Branch_Master__r.Account_Code__c);
                        }
                    }
                    else {
                        applicantIdVsAddressObjectMap.put(applicantId,addressMapObject);
                        mapFISecond.add(strtype);
                        addressIdVsPincodeMap.put(addressMapObject.Id,addressMapObject.Pincode__c);
                        if(!mapZipWithAddress.containskey(addressMapObject.Pincode__c)){
                            mapZipWithAddress.put(addressMapObject.Pincode__c,new list<Id>());
                            
                        }
                        mapZipWithAddress.get(addressMapObject.Pincode__c).add(addressMapObject.Id);   
                        fiObj =FieldInvestigationUtility.createFiRecord(addressMapObject,objIniFieldCreateWrap.collateralObj,objIniFieldCreateWrap.applicantIdVsBussinessNameMap);
                        FiList.add(fiObj);
                        setAccountId.add(addressMapObject.Applicant__r.Loan__r.Branch_Master__r.Account_Code__c);
                    }
                }
            }
        }
        catch(Exception ex){
            system.debug('ex'+ex);
            system.debug('Exception>>>>'+ex.getMessage()+'  line number>>>'+ex.getLineNumber());
            throw new CustomException(ex);
        }
        objIniFieldCreateWrap.lstField = FiList;
        objIniFieldCreateWrap.setAccountCode = setAccountId;
        objIniFieldCreateWrap.applicantIdVsAddressMap = applicantIdVsAddressMap;
        objIniFieldCreateWrap.mapZipWithAddress = mapZipWithAddress;
        objIniFieldCreateWrap.addressIdVsPincodeMap = addressIdVsPincodeMap;
        return objIniFieldCreateWrap;
    }
            
    public static List<Field_Investigation__c> setFieldInvestigationRecords (List<Field_Investigation__c> FiList, Map<String,String> mapAccAndPinWithOwner, Map<String,String> mapPinWithOwner, Map<String,String> mapPinWithCM, Boolean blnChangeCM, Map<Id,String> addressIdVsPincodeMap) {
        try {
            String queueNameLabelValue = System.Label.Field_Investigation_Centralize_Queue_Name;
            String centralisedQueueId = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = :queueNameLabelValue LIMIT 1].Id;
            for(Field_Investigation__c fieldInvestigationObject:FiList){
                if(addressIdVsPincodeMap.containskey(fieldInvestigationObject.Address_lookup__c)){
                    String strTempZipCode = addressIdVsPincodeMap.get(fieldInvestigationObject.Address_lookup__c);
                    // Set Credit Manager
                    fieldInvestigationObject.Stage__c = Label.FI_Stage_New;
                    fieldInvestigationObject.OwnerId = centralisedQueueId;
                    
                    // Set Owner mapped with Branch and Pin Code
                    if (mapAccAndPinWithOwner.containsKey(strTempZipCode)){
                        fieldInvestigationObject.OwnerId = mapAccAndPinWithOwner.get(strTempZipCode);
                        fieldInvestigationObject.Stage__c = Label.FI_Stage_Assigned;
                        fieldInvestigationObject.FI_Allocation_Date_Time__c=DateTime.now();
                        fieldInvestigationObject.FI_Agent__c = mapAccAndPinWithOwner.get(strTempZipCode);
                    }
                    // Set Owner mapped with Branch Code
                    else if (mapPinWithOwner.containsKey(strTempZipCode)){
                        fieldInvestigationObject.OwnerId = mapPinWithOwner.get(strTempZipCode);
                        fieldInvestigationObject.Stage__c = Label.FI_Stage_Assigned;
                        fieldInvestigationObject.FI_Allocation_Date_Time__c=DateTime.now();
                        fieldInvestigationObject.OwnerId = mapPinWithOwner.get(strTempZipCode);
                        fieldInvestigationObject.FI_Agent__c = mapPinWithOwner.get(strTempZipCode);
                    }
                    // Set Owner Credit Manager mapped with Branch
                    else if (mapPinWithCM.containsKey(strTempZipCode)){
                        fieldInvestigationObject.OwnerId = mapPinWithCM.get(fieldInvestigationObject.Branch_Name_Code__c);
                        fieldInvestigationObject.Stage__c = Label.FI_Stage_Assigned;
                        fieldInvestigationObject.FI_Allocation_Date_Time__c=DateTime.now();
                    }
                    // Set Credit Manager
                    system.debug('test map '+' '+fieldInvestigationObject.Branch_Name_Code__c+' '+mapPinWithCM+' '+blnChangeCM);
                    fieldInvestigationObject.Credit_Manager__c = mapPinWithCM.containsKey(fieldInvestigationObject.Branch_Name_Code__c) ? mapPinWithCM.get(fieldInvestigationObject.Branch_Name_Code__c) : NULL;//blnChangeCM && 
                }
            }
            system.debug('FiList>>'+FiList.size());
        }
        catch (Exception ex) {
            throw new CustomException(ex);
        }
        return fiList;
    }

    /* 
    * Description - Retrigger Field Investigation Record
    */
    public static List<Field_Investigation__c> setReTriggerFieldInvestigationRecords (List<Field_Investigation__c> FiList, Map<String,String> mapAccAndPinWithOwner, Map<String,String> mapPinWithOwner, Map<String,String> mapPinWithCM, Boolean blnChangeCM, Map<Id,String> addressIdVsPincodeMap) {
        List<Field_Investigation__c> lstFieldUpdateRetrigger = new List<Field_Investigation__c>();
        List<Field_Investigation__c> newInstanceFIRecords = new List<Field_Investigation__c>();
        try {
            for(Field_Investigation__c fieldInvestigationObject:FiList){
                Field_Investigation__c objRetrigger = new Field_Investigation__c();
                objRetrigger.Re_Trigger__c = true;
                objRetrigger.Id = fieldInvestigationObject.Id;
                lstFieldUpdateRetrigger.add(objRetrigger);
                fieldInvestigationObject.Id = NULL;
                if(addressIdVsPincodeMap.containskey(fieldInvestigationObject.Address_lookup__c)){
                    String strTempZipCode = addressIdVsPincodeMap.get(fieldInvestigationObject.Address_lookup__c);
                    // Set Credit Manager
                    fieldInvestigationObject.Stage__c = Label.FI_Stage_New;
                    fieldInvestigationObject.Id = NULL;
                    // Set Owner mapped with Branch and Pin Code
                    if (mapAccAndPinWithOwner.containsKey(strTempZipCode)){
                        fieldInvestigationObject.OwnerId = mapAccAndPinWithOwner.get(strTempZipCode);
                        fieldInvestigationObject.Stage__c = Label.FI_Stage_Assigned;
                        fieldInvestigationObject.FI_Allocation_Date_Time__c=DateTime.now();
                        fieldInvestigationObject.FI_Agent__c = mapAccAndPinWithOwner.get(strTempZipCode);
                    }
                    // Set Owner mapped with Branch Code
                    else if (mapPinWithOwner.containsKey(strTempZipCode)){
                        fieldInvestigationObject.OwnerId = mapPinWithOwner.get(strTempZipCode);
                        fieldInvestigationObject.Stage__c = Label.FI_Stage_Assigned;
                        fieldInvestigationObject.FI_Allocation_Date_Time__c=DateTime.now();
                        fieldInvestigationObject.OwnerId = mapPinWithOwner.get(strTempZipCode);
                    }
                    // Set Owner Credit Manager mapped with Branch
                    else if (mapPinWithCM.containsKey(strTempZipCode)){
                        fieldInvestigationObject.OwnerId = mapPinWithCM.get(strTempZipCode);
                        fieldInvestigationObject.Stage__c = Label.FI_Stage_Assigned;
                        fieldInvestigationObject.FI_Allocation_Date_Time__c=DateTime.now();
                    }
                    // Set Credit Manager
                    fieldInvestigationObject.Credit_Manager__c = blnChangeCM && mapPinWithCM.containsKey(strTempZipCode) ? mapPinWithCM.get(strTempZipCode) : NULL;
                    

                }
                newInstanceFIRecords.add(fieldInvestigationObject);
            }
            if (lstFieldUpdateRetrigger.size()>0)
                update lstFieldUpdateRetrigger;
        }
        catch (Exception ex) {
            throw new CustomException(ex);
        }
        system.debug('mohit is here '+newInstanceFIRecords);
        return newInstanceFIRecords;
    }
    
    public class InitiateFieldCreationWrapper {
        public Map<String,String> applicantIdVsBussinessNameMap= new Map<String,String>();
        public Map<Id,String> addressIdVsPincodeMap = new Map<Id,String>();
        public List<Address__c> addressList = new List<Address__c>();
        public Map<Id,List<Address__c>> applicantIdVsAddressMap = new Map<Id,List<Address__c>>();
        public Set<String> setAccountCode = new Set<String>();
        // Map of Application Branch PinCode With FI Id
        Map<String,String> mapAccAndPinWithOwner = new Map<String,String>();
        // Map of Pincode With FI Id
        Map<String,String> mapPinWithOwner = new Map<String,String>();
        // Map of Pincode with CM Id
        Map<String,String> mapPinWithCM = new Map<String,String>();
        Map<String,List<Id>> mapZipWithAddress = new Map<String,List<Id>>();
        List<Field_Investigation__c> lstField = new List<Field_Investigation__c>();
        Collateral__c  collateralObj = new Collateral__c();
    }
    
    /* 
    * Description - update Field_Investigation record on submit
     */ 
    @AuraEnabled
    public static FieldInvestigationWrap updateFieldInvestigationRecord (String strFields, String recordId, Boolean blnFIProfile, Boolean blnfinalupdate) {
        Savepoint sp = Database.setSavepoint();
        FieldInvestigationWrap objWrap = new FieldInvestigationWrap();
        objWrap.blnSuccess = false;
        Field_Investigation__c objFIRecord = new Field_Investigation__c();
        String queueNameLabelValue = System.Label.Field_Investigation_Centralize_Queue_Name;
        String centralisedQueueId = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = :queueNameLabelValue LIMIT 1].Id;
        try{
            List<Field_Investigation__c> lstFI = [Select Id, Credit_Manager__c,Type_of_address__c, Loan_Application__c, Loan_Application__r.Stage__c, Loan_Application__r.BRE_Decision__c, 
                                                  Loan_Application__r.BRE_ReRun_Required__c, CreatedById from Field_Investigation__c where Id =: recordId];
            if(String.isNotBlank(strFields)) {
                Field_Investigation__c objFI = (Field_Investigation__c)JSON.deserialize(strFields, Field_Investigation__c.class);
                objFIRecord = objFI;
                objFIRecord.Id = recordId;
                objFIRecord.Loan_Application__c = lstFI[0].Loan_Application__c;
                if(objFIRecord.FI_Status__c == 'Cancelled' || objFIRecord.FI_Profile_Status__c == 'Cancelled'){
                    objFIRecord.Stage__c = 'New';
                    objFIRecord.OwnerId = lstFI[0].Credit_Manager__c != NULL ? lstFI[0].Credit_Manager__c : centralisedQueueId;
                    objFIRecord.FI_Agent__c = null;
                    update objFIRecord;
                    objWrap.blnSuccess = true;
                    objWrap.strMessage = 'Record updated successfully';
                    
                }   
                else{
                    if (blnFIProfile != NULL && blnFIProfile) {
                        objFIRecord.FI_Status__c = objFIRecord.FI_Profile_Status__c;
                    }
                    else {
                        objFIRecord.FI_Profile_Status__c = objFIRecord.FI_Status__c;
                    }
                    if(objFIRecord.FI_Status__c == Label.FI_Status_Positive || objFIRecord.FI_Status__c == Label.FI_Status_Negative){
                        objFI.FI_Submission_Date_Time__c = System.now();
                    }
                    objFIRecord.Stage__c = objFIRecord.FI_Status__c == Label.FI_Status_Positive || objFIRecord.FI_Status__c == Label.FI_Status_Negative || objFIRecord.FI_Status__c == Label.FI_Stage_Waived_Off || objFIRecord.FI_Status__c == Label.FI_Stage_Cancelled ? Label.FI_Stage_Closed : objFIRecord.Stage__c;
                    if (blnfinalupdate) {
                        objFIRecord.FI_Submission_Date_Time__c = ((objFIRecord.FI_Status__c == Label.FI_Status_Negative || objFIRecord.FI_Status__c == Label.FI_Status_Positive) ? System.Now() : objFIRecord.FI_Submission_Date_Time__c);
                        //objFIRecord.ownerId = objFIRecord.Stage__c == Label.FI_Stage_Closed && lstFI[0].Credit_Manager__c != NULL ? lstFI[0].Credit_Manager__c : centralisedQueueId;
                    }
                    
                    
                    if((String.isNotBlank(objFI.Address_Negative_Reason__c) || String.isNotBlank(objFI.Profile_Negative_Reasons__c)) && objFI.FI_Status__c == 'Negative' || objFI.FI_Profile_Status__c  == 'Negative' ) {
                        createFieldInvestigationDeviationRecord(objFI);
                    }
                    objFI.Is_Send_Back__c = false;
                    update objFI;

                    if((objFI.FI_Status__c == 'Negative' || objFI.FI_Profile_Status__c  == 'Negative') && lstFI[0].Loan_Application__r.Stage__c=='DDE'){
                        Loan_Application__c appl = new Loan_Application__c(Id = lstFI[0].Loan_Application__c, BRE_ReRun_Required__c = true);
                        update appl;
                    }
                    objWrap.blnSuccess = true;
                    objWrap.strMessage = 'Record updated successfully';
                    if(objFIRecord.FI_Status__c == Label.FI_Status_Positive || objFIRecord.FI_Status__c == Label.FI_Status_Negative ){
                        system.debug('yash '+lstFI[0].Type_of_address__c+'@@@'+objFIRecord.FI_Status__c);
                        NotificationHandler.sendNotification('FI Stage Completion',lstFI[0].Loan_Application__c ,lstFI[0].Type_of_address__c+'@@@'+objFIRecord.FI_Status__c); //SFAU-2996
                    }
                    

                }
            }    
        }
        catch(Exception ex){
            Database.rollback(sp);
            system.debug('exception ex '+ex.getMessage()+' '+ex.getStackTraceString());
            system.debug(LoggingLevel.ERROR,'Error ' + ex);
            system.debug(LoggingLevel.ERROR,'Error ' + ex.getLineNumber());
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objFIRecord.Id);
            objWrap.strMessage = ex.getMessage();
        }
        return objWrap;
    }
    
    public class FieldInvestigationWrap {
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strMessage {get;set;}
    }
    
    /*
    Description - Insert Negative Address Deviations and update Loan Approval Level
    */
    private static void createFieldInvestigationDeviationRecord(Field_Investigation__c fiRecord) {
        
        try {
            String strLoanApprovalLevel = '';
            Loan_Application__c loanAppObj = [Select Id, BRE_Application_Level__c, Product__c, BRE_Approval_Level__c from Loan_Application__c where Id=: fiRecord.Loan_Application__c];
            strLoanApprovalLevel = String.IsNotBlank(loanAppObj.BRE_Approval_Level__c) ? loanAppObj.BRE_Approval_Level__c : '';
            String prod = 'A_'+loanAppObj.Product__c;
            String productType = '';
            String productLabel = '';
            // Get Product Type
            ProductRTMap__mdt prodRecordType = ProductRTMap__mdt.getInstance(prod);
            if(prodRecordType!=null){
                productType = prodRecordType.RecordType__c;
                productLabel = prodRecordType.Label;
            }
            Map<String, FINegativeStatus_DeviationLevel_Mapping__mdt > mappingMetadataRecord = getMetadataRecordMap(productType);
            STring negativeReasons = fiRecord.Address_Negative_Reason__c;
            String profileNegativeReason = fiRecord.Profile_Negative_Reasons__c;
            List<Deviation__c> devList = new List<Deviation__c>();
            if(String.isNotBlank(negativeReasons)){
                for(String negativeReason : negativeReasons.split(';')){
                    Deviation__c devRecord = new Deviation__c ();
                    devRecord.Deviation_Type__c = 'FI-Negative Marked';
                    devRecord.Active__c = true;
                    devRecord.Loan_Application__c = fiRecord.Loan_Application__c;
                    devRecord.Mitigates__c = negativeReason;
                    devRecord.Details__c = negativeReason;
                    devRecord.Source__c = 'Manual';
                    devRecord.Field_Investigation__c = fiRecord.Id;
                    devRecord.Level__c = (mappingMetadataRecord.containsKey(negativeReason))? 
                        mappingMetadataRecord.get(negativeReason).Deviation_Level__c:'S4';
                    system.debug('here deviation'+devRecord);
                    devList.add(devRecord);
                }
            }
            /**SFAU-4789 Profile Deviation CHeck Added */
            if(String.isNotBlank(profileNegativeReason)){
                for(String negativeReason : profileNegativeReason.split(';')){
                    Deviation__c devRecord = new Deviation__c ();
                    devRecord.Deviation_Type__c = 'FI-Negative Marked';
                    devRecord.Active__c = true;
                    devRecord.Loan_Application__c = fiRecord.Loan_Application__c;
                    devRecord.Details__c = negativeReason;
                    devRecord.Source__c = 'Manual';
                    devRecord.Field_Investigation__c = fiRecord.Id;
                    devRecord.Level__c = (mappingMetadataRecord.containsKey(negativeReason))? 
                        mappingMetadataRecord.get(negativeReason).Deviation_Level__c:'S4';
                    devRecord.Mitigates__c = (devRecord.Level__c == 'S6')?System.Label.FI_Negative_Deviation_Reject_Label:negativeReason;    
                    devList.add(devRecord);
                }
            }
            if(!devList.isEmpty()){
                insert devList;
            }
            

            // START - Update BRE Approval Level on Loan Application based on Deviations
            
            // Current BRE Application Level on Loan Application
            Integer breApplicationLevel = 0;
            if(String.isNotBlank(loanAppObj.BRE_Application_Level__c)){
                breApplicationLevel = Integer.ValueOf(loanAppObj.BRE_Application_Level__c.substring(1));
            }
            // Query on Deviations and Set BRE Approval Level on Loan Application
            List<Deviation__c> highestPriorityDeviationLst = new List<Deviation__c>();
            highestPriorityDeviationLst = [SELECT Id, Level__c, Level_Priority__c FROM Deviation__c WHERE Loan_Application__c =: fiRecord.Loan_Application__c AND Department__c != 'Pricing' AND Level__c != null and Archived__c=false ORDER BY Level_Priority__c DESC];
            if(!highestPriorityDeviationLst.isEmpty()){
                if(productType == 'Two Wheeler'){
                    if(breApplicationLevel > highestPriorityDeviationLst[0].Level_Priority__c){
                        loanAppObj.BRE_Approval_Level__c = loanAppObj.BRE_Application_Level__c;
                    }
                    else{
                        loanAppObj.BRE_Approval_Level__c = highestPriorityDeviationLst[0].Level__c;
                    }
                }
                else if (productType == 'Four Wheeler'){
                    loanAppObj.BRE_Approval_Level__c = (String.isNotBlank(loanAppObj.BRE_Application_Level__c) ? loanAppObj.BRE_Application_Level__c : '' ) + highestPriorityDeviationLst[0].Level__c;
                }
                if (strLoanApprovalLevel != loanAppObj.BRE_Approval_Level__c) {
                    update loanAppObj;
                }
            }
            // 
            // END - Update BRE Approval Level on Loan Application based on Deviations
        }
        catch (Exception ex) {
            throw ex;
        }
    }
    
    private static Map<String, FINegativeStatus_DeviationLevel_Mapping__mdt> getMetadataRecordMap(String vehicleType) {
        Map<String, FINegativeStatus_DeviationLevel_Mapping__mdt> returnMap = new Map<String, FINegativeStatus_DeviationLevel_Mapping__mdt>();
        for(FINegativeStatus_DeviationLevel_Mapping__mdt rec : [SELECT Reason__c, Deviation_Level__c, Vehicle_Type__c 
                                                                from FINegativeStatus_DeviationLevel_Mapping__mdt WHERE Vehicle_Type__c=:vehicleType]) {
            returnMap.put(rec.Reason__c, rec);
        }
        return returnMap;
    }
    
    @AuraEnabled
    public static PermissionWrapper getUserAssignedPermissions() {
        PermissionWrapper returnWRapper = new PermissionWrapper();
        returnWRapper.isEditPermission = FeatureManagement.checkPermission('Edit_FI_Record');
        returnWRapper.isRetriggerPermission = FeatureManagement.checkPermission('ReTrigger_FI_Record');
        returnWRapper.isReassignPermission = FeatureManagement.checkPermission('ReAssign_FI_Record');
        returnWRapper.isUploadPermission = FeatureManagement.checkPermission('FI_Upload_Documents');
        return returnWRapper;
    }

    /*
    Description - Query on Address related to Loan Application
    Created By - Yash
    */
    @AuraEnabled
    public static List<ReTriggerAddressWrapper> getApplicantRelatedAddress(String recordId){
        List<ReTriggerAddressWrapper> addressWrapper = new List<ReTriggerAddressWrapper>();
        try{
            if(String.isBlank(recordId)){
                return addressWrapper;
            }
            List<Address__c> addressRecords = new List<Address__c>();
            addressRecords = [SELECT Id,Name,Address_Type__c, Applicant__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c,
                              City__c, State__c, Pincode__c,Applicant__r.RecordType.Name,
                              Applicant__r.Applicant_Name__c FROM Address__c WHERE Applicant__r.Loan__c = :recordId AND
                              (Applicant__r.RecordType.Name = 'Applicant' OR Applicant__r.RecordType.Name = 'Co-Applicant' OR Applicant__r.RecordType.Name = 'Guarantor') AND Source_Type__c != 'Cibil' AND Source_Type__c != 'CART' AND Applicant__r.IsInactive__c = false
                            ];
            if(!addressRecords.isEmpty()){
                for(Address__c addressRec : addressRecords){
                    String completeAddress = setAddress(addressRec);
                    addressWrapper.add(new ReTriggerAddressWrapper(addressRec.Id, addressRec.Applicant__r.Applicant_Name__c, completeAddress, addressRec.Address_Type__c, addressRec.Applicant__r.RecordType.Name));
                }
            }

        }catch(Exception ex){
            system.debug('exception ex'+ex.getMessage());
        }
        return addressWrapper;
    }

    private static String setAddress(Address__c addressRecord) {
        String streetName = nullCheckAndSetData(String.valueOf(addressRecord.Address_Line_1__c))+' '+nullCheckAndSetData(String.valueOf(addressRecord.Address_Line_2__c))+' '+nullCheckAndSetData(String.valueOf(addressRecord.Address_Line_3__c));
        String city = nullCheckAndSetData(String.valueOf(addressRecord.City__c));
        String state = nullCheckAndSetData(String.valueOf(addressRecord.State__c));
        String pincode = nullCheckAndSetData(String.valueOf(addressRecord.Pincode__c));
        return streetName+' '+city+' '+state+' '+pincode;
    }

    private static String nullCheckAndSetData(String dataValue) {
        return (String.isBlank(dataValue)? '' : dataValue);
    }

    public class ReTriggerAddressWrapper{
        @AuraEnabled public String addressRecId{get;set;}
        @AuraEnabled public String applicantName{get;set;}
        @AuraEnabled public String address{get;set;}
        @AuraEnabled public String addressType{get;set;}
        @AuraEnabled public Boolean checked{get;set;}
        @AuraEnabled public String applicantType{get;set;}

        public ReTriggerAddressWrapper(String addressRecId,String applicantName, String address, String addressType, String applicantType){
            this.addressRecId = addressRecId;
            this.applicantName = applicantName;
            this.address = address;
            this.addressType = addressType;
            this.checked = false;
            this.applicantType = applicantType;
        }
    }
    
    @AuraEnabled
    public static RejectResponseWrapper handleFIRecordReject(String fiRecordId, String fiCreditManager){ 
        RejectResponseWrapper resp = new RejectResponseWrapper();
        try{
            String queueNameLabelValue = System.Label.Field_Investigation_Centralize_Queue_Name;
            String centralisedQueueId = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = :queueNameLabelValue LIMIT 1].Id;
            if(String.isBlank(fiRecordId)){
                resp.isError = true;
                resp.errorMessage = 'Please provide a valid Field Investigation Id';
                return resp;
            }
            Field_Investigation__c fiRecord = new Field_Investigation__c();
            fiRecord.Id = fiRecordId;
            fiRecord.Stage__c = Label.FI_Stage_New;//Label.FI_Stage_Assigned;
            fiRecord.OwnerId = (String.isNotBlank(fiCreditManager))?Id.valueOf(fiCreditManager):centralisedQueueId;
            fiRecord.FI_Agent__c = null;
            update fiRecord;
        }catch(Exception ex){
            resp.isError = true;
            resp.errorMessage = ex.getMessage();
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),fiRecordId);
        }
        return resp;
    }

    /*
    @ description : Send Back FI Report to Agency/Agent SFAU-2999
    @ param1 : strRecordId
    @ return : Success or Failure Messge
    */
    @AuraEnabled
    public static FieldInvestigationWrap sendBackFIRecord (String strRecordId, String sendBackComments) {
        List<Field_Investigation__c> lstFieldInv = new List<Field_Investigation__c>();
        FieldInvestigationWrap objWrap = new FieldInvestigationWrap();
        objWrap.blnSuccess = true;
        Profile loggedInUserProfile = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1];
        if(loggedInUserProfile.Name!='Credit Manager' && !Test.isRunningTest()){
            throw new CustomException('Only Credit Manager can Send Back the Field Investigation Record');
        }
        try {
            lstFieldInv = [Select Id, Stage__c, FI_Status__c, FI_Profile_Status__c, FI_Agent__c, OwnerId, Send_Back_Comments__c,
                           Loan_Application__c, Loan_Application__r.Stage__c,
                           Send_Back_Counter__c from Field_Investigation__c where Id =: strRecordId];
            if (!lstFieldInv.isEmpty() && lstFieldInv[0].FI_Status__c != 'POSITIVE' && lstFieldInv[0].FI_Status__c != 'NEGATIVE') {
                throw new CustomException(Label.Field_Investigation_Send_Back_App_Not_complete_Msg);
            }
            List<String> restrictedStages = GlobalConstants.RESTRICTED_STAGES;
            if (!lstFieldInv.isEmpty() && (restrictedStages.contains(lstFieldInv[0].Loan_Application__r.Stage__c))){
                throw new CustomException('You cannot Send Back FI in the following stage: '+lstFieldInv[0].Loan_Application__r.Stage__c);
            }
            else if (!lstFieldInv.isEmpty()) {
                lstFieldInv[0].Stage__c = 'In Progress';
                lstFieldInv[0].FI_Status__c = 'In Progress';
                lstFieldInv[0].FI_Profile_Status__c = 'In Progress';
                lstFieldInv[0].Is_Send_Back__c = true;
                lstFieldInv[0].Send_Back_Counter__c = lstFieldInv[0].Send_Back_Counter__c != NULL ? lstFieldInv[0].Send_Back_Counter__c + 1 : 1;
                if (lstFieldInv[0].FI_Agent__c == NULL)
                    throw new CustomException(Label.Field_Investigation_Record_FI_Agent_Not_Assigned_Msg);
                lstFieldInv[0].OwnerId = lstFieldInv[0].FI_Agent__c;
                lstFieldInv[0].Send_Back_Comments__c = sendBackComments;
                update lstFieldInv[0];
                archiveNegativeDeviations(strRecordId);
                objWrap.strMessage = Label.Field_Investigation_Send_Back_Success_Msg;
            }
        }
        catch (Exception ex) {
            objWrap.blnSuccess = false;
            objWrap.strMessage = ex.getMessage();
            Log.error('Error in Field Investigation Send Back -- ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strRecordId);
        }
        return objWrap;
    } 

    private static void archiveNegativeDeviations(String fiId){
        try{
            if(String.isNotBlank(fiId)){
                List<Deviation__c> fiDeviations = [SELECT Id, Archived__c, Field_Investigation__c FROM Deviation__c WHERE Field_Investigation__c = :fiId];
                if(!fiDeviations.isEmpty()){
                    for(Deviation__c dev : fiDeviations){
                        dev.Archived__c =  true;
                    }
                    update fiDeviations;
                }
            }

        }catch(Exception ex){
            Log.error('Error in Archiving Send Back Deviations -- ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),fiId);
        }
        
    }


    public class RejectResponseWrapper{
        @AuraEnabled public Boolean isError{get;set;}
        @AuraEnabled public String errorMessage{get;set;}
        public RejectResponseWrapper(){
            this.isError = false;
            this.errorMessage = '';
        }
    }
    
    public class PermissionWrapper{
        @AuraEnabled
        public Boolean isEditPermission{get;set;}
        @AuraEnabled
        public Boolean isRetriggerPermission{get;set;}
        @AuraEnabled
        public Boolean isReassignPermission{get;set;}
        @AuraEnabled
        public Boolean isUploadPermission{get;set;}
    }
    
    /*Updating With Active Check Box in the Query 11 September 2023 */
    @AuraEnabled
    public static NegativeReasonWrapper getProfileAddressNegativePicklistValues(String vehicleType) {
        NegativeReasonWrapper retWrapper = new NegativeReasonWrapper();
        List<ReasonWrapper> addressReasons = new List<ReasonWrapper>();
        List<ReasonWrapper> profileReasons = new List<ReasonWrapper>();
        for(FINegativeStatus_DeviationLevel_Mapping__mdt rec : [SELECT Reason__c, Vehicle_Type__c , Negative_Status_Field__c,Is_Active__c  from 
                                                                FINegativeStatus_DeviationLevel_Mapping__mdt where Vehicle_Type__c=:vehicleType AND Is_Active__c = TRUE]) 
        {
            if(rec.Negative_Status_Field__c == 'Profile Negative Reason') {
                ReasonWrapper wrapRec = new ReasonWrapper();
                wrapRec.label = rec.Reason__c;
                wrapRec.value = rec.Reason__c;
                profileReasons.add(wrapRec);
           }
            if(rec.Negative_Status_Field__c == 'Address Negative Reason') {
                ReasonWrapper wrapRec = new ReasonWrapper();
                wrapRec.label = rec.Reason__c;
                wrapRec.value = rec.Reason__c;
                addressReasons.add(wrapRec);
            }
        }
        retWrapper.profileRelated = profileReasons;
        retWRapper.addressRelated = addressReasons;
        return retWrapper;
    }
    
    public class NegativeReasonWrapper{
        @Auraenabled
        public List<ReasonWrapper> profileRelated{get;set;}
        @Auraenabled
        public List<ReasonWrapper> addressRelated{get;set;}
        public NegativeReasonWrapper(){
            this.profileRelated = new List<ReasonWrapper>();
            this.addressRelated = new List<ReasonWrapper>();
        }
    }
    
    public class ReasonWrapper{
        @Auraenabled
        public String label{get;set;}
        @Auraenabled
        public String value{get;set;}
        public ReasonWrapper(){
            this.label = '';
            this.value = '';
        }
            
        

    }

    public class CustomException extends Exception {}

    // Method added for R2-2575
    @AuraEnabled
    public static Boolean tractorQuestionnaireCheck(String fieldInvestigationId) {
        for (ContentDocumentLink docLink : [
            SELECT Id, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE ContentDocument.Title = 'Personal Discussion' 
            AND LinkedEntityId = :fieldInvestigationId
        ]) {
            return true;
        }
        return false;
    }
}