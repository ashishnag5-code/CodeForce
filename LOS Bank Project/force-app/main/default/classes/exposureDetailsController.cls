public with sharing class exposureDetailsController {
    
    
    
    @AuraEnabled
    public static fullDetailsWrapper getAccountDetails(Id laonApplicantId) {
        try {
            fullDetailsWrapper finalWrapperInstance = new fullDetailsWrapper();
            Map < Id, String > applicantNameMap = new Map < Id, String > ();
            Map < Id, String > applicantCIFNoMap = new Map < Id, String > ();
            Map < Id, String > applicantExposureMap = new Map < Id, String > ();
            Map < Id, List<Applicant__c> > applicantExposureMapList = new Map < Id, List<Applicant__c> > ();
            
            
            List < Applicant__c > applicantList = new List < Applicant__c > ();
            List < accountRecordsWrapper > wrapperList = new List < accountRecordsWrapper > ();
            List < Bank_Account_Records__c > bankRecordList = new List < Bank_Account_Records__c > ();
            List < Loan_Application__c > loanRecordsList = new List < Loan_Application__c > ();
            Map < Id, List < Bank_Account_Records__c >> applodCCBankMap = new Map < Id, List < Bank_Account_Records__c >> ();
            Map < Id, List < Bank_Account_Records__c >> applCasaBankMap = new Map < Id, List < Bank_Account_Records__c >> ();
            Map < Id, List < Bank_Account_Records__c >> applloanBankMap = new Map < Id, List < Bank_Account_Records__c >> ();
            Map < Id, List < Bank_Account_Records__c >> applloanCreditBankMap = new Map < Id, List < Bank_Account_Records__c >> ();
            
            
            List < Bank_Account_Records__c > accountRecords = new List < Bank_Account_Records__c > ();
            
            Loan_Application__c loanInstance = [SELECT Id, Wheels_Exposure__c, Final_Exposure__c,Product__c
                                                FROM Loan_Application__c WHERE Id =: laonApplicantId WITH SECURITY_ENFORCED LIMIT 1
                                               ];
            
            if (loanInstance.Wheels_Exposure__c != null) {
                finalWrapperInstance.wheelsExposure = loanInstance.Wheels_Exposure__c;
            }
            if (loanInstance.Final_Exposure__c != null) {
                finalWrapperInstance.totalExposure = loanInstance.Final_Exposure__c;
            }
            
            //Check whether its a two or four wheeler
            String productCode = (String.isNotBlank(loanInstance.Product__c)) ? loanInstance.Product__c : '';
            List < ProductRTMap__mdt > productData = new List < ProductRTMap__mdt > ();
            if (String.isNotBlank(productCode)) {
                productData = [SELECT MasterLabel, RecordType__c, Product__c
                               FROM ProductRTMap__mdt
                               WHERE Product__c =: productCode  WITH SECURITY_ENFORCED  LIMIT 1
                              ];
            }
            
            applicantList = [SELECT Id,SF_Exposure_JSON__c,Customer_Name__c,Voter_Id__c,Passport_Number__c,Customer_Type__c,  Driving_License_Id__c, First_Name__c,Mobile_Number__c,PAN__c,Aadhaar_Number__c,CIF_No__c, Middle_Name__c, Last_Name__c, Name, Loan__c, Loan_Stage__c, Loan__r.EMI__c, Loan__r.Loan_Amount__c, Loan__r.Loan_Sanction_date__c, Loan__r.Loan_Number__c, Loan__r.Product__c, Loan__r.Stage__c, Loan__r.Customer_Name__c, RecordType.DeveloperName, RecordType.Name,Loan__r.Wheels_Exposure__c,Loan__r.Final_Exposure__c
                             FROM Applicant__c
                             WHERE(Loan__c =: laonApplicantId OR Id =: laonApplicantId)
                             AND RecordType.DeveloperName != 'Additional_Match'
                             AND RecordType.DeveloperName != 'BO'
                             AND  RecordType.DeveloperName != 'Nominee'
                             AND IsInactive__c = false //SFAU-4094
                             WITH SECURITY_ENFORCED
                            ];
            
            List<Applicant__c> existingApplicantList = createApplicantQuery(applicantList);
            List<Applicant__c> existingLoanList = new List<Applicant__c>();
            System.debug('existingApplicantList-->' +existingApplicantList);
            for(Applicant__c applicantInstance : existingApplicantList){
                if( (laonApplicantId!=applicantInstance.Loan__c) && (applicantInstance.Loan__r.Stage__c == 'PDD')){
                    existingLoanList.add(applicantInstance);
                }
            }
            System.debug('existingLoanList-->' +existingLoanList);
            
            for (Applicant__c appInstance: applicantList) {
                if (!applicantNameMap.containsKey(appInstance.Id)) {
                    applicantNameMap.put(appInstance.Id, appInstance.Customer_Name__c);
                }
                if(!applicantCIFNoMap.containsKey(appInstance.Id)){
                    applicantCIFNoMap.put(appInstance.Id,appInstance.CIF_No__c);
                }
                if(!applicantExposureMap.containsKey(appInstance.Id)){
                    applicantExposureMap.put(appInstance.Id,appInstance.SF_Exposure_JSON__c);
                }
                if(!applicantExposureMapList.containsKey(appInstance.Id)){
                    List<Applicant__c> applist = new  List<Applicant__c>();
                    String jsonStr = String.isNotBlank(appInstance.SF_Exposure_JSON__c) ? appInstance.SF_Exposure_JSON__c:'';
                    if(String.isNotBlank(jsonStr)){
                        Object jsonObj = JSON.deserializeUntyped(jsonStr);
                        if ( ((List<Object>)jsonObj).isEmpty()) {
                            
                        }else{
                            applist.add(appInstance);
                            applicantExposureMapList.put(appInstance.Id, applist);
                        }
                    }
                   
                }
                
                
            }
            accountRecords = [SELECT Id,Applicant__r.Loan__r.Stage__c, Applicant__c, Applicant__r.First_Name__c, Applicant__r.Last_Name__c, RecordType.DeveloperName, Account_Number__c, OD_Limit_Sanctioned__c, Product_Code__c, Account_Name__c, Applicant_Type__c, ROI__c, Branch_Name__c, Loan_Amount__c, No_of_Emi_Paid__c, Loan_Tenure__c, EMI_Amount__c, Loan_Current_DPD__c, Sanctioned_Amount__c, DPP_Value__c,Applicant__r.Loan__r.Final_Exposure__c,
                              Loan_Overdue_EMI__c, POS__c, Product__c, Account_Opening_Date__c, Current_Status__c, Current_Balance__c, Account_Type__c,Customer_Id__c,Customer_Relationship__c,Status__c,Last_Statement_Balance__c,Applicant__r.Loan__r.Wheels_Exposure__c,Applicant__r.Loan__r.Total_Exposure__c,Applicant__r.Loan__c,View_Check__c,Include_In_Exposure__c,Credit_Override_authority__c
                              FROM Bank_Account_Records__c
                              WHERE RecordType.DeveloperName = 'CBS'
                              AND Applicant__r.Loan__c =: laonApplicantId WITH SECURITY_ENFORCED
                             ];
            System.debug('accountRecords-->' + accountRecords);

            String loanStage ='';
            for (Bank_Account_Records__c bankInstance: accountRecords) {
                //bankInstance.Include_In_Exposure__c='Yes';
                loanStage= bankInstance.Applicant__r.Loan__r.Stage__c;
                if (bankInstance.Account_Type__c == 'ODCC') {
                    if (applodCCBankMap.containsKey(bankInstance.Applicant__c)) {
                        List < Bank_Account_Records__c > accRecords = applodCCBankMap.get(bankInstance.Applicant__c);
                        accRecords.add(bankInstance);
                        applodCCBankMap.put(bankInstance.Applicant__c, accRecords);
                    } else {
                        applodCCBankMap.put(bankInstance.Applicant__c, new List < Bank_Account_Records__c > {
                            bankInstance
                                });
                    }
                }
                if (bankInstance.Account_Type__c == 'Loan') {
                    if (applloanBankMap.containsKey(bankInstance.Applicant__c)) {
                        List < Bank_Account_Records__c > accRecords = applloanBankMap.get(bankInstance.Applicant__c);
                        accRecords.add(bankInstance);
                        applloanBankMap.put(bankInstance.Applicant__c, accRecords);
                    } else {
                        applloanBankMap.put(bankInstance.Applicant__c, new List < Bank_Account_Records__c > {
                            bankInstance
                                });
                    }
                }
                if (bankInstance.Account_Type__c == 'CASA') {
                    if (applCasaBankMap.containsKey(bankInstance.Applicant__c)) {
                        List < Bank_Account_Records__c > accRecords = applCasaBankMap.get(bankInstance.Applicant__c);
                        accRecords.add(bankInstance);
                        applCasaBankMap.put(bankInstance.Applicant__c, accRecords);
                    } else {
                        applCasaBankMap.put(bankInstance.Applicant__c, new List < Bank_Account_Records__c > {
                            bankInstance
                                });
                    }
                    
                }
                if (bankInstance.Account_Type__c == 'CC') {
                    if (applloanCreditBankMap.containsKey(bankInstance.Applicant__c)) {
                        List < Bank_Account_Records__c > accRecords = applloanCreditBankMap.get(bankInstance.Applicant__c);
                        accRecords.add(bankInstance);
                        applloanCreditBankMap.put(bankInstance.Applicant__c, accRecords);
                    } else {
                        applloanCreditBankMap.put(bankInstance.Applicant__c, new List < Bank_Account_Records__c > {
                            bankInstance
                                });
                    }
                    
                }
                
            }
            
            Boolean boolIsExistingRecords = false;
            for (Id recordIdInstance: applicantNameMap.keySet()) {
                accountRecordsWrapper wrapperInstance = new accountRecordsWrapper();
                wrapperInstance.applicantId = recordIdInstance;
                wrapperInstance.loanId = String.valueof(laonApplicantId);
                wrapperInstance.applicantName = (applicantNameMap.get(recordIdInstance) != null) ? applicantNameMap.get(recordIdInstance) : '';
                wrapperInstance.applicantCIF = (applicantCIFNoMap.get(recordIdInstance) != null) ? applicantCIFNoMap.get(recordIdInstance) : '';
                wrapperInstance.odccBankAccountRecords = (applodCCBankMap.get(recordIdInstance) != null) ? applodCCBankMap.get(recordIdInstance) : null;
                wrapperInstance.isODCC = (applodCCBankMap.get(recordIdInstance) != null) ? true : false;
                wrapperInstance.loanBankAccountRecords = (applloanBankMap.get(recordIdInstance) != null) ? applloanBankMap.get(recordIdInstance) : null;
                wrapperInstance.isLOAN = (applloanBankMap.get(recordIdInstance) != null) ? true : false;
                wrapperInstance.casBankAccountRecords = (applCasaBankMap.get(recordIdInstance) != null) ? applCasaBankMap.get(recordIdInstance) : null;
                wrapperInstance.isCASA = (applCasaBankMap.get(recordIdInstance) != null) ? true : false;
                wrapperInstance.creditBankAccountRecords = (applloanCreditBankMap.get(recordIdInstance) != null) ? applloanCreditBankMap.get(recordIdInstance) : null;
                wrapperInstance.isCREDIT = (applloanCreditBankMap.get(recordIdInstance) != null) ? true : false;
                List<Applicant__c> applicantRecords = applicantExposureMapList.get(recordIdInstance);
                System.debug('applicantRecords-->' +applicantRecords);
                if(applicantRecords!=null){
                    wrapperInstance.applicantRecords = (!applicantRecords.isEmpty()) ? applicantRecords : null;
                    System.debug('applicantRecords-->'+applicantRecords);
                    wrapperInstance.isApplicantLoan = (!applicantRecords.isEmpty()) ?  true : false;
                }else{
                    wrapperInstance.applicantRecords = null;
                        wrapperInstance.isApplicantLoan = false;
                }
                
                
                String jsonString = (applicantExposureMap.get(recordIdInstance)!=null) ? applicantExposureMap.get(recordIdInstance) :'';
                if(String.isNotBlank(jsonString)){
                    List<ExistingLoanWrapper> loanList = (List<ExistingLoanWrapper>)JSON.deserialize(jsonString,List<ExistingLoanWrapper>.class );
                if(!loanList.isEmpty()){
                    ExistingLoanWrapper loanWrapper = loanList[0];
                    wrapperInstance.includeExposure = loanWrapper.includeInExposure;
                    wrapperInstance.creditAuthority = loanWrapper.creditOverrideAuthority;  
                    boolIsExistingRecords = true;
                }         
                }
                if(wrapperInstance.isODCC == false && wrapperInstance.isLOAN == false && wrapperInstance.isCASA == false && wrapperInstance.isCREDIT == false && wrapperInstance.isApplicantLoan == false ){
                    wrapperInstance.bankCheck = false;
                }else{
                    wrapperInstance.bankCheck = true;
					}
                            
                wrapperList.add(wrapperInstance);
            }
            System.debug('wrapperList-->' +wrapperList);
            System.debug('isApplicantLoan-->' +wrapperList[0].isApplicantLoan);
            
            finalWrapperInstance.recordWrapperList = wrapperList;
            finalWrapperInstance.typeOfVehicle = (productData[0].RecordType__c !=null) ?  productData[0].RecordType__c : '';
            finalWrapperInstance.loanStage = loanStage;
            if((accountRecords!=null && !accountRecords.isEmpty()) || boolIsExistingRecords){
                finalWrapperInstance.showMainSection = true;
            }else{
                finalWrapperInstance.showMainSection = false;
            }
            return finalWrapperInstance;
            
        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('line-->' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    
    
    @AuraEnabled
    public static void updateAccountDetails(Bank_Account_Records__c toUpdateLoan, Id laonApplicantId, fullDetailsWrapper calculatedList) {
        try {
            System.debug('calculatedList-->' + calculatedList);
            Loan_Application__c loanInstance = [SELECT Id, Wheels_Exposure__c, Final_Exposure__c
                                                FROM Loan_Application__c WHERE Id =: laonApplicantId WITH SECURITY_ENFORCED LIMIT 1
                                               ];
            String accountNumber = toUpdateLoan.Account_Number__c;
            List < Bank_Account_Records__c > accountRecords = [SELECT Id, Account_Number__c
                                                               FROM Bank_Account_Records__c
                                                               WHERE RecordType.DeveloperName = 'CBS'
                                                               AND Applicant__r.Loan__c =: laonApplicantId AND Account_Number__c =: accountNumber WITH SECURITY_ENFORCED
                                                              ];
            if (toUpdateLoan != null) {
                // this.includedExposure.push({ accountId:this.objAccountRecord.Id, POS:this.objAccountRecord.POS__c,applicantId:this.objAccountRecord.Applicant__c, accountType: this.objAccountRecord.Account_Type__c,productCode: this.objAccountRecord.Product_Code__c})
                System.debug('toUpdateLoan-->' + toUpdateLoan);
                List<Bank_Account_Records__c>toUpdateRecords= new List<Bank_Account_Records__c>();
                for(Bank_Account_Records__c records : accountRecords){
                    Bank_Account_Records__c bankRecord = new Bank_Account_Records__c();
                    bankRecord.Id = records.Id;
                    bankRecord.Include_In_Exposure__c = 'No';
                    toUpdateRecords.add(bankRecord);
                }
                
                if (Schema.sObjectType.Bank_Account_Records__c.isUpdateable()) {
                    update toUpdateRecords;
                    System.debug('bankRecord-->' + toUpdateRecords);
                }
                
                String productCode = (String.isNotBlank(toUpdateLoan.Product_Code__c)) ? toUpdateLoan.Product_Code__c : '';
                List < ProductRTMap__mdt > productData = new List < ProductRTMap__mdt > ();
                if (String.isNotBlank(productCode)) {
                    productData = [SELECT MasterLabel, RecordType__c, Product__c
                                   FROM ProductRTMap__mdt
                                   WHERE Product__c =: productCode  WITH SECURITY_ENFORCED LIMIT 1
                                  ];
                }
                
                Decimal POS = (toUpdateLoan.POS__c != null) ? (toUpdateLoan.POS__c) : 0;
                Decimal updatedTotalExposure = 0;
                Decimal updatedWheelsExposure = 0;
                
                Applicant__c applicant = new Applicant__c();
                System.debug('calculatedList.totalExposure-->' + calculatedList.totalExposure);
                System.debug('toUpdateLoan.POS__c-->' + toUpdateLoan.POS__c);
                
                applicant.Id = toUpdateLoan.Applicant__c;
                
                Decimal creditLimit = (toUpdateLoan.Sanctioned_Amount__c != null) ? toUpdateLoan.Sanctioned_Amount__c : 0;
                if (toUpdateLoan.Account_Type__c == 'Loan') {
                    updatedTotalExposure = calculatedList.totalExposure;
                    updatedWheelsExposure = calculatedList.wheelsExposure;
                    if (loanInstance.Final_Exposure__c != null) {
                        applicant.Final_Exposure__c = updatedTotalExposure;
                    }
                    if ((!productData.isEmpty()) && (productData[0].RecordType__c == GlobalConstants.TWOWHEELER || productData[0].RecordType__c == GlobalConstants.FOURWHEELER
                         || productData[0].RecordType__c == GlobalConstants.TRACTOR || productData[0].RecordType__c == GlobalConstants.COMMERCIALVEHICLE || productData[0].RecordType__c == GlobalConstants.CONSTRUCTIONEQUIP)) {
                        applicant.Wheels_Exposure__c = updatedWheelsExposure;
                    }
                }
                
                if (toUpdateLoan.Account_Type__c == 'CC') {
                    updatedTotalExposure = calculatedList.totalExposure;
                    applicant.Final_Exposure__c = updatedTotalExposure;
                    
                }
                
                if (Schema.sObjectType.Applicant__c.isUpdateable()) {
                    update applicant;
                    System.debug('applicant-->' + applicant);
                    
                    Loan_Application__c application = new Loan_Application__c();
                    application.Id = laonApplicantId;
                    if (toUpdateLoan.Account_Type__c == 'Loan') {
                        if ((!productData.isEmpty()) && (productData[0].RecordType__c == 'Two Wheeler' || productData[0].RecordType__c == 'Four Wheeler')) {
                            application.Wheels_Exposure__c = updatedWheelsExposure;
                        }
                        application.Final_Exposure__c = updatedTotalExposure;
                    }
                    if (toUpdateLoan.Account_Type__c == 'CC') {
                        application.Final_Exposure__c = updatedTotalExposure;
                    }
                    if (Schema.sObjectType.Loan_Application__c.isUpdateable()) {
                        update application;
                    }
                    System.debug('loanApplication-->' + application);
                    
                }
            }
        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('exception-->' + e.getLineNumber());
        }
    }
    @AuraEnabled
    public static List<casaDetailsWrapper>  getCasaDetails(String accountNumberInstance, String applicantId){
        String respBody;
        String requestBody;
        
        try {
            //Date Formatting
            Integer monthInterval = Integer.valueof(System.label.AUSFSOAMonthGap);
            Date sixMonthsAgo = Date.today().addMonths(-monthInterval);
            DateTime dt = DateTime.newInstance(sixMonthsAgo.year(),sixMonthsAgo.month(),sixMonthsAgo.day());
            //Date sixMonthsAfter = Date.today().addMonths(monthInterval);
            Date sixMonthsAfter = Date.today();
            DateTime dt1 = DateTime.newInstance(sixMonthsAfter.year(),sixMonthsAfter.month(),sixMonthsAfter.day());
            
            String beforeMonth = dt.format('MMMM');
            String afterMonth = dt1.format('MMMM');
            
            String formatedMonth = beforeMonth.substring(0,3);
            String formatedLastMonth = aftermonth.substring(0,3);
            String day = (sixMonthsAgo.day()<9)? ( '0' +String.valueof(sixMonthsAgo.day())) : String.valueOf(sixMonthsAgo.day());
            String afterday = (sixMonthsAfter.day()<9)? ( '0' +String.valueof(sixMonthsAfter.day())) : String.valueOf(sixMonthsAfter.day());
            
            String startDate =  day+'-'+formatedMonth+'-'+ String.valueof(sixMonthsAgo.year());
            String endDate =  afterday+'-'+formatedLastMonth+'-'+ String.valueof(sixMonthsAfter.year());
            
            System.debug('startDate-->' +startDate);
            System.debug('endDate-->' +endDate);
            //End
            
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('CASA SOA');
            Map<String,Object> reqParam = new Map<String,Object>();
            //reqParam.put('StartDate','01-Apr-2022');
            //reqParam.put('EndDate','30-Oct-2022');
            reqParam.put('StartDate',startDate);
            reqParam.put('EndDate',endDate);
            reqParam.put('OriginatingChannel',objIntMapper.Apiuser__c);
            reqParam.put('TransactionBranch','2011');
            
             reqParam.put('AccountNumber',accountNumberInstance);
            //reqParam.put('AccountNumber','2211260640588038');
            requestBody = casaDetailsHandler.generateRequest(reqParam)[0];
            system.debug('%%'+requestBody);
            String recordId =applicantId;
            
            casaDetailsHandler.CASADetailsRequestWrapper casaDetailsRequest = 
                (casaDetailsHandler.CASADetailsRequestWrapper) JSON.deserialize(requestBody, casaDetailsHandler.CASADetailsRequestWrapper.class);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
            respBody = calloutResponseWrapper.response;
            system.debug('respBody-->' +respBody);
            Map<String, Object> jsonMap1= (Map<String, Object>) JSON.deserializeUntyped(respBody);
            List<Object> miniStatement = ( List<Object>) jsonMap1.get('MiniStatement');
            List<Map<String, String>> miniStatementList = (List<Map<String, String>>) JSON.deserialize(JSON.serialize(miniStatement), List<Map<String, String>>.class);
            List<casaDetailsWrapper> wrapperrList = new List<casaDetailsWrapper>(); 
            for (Map<String, String> MapInstance : miniStatementList) {
                casaDetailsWrapper wrapperInstance = new casaDetailsWrapper();
                wrapperInstance.AccountNumber = accountNumberInstance;
                wrapperInstance.Description = MapInstance.get('Description');
                wrapperInstance.TransactionAmount =MapInstance.get('TransactionAmount');
                wrapperInstance.TransactionType = MapInstance.get('TransactionType');
                wrapperInstance.TxnId = MapInstance.get('TxnId');
                wrapperInstance.RunningTotal = MapInstance.get('RunningTotal');
                wrapperInstance.ChequeNumber = MapInstance.get('ChequeNumber');
                wrapperInstance.ValueDate = MapInstance.get('ValueDate');
                wrapperInstance.TransactionBranch = MapInstance.get('TransactionBranch');
                wrapperInstance.TransactionDate = MapInstance.get('TransactionDate');
                wrapperrList.add(wrapperInstance);
            }
            
            /*     

//Hardcoding the response for now
String jsonString = '{ "MiniStatement": [{ "TransactionAmount": "11", "TransactionType": "D", "TxnId": "FT-20220415165326461000000-060 ", "Description": "CC Payment via MB-4760-1697031349636820-20220415453236", "RunningTotal": "3642955965.9", "ChequeNumber": null, "ValueDate": "2022-04-15 00:00:00", "TransactionBranch": "2011", "TransactionDate": "2022-04-15 16:53:26" }]}';


Map<String, List<casaDetailsHandler.CASADetailsResponseWrapper>> jsonMap = (Map<String, List<casaDetailsHandler.CASADetailsResponseWrapper>>) JSON.deserialize(respBody, Map<String, List<casaDetailsHandler.CASADetailsResponseWrapper>>.class);
System.debug('jsonMap-->' +jsonMap);
List<casaDetailsHandler.CASADetailsResponseWrapper> miniStatementList =(List<casaDetailsHandler.CASADetailsResponseWrapper>)jsonMap.get('MiniStatement');
List<casaDetailsWrapper> wrapperrList = new List<casaDetailsWrapper>(); 
System.debug('miniStatement-->' +miniStatementList);
for(integer i=0;i<miniStatementList.size();i++){
casaDetailsWrapper wrapperInstance = new casaDetailsWrapper();
wrapperInstance.AccountNumber = accountNumberInstance;
wrapperInstance.Description = miniStatementList[i].Description;
wrapperInstance.TransactionAmount = miniStatementList[i].TransactionAmount;
wrapperInstance.TransactionType = miniStatementList[i].TransactionType;
wrapperInstance.TxnId = miniStatementList[i].TxnId;
wrapperInstance.RunningTotal = miniStatementList[i].RunningTotal;
wrapperInstance.ChequeNumber = miniStatementList[i].ChequeNumber;
wrapperInstance.ValueDate = miniStatementList[i].ValueDate;
wrapperInstance.TransactionBranch = miniStatementList[i].TransactionBranch;
wrapperInstance.TransactionDate = miniStatementList[i].TransactionDate;
wrapperrList.add(wrapperInstance);
}
*/
            System.debug('wrapperrList-->' +wrapperrList);
            
            return wrapperrList;
            
        } catch (Exception e) {
            System.debug('exception-->' +e);
            System.debug('exception-->' +e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static  List<loanDetailsWrapper>  getLoanDetails(String accountNumberInstance,String applicantId){
        String respBody;
        String requestBody;
        List<loanDetailsWrapper> wrapperrList = new List<loanDetailsWrapper>(); 
        try {
            Integer monthInterval = Integer.valueof(System.label.AUSFSOAMonthGap); //6
            //Date Formatting
            Date sixMonthsAgo = Date.today().addMonths(-monthInterval);
            Date sixMonthsAfter = Date.today().addMonths(monthInterval);
            String month = (sixMonthsAgo.month()<9)? ( '0' +String.valueof(sixMonthsAgo.month())) : String.valueOf(sixMonthsAgo.month());
            String aftermonth = (sixMonthsAfter.month()<9)? ( '0' +String.valueof(sixMonthsAfter.month())) : String.valueOf(sixMonthsAfter.month());
            String day =  (sixMonthsAgo.day()<9)? ( '0' +String.valueof(sixMonthsAgo.day())) : String.valueOf(sixMonthsAgo.day());
            String afterday =  (sixMonthsAfter.day()<9)? ( '0' +String.valueof(sixMonthsAfter.day())) : String.valueOf(sixMonthsAfter.day());
            
            String valueFrmDate = String.valueof(sixMonthsAgo.year())+month + day;
            String valueToDate = String.valueof(sixMonthsAfter.year())+aftermonth + afterday;
            System.debug('valueFrmDate-->' +valueFrmDate);
            System.debug('valueToDate-->' +valueToDate);
            //End
            
            //LOAN SOA Part
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Loan SOA');
            Map<String,Object> reqParam = new Map<String,Object>();
            //reqParam.put('ValueFromDate','20221226');
            //reqParam.put('ValueToDate','20230102');
            //reqParam.put('OriginatingChannel',objIntMapper.Apiuser__c);
            reqParam.put('ValueFromDate',valueFrmDate);
            reqParam.put('ValueToDate',valueToDate);
            reqParam.put('OriginatingChannel','SFDC');
            reqParam.put('TransactionBranch','2011');
            reqParam.put('AccountNumber',accountNumberInstance); //  //9001070130327270
            requestBody = casaDetailsHandler.generateLoanRequest(reqParam)[0];
            system.debug('RequestBoday'+requestBody);
            String recordId =applicantId;
            
            casaDetailsHandler.LoanDetailsRequestWrapper loanDetailsRequest =
                (casaDetailsHandler.LoanDetailsRequestWrapper) JSON.deserialize(requestBody, casaDetailsHandler.LoanDetailsRequestWrapper.class);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
            
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            respBody = calloutResponseWrapper.response;
            
            Map<String, Object> jsonMap1= (Map<String, Object>) JSON.deserializeUntyped(respBody);
            List<Object> transactionStatus = ( List<Object>) jsonMap1.get('AccountStatementDetails');
            List<Map<String, String>> newList = (List<Map<String, String>>) JSON.deserialize(JSON.serialize(transactionStatus), List<Map<String, String>>.class);
            System.debug('transactionStatus-->' +newList);
             if(newList!=null){
            for (Map<String, String> MapInstance : newList) {
                loanDetailsWrapper wrapperInstance = new loanDetailsWrapper();
                wrapperInstance.AccountNumber = accountNumberInstance;
                wrapperInstance.AccountID = MapInstance.get('AccountID');
                wrapperInstance.DebitedAmount =(String)MapInstance.get('DebitedAmount');
                wrapperInstance.CreditedAmount = MapInstance.get('CreditedAmount');
                wrapperInstance.RunningBalance = (String)MapInstance.get('RunningBalance');
                wrapperInstance.TxnDate = MapInstance.get('TxnDate');
                wrapperInstance.ValueDate = MapInstance.get('ValueDate');
                wrapperrList.add(wrapperInstance);
            }
             }
           
            //HardCoding Part
            //System.debug('respBody-->' + respBody);
            // Map<String, List<casaDetailsHandler.LoanDetailsResponseWrapper>> loanDetailsResponse = (Map<String, List<casaDetailsHandler.LoanDetailsResponseWrapper>>) JSON.deserialize(respBody,Map<String, List<casaDetailsHandler.LoanDetailsResponseWrapper>>.class);
            // List<casaDetailsHandler.LoanDetailsResponseWrapper>  accStatementList = loanDetailsResponse.get('AccountStatementDetails');
            // List<casaDetailsHandler.CASADetailsResponseWrapper> accStatementList =(List<casaDetailsHandler.CASADetailsResponseWrapper>)loanDetailsResponse.get('AccountStatementDetails');
            // System.debug('accStatementList-->' +accStatementList);
            // casaDetailsHandler.LoanDetailsResponseWrapper loanDetailsResponse =(casaDetailsHandler.LoanDetailsResponseWrapper) JSON.deserialize(respBody, casaDetailsHandler.LoanDetailsResponseWrapper.class);
            // System.debug('loanDetailsResponse-->' +loanDetailsResponse);
            
            //HardCoding the response for now
            /*   String jsonString ='{"AccountStatementDetails": [{"AccountID": "123423234","DebitedAmount": "2510","CreditedAmount": "0","RunningBalance": "2510","RunningTotal": "3642955965.9","TxnDate": "30-JUL-2022","ValueDate": "30-JUL-2022"}]}';
Map<String, List<casaDetailsHandler.LoanDetailsResponseWrapper>> jsonMap = (Map<String, List<casaDetailsHandler.LoanDetailsResponseWrapper>>) JSON.deserialize(jsonString, Map<String, List<casaDetailsHandler.LoanDetailsResponseWrapper>>.class);
System.debug('jsonMap-->' +jsonMap);
List<casaDetailsHandler.LoanDetailsResponseWrapper> accountStatementList =(List<casaDetailsHandler.LoanDetailsResponseWrapper>)jsonMap.get('AccountStatementDetails');
System.debug('accountStatementList-->' +accountStatementList);

for(integer i=0;i<accountStatementList.size();i++){
loanDetailsWrapper wrapperInstance = new loanDetailsWrapper();
wrapperInstance.AccountNumber = accountNumberInstance;
wrapperInstance.AccountID = accountStatementList[i].AccountID;
wrapperInstance.DebitedAmount = accountStatementList[i].DebitedAmount;
wrapperInstance.CreditedAmount = accountStatementList[i].CreditedAmount;
wrapperInstance.RunningBalance = accountStatementList[i].RunningBalance;
wrapperInstance.TxnDate = accountStatementList[i].TxnDate;
wrapperInstance.ValueDate = accountStatementList[i].ValueDate;
wrapperrList.add(wrapperInstance);
}*/
        } catch (Exception e) {
            System.debug('exception-->' +e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return wrapperrList;
    }
    
    @AuraEnabled
    public static   List<Bank_Account_Records__c> getLoanInquiryDetails(String accountNumberInstance,String applicantId){
        String respBody;
        String requestBody;
        // List<loanDetailsWrapper> wrapperrList = new List<loanDetailsWrapper>(); 
        try {
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Loan Inquiry');
             List<Bank_Account_Records__c> toUpdateBankRecords = new List<Bank_Account_Records__c>();
            //Loan Inquiry Request Part
            Map<String,Object> reqParam = new Map<String,Object>();
            //reqParam.put('ValueFromDate','20221226');
            //reqParam.put('ValueToDate','20230102');
            //reqParam.put('OriginatingChannel',objIntMapper.Apiuser__c);
            reqParam.put('OriginatingChannel','SFDC'); 
            reqParam.put('TransactionBranch','2011');
            reqParam.put('AccountNumber',accountNumberInstance); //  //9001070130327270
            requestBody = casaDetailsHandler.generateLoanInquiryRequest(reqParam)[0];
            system.debug('RequestBoday'+requestBody);
            String recordId =applicantId;
            
            casaDetailsHandler.LoanInquiryRequestWrapper loanDetailsRequest =
                (casaDetailsHandler.LoanInquiryRequestWrapper) JSON.deserialize(requestBody, casaDetailsHandler.LoanInquiryRequestWrapper.class);
            
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
            
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            respBody = calloutResponseWrapper.response;
            
            //Loan Inquiry Response Part
            Map<String, Object> jsonMap1= (Map<String, Object>) JSON.deserializeUntyped(respBody);
            if(jsonMap1.get('LoanAccountDetails')!=null){
                Map<string,Object> transactionStatus = ( Map<string,Object> ) jsonMap1.get('LoanAccountDetails');
                Map<String, String> newMap = (Map<String, String>) JSON.deserialize(JSON.serialize(transactionStatus), Map<String, String>.class);
                System.debug('transactionStatus-->' +newMap);
           
                if(newMap!=null){
                    Map<String,String> emiMap = new Map<String,String>();
                    Map<String,String> installmentMap = new Map<String,String>();
                    Map<String,String> nextDueDateMap = new Map<String,String>();
                    //for (Map<String, String> MapInstance : newList) {
                    emiMap.put(newMap.get('AccountNo'), newMap.get('TotalNoOfInstallmentsReceived'));
                    installmentMap.put(newMap.get('AccountNo'), newMap.get('InstallmentsOverDue'));
                    nextDueDateMap.put(newMap.get('AccountNo'), newMap.get('NextDueDate'));
                    //}
            
                    List < Bank_Account_Records__c > bankRecords = [SELECT Id, No_of_Emi_Paid__c, Loan_Overdue_EMI__c, RecordType.DeveloperName, Account_Number__c,POS__c
                                                            FROM Bank_Account_Records__c 
                                                            WHERE RecordType.DeveloperName = 'CBS'
                                                            AND Account_Number__c =: emiMap.keySet() 
                                                            AND Applicant__c =: applicantId WITH SECURITY_ENFORCED];
            
           
                    for (Bank_Account_Records__c bankRecord: bankRecords) {
                        String accountNumber = bankRecord.Account_Number__c;
                        bankRecord.No_of_Emi_Paid__c = Integer.valueof(emiMap.get(accountNumber));
                        bankRecord.Loan_Overdue_EMI__c = Integer.valueof(installmentMap.get(accountNumber));
                        String dueDate = nextDueDateMap.get(accountNumber)!=null ? nextDueDateMap.get(accountNumber) :'';
                        //Date dateValue = Date.valueOf(dueDate.substring(0,4) + '-' + dueDate.substring(4,6) + '-' + dueDate.substring(6,8));
                        if(String.isNotBlank(dueDate)){
                            //Date dateValue = Date.valueOf(dueDate.substring(0,4) + '-' + dueDate.substring(4,6) + '-' + dueDate.substring(6,8));    
                            Date dateValue =Date.valueOf(dueDate);
                            bankRecord.Next_Due_Date__c = dateValue;
                        }
                        if(bankRecord.Account_Number__c == newMap.get('AccountNo')){
                            if(newMap.get('PrincipalBalance')!=null){
                                bankRecord.POS__c = Decimal.valueOf(newMap.get('PrincipalBalance'));
                            }
                        }
                        bankRecord.View_Check__c = true;
                        toUpdateBankRecords.add(bankRecord);
                    }
            
                    if(!toUpdateBankRecords.isEmpty()){
                        update toUpdateBankRecords;
                    }
                }
			}
            
            else if(calloutResponseWrapper.statusCode == 200){
				List < Bank_Account_Records__c > bankRecords = [SELECT Id, No_of_Emi_Paid__c, Loan_Overdue_EMI__c, RecordType.DeveloperName, Account_Number__c
                                                            FROM Bank_Account_Records__c 
                                                            WHERE RecordType.DeveloperName = 'CBS'
                                                            AND Account_Number__c =: accountNumberInstance
                                                            AND Applicant__c =: applicantId WITH SECURITY_ENFORCED];
                if(!bankRecords.isEmpty()){
                    List<Bank_Account_Records__c> bankViewCheckList = new List<Bank_Account_Records__c>();
                    for(Bank_Account_Records__c bankInstance : bankRecords){
						Bank_Account_Records__c bank = new Bank_Account_Records__c();
                        bank.Id = bankInstance.Id;
                        bank.View_Check__c = true;
						bankViewCheckList.add(bank);                        
                    }
                    if(bankViewCheckList!=null && bankViewCheckList.size()>0){
					  update bankViewCheckList;
                    }
                }
            }
            
            
            
            return toUpdateBankRecords;
            
        } catch (Exception e) {
            System.debug('exception-->' +e.getMessage());
            System.debug('exception-->' +e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
     public static  List<Applicant__c> createApplicantQuery(List<Applicant__c> loanList){
        String strQuery;
        List<Applicant__c> applicantList  = new List<Applicant__c>();
        try{
            if(!loanList.isEmpty()){
                strQuery = 'SELECT id,SF_Exposure_JSON__c, Name,Voter_Id__c,Passport_Number__c,Driving_License_Id__c,Loan__r.Customer_Name__c,Loan__r.Loan_Sanction_date__c, Aadhaar_Number__c,PAN__c,CIF_No__c,Loan__r.Account__r.Name,Loan__r.RecordType.Name, RecordTypeId,Loan_Stage__c, Loan__r.Loan_Number__c,Loan__r.Application_Number__c, toLabel(Loan__r.Product__c),Customer_Type__c, Loan__r.CreatedDate, Loan__r.Stage__c, Loan__r.Loan_Amount__c, Loan__r.Branch_Name__c, Customer_Name__c, Mobile_Number__c, KYC_Status__c, CreatedById, CreatedBy.MobilePhone,CreatedBy.Name  FROM Applicant__c ';
                strQuery = strQuery + 'WHERE Id != \''+ String.escapeSingleQuotes(loanList[0].id) +'\' AND (';
                if(!String.isBlank(loanList[0].Mobile_Number__c)){
                    strQuery = strQuery + 'Mobile_Number__c = \''+String.escapeSingleQuotes(loanList[0].Mobile_Number__c)+'\' OR ';
                }
                if(!String.isBlank(loanList[0].PAN__c)){
                    strQuery = strQuery + 'PAN__c = \''+String.escapeSingleQuotes(loanList[0].PAN__c)+'\' OR ';
                }
                if(!String.isBlank(loanList[0].CIF_No__c)){
                    strQuery = strQuery + ' CIF_No__c = \''+String.escapeSingleQuotes(loanList[0].CIF_No__c)+'\' OR ';
                }
                if(!String.isBlank(loanList[0].Customer_Type__c) && loanList[0].Customer_Type__c == 'Individual'){
                    if(!String.isBlank(loanList[0].Aadhaar_Number__c)){
                        strQuery = strQuery + ' Aadhaar_Number__c = \''+String.escapeSingleQuotes(loanList[0].Aadhaar_Number__c)+'\' OR ';
                    }
                    if(!String.isBlank(loanList[0].Voter_Id__c)){
                        strQuery = strQuery + ' Voter_Id__c = \''+String.escapeSingleQuotes(loanList[0].Voter_Id__c)+'\' OR ';
                    }
                    if(!String.isBlank(loanList[0].Passport_Number__c)){
                        strQuery = strQuery + ' Passport_Number__c = \''+String.escapeSingleQuotes(loanList[0].Passport_Number__c)+'\' OR ';
                    }
                    if(!String.isBlank(loanList[0].Driving_License_Id__c)){
                        strQuery = strQuery + ' Driving_License_Id__c = \''+String.escapeSingleQuotes(loanList[0].Driving_License_Id__c)+'\' OR ';
                    }
                }
                
                strQuery = strQuery.removeEnd('OR ');
                strQuery = strQuery + ')';
                system.debug('%% '+strQuery);
                applicantList = Database.query(strQuery);
                
            }
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),loanList[0].Id);
        }
        return applicantList;
    }
    
    
    @AuraEnabled
    public static odLimitDetailsWrapper getCCDetails(String accountNumberInstance, String applicantId,String accountId){
        String respBody;
        String requestBody;
        try {
            System.debug('accountId-->' +accountId);
            Bank_Account_Records__c recordInstance =[SELECT Id,Over_Limit_Amount__c,Over_Limit_DPD__c,Drawing_Power__c,Fixed_Interest_Rate__c,Start_Date__c,End_Date__c,Next_Expiry_Date__c,isSecured__c,Renewal_Mode__c    
                                                     FROM Bank_Account_Records__c
                                                     WHERE Id=:accountId];
            System.debug('recordInstance-->' +recordInstance);
            
            
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('OD Limit Equiry');
            Map<String,Object> reqParam = new Map<String,Object>();
            
            reqParam.put('Channel','SFDC');
            reqParam.put('TransactionBranch','2011');
            reqParam.put('accountNo',accountNumberInstance); //accountNumberInstance  //2206210944321296
            requestBody = casaDetailsHandler.generateODLimitEquiryRequest(reqParam)[0];
            system.debug('RequestBoday'+requestBody);
            String recordId =applicantId;
            
            casaDetailsHandler.ODLimitInquiryRequestWrapper odDetailsRequest =
                (casaDetailsHandler.ODLimitInquiryRequestWrapper) JSON.deserialize(requestBody, casaDetailsHandler.ODLimitInquiryRequestWrapper.class);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
            
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            respBody = calloutResponseWrapper.response;
            
            
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(respBody);
            List<Object> overdraftDetails = (List<Object>) response.get('OverdraftDetails');
            Map<String, Object> overdraftDetailMap = (Map<String, Object>) overdraftDetails[0];
            Map<String, Object> overdraftDetail = (Map<String, Object>) overdraftDetailMap.get('OverdraftDetail');
            System.debug('OverdraftDetail-->' +OverdraftDetail);
            odLimitDetailsWrapper wrapperInstance = new odLimitDetailsWrapper();
            if(OverdraftDetail!=null){
                
                wrapperInstance.limitAmount = String.valueof((Integer) OverdraftDetail.get('limitAmount'));
                wrapperInstance.startDate = (String) OverdraftDetail.get('startDate');
                wrapperInstance.endDate = (String) OverdraftDetail.get('endDate');
                wrapperInstance.drawingPower = String.valueof((Integer) OverdraftDetail.get('drawingPower'));
                wrapperInstance.isSecured = (String) OverdraftDetail.get('isSecured');
                wrapperInstance.renewalMode = (String) OverdraftDetail.get('renewalMode');
                wrapperInstance.nextexpiryDate = (String) OverdraftDetail.get('nextexpiryDate');
                wrapperInstance.fixedInterestRate = String.valueof((Decimal) OverdraftDetail.get('fixedInterestRate'));
                wrapperInstance.DPD = '1234';
                
                Bank_Account_Records__c bankRecord = new Bank_Account_Records__c();
                bankRecord.Id = recordInstance.Id;
                bankRecord.Over_Limit_Amount__c = (Integer) OverdraftDetail.get('limitAmount');
                String startDate = String.valueof(wrapperInstance.startDate);
                String endDate  = String.valueof(wrapperInstance.endDate);
                
                Date dateValue = Date.valueOf(startDate.substring(0,4) + '-' + startDate.substring(4,6) + '-' + startDate.substring(6,8));
                Date dateEndValue = Date.valueOf(endDate.substring(0,4) + '-' + endDate.substring(4,6) + '-' + endDate.substring(6,8));
                bankRecord.Start_Date__c =dateValue;
                bankRecord.End_Date__c = dateEndValue;
                bankRecord.Drawing_Power__c =  Decimal.valueof(wrapperInstance.drawingPower);
                bankRecord.isSecured__c =   Boolean.valueof(wrapperInstance.isSecured);
                bankRecord.Renewal_Mode__c = wrapperInstance.renewalMode;
                String expiryDate = String.valueof(wrapperInstance.nextexpiryDate);
                Date expiryVal = Date.valueOf(expiryDate.substring(0,4) + '-' + expiryDate.substring(4,6) + '-' + expiryDate.substring(6,8));
                bankRecord.Next_Expiry_Date__c =expiryVal;
                bankRecord.Fixed_Interest_Rate__c =  (Decimal) OverdraftDetail.get('fixedInterestRate');
                bankRecord.Over_Limit_DPD__c =1234;
                if (Schema.sObjectType.Bank_Account_Records__c.isUpdateable()) {
                    update bankRecord;
                }
                System.debug('bankRecord-->' +bankRecord);
                return wrapperInstance;
            }else{
                return null;
            }
            
            
            
        } catch (Exception e) {
            System.debug('exception-->' +e);
            System.debug('line-->' +e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static fullDetailsWrapper handleExposureUpdation(Bank_Account_Records__c records,String  includeExposureVal) {
        Boolean isUpdated = false;
        fullDetailsWrapper wrapperInstance = new fullDetailsWrapper();
        try {
            
            System.debug('records-->' + records.Applicant__c);
            List < Applicant__c > applicantList = Utility.getApplicants(records.Applicant__c);
            System.debug('applicantList-->' + applicantList);
            List < Applicant__c > applicantTypeList = new List < Applicant__c > ();
            /* for(Applicant__c applicantInstance : applicantList){
if(applicantInstance.RecordType.Name =='Applicant'){
applicantTypeList.add(applicantInstance);
}
}*/
            
            Decimal WheelsExposure = records.Applicant__r.Loan__r.Wheels_Exposure__c;
            Decimal TotalExposure = records.Applicant__r.Loan__r.Final_Exposure__c;
            Decimal posVal = (records.POS__c != null) ? records.POS__c : 0;
            Decimal creditLimit = (records.Sanctioned_Amount__c != null) ? records.Sanctioned_Amount__c : 0;
            
            Decimal updatedWheelsExposure = 0;
            Decimal updatedTotalExposure = 0;
            
            String productCode = (String.isNotBlank(records.Product_Code__c)) ? records.Product_Code__c : '';
            List < ProductRTMap__mdt > productData = new List < ProductRTMap__mdt > ();
            if (String.isNotBlank(productCode)) {
                productData = [SELECT MasterLabel, RecordType__c, Product__c
                               FROM ProductRTMap__mdt
                               WHERE Product__c =: productCode  WITH SECURITY_ENFORCED LIMIT 1
                              ];
            }
            
            if (records.Account_Type__c == 'Loan') {
                if ((!productData.isEmpty()) && (productData[0].RecordType__c == 'Two Wheeler' || productData[0].RecordType__c == 'Four Wheeler')) {
                    if(includeExposureVal =='No'){
                        updatedWheelsExposure = (WheelsExposure - posVal);
                        records.Include_In_Exposure__c ='No';
                    }else if(includeExposureVal =='Yes'){
                        updatedWheelsExposure = (WheelsExposure + posVal);
                        records.Include_In_Exposure__c ='Yes';
                    }
                    
                }
                if(includeExposureVal =='No'){
                    updatedTotalExposure = (TotalExposure - posVal);
                    records.Include_In_Exposure__c ='No';
                }else if(includeExposureVal =='Yes'){
                    updatedTotalExposure = (TotalExposure + posVal);
                    records.Include_In_Exposure__c ='Yes';
                }
            }
            System.debug('TotalExposure-->' + TotalExposure + '---creditLimit-->' + creditLimit + '---posVal==>' + posVal);
            System.debug('records.Account_Type__c-->' + records.Account_Type__c);
            if (records.Account_Type__c == 'CC') {
                if(includeExposureVal =='No'){
                    updatedTotalExposure = (TotalExposure - creditLimit);
                    records.Include_In_Exposure__c ='No';
                }else if(includeExposureVal =='Yes'){
                    updatedTotalExposure = (TotalExposure + creditLimit);
                    records.Include_In_Exposure__c ='Yes';
                }
            }
            System.debug('updatedTotalExposure-->' + updatedTotalExposure);
            //Update Exposure Applicant Level
            Applicant__c applicant = new Applicant__c();
            applicant.Id = applicantList[0].Id;
            applicant.Final_Exposure__c = updatedTotalExposure;
            
            if ((updatedWheelsExposure != 0) && (records.Account_Type__c == 'Loan')) {
                applicant.Wheels_Exposure__c = updatedWheelsExposure;
            }
            if (Schema.sObjectType.Applicant__c.isUpdateable()) {
                update applicant;
                System.debug('applicant-->' + applicant);
                
                Loan_Application__c application = new Loan_Application__c();
                application.Id = records.Applicant__r.Loan__c;
                application.Wheels_Exposure__c = updatedWheelsExposure;
                application.Final_Exposure__c = updatedTotalExposure;
                update application;
                
                
                isUpdated = true;
            }
            
            
            wrapperInstance.wheelsExposure = updatedWheelsExposure;
            wrapperInstance.totalExposure = updatedTotalExposure;
            
            update records;
            
        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('line-->' + e.getLineNumber());
        }
        return wrapperInstance;
    }
    
    
    @AuraEnabled
    public static fullDetailsWrapper handleDisbursedExposureUpdation(Applicant__c applicantRecords, String includeExposureVal ,String strLoanId){
        fullDetailsWrapper wrapperInstance1 = new fullDetailsWrapper();
        System.debug('records-->' + applicantRecords);
        try {
            Loan_Application__c loanInstance = [SELECT Id, Wheels_Exposure__c, Final_Exposure__c, Product__c 
                                                FROM Loan_Application__c WHERE Id =: strLoanId WITH SECURITY_ENFORCED LIMIT 1
                                               ];
            System.debug('loanInstance-->' +loanInstance);
            Decimal WheelsExposure = loanInstance.Wheels_Exposure__c;
            Decimal TotalExposure = loanInstance.Final_Exposure__c;
            Decimal loanAmount = applicantRecords.Loan__r.Loan_Amount__c;
            Decimal updatedWheelsExposure=0;
            Decimal updatedTotalExposure =0;
            
            String productName = (String.isNotBlank(loanInstance.Product__c)) ? 'A_' + loanInstance.Product__c : ''; // SFAU-5584
            List < ProductRTMap__mdt > productData = new List < ProductRTMap__mdt > ();
            if (String.isNotBlank(productName)) {
                productData = [SELECT MasterLabel, RecordType__c, Product__c
                               FROM ProductRTMap__mdt
                               WHERE DeveloperName =: productName  WITH SECURITY_ENFORCED LIMIT 1
                              ];
            }
            
            if ((!productData.isEmpty()) && (productData[0].RecordType__c == 'Two Wheeler' || productData[0].RecordType__c == 'Four Wheeler')) {
                if(includeExposureVal =='No'){
                    updatedWheelsExposure = (WheelsExposure - loanAmount);
                }else if(includeExposureVal =='Yes'){
                    updatedWheelsExposure = (WheelsExposure + loanAmount);
                }
                
            }
            
            if(includeExposureVal =='No'){
                updatedTotalExposure = (TotalExposure - loanAmount);
            }else if(includeExposureVal =='Yes'){
                updatedTotalExposure = (TotalExposure + loanAmount);
            }
            
            String jsonString = applicantRecords.SF_Exposure_JSON__c;
            List<ExistingLoanWrapper> updatedLoanList = new List<ExistingLoanWrapper>();
            ExistingLoanWrapper wrapperInstance = new ExistingLoanWrapper();
            List<ExistingLoanWrapper> loanList = (List<ExistingLoanWrapper>)JSON.deserialize(jsonString,List<ExistingLoanWrapper>.class );
            ExistingLoanWrapper loanWrapper = loanList[0];
            
            
            wrapperInstance.includeInExposure = includeExposureVal;
            wrapperInstance.SanctionDate = loanWrapper.SanctionDate;
            wrapperInstance.LoanAmount =  loanWrapper.LoanAmount;
            wrapperInstance.customerName =  loanWrapper.customerName;
            wrapperInstance.creditOverrideAuthority =  loanWrapper.creditOverrideAuthority;
            wrapperInstance.applicationNumber =  loanWrapper.applicationNumber;
            updatedLoanList.add(wrapperInstance);
            
            
            //Update Exposure Applicant Level
            Applicant__c applicant = new Applicant__c();
            applicant.Id = applicantRecords.Id;
            applicant.Final_Exposure__c = updatedTotalExposure;
            applicant.SF_Exposure_JSON__c = JSON.serialize(updatedLoanList);
            
            if (updatedWheelsExposure != 0) {
                applicant.Wheels_Exposure__c = updatedWheelsExposure;
            }
            if (Schema.sObjectType.Applicant__c.isUpdateable()) {
                update applicant;
            }
            System.debug('applicant-->' + applicant);
            Loan_Application__c application = new Loan_Application__c();
            application.Id = strLoanId;
            application.Wheels_Exposure__c = updatedWheelsExposure;
            application.Final_Exposure__c = updatedTotalExposure;
            if(Schema.sObjectType.Loan_Application__c.isUpdateable()){
                update application;
            }
            
            wrapperInstance1.wheelsExposure = updatedWheelsExposure;
            wrapperInstance1.totalExposure = updatedTotalExposure;
        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('exception-->' + e.getLineNumber());
        }
        return wrapperInstance1;
    }
    
    
    @AuraEnabled
    public static string getUserProfileDetails(String userId){
        try {
             User userDetails = [SELECT id,name,Profile.Name 
                                 FROM User
                                 WHERE Id=:userId  ];

             String profileName = userDetails.Profile.Name ;
             return profileName; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    /*
@description :  Method to get Visible fields based on the screen from Stage_Profile_Data_Configuration__mdt Custom Metadata Records
@param :  String  strScreen
@return : List<String>
*/
    @AuraEnabled
    public static List<String> getVisibleFields(String strScreen,String Stage) {
        return Utility.getVisibleFields(strScreen,Stage,'System Administrator');
    }
    
    
    public class accountRecordsWrapper {
        // @AuraEnabled public Decimal cbsLoanAmount{get;set;}
        
        @AuraEnabled public String applicantName {
            get;
            set;
        }
        @AuraEnabled public String applicantId {
            get;
            set;
        }
        @AuraEnabled public String applicantCIF {
            get;
            set;
        }
        
        @AuraEnabled public List < Applicant__c > applicantRecords {
            get;
            set;
        }
        @AuraEnabled public List < Bank_Account_Records__c > odccBankAccountRecords {
            get;
            set;
        }
        @AuraEnabled public List < Bank_Account_Records__c > casBankAccountRecords {
            get;
            set;
        }
        @AuraEnabled public List < Bank_Account_Records__c > loanBankAccountRecords {
            get;
            set;
        }
        @AuraEnabled public List < Bank_Account_Records__c > creditBankAccountRecords {
            get;
            set;
        }
        @AuraEnabled public Boolean isODCC {
            get;
            set;
        }
        @AuraEnabled public Boolean isCASA {
            get;
            set;
        }
        @AuraEnabled public Boolean isLOAN {
            get;
            set;
        }
        
        
        @AuraEnabled public Boolean isCREDIT {
            get;
            set;
        }
        
        @AuraEnabled public Boolean isApplicantLoan {
            get;
            set;
        }
        
        @AuraEnabled public String includeExposure {
            get;
            set;
        }
        @AuraEnabled public String loanId {
            get;
            set;
        }
        
        @AuraEnabled public Boolean creditAuthority {
            get;
            set;
        }
         @AuraEnabled public Boolean bankCheck{
            get;
            set;
        }
        
        
        
        public accountRecordsWrapper() {
            applicantId='';
            loanId='';
            applicantName = '';
            applicantCIF ='';
            includeExposure ='';
            applicantRecords = new List < Applicant__c > ();
            odccbankAccountRecords = new List < Bank_Account_Records__c > ();
            casBankAccountRecords = new List < Bank_Account_Records__c > ();
            loanBankAccountRecords = new List < Bank_Account_Records__c > ();
            creditBankAccountRecords = new List < Bank_Account_Records__c > ();
            isODCC = false;
            isCASA = false;
            isLOAN = false;
            isCREDIT = false;
            creditAuthority = false;
            isApplicantLoan = false;
            bankCheck = true;
        }
    }
    
    public class fullDetailsWrapper {
        @AuraEnabled public List < accountRecordsWrapper > recordWrapperList {
            get;
            set;
        }
        @AuraEnabled public Decimal wheelsExposure {
            get;
            set;
        }
        @AuraEnabled public Decimal totalExposure {
            get;
            set;
        }
        
        @AuraEnabled public String typeOfVehicle {
            get;
            set;
        }
        
        @AuraEnabled public String loanStage{
            get;
            set;
        }

        @AuraEnabled public Boolean showMainSection{
            get;
            set;
        }
        
        public fullDetailsWrapper() {
            wheelsExposure = 0;
            totalExposure = 0;
            typeOfVehicle='';
            loanStage='';
            showMainSection = true;
            recordWrapperList = new List < accountRecordsWrapper > ();
        }
    }
    
    public class casaDetailsWrapper{
        @AuraEnabled public String AccountNumber {
            get;
            set;
        }
        
        @AuraEnabled public String TransactionAmount {
            get;
            set;
        }
        @AuraEnabled public String TransactionType {
            get;
            set;
        }
        @AuraEnabled public String TxnId {
            get;
            set;
        }
        @AuraEnabled public String Description {
            get;
            set;
        }
        @AuraEnabled public String RunningTotal {
            get;
            set;
        }
        @AuraEnabled public String ChequeNumber {
            get;
            set;
        }
        @AuraEnabled public String ValueDate {
            get;
            set;
        }
        @AuraEnabled public String TransactionBranch {
            get;
            set;
        }
        @AuraEnabled public String TransactionDate {
            get;
            set;
        }
        
        public casaDetailsWrapper() {
            AccountNumber='';//Added Extra to distinguish
            TransactionAmount='';
            TransactionType='';
            TxnId='';
            Description='';
            RunningTotal='';
            ChequeNumber='';
            ValueDate='';
            TransactionBranch='';
            TransactionDate='';
            
            
        }
    }
    
    public class odLimitDetailsWrapper{
        @AuraEnabled public String limitAmount {
            get;
            set;
        }
        
        @AuraEnabled public String startDate {
            get;
            set;
        }
        @AuraEnabled public String endDate {
            get;
            set;
        }
        @AuraEnabled public String drawingPower {
            get;
            set;
        }
        @AuraEnabled public String isSecured {
            get;
            set;
        }
        @AuraEnabled public String renewalMode {
            get;
            set;
        }
        @AuraEnabled public String nextexpiryDate {
            get;
            set;
        }
        @AuraEnabled public String fixedInterestRate {
            get;
            set;
        }
        @AuraEnabled public String DPD {
            get;
            set;
        }
        
        
        public odLimitDetailsWrapper() {
            limitAmount='';
            startDate='';
            endDate='';
            drawingPower='';
            isSecured='';
            renewalMode='';
            nextexpiryDate='';
            fixedInterestRate='';
            DPD='';
        }
    }
    
    public class loanDetailsWrapper{
        @AuraEnabled public String AccountNumber {
            get;
            set;
        }
        @AuraEnabled public String AccountID {
            get;
            set;
        }
        
        @AuraEnabled public String DebitedAmount {
            get;
            set;
        }
        @AuraEnabled public String CreditedAmount {
            get;
            set;
        }
        @AuraEnabled public String RunningBalance {
            get;
            set;
        }
        @AuraEnabled public String TxnDate {
            get;
            set;
        }
        @AuraEnabled public String ValueDate {
            get;
            set;
        }
        
        public loanDetailsWrapper(){
            AccountNumber='';
            AccountID ='';
            DebitedAmount='';
            CreditedAmount='';
            RunningBalance='';
            TxnDate='';
            ValueDate='';
        }
        
    }
    
    public class ExistingLoanWrapper{
        @AuraEnabled  public String applicationNumber;
        @AuraEnabled  public String customerName;
        @AuraEnabled public String Product;
        @AuraEnabled public String LoanAmount;
        @AuraEnabled  public String SanctionDate;
        @AuraEnabled  public String includeInExposure;
        @AuraEnabled public Boolean creditOverrideAuthority;
    }
    
    
}