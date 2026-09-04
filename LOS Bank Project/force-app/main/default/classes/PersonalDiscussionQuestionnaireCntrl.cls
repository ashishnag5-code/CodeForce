public without sharing class PersonalDiscussionQuestionnaireCntrl {
    @AuraEnabled
    public static ExistingDataWrapper getLatestValues(String loanId, String documentId) {
        ExistingDataWrapper respInst = new ExistingDataWrapper();
        try {
            String csvAsString = '';
            List<ContentVersion> contentVersionList;

            if (String.isNotBlank(documentId)) {
                contentVersionList = [
                    SELECT Id, VersionData 
                    FROM ContentVersion 
                    WHERE ContentDocumentId = :documentId 
                    ORDER BY CreatedDate DESC 
                    LIMIT 1
                ];
            } else if (String.isNotBlank(loanId)) {
                Set<Id> setOfContDocIds = new Set<Id>();
                for (ContentDocumentLink docLink : [
                    SELECT Id, ContentDocumentId 
                    FROM ContentDocumentLink 
                    WHERE ContentDocument.Title = 'Personal Discussion' 
                    AND LinkedEntityId = :loanId
                ]) {
                    setOfContDocIds.add(docLink.ContentDocumentId);
                }
                if (!setOfContDocIds.isEmpty()) {
                    contentVersionList = [
                        SELECT Id, VersionData, LastModifiedBy.Name, LastModifiedBy.Employee_Code__c
                        FROM ContentVersion 
                        WHERE Document_Type__c = 'Personal Discussion' 
                        AND ContentDocumentId IN :setOfContDocIds 
                        ORDER BY CreatedDate DESC
                    ];
                }
            }

            if (contentVersionList != null && !contentVersionList.isEmpty()) {
                Blob csvFileBody = contentVersionList[0].VersionData;
                csvAsString = csvFileBody.toString();
                respInst.pdDoneBy = contentVersionList[0].LastModifiedBy.Employee_Code__c != null ? (contentVersionList[0].LastModifiedBy.Name + ' - '
                    + contentVersionList[0].LastModifiedBy.Employee_Code__c) : contentVersionList[0].LastModifiedBy.Name;
            }
            respInst.csvString = csvAsString;
            return respInst;
        } catch (Exception ex) {
            System.debug('ex.getMessage(): '+ex.getMessage()+' Line no:'+ ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static ReturnWrapper displayQuestionnaire(String loanId) {
        ReturnWrapper returnInst = new ReturnWrapper();
        returnInst.hiddenQuestions = new List<String>();
        List<SectionQuestionInfo> resultList =  new List<SectionQuestionInfo>();
        Map<String, List<Personal_Discussion_Questionnaire__mdt>> mapOfPDQs = new Map<String, List<Personal_Discussion_Questionnaire__mdt>>();
        String customerGrade;
        String product;
        String objectFilter = loanId.substring(0, 3) == Field_Investigation__c.SObjectType.getDescribe().getKeyPrefix() ? 'FI' : 'Loan';
        String recordId;
        Set<String> applicantFieldsSet = new Set<String>{'Id'};
        Set<String> assetFieldSet = new Set<String>{'Id'};
        List<String> applicantFields = new List<String>();
        List<String> assetFields = new List<String>();

        List<Personal_Discussion_Questionnaire__mdt> personalDiscussionQuestionList = [SELECT Id, Question_Label__c, Applicable_Customer_Types__c,
            Applicable_Occupations__c,Table_Definition_LOVs__c,Order__c, Question_Type__c, isMandatory__c, QualifiedApiName,Section_Name__c, Type__c,
            Add_New_Row_Option__c, Options__c, Header_Field_Name__c, Column_Name__c, Disabled__c
            from Personal_Discussion_Questionnaire__mdt WHERE Object__c = :objectFilter ORDER BY Order__c];

        for (Personal_Discussion_Questionnaire__mdt pdq : personalDiscussionQuestionList) {
            if (String.isNotBlank(pdq.Header_Field_Name__c)) {
                if (pdq.Question_Type__c == 'Per Applicant') {
                    applicantFieldsSet.add(pdq.Header_Field_Name__c);
                } else if (pdq.Question_Type__c == 'Per Asset') {
                    assetFieldSet.add(pdq.Header_Field_Name__c);
                }
            }
        }
        applicantFields.addAll(applicantFieldsSet);
        assetFields.addAll(assetFieldSet);

        if (objectFilter == 'FI') {
            Field_Investigation__c fieldInvestigation = [SELECT Id, Loan_Application__c, Loan_Application__r.Customer_Grade__c, toLabel(Loan_Application__r.Product__c)
                FROM Field_Investigation__c WHERE Id = :loanId];
            customerGrade = fieldInvestigation.Loan_Application__r.Customer_Grade__c;
            product = fieldInvestigation.Loan_Application__r.Product__c;
            if (fieldInvestigation.Loan_Application__r.Product__c?.contains('Tractor')) {
                for (Collateral__c each : [SELECT Id, Vehicle_Delivery__c FROM Collateral__c WHERE Loan__c = :fieldInvestigation.Loan_Application__c]) {
                    if (each.Vehicle_Delivery__c == 'Yes') {
                        returnInst.hiddenQuestions.add('Asset_Delivery_Status_FI');
                    }
                }
            }
            recordId = fieldInvestigation.Loan_Application__c;
            String queryString = 'SELECT Id, (SELECT ' + String.join(applicantFields, ',') + ' FROM Applicants__r WHERE IsInactive__c = false AND RecordType.DeveloperName IN (\'Primary_Applicant\', \'Co_Applicant\', \'Guarantor\')), '
                + '(SELECT ' + String.join(assetFields, ',') + ' FROM Collaterals__r) FROM Loan_Application__c WHERE Id = :recordId';
            for (Loan_Application__c each : (List<Loan_Application__c>) Database.query(queryString)) {
                returnInst.applicants = each.Applicants__r;
                returnInst.assets = each.Collaterals__r;
            }
        } else {
            Loan_Application__c oppRec = new Loan_Application__c();
            String queryString = 'SELECT Id, Customer_Grade__c, Stage__c, OwnerId, toLabel(Product__c), '
                + '(SELECT Id, Approver__c FROM Loan_Application_Approvers__r WHERE Approval_Status__c = \'Pending\'),'
                + '(SELECT ' + String.join(applicantFields, ',') + ' FROM Applicants__r WHERE IsInactive__c = false AND RecordType.DeveloperName IN (\'Primary_Applicant\', \'Co_Applicant\', \'Guarantor\')), '
                + '(SELECT ' + String.join(assetFields, ',') + ' FROM Collaterals__r) FROM Loan_Application__c WHERE Id = :loanId';

            for (Loan_Application__c each : (List<Loan_Application__c>) Database.query(queryString)) {
                returnInst.applicants = each.Applicants__r;
                returnInst.assets = each.Collaterals__r;
                oppRec = each;
                break;
            }

            for (User each : [SELECT Id, Name, Employee_Code__c FROM User WHERE Id = :oppRec.OwnerId]) {
                returnInst.roName = each.Employee_Code__c != null ? (each.Name + ' - ' + each.Employee_Code__c) : each.Name;
            }
            if (returnInst.applicants?.size() > 0) {
                returnInst.applicantDetails = [SELECT Id,Name, (SELECT Id, Total_Net_Income__c, RecordType.DeveloperName, Net_Revenue__c, Net_Annual_Income__c,
                    Salary_Received_in_Bank__c, Salary_Received_in_Cash__c, Monthly_Turnover__c, Monthly_Total_Income__c, Other_Income_Picklist__c,
                    Monthly_Income__c, Crop_Details__c, Area_under_crop__c, Area_under_Crop_Unit__c, Total_Income__c FROM Applicant_Financials__r),
                    (SELECT Id, Khata_Khasara_Survey_Number__c FROM Addresses__r WHERE Address_Type__c = 'Land') FROM Applicant__c WHERE Id IN :returnInst.applicants];
            }
            customerGrade = oppRec.Customer_Grade__c;
            product = oppRec.Product__c;
            returnInst.isEditable = false;
            Id creditApprover;
            String profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
            for (Loan_Application_Approval__c each : oppRec.Loan_Application_Approvers__r) {
                if (each.Approver__c == UserInfo.getUserId()) {
                    creditApprover = each.Approver__c;
                }
            }
            if ((oppRec.Stage__c == 'QDE' || oppRec.Stage__c == 'DDE') && (oppRec.OwnerId == UserInfo.getUserId())) {
                returnInst.isEditable = true;
            } else if (oppRec.Stage__c == 'Credit' && creditApprover == UserInfo.getUserId()) {
                returnInst.isEditable = true;
            } else if (profileNameUserInfo == 'System Administrator') {
                returnInst.isEditable = true;
            }
            if (oppRec.Stage__c == 'QDE' || oppRec.Stage__c == 'DDE') {
                returnInst.isEditableInWizard = true;
            }
            recordId = loanId;
        }

        for(Personal_Discussion_Questionnaire__mdt pdq : personalDiscussionQuestionList) {
            String allGrades = pdq.Applicable_Customer_Types__c;
            String allProducts = pdq.Applicable_Occupations__c;
            List<String> gradeList = allGrades != null ? allGrades.contains(';') ? allGrades.split(';') : new List<String>{allGrades} : new List<String>();
            Boolean gradeResult = gradeList.contains(customerGrade);
            if ((gradeResult || gradeList.isEmpty()) && product.contains(allProducts)) {
                if (!mapOfPDQs.containsKey(pdq.Section_Name__c)) {
                    mapOfPDQs.put(pdq.Section_Name__c, new List<Personal_Discussion_Questionnaire__mdt>());
                }
                mapOfPDQs.get(pdq.Section_Name__c).add(pdq);
            }            
        }
        if (!mapOfPDQs.isEmpty()) {
            for (String sectionName : mapOfPDQs.keySet()) {
                resultList.add(new SectionQuestionInfo(sectionName, mapOfPDQs.get(sectionName)));
            }
        }
        returnInst.questions = resultList;
        return returnInst;
    }
    
    @AuraEnabled
    public static void insertFileVersion(String versionData, String loanId) {
        try {
            Id currentUserId = UserInfo.getUserId();
            ContentVersion contVer = new ContentVersion(
                Title = 'Personal Discussion',
                PathOnClient = 'Personal_Discussion.txt', 
                Document_Type__c = 'Personal Discussion',
                VersionData = EncodingUtil.base64Decode(versionData)
            );
            List<ContentDocumentLink> docLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocument.Title = 'Personal Discussion' 
                AND LinkedEntityId = :loanId AND ContentDocument.OwnerId = :currentUserId];
            if (!docLinks.isEmpty()) {
                contVer.ContentDocumentId = docLinks[0].ContentDocumentId;
            }
            insert contVer;
            if (docLinks.isEmpty()) {
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = loanId;
                contentlink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contVer.Id].ContentDocumentId;
                contentlink.ShareType = 'V';
                insert contentlink;
            }
            String objectFilter = loanId.substring(0, 3) == Field_Investigation__c.SObjectType.getDescribe().getKeyPrefix() ? 'FI' : 'Loan';
            String applicationId;
            if (objectFilter == 'FI') {
                applicationId = [SELECT Id, Loan_Application__c FROM Field_Investigation__c WHERE Id = :loanId WITH SECURITY_ENFORCED].Loan_Application__c;
            } else {
                applicationId = loanId;
            }
            if (objectFilter != 'FI') {
                CreditVerification.resetCreditVerificationOnLoan(applicationId, 'PD form', false);
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class ReturnWrapper {
        @AuraEnabled public List<SectionQuestionInfo> questions;
        @AuraEnabled public List<String> hiddenQuestions;
        @AuraEnabled public Boolean isEditable = true;
        @AuraEnabled public Boolean isEditableInWizard = false;
        @AuraEnabled public List<Applicant__c> applicants;
        @AuraEnabled public List<Collateral__c> assets;
        @AuraEnabled public List<Applicant__c> applicantDetails;
        @AuraEnabled public String roName;
    }

    public class SectionQuestionInfo {
        @AuraEnabled public String sectionName;
        @AuraEnabled public List<Personal_Discussion_Questionnaire__mdt> pdqs;

        public SectionQuestionInfo(String sectionName, List<Personal_Discussion_Questionnaire__mdt> pdqs){
            this.sectionName = sectionName;
            this.pdqs = pdqs;
        }
    }

    public class ExistingDataWrapper {
        @AuraEnabled public String csvString;
        @AuraEnabled public String pdDoneBy;
    }
}