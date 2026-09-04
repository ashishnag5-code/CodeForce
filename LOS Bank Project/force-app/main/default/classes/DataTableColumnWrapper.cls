public class DataTableColumnWrapper {
    @auraEnabled
    public string label 											{get;set;}
    @auraEnabled
    public string fieldName 										{get;set;}
    @auraEnabled
    public string type 												{get;set;}
    @auraEnabled
    public Boolean hideDefaultActions  								{get;set;}
    @auraEnabled
    public DataTableColumnTypeAttributeWrapper typeAttributes  		{get;set;}
}