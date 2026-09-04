global class GenericWizardScreenConfigList extends VisualEditor.DynamicPickList{
    VisualEditor.DesignTimePageContext context;
    
    /**
     * Description: Default Constructor for Design Attibute
     */
    global GenericWizardScreenConfigList(VisualEditor.DesignTimePageContext context) {
       this.context = context;
    }
    
    /**
     * Description: Set Default value for Design Attibute
     */
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', '');
        return defaultValue;
    }
    
    /**
     * Description: Get Related Child Object for given Parent Object for picklist in Design Attibute
     */
     
    global override VisualEditor.DynamicPickListRows getValues() {
        Set<String> setFlowName = new Set<String>();
        String strSObjectName = context.entityName;
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        for (Generic_Wizard_Flow_Config__mdt objgw : Generic_Wizard_Flow_Config__mdt.getAll().values()) {
            if(!setFlowName.contains(objgw.Flow_Name__c)){
                setFlowName.add(objgw.Flow_Name__c);
                VisualEditor.DataRow value1 = new VisualEditor.DataRow(String.valueOf(objgw.Flow_Name__c), String.valueOf(objgw.Flow_Name__c));  
                myValues.addRow(value1);
            }
        }
        return myValues;
    }
}