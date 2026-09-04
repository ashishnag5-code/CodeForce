public with sharing class LosKYCConsent {

    public static List<Aadhaar_consent__mdt> getAadhaaeConsent() {
        List<Aadhaar_consent__mdt>  aadhaarConsentList = [SELECT id, Language__c, Consent_Audio_file__c, Consent_Document__c, URL__c
                                                         FROM Aadhaar_consent__mdt WITH SECURITY_ENFORCED];
        return aadhaarConsentList;
    }

    public static List<ContentVersion> getContentVersion(List<String> consentDocumentLst) {
        List<ContentVersion>  aadhaarConsentList = [SELECT id, Title, ContentDocumentId, VersionDataUrl
                                                         FROM ContentVersion where isActive__c = true AND Title =:consentDocumentLst WITH SECURITY_ENFORCED];
        return aadhaarConsentList;
    }
    public static List<StaticResource> getStaticResource(List<String> nameList) {
        List<StaticResource> sr = [SELECT Id, Name FROM StaticResource WHERE Name =:nameList WITH SECURITY_ENFORCED];
        return sr;
    }

    @AuraEnabled
    public static LosKYCConsentWrapper initLanguage(){

        List<String> consentAudioFileList = new List<String>();
        List<String> consentDocumentList = new List<String>();
        Map<String, String> titleToContDocId = new Map<String, String>();
        Map<String, String> nameToAudioFIle = new Map<String, String>();

        List<Aadhaar_consent__mdt>  aadhaarConsentMdtLst = getAadhaaeConsent().size() > 0 ? getAadhaaeConsent() : new List<Aadhaar_consent__mdt>();
        LosKYCConsentWrapper losKycConsentObj = new LosKYCConsentWrapper();
        List<LanguageOptions> langList = new List<LanguageOptions>();
        for(Aadhaar_consent__mdt aadhaarConsentMdt : aadhaarConsentMdtLst) {
            consentAudioFileList.add(aadhaarConsentMdt.Consent_Audio_file__c);
            consentDocumentList.add(aadhaarConsentMdt.Consent_Document__c);

            losKycConsentObj.languageOpt   = new List<LanguageOptions>();

            LanguageOptions langOption  = new LanguageOptions();
            langOption.language         = aadhaarConsentMdt.Language__c;
            langOption.consentAudioFile = aadhaarConsentMdt.Consent_Audio_file__c;
            langOption.consentDocument  = aadhaarConsentMdt.Consent_Document__c;
            langOption.publicUrlForConsentDoc = aadhaarConsentMdt.URL__c;
            langList.add(langOption);
        }
        losKycConsentObj.languageOpt = langList;
        system.debug('consentDocumentList--'+consentDocumentList);
        List<ContentVersion> contentList = getContentVersion(consentDocumentList);
        system.debug('contentList--'+contentList);
        for(ContentVersion contVer : contentList) {
            titleToContDocId.put(contVer.Title, contVer.VersionDataUrl);
        }
        system.debug('titleToContDocId--'+titleToContDocId);
        losKycConsentObj.titleToContDocumId = titleToContDocId;

        List<StaticResource> srList = getStaticResource(consentAudioFileList);

        for(StaticResource sr : srList) {
            String audioFileUrl = '/resource/' + sr.name + '?';
            nameToAudioFIle.put(sr.Name, audioFileUrl);
        }
        losKycConsentObj.nameToAudioFileUrl = nameToAudioFIle;
        return losKycConsentObj;    
    }

    @AuraEnabled
    public static String saveDocUrl(String applicantId, String docUrl) {

        Applicant__c applcnt = new Applicant__c();
        applcnt.Id = applicantId;
        applcnt.Aadhaar_Consent_Version__c = docUrl;

        if(applcnt != null) {
            update applcnt;
            return 'Applicant Updated Successfully';
        }
        return null;
    }

    public class LosKYCConsentWrapper {
        @AuraEnabled  public List<LanguageOptions> languageOpt; 
        @AuraEnabled  public Map<String, String> titleToContDocumId; 
        @AuraEnabled  public Map<String, String> nameToAudioFileUrl; 
    }

    public class LanguageOptions {
        @AuraEnabled  public String language; 
        @AuraEnabled  public String consentAudioFile; 
        @AuraEnabled  public String consentDocument; 
        @AuraEnabled  public String publicUrlForConsentDoc; 
    }
}