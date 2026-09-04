@isTest
public class WelcomeLetterPDFUtilTest {
    testmethod static void mainASCENDING(){
        WelcomeLetterPDFController.EMIScheduleWrapper record = new WelcomeLetterPDFController.EMIScheduleWrapper();
        record.StageNumber =1;
        record.InstallmentCounter =1;
        record.InstallmentStartDate ='1';
        record.InstallmentDate ='1';
        record.InterestRate =1;
        record.PrincipalAmount =1;
        record.InterestAmount =1;
        record.SubsidyAmount =1;
        record.PremiumAmount =1;
        record.ServiceChargeAmount =1;
        record.CapitalizedAmount =1;
        record.PrincipalBalanceAmount =1;
        record.InstallmentAmount =1;
        record.TotalInstallmentAmount =1;
        record.NumberOfDays =1;
        WelcomeLetterPDFUtil obj = new WelcomeLetterPDFUtil(record,WelcomeLetterPDFUtil.SortOrder.ASCENDING);
        WelcomeLetterPDFUtil obj2 = new WelcomeLetterPDFUtil(record,WelcomeLetterPDFUtil.SortOrder.ASCENDING);
        obj.compareTo(obj2);
    }
    testmethod static void mainDESCENDING(){
        WelcomeLetterPDFController.EMIScheduleWrapper record = new WelcomeLetterPDFController.EMIScheduleWrapper();
        record.StageNumber =1;
        record.InstallmentCounter =1;
        record.InstallmentStartDate ='1';
        record.InstallmentDate ='1';
        record.InterestRate =1;
        record.PrincipalAmount =1;
        record.InterestAmount =1;
        record.SubsidyAmount =1;
        record.PremiumAmount =1;
        record.ServiceChargeAmount =1;
        record.CapitalizedAmount =1;
        record.PrincipalBalanceAmount =1;
        record.InstallmentAmount =1;
        record.TotalInstallmentAmount =1;
        record.NumberOfDays =1;
        WelcomeLetterPDFUtil obj = new WelcomeLetterPDFUtil(record,WelcomeLetterPDFUtil.SortOrder.DESCENDING);
        WelcomeLetterPDFUtil obj2 = new WelcomeLetterPDFUtil(record,WelcomeLetterPDFUtil.SortOrder.DESCENDING);
        obj.compareTo(obj2);
    }
    
    testmethod static void sortDESCENDING(){
        WelcomeLetterPDFController.EMIScheduleWrapper record = new WelcomeLetterPDFController.EMIScheduleWrapper();
        record.StageNumber =1;
        record.InstallmentCounter =1;
        record.InstallmentStartDate ='20230102';
        record.InstallmentDate ='2023-01-02';
        record.InterestRate =1;
        record.PrincipalAmount =1;
        record.InterestAmount =1;
        record.SubsidyAmount =1;
        record.PremiumAmount =1;
        record.ServiceChargeAmount =1;
        record.CapitalizedAmount =1;
        record.PrincipalBalanceAmount =1;
        record.InstallmentAmount =1;
        record.TotalInstallmentAmount =1;
        record.NumberOfDays =1;
        
        WelcomeLetterPDFController.EMIScheduleWrapper record2 = new WelcomeLetterPDFController.EMIScheduleWrapper();
        record2.StageNumber =1;
        record2.InstallmentCounter =1;
        record2.InstallmentStartDate ='20230101';
        record2.InstallmentDate ='2023-01-01';
        record2.InterestRate =1;
        record2.PrincipalAmount =1;
        record2.InterestAmount =1;
        record2.SubsidyAmount =1;
        record2.PremiumAmount =1;
        record2.ServiceChargeAmount =1;
        record2.CapitalizedAmount =1;
        record2.PrincipalBalanceAmount =1;
        record2.InstallmentAmount =1;
        record2.TotalInstallmentAmount =1;
        record2.NumberOfDays =1;
        WelcomeLetterPDFUtil.sortRecords(new List<WelcomeLetterPDFController.EMIScheduleWrapper>{record,record2}, WelcomeLetterPDFUtil.SortOrder.DESCENDING);
    }
}