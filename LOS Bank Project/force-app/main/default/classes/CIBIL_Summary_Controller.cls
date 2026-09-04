public with sharing class CIBIL_Summary_Controller {
    
    public String currentRecordId{get; set;}
    public String customerName{get; set;}
    public String rltnshpWithCase{get; set;}
    public String ageAndDob{get; set;}
    public List<String> conList{get; set;}
    public List<String> emailList{get; set;}
    public List<AddressWrapper> addrssList{get; set;}
    public List<BankAccountWrapper> barWrapList{get; set;}
    public String bureauVintageDate{get; set;}
    public String bureauScore{get; set;}
    // variables for Total Facilities (Nos  & Value) of Loans
    public Integer ttlFacltsUnscrdLoanCount{get; set;}
    public Double ttlFacltsUnscrdLoanSnctnAmount{get; set;}
    public Integer ttlFacltsVhclLoanCount{get; set;}
    public Double ttlFacltsVhclLoanSnctnAmount{get; set;}
    public Integer ttlFacltsHomeLoanCount{get; set;}
    public Double ttlFacltsHomeLoanSnctnAmount{get; set;}
    public Integer ttlFacltsOthrLoanCount{get; set;}
    public Double ttlFacltsOthrLoanSnctnAmount{get; set;}
    public Integer ttlFacltsLoanCount{get; set;}
    public Double ttlFacltsLoanSnctnAmount{get; set;}
    // variables for Live_POS_amount (Rs) of Loans
    public Integer ttlLivePOSUnscrdLoanCount{get; set;}
    public Double ttlLivePOSUnscrdLoanSnctnAmount{get; set;}
    public Integer ttlLivePOSVhclLoanCount{get; set;}
    public Double ttlLivePOSVhclLoanSnctnAmount{get; set;}
    public Integer ttlLivePOSHomeLoanCount{get; set;}
    public Double ttlLivePOSHomeLoanSnctnAmount{get; set;}
    public Integer ttlLivePOSOthrLoanCount{get; set;}
    public Double ttlLivePOSOthrLoanSnctnAmount{get; set;}
    public Integer ttlLivePOSLoanCount{get; set;}
    public Double ttlLivePOSLoanSnctnAmount{get; set;}
    // variables for Overdue_amt (Rs.) of Loans
    public Integer ttlOvrDueUnscrdLoanCount{get; set;}
    public Double ttlOvrDueUnscrdLoanSnctnAmount{get; set;}
    public Integer ttlOvrDueVhclLoanCount{get; set;}
    public Double ttlOvrDueVhclLoanSnctnAmount{get; set;}
    public Integer ttlOvrDueHomeLoanCount{get; set;}
    public Double ttlOvrDueHomeLoanSnctnAmount{get; set;}
    public Integer ttlOvrDueOthrLoanCount{get; set;}
    public Double ttlOvrDueOthrLoanSnctnAmount{get; set;}
    public Integer ttlOvrDueLoanCount{get; set;}
    public Double ttlOvrDueLoanSnctnAmount{get; set;}
    // variables for Availed Facility in last 3 year (Nos & value) of Loans
    public Integer ttlAvldFacltUnscrdLoanCount{get; set;}
    public Double ttlAvldFacltUnscrdLoanSnctnAmount{get; set;}
    public Integer ttlAvldFacltVhclLoanCount{get; set;}
    public Double ttlAvldFacltVhclLoanSnctnAmount{get; set;}
    public Integer ttlAvldFacltHomeLoanCount{get; set;}
    public Double ttlAvldFacltHomeLoanSnctnAmount{get; set;}
    public Integer ttlAvldFacltOthrLoanCount{get; set;}
    public Double ttlAvldFacltOthrLoanSnctnAmount{get; set;}
    public Integer ttlAvldFacltLoanCount{get; set;}
    public Double ttlAvldFacltLoanSnctnAmount{get; set;}
    // variables for Closed_facilities (Nos  & Value) of Loans
    public Integer ttlClsdFacltUnscrdLoanCount{get; set;}
    public Double ttlClsdFacltUnscrdLoanSnctnAmount{get; set;}
    public Integer ttlClsdFacltVhclLoanCount{get; set;}
    public Double ttlClsdFacltVhclLoanSnctnAmount{get; set;}
    public Integer ttlClsdFacltHomeLoanCount{get; set;}
    public Double ttlClsdFacltHomeLoanSnctnAmount{get; set;}
    public Integer ttlClsdFacltOthrLoanCount{get; set;}
    public Double ttlClsdFacltOthrLoanSnctnAmount{get; set;}
    public Integer ttlClsdFacltLoanCount{get; set;}
    public Double ttlClsdFacltLoanSnctnAmount{get; set;}
    // variables for Live_Loan Amt (Nos  & Value) of Loans
    public Integer ttlLiveLoanUnscrdLoanCount{get; set;}
    public Double ttlLiveLoanUnscrdLoanSnctnAmount{get; set;}
    public Integer ttlLiveLoanVhclLoanCount{get; set;}
    public Double ttlLiveLoanVhclLoanSnctnAmount{get; set;}
    public Integer ttlLiveLoanHomeLoanCount{get; set;}
    public Double ttlLiveLoanHomeLoanSnctnAmount{get; set;}
    public Integer ttlLiveLoanOthrLoanCount{get; set;}
    public Double ttlLiveLoanOthrLoanSnctnAmount{get; set;}
    public Integer ttlLiveLoanLoanCount{get; set;}
    public Double ttlLiveLoanLoanSnctnAmount{get; set;}
    // variables for Overdue_facilities (Nos  & Value) of Loans
    public Integer ttlOvrDueFacltUnscrdLoanCount{get; set;}
    public Double ttlOvrDueFacltUnscrdLoanSnctnAmount{get; set;}
    public Integer ttlOvrDueFacltVhclLoanCount{get; set;}
    public Double ttlOvrDueFacltVhclLoanSnctnAmount{get; set;}
    public Integer ttlOvrDueFacltHomeLoanCount{get; set;}
    public Double ttlOvrDueFacltHomeLoanSnctnAmount{get; set;}
    public Integer ttlOvrDueFacltOthrLoanCount{get; set;}
    public Double ttlOvrDueFacltOthrLoanSnctnAmount{get; set;}
    public Integer ttlOvrDueFacltLoanCount{get; set;}
    public Double ttlOvrDueFacltLoanSnctnAmount{get; set;}
    // variables for Suitfiled facility in Last 3 Year of Loans
    public String sutfldFacltUnscrdLoan{get; set;}
    public String sutfldFacltVhclLoan{get; set;}
    public String sutfldFacltHomeLoan{get; set;}
    public String sutfldFacltOthrLoan{get; set;}
    public String sutfldFacltLoan{get; set;}
    // variables for Writeoff facility in Last 3 Year of Loans
    public String wrtoffFacltUnscrdLoan{get; set;}
    public String wrtoffFacltVhclLoan{get; set;}
    public String wrtoffFacltHomeLoan{get; set;}
    public String wrtoffFacltOthrLoan{get; set;}
    public String wrtoffFacltLoan{get; set;}
    // variables for SOW (Nos & value) of Loans
    public Integer ttlSOWUnscrdLoanCount{get; set;}
    public Double ttlSOWUnscrdLoanSnctnAmount{get; set;}
    public Integer ttlSOWVhclLoanCount{get; set;}
    public Double ttlSOWVhclLoanSnctnAmount{get; set;}
    public Integer ttlSOWHomeLoanCount{get; set;}
    public Double ttlSOWHomeLoanSnctnAmount{get; set;}
    public Integer ttlSOWOthrLoanCount{get; set;}
    public Double ttlSOWOthrLoanSnctnAmount{get; set;}
    public Integer ttlSOWLoanCount{get; set;}
    public Double ttlSOWLoanSnctnAmount{get; set;}
    // variables for Co-app (Nos & value) of Loans
    public Integer ttlCoAppUnscrdLoanCount{get; set;}
    public Double ttlCoAppUnscrdLoanSnctnAmount{get; set;}
    public Integer ttlCoAppVhclLoanCount{get; set;}
    public Double ttlCoAppVhclLoanSnctnAmount{get; set;}
    public Integer ttlCoAppHomeLoanCount{get; set;}
    public Double ttlCoAppHomeLoanSnctnAmount{get; set;}
    public Integer ttlCoAppOthrLoanCount{get; set;}
    public Double ttlCoAppOthrLoanSnctnAmount{get; set;}
    public Integer ttlCoAppLoanCount{get; set;}
    public Double ttlCoAppLoanSnctnAmount{get; set;}
    // variables for GTR (Nos & value) of Loans
    public Integer ttlGTRUnscrdLoanCount{get; set;}
    public Double ttlGTRUnscrdLoanSnctnAmount{get; set;}
    public Integer ttlGTRVhclLoanCount{get; set;}
    public Double ttlGTRVhclLoanSnctnAmount{get; set;}
    public Integer ttlGTRHomeLoanCount{get; set;}
    public Double ttlGTRHomeLoanSnctnAmount{get; set;}
    public Integer ttlGTROthrLoanCount{get; set;}
    public Double ttlGTROthrLoanSnctnAmount{get; set;}
    public Integer ttlGTRLoanCount{get; set;}
    public Double ttlGTRLoanSnctnAmount{get; set;}
    // variables for last one month count of Enquiries
    public Integer ttlLstOneMnthUnscrdEnqCount{get; set;}
    public Integer ttlLstOneMnthVhclEnqCount{get; set;}
    public Integer ttlLstOneMnthHomeEnqCount{get; set;}
    public Integer ttlLstOneMnthOthrEnqCount{get; set;}
    public Integer ttlLstOneMnthEnqCount{get; set;}
    // variables for last one to three months count of Enquiries
    public Integer ttlLstOneToThreeMnthUnscrdEnqCount{get; set;}
    public Integer ttlLstOneToThreeMnthVhclEnqCount{get; set;}
    public Integer ttlLstOneToThreeMnthHomeEnqCount{get; set;}
    public Integer ttlLstOneToThreeMnthOthrEnqCount{get; set;}
    public Integer ttlLstOneToThreeMnthEnqCount{get; set;}
    // variables for last four to six months count of Enquiries
    public Integer ttlLstFourToSixMnthUnscrdEnqCount{get; set;}
    public Integer ttlLstFourToSixMnthVhclEnqCount{get; set;}
    public Integer ttlLstFourToSixMnthHomeEnqCount{get; set;}
    public Integer ttlLstFourToSixMnthOthrEnqCount{get; set;}
    public Integer ttlLstFourToSixMnthEnqCount{get; set;}
    // variables for last three months count of Loans
    public Integer ttlLstThreeMnthUnscrdLoanCount{get; set;}
    public Integer ttlLstThreeMnthVhclLoanCount{get; set;}
    public Integer ttlLstThreeMnthHomeLoanCount{get; set;}
    public Integer ttlLstThreeMnthOthrLoanCount{get; set;}
    public Integer ttlLstThreeMnthLoanCount{get; set;}
    // variables for last four to six months count of Loans
    public Integer ttlLstThreeToSixMnthUnscrdLoanCount{get; set;}
    public Integer ttlLstThreeToSixMnthVhclLoanCount{get; set;}
    public Integer ttlLstThreeToSixMnthHomeLoanCount{get; set;}
    public Integer ttlLstThreeToSixMnthOthrLoanCount{get; set;}
    public Integer ttlLstThreeToSixMnthLoanCount{get; set;}
    // variables for last seven to twelve months count of Loans
    public Integer ttlLstSvnToTwlvMnthUnscrdLoanCount{get; set;}
    public Integer ttlLstSvnToTwlvMnthVhclLoanCount{get; set;}
    public Integer ttlLstSvnToTwlvMnthHomeLoanCount{get; set;}
    public Integer ttlLstSvnToTwlvMnthOthrLoanCount{get; set;}
    public Integer ttlLstSvnToTwlvMnthLoanCount{get; set;}
    // variables for last twelve plus months count of Loans
    public Integer ttlLstTwlvPlusUnscrdLoanCount{get; set;}
    public Integer ttlLstTwlvPlusMnthVhclLoanCount{get; set;}
    public Integer ttlLstTwlvPlusMnthHomeLoanCount{get; set;}
    public Integer ttlLstTwlvPlusMnthOthrLoanCount{get; set;}
    public Integer ttlLstTwlvPlusMnthLoanCount{get; set;}
    // variables for last twelve months highest DPD of Loans
    public String lstTwlvMnthHghstDpdUnscrdSowJnt{get; set;}
    public String lstTwlvMnthHghstDpdVhclSowJnt{get; set;}
    public String lstTwlvMnthHghstDpdHomeSowJnt{get; set;}
    public String lstTwlvMnthHghstDpdOtherSowJnt{get; set;}
    public String lstTwlvMnthHghstDpdUnscrdGrntee{get; set;}
    public String lstTwlvMnthHghstDpdVhclGrntee{get; set;}
    public String lstTwlvMnthHghstDpdHomeGrntee{get; set;}
    public String lstTwlvMnthHghstDpdOtherGrntee{get; set;}
    // variables for last twelve to twenty four months highest DPD of Loans
    public String lstTwlvToTwntyFourMnthHghstDpdUnscrdSowJnt{get; set;}
    public String lstTwlvToTwntyFourMnthHghstDpdVhclSowJnt{get; set;}
    public String lstTwlvToTwntyFourMnthHghstDpdHomeSowJnt{get; set;}
    public String lstTwlvToTwntyFourMnthHghstDpdOtherSowJnt{get; set;}
    public String lstTwlvToTwntyFourMnthHghstDpdUnscrdGrntee{get; set;}
    public String lstTwlvToTwntyFourMnthHghstDpdVhclGrntee{get; set;}
    public String lstTwlvToTwntyFourMnthHghstDpdHomeGrntee{get; set;}
    public String lstTwlvToTwntyFourMnthHghstDpdOtherGrntee{get; set;}
    // variables for last twenty four to thirty six four months highest DPD of Loans
    public String lstTwntyFourToThrtySixMnthHghstDpdUnscrdSowJnt{get; set;}
    public String lstTwntyFourToThrtySixMnthHghstDpdVhclSowJnt{get; set;}
    public String lstTwntyFourToThrtySixMnthHghstDpdHomeSowJnt{get; set;}
    public String lstTwntyFourToThrtySixMnthHghstDpdOtherSowJnt{get; set;}
    public String lstTwntyFourToThrtySixMnthHghstDpdUnscrdGrntee{get; set;}
    public String lstTwntyFourToThrtySixMnthHghstDpdVhclGrntee{get; set;}
    public String lstTwntyFourToThrtySixMnthHghstDpdHomeGrntee{get; set;}
    public String lstTwntyFourToThrtySixMnthHghstDpdOtherGrntee{get; set;}
    
    
    public CIBIL_Summary_Controller(ApexPages.StandardController stdController){
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id').escapeHtml4();
        initializeApplcntDetails(currentRecordId);
    }
    
    
    public void initializeApplcntDetails(String currentRecordId){
        List<Applicant__c> applcntList = [Select id, RecordType.Name,Loan__r.Product__c,
                                          (SELECT id, Bureau_Score__c, Name_of_Applicant__c, DOB__c, TelephoneNumber__c, EmailID__c 
                                           FROM Bureau_Results__r WHERE (Bureau__c = 'CIBIL')                                                      
                                           ORDER BY createddate DESC LIMIT 1)
                                          From Applicant__c WHERE id=:currentRecordId];
        
        if(applcntList[0].Bureau_Results__r.size() > 0){
            List<Address__c> addList = [SELECT id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, State__c, Pincode__c,
                                        Address_Type__c, Date_Reported__c, Enriched_Through_Enquiry__c
                                        FROM Address__c WHERE (Source_Type__c = 'CIBIL' AND Bureau_Results__c =: applcntList[0].Bureau_Results__r[0].id)];
            system.debug('addList Size'+addList.size());
            system.debug('addList'+addList);
            if(addList.size() > 0){
                addrssList = new List<AddressWrapper>();
                for(Address__c add : addList){
                    String address1 = add.Address_Line_1__c !=null ? add.Address_Line_1__c : '';
                    String address2 = add.Address_Line_2__c !=null ? add.Address_Line_2__c : '';
                    String address3 = add.Address_Line_3__c !=null ? add.Address_Line_3__c : '';
                    String state    = add.State__c !=null ? add.State__c : '';
                    String pincde  	= add.Pincode__c !=null ? add.Pincode__c : '';
                    String enrThrghEnq = add.Enriched_Through_Enquiry__c !=null ? add.Enriched_Through_Enquiry__c : ''; 
                    AddressWrapper addwrpObj = new AddressWrapper();
                    addwrpObj.address = address1 + ', ' + address2 + ', ' + address3 + ', ' + state + ', ' + pincde;
                    addwrpObj.dateReported = add.Date_Reported__c != null ? Datetime.newInstance(add.Date_Reported__c.year(), add.Date_Reported__c.month(), add.Date_Reported__c.day()).format('dd-MM-yyyy') : '';
                    addwrpObj.enquiry = enrThrghEnq == 'Y' ? '(e)' : '';
                    system.debug('addwrpObj'+addwrpObj);
                    addrssList.add(addwrpObj);
                }
            }
            
            if(String.isNotBlank(applcntList[0].Bureau_Results__r[0].Name_of_Applicant__c)){
                customerName = applcntList[0].Bureau_Results__r[0].Name_of_Applicant__c;
            }
            if(applcntList[0].Bureau_Results__r[0].DOB__c != null){
                Integer days = applcntList[0].Bureau_Results__r[0].DOB__c.daysBetween(Date.Today());
                Integer age = Integer.valueOf(days/365);
                Datetime dateOfBirth = applcntList[0].Bureau_Results__r[0].DOB__c;
                ageAndDob = age+' yrs, '+Datetime.newInstance(dateOfBirth.year(), dateOfBirth.month(), dateOfBirth.day()).format('dd-MM-yyyy');
            }
            if(String.isNotBlank(applcntList[0].Bureau_Results__r[0].TelephoneNumber__c)){
                conList = applcntList[0].Bureau_Results__r[0].TelephoneNumber__c.split(',');
            }
            if(String.isNotBlank(applcntList[0].Bureau_Results__r[0].EmailID__c)){
                emailList = applcntList[0].Bureau_Results__r[0].EmailID__c.split(',');
            }
            if(applcntList[0].Bureau_Results__r[0].Bureau_Score__c != null){
                bureauScore  = String.valueOf(
                    applcntList[0].Bureau_Results__r[0].Bureau_Score__c >=100 && 
                    applcntList[0].Bureau_Results__r[0].Bureau_Score__c <=200 &&
                	Utility.getTypeOfWheeler(applcntList[0].loan__r.Product__c) =='Four Wheeler' ?  -1 :
                	applcntList[0].Bureau_Results__r[0].Bureau_Score__c);
            }
            
            
            List<Bank_Account_Records__c> barList = [SELECT id, Account_Opening_Date__c, Type_of_Loan__c, Loan_Amount__c, Account_Closing_Date__c, 
                                                     Total_Outstanding__c, Amount_Overdue__c, Owenership_Indicator__c, Is_Enquiry_Type__c, Date_Of_Enquiry__c,
                                                     Name_of_the_Financier__c, Reported_Date__c, Payment_Frequency__c, Tenure__c, No_of_Emi_Paid__c, EMI_Amount__c, 
                                                     Suit_Filed_Or_Wilful_Default__c, Highest_12_Month_DPD__c, Highest_12_24_Month_DPD__c, Highest_24_36_Month_DPD__c,
                                                     Highest_Overall_DPD__c, Average_12_Month_DPD__c, Average_Delay__c
                                                     FROM Bank_Account_Records__c WHERE (RecordType.Name = 'CIBIL' AND Bureau_Results__c =: applcntList[0].Bureau_Results__r[0].id)
                                                     ORDER BY Account_Opening_Date__c];
            if(barList.size() >0){
                barWrapList = new List<BankAccountWrapper>();
                DateTime oldestDate = barList[0].Account_Opening_Date__c;
                bureauVintageDate = oldestDate != null ? Datetime.newInstance(oldestDate.year(), oldestDate.month(), oldestDate.day()).format('dd-MM-yyyy') : '';
                ttlFacltsUnscrdLoanCount = 0;
                ttlFacltsUnscrdLoanSnctnAmount = 0;
                ttlFacltsVhclLoanCount = 0;
                ttlFacltsVhclLoanSnctnAmount = 0;
                ttlFacltsHomeLoanCount = 0;
                ttlFacltsHomeLoanSnctnAmount = 0;
                ttlFacltsOthrLoanCount = 0;
                ttlFacltsOthrLoanSnctnAmount = 0;
                ttlFacltsLoanCount = 0;
                ttlFacltsLoanSnctnAmount = 0;
                
                ttlLivePOSUnscrdLoanCount = 0;
                ttlLivePOSUnscrdLoanSnctnAmount = 0;
                ttlLivePOSVhclLoanCount = 0;
                ttlLivePOSVhclLoanSnctnAmount = 0;
                ttlLivePOSHomeLoanCount = 0;
                ttlLivePOSHomeLoanSnctnAmount = 0;
                ttlLivePOSOthrLoanCount = 0;
                ttlLivePOSOthrLoanSnctnAmount = 0;
                ttlLivePOSLoanCount = 0;
                ttlLivePOSLoanSnctnAmount = 0;
                
                ttlOvrDueUnscrdLoanCount = 0;
                ttlOvrDueUnscrdLoanSnctnAmount = 0;
                ttlOvrDueVhclLoanCount = 0;
                ttlOvrDueVhclLoanSnctnAmount = 0;
                ttlOvrDueHomeLoanCount = 0;
                ttlOvrDueHomeLoanSnctnAmount = 0;
                ttlOvrDueOthrLoanCount = 0;
                ttlOvrDueOthrLoanSnctnAmount = 0;
                ttlOvrDueLoanCount = 0;
                ttlOvrDueLoanSnctnAmount = 0;
                
                ttlAvldFacltUnscrdLoanCount = 0;
                ttlAvldFacltUnscrdLoanSnctnAmount = 0;
                ttlAvldFacltVhclLoanCount = 0;
                ttlAvldFacltVhclLoanSnctnAmount = 0;
                ttlAvldFacltHomeLoanCount = 0;
                ttlAvldFacltHomeLoanSnctnAmount = 0;
                ttlAvldFacltOthrLoanCount = 0;
                ttlAvldFacltOthrLoanSnctnAmount = 0;
                ttlAvldFacltLoanCount = 0;
                ttlAvldFacltLoanSnctnAmount = 0;
                
                ttlClsdFacltUnscrdLoanCount = 0;
                ttlClsdFacltUnscrdLoanSnctnAmount = 0;
                ttlClsdFacltVhclLoanCount = 0;
                ttlClsdFacltVhclLoanSnctnAmount = 0;
                ttlClsdFacltHomeLoanCount = 0;
                ttlClsdFacltHomeLoanSnctnAmount = 0;
                ttlClsdFacltOthrLoanCount = 0;
                ttlClsdFacltOthrLoanSnctnAmount = 0;
                ttlClsdFacltLoanCount = 0;
                ttlClsdFacltLoanSnctnAmount = 0;
                
                ttlLiveLoanUnscrdLoanCount = 0;
                ttlLiveLoanUnscrdLoanSnctnAmount = 0;
                ttlLiveLoanVhclLoanCount = 0;
                ttlLiveLoanVhclLoanSnctnAmount = 0;
                ttlLiveLoanHomeLoanCount = 0;
                ttlLiveLoanHomeLoanSnctnAmount = 0;
                ttlLiveLoanOthrLoanCount = 0;
                ttlLiveLoanOthrLoanSnctnAmount = 0;
                ttlLiveLoanLoanCount = 0;
                ttlLiveLoanLoanSnctnAmount = 0;
                
                ttlOvrDueFacltUnscrdLoanCount = 0;
                ttlOvrDueFacltUnscrdLoanSnctnAmount = 0;
                ttlOvrDueFacltVhclLoanCount = 0;
                ttlOvrDueFacltVhclLoanSnctnAmount = 0;
                ttlOvrDueFacltHomeLoanCount = 0;
                ttlOvrDueFacltHomeLoanSnctnAmount = 0;
                ttlOvrDueFacltOthrLoanCount = 0;
                ttlOvrDueFacltOthrLoanSnctnAmount = 0;
                ttlOvrDueFacltLoanCount = 0;
                ttlOvrDueFacltLoanSnctnAmount = 0;
                
                ttlSOWUnscrdLoanCount = 0;
                ttlSOWUnscrdLoanSnctnAmount = 0;
                ttlSOWVhclLoanCount = 0;
                ttlSOWVhclLoanSnctnAmount = 0;
                ttlSOWHomeLoanCount = 0;
                ttlSOWHomeLoanSnctnAmount = 0;
                ttlSOWOthrLoanCount = 0;
                ttlSOWOthrLoanSnctnAmount = 0;
                ttlSOWLoanCount = 0;
                ttlSOWLoanSnctnAmount = 0;
                
                ttlCoAppUnscrdLoanCount = 0;
                ttlCoAppUnscrdLoanSnctnAmount = 0;
                ttlCoAppVhclLoanCount = 0;
                ttlCoAppVhclLoanSnctnAmount = 0;
                ttlCoAppHomeLoanCount = 0;
                ttlCoAppHomeLoanSnctnAmount = 0;
                ttlCoAppOthrLoanCount = 0;
                ttlCoAppOthrLoanSnctnAmount = 0;
                ttlCoAppLoanCount = 0;
                ttlCoAppLoanSnctnAmount = 0;
                
                ttlGTRUnscrdLoanCount = 0;
                ttlGTRUnscrdLoanSnctnAmount = 0;
                ttlGTRVhclLoanCount = 0;
                ttlGTRVhclLoanSnctnAmount = 0;
                ttlGTRHomeLoanCount = 0;
                ttlGTRHomeLoanSnctnAmount = 0;
                ttlGTROthrLoanCount = 0;
                ttlGTROthrLoanSnctnAmount = 0;
                ttlGTRLoanCount = 0;
                ttlGTRLoanSnctnAmount = 0;
                
                ttlLstOneMnthUnscrdEnqCount = 0;
                ttlLstOneMnthVhclEnqCount = 0;
                ttlLstOneMnthHomeEnqCount = 0;
                ttlLstOneMnthOthrEnqCount = 0;
                ttlLstOneMnthEnqCount = 0;
                
                ttlLstOneToThreeMnthUnscrdEnqCount = 0;
                ttlLstOneToThreeMnthVhclEnqCount = 0;
                ttlLstOneToThreeMnthHomeEnqCount = 0;
                ttlLstOneToThreeMnthOthrEnqCount = 0;
                ttlLstOneToThreeMnthEnqCount = 0;
                
                ttlLstFourToSixMnthUnscrdEnqCount = 0;
                ttlLstFourToSixMnthVhclEnqCount = 0;
                ttlLstFourToSixMnthHomeEnqCount = 0;
                ttlLstFourToSixMnthOthrEnqCount = 0;
                ttlLstFourToSixMnthEnqCount = 0;
                
                ttlLstThreeMnthUnscrdLoanCount = 0;
                ttlLstThreeMnthVhclLoanCount = 0;
                ttlLstThreeMnthHomeLoanCount = 0;
                ttlLstThreeMnthOthrLoanCount = 0;
                ttlLstThreeMnthLoanCount = 0;
                
                ttlLstThreeToSixMnthUnscrdLoanCount = 0;
                ttlLstThreeToSixMnthVhclLoanCount = 0;
                ttlLstThreeToSixMnthHomeLoanCount = 0;
                ttlLstThreeToSixMnthOthrLoanCount = 0;
                ttlLstThreeToSixMnthLoanCount = 0;
                
                ttlLstSvnToTwlvMnthUnscrdLoanCount = 0;
                ttlLstSvnToTwlvMnthVhclLoanCount = 0;
                ttlLstSvnToTwlvMnthHomeLoanCount = 0;
                ttlLstSvnToTwlvMnthOthrLoanCount = 0;
                ttlLstSvnToTwlvMnthLoanCount = 0;
                
                ttlLstTwlvPlusUnscrdLoanCount = 0;
                ttlLstTwlvPlusMnthVhclLoanCount = 0;
                ttlLstTwlvPlusMnthHomeLoanCount = 0;
                ttlLstTwlvPlusMnthOthrLoanCount = 0;
                ttlLstTwlvPlusMnthLoanCount = 0;
                
                sutfldFacltUnscrdLoan = '';
                sutfldFacltVhclLoan = '';
                sutfldFacltHomeLoan = '';
                sutfldFacltOthrLoan = '';
                sutfldFacltLoan = '';
                
                wrtoffFacltUnscrdLoan = '';
                wrtoffFacltVhclLoan = '';
                wrtoffFacltHomeLoan = '';
                wrtoffFacltOthrLoan = '';
                wrtoffFacltLoan = '';
                
                
                lstTwlvMnthHghstDpdUnscrdSowJnt = '';
                lstTwlvMnthHghstDpdVhclSowJnt= '';
                lstTwlvMnthHghstDpdHomeSowJnt= '';
                lstTwlvMnthHghstDpdOtherSowJnt= '';
                
                lstTwlvToTwntyFourMnthHghstDpdUnscrdSowJnt= '';
                lstTwlvToTwntyFourMnthHghstDpdVhclSowJnt= '';
                lstTwlvToTwntyFourMnthHghstDpdHomeSowJnt= '';
                lstTwlvToTwntyFourMnthHghstDpdOtherSowJnt= '';
                
                lstTwntyFourToThrtySixMnthHghstDpdUnscrdSowJnt= '';
                lstTwntyFourToThrtySixMnthHghstDpdVhclSowJnt= '';
                lstTwntyFourToThrtySixMnthHghstDpdHomeSowJnt= '';
                lstTwntyFourToThrtySixMnthHghstDpdOtherSowJnt= '';
                
                lstTwlvMnthHghstDpdUnscrdGrntee = '';
                lstTwlvMnthHghstDpdVhclGrntee= '';
                lstTwlvMnthHghstDpdHomeGrntee= '';
                lstTwlvMnthHghstDpdOtherGrntee= '';
                
                lstTwlvToTwntyFourMnthHghstDpdUnscrdGrntee= '';
                lstTwlvToTwntyFourMnthHghstDpdVhclGrntee= '';
                lstTwlvToTwntyFourMnthHghstDpdHomeGrntee= '';
                lstTwlvToTwntyFourMnthHghstDpdOtherGrntee= '';
                
                lstTwntyFourToThrtySixMnthHghstDpdUnscrdGrntee= '';
                lstTwntyFourToThrtySixMnthHghstDpdVhclGrntee= '';
                lstTwntyFourToThrtySixMnthHghstDpdHomeGrntee= '';
                lstTwntyFourToThrtySixMnthHghstDpdOtherGrntee= '';
                
                //declare list of String variable.
                List<String> twlvUnscrdSowJntList = new List<String>();
                List<String> twlvToTwntyFourUnscrdSowJntList = new List<String>();
                List<String> twntyFourToThrtySixUnscrdSowJntList = new List<String>();
                List<String> twlvVhclSowJntList = new List<String>();
                List<String> twlvToTwntyFourVhclSowJntList = new List<String>();
                List<String> twntyFourToThrtySixVhclSowJntList = new List<String>();
                List<String> twlvHomeSowJntList = new List<String>();
                List<String> twlvToTwntyFourHomeSowJntList = new List<String>();
                List<String> twntyFourToThrtySixHomeSowJntList = new List<String>();
                List<String> twlvOthrSowJntList = new List<String>();
                List<String> twlvToTwntyFourOthrSowJntList = new List<String>();
                List<String> twntyFourToThrtySixOthrSowJntList = new List<String>();
                
                List<String> twlvUnscrdGrnteeList = new List<String>();
                List<String> twlvToTwntyFourUnscrdGrnteeList = new List<String>();
                List<String> twntyFourToThrtySixUnscrdGrnteeList = new List<String>();
                List<String> twlvVhclGrnteeList = new List<String>();
                List<String> twlvToTwntyFourVhclGrnteeList = new List<String>();
                List<String> twntyFourToThrtySixVhclGrnteeList = new List<String>();
                List<String> twlvHomeGrnteeList = new List<String>();
                List<String> twlvToTwntyFourHomeGrnteeList = new List<String>();
                List<String> twntyFourToThrtySixHomeGrnteeList = new List<String>();
                List<String> twlvOthrGrnteeList = new List<String>();
                List<String> twlvToTwntyFourOthrGrnteeList = new List<String>();
                List<String> twntyFourToThrtySixOthrGrnteeList = new List<String>();
                for(Bank_Account_Records__c bar : barList){
                    if(bar.Is_Enquiry_Type__c == False){
                        BankAccountWrapper barObj = new BankAccountWrapper();
                        barObj.fnncrName = bar.Name_of_the_Financier__c != null ? bar.Name_of_the_Financier__c : '';
                        barObj.loanType = bar.Type_of_Loan__c != null ? bar.Type_of_Loan__c : '';
                        barObj.startDate = bar.Account_Opening_Date__c != null ? Datetime.newInstance(bar.Account_Opening_Date__c.year(), bar.Account_Opening_Date__c.month(), bar.Account_Opening_Date__c.day()).format('dd-MM-yyyy') : '';
                        barObj.endDate = bar.Account_Closing_Date__c != null ? Datetime.newInstance(bar.Account_Closing_Date__c.year(), bar.Account_Closing_Date__c.month(), bar.Account_Closing_Date__c.day()).format('dd-MM-yyyy') : '';
                        barObj.dateRprtd = bar.Reported_Date__c != null ? Datetime.newInstance(bar.Reported_Date__c.year(), bar.Reported_Date__c.month(), bar.Reported_Date__c.day()).format('dd-MM-yyyy') : '';
                        barObj.loanAmount = bar.Loan_Amount__c != null ? String.valueOf(bar.Loan_Amount__c.setScale(0)) : '';
                        barObj.pmtFrqncy = bar.Payment_Frequency__c != null ? bar.Payment_Frequency__c : '';
                        barObj.tenure = bar.Tenure__c != null ? bar.Tenure__c : '';
                        barObj.emiPaid = bar.No_of_Emi_Paid__c != null ? String.valueOf(bar.No_of_Emi_Paid__c) : '';
                        barObj.odAmount = bar.Amount_Overdue__c != null ? String.valueOf(bar.Amount_Overdue__c.setScale(0)) : '';
                        barObj.emiAmount = bar.EMI_Amount__c != null ? String.valueOf(bar.EMI_Amount__c.setScale(0)) : '';
                        barObj.peakDelayInTwlvMnths = bar.Highest_12_Month_DPD__c != null ? String.valueOf(bar.Highest_12_Month_DPD__c) : '';
                        barObj.avgDelayInTwlvMnths = bar.Average_12_Month_DPD__c != null ? String.valueOf(bar.Average_12_Month_DPD__c ) : '';
                        barObj.ownrshp = bar.Owenership_Indicator__c != null ? bar.Owenership_Indicator__c : '';
                        barObj.status = bar.Suit_Filed_Or_Wilful_Default__c != null ? bar.Suit_Filed_Or_Wilful_Default__c : '';
                        barObj.peakDelayOvrall = bar.Highest_Overall_DPD__c != null ? String.valueOf(bar.Highest_Overall_DPD__c ) : '';
                        barObj.avgDelayOvrall = bar.Average_Delay__c != null ? String.valueOf(bar.Average_Delay__c ) : '';
                        barWrapList.add(barObj);
                        if(bar.Type_of_Loan__c != null){
                            if(bar.Type_of_Loan__c.contains('Unsecured') || bar.Type_of_Loan__c.contains('Personal')){
                                ttlFacltsUnscrdLoanCount++;
                                if(bar.Loan_Amount__c != null)
                                    ttlFacltsUnscrdLoanSnctnAmount +=  bar.Loan_Amount__c.setScale(0);
                                if(bar.Account_Closing_Date__c == null){
                                    ttlLivePOSUnscrdLoanCount++;
                                    ttlLiveLoanUnscrdLoanCount++;
                                    if(bar.Total_Outstanding__c  != null)
                                        ttlLivePOSUnscrdLoanSnctnAmount +=  bar.Total_Outstanding__c.setScale(0) ;
                                    if(bar.Loan_Amount__c != null)
                                        ttlLiveLoanUnscrdLoanSnctnAmount += bar.Loan_Amount__c.setScale(0);
                                }
                                else{
                                    ttlClsdFacltUnscrdLoanCount++;
                                    if(bar.Loan_Amount__c != null)
                                        ttlClsdFacltUnscrdLoanSnctnAmount +=  bar.Loan_Amount__c.setScale(0);
                                }
                                if(bar.Amount_Overdue__c != null){
                                    ttlOvrDueUnscrdLoanCount++;
                                    ttlOvrDueFacltUnscrdLoanCount++;
                                    ttlOvrDueUnscrdLoanSnctnAmount += bar.Amount_Overdue__c.setScale(0);
                                    if(bar.Loan_Amount__c != null)
                                        ttlOvrDueFacltUnscrdLoanSnctnAmount += bar.Loan_Amount__c.setScale(0);
                                }
                                if(bar.Account_Opening_Date__c != null){
                                    if(bar.Account_Opening_Date__c > Date.today().addYears(-3)){
                                        ttlAvldFacltUnscrdLoanCount++;
                                        if(bar.Loan_Amount__c != null)
                                            ttlAvldFacltUnscrdLoanSnctnAmount += bar.Loan_Amount__c.setScale(0);
                                    }
                                    if(bar.Account_Opening_Date__c > Date.today().addMonths(-3)){
                                        ttlLstThreeMnthUnscrdLoanCount++;
                                    }
                                    else if(bar.Account_Opening_Date__c < Date.today().addMonths(-3) && bar.Account_Opening_Date__c > Date.today().addMonths(-6)){
                                        ttlLstThreeToSixMnthUnscrdLoanCount++;
                                    }
                                    else if(bar.Account_Opening_Date__c < Date.today().addMonths(-6) && bar.Account_Opening_Date__c > Date.today().addMonths(-12)){
                                        ttlLstSvnToTwlvMnthUnscrdLoanCount++;
                                    }
                                    else{
                                        ttlLstTwlvPlusUnscrdLoanCount++;
                                    }
                                }
                                if(bar.Owenership_Indicator__c != null){
                                    if(bar.Owenership_Indicator__c == 'Individual'){
                                        ttlSOWUnscrdLoanCount++;
                                        if(bar.Loan_Amount__c != null)
                                            ttlSOWUnscrdLoanSnctnAmount += bar.Loan_Amount__c;
                                        if(bar.Highest_12_Month_DPD__c != null)
                                            twlvUnscrdSowJntList.add(bar.Highest_12_Month_DPD__c);
                                        if(bar.Highest_12_24_Month_DPD__c != null)
                                            twlvToTwntyFourUnscrdSowJntList.add(bar.Highest_12_24_Month_DPD__c);
                                        if(bar.Highest_24_36_Month_DPD__c != null)
                                            twntyFourToThrtySixUnscrdSowJntList.add(bar.Highest_24_36_Month_DPD__c);
                                    }
                                    else if(bar.Owenership_Indicator__c == 'Joint'){ 
                                        ttlCoAppUnscrdLoanCount++;
                                        if(bar.Loan_Amount__c != null)
                                            ttlCoAppUnscrdLoanSnctnAmount += bar.Loan_Amount__c;
                                        if(bar.Highest_12_Month_DPD__c != null)
                                            twlvUnscrdSowJntList.add(bar.Highest_12_Month_DPD__c);
                                        if(bar.Highest_12_24_Month_DPD__c != null)
                                            twlvToTwntyFourUnscrdSowJntList.add(bar.Highest_12_24_Month_DPD__c);
                                        if(bar.Highest_24_36_Month_DPD__c != null)
                                            twntyFourToThrtySixUnscrdSowJntList.add(bar.Highest_24_36_Month_DPD__c);
                                    }
                                    else if(bar.Owenership_Indicator__c == 'Guarantor'){
                                        ttlGTRUnscrdLoanCount++;
                                        if(bar.Loan_Amount__c != null)
                                            ttlGTRUnscrdLoanSnctnAmount += bar.Loan_Amount__c;
                                        if(bar.Highest_12_Month_DPD__c != null)
                                            twlvUnscrdGrnteeList.add(bar.Highest_12_Month_DPD__c);
                                        if(bar.Highest_12_24_Month_DPD__c != null)
                                            twlvToTwntyFourUnscrdGrnteeList.add(bar.Highest_12_24_Month_DPD__c);
                                        if(bar.Highest_24_36_Month_DPD__c != null)
                                            twntyFourToThrtySixUnscrdGrnteeList.add(bar.Highest_24_36_Month_DPD__c);
                                    }
                                }
                            }
                            else{
                                if(bar.Type_of_Loan__c.contains('Auto') || bar.Type_of_Loan__c.contains('Two-wheeler') || 
                                   bar.Type_of_Loan__c.contains('Four-wheeler') || bar.Type_of_Loan__c.contains('Commercial') ||
                                   bar.Type_of_Loan__c.contains('Tractor')){
                                       ttlFacltsVhclLoanCount++;
                                       if(bar.Loan_Amount__c != null)
                                           ttlFacltsVhclLoanSnctnAmount +=  bar.Loan_Amount__c;
                                       if(bar.Account_Closing_Date__c == null){
                                           ttlLivePOSVhclLoanCount++;
                                           ttlLiveLoanVhclLoanCount++;
                                           if(bar.Total_Outstanding__c  != null)
                                               ttlLivePOSVhclLoanSnctnAmount +=  bar.Total_Outstanding__c ;
                                           if(bar.Loan_Amount__c != null)
                                               ttlLiveLoanVhclLoanSnctnAmount += bar.Loan_Amount__c;
                                       }
                                       else{
                                           ttlClsdFacltVhclLoanCount++;
                                           if(bar.Loan_Amount__c != null)
                                               ttlClsdFacltVhclLoanSnctnAmount +=  bar.Loan_Amount__c;
                                       }
                                       if(bar.Amount_Overdue__c != null){
                                           ttlOvrDueVhclLoanCount++;
                                           ttlOvrDueFacltVhclLoanCount++;
                                           ttlOvrDueVhclLoanSnctnAmount += bar.Amount_Overdue__c;
                                           if(bar.Loan_Amount__c != null)
                                               ttlOvrDueFacltVhclLoanSnctnAmount += bar.Loan_Amount__c;
                                       }
                                       if(bar.Account_Opening_Date__c != null){
                                           if(bar.Account_Opening_Date__c > Date.today().addYears(-3)){
                                               ttlAvldFacltVhclLoanCount++;
                                               if(bar.Loan_Amount__c != null)
                                                   ttlAvldFacltVhclLoanSnctnAmount += bar.Loan_Amount__c;
                                           }
                                           if(bar.Account_Opening_Date__c > Date.today().addMonths(-3)){
                                               ttlLstThreeMnthVhclLoanCount++;
                                           }
                                           else if(bar.Account_Opening_Date__c < Date.today().addMonths(-3) && bar.Account_Opening_Date__c > Date.today().addMonths(-6)){
                                               ttlLstThreeToSixMnthVhclLoanCount++;
                                           }
                                           else if(bar.Account_Opening_Date__c < Date.today().addMonths(-6) && bar.Account_Opening_Date__c > Date.today().addMonths(-12)){
                                               ttlLstSvnToTwlvMnthVhclLoanCount++;
                                           }
                                           else{
                                               ttlLstTwlvPlusMnthVhclLoanCount++;
                                           }
                                       }
                                       if(bar.Owenership_Indicator__c != null){
                                           if(bar.Owenership_Indicator__c == 'Individual'){
                                               ttlSOWVhclLoanCount++;
                                               if(bar.Loan_Amount__c != null)
                                                   ttlSOWVhclLoanSnctnAmount += bar.Loan_Amount__c;
                                               if(bar.Highest_12_Month_DPD__c != null)
                                                   twlvVhclSowJntList.add(bar.Highest_12_Month_DPD__c);
                                               if(bar.Highest_12_24_Month_DPD__c != null)
                                                   twlvToTwntyFourVhclSowJntList.add(bar.Highest_12_24_Month_DPD__c);
                                               if(bar.Highest_24_36_Month_DPD__c != null)
                                                   twntyFourToThrtySixVhclSowJntList.add(bar.Highest_24_36_Month_DPD__c);
                                               
                                           }
                                           else if(bar.Owenership_Indicator__c == 'Joint'){ 
                                               ttlCoAppVhclLoanCount++;
                                               if(bar.Loan_Amount__c != null)
                                                   ttlCoAppVhclLoanSnctnAmount += bar.Loan_Amount__c;
                                               if(bar.Highest_12_Month_DPD__c != null)
                                                   twlvVhclSowJntList.add(bar.Highest_12_Month_DPD__c);
                                               if(bar.Highest_12_24_Month_DPD__c != null)
                                                   twlvToTwntyFourVhclSowJntList.add(bar.Highest_12_24_Month_DPD__c);
                                               if(bar.Highest_24_36_Month_DPD__c != null)
                                                   twntyFourToThrtySixVhclSowJntList.add(bar.Highest_24_36_Month_DPD__c);
                                           }
                                           else if(bar.Owenership_Indicator__c == 'Guarantor'){
                                               ttlGTRVhclLoanCount++;
                                               if(bar.Loan_Amount__c != null)
                                                   ttlGTRVhclLoanSnctnAmount += bar.Loan_Amount__c;
                                               if(bar.Highest_12_Month_DPD__c != null)
                                                   twlvVhclGrnteeList.add(bar.Highest_12_Month_DPD__c);
                                               if(bar.Highest_12_24_Month_DPD__c != null)
                                                   twlvToTwntyFourVhclGrnteeList.add(bar.Highest_12_24_Month_DPD__c);
                                               if(bar.Highest_24_36_Month_DPD__c != null)
                                                   twntyFourToThrtySixVhclGrnteeList.add(bar.Highest_24_36_Month_DPD__c);
                                           }
                                       }
                                   }
                                else if(bar.Type_of_Loan__c.contains('Housing')){
                                    ttlFacltsHomeLoanCount++;
                                    if(bar.Loan_Amount__c != null)
                                        ttlFacltsHomeLoanSnctnAmount +=  bar.Loan_Amount__c;
                                    if(bar.Account_Closing_Date__c == null){
                                        ttlLivePOSHomeLoanCount++;
                                        ttlLiveLoanHomeLoanCount++;
                                        if(bar.Total_Outstanding__c  != null)
                                            ttlLivePOSHomeLoanSnctnAmount +=  bar.Total_Outstanding__c ;
                                        if(bar.Loan_Amount__c != null)
                                            ttlLiveLoanHomeLoanSnctnAmount += bar.Loan_Amount__c;
                                    }
                                    else{
                                        ttlClsdFacltHomeLoanCount++;
                                        if(bar.Loan_Amount__c != null)
                                            ttlClsdFacltHomeLoanSnctnAmount +=  bar.Loan_Amount__c;
                                    }
                                    if(bar.Amount_Overdue__c != null){
                                        ttlOvrDueHomeLoanCount++;
                                        ttlOvrDueFacltHomeLoanCount++;
                                        ttlOvrDueHomeLoanSnctnAmount += bar.Amount_Overdue__c;
                                        if(bar.Loan_Amount__c != null)
                                            ttlOvrDueFacltHomeLoanSnctnAmount += bar.Loan_Amount__c;
                                        
                                    }
                                    if(bar.Account_Opening_Date__c != null){
                                        if(bar.Account_Opening_Date__c > Date.today().addYears(-3)){
                                            ttlAvldFacltHomeLoanCount++;
                                            if(bar.Loan_Amount__c != null)
                                                ttlAvldFacltHomeLoanSnctnAmount += bar.Loan_Amount__c;
                                        }
                                        if(bar.Account_Opening_Date__c > Date.today().addMonths(-3)){
                                            ttlLstThreeMnthHomeLoanCount++;
                                        }
                                        else if(bar.Account_Opening_Date__c < Date.today().addMonths(-3) && bar.Account_Opening_Date__c > Date.today().addMonths(-6)){
                                            ttlLstThreeToSixMnthHomeLoanCount++;
                                        }
                                        else if(bar.Account_Opening_Date__c < Date.today().addMonths(-6) && bar.Account_Opening_Date__c > Date.today().addMonths(-12)){
                                            ttlLstSvnToTwlvMnthHomeLoanCount++;
                                        }
                                        else{
                                            ttlLstTwlvPlusMnthHomeLoanCount++;
                                        }
                                    }
                                    if(bar.Owenership_Indicator__c != null){
                                        if(bar.Owenership_Indicator__c == 'Individual'){
                                            ttlSOWHomeLoanCount++;
                                            if(bar.Loan_Amount__c != null)
                                                ttlSOWHomeLoanSnctnAmount += bar.Loan_Amount__c;
                                            if(bar.Highest_12_Month_DPD__c != null)
                                                twlvHomeSowJntList.add(bar.Highest_12_Month_DPD__c);
                                            if(bar.Highest_12_24_Month_DPD__c != null)
                                                twlvToTwntyFourHomeSowJntList.add(bar.Highest_12_24_Month_DPD__c);
                                            if(bar.Highest_24_36_Month_DPD__c != null)
                                                twntyFourToThrtySixHomeSowJntList.add(bar.Highest_24_36_Month_DPD__c);
                                        }
                                        else if(bar.Owenership_Indicator__c == 'Joint'){ 
                                            ttlCoAppHomeLoanCount++;
                                            if(bar.Loan_Amount__c != null)
                                                ttlCoAppHomeLoanSnctnAmount += bar.Loan_Amount__c;
                                            if(bar.Highest_12_Month_DPD__c != null)
                                                twlvHomeSowJntList.add(bar.Highest_12_Month_DPD__c);
                                            if(bar.Highest_12_24_Month_DPD__c != null)
                                                twlvToTwntyFourHomeSowJntList.add(bar.Highest_12_24_Month_DPD__c);
                                            if(bar.Highest_24_36_Month_DPD__c != null)
                                                twntyFourToThrtySixHomeSowJntList.add(bar.Highest_24_36_Month_DPD__c);
                                        }
                                        else if(bar.Owenership_Indicator__c == 'Guarantor'){
                                            ttlGTRHomeLoanCount++;
                                            if(bar.Loan_Amount__c != null)
                                                ttlGTRHomeLoanSnctnAmount += bar.Loan_Amount__c;
                                            if(bar.Highest_12_Month_DPD__c != null)
                                                twlvHomeGrnteeList.add(bar.Highest_12_Month_DPD__c);
                                            if(bar.Highest_12_24_Month_DPD__c != null)
                                                twlvToTwntyFourHomeGrnteeList.add(bar.Highest_12_24_Month_DPD__c);
                                            if(bar.Highest_24_36_Month_DPD__c != null)
                                                twntyFourToThrtySixHomeGrnteeList.add(bar.Highest_24_36_Month_DPD__c);
                                        }
                                    }
                                    
                                }
                                else{
                                    ttlFacltsOthrLoanCount++;
                                    if(bar.Loan_Amount__c != null)
                                        ttlFacltsOthrLoanSnctnAmount +=  bar.Loan_Amount__c;
                                    if(bar.Account_Closing_Date__c == null){
                                        ttlLivePOSOthrLoanCount++;
                                        ttlLiveLoanOthrLoanCount++;
                                        if(bar.Total_Outstanding__c  != null)
                                            ttlLivePOSOthrLoanSnctnAmount +=  bar.Total_Outstanding__c ;
                                        if(bar.Loan_Amount__c != null)
                                            ttlLiveLoanOthrLoanSnctnAmount += bar.Loan_Amount__c;
                                    }
                                    else{
                                        ttlClsdFacltOthrLoanCount++;
                                        if(bar.Loan_Amount__c != null)
                                            ttlClsdFacltOthrLoanSnctnAmount +=  bar.Loan_Amount__c;
                                    }
                                    if(bar.Amount_Overdue__c != null){
                                        ttlOvrDueOthrLoanCount++;
                                        ttlOvrDueFacltOthrLoanCount++;
                                        ttlOvrDueOthrLoanSnctnAmount += bar.Amount_Overdue__c;
                                        if(bar.Loan_Amount__c != null)
                                            ttlOvrDueFacltOthrLoanSnctnAmount += bar.Loan_Amount__c;
                                        
                                    }
                                    if(bar.Account_Opening_Date__c != null){
                                        if(bar.Account_Opening_Date__c > Date.today().addYears(-3)){
                                            ttlAvldFacltOthrLoanCount++;
                                            if(bar.Loan_Amount__c != null)
                                                ttlAvldFacltOthrLoanSnctnAmount += bar.Loan_Amount__c;
                                        }
                                        if(bar.Account_Opening_Date__c > Date.today().addMonths(-3)){
                                            ttlLstThreeMnthOthrLoanCount++;
                                        }
                                        else if(bar.Account_Opening_Date__c < Date.today().addMonths(-3) && bar.Account_Opening_Date__c > Date.today().addMonths(-6)){
                                            ttlLstThreeToSixMnthOthrLoanCount++;
                                        }
                                        else if(bar.Account_Opening_Date__c < Date.today().addMonths(-6) && bar.Account_Opening_Date__c > Date.today().addMonths(-12)){
                                            ttlLstSvnToTwlvMnthOthrLoanCount++;
                                        }
                                        else{
                                            ttlLstTwlvPlusMnthOthrLoanCount++;
                                        }
                                    }
                                    if(bar.Owenership_Indicator__c != null){
                                        if(bar.Owenership_Indicator__c == 'Individual'){
                                            ttlSOWOthrLoanCount++;
                                            if(bar.Loan_Amount__c != null)
                                                ttlSOWOthrLoanSnctnAmount += bar.Loan_Amount__c;
                                            if(bar.Highest_12_Month_DPD__c != null)
                                                twlvOthrSowJntList.add(bar.Highest_12_Month_DPD__c);
                                            if(bar.Highest_12_24_Month_DPD__c != null)
                                                twlvToTwntyFourOthrSowJntList.add(bar.Highest_12_24_Month_DPD__c);
                                            if(bar.Highest_24_36_Month_DPD__c != null)
                                                twntyFourToThrtySixOthrSowJntList.add(bar.Highest_24_36_Month_DPD__c);
                                        }
                                        else if(bar.Owenership_Indicator__c == 'Joint'){ 
                                            ttlCoAppOthrLoanCount++;
                                            if(bar.Loan_Amount__c != null)
                                                ttlCoAppOthrLoanSnctnAmount += bar.Loan_Amount__c;
                                            if(bar.Highest_12_Month_DPD__c != null)
                                                twlvOthrSowJntList.add(bar.Highest_12_Month_DPD__c);
                                            if(bar.Highest_12_24_Month_DPD__c != null)
                                                twlvToTwntyFourOthrSowJntList.add(bar.Highest_12_24_Month_DPD__c);
                                            if(bar.Highest_24_36_Month_DPD__c != null)
                                                twntyFourToThrtySixOthrSowJntList.add(bar.Highest_24_36_Month_DPD__c);
                                        }
                                        else if(bar.Owenership_Indicator__c == 'Guarantor'){
                                            ttlGTROthrLoanCount++;
                                            if(bar.Loan_Amount__c != null)
                                                ttlGTROthrLoanSnctnAmount += bar.Loan_Amount__c;
                                            if(bar.Highest_12_Month_DPD__c != null)
                                                twlvOthrGrnteeList.add(bar.Highest_12_Month_DPD__c);
                                            if(bar.Highest_12_24_Month_DPD__c != null)
                                                twlvToTwntyFourOthrGrnteeList.add(bar.Highest_12_24_Month_DPD__c);
                                            if(bar.Highest_24_36_Month_DPD__c != null)
                                                twntyFourToThrtySixOthrGrnteeList.add(bar.Highest_24_36_Month_DPD__c);
                                        }
                                    }
                                }
                            }
                            ttlFacltsLoanCount++;
                            if(bar.Loan_Amount__c != null)
                                ttlFacltsLoanSnctnAmount +=  bar.Loan_Amount__c;
                            if(bar.Account_Closing_Date__c == null){
                                ttlLivePOSLoanCount++;
                                ttlLiveLoanLoanCount++;
                                if(bar.Total_Outstanding__c != null)
                                    ttlLivePOSLoanSnctnAmount +=  bar.Total_Outstanding__c ;
                                if(bar.Loan_Amount__c != null)
                                    ttlLiveLoanLoanSnctnAmount += bar.Loan_Amount__c;
                            }
                            else{
                                ttlClsdFacltLoanCount++;
                                if(bar.Loan_Amount__c != null)
                                    ttlClsdFacltLoanSnctnAmount +=  bar.Loan_Amount__c;
                            }
                            if(bar.Amount_Overdue__c != null){
                                ttlOvrDueLoanCount++;
                                ttlOvrDueFacltLoanCount++;
                                ttlOvrDueLoanSnctnAmount += bar.Amount_Overdue__c;
                                if(bar.Loan_Amount__c != null)
                                    ttlOvrDueFacltLoanSnctnAmount += bar.Loan_Amount__c;
                            }
                            if(bar.Account_Opening_Date__c != null){
                                if(bar.Account_Opening_Date__c > Date.today().addYears(-3)){
                                    ttlAvldFacltLoanCount++;
                                    if(bar.Loan_Amount__c != null)
                                        ttlAvldFacltLoanSnctnAmount += bar.Loan_Amount__c;
                                }
                                if(bar.Account_Opening_Date__c > Date.today().addMonths(-3)){
                                    ttlLstThreeMnthLoanCount++;
                                }
                                else if(bar.Account_Opening_Date__c < Date.today().addMonths(-3) && bar.Account_Opening_Date__c > Date.today().addMonths(-6)){
                                    ttlLstThreeToSixMnthLoanCount++;
                                }
                                else if(bar.Account_Opening_Date__c < Date.today().addMonths(-6) && bar.Account_Opening_Date__c > Date.today().addMonths(-12)){
                                    ttlLstSvnToTwlvMnthLoanCount++;
                                }
                                else{
                                    ttlLstTwlvPlusMnthLoanCount++;
                                }
                            }
                            if(bar.Owenership_Indicator__c != null){
                                if(bar.Owenership_Indicator__c == 'Individual'){
                                    ttlSOWLoanCount++;
                                    if(bar.Loan_Amount__c != null)
                                        ttlSOWLoanSnctnAmount += bar.Loan_Amount__c;
                                }
                                else if(bar.Owenership_Indicator__c == 'Joint'){ 
                                    ttlCoAppLoanCount++;
                                    if(bar.Loan_Amount__c != null)
                                        ttlCoAppLoanSnctnAmount += bar.Loan_Amount__c;
                                }
                                else if(bar.Owenership_Indicator__c == 'Guarantor'){
                                    ttlGTRLoanCount++;
                                    if(bar.Loan_Amount__c != null)
                                        ttlSOWLoanSnctnAmount += bar.Loan_Amount__c;
                                }
                            }
                        } 
                    }
                    else{
                        if(bar.Type_of_Loan__c != null && bar.Date_Of_Enquiry__c != null){
                            if(bar.Type_of_Loan__c.contains('Unsecured') || bar.Type_of_Loan__c.contains('Personal')){
                                
                                if(bar.Date_Of_Enquiry__c > Date.today().addMonths(-1)){
                                    ttlLstOneMnthUnscrdEnqCount++;
                                }
                                else if(bar.Date_Of_Enquiry__c < Date.today().addMonths(-1) && 
                                        bar.Date_Of_Enquiry__c > Date.today().addMonths(-3)){
                                            ttlLstOneToThreeMnthUnscrdEnqCount++;
                                        }
                                else if(bar.Date_Of_Enquiry__c < Date.today().addMonths(-4) && 
                                        bar.Date_Of_Enquiry__c > Date.today().addMonths(-6)){
                                            ttlLstFourToSixMnthUnscrdEnqCount++;
                                        }
                                
                            }
                            else{
                                if(bar.Type_of_Loan__c.contains('Auto') || bar.Type_of_Loan__c.contains('Two-wheeler') || 
                                   bar.Type_of_Loan__c.contains('Four-wheeler') || bar.Type_of_Loan__c.contains('Commercial') ||
                                   bar.Type_of_Loan__c.contains('Tractor')){
                                       if(bar.Date_Of_Enquiry__c > Date.today().addMonths(-1)){
                                           ttlLstOneMnthVhclEnqCount++;
                                       }
                                       else if(bar.Date_Of_Enquiry__c < Date.today().addMonths(-1) && 
                                               bar.Date_Of_Enquiry__c > Date.today().addMonths(-3)){
                                                   ttlLstOneToThreeMnthVhclEnqCount++;
                                               }
                                       else if(bar.Date_Of_Enquiry__c < Date.today().addMonths(-3) && 
                                               bar.Date_Of_Enquiry__c > Date.today().addMonths(-6)){
                                                   ttlLstFourToSixMnthVhclEnqCount++;
                                               }
                                   }
                                else if(bar.Type_of_Loan__c.contains('Housing')){
                                    if(bar.Date_Of_Enquiry__c > Date.today().addMonths(-1)){
                                        ttlLstOneMnthHomeEnqCount++;
                                    }
                                    else if(bar.Date_Of_Enquiry__c < Date.today().addMonths(-1) && 
                                            bar.Date_Of_Enquiry__c > Date.today().addMonths(-3)){
                                                ttlLstOneToThreeMnthHomeEnqCount++;
                                            }
                                    else if(bar.Date_Of_Enquiry__c < Date.today().addMonths(-3) && 
                                            bar.Date_Of_Enquiry__c > Date.today().addMonths(-6)){
                                                ttlLstFourToSixMnthHomeEnqCount++;   
                                            }
                                }
                                else{
                                    if(bar.Date_Of_Enquiry__c > Date.today().addMonths(-1)){
                                        ttlLstOneMnthOthrEnqCount++;
                                    }
                                    else if(bar.Date_Of_Enquiry__c < Date.today().addMonths(-1) && 
                                            bar.Date_Of_Enquiry__c > Date.today().addMonths(-3)){
                                                ttlLstOneToThreeMnthOthrEnqCount++;
                                            }
                                    else if(bar.Date_Of_Enquiry__c < Date.today().addMonths(-3) && 
                                            bar.Date_Of_Enquiry__c > Date.today().addMonths(-6)){
                                                ttlLstFourToSixMnthOthrEnqCount++;
                                            }
                                }
                                
                            }
                            if(bar.Date_Of_Enquiry__c > Date.today().addMonths(-1)){
                                ttlLstOneMnthEnqCount++;
                            }
                            else if(bar.Date_Of_Enquiry__c < Date.today().addMonths(-1) && 
                                    bar.Date_Of_Enquiry__c > Date.today().addMonths(-3)){
                                        ttlLstOneToThreeMnthEnqCount++;
                                    }
                            else if(bar.Date_Of_Enquiry__c < Date.today().addMonths(-3) && 
                                    bar.Date_Of_Enquiry__c > Date.today().addMonths(-6)){
                                        ttlLstFourToSixMnthEnqCount++;
                                    }
                        }
                    }
                    
                }
                
                //SOW & Joint Highest DPD values
                if(twlvUnscrdSowJntList.size() > 0){
                    lstTwlvMnthHghstDpdUnscrdSowJnt = getHighestDpdFromList(twlvUnscrdSowJntList);
                }
                if(twlvToTwntyFourUnscrdSowJntList.size() > 0){
                    lstTwlvToTwntyFourMnthHghstDpdUnscrdSowJnt = getHighestDpdFromList(twlvToTwntyFourUnscrdSowJntList);
                }
                if(twntyFourToThrtySixUnscrdSowJntList.size() > 0){
                    lstTwntyFourToThrtySixMnthHghstDpdUnscrdSowJnt = getHighestDpdFromList(twntyFourToThrtySixUnscrdSowJntList);
                }
                
                if(twlvVhclSowJntList.size() > 0){
                    lstTwlvMnthHghstDpdVhclSowJnt = getHighestDpdFromList(twlvVhclSowJntList);
                }
                if(twlvToTwntyFourVhclSowJntList.size() > 0){
                    lstTwlvToTwntyFourMnthHghstDpdVhclSowJnt = getHighestDpdFromList(twlvToTwntyFourVhclSowJntList);
                }
                if(twntyFourToThrtySixVhclSowJntList.size() > 0){
                    lstTwntyFourToThrtySixMnthHghstDpdVhclSowJnt = getHighestDpdFromList(twntyFourToThrtySixVhclSowJntList);
                }
                
                if(twlvHomeSowJntList.size() > 0){
                    lstTwlvMnthHghstDpdHomeSowJnt = getHighestDpdFromList(twlvHomeSowJntList);
                }
                if(twlvToTwntyFourHomeSowJntList.size() > 0){
                    lstTwlvToTwntyFourMnthHghstDpdHomeSowJnt = getHighestDpdFromList(twlvToTwntyFourHomeSowJntList);
                }
                if(twntyFourToThrtySixHomeSowJntList.size() > 0){
                    lstTwntyFourToThrtySixMnthHghstDpdHomeSowJnt = getHighestDpdFromList(twntyFourToThrtySixHomeSowJntList);
                }
                
                if(twlvOthrSowJntList.size() > 0){
                    lstTwlvMnthHghstDpdOtherSowJnt = getHighestDpdFromList(twlvOthrSowJntList);
                }
                if(twlvToTwntyFourOthrSowJntList.size() > 0){
                    lstTwlvToTwntyFourMnthHghstDpdOtherSowJnt = getHighestDpdFromList(twlvToTwntyFourOthrSowJntList);
                }
                if(twntyFourToThrtySixOthrSowJntList.size() > 0){
                    lstTwntyFourToThrtySixMnthHghstDpdOtherSowJnt = getHighestDpdFromList(twntyFourToThrtySixOthrSowJntList);
                }
                
                //Guarantee Highest DPD values
                if(twlvUnscrdGrnteeList.size() > 0){
                    lstTwlvMnthHghstDpdUnscrdGrntee = getHighestDpdFromList(twlvUnscrdGrnteeList);
                }
                if(twlvToTwntyFourUnscrdGrnteeList.size() > 0){
                    lstTwlvToTwntyFourMnthHghstDpdUnscrdGrntee = getHighestDpdFromList(twlvToTwntyFourUnscrdGrnteeList);
                }
                if(twntyFourToThrtySixUnscrdGrnteeList.size() > 0){
                    lstTwntyFourToThrtySixMnthHghstDpdUnscrdGrntee = getHighestDpdFromList(twntyFourToThrtySixUnscrdGrnteeList);
                }
                
                if(twlvVhclGrnteeList.size() > 0){
                    lstTwlvMnthHghstDpdVhclGrntee = getHighestDpdFromList(twlvVhclGrnteeList);
                }
                if(twlvToTwntyFourVhclGrnteeList.size() > 0){
                    lstTwlvToTwntyFourMnthHghstDpdVhclGrntee = getHighestDpdFromList(twlvToTwntyFourVhclGrnteeList);
                }
                if(twntyFourToThrtySixVhclGrnteeList.size() > 0){
                    lstTwntyFourToThrtySixMnthHghstDpdVhclGrntee = getHighestDpdFromList(twntyFourToThrtySixVhclGrnteeList);
                }
                
                if(twlvHomeGrnteeList.size() > 0){
                    lstTwlvMnthHghstDpdHomeGrntee = getHighestDpdFromList(twlvHomeGrnteeList);
                }
                if(twlvToTwntyFourHomeGrnteeList.size() > 0){
                    lstTwlvToTwntyFourMnthHghstDpdHomeGrntee = getHighestDpdFromList(twlvToTwntyFourHomeGrnteeList);
                }
                if(twntyFourToThrtySixHomeGrnteeList.size() > 0){
                    lstTwntyFourToThrtySixMnthHghstDpdHomeGrntee = getHighestDpdFromList(twntyFourToThrtySixHomeGrnteeList);
                }
                
                if(twlvOthrGrnteeList.size() > 0){
                    lstTwlvMnthHghstDpdOtherGrntee = getHighestDpdFromList(twlvOthrGrnteeList);
                }
                if(twlvToTwntyFourOthrGrnteeList.size() > 0){
                    lstTwlvToTwntyFourMnthHghstDpdOtherGrntee = getHighestDpdFromList(twlvToTwntyFourOthrGrnteeList);
                }
                if(twntyFourToThrtySixOthrGrnteeList.size() > 0){
                    lstTwntyFourToThrtySixMnthHghstDpdOtherGrntee = getHighestDpdFromList(twntyFourToThrtySixOthrGrnteeList);
                }
                
                
            }
            
        }
        if(String.isNotBlank(applcntList[0].RecordType.Name)){
            rltnshpWithCase = applcntList[0].RecordType.Name;
        }
        
    }
    
    public class AddressWrapper{
        public String address{get;set;}
        public String dateReported{get;set;}
        public String enquiry{get;set;}
        public AddressWrapper(){
            this.address = '';
            this.dateReported = '';
            this.enquiry = '';
        }
    }
    
    public class BankAccountWrapper{
        public String fnncrName{get;set;}
        public String loanType{get;set;}
        public String startDate{get;set;}
        public String endDate{get;set;}
        public String dateRprtd{get;set;}
        public String loanAmount{get;set;}
        public String pmtFrqncy{get;set;}
        public String tenure{get;set;}
        public String emiPaid{get;set;}
        public String emiOd{get;set;}//?
        public String odAmount{get;set;}
        public String emiAmount{get;set;}
        public String peakDelayInTwlvMnths{get;set;}
        public String avgDelayInTwlvMnths{get;set;}//?
        public String ownrshp{get;set;}
        public String status{get;set;}
        public String peakDelayOvrall{get;set;}
        public String avgDelayOvrall{get;set;}//?
        
        public BankAccountWrapper(){
            this.fnncrName = '';
            this.loanType = '';
            this.startDate = '';
            this.endDate = '';
            this.dateRprtd = '';
            this.loanAmount = '';
            this.pmtFrqncy = '';
            this.tenure = '';
            this.emiPaid = '';
            this.emiOd = '';
            this.odAmount = '';
            this.emiAmount = '';
            this.peakDelayInTwlvMnths = '';
            this.avgDelayInTwlvMnths = '';
            this.ownrshp = '';
            this.status = '';
            this.peakDelayOvrall = '';
            this.avgDelayOvrall = '';
        }
    }
    
    public string getHighestDpdFromList(List<String> dpdList){
        Map<String, Integer> dpdCodeToHighestRange = new Map<String, Integer>{
            'XXX' => 0,
                'STD' => 0,
                'SMA' => 30, 
                'SUB' => 365, 
                'DBT' => 1095
                };
                    String highestDpd;
        if(dpdList[0].isNumeric()){
            highestDpd = dpdList[0];
        }
        else if(dpdList[0].isAlpha()){
            highestDpd = dpdCodeToHighestRange.containsKey(dpdList[0]) ? String.valueOf(dpdCodeToHighestRange.get(dpdList[0])) : '0';
        }
        
        
        for(String dpd : dpdList){
            Integer dpdValue;
            if(dpd.isNumeric()){
                dpdValue = Integer.valueOf(dpd);
            }
            else if(dpd.isAlpha()){
                dpdValue = dpdCodeToHighestRange.containsKey(dpd) ? dpdCodeToHighestRange.get(dpd) : 0;
            }
            if(dpdValue > Integer.ValueOf(highestDpd))
                highestDpd = dpd; 
            system.debug('highestDpd'+highestDpd);
        }
        system.debug('highestDpd'+highestDpd);
        return highestDpd;
    }
    
    
    
}