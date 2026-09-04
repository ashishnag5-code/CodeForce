public class VFC_ProcessFieldInvesRecords {
    public List<Field_Investigation__c> selFiLst;
    public String FiIds;

    // Constructor
    public VFC_ProcessFieldInvesRecords(ApexPages.StandardSetController cntlr){
        selFiLst = cntlr.getSelected(); //get selected records from account list view
         FiIds = '';  
         for(Field_Investigation__c fii : selFiLst){
            FiIds += fii.Id + ','; //build list of ids string concatenated with comma                         
          }
          FiIds = FiIds.removeEnd(','); 
    } 

    public PageReference redirectToLC(){
          String returnUrl = '/lightning/cmp/c__ProcessListView?c__listofAccounts='+FiIds;
          PageReference pgReturnPage = new PageReference(returnUrl);
          pgReturnPage.setRedirect(true);
          return pgReturnPage;
    }

}