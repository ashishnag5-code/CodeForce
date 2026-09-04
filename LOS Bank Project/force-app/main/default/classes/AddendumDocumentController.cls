public with sharing class AddendumDocumentController {
    public static Id RecordId {get;set;}    
    public static Loan_Application__c loan{get;set;}
    public static Applicant__c applicant {get;set;}   
    public static Collateral__c collateral {get;set;}
    public static User RO{get;set;}
    public static String formattedDate{get;set;}
    public static String selectedDate{get;set;}
    public static Map<Integer, String> numberVsMonth{get;set;}
    public static String firstDayOfInst{get;set;}
    

    public AddendumDocumentController() {
        if(ApexPages.currentPage().getParameters().get('applicationId')!=null){
            RecordId = ApexPages.currentPage().getParameters().get('applicationId');
            selectedDate = ApexPages.currentPage().getParameters().get('selectedEMIDate');
            numberVsMonth = new Map<Integer, String>{1 => 'January', 2 => 'February', 3 => 'March',
                                                    4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July',
                                                    8 => 'August', 9 => 'September', 10 => 'October',
                                                    11 => 'November', 12 => 'December'};

            getLoan();
        }
    }

    public static Loan_Application__c getLoan(){   
        Date todaysDate = Date.today();    
        String query = 'SELECT Id, ROI__c, LC_Code__c,RBP__c, Ops_Status__c,BT_Type__c, Repayment_Mode__c, Esign_Type__c, Total_Charges__c, Emi_Frequency__c, BRE_Decision__c, EMI_Date__c, First_EMI_Date__c, Sourcing_channel__c, Sourcing_Channel_Name__c, Final_Exposure__c, LAN__c, Branch_Master__r.Region__r.Account_Name__c, Pre_Approved_Flag__c, OwnerId, BSR_PSL_Status__c, Mobile__c, Customer_Name__c, Purpose_of_Loan__c, Total_Loan_Amount__c, Vehicle_use__c, Loan_Amount__c, Name, CreatedDate, Scheme__c,Scheme__r.Scheme_Name__c, Application_Id__c,toLabel(Product__c), Wheels_Exposure__c, Branch_Master__r.Business_HUB__r.Account_Name__c,Total_Exposure__c, Application_FI_Status__c, Application_Number__c, Stage__c, Branch_Master__r.Account_Name__c, Branch_Master__r.State__r.Account_Name__C, Dealer_Master__c, Dealer_Master__r.Account_Name__c, Dealer_Master__r.Account_Code__c,Dealer_Master__r.Dealer_Class__c, Dealer_Master__r.State__r.Account_Name__c, Purchase_City__c, Tenure__c, EMI__c,'+
            '(SELECT Customer_Type__c, Constitution_Type__c, Title__c, First_Name__c, Middle_Name__c, Last_Name__c, Customer_Grade__c, Marital_Status__c, Father_Name__c, Spouse_Name__c FROM Applicants__r WHERE RecordType.DeveloperName=\'Primary_Applicant\' AND IsInactive__c=false),'+
            '(SELECT Id, Make__c, LTV__c, Existing_Policy_Type__c, toLabel(Collateral_Name__c), Vehicle_Number__c,Other_Funding_Total__c, Grid_Depreciated_Value__c, DO_Generation_Date__c, SVSH_SVOH__c, Collateral_Type__c, Manufacturer__c, Final_Cost__c, LTV_offered_On_final_cost__c, IBB_Value__c, IDV__c, Vehicle_Category__c,Vehicle_Cost__c, Accessories__c, LS__c, Model__c, Variant__c, Manufacture_year_month__c, Manufacture_Year__c, Fuel_Type__c, Ex_Showroom_Price__c, Discount__c, Net_of_Discount_Price__c, Insurance__c, RTO_Tax_Value__c, On_Road_Price__c, Other_Costs__c, Apportioned_Loan_Amount__c, Customer_equity__c, Approved_LTV__c, LTV_offered_Ex_showroom__c, LTV_offered_On_road__c FROM Collaterals__r WHERE RecordType.Developername in (\'New\',\'Used_Cash_on_Wheels\') Order by CreatedDate Desc Limit 1) '+
            'FROM Loan_Application__c WHERE Id = :RecordId';
            
        loan = Database.query(query);

        applicant = loan.Applicants__r!=null && loan.Applicants__r.size()>0?loan.Applicants__r[0]:new Applicant__c();
        collateral = loan.Collaterals__r!=null && loan.Collaterals__r.size()>0?loan.Collaterals__r[0]:new Collateral__c();

        if(loan.OwnerId.getSObjectType() == Schema.User.getSObjectType()){
            List<User> owners = [SELECT Id, Name, Employee_Code__c, MobilePhone FROM User WHERE Id=:loan.OwnerId];
            if(owners!=null && owners.size()>0){
                RO = owners[0];
            }
        } 
        Date firstEMIDate = (Date) JSON.deserialize(selectedDate, Date.class);
        formattedDate = firstEMIDate.day()+'th of '+numberVsMonth.get(firstEMIDate.month())+' '+firstEMIDate.year();
        firstDayOfInst = String.valueOf(firstEMIDate.day());
        /*if(loan.EMI_Date__c!=null && todaysDate.day()<Integer.valueOf(selectedDate)){
            formattedDate = Integer.valueOf(selectedDate)+'th of '+numberVsMonth.get(todaysDate.month())+' '+todaysDate.year();
            
        }else{
            formattedDate = Integer.valueOf(selectedDate)+'th of '+numberVsMonth.get(todaysDate.addMonths(1).month())+' '+todaysDate.year();
        }*/

        return loan;
    }
}