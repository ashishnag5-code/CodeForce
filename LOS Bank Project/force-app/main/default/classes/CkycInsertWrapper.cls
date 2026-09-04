public with sharing virtual class CkycInsertWrapper {

    public CUSTOMERS_DETAILS CUSTOMERS_DETAILS{get;set;}
    public String UNIQUE_REQUEST_ID{get;set;}
    public class UPDATION_MODULE{
        public String IDENTITY_DETAILS_UPDATE_FLAG{get;set;}
        public String KYC_VERIFICATION_UPDATE_FLAG{get;set;}
        public String RELATED_PERSON_DETAILS_UPDATE_FLAG{get;set;}
        public String REMARKS_UPDATE_FLAG{get;set;}
        public String IMAGE_DETAILS_UPDATE_FLAG{get;set;}
        public String CONTACT_DETAILS_UPDATE_FLAG{get;set;}
        public String APPLICANT_ENTITY_UPDATE_FLAG{get;set;}
        public String ADDRESS_DETAILS_UPDATE_FLAG{get;set;}
        public String PERSONAL_ENTITY_DETAILS_UPDATE_FLAG{get;set;}
    }
    public class SYSTEM_USE{
        public String CKYCNumber{get;set;}
        public String BRANCH_CODE{get;set;}
        public String APPLICATION_TYPE{get;set;}
    }
    public class PERSONAL_ENTITY_DETAILS{
        public String NUMBER_OF_RELATED_PERSON{get;set;}
        public String AADHAR{get;set;}
        public String GENDER{get;set;}
        public String DOB{get;set;}
        public String MOTHER_LNAME{get;set;}
        public String PAN_FORM60{get;set;}
        public String MOTHER_MNAME{get;set;}
        public String MOTHER_PREFIX{get;set;}
        public String FATHER_SPOUSE_LNAME{get;set;}
        public String MOTHER_FNAME{get;set;}
        public String FATHER_SPOUSE_MNAME{get;set;}
        public String MNAME{get;set;}
        public String LNAME{get;set;}
        public String FNAME{get;set;}
        public String NAME_OF_THE_ENTITY{get;set;}
        public String PREFIX{get;set;}
        public String FATHER_SPOUSE_FLAG{get;set;}
        public String CKYC_FI_REF_NO{get;set;}
        public String FATHER_SPOUSE_PREFIX{get;set;}
        public String ACC_TYPE{get;set;}
        public String FATHER_SPOUSE_FNAME{get;set;}
        public String CONSTI_TYPE{get;set;}
    }
    public class KYC_VERIFICATION{
        public String DATE_OF_DECLARATION{get;set;}
        public String KYC_VERIFICATION_BRANCH{get;set;}
        public String KYC_VERIFICATION_DESIGNATION{get;set;}
        public String KYC_VERIFICATION_EMP_CODE{get;set;}
        public String KYC_VERIFICATION_NAME{get;set;}
        public String ORGANISATION_NAME{get;set;}
        public String TYPE_OF_DOC_SUBMITTED{get;set;}
        public String ORGANISATION_CODE{get;set;}
        public String KYC_VERIFICATION_DATE{get;set;}
        public String CUSTOMER_IDENTIFICATION_FLAG{get;set;}
        public String PLACE_OF_DECLARATION{get;set;}
        public String SRC_APPLICATION{get;set;}
    }
    public class IMAGE_DETAILS{
        public String IMAGE_TYPE{get;set;}
        public String IMAGE_CODE{get;set;}
        public String IMAGE_DATA{get;set;}
        public String IMAGE_EXTENTION{get;set;}
    }
    public class IDENTITY_DETAILS{
        public String IDENT_TYPE{get;set;}
        public String IDPROOF_SUB_IMG_TYPE{get;set;}
        public String IDPROOF_SUBMITTED{get;set;}
        public String IDPROOF_SUB_IMG_DATA{get;set;}
        public String IDENT_NUM{get;set;}
    }
    public class CUSTOMERS_DETAILS{
        public CONTACT_DETAILS CONTACT_DETAILS{get;set;}
        public ADDRESS_DETAILS ADDRESS_DETAILS{get;set;}
        public PERSONAL_ENTITY_DETAILS PERSONAL_ENTITY_DETAILS{get;set;}
        public list<IDENTITY_DETAILS> IDENTITY_DETAILS{get;set;}
        public UPDATION_MODULE UPDATION_MODULE{get;set;}
        public ADDRESS_DETAILS_IMG ADDRESS_DETAILS_IMG{get;set;}
        public SYSTEM_USE SYSTEM_USE{get;set;}
        public list<IMAGE_DETAILS> IMAGE_DETAILS{get;set;}
        public String MOD_FLAG{get;set;}
        public KYC_VERIFICATION KYC_VERIFICATION{get;set;}
        public String CUSTOMER_ID{get;set;}
    }
    public class CONTACT_DETAILS{
        public String MOBILE_NO{get;set;}
        public String OFFICE_TEL_NO_STDCODE{get;set;}
        public String OFFICE_TEL_NO{get;set;}
        public String RESIDENCE_TEL_NO{get;set;}
        public String MOBILE_NO_ISDCODE{get;set;}
        public String RESIDENCE_TEL_NO_STDCODE{get;set;}
    }
    public class ADDRESS_DETAILS_IMG{
        public String ADDRESS_PROOF_POI_POA_NUMBER{get;set;}
        public String ADDRESS_PROOF_CURRENT_ADDRESS_NUMBER{get;set;}
        public String ADDRESS_PROOF_CURRENT_ADDRESS_IMG_TYPE{get;set;}
        public String ADDRESS_PROOF_POI_POA_IMGDATA{get;set;}
        public String ADDRESS_PROOF_CURRENT_ADDRESS_IMGDATA{get;set;}
        public String ADDRESS_PROOF_POI_POA_IMG_TYPE{get;set;}
    }
    public class ADDRESS_DETAILS{
        public String CURRENT_ADDRESS_COUNTRY{get;set;}
        public String FLAG_POI_POA_ADDR_SAME_CURRENT_ADDR{get;set;}
        public String ADDRESS_PROOF_POI_POA_OTHERS{get;set;}
        public String CURRENT_ADDRESS_LINE1{get;set;}
        public String ADDRESS_PROOF_POI_POA{get;set;}
        public String CURRENT_ADDRESS_LINE2{get;set;}
        public String POI_POA_ADDRESS_PINCODE{get;set;}
        public String CURRENT_ADDRESS_LINE3{get;set;}
        public String POI_POA_ADDRESS_COUNTRY{get;set;}
        public String CURRENT_ADDRESS_C_T_V{get;set;}
        public String POI_POA_ADDRESS_STATE{get;set;}
        public String CURRENT_ADDRESS_DISTRICT{get;set;}
        public String POI_POA_ADDRESS_DISTRICT{get;set;}
        public String CURRENT_ADDRESS_STATE{get;set;}
        public String POI_POA_ADDRESS_C_T_V{get;set;}
        public String CURRENT_ADDRESS_PINCODE{get;set;}
        public String POI_POA_ADDRESS_LINE3{get;set;}
        public String ADDRESS_PROOF_CURRENT_ADDRESS{get;set;}
        public String POI_POA_ADDRESS_LINE2{get;set;}
        public String SELF_DECLARATION{get;set;}
        public String POI_POA_ADDRESS_LINE1{get;set;}
    }

        public static CkycInsertWrapper parse(String json){
            return (CkycInsertWrapper) System.JSON.deserialize(json, CkycInsertWrapper.class);
        }
}