public class AUSFLoanApprovalButtonController {

    
    public static loan_Application_Approval__c getCurrentLoanApprover(String loanAppRecordId){
       String approverId = UserInfo.getUserId();
       loan_Application_Approval__c currentLoanApproval;
       for(loan_Application_Approval__c loanAppr :[SELECT Id,Type__c,Approval_Status__c,Is_Assigned_Approver__c FROM Loan_Application_Approval__c 
                                                   WHERE Loan_Application__c=:loanAppRecordId 
                                                   AND Approver__c=:approverId WITH SECURITY_ENFORCED])
       {
           if(loanAppr.Is_Assigned_Approver__c == true && loanAppr.Approval_Status__c=='Pending'){
               system.debug('loanappr');
               currentLoanApproval = loanAppr;
           }/*else if(loanAppr.Is_Assigned_Approver__c = false && loanAppr.Type__c=='Middle'){
               
           }*/           
       }
        
      return currentLoanApproval;
    }
    
    @AuraEnabled
    public static void submitForApproval(String loanAppRecordId,String nextApproverId,String currentApproverId)
    {
        
        approve(currentApproverId,nextApproverId);

        //return appr;
    }
    
    public static void approve(String recordId,String nextApproverId){
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :recordId 
        ];
        system.debug('workItems  '+workItems);
        
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            //Valid values are: Approve, Reject, or Removed. 
            //Only system administrators can specify Removed.
            req.setAction('Approve');
            req.setComments('Your Comment.');
            requests.add(req);
        }
        system.debug('requests  '+requests);
        Approval.ProcessResult[] processResults = Approval.process(requests);
        assignNextApprover(nextApproverId);
    }
    
    public static void assignNextApprover(String nextApproverId){
        system.debug('nextApproverId '+nextApproverId);
        loan_Application_Approval__c nextAppr = new loan_Application_Approval__c();
        nextAppr.Is_Assigned_Approver__c = true;
        nextAppr.Approval_Status__c = 'Pending';
        nextAppr.Id=nextApproverId;
        update nextAppr;
    }
    
    
}