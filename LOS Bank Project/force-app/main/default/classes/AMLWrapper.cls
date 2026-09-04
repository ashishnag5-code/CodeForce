public class AMLWrapper {
    	    	
	@AuraEnabled public String userid       {get;set;}
	@AuraEnabled public String refid        {get;set;}
	@AuraEnabled public String referenceid  {get;set;}
	@AuraEnabled public String callbackurl  {get;set;}
	@AuraEnabled public String batchmode    {get;set;}
	@AuraEnabled public String systemname   {get;set;}
	@AuraEnabled public String datetimex    {get;set;}
	@AuraEnabled public List<Fields> fields {get;set;}
    @AuraEnabled public Status status       {get;set;}

	public class Fields {
		@AuraEnabled public String name  {get;set;}
		@AuraEnabled public String value {get;set;}
	}

	@AuraEnabled public String MATCH		       {get;set;}
	// public String AmlAction		   {get;set;}
	@AuraEnabled public String AML_ACTION    {get;set;}
	public class Status{
		@AuraEnabled public String errorDetails    {get;set;}
		@AuraEnabled public String status          {get;set;}
	}

	@AuraEnabled public String errorMessage  {get;set;}
	@AuraEnabled public String errorCode     {get;set;}

}