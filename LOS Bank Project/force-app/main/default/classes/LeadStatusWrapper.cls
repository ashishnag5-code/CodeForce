/*****
 * Class Name: LeadStatusWrapper
 * Description: Attribute wrapper for Lead Status
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-28-2023          -   Mohit Maheshwari    -   Attribute wrapper for Lead Status
 */
public with sharing class LeadStatusWrapper {
    public String LoanReferenceNumber { get; set; }
    public String FinancierId { get; set; }
    public String ApplicationStatus { get; set; }
    public String LastUpdatedTimestamp { get; set; }
    public String StatusComment { get; set; }
    public String ApprovedTenure { get; set; }
    public String ApprovedROI { get; set; }
    public String ApprovedLoanAmount { get; set; }
    public String ApproverComment { get; set; }
    public String LoanTypeId { get; set; }
    public String ApplicantId { get; set; }
    public String ProcessingFee { get; set; }
    public String Address1 { get; set; }
    public String Address2 { get; set; }
    public String Address3 { get; set; }
    public String Address4 { get; set; }
    public String AddressTypeId { get; set; }
    public String DistrictId { get; set; }
    public String StateId { get; set; }
    public String PinCode { get; set; }
    public String CityId { get; set; }
    public String Country { get; set; }
    public String Landmark { get; set; }
    public List<DocumentReuploadListWrapper> DocumentReuploadList { get; set; }

    public class DocumentReuploadListWrapper{
        public String BankCode='';
        public String RejectReason='';
        public String DocID='';
        public String DocTypeId='';
        public DocumentReuploadListWrapper (){}
    }

    public LeadStatusWrapper (){
        LoanReferenceNumber='';
        FinancierId='';
        ApplicationStatus='';
        LastUpdatedTimestamp='';
        StatusComment='';
        ApprovedTenure='';
        ApprovedROI='';
        ApprovedLoanAmount='';
        ApproverComment='';
        LoanTypeId='';
        ApplicantId='';
        ProcessingFee='';
        Address1='';
        Address2='';
        Address3='';
        Address4='';
        AddressTypeId='';
        DistrictId='';
        StateId='';
        PinCode='';
        CityId='';
        Country='';
        Landmark='';
        DocumentReuploadList = null;
    }
}