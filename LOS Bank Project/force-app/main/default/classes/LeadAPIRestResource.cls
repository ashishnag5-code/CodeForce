/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-21-2023
 * @last modified by  : Harshit Goyal       | Salesforce
 * @last modified by  : Mohit M.            | May
 * @last modified by  : Mohit M.            | June 
 * @last modified by  : Mohit M.            | Sept 
 * @last modified by  : Mohit M.            | Oct - Document checklist change 
 * @last modified by  : Mohit M.            | SFAU-5395 - Oct-14 - Set default residentofficetype to 'Flat'
 * @last modified by  : Mohit M.            | SFAU-5412 - Customer Name is blank for Lead  
 * @last modified by  : Mohit M.            | SFAU-5608 - Handle Used Vehicle
**/
@RestResource(urlMapping='/LeadAPIRestResource/*')
global class LeadAPIRestResource {
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-20-2023 
    **/
    @HttpPost
    global static void postLeadDetails(){
        List<Loan_Application__c> loanList = new List<Loan_Application__c>();
        List<Applicant__c> applicantList = new List<Applicant__c>();
        List<Address__c> lstAddress = new List<Address__c>();
        List<Applicant_Financials_Details__c> lstFinancialParent = new List<Applicant_Financials_Details__c>();
        List<Applicant_Financials_Details__c> lstFinancialChild = new List<Applicant_Financials_Details__c>();
        List<Collateral__c> lstCollateral = new List<Collateral__c>();
        List<Valuation__c> lstValuation = new List<Valuation__c>();
        List<Charge__c> lstCharge = new List<Charge__c>();
        List<Document_Checklist__c> lstDocumentcheck = new List<Document_Checklist__c>();        
        Map<String,Id> mapObjWithRecordType = new Map<String,Id>();
        Map<Id,String> mapRTIdWithName = new Map<Id,String>();
        Map<String,List<Applicant_Financials_Details__c>> mapAppParentWithChild = new Map<String,List<Applicant_Financials_Details__c>>();
        Set<String> setBranchDealerId = new Set<String>();
        Map<String,String> mapLeadIdWithBranch = new Map<String,String>();
        Map<String, LeadWrapper.DocumentDetail> mapKeyWithDocument = new Map<String, LeadWrapper.DocumentDetail>();
        //Map<String,LeadWrapper> mapLeadWrapperWithOwner = new Map<String,LeadWrapper?();
        //Map<String,String> mapLeadWithPin = new Map<String,String>();
        //Map<String,String> mapLeadWithBrDealOutlet = new Map<String,String>();
        //Map<String,String> mapLeadWithPin = new Map<String,String>();
        
        // Lead
        Id recordtypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        mapObjWithRecordType.put('Lead',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'Lead');
        // Applicant
        recordtypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        mapObjWithRecordType.put('Applicant',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'Applicant');
        recordtypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Co-Applicant').getRecordTypeId();
        mapObjWithRecordType.put('Co-Applicant',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'Co-Applicant');
        recordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        mapObjWithRecordType.put('Guarantor',recordTypeId);
        mapRTIdWithName.put(recordtypeId,'Guarantor');
        recordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Nominee').getRecordTypeId();
        mapObjWithRecordType.put('Nominee',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'Nominee');
        // Applicant Financial
        recordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Assessed No Document').getRecordTypeId();
        mapObjWithRecordType.put('Assessed No Document',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'FinanceAssessedNodocument');
        recordtypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Documented With Audited financial').getRecordTypeId();
        mapObjWithRecordType.put('Documented With Audited financial',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'FinanceDocumentWithAudit');
        recordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Documented Without Audited financial').getRecordTypeId();
        mapObjWithRecordType.put('Documented Without Audited financial',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'FinanceDocumentWithoutAudit');
        recordtypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Farmer - Agriculture Own Land').getRecordTypeId();
        mapObjWithRecordType.put('Farmer - Agriculture Own Land',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'FinanceAgriOwnLand');
        recordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Farmer - Agriculture Rented Land').getRecordTypeId();
        mapObjWithRecordType.put('Farmer - Agriculture Rented Land',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'FinanceAgriRentLand');
        recordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Farmer - Commercial').getRecordTypeId();
        mapObjWithRecordType.put('Farmer - Commercial',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'FinanceFarmerCommercial');
        recordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Farmer - Dairy Business').getRecordTypeId();
        mapObjWithRecordType.put('Farmer - Dairy Business',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'FinanceDairyBusiness');
        recordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Financial Parent').getRecordTypeId();
        mapObjWithRecordType.put('Financial Parent',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'Finance');
        recordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Other Income').getRecordTypeId();
        mapObjWithRecordType.put('Other Income',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'FinanceOtherIncome');
        recordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Salaried Document').getRecordTypeId();
        mapObjWithRecordType.put('Salaried Document',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'FinanceSalary');
        // Collateral
        recordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Existing Collateral').getRecordTypeId();
        mapObjWithRecordType.put('Existing Collateral',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'ExistingCollateral');
        recordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        mapObjWithRecordType.put('New',recordtypeId);
        mapRTIdWithName.put(recordtypeId,'New');
        recordtypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        mapObjWithRecordType.put('Used/Cash on Wheels',recordtypeId);
        mapObjWithRecordType.put('Used',recordtypeId);
        mapObjWithRecordType.put('Cash on Wheels',recordtypeId);
        mapObjWithRecordType.put('Existing',recordtypeId);
        
        mapRTIdWithName.put(recordtypeId,'UsedCashOnwheel');
        Applicant__c objPrimaryApp = NULL;

        String strDigitalAndPartnerLeadMaster = Label.Digital_And_Partner_Lead_Master_Name;
        Integration_Master__c objIntMasterReg = new Integration_Master__c(
            Name = strDigitalAndPartnerLeadMaster);
        
        Integration_Checklist__c objIntCheck = new Integration_Checklist__c();
        objIntCheck.Integration_Master__r = objIntMasterReg;
        objIntCheck.Request_Initiated_At__c = System.Now();

        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        LeadWrapper leadWrap;
        LeadResponseWrapper.Response objResponse = new LeadResponseWrapper.Response();
        //LeadWrapper objBlankLead = new LeadWrapper();
        //objBlankLead.leadRecordList = new List<LeadWrapper.LeadRecord>();
        Savepoint sp = Database.setSavepoint();
        try
        {
            Loan_Application__c objLANew;
            leadWrap = LeadWrapper.parse(req.requestBody.toString());
            System.debug(LoggingLevel.Info,'Request Parse successfully...');
            
            if(!leadWrap.leadRecordList.isEmpty()){
                for(LeadWrapper.LeadRecord leadRecord: leadWrap.leadRecordList){
                    objLANew = new Loan_Application__c();
                    objLANew.RecordTypeId= mapObjWithRecordType.get('Lead');
                    objLANew.Product__c = leadRecord.productcode;
                    objLANew.Purpose_of_Loan__c = leadRecord.loanpurpose;
                    objLANew.Nature_of_Loan__c = leadRecord.loannature;
                    objLANew.Source_Name__c = leadRecord.sourcename;
                    objLANew.Sourcing_channel__c = leadRecord.sourcechannel;
                    // SFAU-5608
                    objLANew.Lead_Source__c = leadRecord.leadsourcename;
                    objLANew.Lead_Source_Channel__c = leadRecord.leadsourcechannel;
                    objLANew.Campaign__c = leadRecord.campaignname;
                    if(String.isNotBlank(leadRecord.branchcode)){
                        Account branchRef = new Account(
                            Account_Code__c=leadRecord.branchcode);
                        objLANew.Branch_Master__r = branchRef;
                        setBranchDealerId.add(leadRecord.branchcode);
                    }
                    if(String.isNotBlank(leadRecord.dealercode)){
                        Account dealerRef = new Account(
                            Account_Code__c=leadRecord.dealercode);
                        objLANew.Dealer_Master__r = dealerRef;
                        setBranchDealerId.add(leadRecord.branchcode);
                    }
                    
                    // Need to confirm
                    Boolean blnFindScheme = false;
                    if(String.isNotBlank(leadRecord.schemename) && String.isNotBlank(leadRecord.schemecode)){
                        Scheme_Master__c schemeRef = new Scheme_Master__c(
                            Scheme_Name__c=leadRecord.schemename,
                            Scheme_Code__c=leadRecord.schemecode
                            );
                        objLANew.Scheme__r = schemeRef;
                        blnFindScheme = true;
                    }
                    // Need to confirm
                    if(!blnFindScheme && String.isNotBlank(leadRecord.schemecode)){
                        Scheme_Master__c schemeRef = new Scheme_Master__c(
                            Scheme_Code__c=leadRecord.schemecode
                            );
                        objLANew.Scheme__r = schemeRef;
                        blnFindScheme = true;
                    }
                    // Need to confirm
                    if(!blnFindScheme && String.isNotBlank(leadRecord.schemename)){
                        Scheme_Master__c schemeRef = new Scheme_Master__c(
                            Scheme_Name__c=leadRecord.schemename
                            );
                        objLANew.Scheme__r = schemeRef;
                        blnFindScheme = true;
                    }
                    /*
                    if(String.isNotBlank(leadRecord.schemecode)){
                        Scheme_Master__c schemeCodRef = new Scheme_Master__c(
                            Scheme_Code__c=leadRecord.schemecode);
                        objLANew.Scheme__r = schemeCodRef;
                    }
                    */
                    objLANew.Customer_Type__c = leadRecord.customertype;
                    objLANew.Customer_Name__c = leadRecord.customername;
                    if (String.isBlank(leadRecord.customermobile)) {
                        throw new CustomException('Mobile Number is mandatory to generate Lead.');
                    }
                    objLANew.Mobile__c = leadRecord.customermobile;
                    // check with Integer and NULL
                    objLANew.Loan_Amount__c = leadRecord.loanamount;
                    // check with NULL and String
                    objLANew.Follow_Up_Date__c = String.isNotBlank(leadRecord.followupdate) ?  Date.parse(leadRecord.followupdate) : NULL;
                    if (String.isNotBlank(leadRecord.followuptime)) {
                        String[] strTimeSplit = leadRecord.followuptime.split(':');
                        Time tmefollowUpTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]),0 , 0);   
                        objLANew.Follow_Up_Time__c = tmefollowUpTime;
                    }
                    objLANew.Vehicle_use__c = leadRecord.vehicleusage;
                    //objLANew.Follow_Up_Time__c - This need to be handeled.
                    //Need to handle customerpincode (Address__c    - Pincode__c)
                    objLANew.Purchase_City__c = leadRecord.purchasecity;
                    // check with Integer and NULL
                    objLANew.Total_Loan_Amount__c = leadRecord.totalloanamount;
                    // check with Integer and NULL
                    objLANew.ROI__c = leadRecord.roi;
                    objLANew.Tenure__c = leadRecord.tenure;
                    //objLANew.Promo_Code__c = leadRecord.promocode; //to be replaced with lookup field
                    objLANew.LC_Code__c = leadRecord.lccode;
                    objLANew.Type_of_Rate__c = leadRecord.typeofrate;
                    objLANew.Emi_Frequency__c = leadRecord.emifrequency;
                    objLANew.EMI_Date__c = leadRecord.emidate;
                    objLANew.Schedule_Type__c = leadRecord.scheduletype;
                    objLANew.Moratorium_Period__c = leadRecord.moratoriumperiod;
                    objLANew.Disbursement_Category__c = leadRecord.disbursementcategory;
                    objLANew.Repayment_Start_Date__c = String.isNotblank(leadRecord.repaymentstartdate) ? date.parse(leadRecord.repaymentstartdate) : NULL;
                    objLANew.Repayment_Bank_Name__c = leadRecord.repaymentbankname;
                    objLANew.Repayment_Account_Number__c = leadRecord.repaymentaccountnum;
                    objLANew.Repayment_Mode__c = leadRecord.repaymentmode;
                    objLANew.Stage__c = System.Label.API_Lead_DefaultStage;
                    objLANew.Sub_Stage__c = System.Label.API_Lead_DefaultSubStage;
                    
                    insert objLANew;
                }
            }

            List<Loan_Application__c> lstLead = [Select id, Name, Application_Id__c from Loan_Application__c where Id =: objLANew.Id LIMIT 1];

            
            if(!leadWrap.leadRecordList.isEmpty()){
                for(LeadWrapper.LeadRecord leadRecord: leadWrap.leadRecordList){
                    Loan_Application__c loanNew = new Loan_Application__c();
                    loanNew.RecordTypeId= mapObjWithRecordType.get('Lead');
                    loanNew.Product__c = leadRecord.productcode;
                    loanNew.Purpose_of_Loan__c = leadRecord.loanpurpose;
                    loanNew.Nature_of_Loan__c = leadRecord.loannature;
                    loanNew.Source_Name__c = leadRecord.sourcename;
                    loanNew.Sourcing_channel__c = leadRecord.sourcechannel;
                    loanNew.Campaign__c = leadRecord.campaignname;
                    /*
                     * if(String.isNotBlank(leadRecord.branchcode)){
                        Account branchRef = new Account(
                            Account_Code__c=leadRecord.branchcode);
                        loanNew.Branch_Master__r = branchRef;
                        setBranchDealerId.add(leadRecord.branchcode);
                    }
                    if(String.isNotBlank(leadRecord.dealercode)){
                        Account dealerRef = new Account(
                            Account_Code__c=leadRecord.dealercode);
                        loanNew.Dealer_Master__r = dealerRef;
                        setBranchDealerId.add(leadRecord.branchcode);
                    }
                    */
                    // Need to confirm
                    Boolean blnFindScheme = false;
                    if(String.isNotBlank(leadRecord.schemename) && String.isNotBlank(leadRecord.schemecode)){
                        Scheme_Master__c schemeRef = new Scheme_Master__c(
                            Scheme_Name__c=leadRecord.schemename,
                            Scheme_Code__c=leadRecord.schemecode
                            );
                        loanNew.Scheme__r = schemeRef;
                        blnFindScheme = true;
                    }
                    // Need to confirm
                    if(!blnFindScheme && String.isNotBlank(leadRecord.schemecode)){
                        Scheme_Master__c schemeRef = new Scheme_Master__c(
                            Scheme_Code__c=leadRecord.schemecode
                            );
                        loanNew.Scheme__r = schemeRef;
                        blnFindScheme = true;
                    }
                    /*
                     * // Need to confirm
                    if(!blnFindScheme && String.isNotBlank(leadRecord.schemename)){
                        Scheme_Master__c schemeRef = new Scheme_Master__c(
                            Scheme_Name__c=leadRecord.schemename
                            );
                        loanNew.Scheme__r = schemeRef;
                        blnFindScheme = true;
                    }
                    
                    if(String.isNotBlank(leadRecord.schemecode)){
                        Scheme_Master__c schemeCodRef = new Scheme_Master__c(
                            Scheme_Code__c=leadRecord.schemecode);
                        loanNew.Scheme__r = schemeCodRef;
                    }
                    */
                    loanNew.Customer_Type__c = leadRecord.customertype;
                    loanNew.Customer_Name__c = leadRecord.customername;
                    if (String.isBlank(leadRecord.customermobile)) {
                        throw new CustomException('Mobile Number is mandatory to generate Lead.');
                    }
                    loanNew.Mobile__c = leadRecord.customermobile;
                    // check with Integer and NULL
                    loanNew.Loan_Amount__c = leadRecord.loanamount;
                    // check with NULL and String
                    loanNew.Follow_Up_Date__c = String.isNotBlank(leadRecord.followupdate) ?  Date.parse(leadRecord.followupdate) : NULL;
                    if (String.isNotBlank(leadRecord.followuptime)) {
                        String[] strTimeSplit = leadRecord.followuptime.split(':');
                        Time tmefollowUpTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]),0 , 0);   
                        loanNew.Follow_Up_Time__c = tmefollowUpTime;
                    }
                    loanNew.Vehicle_use__c = leadRecord.vehicleusage;
                    //loanNew.Follow_Up_Time__c - This need to be handeled.
                    //Need to handle customerpincode (Address__c    - Pincode__c)
                    loanNew.Purchase_City__c = leadRecord.purchasecity;
                    // check with Integer and NULL
                    loanNew.Total_Loan_Amount__c = leadRecord.totalloanamount;
                    // check with Integer and NULL
                    loanNew.ROI__c = leadRecord.roi;
                    loanNew.Tenure__c = leadRecord.tenure;
                    //loanNew.Promo_Code__c = leadRecord.promocode; //to be replaced with lookup field
                    loanNew.LC_Code__c = leadRecord.lccode;
                    loanNew.Type_of_Rate__c = leadRecord.typeofrate;
                    loanNew.Emi_Frequency__c = leadRecord.emifrequency;
                    loanNew.EMI_Date__c = leadRecord.emidate;
                    loanNew.Schedule_Type__c = leadRecord.scheduletype;
                    loanNew.Moratorium_Period__c = leadRecord.moratoriumperiod;
                    loanNew.Disbursement_Category__c = leadRecord.disbursementcategory;
                    loanNew.Repayment_Start_Date__c = String.isNotblank(leadRecord.repaymentstartdate) ? date.parse(leadRecord.repaymentstartdate) : NULL;
                    loanNew.Repayment_Bank_Name__c = leadRecord.repaymentbankname;
                    loanNew.Repayment_Account_Number__c = leadRecord.repaymentaccountnum;
                    loanNew.Repayment_Mode__c = leadRecord.repaymentmode;
                    loanNew.Stage__c = System.Label.API_Lead_DefaultStage;
                    loanNew.Sub_Stage__c = System.Label.API_Lead_DefaultSubStage;
                    leadRecord.loanId = lstLead[0].Name;
                    loanNew.Lead_Id__c = leadRecord.loanId;
                    loanNew.Id = lstLead[0].Id;
                    mapLeadIdWithBranch.put(leadRecord.loanId,leadRecord.branchcode);
                    // Nominee Details
                    if (leadRecord.hasnominee != NULL && leadRecord.hasnominee == true){
                        Applicant__c nomineeRec = new Applicant__c();
                        Loan_Application__c loanRef = new Loan_Application__c(
                        Lead_Id__c= loanNew.Lead_Id__c);
                        nomineeRec.External_Lead_Id__c = loanNew.Lead_Id__c + '0';
                        nomineeRec.Loan__r =  loanRef;
                        nomineeRec.RecordTypeId = mapObjWithRecordType != NULL && mapObjWithRecordType.containsKey('Nominee') ? mapObjWithRecordType.get('Nominee') : NULL;
                        nomineeRec.Customer_Name__c = leadRecord.nomineename;
                        nomineeRec.Dob__c = String.isNotBlank(leadRecord.nomineedob) ? Date.parse(leadRecord.nomineedob) : NULL;
                        nomineeRec.Relationship_with_applicant__c = leadRecord.nomineerelationship;
                        nomineeRec.Percentage_Share_for_Nomination__c = leadRecord.nomineepercentage;
                        nomineeRec.Mobile_Number__c = leadRecord.nomineecontact;
                        applicantList.add(nomineeRec);
                    }
                    
                    
                    
                    Map<String,List<LeadWrapper.Address>> mapAppWithAddress = new  Map<String,List<LeadWrapper.Address>>();
                    Map<String,LeadWrapper.Finance> mapAppWithFinance = new  Map<String,LeadWrapper.Finance>();
                    Map<String,List<LeadWrapper.DocumentDetail>> mapApplicantWithDoc = new  Map<String,List<LeadWrapper.DocumentDetail>>();
                    
                    if(!leadRecord.detailsapplicant.isEmpty()){
                        Integer counter=0;
                        for(LeadWrapper.Applicant appRecord: leadRecord.detailsapplicant){
                            counter++;
                            Applicant__c applicantRecord = new Applicant__c();
                            applicantRecord = mapApplicantRecord(loanNew.Lead_Id__c, appRecord,counter,mapObjWithRecordType);
                            applicantRecord.Customer_Type__c = leadRecord.customertype;
                            // SFAU-5412
                            if (appRecord.applicanttype == 'Applicant') {
                                objPrimaryApp = applicantRecord;
                            }
                            applicantList.add(applicantRecord);
                            // Map - Applicant with Address
                            if (appRecord.detailsaddress != NULL && !appRecord.detailsaddress.isEmpty()) {
                                mapAppWithAddress.put(applicantRecord.External_Lead_Id__c,appRecord.detailsaddress);
                            }
                            // Map - Applicant with Financial
                            if (appRecord.detailsfinance != NULL) {
                                mapAppWithFinance.put(applicantRecord.External_Lead_Id__c,appRecord.detailsfinance);
                            }
                            // Map - Applicant with Document
                            if (appRecord.detailsapplicantdocument != NULL && !appRecord.detailsapplicantdocument.isEmpty()) {
                                mapApplicantWithDoc.put(applicantRecord.External_Lead_Id__c,appRecord.detailsapplicantdocument);
                            }
                        }
                    }
                    // Address Mapping
                    if (mapAppWithAddress != NULL && mapAppWithAddress.size()>0) {
                        for (String strAddKey : mapAppWithAddress.keySet()) {
                            for (LeadWrapper.Address objWrapAdd : mapAppWithAddress.get(strAddKey)){
                                Address__c objAdd = mapAddressRecord (objWrapAdd, strAddKey);
                                if (objAdd.Address_Type__c == 'Current' && String.isNotBlank(objAdd.Pincode__c)) {
                                    leadRecord.pincode = objAdd.Pincode__c;
                                    //mapLeadWithPin.put(loanNew.Lead_Id__c,objAdd.Pincode__c);
                                }
                                lstAddress.add(objAdd);
                            }
                        }
                    }
                    // Financial Account Mapping
                    if (mapAppWithFinance != NULL && mapAppWithFinance.size()>0) {
                        for (String strAddKey : mapAppWithFinance.keySet()) {
                            Integer counter = 1;
                            LeadWrapper.Finance objWrapFinance = mapAppWithFinance.get(strAddKey);
                            Applicant_Financials_Details__c objFin = new Applicant_Financials_Details__c();
                            Applicant__c appRef = new Applicant__c(
                            External_Lead_Id__c = strAddKey);
                            objFin.Applicant__r =  appRef;
                            objFin.External_Lead_Id__c = strAddKey + counter;
                            objFin.Type_Of_Employment__c = objWrapFinance.employmenttype;
                            objFin.Method_Of_Assesment__c = objWrapFinance.assessmentmethod;
                            objFin.Company_Name__c = objWrapFinance.companybusinessname;
                            objFin.Consider_Income_for_Eligibility__c = objWrapFinance.considerincomeeligible;
                            objFin.Customer_Grade__c = objWrapFinance.customergrade;
                            objFin.Monthly_Income__c = objWrapFinance.monthlyincome;
                            objFin.Monthly_Obligation__c = objWrapFinance.monthlyobligation;
                            objFin.Other_Income__c = objWrapFinance.otherincomeamt;
                            objFin.Sector__c = objWrapFinance.sector;
                            objFin.Industry__c = objWrapFinance.industry;
                            objFin.Sub_Industry__c = objWrapFinance.industrysubtype;
                            objFin.Occupation__c = objWrapFinance.occupation;
                            objFin.RecordtypeId = mapObjWithRecordType.get('Financial Parent');
                            lstFinancialParent.add(objFin);
                            Applicant_Financials_Details__c objpRef = new Applicant_Financials_Details__c(External_Lead_Id__c = objFin.External_Lead_Id__c);
                            // Financial Other Income
                            if (objWrapFinance.finotherIncome != NULL && !objWrapFinance.finotherIncome.isEmpty()){
                                for (LeadWrapper.FinanceOtherIncome finOther : objWrapFinance.finotherIncome){
                                    Applicant_Financials_Details__c objFinOther = new Applicant_Financials_Details__c();
                                    objfinOther.RecordtypeId = mapObjWithRecordType.get('Other Income');
                                    objFinOther.Applicant__r =  appRef;
                                    objFinOther.Applicant_Financials__c = NULL;
                                    objFinOther.External_Lead_Id__c = strAddKey + counter;
                                    objFinOther = mapFinancialAccountOtherIncome (finOther, objFinOther);
                                    lstFinancialChild.add(objFinOther);
                                }
                            }
                            // Financial Diary
                            if (objWrapFinance.findairybusiness != NULL && !objWrapFinance.findairybusiness.isEmpty()){
                                for (LeadWrapper.FinanceDairyBusiness finDairyBusiness : objWrapFinance.findairybusiness){
                                    Applicant_Financials_Details__c objFinDairy = new Applicant_Financials_Details__c();
                                    objFinDairy.Applicant__r =  appRef;
                                    objFinDairy.Applicant_Financials__c = NULL;
                                    objFinDairy.External_Lead_Id__c = strAddKey + counter;
                                    objFinDairy.RecordtypeId = mapObjWithRecordType.get('Farmer - Dairy Business');
                                    objFinDairy = mapFinancialAccountDairy (finDairyBusiness, objFinDairy);
                                    lstFinancialChild.add(objFinDairy);
                                }
                            }
                            // Financial Farmer Commercial
                            if (objWrapFinance.finfarmercommercial != NULL && !objWrapFinance.finfarmercommercial.isEmpty()){
                                for (LeadWrapper.FinanceFarmerCommercial finDairyBusiness : objWrapFinance.finfarmercommercial){
                                    Applicant_Financials_Details__c objFinFarmCom = new Applicant_Financials_Details__c();
                                    objFinFarmCom.Applicant__r =  appRef;
                                    objFinFarmCom.Applicant_Financials__c = NULL;
                                    objFinFarmCom.External_Lead_Id__c = strAddKey + counter;
                                    objFinFarmCom.RecordtypeId = mapObjWithRecordType.get('Farmer - Commercial');
                                    objFinFarmCom = mapFinancialAccountFarmerCommercial (finDairyBusiness, objFinFarmCom);
                                    lstFinancialChild.add(objFinFarmCom);
                                }
                            }
                            // Financial Owner Or Rented Land
                            if (objWrapFinance.finagriownorrentland != NULL && !objWrapFinance.finagriownorrentland.isEmpty()){
                                for (LeadWrapper.FinanceAgriOwnorRentLand finOwnOrRent : objWrapFinance.finagriownorrentland){
                                    Applicant_Financials_Details__c objFinOwnRent = new Applicant_Financials_Details__c();
                                    objFinOwnRent.Applicant_Financials__c = NULL;
                                    objFinOwnRent.External_Lead_Id__c = strAddKey + counter;
                                    objFinOwnRent.Applicant__r =  appRef;
                                    if (finOwnOrRent.landType == 'Own') {
                                        objFinOwnRent.RecordtypeId = mapObjWithRecordType.get('Farmer - Agriculture Own Land');
                                    }
                                    else if (finOwnOrRent.landType == 'Rent'){
                                        objFinOwnRent.RecordtypeId = mapObjWithRecordType.get('Farmer - Agriculture Rented Land');
                                    }
                                    objFinOwnRent = mapFinancialAgriOwnOrRentLand (finOwnOrRent, objFinOwnRent);
                                    lstFinancialChild.add(objFinOwnRent);
                                }
                            }
                            // Financial Document Without Audit
                            if (objWrapFinance.findocumentwithoutaudit != NULL && !objWrapFinance.findocumentwithoutaudit.isEmpty()){
                                for (LeadWrapper.FinanceDocumentWithoutAudit finWOAudit : objWrapFinance.findocumentwithoutaudit){
                                    Applicant_Financials_Details__c objFinWOAudit = new Applicant_Financials_Details__c();
                                    objFinWOAudit.Applicant_Financials__c = NULL;
                                    objFinWOAudit.External_Lead_Id__c = strAddKey + counter;
                                    objFinWOAudit.Applicant__r =  appRef;
                                    objFinWOAudit.RecordtypeId = mapObjWithRecordType.get('Documented Without Audited financial');
                                    objFinWOAudit = mapFinancialDocumentWithoutAudit (finWOAudit, objFinWOAudit);
                                    lstFinancialChild.add(objFinWOAudit);
                                }
                            }
                            // Financial Document With Audit
                            if (objWrapFinance.findocumentwithaudit != NULL && !objWrapFinance.findocumentwithaudit.isEmpty()){
                                for (LeadWrapper.FinanceDocumentWithAudit finWithAudit : objWrapFinance.findocumentwithaudit){
                                    Applicant_Financials_Details__c objFinWithAudit = new Applicant_Financials_Details__c();
                                    objFinWithAudit.Applicant_Financials__c = NULL;
                                    objFinWithAudit.Applicant__r =  appRef;
                                    objFinWithAudit.External_Lead_Id__c = strAddKey + counter;
                                    objFinWithAudit.RecordtypeId = mapObjWithRecordType.get('Documented With Audited financial');
                                    objFinWithAudit = mapFinancialDocumentWithAudit (finWithAudit, objFinWithAudit);
                                    lstFinancialChild.add(objFinWithAudit);
                                }
                            }
                            // Financial Document Without Document
                            if (objWrapFinance.finaddresswithoutdocument != NULL && !objWrapFinance.finaddresswithoutdocument.isEmpty()){
                                for (LeadWrapper.FinanceAssessedNodocument finAssWODoc : objWrapFinance.finaddresswithoutdocument){
                                    Applicant_Financials_Details__c objFinAssWODoc = new Applicant_Financials_Details__c();
                                    objFinAssWODoc.Applicant__r =  appRef;
                                    objFinAssWODoc.Applicant_Financials__c = NULL;
                                    objFinAssWODoc.External_Lead_Id__c = strAddKey + counter;
                                    objFinAssWODoc.RecordtypeId = mapObjWithRecordType.get('Assessed No Document');
                                    objFinAssWODoc = mapFinancialAssessNoDocument (finAssWODoc, objFinAssWODoc);
                                    lstFinancialChild.add(objFinAssWODoc);
                                }
                            }
                            // Financial - Salary
                            if (objWrapFinance.finsalary != NULL){
                                Applicant_Financials_Details__c objFinSalary = new Applicant_Financials_Details__c();
                                objFinSalary.Applicant__r =  appRef;
                                objFinSalary.Applicant_Financials__c = NULL;
                                objFinSalary.External_Lead_Id__c = strAddKey + counter;
                                objFinSalary.RecordtypeId = mapObjWithRecordType.get('Salaried Document');
                                objFinSalary = mapFinancialAccountSalary (objWrapFinance.finsalary, objFinSalary);
                                lstFinancialChild.add(objFinSalary);
                            }
                            mapAppParentWithChild.put(objFin.External_Lead_Id__c,lstFinancialChild);
                            counter++;
                        }
                    }
                    // Colleteral Mapping
                    LeadWrapper.Vehicle wrapCol = leadRecord.detailsvehicle;
                    if (wrapCol != NULL) {
                        Integer counter = 1;
                        Collateral__c objCol = mapCollateral (wrapCol, loanNew.Lead_Id__c, mapObjWithRecordType,counter);
                        lstCollateral.add(objCol);
                        // Valuation Mapping
                        if (wrapCol.detailsvaluation != NULL && wrapCol.detailsvaluation.size()>0) {
                            for (LeadWrapper.Valuations objValWrao : wrapCol.detailsvaluation) {
                                Valuation__c objValuation = mapValuation (objValWrao, objCol.External_Lead_Id__c);
                                lstValuation.add(objValuation);
                            }
                        }
                        
                        
                    }
                    // Charge Mapping
                    List<LeadWrapper.Charge> lstWrapCharge = leadRecord.detailscharge;
                    if (lstWrapCharge != NULL) {
                        for (LeadWrapper.Charge objChargeWrap : lstWrapCharge) {
                            Charge__c objCharge = mapCharge (objChargeWrap, loanNew.Lead_Id__c);
                            lstCharge.add(objCharge);
                        }
                    }
                    // Applicant Document Mapping
                    if (mapApplicantWithDoc != NULL && mapApplicantWithDoc.size()>0) {
                        for (String strAppKey : mapApplicantWithDoc.keySet()) {
                            for (LeadWrapper.DocumentDetail wrapDoc : mapApplicantWithDoc.get(strAppKey)){
                                mapKeyWithDocument.put(strAppKey+','+wrapDoc.documentId,wrapDoc);
                            }
                        }
                    }
                    /*
                    if (mapApplicantWithDoc != NULL && mapApplicantWithDoc.size()>0) {
                        for (String strAppKey : mapApplicantWithDoc.keySet()) {
                            Integer counter = 1;
                            for (LeadWrapper.DocumentDetail wrapDoc : mapApplicantWithDoc.get(strAppKey)){
                                Document_Checklist__c objAppDocCheck = mapDocumentchecklistRecord (wrapDoc, strAppKey,loanNew.Lead_Id__c, counter);
                                lstDocumentcheck.add(objAppDocCheck);
                                mapKeyWithDocument.put(strAppKey+','+wrapDoc.documentId,objAppDocCheck);
                                counter++;
                            }
                        }
                    }
                    */

                    // Reference Mapping
                    List<LeadWrapper.Reference> lstWrapRef = leadRecord.detailsreference;
                    if (lstWrapRef != NULL) {
                        List<Object> lstReference = new List<Object>();
                        for (LeadWrapper.Reference objRef : lstWrapRef) {
                            //strReference = mapReference (objRef,strReference);
                            //strReference = strReference + (String.isNotBlank(strReference) ? ',' : '') + JSON.serialize(objRef);
                            lstReference.add((Object)objRef);
                        }
                        loanNew.References__c = JSON.serialize(lstReference);
                    }
                    
                    // Application - Document Mapping
                    List<LeadWrapper.DocumentDetail> lstAppDocumentList = leadRecord.detailsappdocument;
                    if (lstAppDocumentList != NULL) {
                        for (LeadWrapper.DocumentDetail objAppDocList : lstAppDocumentList) {
                            mapKeyWithDocument.put(loanNew.Lead_Id__c+','+objAppDocList.documentId,objAppDocList);
                        }
                    }
                    /*
                    List<LeadWrapper.DocumentDetail> lstAppDocumentList = leadRecord.detailsappdocument;
                    if (lstAppDocumentList != NULL) {
                        for (LeadWrapper.DocumentDetail objAppDocList : lstAppDocumentList) {
                            Integer counter = 1;
                            Document_Checklist__c objAppDocCheck = mapDocumentchecklistRecord (objAppDocList, NULL,loanNew.Lead_Id__c, counter);
                                lstDocumentcheck.add(objAppDocCheck);
                                mapKeyWithDocument.put(loanNew.Lead_Id__c+','+wrapDoc.documentId,objAppDocCheck);
                                counter++;
                        }
                    }
                    */
                    loanList.add(loanNew);
                }
            }

            system.debug(LoggingLevel.Info,'Information :: Line Number 446');
            leadWrap.dealerCodeVsOwner = new Map<String,String>();
            leadWrap.pinCodeVsOwner = new Map<String,String>();
            leadWrap.mapLeadIdWithOwnerId = new Map<String,String>();


            // Set Lead Ownership
            LeadWrapper objLeadWrapperOwner = LeadAssignementUtility.returnLeadAssignment(leadWrap);
            Map<String,Account> mapLeadWithBranch  = objLeadWrapperOwner.mapLeadWithBranch;

            Map<String,Account> mapAccountCodeWithAccount = new Map<String,Account>();
            if (setBranchDealerId.size()> 0) {
                for (Account objAcc : [SELECT Id, Account_Code__c, Name from Account where Account_Code__c in: setBranchDealerId]){
                    mapAccountCodeWithAccount.put(objAcc.Account_Code__c,objAcc);
                }
            }

            for (Loan_Application__c objLA : loanList) {
                system.debug(LoggingLevel.Info,'Lead Id ' + objLA.Lead_Id__c);
                system.debug(LoggingLevel.Info,' objLeadWrapperOwner ' + objLeadWrapperOwner.mapLeadIdWithOwnerId);
                system.debug(LoggingLevel.Info,' objLeadWrapperOwner ' + objLeadWrapperOwner.mapLeadIdWithOwnerId.containsKey(objLA.Lead_Id__c));

                if(objLeadWrapperOwner != NULL && objLeadWrapperOwner.mapLeadIdWithOwnerId != NULL && objLeadWrapperOwner.mapLeadIdWithOwnerId.containsKey(objLA.Lead_Id__c)) {
                    objLA.OwnerId = objLeadWrapperOwner.mapLeadIdWithOwnerId.get(objLA.Lead_Id__c);
                }
                if (mapLeadWithBranch != NULL && mapLeadWithBranch.containsKey(objLA.Lead_Id__c)) {
                    objLA.Branch__c = mapLeadWithBranch.get(objLA.Lead_Id__c).Name;
                    objLA.Branch_Master__c = mapLeadWithBranch.get(objLA.Lead_Id__c).Id;
                }
                else if (mapLeadIdWithBranch.containsKey(objLA.Lead_Id__c) && mapAccountCodeWithAccount.containsKey(mapLeadIdWithBranch.get(objLA.Lead_Id__c))) {
                    objLA.Branch__c = mapAccountCodeWithAccount.get(mapLeadIdWithBranch.get(objLA.Lead_Id__c)).Name;
                }
            }

            system.debug(LoggingLevel.Info,'Information :: Line Number 461');
            if(!loanList.isEmpty()){
                upsert loanList;
                system.debug(LoggingLevel.Info,'Loan Id ' + loanList[0].Id);
            }

            lstLead = [Select id, Name, Application_Id__c from Loan_Application__c where Id in: loanList];
            
            if(!applicantList.isEmpty()){
                insert applicantList;
            }
            if (!lstAddress.isEmpty()){
                insert lstAddress;
            }
            if (!lstFinancialParent.isEmpty()) {
                insert lstFinancialParent;
            }
            if (mapAppParentWithChild.size()>0) {
                for (Applicant_Financials_Details__c objFin : [Select id, External_Lead_Id__c from Applicant_Financials_Details__c where Id in: lstFinancialParent]) {
                    for (Applicant_Financials_Details__c objChild : lstFinancialChild) {
                        if (mapAppParentWithChild.containsKey(objFin.External_Lead_Id__c)) {
                            objChild.Applicant_Financials__c = objFin.Id;
                        }
                    }
                }
                insert lstFinancialChild;
            }
            if (!lstCollateral.isEmpty()){
                insert lstCollateral;
            }
            //Upsert Collateral to update Collateral Id
            List<Collateral__c> lstUpsertCollateral = new List<Collateral__c>();
            for (Collateral__c objCol : [Select Id, Name, Loan__r.Product__c, MMV_Master__c, MMV_Master__r.Collateral_Name__c, Collateral_Name__c FROM Collateral__c where Id in: lstCollateral]) {
                Collateral__c objC = new Collateral__c();
                objC = objCol;
                objC.Collateral_Id__c = objCol.Loan__r.Product__c + objCol.Name + Integer.valueof((Math.random() * 10));
                objC.Collateral_Name__c = objCol.MMV_Master__c != NULL && objCol.MMV_Master__r.Collateral_Name__c != NULL ? objCol.MMV_Master__r.Collateral_Name__c : objCol.Collateral_Name__c;
                lstUpsertCollateral.add(objC);
            }
            if (!lstUpsertCollateral.isEmpty()){
                upsert lstUpsertCollateral;
            }
            if (!lstValuation.isEmpty()){
                insert lstValuation;
            }
            if (!lstCharge.isEmpty()){
                insert lstCharge;
            }
            //List<Document_Checklist__c> lstDocCheckByAutomation = [Select Id, Name, Loan_Application__c, Applicant__c, Checklist_ID__c, Document_Master__c, Document_Master__r.Document_Id__c, Document_Master__r.Document_Name__c from Document_Checklist__c WHERE (Loan_Application__c in: lstLead OR Applicant__r.Loan__c in: lstLead) WITH SECURITY_ENFORCED];
            Integer intApplicantCounter = 0;
            Integer intApplicationCounter = 0;
            for (Document_Checklist__c objDC : [Select Id, Name, Loan_Application__c, Loan_Application__r.Lead_Id__c, Applicant__c, Applicant__r.External_Lead_Id__c, Applicant__r.Loan__r.Lead_Id__c, Checklist_ID__c, Document_Master__c, Document_Master__r.Document_Id__c, Document_Master__r.Document_Name__c from Document_Checklist__c WHERE (Loan_Application__c in: lstLead OR Applicant__r.Loan__c in: lstLead) WITH SECURITY_ENFORCED]) {
                if (objDC.Applicant__c != NULL && mapKeyWithDocument.containsKey(objDC.Applicant__r.External_Lead_Id__c + ',' + objDC.Document_Master__r.Document_Id__c)) {
                    intApplicantCounter ++;
                    LeadWrapper.DocumentDetail wrapDoc = mapKeyWithDocument.get(objDC.Applicant__r.External_Lead_Id__c + ',' + objDC.Document_Master__r.Document_Id__c);
                    Document_Checklist__c objAppDocCheck = mapDocumentchecklistRecord (wrapDoc, objDC.Applicant__r.External_Lead_Id__c, objDC.Applicant__r.Loan__r.Lead_Id__c, intApplicantCounter, objDC);
                    lstDocumentcheck.add(objAppDocCheck);
                }
                else if (objDC.Loan_Application__c != NULL && mapKeyWithDocument.containsKey(objDC.Loan_Application__r.Lead_Id__c + ',' + objDC.Document_Master__r.Document_Id__c)) {
                    intApplicationCounter++;
                    LeadWrapper.DocumentDetail objAppDocList = mapKeyWithDocument.get(objDC.Loan_Application__r.Lead_Id__c + ',' + objDC.Document_Master__r.Document_Id__c);
                    Document_Checklist__c objAppDocCheck = mapDocumentchecklistRecord (objAppDocList, NULL, objDC.Loan_Application__r.Lead_Id__c, intApplicationCounter, objDC);
                    lstDocumentcheck.add(objAppDocCheck);
                }
            }
            if (!lstDocumentcheck.isEmpty()){
                upsert lstDocumentcheck;
            }
            //List<Document_Checklist__c> lstNewDocument = new List<Document_Checklist__c>();
            //lstNewDocument = [Select Id, Name, Loan_Application__c, Applicant__c, Checklist_ID__c, Document_Master__c, Document_Master__r.Document_Id__c, Document_Master__r.Document_Name__c from Document_Checklist__c where Id in: lstDocumentcheck WITH SECURITY_ENFORCED];
            objResponse.leadId = lstLead[0].Name;
            objResponse.loanId = lstLead[0].Name;
            objResponse.detailsapplicant = new List<LeadResponseWrapper.Applicant>();
            for(Applicant__c objApp : applicantList){
                LeadResponseWrapper.Applicant wrapApp = new LeadResponseWrapper.Applicant();
                wrapApp.applicantId = objApp.External_Lead_Id__c;
                wrapApp.applicanttype = mapRTIdWithName.containsKey(objApp.RecordtypeId) ? mapRTIdWithName.get(objApp.RecordTypeId) : '';
                wrapApp.detailsaddress = new List<LeadResponseWrapper.Address>();
                wrapApp.detailsapplicantdocument = new List<LeadResponseWrapper.DocumentDetail>();
                // Address
                for(Address__c objAdd : lstAddress) {
                    LeadResponseWrapper.Address wrapAdd = new LeadResponseWrapper.Address();
                    wrapAdd.addresstype = objAdd.Address_Type__c;
                    wrapAdd.addressid = objAdd.Id;
                    wrapAdd.status = 'Success';
                    wrapApp.detailsaddress.add(wrapAdd);
                }
                // Document Checklist
                for (Document_Checklist__c objDoc : lstDocumentcheck){
                    if (objDoc.Applicant__c == objApp.Id){
                        LeadResponseWrapper.DocumentDetail wrapDoc = new LeadResponseWrapper.DocumentDetail();
                        wrapDoc.documentId = objDoc.Id + IntegrationUtility.getReferenceId().subString(3);
                        wrapDoc.documentname = objDoc.Document_Master__r.Document_Id__c;

                        wrapDoc.status = 'Success';
                        wrapApp.detailsapplicantdocument.add(wrapDoc);
                    }
                }
                wrapApp.detailsfinance = new LeadResponseWrapper.Finance();
                wrapApp.detailsfinance.finotherIncome = new List<LeadResponseWrapper.FinanceOtherIncome>();
                wrapApp.detailsfinance.findairybusiness = new List<LeadResponseWrapper.FinanceDairyBusiness>();
                wrapApp.detailsfinance.finfarmercommercial = new List<LeadResponseWrapper.FinanceFarmerCommercial>();
                wrapApp.detailsfinance.finagriownorrentland = new List<LeadResponseWrapper.FinanceAgriOwnorRentLand>();
                wrapApp.detailsfinance.findocumentwithoutaudit = new List<LeadResponseWrapper.FinanceDocumentWithoutAudit>();
                wrapApp.detailsfinance.Findocumentwithaudit = new List<LeadResponseWrapper.FinanceDocumentWithAudit>();
                wrapApp.detailsfinance.Finaddresswithoutdocument = new List<LeadResponseWrapper.FinanceAssessedNodocument>();
                for (Applicant_Financials_Details__c objFin : lstFinancialParent) {
                    if(mapRTIdWithName.containsKey(objFin.RecordTypeId) && mapRTIdWithName.get(objFin.RecordTypeId) == 'Finance') {
                        wrapApp.detailsfinance.recordid = objFin.Id;
                        wrapApp.detailsfinance.status = 'Success';
                    }
                }
                for (Applicant_Financials_Details__c objFin : lstFinancialChild) {
                    if(mapRTIdWithName.containsKey(objFin.RecordTypeId) && mapRTIdWithName.get(objFin.RecordTypeId) == 'FinanceSalary') {
                        LeadResponseWrapper.FinanceSalary wrapFin = new LeadResponseWrapper.FinanceSalary();
                        wrapFin.recordid = objFin.Id;
                        wrapFin.status = 'Success';
                        wrapApp.detailsfinance.finsalary = wrapFin;
                    }
                    else if(mapRTIdWithName.containsKey(objFin.RecordTypeId) && mapRTIdWithName.get(objFin.RecordTypeId) == 'FinanceAssessedNodocument') {
                        LeadResponseWrapper.FinanceAssessedNodocument wrapFin = new LeadResponseWrapper.FinanceAssessedNodocument();
                        wrapFin.recordid = objFin.Id;
                        wrapFin.status = 'Success';
                        wrapApp.detailsfinance.finaddresswithoutdocument.add(wrapFin);
                    }
                    else if(mapRTIdWithName.containsKey(objFin.RecordTypeId) && mapRTIdWithName.get(objFin.RecordTypeId) == 'FinanceDocumentWithAudit') {
                        LeadResponseWrapper.FinanceDocumentWithAudit wrapFin = new LeadResponseWrapper.FinanceDocumentWithAudit();
                        wrapFin.recordid = objFin.Id;
                        wrapFin.status = 'Success';
                        wrapApp.detailsfinance.findocumentwithaudit.add(wrapFin);
                    }
                    else if(mapRTIdWithName.containsKey(objFin.RecordTypeId) && mapRTIdWithName.get(objFin.RecordTypeId) == 'FinanceDocumentWithoutAudit') {
                        LeadResponseWrapper.FinanceDocumentWithoutAudit wrapFin = new LeadResponseWrapper.FinanceDocumentWithoutAudit();
                        wrapFin.recordid = objFin.Id;
                        wrapFin.status = 'Success';
                        wrapApp.detailsfinance.findocumentwithoutaudit.add(wrapFin);
                    }
                    else if(mapRTIdWithName.containsKey(objFin.RecordTypeId) && (mapRTIdWithName.get(objFin.RecordTypeId) == 'FinanceAgriRentLand' || mapRTIdWithName.get(objFin.RecordTypeId) == 'FinanceAgriOwnLand')) {
                        LeadResponseWrapper.FinanceAgriOwnorRentLand wrapFin = new LeadResponseWrapper.FinanceAgriOwnorRentLand();
                        wrapFin.recordid = objFin.Id;
                        wrapFin.status = 'Success';
                        wrapApp.detailsfinance.finagriownorrentland.add(wrapFin);
                    }
                    else if(mapRTIdWithName.containsKey(objFin.RecordTypeId) && mapRTIdWithName.get(objFin.RecordTypeId) == 'FinanceFarmerCommercial') {
                        LeadResponseWrapper.FinanceFarmerCommercial wrapFin = new LeadResponseWrapper.FinanceFarmerCommercial();
                        wrapFin.recordid = objFin.Id;
                        wrapFin.status = 'Success';
                        wrapApp.detailsfinance.finfarmercommercial.add(wrapFin);
                    }
                    else if(mapRTIdWithName.containsKey(objFin.RecordTypeId) && mapRTIdWithName.get(objFin.RecordTypeId) == 'FinanceDairyBusiness') {
                        LeadResponseWrapper.FinanceDairyBusiness wrapFin = new LeadResponseWrapper.FinanceDairyBusiness();
                        wrapFin.recordid = objFin.Id;
                        wrapFin.status = 'Success';
                        wrapApp.detailsfinance.findairybusiness.add(wrapFin);
                    }
                    else if(mapRTIdWithName.containsKey(objFin.RecordTypeId) && mapRTIdWithName.get(objFin.RecordTypeId) == 'FinanceOtherIncome') {
                        LeadResponseWrapper.FinanceOtherIncome wrapFin = new LeadResponseWrapper.FinanceOtherIncome();
                        wrapFin.recordid = objFin.Id;
                        wrapFin.status = 'Success';
                        wrapApp.detailsfinance.finotherIncome.add(wrapFin);
                    }
                    /*
                    else if(mapRTIdWithName.containsKey(objFin.RecordTypeId) && mapRTIdWithName.get(objFin.RecordTypeId) == 'Finance') {
                        wrapApp.detailsfinance.recordid = objFin.Id;
                        wrapApp.detailsfinance.status = 'Success';
                    }
                    */
                }
                objResponse.detailsapplicant.add(wrapApp);
            }
            // Vehicle
            objResponse.detailsvehicle = new LeadResponseWrapper.Vehicle();
            objResponse.detailsvehicle.recordid = !lstCollateral.isEmpty() ? lstCollateral[0].External_Lead_Id__c : NULL;
            objResponse.detailsvehicle.detailsvaluation = new List<LeadResponseWrapper.Valuations>();
            // Valuation
            for (Valuation__c objValue : lstValuation){
                LeadResponseWrapper.Valuations wrapVal = new LeadResponseWrapper.Valuations();
                wrapVal.recordid = objValue.Id;
                wrapVal.status = 'Success';
                objResponse.detailsvehicle.detailsvaluation.add(wrapVal);
            }
            // Charge
            objResponse.detailscharge = new List<LeadResponseWrapper.Charge>();
            for(Charge__c objCharge : lstCharge){
                LeadResponseWrapper.Charge wrapCharge = new LeadResponseWrapper.Charge();
                wrapCharge.recordid = objCharge.Id;
                wrapCharge.status = 'Success';
                objResponse.detailscharge.add(wrapCharge);
            }

            // Document Checklist
            objResponse.detailsappdocument = new List<LeadResponseWrapper.DocumentDetail>();
            for (Document_Checklist__c objDoc : lstDocumentcheck){
                if (objDoc.Loan_Application__c == loanList[0].Id){
                    LeadResponseWrapper.DocumentDetail wrapDoc = new LeadResponseWrapper.DocumentDetail();
                    wrapDoc.documentId = objDoc.Id + IntegrationUtility.getReferenceId().subString(3);
                    wrapDoc.documentname = objDoc.Document_Master__r.Document_Id__c;
                    wrapDoc.status = 'Success';
                    objResponse.detailsappdocument.add(wrapDoc);
                }
            }
            
            objIntCheck.Request__c = req.requestBody.toString();
            objIntCheck.Response_Received_At__c = system.now();
            objIntCheck.API_Error__c = loanList[0].Id;
            objIntCheck.Response__c = JSON.serialize(objResponse);
            objIntCheck.Loan_Application__c = loanList[0].Id;
            insert objIntCheck;

            // START- SFAU-5412 Check for Update Primary Applicant on Loan Application
            
            if (objPrimaryApp != NULL && String.isNotBlank(objPrimaryApp.External_Lead_Id__c)) {
                List<Loan_Application__c> lstLoanAppWithPrimaryApp = new List<Loan_Application__c>();
                lstLoanAppWithPrimaryApp = [Select Id, Primary_Applicant__c, Customer_Name__c, Primary_Applicant__r.External_Lead_Id__c from Loan_Application__c where Id in: loanList and (Primary_Applicant__c = NULL AND Customer_Name__c = '')];
                if (lstLoanAppWithPrimaryApp.size() == 0) {
                    Loan_Application__c objPrimaryApplication = new  Loan_Application__c();
                    objPrimaryApplication.Id = loanList[0].Id;
                    Applicant__c appRef = new Applicant__c(External_Lead_Id__c = objPrimaryApp.External_Lead_Id__c);
                    objPrimaryApplication.Primary_Applicant__r = appRef;
                    objPrimaryApplication.Customer_Name__c = ((String.isBlank(objPrimaryApp.First_Name__c) ? '' : objPrimaryApp.First_Name__c + ' ') + (String.isBlank(objPrimaryApp.Middle_Name__c) ? '' : objPrimaryApp.Middle_Name__c) + (String.isBlank(objPrimaryApp.Last_Name__c) ? '' : objPrimaryApp.Last_Name__c)).trim();
                    update objPrimaryApplication;
                }
            }
            // END - SFAU-5412


            objResponse.success = true;
            objResponse.status = 'Success';
            objResponse.duration = Double.valueOf((objIntCheck.Response_Received_At__c.getTime() - objIntCheck.Request_Initiated_At__c.getTime()));

            
            
        }catch(Exception objException){
            Database.rollback(sp);
            objResponse.success = false;
            objResponse.error = true;
            objResponse.status = 'Error';
            //if (objException.subString(''))
            objResponse.errormsg = objException.getMessage();

            objIntCheck.Response_Received_At__c = System.now();
            objIntCheck.Request__c = req.requestBody.toString();
            objIntCheck.API_Error__c = objException + '';
            objIntCheck.Response__c = JSON.serialize(objResponse);
            insert objIntCheck;

            objResponse.duration = Double.valueOf((objIntCheck.Response_Received_At__c.getTime() - objIntCheck.Request_Initiated_At__c.getTime()));
            system.debug('Exception line Error '+objException.getMessage());
            system.debug('Exception line Error '+objException);
            system.debug('Exception line '+objException.getLineNumber());
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(objResponse));
        
    }

    private static Applicant__c mapApplicantRecord(String strLeadId, LeadWrapper.Applicant appRecord, Integer counter, Map<String,Id> mapObjWithRecordType) {
        try{
            Applicant__c applicantRecord = new Applicant__c();
            Loan_Application__c loanRef = new Loan_Application__c(
            Lead_Id__c= strLeadId);
            applicantRecord.External_Lead_Id__c = strLeadId + counter;
            applicantRecord.Loan__r =  loanRef;
            applicantRecord.Existing_Customer__c = appRecord.existingcustomer;
            applicantRecord.RecordTypeId = mapObjWithRecordType != NULL && mapObjWithRecordType.containsKey(appRecord.applicanttype) ? mapObjWithRecordType.get(appRecord.applicanttype) : NULL;
            /*
            if(appRecord.applicanttype =='Applicant'){
                applicantRecord.RecordTypeId = mapObjWithRecordType.get('applicanttype');
            }else if(appRecord.applicanttype =='Co-Applicant'){
                applicantRecord.RecordTypeId = mapObjWithRecordType.get('Co-Applicant');
            }else if(appRecord.applicanttype =='Guarantor'){
                applicantRecord.RecordTypeId = mapObjWithRecordType.get('Guarantor');
            }
            */
            applicantRecord.Dob__c = String.isNotBlank(appRecord.dob) ? date.parse(appRecord.dob) : NULL;
            applicantRecord.Aadhaar_Number__c = appRecord.aadhaarno;
            applicantRecord.PAN__c = appRecord.panno;
            applicantRecord.Voter_Id__c = appRecord.voterid;
            applicantRecord.Pan_Form60__c= appRecord.panform60 ;
            applicantRecord.Driving_License_Id__c = appRecord.drivinglicense;
            //check and confirm
            //applicantRecord.drivinglicenseexpiry = 
            applicantRecord.Passport_Number__c = apprecord.passportno;
            applicantRecord.NPR__c = appRecord.npr;
            applicantRecord.NREGA__c = appRecord.nrega;
            applicantRecord.PAN_verification_Status__c = appRecord.panverificationstatus;
            applicantRecord.Title__c = appRecord.title;
            applicantRecord.First_Name__c = appRecord.fname;
            applicantRecord.Middle_Name__c = appRecord.mname;
            applicantRecord.Last_Name__c = appRecord.lname;
            applicantRecord.Gender__c = appRecord.gender;
            applicantRecord.Father_Name__c = appRecord.fathername;
            applicantRecord.Mother_Name__c = appRecord.mothername;
            applicantRecord.Marital_Status__c = appRecord.maritialstatus;
            applicantRecord.Spouse_Name__c = appRecord.spousename;
            applicantRecord.High_risk_Profile__c = appRecord.highriskprofile;
            applicantRecord.Residential_Status__c = appRecord.residentstatus;
            applicantRecord.Mobile_Number__c = appRecord.contactmobile;
            applicantRecord.Alternate_Mobile_Number__c = appRecord.altmobile;
            applicantRecord.Email__c = appRecord.contactemailid;
            applicantRecord.IsEmailVerified__c = appRecord.emailverified == null ? false : appRecord.emailverified;
            applicantRecord.Caste__c = appRecord.caste;
            applicantRecord.Religion__c = appRecord.religion;
            applicantRecord.Key_Person__c = appRecord.keyperson;
            applicantRecord.Risk_Category__c = appRecord.riskcategory;
            applicantRecord.No_of_Dependents__c = appRecord.noofdependent;
            applicantRecord.Politically_Exposed_Person__c = appRecord.politicalexposed;
            applicantRecord.Relationship_with_applicant__c = appRecord.relationtype;
            applicantRecord.Constitution_Type__c = appRecord.constype;
            applicantRecord.Reg_No__c = appRecord.regno;
            applicantRecord.GST_NO__c = appRecord.gstno;
            applicantRecord.UDYAM_Registration_Number__c = appRecord.udyamno;
            applicantRecord.TIN__c = appRecord.tinno;
            applicantRecord.CIN__c = appRecord.cinno;
            applicantRecord.Entity_Name__c = appRecord.enityname;
            applicantRecord.Key_Contact_Name__c = appRecord.keycontactname;
            String strEstDate = appRecord.eastablishdate;
            applicantRecord.Date_of_Establishment__c = String.isNotblank(strEstDate) ? date.parse(strEstDate) : NULL;
            applicantRecord.Phsically_challenged__c = appRecord.physicallychallenge;
            applicantRecord.Natutre_of_Phsically_challenge__c = appRecord.physicallychallengenature;
            applicantRecord.CKYC__c = appRecord.ckycnumber;
            applicantRecord.Is_Customer_HIN_VIP__c = appRecord.customerhinvip;
            applicantRecord.Proof_of_Disablity__c = appRecord.proofdisability;
            applicantRecord.Director_Identification_Number__c = appRecord.directoridentificationnum;
            applicantRecord.CIF_No__c = appRecord.cif;
            return applicantRecord;
        }
        catch(Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    private static Address__c mapAddressRecord (LeadWrapper.Address objWrapAdd, String strAddKey) {
        try{

            Address__c objAdd = new Address__c();
            Applicant__c appRef = new Applicant__c(
                External_Lead_Id__c = strAddKey);
                objAdd.Applicant__r =  appRef;
            objAdd.Address_Type__c = objWrapAdd.addresstype;
            objAdd.Address_Line_1__c = objWrapAdd.addressline1;
            objAdd.Address_Line_2__c = objWrapAdd.addressline2;
            objAdd.Address_Line_3__c = objWrapAdd.addressline3;
            objAdd.Area_Name__c = objWrapAdd.areaname;
            objAdd.Area_Type__c = objWrapAdd.areaytype;
            objAdd.City__c = objWrapAdd.city;
            objAdd.State__c = objWrapAdd.state;
            objAdd.Taluka__c = objWrapAdd.taluka;
            objAdd.Pincode__c = objWrapAdd.pincode;
            objAdd.District__c = objWrapAdd.district;
            objAdd.Stability__c = objWrapAdd.stability;
            objAdd.Land_mark__c = objWrapAdd.landmark;
            //objAdd.Address_Source__c = objWrapAdd.verified;
            objAdd.Address_Source__c = objWrapAdd.addresstakenfrom;
            objAdd.Office_Email_address__c = objWrapAdd.officeemail;
            objAdd.Office_Number__c = String.IsNotBlank(objWrapAdd.officephone) ? objWrapAdd.officephone : NULL;
            objAdd.Type__c = Label.Lead_API_Consider_Default_ResidenceOfficeType == 'Yes' || String.isEmpty(objWrapAdd.residentofficetype) ? Label.Lead_API_Default_ResidenceOfficeType : objWrapAdd.residentofficetype;
            objAdd.Status__c = objWrapAdd.residentstatus;
            return objAdd;
        }
        catch(Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    
    private static Applicant_Financials_Details__c mapFinancialAccountSalary(LeadWrapper.FinanceSalary finSal, Applicant_Financials_Details__c objFin) {
        try {
            objFin.First_Month__c = finSal.firstmonthsalary;
            objFin.Second_Month__c = finSal.secondmonthsalary;
            objFin.Third_Month__c = finSal.thirdmonthsalary;
            objFin.Average_Monthly_Salary__c = finSal.avgsalary;
            objFin.Company_Name__c = finSal.companybusinessname;
            objFin.Monthly_Gross_Salary__c = finSal.monthlygrosssalary;
            objFin.Salary_Received_in_Bank__c = finSal.salaryreceivedbank;
            objFin.Monthly_Net_Salary__c = finSal.monthlynetsalary;
            objFin.Salary_Received_in_Cash__c = finSal.salaryreceivedcash;
            return objFin;
        }
        catch(Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    private static Applicant_Financials_Details__c mapFinancialAssessNoDocument (LeadWrapper.FinanceAssessedNodocument finAssWODoc, Applicant_Financials_Details__c objFin) {
        try {
            objFin.Monthly_Turnover__c = finAssWODoc.monthlyturnover;
            objFin.Annual_Turnover__c = finAssWODoc.annualturnover;
            objFin.Monthly_Expense__c = finAssWODoc.monthlyexpense;
            objFin.Annual_Expense__c = finAssWODoc.annualexpense;
            objFin.Company_Name__c = finAssWODoc.companybusinessname;
            objFin.Monthly_Net_Profit__c = finAssWODoc.monthlynetprofit;
            objFin.Annual_Net_Profit__c = finAssWODoc.annualnetprofit;
            
            return objFin;
        }
        catch(Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    private static Applicant_Financials_Details__c mapFinancialDocumentWithAudit (LeadWrapper.FinanceDocumentWithAudit finAudit, Applicant_Financials_Details__c objFin) {
        try {
            objFin.Company_Name__c = finAudit.companybusinessname;
            objFin.Year__c = finAudit.year != NULL ? String.valueOf(finAudit.year) : '';
            objFin.Annual_Turnover__c = finAudit.annualturnover;
            objFin.Monthly_Turnover__c = finAudit.monthlyturnover;
            objFin.Annual_Net_Profit__c = finAudit.annualnetprofit;
            objFin.Monthly_Net_Profit__c = finAudit.monthlynetprofit;
            objFin.Annual_Depreciation__c = finAudit.annualdepreciation;
            objFin.Monthly_Depreciation__c = finAudit.monthlydepreciation;
            objFin.Annual_Interest_Paid_On_Loans__c = finAudit.annualinterestonloan;
            objFin.Monthly_Interest_Paid_on_Loans__c = finAudit.monthlyinterestonloan;
            objFin.Annual_Non_Cash_Expenses__c = finAudit.annualnoncashexpense;
            objFin.Monthly_Non_Cash_Expenses__c = finAudit.monthlynoncashexpense;
            objFin.Annual_Total_Income__c = finAudit.annualtotalincome;
            objFin.Monthly_Total_Income__c = finAudit.totalmonthlyincome;
            
            return objFin;
        }
        catch(Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    private static Applicant_Financials_Details__c mapFinancialDocumentWithoutAudit (LeadWrapper.FinanceDocumentWithoutAudit finWOAudit, Applicant_Financials_Details__c objFin) {
        try {
            objFin.Annual_Net_Profit__c = finWOAudit.annualnetprofit;
            objFin.Monthly_Net_Profit__c = finWOAudit.monthlynetprofit;
            objFin.Year__c = finWOAudit.year != NULL ? String.valueOf(finWOAudit.year) : '';
            objFin.Filing_Date__c = String.isNotBlank(finWOAudit.filingdate) ? Date.parse(finWOAudit.filingdate) : NULL;
            return objFin;
        }
        catch(Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    private static Applicant_Financials_Details__c mapFinancialAgriOwnOrRentLand (LeadWrapper.FinanceAgriOwnorRentLand finLand, Applicant_Financials_Details__c objFin) {
        try {
            objFin.Crop_Details__c = finLand.cropdetails;
            objFin.Market_Price__c = finLand.marketprice;
            objFin.Irrigartion_Source__c = finLand.irrigationsource;
            
            objFin.Sowing_Month__c = finLand.sowingmonth;
            objFin.Harvesting_Month__c = finLand.harvestmonth;
            objFin.Estimated_Yield__c = finLand.estimatedyield;
            objFin.Estimated_Sale_Value__c = finLand.estimatedsalevalue;
            objFin.Net_Revenue__c = finLand.netrevenue;
            objFin.Area_under_crop__c = finLand.areaundercrop;
            
            return objFin;
        }
        catch(Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }
    
    
    private static Applicant_Financials_Details__c mapFinancialAccountFarmerCommercial (LeadWrapper.FinanceFarmerCommercial finComm, Applicant_Financials_Details__c objFin) {
        try {
            objFin.Type_of_Income__c = finComm.typeofincome;
            objFin.Income_Source__c = finComm.incomesource;
            objFin.Unit__c = finComm.unit;
            objFin.Annual_Income_Unit_Rs__c = finComm.annualincomeunit;
            objFin.Proof__c = finComm.proof;
            objFin.Document_Type__c = finComm.documenttype;
            objFin.Net_Annual_Income__c = finComm.netannualincome;
            //objFin.Area_under_Crop_Unit__c = finComm.areaundercropunit;
            
            return objFin;
        }
        catch(Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    private static Applicant_Financials_Details__c mapFinancialAccountDairy (LeadWrapper.FinanceDairyBusiness finDairy, Applicant_Financials_Details__c objFin) {
        try {
            objFin.No_of_Cattle__c = finDairy.noofcattle;
            objFin.Daily_Supply_of_Milk_Ltrs__c = finDairy.dailymilksupplyltr;
            objFin.Average_Sale_Price_Per_Liter__c = finDairy.avgsalepriceltr;
            objFin.Daily_Collection__c = finDairy.dailycollectionrs;
            objFin.Monthly_Receipts__c = finDairy.monthlyreceiptrs;
            objFin.Profit_Margin__c = finDairy.profitmarginpercentage;
            objFin.Monthly_Net_Income__c = finDairy.monthlynetincome;
            objFin.Any_Other_Income__c = finDairy.anyotherincome;
            objFin.Total_Net_Income__c = finDairy.totalnetincome;
            objFin.Any_Other_Expense__c = finDairy.otherexpense;
            return objFin;
        }
        catch(Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    

    private static Applicant_Financials_Details__c mapFinancialAccountOtherIncome (LeadWrapper.FinanceOtherIncome finOther, Applicant_Financials_Details__c objFin) {
        try {



            objFin.Other_Income_Picklist__c = finOther.otherincometype;
            objFin.Other_If_Any__c = finOther.otherifany;
            objFin.Monthly_Income__c = finOther.monthlyincome;
            objFin.Method_Of_Assesment__c = finOther.assessmentmethod;
            return objFin;
        }
        catch(Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    /*
    private static Applicant_Financials_Details__c mapFinancialAccountParent (LeadWrapper.Finance objWrapFin, String strAddKey) {
        try {
            Applicant_Financials_Details__c objFin = new Applicant_Financials_Details__c();
                Applicant__c appRef = new Applicant__c(
                    External_Lead_Id__c = strAddKey);
                    objFin.Applicant__r =  appRef;

                  
                return objFin;
        }
        catch (Exception ex) {
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }
    */

    private static Collateral__c mapCollateral (LeadWrapper.Vehicle wrapCol, String strLeadId, Map<String,Id> mapObjWithRecordType,Integer counter) {
        try {
            Collateral__c objCol = new Collateral__c();
            Loan_Application__c loanRef = new Loan_Application__c(
                Lead_Id__c= strLeadId);
            objCol.Loan__r =  loanRef;
            // Check Record type
            if (mapObjWithRecordType != NULL && mapObjWithRecordType.containsKey(wrapcol.collateraltype)) {
                objCol.RecordtypeId = mapObjWithRecordType.get(wrapcol.collateraltype);
            }
            else {
                objCol.RecordtypeId = mapObjWithRecordType.get('New');
            }
            objCol.External_Lead_Id__c = strLeadId+counter;
            String strMakeModelVariant = wrapCol.make + '_' + wrapCol.model + '_' + wrapCol.variant;
            MMV_Master__c mmvRef = new MMV_Master__c(
                Make_Model_Variant__c = strMakeModelVariant);
            objCol.MMV_Master__r = mmvRef;
            objCol.Collateral_Type__c = wrapCol.collateraltype;
            objCol.Collateral_Name__c = wrapCol.collateralname;
            objCol.Collateral_From_Lead_Api__c = String.isNotBlank(wrapcol.collateraltype) && objCol.Collateral_Type__c != 'New' ? true : false;
            
            //objCol.Manual_Make__c = wrapCol.make;
            //objCol.Manual_Model__c = wrapCol.model;
            //objCol.Manual_Variant__c = wrapCol.variant;
            objCol.Vehicle_Color__c = wrapCol.color;
            objCol.Fuel_Type__c = wrapCol.fueltype;
            objCol.Vehicle_Category__c = wrapCol.vehiclecategory;
            objCol.Vehicle_Usage__c = wrapCol.vehicleusage;
            objCol.Manufacture_year_month__c = wrapCol.vehicleyearmonth;
            objCol.Engine_Category__c = wrapCol.enginecategory;
            objCol.Ex_Showroom_Price__c = wrapCol.exshowroomprice;
            objCol.Discount__c = wrapCol.discount;
            objCol.Net_of_Discount_Price__c = wrapCol.netdiscountprice;
            objCol.Insurance__c = wrapCol.insurance;
            //objCol.RTO_Taxes__c = wrapCol.rtotaxes;
            //objCol.RTO_Tax__c = wrapCol.isrtotax;
            //objCol.RTO_Tax_Value__c = wrapCol.rtotaxamount;
            //objCol.Accessories_Funding__c = wrapCol.accessoriesfunding;
            //objCol.Accessories__c = wrapCol.accessories;
            //objCol.Accessories_Value__c = wrapCol.accessoriesvalue;
            objCol.Other_Costs__c = wrapCol.othercost;
            //objCol.On_Road_Price__c = wrapCol.onroadprice;
            objCol.Final_Cost__c = wrapCol.finalcost;
            objCol.Insurance_Funding__c = wrapCol.insurancefunding;
            objCol.Insurance_Value__c = wrapCol.insurancevalue;
            objCol.LS__c = wrapCol.isLS;
            objCol.LS_Value__c = wrapCol.lsamount;
            objCol.Apportioned_Loan_Amount__c = wrapCol.apportionedloanamount;
            //objCol. = wrapCol.totalloanamount;
            //objCol.Approved_LTV__c = wrapCol.approved_ltv_percentage;
            //objCol.Assessment_Method__c = wrapCol.assessmentmethod;
            //objCol. = wrapCol.loaneligibility;
            //objCol. = wrapCol.customerequity;
            //objCol. = wrapCol.approved_customerequity;
            //objCol. = wrapCol.ltvoffered_exshowroom_percentage;
            //objCol. = wrapCol.ltvoffered_onroad_percentage;
            //objCol. = wrapCol.ltvoffered_final_percentage;
            objCol.Vehicle_Number__c = wrapCol.vehiclenumber;
            objCol.Engine_Number__c = wrapCol.enginenumber;
            objCol.Chasis_Number__c = wrapCol.chasisnumber;
            //objCol. = wrapCol.manufacturer;
            objCol.Kilometer__c = wrapCol.kilometer;
            objCol.HPN_With_Financiers_Name__c = wrapCol.hpnfinancename;
            objCol.Current_Owner_Name__c = wrapCol.currentowner;
            objCol.Owner_Serial_number__c = wrapCol.ownerserialnum;
            objCol.Registration_City__c = wrapCol.registrationcity;
            //objCol.Registration_City__c = wrapCol.svsh_svoh;
            objCol.Certified_Value__c = wrapCol.certifiedvalue;
            //objCol.Grid_Depreciated_Value__c = wrapCol.griddepreciatedvalue;
            //objCol.IBB_Value__c = wrapCol.ibbvalue;
            //Removed objCol.Valuation_Amount__c = wrapCol.valuationamount;
            objCol.IDV__c = wrapCol.idvinsurancevalue;
            objCol.Exiting_Policy_Expired__c = wrapCol.exitpolicyexp;
            objCol.Insurance_Expiry_Date__c = String.isnotBlank(wrapCol.insuranceexpdate) ? Date.parse(wrapCol.insuranceexpdate) : NULL;
            objCol.Existing_Policy_Insurer_Company__c = wrapCol.existpolicy_insurercompany;
            objCol.Existing_Policy_Type__c = wrapCol.exist_policytype;
            objCol.Have_you_made_a_claim_Last_year__c = wrapCol.made_claim_last_year;
            objCol.NCB_in_Exisiting_policy__c = wrapCol.ncb_percentage;
            objCol.Vehicle_Cost__c = wrapCol.vehiclecost;
            objCol.Final_Vehicle_Cost__c = wrapCol.finalvehiclecost;
            return objCol;

        }
        catch (Exception ex){
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    private static Valuation__c mapValuation (LeadWrapper.Valuations wrapVal, String strColLeadId) {
        try {
            Valuation__c objValuation = new Valuation__c();
            Collateral__c appRef = new Collateral__c(
            External_Lead_Id__c = strColLeadId);
            objValuation.Collateral__r =  appRef;
            //objValuation.Reference_ID__c = wrapVal.referenceid;
            // Check If pass from Lead
            objValuation.Product__c = wrapVal.product;
            objValuation.Collateral_Type__c = wrapVal.collateraltype;
            // Check If pass from Lead
            //objValuation. = wrapVal.mmv_make;
            // Check If pass from Lead
            //objValuation. = wrapVal.mmv_model;
            // Check If pass from Lead
            //objValuation. = wrapVal.mmv_variant;
            //objValuation.Action__c = wrapVal.action;
            objValuation.Valuer_Name_Code__c = wrapVal.valuename_code;
            objValuation.Other_state_and_list_from_master__c = wrapVal.otherstate_masterlist;
            objValuation.Coordinate_for_valuation_POC__c = wrapVal.coordinateforvaluation;
            objValuation.Contact_Person_Mobile_Number__c = wrapVal.contactperson_mobilenumber;
            // Check Parsing
            //objValuation.Allocation_Date_Time__c = wrapVal.allocationdatetime;
            // Check Parsing
            //objValuation.Completion_Date_Time__c = wrapVal.completiondatetime;
            objValuation.Vehicle_Number__c = wrapVal.vehicle_number;
            objValuation.Make_Model__c = wrapVal.make_model;
            objValuation.Engine_number__c = wrapVal.enginenumber;
            objValuation.Chassis_number__c = wrapVal.chasisnumber;
            objValuation.Manufacturing_year__c = wrapVal.manufacture_year;
            objValuation.Registration_date__c = wrapVal.registration_date;
            objValuation.Owner_Serial_no__c = wrapVal.ownerserial_number;
            objValuation.Hypothication__c = wrapVal.hypothication;
            objValuation.Color__c = wrapVal.color;
            objValuation.Odometer__c = wrapVal.odometer;
            objValuation.Fuel__c = wrapVal.fuel;
            objValuation.Vehicle_Condition__c = wrapVal.vehicle_condition;
            objValuation.Valuation_Amount__c = wrapVal.valuation_amount;
            objValuation.Final_remarks__c = wrapVal.final_remarks;
            return objValuation;
        }
        catch (Exception ex){
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    private static Charge__c mapCharge(LeadWrapper.Charge wrapCharge, String strLeadId) {
        try {
            Charge__c objCharge = new Charge__c();
            Loan_Application__c loanRef = new Loan_Application__c(
            Lead_Id__c= strLeadId);
            objCharge.Loan_Application__r = loanRef;
            objCharge.Value_type__c = wrapCharge.valuetype;
            objCharge.Charges_Name__c = wrapCharge.chargename;
            //  objCharge.Rate_value_As_per_Policy__c = wrapCharge.ratevalueasperpolicy;
            objCharge.Actual_rate__c = wrapCharge.actualrate;
            objCharge.Charge_Amount__c = wrapCharge.chargeamount;
            //  objCharge.Tax_Amount__c = wrapCharge.taxamount;
            //  objCharge.Total_Amount__c = wrapCharge.totalamount;
            return objCharge;
        }
        catch (Exception ex){
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    private static Document_Checklist__c mapDocumentchecklistRecord (LeadWrapper.DocumentDetail wrapDoc, String strApplicantId, String strLeadId, Integer counter, Document_Checklist__c objDocCheck) {
        try {
            if (objDocCheck.Applicant__c != NULL){
                objDocCheck.Checklist_ID__c = strApplicantId + counter;
            }
            else if (objDocCheck.Loan_Application__c != NULL) {
                objDocCheck.Checklist_ID__c = strLeadId + counter;
            }
            objDocCheck.Category__c = wrapDoc.category;
            objDocCheck.Sub_Category__c = wrapDoc.subcategory;
            objDocCheck.Document_Expiry_Date__c = String.isNotBlank(wrapDoc.documentexpiry) ? Date.parse(wrapDoc.documentexpiry) : NULL ;
            objDocCheck.Passport_File_Number__c = wrapDoc.filenumber;
            objDocCheck.Document_Number__c = wrapDoc.documentnumber;
            return objDocCheck;
        }
        catch (Exception ex){   
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    /*
    private static Document_Checklist__c mapDocumentchecklistRecord (LeadWrapper.DocumentDetail wrapDoc, String strApplicantId, String strLeadId, Integer counter) {
        try {
            Document_Checklist__c objDocCheck = new Document_Checklist__c();
            if (String.isNotBlank(strApplicantId)){
                Applicant__c appRef = new Applicant__c(
                External_Lead_Id__c= strApplicantId);
                objDocCheck.Applicant__r = appRef;
                objDocCheck.Checklist_ID__c = strApplicantId + counter;
            }
            else if (String.isNotBlank(strLeadId)) {
                Loan_Application__c loanRef = new Loan_Application__c(
                Lead_Id__c= strLeadId);
                objDocCheck.Loan_Application__r = loanRef;
                objDocCheck.Checklist_ID__c = strLeadId + counter;
            }
            Document_Master__c objDocMasterRef = new Document_Master__c(
                Document_ID__c = wrapDoc.documentId);
            objDocCheck.Document_Master__r = objDocMasterRef;
            
            //
            objDocCheck.Category__c = wrapDoc.category;
            //
            objDocCheck.Sub_Category__c = wrapDoc.subcategory;
            objDocCheck.Document_Expiry_Date__c = String.isNotBlank(wrapDoc.documentexpiry) ? Date.parse(wrapDoc.documentexpiry) : NULL ;
            objDocCheck.Passport_File_Number__c = wrapDoc.filenumber;
            objDocCheck.Document_Number__c = wrapDoc.documentnumber;
            // wrapDoc.type;
            return objDocCheck;
        }
        catch (Exception ex){   
            system.debug('Exception line '+ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }
    */

    /*
    private static String mapReference (LeadWrapper.Reference objRef,String strReference){

    }
    */


    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-20-2023 
    * @param status 
    * @param error 
    * @return string 
    **/
    private static string generateJSON(String status,String error){
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeStringField(GlobalConstants.STATUS,status);
        jsGen.writeStringField(GlobalConstants.ERROR, error);
        jsGen.writeEndObject();
        return jsGen.getAsString();
    }

    public class CustomException extends Exception{
        
    }
}