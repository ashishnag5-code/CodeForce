public class ApplicationFormPDFController {
    public ApplicationFormPDFController(SystemGeneratedEsignDocumentsController controller) {
        runControllerLogic();
    }

    public String dateString {get; set;}
    public List<String> dateStringList {get; set;}
    public Map<Id, Map<String, Address__c>> addressMap {get; set;}
    public Map<Id, Applicant_Financials_Details__c> applicantFinancialsMap {get; set;}
    public Applicant__c primaryApplicant {get; set;}
    public Loan_Application__c loanRecord {get; set;}
    public List<References> references {get;set;}    
    public List<Applicant__c> coApplicant {get; set;}
    public List<Applicant__c> guarantors {get; set;}
    public Map<Id, String> incomeMap {get; set;}
    public Map<Id, Map<String, Integer>> workExpMap {get; set;}
    public Collateral__c collateral {get;set;}
    public List<Collateral__c> lstPropertyOffered {get;set;}
    public List<Fleet__c> lstFleet {get;set;}
    public Map<Id, String> mapApplicantImage {get;set;}
    public Map<String,Applicant_Financials_Details__c> mapAppFindetails{get;set;}
    public List<DocumentChecklistWrapper> documentChecklists {get; set;}
    public List<Applicant__c> beneficialOwners {get;set;}
    public List<Applicant__c> blankBO {get;set;}
    public Map<Id, String> entityProofMap {get; set;}
    public BSR_PSL_Details__c bsrDetails {get; set;}
    public List<Bank_Account_Records__c> bankAccounts {get; set;}
    public List<Map<Integer, String>> declarationList {get; set;}
    public DocumentChecklistWrapper declarationWrap {get; set;}
    public String marginMoneyStr {get; set;}

    public ApplicationFormPDFController() {
        runControllerLogic();
    }

    public void runControllerLogic() {
        //dateString = Date.today().format();
        //dateStringList = dateString.replace('/', '').replace('-', '').split('');
        Id loanApplicationId = ApexPages.currentPage().getParameters().get('id');
        Set<Id> applicantIds = new Set<Id>();
        addressMap = new Map<Id, Map<String, Address__c>>();
        mapApplicantImage = new Map<Id, String>();
        applicantFinancialsMap = new Map<Id, Applicant_Financials_Details__c>();
        incomeMap = new Map<Id, String>();
        workExpMap = new Map<Id, Map<String, Integer>>();
        String placeholderImageURL = '';
        beneficialOwners = new List<Applicant__c>();
        blankBO = new List<Applicant__c>();
        entityProofMap = new Map<Id, String>();
        references = new List<References>();
        bsrDetails = new BSR_PSL_Details__c(Land_Holding_in_acre__c = 0);
        documentChecklists = new List<DocumentChecklistWrapper>();
        declarationList = new List<Map<Integer, String>>();

        for (StaticResource each : [SELECT Id, SystemModStamp FROM StaticResource WHERE Name = 'ApplicationForm' LIMIT 1]) {
            placeholderImageURL = '/resource/' + String.valueOf(((DateTime) each.SystemModStamp).getTime()) + '/ApplicationForm/PlaceholderPhoto.png';
        }
        loanRecord = [SELECT Id, RecordType.DeveloperName, References__c, ROI__c, Total_Charges__c, toLabel(Product__c), Total_Loan_Amount__c, Tenure__c, Application_Number__c, Application_Id__c, Loan_Amount__c,
                      Unhedged_Foreign_Currency_Exposure__c, CreatedDate,
                      (
                          SELECT Id, Existing_Customer__c, Constitution_Type__c, Applicant_Name__c, Mother_Name__c, Father_Name__c, Spouse_Name__c, Mobile_Number__c, Email__c, Customer_Grade__c, Place_of_Birth_Incorporation__c ,
                          RecordType.DeveloperName, Religion__c, Gender__c, CIF_No__c, CKYC__c, Marital_Status__c, Title__c, Caste__c, Dob__c, Date_of_Establishment__c, PAN__c,
                          Pan_Form60__c, Residential_Status__c, Phsically_challenged__c, Education_qualification__c, Passport_Expiry_Date__c, Passport_Number__c, Driving_License_Expiry_Date__c,
                          Driving_License_Id__c, Voter_Id__c,Relationship_with_applicant__c, Aadhaar_Number__c, Utility_Bills_Electricity__c, Utility_Bills_Landline_Phone__c, Utility_Bills_Water__c,
                          Type_Of_Employment__c, Total_Monthly_Income_Sum__c, Age__c, Shareholding__c, NPR__c, NREGA__c, Customer_Type__c, AU_Employee__c, AU_Employee_ID__c
                          FROM Applicants__r WHERE IsInactive__c = FALSE
                      ),
                      (SELECT Land_Holding_in_acre__c FROM BSR_PSL_Details__r ORDER BY CreatedDate DESC LIMIT 1)
                      FROM Loan_Application__c WHERE Id = :loanApplicationId];

        dateString = loanRecord.CreatedDate.format('dd/MM/yyyy');
        dateStringList = dateString.replace('/', '').replace('-', '').split('');
        coApplicant = new List<Applicant__c>();
        guarantors = new List<Applicant__c>();
        if (loanRecord.BSR_PSL_Details__r != null && !loanRecord.BSR_PSL_Details__r.isEmpty()) {
            bsrDetails = loanRecord.BSR_PSL_Details__r.get(0);
            bsrDetails.Land_Holding_in_acre__c = bsrDetails.Land_Holding_in_acre__c == null ? 0 : bsrDetails.Land_Holding_in_acre__c;
        }
        for (Applicant__c each : loanRecord.Applicants__r) {
            addressMap.put(each.Id, new Map<String, Address__c>{'Permanent' => new Address__c(), 'Current' => new Address__c(), 'Office' => new Address__c()});
            applicantFinancialsMap.put(each.Id, new Applicant_Financials_Details__c());
            incomeMap.put(each.Id, each.Total_Monthly_Income_Sum__c == null ? '0' : (each.Total_Monthly_Income_Sum__c * 12).format());
            if (String.isNotBlank(each.Aadhaar_Number__c)) {
                entityProofMap.put(each.Id, 'Aadhaar');
                each.Aadhaar_Number__c = 'XXXXXXXX' + each.Aadhaar_Number__c.right(4);
            } else if (String.isNotBlank(each.Voter_Id__c)) {
                entityProofMap.put(each.Id, 'Voter ID');
            } else if (String.isNotBlank(each.Driving_License_Id__c)) {
                entityProofMap.put(each.Id, 'Driving License');
            } else if (String.isNotBlank(each.Passport_Number__c)) {
                entityProofMap.put(each.Id, 'Passport');
            } else if (String.isNotBlank(each.NPR__c)) {
                entityProofMap.put(each.Id, 'National Population Register (NPR)');
            } else if (String.isNotBlank(each.NREGA__c)) {
                entityProofMap.put(each.Id, 'NREGA Job Card');
            } else {
                entityProofMap.put(each.Id, '');
            }
            if (each.RecordType.DeveloperName == 'Primary_Applicant') {
                primaryApplicant = each;
                applicantIds.add(each.Id);
            } else if (each.RecordType.DeveloperName == 'Co_Applicant') {
                coApplicant.add(each);
                applicantIds.add(each.Id);
            } else if (each.RecordType.DeveloperName == 'Guarantor') {
                guarantors.add(each);
                applicantIds.add(each.Id);
            } else if (each.RecordType.DeveloperName == 'BO') {
                beneficialOwners.add(each);
            }
            mapApplicantImage.put(each.Id, placeholderImageURL);
            workExpMap.put(each.Id, new Map<String, Integer>{'Years' => 0, 'Months' => 0});
        }

        Map<Integer, String> signatureMap = new Map<Integer, String>{0 => 'Applicant'};
        Integer j = 1;
        for (Integer i = 0; i < coApplicant.size(); i++) {
            if (signatureMap.size() == 3) {
                declarationList.add(signatureMap);
                signatureMap = new Map<Integer, String>();
                j = 0;
            }
            signatureMap.put(j++, 'Co-Applicant');
        }
        for (Integer i = 0; i < guarantors.size(); i++) {
            if (signatureMap.size() == 3) {
                declarationList.add(signatureMap);
                signatureMap = new Map<Integer, String>();
                j = 0;
            }
            signatureMap.put(j++, 'Guarantor');
        }
        declarationList.add(signatureMap);
        declarationWrap = new DocumentChecklistWrapper();
        declarationWrap.declarationMap = declarationList;
        
        Map<Id, Id> applicantImagesMap = new Map<Id, Id>();
        Map<Id, Id> conDocIdToApplicantIdMap = new Map<Id, Id>();
        Map<Id, Id> mapDocCheckApplicantId = new Map<Id, Id>();
        List<String> docCheckList = new List<String>();
        for (Document_Checklist__c docCheck : [SELECT id, Applicant__c FROM Document_Checklist__c WHERE Applicant__c IN :applicantIds and Document_Master__r.Document_Name__c ='Live Photo']) {
            docCheckList.add(docCheck.Id);
            mapDocCheckApplicantId.put(docCheck.Id, docCheck.Applicant__c);
        }
        if (docCheckList.size() > 0) {
            for (ContentDocumentLink conDoc : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: docCheckList AND ContentDocument.LatestPublishedVersion.isActive__c=TRUE]){
                conDocIdToApplicantIdMap.put(conDoc.ContentDocumentId, mapDocCheckApplicantId.get(conDoc.LinkedEntityId));
            }
            for(ContentVersion con : [SELECT Id, ContentDocumentId, Document_Type__c FROM ContentVersion WHERE ContentDocumentId =:conDocIdToApplicantIdMap.keySet() AND isActive__c = true ORDER By LastModifiedDate DESC]) {
                if (conDocIdToApplicantIdMap != null && conDocIdToApplicantIdMap.containsKey(con.ContentDocumentId) && !applicantImagesMap.containsKey(conDocIdToApplicantIdMap.get(con.ContentDocumentId))){
                    applicantImagesMap.put(conDocIdToApplicantIdMap.get(con.ContentDocumentId), con.ContentDocumentId);
                }
            }
            for (Applicant__c each : loanRecord.Applicants__r) {
                if (applicantImagesMap.get(each.Id) != null) {
                    mapApplicantImage.put(each.Id, '/sfc/servlet.shepherd/document/download/' + applicantImagesMap.get(each.Id));
                }
            }
        }

        for (Applicant_Financials_Details__c each : [SELECT Company_Name__c, Total_Work_Experience__c, Applicant__r.RecordType.Name, Applicant__r.RecordType.DeveloperName,
            Sector__c FROM Applicant_Financials_Details__c
            WHERE Applicant__c IN :applicantIds AND RecordType.Name = 'Financial Parent' ORDER BY CreatedDate DESC]) {
            applicantFinancialsMap.put(each.Applicant__c, each);
            if (each.Total_Work_Experience__c != null) {
                Integer workExpInNum = Integer.valueOf(each.Total_Work_Experience__c);
                workExpMap.put(each.Applicant__c, new Map<String, Integer>{'Months' => Math.mod(workExpInNum, 12), 'Years' => workExpInNum/12});
            }
        }

        Set<Id> applicantsAdded = new Set<Id>();
        DocumentChecklistWrapper docWrapper;
        List<String> currentList;
        for (Document_Checklist__c objDoc : [SELECT Id, Applicant__c, Applicant__r.Applicant_Name__c, Applicant__r.Title__c, Applicant__r.First_Name__c,
            Applicant__r.Middle_Name__c, Applicant__r.Last_Name__c, Document_Master__c, Document_Master__r.Document_Name__c
            FROM Document_Checklist__c WHERE Applicant__c IN: applicantIds AND Status__c IN ('Received', 'Verified', 'Approved') ORDER BY Applicant__c]) {
            if (!applicantsAdded.contains(objDoc.Applicant__c)) {
                if (docWrapper != null) {
                    if (currentList.size() < 3) {
                        for (Integer i = currentList.size(); i < 3; i++) {
                            currentList.add('');
                        }
                        docWrapper.documentNames.add(currentList);
                    }
                    documentChecklists.add(docWrapper);
                }
                docWrapper = new DocumentChecklistWrapper();
                docWrapper.applicantName = objDoc.Applicant__r.Applicant_Name__c == null ? objDoc.Applicant__r.First_Name__c : objDoc.Applicant__r.Applicant_Name__c;
                docWrapper.documentNames = new List<List<String>>();
                currentList = new List<String>();
                applicantsAdded.add(objDoc.Applicant__c);
            }
            if (currentList.size() == 3) {
                docWrapper.documentNames.add(currentList);
                currentList = new List<String>();
            }
            currentList.add(objDoc.Document_Master__r.Document_Name__c);
        }
        if (docWrapper != null) {
            documentChecklists.add(docWrapper);
        }

        for (Address__c each : [SELECT Id, Address_Type__c,Applicant__r.RecordTypeId, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Land_mark__c, District__c, City__c, State__c,
            Pincode__c, Stability__c, Applicant__c, Status__c FROM Address__c WHERE Applicant__c IN :applicantIds AND Source_Type__c IN (null, 'CBS', '')]) {
            addressMap.get(each.Applicant__c).put(each.Address_Type__c, each);
        }

        if (!String.isBlank(loanRecord.References__c)) {
            String jsonString = loanRecord.References__c;
            if (jsonString.startsWith('{')) {
                References singleRef = (References) JSON.deserialize(jsonString, References.class);
                references.add(singleRef);
                references.add(new References());
            } else if (jsonString.startsWith('[')) {
                List<References> tempReferences = (List<References>) JSON.deserialize(jsonString, List<References>.class);
                if (tempReferences.size() >= 2) {
                    references.add(tempReferences.get(0));
                    references.add(tempReferences.get(1));
                } else if (tempReferences.size() == 1) {
                    references.add(tempReferences.get(0));
                    references.add(new References());
                } else {
                    references.add(new References());
                    references.add(new References());
                }
            }
        } else {
            references.add(new References());
            references.add(new References());
        }
        
        List<Collateral__c> lstPropertyOffered = [SELECT Id, Collateral_Type__c, Current_Owner_Name__c,Make__c, Model__c, Manufacture_Year__c, Manufacture_year_month__c, Approved_LTV__c, Variant__c, MMV_Master__c , MMV_Master__r.Name,
                                                 Ex_Showroom_Price__c, Discount__c, Net_of_Discount_Price__c, On_Road_Price__c, LTV__c, Collateral_Name__c, Loan__r.Dealer_Master__r.Name,
                                                 Invoice_Status__c, Land_Area__c, Address_Line_1__c FROM Collateral__c WHERE Loan__c =:loanApplicationId
                                                 AND Collateral_Type__c = 'Property' AND RecordType.Name = 'Existing Collateral'];
        
        List<Collateral__c> lstCollateral = [SELECT Id, Collateral_Type__c, Current_Owner_Name__c,Make__c, Model__c,Manufacture_Year__c, Manufacture_year_month__c, Approved_LTV__c, Variant__c,MMV_Master__c , MMV_Master__r.Name,
                                                 Ex_Showroom_Price__c, Discount__c, Net_of_Discount_Price__c, On_Road_Price__c, LTV__c, Collateral_Name__c, Loan__r.Dealer_Master__r.Name,
                                                 Invoice_Status__c, Land_Area__c, Address_Line_1__c FROM Collateral__c WHERE Loan__c =:loanApplicationId AND
                                               (RecordType.Name = 'Used/Cash on Wheels' OR RecordType.Name = 'New') Order by CreatedDate ASC];
        if (!lstCollateral.isEmpty() && lstCollateral.size() > 0) {
            collateral = lstCollateral[0];
            marginMoneyStr = collateral.On_Road_Price__c != null && loanRecord.Loan_Amount__c != null ? (collateral.On_Road_Price__c - loanRecord.Loan_Amount__c).format() : '0';
        }
        lstFleet = [SELECT ID, Financial_Institution_Name__c, HPN_Status__c, Loan_Tenure__c, MFG_Year__c, Relationship_with_borrower__c, Vehicle_Make_Model__c, Vehicle_Number__c FROM Fleet__c WHERE Loan_Application__c =:loanApplicationId];
        bankAccounts = [SELECT Id, Account_Closing_Date__c, Account_Number__c, Bank_Name__c, Name_of_the_Financier__c, Type_of_Loan__c, Tenure__c, EMI_Amount__c, Loan_Amount__c
            FROM Bank_Account_Records__c WHERE Applicant__c IN :mapDocCheckApplicantId.keySet() AND Account_Closing_Date__c = null];
    }
    
    public class References {
        public String Mobile_Number{get;set;}
        public String Address{get;set;}
        public String IsActive{get;set;}
        public String Name{get;set;}
        public String Relationship_With_Borrower {get;set;}
        public References(){
            Mobile_Number = '';
            Address = '';
            IsActive = '';
            Name = '';
            Relationship_With_Borrower = '';
        }
    }
}