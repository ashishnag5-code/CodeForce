public with sharing class EMIScheduleAPIHandler {
    
    public static List<String> generateRequest(Object reqParam, Integration_Master__c objIntMapper, Loan_Application__c loanApp){
        Date todaysDate = Date.today();
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        EMIScheduleRequestWrapper scheduleRequestWrapper = new EMIScheduleRequestWrapper();
        scheduleRequestWrapper.UserModifiedStageParameter = new List<Object>();

        scheduleRequestWrapper.RequestId = String.valueOf(paramsMap.get('RefId'));
        scheduleRequestWrapper.TermMonths = Integer.valueOf(paramsMap.get('TermMonths'));
        scheduleRequestWrapper.ProductCode = Integer.valueOf(paramsMap.get('ProductCode'));
        scheduleRequestWrapper.RateChartCode = Integer.valueOf(paramsMap.get('RateChartCode'));
         //objIntMapper.Apiuser__c;
        scheduleRequestWrapper.ScheduleTypeCode = Integer.valueOf(paramsMap.get('ScheduleTypeCode'));
        scheduleRequestWrapper.AccountVarianceRate = (Decimal)(paramsMap.get('AccountVarianceRate'));
        
        //Added by Samridhi to make API work on holiday - To be commented
        //Date emiDate = Date.newInstance(2023, 06, 30);
        //scheduleRequestWrapper.GenerationDate=String.valueOf(emiDate);
        
        //Commented by Samridhi to make API work on holiday - To be uncommented
        scheduleRequestWrapper.GenerationDate=String.valueOf(todaysDate);
       // 2024-01-08
         /* start - Updated the date for testing R2 */
        // Date genDate = Date.newInstance(2024, 01, 08);
        //scheduleRequestWrapper.GenerationDate=String.valueOf(genDate);
            /* End - Updated the date for testing R2 */
        scheduleRequestWrapper.InterestVarianceType = 'A';
        if(paramsMap.keySet().contains('SessionId')){
            scheduleRequestWrapper.SessionId = Integer.valueOf(paramsMap.get('SessionId'));
            scheduleRequestWrapper.OriginatingChannel = String.valueOf(paramsMap.get('DisbursementScheduleChannel'));//'LOS';
            scheduleRequestWrapper.DisbursementDate = String.valueOf(loanApp.Disbursement_Date__c);
            scheduleRequestWrapper.AccountId = Long.valueOf(loanApp.LAN__c);
        }else{
            scheduleRequestWrapper.Channel = String.valueOf(paramsMap.get('EMIScheduleChannel'));//'HFT';
        }
        
        if(loanApp.Schedule_Type__c=='VPI'){
            scheduleRequestWrapper.VariableEPISchedule = new List<VariableEPIScheduleWrapper>();
            List<EMI_Schedule__c> emiList = [select id, name, stage_number__c, installment_number__c, installment_amount__c from emi_schedule__c where loan_application__c=:loanApp.Id and isInactive__c=false AND RecordType.DeveloperName='VPI' order by stage_number__c];
            for(EMI_Schedule__c schedule: emiList){
                VariableEPIScheduleWrapper newWrapper = new VariableEPIScheduleWrapper();
                newWrapper.StageNumber=(Integer)schedule.stage_number__c;
                newWrapper.InstallmentNumberTo=(Integer)schedule.installment_number__c;
                newWrapper.InstallmentAmount=schedule.installment_amount__c;
                scheduleRequestWrapper.VariableEPISchedule.add(newWrapper);
            }   
        }

        List<String> ioiProducts = System.Label.IOI_Products.split(',');
        if(ioiProducts.contains(loanApp.Product__c) && loanApp.Schedule_Name__c.contains('Equated')){
            UserModifiedStageParameterWrapper stageParam1 = new UserModifiedStageParameterWrapper();
            stageParam1.StageNumber=1;
            stageParam1.NumberOfInterestRepayments=0;
            scheduleRequestWrapper.UserModifiedStageParameter.add(stageParam1);
            UserModifiedStageParameterWrapper stageParam2 = new UserModifiedStageParameterWrapper();
            stageParam2.StageNumber=1;
            stageParam2.NumberOfPrincipalRepayments=getNumberOfPrincipalRepayments(loanApp);
            if(loanApp.EMI_Date__c!=null && loanApp.First_EMI_Date__c != null){
                stageParam2.FirstPrincipalRepaymentDate=String.valueOf(loanApp.First_EMI_Date__c);
                stageParam2.FirstInterestRepaymentDate=String.valueOf(loanApp.First_EMI_Date__c);
            }
            scheduleRequestWrapper.UserModifiedStageParameter.add(stageParam2);
        }else if(ioiProducts.contains(loanApp.Product__c) && loanApp.Schedule_Name__c.contains('Variable')){
            UserModifiedStageParameterWrapper stageParam1 = new UserModifiedStageParameterWrapper();
            stageParam1.StageNumber=1;
            stageParam1.NumberOfPrincipalRepayments=getNumberOfPrincipalRepayments(loanApp);
            scheduleRequestWrapper.UserModifiedStageParameter.add(stageParam1);
            UserModifiedStageParameterWrapper stageParam2 = new UserModifiedStageParameterWrapper();
            stageParam2.StageNumber=1;
            if(loanApp.EMI_Date__c!=null && loanApp.First_EMI_Date__c != null){
                stageParam2.FirstPrincipalRepaymentDate=String.valueOf(loanApp.First_EMI_Date__c);
                /*if(loanApp.RecordType.DeveloperName=='Commercial_Vehicle' || loanApp.RecordType.DeveloperName=='Construction_Equipment'){
                    stageParam2.FirstInterestRepaymentDate=String.valueOf(loanApp.First_EMI_Date__c);
                }*/
            }
            scheduleRequestWrapper.UserModifiedStageParameter.add(stageParam2);
        }else{
            UserModifiedStageParameterWrapper stageParam = new UserModifiedStageParameterWrapper();
            stageParam.StageNumber=1;
            stageParam.NumberOfPrincipalRepayments=getNumberOfPrincipalRepayments(loanApp);
            if(loanApp.EMI_Date__c!=null && loanApp.First_EMI_Date__c != null){
                stageParam.FirstPrincipalRepaymentDate=String.valueOf(loanApp.First_EMI_Date__c);
                stageParam.FirstInterestRepaymentDate=String.valueOf(loanApp.First_EMI_Date__c);
            }
            scheduleRequestWrapper.UserModifiedStageParameter.add(stageParam);
        }

        /*UserModifiedStageParameterWrapper stageParam = new UserModifiedStageParameterWrapper();
        stageParam.StageNumber=1;
        if(loanApp.EMI_Frequency__c=='MONTHLY'){
            stageParam.NumberOfPrincipalRepayments=scheduleRequestWrapper.TermMonths;
        }
        if(loanApp.EMI_Frequency__c=='QUARTERLY'){
            stageParam.NumberOfPrincipalRepayments=scheduleRequestWrapper.TermMonths/3;
        }
        if(loanApp.EMI_Frequency__c=='HALF YEARLY'){
            stageParam.NumberOfPrincipalRepayments=scheduleRequestWrapper.TermMonths/6;
        }commented in R2*/
        /*if(loanApp.EMI_Frequency__c=='MONTHLY'){
            stageParam.NumberOfPrincipalRepayments=scheduleRequestWrapper.TermMonths;
        }else if(loanApp.EMI_Frequency__c=='QUARTERLY' && loanApp.Schedule_Type__c=='VPI'){
            if(Math.mod(scheduleRequestWrapper.TermMonths,3) ==0){
                stageParam.NumberOfPrincipalRepayments=scheduleRequestWrapper.TermMonths/3;
            }else{
                stageParam.NumberOfPrincipalRepayments=Integer.valueOf((Math.floor(scheduleRequestWrapper.TermMonths)/3)+1);
            }
        }else if(loanApp.EMI_Frequency__c=='QUARTERLY' && loanApp.Schedule_Type__c=='EPI'){
            stageParam.NumberOfPrincipalRepayments=Integer.valueOf(Math.floor(scheduleRequestWrapper.TermMonths)/3);
        }else if(loanApp.EMI_Frequency__c=='HALF YEARLY' && loanApp.Schedule_Type__c=='VPI'){
            if(Math.mod(scheduleRequestWrapper.TermMonths,6) ==0){
                stageParam.NumberOfPrincipalRepayments=scheduleRequestWrapper.TermMonths/6;
            }else{
                stageParam.NumberOfPrincipalRepayments=Integer.valueOf((Math.floor(scheduleRequestWrapper.TermMonths/6))+1);
            }
            
        }else if(loanApp.EMI_Frequency__c=='HALF YEARLY' && loanApp.Schedule_Type__c=='EPI'){
            stageParam.NumberOfPrincipalRepayments=Integer.valueOf(Math.floor(scheduleRequestWrapper.TermMonths)/6);
        }moved to getNumberOfPrincipalRepayments method*/

        // if(loanApp.EMI_Date__c!=null && todaysDate.day()<Integer.valueOf(loanApp.EMI_Date__c)){
        //     Date newDate = Date.newInstance(todaysDate.year(),todaysDate.month(),Integer.valueOf(loanApp.EMI_Date__c));
        //     String newDateValue = String.valueOf(newDate);
        //     System.debug('newDateValue: '+newDateValue);
        //     stageParam.FirstPrincipalRepaymentDate=newDateValue;
        //     stageParam.FirstInterestRepaymentDate=newDateValue;
        // }else{
        //     Date newDate = Date.newInstance(todaysDate.year(),todaysDate.addMonths(1).month(),Integer.valueOf(loanApp.EMI_Date__c));
        //     String newDateValue = String.valueOf(newDate);
        //     System.debug('newDateValue: '+newDateValue);
        //     System.debug('newDateValue: '+String.valueOf(loanApp.First_EMI_Date__c));
        //     stageParam.FirstPrincipalRepaymentDate=newDateValue;
        //     stageParam.FirstInterestRepaymentDate=newDateValue;
        // }
        /*if(loanApp.EMI_Date__c!=null && loanApp.First_EMI_Date__c != null){
            stageParam.FirstPrincipalRepaymentDate=String.valueOf(loanApp.First_EMI_Date__c);
            stageParam.FirstInterestRepaymentDate=String.valueOf(loanApp.First_EMI_Date__c);
        }commented in R2*/
        //scheduleRequestWrapper.UserModifiedStageParameter.add(stageParam);commented in R2

        scheduleRequestWrapper.SanctionedAmount = (Decimal) (paramsMap.get('SanctionedAmount'));
        scheduleRequestWrapper.TransactionBranch = String.valueOf(paramsMap.get('TransactionBranch'));
        scheduleRequestWrapper.ReferenceNo =scheduleRequestWrapper.RequestId;

        lstString.add(JSON.serializePretty(scheduleRequestWrapper, false));  
        return lstString;
    }

    public static Integer getNumberOfPrincipalRepayments(Loan_Application__c loanApp){
        Integer noOfPrincipalRepayments;
        Integer tenure = Integer.valueOf(loanApp.Tenure__c);
        if(loanApp.EMI_Frequency__c=='MONTHLY'){
            noOfPrincipalRepayments=tenure;
        }else if(loanApp.EMI_Frequency__c=='QUARTERLY' && loanApp.Schedule_Type__c=='VPI'){
            if(Math.mod(tenure,3) ==0){
                noOfPrincipalRepayments=tenure/3;
            }else{
                noOfPrincipalRepayments=Integer.valueOf((Math.floor(tenure)/3)+1);
            }
        }else if(loanApp.EMI_Frequency__c=='QUARTERLY' && loanApp.Schedule_Type__c=='EPI'){
            noOfPrincipalRepayments=Integer.valueOf(Math.floor(tenure)/3);
        }else if(loanApp.EMI_Frequency__c=='HALF YEARLY' && loanApp.Schedule_Type__c=='VPI'){
            if(Math.mod(tenure,6) ==0){
                noOfPrincipalRepayments=tenure/6;
            }else{
                noOfPrincipalRepayments=Integer.valueOf((Math.floor(tenure/6))+1);
            }
            
        }else if(loanApp.EMI_Frequency__c=='HALF YEARLY' && loanApp.Schedule_Type__c=='EPI'){
            noOfPrincipalRepayments=Integer.valueOf(Math.floor(tenure)/6);
        }
        return noOfPrincipalRepayments;
    }

    @TestVisible
    public class EMIScheduleRequestWrapper{

        @AuraEnabled public String Channel {get;set;}
        @AuraEnabled public String ReferenceNo {get;set;}
        @AuraEnabled public String RequestId {get;set;}
        @AuraEnabled public Integer TermMonths {get;set;}
        @AuraEnabled public Integer ProductCode {get;set;}
        @AuraEnabled public Integer RateChartCode {get;set;}
        @AuraEnabled public Decimal AccountVarianceRate {get;set;}
        @AuraEnabled public String GenerationDate {get;set;}
        @AuraEnabled public String InterestVarianceType {get;set;}
        @AuraEnabled public Decimal SanctionedAmount {get;set;}
        @AuraEnabled public String TransactionBranch {get;set;}
        @AuraEnabled public Integer ScheduleTypeCode {get;set;}
        @AuraEnabled public List<Object> UserModifiedStageParameter {get;set;}
        public Integer SessionId;
        public String OriginatingChannel;
        public String DisbursementDate;
        public Long AccountId;
        @AuraEnabled public List<VariableEPIScheduleWrapper> VariableEPISchedule {get;set;}
    }


    @TestVisible
    public class VariableEPIScheduleWrapper{
        @AuraEnabled public Integer StageNumber {get;set;}
        @AuraEnabled public Integer InstallmentNumberTo {get;set;}
        @AuraEnabled public Decimal InstallmentAmount {get;set;}
    }

    @TestVisible
    public class UserModifiedStageParameterWrapper{
        @AuraEnabled public Integer StageNumber {get;set;}
        @AuraEnabled public Integer NumberOfPrincipalRepayments {get;set;}
        @AuraEnabled public Integer NumberOfInterestRepayments {get;set;}
        @AuraEnabled public String FirstInterestRepaymentDate {get;set;}
        @AuraEnabled public String FirstPrincipalRepaymentDate {get;set;}
       
    }

    @TestVisible
    public class EMIScheduleResponseWrapper{
        @AuraEnabled public String PostingDate {get;set;}
        @AuraEnabled public List<ResponseWrapper> Response {get;set;}
        @AuraEnabled public TransactionStatusWrapper TransactionStatus {get;set;}
    }

    @TestVisible
    public class RepaymentScheduleResponseWrapper{
        @AuraEnabled public TransactionStatusWrapper TransactionStatus {get;set;}
        @AuraEnabled public String SessionId{get;set;}
        @AuraEnabled public List<ResponseWrapper> RepaymentRecords {get;set;}
        public RepaymentScheduleResponseWrapper(){
            TransactionStatus = new TransactionStatusWrapper();
            SessionId = '';
            RepaymentRecords = new List<ResponseWrapper>();
        }
    }


    @TestVisible
    public class TransactionStatusWrapper{
        @AuraEnabled public String ResponseCode {get;set;}
        @AuraEnabled public String ResponseMessage {get;set;}
        @AuraEnabled public ExtendedErrorDetailsWrapper ExtendedErrorDetails {get;set;}
        public TransactionStatusWrapper(){
            ResponseCode = '';
            ResponseMessage = '';
            ExtendedErrorDetails = new ExtendedErrorDetailsWrapper();
        }

    }

    @TestVisible
    public class ExtendedErrorDetailsWrapper{
        @AuraEnabled public List<MessageWrapper> messages {get;set;}
        public ExtendedErrorDetailsWrapper(){
            messages = new List<MessageWrapper>();
        }

    }

    @TestVisible
    public class MessageWrapper{
        @AuraEnabled public String code {get;set;}
        @AuraEnabled public String message {get;set;}
        public MessageWrapper(){
            code = '';
            message = '';
        }
    }

    @TestVisible
    public class ResponseWrapper{
        @AuraEnabled public Integer StageNumber {get;set;}
        @AuraEnabled public Integer InstallmentCounter {get;set;}
        @AuraEnabled public String InstallmentStartDate {get;set;}
        @AuraEnabled public String InstallmentDate {get;set;}
        @AuraEnabled public Decimal InterestRate {get;set;}
        @AuraEnabled public Decimal PrincipalAmount {get;set;}
        @AuraEnabled public Decimal InterestAmount {get;set;}
        @AuraEnabled public Decimal SubsidyAmount {get;set;}
        @AuraEnabled public Decimal PremiumAmount {get;set;}
        @AuraEnabled public Decimal ServiceChargeAmount {get;set;}
        @AuraEnabled public Decimal CapitalizedAmount {get;set;}
        @AuraEnabled public Decimal InstallmentAmount {get;set;}
        @AuraEnabled public Decimal PrincipalBalanceAmount {get;set;}
        @AuraEnabled public Decimal TotalInstallmentAmount {get;set;}
        @AuraEnabled public Integer NumberOfDays {get;set;}       
    }
}