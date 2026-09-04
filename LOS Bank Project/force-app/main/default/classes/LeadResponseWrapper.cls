public with sharing class LeadResponseWrapper {
    public class response{
        //public String dealerCode{get;set;}
        public Boolean success = false;
        public Boolean error = false;
        public String status{get;set;}
        public String loanId{get;set;}
        public String leadId{get;set;}
        public String errormsg {get;set;}
        public List<Applicant> detailsapplicant{get;set;}
        public Vehicle detailsvehicle{get;set;}
        public List<Charge> detailscharge{get;set;}
        public List<DocumentDetail> detailsappdocument{get;set;}
        public Double duration {get;set;}

    }
    public class Applicant{

        public String applicantId{get;set;}
        public String applicanttype{get;set;}
        //public List<Kyc> detailskyc{get;set;}
        public List<Address> detailsaddress{get;set;}
        public List<DocumentDetail> detailsapplicantdocument{get;set;}
        //public Cibil detailscibil{get;set;}
        public Finance detailsfinance{get;set;}
    }
    /*
    public class Kyc{
        
    }
    */
    public class Address{
        public String addresstype{get;set;}
        public String addressid{get;set;}
        public String status {get;set;}
    }
    public class DocumentDetail{
        public String documentId{get;set;}
        public String documentname {get;set;}
        public String status {get;set;}
    }
    /*
    public class Cibil{
        / *
        public String cibilrun{get;set;}
        public String cibilscore{get;set;}
        public String cibildate{get;set;}
        * /
    }
    */
    public class FinanceSalary {
        public String recordid {get;set;}
        public String status {get;set;}
    }

    public class FinanceAssessedNodocument{
        public String recordid {get;set;}
        public String status {get;set;}
    }

    public class FinanceDocumentWithAudit{
        public String recordid {get;set;}
        public String status {get;set;}
    }

    public class FinanceDocumentWithoutAudit{
        public String recordid {get;set;}
        public String status {get;set;}
    }

    public class FinanceAgriOwnorRentLand{
        public String recordid {get;set;}
        public String status {get;set;}
    }

    public class FinanceFarmerCommercial{
        public String recordid {get;set;}
        public String status {get;set;}
    }

    public class FinanceDairyBusiness{
        public String recordid {get;set;}
        public String status {get;set;}
    }

    public class FinanceOtherIncome{
        public String recordid {get;set;}
        public String status {get;set;}
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
        public String recordid {get;set;}
        public String status {get;set;}
    }
    public class Vehicle{
        public String recordid {get;set;}
        public String status {get;set;}
        public List<Valuations> detailsvaluation{get;set;}
    }
    public class Valuations{
        public String recordid {get;set;}
        public String status {get;set;}
    }
    public class Reference{
        /*
        public String name{get;set;}
        public String relation{get;set;}
        public String address{get;set;}
        public String mobileno{get;set;}
        public String isactive {get;set;}
        */
    }
    public class Charge{
        public String recordid {get;set;}
        public String status {get;set;}
    }
    public class Document{
        public String recordid {get;set;}
        public String status {get;set;}
    }
}