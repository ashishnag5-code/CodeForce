public class DataTableColumnTypeAttributeWrapper {
    @auraEnabled
    public string weekday 											{get;set;}
    @auraEnabled
    public string year 												{get;set;}
    @auraEnabled
    public string month 											{get;set;}
    @auraEnabled
    public string day 												{get;set;}
    @auraEnabled
    public string hour 												{get;set;}
    @auraEnabled
    public string minute 											{get;set;}
    @auraEnabled
    public string currencyCode  									{get;set;}
    @auraEnabled
    public FieldName label  										{get;set;}
    
    public class FieldName{
        @auraEnabled
    	public string fieldName   									{get;set;}
    }

}