public without sharing class VahanPdfController {
    public Id loanId{get;set;}
    private List<Lead> leadsToUpdate;
    public String renderingService {get; set;}
    public String renderedContentType {get; set;}
    
    public String Error {get;set;}
    public Id ContentDocumentId{get; set;}
    //public String checklist {get;set;}
    public static String pageBlockSectionCSS{get;set;}
    public static String tableRowStyle{get;set;}
    public static String tableHeadStyle{get;set;}
    public static String tableDataStyle{get;set;}
    public static String tableHeadDataStyle{get;set;}
    public static String cellData{get;set;}
    public static String labelData{get;set;}
    public static String tableStyle{get;set;}
    public Map < String, Object > metadataMap {get;set;}
    public string pdflink {get;set;}
    public Map < String, Object > noccMap {get;set;}
    public Map < String, Object > ownerMap {get;set;}
    public Map < String, Object > vehicleMap {get;set;}
    public Map < String, Object > financeMap {get;set;}
    public Map < String, Object > insuranceMap {get;set;}
    public List<ChallanWrapper> challanMapList {get;set;}
    
    public VahanPdfController(ApexPages.StandardController controller){
        List<Map < String, Object >> chList = new List<Map < String, Object >>();
        List<Integration_Checklist__c> ic =  new List<Integration_Checklist__c>();
        loanId = ApexPages.CurrentPage().getparameters().get('loanid')?.escapeHtml4();
        system.debug('@@loanId'+loanId);
        //checklist = ApexPages.CurrentPage().getparameters().get('checklist')?.escapeHtml4();
        if (loanId == null) {
            loanId = ApexPages.CurrentPage().getparameters().get('applicationid')?.escapeHtml4();
        }
        pageBlockSectionCSS='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; width:97%; overflow:auto; margin: 13px; !important;background-color:white; text-align:left';
        
        cellData='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; background-color: white; ; width:20% !important; color: #181818; font-size: 13px;padding: 0.5em;border-bottom: 1px solid rgb(240, 240, 240) !important;text-align: left;font-weight: normal;margin:5px';
        labelData='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; background-color: white; ;  width:13% !important; color: #181818; font-weight:bold; font-size: 12.5px;padding-left: 1.5em;padding-right: 0.5em; padding-top: 0.5em;margin:5px; padding-bottom: 0.5em;border-bottom: 1px solid rgb(240, 240, 240) !important;text-align: left;';//font-weight: bold; 
        tableStyle='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; width:100%;  ;border-collapse: collapse;';
        tableRowStyle='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; page-break-inside: avoid;  !important;';//background-color: #f2f3f3
        tableHeadStyle='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; white-space:normal; word-break:break-word;background-color: rgb(240, 240, 240); width:15% !important; word-wrap:break-word;text-align:right;color: #181818;font-size: 12.5px;font-weight: bold;padding: 0.5em;border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;';
        tableHeadDataStyle='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; white-space:normal; background-color: rgb(240, 240, 240); text-align:center;color: #181818;font-size: 12.5px;font-weight: bold;padding: 0.5em;border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;';
        tableDataStyle='font-family:"Segoe UI", Roboto, Helvetica,  sans-serif; text-align:center; border: 1px solid rgb(240, 240, 240) !important; background-color: white; color: #181818; font-size: 13px;font-weight: normal;padding: 0.5em;';//border-right: 0.1em solid white !important;border-bottom: 0.1em solid white !important;
        
        renderingService = 'pdf';
        renderedContentType = 'text/html';
        List<Integration_Master__c> imList = [Select ID FROM Integration_Master__c WHERE Name = 'Vahaan API' AND Active__c = TRUE limit 1];//:TODO pick active 
        system.debug('@@ic'+imList[0].id+loanId);
        
        ic  = [SELECT Id,Response__c FROM Integration_Checklist__c WHERE Integration_Master__c =: imList[0].Id AND Loan_Application__c =: loanId AND Status__c = 'Completed' ORDER BY createdDate DESC limit 1];
        /*if(ic != null && !ic.isEmpty() && checklist != null){
            ic = [SELECT Id,Response__c FROM Integration_Checklist__c WHERE Id =:checklist AND Status__c = 'Completed'];
        }*/
        system.debug('@@ic'+ic);
        if(ic != null && !ic.isEmpty() && ic[0].Response__c != null){
            Set<String> challanKeys = new Set<String>{'totalAmount','violatorName','challanNo','dlRcNumber','paymentSource','paymentDateAndTime','state','challanDate','transactionId','status'};
            Set<String> offenceKeys = new Set<String>{'penalty','offenceName'};
            Set<String> metaKeys = new Set<String>{'amountBeforePayment','amountAfterPayment','searchBy','user'};
            Set<String> noccKeys = new Set<String>{'officeCode','details'};            
            Set<String> ownerKeys = new Set<String>{'fathersName','presentAddress','ownersName','permanentAddress'};            
            Set<String> vehicleKeys = new Set<String>{'bodyType','horsePower','color','registrationDt','fuel','purchaseDt','noOfCylinders','fitnessUpto','manufacturer','cubicCap','seatingCap','vehicleClass','makerModel','panGirNo','ownerSrNo','saleAmount','engineNo','gvw','standingCap','wheelbase','registrationNo','chassisNo','dealer','wtUnladen','blackListDetails'};
            Set<String> financeKeys = new Set<String>{'address','financersName','withEffectFrom'};    
            Set<String> insuranceKeys = new Set<String>{'company','validity','type'}; 
                Map < String, Object > responseMap = new Map < String, Object >();
                if(ic[0].Response__c != null){
                    responseMap = (Map < String, Object > ) JSON.deserializeUntyped(ic[0].Response__c);
                }
           
            
            system.debug('@@responseMap'+responseMap);
            Map < String, Object > resultMap = (Map < String, Object > ) responseMap.get('result');
            if(resultMap != null && !resultMap.isEmpty()){
                if(resultMap.containsKey('metadata')){
                    Map < String, Object > metaNullMap = new Map < String, Object >();
                    Map < String, Object > metaMap = (Map < String, Object >)resultMap.get('metadata');
                    for(String s : metaKeys){
                        
                        if(metaMap.containsKey(s)){
                            Object value = metaMap.get(s);
                            if (value == null){
                                value ='';
                            }
                            metaNullMap.put(s,value);
                        }
                        else{
                            metaNullMap.put(s,'');
                        }
                        
                    }
                    metadataMap = metaNullMap;
                }
                if(resultMap.containsKey('pdf')){
                    pdflink = (String)resultMap.get('pdf');
                    system.debug('@@pdflink'+pdflink);
                }
                if(resultMap.containsKey('nocCcDetails')){
                    Map < String, Object > noccNullMap = new Map < String, Object >();
                    Map < String, Object > noMap = (Map < String, Object >)resultMap.get('nocCcDetails');
                    for(String s : noccKeys){
                        
                        if(noMap.containsKey(s)){
                            Object value = noMap.get(s);
                            if (value == null){
                                value ='';
                            }
                            noccNullMap.put(s,value);
                        }
                        else{
                            noccNullMap.put(s,'');
                        }
                        
                    }
                    noccMap = noccNullMap;
                }
                if(resultMap.containsKey('ownerDetails')){
                    Map < String, Object > ownerNullMap = new Map < String, Object >();
                    Map < String, Object > ownMap = (Map < String, Object >)resultMap.get('ownerDetails');
                    for(String s : ownerKeys){
                        
                        if(ownMap.containsKey(s)){
                            Object value = ownMap.get(s);
                            if (value == null){
                                value ='';
                            }
                            ownerNullMap.put(s,value);
                        }
                        else{
                            ownerNullMap.put(s,'');
                        }
                        
                    }
                    ownerMap = ownerNullMap;
                }
                if(resultMap.containsKey('vehicleDetails')){
                    Map < String, Object > vehicleNullMap = new Map < String, Object >();
                    Map < String, Object > vehMap = (Map < String, Object >)resultMap.get('vehicleDetails');
                    for(String s : vehicleKeys){
                        
                        if(vehMap.containsKey(s)){
                            Object value = vehMap.get(s);
                            if (value == null){
                                value ='';
                            }
                            vehicleNullMap.put(s,value);
                        }
                        else{
                            vehicleNullMap.put(s,'');
                        }
                        
                    }
                    vehicleMap = vehicleNullMap;
                }
                if(resultMap.containsKey('financersDetails')){
                    Map < String, Object > financeNullMap = new Map < String, Object >();
                    Map < String, Object > finMap = (Map < String, Object >)resultMap.get('financersDetails');
                    for(String s : financeKeys){
                        
                        if(finMap.containsKey(s)){
                            Object value = finMap.get(s);
                            if (value == null){
                                value ='';
                            }
                            financeNullMap.put(s,value);
                        }
                        else{
                            financeNullMap.put(s,'');
                        }
                        
                    }
                    financeMap = financeNullMap;
                }
                if(resultMap.containsKey('insuranceDetails')){
                    Map < String, Object > insuranceNullMap = new Map < String, Object >();
                    Map < String, Object > insMap = (Map < String, Object >)resultMap.get('insuranceDetails');
                    for(String s : insuranceKeys){
                        
                        if(insMap.containsKey(s)){
                            Object value = insMap.get(s);
                            if (value == null){
                                value ='';
                            }
                            insuranceNullMap.put(s,value);
                        }
                        else{
                            insuranceNullMap.put(s,'');
                        }
                        
                    }
                    insuranceMap = insuranceNullMap;
                }
                if(resultMap.containsKey('challanDetails')){
                    List<ChallanWrapper> cwList = new List<ChallanWrapper>();
                    List < Object > challanList = (List < Object > ) resultMap.get('challanDetails');
                    for(Object ob : challanList){
                        ChallanWrapper cw = new ChallanWrapper();
                        List<OffenceWrapper> owList = new List<OffenceWrapper>();
                        Map < String, Object > ch = (Map < String, Object > ) ob;
                        Map < String, Object > challanNullMap = new Map < String, Object >();
                        for(String s : challanKeys){
                            
                            if(ch.containsKey(s)){
                                Object value = ch.get(s);
                                if (value == null){
                                    value ='';
                                }
                                challanNullMap.put(s,value);
                            }
                            else{
                                challanNullMap.put(s,'');
                            }
                            
                        }
                        system.debug('@@challanNullMap'+challanNullMap);
                        cw.ChallanMap = challanNullMap;
                        List < Object > offenceList = (List < Object >) ch.get('offenceDetails');
                        for(Object off : offenceList){
                            Map < String, Object > offNullMap = new Map < String, Object >();
                            OffenceWrapper ow = new OffenceWrapper();
                            Map < String, Object > offence = (Map < String, Object > ) off;
                            for(String s : offenceKeys){
                                
                                if(offence.containsKey(s)){
                                    Object value = offence.get(s);
                                    if (value == null){
                                        value ='';
                                    }
                                    offNullMap.put(s,value);
                                }
                                else{
                                    offNullMap.put(s,'');
                                }
                                
                            }
                            ow.OffenceMap = offNullMap;
                            owList.add(ow);
                        }
                        cw.OffenceWrapperList = owList;
                        system.debug('@@ch'+ch);
                        cwList.add(cw);
                    }
                    
                    challanMapList = cwList;
                }
                
            }
            else{
                Error = 'Error in Vahaan Response';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Error));
            }
            
            //Map < String, Object > totalMap = (Map < String, Object > ) jsonBankMap.get('total');
        }
        else{
            Error = 'Error in Vahaan Response';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Error));
        }
        if (Error !=null && ApexPages.currentPage().getParameters().get('type') == 'download') {
            system.debug('hiiii');
            renderedContentType = 'vahan/pdf';
            renderedContentType += '#' + 'Vahan-Form.pdf';
            ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + 'Vahan-Form.pdf');
            
        }
    }
    public PageReference pageLoadAction(){
        
        return null;
    }
    
    
    Public class ChallanWrapper{
        public Map < String, Object > ChallanMap {get;set;}
        public List<OffenceWrapper> OffenceWrapperList {get;set;}
    }
    
    Public class OffenceWrapper{
        public Map < String, Object > OffenceMap {get;set;}
    }
    
}