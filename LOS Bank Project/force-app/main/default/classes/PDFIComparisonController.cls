public with sharing class PDFIComparisonController {
    static final Set<String> COMPARISON_MD = new Set<String>{'Asset_Delivery_Status_FI', 'Asset_Delivery_Status', 'SECTION_B_Tractor_FI', 'SECTION_B_Tractor',
        'LAND_HOLDING_DETAILS_ACRE_FI', 'LAND_HOLDING_DETAILS_ACRE'};

    @AuraEnabled
    public static ReturnWrapper fetchDetails(String loanId) {
        ReturnWrapper returnInst = new ReturnWrapper();
        Map<String, Object> fiData = new Map<String, String>();
        Map<String, Object> pdData = new Map<String, String>();
        Set<Id> linkedIds = new Set<Id>();
        String fiKeyPrefix = Field_Investigation__c.SObjectType.getDescribe().getKeyPrefix();
        Id fieldInvestigationId;
        for (Loan_Application__c each : [SELECT Id, (SELECT Id FROM Field_Investigations__r WHERE Applicant__r.RecordType.DeveloperName = 'Primary_Applicant'
            AND Address_lookup__r.Address_Type__c = 'Current') FROM Loan_Application__c WHERE Id = :loanId]) {
            for (Field_Investigation__c eachFI : each.Field_Investigations__r) {
                fieldInvestigationId = eachFI.Id;
                linkedIds.add(eachFI.Id);
            }
            linkedIds.add(each.Id);
        }

        /*if (String.isBlank(fieldInvestigationId)) {
            returnInst.errorMessage = 'Field Investigation for Primary Applicant\'s Current address is not available for comparison';
            return returnInst;
        }*/

        for (ContentDocumentLink each : [SELECT Id, ContentDocument.LatestPublishedVersion.VersionData, LinkedEntityId FROM ContentDocumentLink
            WHERE LinkedEntityId IN :linkedIds AND ContentDocument.LatestPublishedVersion.Document_Type__c = 'Personal Discussion']) {
            if (String.valueOf(each.LinkedEntityId).substring(0, 3) == fiKeyPrefix) {
                fiData = getNameValuePairs(each.ContentDocument.LatestPublishedVersion.VersionData.toString());
            } else {
                pdData = getNameValuePairs(each.ContentDocument.LatestPublishedVersion.VersionData.toString());
            }
        }

        /*if (fiData.isEmpty()) {
            returnInst.errorMessage = 'FI Form is incomplete. Please await this data to view the comparison';
            return returnInst;
        }
        if (pdData.isEmpty()) {
            returnInst.errorMessage = 'PD is incomplete. Please await this data to view the comparison';
            return returnInst;
        }*/

        returnInst.tableValuesInst = new List<TableValues>();

        EditTableWrapper assetDeliveryFI = fiData?.get('Asset_Delivery_Status_FI') != null ? (EditTableWrapper) JSON.deserialize(JSON.serialize(fiData.get('Asset_Delivery_Status_FI'))
            .replace('\\', '').removeStart('"').removeEnd('"'), EditTableWrapper.class) : new EditTableWrapper();
        EditTableWrapper assetDeliveryPD = pdData?.get('Asset_Delivery_Status') != null ? (EditTableWrapper) JSON.deserialize(JSON.serialize(pdData.get('Asset_Delivery_Status'))
            .replace('\\', '').removeStart('"').removeEnd('"'), EditTableWrapper.class) : new EditTableWrapper();
        EditTableWrapper assetDetailsFI = fiData?.get('SECTION_B_Tractor_FI') != null ? (EditTableWrapper) JSON.deserialize(JSON.serialize(fiData.get('SECTION_B_Tractor_FI'))
            .replace('\\', '').removeStart('"').removeEnd('"'), EditTableWrapper.class) : new EditTableWrapper();
        EditTableWrapper assetDetailsPD = pdData?.get('SECTION_B_Tractor') != null ? (EditTableWrapper) JSON.deserialize(JSON.serialize(pdData.get('SECTION_B_Tractor'))
            .replace('\\', '').removeStart('"').removeEnd('"'), EditTableWrapper.class) : new EditTableWrapper();
        EditTableWrapper landDetailsFI = fiData?.get('LAND_HOLDING_DETAILS_ACRE_FI') != null ? (EditTableWrapper) JSON.deserialize(JSON.serialize(fiData.get('LAND_HOLDING_DETAILS_ACRE_FI'))
            .replace('\\', '').removeStart('"').removeEnd('"'), EditTableWrapper.class) : new EditTableWrapper();
        EditTableWrapper landDetailsPD = pdData?.get('LAND_HOLDING_DETAILS_ACRE') != null ? (EditTableWrapper) JSON.deserialize(JSON.serialize(pdData.get('LAND_HOLDING_DETAILS_ACRE'))
            .replace('\\', '').removeStart('"').removeEnd('"'), EditTableWrapper.class) : new EditTableWrapper();

        String fiAssetStatus = '';
        String pdAssetStatus = '';
        if (assetDeliveryFI?.value?.tableData != null) {
            for (TableData each : assetDeliveryFI?.value?.tableData) {
                fiAssetStatus += each.assetLabel + ' - ' + each.inputField + '\n';
            }
        }
        if (assetDeliveryPD?.value?.tableData != null) {
            for (TableData each : assetDeliveryPD?.value?.tableData) {
                pdAssetStatus += each.assetLabel + ' - ' + each.inputField + '\n';
            }
        }
        returnInst.tableValuesInst.add(new TableValues('Asset Delivery Status', fiAssetStatus, pdAssetStatus));

        Map<String, String> fiAssetDetails = new Map<String, String>();
        Map<String, String> pdAssetDetails = new Map<String, String>();
        Set<String> assetNames = new Set<String>{'Milch Animals', 'Tractor', 'CV / JCB', 'Combine Harvester', 'Agri Land (s)', 'Four wheelers'};
        if (assetDetailsFI?.value?.tableData != null) {
            for (TableData each : assetDetailsFI?.value?.tableData) {
                if (assetNames.contains(each.secAsset1)) {
                    fiAssetDetails.put(each.secAsset1, 'No: - ' + each.secNo1 + ', Approx Value - ' + each.secApproxVal1);
                }
                if (assetNames.contains(each.secAsset2)) {
                    fiAssetDetails.put(each.secAsset2, 'No: - ' + each.secNo2 + ', Approx Value - ' + each.secApproxVal2);
                }
            }
        }
        if (assetDetailsPD?.value?.tableData != null) {
            for (TableData each : assetDetailsPD?.value?.tableData) {
                if (assetNames.contains(each.secAsset1)) {
                    pdAssetDetails.put(each.secAsset1, 'No: - ' + each.secNo1 + ', Approx Value - ' + each.secApproxVal1);
                }
                if (assetNames.contains(each.secAsset2)) {
                    pdAssetDetails.put(each.secAsset2, 'No: - ' + each.secNo2 + ', Approx Value - ' + each.secApproxVal2);
                }
            }
        }
        for (String each : assetNames) {
            returnInst.tableValuesInst.add(new TableValues(each, fiAssetDetails.get(each), pdAssetDetails.get(each)));
        }

        Map<String, String> fiLandDetails = new Map<String, String>();
        Map<String, String> pdLandDetails = new Map<String, String>();
        Set<String> landParameters = new Set<String>{'Survey No./Block', 'No./Khata No.', 'Total Land', 'Total Irrigated Land'};
        if (landDetailsFI?.value?.tableData != null) {
            for (TableData each : landDetailsFI?.value?.tableData) {
                if (!landParameters.contains(each.landHeadRow)) {
                    continue;
                }
                fiLandDetails.put(each.landHeadRow, each.landAnotherOneRow);
            }
        }
        if (landDetailsPD?.value?.tableData != null) {
            for (TableData each : landDetailsPD?.value?.tableData) {
                if (!landParameters.contains(each.landHeadRow)) {
                    continue;
                }
                pdLandDetails.put(each.landHeadRow, each.landAnotherOneRow);
            }
        }
        for (String each : landParameters) {
            returnInst.tableValuesInst.add(new TableValues(each, fiLandDetails.get(each), pdLandDetails.get(each)));
        }

        return returnInst;
    }

    private static Map<String, Object> getNameValuePairs(String jsonString) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Object> nameValuePairs = (List<Object>) JSON.deserializeUntyped(jsonString);
        for (Object each : nameValuePairs) {
            Map<String, Object> eachDS = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(each));
            if (COMPARISON_MD.contains((String) eachDS.get('name'))) {
                returnMap.put((String) eachDS.get('name'), eachDS.get('value'));
            }
        }
        return returnMap;
    }

    public class ReturnWrapper {
        @AuraEnabled public String errorMessage;
        @AuraEnabled public List<TableValues> tableValuesInst;
    }

    public class TableValues {
        @AuraEnabled public String parameter;
        @AuraEnabled public Boolean isSame;
        @AuraEnabled public String fiValue;
        @AuraEnabled public String pdValue;

        public TableValues(String parameter, String fiValue, String pdValue) {
            this.parameter = parameter;
            this.fiValue = fiValue;
            this.pdValue = pdValue;
            this.isSame = fiValue == pdValue;
        }
    }

    public class EditTableWrapper {
        public DataTableDefinition value;
    }

    public class DataTableDefinition {
        public List<TableData> tableData;
    }

    public class TableData {
        public String assetLabel;
        public String inputField;
        public String secAsset1;
        public String secNo1;
        public String secApproxVal1;
        public String secAsset2;
        public String secNo2;
        public String secApproxVal2;
        public String landHeadRow;
        public String landAnotherOneRow;
        public String landAnotherTwoRow;
    }
}