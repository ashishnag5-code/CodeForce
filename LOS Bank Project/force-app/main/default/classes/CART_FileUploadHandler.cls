public with sharing class CART_FileUploadHandler {
    public CART_FileUploadHandler() {

    }

    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        CARTDetailsRequestWrapper cartRequestWrapper = new CARTDetailsRequestWrapper();
        cartRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
        cartRequestWrapper.Source = System.Label.Integration_Channel;//'SFDC';
        cartRequestWrapper.filename = String.valueOf(paramsMap.get('filename'));
        cartRequestWrapper.file = String.valueOf(paramsMap.get('base64'));
        cartRequestWrapper.password = String.valueOf(paramsMap.get('password'));
        cartRequestWrapper.organizationName = 'AUF';
        cartRequestWrapper.accountNumber = '';
        cartRequestWrapper.accountType = '';
        cartRequestWrapper.internal = '';
        cartRequestWrapper.odCcLimit = '';
        lstString.add(JSON.serialize(cartRequestWrapper));   
        return lstString;
    }

    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class CARTDetailsRequestWrapper{
        public String RequestId;
        public String Source;
        public String filename;
        public String file;
        public String password;
        public String organizationName;
        public String accountNumber;
        public String accountType;
        public String internal;
        public String odCcLimit;
    }

    public class CARTDetailsResponseWrapper{
        public String docId;
        public String status;
        public String message;
        public String periodStart;
        public String periodEnd;
        public String documents;
        public String fileName;
        public String uploadTime;
        public String ocrFile;
        public String fileCount;
        public String totalPages;
        public String error;
    }

    public class CARTBankStatementDetailsResponseWrapper{
        public String docId;
        public String status;
        public List<CARTBankStatementDetails> data;
    }

    public class CARTStatementStatus{
        public String status;
        public List<CARTBankStatementDetails> data;

    }

    public class CARTBankStatementDetails{
        public String bankName;
        public String accountNumber;
        public String accountName;
        public String accountType;
        public String periodStart;
        public String periodEnd;
        public CamAnalysisData camAnalysisData;
        public List<AnalysisData> analysisData;

    }

    public class CamAnalysisData{
        public Decimal averageBalance;
        public Decimal averageBalanceLastSixMonths;
        public Decimal averageBalanceLastTwelveMonths;
        List<CamAnalysisMonthly> camAnalysisMonthly;

    }

    public class AnalysisData{
        public MonthlyCreditsDetailsGrandTotalWrapper monthlyCreditsDetailsGrandTotal;
        public MonthlyBalancesDetailsGrandTotalWrapper monthlyBalancesDetailsGrandTotal;
        public List<MonthlyCreditsDetailsWrapper> monthlyCreditsDetails;
        public List<MonthlyBalancesDetailsWrapper> monthlyBalancesDetails;
        /*public String month;
        public Integer noOfCreditTransactions;
        public Decimal creditTransactionsAmount;
        public Integer noOfDebitTransactions;
        public Decimal debitTransactionsAmount;
        public Integer noOfNetCreditTransactions;
        public Decimal netCreditTransactionsAmount;
        public Integer noOfNetDebitTransactions;
        public Decimal netDebitTransactionsAmount;
        public Integer noOfCashWithdrawals;
        public Decimal cashWithdrawalsAmount;
        public Integer noOfATMWithdrawals;
        public Decimal atmWithdrawalsAmount;
        public Integer noOfCashDeposits;
        public Decimal cashDepositsAmount;
        public Integer noOfChequeBounceInward;
        public Decimal chequeBounceInwardAmount;
        public Integer noOfChequeBounceOutward;
        public Decimal chequeBounceOutwardAmount;
        public Integer noOfPaymentBounceInward;
        public Decimal paymentBounceInwardAmount;
        public Integer noOfPaymentBounceOutward;
        public Decimal paymentBounceOutwardAmount;
        public Integer noOfChequeDeposits;

        public Decimal chequeDepositsAmount;
        public Integer noOfChequeIssued;
        public Decimal chequeIssuedAmount;
        public Integer noOfEMI;

        public Decimal totalEMIAmount;
        public Integer noOfEMIBounce;
        public Decimal totalEMIBounceAmount;
        public Integer noOfLoanDisbursal;

        public Decimal loanDisbursalAmount;
        public Decimal otherIncomeAmount;
        public Decimal salaryAmount;
        public Integer noOfMinimumBalanceCharges;

        public Decimal minimumEODBalance;
        public Decimal maximumEODBalance;
        public Decimal averageEODBalance;
        public Integer noOfPenalCharges;

        public Decimal totalPenalChargesAmount;
        public Decimal totalBankChargesAmount;
        public Decimal cashDepositPercentage;
        public Integer noOfBankCharges;
        
        public Decimal totalInterestReceived;
        public Decimal totalInterestPaid;
        public Integer noOfInterestPaid;
        public Integer noOfInterestReceived;
        
        public Decimal totalChequeReturnCharges;
        public Integer noOfChequeReturnCharges;
        public Decimal totalReversalAmount;
        public Integer noOfReversal;
       
        public Decimal totalPaymentBounceCharges;
        public Integer noOfPaymentBounceCharges;
        public Decimal minimumBalance;
        public Decimal maximumBalance;*/
    
    }

    public static AnalysisData parseAnalysisData(String analysisDataResponse){
        String modifiedAnalysisDataResponse = analysisDataResponse!=null?analysisDataResponse:null;
        if(analysisDataResponse!=null)
        if(analysisDataResponse.contains('Month-Year')){
            analysisDataResponse = analysisDataResponse.replace('Month-Year','MonthYear');
        }
        if(analysisDataResponse.contains('Salary Credit')){
            analysisDataResponse=analysisDataResponse.replace('Salary Credit','SalaryCredit');
        }
        if(analysisDataResponse.contains('Average of Custom Day')){
            analysisDataResponse=analysisDataResponse.replace('Average of Custom Day','AverageOfCustomDay');
        }
        AnalysisData response = (AnalysisData) JSON.deserialize(analysisDataResponse, AnalysisData.class);
        system.debug('response '+response);
        return response;
    }

    public class MonthlyCreditsDetailsGrandTotalWrapper{
        public Decimal SalaryCredit;
        public String MonthYear;
        public Decimal Credit;
    }

    public class MonthlyBalancesDetailsGrandTotalWrapper{
        public Decimal averageBalanceOn5th;
        public Decimal averageBalanceOn25th;
        public String MonthYear;
        public Decimal averageBalanceOn20th;
        public Decimal AMB;
        public Decimal averageBalanceOn10th;
        public Decimal AverageOfCustomDay;
        public Decimal averageBalanceOn15th;
        public Decimal averageBalanceOn1st;
    }

    public class MonthlyCreditsDetailsWrapper{
        public Decimal SalaryCredit;
        public String MonthYear;
        public Decimal Credit;
    }

    public class MonthlyBalancesDetailsWrapper{
        public Decimal averageBalanceOn5th;
        public Decimal averageBalanceOn25th;
        public String MonthYear;
        public Decimal averageBalanceOn20th;
        public Decimal AMB;
        public Decimal averageBalanceOn10th;
        public Decimal AverageOfCustomDay;
        public Decimal averageBalanceOn15th;
        public Decimal averageBalanceOn1st;
    }

    public class CamAnalysisMonthly{
        public String month;
    }

}