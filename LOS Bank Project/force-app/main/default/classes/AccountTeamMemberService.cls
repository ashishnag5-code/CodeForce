/**
 * @description       : 
 * @author            : Mohit M. | Salesforce
 * @group             : 
 * @last modified on  : 16-01-2023
**/
public with sharing class AccountTeamMemberService {
    
    //Declare variables
    public static string userDesignation;
    public static Set<String> zipCodeSet;
    public static Set<String> setAccountId;
    
    /**
    * @description 
    * @author Mohit M | Salesforce | 16-01-2023 
    * @return String 
    **/
    public static String createQuery() {
        return 'Id, UserId, User.Name,Zip_Code__c, Account.Account_Code__c, User.IsActive, Approver_Level__c, Active__c ';
    }

    /**
    * @description 
    * @author Mohit M | Salesforce | 16-01-2023 
    * @param whereClause 
    * @return List<Document_Checklist__c> 
    **/
    public static List<AccountTeamMember> getAccountTeamMember(String whereClause){
        String queryString ='';
        if(String.isNotBlank(whereClause)){
            queryString = 'SELECT ' + createQuery() + ' FROM AccountTeamMember ' + whereClause + ' WITH SECURITY_ENFORCED';
        }else{
            queryString = 'SELECT ' + createQuery() + ' FROM AccountTeamMember WITH SECURITY_ENFORCED' ;
        }
        system.debug('queryString'+queryString);
        return Database.query(queryString);
	}
}