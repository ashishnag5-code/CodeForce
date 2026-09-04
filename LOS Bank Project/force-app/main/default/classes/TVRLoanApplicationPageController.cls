public with sharing class TVRLoanApplicationPageController {
    @AuraEnabled
    public static resultWrapper deleteTVR(Id tvrId){
        try { 
            resultWrapper resultWrapper =new resultWrapper();
            
            TVR__c tvr= new TVR__c();
            tvr.Id=tvrId;
            delete tvr;
            resultWrapper.isSuccess=true;
            resultWrapper.message ='Success';
            return resultWrapper;
            
        } catch (Exception e) {
            resultWrapper resultWrapper =new resultWrapper();
            resultWrapper.isSuccess=false;
            resultWrapper.message =e.getMessage();
            return resultWrapper;    
        }
    }
    @AuraEnabled
    public static ReturnWrapper fetchTVR(Id loanApplicationId){
        try {
            List < Map < String, String >> options = new List < Map < String, String >> ();
            ReturnWrapper response = new ReturnWrapper();
            List<RespWrapper> tvrOptionsList = new List<RespWrapper>();
            //resultWrapper resultWrapper =new resultWrapper();
            response.lstTvr=[Select Id,CreatedById,Employee_ID__c,Loan_Application__c,Mobile_Number__c,Name,Name_Of_Employee__c,
                             RecordTypeId,Remark__c,TVR_Date__c,TVR_Done_With__c  from 
                             TVR__c where Loan_Application__c=:loanApplicationId WITH SECURITY_ENFORCED];
            //String remarks = '';            
            for(Applicant__c objAppl:[Select Id,(Select Id,Source_Type__c,Address_Type__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,
                                                 District__c,Pincode__c,Stability__c from Addresses__r where Source_Type__c =''),
                                      (Select Id,RecordType.Name,Company_Name__c,Occupation__c,Monthly_Income__c from Applicant_Financials__r 
                                       where recordType.Name ='Financial Parent' limit 1),loan__r.Product__c,recordType.Name,Mobile_Number__c,Customer_Name__c,
                                       Type_Of_Employment__c , Risk_Category__c
                                      from Applicant__c where loan__c =:loanApplicationId and recordType.Name !='Nominee' and recordType.Name !='Additional Match' AND IsInactive__c = false]
             ){
                                          
                 RespWrapper tvrData = new RespWrapper();                      
                 tvrData.isTwoWheeler= objAppl.loan__r.Product__c =='10301' ? true :objAppl.loan__r.Product__c =='10302' ? true:objAppl.loan__r.Product__c =='10303'?true:false;
                 if(!string.isEmpty(objAppl.Customer_Name__c )){
                     //Commenting as code needs to be updated Yash 3577
                     tvrData.tvrOptionLabel = objAppl.Customer_Name__c;
                     tvrData.tvrOptionValue = objAppl.Mobile_Number__c;
                     
                     for(Address__c addressObject:objAppl.Addresses__r){
                         if(addressObject.Address_Type__c =='Current'){
                             String fullAddress = '';
                             if(!String.isEmpty(addressObject.Address_Line_1__c)){
                                 fullAddress=addressObject.Address_Line_1__c;
                             }
                             if(!String.isEmpty(addressObject.Address_Line_2__c)){
                                 fullAddress+='%';
                                 fullAddress+=addressObject.Address_Line_2__c;
                                 
                             }
                             if(!String.isEmpty(addressObject.Address_Line_3__c)){
                                 fullAddress+='%';
                                 fullAddress+=addressObject.Address_Line_3__c;
                                 
                             }
                             if(!String.isEmpty(addressObject.State__c)){
                                 fullAddress+='%';
                                 fullAddress+=addressObject.State__c;
                                 
                             }
                             if(!String.isEmpty(addressObject.District__c)){
                                 fullAddress+='%';
                                 fullAddress+=addressObject.District__c;
                                 
                             }
                             if(!String.isEmpty(addressObject.Pincode__c)){
                                 fullAddress+='%';
                                 fullAddress+=addressObject.Pincode__c;
                             }
                             system.debug('fullAddress>>>>'+fullAddress);
                             fullAddress = fullAddress.replaceAll('%',', ');
                             if(!String.isEmpty(fullAddress)){
                                 tvrData.remarks='Current Address : '+fullAddress;
                             }
                             if(!String.isEmpty(addressObject.Stability__c)){
                                 tvrData.remarks+='\n';
                                 tvrData.remarks+='Stability : '+addressObject.Stability__c;
                             }
                             
                             // objAddress.Stability__c
                         }
                         if(addressObject.Address_Type__c =='Office'){
                             if(!String.isEmpty(addressObject.Stability__c)){
                                 tvrData.remarks+='\n';
                                 tvrData.remarks+='Office Stability : '+addressObject.Stability__c;
                             }
                             // objAddress.Office stability
                         }
                     }
                     tvrData.remarks+='\n';
                     tvrData.remarks+='Employment Type :'+objAppl.Type_Of_Employment__c;
                     tvrData.remarks+='\n';
                     tvrData.remarks+='Risk Category :'+objAppl.Risk_Category__c;
                     for(Applicant_Financials_Details__c objFin:objAppl.Applicant_Financials__r){
                         if(!String.isEmpty(objFin.Company_Name__c)){
                             tvrData.remarks+='\n';
                             tvrData.remarks+='Company Name : '+objFin.Company_Name__c;
                         }
                         if(!String.isEmpty(objFin.Occupation__c)){
                             tvrData.remarks+='\n';
                             tvrData.remarks+='Occupation : '+objFin.Occupation__c;
                         }
                         if(objFin.Monthly_Income__c != null){
                             tvrData.remarks+='\n';
                             tvrData.remarks+='Monthly Income : '+objFin.Monthly_Income__c;
                         }
                     }
                 }
                 tvrOptionsList.add(tvrData);                
         }
            for(Collateral__c objColt: [Select Id,Make__c,Model__c,Variant__c, Vehicle_Usage__c from  Collateral__c  where 
                                        loan__c =:loanApplicationId limit 1]
            ){
                for(RespWrapper resp : tvrOptionsList)
                {
                    if(!String.isEmpty(objColt.Make__c)){
                        resp.remarks+='\n';
                        resp.remarks+='Make : '+objColt.Make__c;
                    }
                    if(!String.isEmpty(objColt.Model__c)){
                        resp.remarks+='\n';
                        resp.remarks+='Model : '+objColt.Model__c;
                    }
                    if(!String.isEmpty(objColt.Variant__c)){
                        resp.remarks+='\n';
                        resp.remarks+='Variant : '+objColt.Variant__c;
                    }
                    if(!String.isEmpty(objColt.Vehicle_Usage__c)){
                        resp.remarks+='\n';
                        resp.remarks+='End Usage : '+objColt.Vehicle_Usage__c;
                    }
                    
                }
                
            }
            response.tvrOptions = tvrOptionsList;
            response.todayDate=date.today();
            response.isSuccess=  true;
            response.message =response.lstTvr.size()>0 ? 'Success':'No Records Available';
            return response;
        } catch (Exception e) {
            ReturnWrapper resultWrapper =new ReturnWrapper();
            resultWrapper.isSuccess=false;
            resultWrapper.message =e.getMessage();
            return resultWrapper;
        }
    }
    
    public class ReturnWrapper{
        @AuraEnabled
        public List<RespWrapper> tvrOptions = new List<RespWrapper>();
        @AuraEnabled public Boolean isSuccess;
        @AuraENabled public Date todayDate;
        @AuraEnabled public String message;
        @AuraEnabled public List<TVR__c> lstTvr= new List<TVR__c>();
        
    }
    
    public class RespWrapper{
        @AuraEnabled public String tvrOptionLabel;
        @AuraEnabled public String tvrOptionValue;
        @AuraEnabled public String remarks;
        @AuraEnabled public Boolean isTwoWheeler;
        
    }
    
    public class resultWrapper{
        @AuraEnabled
        public List<TVR__c> lstTvr= new List<TVR__c>();
        @AuraEnabled
        public List < Map < String, String >> tvrDoneWithOptions = new List < Map < String, String >> ();
        
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String remarks;
        @AuraEnabled
        public Date todayDate;
        @AuraEnabled
        public Boolean isTwoWheeler;
        
        
    }
}