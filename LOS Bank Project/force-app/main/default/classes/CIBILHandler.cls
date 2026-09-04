public with Sharing class CIBILHandler {
    public Map<String, String> fldApiNameToIdentifier;
    public Map<String, Integer> dpdCodeToHighestRange;
    public Map<String, String> cibilNameToValueMap;
    public Map<String, String> cibilValueToNameMap;
    Map<String, Integer> dpdMap = new Map<String, Integer>{'SMA' => 89, 'SUB' => 90, 'DST' => 365, 'LSS' => 1095, 'XXX' => 0, 'STD' => 0};
    Map<String, Integer> dpdDenominatorCount = new Map<String, Integer>{'SMA' => 1, 'SUB' => 1, 'DST' => 1, 'LSS' => 1, 'XXX' => 0, 'STD' => 1};
    public static Applicant__c appObj;
    public CIBILHandler(){
        this.cibilNameToValueMap = new Map<String, String>();
        this.cibilValueToNameMap = new Map<String, String>();
        for(Generic_Master__c gm : [Select Id, Type__c, Name__c, Value__c  from Generic_Master__c where (Bureau__c ='CIBIL' AND Type__c != Null AND Name__c != Null AND Value__c != Null) WITH SECURITY_ENFORCED])
        {
            this.cibilNameToValueMap.put(gm.Type__c+'-'+gm.Name__c.toLowerCase(), gm.Value__c);
            this.cibilValueToNameMap.put(gm.Type__c+'-'+gm.Value__c, gm.Name__c);
        }
        
        this.fldApiNameToIdentifier = new Map<String, String>{
            'PAN__c' => 'PAN No',
                'Aadhaar_Number__c' => 'Aadhaar No',
                'Voter_Id__c' => 'Voter Id',
                'Passport_Number__c' => 'Passport No',
                'Driving_License_Id__c' => 'DL No'
                };
                    
                    this.dpdCodeToHighestRange = new Map<String, Integer>{
                        'XXX' => 0,
                            'STD' => 0,
                            'SMA' => 30, 
                            'SUB' => 365, 
                            'DBT' => 1095
                            };
                                
                                system.debug('cibilNameToValueMap'+cibilNameToValueMap);
        system.debug('cibilValueToNameMap'+cibilValueToNameMap);
        system.debug('fldApiNameToIdentifier'+fldApiNameToIdentifier);
        system.debug('dpdCodeToHighestRange'+dpdCodeToHighestRange);
        
    }
    
    
    
    public String getCibilValue(String sType, String sName){
        String value = '';
        if(String.isNotBlank(sName) && cibilNameToValueMap.containsKey(sType+'-'+sName.toLowerCase())){
            value = cibilNameToValueMap.get(sType+'-'+sName.toLowerCase());
        }
        return value;
    }
    
    public String getCibilName(String sType, String sValue){
        String name = '';
        if(cibilValueToNameMap.containsKey(sType+'-'+sValue)){
            name = cibilValueToNameMap.get(sType+'-'+sValue);
        }
        return name;
    }
    
    
    public List<String> callValidateCibilInputData(String appRecId){
        system.debug('appRecId'+appRecId);
        Integration_Master__c masterobj = [select id,Active__c, Category__c, Is_Mandatory__c, Source_of_Entry__c,(select id,name,Field_Name__c,Child_Relationship_Name__c, Integration_Master__c from Interface_Inputs__r) from Integration_Master__c where name ='Cibil Individual' WITH SECURITY_ENFORCED];
        
        Integration_Checklist__c intChkObj = new Integration_Checklist__c();
        intChkObj.Integration_Master__c = masterobj.Id;
        intChkObj.Applicant__c = appRecId;
        
        Applicant__c applicantRecord = [Select id from Applicant__c where Id =: appRecId WITH SECURITY_ENFORCED];
        //  applicantRecord.Id = appRecId;
        
        
        
        List<SObject> objList = new List<SObject>();
        objList.add(applicantRecord);
        objList.add(intChkObj);
        objList.add(masterobj);
        return validateInputData(objList);
    }
    
    
    public List<String> validateInputData(List<Object> recordList) {
        if (recordList.isEmpty()) {
            return new List<String>();
        }
        List<String> validationErrorsList = new List<String>();
        
        for (Object each : recordList) {
            system.debug('each'+each);
            CommonCalloutEventPublisher.AutoIntegrationsInputWrapper inputWrapper = (CommonCalloutEventPublisher.AutoIntegrationsInputWrapper) each;
            System.debug('dynamic Query Input'+inputWrapper.dynamicQueryInput);
            Applicant__c applicantRecord = (Applicant__c) inputWrapper.dynamicQueryInput;
            Map<String, Set<String>> applicantRecordFieldsMap = (Map<String, Set<String>>) inputWrapper.objectToInterfaceInputsMap;
            System.debug('applicantRecord'+ applicantRecord);
            System.debug('applicantRecordFieldsMap'+ applicantRecordFieldsMap);
            List<String> validationFieldList = new  List<String>();
            List<String> validationObjectList = new  List<String>();
            
            for(String key: applicantRecordFieldsMap.keySet()){
                system.debug('key'+key);
                if(key.toLowerCase() == 'Addresses__r'){
                    for(String element : applicantRecordFieldsMap.get(key)){
                        system.debug('applicantRecord String'+String.valueOf(applicantRecord));
                        system.debug('element'+element);
                        if(!String.valueOf(applicantRecord).contains(element)){
                            validationFieldList.add(element);
                        }
                    }
                }
                if(key.toLowerCase() == 'Applicant__c'){
                    for(String element : applicantRecordFieldsMap.get(key)){
                        system.debug('applicantRecord String'+String.valueOf(applicantRecord));
                        system.debug('element'+element);
                        if(!String.valueOf(applicantRecord).contains(element)){
                            validationFieldList.add(element);
                        }
                    }
                }
            }
            system.debug('validationFieldList'+validationFieldList);
            if(validationFieldList.size() > 0){
                validationObjectList.add(validationFieldList+' is blank on Applicant/Address.');
            }
            system.debug('validationObjectList'+validationObjectList);
            if(validationObjectList.size() > 0){
                validationErrorsList.add(validationObjectList+' Please fill that in before running CIBIL.');
            }
            system.debug('validationErrorsList'+validationErrorsList);
        }
        return validationErrorsList;
    }
    
    
    
    public String generateCibilRequest(String applicantRecId) {
        String requestBody;
        System.debug('applicantRecId'+applicantRecId);
     //   Applicant__c appObj = new Applicant__c();
        if(applicantRecId != null){
            appObj = [Select Id,RecordTypeId, Loan__r.Loan_Amount__c, Loan__r.Product__c, First_Name__c, Middle_Name__c, Last_Name__c, Dob__c, Gender__c, Email__c, PAN__c, Aadhaar_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, Mobile_Number__c, Alternate_Mobile_Number__c, (Select Id,Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Type__c, City__c, Pincode__c, Type__c, State__c from Addresses__r where Source_Type__c != 'Cibil' AND Pincode__c != null ) from Applicant__c where Id =: applicantRecId WITH SECURITY_ENFORCED];
        }
        system.debug('appObj'+appObj);
        LosCibilRequestWrapper reqObj = new LosCibilRequestWrapper();
        LosCibilRequestWrapper.RequestInfo reqInfoObj = new LosCibilRequestWrapper.RequestInfo();
        LosCibilRequestWrapper.ApplicationData appDataObj = new LosCibilRequestWrapper.ApplicationData();
        LosCibilRequestWrapper.Applicant appcntObj = new LosCibilRequestWrapper.Applicant();
        String RequestId = IntegrationUtility.getReferenceId();
        reqObj.RequestId = RequestId.left(2) + RequestId.right(RequestId.length()-4);
        reqObj.OriginatingChannel = Label.CIBILHandler_Channel ;
        //RequestInfo 
        reqInfoObj.ExecutionMode  = 'NewWithContext';
        reqInfoObj.SolutionSetId = '50';
        reqInfoObj.SolutionSetVersion = '1';
        reqObj.RequestInfo = reqInfoObj; 
        //Application Data
        appDataObj.Purpose = getCibilValue('Purpose', appObj.Loan__r.Product__c);
        appDataObj.Amount = String.valueOf(Integer.valueOf(appObj.Loan__r.Loan_Amount__c));
        appDataObj.ScoreType = '16';
        appDataObj.GSTStateCode = '08';
        appDataObj.CibilBureauFlag = 'False';
        appDataObj.DSTuNtcFlag = 'True';
        appDataObj.IDVerificationFlag = 'False';
        appDataObj.MFIBureauFlag = 'True';
        appDataObj.NTCProductType = 'PL';
        appDataObj.ConsumerConsentForUIDAIAuthentication  = 'N';
        appDataObj.FormattedReport = 'True';
        reqObj.ApplicationData = appDataObj;
        //Applicant
        appcntObj.ApplicantType = 'Main';
        appcntObj.ApplicantFirstName = appObj.First_Name__c;
        appcntObj.ApplicantMiddleName = appObj.Middle_Name__c;
        appcntObj.ApplicantLastName = appObj.Last_Name__c;
        appcntObj.DateOfBirth = appObj.Dob__c != null ? Datetime.newInstance(appObj.Dob__c.year(), appObj.Dob__c.month(),appObj.Dob__c.day()).format('ddMMyyyy') : '';  
        appcntObj.Gender = appObj.Gender__c;
        appcntObj.EmailAddress = appObj.Email__c;
        appcntObj.Identifiers = getIdentifiers(appObj);
        appcntObj.Telephones = getTelephones(appObj);
        appcntObj.Address = getAddress(appObj);
        appcntObj.Accounts = getAccounts(appObj);
        appcntObj.FinalTraceLevel = '2';
        reqObj.Applicant = appcntObj;
        requestBody = Json.serialize(reqObj);
        system.debug('requestBody'+requestBody);
        return requestBody;
    }
    
    public String createCibilRequest(String requestBody, String applcntId, String integrationMasterName) {
        system.debug('requestBody'+requestBody);
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(integrationMasterName);
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applcntId);
        String respBody;
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.contentType = 'application/json';
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody = calloutResponseWrapper.response;
        system.debug('respBody-- ' +respBody);
        return respBody;
    }
    
    
    
    public LosCibilRequestWrapper.Identifiers getIdentifiers(Applicant__c appRec) {
        LosCibilRequestWrapper.Identifiers identsObj = new LosCibilRequestWrapper.Identifiers();
        List<LosCibilRequestWrapper.Identifier> IdentList = new List<LosCibilRequestWrapper.Identifier>();
        if(String.isNotBlank(appRec.PAN__c)){
            IdentList.add(createIdentifier(appRec.PAN__c,getCibilValue('ID No', fldApiNameToIdentifier.get('PAN__c'))));
        }
        if(String.isNotBlank(appRec.Aadhaar_Number__c)){
            IdentList.add(createIdentifier(appRec.Aadhaar_Number__c,getCibilValue('ID No', fldApiNameToIdentifier.get('Aadhaar_Number__c'))));
        }
        if(String.isNotBlank(appRec.Voter_Id__c)){
            IdentList.add(createIdentifier(appRec.Voter_Id__c,getCibilValue('ID No', fldApiNameToIdentifier.get('Voter_Id__c'))));
        }
        if(String.isNotBlank(appRec.Passport_Number__c)){
            IdentList.add(createIdentifier(appRec.Passport_Number__c,getCibilValue('ID No', fldApiNameToIdentifier.get('Passport_Number__c'))));
        }
        if(String.isNotBlank(appRec.Driving_License_Id__c)){
            IdentList.add(createIdentifier(appRec.Driving_License_Id__c,getCibilValue('ID No', fldApiNameToIdentifier.get('Driving_License_Id__c'))));
        }
        identsObj.Identifier = IdentList;
        return identsObj;
    }
    
    
    
    public static LosCibilRequestWrapper.Identifier createIdentifier(String idNumber, String idType) {
        LosCibilRequestWrapper.Identifier IdentObj  = new LosCibilRequestWrapper.Identifier();
        IdentObj.IdNumber = idNumber;
        IdentObj.IdType = idType;
        return IdentObj;      
    }
    
    
    public LosCibilRequestWrapper.Telephones getTelephones(Applicant__c appRec){
        LosCibilRequestWrapper.Telephones telObj = new LosCibilRequestWrapper.Telephones();
        List<LosCibilRequestWrapper.Telephone> telList = new List<LosCibilRequestWrapper.Telephone>();
        if(String.isNotBlank(appRec.Mobile_Number__c)){
            telList.add(createTelephone(appRec.Mobile_Number__c, getCibilValue('Telephone Type', 'Mobile Phone')));
        }
        if(String.isNotBlank(appRec.Alternate_Mobile_Number__c)){
            telList.add(createTelephone(appRec.Alternate_Mobile_Number__c, getCibilValue('Telephone Type', 'Mobile Phone')));
        }
        telObj.Telephone = telList;
        return telObj;
    }
    
    public static LosCibilRequestWrapper.Telephone createTelephone(String telephoneNumber , String telephoneType  ) {
        LosCibilRequestWrapper.Telephone telObj  = new LosCibilRequestWrapper.Telephone();
        telObj.TelephoneNumber = telephoneNumber;
        telObj.TelephoneType = telephoneType;
        return telObj;      
    }
    
    public List<LosCibilRequestWrapper.Address> getAddress(Applicant__c appRec){
        List<LosCibilRequestWrapper.Address> addList = new List<LosCibilRequestWrapper.Address>();
        if(appRec.addresses__r.size()>0){
            for(Address__c add : appRec.addresses__r){
                LosCibilRequestWrapper.Address addObj = new LosCibilRequestWrapper.Address();
                addObj = createAddress(add.Address_Line_1__c, add.Address_Line_2__c, add.Address_Line_3__c, getCibilValue('Address Type', add.Address_Type__c), add.City__c, add.Pincode__c, getCibilValue('State Code', add.State__c));
                addList.add(addObj);
            }
        }
        return addList;
    }
    
    
    public static LosCibilRequestWrapper.Address createAddress(String addressLine1 , String addressLine2, String addressLine3 , String addressType, String city , String pinCode, String stateCode) {
        LosCibilRequestWrapper.Address addObj  = new LosCibilRequestWrapper.Address();
        addObj.AddressLine1 = addressLine1;
        addObj.AddressLine2 = addressLine2;
        addObj.AddressLine3 = addressLine3;
        addObj.AddressType = addressType;
        addObj.City = city;
        addObj.PinCode = pinCode;
        addObj.ResidenceType = null ; // null always as discussed with ANIL from AU on call 3rd-Dec,2022
        addObj.StateCode = stateCode;
        return addObj;      
    }
    
    public static LosCibilRequestWrapper.Accounts getAccounts(Applicant__c appRec){
        LosCibilRequestWrapper.Accounts accsObj = new LosCibilRequestWrapper.Accounts();
        LosCibilRequestWrapper.Account accObj = new LosCibilRequestWrapper.Account();
        accsObj.Account = accObj;
        return accsObj;
    }

    // Commercial Final Demo Feedback fix - score should be -1 in UI as well as field
    public Decimal getDecimalValue(String stringValue) {
        try {
            return Decimal.valueOf(stringValue); //if this is null or not a number, exception block will return 0 which should work for the logic
        } catch (Exception ex) {
            return 0;
        }
    }

    public String updateCibilScore(String appId, String respBody){
        system.debug('respBody'+respBody);
        LosCibilResponseWrapper cibilResWrpObj = LosCibilResponseWrapper.parse(respBody);
        system.debug('cibilResWrpObj'+cibilResWrpObj);
        
        LosCibilResponseWrapper.cls_SucessResponse succResObj = new LosCibilResponseWrapper.cls_SucessResponse();
        LosCibilResponseWrapper.cls_FailureResponse failResObj = new LosCibilResponseWrapper.cls_FailureResponse();
        LosCibilResponseWrapper.cls_SecondaryReportXml secRepObj = new LosCibilResponseWrapper.cls_SecondaryReportXml();
        List<LosCibilResponseWrapper.cls_Account_NonSummary_Segment_Fields> nonSumFldList = new List<LosCibilResponseWrapper.cls_Account_NonSummary_Segment_Fields>();
        
        List<LosCibilResponseWrapper.cls_Header> successHeaderTagData = new  List<LosCibilResponseWrapper.cls_Header>();
        
        //Insert Bureau_Results__c record for Cibil
        Bureau_Results__c objbureauResult = new Bureau_Results__c();
        objbureauResult.Applicant__c = appId;
        objbureauResult.Bureau__c = 'CIBIL';
        objbureauResult.Name = 'CIBIL Score';
     //   objbureauResult.Bureau_Response__c = Json.serialize(cibilResWrpObj);
        Insert objbureauResult;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Response';
        cv.VersionData = Blob.valueOf(Json.serialize(cibilResWrpObj));
        cv.Document_Type__c = 'Callout Response';
        cv.PathOnClient = 'Response.txt';
        cv.FirstPublishLocationId = objbureauResult.Id;
        insert cv;
        
        
        if(cibilResWrpObj.DCResponse.ContextData.Applicants.Applicant.DsCibilBureau.Response.CibilBureauResponse.BureauResponseXml.SucessResponse != null){
            succResObj = cibilResWrpObj.DCResponse.ContextData.Applicants.Applicant.DsCibilBureau.Response.CibilBureauResponse.BureauResponseXml.SucessResponse;
            /*SFAU-  5752 Changes*/
            successHeaderTagData = succResObj.Header;
            /********************* */
            system.debug('succResObj.Address'+succResObj.Address);
            if(succResObj.Address != null && succResObj.Address.size() > 0){
                //Insert Address__c records from Cibil Response
                List<Address__c> addressListToInsert = new List<Address__c>();
                for(LosCibilResponseWrapper.cls_Address add : succResObj.Address){
                    Address__c addObj = new Address__c();
                    addObj.Address_Line_1__c = add.AddressLine1;
                    addObj.Address_Line_2__c = add.AddressLine2;
                    addObj.Address_Line_3__c = add.AddressLine3;
                    addObj.State__c = getCibilName('State Code', add.StateCode);
                    addObj.Pincode__c = add.PinCode;
                    addObj.Address_Type__c = getCibilName('Address Type', add.AddressCategory);
                    if(String.isNotBlank(add.DateReported)){
                        addObj.Date_Reported__c = Date.valueOf(getDateAsStringFormat(add.DateReported));
                    }
                    addObj.Enriched_Through_Enquiry__c = add.EnrichedThroughEnquiry;
                    addObj.Source_Type__c = 'Cibil';
                    addObj.Applicant__c = appId;
                    addObj.Bureau_Results__c = objbureauResult.Id;
                    addressListToInsert.add(addObj);
                }
                system.debug('addressListToInsert'+addressListToInsert);
                if(addressListToInsert.size() > 0){
                    Insert addressListToInsert;
                    Set<Id> resultIds = (new Map<Id,SObject>(addressListToInsert)).keySet();
                    system.debug('List of Ids '+resultIds);
                    LOSKarzaAddressMatchController.callAddressParsingMethod(resultIds, appId);
                }
            }
            
            Integer highCreditOrSanctionedAmount;
            Integer currentBalance;
            Integer totalEmiAmount;
            system.debug('succResObj.Account'+succResObj.Account);
            if(succResObj.Account != null && succResObj.Account.size() > 0){
                List<Bank_Account_Records__c> bnkAccRecListToInsert = new List<Bank_Account_Records__c>();
                //get custom metadata values to calculate default logic if values are not avail in response
                Map<String, Cibil_Calculation_Logic__mdt> cclMetadata = Cibil_Calculation_Logic__mdt.getAll();
                for(LosCibilResponseWrapper.cls_Account acc : succResObj.Account){
                    LosCibilResponseWrapper.cls_Account_NonSummary_Segment_Fields nonSumFldObj = new LosCibilResponseWrapper.cls_Account_NonSummary_Segment_Fields();
                   // nonSumFldList = acc.Account_NonSummary_Segment_Fields; 
                   nonSumFldList.addAll(acc.Account_NonSummary_Segment_Fields); 
                    //nonSumFldList.add(nonSumFldObj);
                } 
                system.debug('nonSumFldList'+nonSumFldList);

                // 22 Sept - Kunal (Delete existing cibil bank account records before creating new one) SFAU-4421
                List<Bank_Account_Records__c> lstExistingBankAccount = [Select Id from Bank_Account_Records__c where Applicant__c =:appId AND RecordType.Name =:  GlobalConstants.CIBIL  WITH SECURITY_ENFORCED];
                DatabaseUtility.deleteRecords(lstExistingBankAccount,'');

                for(LosCibilResponseWrapper.cls_Account_NonSummary_Segment_Fields ansf :  nonSumFldList){
                    //Insert Bank_Account_Records__c records from Cibil Response
                    Bank_Account_Records__c barObj = new Bank_Account_Records__c();
                    if(String.isNotBlank(ansf.ReportingMemberShortName)){
                        barObj.Name_of_the_Financier__c  = ansf.ReportingMemberShortName;
                    }
                    if(String.isNotBlank(ansf.AccountType)){
                        barObj.Type_of_Loan__c = getCibilName('Account Type', ansf.AccountType);
                    }
                    if(String.isNotBlank(ansf.RateOfInterest)){
                        barObj.ROI__c  = Decimal.valueOf(ansf.RateOfInterest);
                    }
                    if(String.isNotBlank(ansf.DateClosed)){
                        barObj.Account_Closing_Date__c = Date.valueOf(getDateAsStringFormat(ansf.DateClosed));
                        if(String.isNotBlank(ansf.DateOpenedOrDisbursed)){
                            Date dateOpenedOrDisbursed = Date.valueOf(getDateAsStringFormat(ansf.DateOpenedOrDisbursed));
                            Date dateClosed = Date.valueOf(getDateAsStringFormat(ansf.DateClosed));
                            barObj.No_of_Emi_Paid__c  = dateOpenedOrDisbursed.monthsBetween(dateClosed);
                        }                                      
                    }
                    else{
                        if(String.isNotBlank(ansf.PaymentHistoryStartDate) && String.isNotBlank(ansf.PaymentHistoryEndDate)){
                            Date paymentHistoryStartDate = Date.valueOf(getDateAsStringFormat(ansf.PaymentHistoryStartDate));
                            Date paymentHistoryEndDate = Date.valueOf(getDateAsStringFormat(ansf.PaymentHistoryEndDate));
                            barObj.No_of_Emi_Paid__c  = paymentHistoryEndDate.monthsBetween(paymentHistoryStartDate);
                        }
                        
                    }
                    if(String.isNotBlank(ansf.CurrentBalance)){
                        barObj.Total_Outstanding__c = Integer.valueOf(ansf.CurrentBalance);
                        if(currentBalance == null){
                            currentBalance = Integer.valueOf(ansf.CurrentBalance);
                        }
                        else{
                            currentBalance += Integer.valueOf(ansf.CurrentBalance);
                        }
                        barObj.RTR_Status__c = barObj.Total_Outstanding__c > 0 && String.isBlank(ansf.DateClosed) ? 'Live' :  barObj.Total_Outstanding__c == 0 && String.isBlank(ansf.DateClosed) ? 'Matured' :  String.isNotBlank(ansf.DateClosed) ? 'Closed'  : '';
                    }
                    if(String.isNotBlank(ansf.RepaymentTenure)){
                        barObj.Tenure__c = ansf.RepaymentTenure;
                    }
                    if(String.isNotBlank(ansf.EmiAmount)){ 
                        barObj.EMI_Amount__c = Double.valueOf(ansf.EmiAmount);
                        if(totalEmiAmount == null && barObj.RTR_Status__c == 'Live'){ // Added by Kunal - If Account is open then only we need to consider for EMI Calculation. [SFAU-4426]
                            totalEmiAmount = Integer.valueOf(ansf.EmiAmount);
                        }
                        else if(barObj.RTR_Status__c == 'Live'){         // Added by Kunal - If Account is open then only we need to consider for EMI Calculation. [SFAU-4426]
                            totalEmiAmount += Integer.valueOf(ansf.EmiAmount);
                        }
                    }else if(String.isNotBlank(ansf.HighCreditOrSanctionedAmount)){
                        //Calculating EMI when EMI value is not there in the response
                        Decimal emiAmt = 0;
                        decimal loanAmount = decimal.valueOf(ansf.HighCreditOrSanctionedAmount);
                        Set<String> tenureSet = new Set<String>{'00','01','02','03','05','09','12','13','16'
                            ,'17','22','23','24','27','29','30','31','32','35','36','38','39','40','41','42','48'};
                        Set<String> percentSet = New Set<String>{'04','06','07','08','11','28','33','37','43','44','45','46','47'};
                        Set<String> outStandingSet = New Set<String>{'10','15','21','25','26','34'};
                        if (tenureSet.contains(ansf.AccountType)) {
                            system.debug('ansf.AccountType+++'+ansf.AccountType);
                            Decimal roi = ansf.RateOfInterest != null? Decimal.valueOf(ansf.RateOfInterest) : 
                                cclMetadata.get('X'+''+ansf.AccountType)?.Rate_of_Interest__c ;
                            Decimal tenInMon = ansf.RepaymentTenure != null? Decimal.valueOf(ansf.RepaymentTenure):
                                cclMetadata.get('X'+''+ansf.AccountType)?.Tenure__c;
                            emiAmt = calculateEMI(loanAmount, tenInMon, roi);
                            /*((Decimal)(loanAmount * ((roi)/12)) / (1-Math.Pow((Double)(1 + ((roi)/12)),(Double)(-tenInMon)))).setScale(2);*/
                        } else if(percentSet.contains(ansf.AccountType)){
                            emiAmt = loanAmount * cclMetadata.get('X'+''+ansf.AccountType)?.Rate_of_Interest__c ;
                        } else if(outStandingSet.contains(ansf.AccountType) && ansf.CurrentBalance != null){
                            emiAmt = Decimal.valueOf(ansf.CurrentBalance) * cclMetadata.get('X'+''+ansf.AccountType)?.Rate_of_Interest__c ;
                        }
                        if(emiAmt != 0) { 
                            barObj.EMI_Amount__c = emiAmt;
                            if(totalEmiAmount == null && barObj.RTR_Status__c == 'Live'){ // Added by Kunal - If Account is open then only we need to consider for EMI Calculation. [SFAU-4426]
                                totalEmiAmount = Integer.valueOf(emiAmt);
                            }
                            else if(barObj.RTR_Status__c == 'Live'){        // Added by Kunal - If Account is open then only we need to consider for EMI Calculation. [SFAU-4426]
                                totalEmiAmount += Integer.valueOf(emiAmt);
                            }
                        }
                    }
                    if(String.isNotBlank(ansf.AmountOverdue)){
                        barObj.Amount_Overdue__c = Double.valueOf(ansf.AmountOverdue);
                    }
                    if(String.isNotBlank(ansf.OwenershipIndicator)){
                        barObj.Owenership_Indicator__c = getCibilName('Ownership Indicator', ansf.OwenershipIndicator);
                    }
                    if(String.isNotBlank(ansf.SuitFiledOrWilfulDefault)){
                        barObj.Suit_Filed_Or_Wilful_Default__c = getCibilName('Status Type', ansf.SuitFiledOrWilfulDefault);
                    }
                    if(String.isNotBlank(ansf.WrittenOffAndSettled)){
                        barObj.Written_Off_And_Settled__c  = ansf.WrittenOffAndSettled;
                    }
                    if(String.isNotBlank(ansf.PaymentFrequency)){
                        barObj.Payment_Frequency__c = getCibilName('Payment Frequency', ansf.PaymentFrequency);
                    }
                    if(String.isNotBlank(ansf.DateOpenedOrDisbursed)){
                        barObj.Account_Opening_Date__c = Date.valueOf(getDateAsStringFormat(ansf.DateOpenedOrDisbursed));
                    }
                    if(String.isNotBlank(ansf.HighCreditOrSanctionedAmount)){
                        barObj.Loan_Amount__c = Integer.valueOf(ansf.HighCreditOrSanctionedAmount);
                        if(highCreditOrSanctionedAmount == null){
                            highCreditOrSanctionedAmount = Integer.valueOf(ansf.HighCreditOrSanctionedAmount);
                        }
                        else{        
                            highCreditOrSanctionedAmount += Integer.valueOf(ansf.HighCreditOrSanctionedAmount);
                        }
                    }
                    if(String.isNotBlank(ansf.DateReportedAndCertified)){
                        barObj.Date_Of_Enquiry__c = Date.valueOf(getDateAsStringFormat(ansf.DateReportedAndCertified));
                    }
                    if(String.isNotBlank(ansf.DateOfLastPayment)){
                        barObj.Last_Payment_Date__c = Date.valueOf(getDateAsStringFormat(ansf.DateOfLastPayment));
                    }
                    barObj.RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId();
                    
                    if(String.isNotBlank(ansf.PaymentHistoryStartDate)){
                        barObj.Payment_History_Start_Date__c = Date.valueOf(getDateAsStringFormat(ansf.PaymentHistoryStartDate));
                    }
                    if(String.isNotBlank(ansf.PaymentHistoryEndDate)){
                        barObj.Payment_History_End_Date__c = Date.valueOf(getDateAsStringFormat(ansf.PaymentHistoryEndDate));
                    }
                    if(String.isNotBlank(ansf.PaymentHistory1) || String.isNotBlank(ansf.PaymentHistory2)){
                        //Comment as ansf.PaymentHistory2 is NULL and throw error in getHighestDpd()
                        //barObj.Payment_History__c = ansf.PaymentHistory1+ansf.PaymentHistory2;
                        barObj.Payment_History__c = (String.isBlank(ansf.PaymentHistory1) ? '' : ansf.PaymentHistory1) + (String.isBlank(ansf.PaymentHistory2) ? '' : ansf.PaymentHistory2);
                        barObj.Highest_6_Month_DPD__c = getHighestDpd(barObj.Payment_History__c, barObj.Payment_History_Start_Date__c, barObj.Payment_History_End_Date__c, 0, 5);
                        barObj.Highest_12_Month_DPD__c = getHighestDpd(barObj.Payment_History__c, barObj.Payment_History_Start_Date__c, barObj.Payment_History_End_Date__c, 0, 11);
                        barObj.Highest_12_24_Month_DPD__c = getHighestDpd(barObj.Payment_History__c, barObj.Payment_History_Start_Date__c, barObj.Payment_History_End_Date__c, 12, 23);
                        barObj.Highest_24_36_Month_DPD__c = getHighestDpd(barObj.Payment_History__c, barObj.Payment_History_Start_Date__c, barObj.Payment_History_End_Date__c, 24, 35);
                        barObj.Highest_Overall_DPD__c = getHighestDpd(barObj.Payment_History__c, barObj.Payment_History_Start_Date__c, barObj.Payment_History_End_Date__c, 0, 35);
                        barObj.Average_12_Month_DPD__c = getAverageDpd(barObj.Payment_History__c, barObj.Payment_History_Start_Date__c, barObj.Payment_History_End_Date__c, 0, 11);
                        barObj.Average_Delay__c = getAverageDpd(barObj.Payment_History__c, barObj.Payment_History_Start_Date__c, barObj.Payment_History_End_Date__c, 0, 35);
                    }
                    barObj.Applicant__c = appId;
                    barObj.Bureau_Results__c = objbureauResult.Id;
                    barObj.Reported_Date__c = System.today();
                    bnkAccRecListToInsert.add(barObj);
                }
                system.debug('bnkAccRecListToInsert'+bnkAccRecListToInsert);
                if(bnkAccRecListToInsert.size() > 0){
                    Insert bnkAccRecListToInsert;
                }
            }
            
            if(succResObj.Enquiry != null && succResObj.Enquiry.size() > 0){
                List<Bank_Account_Records__c> bnkAccRecAsEnqListToInsert = new List<Bank_Account_Records__c>();
                for(LosCibilResponseWrapper.cls_Enquiry enq : succResObj.Enquiry){
                    Bank_Account_Records__c barEnq = new Bank_Account_Records__c();
                    barEnq.Is_Enquiry_Type__c  = true;
                    if(String.isNotBlank(enq.EnquiryPurpose)){
                        barEnq.Type_of_Loan__c = getCibilName('Account Type', enq.EnquiryPurpose);
                    }
                    if(String.isNotBlank(enq.DateOfEnquiryFields)){
                        barEnq.Date_Of_Enquiry__c = Date.valueOf(getDateAsStringFormat(enq.DateOfEnquiryFields));
                    }
                    barEnq.RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId();
                    barEnq.Applicant__c = appId;
                    barEnq.Bureau_Results__c = objbureauResult.Id;
                    bnkAccRecAsEnqListToInsert.add(barEnq);
                }
                if(bnkAccRecAsEnqListToInsert.size() >0){
                    Insert bnkAccRecAsEnqListToInsert;
                }
            }
            
            //Update Bureau_Results__c record from Cibil Response
            if(succResObj.NameSegment != null && succResObj.NameSegment.size() > 0){
                if(String.isNotBlank(succResObj.NameSegment[0].ConsumerName1)){
                    objbureauResult.Name_of_Applicant__c = succResObj.NameSegment[0].ConsumerName1;
                }
                if(String.isNotBlank(succResObj.NameSegment[0].DateOfBirth)){
                    objbureauResult.DOB__c = Date.valueOf(getDateAsStringFormat(succResObj.NameSegment[0].DateOfBirth));
                }
            }
            
            if(succResObj.TelephoneSegment != null && succResObj.TelephoneSegment.size() > 0){
                List<String> telAsArray = new List<String>();
                for(LosCibilResponseWrapper.cls_TelephoneSegment tel : succResObj.TelephoneSegment){
                    if(String.isNotBlank(tel.TelephoneNumber)){
                        telAsArray.add(tel.TelephoneNumber);
                    }
                }
                objbureauResult.TelephoneNumber__c = String.join(telAsArray, ',');
            }
            if(succResObj.EmailContactSegment != null && succResObj.EmailContactSegment.size() > 0){
                List<String> emailAsArray = new List<String>();
                for(LosCibilResponseWrapper.cls_EmailContactSegment email : succResObj.EmailContactSegment ){
                    if(String.isNotBlank(email.EmailID)){
                        emailAsArray.add(email.EmailID);
                    }
                }
                objbureauResult.EmailID__c = String.join(emailAsArray, ',');
            }
            
            
            if(succResObj.ScoreSegment != null && succResObj.ScoreSegment.size() > 0){
                if(String.isNotBlank(succResObj.ScoreSegment[0].Score)){
                    objbureauResult.Bureau_Score__c = Integer.valueOf(succResObj.ScoreSegment[0].Score.replaceFirst('^0+', ''));
                    Set<String> productSet = new Set<String>{'Four Wheeler', 'Tractor', 'Commercial Vehicle', 'Construction Equipment'};
                    String product = Aml.getTypeOfWheeler(appId);
                    Applicant__c existAppRec = new Applicant__c();
                    existAppRec.Id = appId;
                    existAppRec.Bureau_Score__c = succResObj.ScoreSegment[0].Score.substring(2);
                    // Commercial Final Demo Feedback fix - score should be -1 in UI as well as field
                    if (productSet.contains(product) && getDecimalValue(existAppRec.Bureau_Score__c) >= 100 && getDecimalValue(existAppRec.Bureau_Score__c) <= 200) {
                        existAppRec.Bureau_Score__c = '-1';
                    }
                    existAppRec.Last_CIBIL_Run_Date__c = system.today();
                    existAppRec.CIBIL_Status__c = 'Completed';
                    existAppRec.CIBIL_Rerun__c = false;
                    /* New Tags added for Reports and Saved on Applicant*/ 
                    if(!successHeaderTagData.isempty()){
                        existAppRec.Reference_Number__c = successHeaderTagData[0]?.ReferenceNumber;
                        existAppRec.Control_Number_ECN__c = successHeaderTagData[0]?.EnquiryControlNumber;
                    }
                    /******SFAU-  5752 Changes**************************/
                    
                    update existAppRec;
                }
                if(String.isNotBlank(succResObj.ScoreSegment[0].ScoreDate)){
                    objbureauResult.Bureau_Score_Date__c = Date.valueOf(getDateAsStringFormat(succResObj.ScoreSegment[0].ScoreDate));
                }
                if(highCreditOrSanctionedAmount != null){
                    objbureauResult.Account_High_Credit_Amount__c = highCreditOrSanctionedAmount;
                }
                if(currentBalance != null){
                    objbureauResult.Accounts_Overdue_Amount__c = currentBalance;
                }
                if(totalEmiAmount != null){
                    objbureauResult.Total_EMI_Amount__c = totalEmiAmount;
                }
                Update objbureauResult;
            }
            
        }
        else if(cibilResWrpObj.DCResponse.ContextData.Applicants.Applicant.DsCibilBureau.Response.CibilBureauResponse.BureauResponseXml.FailureResponse != null){
            failResObj = cibilResWrpObj.DCResponse.ContextData.Applicants.Applicant.DsCibilBureau.Response.CibilBureauResponse.BureauResponseXml.FailureResponse;
            if(String.isNotBlank(failResObj.Segment)){
                Integration_Checklist__c intChkLstObj = [SELECT Id FROM Integration_Checklist__c where Applicant__c =: appId AND Integration_Master__r.Name = 'Cibil Individual' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC Limit 1];
                intChkLstObj.API_Error__c = failResObj.Segment;
                Update intChkLstObj;
            }
        }
        if(cibilResWrpObj.DCResponse.ContextData.Applicants.Applicant.DsCibilBureau.Response.CibilBureauResponse.SecondaryReportXml.CreditReport != null){
            String loanAppId = [Select Id, Loan__c  from Applicant__c where Id =: appId]?.Loan__c;
            List<Applicant__c> Primary_Applicant = [SELECT Id,Mobile_Number__c,Aadhaar_Number__c,PAN__c,Voter_Id__c,Driving_License_Id__c,Passport_Number__c FROM Applicant__c where recordtype.Name = 'Applicant' and isInactive__c = false AND Loan__c =: loanAppId];
            secRepObj.CreditReport = cibilResWrpObj.DCResponse.ContextData.Applicants.Applicant.DsCibilBureau.Response.CibilBureauResponse.SecondaryReportXml.CreditReport;
            //Insert Applicant__c as Additional Match record from Cibil Response
            Applicant__c appObj = new Applicant__c();
            if(String.isNotBlank(secRepObj.CreditReport.NameSegment.ConsumerName1))
                appObj.First_Name__c = secRepObj.CreditReport.NameSegment.ConsumerName1;
            if(String.isNotBlank(secRepObj.CreditReport.NameSegment.ConsumerName2))
                appObj.Middle_Name__c = secRepObj.CreditReport.NameSegment.ConsumerName2;
            if(String.isNotBlank(secRepObj.CreditReport.NameSegment.ConsumerName3))
                appObj.Last_Name__c = secRepObj.CreditReport.NameSegment.ConsumerName3;
            if(String.isNotBlank(secRepObj.CreditReport.NameSegment.DateOfBirth)){
                appObj.Dob__c = Date.valueOf(getDateAsStringFormat(secRepObj.CreditReport.NameSegment.DateOfBirth));
            }
            if(String.isNotBlank(secRepObj.CreditReport.NameSegment.Gender)){
                appObj.Gender__c = getCibilName('Gender', secRepObj.CreditReport.NameSegment.Gender);
            }
            if(secRepObj.CreditReport.IDSegment != null && secRepObj.CreditReport.IDSegment.size() >0){
                for(LosCibilResponseWrapper.cls_IDSegment Id : secRepObj.CreditReport.IDSegment){
                    if(getCibilName('ID No', Id.IDType) == fldApiNameToIdentifier.get('PAN__c'))
                        appObj.PAN__c = Id.IDNumber;
                    if(getCibilName('ID No', Id.IDType) == fldApiNameToIdentifier.get('Aadhaar_Number__c'))
                        appObj.Aadhaar_Number__c = Id.IDNumber;
                    if(getCibilName('ID No', Id.IDType) == fldApiNameToIdentifier.get('Voter_Id__c'))
                        appObj.Voter_Id__c = Id.IDNumber;
                    if(getCibilName('ID No', Id.IDType) == fldApiNameToIdentifier.get('Passport_Number__c'))
                        appObj.Passport_Number__c = Id.IDNumber;
                    if(getCibilName('ID No', Id.IDType) == fldApiNameToIdentifier.get('Driving_License_Id__c'))
                        appObj.Driving_License_Id__c = Id.IDNumber;
                }
            }
            if(secRepObj.CreditReport.TelephoneSegment != null && secRepObj.CreditReport.TelephoneSegment.size() >0){
                for(LosCibilResponseWrapper.cls_TelephoneSegment Tel : secRepObj.CreditReport.TelephoneSegment){
                    if(getCibilName('Telephone Type', Tel.TelephoneType) == 'Mobile Phone')
                        appObj.Mobile_Number__c = Tel.TelephoneNumber;
                }
            }

            //SFAU-5204 Start 
            appObj.Mobile_Number__c = appObj.Mobile_Number__c == null ? Primary_Applicant[0].Mobile_Number__c : appObj.Mobile_Number__c;
            appObj.PAN__c = String.isNotBlank(Primary_Applicant[0].PAN__c) ? Primary_Applicant[0].PAN__c : appObj.PAN__c;
            if(String.isBlank(appObj.Aadhaar_Number__c) && String.isBlank(appObj.Voter_Id__c) &&
             String.isBlank(appObj.Passport_Number__c) && String.isBlank(appObj.Driving_License_Id__c)){
                appObj.Aadhaar_Number__c = String.isNotBlank(Primary_Applicant[0].Aadhaar_Number__c) ? Primary_Applicant[0].Aadhaar_Number__c : appObj.Aadhaar_Number__c;
                appObj.Voter_Id__c = String.isNotBlank(Primary_Applicant[0].Voter_Id__c) ? Primary_Applicant[0].Voter_Id__c : appObj.Voter_Id__c;
                appObj.Passport_Number__c = String.isNotBlank(Primary_Applicant[0].Passport_Number__c) ? Primary_Applicant[0].Passport_Number__c : appObj.Passport_Number__c;
                appObj.Driving_License_Id__c = String.isNotBlank(Primary_Applicant[0].Driving_License_Id__c) ? Primary_Applicant[0].Driving_License_Id__c : appObj.Driving_License_Id__c;
             }
            //SFAU-5204 End
           
           // Delete Existing Additional Match records and related Address & Bureau - Start
            List<Address__c> addressToRemove = new List<Address__c>();
            List<Bureau_Results__c> bureauToRemove = new List<Bureau_Results__c>();

            List<Applicant__c> existingAdditionalMatchRecs = [SELECT Id,(SELECT Id FROM Addresses__r),(SELECT Id FROM Bureau_Results__r) FROM Applicant__c Where RecordType.Name = 'Additional Match' AND Applicant__c =: appId];
            for(Applicant__c record :  existingAdditionalMatchRecs){
                addressToRemove.addAll(record.Addresses__r);
                bureauToRemove.addAll(record.Bureau_Results__r);
            }

            Database.delete(addressToRemove);
            Database.delete(bureauToRemove);
            Database.delete(existingAdditionalMatchRecs);

            // Delete Existing Additional Match records and related Address & Bureau - End

            if(secRepObj.CreditReport.EmailContactSegment != null && secRepObj.CreditReport.EmailContactSegment.size() >0){
                appObj.Email__c = secRepObj.CreditReport.EmailContactSegment[0].EmailID;
            }
            appObj.RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Additional Match').getRecordTypeId();
            appObj.Applicant__c = appId;
            appObj.Bureau_Results__c = objbureauResult.Id;
            appObj.Loan__c = loanAppId;
            Insert appObj;
            
            if(secRepObj.CreditReport.Address != null && secRepObj.CreditReport.Address.size() > 0){
                List<Address__c> addressListToInsert = new List<Address__c>();
                for(LosCibilResponseWrapper.cls_Address Add : secRepObj.CreditReport.Address){
                    //Insert Address__c records of Additional Match type Applicant from Cibil Response
                    Address__c addObj = new Address__c();
                    addObj.Address_Line_1__c = 'HNo ' + Add.AddressLine1;
                    addObj.Address_Line_2__c = Add.AddressLine2;
                    addObj.Address_Line_3__c = Add.AddressLine3;
                    addObj.State__c = getCibilName('State Code', Add.StateCode);
                    addObj.Pincode__c = Add.PinCode;
                    addObj.Address_Type__c = getCibilName('Address Type', Add.AddressCategory);
                    addObj.Applicant__c = appObj.Id;
                    addressListToInsert.add(addObj);
                }
                system.debug('addressListToInsert'+addressListToInsert);
                if(addressListToInsert.size() > 0){
                    Insert addressListToInsert;
                }
            }
        }

        Applicant__c applicant = [Select Id, Loan__c  from Applicant__c where Id =: appId LIMIT 1];
        sendNotification(applicant);
        return objbureauResult.Id;
    }
    
    private static void sendNotification(Applicant__c applicant){
        try{
            NotificationHandler.sendNotification('ON generation of Customer CIBIL', applicant.Loan__c, ''); //Notification 
        }catch(Exception ex){
            Log.error('CIBILHandler method updateCreditScore.SendNotification :: LINE NUMBER ' + ex.getLineNumber() + ' --  ' +  ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applicant.Id);
        }
    }
    
    public String generateCibilReportRequest(String applicantRecId, String applicationId){
        String requestBody;
        System.debug('applicantRecId'+applicantRecId);
        System.debug('applicationId'+applicationId);
        String RequestId = IntegrationUtility.getReferenceId();
        LosCibilRequestWrapper.cls_Cibil_report reqObj = new LosCibilRequestWrapper.cls_Cibil_report();
        reqObj.RequestId = RequestId.left(2) + RequestId.right(RequestId.length()-4);
        reqObj.OriginatingChannel = Label.CIBILHandler_Channel ;
        reqObj.ApplicationId= applicationId;
        requestBody = Json.serialize(reqObj);
        system.debug('requestBody'+requestBody);
        return requestBody;
    }
    
    public String getDateAsStringFormat(String dateAsDateFormat){
        dateAsDateFormat = dateAsDateFormat = dateAsDateFormat.trim();
        dateAsDateFormat = dateAsDateFormat.length() == 7 ? '0'+dateAsDateFormat : dateAsDateFormat;
        return dateAsDateFormat.mid(4,4)+'-'+dateAsDateFormat.mid(2,2)+'-'+dateAsDateFormat.mid(0,2);
    }
    
    public String getHighestDpd(String paymentHistory, Date paymentHistoryStartDate, Date paymentHistoryEndDate, Integer startMonth, Integer lastMonth) {
        if(paymentHistory != '0') {
            Integer nbrOfChars = 3;
            // taking this as integer as month doesn't matter. Regardless of the closure/payment, DPD of last 12 months will be considered for calculations
            Map<Integer, Integer> countOfMonthToDPDMap = new Map<Integer, Integer>();
            Integer j = 0;
            for (Integer i = 0; i < paymentHistory.length(); i += nbrOfChars){
                String dpd = paymentHistory.substring(i, Math.min(paymentHistory.length(), i + nbrOfChars));
                countOfMonthToDPDMap.put(j++, dpdMap.containsKey(dpd) ? dpdMap.get(dpd) : (dpd.isNumeric() ? Integer.valueOf(dpd) : 0));
            }

            Integer highestDPD = 0;
            for (Integer i = startMonth; i <= lastMonth; i++) {
                if (countOfMonthToDPDMap.containsKey(i) && highestDPD < countOfMonthToDPDMap.get(i)) {
                    highestDPD = countOfMonthToDPDMap.get(i);
                }
            }

            return String.valueOf(highestDPD);
        } else{
            return paymentHistory;
        }
    }
    
    public String getAverageDpd(String paymentHistory, Date paymentHistoryStartDate, Date paymentHistoryEndDate, Integer startMonth, Integer lastMonth){    
        Integer nbrOfChars = 3;
        Integer dpdValue = 0;
        Map<Integer, Integer> countOfMonthToDPDMap = new Map<Integer, Integer>();
        Map<Integer, Integer> denominatorMap = new Map<Integer, Integer>();
        Integer j = 0;
        Integer numerator = 0;
        Integer denominator = 0;
        for (Integer i = 0; i < paymentHistory.length(); i += nbrOfChars) {
            String dpd = paymentHistory.substring(i, Math.min(paymentHistory.length(), i + nbrOfChars));
            countOfMonthToDPDMap.put(j, dpdMap.containsKey(dpd) ? dpdMap.get(dpd) : (dpd.isNumeric() ? Integer.valueOf(dpd) : 0));
            denominatorMap.put(j++, dpdDenominatorCount.containsKey(dpd) ? dpdDenominatorCount.get(dpd) : 1);
        }

        for (Integer i = startMonth; i <= lastMonth; i++) {
            if (countOfMonthToDPDMap.containsKey(i)) {
                numerator += countOfMonthToDPDMap.get(i);
                denominator += denominatorMap.get(i);
            }
        }

        return String.valueOf(denominator == 0 ? 0 : ((Decimal) numerator/denominator).setScale(2));
    }

    public Decimal calculateEMI(Decimal loanAmount, Decimal tenure, Decimal roi) {
        if (loanAmount == null || roi == null || tenure == null) {
            return null;
        } else {
            Double tenureDouble = Double.valueOf(tenure);
            Double roiDouble = Double.valueOf(roi)/12;
            roi = roi/12;
            Double part1 = Math.pow(1 + (roiDouble/100), tenureDouble);
            Double part2 = (part1 * (roiDouble/100));
            Double part3 = (Math.pow((1 + (roiDouble/100)), tenureDouble) - 1);
            if (part3 == 0) {
                return 0;
            }
            Decimal finalValue = (loanAmount * (part2/part3));
            return finalValue;
        }
    }
}