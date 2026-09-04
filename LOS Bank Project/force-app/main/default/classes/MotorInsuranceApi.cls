@isTest
public with sharing class MotorInsuranceApi{
/*
    public Static Collateral__c collateralObj;
    public Static Loan_Application__c loanAppObj;
    public Static List<Applicant__c> applcLst;
    public String loanType;

    public Static List<Loan_Application__c> getLoanAppList(String loanApplId) {

        List<Loan_Application__c> loanApplLst = [SELECT id, Product__c, RecordType.Name
                                                 FROM Loan_Application__c
                                                 WHERE id = :loanApplId WITH SECURITY_ENFORCED];
        
        loanAppObj = loanApplLst.size() > 0 ? loanApplLst[0] : new Loan_Application__c();
      
        return loanApplLst;
    }

    @AuraEnabled
    public static List<Applicant__c> getApplicant(String applcntRecordId) {
        List<Applicant__c> applicantList = [SELECT Id, Customer_Type__c, Dob__c, Gender__c, First_Name__c, Middle_Name__c, Last_Name__c, Email__c, Mobile_Number__c, PAN__c, 
                                             CIF_No__c
                                            FROM Applicant__c WHERE Id = :applcntRecordId WITH SECURITY_ENFORCED];
        
        return applicantList;
    }

    public Static List<User> getCurrentUser(String currentUserId) {

        List<User> userList = [SELECT id, Employee_Code__c
                                                FROM User
                                                WHERE id =:currentUserId WITH SECURITY_ENFORCED];
        
        return userList;
    }



    public Static String getApplcntFullName(Applicant__c applcnt) {
        Applicant__c applRec        = applcLst.size() > 0 ? applcLst[0] : new Applicant__c();
        String firstName            = String.isNotEmpty(applcLst[0].First_Name__c) ? applcLst[0].First_Name__c : '';
        String middleName           = String.isNotEmpty(applcLst[0].Middle_Name__c) ? applcLst[0].Middle_Name__c : '';
        String lastName             = String.isNotEmpty(applcLst[0].Last_Name__c) ? applcLst[0].Last_Name__c : '';
        String fullName             = firstName + middleName + lastName;
        return fullName;
    }

    public Static List<Collateral__c> getCollateralList(String loanApplId) {

        List<Collateral__c> collateralLst = [SELECT id, Vehicle_Number__c, Make__c, Registration_Date__c, MMV_Master__r.Vehicle_Id__c, Rto_Code__c,
                                             Model__c, Fuel_Type__c, Variant__c, Have_you_made_a_claim_Last_year__c, Insurance_Expiry_Date__c, NCB_in_Exisiting_policy__c,
                                             Existing_Policy_Type__c, Existing_Policy_Insurer_Company__c, Exiting_Policy_Expired__c 
                                             FROM Collateral__c
                                             WHERE Loan__c = :loanApplId WITH SECURITY_ENFORCED];
        
        collateralObj = collateralLst.size() > 0 ? collateralLst[0] : new Collateral__c();
        return collateralLst;
    }

    public String motorInsuranceCallOut(String applcntId, String loanApplicantId, String masterRecord) {
        String respBody;
        
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(masterRecord); 
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = loanApplicantId);
        
        MotorInsuranceApi reqObj = generateRequest(loanApplicantId, applcntId);
        String requestBody = '{"AuthToken":"42cy9da5f019434e91c556150b4c2420","MotorPremiumRequest":{"VehicleID":"365","RtoCode":"MH01","RegDate":"06-02-2023","IDV":"0","RegistrationYear":"2023","PACover":"0","Make":"HONDA","Car":"ACCORD","Fueltype":"PETROL","Model":"2.4 MANUAL TRANSMISSION","HasExpired":"0","HasClaimed":"0","ExpireTime":"0","PreviosPolicyExpiryDate":"","PreviousNcb":"-1","VehicleType":"1","SubVehicleType":"1","ISNewVehicle":"1","PolicyType":"1","PreviousInsurerID":"","AddonInput":[],"OwnerDriverPAType":"","RegNo":"","SubVechicleClass":"-1","SubVehicleCategory":"-1","PrevPolicyType":"-1","ncb":"0","TPStartDate":null,"TPEndDate":null,"ProposerFullName":"test test","ProposerGender":"Male","ProposerMobileNo":"9876543210","ProposerEmailID":"test@test.com"}}';
            // JSON.serialize(reqObj);
         
        system.debug('%%'+requestBody);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
        system.debug('calloutResponseWrapper '+calloutResponseWrapper);
        respBody = calloutResponseWrapper.response;
  
        return respBody;
    }

    @AuraEnabled
    public Static String motorInsuranceHandler(String applcntId, String loanAppId, String integrationMasterRecord) {

        MotorInsuranceApi motorInsuranceApi = new MotorInsuranceApi();
        String responseBody = motorInsuranceApi.motorInsuranceCallOut(applcntId, loanAppId, integrationMasterRecord);
        return responseBody;
    }



    public MotorInsuranceApi generateRequest(String loanApplcId, String applicntId) {

        getCollateralList(loanApplcId);
        getLoanAppList(loanApplcId);

        applcLst = getApplicant(applicntId);
        String fullName = getApplcntFullName(applcLst[0]);
        
        MotorInsuranceApi motorInsuranceObj = new MotorInsuranceApi();
        motorInsuranceobj.AuthToken = '42cy9da5f019434e91c556150b4c2420';

        Date regDate = collateralObj.Registration_Date__c;
        String registrationDate = regDate.day() + '-' + regDate.month() + '-' + regDate.year();
        loanType       = RelatedPaymentFavouringsController.getSubProductName(loanAppObj.Product__c);
        String hasExpired = '';
        String existingPolicy = collateralObj.Exiting_Policy_Expired__c;

        if(loanType == 'New' || existingPolicy == 'No') {
            hasExpired = '0';
        }
        else if(existingPolicy == 'Yes') {
            hasExpired = '1';
        }
        String recordType = loanAppObj.RecordType.Name;
        String expirTime = calculateExpiryTime();
        String subVehicleType = '';
        if(recordType == 'Two Wheeler') {
            subVehicleType = '2';
        }
        else if(recordType == 'Four Wheeler') {
            subVehicleType = '1';
        }
        String isVehicleType = loanType == 'New' ? '1' : '0';
        Decimal preciousNcb = collateralObj.NCB_in_Exisiting_policy__c;
        String ncb = calculateNcb(preciousNcb);

        MotorPremiumRequest motorPremReqObj = new MotorPremiumRequest();
        motorPremReqObj.VehicleID           = collateralObj.MMV_Master__r.Vehicle_Id__c;
        motorPremReqObj.RtoCode             = collateralObj.Rto_Code__c;
        motorPremReqObj.RegDate             = registrationDate;
        motorPremReqObj.IDV                 = '0';
        motorPremReqObj.RegistrationYear    = String.valueOf(collateralObj.Registration_Date__c.Year()); 
        motorPremReqObj.PACover             = '0';
        motorPremReqObj.Make                = collateralObj.Make__c;   
        motorPremReqObj.Car                 = collateralObj.Model__c; 
        motorPremReqObj.FuelType            = collateralObj.Fuel_Type__c; 
        motorPremReqObj.Model                     = collateralObj.Variant__c;  
        motorPremReqObj.HasExpired                = hasExpired;
        motorPremReqObj.HasClaimed                = collateralObj.Have_you_made_a_claim_Last_year__c;
        motorPremReqObj.ExpireTime                = expirTime;
        motorPremReqObj.PreviosPolicyExpiryDate   = String.valueOf(collateralObj.Insurance_Expiry_Date__c);
        motorPremReqObj.PreviousNcb               = String.valueOf(collateralObj.NCB_in_Exisiting_policy__c);
        motorPremReqObj.VehicleType               = recordType;
        motorPremReqObj.SubVehicleType            = subVehicleType;
        motorPremReqObj.ISNewVehicle              = isVehicleType;
        motorPremReqObj.PolicyType                = collateralObj.Existing_Policy_Type__c;
        motorPremReqObj.PreviousInsurerID         = collateralObj.Existing_Policy_Insurer_Company__c;
        motorPremReqObj.ncb                       = ncb;
        motorPremReqObj.AddonInput                = new List<AddonInput>();
        motorInsuranceObj.MotorPremiumRequest     = motorPremReqObj;   

        return motorInsuranceobj;
    }
    
    public String calculateNcb(Decimal preciousNcb) {
        Integer ncb;
        Integer previousNcbInNumber = Integer.valueOf(preciousNcb);

        Date startDate = Date.today();
        Date dueDate = collateralObj.Insurance_Expiry_Date__c;
        Integer numberDaysDue = startDate.daysBetween(dueDate);

        if(collateralObj.Have_you_made_a_claim_Last_year__c == '1') {
            ncb = 0;
        }
        else if(previousNcbInNumber == -1) {
            ncb = -1;
        }
        else if(previousNcbInNumber == 0) {
            if(numberDaysDue > 90) {
                ncb = previousNcbInNumber;
            }
            else if(previousNcbInNumber < 90) {
                ncb = previousNcbInNumber + 20;
            }
            else if(previousNcbInNumber == 20 || previousNcbInNumber == 45) {
                ncb = previousNcbInNumber + 5;
            }
            else if(previousNcbInNumber == 25 || previousNcbInNumber == 35) {
                ncb = previousNcbInNumber + 10;
            }
        }
        else {
            ncb = previousNcbInNumber;
        }
        String ncbInString = String.valueOf(ncb);
        return ncbInString;
    }

    public String calculateExpiryTime() {
        String expiryTime = '';
        String recordType = loanAppObj.RecordType.Name;
        Date startDate = Date.today();
        Date dueDate = collateralObj.Insurance_Expiry_Date__c;
        Integer numberDaysDue = startDate.daysBetween(dueDate);
        if(recordType == 'Four Wheeler') {
            if(numberDaysDue > 30 ) {
                expiryTime = '1';
            }else {
                expiryTime = '0';
            }
        }
        else if(recordType == 'Two Wheeler') {
            if(numberDaysDue > 90) {
                expiryTime = '1';
            }else {
                expiryTime = '0';
            }
        }
        else if(loanType == 'New') {
            expiryTime = '0';
        }
        return expiryTime;
    }

    @AuraEnabled
    public Static List<Address__c> getAddress(String applcntId, String addressType) {
        List<Address__c> addressList = [SELECT Id,Name,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                            State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,
                                            Address_Source__c,Type__c, District__c
                                        FROM Address__c 
                                        WHERE (Applicant__c =:applcntId AND Address_Type__c = :addressType) WITH SECURITY_ENFORCED];
        
        return addressList;
    }

    public static void redirectToProposalMotorHandller(String applcntId) {

        getCollateralList(applcntId);
        getLoanAppList(applcntId);
        Applicant__c applcntRec =  getApplicant(applcntId).size() > 0 ? getApplicant(applcntId)[0] : new Applicant__c();
        
        String recordType = loanAppObj.RecordType.Name;
        String currentUserId = UserInfo.getUserId();
        String customerId = '';
        String cifNo = applcntRec.CIF_No__c;
        User userRec = getCurrentUser(currentUserId)[0];
        String userLoginId = userRec.Employee_Code__c;
        
        if(String.isBlank(cifNo)) {
            cifNo = applcntRec.Id;
        }
        else {
            cifNo = applcntRec.CIF_No__c;
        }
        String fkSubModuleID = '';
        if(recordType == 'Two Wheeler') {
            fkSubModuleID = '2';
        }
        else if(recordType == 'Four Wheeler') {
            fkSubModuleID = '1';
        }

        Map<String, String> address = RedirectToProposal.getPermanentAddress(applcntId);
        String fullPermanentAddress = address.get('fullPermanentAddress');

        List<Applicant__c> applcntList = getApplicant(applcntId);
        Applicant__c  applicantRec     = applcntList[0];

        List<AddOnDetails> addOnDetailsList = new List<AddOnDetails>();
        MotorInsuranceApi motorInsuranceApiPbj         = new MotorInsuranceApi();
        OtherDetails otherDetObj = new OtherDetails();
        
        String applFullName                 = getApplcntFullName(applicantRec);

        motorInsuranceApiPbj.Name       = applFullName;
        motorInsuranceApiPbj.Gender     = applicantRec.Gender__c;
        motorInsuranceApiPbj.Email      = applicantRec.Email__c;
        motorInsuranceApiPbj.Mobile     = applicantRec.Mobile_Number__c;
        motorInsuranceApiPbj.DOB        = String.valueOf(applicantRec.Dob__c);
        motorInsuranceApiPbj.PanNo      = applicantRec.PAN__c;
        motorInsuranceApiPbj.CustomerID = cifNo;
        otherDetObj.FkModuleID           = 2;
        otherDetObj.FkSubModuleID        = Integer.valueOf(fkSubModuleID);
        otherDetObj.PermanentAddress     = fullPermanentAddress;
        otherDetObj.Pincode              = Integer.valueOf(address.get('pincode'));
        otherDetObj.UserLoginID          = userLoginId;

        motorInsuranceApiPbj.OtherDetails = otherDetObj;
    }
*/
}