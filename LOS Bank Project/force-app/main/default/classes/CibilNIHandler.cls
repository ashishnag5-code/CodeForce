public with sharing class CibilNIHandler {
    public static Map < String, Map < String, String >> mappingValues = new Map < String, Map < String, String >> ();

    public static String validateData(Applicant__c appData){
        String preReqMessage = '';
        if(appData.PAN__c== NULL || appData.PAN__c==''){
            preReqMessage += 'PAN is Mandatory';
        }
        if(appData.Entity_Name__c ==NULL || appData.Entity_Name__c ==''){
            preReqMessage += 'Company Name is Mandatory';
        }
        if(appData.Constitution_Type__c ==NULL || appData.Constitution_Type__c ==''){
            preReqMessage += 'Entity Type is Mandatory';
        }
        if(appData.Date_of_Establishment__c ==NULL){
            preReqMessage += 'Date of Establishment is Mandatory';
        }
        if(appData.addresses__r == NULL || appData.addresses__r.size()==0){
            preReqMessage += 'Registered Address is Mandatory';
        }else if(appData.addresses__r[0]. Address_Line_1__c == NULL || appData.addresses__r[0]. Address_Line_1__c ==''){
            preReqMessage += 'Address Line 1 is Mandatory';
        }
        return preReqMessage;
    }
    public static string generatereq(Applicant__c appData){
        String stateCode = '';
        for (Integration_Mappings__mdt each: [SELECT Id, Endpoint_Value__c, Interface__c, LOS_Value__c, Tag_Name__c 
        FROM Integration_Mappings__mdt WHERE Interface__c = 'CIBIL - NI']) {
            if (!mappingValues.containsKey(each.Tag_Name__c)) {
                mappingValues.put(each.Tag_Name__c, new Map < String, String > ());
            }
            mappingValues.get(each.Tag_Name__c).put(each.LOS_Value__c, each.Endpoint_Value__c);
        }
        Set<String> stateSet = New Set<String>();
        for(Address__c addr: appData.addresses__r){
            if(addr.Address_Type__c == 'Office'){
                stateSet.add(addr.State__c);
            }
        }
        Map<String, String> stateMap = New Map<String,String>();
        for(Location_Master__c lm: [Select id,State__c,State_Code__c from Location_Master__c where 
            State__c in: stateSet]){
                stateMap.put(lm.State__c,lm.State_Code__c);
        }

        CibilNIWrapper cibilNIData = New CibilNIWrapper();
        DateTime currentDT = System.now();
        String strUnixTimeStamp = String.valueof( currentDT.getTime() );    
        cibilNIData.requestId = strUnixTimeStamp;
        cibilNIData.OriginatingChannel = 'ADS';
        RequestInfo reqInfo = New RequestInfo();
        reqInfo.SolutionSetId = '440';
        reqInfo.SolutionSetVersion= '1';
        reqInfo.ExecutionMode = 'NewWithContext';
        reqInfo.EnvironmentId = '1';
        cibilNIData.requestInfo = reqInfo;
        cibilNIData.userData = '';
        Fields fields = New Fields();
        Field field = New Field();
        Applicants applicants = New Applicants();
        Applicant applicant = New Applicant();
        applicant.ApplicantType = 'Company';
        applicant.RelationType = '';
        applicant.ConsumerBureauCheck = '';
        applicant.IndividualPanCheck = '';
        applicant.ApplicantFirstName = '';
        applicant.ApplicantMiddleName = '';
        applicant.ApplicantLastName = '';
        applicant.DateOfBirth = '';
        applicant.Gender = '';
        Identifiers identifiers = New Identifiers();
        Identifier identifier = New Identifier(); 
        identifier.IdNumber = '';
        identifier.IdType = '';
        identifiers.Identifier = identifier;
        applicant.Identifiers = identifiers;
        applicant.DIN = '';
        Telephones telephones = New Telephones();
        Telephone telephone = New Telephone();
        telephone.TelephoneExtension = '';
        telephone.TelephoneNumber = '';
        telephone.TelephoneType = '';
        telephone.ContactArea = '';
        telephone.ContactPrefix = '';
        telephones.Telephone = telephone;
        applicant.Telephones = telephones;
        Addresses addresses = New Addresses();
        Address address = New Address();
        address.AddressLine1 = '';
        address.AddressLine2 = '';
        address.AddressLine3 = '';
        address.AddressLine4 = '';
        address.AddressLine5 = '';
        address.AddressType = '';
        address.City = '';
        address.PinCode = '';
        address.ResidenceType = '';
        address.StateCode = '';
        addresses.Address = address;
        applicant.Addresses = addresses;
        applicant.PAN = appData.PAN__c;
        if(appData.CIN__c<> null && appData.CIN__c <> ''){
            applicant.CIN = appData.CIN__c;
        }else{
            applicant.CIN = '';
        }
        applicant.CRN = '';
        applicant.TIN = '';
        applicant.CompanyName = appData.Entity_Name__c;
        applicant.ClassOfActivity = 'LOANS FOR PURCHASE OF MOTOR VEHICLE & TWO WHEELERS - OTHER THAN STAFF';
        applicant.TypeOfEntity = mappingValues.get('Constitution Type').get(appData.Constitution_Type__c);
        applicant.DateOfRegistration = getDateInDDMMMYYYYFormat(appData.Date_of_Establishment__c);
        for(Address__c addr: appData.addresses__r){
            if(addr.Address_Type__c == 'Office'){
                RegisteredAddress registeredAddress = New RegisteredAddress();
                registeredAddress.AddressType = 'REGISTERED OFFICE';
                registeredAddress.AddressLine1 = addr.Address_Line_1__c;
                registeredAddress.AddressLine2 = addr.Address_Line_2__c;
                registeredAddress.AddressLine3 = addr.Address_Line_3__c;
                registeredAddress.AddressCity = addr.City__c;
                if(stateMap.containsKey(addr.State__c)){
                    stateCode = stateMap.get(addr.State__c);
                    registeredAddress.AddressStateCode = stateCode;
                }else{
                    registeredAddress.AddressStateCode = '';
                }
                registeredAddress.AddressPincode = addr.Pincode__c;
                Telephone_Z regtelephone = New Telephone_Z();
                regtelephone.TelephoneType = '01';
                if(addr.Office_Number__c <> null){
                    regtelephone.TelephoneNum = addr.Office_Number__c;
                }
                regtelephone.ContactArea = '';
                regtelephone.ContactPrefix = '';
                registeredAddress.Telephone = regtelephone;
                applicant.RegisteredAddress = registeredAddress;
            }
        }
        OtherAddresses otherAddresses = New OtherAddresses();
        OtherAddress OtherAddress = New OtherAddress();
        OtherAddress.AddressType = '';
        OtherAddress.AddressLine1 = '';
        OtherAddress.AddressLine2 = '';
        OtherAddress.AddressLine3 = '';
        OtherAddress.AddressCity = '';
        OtherAddress.AddressStateCode = '';
        OtherAddress.AddressPincode = '';
        Telephone_Y othtelephone = New Telephone_Y();
        othtelephone.TelephoneType = '';
        othtelephone.TelephoneNum = '';
        othtelephone.ContactArea = '';
        othtelephone.ContactPrefix = '';
        OtherAddress.Telephone = othtelephone;
        otherAddresses.OtherAddress = OtherAddress;
        applicant.OtherAddresses = otherAddresses;

        applicant.MemberReferenceNumber = '';
        applicant.FacilityCategory = mappingValues.get('Facility Category').get(appData.Loan__r.Product__c);
        applicant.FacilityType=mappingValues.get('Facility Type').get(appData.Loan__r.Product__c);
        applicants.Applicant = applicant;
        field.Applicants = applicants;
        ApplicationData applicationData = New ApplicationData();
        applicationData.LitigationReport= 'false';
        applicationData.CommercialCIR= 'true';
        applicationData.ConsumerCIR= 'true';
        applicationData.MSMERank= 'false';
        applicationData.NoOfDirector= '';
        applicationData.FormattedReport= 'true';
        applicationData.RawResponse= '';
        applicationData.GSTStateCode= stateCode;
        applicationData.Amount= String.valueOf(appData.Total_Loan_Amount__c);
        applicationData.CompanyPANCheck= '';
        applicationData.CustomerConsent= '';
        applicationData.AddtionalTag1= '';
        applicationData.AddtionalTag2= '';
        applicationData.AddtionalTag3= '';
        applicationData.AddtionalTag4= '';
        applicationData.MemberReferenceNumber= 'Wheels';
        field.ApplicationData = applicationData;
        fields.Field = field;
        cibilNIData.Fields = fields;
        cibilNIData.key = '';
        String reqData = Json.serialize(cibilNIData,true);
        return reqData;
    }

    public static String getDateInDDMMMYYYYFormat(Date dateValue) {
        if (dateValue == null) {
            return '';
        }
        Map<Integer, String> monthMap = new Map<Integer, String>{1 => 'JAN', 2 => 'FEB', 3 => 'MAR', 4 => 'APR', 5 => 'MAY', 6 => 'JUN', 7 => 'JUL',
            8 => 'AUG', 9 => 'SEP', 10 => 'OCT', 11 => 'NOV', 12 => 'DEC'};
        String dateValueStr = String.valueOf(dateValue.day());
        if (dateValueStr.length() == 1) {
            dateValueStr = '0' + dateValueStr;
        }
        return dateValueStr + '-' + monthMap.get(dateValue.month()) + '-' + dateValue.year();
    }
    
    public class CibilNIWrapper {

        public String RequestId;
        public String OriginatingChannel;
        public RequestInfo RequestInfo;
        public String UserData;
        public Fields Fields;
        public String Key;
    }
    public class Telephone {
        public String TelephoneExtension;
        public String TelephoneNumber;
        public String TelephoneType;
        public String ContactArea;
        public String ContactPrefix;
    }

    public class Address {
        public String AddressLine1;
        public String AddressLine2;
        public String AddressLine3;
        public String AddressLine4;
        public String AddressLine5;
        public String AddressType;
        public String City;
        public String PinCode;
        public String ResidenceType;
        public String StateCode;
    }

    public class Telephone_Z {
        public String TelephoneType;
        public String TelephoneNum;
        public String ContactArea;
        public String ContactPrefix;
    }

    public class Telephone_Y {
        public String TelephoneType;
        public String TelephoneNum;
        public String ContactArea;
        public String ContactPrefix;
    }

    public class ApplicationData {
        public String LitigationReport;
        public String CommercialCIR;
        public String ConsumerCIR;
        public String MSMERank;
        public String NoOfDirector;
        public String FormattedReport;
        public String RawResponse;
        public String GSTStateCode;
        public String Amount;
        public String CompanyPANCheck;
        public String CustomerConsent;
        public String AddtionalTag1;
        public String AddtionalTag2;
        public String AddtionalTag3;
        public String AddtionalTag4;
        public String MemberReferenceNumber;
    }

    public class RequestInfo {
        public String SolutionSetId;
        public String SolutionSetVersion;
        public String ExecutionMode;
        public String EnvironmentId;
    }

    public class OtherAddresses {
        public OtherAddress OtherAddress;
    }

    public class Addresses {
        public Address Address;
    }

    public class Field {
        public Applicants Applicants;
        public ApplicationData ApplicationData;
    }

    public class Identifier {
        public String IdNumber;
        public String IdType;
    }

    public class Fields {
        public Field Field;
    }

    public class Telephones {
        public Telephone Telephone;
    }

    public class RegisteredAddress {
        public String AddressType;
        public String AddressLine1;
        public String AddressLine2;
        public String AddressLine3;
        public String AddressCity;
        public String AddressStateCode;
        public String AddressPincode;
        public Telephone_Z Telephone;
    }

    public class Applicants {
        public Applicant Applicant;
    }

    public class OtherAddress {
        public String AddressType;
        public String AddressLine1;
        public String AddressLine2;
        public String AddressLine3;
        public String AddressCity;
        public String AddressStateCode;
        public String AddressPincode;
        public Telephone_Y Telephone;
    }

    public class Identifiers {
        public Identifier Identifier;
    }

    public class Applicant {
        public String ApplicantType;
        public String RelationType;
        public String ConsumerBureauCheck;
        public String IndividualPanCheck;
        public String ApplicantFirstName;
        public String ApplicantMiddleName;
        public String ApplicantLastName;
        public String DateOfBirth;
        public String Gender;
        public Identifiers Identifiers;
        public String DIN;
        public Telephones Telephones;
        public Addresses Addresses;
        public String PAN;
        public String CIN;
        public String CRN;
        public String TIN;
        public String CompanyName;
        public String ClassOfActivity;
        public String TypeOfEntity;
        public String DateOfRegistration;
        public RegisteredAddress RegisteredAddress;
        public OtherAddresses OtherAddresses;
        public String MemberReferenceNumber;
        public String FacilityCategory;
        public String FacilityType;
    }
}