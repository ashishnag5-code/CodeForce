/*****
 * Class Name: CIFCreationApiHandler
 * Description: CIFCreationControllerTest
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Nov-08-2023          -   Mohit Maheshwari    -   SFAU-5534 - NationalIdentificationCode
 * Dec-22-2023          -   Yash Shukla         -   SFAU-5785 - Transgender check added
 */
public with sharing class CIFCreationApiHandler implements IntegrationHandlerInterface{

    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,String> paramsMap=(Map<String,String>)reqParam;
        String recordId = paramsMap.get('ApplicantId');
        List<Applicant__c> applicantList = [SELECT Id, Name, Age__c, Mother_Name__c, Aadhaar_Seeding__c, Pan_Form60__c, IsEmailVerified__c, loan__r.Branch_Master__r.Account_Code__c, Dob__c, Customer_Type__c,
                Gender__c, Marital_Status__c, Mobile_Number__c, Aadhaar_Number__c, AU_Employee__c, AU_Employee_ID__c, PAN__c, Education_Qualification__c, (SELECT Id, Name, Pincode__c, State__c,
                City__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Type__c FROM Addresses__r WHERE Address_Type__c in ('Current','Permanent','Office') AND
                Source_Type__c=null Order By CreatedDate Desc), 
                (SELECT Id, isActive__c, Sector__c, Industry__c, Sub_Industry__c, Occupation__c, Type_Of_Employment__c FROM Applicant_Financials__r WHERE RecordType.DeveloperName='Financial_Parent' AND isActive__c=true Order By CreatedDate Desc Limit 1),
                First_Name__c, Middle_Name__c, Last_Name__c, Title__c,
                CBS_Signature_Available__c, CBS_Image_Available__c, KYC_Status__c, Constitution_Type__c, CIF_No__c, Total_Monthly_Income_Sum__c, Email__c,
                Date_of_Establishment__c FROM
                Applicant__c WHERE id=:recordId AND IsInactive__c=false];
        
        
        Applicant__c applicant;
        if(applicantList!=null && applicantList.size()>0){
            applicant = applicantList[0];
        }

        List<Title_Master__mdt> titleMaster = Title_Master__mdt.getAll().values();
        Map<String, Title_Master__mdt> titleMasterMap = new Map<String, Title_Master__mdt>();
        for(Title_Master__mdt title : titleMaster){
            titleMasterMap.put(title.MasterLabel, title);
        }
        Applicant_Financials_Details__c applicantParentFinancial = applicant.Applicant_Financials__r!=null && applicant.Applicant_Financials__r.size()>0?applicant.Applicant_Financials__r:new Applicant_Financials_Details__c();
        List<Profiling_Master__c> profilingMasterRecords = new List<Profiling_Master__c>();   
        profilingMasterRecords = [SELECT Name,Code__c,Sector__c, Sector__r.Code__c, Industry__c, Industry__r.Code__c,
        Sub_Industry__c, Sub_Industry__r.Code__c, Occupation__c, Occupation__r.Code__c, Employment_Type__c, 
        Employment_Type__r.Code__c 
        FROM Profiling_Master__c WHERE RecordType.DeveloperName = 'RT_Employment_Type' AND
        Sector__r.Name =:applicantParentFinancial.Sector__c AND Industry__r.Name=:applicantParentFinancial.Industry__c 
        AND Sub_Industry__r.Name =:applicantParentFinancial.Sub_Industry__c AND 
        Occupation__r.Name =:applicantParentFinancial.Occupation__c AND Name=:applicantParentFinancial.Type_Of_Employment__c];

        CustomerProfilingDetailsWrapper customerProfilingDetails= new CustomerProfilingDetailsWrapper();
        Profiling_Master__c profilingMasterRecord = new Profiling_Master__c();   
        if(profilingMasterRecords!=null && profilingMasterRecords.size()>0){
            profilingMasterRecord=profilingMasterRecords[0];
            customerProfilingDetails.Activity = profilingMasterRecord.Occupation__c!=null?String.valueOf(profilingMasterRecord.Occupation__r.Code__c):'';
            customerProfilingDetails.BusinessProfiler = 'Y';
            customerProfilingDetails.CustCategory = profilingMasterRecord.Code__c!=null?String.valueOf(profilingMasterRecord.Code__c):'';
            customerProfilingDetails.IncomeProfiler = 'N';
            customerProfilingDetails.Industry = profilingMasterRecord.Industry__c!=null?String.valueOf(profilingMasterRecord.Industry__r.Code__c):'';
            customerProfilingDetails.Sector = profilingMasterRecord.Sector__r!=null?String.valueOf(profilingMasterRecord.Sector__r.Code__c):'';
            customerProfilingDetails.SubIndustry = profilingMasterRecord.Sub_Industry__c!=null?String.valueOf(profilingMasterRecord.Sub_Industry__r.Code__c):'';
        }
        /*else{
            customerProfilingDetails.BusinessProfiler = 'Y';
            customerProfilingDetails.IncomeProfiler = 'N';
        }*/
        
        if(applicant.Customer_Type__c == 'Individual'){
            CIFCreationApiIndRequestWrapper cifApiRequestWrapper = new CIFCreationApiIndRequestWrapper();
            cifApiRequestWrapper.TransactionBranch = applicant.loan__r.Branch_Master__r.Account_Code__c;
            cifApiRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
            cifApiRequestWrapper.OriginatingChannel = paramsMap.get('Channel');//'CRM';

            ReportingParamWrapper reportingWrapper = new ReportingParamWrapper();
            reportingWrapper.MISClass = 'DIVISION';
            reportingWrapper.MISCode = '0';
            cifApiRequestWrapper.ReportingParam = reportingWrapper;

            ApplicantWrapperInd newApplicantWrapper = new ApplicantWrapperInd();
            newApplicantWrapper.LeadId = String.valueOf(applicant.Aadhaar_Number__c);//'162345';//applicant.Aadhaar_Number__c;
            newApplicantWrapper.NumberOfAttempt = '1';
            newApplicantWrapper.CustomerProfilingDetails = customerProfilingDetails;

            IndividualCustomerWrapper newIndCustWrapper = new IndividualCustomerWrapper();
            //newIndCustWrapper.InoperativePan = applicant.PAN__c!=null?'Y':'';
            newIndCustWrapper.CountryOfResidence = 'IN';
            newIndCustWrapper.DateOfBirth = String.valueOf(applicant.Dob__c);
            String categoryValue;
            if(applicant.Age__c>=18 && applicant.Age__c<60){
                categoryValue = '100';
            }else if(applicant.Age__c>=60){
                categoryValue = '129';
            }else{
                categoryValue='';
            }
            //newIndCustWrapper.CustomerProfilingDetails = customerProfilingDetails;
            newIndCustWrapper.InoperativePan='';
            if(applicant.PAN__c!=null && applicant.Pan_Form60__c == 'Pan Card'){
                if(applicant.Aadhaar_Seeding__c=='Y'){
                    newIndCustWrapper.InoperativePan = 'N';
                }else if(applicant.Aadhaar_Seeding__c=='R'){
                    newIndCustWrapper.InoperativePan = 'Y';
                }
            }
            else{
                newIndCustWrapper.InoperativePan = '';
            }
            
            /*if(applicant.Customer_Type__c == 'Individual'){
                if(applicant.KYC_Status__c == 'Approved'){
                    categoryValue = CBS_Customer_Type_Mapping__mdt.getInstance('CUST_TYP_100').FLG_CUST_TYPE__c;
                }else{
                    categoryValue = CBS_Customer_Type_Mapping__mdt.getInstance('CUST_TYP_101').FLG_CUST_TYPE__c;
                }
                if(applicant.Age__c>=18 && applicant.Age__c<=60){
                    categoryValue = '100';
                }else if(applicant.Age__c>60){
                    categoryValue = '129';
                }else{
                    categoryValue='';
                }
            }*/
            newIndCustWrapper.Category = categoryValue;
            Map<String, String> educationQualification = new Map<String, String>{'UNEDUCATED' => '1', 
                                                                                'BELOW 10TH' => '2', 
                                                                                'SECONDARY' => '4', 
                                                                                'SENIOR SECONDARY' => '5', 
                                                                                'ITI - TECHNICAL DEGREE' => '6', 
                                                                                'GRADUATE' => '7',
                                                                                'POST GRADUATE&ABOVE' => '7'};

            newIndCustWrapper.CustomerEducation = educationQualification.get(applicant.Education_qualification__c);
            newIndCustWrapper.MotherMaidenName = applicant.Mother_Name__c!=null?applicant.Mother_Name__c:'';
            if(applicant.Gender__c == 'Male'){
                newIndCustWrapper.Sex = 'M';
            }else if(applicant.Gender__c == 'Female'){
                newIndCustWrapper.Sex = 'F';
            }
            newIndCustWrapper.CifType = 'C';
            newIndCustWrapper.Nationality = 'IN';
            if(applicant.Total_Monthly_Income_Sum__c == null){
               applicant.Total_Monthly_Income_Sum__c = 0; 
            }
            Income_Category__mdt incomeCat = [Select Category__c FROM Income_Category__mdt WHERE 
            Min_Amount__c<=:applicant.Total_Monthly_Income_Sum__c AND Max_Amount__c>=:applicant.Total_Monthly_Income_Sum__c LIMIT 1];
            if(incomeCat!=null){
                newIndCustWrapper.IncomeCategory = String.valueOf(Integer.valueOf(incomeCat.Category__c));//String.valueOf(incomeCat.Category__c);
            }
            newIndCustWrapper.HomeBranchCode = applicant.loan__r.Branch_Master__r.Account_Code__c;
            Map<String, String> maritalStatusMap = new Map<String, String>{'NONE' => '0', 'SINGLE' => '1', 'MARRIED' => '2', 'DIVORCED' => '3', 'WIDOWED' => '4', 'SEPARATED' => '5'};
            if(applicant.Marital_Status__c!=null && maritalStatusMap.keySet().contains(applicant.Marital_Status__c.toUpperCase())){
                newIndCustWrapper.MaritalStatus = maritalStatusMap.get(applicant.Marital_Status__c.toUpperCase());
            }else{
                newIndCustWrapper.MaritalStatus='';
            }
            newIndCustWrapper.MobileNumber = applicant.Mobile_Number__c!=null?applicant.Mobile_Number__c.replaceAll('\\D',''):'';
            newIndCustWrapper.EmailId = applicant.IsEmailVerified__c?applicant.Email__c:'';
            newIndCustWrapper.Language = 'ENG';
            /* Start - SFAU-5534 - NationalIdentificationCode Change*/
            /*
            if(applicant.Aadhaar_Number__c!=null){
                newIndCustWrapper.NationalIdentificationCode = applicant.Aadhaar_Number__c;
            }else if(applicant.PAN__c!=null){
                newIndCustWrapper.NationalIdentificationCode = applicant.PAN__c;
            }else{
                newIndCustWrapper.NationalIdentificationCode = generateIdentificationCode(applicant.Id);
            }
            */
            /* End - SFAU-5534 - NationalIdentificationCode */
            newIndCustWrapper.NationalIdentificationCode = applicant.Id;

            if(applicant.CIF_No__c!=null){
                newIndCustWrapper.CustomerID = applicant.CIF_No__c;
            }
            if(applicant.AU_Employee__c == 'Yes'){
                newIndCustWrapper.IsStaff = 'Y';
                newIndCustWrapper.EmployeeId = applicant.AU_Employee_ID__c;
            }else if(applicant.AU_Employee__c == 'No'){
                newIndCustWrapper.IsStaff = 'N';
            }
            newIndCustWrapper.PAN = applicant.PAN__c;
            AadhaarWrapper newAadhaarWrapper = new AadhaarWrapper();
            newAadhaarWrapper.AadhaarNumber = applicant.Aadhaar_Number__c;
            newIndCustWrapper.Aadhaar = newAadhaarWrapper;


            //Address__c currentAddress = applicant.Addresses__r[0];
            for(Address__c add: applicant.Addresses__r){
                if(add.Address_Type__c=='Permanent'){
                    newIndCustWrapper.Address = getFormattedAddress(add);
                }
                if(add.Address_Type__c=='Current'){
                    newIndCustWrapper.MailingAddress = getFormattedAddress(add);
                }
            }

            
            NameWrapper newNameWrapper = new NameWrapper();
            newNameWrapper.FirstName = applicant.First_Name__c!=null?applicant.First_Name__c:'';
            /*if(applicant.Middle_Name__c!=null && applicant.Middle_Name__c!=''){
                newNameWrapper.FormattedFullName = applicant.First_Name__c+' '+applicant.Middle_Name__c+' '+applicant.Last_Name__c;
            }else{
                newNameWrapper.FormattedFullName = applicant.First_Name__c+' '+applicant.Last_Name__c;
            }*/
            newNameWrapper.FormattedFullName = (applicant.First_Name__c!=null?applicant.First_Name__c+' ':'')+(applicant.Middle_Name__c!=null?applicant.Middle_Name__c+' ':'')+(applicant.Last_Name__c!=null?applicant.Last_Name__c:'');
            if(applicant.First_Name__c==null){
                newNameWrapper.ShortName = '';
            }else if(applicant.First_Name__c.length()>20){
                newNameWrapper.ShortName = applicant.First_Name__c.left(20);
            }else{
                newNameWrapper.ShortName = applicant.First_Name__c;
            }
            newNameWrapper.Prefix = titleMasterMap.get(applicant.Title__c)!=null?titleMasterMap.get(applicant.Title__c).CBS_Title__c:'';//applicant.Title__c+'.';
            newNameWrapper.LastName = applicant.Last_Name__c!=null?applicant.Last_Name__c:'';
            newNameWrapper.MiddleName = applicant.Middle_Name__c!=null?applicant.Middle_Name__c:'';

            newIndCustWrapper.Name = newNameWrapper;
            newApplicantWrapper.IndividualCustomer = newIndCustWrapper;

            CustomerImagesWrapper newCustImgWrapper = new CustomerImagesWrapper(); 
            if(!applicant.CBS_Signature_Available__c){
                newCustImgWrapper.Signature = getImages('AUWheels0134', applicant.Id);
            }
            if(!applicant.CBS_Image_Available__c){
                newCustImgWrapper.Photograph = getImages('AUWheels0089', applicant.Id);
            }
            newApplicantWrapper.CustomerImages = newCustImgWrapper; 
            cifApiRequestWrapper.Applicant = newApplicantWrapper;

            lstString.add(JSON.serialize(cifApiRequestWrapper));   
        }
        
        if(applicant.Customer_Type__c == 'Non Individual'){
            CIFCreationApiNIRequestWrapper cifApiRequestWrapper = new CIFCreationApiNIRequestWrapper();
            cifApiRequestWrapper.TransactionBranch = applicant.loan__r.Branch_Master__r.Account_Code__c;
            cifApiRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
            cifApiRequestWrapper.OriginatingChannel = paramsMap.get('Channel');//'CRM';

            ReportingParamWrapper reportingWrapper = new ReportingParamWrapper();
            reportingWrapper.MISClass = 'DIVISION';
            reportingWrapper.MISCode = '0';
            cifApiRequestWrapper.ReportingParam = reportingWrapper;

            ApplicantWrapperNI newApplicantWrapper = new ApplicantWrapperNI();
            newApplicantWrapper.LeadId = String.valueOf(applicant.Aadhaar_Number__c);//'162345';//applicant.Aadhaar_Number__c;
            newApplicantWrapper.NumberOfAttempt = '1';
            newApplicantWrapper.CustomerProfilingDetails = customerProfilingDetails;

            CorporateCustomerWrapper corporateCustWrapper = new CorporateCustomerWrapper();
            NameWrapper newNameWrapper = new NameWrapper();
            newNameWrapper.Prefix = 'M/S.'; // Added by Kunal [SFAU-4479]
            newNameWrapper.FirstName = applicant.First_Name__c!=null?applicant.First_Name__c:'';
            newNameWrapper.MiddleName = applicant.Middle_Name__c!=null?applicant.Middle_Name__c:'';
            newNameWrapper.LastName = applicant.Last_Name__c!=null?applicant.Last_Name__c:'';
            //newNameWrapper.ShortName = applicant.First_Name__c!=null?applicant.First_Name__c:'';
            /*if(applicant.Middle_Name__c!=null && applicant.Middle_Name__c!=''){
                newNameWrapper.FormattedFullName = applicant.First_Name__c+' '+applicant.Middle_Name__c+' '+applicant.Last_Name__c;
            }else{
                newNameWrapper.FormattedFullName = applicant.First_Name__c+' '+applicant.Last_Name__c;
            }*/
            if(applicant.First_Name__c==null){
                newNameWrapper.ShortName = '';
            }else if(applicant.First_Name__c.length()>20){
                newNameWrapper.ShortName = applicant.First_Name__c.left(20);
            }else{
                newNameWrapper.ShortName = applicant.First_Name__c;
            }
            newNameWrapper.FormattedFullName = (applicant.First_Name__c!=null?applicant.First_Name__c+' ':'')+(applicant.Middle_Name__c!=null?applicant.Middle_Name__c+' ':'')+(applicant.Last_Name__c!=null?applicant.Last_Name__c:'');
            corporateCustWrapper.Name = newNameWrapper;
            

            for(Address__c add: applicant.Addresses__r){
                if(add.Address_Type__c=='Office'){
                    corporateCustWrapper.Address = getFormattedAddressForNI(add);
                }
                if(add.Address_Type__c=='Current'){
                    corporateCustWrapper.MailingAddress = getFormattedAddressForNI(add);
                }
            }

            corporateCustWrapper.CountryOfResidence = 'IN';
            corporateCustWrapper.CustomerId = applicant.CIF_No__c!=null?Long.valueOf(applicant.CIF_No__c):null;
            corporateCustWrapper.MobileNumber = applicant.Mobile_Number__c!=null?Long.valueOf(applicant.Mobile_Number__c.replaceAll('\\D','')):null;
            corporateCustWrapper.EmailId = applicant.IsEmailVerified__c?applicant.Email__c:'';
            corporateCustWrapper.Nationality = 'IN';
            /* Start - SFAU-5534 - NationalIdentificationCode Change*/
            /*
            if(applicant.Aadhaar_Number__c!=null){
                corporateCustWrapper.NationalIdentificationCode = applicant.Aadhaar_Number__c;
            }else if(applicant.PAN__c!=null){
                corporateCustWrapper.NationalIdentificationCode = applicant.PAN__c;
            }else{
                corporateCustWrapper.NationalIdentificationCode = generateIdentificationCode(applicant.Id);
            }
            */
            corporateCustWrapper.NationalIdentificationCode = applicant.Id;
            /* End - SFAU-5534 - NationalIdentificationCode */
            
            String categoryValue;
            List<CBS_Customer_Type_Mapping__mdt> categoryValues = [SELECT Id, FLG_TYP_CLASS__c, FLG_CUST_TYPE__c FROM CBS_Customer_Type_Mapping__mdt WHERE TXT_CUST_TYPE__c=:applicant.Constitution_Type__c AND FLG_TYP_CLASS__c='C'];
            if(categoryValues!=null && categoryValues.size()>0){
                corporateCustWrapper.Category = categoryValues[0].FLG_CUST_TYPE__c;
            }
            corporateCustWrapper.SignatureType = '';
            corporateCustWrapper.ResidencePhone = applicant.Mobile_Number__c!=null?applicant.Mobile_Number__c.replaceAll('\\D',''):null;
            corporateCustWrapper.Origin = 'IND';
            corporateCustWrapper.Language = 'ENG';
            corporateCustWrapper.HomeBranchCode = Long.valueOf(applicant.loan__r.Branch_Master__r.Account_Code__c);
            corporateCustWrapper.CifType = 'C';
            corporateCustWrapper.StatementOption = '';
            //corporateCustWrapper.InoperativePan = '';
            corporateCustWrapper.InoperativePan='';
            if(applicant.Constitution_Type__c == 'Sole Proprietary'){
                if(applicant.Aadhaar_Seeding__c=='Y'){
                    corporateCustWrapper.InoperativePan = 'N';
                }else if(applicant.Aadhaar_Seeding__c=='R'){
                    corporateCustWrapper.InoperativePan = 'Y';
                }
            }
            //corporateCustWrapper.Designation = '';
            corporateCustWrapper.PAN = applicant.PAN__c;
            corporateCustWrapper.BusinessCode = null;
            corporateCustWrapper.DateOfRegistration = applicant.Date_of_Establishment__c!=null?String.valueOf(applicant.Date_of_Establishment__c):'';
            corporateCustWrapper.RegistrationNo = '';
            corporateCustWrapper.Signatories = new List<SignatoriesWrapper>();
            SignatoriesWrapper signatories = new SignatoriesWrapper();
            signatories.Designation='';
            signatories.DirectorName='';
            signatories.SignatoryName='';
            corporateCustWrapper.Signatories.add(signatories);
            
            newApplicantWrapper.CorporateCustomer = corporateCustWrapper;

            CustomerImagesWrapper newCustImgWrapper = new CustomerImagesWrapper(); 
            newCustImgWrapper.Signature='';
            newCustImgWrapper.Photograph='';
            /*if(!applicant.CBS_Signature_Available__c){
                newCustImgWrapper.Signature = getImages('AUWheels0134', applicant.Id);
            }
            if(!applicant.CBS_Image_Available__c){
                newCustImgWrapper.Photograph = getImages('AUWheels0089', applicant.Id);
            }*/
            newApplicantWrapper.CustomerImages = newCustImgWrapper; 
            cifApiRequestWrapper.Applicant = newApplicantWrapper;

            lstString.add(JSON.serialize(cifApiRequestWrapper));  
        }
        
        
        return lstString;
    }

    public static String getImages(String type, Id appId){
        system.debug('type '+type);
        system.debug('appId '+appId);
        List<ContentVersion> cvList = new List<ContentVersion>();
        Map<Id, Document_Checklist__c> imagesCheckList = new Map<Id,Document_Checklist__c> ([SELECT Id from Document_Checklist__c WHERE 
        Document_Master__r.Name =:type AND Applicant__c=:appId Order By CreatedDate Desc LIMIT 1]);

        system.debug('imagesCheckList '+imagesCheckList);
        if(imagesCheckList.keySet()!=null && imagesCheckList.keySet().size()>0){
            Map<Id, ContentDocumentLink> contentDocList= new Map<Id,ContentDocumentLink> ([SELECT Id, ContentDocumentId from ContentDocumentLink WHERE 
            LinkedEntityId in :imagesCheckList.keySet() LIMIT 1]);
            system.debug('contentDocList '+contentDocList);

            if(contentDocList.values()!=null && contentDocList.values().size()>0){
                cvList = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :contentDocList.values()[0].ContentDocumentId AND isActive__c=true
                Order By CreatedDate Desc LIMIT 1];
                system.debug('cvList '+cvList);
            }

        }

        if(cvList!=null && cvList.size()>0){
            return EncodingUtil.base64Encode(cvList[0].VersionData);
        }else{
            return null;
        }
    }

    public static AddressWrapper getFormattedAddress(Address__c currentAddress){
        AddressWrapper newAddressWrapper = new AddressWrapper();
        newAddressWrapper.Zip = currentAddress.Pincode__c!=null?currentAddress.Pincode__c:'';
        newAddressWrapper.State = currentAddress.State__c!=null?currentAddress.State__c.toUpperCase():'';
        newAddressWrapper.Country = 'IN';
        newAddressWrapper.City = currentAddress.City__c!=null?currentAddress.City__c.toUpperCase():'';
        currentAddress.Address_Line_1__c = currentAddress.Address_Line_1__c!=null?currentAddress.Address_Line_1__c:'';
        currentAddress.Address_Line_2__c = currentAddress.Address_Line_2__c!=null?currentAddress.Address_Line_2__c:'';
        currentAddress.Address_Line_3__c = currentAddress.Address_Line_3__c!=null?currentAddress.Address_Line_3__c:'';
        String addressSplit = currentAddress.Address_Line_1__c+currentAddress.Address_Line_2__c+currentAddress.Address_Line_3__c;
            
        if(addressSplit.length()>30){
            newAddressWrapper.Line1 = addressSplit.subString(0,29);
            if(addressSplit.subString(29,addressSplit.length()).length()>30){
                newAddressWrapper.Line2 = addressSplit.subString(29,59);
                if(addressSplit.subString(59,addressSplit.length()).length()>30){
                    newAddressWrapper.Line3 = addressSplit.subString(59,89);
                }else{
                    newAddressWrapper.Line3 = addressSplit.subString(59,addressSplit.length());
                }
            }else{
                    newAddressWrapper.Line2 = addressSplit.subString(29,addressSplit.length());
                    newAddressWrapper.Line3 = '';
            }
        }else{
                newAddressWrapper.Line1 = addressSplit.subString(0,addressSplit.length());
                newAddressWrapper.Line2 = '';
                newAddressWrapper.Line3 = '';
        }
        return newAddressWrapper;
    }

    public static AddressWrapperForNI getFormattedAddressForNI(Address__c currentAddress){
        AddressWrapperForNI newAddressWrapper = new AddressWrapperForNI();
            newAddressWrapper.Zip = currentAddress.Pincode__c!=null?currentAddress.Pincode__c:'';
            newAddressWrapper.State = currentAddress.State__c!=null?currentAddress.State__c.toUpperCase():'';
            newAddressWrapper.Country = 'IN';
            newAddressWrapper.City = currentAddress.City__c!=null?currentAddress.City__c.toUpperCase():'';
            currentAddress.Address_Line_1__c = currentAddress.Address_Line_1__c!=null?currentAddress.Address_Line_1__c:'';
            currentAddress.Address_Line_2__c = currentAddress.Address_Line_2__c!=null?currentAddress.Address_Line_2__c:'';
            currentAddress.Address_Line_3__c = currentAddress.Address_Line_3__c!=null?currentAddress.Address_Line_3__c:'';
            String addressSplit = currentAddress.Address_Line_1__c+currentAddress.Address_Line_2__c+currentAddress.Address_Line_3__c;
            if(addressSplit.length()>30){
                newAddressWrapper.Line1 = addressSplit.subString(0,29);
                if(addressSplit.subString(29,addressSplit.length()).length()>30){
                    newAddressWrapper.Line2 = addressSplit.subString(29,59);
                    if(addressSplit.subString(59,addressSplit.length()).length()>30){
                        newAddressWrapper.Line3 = addressSplit.subString(59,89);
                        if(addressSplit.subString(89,addressSplit.length()).length()>30){
                            newAddressWrapper.Line4 = addressSplit.subString(59,89);
                        }else{
                            newAddressWrapper.Line4 = addressSplit.subString(89,addressSplit.length());
                        }
                    }else{
                        newAddressWrapper.Line3 = addressSplit.subString(59,addressSplit.length());
                        newAddressWrapper.Line4='';
                    }
                }else{
                    newAddressWrapper.Line2 = addressSplit.subString(29,addressSplit.length());
                    newAddressWrapper.Line3='';
                    newAddressWrapper.Line4='';
                }
            }else{
                newAddressWrapper.Line1 = addressSplit.subString(0,addressSplit.length());
                newAddressWrapper.Line2='';
                newAddressWrapper.Line3='';
                newAddressWrapper.Line4='';
            }
            return newAddressWrapper;
    }

    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public static String generateIdentificationCode(String applicantId){
        Integer charLength = 10;
        String hashString = applicantId + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash).left(charLength);
        system.debug('##########' + hexDigest );
        return hexDigest;
    }
    
    public class CIFCreationApiIndRequestWrapper{
        public String RequestId;
        public String OriginatingChannel;
        public ReportingParamWrapper ReportingParam;
        public String TransactionBranch;
        public ApplicantWrapperInd Applicant;
    }

    public class CIFCreationApiNIRequestWrapper{
        public String RequestId;
        public String OriginatingChannel;
        public ReportingParamWrapper ReportingParam;
        public String TransactionBranch;
        public ApplicantWrapperNI Applicant;
    }

    public class CIFCreationApiRequestWrapper{
        public String RequestId;
        public String OriginatingChannel;
        public ReportingParamWrapper ReportingParam;
        public String TransactionBranch;
        public ApplicantWrapperInd Applicant;
    }

    public class ReportingParamWrapper{
        public String MISClass;
        public String MISCode;
    }

    public class ApplicantWrapperInd{
        public IndividualCustomerWrapper IndividualCustomer;
        public String LeadId;
        public String NumberOfAttempt;
        public CustomerProfilingDetailsWrapper CustomerProfilingDetails;
        public CustomerImagesWrapper CustomerImages;
    }

    public class ApplicantWrapperNI{
        public CorporateCustomerWrapper CorporateCustomer;
        public String LeadId;
        public String NumberOfAttempt;
        public CustomerProfilingDetailsWrapper CustomerProfilingDetails;
        public CustomerImagesWrapper CustomerImages;
    }

    public class CorporateCustomerWrapper{
        public NameWrapper Name;
        public AddressWrapperForNI Address;
        public AddressWrapperForNI MailingAddress;
        public String CountryOfResidence;
        public String InoperativePan;
        public Long CustomerId;
        public Long MobileNumber;
        public String EmailId;
        public String Nationality;
        public String NationalIdentificationCode;
        public String IcType;
        public String Category;
        public String SignatureType;
        public String ResidencePhone;
        public String Origin;
        public String Language;
        public Long HomeBranchCode;
        public String CifType;
        public String StatementOption;
        //public String Designation;
        public String PAN;
        public Integer BusinessCode;
        public String DateOfRegistration;
        public String RegistrationNo;
        public List<SignatoriesWrapper> Signatories;
    }

    public class SignatoriesWrapper{
        public String Designation;
        public String DirectorName;
        public String SignatoryName;
    }

    public class IndividualCustomerWrapper{
        public String CountryOfResidence;
        public String InoperativePan;
        public String DateOfBirth;
        public String Category;
        public String CustomerID;
        public AadhaarWrapper Aadhaar;
        public AddressWrapper Address;
        public String CustomerEducation;
        public String MotherMaidenName;
        public String Sex;
        public String CifType;
        public AddressWrapper MailingAddress;
        public String Nationality;
        public String IncomeCategory;
        public NameWrapper Name;
        public String HomeBranchCode;
        public String MaritalStatus;
        public String MobileNumber;
        public String EmailId;
        public String Language;
        public String NationalIdentificationCode;
        public String IsStaff;
        public String EmployeeId;
        public String PAN;
    }

    public class CustomerProfilingDetailsWrapper{
        public String Activity;
        public String BusinessProfiler;
        public String CustCategory;
        public String IncomeProfiler;
        public String Industry;
        public String Sector;
        public String SubIndustry;
    }

    public class AadhaarWrapper{
        public String AadhaarNumber;
    }

    public class AddressWrapper{
        public String Zip;
        public String State;
        public String Country;
        public String City;
        public String Line1;
        public String Line2;
        public String Line3;
    }

    public class AddressWrapperForNI{
        public String Zip;
        public String State;
        public String Country;
        public String City;
        public String Line1;
        public String Line2;
        public String Line3;
        public String Line4;
    }
   
    public class NameWrapper{
        public String FirstName;
        public String FormattedFullName;
        public String ShortName;
        public String Prefix;
        public String LastName;
        public String MiddleName;
    }

    public class CustomerImagesWrapper{
        public String Photograph;
        public String Signature;
    }

    public class CIFCreationApiResponseWrapper{
        @AuraEnabled public List<MatchFoundWrapper> MatchFound{get;set;}
        @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
        @AuraEnabled public String ServiceExecutionStatus{get;set;}
        @AuraEnabled public ErrorsWrapper Errors{get;set;}
        @AuraEnabled public List<ApplicantReturnWrapper> ApplicantReturn{get;set;}
    }

    public class ErrorsWrapper{
        @AuraEnabled public ErrorWrapper Error{get;set;}
    }

    public class ErrorWrapper{
        @AuraEnabled public String Code{get;set;}
        @AuraEnabled public String Message{get;set;}
    }

    public class MatchFoundWrapper{
        @AuraEnabled public String CustomerID;
        @AuraEnabled public String PAN;
        @AuraEnabled public String AadhaarNumber;
        @AuraEnabled public String MobileNumber;
        @AuraEnabled public String LandlineResidenceNumber;
        @AuraEnabled public String CustomerFullName;
        @AuraEnabled public String DateOfBirth;
        @AuraEnabled public String DateOfIncorporation;
        @AuraEnabled public String MotherMaidenName;
        @AuraEnabled public String BlockStatus;        
        @AuraEnabled public AddressResponseWrapper Address{get;set;}
        @AuraEnabled public String LeadId{get;set;}
    }

    public class AddressResponseWrapper{
        @AuraEnabled public String Zip{get;set;}
        @AuraEnabled public String State{get;set;}
        @AuraEnabled public String Country{get;set;}
        @AuraEnabled public String Line{get;set;}
    }

    public class TransactionStatusWrapper{
        @AuraEnabled public String ResponseCode{get;set;}
        @AuraEnabled public List<ValidationErrorsWrapper> ValidationErrors;
        @AuraEnabled public String ResponseMessage{get;set;}
        @AuraEnabled public ExtendedErrorDetailsWrapper ExtendedErrorDetails{get;set;}
    }

    public class ValidationErrorsWrapper{
        @AuraEnabled public String AttributeName{get;set;}
        @AuraEnabled public String ErrorMessage{get;set;}
    }

    public class ExtendedErrorDetailsWrapper{
        @AuraEnabled public List<MessagesWrapper> messages{get;set;}
    }

    public class MessagesWrapper{
        @AuraEnabled public Integer code{get;set;}
        @AuraEnabled public String message{get;set;}
    }

    public class ApplicantReturnWrapper{
        @AuraEnabled public String LeadId{get;set;}
        @AuraEnabled public Integer CustomerId{get;set;}
    }
}