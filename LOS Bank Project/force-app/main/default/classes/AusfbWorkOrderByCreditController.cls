/**
 * @description       : Work Order related DML functions
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 10-29-2023
 * @last modified by  : Ajitesh
**/
public with sharing class AusfbWorkOrderByCreditController {

    public static final String WORK_ORDER_RECORD_TYPE_NAME = 'Work_Order';

    // Config Setup Literals
    public static final String CONFIG_PROFILE_EDITABLE = 'Work_Order_Profile_who_can_edit';
    public static final String CONFIG_STAGE_APPLICABLE = 'Work_Order_Stage_Applicable_On';
    public static final String CONFIG_PRODUCT_APPLICABLE = 'Work_Order_Product_Applicable';
    public static final String CONFIG_COMPONENT_NAME = 'Work Order';
    // Config Setup Literals
    
    /**
    * @description Inserting Work Order into DB
    * @author Ajitesh | 10-25-2023 
    * @param workOrders 
    **/
    @AuraEnabled
    public static List<Work_Order__c> upsertWorkOrders(List<Work_Order__c> workOrders, Id loanId){
        try {
            
            Database.upsert(workOrders, AccessLevel.USER_MODE);
            return getInitialData(loanId);

        } catch (Exception e) {
            System.debug('Something went wrong ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    /**
    * @description Getting created work orders
    * @author Ajitesh | 10-25-2023 
    * @param workOrders 
    * @return string 
    **/
    @AuraEnabled
    public static List<Work_Order__c> getInitialData(Id loanId){
        try {
            return [SELECT age_work_completed__c, Completion_date__c, Contract_start_date__c, Name_of_the_Principal__c, Nature_of_Work__c, S_No__c, Value_of_contract_Rs_in_lacs__c, Unexecuted_CIH_Rs_in_Lacs__c FROM Work_Order__c WHERE Loan_Application__c = :loanId  WITH SECURITY_ENFORCED ORDER BY S_No__c ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Getting the config data to setup up UI
    * @author Ajitesh | 10-24-2023 
    * @return List<AUSFB_Finance_WorkOrder_By_Credit_Config__mdt> 
    **/
   @AuraEnabled(cacheable=true)
   public static Map<String,Boolean> viewAndEditRight(Id loanId){
       try {
           
           Map<String, Boolean> viewEditRightStore = new Map<String, Boolean>{'visible' => true, 'editable' => true};

           Loan_Application__c loanApplicationData = [SELECT Product__c, Stage__c FROM Loan_Application__c WHERE Id = :loanId WITH SECURITY_ENFORCED];

           String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;

           for(AUSFB_Finance_WorkOrder_By_Credit_Config__mdt setupData : 
           [SELECT Order__c, MasterLabel, DeveloperName, Amount_Greater_Than_Equal_to_lacs__c, 
           Collateral_Type__c, Customer_Grade__c, Customer_Type__c, Metadata_Value__c, No_Of_Months_Date_Of_Establishment_more__c 
           FROM AUSFB_Finance_WorkOrder_By_Credit_Config__mdt WHERE Component__c = :CONFIG_COMPONENT_NAME WITH SECURITY_ENFORCED ORDER BY Order__c ASC
           ]
           ){

               // Product check
               if(setupData.DeveloperName == CONFIG_PRODUCT_APPLICABLE ){
                   boolean foundMatch = false;
                   for(String recordType : setupData.Metadata_Value__c.split(',')){
                       if(loanApplicationData.Product__c == recordType.trim()){
                           foundMatch = true;
                           break;
                       }
                   }
                   if(!foundMatch){
                       viewEditRightStore.put('visible', false);
                       break;
                   }
               }


               // Stage Check
               if(setupData.DeveloperName == CONFIG_STAGE_APPLICABLE ){
                   boolean foundMatch = false;
                   for(String stageType : setupData.Metadata_Value__c.split(',')){
                       if(loanApplicationData.Stage__c == stageType.trim()){
                           foundMatch = true;
                           break;
                       }
                   }
                   if(!foundMatch){
                       viewEditRightStore.put('visible', false);
                       break;
                   }
               }

               // Editable non editable based on Profiles
               if(setupData.DeveloperName == CONFIG_PROFILE_EDITABLE ){
                   boolean foundMatch = false;
                   for(String profileNameValue : setupData.Metadata_Value__c.split(',')){
                       if(profileName == profileNameValue.trim()){
                           foundMatch = true;
                           break;
                       }
                   }
                   if(!foundMatch){
                       viewEditRightStore.put('editable', false);
                   }
                   
               }
           }
           
           return viewEditRightStore;

       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }


}