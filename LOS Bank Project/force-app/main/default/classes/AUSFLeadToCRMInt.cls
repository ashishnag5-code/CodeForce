public with sharing class AUSFLeadToCRMInt {
    public static final String LEAD_TO_CRM_INT_MASTER_NAME = 'Lead To CRM';
    
    public static map<String, Object> validateAndCallCRMApi( Loan_Application__c leadDetails, Boolean overrideETBFlag ){
        if( leadDetails == null ){
            throw new LeadToCRMApiException( 'Lead details can\'t be blank' );
        } else if( ( leadDetails.Primary_Applicant__r.Existing_Customer__c == 'Yes' && !overrideETBFlag ) && String.isBlank( leadDetails.Primary_Applicant__r.CIF_No__c ) ){ //CIF is required for ETB Customers
            throw new LeadToCRMApiException( 'CIF Number if mandatory for ETB Customers' );
        }

        map<String, Object> result = new map<String, Object>();
        try{
            Integration_Checklist__c checklist = new Integration_Checklist__c( Loan_Application__c = leadDetails.Id );
            Integration_Master__c intMaster = IntegrationUtility.getIntegrationMasterRecord( LEAD_TO_CRM_INT_MASTER_NAME );
            String[] custName = leadDetails.Customer_Name__c?.split(' ');

            map<String, Object> reqParams =  new map<String, Object>{
                'RequestId' => IntegrationUtility.getReferenceId(),
                'Channel' => intMaster.Channel__c,
                'ItemId' => leadDetails.Lead_Id_Ext__c != null ? leadDetails.Lead_Id_Ext__c : '-1', //:TODO verify if lead already in CRM can be updated
                'ItemType' => 'Lead',
                'LayoutId' => Label.LeadToCRMLayoutId,//'102430',
                'LastName' => custName != null && custName.size() > 1 ? custName[custName.size() - 1] : leadDetails.Customer_Name__c,
                'LeadType' => Label.LeadToCRMLeadType,//'1',
                'ProductID' => leadDetails.Product__c,
                'RatingID' => '1',
                'IsMobile' => '1',
                'MobilePhone' => leadDetails.Mobile__c,
                'StampCustName' => leadDetails.Customer_Name__c,
                'TypeofCustomerSA' => ( leadDetails.Primary_Applicant__r.Existing_Customer__c == 'Yes' || !overrideETBFlag ) ? '1' : '2',
                'CIF' => overrideETBFlag ? '' : leadDetails.Primary_Applicant__r.CIF_No__c,
                // 'EntityNew' => '100', //Not in the new specs shared - 13th Nov
                'StatusCodeID' => Label.LeadToCRMStatusCodeID,//'100470',
                'TerritoryID' => Label.LeadToCRMTerritoryID,//'2011',
                'LeadSource' => Label.LeadToCRMLeadSource//'UBL01'
            };

            IntegrationUtility.RequestWrapper requestWrapper = new IntegrationUtility.RequestWrapper();
            requestWrapper.request = AUSFLeadToCRMIntHandler.generateRequest( reqParams )[0];
            requestWrapper.method = intMaster.HTTP_Method__c;
            requestWrapper.masterRecord = intMaster;
            requestWrapper.checklistRecord = checklist;

            IntegrationUtility.ResponseWrapper responseWrapper = IntegrationUtility.doRestCallout( requestWrapper );   
            system.debug('calloutResponseWrapper '+responseWrapper);

            
            result.put( 'statusCode', responseWrapper.statusCode );
            validateAndProcessResponse( result, checklist, responseWrapper );
        } catch( Exception objException ) {
            result.put('message', new String[]{ objException.getMessage() } );
            Log.error( objException, Log.SeverityType.valueOf('High'), leadDetails.Id );
        }
        return result;
    }

    public static void validateAndProcessResponse( map<String, Object> result, Integration_Checklist__c checklist, IntegrationUtility.ResponseWrapper responseWrapper ){
        AUSFLeadToCRMIntHandler.LeadToCRMFailureResopnse failureResponse = (AUSFLeadToCRMIntHandler.LeadToCRMFailureResopnse)JSON.deserialize(
            responseWrapper.response,
            AUSFLeadToCRMIntHandler.LeadToCRMFailureResopnse.class
        );
        System.debug(JSON.serializePretty(failureResponse));

        if( failureResponse.ServiceExecutionStatus != 'ERROR' ){
            AUSFLeadToCRMIntHandler.LeadToCRMSuccessResopnse response = (AUSFLeadToCRMIntHandler.LeadToCRMSuccessResopnse)JSON.deserialize(
                responseWrapper.response,
                AUSFLeadToCRMIntHandler.LeadToCRMSuccessResopnse.class
            );
            System.debug(' == Response ==> ' + JSON.serializePretty(response));
            result.put( 'isSuccess', response.IsSuccess );
            
            if( response.IsSuccess == 'true' && response.TransactionStatus?.ResponseCode == '00' ){
                result.put('leadIdExt', response.LeadId );
                result.put( 'message', new String[]{ response.Message } );
            } else if( response.TransactionStatus?.ExtendedErrorDetails?.messages != null ) {
                if( !result.containsKey( 'message' ) ){
                    result.put( 'message', new String[0] );
                }
                for(AUSFLeadToCRMIntHandler.Cls_Messages msg: response.TransactionStatus.ExtendedErrorDetails.messages){
                    String[] errors = (String[])result.get( 'message' );
                    errors.add( msg.message );

                    result.put( 'message', errors );
                }
            }
        } else {
            String serviceError = failureResponse.Errors?.Error?.Message != null ? failureResponse.Errors.Error.Code + ': ' +failureResponse.Errors.Error.Message : String.format(Label.GenericCalloutErrorMessage, new String[]{ LEAD_TO_CRM_INT_MASTER_NAME, responseWrapper.checklistRecord?.Name });
            result.put('message', new String[]{ serviceError } );
            checklist.Status__c = 'Failed';
            Database.update( checklist, false, AccessLevel.SYSTEM_MODE );
        }
    }

    public class LeadToCRMApiException extends Exception{}
}