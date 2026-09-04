public with sharing class DealerDetailController {

    public static List<Loan_Application__c> loanApplcList;
    public static DealerDetailWrapper dealerDetailObj;

   
    public static List<Loan_Application__c> getLoanAppl(String loanApplId) {

        List<Loan_Application__c> loanApplLst = [SELECT id,RecordType.DeveloperName, Sourcing_channel__c, Source_Name__c, Purchase_City__c, toLabel(Product__c) prod, Product__c, Vehicle_use__c, Dealer_Master__c,Collateral_Type__c,
                                                        Dealer_Master__r.MFG__r.Name, Dealer_Master__r.Purchase_State__c, Dealer_Master__r.Purchase_City__c, Dealer_Master__r.Account_Name__c,
                                                        Dealer_Master__r.Outlet_Name__c, Dealer_Master__r.Account_Code__c, Dealer_Master__r.Category__c,
                                                        Dealer_Master__r.Dealer_Class__c, Dealer_Master__r.Dealer_Type__c, Dealer_Master__r.Phone,
                                                        Dealer_Master__r.Email__c, Dealer_Master__r.Bank_Name__c, Dealer_Master__r.Benificiary_Account_Number__c,
                                                        Dealer_Master__r.IFSC_Code__c, Dealer_Master__r.PDD_RC__c, Dealer_Master__r.Collection__c,
                                                        Dealer_Master__r.RC_Limit_Count__c, Dealer_Master__r.RC_Limit_Used_Count__c, Dealer_Master__r.RC_Limit_Amount__c,
                                                        Sourcing_Channel_Name__r.Dealer_Class__c,
                                                        Dealer_Master__r.RC_Limit_Used_Amount__c, Sourcing_Channel_Name__r.Account_Name__c, Dealer_Channel__c, Dealer_Master__r.Name, Outlet_Name__c, Outlet_Name__r.Name, Outlet_Name__r.Outlet_Name__c, Purchase_State__c,
                                                        Sourcing_Channel_Name__r.RC_Limit_Count__c, Sourcing_Channel_Name__r.RC_Limit_Used_Count__c, Sourcing_Channel_Name__r.RC_Limit_Amount__c, 
                                                        Sourcing_Channel_Name__r.RC_Limit_Used_Amount__c, Sourcing_Channel_Name__r.RC_Balance_Limit_Amount__c, Sourcing_Channel_Name__r.RC_Balance_Limit_Count__c,
                                                            (SELECT id
                                                            FROM Applicants__r)                                                          
                                                FROM Loan_Application__c
                                                WHERE id=: loanApplId WITH SECURITY_ENFORCED]; //R2 Added Collateral_Type__c field in query 
        return loanApplLst;
    }

    @AuraEnabled
    public static DealerDetailWrapper dealerDetailHandler(String loanApplId) {

        dealerDetailObj = new DealerDetailWrapper();
        loanApplcList = getLoanAppl(loanApplId).size() > 0 ? getLoanAppl(loanApplId) : new List<Loan_Application__c>();
        Loan_Application__c loanApplRec = loanApplcList.size() > 0 ? loanApplcList[0] : new Loan_Application__c();
        dealerDetailObj.loanApp = loanApplRec;
        Set<String> products = new Set<String>();
        products.add('ALL');
        if(loanApplRec.RecordType.DeveloperName == 'Four_Wheeler'){
            products.add('4W');
        }else if(loanApplRec.RecordType.DeveloperName == 'Two_Wheeler'){
            products.add('2W');
        }
        else if(loanApplRec.RecordType.DeveloperName == 'TRACTOR'){
            products.add('TRACTOR');
        }
        List<Account> accounts = [SELECT Id,Name,Purchase_State__c FROM Account Where Product__c IN: products AND Purchase_State__c != null ORDER BY Purchase_State__c ASC];
        List<SelectOptionWrapper> optionWrapper = new List<SelectOptionWrapper>();
        Set<String> setPurchaseState = new Set<String>();
        for(Account acc : accounts){
            String purchaseStateCase = acc.Purchase_State__c.touppercase(); 
            if(!setPurchaseState.contains(purchaseStateCase)){
            optionWrapper.add(new SelectOptionWrapper(acc.Purchase_State__c,acc.Purchase_State__c));
            }
            setPurchaseState.add(purchaseStateCase);
        }
        dealerDetailObj.purchaseStateOptions = optionWrapper;


        if(String.isNotBlank(loanApplRec.Dealer_Master__c)) {
            fetchMFg();
            filldetailsFromLoan(loanApplRec);
            fetchdetailFromPayment(loanApplId, loanApplRec.Dealer_Master__c);
            dealerDetailObj.isFetchFromLoanAppl = true;
            return dealerDetailObj;
        }
        else {
            dealerDetailObj.isFetchFromLoanAppl = false;
            fetchMFg();
            //added when Dealer Master == Null
            DisplayValueOnUIWrapper displayValueObj  = new DisplayValueOnUIWrapper();
        displayValueObj.sourcingChannel          = loanApplRec.Sourcing_channel__c;
        
        Collateral__c coll = [Select Make__c from Collateral__c where (RecordType.DeveloperName = 'New' or RecordType.DeveloperName = 'Used_Cash_on_Wheels') AND Loan__c =: loanApplId AND Is_Deleted__c = false limit 1];
       // displayValueObj.mfg                      = loanApplRec.Dealer_Master__r.MFG__r.Name;
        displayValueObj.mfg                      = coll.Make__c;
            dealerDetailObj.dealerValues = new DisplayValueOnUIWrapper();
        dealerDetailObj.dealerValues = displayValueObj;
            return dealerDetailObj;
        }   
    }

    public static void fetchMFg() {

        Map<String, List<String>> productVsMfgMap        = new Map<String, List<String>>();
        String productLabel                              = String.valueOf(loanApplcList[0].get('prod'));
        String productApiName                            = Utility.getProductTypeName(loanApplcList[0].Product__c);

        String fields = 'MFG__c, MFG__r.Name, toLabel(Product__c), Purchase_State__c, Purchase_City__c, Sourcing_channel__c, Vehicle_use__c'; 
       //String whereClause    = ' WHERE (RecordType.Name = \'Dealer\' AND Product__c = :productApiName)';
         String whereClause;
         if(productApiName == 'Commercial'){
              whereClause = ' WHERE RecordType.Name = \'Dealer\' AND (Product__c IN (\'CV\', \'Car Taxi\', \'4W\', \'3W\', \'CV - All\') OR Product__c = \'ALL\')';
        }else{
            whereClause    = ' WHERE (RecordType.Name = \'Dealer\' AND Product__c = :productApiName)';
            }
        System.debug('whereClause-->' +whereClause);
        List<Account> acctList = (List<Account>) genericQuery('Account', fields, whereClause);             

        for(Account accRec: acctList) {
            if(accRec.Product__c == productApiName) {
                if(productVsMfgMap.containsKey(productApiName)) {
                    List<String> val = productVsMfgMap.get(productApiName);
                    val.add(accRec.MFG__r.Name);
                    productVsMfgMap.put(productApiName, val);
                }
                else {
                    productVsMfgMap.put(productApiName, new List<String>{accRec.MFG__r.Name});
                }
            }
        }
        dealerDetailObj.productVsMfg = new Map<String, List<String>>();
        dealerDetailObj.productVsMfg = productVsMfgMap;
    }

    public static List<Sobject> genericQuery(String sobjectName, String fields, String whereClause) {
        String productApiName             = Utility.getProductTypeName(loanApplcList[0].Product__c);
        String query = 'SELECT id,' + fields + ' FROM ' + sobjectName + whereClause + ' WITH SECURITY_ENFORCED';
        system.debug('query-- '+query);
        List<SObject> fetchRecordsList = Database.query(query);
        return fetchRecordsList;
    }
    
    @AuraEnabled
    public static DealerDetailWrapper genericFetchForDealer(Object params, String loanApplId) {
        dealerDetailObj = new DealerDetailWrapper();
        loanApplcList = getLoanAppl(loanApplId).size() > 0 ? getLoanAppl(loanApplId) : new List<Loan_Application__c>();
        loanApplcList = loanApplcList.size() > 0 ? loanApplcList : new List<Loan_Application__c>();
        dealerDetailObj.loanApp = loanApplcList[0];

        String fields = 'Account_Code__c, Category__c, Dealer_Class__c, Dealer_Type__c, Phone, Email__c, Bank_Name__c, Benificiary_Account_Number__c, IFSC_Code__c,' +
                         ' RC_Limit_Count__c, RC_Limit_Used_Count__c, RC_Limit_Amount__c, RC_Limit_Used_Amount__c, PDD_RC__c, Collection__c ,'+
                         ' (Select id, Name, Type__c, PAN__c FROM Contacts)';

        String whereClaus = ' WHERE (RecordType.Name = \'Dealer\' AND ';
        Map<String, Object> fldName = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(params));   

        for(String fld : fldName.keyset()) {                  
            system.debug(fld + ' : ' + fldName.get(fld));
            if(fldName.get(fld) == 'Commercial'){
                whereClaus += fld + ' IN (\'CV\', \'Car Taxi\', \'4W\', \'3W\', \'CV - All\',\'ALL\') AND ';
            }else{
                if(fld == 'Product__c'){
                    //R2-2708
                    whereClaus += ' ( ' + fld + '=\'' +fldName.get(fld) + '\' OR '+ ' Product__c = \'ALL\' ' +' ) AND ';  
                    // R2-2708
                }
                else{
                    whereClaus += fld + '=\'' +fldName.get(fld) + '\' AND ';  
                }
                 
            }
           
        }
        whereClaus = whereClaus.removeEnd(' AND ') + ') ';
       
        System.debug('whereClaus-->' +whereClaus);
        List<Account> genericList = (List<Account>) genericQuery('Account', fields, whereClaus);
        dealerDetailObj.dealerValues = new DisplayValueOnUIWrapper();
        if(!genericList.isEmpty()){
            Account acct                 =  genericList[0];
        dealerDetailObj.dealerValues =  genDetailsFromAccount(acct);
        dealerDetailObj.relatedContactsOfAccount = new List<Contact>();
        dealerDetailObj.relatedContactsOfAccount = acct.Contacts;
        return dealerDetailObj; 
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String saveDealerAndUpdatLoanAppl(Loan_Application__c loanApplctn, Payment__c paymentRec, String scenario) {
        if(loanApplctn != null && loanApplctn.Id != null) {
            update loanApplctn;
        }
        if(paymentRec != null) {
            paymentRec.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Dealer Payout').getRecordTypeId();

            if(scenario == 'save') {
                insert paymentRec;
            }
            else if(scenario == 'edit'){
                update paymentRec;
            }     
            return 'success';
        }
        return null;
    }
    

    public static void filldetailsFromLoan(Loan_Application__c loanApplRec) {
        DisplayValueOnUIWrapper displayValueObj  = new DisplayValueOnUIWrapper();
        displayValueObj.sourcingChannel          = loanApplRec.Sourcing_channel__c;
        
        Collateral__c coll = [Select Make__c from Collateral__c where (RecordType.DeveloperName = 'New' or RecordType.DeveloperName = 'Used_Cash_on_Wheels') AND Loan__c =: loanApplRec.id AND Is_Deleted__c = false limit 1 ];
       // displayValueObj.mfg                      = loanApplRec.Dealer_Master__r.MFG__r.Name;
        displayValueObj.mfg                      = coll.Make__c;
        displayValueObj.purchaseState            = loanApplRec.Dealer_Master__r.Purchase_State__c;
        displayValueObj.purchaseCity             = loanApplRec.Dealer_Master__r.Purchase_City__c; 
        displayValueObj.dealerName               = loanApplRec.Dealer_Master__r.Account_Name__c; 
        displayValueObj.outletName               = loanApplRec.Outlet_Name__r.Outlet_Name__c; 
        displayValueObj.dealerCode               = loanApplRec.Dealer_Master__r.Account_Code__c; 
        displayValueObj.category                 = loanApplRec.Dealer_Master__r.Category__c; 
        displayValueObj.dealerClass              = loanApplRec.Dealer_Master__r.Dealer_Class__c; 
        displayValueObj.dealerType               = loanApplRec.Dealer_Master__r.Dealer_Type__c; 
        displayValueObj.phoneNumber              = loanApplRec.Dealer_Master__r.Phone; 
        displayValueObj.email                    = loanApplRec.Dealer_Master__r.Email__c; 
        displayValueObj.bankName                 = loanApplRec.Dealer_Master__r.Bank_Name__c; 
        displayValueObj.benificiaryAccountNumber = loanApplRec.Dealer_Master__r.Benificiary_Account_Number__c; 
        displayValueObj.ifscCode                 = loanApplRec.Dealer_Master__r.IFSC_Code__c;
        displayValueObj.pddRcPercent             = loanApplRec.Dealer_Master__r.PDD_RC__c; 
        displayValueObj.collectionPercent        = loanApplRec.Dealer_Master__r.Collection__c;
        // Mapping with Sourcing channel 3764
        displayValueObj.rcLimitCount             = loanApplRec.Sourcing_Channel_Name__r.RC_Limit_Count__c; 
        displayValueObj.rcLimitUsedCount         = loanApplRec.Sourcing_Channel_Name__r.RC_Limit_Used_Count__c;
        displayValueObj.rcLimitAmount            = loanApplRec.Sourcing_Channel_Name__r.RC_Limit_Amount__c; 
        displayValueObj.rcLimitUsedAmount        = loanApplRec.Sourcing_Channel_Name__r.RC_Limit_Used_Amount__c;
        displayValueObj.balRcLimitCount          = loanApplRec.Sourcing_Channel_Name__r.RC_Balance_Limit_Count__c;
        dealerDetailObj.dealerValues = new DisplayValueOnUIWrapper();
        dealerDetailObj.dealerValues = displayValueObj;
    }

    public static void fetchdetailFromPayment(String loanApplId, String dealerMstrId) {
        List<Payment__c> paymentRecList = [SELECT id, Sourcing_Channel__c, Source_Name__c, Source_Channel_Payout__c, Source_Channel_Payout_Type__c, Source_Payout_amt__c,
                                          Dealer_Payout__c, Dealer_Payout_Type__c, Dealer_Payout_amt__c, DSE_Payout__c, DSM_Payout__c, DSE__c, DSE__r.Name, DSE__r.PAN__c,
                                          DSM__c, DSM__r.Name, DSM__r.PAN__c, Loan_Application__c
                                          FROM Payment__c 
                                          WHERE Loan_Application__c =: loanApplId LIMIT 1];
                                         
        if(paymentRecList.size() > 0) {
            Payment__c paymentRec = paymentRecList[0];
            dealerDetailObj.populateVal   = populateValFromPaymentObj(paymentRec);
            dealerDetailObj.dseNamePanList = new List<dse>();
            dealerDetailObj.dsmNamePanList = new List<dsm>();
            
            PopulateValues popValObject1   = populateValFromRelContact(dealerMstrId);
          //  dealerDetailObj.dseNamePanList = new List<dse>();
          //  dealerDetailObj.dsmNamePanList = new List<dsm>();
            dealerDetailObj.dseNamePanList = popValObject1.dseNamePanLst;
            dealerDetailObj.dsmNamePanList = popValObject1.dsmNamePanLst;
            system.debug('dealerDetailObj.populateVal iinside paymentRecList--> '+Json.serialize(dealerDetailObj.populateVal));
        }
        else{
            dealerDetailObj.populateVal = populateValFromRelContact(dealerMstrId);
            system.debug('dealerDetailObj.populateVal--> '+Json.serialize(dealerDetailObj.populateVal));
        }                                                             
    }

    public static PopulateValues populateValFromRelContact(String dealerMstrId) {
        List<Contact> contList = [SELECT id, Name, PAN__c, Type__c
                                 FROM Contact where accountId = : dealerMstrId];
        
                                 system.debug('contList--> '+Json.serialize(contList));
        PopulateValues popValObject  = new PopulateValues();
        popValObject.sourceChannelPayoutType = 'Full';
        popValObject.dealerPayoutType = 'Full';

        popValObject.dseNamePanLst = new List<Dse>();
        popValObject.dsmNamePanLst    = new List<Dsm>();

        for(Contact contRec : contList) {
            if(contRec.Type__c == 'DSE') {
                Dse dseObj  = new Dse();
                dseObj.id   = contRec.id;
                dseObj.name = contRec.Name;
                dseObj.pan  = contRec.PAN__c;
                popValObject.dseNamePanLst.add(dseObj);
            }
            else if(contRec.Type__c == 'DSM') {
                Dsm dsmObj  = new Dsm();
                dsmObj.id   = contRec.id;
                dsmObj.name = contRec.Name;
                dsmObj.pan  = contRec.PAN__c;     
                popValObject.dsmNamePanLst.add(dsmObj);
            }
        }
        return popValObject;
    }
     // R2 -1816|| START  method to check whether Body funding input required or not
    @AuraEnabled
    public static Boolean checkBodyFundingRequired(String manufacture ,String purchaseCity, String purchaseState ,String dealerChannel ,String product ){
       List<Account> accList = [SELECT id,name, Account_Name__c,Purchase_City__c, MFG__r.Name, Product__c,Purchase_State__c,Dealer_Class__c from Account  
                                WHERE MFG__r.Name=:manufacture AND (Product__c='ALL' OR Product__c=:product ) AND Purchase_State__c=:purchaseState AND Dealer_Class__c=:dealerChannel WITH SECURITY_ENFORCED];
            if(accList!=null && !accList.isEmpty()){
                return true;
            }else{
                return false;
            }                             
    }

    //R2 method to insert dealer record under dealer master outlet issue,product mapping and ifsc mapping
    @AuraEnabled
    public static void dealerSave(Account dealerRecord,String Mfg,String strLoanId,String channel){
        try {
            
            System.debug('Mfg-->' +Mfg);
            System.debug('dealerRecord-->' +dealerRecord);
            //Dealer Record Type
            Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
            //Outlet Record Type
            Id outletRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Outlet').getRecordTypeId();
            Account accObj = new Account();
            accObj = dealerRecord;
            accObj.Name = accObj.Account_Name__c;
            accObj.RecordTypeId = dealerRecordTypeId;
            accObj.RoCreated__c = true; //identifer for Ro Created
            //accObj.Product__c = 'CE';
          
            if(String.isNotBlank(Mfg)){
                MMV_Master__c makeInstance = [SELECT id,Name from MMV_Master__c where RecordType.DeveloperName = 'Make' AND Name =:Mfg LIMIT 1 ];
                if(makeInstance!=null){
                    accObj.MFG__c = makeInstance.Id;
                }
            }
            //Product i need to add CE value and bank name ifsc name validations is pending and outlet record creation is pending 
            if(Schema.sObjectType.Account.isUpdateable()){
                upsert accObj;
                System.debug('accObj-->' +accObj);
               
                //Outlet Creation
                Account outletObj = new Account();
                if(String.isNotBlank(accObj.Outlet_Name__c)){
                    outletObj.Name = accObj.Outlet_Name__c;
                    outletObj.Account_Name__c = accObj.Outlet_Name__c;
                    outletObj.Outlet_Name__c = accObj.Outlet_Name__c;
                    outletObj.RecordTypeId = outletRecordTypeId;
                    outletObj.ParentId = accObj.Id;
                    if(Schema.sObjectType.Account.isUpdateable()){
                     upsert outletObj;
                    }
                    
                }

                 // Loan Dealer Master Update
                 Loan_Application__c loanInstance = new Loan_Application__c();
                 loanInstance.Id = strLoanId;
                 loanInstance.Dealer_Master__c = accObj.Id;
                 loanInstance.Dealer_Channel__c = channel;
                 loanInstance.Purchase_City__c = accObj.Purchase_City__c;
                 loanInstance.Purchase_State__c = accObj.Purchase_State__c;
                 loanInstance.Outlet_Name__c = outletObj.Id;
                 if(Schema.sObjectType.Loan_Application__c.isUpdateable()){
                 update loanInstance;
                 }
            }
        } catch (Exception e) {
            System.debug('lineNumerb-->' +e.getLineNumber());
           // throw new AuraHandledException(e.getMessage());
        }
    }
    // R2 -1816|| END 

    public static PopulateValues populateValFromPaymentObj(Payment__c paymentRecData) {
        system.debug('paymentRecData-- '+JSON.serialize(paymentRecData));
        PopulateValues popValObj          = new PopulateValues();
        popValObj.Id                      = paymentRecData.Id;
        popValObj.loanAppId               = paymentRecData.Loan_Application__c;
        popValObj.sourcingChannel         = paymentRecData.Sourcing_Channel__c;
        popValObj.sourceName              = paymentRecData.Source_Name__c;
        popValObj.sourceChannelPayout     = paymentRecData.Source_Channel_Payout__c;
        popValObj.sourceChannelPayoutType = paymentRecData.Source_Channel_Payout_Type__c;
        popValObj.sourcePayoutAmt         = paymentRecData.Source_Payout_amt__c;
        popValObj.dealerPayout            = paymentRecData.Dealer_Payout__c;
        popValObj.dealerPayoutType        = paymentRecData.Dealer_Payout_Type__c;
        popValObj.dealerPayoutAmt         = paymentRecData.Dealer_Payout_amt__c;
        popValObj.dsePayout               = paymentRecData.DSE_Payout__c;
        popValObj.dsmPayout               = paymentRecData.DSM_Payout__c;
        popValObj.dse                     = paymentRecData.DSE__c;
        popValObj.dsm                     = paymentRecData.DSM__c;
        popValObj.dseNamePanLst          = new List<Dse>();

        Dse dseObj                        = new Dse();
        dseObj.id                         = paymentRecData.DSE__c;
        dseObj.name                       = paymentRecData.DSE__r.Name;
        dseObj.pan                        = paymentRecData.DSE__r.PAN__c;       
        popValObj.dseNamePanLst.add(dseObj);

        Dsm dsmObj                        = new Dsm();
        dsmObj.id                         = paymentRecData.DSM__c;
        dsmObj.name                       = paymentRecData.DSM__r.Name;
        dsmObj.pan                        = paymentRecData.DSM__r.PAN__c;       
        popValObj.dsmNamePanLst          = new List<Dsm>();
        popValObj.dsmNamePanLst.add(dsmObj);
        system.debug('popValObj-- '+JSON.serialize(popValObj));
        return  popValObj;   
    }

    public static DisplayValueOnUIWrapper genDetailsFromAccount(Account acct) {
        DisplayValueOnUIWrapper displayValueObj  = new DisplayValueOnUIWrapper(); 
        displayValueObj.category                 = acct.Category__c; 
        displayValueObj.dealerClass              = acct.Dealer_Class__c; 
        displayValueObj.dealerType               = acct.Dealer_Type__c; 
        displayValueObj.dealerCode               = acct.Account_Code__c; 
        displayValueObj.phoneNumber              = acct.Phone; 
        displayValueObj.email                    = acct.Email__c; 
        displayValueObj.bankName                 = acct.Bank_Name__c; 
        displayValueObj.benificiaryAccountNumber = acct.Benificiary_Account_Number__c; 
        displayValueObj.ifscCode                 = acct.IFSC_Code__c;
        displayValueObj.pddRcPercent             = acct.PDD_RC__c; 
        displayValueObj.collectionPercent        = acct.Collection__c;
        displayValueObj.rcLimitCount             = acct.RC_Limit_Count__c; 
        displayValueObj.rcLimitUsedCount         = acct.RC_Limit_Used_Count__c;
        displayValueObj.rcLimitAmount            = acct.RC_Limit_Amount__c; 
        displayValueObj.rcLimitUsedAmount        = acct.RC_Limit_Used_Amount__c;

        return displayValueObj;
    }


    public class DealerDetailWrapper {
        @AuraEnabled public Loan_Application__c loanApp;
        @AuraEnabled public PopulateValues populateVal;
        @AuraEnabled public DisplayValueOnUIWrapper dealerValues;
        @AuraEnabled public Map<String, List<String>> productVsMfg;
        @AuraEnabled public Boolean isFetchFromLoanAppl;
        @AuraEnabled public List<Contact> relatedContactsOfAccount;
        @AuraEnabled public List<Dse> dseNamePanList;
        @AuraEnabled public List<Dsm> dsmNamePanList;
        @AuraEnabled public List<SelectOptionWrapper> purchaseStateOptions;
    }

    public class PopulateValues {
        @AuraEnabled public String sourcingChannel;
        @AuraEnabled public String sourceName;
        @AuraEnabled public String sourceChannelPayout;
        @AuraEnabled public String sourceChannelPayoutType;
        @AuraEnabled public String sourcePayoutAmt;
        @AuraEnabled public String dealerPayout;
        @AuraEnabled public String dealerPayoutType;
        @AuraEnabled public String dealerPayoutAmt;
        @AuraEnabled public String dsePayout;
        @AuraEnabled public String dsmPayout;
        @AuraEnabled public String dse;
		@AuraEnabled public String dsm;
        @AuraEnabled public List<Dse> dseNamePanLst;
        @AuraEnabled public List<Dsm> dsmNamePanLst;
        @AuraEnabled public String loanAppId;		
		@AuraEnabled public String Id;
    }

    public class Dse {
        @AuraEnabled public String name;
        @AuraEnabled public String pan;
        @AuraEnabled public String id;
    }

    public class Dsm {
        @AuraEnabled public String name;
        @AuraEnabled public String pan;
        @AuraEnabled public String id;
    }

    public class DisplayValueOnUIWrapper {
        @AuraEnabled public String sourcingChannel;
        @AuraEnabled public String mfg;
        @AuraEnabled public String purchaseState;
        @AuraEnabled public String purchaseCity;
        @AuraEnabled public String dealerName;
        @AuraEnabled public String outletName;
        @AuraEnabled public String dealerCode;
        @AuraEnabled public String category;
        @AuraEnabled public String dealerClass;
        @AuraEnabled public String dealerType;
        @AuraEnabled public String phoneNumber;
        @AuraEnabled public String email;
        @AuraEnabled public String bankName;
        @AuraEnabled public String benificiaryAccountNumber;
        @AuraEnabled public String ifscCode;
        @AuraEnabled public Decimal pddRcPercent;
        @AuraEnabled public Decimal collectionPercent;
        @AuraEnabled public Decimal rcLimitCount;
        @AuraEnabled public Decimal rcLimitUsedCount;
        @AuraEnabled public Decimal rcLimitAmount;
        @AuraEnabled public Decimal rcLimitUsedAmount;
        @AuraEnabled public Decimal balRcLimitCount;

    }
    public class SelectOptionWrapper {
        @AuraEnabled public string value;
        @AuraEnabled public string label;
        
        public SelectOptionWrapper(string value, string label) {
            this.value = value;
            this.label = label;
        }
    }
}