/*******************************************************************************************
* @Name         BSRPSLController
* @Author       Shivani Kulkarni
* @Description   Controller Class for BSR-PSL Screen
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Shivani Kulkarni         20/02/2023         Initial Creation 
*******************************************************************************************/
public class BSRPSLController {
    @AuraEnabled
    public static String getRecordInfo(String objectName,String id){
        try{
            String query = 'SELECT Loan_Application__c FROM '+objectName+' WHERE Id=:id';
            sObject obj = Database.query(query);
            String recordId = (Id)obj.get('Loan_Application__c');
            return recordId;
        }
        catch(Exception e){
            System.debug('error--- '+e.getMessage()+' '+e.getStackTraceString());
        }
        return '';
    }
    
    //Get Sector, Inudstry, Sub-Industry, Occupation from Applicant_Financials_Details__c
	@AuraEnabled
    public static List<Applicant_Financials_Details__c> getSectorInfo(String applicantId){
        List<Applicant_Financials_Details__c> records = [SELECT Id,Sector__c,Industry__c,Sub_Industry__c,Occupation__c,Type_Of_Employment__c,RecordType.Name, RecordType.DeveloperName
                                                             FROM Applicant_Financials_Details__c 
                                                             WHERE  Applicant__c =:applicantId AND  isActive__c=true and recordtype.Name = 'Financial Parent' WITH SECURITY_ENFORCED];
        return records;
    }
    
