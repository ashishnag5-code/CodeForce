public with sharing class LoanAgreementDocumentController {
    
    public static Map<String, Generic_Master__c> loanAgreementContents{get;set;}
    public static Set<String> loanAgreementContentsName;
    public static String mitcContent{get;set;}
    public static String thirdPartContent{get;set;}
    public static String declarationContent{get;set;}
    public static String loanCumHypoContent{get;set;}

    public static String recordId{get;set;}
	public static Generic_Master__c objGenericMaster;

    public static Generic_Master__c getObjGenericMaster(){
        objGenericMaster = [Select Id,Letter_Name__c,Letter_Content__c from Generic_Master__c where Letter_Name__c = 'Customer Request Letter for Deferral Amount Lien Marking' limit 1];
        return objGenericMaster;
    }




    public static Set<String> getLoanAgreementContentsName(){
        loanAgreementContents = new Map<String, Generic_Master__c>();
        List<Generic_Master__c> documentContents = [SELECT Id, Name, Letter_Content__c FROM Generic_Master__c WHERE RecordType.DeveloperName='Auto_Generated_Letters_Content' AND Letter_Name__c='Loan Agreement' order by Name];
        system.debug('documentContents '+documentContents);
        if(documentContents!=null && documentContents.size()>0){
            for(Generic_Master__c content: documentContents){
                if(content.Name == 'MITC'){
                    mitcContent = content.Letter_Content__c;
                }else if(content.Name == 'Third Part Loan Agreement'){
                    thirdPartContent = content.Letter_Content__c;
                }else if(content.Name == 'Declaration'){
                    declarationContent = content.Letter_Content__c;
                }else if(content.Name == 'Loan Cum Hypothecation'){
                    loanCumHypoContent = content.Letter_Content__c;
                }else{
                    loanAgreementContents.put(content.Name, content);
                }
            }
            loanAgreementContentsName = loanAgreementContents.keySet();
        }
        return loanAgreementContentsName;
    }
}