/**
* @author        Joshna Palla
* @date          28/07/2022
* @description   Implement this interface for all interface handlers
* Modification Log:
* --------------------------------------------------------------------------------------------
* Developer            Date            Description
* --------------------------------------------------------------------------------------------
* Joshna Palla         28/07/2022      Original Version
* --------------------------------------------------------------------------------------------
*/
public interface IntegrationHandlerInterface {
    /* This interface method should be implemented for all auto integrations. Manual integrations
     * can leave this method blank. All auto integrations should internally use generateRequest method
     * to get the XML/JSON request structure. This method should generate "Common Callout Events" or
     * "Common Callout Large Payload Events" with following values - 
     * 1. Request - use generateRequest to get this for each record
     * 2. Event Type - will be a constant specific to each integration (for instance NSDL, CIBIL)
     * 3. Event Reference ID - Unique ID (usually external ID of integration checklist record)
     * 4. Document ID - for large payload interfaces, content version ID
     * Parameters - pass a list of objects
     * In the method implementation, this list can be typecasted to any inner class list or sObject list
     * This will allow more flexibility to pass parameters from multiple object entities wherever applicable
     */
    //List<sObject> generatePlatformEvents(List<Object> recordList);

    /* This interface method should be implemented for all auto & manual integrations
     * Manual integrations will call this method with a single record instance. Auto integrations will call
     * this method from generatePlatformEvents with a list of records. This method should use the request
     * sample and schema of every interface to generate an XML or JSON structure and return that as a list of
     * strings
     * For auto integrations, this request body will be a field value in platform event
     * For manual integrations, this request body will be used in HTTP body for request HTTP instance
     * 
     * Parameters - pass a list of objects
     * In the method implementation, this list can be typecasted to any inner class list or sObject list
     * This will allow more flexibility to pass parameters from multiple object entities wherever applicable
     */
    List<Object> generateRequest(List<Object> recordList);

    /* This interface method should be called before every auto & manual interface is initiated
     * This method is responsible for validating if the minimal required inputs for that interface are already added
     * If all inputs are available, this method will return null or a blank string
     * If any input is missing, this method should return the consolidated list of validations which can be used in
     * LWC component to display for manual integrations. For auto integrations, this string will be used to save
     * the validations in checklist. LWC of each interface should read this when status = Pre-requisites Missing
     * and display on UI for user to take corrective actions
     * Input parameters are list of objects/wrappers that have the necessary input data for this interface
     */
    String generateJSONResponse(List<Object> recordList);

    /* This interface method is called after interface status changes - regardless of success or failure. In case
     * the response is a success, callback service will update the related records with information from the response.
     * For failure - this is optional in case previous callback data has to be cleared
     */
    //void callbackService(List<Integration_Checklist__c> checklistRecords, List<ContentVersion> responseFiles);

    /* This interface method is called whenever an interface is marked completed. This method reviews the response and
     * identifies from the tags if there is a failure of if the response is complete. These are instances where even
     * if the endpoint returns 200 OK, there may be a failure in the endpoint. This caters to such instances by updating
     * integration checklist to the right status. Integration Checklist trigger calls this method in before events. If in
     * addition to setting status, if additional parameters are required, use this method
     */
    //void beforeUpdateService(Integration_Checklist__c checklistRecord, ContentVersion responseFile);

    /* This interface method should be called before every auto & manual interface is initiated
    * This method is responsible for validating if the minimal required inputs for that interface are already added
    * If all inputs are available, this method will return null or a blank string
    * If any input is missing, this method should return the consolidated list of validations which can be used in
    * LWC component to display for manual integrations. For auto integrations, this string will be used to save
    * the validations in checklist. LWC of each interface should read this when status = Pre-requisites Missing
    * and display on UI for user to take corrective actions
    * Input parameters are list of objects/wrappers that have the necessary input data for this interface
    */
    //List<String> validateInputData(List<Object> recordList);
}