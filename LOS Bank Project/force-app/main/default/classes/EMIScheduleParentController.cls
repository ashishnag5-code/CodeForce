public with sharing class EMIScheduleParentController {
    public static String recordId{get;set;}
    public EMIScheduleParentController() {
        recordId  = ApexPages.CurrentPage().getparameters().get('id');
        PageReference reRend = new PageReference('/apex/EMISchedule');
        reRend.setRedirect(true);
        
    }
    
}