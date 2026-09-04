public with sharing class CFRNegativeCheckRelatedPartyAMLCheck {

    public static String pan;
    public static String completeName;
    public static String aadharNumber;
    public static String passportNumber;
    public static String voterId;
    public static String applcntRecordTypeName;
    public static String cinNo;
    public static String customerType;
    @AuraEnabled public String messag {
        get;
        set;
    }
    @AuraEnabled public List < Sobject > recMatchList {
        get;
        set;
    }
    @AuraEnabled public List < Applicant__c > applcntList {
        get;
        set;
    }
    @AuraEnabled public Map < String, String > cibilCutomMetaDataLst {
        get;
        set;
    }


    @AuraEnabled
    public static String genericDynamicSoql(String fields, String sobjectName, String whereClause) {
        String query = 'SELECT Id,' + fields + ' FROM ' + sobjectName + ' ' + whereClause;
        System.debug('query = > ' + query);
        return query;
    }

    @AuraEnabled
    public static List < CFR_Master__c > checkCFR() {

        String panNo = String.isNotBlank(pan) ? String.escapeSingleQuotes(pan) : '';
        List < CFR_Master__c > cfrList = new List < CFR_Master__c > ();
        String whereClauseForCfr = '';
        String query = '';

        if (String.isNotBlank(pan)) {
            whereClauseForCfr = 'WHERE (PAN__c =: panNo)';
            query = genericDynamicSoql('Name, PAN__c', 'CFR_Master__c', whereClauseForCfr);
            cfrList = Database.Query(String.escapeSingleQuotes(query));
        }
        return cfrList;
    }

    public static List < CFR_Master__c > checkCFRByName() {

        String completeNameVal = String.isNotBlank(completeName) ? String.escapeSingleQuotes(completeName) : '';
        List < CFR_Master__c > cfrList = new List < CFR_Master__c > ();
        String whereClauseForCfr = '';
        String query = '';

        if (String.isNotBlank(completeNameVal) && String.isBlank(pan)) { // Check partial match only if Pan is Blank --> Kunal [9th Sept]
            whereClauseForCfr = 'WHERE (Name_of_Perpetrator__c =: completeNameVal)';
            query = genericDynamicSoql('Name, PAN__c', 'CFR_Master__c', whereClauseForCfr);
            cfrList = Database.Query(String.escapeSingleQuotes(query));
        }
        return cfrList;
    }

    @AuraEnabled
    public static List < Negative_Check_Master__c > checkNegativeCheck() {

        List < Negative_Check_Master__c > negCheckList = new List < Negative_Check_Master__c > ();
        String query = '';
        String whereClauseForNP = '';
        String panNo = String.isNotBlank(pan) ? String.escapeSingleQuotes(pan) : '';

        if (customerType == 'Individual') {
            String aadharNo = String.isNotBlank(aadharNumber) ? String.escapeSingleQuotes(aadharNumber) : '';
            String passportNo = String.isNotBlank(passportNumber) ? String.escapeSingleQuotes(passportNumber) : '';
            String votrId = String.isNotBlank(voterId) ? String.escapeSingleQuotes(voterId) : '';
            system.debug('aadharNumber-->' + aadharNo);
            if (String.isNotBlank(aadharNo)) {
                whereClauseForNP = '(Aadhaar_Number__c =: aadharNo)';
            }
            if (String.isNotBlank(pan)) {
                if (String.isNotBlank(whereClauseForNP)) {
                    whereClauseForNP = whereClauseForNP.substring(0, whereClauseForNP.length() - 1) + ' OR PAN__c =: panNo)';
                } else {
                    whereClauseForNP = whereClauseForNP + ' (PAN__c =: panNo)';
                }
            }
            if (String.isNotBlank(passportNumber)) {
                if (String.isNotBlank(whereClauseForNP)) {
                    whereClauseForNP = whereClauseForNP.substring(0, whereClauseForNP.length() - 1) + ' OR PASSPORT_NUMBER__c =: passportNo)';
                } else {
                    whereClauseForNP = whereClauseForNP + ' (PASSPORT_NUMBER__c =: passportNo)';
                }
            }
            if (String.isNotBlank(voterId)) {
                if (String.isNotBlank(whereClauseForNP)) {
                    whereClauseForNP = whereClauseForNP.substring(0, whereClauseForNP.length() - 1) + ' OR VOTER_ID__c =: voterId)';
                } else {
                    whereClauseForNP = whereClauseForNP + ' (VOTER_ID__c =: voterId)';
                }
            }
            if (String.isNotBlank(whereClauseForNP)) {
                whereClauseForNP = ' WHERE ' + whereClauseForNP;
            }
            if (String.isNotBlank(aadharNo) || String.isNotBlank(pan) || String.isNotBlank(passportNumber) || String.isNotBlank(voterId)) {
                query = genericDynamicSoql('Name, Aadhaar_Number__c, PAN__c, PASSPORT_NUMBER__c, VOTER_ID__c', 'Negative_Check_Master__c', whereClauseForNP);
            }

        } else if (customerType == 'Non Individual') {
            String cin = String.isNotBlank(cinNo) ? String.escapeSingleQuotes(cinNo) : '';
            /*if (String.isNotBlank(cin)) {
                whereClauseForNP = 'WHERE (CIN_NO__c =: cin)';
                query = genericDynamicSoql('Name, CIN_NO__c', 'Negative_Check_Master__c', whereClauseForNP);
            }*/
            if (String.isNotBlank(cin)) {
                whereClauseForNP = '(CIN_NO__c =: cin)';
            }
            if (String.isNotBlank(pan)) {
                if (String.isNotBlank(whereClauseForNP)) {
                    whereClauseForNP = whereClauseForNP.substring(0, whereClauseForNP.length() - 1) + ' OR PAN__c =: panNo)';
                } else {
                    whereClauseForNP = whereClauseForNP + ' (PAN__c =: panNo)';
                }
            }
            if (String.isNotBlank(whereClauseForNP)) {
                whereClauseForNP = ' WHERE ' + whereClauseForNP;
            }
            if (String.isNotBlank(cin) || String.isNotBlank(pan)) {
                query = genericDynamicSoql('Name, CIN_NO__c, PAN__c', 'Negative_Check_Master__c', whereClauseForNP);
            }
        }
        if (String.isNotBlank(query)) {
            system.debug('query--' + query);
            negCheckList = Database.Query(query);
            system.debug('negCheckList inside checkNegativeCheck--> ' + negCheckList);
        }

        return negCheckList;
    }

    @AuraEnabled
    public static List < Related_Party_Master__c > checkRelatedParty() {

        String panNo = String.isNotBlank(pan) ? String.escapeSingleQuotes(pan) : '';
        String query = '';
        String whereClauseForRP = '';
        List < Related_Party_Master__c > rpLst = new List < Related_Party_Master__c > ();
        if (customerType == 'Individual') {
            String aadharNo = String.isNotBlank(aadharNumber) ? String.escapeSingleQuotes(aadharNumber) : '';
            if (String.isNotBlank(aadharNo)) {
                whereClauseForRP = 'WHERE (Aadhaar_Number__c =: aadharNo)';
            }
            system.debug('whereClauseForRP--' + whereClauseForRP);
            if (String.isNotBlank(panNo)) {
                whereClauseForRP = String.isNotBlank(whereClauseForRP) ? whereClauseForRP.substring(0, whereClauseForRP.length() - 1) : '';
                whereClauseForRP = String.isNotBlank(whereClauseForRP) ? whereClauseForRP + ' OR PAN__c =: panNo)' : ' WHERE PAN__c =: panNo';
            }
            if (String.isNotBlank(aadharNo) || String.isNotBlank(panNo)) {
                query = genericDynamicSoql('Name, PAN__c , Aadhaar_Number__c', 'Related_Party_Master__c', whereClauseForRP);
            }
        } else if (customerType == 'Non Individual') {
            if (String.isNotBlank(panNo)) {
                String panNumber = String.escapeSingleQuotes(panNo);
                whereClauseForRP = 'WHERE (PAN__c =: panNumber)';
                query = genericDynamicSoql('Name, PAN__c', 'Related_Party_Master__c', whereClauseForRP);
            }
        }
        if (String.isNotBlank(query)) {
            rpLst = Database.Query(String.escapeSingleQuotes(query));
        }
        return rpLst;
    }

    @AuraEnabled
    public static List < Applicant__c > getApplicant(ID recordId) {
        system.debug('in getApplicant');
        List < Applicant__c > applicantList = [SELECT Id, Customer_Type__c, Customer_Name__c, Recordtype.Name, PAN__c, Aadhaar_Number__c, CFR_Status__c, Negative_Check_Status__c,
            Related_Party_Status__c, IsInactive__c, Inactive_reason__c, Passport_Number__c, Mobile_Number__c, Email__c, Complete_Name__c,
            Voter_Id__c, CIN__c, Loan__c, Loan__r.Id, Loan__r.Remarks__c, Driving_License_Id__c, Dob__c, Gender__c, AML_Status__c
            FROM Applicant__c WHERE Id =: recordId WITH SECURITY_ENFORCED
        ];

        return applicantList;
    }

    public static Map < String, String > initCibilCustomData() {

        Map < String, String > cibilMetaData = new Map < String, String > ();
        Map < String, Cibil__mdt > mapCibilRange = Cibil__mdt.getAll();

        for (String cibilRec: mapCibilRange.keySet()) {
            String cibilRange = mapCibilRange.get(cibilRec).Cibil_Range__c;
            String color = mapCibilRange.get(cibilRec).Color__c;
            cibilMetaData.put(cibilRange, color);
        }
        return cibilMetaData;
    }

    @AuraEnabled
    public static CFRNegativeCheckRelatedPartyAMLCheck checkHandler(String applcntId) {

        CFRNegativeCheckRelatedPartyAMLCheck cfrNpRpobj = new CFRNegativeCheckRelatedPartyAMLCheck();
        cfrNpRpobj.recMatchList = new List < SObject > ();
        cfrNpRpobj.applcntList = new List < Applicant__c > ();

        cfrNpRpobj.cibilCutomMetaDataLst = initCibilCustomData();

        List < Applicant__c > applcntRecLst = getApplicant(applcntId);
        cfrNpRpobj.applcntList = applcntRecLst;

        pan = applcntRecLst[0].PAN__c;
        aadharNumber = applcntRecLst[0].Aadhaar_Number__c;
        passportNumber = applcntRecLst[0].Passport_Number__c;
        voterId = applcntRecLst[0].Voter_Id__c;
        applcntRecordTypeName = applcntRecLst[0].RecordType.Name;
        customerType = applcntRecLst[0].Customer_Type__c;
        cinNo = applcntRecLst[0].CIN__c;
        String whereClauseForCfr = '';
        String whereClauseForNP = '';
        String whereClauseForRP = '';
        String messag = '';
        completeName = applcntRecLst[0].Complete_Name__c;

        if (applcntRecordTypeName == 'Applicant') {
            messag = 'Applicant and Loan Application Updated Successfully';
        } else if (applcntRecordTypeName == 'Co-Applicant' || applcntRecordTypeName == 'Guarantor') {
            messag = 'Applicant Updated Successfully';
        }

        List < Applicant__c > applcntToUpdat = new List < Applicant__c > {
            new Applicant__c(Id = applcntRecLst[0].Id, Loan__c = applcntRecLst[0].Loan__c,
                RecordTypeId = applcntRecLst[0].RecordType.Id)
        };
        if (applcntToUpdat[0].CFR_Status__c == null || applcntToUpdat[0].Negative_Check_Status__c == null || applcntToUpdat[0].Related_Party_Status__c == null) {
            String cfrStatus = '';
            String cfrMessage = '';
            List < CFR_Master__c > matchedCFR = checkCFR();
            List < CFR_Master__c > partialMatchedCFR = checkCFRByName();
            if (partialMatchedCFR.size() > 0) {
                cfrStatus = 'Partial Match Found';
                cfrMessage = 'Partial Match';
                cfrNpRpobj.recMatchList = partialMatchedCFR;
            }
            if (matchedCFR.size() > 0) {
                    cfrStatus = 'Rejected due to match with fraud registry';
                    cfrMessage = 'CFR Match';
                    applcntToUpdat[0].CFR_Status__c = cfrStatus;
                    cfrNpRpobj.messag = cfrMessage;
                    cfrNpRpobj.recMatchList = matchedCFR;
                    updateHandler(applcntToUpdat);
            }else if (checkNegativeCheck().size() > 0) {
                applcntToUpdat[0].CFR_Status__c = (cfrStatus == 'Partial Match Found') ? 'Partial Match Found' : 'No Match';
                applcntToUpdat[0].Negative_Check_Status__c = 'Rejected due to match with fraud registry';
                cfrNpRpobj.messag = 'NP Match';
                cfrNpRpobj.recMatchList = checkNegativeCheck();
                updateHandler(applcntToUpdat);
            } else if (checkRelatedParty().size() > 0) {
                applcntToUpdat[0].CFR_Status__c = (cfrStatus == 'Partial Match Found') ? 'Partial Match Found' : 'No Match';
                applcntToUpdat[0].Negative_Check_Status__c = 'No Match';
                applcntToUpdat[0].Related_Party_Status__c = 'Rejected due to match with fraud registry';
                cfrNpRpobj.messag = 'RP Match';
                cfrNpRpobj.recMatchList = checkRelatedParty();
                updateHandler(applcntToUpdat);
            }
            /*else if(partialMatchedCFR.size() > 0){
                           applcntToUpdat[0].CFR_Status__c = 'Partial Match Found';
                           cfrNpRpobj.messag = 'Partial Match';
                           cfrNpRpobj.recMatchList = partialMatchedCFR;
                           updateHandler(applcntToUpdat);
                       }*/
            else {
                cfrNpRpobj.messag = 'No Match Found';
            }

            if (cfrNpRpobj.messag == 'No Match Found') {
                cfrNpRpobj.messag =  cfrMessage == 'Partial Match' ? cfrMessage : 'No Match Found';
                applcntToUpdat[0].CFR_Status__c = (cfrStatus == 'Partial Match Found') ? 'Partial Match Found' : 'No Match';
                applcntToUpdat[0].Negative_Check_Status__c = 'No Match';
                applcntToUpdat[0].Related_Party_Status__c = 'No Match';
                updateApplcnt(applcntToUpdat);
            }
        } else {
            if (applcntToUpdat[0].CFR_Status__c == 'No match' && applcntToUpdat[0].Negative_Check_Status__c == 'No match' && applcntToUpdat[0].Related_Party_Status__c == 'No match') {
                cfrNpRpobj.messag = 'No Match Found';
            } else if (applcntToUpdat[0].CFR_Status__c == 'Match') {
                cfrNpRpobj.messag = 'CFR Match';
                cfrNpRpobj.recMatchList = checkCFR();
            } else if (applcntToUpdat[0].Negative_Check_Status__c == 'Match') {
                cfrNpRpobj.messag = 'NP Match';
                cfrNpRpobj.recMatchList = checkNegativeCheck();
            } else if (applcntToUpdat[0].Related_Party_Status__c == 'Match') {
                cfrNpRpobj.messag = 'RP Match';
                cfrNpRpobj.recMatchList = checkRelatedParty();
            }
        }
        return cfrNpRpobj;
    }

    @AuraEnabled
    public static void updateHandler(List < Applicant__c > applcntRecLst) {
        String applcntRecordTypeName = Schema.SObjectType.Applicant__c.getRecordTypeInfosById().get(applcntRecLst[0].recordtypeid).getname();
        system.debug('applcntRecordTypeName--' + applcntRecordTypeName);
        if (applcntRecordTypeName == 'Applicant' && ((applcntRecLst[0].CFR_Status__c != 'Partial Match Found' && applcntRecLst[0].CFR_Status__c != 'No Match') || applcntRecLst[0].Negative_Check_Status__c != 'No Match' || applcntRecLst[0].Related_Party_Status__c != 'No Match')) {
            system.debug('applcntRecLst--' + applcntRecLst);
            updateApplcnt(applcntRecLst);
            updateLoanApplction(applcntRecLst[0].Loan__c);
        } else if (applcntRecordTypeName == 'Co-Applicant' || applcntRecordTypeName == 'Guarantor' || applcntRecordTypeName == 'BO' && (applcntRecLst[0].CFR_Status__c != 'No Match' || applcntRecLst[0].Negative_Check_Status__c != 'No Match' || applcntRecLst[0].Related_Party_Status__c != 'No Match')) {
            applcntRecLst[0].IsInactive__c = true;
            applcntRecLst[0].Inactive_reason__c = 'Rejected due to match with fraud registry';
            updateApplcnt(applcntRecLst);
        }
    }

    @AuraEnabled
    public static void updateApplcnt(List < Applicant__c > applcntRecLst) {

        if (Schema.sObjectType.Applicant__c.isUpdateable()) {
            system.debug('inside isUpdateable');
            update applcntRecLst;
        }
    }

    @AuraEnabled
    public static void updateLoanApplction(String loanApplctnId) {

        List < Loan_Application__c > loanApplicantoionList = new List < Loan_Application__c > ();
        Loan_Application__c loanApplicantionRec = new Loan_Application__c();
        loanApplicantionRec.Id = loanApplctnId;
        loanApplicantionRec.Remarks__c = 'Case is rejected due to match with fraud registry';
        loanApplicantionRec.Stage__c = 'Rejected';
        loanApplicantoionList.add(loanApplicantionRec);

        if (Schema.sObjectType.Loan_Application__c.isUpdateable()) {
            DatabaseUtility.updateRecords(loanApplicantoionList, 'Loan_Application__c');
        }
    }
}