public without sharing class ChargeTriggerService implements ServiceInterface {

    public void beforeInsert(List<sObject> newRecordList){
    }
    
    public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap){
        Map<String, List<Charge__c>> mapLoanIdvsCharges = new Map<String, List<Charge__c>>();
        Set<Id> loanIdsRelatedToCharge = new Set<Id>();
        for(Charge__c objCharge: (List<Charge__c>)newRecordList){
            loanIdsRelatedToCharge.add(objCharge.Loan_Application__c);
        }
        List<Charge__c> newChargeRecordList = [SELECT Actual_rate__c, Charge_Amount__c, Charges_Name__c, Customer_category__c, 
        Dedn_Cod__c, Deviation_Applicable__c, Loan_Application__c, Master_Name__c, Max_Charges_SOC__c, Min_charges__c, 
        Model_Age__c, Rate_value_As_per_Policy__c, SC_Code__c, Sequence_NO__c, Sequence_Number__c, Shown_to_UI__c, Tax_Amount__c, 
        Tax_Applicable__c, Tax_Percentage__c, Total_Amount__c, Value_Type__c, Loan_Application__r.RecordType.DeveloperName, Loan_Application__r.Stage__c,
        Loan_Application__r.RecordType.Name, Loan_Application__r.Collateral_Type__c FROM Charge__c WHERE Loan_Application__c IN :loanIdsRelatedToCharge];
        LosPricingApproval.loanRecordTypes=new List<String>();
        //for(Charge__c objCharge: (List<Charge__c>)newRecordList) {
        for(Charge__c objCharge: newChargeRecordList){
           if(mapLoanIdvsCharges.containsKey(objCharge.Loan_Application__c)){
               List<Charge__c> lstCharge = mapLoanIdvsCharges.get(objCharge.Loan_Application__c);
               lstCharge.add(objCharge);
               mapLoanIdvsCharges.put(objCharge.Loan_Application__c,lstCharge);
           }
           else{
                LosPricingApproval.loanRecordTypes.add(objCharge.Loan_Application__r.RecordType.Name);//R2-1693,1691
               mapLoanIdvsCharges.put(objCharge.Loan_Application__c,new List<Charge__c>{objCharge});
           }
        }
        system.debug('inside mapLoanIdvsCharges>>>'+mapLoanIdvsCharges);
        if(mapLoanIdvsCharges != null && !mapLoanIdvsCharges.keySet().isEmpty()){
           system.debug('inside mapLoanIdvsCharges>>>'+mapLoanIdvsCharges);
           checkDeviation(mapLoanIdvsCharges);
       }
        markApplicationChargeChangedFlag( (Charge__c[])newRecordList );
    }
    
    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
    }
    
    public void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
       system.debug('inchargeservice after update>>>');
       Map<String, List<Charge__c>> mapLoanIdvsCharges = new Map<String, List<Charge__c>>();
       Map<Id,Charge__c> oldChargeMap = (Map<Id,Charge__c>) oldRecordMap;
       Set<Id> loanIdsRelatedToCharge = new Set<Id>();
        for(Charge__c objCharge: (List<Charge__c>)newRecordList){
            loanIdsRelatedToCharge.add(objCharge.Loan_Application__c);
        }
        List<Charge__c> newChargeRecordList = [SELECT Actual_rate__c, Charge_Amount__c, Charges_Name__c, Customer_category__c, 
        Dedn_Cod__c, Deviation_Applicable__c, Loan_Application__c, Master_Name__c, Max_Charges_SOC__c, Min_charges__c, 
        Model_Age__c, Rate_value_As_per_Policy__c, SC_Code__c, Sequence_NO__c, Sequence_Number__c, Shown_to_UI__c, Tax_Amount__c, 
        Tax_Applicable__c, Tax_Percentage__c, Total_Amount__c, Value_Type__c, Loan_Application__r.RecordType.DeveloperName, Loan_Application__r.Stage__c,
        Loan_Application__r.RecordType.Name, Loan_Application__r.Collateral_Type__c FROM Charge__c WHERE Loan_Application__c IN :loanIdsRelatedToCharge];
        LosPricingApproval.loanRecordTypes=new List<String>();
       //for(Charge__c objCharge: (List<Charge__c>)newRecordList) {
        for(Charge__c objCharge: (List<Charge__c>)newChargeRecordList) {
           //if((objCharge.Charge_Amount__c != oldChargeMap.get(objCharge.Id).Charge_Amount__c) || (objCharge.Rate_value_As_per_Policy__c != oldChargeMap.get(objCharge.Id).Rate_value_As_per_Policy__c)) {
               if(mapLoanIdvsCharges.containsKey(objCharge.Loan_Application__c)){
                   List<Charge__c> lstCharge = mapLoanIdvsCharges.get(objCharge.Loan_Application__c);
                   lstCharge.add(objCharge);
                   mapLoanIdvsCharges.put(objCharge.Loan_Application__c,lstCharge);
               }
               else{
                LosPricingApproval.loanRecordTypes.add(objCharge.Loan_Application__r.RecordType.Name);//R2-1693,1691
                   mapLoanIdvsCharges.put(objCharge.Loan_Application__c,new List<Charge__c>{objCharge});
               }
           //}
       }
       if(mapLoanIdvsCharges != null && !mapLoanIdvsCharges.keySet().isEmpty()){
           system.debug('inside mapLoanIdvsCharges>>>');
           checkDeviation(mapLoanIdvsCharges);
       }
       markApplicationChargeChangedFlag( (Charge__c[])newRecordList, (map<Id, Charge__c>)oldRecordMap );
    }
    
    public void beforeDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterUndelete(Map<Id,sObject> newRecordList){
    } 
    
    public void checkDeviation(Map<String, List<Charge__c>> mapLoanIdvsCharges){
        Map<Id,Id> mapExistingLoanIdDeviation = new Map<Id,Id>();
        Map<Id,List<Deviation__c>> mapExistingLoanIdAdditionalDeviation = new Map<Id,List<Deviation__c>>();
        List<Id> loanAppIds = new List<Id>();
        Map<Id,Deviation__c> mapExistingDeviationIdVsDeviation = new Map<Id,Deviation__c>();
        Map<String,Deviation__c> mapTypevsDeviation = new Map<String,Deviation__c>();
        for(Deviation__c objDeviation : [Select Id,Level__c,Details__c,Loan_Application__c,Active__c,Deviation_Type__c From Deviation__c where Loan_Application__c =:mapLoanIdvsCharges.keySet() 
                                     AND Archived__c=false WITH SECURITY_ENFORCED]){
            if(objDeviation.Deviation_Type__c == 'Charges - Min Level Breached'){
                mapExistingLoanIdDeviation.put(objDeviation.Loan_Application__c,objDeviation.Id);
            }else if(objDeviation.Deviation_Type__c == GlobalConstants.LS_CHARGE_DEVIATION_NAME || objDeviation.Deviation_Type__c == GlobalConstants.PF_CHARGE_DEVIATION_NAME || objDeviation.Deviation_Type__c == GlobalConstants.DC_CHARGE_DEVIATION_NAME){
                if(mapExistingLoanIdAdditionalDeviation.containsKey(objDeviation.Loan_Application__c)){
                    mapExistingLoanIdAdditionalDeviation.get(objDeviation.Loan_Application__c).add(objDeviation);
                }else{
                    mapExistingLoanIdAdditionalDeviation.put(objDeviation.Loan_Application__c, new List<Deviation__c>());
                    List<Deviation__c> tempDevList = new List<Deviation__c>();
                    tempDevList.add(objDeviation);
                    mapExistingLoanIdAdditionalDeviation.put(objDeviation.Loan_Application__c,tempDevList);
                }
            }

            mapExistingDeviationIdVsDeviation.put(objDeviation.Id,objDeviation);
        }
        Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMap = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
        //pricingAuthorityChargeMap = LosPricingApproval.getSFPricingAuthorityChargeMap();
        Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMapTW = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
        Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMapFW = new Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>();
        Map<String,Map<String,List<Pricing_Authority_Charges_Matrix__mdt>>> pricingAuthorityChargeMapR2 = new Map<String,Map<String, List<Pricing_Authority_Charges_Matrix__mdt>>>();
        LosPricingApproval.ChargesMatrixListsWrapper chargesMatrixSplitWrapper = new LosPricingApproval.ChargesMatrixListsWrapper();
        chargesMatrixSplitWrapper = LosPricingApproval.getSFPricingAuthorityChargeMap();
        pricingAuthorityChargeMapTW = chargesMatrixSplitWrapper.pricingAuthorityChargeMapTWWrap;
        pricingAuthorityChargeMapFW = chargesMatrixSplitWrapper.pricingAuthorityChargeMapFWWrap;
        pricingAuthorityChargeMapR2 = chargesMatrixSplitWrapper.pricingAuthorityChargeMapR2Wrap;//R2-1693,1691

        Charge__c selectedChargeRecord;
        String existingDeviation;
        String levelForDeviation;
        List<String> strAppAsc = LosPricingApproval.getSFpricingAuthorities();
        List<Deviation__c> lstDeviationtoInsert = new List<Deviation__c>();
        for(String strLoanId : mapLoanIdvsCharges.keySet()){
            
            Boolean isDeviationUpdated=false;
            //existingDeviation = mapExistingLoanIdDeviation.get(strLoanId)!=null?mapExistingLoanIdDeviation.get(strLoanId):null;
            //levelForDeviation = existingDeviation!=null && mapExistingDeviationIdVsDeviation.get(existingDeviation)!=null?mapExistingDeviationIdVsDeviation.get(existingDeviation).Level__c:null; 
            for(Charge__c objCharge : mapLoanIdvsCharges.get(strLoanId)){  
                Map<Id,String> loanIdVsDeviationType = new Map<Id,String>();
                List<String> deviationTypes = new List<String>();
                if(objCharge.Loan_Application__r.Stage__c=='Credit'){
                    loanAppIds.add(Id.valueOf(strLoanId));
                }
                if(objCharge.Loan_Application__r.RecordType.DeveloperName=='Two_Wheeler'){
                    pricingAuthorityChargeMap=pricingAuthorityChargeMapTW;
                }else if(objCharge.Loan_Application__r.RecordType.DeveloperName=='Four_Wheeler'){
                    pricingAuthorityChargeMap=pricingAuthorityChargeMapFW;
                }else{
                    String key = objCharge.Loan_Application__r.RecordType.Name+'_'+objCharge.Loan_Application__r.Collateral_Type__c;
                    pricingAuthorityChargeMap=pricingAuthorityChargeMapR2.get(key);
                }//else part - R2-1693,1691
                if(objCharge.Value_Type__c == 'Fixed' && objCharge.Deviation_Applicable__c == 'Yes' 
                            && objCharge.Charge_Amount__c < objCharge.Rate_value_As_per_Policy__c ){
                    String newLevel = getPricingAuthority(objCharge, strAppAsc, pricingAuthorityChargeMap);
                    Deviation__c newDev = getAdditionalDeviations(objCharge, mapExistingLoanIdAdditionalDeviation, newLevel, strLoanId);
                    if(newDev!=null){
                        lstDeviationtoInsert.add(newDev);
                    }
                    if(checkIfDeviationNeedToUpdated(newLevel, levelForDeviation)){
                        selectedChargeRecord = objCharge;
                        levelForDeviation = newLevel;
                    }
                }else if(objCharge.Value_Type__c == 'Fixed' && objCharge.Deviation_Applicable__c == 'Yes' 
                && objCharge.Charge_Amount__c >= objCharge.Rate_value_As_per_Policy__c){
                    Deviation__c newDev = getDeviationsToArchive(objCharge, mapExistingLoanIdAdditionalDeviation, strLoanId);
                    if(newDev!=null){
                        lstDeviationtoInsert.add(newDev);
                    }    
                    
                }else if(objCharge.Value_Type__c == 'Percent' && objCharge.Deviation_Applicable__c == 'Yes' 
                            && objCharge.Actual_rate__c < objCharge.Rate_value_As_per_Policy__c ){
                    String newLevel = getPricingAuthority(objCharge, strAppAsc, pricingAuthorityChargeMap);
                    Deviation__c newDev = getAdditionalDeviations(objCharge, mapExistingLoanIdAdditionalDeviation, newLevel, strLoanId);
                    if(newDev!=null){
                        lstDeviationtoInsert.add(newDev);
                    }
                    if(checkIfDeviationNeedToUpdated(newLevel, levelForDeviation)){
                        selectedChargeRecord = objCharge;
                        levelForDeviation = newLevel;
                    }
                }else if(objCharge.Value_Type__c == 'Percent' && objCharge.Deviation_Applicable__c == 'Yes' 
                && objCharge.Charge_Amount__c >= objCharge.Rate_value_As_per_Policy__c){
                    Deviation__c newDev = getDeviationsToArchive(objCharge, mapExistingLoanIdAdditionalDeviation, strLoanId);
                    if(newDev!=null){
                        lstDeviationtoInsert.add(newDev);
                    }    
                    
                }
                
                /*if(objCharge.Value_Type__c == 'Fixed' && objCharge.Deviation_Applicable__c == 'Yes' 
                            && objCharge.Charge_Amount__c < objCharge.Rate_value_As_per_Policy__c ){
                    
                    String newLevel = getPricingAuthority(objCharge, strAppAsc, pricingAuthorityChargeMap);
                    String existingDeviation = mapExistingLoanIdDeviation.get(objCharge.Loan_Application__c)!=null?mapExistingLoanIdDeviation.get(objCharge.Loan_Application__c):null;
                    //String oldLevel = mapExistingLoanIdDeviation.get(objCharge.Loan_Application__c)!=null && mapExistingDeviationIdVsDeviation.get()!=null?
                    String oldLevel = existingDeviation!=null && mapExistingDeviationIdVsDeviation.get(existingDeviation)!=null?mapExistingDeviationIdVsDeviation.get(existingDeviation).Level__c:null; 
                    if(checkIfDeviationNeedToUpdated(newLevel, oldLevel)){
                        Deviation__c newDeviation = new Deviation__c();
                        newDeviation = Utility.getDeviation(mapExistingLoanIdDeviation.get(objCharge.Loan_Application__c),'Charges - Min Level Breached','Amount less than minimum','S1',objCharge.Loan_Application__c,'',true);
                        newDeviation.Policy_Value__c = objCharge.Rate_value_As_per_Policy__c;
                        newDeviation.Actual_Value__c = objCharge.Charge_Amount__c;
                        newDeviation.Variance__c = newDeviation.Policy_Value__c - newDeviation.Actual_Value__c;
                        newDeviation.Department__c = 'Pricing';
                        newDeviation.Source__c = 'SF';
                        newDeviation.Level__c = newLevel;//getPricingAuthority(objCharge, strAppAsc, pricingAuthorityChargeMap);
                        isDeviationUpdated=true;
                        lstDeviationtoInsert.add(newDeviation);
                    }
                }*/
                /*else if(objCharge.Value_Type__c == 'Percent' && objCharge.Deviation_Applicable__c == 'Yes' 
                            && objCharge.Actual_rate__c < objCharge.Rate_value_As_per_Policy__c ){
                    String newLevel = getPricingAuthority(objCharge, strAppAsc, pricingAuthorityChargeMap);
                    String existingDeviation = mapExistingLoanIdDeviation.get(objCharge.Loan_Application__c)!=null?mapExistingLoanIdDeviation.get(objCharge.Loan_Application__c):null;
                    String oldLevel = existingDeviation!=null && mapExistingDeviationIdVsDeviation.get(existingDeviation)!=null?mapExistingDeviationIdVsDeviation.get(existingDeviation).Level__c:null; 
                    Deviation__c newDeviation = new Deviation__c();
                    if(checkIfDeviationNeedToUpdated(newLevel, oldLevel)){
                        newDeviation = Utility.getDeviation(mapExistingLoanIdDeviation.get(objCharge.Loan_Application__c),'Charges - Min Level Breached','Amount less than minimum','S1',objCharge.Loan_Application__c,'',true);
                        newDeviation.Policy_Value__c = objCharge.Rate_value_As_per_Policy__c;
                        newDeviation.Actual_Value__c = objCharge.Actual_rate__c;
                        newDeviation.Variance__c = newDeviation.Policy_Value__c - newDeviation.Actual_Value__c;
                        newDeviation.Department__c = 'Pricing';
                        newDeviation.Source__c = 'SF';
                        isDeviationUpdated=true;
                        newDeviation.Level__c = newLevel;//getPricingAuthority(objCharge, strAppAsc, pricingAuthorityChargeMap);
                        lstDeviationtoInsert.add(newDeviation); 
                    }  
                }*/
                /*if(isDeviationUpdated==false){
                    Deviation__c newDeviation = new Deviation__c();
                    newDeviation.Id = mapExistingLoanIdDeviation.get(objCharge.Loan_Application__c);
                    newDeviation.Archived__c = true;                    
                    lstDeviationtoInsert.add(newDeviation);   
                }*/
            }
            if(selectedChargeRecord!=null){
                Deviation__c  newDeviation = new Deviation__c();
                newDeviation = Utility.getDeviation(mapExistingLoanIdDeviation.get(selectedChargeRecord.Loan_Application__c),'Charges - Min Level Breached','Amount less than minimum','S1',selectedChargeRecord.Loan_Application__c,'',true);
                newDeviation.Policy_Value__c = selectedChargeRecord.Rate_value_As_per_Policy__c;
                if(selectedChargeRecord.Value_Type__c=='Percent'){
                    newDeviation.Actual_Value__c = selectedChargeRecord.Actual_rate__c;
                }
                if(selectedChargeRecord.Value_Type__c=='Fixed'){
                    newDeviation.Actual_Value__c = selectedChargeRecord.Charge_Amount__c;
                }
                newDeviation.Variance__c = newDeviation.Policy_Value__c - newDeviation.Actual_Value__c;
                newDeviation.Department__c = 'Pricing';
                newDeviation.Source__c = 'SF';
                newDeviation.Loan_Application__c = selectedChargeRecord.Loan_Application__c;
                isDeviationUpdated=true;
                newDeviation.Level__c = levelForDeviation;//getPricingAuthority(objCharge, strAppAsc, pricingAuthorityChargeMap);
                lstDeviationtoInsert.add(newDeviation); 
            }
            if(isDeviationUpdated==false && mapExistingLoanIdDeviation.get(strLoanId)!=null && selectedChargeRecord==null){
                Deviation__c newDeviation = new Deviation__c();
                newDeviation.Id = mapExistingLoanIdDeviation.get(strLoanId);
                newDeviation.Archived__c = true;                    
                lstDeviationtoInsert.add(newDeviation);   
            }
        }
        system.debug('inside mapLoanIdvsCharges>>>'+lstDeviationtoInsert);
        if(loanAppIds!=null && loanAppIds.size()>0){
            Map<Id, Loan_Application__c> loanApplications = new Map<Id, Loan_Application__c>([SELECT Id, Branch_Master__r.Region__c, Branch_Master__r.National__c FROM Loan_Application__c WHERE Id IN :loanAppIds]);
            LosPricingApproval.insertApprovalsForMotorInsurance(LosPricingApproval.createMotorInsuranceDeviations(loanAppIds), loanApplications, true);    
        }
        if(!lstDeviationtoInsert.isEmpty()){
            system.debug('inside mapLoanIdvsCharges>>>');
            Utility.createDeviation(lstDeviationtoInsert);
        }
    }
    
    public static Boolean checkIfDeviationNeedToUpdated(String newLevelTemp, String oldLevelTemp){
        Integer newLevelAuthority = newLevelTemp!=null?Integer.valueOf(newLevelTemp.replace('P','')):null;
        Integer oldLevelAuthority = oldLevelTemp!=null?Integer.valueOf(oldLevelTemp.replace('P','')):null;
        Boolean updateDeviation = false;
        if(oldLevelAuthority==null || (newLevelAuthority!=null && (newLevelAuthority>=oldLevelAuthority))){
            updateDeviation = true;
        }
        return updateDeviation;
    }
    /**
    * Sachin - Updates Is_Charge_Changed__c flag on loan Application when related charges are changed
    */
    public static void markApplicationChargeChangedFlag(Charge__c[] newCharges){
        Set<Id> loanIds = new Set<Id>();
        for(Charge__c charge: newCharges){
            loanIds.add( charge.Loan_Application__c );
        }

        Set<Loan_Application__c> applicationsToUpdate = new Set<Loan_Application__c>();
        for(Charge__c charge: [ SELECT Id, Loan_Application__c FROM Charge__c WHERE Loan_Application__c IN: loanIds AND Id NOT IN: newCharges ]){
            ChargesController.boolIsChargeChanged = true;
            /*applicationsToUpdate.add(
                new Loan_Application__c(
                    Id = charge.Loan_Application__c,
                    Is_Charge_Changed__c = true
                )
            );*/
        }
        //update new List<Loan_Application__c>( applicationsToUpdate );
    }

    public static void markApplicationChargeChangedFlag(Charge__c[] newCharges, map<Id, Charge__c> oldCharges){
        Boolean isInsert = oldCharges == null;
        Set<Loan_Application__c> applicationsToUpdate = new Set<Loan_Application__c>();
        for(Charge__c charge: newCharges){
            if( isInsert || charge.Charge_Amount__c != oldCharges.get(charge.Id).Charge_Amount__c){
                if(charge.Value_Type__c == 'Fixed' && charge.Charge_Amount__c < charge.Rate_value_As_per_Policy__c){
                    ChargesController.boolIsChargeChanged = true;
                }
                if(charge.Value_Type__c == 'Percent' && charge.Actual_rate__c < charge.Rate_value_As_per_Policy__c){
                    ChargesController.boolIsChargeChanged = true;
                }
                
                /*applicationsToUpdate.add(
                    new Loan_Application__c(
                        Id = charge.Loan_Application__c,
                        Is_Charge_Changed__c = true
                    )
                );*/
            }
        }
        //update new List<Loan_Application__c>( applicationsToUpdate );
    }

    public static String getPricingAuthority(Charge__c objChargeTemp, List<String> strAppAscTemp, Map<String, List<Pricing_Authority_Charges_Matrix__mdt>> pricingAuthorityChargeMapTemp){
        List<String> tempList = new List<String>();
        tempList.add(objChargeTemp.Charges_Name__c);
        Map<String,List<String>> loanVSChargesMap = new Map<String,List<String>>();
        loanVSChargesMap.put(objChargeTemp.Loan_Application__c,tempList);
        Map<String, Charge__c> chargesMap = new Map<String, Charge__c>();
        String key = objChargeTemp.Loan_Application__c+';'+objChargeTemp.Charges_Name__c;
        chargesMap.put(key,objChargeTemp);
                List<String> listOfAuthority = LosPricingApproval.getAuthorityBasedOnCharges(loanVSChargesMap, objChargeTemp.Loan_Application__c, strAppAscTemp, chargesMap, pricingAuthorityChargeMapTemp);
        if(listOfAuthority!=null && listOfAuthority.size()>0){
            listOfAuthority = LosPricingApproval.sortLists(listOfAuthority);
            Integer position = listOfAuthority.size()-1;
            return listOfAuthority[position];
        }else{
            return null;
            //Integer position = strAppAscTemp.size()-1;
            //return strAppAscTemp[position];
        }
        
    }

    public static Deviation__c getAdditionalDeviations(Charge__c objCharge, Map<Id, List<Deviation__c>> mapExistingLoanIdAdditionalDeviation, String newLevel, Id strLoanId){
        Deviation__c newDeviation;
        if(objCharge.Charges_Name__c == GlobalConstants.PF_CHARGE || objCharge.Charges_Name__c == GlobalConstants.DC_CHARGE || objCharge.Charges_Name__c == GlobalConstants.LS_CHARGE){
            newDeviation = new Deviation__c();
            Boolean deviationExists = false;
            String deviationName='';
            if(objCharge.Charges_Name__c == GlobalConstants.PF_CHARGE){
                deviationName=GlobalConstants.PF_CHARGE_DEVIATION_NAME;
            }else if(objCharge.Charges_Name__c == GlobalConstants.DC_CHARGE){
                deviationName=GlobalConstants.DC_CHARGE_DEVIATION_NAME;
            }else if(objCharge.Charges_Name__c == GlobalConstants.LS_CHARGE){
                deviationName=GlobalConstants.LS_CHARGE_DEVIATION_NAME;
            }
            if(mapExistingLoanIdAdditionalDeviation!=null && mapExistingLoanIdAdditionalDeviation.containsKey(strLoanId) && mapExistingLoanIdAdditionalDeviation.get(strLoanId)!=null && mapExistingLoanIdAdditionalDeviation.get(strLoanId).size()>0){
                for(Deviation__c dev: mapExistingLoanIdAdditionalDeviation.get(strLoanId)){
                    if(dev.Deviation_Type__c.contains(objCharge.Charges_Name__c)){
                        newDeviation = Utility.getDeviation(dev.Id,deviationName,'Amount less than minimum',newLevel,objCharge.Loan_Application__c,'',true);
                        deviationExists=true;
                    }
                    /*if(objCharge.Charges_Name__c == GlobalConstants.PF_CHARGE && dev.Deviation_Type__c.contains(GlobalConstants.PF_CHARGE)){
                        newDeviation = Utility.getDeviation(dev.Id,GlobalConstants.PF_CHARGE_DEVIATION_NAME,'Amount less than minimum',newLevel,objCharge.Loan_Application__c,'',true);
                        deviationExists=true;
                    }else if(objCharge.Charges_Name__c == GlobalConstants.DC_CHARGE && dev.Deviation_Type__c.contains(GlobalConstants.DC_CHARGE)){
                        newDeviation = Utility.getDeviation(dev.Id,GlobalConstants.DC_CHARGE_DEVIATION_NAME,'Amount less than minimum',newLevel,objCharge.Loan_Application__c,'',true);
                        deviationExists=true;
                    }else if(objCharge.Charges_Name__c == GlobalConstants.LS_CHARGE && dev.Deviation_Type__c.contains(GlobalConstants.LS_CHARGE)){
                        newDeviation = Utility.getDeviation(dev.Id,GlobalConstants.LS_CHARGE_DEVIATION_NAME,'Amount less than minimum',newLevel,objCharge.Loan_Application__c,'',true);
                        deviationExists=true;
                    }*/
                    //getPricingAuthority(objCharge, strAppAsc, pricingAuthorityChargeMap);
                } 
                if(deviationExists==false){
                    newDeviation = Utility.getDeviation(null,deviationName,'Amount less than minimum',newLevel,objCharge.Loan_Application__c,'',true);
                }     
            }else{
                newDeviation = Utility.getDeviation(null,deviationName,'Amount less than minimum',newLevel,objCharge.Loan_Application__c,'',true);
                /*if(objCharge.Charges_Name__c == GlobalConstants.PF_CHARGE){
                    newDeviation = Utility.getDeviation(null,GlobalConstants.PF_CHARGE_DEVIATION_NAME,'Amount less than minimum',newLevel,objCharge.Loan_Application__c,'',true);
                }else if(objCharge.Charges_Name__c == GlobalConstants.DC_CHARGE){
                    newDeviation = Utility.getDeviation(null,GlobalConstants.DC_CHARGE_DEVIATION_NAME,'Amount less than minimum',newLevel,objCharge.Loan_Application__c,'',true);
                }else if(objCharge.Charges_Name__c == GlobalConstants.LS_CHARGE){
                    newDeviation = Utility.getDeviation(null,GlobalConstants.LS_CHARGE_DEVIATION_NAME,'Amount less than minimum',newLevel,objCharge.Loan_Application__c,'',true);
                }*/
            }
            newDeviation.Level__c = newLevel;
            newDeviation.Policy_Value__c = objCharge.Rate_value_As_per_Policy__c;
            if(objCharge.Value_Type__c=='Fixed'){
                newDeviation.Actual_Value__c = objCharge.Charge_Amount__c;
            }else if(objCharge.Value_Type__c=='Percent'){
                newDeviation.Actual_Value__c = objCharge.Actual_Rate__c;
            }
            newDeviation.Variance__c = newDeviation.Policy_Value__c - newDeviation.Actual_Value__c;
            newDeviation.Department__c = 'Pricing';
            newDeviation.Source__c = 'SF';
            newDeviation.Loan_Application__c = objCharge.Loan_Application__c;
        }
        return newDeviation;
    }

    public static Deviation__c getDeviationsToArchive(Charge__c objCharge, Map<Id, List<Deviation__c>> mapExistingLoanIdAdditionalDeviation, Id strLoanId){
        Deviation__c newDeviation;
        if(objCharge.Charges_Name__c==GlobalConstants.PF_CHARGE  || objCharge.Charges_Name__c == GlobalConstants.DC_CHARGE || objCharge.Charges_Name__c == GlobalConstants.LS_CHARGE){
            if(mapExistingLoanIdAdditionalDeviation!=null && mapExistingLoanIdAdditionalDeviation.containsKey(strLoanId) && mapExistingLoanIdAdditionalDeviation.get(strLoanId)!=null && mapExistingLoanIdAdditionalDeviation.get(strLoanId).size()>0){
                for(Deviation__c dev: mapExistingLoanIdAdditionalDeviation.get(strLoanId)){
                    if(objCharge.Charges_Name__c == GlobalConstants.PF_CHARGE && dev.Deviation_Type__c.contains(GlobalConstants.PF_CHARGE)){
                        newDeviation = new Deviation__c();
                        newDeviation.Id = dev.Id;
                        newDeviation.Archived__c = true;                    
                    }else if(objCharge.Charges_Name__c == GlobalConstants.DC_CHARGE && dev.Deviation_Type__c.contains(GlobalConstants.DC_CHARGE)){
                        newDeviation = new Deviation__c();
                        newDeviation.Id = dev.Id;
                        newDeviation.Archived__c = true;                    
                    }else if(objCharge.Charges_Name__c == GlobalConstants.LS_CHARGE && dev.Deviation_Type__c.contains(GlobalConstants.LS_CHARGE)){
                        newDeviation = new Deviation__c();
                        newDeviation.Id = dev.Id;
                        newDeviation.Archived__c = true;                    
                    }
                }      
            }
        }
        return newDeviation;
    }
}