public class CIBILNonIndividualHandler {
    
    public String generateNonIndividualCibilRequest(String applicantRecId) {
        String requestBody;
        System.debug('applicantRecId'+applicantRecId);
        
        Applicant__c appObj;
        if(applicantRecId != null){
            appObj = [Select Id, Loan__r.Loan_Amount__c, Loan__r.Product__c, PAN__c, CIN__c, Entity_Name__c, Date_of_Establishment__c, (Select Id,Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Type__c, City__c, Pincode__c, Type__c, State__c, Office_Number__c from Addresses__r where Address_Type__c = 'Office') from Applicant__c where Id =: applicantRecId WITH SECURITY_ENFORCED];
        }
        
        LosNonIndividualCibilRequestWrapper reqObj = new LosNonIndividualCibilRequestWrapper();
        LosNonIndividualCibilRequestWrapper.RequestInfo reqInfoObj = new LosNonIndividualCibilRequestWrapper.RequestInfo();
        LosNonIndividualCibilRequestWrapper.ApplicationData appData = new LosNonIndividualCibilRequestWrapper.ApplicationData();
        LosNonIndividualCibilRequestWrapper.Applicant applicant = new LosNonIndividualCibilRequestWrapper.Applicant();
        LosNonIndividualCibilRequestWrapper.RegisteredAddress address = new LosNonIndividualCibilRequestWrapper.RegisteredAddress();
        LosNonIndividualCibilRequestWrapper.Fields fields = new LosNonIndividualCibilRequestWrapper.Fields();
        LosNonIndividualCibilRequestWrapper.Field field = new LosNonIndividualCibilRequestWrapper.Field();
        LosNonIndividualCibilRequestWrapper.Applicants applicantList = new LosNonIndividualCibilRequestWrapper.Applicants();
        
        String RequestId = IntegrationUtility.getReferenceId();
        reqObj.RequestId = RequestId.left(2) + RequestId.right(RequestId.length()-4);
        reqObj.OriginatingChannel = 'SFDC';
        
        //RequestInfo 
        reqInfoObj.SolutionSetId = 50;
        reqInfoObj.SolutionSetVersion = 1;
        reqInfoObj.ExecutionMode  = 'NewWithContext';
        reqInfoObj.EnvironmentId = 1;
        reqObj.RequestInfo = reqInfoObj;
        
        //RegisteredAddress
        if(appObj.Addresses__r!= null && appObj.Addresses__r.size()>0){
            Address__c offcAdd = appObj.Addresses__r[0];
            address.AddressLine1 = offcAdd.Address_Line_1__c;
            address.AddressLine2 = offcAdd.Address_Line_2__c;
            address.AddressLine3 = offcAdd.Address_Line_3__c;
            address.AddressPincode = Integer.valueOf(offcAdd.Pincode__c);
            address.AddressType = 'REGISTERED OFFICE';
            address.AddressCity = offcAdd.City__c;
            //address.AddressStateCode = ;
        }
        
        //Applicant
        applicant.ApplicantType = 'Company';
        applicant.PAN = appObj.PAN__c;
        applicant.CIN = appObj.CIN__c;
        applicant.CompanyName = appObj.Entity_Name__c;
        applicant.DateOfRegistration = ''+appObj.Date_of_Establishment__c;
        applicant.FacilityCategory = ''; //to be confirmed with Shashank
        applicant.FacilityType = 'NEW LOAN';
        applicant.TypeOfEntity = ''; //mapping to be added in metadata
        applicant.MemberReferenceNumber = 'Wheels';
        applicant.ClassOfActivity = 'LOANS FOR PURCHASE OF MOTOR VEHICLE & TWO WHEELERS - OTHER THAN STAFF';
        applicant.RegisteredAddress = address;
        applicantList.Applicant = applicant;
        field.Applicants = applicantList;
        
        //Application Data
        appData.LitigationReport = 'false'	;
	    appData.CommercialCIR = true;
        appData.ConsumerCIR = true;
        appData.NoOfDirector = 0;
        appData.FormattedReport = true;
        appData.GSTStateCode = '';
        appData.Amount = Integer.valueOf(appObj.Loan__r.Loan_Amount__c);
        appData.MemberReferenceNumber = 'Wheels';
        field.ApplicationData = appData;
        fields.Field = field;
        reqObj.Fields = fields;
        requestBody = JSON.serialize(reqObj, true);
        System.debug('request: '+requestBody);
        
        return requestBody;
    }
}