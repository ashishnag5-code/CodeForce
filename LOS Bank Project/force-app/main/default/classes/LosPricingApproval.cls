/*****
 * Class Name: LosPricingApproval
 * Description: 
 * Test Class Name: LosPricingApprovalTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-20-2023          -   Mohit M.            -   SFAU-5236 - Add Logic - Deviation Applicable and Min Charges for Higher Authority
 * Sep-25-2023          -   Mohit M.            -   SFAU-5236 - Add Logic - Deviation Applicable and Min Charges for Higher Authority
 * Nov-22-2023          -   Mohit M.            -   SFAU-5606 - If No_Pricing_Deviation__c THEN Change Stage accordingly
 * Dec-14-2023          -   Mohit M.            -   SFAU-5722 - pricing approvals not created in preapproved cases
 */
public without sharing class LosPricingApproval {
    
    public static Map<String,String> motorInsuranceRBMPricingApprovalAuthority {get;set;}
    public static Map<String,String> motorInsuranceNBMPricingApprovalAuthority {get;set;}
    public static List<Deviation__c> motorInsuranceDeviation {get;set;}
    public static List<String> loanRecordTypes {get;set;}//R2-1693,1691
    public static Map<String,String> getPricingApprovalAuthorities(Map<Id, Loan_Application__c> loanAppsParam){

        List<Loan_Application__c> loanApps = loanAppsParam.values();
        List<String> loanAppsParamIdList = new List<String>();
        List<ProductRTMap__mdt> productDetails = [SELECT Id, MasterLabel, Sub_Product__c FROM ProductRTMap__mdt WITH SECURITY_ENFORCED];
        Map<String, String> productDetailsMap = new Map<String, String>();
        String COWProducts = System.Label.COW_Product_Names;//R2-1693,1691
        for(ProductRTMap__mdt product: productDetails){
            productDetailsMap.put(product.MasterLabel, product.Sub_Product__c);
        }
        List<Pricing_Authority_ROI_Matrix__mdt> pricingAuthorityROIList = new List<Pricing_Authority_ROI_Matrix__mdt>();
        List<Pricing_Authority_ROI_Matrix__mdt> pricingAuthorityROIListComplete = [SELECT Id, Max_Deviation__c, Minimum_Cap_New__c, Minimum_Cap_Used_CoW__c, Proposed_Matrix__c, Product_Type__c, Collateral_Type__c FROM Pricing_Authority_ROI_Matrix__mdt WHERE Product_Type__c IN :loanRecordTypes WITH SECURITY_ENFORCED Order By Order__c];//R2-1693,1691
        List<Pricing_Authority_ROI_Matrix__mdt> pricingAuthorityROIListTW = new List<Pricing_Authority_ROI_Matrix__mdt>();
        List<Pricing_Authority_ROI_Matrix__mdt> pricingAuthorityROIListFW = new List<Pricing_Authority_ROI_Matrix__mdt>();
        Map<String,List<Pricing_Authority_ROI_Matrix__mdt>> pricingAuthorityROIListR2 = new Map<String, List<Pricing_Authority_ROI_Matrix__mdt>>();//R2-1693,1691

        for(Pricing_Authority_ROI_Matrix__mdt roiMatrix: pricingAuthorityROIListComplete){
            if(roiMatrix.Product_Type__c == 'Two Wheeler'){
                pricingAuthorityROIListTW.add(roiMatrix);
            }else if(roiMatrix.Product_Type__c == 'Four Wheeler'){
                pricingAuthorityROIListFW.add(roiMatrix);
            }else{
                for(String collateralType: roiMatrix.Collateral_Type__c.split(',')){
                    String key = roiMatrix.Product_Type__c+'_'+collateralType;
                    if(pricingAuthorityROIListR2.containsKey(key)){
                        pricingAuthorityROIListR2.get(key).add(roiMatrix);
                    }else{
                        pricingAuthorityROIListR2.put(key,new List<Pricing_Authority_ROI_Matrix__mdt>{roiMatrix});
                    }
                }
                //system.debug('pricingAuthorityROIListR2 '+pricingAuthorityROIListR2);
            }//else part - R2-1693,1691
        }

        List<Pricing_Authority_Charges_Matrix__mdt> pricingAuthorityChargeList = Pricing_Authority_Charges_Matrix__mdt.getAll().values();
        
        Map<Id,Id> mapOfLoanIdVsROIDeviationId = new Map<Id,Id>();
        for(Deviation__c deviationRecord : [Select Id,Level__c,Details__c,Loan_Application__c,Active__c,Deviation_Type__c From Deviation__c where Loan_Application__c =:loanAppsParam.keySet() 
                                            AND Deviation_Type__c = 'ROI - Min Level Breached']){
            mapOfLoanIdVsROIDeviationId.put(deviationRecord.Loan_Application__c,deviationRecord.Id);
        }
        //commented to create a common method Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMap = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
        

        List<Charge__c> charges = [SELECT Id, Loan_Application__c, SC_Code__c, Charges_Name__c, Rate_value_As_per_Policy__c, Actual_rate__c, Charge_Amount__c, Value_Type__c, Min_charges__c, Deviation_Applicable__c  FROM Charge__c WHERE Loan_Application__c in :loanAppsParam.keySet() AND (Rate_value_As_per_Policy__c!=0 OR Total_Amount__c!=0) WITH SECURITY_ENFORCED];
        Map<String, Charge__c> chargesMap = new Map<String, Charge__c>();
        Map<String, List<String>> loanVSChargesMap = new Map<String, List<String>>();

        //List<String> strAppAsc = (Approver_Deviation_Level_Mapping__mdt.getInstance('PricingApprovalLevel').Level_Mapping__c).split(',');
        List<String> strAppAsc = getSFpricingAuthorities();
        Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMapTW = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
        Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMapFW = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
        Map<String,Map<String,List<Pricing_Authority_Charges_Matrix__mdt>>> pricingAuthorityChargeMapR2 = new Map<String,Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>>();//R2-1693,1691
        ChargesMatrixListsWrapper chargeMatrixSplitWrapper = getSFPricingAuthorityChargeMap();
        pricingAuthorityChargeMapTW = chargeMatrixSplitWrapper.pricingAuthorityChargeMapTWWrap;
        pricingAuthorityChargeMapFW = chargeMatrixSplitWrapper.pricingAuthorityChargeMapFWWrap;
        pricingAuthorityChargeMapR2 = chargeMatrixSplitWrapper.pricingAuthorityChargeMapR2Wrap;//R2-1693,1691
        Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMap = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
        //pricingAuthorityChargeMap = getSFPricingAuthorityChargeMap();
        /*for(Pricing_Authority_Charges_Matrix__mdt pricingCharge: pricingAuthorityChargeList){
            
            if(pricingAuthorityChargeMap.keySet().contains(pricingCharge.Particulars__c)){
                pricingAuthorityChargeMap.get(pricingCharge.Particulars__c).add(pricingCharge);
            }else{
                List<Pricing_Authority_Charges_Matrix__mdt> tempList = new List<Pricing_Authority_Charges_Matrix__mdt>();
                tempList.add(pricingCharge);
                pricingAuthorityChargeMap.put(pricingCharge.Particulars__c,tempList);
            }
        }*/

        for(Charge__c charge: charges){
            String key = charge.Loan_Application__c+';'+charge.Charges_Name__c;
            chargesMap.put(key,charge);
            if(loanVSChargesMap.keySet().contains(charge.Loan_Application__c)){
                loanVSChargesMap.get(charge.Loan_Application__c).add(charge.Charges_Name__c);
            }else{
                List<String> tempList = new List<String>();
                tempList.add(charge.Charges_Name__c);
                loanVSChargesMap.put(charge.Loan_Application__c,tempList);
            }
            
        }
        // SFAU-4071
        map<String, Charge__c> chargesByCode = Utility.getChargesMappedByScCode( charges );

        List<String> listOfAuthorityBasedOnROI = new List<String>();
        List<String> listOfAuthorityBasedOnCharges = new List<String>();
        List<String> listOfAuthority = new List<String>();
        Map<String,String> mapOfLoanIdVSAuthority = new Map<String,String>();
        Map<String,String> mapOfLoanIdVSAuthorityMotorIns = new Map<String,String>();
        Map<String,String> mapOfLoanIdVSAuthorityReturn = new Map<String,String>();


        List<Loan_Application__c> loanApplicationsToBeUpdated = new List<Loan_Application__c>();
        List<Deviation__c> lstDeviationtoInsert = new List<Deviation__c>();
        
        if(loanApps!=null && loanApps.size()>0){
            listOfAuthorityBasedOnROI = new List<String>();
            listOfAuthorityBasedOnCharges = new List<String>();
            listOfAuthority = new List<String>();
            Integer count=0;
            for(Loan_Application__c loan: loanApps){
                loanAppsParamIdList.add(loan.Id);
                if(loan.ROI__c < loan.RBP__c){
                    Decimal roiRbpDifference = loan.RBP__c - loan.ROI__c;
                    if(loan.RecordType.DeveloperName == 'Two_Wheeler'){
                        pricingAuthorityROIList = pricingAuthorityROIListTW;
                    }else if(loan.RecordType.DeveloperName == 'Four_Wheeler'){
                        pricingAuthorityROIList = pricingAuthorityROIListFW;
                    }else{
                        String key = loan.RecordType.name+'_'+loan.Collateral_Type__c;
                        //System.debug('key for ROI '+key);
                        //system.debug('Pricing ROI Matrix '+pricingAuthorityROIListR2);
                        pricingAuthorityROIList = pricingAuthorityROIListR2.get(key);
                    }//else part - R2-1693,1691
                    
                    for(Pricing_Authority_ROI_Matrix__mdt pricingROI: pricingAuthorityROIList){
                        if(roiRbpDifference <= pricingROI.Max_Deviation__c){
                            if(productDetailsMap.get(loan.Product__c)=='New'){
                                if(loan.ROI__c >= pricingROI.Minimum_Cap_New__c){
                                    listOfAuthorityBasedOnROI.add(pricingROI.Proposed_Matrix__c);
                                    listOfAuthority.add(pricingROI.Proposed_Matrix__c);
                                    count++;
                                }
                            }
                            if(productDetailsMap.get(loan.Product__c)!=null && (productDetailsMap.get(loan.Product__c)=='Used' || COWProducts.toUpperCase().contains(productDetailsMap.get(loan.Product__c).toUpperCase()))){//COW products change R2-1693,1691
                                //productDetailsMap.get(loan.Product__c)=='Cash on Wheels'){
                                if(loan.ROI__c >= pricingROI.Minimum_Cap_Used_CoW__c){
                                    listOfAuthorityBasedOnROI.add(pricingROI.Proposed_Matrix__c);
                                    listOfAuthority.add(pricingROI.Proposed_Matrix__c);
                                    count++;
                                }
                            }
                        }
                        if(count==1 && !Test.isRunningTest()){
                            break;
                        }
                    }
                    if(listOfAuthorityBasedOnROI!=null && listOfAuthorityBasedOnROI.size()==0){
                        /*Integer position = pricingAuthorityROIList.size()-1;
                        listOfAuthorityBasedOnROI.add(pricingAuthorityROIList[position].Proposed_Matrix__c);
                        listOfAuthority.add(pricingAuthorityROIList[position].Proposed_Matrix__c);*/
                        Integer position = strAppAsc.size()-1;
                        listOfAuthorityBasedOnROI.add(strAppAsc[position]);
                        listOfAuthority.add(strAppAsc[position]);
                    }
                    listOfAuthority = sortLists(listOfAuthority);
                    //listOfAuthority.sort();
                    Integer position = listOfAuthority.size()-1;
                    mapOfLoanIdVSAuthority.put(loan.Id,listOfAuthority[position]);

                    Deviation__c newDeviation = new Deviation__c();
                    newDeviation = Utility.getDeviation(mapOfLoanIdVsROIDeviationId.get(loan.Id),'ROI - Min Level Breached','Amount less than minimum',mapOfLoanIdVSAuthority.get(loan.Id),loan.Id,'',true);
                    newDeviation.Policy_Value__c = loan.RBP__c;
                    newDeviation.Actual_Value__c = loan.ROI__c;
                    newDeviation.Variance__c = loan.RBP__c - loan.ROI__c;
                    newDeviation.Department__c = 'Pricing';
                    newDeviation.Source__c = 'SF';
                    lstDeviationtoInsert.add(newDeviation);
                }
                if(loan.ROI__c >= loan.RBP__c || (mapOfLoanIdVSAuthority.values()!=null && mapOfLoanIdVSAuthority.values().size()>0 && mapOfLoanIdVSAuthority.values()[0] != strAppAsc[strAppAsc.size()-1])){
                    if(loanVSChargesMap.keySet().contains(loan.Id)){
                        if(loan.RecordType.DeveloperName == 'Two_Wheeler'){
                            pricingAuthorityChargeMap=pricingAuthorityChargeMapTW;
                        }else if(loan.RecordType.DeveloperName == 'Four_Wheeler'){
                            pricingAuthorityChargeMap=pricingAuthorityChargeMapFW;
                        }else{
                            String key = loan.RecordType.Name+'_'+loan.Collateral_Type__c;
                            pricingAuthorityChargeMap=pricingAuthorityChargeMapR2.get(key);
                        }//else part - R2-1693,1691
                        listOfAuthority.addAll(getAuthorityBasedOnCharges(loanVSChargesMap, loan.Id, strAppAsc, chargesMap, pricingAuthorityChargeMap));
                        /*for(String chargeName: loanVSChargesMap.get(loan.Id)){
                            if(chargeName!='Processing Fees' && chargename!='Documentation Charges' && chargeName!='LS Charges'){
                                Integer position = strAppAsc.size()-1;
                                listOfAuthority.add(strAppAsc[position]);
                            }
                        }commented to make common method*/
                        /*if(!loanVSChargesMap.get(loan.Id).contains('Processing Fees') && !loanVSChargesMap.get(loan.Id).contains('Documentation Charges') && !loanVSChargesMap.get(loan.Id).contains('LS Charges')){
                            Integer position = strAppAsc.size()-1;
                            listOfAuthority.add(strAppAsc[position]);
                        }*/

                        /*if(loanVSChargesMap.get(loan.Id).contains('Processing Fees')){
                            String key = loan.Id +';'+'Processing Fees';
                            Charge__c chargeRecord = chargesMap.get(key);
                            for(Pricing_Authority_Charges_Matrix__mdt pricingChargeRecord: pricingAuthorityChargeMap.get('Processing Fees')){
                                Decimal chargeDifference = chargeRecord.Rate_value_As_per_Policy__c - chargeRecord.Actual_rate__c;
                                if(chargeDifference >= pricingChargeRecord.Min_Value__c && chargeDifference < pricingChargeRecord.Max_Value__c){
                                    listOfAuthorityBasedOnCharges.add(pricingChargeRecord.Approval_Authority__c);
                                    listOfAuthority.add(pricingChargeRecord.Approval_Authority__c);
    
                                }
                            }
                        }

                        if(loanVSChargesMap.get(loan.Id).contains('Documentation Charges')){
                            String key = loan.Id +';'+'Documentation Charges';
                            Charge__c chargeRecord = chargesMap.get(key);
                            if(chargeRecord.Charge_Amount__c==0){
                                for(Pricing_Authority_Charges_Matrix__mdt pricingChargeRecord: pricingAuthorityChargeMap.get('Documentation Charges')){
                                    if(pricingChargeRecord.Is_Waived__c==true){
                                        listOfAuthorityBasedOnCharges.add(pricingChargeRecord.Approval_Authority__c);
                                        listOfAuthority.add(pricingChargeRecord.Approval_Authority__c);
    
                                    }
                                }
                            }else{
                                Decimal chargeDifference = chargeRecord.Rate_value_As_per_Policy__c - chargeRecord.Charge_Amount__c;
                                for(Pricing_Authority_Charges_Matrix__mdt pricingChargeRecord: pricingAuthorityChargeMap.get('Documentation Charges')){
                                    if(chargeDifference >= pricingChargeRecord.Min_Value__c && chargeDifference < pricingChargeRecord.Max_Value__c){
                                        listOfAuthorityBasedOnCharges.add(pricingChargeRecord.Approval_Authority__c);
                                        listOfAuthority.add(pricingChargeRecord.Approval_Authority__c);
    
                                    }
                                } 
                            }       
                        }

                        if(loanVSChargesMap.get(loan.Id).contains('LS Charges')){
                            String key = loan.Id +';'+'LS Charges';
                            Charge__c chargeRecord = chargesMap.get(key);
                            if(chargeRecord.Charge_Amount__c==0){
                                for(Pricing_Authority_Charges_Matrix__mdt pricingChargeRecord: pricingAuthorityChargeMap.get('LS Charges')){
                                    if(pricingChargeRecord.Is_Waived__c){
                                        listOfAuthorityBasedOnCharges.add(pricingChargeRecord.Approval_Authority__c);
                                        listOfAuthority.add(pricingChargeRecord.Approval_Authority__c);
                                    }
                                }
                            }
                            
                        }commented to make a common method*/
                    }/*else{
                        Integer position = strAppAsc.size()-1;
                        listOfAuthority.add(strAppAsc[position]);
                    }*/
                }
                // validate if LS charges has been taken if not add authrity which is configured for LS.
                String[] lsApprovalAuthority = getLsChargeApprovalAuthority( chargesByCode );
                // SFAU-5236 - Commented and add new if condition
                //if(!lsApprovalAuthority.isEmpty() && mapOfLoanIdVSAuthority.isEmpty() || (mapOfLoanIdVSAuthority.get(loan.Id) != lsApprovalAuthority[lsApprovalAuthority.size()-1])){
                if(!lsApprovalAuthority.isEmpty() && (mapOfLoanIdVSAuthority.isEmpty() || (mapOfLoanIdVSAuthority.containsKey(loan.Id) && mapOfLoanIdVSAuthority.get(loan.Id) != lsApprovalAuthority[lsApprovalAuthority.size()-1]))){
                    listOfAuthority.addAll(lsApprovalAuthority);
                    listOfAuthority = sortLists(listOfAuthority);
                    
                    String lsApprovalLevel = listOfAuthority[listOfAuthority.size()-1];
                    mapOfLoanIdVSAuthority.put( loan.Id, lsApprovalLevel );

                    Deviation__c lsDeviation = Utility.getDeviation( null, 'LS Charges', 'Charges not taken', lsApprovalLevel, loan.Id, '', true );
                    lsDeviation.Department__c = 'Pricing';
                    lsDeviation.Source__c = 'SF';
        
                    lstDeviationtoInsert.add( lsDeviation );
                }
                if(listOfAuthority!=null && listOfAuthority.size()>0){
                    listOfAuthority = sortLists(listOfAuthority);
                    //listOfAuthority.sort();
                    Integer position = listOfAuthority.size()-1;
                    mapOfLoanIdVSAuthority.put(loan.Id,listOfAuthority[position]);
                }/*else{
                    Loan_Application__c loanAppToUpdate = new Loan_Application__c();
                    loanAppToUpdate.Id = loan.Id;
                    loanAppToUpdate.No_Pricing_Deviation__c = true;
                    if((loan.Bre_Decision__c == GlobalConstants.BRE_DECISION_NSTP || loan.Bre_Decision__c == GlobalConstants.BRE_DECISION_STP) && loan.Stage__c==GlobalConstants.STAGE_PRICING){
                        if(loan.RecordType.DeveloperName == 'Four_Wheeler'){
                            loanAppToUpdate.Stage__c=GlobalConstants.STAGE_PSD;
                        }else if(loan.RecordType.DeveloperName == 'Two_Wheeler'){
                            loanAppToUpdate.Stage__c=GlobalConstants.STAGE_DDE;
                        }
                    }
                    loanApplicationsToBeUpdated.add(loanAppToUpdate);
                }*/
                
            }
        }
        mapOfLoanIdVSAuthorityMotorIns = insertApprovalsForMotorInsurance(createMotorInsuranceDeviations(loanAppsParamIdList), loanAppsParam, false);
        List<Id> loanApprovalLoanIdToDelete = new List<Id>();
        Map<String,String> mapOfMotorInsuranceAuthorityApproval = new Map<String,String>();
        for(Loan_Application__c loan: loanApps){
            if(!mapOfLoanIdVSAuthority.containsKey(loan.Id) && !mapOfLoanIdVSAuthorityMotorIns.containsKey(loan.Id)){
                Loan_Application__c loanAppToUpdate = new Loan_Application__c();
                loanAppToUpdate.Id = loan.Id;
                loanAppToUpdate.No_Pricing_Deviation__c = true;
                /* START - SFAU-5606 - If No_Pricing_Deviation__c THEN Change Stage accordingly */
                // SFAU-5722 - pricing approvals not created in preapproved cases - Add Pre Approved check
                if(((loan.Bre_Decision__c == GlobalConstants.BRE_DECISION_NSTP || loan.Bre_Decision__c == GlobalConstants.BRE_DECISION_STP || loan.Pre_Approved_Flag__c) && loan.Stage__c==GlobalConstants.STAGE_PRICING)){
                    if(loan.RecordType.DeveloperName == 'Four_Wheeler'){
                        loanAppToUpdate.Stage__c=GlobalConstants.STAGE_PSD;
                    }else if(loan.RecordType.DeveloperName == 'Two_Wheeler'){
                        loanAppToUpdate.Stage__c=GlobalConstants.STAGE_DDE;
                    }else if(loan.RecordType.DeveloperName == 'Tractor' || loan.RecordType.DeveloperName == 'Construction_Equipment' || loan.RecordType.DeveloperName == 'Commercial_Vehicle'){
                        loanAppToUpdate.Stage__c=GlobalConstants.STAGE_PSD;
                    }
                }
                /* END - SFAU-5606 - If No_Pricing_Deviation__c THEN Change Stage accordingly */
                loanApplicationsToBeUpdated.add(loanAppToUpdate);
            }else if(mapOfLoanIdVSAuthority.containsKey(loan.Id) && !mapOfLoanIdVSAuthorityMotorIns.containsKey(loan.Id)){
                mapOfLoanIdVSAuthorityReturn.put(loan.Id,mapOfLoanIdVSAuthority.get(loan.Id));
            }else if(!mapOfLoanIdVSAuthority.containsKey(loan.Id) && mapOfLoanIdVSAuthorityMotorIns.containsKey(loan.Id)){
                mapOfLoanIdVSAuthorityReturn.put(loan.Id,mapOfLoanIdVSAuthorityMotorIns.get(loan.Id));
                mapOfMotorInsuranceAuthorityApproval.put(loan.Id,mapOfLoanIdVSAuthorityMotorIns.get(loan.Id));
            }else{
                if(Integer.valueOf(mapOfLoanIdVSAuthority.get(loan.Id).replace('P',''))>Integer.valueOf(mapOfLoanIdVSAuthorityMotorIns.get(loan.Id).replace('P',''))){
                    mapOfLoanIdVSAuthorityReturn.put(loan.Id,mapOfLoanIdVSAuthority.get(loan.Id));
                    loanApprovalLoanIdToDelete.add(loan.Id);
                    if(motorInsuranceRBMPricingApprovalAuthority!=null && motorInsuranceRBMPricingApprovalAuthority.containsKey(loan.Id)){
                        motorInsuranceRBMPricingApprovalAuthority.remove(loan.Id);
                    }
                    if(motorInsuranceNBMPricingApprovalAuthority!=null && motorInsuranceNBMPricingApprovalAuthority.containsKey(loan.Id)){
                        motorInsuranceNBMPricingApprovalAuthority.remove(loan.Id);
                    }
                }else{
                    mapOfLoanIdVSAuthorityReturn.put(loan.Id,mapOfLoanIdVSAuthorityMotorIns.get(loan.Id));
                    mapOfMotorInsuranceAuthorityApproval.put(loan.Id,mapOfLoanIdVSAuthorityMotorIns.get(loan.Id));
                }
            }
        }
        //motorInsuranceRBMPricingApprovalAuthority = mapOfMotorInsuranceAuthorityApproval;
        List<Loan_Application_Approval__c> loanMotorApprovalsDelete = [SELECT Id FROM Loan_Application_Approval__c WHERE 
            Loan_Application__c IN :loanApprovalLoanIdToDelete AND Type__c='Highest' AND Archived__c=false AND Approval_Status__c=:GlobalConstants.APPROVAL_STATUS_PENDING AND 
            Approval_Type__c=:GlobalConstants.APPROVAL_TYPE_PRICING Order By CreatedDate Desc];
        
        if(loanMotorApprovalsDelete!=null && loanMotorApprovalsDelete.size()>0){
            delete loanMotorApprovalsDelete;
        }
        if(loanApplicationsToBeUpdated!=null && loanApplicationsToBeUpdated.size()>0){
            if(Schema.sObjectType.Loan_Application__c.isUpdateable()){
                update loanApplicationsToBeUpdated;
            }
        }
        if(!lstDeviationtoInsert.isEmpty()){
            // SFAU-4471 - LS Charges to be archived when reassignment happens
            Utility.archiveDeviations([ SELECT Id FROM Deviation__c WHERE Deviation_Type__c = 'LS Charges' AND Archived__c = FALSE AND Loan_Application__c IN: loanApps ]);
            Utility.createDeviation(lstDeviationtoInsert);
        }
        return mapOfLoanIdVSAuthorityReturn;

    }

    public static  Map<String,String> insertApprovalsForMotorInsurance(Map<String,String> mapOfMotorInsuranceAuthorityApproval, Map<Id, Loan_Application__c> loanAppsParam, Boolean isOnChargeUpdate){
        Set<String> regionIds = new Set<String>();
        Set<String> nationalIds = new Set<String>();
        List<Id> loanAppIdList = new List<Id>();
        for(String key: mapOfMotorInsuranceAuthorityApproval.keySet()){
            loanAppIdList.add(key);
            if(mapOfMotorInsuranceAuthorityApproval.get(key).split('/')[1]=='NBM'){
                nationalIds.add(loanAppsParam.get(key).Branch_Master__r.National__c);
            }else if(mapOfMotorInsuranceAuthorityApproval.get(key).split('/')[1]=='RBM'){
                regionIds.add(loanAppsParam.get(key).Branch_Master__r.Region__c);
            }
        }
        Map<String,String> mapOfLoanIdVsCollateralName = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsCustGrade = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsTypeOfEmpl = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsProduct = new Map<String,String>();
        Map<String,List<String>> mapOfFieldVsListOfValues = new Map<String,List<String>>();
        CreditApprovalHandler.wrapper wrap = CreditApprovalHandler.getListOfFilterValues(loanAppIdList);
        mapOfLoanIdVsCollateralName = wrap.mapOfLoanIddVsCollateralName;
        mapOfLoanIdVsCustGrade = wrap.mapOfLoanIdVsCustGrade;
        mapOfLoanIdVsTypeOfEmpl = wrap.mapOfLoanIdVsTypeOfEmpl;
        mapOfFieldVsListOfValues = wrap.mapOfFieldVsValues;
        mapOfLoanIdVsProduct = wrap.mapOfLoanIdVsProduct;     
        // SFAU-4827 - 07/09/23
        /*AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCustGrade = mapOfLoanIdVsCustGrade;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsTypeOfEmpl = mapOfLoanIdVsTypeOfEmpl;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCollateralName = mapOfLoanIdVsCollateralName;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsProduct = mapOfLoanIdVsProduct;
        AUSFLoanApplicationAssignmentHelper.mapOfFieldVsListOfValues = mapOfFieldVsListOfValues;*/
        List<AccountTeamMember> accountTeamMemberListRBM = CreditApprovalHandler.getAccountTeamMembers(regionIds, loanAppIdList, mapOfFieldVsListOfValues, GlobalConstants.APPROVAL_TYPE_PRICING);
        List<AccountTeamMember> accountTeamMemberListNBM = CreditApprovalHandler.getAccountTeamMembers(nationalIds, loanAppIdList, mapOfFieldVsListOfValues, GlobalConstants.APPROVAL_TYPE_PRICING);
        Map<String,String> newAuthorityOfApproval = new Map<String, String>();
        List<Loan_Application_Approval__c> approvalListToUpsert = new List<Loan_Application_Approval__c>();
        Map<Id, List<AccountTeamMember>> mapOfRBMs = new Map<Id, List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> mapOfNBMs = new Map<Id, List<AccountTeamMember>>();
        mapOfRBMs = getMapOfAcTeamMembers(accountTeamMemberListRBM, System.Label.Region_Head_RBM);
        mapOfNBMs = getMapOfAcTeamMembers(accountTeamMemberListNBM, System.Label.National_Head_NBM_NPM);
        String currentAuth;
        for(String key: mapOfMotorInsuranceAuthorityApproval.keySet()){
            Integer approvalLevelOfRBM;
            AccountTeamMember selectMember;
            Id locationId;
            Map<Id, List<AccountTeamMember>> currentAuthorityMap = new Map<Id, List<AccountTeamMember>>();
            if(mapOfRBMs.containsKey(loanAppsParam.get(key).Branch_Master__r.Region__c)){
                locationId = loanAppsParam.get(key).Branch_Master__r.Region__c;
                currentAuthorityMap=mapOfRBMs;
                currentAuth='RBM';
            }else if(mapOfNBMs.containsKey(loanAppsParam.get(key).Branch_Master__r.National__c)){
                locationId = loanAppsParam.get(key).Branch_Master__r.National__c;
                currentAuthorityMap=mapOfNBMs;
                currentAuth='NBM';
            }
            if(locationId==null){
                return new Map<String,String>();
            }
            for(AccountTeamMember head: currentAuthorityMap.get(locationId)){
                Integer previousRBMLevel = approvalLevelOfRBM;
                if(head.Approver_Level__c.contains(';')){
                    approvalLevelOfRBM = Integer.valueOf(sortLists(head.Approver_Level__c.split(';'))[0].replace('P',''));
                }else{
                    approvalLevelOfRBM = Integer.valueOf(head.Approver_Level__c.replace('P',''));
                }
                if(approvalLevelOfRBM>Integer.valueOf(mapOfMotorInsuranceAuthorityApproval.get(key).split('/')[0].replace('P','')) && (previousRBMLevel==null || (previousRBMLevel!=null && approvalLevelOfRBM<previousRBMLevel))){
                    newAuthorityOfApproval.put(key,'P'+approvalLevelOfRBM);
                    selectMember=head;
                }
                
            }
            if(currentAuth=='RBM'){
                motorInsuranceRBMPricingApprovalAuthority=newAuthorityOfApproval;
            }
            if(currentAuth=='NBM'){
                motorInsuranceNBMPricingApprovalAuthority=newAuthorityOfApproval;
            }
            if(!isOnChargeUpdate){
                Loan_Application_Approval__c approval1 = new Loan_Application_Approval__c();
                approval1.Loan_Application__c = key;
                approval1.Type__c = 'Highest'; 
                approval1.Approver__c = selectMember.UserId ;
                approval1.Approval_Type__c = GlobalConstants.APPROVAL_TYPE_PRICING ;
                approval1.Approver_Level__c = String.valueOf(newAuthorityOfApproval.get(key));
                approval1.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
                approvalListToUpsert.add(approval1);
            } 
        }
        List<Deviation__c> updateMotorDeviationAuthority = new List<Deviation__c>();
        if(motorInsuranceDeviation!=null && motorInsuranceDeviation.size()>0){
            for(Deviation__c dev: motorInsuranceDeviation){
                dev.Level__c = newAuthorityOfApproval.get(dev.Loan_Application__c);
                updateMotorDeviationAuthority.add(dev);
               
            }
            update updateMotorDeviationAuthority;
        }
        
        if(!isOnChargeUpdate){
            if(approvalListToUpsert!=null && approvalListToUpsert.size()>0 && !isOnChargeUpdate){
                upsert approvalListToUpsert;
            }
        }

        
        return newAuthorityOfApproval;
    }

    public static void callLoanApplicationAssignmentHelperMethod(Set<Id> loanAppIds){
        // SFAU-5722 - Add Pre_Approved_Flag__c on SOQL Query
        Map<Id, Loan_Application__c> listOfLoanApplications = new Map<Id, Loan_Application__c>([select Id, No_Pricing_Deviation__c, Name, ROI__c, RBP__c, RecordType.DeveloperName, toLabel(Product__c), RecordType.Name, Branch_Master__c,Branch_Master__r.Business_HUB__c,Branch_Master__r.State__c, Branch_Master__r.Region__c, Branch_Master__r.Zone__c, Branch_Master__r.National__c, BRE_Approval_Level__c, Bre_Decision__c, Stage__c, Collateral_Type__c, Pre_Approved_Flag__c, (SELECT Id, Insurance_Expiry_Date__c FROM Collaterals__r WHERE RecordType.DeveloperName In ('New','Used_Cash_on_Wheels') Order By CreatedDate Desc) from loan_application__c WHERE Id in :loanAppIds WITH SECURITY_ENFORCED]);
        List<Loan_Application__c> allLoanApps = new List<Loan_Application__c>();
        List<String> idList = new List<String>();
        for(Id idValue: listOfLoanApplications.keySet()){
            idList.add(idValue);
        }
        Map<Id, Id> mapOfLoanVsRegion = new Map<Id, Id>();
        Set<String> regionIds = new Set<String>();
        Set<String> branchMasters = new Set<String>();
        loanRecordTypes = new List<String>();//R2-1693,1691
        for(Loan_Application__c loan: listOfLoanApplications.values()){
            mapOfLoanVsRegion.put(loan.Id, loan.Branch_Master__r.Region__c);
            regionIds.add(loan.Branch_Master__r.Region__c);
            branchMasters.add(loan.Branch_Master__c);
            branchMasters.add(loan.Branch_Master__r.Business_HUB__c);
            branchMasters.add(loan.Branch_Master__r.State__c);
            branchMasters.add(loan.Branch_Master__r.Region__c);
            branchMasters.add(loan.Branch_Master__r.Zone__c);
            branchMasters.add(loan.Branch_Master__r.National__c);
            allLoanApps.add(loan);
            loanRecordTypes.add(loan.RecordType.Name);//R2-1693,1691
        }
        branchMasters.remove( null );

        Map<String, String> mapOfLoanIdVSAuthority = getPricingApprovalAuthorities(listOfLoanApplications);
        Map<String, String> mapOfLoanIdVSAuthorityOriginal = new Map<String, String>();
        mapOfLoanIdVSAuthorityOriginal = mapOfLoanIdVSAuthority.clone();
        //List<AccountTeamMember> accountTeamMemberList = [select Id, Customer_Grade__c, Type_Of_Employment__c, Collateral__c, Product__c, UserId, AccountId, Account.RecordType.DeveloperName, Approver_Level__c, Deviation_Level__c from AccountTeamMember Where (AccountId in :branchMasters AND TeamMemberRole='Pricing') OR (AccountId in :mapOfLoanVsRegion.values() AND TeamMemberRole='Region Head')];
        
        // AUSFLoanApplicationAssignmentHelper cs = new AUSFLoanApplicationAssignmentHelper(GlobalConstants.APPROVAL_TYPE_PRICING, mapOfLoanIdVSAuthority);
        Map<String,String> mapOfLoanIdVsCollateralName = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsCustGrade = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsTypeOfEmpl = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsProduct = new Map<String,String>();
        Map<String,List<String>> mapOfFieldVsListOfValues = new Map<String,List<String>>();
        
        CreditApprovalHandler.wrapper wrap = CreditApprovalHandler.getListOfFilterValues(idList);
        mapOfLoanIdVsCollateralName = wrap.mapOfLoanIddVsCollateralName;
        mapOfLoanIdVsCustGrade = wrap.mapOfLoanIdVsCustGrade;
        mapOfLoanIdVsTypeOfEmpl = wrap.mapOfLoanIdVsTypeOfEmpl;
        mapOfFieldVsListOfValues = wrap.mapOfFieldVsValues;
        mapOfLoanIdVsProduct = wrap.mapOfLoanIdVsProduct;
        
        /*
        * SFAU-4827 - 04/09/23
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCustGrade = mapOfLoanIdVsCustGrade;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsTypeOfEmpl = mapOfLoanIdVsTypeOfEmpl;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCollateralName = mapOfLoanIdVsCollateralName;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsProduct = mapOfLoanIdVsProduct;
        AUSFLoanApplicationAssignmentHelper.mapOfFieldVsListOfValues = mapOfFieldVsListOfValues;*/
        
       List<AccountTeamMember> accountTeamMemberListPricing = CreditApprovalHandler.getAccountTeamMembers(branchMasters, idList, mapOfFieldVsListOfValues, GlobalConstants.APPROVAL_TYPE_PRICING);
        List<AccountTeamMember> accountTeamMemberListRH = CreditApprovalHandler.getAccountTeamMembers(regionIds, idList, mapOfFieldVsListOfValues, GlobalConstants.APPROVAL_TYPE_PRICING);

        List<AccountTeamMember> listOfAccountTeamMembers = new List<AccountTeamMember>();
        //Map<Id, AccountTeamMember> mapOfRBMMembers = new Map<Id, AccountTeamMember>();
        Map<Id, List<AccountTeamMember>> mapOfRBMMembers = new Map<Id, List<AccountTeamMember>>();

        for(AccountTeamMember member: accountTeamMemberListPricing){
            //if(member.TeamMemberRole=='Pricing'){
            List<String> teamMemberRoles = System.Label.PricingTeamMemberRoles.split(',');
            if(teamMemberRoles.contains(member.TeamMemberRole)){
                listOfAccountTeamMembers.add(member);
            }
        }
        
        for(AccountTeamMember member: accountTeamMemberListRH){
            //if(member.TeamMemberRole=='Region Head'){
            if(member.TeamMemberRole==System.Label.Region_Head_RBM){    
                if(mapOfRBMMembers.containsKey(member.AccountId)){
                    mapOfRBMMembers.get(member.AccountId).add(member);
                }else{
                    List<AccountTeamMember> membersTempList = new List<AccountTeamMember>();
                    membersTempList.add(member);
                    mapOfRBMMembers.put(member.AccountId, membersTempList);
                }

				//mapOfRBMMembers.put(member.AccountId, member);
            }
            
        }
        
        /*for(AccountTeamMember member: accountTeamMemberList){
            if(member.Account.RecordType.DeveloperName == 'Branch'){
                listOfAccountTeamMembers.add(member);
            }else{
                mapOfRBMMembers.put(member.AccountId, member);
            }
            
        }*/

        
        // AUSFLoanApplicationAssignmentHelper.mainMethod(listOfAccountTeamMembers,listOfLoanApplications.values());

        // * SFAU-4827 - 04/09/23
        Loan_Application__c loanApplication = allLoanApps[0];
        CreditApprovalAssignmentHandler.mainMethod( GlobalConstants.APPROVAL_TYPE_PRICING, listOfAccountTeamMembers, loanApplication , mapOfLoanIdVSAuthority.get(loanApplication.Id) );

        List<Loan_Application_Approval__c> loanAppApprovals = [select Id, Approver_Level__c, Loan_Application__c, Loan_Application__r.Branch_Master__r.Region__c, Type__c from Loan_Application_Approval__c where Loan_Application__c in :listOfLoanApplications.keySet() AND Approval_Type__c=:GlobalConstants.APPROVAL_TYPE_PRICING AND Archived__c=false AND Approval_Status__c=:GlobalConstants.APPROVAL_STATUS_PENDING WITH SECURITY_ENFORCED ORDER BY CreatedDate Desc];
        loanAppApprovals = loanAppApprovals!=null && loanAppApprovals.size()>0?loanAppApprovals:new List<Loan_Application_Approval__c>();
        Map<Id,List<Loan_Application_Approval__c>> mapOfLoanVsApprovals = new Map<Id,List<Loan_Application_Approval__c>>();
        for(Loan_Application_Approval__c approval: loanAppApprovals){
            if(mapOfLoanVsApprovals.containsKey(approval.Loan_Application__c)){
                mapOfLoanVsApprovals.get(approval.Loan_Application__c).add(approval);
            }else{
                List<Loan_Application_Approval__c> newApprovalRecords = new List<Loan_Application_Approval__c>();
                newApprovalRecords.add(approval);
                mapOfLoanVsApprovals.put(approval.Loan_Application__c,newApprovalRecords);
            }
        }
        List<Loan_Application_Approval__c> approvalListToInsert = new List<Loan_Application_Approval__c>();
        Set<Id> loansWithNoPricing = new Set<Id>();
        loansWithNoPricing = listOfLoanApplications.keySet();
        List<Loan_Application_Approval__c> approvalsToDelete = new List<Loan_Application_Approval__c>();
        for(Id loanRecord: mapOfLoanVsApprovals.keySet()){
            String region = listOfLoanApplications.get(loanRecord).Branch_Master__r.Region__c;
            Integer approvalLevelOfHighest;
            Integer approvalLevelOfMiddle;
            Integer approvalLevelOfRBM;
            Id middleLevelApproverId;
            if((motorInsuranceRBMPricingApprovalAuthority==null || !motorInsuranceRBMPricingApprovalAuthority.containsKey(loanRecord)) && mapOfRBMMembers.keySet().contains(region)){
                AccountTeamMember regionHead;
                List<AccountTeamMember> regionHeads = mapOfRBMMembers.get(region);
                for(Loan_Application_Approval__c loanAppApproval: mapOfLoanVsApprovals.get(loanRecord)){
                    if(loanAppApproval.Type__c=='Highest'){
                        approvalLevelOfHighest = Integer.valueOf(loanAppApproval.Approver_Level__c.replace('P',''));
                    }
                    if(loanAppApproval.Type__c=='Middle'){
                        approvalLevelOfMiddle = Integer.valueOf(loanAppApproval.Approver_Level__c.replace('P',''));
                        middleLevelApproverId = loanAppApproval.Id;
                    }
                }
                if(regionHeads!=null && regionHeads.size()>0){
                    Map<Integer,AccountTeamMember> selectedRegionHeadsList = new Map<Integer,AccountTeamMember>();
                    for(AccountTeamMember head: regionHeads){
                        if(head.Approver_Level__c.contains(';')){
                            approvalLevelOfRBM = Integer.valueOf(sortLists(head.Approver_Level__c.split(';'))[0].replace('P',''));
                        }else{
                            approvalLevelOfRBM = Integer.valueOf(head.Approver_Level__c.replace('P',''));
                        }
                        if(approvalLevelOfRBM<approvalLevelOfHighest){
                            selectedRegionHeadsList.put(approvalLevelOfRBM,head);
                        }
                    }
                    if(selectedRegionHeadsList.keySet()!=null && selectedRegionHeadsList.keySet().size()>0){
                        List<Integer> sortedList = new List<Integer>(selectedRegionHeadsList.keySet());
                        sortedList.sort();
                        Integer position = sortedList.size()-1;
                        regionHead = selectedRegionHeadsList.get(sortedList[position]);
                        approvalLevelOfRBM = sortedList[position];
                    }
                }else{
                    regionHead = regionHeads[0];
                    if(regionHead.Approver_Level__c.contains(';')){
                        approvalLevelOfRBM = Integer.valueOf(sortLists(regionHead.Approver_Level__c.split(','))[0].replace('P',''));
                    }else{
                        approvalLevelOfRBM = Integer.valueOf(regionHead.Approver_Level__c.replace('P',''));
                    }
                }
                
                /*if(regionHead.Approver_Level__c.contains(',')){
                    approvalLevelOfRBM = Integer.valueOf(sortLists(regionHead.Approver_Level__c.split(','))[0]);
                }else{
                    approvalLevelOfRBM = Integer.valueOf(regionHead.Approver_Level__c.replace('P',''));
                }*/
		if(regionHead != null){
	                if(approvalLevelOfMiddle==null){
	                    Loan_Application_Approval__c approval1 = new Loan_Application_Approval__c();
	                    approval1.Loan_Application__c = loanRecord;
	                    approval1.Type__c = 'Middle'; 
	                    approval1.Approver__c = regionHead.UserId ;
	                    approval1.Approval_Type__c = GlobalConstants.APPROVAL_TYPE_PRICING ;
	                    approval1.Approver_Level__c = 'P'+String.valueOf(approvalLevelOfRBM);
	                    approval1.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
	                    approvalListToInsert.add(approval1); 
	                }else if(approvalLevelOfRBM<approvalLevelOfHighest && approvalLevelOfRBM>approvalLevelOfMiddle){
	                    Loan_Application_Approval__c approval1 = new Loan_Application_Approval__c();
	                    approval1.Loan_Application__c = loanRecord;
	                    approval1.Type__c = 'Middle'; 
	                    approval1.Approver__c = regionHead.UserId ;
	                    approval1.Approval_Type__c = GlobalConstants.APPROVAL_TYPE_PRICING ;
	                    approval1.Approver_Level__c = 'P'+String.valueOf(approvalLevelOfRBM);
	                    approval1.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
	                    approvalListToInsert.add(approval1); 
	
	                    Loan_Application_Approval__c approval2 = new Loan_Application_Approval__c();
	                    approval2.Type__c = 'Base'; 
	                    approval2.Id = middleLevelApproverId;
	                    approvalListToInsert.add(approval2);    
	                }else if(approvalLevelOfRBM<approvalLevelOfHighest && approvalLevelOfRBM<approvalLevelOfMiddle){
	                    Loan_Application_Approval__c approval1 = new Loan_Application_Approval__c();
	                    approval1.Loan_Application__c = loanRecord;
	                    approval1.Type__c = 'Base'; 
	                    approval1.Approver__c = regionHead.UserId ;
	                    approval1.Approval_Type__c = GlobalConstants.APPROVAL_TYPE_PRICING ;
	                    approval1.Approver_Level__c = 'P'+String.valueOf(approvalLevelOfRBM);
	                    approval1.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
	                    approvalListToInsert.add(approval1);
	                }
		}
            }
            if((motorInsuranceRBMPricingApprovalAuthority!=null && motorInsuranceRBMPricingApprovalAuthority.containsKey(loanRecord))||(motorInsuranceNBMPricingApprovalAuthority!=null && motorInsuranceNBMPricingApprovalAuthority.containsKey(loanRecord))){
                for(Loan_Application_Approval__c loanAppApproval: mapOfLoanVsApprovals.get(loanRecord)){
                    if(loanAppApproval.Type__c=='Highest'){
                        approvalsToDelete.add(loanAppApproval);
                        break;
                    }
                }
            }
            if(loansWithNoPricing.contains(loanRecord)){
                loansWithNoPricing.remove(loanRecord);
            } 
        }
        //AND Type__c='Middle'
        /*Set<Id> loansWithNoPricing = new Set<Id>();
        loansWithNoPricing = listOfLoanApplications.keySet();
        Map<Id, Loan_Application_Approval__c> approvalListToInsert = new Map<Id, Loan_Application_Approval__c>();
        for(Loan_Application_Approval__c approval: loanAppApprovals){
            if(approval.Type__c == 'Highest'){
                String region = approval.Loan_Application__r.Branch_Master__r.Region__c;
                if(mapOfRBMMembers.keySet().contains(region)){
                    AccountTeamMember regionHead = mapOfRBMMembers.get(region);
                    Integer approvalApproverLevel = Integer.valueOf(approval.Approver_Level__c.replace('P',''));
                    Integer accApproverLevel;
                    if(regionHead.Approver_Level__c.contains(',')){
                        accApproverLevel = Integer.valueOf(sortLists(regionHead.Approver_Level__c.split(','))[0]);
                    }else{
                        accApproverLevel = Integer.valueOf(regionHead.Approver_Level__c.replace('P',''));
                    }

                    if(approvalApproverLevel > accApproverLevel){
                        Loan_Application_Approval__c lc = new Loan_Application_Approval__c();
                        lc.Loan_Application__c = approval.Loan_Application__c;
                        lc.Type__c = 'Base'; 
                        //lc.RecordTypeId = Schema.SObjectType.Loan_Application_Approval__c.getRecordTypeInfosByDeveloperName().get('Pricing_Approver').getRecordTypeId();
                        lc.Approver__c = regionHead.UserId ;
                        lc.Approval_Type__c = GlobalConstants.APPROVAL_TYPE_PRICING ;
                        lc.Approver_Level__c = 'P'+String.valueOf(accApproverLevel);
                        lc.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
                        approvalListToInsert.put(approval.Loan_Application__c,lc);
                    }
                }
            }
            if(loansWithNoPricing.contains(approval.Loan_Application__c)){
                loansWithNoPricing.remove(approval.Loan_Application__c);
            } 
        }*/
        if(approvalListToInsert!=null && approvalListToInsert.size()>0){
            if(Schema.sObjectType.Loan_Application_Approval__c.isCreateable()){
                //insert approvalListToInsert.values();
                upsert approvalListToInsert;
            }
        }
        if(approvalsToDelete!=null && approvalsToDelete.size()>0){
            delete approvalsToDelete;
        }
        List<Loan_Application__c> loansToBeUpdated = new List<Loan_Application__c>();

        List<Deviation__c> lstDeviationtoInsert = new List<Deviation__c>();
        for(Loan_Application__c loanAppTemp: allLoanApps){
            if(loansWithNoPricing.contains(loanAppTemp.Id)){
                Loan_Application__c loan = new Loan_Application__c();
                loan.Id = loanAppTemp.Id;
                loan.No_Pricing_Deviation__c = true;
                // SFAU-5722 - pricing approvals not created in preapproved cases - Add Pre Approved check
                if((loanAppTemp.Bre_Decision__c == GlobalConstants.BRE_DECISION_NSTP || loanAppTemp.Bre_Decision__c == GlobalConstants.BRE_DECISION_STP || loanAppTemp.Pre_Approved_Flag__c) && loanAppTemp.Stage__c==GlobalConstants.STAGE_PRICING){
                    if(loanAppTemp.RecordType.DeveloperName == 'Four_Wheeler'){
                        loan.Stage__c=GlobalConstants.STAGE_PSD;
                    }else if(loanAppTemp.RecordType.DeveloperName == 'Two_Wheeler'){
                        loan.Stage__c=GlobalConstants.STAGE_DDE;
                    }else if(loanAppTemp.RecordType.DeveloperName == 'Tractor' || loanAppTemp.RecordType.DeveloperName == 'Construction_Equipment' || loanAppTemp.RecordType.DeveloperName == 'Commercial_Vehicle'){
                        loan.Stage__c=GlobalConstants.STAGE_PSD;
                    }
                }
                // CUG -- Case gets stuck on Pricing when it was relooked
                loan.Is_Being_Relooked__c = false;
                loansToBeUpdated.add(loan);
            }else{
                Loan_Application__c loan = new Loan_Application__c();
                loan.Id = loanAppTemp.Id;
                loan.Pricing_Authority__c = mapOfLoanIdVSAuthorityOriginal.get(loanAppTemp.Id);
                /* START - SFAU-5606 - If No_Pricing_Deviation__c THEN Change Stage accordingly */
                // SFAU-5722 - pricing approvals not created in preapproved cases - Add Pre Approved check
                if(((String.isEmpty(loan.Pricing_Authority__c) && (loanAppTemp.Bre_Decision__c == GlobalConstants.BRE_DECISION_NSTP || loanAppTemp.Bre_Decision__c == GlobalConstants.BRE_DECISION_STP || loanAppTemp.Pre_Approved_Flag__c)) && loanAppTemp.Stage__c==GlobalConstants.STAGE_PRICING)){
                    if(loanAppTemp.RecordType.DeveloperName == 'Four_Wheeler'){
                        loan.No_Pricing_Deviation__c = true;
                        loan.Stage__c=GlobalConstants.STAGE_PSD;
                    }else if(loanAppTemp.RecordType.DeveloperName == 'Two_Wheeler'){
                        loan.Stage__c=GlobalConstants.STAGE_DDE;
                        loan.No_Pricing_Deviation__c = true;
                    }else if(loanAppTemp.RecordType.DeveloperName == 'Tractor' || loanAppTemp.RecordType.DeveloperName == 'Construction_Equipment' || loanAppTemp.RecordType.DeveloperName == 'Commercial_Vehicle'){
                        loan.No_Pricing_Deviation__c = true;
                        loan.Stage__c=GlobalConstants.STAGE_PSD;
                    }
                }
                /* END - SFAU-5606 - If No_Pricing_Deviation__c THEN Change Stage accordingly */

                /*if(loanAppTemp.ROI__c<loanAppTemp.RBP__c){
                    Deviation__c newDeviation = new Deviation__c();
                    newDeviation = Utility.getDeviation('','ROI - Min Level Breached','Amount less than minimum',loan.Pricing_Authority__c,loanAppTemp.Id,'',true);
                    newDeviation.Policy_Value__c = loanAppTemp.RBP__c;
                    newDeviation.Actual_Value__c = loanAppTemp.ROI__c;
                    newDeviation.Variance__c = loanAppTemp.RBP__c - loanAppTemp.ROI__c;
                    newDeviation.Department__c = 'Pricing';
                    newDeviation.Source__c = 'SF';
                    lstDeviationtoInsert.add(newDeviation);
                }*/
                // CUG -- Case gets stuck on Pricing when it was relooked
                loan.Is_Being_Relooked__c = false;
                loansToBeUpdated.add(loan);
                
            }
        }
        /*if(loansWithNoPricing!=null && loansWithNoPricing.size()>0){
            List<Loan_Application__c> loansToBeUpdated = new List<Loan_Application__c>();
            for(Id loanIdTemp: loansWithNoPricing){
                Loan_Application__c loan = new Loan_Application__c();
                loan.Id = loanIdTemp;
                loan.No_Pricing_Deviation__c = true;
                loansToBeUpdated.add(loan);
            }
            
        }*/
        if(loansToBeUpdated!=null && loansToBeUpdated.size()>0){
            update loansToBeUpdated;
        }
        

    }

    public static List<String> sortLists(List<String> listToBeSorted){

        List<Integer> newIntList = new List<Integer>();
        List<String> modifiedList = new List<String>();

        for(String item: listToBeSorted){
            Integer itemInt = Integer.valueOf(item.replace('P',''));
            newIntList.add(itemInt);
        }
        newIntList.sort();
        for(Integer item: newIntList){
            modifiedList.add('P'+item);
        }
        return modifiedList;
    }

    public static List<String> getAuthorityBasedOnCharges(Map<String, List<String>> loanVSChargesMapTemp, String currentLoanId, List<String> authoritiesList, Map<String, Charge__c> chargesMapTemp, Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMapTemp){
        List<String> listOfAuthority = new List<String>();
        if(loanVSChargesMapTemp.keySet().contains(currentLoanId)){

            for(String chargeName: loanVSChargesMapTemp.get(currentLoanId)){
                if(chargeName!='Processing Fees' && chargename!='Documentation Charges' && chargeName!='LS Charges' && chargeName!='Stamp Duty'){
                    String key = currentLoanId +';'+chargeName;
                    Charge__c chargeRecord = chargesMapTemp.get(key);
                    Decimal chargeDifference=0;
		    // SFAU-5236 Add Logic - Deviation Applicable and Min Charges for Higher Authority
                    chargeRecord.Min_charges__c = chargeRecord.Min_charges__c == null ? chargeRecord.Min_charges__c = 0 : chargeRecord.Min_charges__c;
                    if(chargeRecord.Value_Type__c=='Percent' && chargeRecord.Deviation_Applicable__c == 'Yes'){
                        chargeDifference = chargeRecord.Min_charges__c - chargeRecord.Actual_rate__c;
                    }
                    if(chargeRecord.Value_Type__c=='Fixed' && chargeRecord.Deviation_Applicable__c == 'Yes'){
                        chargeDifference = chargeRecord.Min_charges__c - chargeRecord.Charge_Amount__c;
                    }
                    if(chargeDifference>0){
                        Integer position = authoritiesList.size()-1;
                        listOfAuthority.add(authoritiesList[position]);
                    }
                }
            }
            /*if(!loanVSChargesMapTemp.get(loan.Id).contains('Processing Fees') && !loanVSChargesMapTemp.get(loan.Id).contains('Documentation Charges') && !loanVSChargesMapTemp.get(loan.Id).contains('LS Charges')){
                Integer position = strAppAsc.size()-1;
                listOfAuthority.add(strAppAsc[position]);
            }*/

            if(loanVSChargesMapTemp.get(currentLoanId).contains('Processing Fees')){
                String key = currentLoanId +';'+'Processing Fees';
                Charge__c chargeRecord = chargesMapTemp.get(key);
                Boolean authorityFound=false;
                Decimal chargeDifference = chargeRecord.Rate_value_As_per_Policy__c - chargeRecord.Actual_rate__c;
                for(Pricing_Authority_Charges_Matrix__mdt pricingChargeRecord: pricingAuthorityChargeMapTemp.get('Processing Fees')){
                    if(chargeDifference >= pricingChargeRecord.Min_Value__c && chargeDifference <= pricingChargeRecord.Max_Value__c){
                        //listOfAuthorityBasedOnCharges.add(pricingChargeRecord.Approval_Authority__c);
                        listOfAuthority.add(pricingChargeRecord.Approval_Authority__c);
                        authorityFound=true;
                    }
                }
                if(!authorityFound && (chargeDifference!=null && chargeDifference>0)){
                    listOfAuthority.add(System.Label.PF_Highest_Authority);
                }
            }

            if(loanVSChargesMapTemp.get(currentLoanId).contains('Documentation Charges')){
                String key = currentLoanId +';'+'Documentation Charges';
                Charge__c chargeRecord = chargesMapTemp.get(key);
                Boolean authorityFound=false;
                Decimal chargeDifference = chargeRecord.Rate_value_As_per_Policy__c - chargeRecord.Charge_Amount__c;
                for(Pricing_Authority_Charges_Matrix__mdt pricingChargeRecord: pricingAuthorityChargeMapTemp.get('Documentation Charges')){
                    if(chargeDifference > pricingChargeRecord.Min_Value__c && chargeDifference <= pricingChargeRecord.Max_Value__c){//R2-1693,1691 - removed = sign from minvalue
                        //listOfAuthorityBasedOnCharges.add(pricingChargeRecord.Approval_Authority__c);
                        listOfAuthority.add(pricingChargeRecord.Approval_Authority__c);
                        authorityFound=true;
                    }
                } 
                if(!authorityFound && (chargeDifference!=null && chargeDifference>0)){
                    Integer position = authoritiesList.size()-1;
                    listOfAuthority.add(authoritiesList[position]);
                }        
            }

            if(loanVSChargesMapTemp.get(currentLoanId).contains('LS Charges')){
                String key = currentLoanId +';'+'LS Charges';
                Charge__c chargeRecord = chargesMapTemp.get(key);
                if(chargeRecord.Charge_Amount__c==0){
                    for(Pricing_Authority_Charges_Matrix__mdt pricingChargeRecord: pricingAuthorityChargeMapTemp.get('LS Charges')){
                        if(pricingChargeRecord.Is_Waived__c){
                            //listOfAuthorityBasedOnCharges.add(pricingChargeRecord.Approval_Authority__c);
                            listOfAuthority.add(pricingChargeRecord.Approval_Authority__c);
                        }
                    }
                }
                
            }
        }
        return listOfAuthority;
    }

    public static List<String> getSFpricingAuthorities(){
        List<String> pricingApprovalAuthorities = (Approver_Deviation_Level_Mapping__mdt.getInstance('PricingApprovalLevel').Level_Mapping__c).split(',');
        return pricingApprovalAuthorities;
    }

    public static ChargesMatrixListsWrapper getSFPricingAuthorityChargeMap(){
        List<Pricing_Authority_Charges_Matrix__mdt> pricingAuthorityChargeList = [SELECT Approval_Authority__c, Collateral_Type__c, Is_Waived__c, Max_Value__c, Min_Value__c, Particulars__c, Product_Type__c FROM Pricing_Authority_Charges_Matrix__mdt WHERE Product_Type__c IN :loanRecordTypes WITH SECURITY_ENFORCED];//Pricing_Authority_Charges_Matrix__mdt.getAll().values();//R2-1693,1691
        Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMapTemp = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
        ChargesMatrixListsWrapper chargesMatrixListsWrapper = new ChargesMatrixListsWrapper();
        chargesMatrixListsWrapper.pricingAuthorityChargeMapTWWrap = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
        chargesMatrixListsWrapper.pricingAuthorityChargeMapFWWrap = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
        chargesMatrixListsWrapper.pricingAuthorityChargeMapR2Wrap = new Map<String,Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>>();//R2-1693,1691

        for(Pricing_Authority_Charges_Matrix__mdt pricingCharge: pricingAuthorityChargeList){
            if(pricingCharge.Product_Type__c == 'Two Wheeler'){
                if(chargesMatrixListsWrapper.pricingAuthorityChargeMapTWWrap.containsKey(pricingCharge.Particulars__c)){
                    chargesMatrixListsWrapper.pricingAuthorityChargeMapTWWrap.get(pricingCharge.Particulars__c).add(pricingCharge);
                }else{
                    List<Pricing_Authority_Charges_Matrix__mdt> tempList = new List<Pricing_Authority_Charges_Matrix__mdt>();
                    tempList.add(pricingCharge);
                    chargesMatrixListsWrapper.pricingAuthorityChargeMapTWWrap.put(pricingCharge.Particulars__c,tempList);
                }
            }
            else if(pricingCharge.Product_Type__c == 'Four Wheeler'){
                if(chargesMatrixListsWrapper.pricingAuthorityChargeMapFWWrap.containsKey(pricingCharge.Particulars__c)){
                    chargesMatrixListsWrapper.pricingAuthorityChargeMapFWWrap.get(pricingCharge.Particulars__c).add(pricingCharge);
                }else{
                    List<Pricing_Authority_Charges_Matrix__mdt> tempList = new List<Pricing_Authority_Charges_Matrix__mdt>();
                    tempList.add(pricingCharge);
                    chargesMatrixListsWrapper.pricingAuthorityChargeMapFWWrap.put(pricingCharge.Particulars__c,tempList);
                }
            }
            else{
                for(String collateralType: pricingCharge.Collateral_Type__c.split(',')){
                    String key = pricingCharge.Product_Type__c+'_'+collateralType;
                    if(chargesMatrixListsWrapper.pricingAuthorityChargeMapR2Wrap.containsKey(key)){
                        Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> tempMap = chargesMatrixListsWrapper.pricingAuthorityChargeMapR2Wrap.get(key);
                        if(tempMap.containsKey(pricingCharge.Particulars__c)){
                            tempMap.get(pricingCharge.Particulars__c).add(pricingCharge);
                        }else{
                            List<Pricing_Authority_Charges_Matrix__mdt> tempList = new List<Pricing_Authority_Charges_Matrix__mdt>();
                            tempList.add(pricingCharge);
                            tempMap.put(pricingCharge.Particulars__c,tempList);
                        }
                        chargesMatrixListsWrapper.pricingAuthorityChargeMapR2Wrap.put(key,tempMap);
                    }else{
                        Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> tempMap = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
                        tempMap.put(pricingCharge.Particulars__c,new List<Pricing_Authority_Charges_Matrix__mdt>{pricingCharge});
                        chargesMatrixListsWrapper.pricingAuthorityChargeMapR2Wrap.put(key,tempMap);
                    }
                }
            }//R2-1693,1691
            
            
        }
        return chargesMatrixListsWrapper;
    }

    public class ChargesMatrixListsWrapper{
        public Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMapTWWrap;
        public Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMapFWWrap;
        public Map<String, Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>> pricingAuthorityChargeMapR2Wrap;//R2-1693,1691
    }

    public static Map<String,String> createMotorInsuranceDeviations(List<Id> applicationIds){
        Map<Id, Loan_Application__c> loanApplicationMap = new Map<Id, Loan_Application__c>([SELECT Id, Product__c, Branch_Master__r.Region__c, Branch_Master__r.National__c, 
        (SELECT Id, Insurance_Expiry_Date__c FROM Collaterals__r WHERE RecordType.DeveloperName IN ('New','Used_Cash_on_Wheels') ORDER By CreatedDate Desc),
        (SELECT Id, Charge_Amount__c, SC_Code__c, Rate_value_As_per_Policy__c, Loan_Application__c FROM Charges__r WHERE SC_Code__c='1099'),
        (SELECT Id FROM Deviations__r WHERE Deviation_Type__c='Motor Insurance' AND Archived__c=false) FROM Loan_Application__c WHERE Id IN: applicationIds]);
        Map<String,ProductRTMap__mdt> productMap = ProductRTMap__mdt.getAll();
        String COWProducts = System.Label.COW_Product_Names;//R2-2426
       
        List<String> loanIdList = new List<String>();
        List<Charge__c> allApplicationChargeList = new List<Charge__c>();
        for(Loan_Application__c loanApp: loanApplicationMap.values()){
            String productType='A_'+loanApp.Product__c;
            String subProductValue = productMap.get(productType).Sub_Product__c;
            //if(productMap.get(productType).Sub_Product__c=='Used' || productMap.get(productType).Sub_Product__c=='Cash on Wheels'){
                if(subProductValue!=null && (subProductValue=='Used' || COWProducts.toUpperCase().contains(subProductValue.toUpperCase()))){//R2-2634
                    loanIdList.add(loanApp.Id);
                allApplicationChargeList.addAll(loanApp.Charges__r);
            }
        }

        Map<String, Motor_Insurance_Deviation_Criteria__mdt> motorInsuranceMetadataMap = Motor_Insurance_Deviation_Criteria__mdt.getAll();
        Map<String,String> mapOfLoanIdVsMotorInsAuthority = new Map<String,String>();
        List<Id> noChargeLoans = new List<Id>();
        noChargeLoans.addAll(loanIdList);
        motorInsuranceDeviation = new List<Deviation__c>();
        for(Charge__c chargeRec: allApplicationChargeList){
            Id loanIdTemp = chargeRec.Loan_Application__c;
            Collateral__c collateralRecord = loanApplicationMap.get(loanIdTemp).Collaterals__r[0];
            noChargeLoans.remove(noChargeLoans.indexOf(loanIdTemp));
            Boolean matchFound=false;
            if(chargeRec.Charge_Amount__c == 0 && collateralRecord.Insurance_Expiry_Date__c!=null){
                Integer noOfDays = ((Date.today()).daysBetween(collateralRecord.Insurance_Expiry_Date__c)+1);
                if(noOfDays<0){
                    noOfDays=0;
                }
                for(Motor_Insurance_Deviation_Criteria__mdt mti: motorInsuranceMetadataMap.values()){
                    //if(collateralRecord.Insurance_Expiry_Date__c>=Date.today().addDays(Integer.valueOf(mti.Minimum_Days__c)) && collateralRecord.Insurance_Expiry_Date__c<=Date.today().addDays(Integer.valueOf(mti.Maximum_Days__c))){
                    if(noOfDays>=Integer.valueOf(mti.Minimum_Days__c) && noOfDays<=Integer.valueOf(mti.Maximum_Days__c)){
                        Id existingDevId = loanApplicationMap.get(loanIdTemp).Deviations__r!=null && loanApplicationMap.get(loanIdTemp).Deviations__r.size()>0?loanApplicationMap.get(loanIdTemp).Deviations__r[0].Id:null;
                        motorInsuranceDeviation.add(createNewDeviation(existingDevId,chargeRec,loanIdTemp,collateralRecord));
                        mapOfLoanIdVsMotorInsAuthority.put(loanIdTemp,mti.Authority__c+'/'+mti.Approval_Level_Type__c);
                        matchFound=true;
                    }
                }
            }
            if(chargeRec.Charge_Amount__c!=0 || matchFound==false){
                
                Id existingDevId = loanApplicationMap.get(loanIdTemp).Deviations__r!=null && loanApplicationMap.get(loanIdTemp).Deviations__r.size()>0?loanApplicationMap.get(loanIdTemp).Deviations__r[0].Id:null;
                if(existingDevId!=null){
                    Deviation__c motorInsdeviation = new Deviation__c();
                    motorInsdeviation.Id=existingDevId;
                    motorInsdeviation.Archived__c=true;
                    if(collateralRecord.Insurance_Expiry_Date__c!=null){
                        motorInsdeviation.Days_left_for_Insurance_Expiry__c = (Date.today()).daysBetween(collateralRecord.Insurance_Expiry_Date__c)+1;
                        if(motorInsdeviation.Days_left_for_Insurance_Expiry__c<0){
                            motorInsdeviation.Days_left_for_Insurance_Expiry__c=0;
                        } 
                    }else{
                        motorInsdeviation.Days_left_for_Insurance_Expiry__c=null;
                    }
                    motorInsuranceDeviation.add(motorInsdeviation);
                }
                
            }

        }
        for(Id loanId: noChargeLoans){
            Collateral__c collateralRecord = loanApplicationMap.get(loanId).Collaterals__r[0];
            Id existingDevId = loanApplicationMap.get(loanId).Deviations__r!=null && loanApplicationMap.get(loanId).Deviations__r.size()>0?loanApplicationMap.get(loanId).Deviations__r[0].Id:null;
            motorInsuranceDeviation.add(createNewDeviation(existingDevId,null,loanId,collateralRecord));
            mapOfLoanIdVsMotorInsAuthority.put(loanId,System.Label.Pricing_Highest_Authority+'/All');
            
            
        }

        if(motorInsuranceDeviation!=null && motorInsuranceDeviation.size()>0){
            upsert motorInsuranceDeviation;
        }

        return mapOfLoanIdVsMotorInsAuthority;
        

    }

    public static Deviation__c createNewDeviation(Id deviationId, Charge__c objChargeRec, Id loanAppId, Collateral__c collateral){
        Deviation__c newDeviation = new Deviation__c();
        newDeviation = Utility.getDeviation(deviationId,'Motor Insurance','Policy Value breached','',loanAppId,'',true);
        if(objChargeRec!=null){
            newDeviation.Policy_Value__c = objChargeRec.Rate_value_As_per_Policy__c;
            newDeviation.Actual_Value__c = objChargeRec.Charge_Amount__c;
            newDeviation.Variance__c = objChargeRec.Rate_value_As_per_Policy__c - objChargeRec.Charge_Amount__c;
        }
        if(collateral.Insurance_Expiry_Date__c!=null){
            newDeviation.Days_left_for_Insurance_Expiry__c = (Date.today()).daysBetween(collateral.Insurance_Expiry_Date__c)+1;
            if(newDeviation.Days_left_for_Insurance_Expiry__c<0){
                newDeviation.Days_left_for_Insurance_Expiry__c=0;
            }
        }else{
            newDeviation.Days_left_for_Insurance_Expiry__c=null;
        }
        newDeviation.Loan_Application__c = loanAppId;
        newDeviation.Department__c = 'Pricing';
        newDeviation.Source__c = 'SF';
        return newDeviation;
    }

    public static Map<Id, List<AccountTeamMember>> getMapOfAcTeamMembers(List<AccountTeamMember> tempList, String role){
        Map<Id, List<AccountTeamMember>> members = new Map<Id, List<AccountTeamMember>>();
        for(AccountTeamMember member: tempList){
            //if(member.TeamMemberRole=='Region Head'){
            if(member.TeamMemberRole==role){    
                if(members.containsKey(member.AccountId)){
                    members.get(member.AccountId).add(member);
                }else{
                    List<AccountTeamMember> membersTempList = new List<AccountTeamMember>();
                    membersTempList.add(member);
                    members.put(member.AccountId, membersTempList);
                }
            } 
        }
        return members;
    }
	
    /**
     * SFAU-4071
     * LS Approval to be considered while deciding highest Pricing level
    */
    public static String[] getLsChargeApprovalAuthority( map<String, Charge__c> chargesByCode ){
        List<String> applicableChargeCodes = System.Label.LoanSurakshaChargeCode.split(';\\s*');
        if( applicableChargeCodes.isEmpty() ) return new String[0];

        Set<String> lsChargeCodes = new Set<String>();
        lsChargeCodes.addAll(applicableChargeCodes);
        Decimal lsCharges = 0;
        for( String charge: lsChargeCodes ){
            // Atleast one LS charge is taken
            if( chargesByCode.containsKey( charge ) && chargesByCode.get( charge ).Charge_Amount__c > 0 ){
                lsCharges += chargesByCode.get( charge ).Charge_Amount__c;
            }
        }
        if( lsCharges == 0 ){
            return new String[]{ Label.LSChargeRequiredApprovalLevel };
        }
        return new String[0];
    }
}