    @AuraEnabled
    public static  List<sObject>  getRelatedProfilingMaster(String selectedValue,String passingType,String returnType, String pslClassType, String recordTypeName,String queryParams){
        system.debug('%%% '+queryParams);
        List<String> lstQueryParams = new List<String>();
        lstQueryParams = String.isBlank(queryParams) ? new List<String>() : queryParams.split('~');
        List<sObject> pmList = new List<sObject>();
        String strEmpType = '';
        String strSector = '';
        String strIndustry = '';
        String strSubIndustry = '';
        for (Integer i = 0;i<lstQueryParams.size();i++) {
            //strname = i == 1 ? lstQueryParams[0] : strname;
            strEmpType = i == 0 ? lstQueryParams[0] : strEmpType;
            strSector = i == 1 ? lstQueryParams[1] : strSector;
            strIndustry = i == 2 ? lstQueryParams[2] : strIndustry;
            strSubIndustry = i == 3 ? lstQueryParams[3] : strSubIndustry;
        }
        try {
            String query,query1,query2,query3,query4;
            String strRecordTypeName = 'RT - Employment Type';
            String recType='RT - BSR';
            if(passingType =='RT - Sector' && lstQueryParams.size() == 1){
                query2 = 'SELECT  Industry__r.Name industryName  from Profiling_Master__c  WHERE RecordType.Name=:strRecordTypeName AND Sector__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + 'GROUP BY Industry__r.Name ';
                if(String.isNotBlank(query2)){
                    List<AggregateResult> agrs = Database.query(query2);
                    Set<String> industryNames= new Set<String>();
                    for(AggregateResult ag : agrs)
                        industryNames.add((String) ag.get('industryName'));
                    query = 'SELECT Name,Code__c,Sector__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE Name =:industryNames AND RecordType.Name=:returnType WITH SECURITY_ENFORCED';
                    //pmList = Database.query(query);
                }
                //query = 'SELECT Name,Code__c,Sector__c,RecordType.Name FROM Profiling_Master__c WHERE RecordType.Name=:returnType AND Sector__r.Name=:selectedValue WITH SECURITY_ENFORCED';
            }
            if(passingType =='RT - Industry' && lstQueryParams.size() == 2){
                query3 = 'SELECT  Sub_Industry__r.Name subindustryName  from Profiling_Master__c  WHERE RecordType.Name=:strRecordTypeName AND Industry__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + (String.isNotBlank(strSector) ? ' AND Sector__r.Name =: strSector ' : '') + 'GROUP BY Sub_Industry__r.Name ';
                if(String.isNotBlank(query3)){
                    List<AggregateResult> agrs = Database.query(query3);
                    Set<String> subindustryNames= new Set<String>();
                    for(AggregateResult ag : agrs)
                        subindustryNames.add((String) ag.get('subindustryName'));
                    query = 'SELECT Name,Code__c,Sector__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE Name =:subindustryNames AND RecordType.Name=:returnType WITH SECURITY_ENFORCED';
                    //pmList = Database.query(query);
                }
                //query = 'SELECT Name,Code__c,Industry__c,RecordType.Name FROM Profiling_Master__c WHERE RecordType.Name=:returnType AND Industry__r.Name=:selectedValue WITH SECURITY_ENFORCED';
            }
            if(passingType =='RT - Sub Industry' && lstQueryParams.size() == 3){
                query4 = 'SELECT  Occupation__r.Name occupationName  from Profiling_Master__c  WHERE RecordType.Name=:strRecordTypeName AND Sub_Industry__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + (String.isNotBlank(strSector) ? ' AND Sector__r.Name =: strSector ' : '') + (String.isNotBlank(strIndustry) ? ' AND Industry__r.Name =: strIndustry ' : '') + 'GROUP BY Occupation__r.Name ';
                if(String.isNotBlank(query4)){
                    List<AggregateResult> agrs = Database.query(query4);
                    Set<String> occupationNames= new Set<String>();
                    for(AggregateResult ag : agrs)
                        occupationNames.add((String) ag.get('occupationName'));
                    query = 'SELECT Name,Code__c,Sector__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE Name =:occupationNames AND RecordType.Name=:returnType WITH SECURITY_ENFORCED';
                    //pmList = Database.query(query);
                }
                //query = 'SELECT Name,Code__c,Sub_Industry__c,RecordType.Name FROM Profiling_Master__c WHERE RecordType.Name=:returnType AND Sub_Industry__r.Name=:selectedValue WITH SECURITY_ENFORCED';
            }
            if(passingType =='RT - Occupation'){
                query = 'SELECT Name,Code__c,Occupation__c,PSL_Code__c,PSL_Description__c FROM Profiling_Master__c WHERE RecordType.Name=:strRecordTypeName AND Occupation__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + (String.isNotBlank(strSector) ? ' AND Sector__r.Name =: strSector ' : '') + (String.isNotBlank(strIndustry) ? ' AND Industry__r.Name =: strIndustry ' : '') + (String.isNotBlank(strSubIndustry) ? ' AND Sub_Industry__r.Name =: strSubIndustry' : '') + ' WITH SECURITY_ENFORCED';
                //query = 'SELECT Name,Code__c,Occupation__c,PSL_Code__c,PSL_Description__c FROM Profiling_Master__c WHERE PSL_Code__c!=null AND Occupation__r.Name=:selectedValue WITH SECURITY_ENFORCED';
            }
			if(passingType =='PSL_Code__c'){
                query = 'SELECT Name,Code__c,PSL_Code__c,PSL_Description__c,PSL_Classification_Type__c ,PSL_Classification_Category__c FROM Profiling_Master__c WHERE PSL_Code__c=:selectedValue WITH SECURITY_ENFORCED';
            }
            //SFAU-5374: Modified by Samridhi to fetch PSL segment on the basis of PSL Classification Category
            if(passingType =='PSL_Classification_Category__c'){
                query = 'SELECT PSL_Classification_Type__c,PSL_Classification_Category__c,PSL_Segment__c FROM PSL_Classification_Type_to_Category__mdt WHERE PSL_Classification_Category__c=:selectedValue';
            }
            if(passingType =='PSL_Classification_Type__c' && returnType=='Group__c'){
                if(recordTypeName=='Two Wheeler'){
                    query = 'SELECT Name,PSL_Classification_Type__c,Group__c FROM Profiling_Master__c WHERE RecordType.Name=:recType WITH SECURITY_ENFORCED';
                }
                else{
                    query = 'SELECT Name,PSL_Classification_Type__c,Group__c FROM Profiling_Master__c WHERE PSL_Classification_Type__c=:selectedValue AND RecordType.Name=:recType WITH SECURITY_ENFORCED';
                }
            }
            if(passingType=='PSL_Classification_Type__c' && returnType=='PSL_Classification_Category__c'){
                query = 'SELECT PSL_Classification_Type__c,PSL_Classification_Category__c FROM PSL_Classification_Type_to_Category__mdt WHERE PSL_Classification_Type__c=:selectedValue';
            }
            if(passingType =='Group__c'){
                if(recordTypeName=='Two Wheeler'){
                    query = 'SELECT Name,Code__c,PSL_Classification_Type__c ,Sub_Group__c FROM Profiling_Master__c WHERE Group__c=:selectedValue AND RecordType.Name=:recType WITH SECURITY_ENFORCED';
                }
                else{
                    query = 'SELECT Name,Code__c,PSL_Classification_Type__c ,Sub_Group__c FROM Profiling_Master__c WHERE Group__c=:selectedValue AND RecordType.Name=:recType AND PSL_Classification_Type__c=:pslClassType WITH SECURITY_ENFORCED';
                } 
            }
            if(passingType =='Sub_Group__c'){
                query = 'SELECT Name,Code__c,PSL_Classification_Type__c ,Occupation_Group__c  FROM Profiling_Master__c WHERE Sub_Group__c=:selectedValue AND RecordType.Name=:recType WITH SECURITY_ENFORCED';
            }
            
            System.debug('query:'+query);
            if(String.isNotBlank(query)){
                pmList = Database.query(query);
            }
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return pmList;
    }
    
    @AuraEnabled
    public static List<Profiling_Master__c> getProfilingMaster(Id applicantId, String employmentType){
        List<Applicant__c> applicantList = getApplicants(applicantId); // will pass the selected applicant id 
        String entityType;
        if(applicantList[0].Loan__r.Customer_Type__c!=null){
            entityType =applicantList[0].Loan__r.Customer_Type__c;
        }
        System.debug('entityType-->' +entityType);
        List<Profiling_Master__c> pmList = new List<Profiling_Master__c>();
        try {
            String query,query1;
            String passingType = 'RT - Employment Type';
            query1 = 'SELECT  Sector__r.Name sectorName  from Profiling_Master__c  WHERE RecordType.Name=:passingType AND Name=:employmentType GROUP BY Sector__r.Name ';
            if(String.isNotBlank(query1)){
                List<AggregateResult> agrs = Database.query(query1);
                Set<String> sectorNames= new Set<String>();
                for(AggregateResult ag : agrs)
                    sectorNames.add((String) ag.get('sectorName'));
                query = 'SELECT id,Name,Entity_Type__c,Code__c,Employment_Type__c,Industry__c,Occupation__c,Sector__c,Sub_Industry__c,RecordTypeId FROM Profiling_Master__c WHERE Name =:sectorNames AND Entity_Type__c =:entityType WITH SECURITY_ENFORCED';
                pmList = Database.query(query);
            }
            
            /*pmList =[SELECT id,Name,Entity_Type__c,Code__c,Employment_Type__c,Industry__c,Occupation__c,Sector__c,Sub_Industry__c,RecordTypeId 
                     FROM Profiling_Master__c
                     WHERE Entity_Type__c =:entityType AND Name =: employmentType  WITH SECURITY_ENFORCED];
            */

            System.debug('pmList-->' +pmList);
            
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return pmList;
    }
    
    @AuraEnabled
    public static  List<Applicant__c> getApplicants(String applicantId){
        List<Applicant__c> applicantList = new List<Applicant__c>();
        try {
            applicantList = [SELECT Id,Type_Of_Employment__c,Existing_Customer__c,UDYAM_Registration_Number__c,Gender__c,Caste__c,Religion__c,First_Name__c,Middle_Name__c,Last_Name__c,Name,Loan__c, Loan__r.Purpose_of_Loan__c,
                             Loan__r.Customer_Type__c,Loan__r.EMI__c,Total_Monthly_Income_Sum__c,Total_Loan_Amount__c,Loan__r.Stage__c,RecordType.DeveloperName,RecordType.Name, Phsically_challenged__c, Loan__r.RecordType.Name,(SELECT State__c,Address_Type__c FROM Addresses__r WHERE Address_Type__c='Current')
                             FROM Applicant__c
                             WHERE (Loan__c=:applicantId OR Id=:applicantId)
                             AND RecordType.DeveloperName ='Primary_Applicant' AND IsInactive__c = false WITH SECURITY_ENFORCED];
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return applicantList;
    }
    
    @AuraEnabled
    public static Map<String,Object> getRecords(String loanId){
        Map<String,Object> response = new Map<String,Object>();
        List<BSR_PSL_Details__c> objList = [SELECT Id,PSL_Code__c,PSL_Classification_Type__c,PSL_Classification_Category__c,PSL_Segment__c,Weaker_Section__c,Reasons_for_Multiple_Weaker_Section__c,
                                           Agri_Land_Available__c,Document_Type__c,Activity__c,Land_Ownership__c,If_Applicant_Relative__c,Land_Holding_in_acre__c,Land_Area_in_Hector__c,
                                           Small_Marginal_Other__c,End_use_of_Vehicle__c,Group__c,Sub_Group__c,Occupation_Group__c,Organisation__c,Organisation_Type__c,Industry__c,Borrower_Category__c,
                                           Investment_in_P_M__c,Investment_in_Equipment__c,Others__c,RecordType.Name,Udyam_Status__c FROM BSR_PSL_Details__c WHERE Loan_Application__c=:loanId];

        List<Loan_Application__c> loanAppList = [SELECT Id,RecordType.Name, Product__c, Loan_Amount__c, Collateral_Type__c FROM Loan_Application__c Where Id =: loanId];
        Boolean isCowProduct = Label.Cow_Product_Codes.contains(loanAppList[0].Product__c);
        response.put('bsrPslDetails',objList);
        response.put('vehileUseOptions',LosLeadCreateWizardController.getVehicleUsageOptions( loanAppList[0].Product__c, loanAppList[0].Collateral_Type__c ));   
        response.put('isCowProduct',isCowProduct); 
        response.put('endUseOfFundOptions',getEndUseFundOptions(loanAppList[0].Product__c)); // SFAU-5584                       
        response.put('isPersonalCOW',loanAppList[0].Product__c == '10213' || loanAppList[0].Product__c == '10310' || loanAppList[0].Product__c == '10507' ||
        loanAppList[0].Product__c == '10110' || loanAppList[0].Product__c == '10113' || loanAppList[0].Product__c == '10407' || loanAppList[0].Product__c == '10216'); // SFAU-5584  
        if(isCowProduct){
            response.put('endUseofFundRecords', getEndUseOfFundsRecords(loanAppList[0].Id));      
        }
        return response;
    }

    public static List<End_Use_Of_Funds__c> getEndUseOfFundsRecords(String loanId){
        return [SELECT Id,Label__c,Amount__c,Loan_Application__c,Expected_Validation__c FROM End_Use_Of_Funds__c Where Loan_Application__c =: loanId];
    }

    // SFAU-5584 Get End use of Fund Options based on Product.
    private static List<SelectOptionWrapper> getEndUseFundOptions(String productVal){
        String developerName = 'A_' + productVal;
        ProductRTMap__mdt productRT = [SELECT Id,End_Use_Of_Funds__c FROM ProductRTMap__mdt Where DeveloperName =: developerName];
        List<SelectOptionWrapper> wrapper = new List<SelectOptionWrapper>();
        if(String.isNotBlank(productRT.End_Use_Of_Funds__c)){
            List<String> funds = productRT.End_Use_Of_Funds__c.split(';');
            for(String value : funds){
                wrapper.add(new SelectOptionWrapper(value,value));
            }
        }
        return wrapper;
    }

    private static List<SelectOptionWrapper> getVehicleUseOptions(String recordTypeName){
        if(recordTypeName == 'Two Wheeler'){
            return new List<SelectOptionWrapper>{ (new SelectOptionWrapper('Personal','Personal')),(new SelectOptionWrapper('Commercial','Commercial'))};
        }else{
            return new List<SelectOptionWrapper>{ (new SelectOptionWrapper('Personal','Personal')),(new SelectOptionWrapper('Business','Business')),(new SelectOptionWrapper('Agri','Agri'))};
        }
    }
    
    @AuraEnabled
    public static String saveRecords(Map<String,String> bsrPslData, Map<String,String> applicantData, Map<String,String> financialAppData, Map<String,String> loanAppData,String assignmentId){
        String result='Success';
        System.debug('data '+bsrPslData);
        System.debug('data '+applicantData);
        System.debug(financialAppData);
        System.debug(loanAppData);
        try{
            List<BSR_PSL_Details__c> objList = [SELECT Id,RecordType.Name,RecordTypeId FROM BSR_PSL_Details__c WHERE Loan_Application__c=:loanAppData.get('Id')];
            BSR_PSL_Details__c objPSL = new BSR_PSL_Details__c();
            BSR_PSL_Details__c objBSR = new BSR_PSL_Details__c();
            for(String data: bsrPslData.keySet()){
                if(data=='PSL_Code__c' || data=='PSL_Classification_Type__c' || data=='PSL_Classification_Category__c' || data=='PSL_Segment__c'
                  || data=='Weaker_Section__c' || data=='Reasons_for_Multiple_Weaker_Section__c' || data=='Agri_Land_Available__c' || data=='Document_Type__c'
                  || data=='Activity__c' || data=='Land_Ownership__c' || data=='If_Applicant_Relative__c' || data=='Land_Holding_in_acre__c'
                  || data=='Land_Area_in_Hector__c' || data=='Small_Marginal_Other__c' || data=='End_use_of_Vehicle__c' || data=='Udyam_Status__c'){
                    if(data=='Land_Holding_in_acre__c' ){
                        objPSL.put(data,Decimal.valueOf(bsrPslData.get(data)));
                    }
                    else{
                        objPSL.put(data,bsrPslData.get(data));
                    }
                }
                if(data=='Group__c' || data=='Sub_Group__c' || data=='Occupation_Group__c' || data=='Organisation__c'
                  || data=='Organisation_Type__c' || data=='Industry__c' || data=='Borrower_Category__c' || data=='Investment_in_P_M__c'
                  || data=='Investment_in_Equipment__c' || data=='Others__c'){
                      if(data=='Investment_in_P_M__c' || data=='Investment_in_Equipment__c'){
                          objBSR.put(data,Decimal.valueOf(bsrPslData.get(data)));
                      }
                      else{
                      	objBSR.put(data,bsrPslData.get(data));
                      }
                }
            }
            if(objList.size()>0){
                if(objList[0].RecordType.Name=='BSR'){
                    objBSR.Id=objList[0].Id;
                    objBSR.RecordTypeId=objList[0].RecordTypeId;
                    objPSL.Id=objList[1].Id;
                    objPSL.RecordTypeId=objList[1].RecordTypeId;
                }
                else{
                    objBSR.Id=objList[1].Id;
                    objBSR.RecordTypeId=objList[1].RecordTypeId;
                    objPSL.Id=objList[0].Id;
                    objPSL.RecordTypeId=objList[0].RecordTypeId;
                }
            }
            else{
                objBSR.Loan_Application__c=loanAppData.get('Id');
                objBSR.RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByName().get('BSR').getRecordTypeId();
                objPSL.Loan_Application__c=loanAppData.get('Id');
                objPSL.RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByName().get('PSL').getRecordTypeId();
            }
            List<BSR_PSL_Details__c> objListNew = new List<BSR_PSL_Details__c>();
            objListNew.add(objBSR);
            objListNew.add(objPSL);
            if(objList.size()>0){
                update objListNew;
            }
            else{
                insert objListNew;
                // SFAU-5208 - Share records with Credit users
                Utility.shareBSRPSLRecords( objListNew, loanAppData.get('Id') );
            }
            System.debug('updated list '+objListNew);
            Applicant__c appObj = new Applicant__c();
            for(String data: applicantData.keySet()){
                appObj.put(data,applicantData.get(data));
            }
            upsert appObj;
            System.debug('updated obj '+appObj);
            Applicant_Financials_Details__c financeObj = new Applicant_Financials_Details__c();
            for(String data: financialAppData.keySet()){
                financeObj.put(data,financialAppData.get(data));
            }
            upsert financeObj;

            System.debug('updated obj '+financeObj);
            Loan_Application__c loanObj = new Loan_Application__c();
            for(String data: loanAppData.keySet()){
                loanObj.put(data,loanAppData.get(data));
            }
            loanObj.BSR_PSL_Status__c = 'Completed';
            loanObj.Original_Vehicle_Usage__c =  objPSL.End_use_of_Vehicle__c;
            update loanObj;

            List<Collateral__c> listOfColl = [SELECT Id FROM Collateral__c WHERE Loan__c=:loanObj.Id AND Is_Deleted__c != true AND recordTypeId IN: GlobalConstants.colRecordTypeIds];
            if(!listOfColl.isEmpty()){
                update new Collateral__c(Id = listOfColl[0].Id, Original_Vehicle_Usage__c = objPSL.End_use_of_Vehicle__c );
            }

            if(String.isNotBlank(assignmentId)){
                Assignment__c obj = new Assignment__c(Id=assignmentId);
                obj.Status__c = 'Complete';
                update obj;
            }
            System.debug('updated obj '+loanObj);
        }
        catch(Exception e){
            System.debug(e.getStackTraceString());
            return e.getMessage();
        }
        return result;
    }

    @AuraEnabled
    public static Map<String,Object> deleteFunds(List<Id> recordIds, Id loanId){
        List<End_Use_Of_Funds__c> records = [select Id from End_Use_Of_Funds__c where id in :recordIds WITH SECURITY_ENFORCED];
        delete records;
        
        Map<String,Object> response = new Map<String,Object>();
        response.put('endUseofFundRecords',getEndUseOfFundsRecords(loanId));
        return response;
    }

    @AuraEnabled
    public static Map<String,Object> upsertData(List<End_Use_Of_Funds__c> records, Id loanId){
        Map<String,Object> response = new Map<String,Object>();
        try{
            for(End_Use_Of_Funds__c fund : records){
                fund.Loan_Application__c = String.isBlank(fund.Loan_Application__c) ? loanId : fund.Loan_Application__c;
            }
            upsert records;
            response.put('endUseofFundRecords',getEndUseOfFundsRecords(loanId));
            return response;
        }catch(Exception e){
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class SelectOptionWrapper {
        @AuraEnabled public string value;
        @AuraEnabled public string label;
        
        public SelectOptionWrapper(string value, string label) {
            this.value = value;
            this.label = label;
        }
    }
    
    
}