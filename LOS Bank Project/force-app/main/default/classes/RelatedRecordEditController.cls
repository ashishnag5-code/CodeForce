/**
 * @author        Joshna
 * @date          20-Jul-2023
 * @description   Controller class for Custom Related Record
 * @reference     Use this to display related record sections for communities
 * Modification Log:
 * --------------------------------------------------------------------------------------------
 * Developer               Date            Description
 * --------------------------------------------------------------------------------------------
 * Joshna                  20-Jul-2023     Initial creation - added fetchFields
 */
public without sharing class RelatedRecordEditController {
    public static final Map<Schema.DisplayType, String> DATA_TYPE_TO_COL_TYPE_MAP = new Map<Schema.DisplayType, String>{
        Schema.DisplayType.Date => 'date',
        Schema.DisplayType.Currency => 'currency',
        Schema.DisplayType.Phone => 'phone',
        Schema.DisplayType.URL => 'url',
        Schema.DisplayType.String => 'string',
        Schema.DisplayType.TextArea => 'string',
        Schema.DisplayType.Picklist => 'string'
    };

    @AuraEnabled(cacheable=true)
    public static ReturnWrapper getFieldNames(String recordId, String fieldSetName, String relatedLookupName) {
        try{
            ReturnWrapper returnInstance = new ReturnWrapper();
            returnInstance.fieldList = new List<FieldWrapper>();

            if (String.isNotBlank(relatedLookupName)) {
                returnInstance.isRelatedRecord = true;
                returnInstance.objectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
                SObject objectRecord = Database.query('SELECT ' + relatedLookupName + ' FROM ' + returnInstance.objectName + ' WHERE Id = :recordId');
                if (objectRecord.get(relatedLookupName) != null) {
                    returnInstance.relatedRecordId = (String) objectRecord.get(relatedLookupName);
                    returnInstance.objectName = Id.valueOf(returnInstance.relatedRecordId).getSObjectType().getDescribe().getName();
                }
            } else {
                returnInstance.objectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            }

            if (returnInstance.objectName != null) {
                Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
                Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(returnInstance.objectName);
                Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
                Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName); 
                for (Schema.FieldSetMember each : fieldSetObj.getFields()) {
                    returnInstance.fieldList.add(new FieldWrapper(each.getFieldPath(), each.getRequired()));
                }
            }
            return returnInstance;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }    

    @AuraEnabled
    public static QueryResponseWrapper getRelatedRecords(String serializedRequest) {
        try{
            QueryResponseWrapper responseInst = new QueryResponseWrapper();
            RequestWrapper requestInst = (RequestWrapper) JSON.deserialize(serializedRequest, RequestWrapper.class);
            String objectName = Id.valueOf(requestInst.recordId).getSObjectType().getDescribe().getName();
            String query = 'SELECT Id, (SELECT ' + requestInst.fields + ' FROM ' + requestInst.relationshipName;
            if (String.isNotBlank(requestInst.whereClause)) {
                query += ' WHERE ' + requestInst.whereClause;
            }
            if (String.isNotBlank(requestInst.sortBy)) {
                query += ' ORDER BY ' + requestInst.sortBy;
            }
            if (String.isNotBlank(requestInst.sortOrder)) {
                query += ' ' + requestInst.sortOrder;
            }
            if (requestInst.viewAll != null && !requestInst.viewAll && requestInst.numberOfRecords != null) {
            //if (requestInst.numberOfRecords != null && requestInst.numberOfRecords != '') {
                query += ' LIMIT '  + requestInst.numberOfRecords;
            }
            Id recordId = requestInst.recordId;
            query += ') FROM ' + objectName + ' WHERE Id = :recordId';
            system.debug('***** query: ' + query);
            List<Sobject> queryResult = Database.query(query);
            responseInst.columns = new List<ColumnWrapper>();
            for(Integer i = 0; i < queryResult.size(); i++){
                if(queryResult.get(i).getSObjects(requestInst.relationshipName) <> null){
                    responseInst.data = queryResult.get(i).getSObjects(requestInst.relationshipName);
                }
            }
            SObjectType objectDescribe = Schema.getGlobalDescribe().get(requestInst.childAPIName);
            Map<String, Schema.SObjectField> fieldDetails = objectDescribe.getDescribe().fields.getMap();
            Schema.DescribeFieldResult describeResult;
            for (String each : requestInst.fields.split(',')) {                
                describeResult = fieldDetails.get(each.toLowerCase())?.getDescribe();
                if (describeResult == null) {
                    if (each.toLowerCase()?.contains('.')) {
                        describeResult = fieldDetails.get(each.toLowerCase().substringBefore('.').replace('__r', '__c'))?.getDescribe();
                        responseInst.columns.add(new ColumnWrapper(describeResult.getLabel(), each, 'string'));
                    } else {
                        responseInst.columns.add(new ColumnWrapper(describeResult.getLabel(), each, 'string'));
                    }
                } else if (each != 'id' && describeResult.getType() != Schema.DisplayType.Reference){
                    responseInst.columns.add(new ColumnWrapper(describeResult.getLabel(), each, DATA_TYPE_TO_COL_TYPE_MAP.get(describeResult.getType())));
                }
            }
            return responseInst;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class ReturnWrapper {
        @AuraEnabled public String objectName;
        @AuraEnabled public List<FieldWrapper> fieldList;
        @AuraEnabled public String relatedRecordId;
        @AuraEnabled public Boolean isRelatedRecord;
    }

    public class FieldWrapper {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;

        public FieldWrapper(String fieldName, Boolean isRequired) {
            this.fieldName = fieldName;
            this.isRequired = isRequired;
        }
    }

    public class RequestWrapper {
        public String recordId;
        public String childAPIName;
        public String relationshipName;
        public String whereClause;
        public String fields;
        public String sortBy;
        public String numberOfRecords;
        public String sortOrder;
        public Boolean viewAll;
    }

    public class QueryResponseWrapper {
        @AuraEnabled public List<sObject> data;
        @AuraEnabled public List<ColumnWrapper> columns;
    }

    public class ColumnWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String type;
        @AuraEnabled public TypeAttributes typeAttributes;

        public ColumnWrapper(String label, String fieldName, String type) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            if (this.fieldName == 'Name') {
                this.typeAttributes = new TypeAttributes();
                this.typeAttributes.label = new LabelWrapper();
                this.type = 'url';
                this.fieldName = 'RecordLink';
            }
        }
    }

    public class TypeAttributes {
        @AuraEnabled public LabelWrapper label;
        @AuraEnabled public String target = '_blank';
    }

    public class LabelWrapper {
        @AuraEnabled public String fieldName = 'Name';
    }

    public class SectionResultWrapper {
        @AuraEnabled public Boolean isParentObject;
        @AuraEnabled public Boolean isChildObject;
        @AuraEnabled public String childObjIcon;
        @AuraEnabled public String sectionLabel;    
        @AuraEnabled public String parentObjName;
        @AuraEnabled public Map<String, List<String>> mapofParentIdToFields =  new Map<String, List<String>>();
    }
}