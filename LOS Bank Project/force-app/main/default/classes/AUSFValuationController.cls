public  without sharing class AUSFValuationController {

    @AuraEnabled
    public static ValuationDetail getValuationDetails(String collId) {
        Map < String, List < PicklistWrapper >> valuatorNamdeCodes = new Map < String, List < PicklistWrapper >> ();
        valuatorNamdeCodes.put('Valuer_Name_Code__c', new List < PicklistWrapper > ());
        Boolean isInactive = false;
        ValuationDetail vl = new ValuationDetail();
        Collateral__c col = [SELECT ID, toLabel(Loan__r.Product__c), Certified_Value__c, toLabel(Collateral_Name__c), MMV_Master__r.Name, Vehicle_Number__c FROM Collateral__c WHERE Id =: collId WITH SECURITY_ENFORCED Limit 1];
        Valuation__c vla = new Valuation__c();
        vla.Product__c = col.Loan__r.Product__c;
        vla.Collateral_Type__c = col.Collateral_Name__c;
        //vla.MMV_Master__c=col.MMV_Master__r.Name;
        vla.Vehicle_Number__c = col.Vehicle_Number__c;
        If(col.Certified_Value__c != null && Integer.valueOf(col.Certified_Value__c) != 0) {
            Integer certifiedValue = Integer.valueOf(col.Certified_Value__c);
            if (certifiedValue > 0 && certifiedValue <= 1000000) {
                isInactive = true;
            } else if (certifiedValue > 1000000) {
                valuatorNamdeCodes.get('Valuer_Name_Code__c').add(new PicklistWrapper('Auto Inspect', 'Auto Inspect'));
                valuatorNamdeCodes.get('Valuer_Name_Code__c').add(new PicklistWrapper('Other valuation', 'Other valuation'));
            }
        } else if (Integer.valueOf(col.Certified_Value__c) == 0 || col.Certified_Value__c == null) {
            valuatorNamdeCodes.get('Valuer_Name_Code__c').add(new PicklistWrapper('Auto Inspect', 'Auto Inspect'));
            valuatorNamdeCodes.get('Valuer_Name_Code__c').add(new PicklistWrapper('Other valuation', 'Other valuation'));
            valuatorNamdeCodes.get('Valuer_Name_Code__c').add(new PicklistWrapper('Cando', 'Cando'));
        }
        vl.isTriggeringPointInActive = isInactive;
        vl.valuatorNamdeCodes = valuatorNamdeCodes;
        vl.valObj = vla;
        vl.referenceNumber = AUSFVehicleController.GenerateRandomNumber(15);
        return vl;
    }
    //CANDOLEAD API
    @AuraEnabled
    public static apiWrapper handleCandoLeadApi(Valuation__c valuationRecord, String integrationName, Id loanId, String variantName) {
        String respBody;
        String requestBody;
        Boolean boolResponse = false;
        apiWrapper wrapperInstance = new apiWrapper();
        try {
            if (integrationName != 'Other valuation') {
                String randomNumber = AUSFVehicleController.GenerateRandomNumber(15);
                String requestId = IntegrationUtility.getReferenceId();
                System.debug('valuationRecord-->' + valuationRecord);
                //Create Valuation Records
                // String valuationId= handleValuationInsertion(requestId,valuationRecord);
               

               
                //Applicant Details
                List < Applicant__c > applicantList = getApplicant(loanId);
                String applicantId = (applicantList != null) ? (applicantList[0].Id) : '';

                System.debug('applicantList-->' + applicantList);
                String customerMobile = (applicantList != null) ? (applicantList[0].Mobile_Number__c != null) ? String.valueof(applicantList[0].Mobile_Number__c) : '' : '';
                String customerName = (applicantList != null) ? (applicantList[0].First_Name__c != null) ? String.valueof(applicantList[0].First_Name__c) : '' : '';
                String customerEmail = (applicantList != null) ? (applicantList[0].Email__c != null) ? String.valueof(applicantList[0].Email__c) : '' : '';

                //MMV Master Detail
                String Mmv = variantName;
                String mmvFormatted = Mmv.replaceAll('_', ',');

                //User Detail
                User loggedinUser = [SELECT id, Name, FederationIdentifier,Employee_Code__c
                    FROM User
                    WHERE id =: Userinfo.getUserID() WITH SECURITY_ENFORCED
                ];

                String federationId = (loggedinUser.Employee_Code__c != null) ? (loggedinUser.Employee_Code__c) : '';

                //Address Details
                List < Address__c > addressList = new List < Address__c > ();
                String currentPincode = '';
                String addressDetail = '';
                Integer vehicalCategory = 0;
                if (!applicantList.isEmpty()) {
                    addressList = getCurrentAddressDetails(applicantList[0].Id);
                    if (addressList!=null && !addressList.isEmpty()) {
                        currentPincode = addressList[0].Pincode__c;
                        addressDetail = addressList[0].Address_Line_1__c + ',' + addressList[0].Address_Line_2__c + ',' + addressList[0].Address_Line_3__c + ',' + addressList[0].State__c + ',' + addressList[0].City__c + ',' + addressList[0].District__c + ',' + addressList[0].Area_Name__c + ',' + addressList[0].Area_Type__c + ',' + addressList[0].Taluka__c;
                    }
                    vehicalCategory = getVehicalCategory(valuationRecord.Product__c);
                }


                Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(integrationName);
                Map < String, Object > reqParam = new Map < String, Object > ();
                
                reqParam.put('channel', 'SFDC');  //cbs //June14
                reqParam.put('vehicle_cat', vehicalCategory); //1
                reqParam.put('cus_veh_regno', valuationRecord.Vehicle_Number__c); //TN717251414 //valuationRecord.Vehicle_Number__c
                reqParam.put('cus_mobile', customerMobile); //9078123456
                reqParam.put('cus_name', customerName); //Test
                reqParam.put('cus_pincode', currentPincode); //600041
                reqParam.put('cus_address', addressDetail); //Chennai
                reqParam.put('executive_name', valuationRecord.Coordinate_for_valuation_POC__c); //Test
                reqParam.put('executive_mobile', valuationRecord.Contact_Person_Mobile_Number__c); //9089123490
                reqParam.put('cus_email', customerEmail); //Test@gm.com
                reqParam.put('veh_mmv', mmvFormatted);
                reqParam.put('prospect_no',requestId); //KKK191278186514  //'SFDC'+randomNumber
                reqParam.put('valuator_name', federationId); // federationId
                reqParam.put('requestId',requestId);
                requestBody = AUSFVehicleHandler.generateLeadRequest(reqParam)[0];

                System.debug('requestBody-->' + requestBody);
                
                AUSFVehicleHandler.LeadRequestWrapper leadDetailsRequest =
                    (AUSFVehicleHandler.LeadRequestWrapper) JSON.deserialize(requestBody, AUSFVehicleHandler.LeadRequestWrapper.class);
                String recordId = applicantId;
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId,Request_Id__c=requestId);

                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = requestBody;
                calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                calloutRequestWrapper.masterRecord = objIntMapper;
                calloutRequestWrapper.checklistRecord = checklistRecord;
                IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
                respBody = calloutResponseWrapper.response;
                system.debug('respBody-->' + respBody);

                if(respBody.contains('The requested URL was rejected.')){
                    Valuation__c valuationObj = new Valuation__c();
                    valuationObj = valuationRecord;
                    //valuationObj.Cando_Request_Id__c = (requestNumber != null) ? requestNumber : '';
                    valuationObj.Cando_Request_Id__c = requestId;
                    if (Schema.sObjectType.Valuation__c.isCreateable()) {
                        insert valuationObj;
                    }
                }else{
                    AUSFVehicleHandler.leadResponse loanDetailsResponse =
                    (AUSFVehicleHandler.leadResponse) JSON.deserialize(respBody, AUSFVehicleHandler.leadResponse.class);

                System.debug('loanDetailsResponse-->' + loanDetailsResponse);
                String requestNumber;

                // if Success store the request number and other details in valuation object
                if (loanDetailsResponse.Status == 'Success') { //|| (loanDetailsResponse.RequestNo!=null)
                    //requestNumber = loanDetailsResponse.RequestNo;
                    boolResponse = true;

                } else {
                    boolResponse = false;
                }
                requestNumber = loanDetailsResponse.RequestNo;
                wrapperInstance.boolResponse = boolResponse;
                //Create Valuation Records
                Valuation__c valuationObj = new Valuation__c();
                valuationObj = valuationRecord;
                valuationObj.Request_Number__c = (requestNumber != null) ? requestNumber : '';
                //valuationObj.Cando_Request_Id__c = (requestNumber != null) ? requestNumber : '';
                valuationObj.Cando_Request_Id__c = requestId;
                if (Schema.sObjectType.Valuation__c.isCreateable()) {
                    insert valuationObj;
                }
                //System.debug('valuationObjInsertion-->' + valuationObj);
                wrapperInstance.valuationId = valuationObj.Id;
                
                //Call the Notification
                 if(valuationRecord.Action__c =='Retrigger'){
                    String phoneNo = (valuationObj.Contact_Person_Mobile_Number__c!=null)? valuationObj.Contact_Person_Mobile_Number__c : '';
                    NotificationHandler.sendNotification('Valuation Retrigger',loanId,phoneNo);
                }

                if(valuationRecord.Action__c  == 'Trigger'){
                    String phoneNo = (valuationObj.Contact_Person_Mobile_Number__c!=null)? valuationObj.Contact_Person_Mobile_Number__c : '';
                    NotificationHandler.sendNotification('Valuation initiate', loanId,phoneNo);
                }
                }
            } else {
                // Send a Notification
                String phoneNo = valuationRecord.Contact_Person_Mobile_Number__c;
               
                Valuation__c valuationObj = new Valuation__c();
                valuationObj = valuationRecord;
                valuationObj.Completion_Date_Time__c = System.today();

                if (Schema.sObjectType.Valuation__c.isCreateable()) {
                    insert valuationObj;
                    wrapperInstance.valuationId = valuationObj.Id;
                    NotificationHandler.sendNotification('Other Valuation initiate', loanId,phoneNo);
                }
            }
            CreditVerification.resetCreditVerificationOnLoan(loanId,'Valuation',false);
        } catch (Exception e) {
            System.debug('exception--->' + e.getMessage() + '---' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return wrapperInstance;
    }

  public static String  handleValuationInsertion(String requestId,  Valuation__c valuationRecord){
        Valuation__c valuationObj = new Valuation__c();
        valuationObj = valuationRecord;
        valuationObj.Cando_Request_Id__c = requestId;
        if (Schema.sObjectType.Valuation__c.isCreateable()) {
            insert valuationObj;
        }
        return valuationObj.Id;
    }

    @AuraEnabled
    public static void handleUpdateValuation(String referenceNo, String actionName, Decimal valuationAmount, String valuationVehicleNumber) {
        try {
            Valuation__c valuationObj = [SELECT Id, Reference_ID__c,Request_Number__c, Vehicle_Number__c, Action__c, Valuation_Identifier__c, Valuation_Amount__c, Cando_Request_Id__c, Collateral__r.Loan__c, Contact_Person_Mobile_Number__c, (SELECT Id, ContentDocumentId, ContentDocument.title, LinkedEntityId FROM ContentDocumentLinks ORDER BY SystemModstamp DESC LIMIT 1)
                FROM Valuation__c
                WHERE((Reference_ID__c =: referenceNo) OR(Action__c = 'Trigger'
                    AND Vehicle_Number__c =: valuationVehicleNumber)) WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1
            ];
            System.debug('valuationObj-->' +valuationObj);
            String contentDocumentId = '';
            if (valuationObj != null) {
                if (!(valuationObj.ContentDocumentLinks).isEmpty()) {
                    contentDocumentId = valuationObj.ContentDocumentLinks[0].ContentDocumentId;
                }
            }
            String loanId = (valuationObj.Collateral__r.Loan__c != null) ? valuationObj.Collateral__r.Loan__c : '';
            if (String.isNotBlank(contentDocumentId)) {
                
                ContentVersion cv = [SELECT Id, Title,VersionData, Shortend_Public_Url__c
                    FROM ContentVersion
                    WHERE ContentDocumentId =: contentDocumentId
                    ORDER BY CreatedDate DESC LIMIT 1
                ];

                insert new ContentDistribution(
                    Name = cv.Title,
                    ContentVersionId = cv.Id,
                    PreferencesAllowViewInBrowser = true
                );



                List < ContentDistribution > ContentDistributionList = [SELECT DistributionPublicUrl
                    FROM ContentDistribution
                    WHERE ContentDocumentId =: contentDocumentId ORDER BY CreatedDate DESC LIMIT 1
                ];
                String documentURL = '';
                if (ContentDistributionList.size() > 0) {
                    documentURL = ContentDistributionList[0].DistributionPublicUrl != null ? ContentDistributionList[0].DistributionPublicUrl : '';
                }

                List < Applicant__c > applicantList = NotificationHandler.getApplicant(loanId);
                
                System.debug('documentURL-->' +documentURL);
                 BitlyKarix.sendKarixRequest(valuationObj.Contact_Person_Mobile_Number__c, documentURL, applicantList[0].Id, cv.Id);

                /*ContentVersion cvInstance = new ContentVersion();
                cvInstance.ID = cv.Id;
                cvInstance.Shortend_Public_Url__c = url;
                update cvInstance;*/


            }

            if (String.isNotBlank(actionName)) {
                valuationObj.Action__c = actionName;
                if (actionName == 'Revoke') {
                    List < Applicant__c > applicantList = NotificationHandler.getApplicant(loanId);
                    String phoneNo = (valuationObj.Contact_Person_Mobile_Number__c != null) ? valuationObj.Contact_Person_Mobile_Number__c : '';

                    handleCandoReject(valuationObj.Request_Number__c,applicantList[0].Id,loanId,phoneNo);
                    
                }
            }

            if (valuationAmount != 0) {
                valuationObj.Valuation_Amount__c = valuationAmount;
                valuationObj.Valuation_Identifier__c = 'Manual';
                valuationObj.Completion_Date_Time__c = System.today();
            }


            if (Schema.sObjectType.Valuation__c.isUpdateable()) {
                update valuationObj;
                System.debug('valuationObjUpdation-->' + valuationObj);
                //calculate average and stamp at collateral 
                calculateAverage(valuationObj.Id, valuationObj.Cando_Request_Id__c);
                updateLoanValuation(loanId);
                NotificationHandler.sendNotification('Valuation Submission', loanId, '');

            }


        } catch (Exception e) {
            System.debug('exception--->' + e.getMessage() + '---' + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
        }
    }


    public static void handleCandoReject(String requestNO, String applicantId,String loanId,String phoneNo) {
        String requestBody;
        String respBody;
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('CANDOLEADCANCEL');
        Map < String, Object > reqParam = new Map < String, Object > ();
        
        reqParam.put('requestId', IntegrationUtility.getReferenceId());
        reqParam.put('channel', objIntMapper.Channel__c);
        reqParam.put('RequestNo', requestNO);
        reqParam.put('RejectedRemark', 'Rejected');
        requestBody = AUSFVehicleHandler.generateRejectRequest(reqParam)[0];


        String recordId = applicantId;
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId); // Request_Id__c = requestId

        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody = calloutResponseWrapper.response;
        system.debug('respBody-->' + respBody);
        // Call Notification
         NotificationHandler.sendNotification('Valuation Revoke', loanId, phoneNo);

    }

    @AuraEnabled
    public static void handleUpdateCollateral( Collateral__c collateralRecord){
        Collateral__c collateralObj = new Collateral__c();
        try{
            
            collateralObj = collateralRecord;
           // if(Schema.sObjectType.Collateral__c.isUpdateable()){
                update collateralObj;
           // }
           System.debug('collateralObj-->' +collateralObj);
        }catch (Exception e) {
            System.debug('exception--->' + e.getMessage() + '---' + e.getLineNumber());
            Log.error(e,Log.SeverityType.valueOf('High'),'');
            
        }
    }

    public static List < Applicant__c > getApplicant(String loanApplicationId) {
        try {
            List < Applicant__c > applicantList = [SELECT id, First_Name__c, Middle_Name__c, Last_Name__c, Mobile_Number__c, Email__c, Loan__c, RecordType.Name
                FROM Applicant__c
                WHERE Loan__c =: loanApplicationId
                AND RecordType.Name = 'Applicant'
                WITH SECURITY_ENFORCED
            ];
            if (!applicantList.isEmpty()) {
                return applicantList;
            } else {
                return null;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());

        }
    }

    public static List < Address__c > getCurrentAddressDetails(String applicantId) {
        try {
            List < Address__c > addressList = [SELECT id, Name, Distance_from_Branch__c, District__c, Address_Type__c, Applicant__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, State__c, City__c, Area_Name__c, Area_Type__c, Taluka__c, Pincode__c, Land_mark__c, Product__c, Stability__c, Status__c, Address_Source__c, Type__c
                FROM Address__c
                WHERE Applicant__c =: applicantId
                AND Address_Type__c != null
                AND Address_Type__c = 'Current'
                AND Source_Type__c != 'Cibil'
                WITH SECURITY_ENFORCED
            ];

            if (!addressList.isEmpty()) {
                return addressList;
            } else {
                return null;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());

        }
    }

    public static Integer getVehicalCategory(String productName) {

        List < ProductRTMap__mdt > productData = [SELECT MasterLabel, RecordType__c
            FROM ProductRTMap__mdt
            WHERE MasterLabel =: productName WITH SECURITY_ENFORCED
        ];
        Integer productCode = 0;

        if (!productData.isEmpty()) {
            if (productData[0].RecordType__c == 'Two Wheeler') {
                productCode = 1;
            } else if (productData[0].RecordType__c == 'Three Wheeler') {
                productCode = 2;
            } else if (productData[0].RecordType__c == 'Four Wheeler') {
                productCode = 3;
            } else if (productData[0].RecordType__c == 'Commercial Vehicle') {
                productCode = 4;
            } else if (productData[0].RecordType__c == 'FE') {
                productCode = 5;
            } else if (productData[0].RecordType__c == 'Construction Equipment') {
                productCode = 6;
            }
        }

        return productCode;
    }
    @AuraEnabled
    public static valueMasterWrapper getValueMasterDetails(Id loanId) {
        try {
            List < Generic_Master__c > valueMasterList = new List < Generic_Master__c > ();
            List < Loan_Application__c > loanApplication = [SELECT id, Branch_Master__r.State__r.Name
                FROM Loan_Application__c
                WHERE id =: loanId WITH SECURITY_ENFORCED
            ];

            String state = (loanApplication[0].Branch_Master__r.State__c != null) ? loanApplication[0].Branch_Master__r.State__r.Name : '';
            List<Generic_Master__c> masterList = [SELECT id, Agency_Name__c, State__c, Phone_No__c,RecordType.Name
                                                  FROM Generic_Master__c
                                                 WHERE  RecordType.Name='Valuer Master' WITH SECURITY_ENFORCED];
            System.debug('state-->' + state);
            if (String.isNotBlank(state)) {
                for(Generic_Master__c masterInstance : masterList){
                    if(masterInstance.State__c == state){
                        valueMasterList.add(masterInstance);
                    }
                }
               /* valueMasterList = [SELECT id, Agency_Name__c, State__c, Phone_No__c,RecordType.Name
                    FROM Generic_Master__c
                    WHERE State__c =: state
                    AND RecordType.Name='Valuer Master' WITH SECURITY_ENFORCED
                ];*/
            }
            valueMasterWrapper wrapperInstance = new valueMasterWrapper();
            wrapperInstance.selectedValueMaster = valueMasterList;
            wrapperInstance.valueMasterList = masterList;
            System.debug('wrapperInstance-->' +wrapperInstance);
            return wrapperInstance;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getLoanSchemeMasterDetails(Id loanId) {
        String schemeName = '';
        try {
            List < Loan_Application__c > loanApplication = [SELECT id, Scheme__r.Scheme_Name__c
                FROM Loan_Application__c
                WHERE id =: loanId WITH SECURITY_ENFORCED
            ];
            if (String.isNotBlank(loanApplication[0].Scheme__r.Scheme_Name__c)) {
                schemeName = loanApplication[0].Scheme__r.Scheme_Name__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return schemeName;
    }

    @AuraEnabled
    public static  Map<string,List<collateralvaluationWrapper>>  getCollateralDetails(Id collateralId,Id loanId) {
        Collateral__c collateralInstance;
        collateralvaluationWrapper collateralWrapper = new collateralvaluationWrapper();
      List<collateralvaluationWrapper> collateralList = new List<collateralvaluationWrapper>();
      List<collateralvaluationWrapper> valuationList = new List<collateralvaluationWrapper>();
        Map<string,List<collateralvaluationWrapper>> wrapperMap = new  Map<string,List<collateralvaluationWrapper>>();
        try {
            collateralInstance = [SELECT Id, Vehicle_Number__c,Fuel_Type__c,MMV_Master__r.Name, Make__c, Model__c, Engine_Number__c, HPN_With_Financiers_Name__c,Chasis_Number__c, Manufacture_Year__c, Owner_Serial_number__c, Vehicle_Color__c, Valuation_Amount__c,Kilometer__c,Manufacture_year_month__c, Registration_Date__c 
                FROM Collateral__c
                WHERE id =: collateralId WITH SECURITY_ENFORCED
            ];

            collateralWrapper.Id = collateralInstance.Id;
            collateralWrapper.Vehiclenumber = collateralInstance.Vehicle_Number__c!=null ? collateralInstance.Vehicle_Number__c :'';
            collateralWrapper.MakeModel = collateralInstance.Make__c;
            collateralWrapper.Enginenumber = collateralInstance.Engine_Number__c;
            collateralWrapper.Chassisnumber = collateralInstance.Chasis_Number__c;
            collateralWrapper.Manufacturingyear = collateralInstance.Manufacture_Year__c;
            String year = collateralInstance.Manufacture_year_month__c;
            String manufacturingYear;
            if(string.isNotBlank(year) && year.length() == 4){
                  manufacturingYear = year.substring(0, 4);
                  collateralWrapper.Manufacturingyear = manufacturingYear;
            }
            collateralWrapper.Registrationdate = collateralInstance.Registration_Date__c!=null ? String.valueof(collateralInstance.Registration_Date__c):'' ;
            collateralWrapper.OwnerSerialno = collateralInstance.Owner_Serial_number__c;
            collateralWrapper.Hypothication = collateralInstance.HPN_With_Financiers_Name__c;
            collateralWrapper.Color = collateralInstance.Vehicle_Color__c;
            collateralWrapper.Fuel = collateralInstance.Fuel_Type__c;
            collateralWrapper.ValuationAmount = collateralInstance.Valuation_Amount__c;
            collateralWrapper.Odometer = collateralInstance.Kilometer__c;
            collateralList.add(collateralWrapper);
            wrapperMap.put('Collateral',collateralList );
            
            List<Valuation__c> valuationRecord = [SELECT id,Response_Received__c, Major_remarks__c,Product__c,Other_state_and_list_from_master__c,Collateral_Type__c,MMV_Master__r.Name,Action__c,Valuer_Name_Code__c,Contact_Person_Mobile_Number__c,Coordinate_for_valuation_POC__c,Allocation_Date_Time__c,Completion_Date_Time__c,Collateral__r.Loan__c,isLatest__c,Vehicle_Number__c,Make_Model__c,Engine_number__c,Chassis_number__c,Manufacturing_year__c,Registration_date__c,Owner_Serial_no__c,Hypothication__c,Color__c,Odometer__c,Fuel__c,Vehicle_Condition__c,Valuation_Amount__c,(SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLinks ORDER BY SystemModstamp DESC  ),Final_remarks__c,Report__c
                                                  FROM Valuation__c
                                                  WHERE Collateral__r.Loan__c=:loanId
                                                  AND isLatest__c =true
                                                  AND Response_Received__c = 'Yes' WITH SECURITY_ENFORCED];
            if(valuationRecord!= null && valuationRecord.size()>0){
            for(Valuation__c valInstance : valuationRecord){
                collateralvaluationWrapper valuationWrapper = new collateralvaluationWrapper();
                valuationWrapper.Id = valInstance.Id;
                valuationWrapper.Vehiclenumber = valInstance.Vehicle_Number__c!=null ? valInstance.Vehicle_Number__c :'';
                valuationWrapper.VehicleColor = ( valInstance.Vehicle_Number__c!= collateralInstance.Vehicle_Number__c )? 'box-color' : '';
                valuationWrapper.MakeModel = valInstance.Make_Model__c;
                valuationWrapper.MakeColor = ( valInstance.Make_Model__c!= collateralInstance.MMV_Master__r.Name )? 'box-color' : '';
                valuationWrapper.Enginenumber = valInstance.Engine_number__c;
                valuationWrapper.EngineColor = ( valInstance.Engine_number__c!= collateralInstance.Engine_Number__c)? 'box-color' : '';
                valuationWrapper.Chassisnumber = valInstance.Chassis_number__c;
                valuationWrapper.ChasisColor = ( valInstance.Chassis_number__c!= collateralInstance.Chasis_Number__c)? 'box-color' : '';
                valuationWrapper.Manufacturingyear = valInstance.Manufacturing_year__c;
                valuationWrapper.ManufacturingColor = ( valInstance.Manufacturing_year__c!= collateralInstance.Manufacture_Year__c)? 'box-color' : '';
                valuationWrapper.Registrationdate = valInstance.Registration_date__c;
                //valuationWrapper.RegColor = ( valInstance.Registration_date__c!= collateralInstance.Manufacture_Year__c)? 'box-color' : '';
                valuationWrapper.OwnerSerialno = valInstance.Owner_Serial_no__c;
                valuationWrapper.OwnerColor = ( valInstance.Owner_Serial_no__c!= collateralInstance.Owner_Serial_number__c)? 'box-color' : '';
                valuationWrapper.Hypothication = valInstance.Hypothication__c;
                valuationWrapper.HypothicationColor = ( valInstance.Hypothication__c!= collateralInstance.HPN_With_Financiers_Name__c)? 'box-color' : '';
                valuationWrapper.Color =valInstance.Color__c;
                valuationWrapper.VhColorIdentifier = ( valInstance.Color__c!= collateralInstance.Vehicle_Color__c)? 'box-color' : '';
                valuationWrapper.Odometer = valInstance.Odometer__c;
               // valuationWrapper.OdometerColor = ( valInstance.Odometer__c!= collateralInstance.Vehicle_Color__c)? 'box-color' : '';
                valuationWrapper.Fuel  = valInstance.Fuel__c;
                valuationWrapper.FuelColor = ( valInstance.Fuel__c!= collateralInstance.Fuel_Type__c)? 'box-color' : '';
                valuationWrapper.VehicleCondition = valInstance.Vehicle_Condition__c;
                //valuationWrapper.ConditionColor = 
                valuationWrapper.ValuationAmount = String.valueof(valInstance.Valuation_Amount__c);
                valuationWrapper.ValuationAmountColor =  ( String.valueof(valInstance.Valuation_Amount__c)!= collateralInstance.Valuation_Amount__c)? 'box-color' : '';
                valuationWrapper.Finalremarks = valInstance.Final_remarks__c;
                valuationWrapper.Majorremarks = valInstance.Major_remarks__c;
                //valuationWrapper.FileMap = getRelatedFilesByRecordId(valInstance.Id);
                //valuationWrapper.remarksColor
                if(!(valInstance.ContentDocumentLinks).isEmpty() ){
                    valuationWrapper.FileId = valInstance.ContentDocumentLinks[0].ContentDocumentId;
                }
                valuationList.add(valuationWrapper);
                
            }
        }
            wrapperMap.put('Valuation',valuationList );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return wrapperMap;
    }

     //Method will be called from Integration Checklist trigger 
     public static void updateValuationDetails(List < Integration_Checklist__c > newRecordList, Map < Id, Integration_Checklist__c > oldRecordMap, Map < Id, Integration_Checklist__c > newRecordMap) {
        try {
            if ((newRecordList[0].Integration_Master_Name__c == 'CANDOLEAD' || newRecordList[0].Integration_Master_Name__c == 'GENNEWLEAD' ) && (String.isNotBlank(newRecordList[0].Callback_Request__c))) {
                
               // String valuationId =  newRecordList[0].Valuation__c;
               Valuation__c valuationObj= [Select id,Name,Cando_Request_Id__c from Valuation__c where Cando_Request_Id__c=:newRecordList[0].Request_Id__c  WITH SECURITY_ENFORCED LIMIT 1] ;
               String valuationId = valuationObj.Id;
                String checklistRequestId = newRecordList[0].Request_Id__c;

                //update the other old valuation records islatest field to false
                updateOldValuationRcords(valuationId,checklistRequestId);
                
              

                List<Valuation__c> valuationList =  new List<Valuation__c>();
                System.debug('newRecordList-->' + newRecordList[0].Callback_Request__c);
              
               
               // Map < String, Object > jsonData = (Map < String, Object > ) JSON.deserializeUntyped(newRecordList[0].Callback_Request__c);
                //List < Object > data = (List < Object > ) jsonData.get('Result');
                Boolean valuationQueryNotification=false;
              //  List < Object > data = (List < Object > ) JSON.deserializeUntyped(newRecordList[0].Callback_Request__c);
              //  for (Object dataInstance: data) {
                    //Map < String, Object > callBackData = (Map < String, Object > )((Map < String, Object > ) dataInstance);
                    String jsonString = newRecordList[0].Callback_Request__c;
                    jsonString = jsonString.replace('\\', '');
                    Map < String, Object > callBackData = (Map < String, Object > )JSON.deserializeUntyped(jsonString);
                   // System.debug('requiredDate-->' +callBackData);\
                    //Update Valuation Records from the Response
                    Valuation__c valObj = new Valuation__c();
                    valObj.Id = valuationId;
                    valObj.Response_Received__c ='Yes';
                    valObj.isLatest__c = true;
                    valObj.Vehicle_Number__c = (String)callBackData.get('VehicleNumber'); 
                   // valObj.Make_Model__c = (String)callBackData.get('make') +'_' + (String)callBackData.get('model') ; 
                    valObj.Engine_number__c = (String)callBackData.get('EngineNumber'); 
                    valObj.Chassis_number__c = (String)callBackData.get('ChassisNumber'); 
                    valObj.Manufacturing_year__c = (String)callBackData.get('ManufacturingYear'); 
                    valObj.Registration_date__c = (String)callBackData.get('RegistrationDate'); 
                    valObj.Owner_Serial_no__c = String.valueof(callBackData.get('OwnerSerialNo')); 
                    valObj.Hypothication__c = (String)callBackData.get('Hypothication'); 
                    valObj.Color__c = (String)callBackData.get('Color'); 
                    valObj.Odometer__c = String.valueOf(callBackData.get('Odometer')); 
                    valObj.Fuel__c = (String)callBackData.get('Fuel'); 
                    valObj.Vehicle_Condition__c = (String)callBackData.get('VehicleCondition'); 
                    valObj.Valuation_Amount__c = Decimal.valueof((String)callBackData.get('ValuationAmount')); 
                    valObj.Final_remarks__c = (String)callBackData.get('FinalRemarks'); 
                    valuationQueryNotification =  valObj.Final_remarks__c!=null ? true : false;
                    //valObj.Report__c = (String)callBackData.get('report_url'); 
                    valObj.Completion_Date_Time__c = System.today();
                    valObj.Valuation_Identifier__c='API';
                    valuationList.add(valObj);
                //}

                if ((!valuationList.isEmpty()) && (Schema.sObjectType.Valuation__c.isUpdateable())) {
                    update valuationList;
                    //Stamp the average of valuationamount of valuation records on the collateral object  based on the action
                    calculateAverage(valuationId, checklistRequestId);
                    Valuation__c valObj1 = [SELECT id, Collateral__r.Loan__c FROM Valuation__c WHERE id =: valuationId];
                    String loanId = (valObj1.Collateral__r.Loan__c != null) ? valObj1.Collateral__r.Loan__c : '';
                    updateLoanValuation(loanId);
                    NotificationHandler.sendNotification('Valuation Submission', loanId, '');
                    if(valuationQueryNotification == true){
                        NotificationHandler.sendNotification('Valuation Query', loanId, '');
                    }
                }
                System.debug('valuationList-->' +valuationList);
            }
            
        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('exception-->' + e.getLineNumber());
            Log.error(e, Log.SeverityType.valueOf('High'), '');
            throw new AuraHandledException(e.getMessage());
            
        }
    }

    @future
    public static void updateLoanValuation(String loanId){
        //Update the Loan Application Valuation Completion Date
        Loan_Application__c loanApplicationInstance =  new Loan_Application__c();
        loanApplicationInstance.Id = loanId;
        loanApplicationInstance.Valuation_Completion_Date__c = System.today();
        if(Schema.sObjectType.Loan_Application__c.isUpdateable()){
            update loanApplicationInstance;
        }
    }
    public static void updateOldValuationRcords(String valuationId,String checklistRequestId){
        List<Valuation__c> valuationOldRecords = [SELECT id,Cando_Request_Id__c,isLatest__c
                                                  FROM Valuation__c
                                                  WHERE Cando_Request_Id__c=: checklistRequestId
                                                  AND id!=:valuationId WITH SECURITY_ENFORCED];
        System.debug('valuationOldRecords-->' +valuationOldRecords);
        List<Valuation__c > valObjRecords = new List<Valuation__c>();
        if(!valuationOldRecords.isEmpty()){
            for(Valuation__c valObj : valuationOldRecords){
                valObj.isLatest__c = false;
                valObjRecords.add(valObj);
            }
        }
       

        if(!valObjRecords.isEmpty()){
            update valObjRecords;
        }
    }

    //Stamp the average on the Collateral object 
    public static void calculateAverage(String valuationId, String checklistRequestId) {
        List < Valuation__c > valuationRecords = [SELECT Id, Cando_Request_Id__c, isLatest__c, Action__c, Collateral__c, Valuation_Amount__c,Collateral__r.Loan__c
            FROM Valuation__c
            WHERE Cando_Request_Id__c =: checklistRequestId 
            WITH SECURITY_ENFORCED
        ];
        String action;
        String collateralId;
        Loan_Application__c loanNewInstance = new Loan_Application__c();
        Map < String, Valuation__c > valuationActionMap = new Map < String, Valuation__c > ();
        for (Valuation__c valuationInstance: valuationRecords) {
            valuationActionMap.put(valuationInstance.Action__c, valuationInstance);
            if (valuationInstance.Id == valuationId) {
                action = valuationInstance.Action__c;
                collateralId = valuationInstance.Collateral__c;
            }

        }
        Decimal Average = 0;
        if (action == 'Trigger') {
            Valuation__c valuationTriggerRecord = (valuationActionMap.get('Trigger') != null) ? valuationActionMap.get('Trigger') : null;
            Average = valuationTriggerRecord.Valuation_Amount__c;
        }
        if (action == 'Retrigger') {
            Valuation__c valuationTriggerRecord = (valuationActionMap.get('Trigger') != null) ? valuationActionMap.get('Trigger') : null;
            Valuation__c valuationReassignRecord = (valuationActionMap.get('Reassign') != null) ? valuationActionMap.get('Reassign') : null;
            Valuation__c valuationReTriggerRecord = (valuationActionMap.get('Retrigger') != null) ? valuationActionMap.get('Retrigger') : null;
            if ((valuationTriggerRecord != null) && (valuationReassignRecord == null)) {
                Average = (valuationTriggerRecord.Valuation_Amount__c + valuationReTriggerRecord.Valuation_Amount__c) / 2;
            } else if ((valuationReassignRecord != null) && (valuationTriggerRecord == null)) {
                Average = (valuationReassignRecord.Valuation_Amount__c + valuationReTriggerRecord.Valuation_Amount__c) / 2;
            } else if((valuationReassignRecord != null) && (valuationTriggerRecord != null)) {
                Average = (valuationReassignRecord.Valuation_Amount__c + valuationReTriggerRecord.Valuation_Amount__c) / 2;
            }
        }

        if (action == 'Reassign') {
            Valuation__c valuationReassignRecord = (valuationActionMap.get('Reassign') != null) ? valuationActionMap.get('Reassign') : null;
            Average = valuationReassignRecord.Valuation_Amount__c;
        }
        System.debug('Average-->' + Average);
        Collateral__c collateralRecord = [SELECT id, Valuation_Amount__c, Application_Proceed__c, Approval_Required__c, Final_Vehicle_Cost__c,Loan__c FROM Collateral__c WHERE id =: collateralId WITH SECURITY_ENFORCED LIMIT 1];
        if (collateralRecord != null) {
            Collateral__c collateralInstance = new Collateral__c();
            collateralInstance.Id = collateralRecord.Id;
            collateralInstance.Valuation_Amount__c = (Average != 0) ? String.valueof(Average) : '';

            Decimal DifferencePerc=0;
            if (collateralRecord.Final_Vehicle_Cost__c != null) {
                DifferencePerc = ((collateralRecord.Final_Vehicle_Cost__c - Average) / collateralRecord.Final_Vehicle_Cost__c) * 100;
            }
                //If the difference is equal to or less than 2% (% is configurable) then application can proceed from PSD stag
                Decimal PercentageCheck = Decimal.valueof(System.label.PercentageDifference);
                if (DifferencePerc <= PercentageCheck) {
                    collateralInstance.Application_Proceed__c = true;
                    collateralInstance.Approval_Required__c = true;
                }
                //valuation amount is more than "Final Vehicle cost" then no approval required
                if (Average > collateralRecord.Final_Vehicle_Cost__c) {
                    collateralInstance.Approval_Required__c = false;
                } else {
                    collateralInstance.Approval_Required__c = true;
                }

                //Update these details on loan application  valuation application proceed and valuation Approval Required
                String loanId = collateralRecord.Loan__c;

                Loan_Application__c loanInstance = [SELECT id,Name,Valuation_Approval_Required__c,Valuation_Application_Proceed__c	
                                                    FROM Loan_Application__c 
                                                    WHERE id=:loanId WITH SECURITY_ENFORCED];

                
                loanNewInstance.Id = loanInstance.Id;
                loanNewInstance.Valuation_Approval_Required__c =  collateralInstance.Approval_Required__c ;
                loanNewInstance.Valuation_Application_Proceed__c = collateralInstance.Application_Proceed__c;
                  
            
            if (Schema.sObjectType.Collateral__c.isUpdateable()) {
                update collateralInstance;
            }
            if (Schema.sObjectType.Loan_Application__c.isUpdateable()) {
                update loanNewInstance;
            }

            System.debug('collateralInstance-->' + collateralInstance);
        }

    }
    //Method will be called from ContentVersion trigger 
    public static void handleValuationCallBackResponse(Map < Id, ContentVersion > contentVersionMap) {
        try {
            Map < Id, Integration_Checklist__c > newICMap = new Map < Id, Integration_Checklist__c > ();
            Map < String, ContentVersion > newRequestIdVSCVMap = new Map < String, ContentVersion > ();
            List < Bank_Account_Records__c > bankrecordsToInsert = new List < Bank_Account_Records__c > ();
            Map < Id, ContentDocumentLink > mapIdVScdl = new Map < Id, ContentDocumentLink > ();
            List < ContentVersion > cvList = [select Id, Request_id__c, VersionData,Title, ContentDocumentId from ContentVersion where id in: contentVersionMap.keySet()];
            
            for (ContentVersion cv: cvList) {
                if (cv.Request_id__c != null && cv.Request_id__c != '') {
                    newRequestIdVSCVMap.put(cv.Request_id__c, cv);
                }
            }
            
           // system.debug('newRequestIdVSCVMap' + newRequestIdVSCVMap.keySet());

            List < Integration_Checklist__c > intCheckList = [SELECT Id, Request_Id__c, Applicant__c, Integration_Master__c, Integration_Master__r.name FROM Integration_Checklist__c WHERE Request_Id__c in: newRequestIdVSCVMap.keySet() AND (Integration_Master__r.Name = 'CANDOLEAD' OR Integration_Master__r.Name = 'GENNEWLEAD'  )
                order by createddate desc
            ];
            List < Valuation__c > valuationRecordList = [SELECT Id, Name, Cando_Request_Id__c,Collateral__c
                FROM Valuation__c
                WHERE Cando_Request_Id__c IN: newRequestIdVSCVMap.keySet()
            ];

            List < ContentDocumentLink > cdlList = new List < ContentDocumentLink > ();
            List < ContentDocumentLink > cdValuationlList = new List < ContentDocumentLink > ();
            List < ContentDocumentLink > docChecklList = new List < ContentDocumentLink > ();
            Set<Id> contentDocIDs = new set<ID>();
            for (Integration_Checklist__c ic: intCheckList) {
                if (newRequestIdVSCVMap.keySet().contains(ic.Request_Id__c)) {
                    ContentVersion cvRecord = newRequestIdVSCVMap.get(ic.Request_Id__c);
                    ContentDocumentLink cdlRecord = new ContentDocumentLink();
                    cdlRecord.ContentDocumentId = cvRecord.ContentDocumentId;
                    cdlRecord.LinkedEntityId = ic.Id;
                    contentDocIDs.add(cvRecord.ContentDocumentId);
                    cdlList.add(cdlRecord);

                }
            }
            if (!cdlList.isEmpty()) {
                insert cdlList;
            }

            //to update the title with extension
            List<ContentDocument> cd = [SELECT Id, Title FROM ContentDocument WHERE Id IN : contentDocIDs];
            List<ContentDocument> cdUpdateList = new  List<ContentDocument>();
            for(ContentDocument cdInstance : cd){
                cdInstance.Title = cdInstance.Title +'.pdf';
                cdUpdateList.add(cdInstance);
            }
            if (!cdUpdateList.isEmpty()) {
                update cdUpdateList;
            }
             
            //Linking Bank Account Records to Content Document
            for (Valuation__c recordInstance: valuationRecordList) {
                if (newRequestIdVSCVMap.keySet().contains(recordInstance.Cando_Request_Id__c)) {
                    ContentVersion cvRecord = newRequestIdVSCVMap.get(recordInstance.Cando_Request_Id__c);
                    ContentDocumentLink cdlRecord = new ContentDocumentLink();
                    cdlRecord.ContentDocumentId = cvRecord.ContentDocumentId;
                    cdlRecord.LinkedEntityId = recordInstance.Id;
                    cdValuationlList.add(cdlRecord);
                }
            }

            if (!cdValuationlList.isEmpty()) {
                insert cdValuationlList;
            }
            //Query Collateral 
            if(valuationRecordList!=null && !valuationRecordList.isEmpty() && valuationRecordList.size()>0){
				String collateralId = String.isNotBlank(valuationRecordList[0].Collateral__c) ? valuationRecordList[0].Collateral__c :'';
            if(String.isNotBlank(collateralId)){
                Collateral__c collateralList = [SELECT id,Name,(SELECT id,name FROM Document_Checklists__r WHERE Document_Master__r.Name = 'AUWheels0014') FROM Collateral__c WHERE id=:valuationRecordList[0].Collateral__c];
                if(collateralList!=null && collateralList.Document_Checklists__r!=null){
                    List<Document_Checklist__c> docList = collateralList.Document_Checklists__r;
                    for (Document_Checklist__c recordInstance: docList) {
                       
                            ContentVersion cvRecord = cvList[0];
                            ContentDocumentLink cdlRecord = new ContentDocumentLink();
                            cdlRecord.ContentDocumentId = cvRecord.ContentDocumentId;
                            cdlRecord.LinkedEntityId = recordInstance.Id;
                            docChecklList.add(cdlRecord);
                        
                    }
                    if (!docChecklList.isEmpty()) {
                        insert docChecklList;
                    }
                }
            }
            }
            
           
           
        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('exception-->' + e.getLineNumber());
            Log.error(e, Log.SeverityType.valueOf('High'), '');
           // throw new AuraHandledException(e.getMessage());
        }

    }

    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
 
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
            FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }

     @AuraEnabled
    public static Boolean getValuationRecord(String loanId){// Added for resolution of this BUG SFAU-2854
        Boolean isRecordPresent;
        String schemeName = getLoanSchemeMasterDetails(loanId);
        //AUSF_Branch_topup
        List<Collateral__c> collaterals = [SELECT id, Name,Loan__c,Certified_Value__c, Loan__r.Dealer_Master__c, Loan__r.Dealer_Master__r.Certified_Value__c
                                    FROM Collateral__c
                                    WHERE Loan__c =:loanId AND RecordTypeId IN: GlobalConstants.colRecordTypeIds AND Is_Deleted__c = FALSE
                                   ];
        Set<Id> collateralIds = new Set<Id>(); 
        if(!collaterals.isEmpty() && collaterals.size()>0){
            for(Collateral__c collateral : collaterals){
                collateralIds.add(collateral.Id);
            }
        }                    
       

        List<Valuation__c> valuationList = new List<Valuation__c>();                                    
        if(!collaterals.isEmpty()){
            Collateral__c collateral = collaterals[0];
            valuationList = [SELECT id,Name,Collateral__r.Loan__c ,Collateral__c
                            FROM Valuation__c
                            WHERE Collateral__c IN :collateralIds
                           ];
            // Don't consider Certified value if not a certified dealer SFAU-4476
            if(collateral.Loan__r.Dealer_Master__c == NULL || collateral.Loan__r.Dealer_Master__r.Certified_Value__c != 'Yes'){
                return !valuationList.isEmpty();
            }
        }
        if(valuationList!=null && valuationList.size()>0){
            isRecordPresent = true;
        }else{
            isRecordPresent = false;
        }
        System.debug('schemeName==>' +schemeName);
        if(String.isNotBlank(schemeName)){
            if(schemeName == System.label.AUSF_Branch_topup){
            isRecordPresent = true;
        	} 
        }
        for(Collateral__c collateralInstance : collaterals){ //12 Jul
            if(String.isNotBlank(collateralInstance.Certified_Value__c)){
                Decimal certified = Decimal.valueof(collateralInstance.Certified_Value__c);
                if(certified>0 && certified<=1000000 ){
                    isRecordPresent = true;
                }
            }else if(String.isBlank(collateralInstance.Certified_Value__c)){ //15 jul
                isRecordPresent = true;
            }
        }
       
		System.debug('isRecordPresent-->' +isRecordPresent);
        return isRecordPresent;
    }
    @AuraEnabled
    public static List<Valuation__c> getLatestValuationRecords(String loanId){
        try {
            List<Collateral__c> collateral = [SELECT id, Name,Loan__c
                                    FROM Collateral__c
                                    WHERE Loan__c =:loanId
                                    WITH SECURITY_ENFORCED];

        List<Valuation__c> valuationList = new List<Valuation__c>();                                    
        if(collateral!=null){
            valuationList = [SELECT id,Name,Collateral__r.Loan__c ,CreatedDate,Action__c,Valuer_Name_Code__c,Other_state_and_list_from_master__c,Coordinate_for_valuation_POC__c,Contact_Person_Mobile_Number__c ,Collateral__r.RecordType.Name,Collateral__r.Is_Deleted__c
                            FROM Valuation__c
                            WHERE Collateral__r.Loan__c=:loanId 
                            AND Action__c!='Revoke'
                            AND Collateral__r.RecordType.Name!='Existing Collateral'
                            AND Collateral__r.Is_Deleted__c = false
                            ORDER BY CreatedDate DESC 
                            LIMIT 1
                           ]; 
        }
        return valuationList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean getGradingValue(String loanId){
        try {
            Boolean showPopUp = false;
            Loan_Application__c loanInstance = [SELECT id,Dealer_Master__c 
                                                FROM Loan_Application__c
                                                WHERE id=:loanId 
                                                WITH SECURITY_ENFORCED];
                                                

            String dealerMaster = loanInstance.Dealer_Master__c;
            System.debug('branchMaster-->' +dealerMaster);
            if(String.isNotBlank(dealerMaster)){
                List<Account> accList = [SELECT id,Name,Grading__c,Certified_Value__c
                                       FROM  Account
                                       WHERE Id=:dealerMaster
                                       AND Grading__c ='Platinum-Certified'
                                       AND  Certified_Value__c ='Yes'];

                if(accList!=null && accList.size()>0){
                    showPopUp = true;
                }else{
                    showPopUp = false;
                }
                
            }
            return showPopUp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class PicklistWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class ValuationDetail {
        @AuraEnabled
        public Valuation__c valObj;
        @AuraEnabled
        public String referenceNumber;
        @AuraEnabled
        public Map < String, List < PicklistWrapper >> valuatorNamdeCodes;
        @AuraEnabled
        public Boolean isTriggeringPointInActive;
    }

    public class apiWrapper {
        @AuraEnabled public Boolean boolResponse = false;
        @AuraEnabled public String valuationId = '';
        @AuraEnabled public Valuation__c valuationRecord;
    }

    public class collateralvaluationWrapper{
        @AuraEnabled public String Id='';
        @AuraEnabled public String Vehiclenumber =''; 
        @AuraEnabled public String VehicleColor=''; 
        @AuraEnabled public String MakeModel =''; 
        @AuraEnabled public String MakeColor=''; 
        @AuraEnabled public String Enginenumber =''; 
        @AuraEnabled public String EngineColor=''; 
        @AuraEnabled public String Chassisnumber =''; 
        @AuraEnabled public String ChasisColor=''; 
        @AuraEnabled public String Manufacturingyear =''; 
        @AuraEnabled public String ManufacturingColor=''; 
        @AuraEnabled public String Registrationdate =''; 
        @AuraEnabled public String RegColor=''; 
        @AuraEnabled public String OwnerSerialno =''; 
        @AuraEnabled public String OwnerColor=''; 
        @AuraEnabled public String Hypothication =''; 
        @AuraEnabled public String HypothicationColor =''; 
        @AuraEnabled public String Color =''; 
        @AuraEnabled public String VhColorIdentifier =''; 
        @AuraEnabled public String Odometer =''; 
        @AuraEnabled public String OdometerColor =''; 
        @AuraEnabled public String Fuel =''; 
        @AuraEnabled public String FuelColor =''; 
        @AuraEnabled public String VehicleCondition =''; 
        @AuraEnabled public String ConditionColor =''; 
        @AuraEnabled public String ValuationAmount =''; 
        @AuraEnabled public String ValuationAmountColor =''; 
        @AuraEnabled public String Finalremarks =''; 
        @AuraEnabled public String remarksColor =''; 
        @AuraEnabled public String Majorremarks='';
        @AuraEnabled public Map<Id,String> FileMap = new  Map<Id,String>();
        @AuraEnabled public String FileId ='';
    }

    public class valueMasterWrapper {
        @AuraEnabled public List < Generic_Master__c > selectedValueMaster;
        @AuraEnabled public List < Generic_Master__c > valueMasterList; 
        
        public valueMasterWrapper() {
            selectedValueMaster = new List< Generic_Master__c >();
            valueMasterList =  new List< Generic_Master__c > ();
        }
    }
}