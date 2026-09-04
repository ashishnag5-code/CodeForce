public without sharing class SIPageController {
    
    public static String loanId;
    public Loan_Application__c loanObj {get;set;}
    public Applicant__c appObj {get;set;}
    public String endDate {get;set;}
    public String todaysDate {get;set;}
    public String fullName {get;set;}
    public List<String> debitAccount {get;set;}
    public SIPageController(){
    
        loanId = System.currentPageReference().getParameters().get('recordid');
        System.debug('loanId*** '+loanId);
        getLADetails();
    }
    public void getLADetails(){
        
        System.debug('loanId*** '+loanId);
        loanObj = [SELECT EMI__c,First_EMI_Date__c,Branch_Name__c,Customer_Name__c,Tenure__c,Loan_Number__c,
                   Application_Number__c,Repayment_Bank_Name__c, Repayment_Account_Number__c,Loan_Amount__c,
                   Loan_Amount_In_Words__c,EMI_Date__c,IFSC_Code__c, SI_Mobile_Number__c  FROM Loan_Application__c
                   WHERE Id=:loanId];
        appObj = [SELECT Mobile_Number__c,Name, First_Name__c ,Last_Name__c  FROM Applicant__c WHERE Loan__c=:loanId AND RecordType.Name='Applicant'];
        //Date emiDate = Date.newInstance(2023, 04, 10); 
        System.debug('appObj *** '+JSON.serializePretty(appObj));
        Date currentDate = Date.today();
        todaysDate = currentDate.year() + '-' + currentDate.month() + '-' + currentDate.day();
        if(appObj!=null)
        fullName = appObj.First_Name__c+' '+appObj.Last_Name__c;
        String debitAccountTemp;
        debitAccount = new List<String>();
        if(!String.isBlank(loanObj.Repayment_Account_Number__c))
        	debitAccountTemp = String.valueOf(loanObj.Repayment_Account_Number__c);//'123456789045678';
        // Convert the string to a list of characters
        for (Integer i = 0; i < debitAccountTemp.length(); i++) {
            debitAccount.add(debitAccountTemp.substring(i, i+1));
        }
        System.debug('debitAccount *** '+JSON.serializePretty(debitAccount));
        if(loanObj.First_EMI_Date__c!=null){
            //Date newDate = Date.parse(loanObj.EMI_Date__c);
            Date newDate;
            /*if(Integer.valueOf(loanObj.EMI_Date__c)<currentDate.day()){
                newDate = Date.newInstance(currentDate.year(), currentDate.month()+1, Integer.valueOf(loanObj.EMI_Date__c));
            }
            else{
                newDate = Date.newInstance(currentDate.year(), currentDate.month(), Integer.valueOf(loanObj.EMI_Date__c));
            }*/
            newDate = loanObj.First_EMI_Date__c;
            loanObj.EMI_Date__c = newDate.format();
            System.debug(newDate);
            endDate = Date.newInstance(newDate.year(),(Integer)(newDate.month()+loanObj.Tenure__c),10).format();
        	System.debug(endDate);
        }
        loanObj.Loan_Amount_In_Words__c = NumberToWord.getNumberTOWord(loanObj.EMI__c);
    }
}