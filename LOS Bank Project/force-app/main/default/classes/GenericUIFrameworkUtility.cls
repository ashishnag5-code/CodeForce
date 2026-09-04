public with sharing class GenericUIFrameworkUtility {

    public static String getIconName(String searchObject){
        System.debug('Sobject name - '+searchObject);
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { 
            tabDesc.addAll(tsr.getTabs()); 
        }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( searchObject == tr.getSobjectName() ) {
                if( tr.isCustom() ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + searchObject.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return iconName != NULL? iconName: 'standard:default';
    } 
    
    public Static Map<String,Schema.SObjectField> getAllFields(String sobjectAPIName){
        Map<String,Schema.SObjectField> mfields;
        if(String.isNotBlank(sobjectAPIName)){
            SObjectType accountType = Schema.getGlobalDescribe().get(sobjectAPIName);
        	mfields = accountType.getDescribe().fields.getMap();
        }
        return mfields;
    }
    
    public Static List<DataTableColumnWrapper> getDataTableColumns(String sobjectAPIName, List<String> fieldAPINames){
        List<DataTableColumnWrapper> dataTableColumnList = new List<DataTableColumnWrapper>();
        if(String.isNotBlank(sobjectAPIName) && fieldAPINames != NULL){
            Map<String,Schema.SObjectField> mfieldsMap = getAllFields(sobjectAPIName);
            DataTableColumnWrapper columnWrapper;
            Schema.DescribeFieldResult  fieldDescribeInstance;
            for(String fieldRec : fieldAPINames){
                columnWrapper = new DataTableColumnWrapper();
                fieldDescribeInstance = mfieldsMap.get(fieldRec).getDescribe();
                columnWrapper.label = fieldDescribeInstance.getLabel();
                columnWrapper.fieldName = fieldDescribeInstance.getName();
                if(columnWrapper.fieldName == 'Name'){
                    columnWrapper.fieldName = 'NameURL';
                    columnWrapper.type = 'url';
                    columnWrapper.typeAttributes = new DataTableColumnTypeAttributeWrapper();
                    columnWrapper.typeAttributes.label = new DataTableColumnTypeAttributeWrapper.FieldName();
                    columnWrapper.typeAttributes.label.fieldName = 'Name';
                }else if(fieldDescribeInstance.getType().name() == 'BOOLEAN'){
                    columnWrapper.type = 'checkbox';
                }else if(fieldDescribeInstance.getType().name() == 'URL'){
                    columnWrapper.type = 'url';
                }else if(fieldDescribeInstance.getType().name() == 'PHONE'){
                    columnWrapper.type = 'phone';
                }else if(fieldDescribeInstance.getType().name() == 'Email'){
                    columnWrapper.type = 'email';
                }else if(fieldDescribeInstance.getType().name() == 'CURRENCY'){
                    columnWrapper.type = 'currency';
                }else{
                    columnWrapper.type = 'text';
                }
                columnWrapper.hideDefaultActions = true;
                dataTableColumnList.add(columnWrapper);
            }
        }
		return dataTableColumnList;
    }
    
    public Static String getRecordUrl(String recordId, String sobjectAPIName){
        return URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/'+recordId+'/view';
    }

}