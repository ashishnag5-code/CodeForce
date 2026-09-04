public with sharing class AUSFVehicleCEController {

    /*
@description :  Method to get Collateral Names based on the Attachment Part for CE
@param :  String loanId
@return : Boolean
*/
    @AuraEnabled
    public static List<String> getCollateralNames(String attachment){
        // R2-2647 - Default option coming without selecting Attachment
        if( String.isBlank( attachment ) ){
            return new String[0];
        }

        try {
            List<MMV_Master__c> collateralList = [SELECT Id, Collateral_Name__c,RecordType.Name,Active_in_Commercial__c,Attachment__c 
                                           FROM MMV_Master__c 
                                           WHERE Active_in_Commercial__c =true 
                                           AND Attachment__c=:attachment WITH SECURITY_ENFORCED];
            List<String> colNameList = new List<String>();                                            
            if(!collateralList.isEmpty()){
                for(MMV_Master__c mmvInstance : collateralList){
                    colNameList.add(mmvInstance.Collateral_Name__c);
                }
            } 
            
            if(!colNameList.isEmpty()){
                return colNameList;
            }else{
                return new List<String>();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /*
@description :  Method to get Collateral Names based on the Attachment Part for CE
@param :  String loanId
@return : Boolean
*/
    @AuraEnabled
    public static List<String> getCEMakeNames(String collateralId,String attachmentValue){
        try {
            String recordTypeIdValue = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get('Variant').getRecordTypeId();

            List<MMV_Master__c> collateralList = [SELECT Id, Collateral_Name__c,RecordType.Name,Active_in_Commercial__c,Attachment__c,Make__r.Name 
                                           FROM MMV_Master__c 
                                           WHERE Active_in_Commercial__c =true 
                                           AND Attachment__c=:attachmentValue 
                                           AND RecordTypeId =:recordTypeIdValue
                                           AND Collateral_Name__c = :collateralId WITH SECURITY_ENFORCED ORDER BY Name ASC ]; // MMVs to be sorted ASC by default - feedback from Subha
            List<String> colMakeNameList = new List<String>();                                            
            if(!collateralList.isEmpty()){
                for(MMV_Master__c mmvInstance : collateralList){
                    colMakeNameList.add(mmvInstance.Make__r.Name);
                }
            } 
            
            if(!colMakeNameList.isEmpty()){
                return colMakeNameList;
            }else{
                return new List<String>();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
      /*
@description :  Method to get Cap Amount  based on the Attachment Type for CE
@param :  String loanId ,attachmentType
@return : Body_Funding_Cap_Master__mdt[]
*/

@AuraEnabled( cacheable = true )
public static Body_Funding_Cap_Master__mdt[] getAttachmentFundingCapAmount( Id loanId, String attachmentType ){

    Loan_Application__c loanApp = [
        SELECT Id, Customer_Grade__c, Sub_Grade__c, toLabel(Collateral_Type__c) FROM Loan_Application__c
        WHERE Id =: loanId WITH SECURITY_ENFORCED
    ];

    String customerGrade = loanApp.Customer_Grade__c,
        subGrade = loanApp.Sub_Grade__c;
       
    return [ 
        SELECT Cap_Amount__c FROM Body_Funding_Cap_Master__mdt
        WHERE Customer_Grade__c =: customerGrade AND
        ( Sub_Grade__c =: subGrade OR Sub_Grade__c = 'All' ) AND Attachment_Type__c =: attachmentType 
        
    ];
}

}