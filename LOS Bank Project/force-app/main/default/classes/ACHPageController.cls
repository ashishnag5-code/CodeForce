/*****
 * Class Name: ACHPageController
 * Test Class: ACHPageControllerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sept-5-2023          -   Mohit M.            -   SFAU-5066 - toDate and endDate
 */
public with sharing class ACHPageController {
    public static String loanId;
    public Loan_Application__c loanObj {get;set;}
    public Applicant__c appObj {get;set;}
    public String endDate {get;set;}
    public String fromDate {get;set;}
    public String today {get;set;}
    public String customerName {get;set;}
    public String referenceOne {get;set;}
    public String referenceTwo {get;set;}
    public List<String> ifscList {get;set;}
    public List<String> accNo {get;set;}
    public ACHPageController(){
        loanId = System.currentPageReference().getParameters().get('recordid');
    }
    public void getLADetails(){
        loanObj = [SELECT Repayment_Bank_Name__c,First_EMI_Date__c, Loan_Amount__c,Repayment_Account_Number__c,Total_Loan_Amount__c,Loan_Amount_In_Words__c,EMI_Date__c,IFSC_Code__c,Tenure__c,Application_Id__c,Repayment_Account_Type__c FROM Loan_Application__c WHERE Id=:loanId];
        appObj = [SELECT Mobile_Number__c,CIF_No__c,First_Name__c,Middle_Name__c,Last_Name__c FROM Applicant__c WHERE Loan__c=:loanId AND RecordType.Name='Applicant'];
        
        Date currentDate = Date.today();
        if(loanObj.First_EMI_Date__c!=null){
            //Date newDate = Date.parse(loanObj.EMI_Date__c);
            Date newDate;
            newDate = loanObj.First_EMI_Date__c;
            // SFAU-5066
            Date toDate = newDate.addYears(30);
            /*if(Integer.valueOf(loanObj.EMI_Date__c)<currentDate.day()){
                newDate = Date.newInstance(currentDate.year(), currentDate.month()+1, Integer.valueOf(loanObj.EMI_Date__c));
            }
            else{
                newDate = Date.newInstance(currentDate.year(), currentDate.month(), Integer.valueOf(loanObj.EMI_Date__c));
            }*/
            //String fromDay= newDate.day() < 10 ? '0'+newDate.day(): String.valueOf(newDate.day());
            fromDate = (newDate.day() < 10 ? ('0'+newDate.day()):String.valueOf(newDate.day())) +'-'+ (newDate.month() < 10 ? ('0'+newDate.month()):String.valueOf(newDate.month()))+'-'+ newDate.year();
            today = (Date.today().day()< 10 ? ('0'+Date.today().day()):String.valueOf(Date.today().day())) +'-'+ (Date.today().month()<10 ? ('0'+Date.today().month()) : String.valueOf(Date.today().month()))+'-'+ Date.today().year();
            System.debug(fromDate);
            Date lastEMIDate=Date.newInstance(newDate.year(), (Integer)(newDate.month()+loanObj.Tenure__c), newDate.day());
            endDate = (lastEMIDate.day() < 10 ? ('0'+lastEMIDate.day()) :String.valueOf(lastEMIDate.day())) +'-'+(lastEMIDate.month() < 10 ? ('0'+lastEMIDate.month()):String.valueOf(lastEMIDate.month()))+'-'+ lastEMIDate.year();
            // SFAU-5066
            endDate = (toDate.day() < 10 ? ('0'+toDate.day()) :String.valueOf(toDate.day())) +'-'+(toDate.month() < 10 ? ('0'+toDate.month()):String.valueOf(toDate.month()))+'-'+ toDate.year(); 
        	System.debug(endDate);
        } 

        if(appObj.First_Name__c!=null){
            customerName = appObj.First_Name__c;
            if(appObj.Middle_Name__c!=null){
                customerName = customerName + ' '+appObj.Middle_Name__c;
            }
            if(appObj.Last_Name__c!=null){
                customerName = customerName + ' ' + appObj.Last_Name__c;
            }
        }
        if(appObj.CIF_No__c!=null){
            referenceTwo = appObj.CIF_No__c;
        }
        referenceOne = loanObj.Application_Id__c;
        if(loanObj.IFSC_Code__c!=null){
            ifscList = loanObj.IFSC_Code__c.split('');
        }
        if(loanObj.Repayment_Account_Number__c!=null){
            accNo = loanObj.Repayment_Account_Number__c.split('');
        }
        loanObj.Loan_Amount_In_Words__c = NumberToWord.getNumberTOWord(loanObj.Total_Loan_Amount__c);
        System.debug('Name '+customerName);
    }
}