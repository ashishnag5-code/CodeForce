public with sharing class BSACreditController {
    @AuraEnabled
    public static List < bankRecordsWrapper > getBankRecords(Id applicantId) {
        List < Bank_Account_Records__c > accountList = new List < Bank_Account_Records__c > ();

        List < bankRecordsWrapper > wrapperList = new List < bankRecordsWrapper > ();

        try {
            Map < Id, Id > bankContentMap = new Map < Id, Id > ();

            accountList = [SELECT Id, Account_Type__c,Manual_Check__c, Average_Monthly_Balance__c,Average_Monthly_Credit__c,Analysis_Data__c, IFSC_Code__c, Account_Name__c, Account_Number__c, (SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLinks ORDER BY SystemModstamp DESC  ), Total_Credit__c, Total_Debit__c, Inward_Cheque_Bounce__c, Outward_Cheque_Bounce__c, Total_Salary__c, RecordType.Name, Applicant__c, Statement_Start_Date__c, Statement_End_Date__c, Month_Difference__c, EMI_Amount__c, No_of_Emi_Paid__c, Average_Balance__c, Bank_Name__c, Branch_Name__c
                FROM Bank_Account_Records__c
                WHERE Applicant__c =: applicantId
                AND RecordType.Name =: GlobalConstants.CART_RECORDTYPE_NAME
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate desc
            ];
         
            for (Bank_Account_Records__c recordInstance: accountList) {
                bankRecordsWrapper wrapperInstance = new bankRecordsWrapper();

                wrapperInstance.recordId = recordInstance.Id;
                wrapperInstance.accHolderName = recordInstance.Account_Name__c;
                wrapperInstance.accountNumber = recordInstance.Account_Number__c;
                wrapperInstance.ifscCode = recordInstance.IFSC_Code__c;
                wrapperInstance.bankNme = recordInstance.Bank_Name__c;
                wrapperInstance.branchName = recordInstance.Branch_Name__c;
                wrapperInstance.accountType = recordInstance.Account_Type__c;
                wrapperInstance.startDate = recordInstance.Statement_Start_Date__c!=null ? String.valueOf(recordInstance.Statement_Start_Date__c):'';
                wrapperInstance.endDate = recordInstance.Statement_End_Date__c!=null ? String.valueOf(recordInstance.Statement_End_Date__c):'';
                wrapperInstance.totalNoCredit = recordInstance.Total_Credit__c;
                wrapperInstance.totalNoDebit = recordInstance.Total_Debit__c;
                wrapperInstance.iwCheque = recordInstance.Inward_Cheque_Bounce__c;
                wrapperInstance.owCheque = recordInstance.Outward_Cheque_Bounce__c;
                wrapperInstance.totalNoEmi = recordInstance.No_of_Emi_Paid__c;
                wrapperInstance.totalNoEmiAmount = recordInstance.EMI_Amount__c;
                wrapperInstance.salaryConfirm = recordInstance.Total_Salary__c;
                wrapperInstance.manualCheck= recordInstance.Manual_Check__c;
                wrapperInstance.AverageMonthlyBalance =recordInstance.Average_Monthly_Balance__c!= null ? (recordInstance.Average_Monthly_Balance__c).setscale(2):0;
                wrapperInstance.AverageMonthlyCredit = recordInstance.Average_Monthly_Credit__c !=null ?(recordInstance.Average_Monthly_Credit__c).setscale(2):0;
                wrapperInstance.averageBalance = recordInstance.Average_Balance__c!=null ? (recordInstance.Average_Balance__c).setscale(2):0;
                wrapperInstance.analysisFullData =( recordInstance.Analysis_Data__c!=null) ? recordInstance.Analysis_Data__c : '';
              /*  if (String.isNotBlank(recordInstance.Analysis_Data__c)) {
                    Map < String, Object > parsedJson = (Map < String, Object > ) JSON.deserializeUntyped(recordInstance.Analysis_Data__c);
                    if (parsedJson.get('monthlyBalancesDetails') != null) {
                        Map < String, Object > monthlyBalancesDetails = (Map < String, Object > ) parsedJson.get('monthlyBalancesDetails');
                        Map < String, Object > monthlyBalancesDec2022 = (Map < String, Object > ) monthlyBalancesDetails.get('Month-Year'); //Dec-2022
                        wrapperInstance.analysisData = true;
                        wrapperInstance.analysisFullData = recordInstance.Analysis_Data__c;
                        wrapperInstance.month = 'Dec-2022';
                        wrapperInstance.year = '2022';
                        wrapperInstance.balance5=0;
                        wrapperInstance.balance15=0;
                        wrapperInstance.balance25=0;
                        wrapperInstance.amb=0;
                        

                       // wrapperInstance.balance5 = ( monthlyBalancesDec2022.get('5') !=null) ? (Decimal) monthlyBalancesDec2022.get('5') :0;
                       // wrapperInstance.balance15 =  ( monthlyBalancesDec2022.get('5') !=null) ? (Decimal) monthlyBalancesDec2022.get('15'):0;
                       // wrapperInstance.balance25 =  ( monthlyBalancesDec2022.get('5') !=null) ? (Decimal) monthlyBalancesDec2022.get('25'):0;
                        wrapperInstance.averageBalance = (wrapperInstance.balance5 + wrapperInstance.balance15 + wrapperInstance.balance25) / 3;
                       //wrapperInstance.amb = (Decimal) monthlyBalancesDec2022.get('AMB');
                    }

                    if (parsedJson.get('monthlyCreditsDetails') != null) {
                        Map < String, Object > monthlyCreditDetails = (Map < String, Object > ) parsedJson.get('monthlyCreditsDetails');
                        Map < String, Object > monthlyCreditsDec2022 = (Map < String, Object > ) monthlyCreditDetails.get('Month-Year');
                       // wrapperInstance.credit = (Decimal) monthlyCreditsDec2022.get('Credit');
                        //wrapperInstance.amc= (Decimal) monthlyCreditsDec2022.get('Credit');
                       //wrapperInstance.salarycredit = (Decimal) monthlyCreditsDec2022.get('Salary Credit');
                        wrapperInstance.credit =0;
                        wrapperInstance.amc =0;
                        wrapperInstance.salarycredit =0;
                        //wrapperInstance.salarycredit = (Decimal) monthlyCreditsDec2022.get('Salary Credit');
                    }
                }*/
                System.debug('recordInstance.ContentDocumentLinks-->' +recordInstance.ContentDocumentLinks);
                    if(!(recordInstance.ContentDocumentLinks).isEmpty() ){
                        wrapperInstance.fileID = recordInstance.ContentDocumentLinks[0].ContentDocumentId;
                    }
               
                wrapperList.add(wrapperInstance);
            }


        } catch (exception e) {
            Log.error(e, Log.SeverityType.valueOf('High'), '');
            System.debug('exception-->' + e);
            System.debug('line-->' + e.getLineNumber());
        }
        return wrapperList;
    }


    @AuraEnabled
    public static String createBSARecord(Bank_Account_Records__c bsaRecord){
        Bank_Account_Records__c bankObj = new Bank_Account_Records__c();
        try {
           Id CartId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
            bankObj = bsaRecord;
            bankObj.Manual_Check__c = true;
            bankObj.RecordTypeId = CartId;
            if(Schema.sObjectType.Bank_Account_Records__c.isUpdateable()){
                upsert bankObj;
            }
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return bankObj.Id;
    }

    @AuraEnabled
    public static void createAmbRecord(String bsaRecord,Decimal ambAverage,String applicantId) {
        System.debug('bsaRecord-->' + bsaRecord);
        System.debug('applicantId-->' + applicantId);
        Bank_Account_Records__c bankRecordInstance = new Bank_Account_Records__c();
         bankRecordsWrapper bsaRecord1 = (bankRecordsWrapper) JSON.deserialize(bsaRecord, bankRecordsWrapper.class );
        try {
            //Get Latest Bank Analysis Data 
            List<bankRecordsWrapper> bankRecords = getBankRecords(applicantId);
            List<bankRecordsWrapper> bankFilteredRecords = new  List<bankRecordsWrapper> ();
            for(bankRecordsWrapper recordInstance : bankRecords){
                if(recordInstance.recordId ==  bsaRecord1.recordId){
                    bankFilteredRecords.add(recordInstance);
                }
            }
            System.debug('bankRecords-->' + bankRecords);

            Map < String, Object > parsedJson = new Map<String,Object>();
            List<Object > monthlyBalancesExistingDetails= new  List<Object >();
            List<Object> monthlyBalancesExistingDetails1 = new  List<Object>();
            Map<String,Object> monthlyBalancesDetailsGrandTotalExisting = new Map<String,Object>();
            Map<String,Object> monthlyCreditsDetailsGrandTotalExisting = new Map<String,Object>();
            
            
            if(!bankFilteredRecords.isEmpty()){
                if(bankFilteredRecords[0].analysisFullData!=null && bankFilteredRecords[0].analysisFullData!='' ){
                    parsedJson= (Map < String, Object > ) JSON.deserializeUntyped(bankFilteredRecords[0].analysisFullData);  //bankAnalysisVal
                    monthlyBalancesExistingDetails = (List < Object > ) parsedJson.get('monthlyBalancesDetails');
                    monthlyBalancesExistingDetails1 = (List < Object >) parsedJson.get('monthlyCreditsDetails');
                    monthlyBalancesDetailsGrandTotalExisting = ( Map<String,Object> ) parsedJson.get('monthlyBalancesDetailsGrandTotal');
                    monthlyCreditsDetailsGrandTotalExisting =  (Map<String,Object> ) parsedJson.get('monthlyCreditsDetailsGrandTotal');
                 }
            }
            
            //Map < String, Object > monthlyBalancesExistingDetails = (Map < String, Object > ) parsedJson.get('monthlyBalancesDetails');
            //Map < String, Object > monthlyBalancesExistingDetails1 = (Map < String, Object > ) parsedJson.get('monthlyCreditsDetails');

           
            
            
            
           

            Map < String, Object > jsonData = new Map < String, Object > ();
           
            //Map < String, Object > monthlyBalancesDetails = new Map < String, Object > ();
            //Map < String, Object > monthlyCreditsDetails = new Map < String, Object > ();

            List<Object>  monthlyBalancesDetails =  new List<Object>();
            List<Object>  monthlyCreditsDetails =  new List<Object>();

            Map < String, Object > decBalances = new Map < String, Object > ();
            Map < String, Object > decCredits = new Map < String, Object > ();

            // Populate monthly balances data for Dec-2022

            bankRecordInstance.Id = (Id) bsaRecord1.recordId;
            decBalances.put('averageBalanceOn5th', bsaRecord1.averageBalanceOn5th);
            decBalances.put('averageBalanceOn15th', bsaRecord1.averageBalanceOn15th);
            decBalances.put('averageBalanceOn25th', bsaRecord1.averageBalanceOn25th);
            decBalances.put('AMB', bsaRecord1.amb);
            decBalances.put('AMC', bsaRecord1.amc);
            decBalances.put('ManualCheck', true);
            String monthYear = bsaRecord1.month + '-' + bsaRecord1.year;
            decBalances.put('Month-Year',monthYear);
            //monthlyBalancesDetails.put(monthYear, decBalances);
            monthlyBalancesDetails.add(decBalances);
            
            //Adding the existing monthly Balance details
          // monthlyBalancesDetails.putAll(monthlyBalancesExistingDetails);
           //monthlyCreditsDetails.putAll(monthlyBalancesExistingDetails1);
           monthlyBalancesDetails.addAll(monthlyBalancesExistingDetails);
           monthlyCreditsDetails.addAll(monthlyBalancesExistingDetails1);

        

            // Add data to the main JSON object
            jsonData.put('monthlyBalancesDetails', monthlyBalancesDetails);
            jsonData.put('monthlyCreditsDetails', monthlyCreditsDetails);

           
             jsonData.put('monthlyBalancesDetailsGrandTotal', monthlyBalancesDetailsGrandTotalExisting);
            jsonData.put('monthlyCreditsDetailsGrandTotal', monthlyCreditsDetailsGrandTotalExisting);


            System.debug('jsonData-->' +jsonData);

            // Serialize the JSON object to a string
            String jsonStr = JSON.serialize(jsonData);
            bankRecordInstance.Analysis_Data__c = jsonStr;
            bankRecordInstance.Average_Balance__c = (Decimal) bsaRecord1.averageBalance;
            bankRecordInstance.Average_Monthly_Balance__c = ((ambAverage!=0)? ambAverage : 0 );
            //bankRecordInstance.Average_Monthly_Credit__c = (Decimal)bsaRecord1.amc + ((amcAverage!=0)? amcAverage : 0 );
            //bankRecordInstance.Manual_Check__c = true;

            if (Schema.sObjectType.Bank_Account_Records__c.isUpdateable()) {
                update bankRecordInstance;
            }


        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('line-->' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createAmcRecord(String bsaRecord, Decimal amcAverage,String applicantId){
        Bank_Account_Records__c bankRecordInstance = new Bank_Account_Records__c();
        bankRecordsWrapper bsaRecord1 = (bankRecordsWrapper) JSON.deserialize(bsaRecord, bankRecordsWrapper.class );
        try {
             //Get Latest Bank Analysis Data 
             List<bankRecordsWrapper> bankRecords = getBankRecords(applicantId);
             List<bankRecordsWrapper> bankFilteredRecords = new  List<bankRecordsWrapper> ();
             for(bankRecordsWrapper recordInstance : bankRecords){
                 if(recordInstance.recordId ==  bsaRecord1.recordId){
                     bankFilteredRecords.add(recordInstance);
                 }
             }
             System.debug('bankRecords-->' + bankRecords);
 
             Map < String, Object > parsedJson = (Map < String, Object > ) JSON.deserializeUntyped(bankFilteredRecords[0].analysisFullData);  //bankAnalysisVal
            // Map < String, Object > monthlyBalancesExistingDetails = (Map < String, Object > ) parsedJson.get('monthlyBalancesDetails');
            // Map < String, Object > monthlyBalancesExistingDetails1 = (Map < String, Object > ) parsedJson.get('monthlyCreditsDetails');

            List<Object > monthlyBalancesExistingDetails = (List < Object > ) parsedJson.get('monthlyBalancesDetails');
            List<Object> monthlyBalancesExistingDetails1 = (List < Object >) parsedJson.get('monthlyCreditsDetails');
            Map<String,Object> monthlyBalancesDetailsGrandTotalExisting = ( Map<String,Object> ) parsedJson.get('monthlyBalancesDetailsGrandTotal');
            Map<String,Object> monthlyCreditsDetailsGrandTotalExisting =  (Map<String,Object> ) parsedJson.get('monthlyCreditsDetailsGrandTotal');


             Map < String, Object > jsonData = new Map < String, Object > ();
            // Map < String, Object > monthlyBalancesDetails = new Map < String, Object > ();
             //Map < String, Object > monthlyCreditsDetails = new Map < String, Object > ();
             List<Object>  monthlyBalancesDetails =  new List<Object>();
             List<Object>  monthlyCreditsDetails =  new List<Object>();

             
             Map < String, Object > decBalances = new Map < String, Object > ();
             Map < String, Object > decCredits = new Map < String, Object > ();

             bankRecordInstance.Id = (Id) bsaRecord1.recordId;
             decCredits.put('Credit', bsaRecord1.credit);
             decCredits.put('Salary Credit', bsaRecord1.salarycredit);
          
             decCredits.put('ManualCheck', true);
             String monthYear = bsaRecord1.month + '-' + bsaRecord1.year;
             decCredits.put('Month-Year',monthYear);

             //monthlyCreditsDetails.put(monthYear, decCredits);
             monthlyCreditsDetails.add(decCredits);
             
             //Adding the existing monthly Balance details
             //monthlyCreditsDetails.putAll(monthlyBalancesExistingDetails1);
             //monthlyBalancesDetails.putAll(monthlyBalancesExistingDetails);
             
             monthlyCreditsDetails.addAll(monthlyBalancesExistingDetails1);
             monthlyBalancesDetails.addAll(monthlyBalancesExistingDetails);
             
             

             
 
             // Add data to the main JSON object
             jsonData.put('monthlyBalancesDetails', monthlyBalancesDetails);
             jsonData.put('monthlyCreditsDetails', monthlyCreditsDetails);
             jsonData.put('monthlyBalancesDetailsGrandTotal', monthlyBalancesDetailsGrandTotalExisting);
             jsonData.put('monthlyCreditsDetailsGrandTotal', monthlyCreditsDetailsGrandTotalExisting);
             System.debug('jsonData-->' +jsonData);
 
             // Serialize the JSON object to a string
             String jsonStr = JSON.serialize(jsonData);
             bankRecordInstance.Analysis_Data__c = jsonStr;
            // bankRecordInstance.Manual_Check__c = true;
            bankRecordInstance.Average_Monthly_Credit__c = (amcAverage!=0)? amcAverage : 0 ;
 
             if (Schema.sObjectType.Bank_Account_Records__c.isUpdateable()) {
                 update bankRecordInstance;
             }
 
 
 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return bankRecordInstance.Id;
    }

    @AuraEnabled
    public static void updateAmbRecord(String bsaUpdatedRecord, String bankRecordId, Decimal ambAverage,Boolean isAmb){
        Bank_Account_Records__c bankRecordInstance = new Bank_Account_Records__c();
        try {
            System.debug('bsaUpdatedRecord-->' +bsaUpdatedRecord);
            bankRecordInstance.Id = bankRecordId;
            bankRecordInstance.Analysis_Data__c = bsaUpdatedRecord;
            if(isAmb ==true){
                bankRecordInstance.Average_Monthly_Balance__c = ambAverage;
            }else{
                bankRecordInstance.Average_Monthly_Credit__c = ambAverage;
            }
            if (Schema.sObjectType.Bank_Account_Records__c.isUpdateable()) {
                update bankRecordInstance;
            }

        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('line-->' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void  removeBSARecord(String bankAccountRecordId){
        try {
            Bank_Account_Records__c  accountList = [SELECT Id, Account_Type__c, Account_Number__c
            FROM Bank_Account_Records__c
            WHERE Id =: bankAccountRecordId
            WITH SECURITY_ENFORCED];

            if(Schema.sObjectType.Bank_Account_Records__c.isDeletable()){
                delete accountList;
            }
            
        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('line-->' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    

    public class bankRecordsWrapper{
          @AuraEnabled public String recordId{get;set;}
        @AuraEnabled public Boolean analysisData{get;set;}
        @AuraEnabled public String analysisFullData{get;set;}
        @AuraEnabled public String month{get;set;}
        @AuraEnabled public String year{get;set;}
        @AuraEnabled public Decimal averageBalanceOn5th{get;set;} 
        @AuraEnabled public Decimal averageBalanceOn15th{get;set;} 
        @AuraEnabled public Decimal averageBalanceOn25th{get;set;} 
        @AuraEnabled public Decimal averageBalance{get;set;} 
        @AuraEnabled public Decimal credit{get;set;} 
        @AuraEnabled public Decimal salarycredit{get;set;} 
        @AuraEnabled public Boolean manualCheck{get;set;}
        @AuraEnabled public Decimal AverageMonthlyBalance{get;set;}
        @AuraEnabled public Decimal AverageMonthlyCredit{get;set;}

        
        @AuraEnabled public String accHolderName{get;set;}     
        @AuraEnabled public String accountNumber{get;set;}
        @AuraEnabled public String ifscCode{get;set;}
        @AuraEnabled public String bankNme{get;set;}
        @AuraEnabled public String branchName{get;set;}
        @AuraEnabled public String accountType{get;set;}
        @AuraEnabled public String startDate{get;set;}
        @AuraEnabled public String endDate{get;set;}
        @AuraEnabled public Decimal totalNoCredit{get;set;}
        @AuraEnabled public Decimal totalNoDebit{get;set;}
        @AuraEnabled public Decimal amb{get;set;}
        @AuraEnabled public Decimal amc{get;set;}
        @AuraEnabled public String iwCheque{get;set;}
        @AuraEnabled public String owCheque{get;set;}
        @AuraEnabled public Decimal totalNoEmi{get;set;}
        @AuraEnabled public Decimal totalNoEmiAmount{get;set;}
        @AuraEnabled public Decimal salaryConfirm{get;set;}
        @AuraEnabled public String fileID{get;set;}
        @AuraEnabled public Integer index{get;set;}

        public bankRecordsWrapper() {
            recordId='';
         analysisData = false;
         analysisFullData ='';
         month='';
         year='';
         averageBalanceOn5th=0;
         averageBalanceOn15th=0;
         averageBalanceOn25th=0;
         averageBalance=0;
         credit=0;
         salarycredit=0;
         manualCheck =false;
         AverageMonthlyBalance=0;
         AverageMonthlyCredit=0;
         accHolderName='';
         accountNumber='';
         ifscCode='';
         bankNme='';
         accountType='';
         startDate='';
         endDate='';
        totalNoCredit=0;
        totalNoDebit=0;
         amb=0;
         amc=0;
        iwCheque='';
        owCheque='';
        totalNoEmi=0;
          totalNoEmiAmount=0;
          salaryConfirm=0;
        fileID='';
          index=0;
        }
    }

    

    

}