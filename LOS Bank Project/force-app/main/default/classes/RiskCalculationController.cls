/*****
 * Class Name: RiskCalculationController
 * Description: Calculate Risk Score
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * May-31-2023          -   Mohit Maheshwari
 * Oct-20-2023          -   Mohit M.            -   SFAU-5133 Calculate Risk Score for Individual and Non-Individual
 * Nov-01-2023          -   Mohit M.            -   SFAU-5536 NI Risk Score Consider BO - 2W/4W - Consider BO as well for Non-Individual
 * Nov-06-2023          -   Mohit M.            -   SFAU-5362 - Internal Risk Score for TW
*/
public with sharing class RiskCalculationController {
    //Risk Score Calculation
    @AuraEnabled
    public static void riskScoreCalculation(String loanAppId) {
        // SFAU-5133
        Map<String,Applicant__c> mapApplicant = new Map<String,Applicant__c>();
        Boolean blnNonIndvidualApplicant = false;
        Boolean blAppSolePop = false;
        Map<Id,Applicant__c> mapAppWithExistScore = new Map<Id,Applicant__c>();
        // SFAU-5536 - Remove BO filter
        List < Applicant__c > applicantList = [SELECT Id,Loan__r.Customer_Grade__c,Loan__r.Application_FI_Status__c, IsInactive__c,Customer_Name__c, Loan__r.Product__c, Age__c, Bureau_Score__c, Customer_Grade__c, Type_Of_Employment__c, Applicant_FI_Status__c, Loan__c, Loan_Stage__c, (SELECT id, Name, Address_Type__c, Applicant__c, Applicant__r.Loan__c, Product__c, Stability__c, Status__c FROM Addresses__r WHERE Address_Type__c = 'Current'
                                                                                                                                                                                                                                  AND Source_Type__c != 'Cibil' AND Source_Type__c != 'Cart'),
                                               Relationship_with_applicant__c, KYC_Status__c, CIF_No__c, Applicant_Type_Priority__c, Name, Customer_Type__c, Constitution_Type__c, CreatedDate, Internal_Risk_Score__c      // SFAU-5133
                                               FROM Applicant__c
                                               WHERE Loan__c =: loanAppId
                                               AND RecordType.DeveloperName != 'Additional_Match'
                                               AND RecordType.DeveloperName != 'Nominee'
                                               AND IsInactive__c = false
                                               WITH SECURITY_ENFORCED ORDER BY Applicant_Type_Priority__c, Name
                                              ];
        /* START - SFAU-5133 */
        for (Applicant__c objApp : applicantList) {
            if (objApp.Applicant_Type_Priority__c == 1 && objApp.Customer_Type__c == 'Non Individual' && objApp.Constitution_Type__c == 'Sole Proprietary') {
                mapApplicant.put ('Applicant',objApp);
                blnNonIndvidualApplicant = true;
                blAppSolePop = true;
            }
            else if (objApp.Applicant_Type_Priority__c == 1 && objApp.Customer_Type__c == 'Non Individual' && objApp.Constitution_Type__c != 'Sole Proprietary') {
                mapApplicant.put ('Applicant',objApp);
                blnNonIndvidualApplicant = true;
            }
            else if (objApp.Applicant_Type_Priority__c == 1 && objApp.Customer_Type__c != 'Non Individual') {
                mapApplicant.put ('Applicant',objApp);
                blnNonIndvidualApplicant = false;
            }
            else if (objApp.Applicant_Type_Priority__c == 2 && (!mapApplicant.containsKey('Co-Applicant') || (mapApplicant.containsKey('Co-Applicant') && objApp.Name < mapApplicant.get('Co-Applicant').Name))) {
                mapApplicant.put ('Co-Applicant',objApp);
            }
            else if (objApp.Applicant_Type_Priority__c == 3 && (!mapApplicant.containsKey('Guarantor') || (mapApplicant.containsKey('Guarantor') && objApp.Name < mapApplicant.get('Guarantor').Name))) {
                mapApplicant.put ('Guarantor',objApp);
            }
            // SFAU-5536 - Add BO condition
            else if (objApp.Applicant_Type_Priority__c == 4 && (!mapApplicant.containsKey('BO') || (mapApplicant.containsKey('BO') && objApp.Name < mapApplicant.get('BO').Name))) {
                mapApplicant.put ('BO',objApp);
            }
            mapAppWithExistScore.put(objApp.Id,objApp);
        }
        /* END - SFAU-5133 */
        if( applicantList!=null && applicantList.size()>0 ){
            String product = applicantList[0].Loan__r.Product__c;
            
            String typeOfProduct = getTypeOfWheeler(product);
            
            List <Collateral__c> collateralList = [SELECT id,LTV_offered_On_final_cost__c, Loan__c
                                                   FROM Collateral__c
                                                   WHERE Loan__c = :loanAppId  ORDER BY CreatedDate desc ];
            Decimal ltvPercentage =  collateralList.size()>0? collateralList[0].LTV_offered_On_final_cost__c!=null ?  collateralList[0].LTV_offered_On_final_cost__c : null:null;                                             
            if(ltvPercentage != null ){
                ltvPercentage = Math.round(ltvPercentage); //2 AUG
            }
            Map < String, Customer_Risk_Score_Mapping__mdt > customerRiskMetadata = Customer_Risk_Score_Mapping__mdt.getAll();
            List < Customer_Risk_Score_Mapping__mdt > customerRiskMetadataList = customerRiskMetadata.values();
            Map < Id, List < Decimal >> applicantVsScoreMap = new Map < Id, List < Decimal >> ();
            Map < Id,String > applicantFiMap = new Map < Id, String> ();
            List < Applicant__c > applicantUpdateList = new List < Applicant__c > ();
            Map < Id,Decimal > mapAppWithScoreRemove = new Map < Id, Decimal> ();
            for (Applicant__c objApp: applicantList) {
                /* START - SFAU-5133 */
                Applicant__c applInstance;
                if (blnNonIndvidualApplicant && objApp.Applicant_Type_Priority__c == 1) {
                    applInstance = mapApplicant.containsKey('Co-Applicant') ? mapApplicant.get('Co-Applicant') : mapApplicant.containsKey('Guarantor') ? mapApplicant.get('Guarantor') : mapApplicant.containsKey('BO') ? mapApplicant.get('BO') : objApp;
                }
                else {
                    applInstance = objApp;
                }
                /* END - SFAU-5133 */
                applicantFiMap.put(objApp.id,objApp.Loan__r.Application_FI_Status__c);
                List<Address__c> currentAddressList = applInstance.Addresses__r != null ? applInstance.Addresses__r.size() > 0 ? applInstance.Addresses__r :null :null;
                Address__c currentAddressInstance = currentAddressList!=null ? currentAddressList.size()>0 ? currentAddressList[0] :null :null;
                Applicant__c appNewInstance = new Applicant__c();
                List < Decimal > scoreList = new List < Decimal > ();
                Boolean blnFoundResidenceConflict = false;
                for (Customer_Risk_Score_Mapping__mdt metaInstance: customerRiskMetadataList) {
                    /* START - SFAU-5133 */
                    Set<String> setCustomerType = new Set<String>();
                    List<String> lstCustomerType = String.isNotBlank(metaInstance.Consider_Customer_Type__c) ? metaInstance.Consider_Customer_Type__c.split(';') : new List<String>();
                    setCustomerType.addAll(lstCustomerType);

                    Set<String> setConstitution = new Set<String>();
                    List<String> lstConstitution = String.isNotBlank(metaInstance.Consider_Constitution_Type__c) ? metaInstance.Consider_Constitution_Type__c.split(';') : new List<String>();
                    setConstitution.addAll(lstConstitution);

                    if (!setCustomerType.contains(objApp.Customer_Type__c.toUpperCase())){
                        applicantVsScoreMap.put(objApp.Id,scoreList );
                        continue;
                    }
                    if (objApp.Customer_Type__c == 'Non Individual' && (String.isBlank(objApp.Constitution_Type__c) || !setConstitution.contains(objApp.Constitution_Type__c.toUpperCase()))){
                        applicantVsScoreMap.put(objApp.Id,scoreList );
                        continue;
                    }
                    /* END - SFAU-5133 */
                    Decimal scoreInstance =0;
                    // Four Wheeler
                    if (metaInstance.Product_Type__c == typeOfProduct &&  (typeOfProduct =='Four Wheeler' || typeOfProduct=='Commercial/Tractor') ) {
                        if (metaInstance.Criteria__c == 'Age') {
                            if(applInstance.Age__c!=null){
                                if (applInstance.Age__c >= metaInstance.Min_Range__c && applInstance.Age__c < metaInstance.Max_Range__c) {
                                    scoreList.add(metaInstance.Score__c);
                                }
                            }
                        }
                        if (metaInstance.Criteria__c == 'Grade') {
                            if(String.isNotBlank(applInstance.Loan__r.Customer_Grade__c)){
                                if (applInstance.Loan__r.Customer_Grade__c == metaInstance.Range_Txt__c) {
                                    scoreList.add(metaInstance.Score__c);
                                }
                            }
                        }
                        if (metaInstance.Criteria__c == 'Income Source') {
                            if(String.isNotBlank(applInstance.Type_Of_Employment__c)){
                                if (applInstance.Type_Of_Employment__c == metaInstance.Range_Txt__c) {
                                    scoreList.add(metaInstance.Score__c);
                                }
                            }
                        }
                        if (metaInstance.Criteria__c == 'CIBIL Score') {
                            if(applInstance.Bureau_Score__c!=null && applInstance.Bureau_Score__c!='0-1'){
                                if (Decimal.valueof(applInstance.Bureau_Score__c) >= metaInstance.Min_Range__c && Decimal.valueof(applInstance.Bureau_Score__c) < metaInstance.Max_Range__c) {
                                    scoreList.add(metaInstance.Score__c);
                                }
                            }
                            
                        }
                        if (metaInstance.Criteria__c == 'FI Status') {
                            if(String.isNotBlank(applInstance.Loan__r.Application_FI_Status__c)){
                                if (applInstance.Loan__r.Application_FI_Status__c == metaInstance.Range_Txt__c) {
                                    scoreList.add(metaInstance.Score__c);
                                }
                            }
                        }
                        if (metaInstance.Criteria__c == 'Residence') {
                            if( currentAddressInstance!=null && currentAddressInstance.Status__c!=null){
                                if (currentAddressInstance.Status__c == metaInstance.Range_Txt__c) {
                                    scoreList.add(metaInstance.Score__c);
                                }
                            }
                            
                        }
                        if(metaInstance.Criteria__c == 'Stability'){
                            if(currentAddressInstance!=null && currentAddressInstance.Stability__c!=null && String.isNotBlank(currentAddressInstance.Stability__c) ){
                                if(Decimal.valueof(currentAddressInstance.Stability__c) >= metaInstance.Min_Range__c && Decimal.valueof(currentAddressInstance.Stability__c)<metaInstance.Max_Range__c){
                                    scoreList.add(metaInstance.Score__c);
                                }
                            } 
                        }
                    }
                    
                    // TWO Wheeler
                    if (metaInstance.Product_Type__c == typeOfProduct &&  typeOfProduct =='Two Wheeler' ) {
                        if (metaInstance.Criteria__c == 'Age') {
                            if(applInstance.Age__c!=null){
                                if (applInstance.Age__c >= metaInstance.Min_Range__c && applInstance.Age__c < metaInstance.Max_Range__c) {
                                    decimal calculation = (metaInstance.Score__c * metaInstance.Weightage__c)/100; 
                                    scoreList.add(calculation);
                                }
                            }
                        }
                        if (metaInstance.Criteria__c == 'Income Source') {
                            if (applInstance.Type_Of_Employment__c == metaInstance.Range_Txt__c) {
                                decimal calculation = (metaInstance.Score__c * metaInstance.Weightage__c)/100; 
                                scoreList.add(calculation);
                            }
                        }
                        if (metaInstance.Criteria__c == 'CIBIL Score') {
                            if(applInstance.Bureau_Score__c!=null){
                                if (Decimal.valueof(applInstance.Bureau_Score__c) >= metaInstance.Min_Range__c && Decimal.valueof(applInstance.Bureau_Score__c) < metaInstance.Max_Range__c) {
                                    decimal calculation = (metaInstance.Score__c * metaInstance.Weightage__c)/100; 
                                    scoreList.add(calculation);
                                }
                            }
                        }
                        if (metaInstance.Criteria__c == 'Residence') {
                            if(currentAddressInstance!=null &&currentAddressInstance.Status__c!=null ){
                                if (currentAddressInstance.Status__c == metaInstance.Range_Txt__c) {
                                    decimal calculation = (metaInstance.Score__c * metaInstance.Weightage__c)/100; 
                                    scoreList.add(calculation);
                                    //SFAU-5362 - Mohit
                                    if (mapAppWithScoreRemove.containsKey(currentAddressInstance.Applicant__c)) {
                                        decimal calculationtoremove = (mapAppWithScoreRemove.get(currentAddressInstance.Applicant__c) * -1);
                                        scoreList.add(calculationtoremove);
                                    }
                                // SFAU-5362 - Mohit Add condition mapAppWithScoreRemove
                                }else if(!mapAppWithScoreRemove.containsKey(currentAddressInstance.Applicant__c) && currentAddressInstance.Status__c.contains(metaInstance.Range_Txt__c) && currentAddressInstance.Status__c != 'Rented Bachelor Accomodation'){  // Updated for SFAU-4694 (Risk Score is 1 for "Rented Bachelor Accomodation" and 2 for all other rented options.)
                                    decimal calculation = (metaInstance.Score__c * metaInstance.Weightage__c)/100; 
                                    scoreList.add(calculation);
                                    mapAppWithScoreRemove.put(currentAddressInstance.Applicant__c,calculation);
                                }
                            }
                        }
                        if (metaInstance.Criteria__c == 'LTV') {
                            if(ltvPercentage!=null){
                                if (ltvPercentage >= metaInstance.Min_Range__c && ltvPercentage <= metaInstance.Max_Range__c) {
                                    decimal calculation = (metaInstance.Score__c * metaInstance.Weightage__c)/100; 
                                    scoreList.add(calculation);
                                }
                            }
                        }
                    }
                    //applicantVsScoreMap.put(applInstance.Id,scoreList );
                    applicantVsScoreMap.put(objApp.Id,scoreList );
                }
                //applicantUpdateList.add(appNewInstance);
            }
            
            for(Id applicantInstance : applicantVsScoreMap.keyset()){
                decimal score=0;
                Integer intcount = 1;
                for(Decimal scoreInstance : applicantVsScoreMap.get(applicantInstance) ){
                    score = score +scoreInstance;
                    intcount++;
                }
                Applicant__c appNewInstance = new Applicant__c();
                appNewInstance.Id = applicantInstance;
                decimal finalScore=0;
                
                if(typeOfProduct == 'Four Wheeler' || typeOfProduct == 'Commercial/Tractor'){
                    Integer intDevideScore = mapAppWithExistScore.containsKey(applicantInstance) && mapAppWithExistScore.get(applicantInstance).Applicant_Type_Priority__c == 1 && blnNonIndvidualApplicant && !blAppSolePop ? 3 : 7;
                    if(String.isNotBlank(applicantFiMap.get(applicantInstance))){
                        finalScore =score/intDevideScore;
                    }else{
                        score = score +2;
                        finalScore =score/intDevideScore;
                    }
                } else if(typeOfProduct == 'Two Wheeler'){
                    finalScore =score;
                }
                if(typeOfProduct == 'Two Wheeler'){
                    if (finalScore < 3.5) {
                        appNewInstance.Risk_Category__c = 'High Risk';
                    }
                    else if ( (finalScore>=3.5) && (finalScore<4.25)) {
                        appNewInstance.Risk_Category__c = 'Moderate Risk';
                    }
                    if (finalScore >= 4.25) {
                        appNewInstance.Risk_Category__c = 'Low Risk';
                    }
                }
                System.debug('finalScore-->' +finalScore);
                appNewInstance.Internal_Risk_Score__c = finalScore.setScale(2); //JUL 20
                if (mapAppWithExistScore.containsKey(appNewInstance.Id) && mapAppWithExistScore.get(appNewInstance.Id).Internal_Risk_Score__c != appNewInstance.Internal_Risk_Score__c)
                    applicantUpdateList.add(appNewInstance);
            }
            if ( applicantUpdateList!=null && !applicantUpdateList.isEmpty() && applicantUpdateList.size() > 0) {
                update applicantUpdateList;
            }
        }
    }
    
    
    public static String getTypeOfWheeler(String productCode) {
        String typeOfWhelr = '';
        if (productCode != null) {
            ProductRTMap__mdt prdRTP = ProductRTMap__mdt.getInstance('A_' + productCode);
            if (prdRTP.RecordType__c == 'Four Wheeler') {
                typeOfWhelr = 'Four Wheeler';
            } else if (prdRTP.RecordType__c == 'Commercial Vehicle' || prdRTP.RecordType__c == 'Construction Equipment' ||  prdRTP.RecordType__c =='Tractor' ) { //R2
                typeOfWhelr = 'Commercial/Tractor';
            } else {
                if (prdRTP.RecordType__c == 'Two Wheeler') {
                    typeOfWhelr = 'Two Wheeler';
                }
            }
        }
        return typeOfWhelr;
    }
}