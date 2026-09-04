/**
 * Created by ngundurao on 27/10/22.
 */

public with sharing class CustomerSearchRequestWrapper {
    public String RequestId{get; set;}
    public String Channel {get; set;}
    public String PanNumber {get; set;}
    public String ReferenceNumber {get; set;}
    public String TransactionBranch {get; set;}
    public String CustomerId {get; set;}
    public String MobileNumber {get; set;}
    public String AadhaarNumber {get; set;}
}