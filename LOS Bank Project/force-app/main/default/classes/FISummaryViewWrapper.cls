public with sharing class FISummaryViewWrapper {
    @AuraEnabled
    public String entity {get;set;}
    @AuraEnabled
    public String partyName {get;set;}
    @AuraEnabled
    public String currentAddress {get;set;}
    @AuraEnabled
    public String bkcurrentAddress {get;set;}
    @AuraEnabled
    public String permanentAddress {get;set;}
    @AuraEnabled
    public String bkpermanentAddress {get;set;}
    @AuraEnabled
    public String officeAddress {get;set;}
    @AuraEnabled
    public String bkofficeAddress {get;set;}
    @AuraEnabled
    public String tpAddress {get;set;}
    @AuraEnabled
    public String bktpAddress {get;set;}
    @AuraEnabled
    public String finalStatus {get;set;}
    @AuraEnabled
    public String bkfinalStatus {get;set;}
    @AuraEnabled
    public String reportLink {get;set;}
    @AuraEnabled
    public String reportLinkForCurrentAddress {get;set;}
    @AuraEnabled
    public String reportLinkForPermanentAddress {get;set;}
    @AuraEnabled
    public String reportLinkForOfficeAddress {get;set;}
    @AuraEnabled
    public String reportLinkForTPAddress {get;set;}
    @AuraEnabled
    public String applicantName {get;set;}
    @AuraEnabled
    public String currentAddressAgency {get;set;}
    @AuraEnabled
    public String permanentAddressAgency {get;set;}
    @AuraEnabled
    public String officeAddressAgency {get;set;}
    @AuraEnabled
    public String tpAddressAgency {get;set;}
    @AuraEnabled
    public String fiRecordId {get;set;}
     @AuraEnabled
    public String fiReportLink {get;set;}
    @AuraEnabled
    public String applicantId {get;set;}
    @AuraEnabled
    public String waivedOffReason {get;set;}


    public FISummaryViewWrapper(){
        entity='';
        partyName='';
        currentAddress='';
        permanentAddress='';
        officeAddress='';
        tpAddress='';
        finalStatus='';
        bkcurrentAddress='';
        bkpermanentAddress='';
        bkofficeAddress='';
        bktpAddress='';
        bkfinalStatus='';
        reportLink='';
        reportLinkForCurrentAddress='';
        reportLinkForPermanentAddress='';
        reportLinkForOfficeAddress='';
        reportLinkForTPAddress='';
        applicantName='';
        currentAddressAgency='';
        permanentAddressAgency='';
        officeAddressAgency='';
        tpAddressAgency='';
        fiRecordId = '';
        fiReportLink = '';
        waivedOffReason = '';

    }
}