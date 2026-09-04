@istest
public class LoanAgreementDocumentControllerTest {
    @isTest
    public static void updateLA2DetailsT(){
        Generic_Master__c obj = new Generic_Master__c();
        obj.Letter_Name__c = 'Customer Request Letter for Deferral Amount Lien Marking';
        insert obj;
        Generic_Master__c obj1 = new Generic_Master__c();
        obj1.Name__c ='MITC';
        obj1.Letter_Content__c = 'TEstdtre';
        obj1.Letter_Name__c = 'Loan Agreement';
        obj1.RecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByDeveloperName().get('Auto_Generated_Letters_Content').getRecordTypeId();
        insert obj1;
        LoanAgreementDocumentController.getObjGenericMaster();
        LoanAgreementDocumentController.getLoanAgreementContentsName();
        LoanAgreementDocumentController.mitcContent = 'tst';
        LoanAgreementDocumentController.thirdPartContent = 'tst';
        LoanAgreementDocumentController.declarationContent = 'tst';
        LoanAgreementDocumentController.loanCumHypoContent = 'tst';
        LoanAgreementDocumentController.recordId = obj1.Id;
        
    } 

}