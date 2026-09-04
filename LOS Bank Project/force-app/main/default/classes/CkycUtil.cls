public with sharing class CkycUtil {
    
    public static void createCkycFaildRecord(Map<String, Object> ckycRequest, String requestType, String identityDetSubImgData, String addressPrrofPoiPoaImgdata, String addressProofCurrentAddImgData, String imageData) {
        CKYC_Failed_Record__c ckycFailedRec = new CKYC_Failed_Record__c();
        ckycFailedRec.Request_Type__c = requestType;
        Map<String, Object> customerDetailsMap = (Map<String, Object>) ckycRequest.get('CUSTOMERS_DETAILS');
        
        ckycFailedRec.name = '';
        ckycFailedRec.Unique_Request_ID__c= (String) ckycRequest.get('UNIQUE_REQUEST_ID');   // To populate
        
        ckycFailedRec.Customer_ID__c= (String) customerDetailsMap.get('CUSTOMER_ID');         //To populate
        ckycFailedRec.Mod_Flag__c= (String) customerDetailsMap.get('MOD_FLAG');  
        
        //SYSTEM_USE
        Map<String, Object> systemUseMap = (Map<String, Object>) customerDetailsMap.get('SYSTEM_USE');
        ckycFailedRec.Application_Type__c= (String) systemUseMap.get('APPLICATION_TYPE');
        ckycFailedRec.Branch_Code__c= (String) systemUseMap.get('BRANCH_CODE');         //To populate
        ckycFailedRec.CKYCNumber__c= (String) systemUseMap.get('CKYCNumber');          //To populate 
    
        //UPDATION_MODULE
        ckycFailedRec.Applicant_Entity_Update_Flag__c = '02';
        ckycFailedRec.Personal_Entity_Details_Update_Flag__c = '02';
        ckycFailedRec.Address_Details_Update_Flag__c = '02';
        ckycFailedRec.Contact_Details_Update_Flag__c = '02';
        ckycFailedRec.Remarks_Update_Flag__c = '02';
        ckycFailedRec.KYC_Verification_Update_Flag__c = '02';
        ckycFailedRec.Identity_Details_Update_Flag__c = '02';
        ckycFailedRec.Related_Person_Details_Update_Flag__c = '02';
        ckycFailedRec.Image_Details_Update_Flag__c = '02';
    
        //PERSONAL_ENTITY_DETAILS
        Map<String, Object> personalEntityDet = (Map<String, Object>) customerDetailsMap.get('PERSONAL_ENTITY_DETAILS');
        ckycFailedRec.Consti_Type__c = (String) personalEntityDet.get('CONSTI_TYPE');
        ckycFailedRec.Acc_Type__c = (String) personalEntityDet.get('ACC_TYPE');
        ckycFailedRec.CKYC_FI_Ref_No__c = (String) personalEntityDet.get('CKYC_FI_REF_NO');
        
        ckycFailedRec.Prefix__c = (String) personalEntityDet.get('PREFIX');
        ckycFailedRec.Fname__c = (String) personalEntityDet.get('FNAME');
        ckycFailedRec.Mname__c = (String) personalEntityDet.get('MNAME');
        ckycFailedRec.Lname__c = (String) personalEntityDet.get('LNAME');
    
        ckycFailedRec.Name_Of_The_Entity__c	 = (String) personalEntityDet.get('NAME_OF_THE_ENTITY');
        ckycFailedRec.Father_Spouse_Flag__c = (String) personalEntityDet.get('FATHER_SPOUSE_FLAG');
    
        ckycFailedRec.Father_Spouse_Prefix__c = (String) personalEntityDet.get('FATHER_SPOUSE_PREFIX');
        ckycFailedRec.Father_Spouse_Fname__c = (String) personalEntityDet.get('FATHER_SPOUSE_FNAME');
        ckycFailedRec.Father_Spouse_Mname__c = (String) personalEntityDet.get('FATHER_SPOUSE_MNAME');
        ckycFailedRec.Father_Spouse_Lname__c = (String) personalEntityDet.get('FATHER_SPOUSE_LNAME');
    
        ckycFailedRec.Mother_Prefix__c	 =(String) personalEntityDet.get('MOTHER_PREFIX');
        ckycFailedRec.Mother_FName__c = (String) personalEntityDet.get('MOTHER_FNAME');
        ckycFailedRec.Mother_Mname__c = (String) personalEntityDet.get('MOTHER_MNAME');
        ckycFailedRec.Mother_Lname__c = (String) personalEntityDet.get('MOTHER_LNAME');
        ckycFailedRec.Gender__c = (String) personalEntityDet.get('GENDER');
        ckycFailedRec.DOB__c = (String) personalEntityDet.get('DOB');
    
        ckycFailedRec.Pan_Form60__c = (String) personalEntityDet.get('PAN_FORM60');
        ckycFailedRec.Aadhar__c = (String) personalEntityDet.get('AADHAR');
        ckycFailedRec.Number_of_Related_Person__c = (String) personalEntityDet.get('NUMBER_OF_RELATED_PERSON');
    
        //ADDRESS_DETAILS
        Map<String, Object> addressDetailsMap = (Map<String, Object>) customerDetailsMap.get('ADDRESS_DETAILS');
        ckycFailedRec.POA_Address_Line_1__c = (String) addressDetailsMap.get('POI_POA_ADDRESS_LINE1');
        ckycFailedRec.POA_Address_Line_2__c = (String) addressDetailsMap.get('POI_POA_ADDRESS_LINE2');
        ckycFailedRec.POA_Address_Line_3__c = (String) addressDetailsMap.get('POI_POA_ADDRESS_LINE3');
        ckycFailedRec.POA_Address_C_T_V__c = (String) addressDetailsMap.get('POI_POA_ADDRESS_C_T_V');
        ckycFailedRec.POI_POA_Address_District__c = (String) addressDetailsMap.get('POI_POA_ADDRESS_DISTRICT');
        ckycFailedRec.POI_POA_Address_State__c = (String) addressDetailsMap.get('POI_POA_ADDRESS_STATE');
        ckycFailedRec.POI_POA_Address_Country__c = (String) addressDetailsMap.get('POI_POA_ADDRESS_COUNTRY');
        ckycFailedRec.POI_POA_Address_Pincode__c = (String) addressDetailsMap.get('POI_POA_ADDRESS_PINCODE');
        ckycFailedRec.Addres_Proof_POI_POA__c = (String) addressDetailsMap.get('ADDRESS_PROOF_POI_POA');
        ckycFailedRec.Address_Proof_POI_POA_Others__c = (String) addressDetailsMap.get('ADDRESS_PROOF_POI_POA_OTHERS');
        ckycFailedRec.Flag_POI_POA_Addr_Same_Current_Addr__c = (String) addressDetailsMap.get('FLAG_POI_POA_ADDR_SAME_CURRENT_ADDR');
    
        ckycFailedRec.Current_Address_Line_1__c	 = (String) addressDetailsMap.get('CURRENT_ADDRESS_LINE1');
        ckycFailedRec.Current_Address_Line_2__c = (String) addressDetailsMap.get('CURRENT_ADDRESS_LINE2');
        ckycFailedRec.Current_Address_Line_3__c = (String) addressDetailsMap.get('CURRENT_ADDRESS_LINE3');
        ckycFailedRec.Current_Address_C_T_V__c = (String) addressDetailsMap.get('CURRENT_ADDRESS_C_T_V');
        ckycFailedRec.Current_Address_District__c = (String) addressDetailsMap.get('CURRENT_ADDRESS_DISTRICT');
        ckycFailedRec.Current_Address_State__c = (String) addressDetailsMap.get('CURRENT_ADDRESS_STATE');
        ckycFailedRec.Current_Address_Country__c = (String) addressDetailsMap.get('CURRENT_ADDRESS_COUNTRY');
        ckycFailedRec.Current_Address_Pincode__c = (String) addressDetailsMap.get('CURRENT_ADDRESS_PINCODE');
        ckycFailedRec.Address_Proof_Current_Address__c = (String) addressDetailsMap.get('ADDRESS_PROOF_CURRENT_ADDRESS');
    
        ckycFailedRec.Self_Declaration__c = (String) addressDetailsMap.get('SELF_DECLARATION');
    
        //CONTACT_DETAILS
        Map<String, Object> contactDetailsMap = (Map<String, Object>) customerDetailsMap.get('CONTACT_DETAILS');
        ckycFailedRec.Residence_Tel_No_Stdcode__c = (String) contactDetailsMap.get('RESIDENCE_TEL_NO_STDCODE');
        ckycFailedRec.Residence_Tel_No__c = (String) contactDetailsMap.get('RESIDENCE_TEL_NO');
        ckycFailedRec.Office_Tel_No_Stdcode__c = (String) contactDetailsMap.get('OFFICE_TEL_NO_STDCODE');
        ckycFailedRec.Office_Tel_No__c = (String) contactDetailsMap.get('OFFICE_TEL_NO');
        ckycFailedRec.Mobile_No_Isdcode__c = (String) contactDetailsMap.get('MOBILE_NO_ISDCODE');
        ckycFailedRec.Mobile_No__c = (String) contactDetailsMap.get('MOBILE_NO');
        
        //IDENTITY_DETAILS
        Map<String, Object> identityDetailsMap = (Map<String, Object>) customerDetailsMap.get('IDENTITY_DETAILS');
        ckycFailedRec.Ident_Type__c = (String) identityDetailsMap.get('IDENT_TYPE');
        ckycFailedRec.Ident_Num__c = (String) identityDetailsMap.get('IDENT_NUM');
        ckycFailedRec.Id_Proof_Submitted__c = (String) identityDetailsMap.get('IDPROOF_SUBMITTED');
        ckycFailedRec.Id_Proof_Sub_Img_Type__c = (String) identityDetailsMap.get('IDPROOF_SUB_IMG_TYPE');
        ckycFailedRec.ID_Proof_SUB_IMG_Data__c = identityDetSubImgData;
    
        //ADDRESS_DETAILS_IMG
        Map<String, Object> addressDetailsImgMap = (Map<String, Object>) customerDetailsMap.get('ADDRESS_DETAILS_IMG');
        ckycFailedRec.Address_Proof_POI_POA_Number__c = (String) addressDetailsImgMap.get('ADDRESS_PROOF_POI_POA_NUMBER');
        ckycFailedRec.Address_Proof_POI_POA_IMG_Type__c = (String) addressDetailsImgMap.get('ADDRESS_PROOF_POI_POA_IMG_TYPE');
        ckycFailedRec.Addres_Proof_POI_POA_IMG_Data__c = addressPrrofPoiPoaImgdata; // String.valueOf(addressDetailsImgMap.get('ADDRESS_PROOF_POI_POA_IMGDATA'));
    
        ckycFailedRec.Address_Proof_Current_Address_Number__c = (String) addressDetailsImgMap.get('ADDRESS_PROOF_CURRENT_ADDRESS_NUMBER');
        ckycFailedRec.Address_Proof_Current_Address_IMG_Type__c = (String) addressDetailsImgMap.get('ADDRESS_PROOF_CURRENT_ADDRESS_IMG_TYPE');
        ckycFailedRec.Address_Proof_Current_Address_IMG_Data__c = addressProofCurrentAddImgData; // String.valueOf(addressDetailsImgMap.get('ADDRESS_PROOF_CURRENT_ADDRESS_IMGDATA'));
    
    
        // IMAGE_DETAILS
        Map<String, Object> imageDetailsMap = (Map<String, Object>) customerDetailsMap.get('IMAGE_DETAILS');
        ckycFailedRec.Image_Type__c = (String) imageDetailsMap.get('IMAGE_TYPE');
        ckycFailedRec.Image_Extension__c = (String) imageDetailsMap.get('IMAGE_EXTENTION');
        ckycFailedRec.Image_Code__c = (String) imageDetailsMap.get('IMAGE_CODE');
        ckycFailedRec.Image_Data__c = imageData; // String.valueOf(imageDetailsMap.get('IMAGE_DATA'));
    
    
        // KYC Verfication
        Map<String, Object> kycVerificationMap = (Map<String, Object>) customerDetailsMap.get('KYC_VERIFICATION');
        ckycFailedRec.Date_of_Declaration__c = (String) kycVerificationMap.get('DATE_OF_DECLARATION');
        ckycFailedRec.Place_of_Declaration__c = (String) kycVerificationMap.get('PLACE_OF_DECLARATION');
        if(kycVerificationMap.get('KYC_VERIFICATION_DATE')!=null){
            Date dateValue = Date.valueOf(kycVerificationMap.get('KYC_VERIFICATION_DATE'));
            String KYCVerificationDate = dateValue.format();
            ckycFailedRec.KYC_Verification_Date__c = KYCVerificationDate;
            }
            else 
              ckycFailedRec.KYC_Verification_Date__c = '';
        ckycFailedRec.Type_Of_Doc_Submitted__c = (String) kycVerificationMap.get('TYPE_OF_DOC_SUBMITTED');
        ckycFailedRec.KYC_verification_Name__c = (String) kycVerificationMap.get('KYC_VERIFICATION_NAME');
        ckycFailedRec.KYC_Verification_Designation__c= (String) kycVerificationMap.get('KYC_VERIFICATION_DESIGNATION');
        ckycFailedRec.KYC_Verification_Branch__c = (String) kycVerificationMap.get('KYC_VERIFICATION_BRANCH');
        ckycFailedRec.KYC_Verification_EMP_Code__c = (String) kycVerificationMap.get('KYC_VERIFICATION_EMP_CODE');
        ckycFailedRec.Organisation_Name__c = (String) kycVerificationMap.get('ORGANISATION_NAME');
        ckycFailedRec.Organisation_Code__c = (String) kycVerificationMap.get('ORGANISATION_CODE');
        ckycFailedRec.Customer_Identification_Flag__c = (String) kycVerificationMap.get('CUSTOMER_IDENTIFICATION_FLAG');
        ckycFailedRec.SRC_Application__c = (String) kycVerificationMap.get('SRC_APPLICATION');

        if(ckycFailedRec != null && Schema.sObjectType.Contact.fields.Email.isCreateable()) {
            insert ckycFailedRec;
        }
    }
}