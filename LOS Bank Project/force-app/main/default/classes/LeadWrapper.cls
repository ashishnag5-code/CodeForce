/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class LeadWrapper {
    public class LeadRecord {
        //public String dealerCode{get;set;}
        public String pinCode{get;set;}
        public String loanId{get;set;}
        public String ownerId{get;set;}
        
        public String productcode{get;set;}
        public String loanpurpose{get;set;}
        public String loannature{get;set;}
        public String branchcode{get;set;}
        public String outletcode{get;set;}
        public String sourcename{get;set;}
        public String sourcechannel{get;set;}
        public String schemename{get;set;}
        public String schemecode{get;set;}
        public String customertype{get;set;}
        public String customername{get;set;}
        public String customermobile{get;set;}
        public Double loanamount{get;set;}
        public String vehicleusage{get;set;}
        public String followupdate{get;set;}
        public String followuptime{get;set;}
        public String campaignname{get;set;}
        //Check public String customerpincode{get;set;}
        public String purchasecity{get;set;}
        public String dealername{get;set;}
        public String outletname{get;set;}
        public String dealercode{get;set;}
        //Removed public String dealercategory{get;set;}
        //Removed public String dealerclass{get;set;}
        //Removed public String dealertype{get;set;}
        //Removed public String dealerphone{get;set;}
        //Removed public String dealeremail{get;set;}
        //Removed public String dealerbank{get;set;}
        //Removed public String beneficiaryaccountnum{get;set;}
        //Removed public String ifsccode{get;set;}
        //Removed public String dsenamepan{get;set;}
        //Removed public String dsmnamepan{get;set;}
        //public String totalloanamount{get;set;}
        public Double totalloanamount{get;set;}
        //public String roi{get;set;}
        public Double roi{get;set;}
        //removed public String flatroi{get;set;}
        //removed public String appliedroi{get;set;}
        public Integer tenure{get;set;}
        public String promocode{get;set;}
        public String lccode{get;set;}
        public String typeofrate{get;set;}
        public String emifrequency{get;set;}
        public String emidate{get;set;}
        public String scheduletype{get;set;}
        public String moratoriumperiod{get;set;}
        public String disbursementcategory{get;set;}
        public String repaymentstartdate{get;set;}
        public String repaymentbankname{get;set;}
        public String repaymentaccountnum{get;set;}
        public String repaymentmode{get;set;}
        public Boolean hasnominee = false;
        public String nomineename{get;set;}
        public String nomineedob{get;set;}
        public String nomineerelationship{get;set;}
        public Double nomineepercentage{get;set;}
        public String nomineecontact{get;set;}
        //removed public String nomineeprofession{get;set;}
        //removed public String stagenovpi{get;set;}
        //removed public String uptoinstallmentnovpi{get;set;}
        //Removed public String installmentamount{get;set;}
        //NotRequired public String riskbasepricing{get;set;}
        public List<Applicant> detailsapplicant{get;set;}
        public Vehicle detailsvehicle{get;set;}
        public List<Reference> detailsreference{get;set;}
        public List<Charge> detailscharge{get;set;}
        public List<DocumentDetail> detailsappdocument{get;set;}
        public String leadsourcechannel {get;set;}
        public String leadsourcename {get;set;}
    }
    public class Applicant{

        public String existingcustomer{get;set;}
        public String applicanttype{get;set;}
        public String dob{get;set;}
        //Removed public String age{get;set;}
        public String aadhaarno{get;set;}
        public String panno{get;set;}
        public String voterid{get;set;}
        public String panform60{get;set;}
        public String drivinglicense{get;set;}
        //Removed public String drivinglicenseexpiry{get;set;}
        public String passportno{get;set;}
        //Removed public String passportexpiry{get;set;}
        public String npr{get;set;}
        public String nrega{get;set;}
        public String panverificationstatus{get;set;}
        // Removed public String auemp{get;set;}
        //Removed public String auempid{get;set;}
        public String title{get;set;}
        public String fname{get;set;}
        public String mname{get;set;}
        public String lname{get;set;}
        public String gender{get;set;}
        public String fathername{get;set;}
        public String mothername{get;set;}
        public String maritialstatus{get;set;}
        public String spousename{get;set;}
        public String highriskprofile{get;set;}
        public String residentstatus{get;set;}
        public String contactmobile{get;set;}
        public String altmobile{get;set;}
        public String contactemailid{get;set;}
        public Boolean emailverified = false;
        public String caste{get;set;}
        public String religion{get;set;}
        public String keyperson{get;set;}
        public String qualification{get;set;}
        public String riskcategory{get;set;}
        public String noofdependent{get;set;}
        public String politicalexposed{get;set;}
        public String relationtype{get;set;}
        public String constype{get;set;}
        public String regno{get;set;}
        public String gstno{get;set;}
        public String udyamno{get;set;}
        public String tinno{get;set;}
        public String cinno{get;set;}
        public String cif{get;set;}
        public String enityname{get;set;}
        public String keycontactname{get;set;}
        public String eastablishdate{get;set;}
        public String physicallychallenge{get;set;}
        public String physicallychallengenature{get;set;}
        public String ckycnumber{get;set;}
        //Removed public String identityproof{get;set;}
        public String customerhinvip{get;set;}
        public String proofdisability{get;set;}
        public String directoridentificationnum{get;set;}
        //Removed public String rco{get;set;}
        //Removed public List<Kyc> detailskyc{get;set;}
        public List<Address> detailsaddress{get;set;}
        public List<DocumentDetail> detailsapplicantdocument{get;set;}
        //Removed public Cibil detailscibil{get;set;}
        public Finance detailsfinance{get;set;}
        
        
        //public List<Object> objApp {get;set;}
        
    }
    public class Kyc{
        public String kyctype{get;set;}
        public String kycstatus{get;set;}
        public String kycdate{get;set;}
        public String idnumber{get;set;}
        public String idexpiry{get;set;}
        public String idfile{get;set;}
        public String verified{get;set;}
    }
    public class Address{
        public String addresstype{get;set;}
        public String addressline1{get;set;}
        public String addressline2{get;set;}
        public String addressline3{get;set;}
        public String areaname{get;set;}
        public String areaytype{get;set;}
        public String city{get;set;}
        public String state{get;set;}
        public String taluka{get;set;}
        public String pincode{get;set;}
        public String district{get;set;}
        public String stability{get;set;}
        //Removed public String firequired{get;set;}
        //Removed public String sameas{get;set;}
        public String landmark{get;set;}
        //Removed public String verified{get;set;}
        public String addresstakenfrom{get;set;}
        public String officeemail{get;set;}
        public String officephone{get;set;}
        public String residentofficetype{get;set;}
        public String residentstatus{get;set;}
    }
    public class DocumentDetail{
        public String documentId{get;set;}
        public String documentname {get;set;}
        public String category{get;set;}
        public String subcategory {get;set;}
        public String documentexpiry {get;set;}
        public String filenumber {get;set;}
        public String documentnumber {get;set;}
        public String type{get;set;}
        public String base64{get;set;}
        public String documentformat{get;set;}
        public String filename {get;set;}
    }
    public class Cibil{
        public String cibilrun{get;set;}
        public String cibilscore{get;set;}
        public String cibildate{get;set;}
    }
    
    public class FinanceSalary {
        public Double firstmonthsalary{get;set;}
        public Double secondmonthsalary{get;set;}
        public Double thirdmonthsalary{get;set;}
        public Double avgsalary{get;set;}
        public String companybusinessname{get;set;}
        public Double monthlygrosssalary{get;set;}
        public Double salaryreceivedbank{get;set;}
        public Double monthlynetsalary{get;set;}
        public Double salaryreceivedcash{get;set;}
    }

    public class FinanceAssessedNodocument{
        public Double monthlyturnover {get;set;}
        public Double annualturnover {get;set;}
        public Double monthlyexpense{get;set;}
        public Double annualexpense{get;set;}
        public String companybusinessname{get;set;}
        public Double monthlynetprofit{get;set;}
        public Double annualnetprofit{get;set;}
    }

    public class FinanceDocumentWithAudit{
        public String companybusinessname{get;set;}
        public String year {get;set;}
        public Double annualturnover {get;set;}
        public Double monthlyturnover {get;set;}
        public Double annualnetprofit {get;set;}
        public Double monthlynetprofit{get;set;}
        public Double annualdepreciation{get;set;}
        public Double monthlydepreciation{get;set;}
        public Double annualinterestonloan{get;set;}
        public Double monthlyinterestonloan{get;set;}
        public Double annualnoncashexpense{get;set;}
        public Double monthlynoncashexpense{get;set;}
        public Double annualtotalincome{get;set;}
        public Double totalmonthlyincome{get;set;}
    }

    public class FinanceDocumentWithoutAudit{
        public Double annualnetprofit {get;set;}
        public Double monthlynetprofit{get;set;}
        public String year {get;set;}
        public String filingdate {get;set;}
    }

    public class FinanceAgriOwnorRentLand{
        public String landType {get;set;}
        public String cropdetails{get;set;}
        public Double marketprice {get;set;}
        public String irrigationsource{get;set;}
        public Double areaundercrop{get;set;}
        public String sowingmonth{get;set;}
        public String harvestmonth{get;set;}
        public Double estimatedyield{get;set;}
        public Double estimatedsalevalue{get;set;}
        public Double netrevenue{get;set;}
    }

    public class FinanceFarmerCommercial{
        public String typeofincome{get;set;}
        public String incomesource{get;set;}
        public String unit{get;set;}
        public Double annualincomeunit{get;set;}
        public String proof{get;set;}
        public String documenttype{get;set;}
        public Double netannualincome{get;set;}
        //Removed public String areaundercropunit{get;set;}
    }

    public class FinanceDairyBusiness{
        public Double noofcattle{get;set;}
        public Double dailymilksupplyltr{get;set;}
        public Double avgsalepriceltr{get;set;}
        public Double dailycollectionrs{get;set;}
        public Double monthlyreceiptrs{get;set;}
        public Double profitmarginpercentage{get;set;}
        public Double monthlynetincome{get;set;}
        public Double anyotherincome{get;set;}
        public Double otherexpense{get;set;}
        public Double totalnetincome{get;set;}
    }

    public class FinanceOtherIncome{
        public String otherincometype{get;set;}
        public String otherifany{get;set;}
        public Double monthlyincome{get;set;}
        public String assessmentmethod{get;set;}
    }

    public class Finance{
        public List<FinanceOtherIncome> finotherIncome {get;set;}
        public List<FinanceDairyBusiness> findairybusiness {get;set;}
        public List<FinanceFarmerCommercial> finfarmercommercial {get;set;}
        public List<FinanceAgriOwnorRentLand> finagriownorrentland {get;set;}
        public List<FinanceDocumentWithoutAudit> findocumentwithoutaudit {get;set;}
        public List<FinanceDocumentWithAudit> findocumentwithaudit {get;set;}
        public List<FinanceAssessedNodocument> finaddresswithoutdocument {get;set;}
        public FinanceSalary finsalary {get;set;}

        //public String financialytype{get;set;}
        public String employmenttype{get;set;} // parent
        public String assessmentmethod{get;set;} // parent
        public String companybusinessname{get;set;} // parent
        public String considerincomeeligible{get;set;} // parent
        public String customergrade{get;set;} // parent
        //public Double totalmonthlyincome{get;set;}
        public Double monthlyincome{get;set;} // parent
        //public Double monthlygrosssalary{get;set;}
        //public Double monthlynetsalary{get;set;}
        //public Double salaryreceivedbank{get;set;}
        //public Double salaryreceivedcash{get;set;}
        //public Double firstmonthsalary{get;set;}
        //public Double secondmonthsalary{get;set;}
        //public Double thirdmonthsalary{get;set;}
        //public Double avgsalary{get;set;}
        //Removed public String currentobligation{get;set;}
        public Double monthlyobligation{get;set;} // parent
        public Double otherincomeamt{get;set;} // parent
        //Removed public String foirpercentage{get;set;}
        public String sector{get;set;} // parent
        public String industry{get;set;} // parent
        public String industrysubtype{get;set;} // parent
        public String occupation{get;set;} // parent
        //public Double monthlyexpense{get;set;}
        //public Double otherexpense{get;set;}
        //public Double monthlynoncashexpene{get;set;}
        //public Double annualexpense{get;set;}
        //public Double annualnoncashexpense{get;set;}
        //Removed public String grossturnoverreceipt{get;set;}
        //Removed public String netprofititr{get;set;}
        //public Double monthlydepreciation{get;set;}
        //public Double annualdepreciation{get;set;}
        //public Double monthlyinterestonloan{get;set;}
        //public Double annualinterestonloan{get;set;}
        //Removed public String othernoncashexpense{get;set;}
        //public String cropdetails{get;set;}
        //Removed public Double msp{get;set;}
        //public String irrigationsource{get;set;}
        //public String areaundercropunit{get;set;}
        //public Double areaundercrop{get;set;}
        //public String sowingmonth{get;set;}
        //public String harvestmonth{get;set;}
        //Removed public Double estimatedyield{get;set;}
        //public Double estimatedsalevalue{get;set;}
        //public Double netrevenue{get;set;}
        //public String typeofincome{get;set;}
        //public String incomesource{get;set;}
        //public String unit{get;set;}
        //public Double annualincomeunit{get;set;}
        //public Double proof{get;set;}
        //public String documenttype{get;set;}
        //public Double netannualincome{get;set;}
        //public Double noofcattle{get;set;}
        //public Double dailymilksupplyltr{get;set;}
        //public Double avgsalepriceltr{get;set;}
        //public Double dailycollectionrs{get;set;}
        //public Double monthlyreceiptrs{get;set;}
        //public Double profitmarginpercentage{get;set;}
        //public Double monthlynetincome{get;set;}
        //public Double anyotherincome{get;set;}
        //public Double totalnetincome{get;set;}
        
        //Removed public String freemonthlycashflow{get;set;}
        //Removed public String proposedemi{get;set;}
        //Removed public String consolidatedobligation{get;set;}
        //Removed public Double totalloanamount{get;set;}
    }
    public class Vehicle{
        public String collateraltype{get;set;}
        //Removed public String product{get;set;}
        public String collateralname{get;set;}
        public String make{get;set;}
        public String model{get;set;}
        public String variant{get;set;}
        public String color{get;set;}
        public String fueltype{get;set;}
        public String vehiclecategory{get;set;}
        public String vehicleusage{get;set;}
        public String vehicleyearmonth{get;set;}
        public String enginecategory{get;set;}
        public Double exshowroomprice{get;set;}
        public Double discount{get;set;}
        public Double netdiscountprice{get;set;}
        public Double insurance{get;set;}
        public String rtotaxes{get;set;}
        public String isrtotax{get;set;}
        public String rtotaxamount{get;set;}
        public String accessoriesfunding{get;set;}
        public String accessories{get;set;}
        public String accessoriesvalue{get;set;}
        public Double othercost{get;set;}
        public String onroadprice{get;set;}
        public Double finalcost{get;set;}
        public String insurancefunding{get;set;}
        public String insurancevalue{get;set;}
        public String isLS{get;set;}
        public String lsamount{get;set;}
        public Double apportionedloanamount{get;set;}
        //Removed public String totalloanamount{get;set;}
        //Removed public String approved_ltv_percentage{get;set;}
        //Removed public String assessmentmethod{get;set;}
        //Removed public String loaneligibility{get;set;}
        //Removed public String customerequity{get;set;}
        //Removed public String approved_customerequity{get;set;}
        //Removed public String ltvoffered_exshowroom_percentage{get;set;}
        //Removed public String ltvoffered_onroad_percentage{get;set;}
        //Removed public String ltvoffered_final_percentage{get;set;}
        public String vehiclenumber{get;set;}
        public String enginenumber{get;set;}
        public String chasisnumber{get;set;}
        //Removed public String manufacturer{get;set;}
        public String kilometer{get;set;}
        public String hpnfinancename{get;set;}
        public String currentowner{get;set;}
        public String ownerserialnum{get;set;}
        public String registrationcity{get;set;}
        //Removed public String svsh_svoh{get;set;}
        public String certifiedvalue{get;set;}
        //Removed public String griddepreciatedvalue{get;set;}
        //Removed public String ibbvalue{get;set;}
        //Removed public String valuationamount{get;set;}
        public String idvinsurancevalue{get;set;}
        public String exitpolicyexp{get;set;}
        public String insuranceexpdate{get;set;}
        public String existpolicy_insurercompany{get;set;}
        public String exist_policytype{get;set;}
        public String made_claim_last_year{get;set;}
        public Double ncb_percentage{get;set;}
        public Double vehiclecost{get;set;}
        public Double finalvehiclecost{get;set;}
        public List<Valuations> detailsvaluation{get;set;}
    }
    public class Valuations{
        public String referenceid{get;set;}
        public String product{get;set;}
        public String collateraltype{get;set;}
        //Removed public String mmv_make{get;set;}
        //Removed public String mmv_model{get;set;}
        //Removed public String mmv_variant{get;set;}
        //Removed public String action{get;set;}
        public String valuename_code{get;set;}
        public String otherstate_masterlist{get;set;}
        public String coordinateforvaluation{get;set;}
        public String contactperson_mobilenumber{get;set;}
        public String allocationdatetime{get;set;}
        public String completiondatetime{get;set;}
        public String vehicle_number{get;set;}
        public String make_model{get;set;}
        public String enginenumber{get;set;}
        public String chasisnumber{get;set;}
        public String manufacture_year{get;set;}
        public String registration_date{get;set;}
        public String ownerserial_number{get;set;}
        public String hypothication{get;set;}
        public String color{get;set;}
        public String odometer{get;set;}
        public String fuel{get;set;}
        public String vehicle_condition{get;set;}
        public Double valuation_amount{get;set;}
        public String final_remarks{get;set;}
    }
    public class Reference{
        public String Name{get;set;}
        public String Address{get;set;}
        public String Relationship_With_Borrower{get;set;} // Posible Values Are - 
        public String Mobile_Number{get;set;}
        public String IsActive {get;set;}
    }
    public class Charge{
        public String valuetype {get;set;}
        public String chargename{get;set;}
        //Removed public Double ratevalueasperpolicy{get;set;}
        public Double actualrate{get;set;}
        public Double chargeamount{get;set;}
        //Removed public Double taxamount{get;set;}
        //Removed public Double totalamount{get;set;}
    }
    

    public List<LeadRecord> leadRecordList;
	public Map<String,String> dealerCodeVsOwner;
	public Map<String,String> pinCodeVsOwner;
    public Map<String,String> mapLeadIdWithOwnerId;
    public Map<String,Account> mapLeadWithBranch;
    public Map<String,String> mapLeadIdWithBranchId;
    public Map<String,String> mapLeadIdDealerId;

    public static LeadWrapper parse(String json) {
		return (LeadWrapper) System.JSON.deserialize(json, LeadWrapper.class);
	}
}