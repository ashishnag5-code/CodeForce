/* 
 @File Name : AdvancedRecordAssignment.cls 
 @Description :  Assignment of object records to users
 @Author : Mohit M.
 @Last Modified By : 16 Jan 2023
 @Last Modified On :  
 @Modification Log : 
 ============================================================================== 
 Ver        Date          Author       Modification 
 ============================================================================== 
 1.0      Jan 2023        Mohit M       Initial Version
 2.0      July-25-2023    Mohit M       FI assignment correction
*/

public with sharing class AdvancedRecordAssignment {


    public static Boolean isRoundRobin = false;
    public static List<AccountTeamMember> lstAccountTeamMember;
    public static List<Branch_Field_Investigation_Master__c> lstBranchAndFIMapping;

    // Roub Robin Assignment based on Branch and Field Investingator Mapping
    public static List<ZipCodeUserIdWrapper> roundRobingAssigFieldInvestigation(String objectName, Set<String> zipCodeSet, String assignedToField) {
        List<ZipCodeUserIdWrapper> zipUidWrapperList = new List<ZipCodeUserIdWrapper>();
        try{
            Map<String,Set<Id>> zipCodeUserMap = new Map<String,Set<Id>>();
            List<String> fieldValuesList = new List<String>();
            if(zipCodeSet != null){
                Set<Id> userIdsSet = new Set<Id>();
                lstBranchAndFIMapping = lstBranchAndFIMapping != NULL && lstBranchAndFIMapping.size()>0 ? lstBranchAndFIMapping :  new List<Branch_Field_Investigation_Master__c>();
                // OOO
                for (Branch_Field_Investigation_Master__c objBFIM : lstBranchAndFIMapping) {
                    userIdsSet.add(objBFIM.FI_Agent__c);
                }
                Set<Id> outOfOfficeUsers = getOutOfOfficeUsers(userIdsSet);
                userIdsSet.removeAll(outOfOfficeUsers);
            
                for (Branch_Field_Investigation_Master__c objBFIM : lstBranchAndFIMapping) {
                    String strZipCode = objBFIM.Pin_Code__c;
                    if (userIdsSet.contains(objBFIM.FI_Agent__c)){
                        if(zipCodeUserMap.get(strZipCode) == null){
                            zipCodeUserMap.put(strZipCode,new Set<ID>{objBFIM.FI_Agent__c});
                        }else{
                            Set<ID> setUserId = zipCodeUserMap.get(strZipCode);
                            setUserId.add(objBFIM.FI_Agent__c);
                            zipCodeUserMap.put(strZipCode,setUserId);
                        }
                    }
                    
                }
                if (isRoundRobin) {
                    zipUidWrapperList = roundRobinAssignment(zipCodeUserMap,objectName,zipCodeSet,assignedToField);
                }
            }
            return zipUidWrapperList;
        } catch(Exception ex){
            throw ex;
        }
    }

    // Round Robin Assignment based on Account Team Member
    public static List<ZipCodeUserIdWrapper> roundRobingAssigTeamMember(String objectName, Set<String> zipCodeSet, String assignedToField) {
        List<ZipCodeUserIdWrapper> zipUidWrapperList = new List<ZipCodeUserIdWrapper>();
        try{
            Map<String,Set<Id>> zipCodeUserMap = new Map<String,Set<Id>>();
            List<String> fieldValuesList = new List<String>();
            if(zipCodeSet != null){
                Set<Id> userIdsSet = new Set<Id>();
                lstAccountTeamMember = lstAccountTeamMember != NULL && lstAccountTeamMember.size()>0 ? lstAccountTeamMember :  new List<AccountTeamMember>();
                // OOO
                for (AccountTeamMember objATM : lstAccountTeamMember) {
                    userIdsSet.add(objATM.UserId);
                }
                Set<Id> outOfOfficeUsers = getOutOfOfficeUsers(userIdsSet);
                userIdsSet.removeAll(outOfOfficeUsers);
                for (AccountTeamMember objATM : lstAccountTeamMember) {
                    String strZipCode = objATM.Zip_Code__c;
                    if (userIdsSet.contains(objATM.UserId)){
                        if(zipCodeUserMap.get(strZipCode) == null){
                            zipCodeUserMap.put(strZipCode,new Set<ID>{objATM.UserId});
                        }else{
                            Set<ID> setUserId = zipCodeUserMap.get(strZipCode);
                            setUserId.add(objATM.UserId);
                            zipCodeUserMap.put(strZipCode,setUserId);
                        }
                    }
                    
                }
                if (isRoundRobin) {
                    zipUidWrapperList = roundRobinAssignment(zipCodeUserMap,objectName,zipCodeSet,assignedToField);
                }
                else {
                    for (AccountTeamMember objATM : lstAccountTeamMember) {
                        ZipCodeUserIdWrapper objWrapper = new ZipCodeUserIdWrapper();
                        objWrapper.zipCodeAndProduct = objATM.Zip_Code__c;
                        objWrapper.userId = objATM.UserId;
                        zipUidWrapperList.add(objWrapper);
                    }
                }
            }
            System.debug(LoggingLevel.Info, 'No Error '+zipUidWrapperList.size());
            return zipUidWrapperList;
        }catch(Exception ex){
            throw ex;
        }
    }

    /*
    * Purpose - Get the Ownership based on Round Robin
    * Note:- SOQL query will run in FOR Loop due to muliple owners working on different pincode - And will run only max 4 time as Applicant will have maximum 4 Address records  
    */
    public static List<ZipCodeUserIdWrapper> roundRobinAssignment(Map<String,Set<Id>> zipCodeUserMap,String objectName, Set<String> zipCodeSet, String assignedToField) {
        try{
            List<String> fieldValuesList = new List<String>();
            
            Map<String,AggregateResult []> zipCodeUserIdRecList = new Map<String,List<SObject>>();
            Record_Assignment_Setting__mdt ras = Record_Assignment_Setting__mdt.getInstance(objectName);
            String field = ras.Field_Name__c;
            fieldValuesList = ras.Field_Values__c.split(',');
            objectName = ras.Object_Name__c;
            
            List<ZipCodeUserIdWrapper> zipUidWrapperList = new List<ZipCodeUserIdWrapper>();
            Map<String,Map<Id,Integer>> assinedRecdsMap = new Map<String,Map<Id,Integer>>();
            if(objectName != null){
                List<Id> userIds = new List<Id>();
                Set<Id> userIdSet = new Set<Id>();
                Map<Id,Integer> userIdAssignedRecdsMap = new Map<Id,Integer>();
                Map<String,String> mapZCandUserId = new Map<String,String>();
                
                for(String zc : zipCodeUserMap.keySet()){
                    userIds.addAll(zipCodeUserMap.get(zc));
                    userIdSet = zipCodeUserMap.get(zc);
                    for (Id usrId : zipCodeUserMap.get(zc)){
                        mapZCandUserId.put(zc+'-'+usrId,usrId);
                    }
                    String fields = 'SELECT COUNT(Id) AssignedRecords, '+ String.escapeSingleQuotes(assignedToField);
                    String fromObject = ' FROM '+ String.escapeSingleQuotes(objectName);
                    String filter = ' WHERE '+ field + ' IN :fieldValuesList' + ' AND '+ String.escapeSingleQuotes(assignedToField) + ' IN :userIdSet' + ' GROUP BY ' + String.escapeSingleQuotes(assignedToField);
                    //String filter = ' WHERE '+ String.escapeSingleQuotes(assignedToField) + ' IN :userIdSet' + ' GROUP BY ' + String.escapeSingleQuotes(assignedToField);
                    String orderBy = ' ORDER BY COUNT(Id) ASC';
                    String query = fields + fromObject + filter + orderBy;
                    AggregateResult[] recordsList = Database.query(query);
                    for(AggregateResult ar : recordsList){
                        Id uId = String.valueOf(ar.get(assignedToField));
                        Integer i = Integer.valueOf(String.valueOf(ar.get('AssignedRecords')));
                        userIdAssignedRecdsMap.put(uId,i);
                    }
                    
                    for(String zipcodec : mapZCandUserId.keySet()){
                        List<String> lstZC = zipcodec.split('-');
                        if (userIdAssignedRecdsMap.containsKey(lstZC[1])) {
                            assinedRecdsMap.put(lstZC[0],userIdAssignedRecdsMap);
                        }
                        else {
                            Map<Id,Integer> mapUserWithCount = new Map<Id,Integer>();
                            mapUserWithCount.put(lstZC[1],0);
                            assinedRecdsMap.put(lstZC[0],mapUserWithCount);
                        }
                    }
                }
                zipUidWrapperList = getZipProdUserIdMapping(zipCodeSet,assinedRecdsMap);
            }
            return zipUidWrapperList;
        }catch(Exception ex){
            throw ex;
        }
    }

    public static List<ZipCodeUserIdWrapper> getZipProdUserIdMapping(Set<String> zipCodeList, Map<String,Map<Id,Integer>> assignedRecords){
        Integer i = 0;
        List<ZipCodeUserIdWrapper> wrapperList = new List<ZipCodeUserIdWrapper>();
        Map<String,Map<Id,Integer>> assignedRecordsMap = assignedRecords; //Copy of original Assigned records
        //List<ZipCodeUserIdWrapper> zipProdUidWrapperList = new List<ZipCodeUserIdWrapper>();
        for(String zip : zipCodeList){
            Map<Id,Integer> userIdAssignedRecs = assignedRecordsMap.get(zip);
            if(userIdAssignedRecs == null){ // If the zipcode has no assigned users
                ZipCodeUserIdWrapper zUIdWrap = new ZipCodeUserIdWrapper();
                zUIdWrap.zipCodeAndProduct = zip;
                zUIdWrap.userId = null;
                wrapperList.add(zUIdWrap);
            }else{
                List<UserIdCountObjectWrapper> recList = new List<UserIdCountObjectWrapper>();
                for(Id userId : userIdAssignedRecs.keySet()){
                    UserIdCountObjectWrapper.UserIdCountObject wrap = new UserIdCountObjectWrapper.UserIdCountObject();
                    wrap.userId = String.valueOf(userId);
                    wrap.assignedRecordsCount = Integer.valueOf(String.valueOf(userIdAssignedRecs.get(wrap.userId)));
                    recList.add(new UserIdCountObjectWrapper(wrap));
                }
                recList.sort();
                UserIdCountObjectWrapper.UserIdCountObject rec = recList.get(0).obj;
                Integer x =  rec.assignedRecordsCount + 1;
                userIdAssignedRecs.put(rec.userId,x);
                assignedRecordsMap.put(zip,userIdAssignedRecs); // Updating the assignedRecordsMap with the latest increased count

                ZipCodeUserIdWrapper zUIdWrap = new ZipCodeUserIdWrapper();
                zUIdWrap.zipCodeAndProduct = zip;
                zUIdWrap.userId = Id.valueOf(String.valueOf(rec.userId));
                wrapperList.add(zUIdWrap); // Adding the rec to the final result list
                
            }
            i++;
        }
        return wrapperList;
    }

    public static Set<Id> getOutOfOfficeUsers(Set<Id> userIdSet){
        datetime today = datetime.now();
        Set<Id> setOOOUsers = new Set<Id>();
        for(OutOfOffice o : [SELECT UserId
                               FROM OutOfOffice
                              WHERE UserId IN :userIdSet
                                AND StartDate <= today
                                AND EndDate >= today]){
            setOOOUsers.add(o.UserId);
        }
        return setOOOUsers;
    }
    

    public class ZipCodeUserIdWrapper{
        public String zipCodeAndProduct {get; set;}
        public Id userId {get;set;}
    }

    
}