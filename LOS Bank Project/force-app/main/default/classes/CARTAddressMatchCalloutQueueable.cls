public with sharing class CARTAddressMatchCalloutQueueable implements Queueable, Database.AllowsCallouts{
    
    public String applicantId;
    public String address;
    public String calloutType;
    public String accountHolderName;

    public CARTAddressMatchCalloutQueueable(String recordId, String cartAddress, String type, String accHolderName) {
        applicantId = recordId;
        address = cartAddress;
        calloutType = type;
        accountHolderName = accHolderName;
    }

    public void execute(QueueableContext context){

        if(calloutType == 'Address Split'){
            MultipleFileUploadController.futureCalloutForSplit(address, applicantId,accountHolderName);
            /*CARTAddressMatchCalloutQueueable newQueuableClass2 = new CARTAddressMatchCalloutQueueable(applicantId, address, 'Address Match');
            Id jobId2 = System.enqueueJob(newQueuableClass2);   */
        }

        if(calloutType == 'Address Match'){
            LOSKarzaAddressMatchController.addressMatchForCART(applicantId, address);
            MultipleFileUploadController.callNameMatchForCart(address, applicantId,accountHolderName);
        }

        if(calloutType == 'Name Match'){
            LOSKarzaNameMatchController.validateNameMatch(accountHolderName, 'Bank Statement', applicantId, '');
        }
    }
}