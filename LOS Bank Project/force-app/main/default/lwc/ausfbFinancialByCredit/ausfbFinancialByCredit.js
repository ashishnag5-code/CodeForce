import { LightningElement, track, api, wire } from 'lwc';

import FORM_FACTOR from '@salesforce/client/formFactor';

import {toastWithMessage} from 'c/lwcutilities';

import insertFinancialDetails from '@salesforce/apex/AusfbFinancialByCreditController.insertFinancialDetails';
import getInitialData from '@salesforce/apex/AusfbFinancialByCreditController.getInitialData';
import viewAndEditRight from '@salesforce/apex/AusfbFinancialByCreditController.viewAndEditRight';

const MOBILE_FORM_FACTOR_LITERAL = 'Small';
const TABLET_FORM_FACTOR_LITERAL = 'Medium';
const LAPTOP_FORM_FACTOR_LITERAL = 'Large';

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings

export default class AusfbFinancialByCredit extends LightningElement {

    // From Parent component
    @api applicantId;

    // Spinner Icon
    isLoading = false;

    // SetupConfig flag variables
    formulaFieldOnFormDisable = true;
    isComponentVisible = false;
    isComponentNotEditable = true;
    // SetupConfig flag variables

    // Id of parent applicance finance
    parentApplicantFinanceDetailId;

    // Proposed loan amount value
    proposedLoanAmount = 0;

    // Secured Loan Total fields
    totalPOS = 0;
    totalCountOfMonthFY = 0;
    totalBalanceTenor = 0;
    totalPrincipal = 0;
    // Secured Loan Total fields

    // Latest current year values
    @track currentYearValues = {
        Id : null,
        Applicant__c : this.applicantId,
        capitalFunds: null,
        reservesSurplus : null,
        addLessProfitLossForTheYear : null,
        totalNetworth : null,
        securedLoans : null,
        unsecuredLoansFromFamilyMemberFriendGroupFirm : null,
        unsecuredLoansFromOthers : null,
        bankODCDLimit : null,
        deferredTaxBalance : null,
        currentLiabilityProvisions : null,
        sundryCreditors : null,
        totalLiability : null,
        totalLongTermLiability : null,

        fixedAssets : null,
        investment : null,
        currentAssetsLoansAdvOthers : null,
        debtorsAsInAbove : null,
        totalAssets : null,

        salesIncome : null,
        othersIncome : null,
        totalIncome : null,
        administrativeExpense : null,
        depreciation : null,
        netProfit : null,
        taxExpense : null,
        financeExpense : null,
        cashProfits : null,
        pbdit : null,
        sundryDebitorMoreThanSixMonths : null,
        sundryDebitorLessThanSixMonths : null,
        totalSundryDebitors : null,

        icor : null,
        dscr: null,
        currentRatio : null,
        leverage : null,
        longTermLeverage : null,
        debitorsTurnoverDays : null,
        creditorsTurnoverDays : null,

        changeInNW : null,
        changeTurnover : null,
        changeNetProfit : null,
        changeCashProfit : null,

        strategicNetWorthToBe : null,
        strategicSecuredLoans : null,
        strategicFixedAssets : null,
        strategicTurnover : null,
        strategicPbt : null,
        strategicCashProfit : null,
        strategicYoyTurnoverToBe : null,
        strategicCashProfitOfCurrentYearToBePositive : null,
        strategicdsdrShouldBe : null,
        strategicDebtEquityRatio : null,
        strategicDrsTurnover : null
    };

    // Last year values
    @track lastYearValues = { 
        Id : null,
        Applicant__c : this.applicantId,
        capitalFunds: null,
        reservesSurplus : null,
        addLessProfitLossForTheYear : null,
        totalNetworth : null,
        securedLoans : null,
        unsecuredLoansFromFamilyMemberFriendGroupFirm : null,
        unsecuredLoansFromOthers : null,
        bankODCDLimit : null,
        deferredTaxBalance : null,
        currentLiabilityProvisions : null,
        sundryCreditors : null,
        totalLiability : null,
        totalLongTermLiability : null,

        fixedAssets : null,
        investment : null,
        currentAssetsLoansAdvOthers : null,
        debtorsAsInAbove : null,
        totalAssets : null,

        salesIncome : null,
        othersIncome : null,
        totalIncome : null,
        administrativeExpense : null,
        depreciation : null,
        netProfit : null,
        taxExpense : null,
        financeExpense : null,
        cashProfits : null,
        pbdit : null,
        sundryDebitorMoreThanSixMonths : null,
        sundryDebitorLessThanSixMonths : null,
        totalSundryDebitors : null,

        icor : null,
        dscr: null,
        currentRatio : null,
        leverage : null,
        longTermLeverage : null,
        debitorsTurnoverDays : null,
        creditorsTurnoverDays : null,

        changeInNW : null,
        changeTurnover : null,
        changeNetProfit : null,
        changeCashProfit : null,

        strategicNetWorthToBe : null,
        strategicSecuredLoans : null,
        strategicFixedAssets : null,
        strategicTurnover : null,
        strategicPbt : null,
        strategicCashProfit : null,
        strategicYoyTurnoverToBe : null,
        strategicCashProfitOfCurrentYearToBePositive : null,
        strategicdsdrShouldBe : null,
        strategicDebtEquityRatio : null,
        strategicDrsTurnover : null

    };

    // Last to Last year values
    @track lastToLastYearValues = {
        Id : null,
        Applicant__c : this.applicantId,
        capitalFunds: null,
        reservesSurplus : null,
        addLessProfitLossForTheYear : null,
        totalNetworth : null,
        securedLoans : null,
        unsecuredLoansFromFamilyMemberFriendGroupFirm : null,
        unsecuredLoansFromOthers : null,
        bankODCDLimit : null,
        deferredTaxBalance : null,
        currentLiabilityProvisions : null,
        sundryCreditors : null,
        totalLiability : null,
        totalLongTermLiability : null,

        fixedAssets : null,
        investment : null,
        currentAssetsLoansAdvOthers : null,
        debtorsAsInAbove : null,
        totalAssets : null,

        salesIncome : null,
        othersIncome : null,
        totalIncome : null,
        administrativeExpense : null,
        depreciation : null,
        netProfit : null,
        taxExpense : null,
        financeExpense : null,
        cashProfits : null,
        pbdit : null,
        sundryDebitorMoreThanSixMonths : null,
        sundryDebitorLessThanSixMonths : null,
        totalSundryDebitors : null,

        icor : null,
        dscr: null,
        currentRatio : null,
        leverage : null,
        longTermLeverage : null,
        debitorsTurnoverDays : null,
        creditorsTurnoverDays : null,

        changeInNW : null,
        changeTurnover : null,
        changeNetProfit : null,
        changeCashProfit : null,

        strategicNetWorthToBe : null,
        strategicSecuredLoans : null,
        strategicFixedAssets : null,
        strategicTurnover : null,
        strategicPbt : null,
        strategicCashProfit : null,
        strategicYoyTurnoverToBe : null,
        strategicCashProfitOfCurrentYearToBePositive : null,
        strategicdsdrShouldBe : null,
        strategicDebtEquityRatio : null,
        strategicDrsTurnover : null

    };

    // Default Values setup
    defaultValueSetup(){
        this.currentYearValues = {
            Id : null,
            Applicant__c : this.applicantId,
            capitalFunds: null,
            reservesSurplus : null,
            addLessProfitLossForTheYear : null,
            totalNetworth : null,
            securedLoans : null,
            unsecuredLoansFromFamilyMemberFriendGroupFirm : null,
            unsecuredLoansFromOthers : null,
            bankODCDLimit : null,
            deferredTaxBalance : null,
            currentLiabilityProvisions : null,
            sundryCreditors : null,
            totalLiability : null,
            totalLongTermLiability : null,
    
            fixedAssets : null,
            investment : null,
            currentAssetsLoansAdvOthers : null,
            debtorsAsInAbove : null,
            totalAssets : null,
    
            salesIncome : null,
            othersIncome : null,
            totalIncome : null,
            administrativeExpense : null,
            depreciation : null,
            netProfit : null,
            taxExpense : null,
            financeExpense : null,
            cashProfits : null,
            pbdit : null,
            sundryDebitorMoreThanSixMonths : null,
            sundryDebitorLessThanSixMonths : null,
            totalSundryDebitors : null,
    
            icor : null,
            dscr: null,
            currentRatio : null,
            leverage : null,
            longTermLeverage : null,
            debitorsTurnoverDays : null,
            creditorsTurnoverDays : null,
    
            changeInNW : null,
            changeTurnover : null,
            changeNetProfit : null,
            changeCashProfit : null,
    
            strategicNetWorthToBe : null,
            strategicSecuredLoans : null,
            strategicFixedAssets : null,
            strategicTurnover : null,
            strategicPbt : null,
            strategicCashProfit : null,
            strategicYoyTurnoverToBe : null,
            strategicCashProfitOfCurrentYearToBePositive : null,
            strategicdsdrShouldBe : null,
            strategicDebtEquityRatio : null,
            strategicDrsTurnover : null
        };

        this.lastYearValues = { 
            Id : null,
            Applicant__c : this.applicantId,
            capitalFunds: null,
            reservesSurplus : null,
            addLessProfitLossForTheYear : null,
            totalNetworth : null,
            securedLoans : null,
            unsecuredLoansFromFamilyMemberFriendGroupFirm : null,
            unsecuredLoansFromOthers : null,
            bankODCDLimit : null,
            deferredTaxBalance : null,
            currentLiabilityProvisions : null,
            sundryCreditors : null,
            totalLiability : null,
            totalLongTermLiability : null,
    
            fixedAssets : null,
            investment : null,
            currentAssetsLoansAdvOthers : null,
            debtorsAsInAbove : null,
            totalAssets : null,
    
            salesIncome : null,
            othersIncome : null,
            totalIncome : null,
            administrativeExpense : null,
            depreciation : null,
            netProfit : null,
            taxExpense : null,
            financeExpense : null,
            cashProfits : null,
            pbdit : null,
            sundryDebitorMoreThanSixMonths : null,
            sundryDebitorLessThanSixMonths : null,
            totalSundryDebitors : null,
    
            icor : null,
            dscr: null,
            currentRatio : null,
            leverage : null,
            longTermLeverage : null,
            debitorsTurnoverDays : null,
            creditorsTurnoverDays : null,
    
            changeInNW : null,
            changeTurnover : null,
            changeNetProfit : null,
            changeCashProfit : null,
    
            strategicNetWorthToBe : null,
            strategicSecuredLoans : null,
            strategicFixedAssets : null,
            strategicTurnover : null,
            strategicPbt : null,
            strategicCashProfit : null,
            strategicYoyTurnoverToBe : null,
            strategicCashProfitOfCurrentYearToBePositive : null,
            strategicdsdrShouldBe : null,
            strategicDebtEquityRatio : null,
            strategicDrsTurnover : null
    
        };

        this.lastToLastYearValues = {
            Id : null,
            Applicant__c : this.applicantId,
            capitalFunds: null,
            reservesSurplus : null,
            addLessProfitLossForTheYear : null,
            totalNetworth : null,
            securedLoans : null,
            unsecuredLoansFromFamilyMemberFriendGroupFirm : null,
            unsecuredLoansFromOthers : null,
            bankODCDLimit : null,
            deferredTaxBalance : null,
            currentLiabilityProvisions : null,
            sundryCreditors : null,
            totalLiability : null,
            totalLongTermLiability : null,
    
            fixedAssets : null,
            investment : null,
            currentAssetsLoansAdvOthers : null,
            debtorsAsInAbove : null,
            totalAssets : null,
    
            salesIncome : null,
            othersIncome : null,
            totalIncome : null,
            administrativeExpense : null,
            depreciation : null,
            netProfit : null,
            taxExpense : null,
            financeExpense : null,
            cashProfits : null,
            pbdit : null,
            sundryDebitorMoreThanSixMonths : null,
            sundryDebitorLessThanSixMonths : null,
            totalSundryDebitors : null,
    
            icor : null,
            dscr: null,
            currentRatio : null,
            leverage : null,
            longTermLeverage : null,
            debitorsTurnoverDays : null,
            creditorsTurnoverDays : null,
    
            changeInNW : null,
            changeTurnover : null,
            changeNetProfit : null,
            changeCashProfit : null,
    
            strategicNetWorthToBe : null,
            strategicSecuredLoans : null,
            strategicFixedAssets : null,
            strategicTurnover : null,
            strategicPbt : null,
            strategicCashProfit : null,
            strategicYoyTurnoverToBe : null,
            strategicCashProfitOfCurrentYearToBePositive : null,
            strategicdsdrShouldBe : null,
            strategicDebtEquityRatio : null,
            strategicDrsTurnover : null
    
        };

        this.template.querySelector('c-ausfb-financial-by-credit-secured-loans').getInitialData(null);
        
    }


    // Get initial config data 
    @wire(viewAndEditRight, {applicantId : '$applicantId'})
    configurationData({error, data}){
        this.isLoading = true;
        if(data){
            if(data.visible){
                this.isComponentVisible = true;
                if(data.editable){
                    this.isComponentNotEditable = false;
                }
                this.handleGetInitialData();
            }
            else{
                this.isComponentVisible = false;
            }
        }
        if(error){
            toastWithMessage(this, 'ERROR!', 'error', 'Error fetching configuration data in financial template' + error);
        }
        this.isLoading = false;
    }

    // Assigning parent level information
    handleAssigningParentLevelData = (applicantFinancialList) => {
        this.parentApplicantFinanceDetailId = applicantFinancialList.Id;
        this.template.querySelector('c-ausfb-financial-by-credit-secured-loans').getInitialData(applicantFinancialList.Break_up_of_Secured_loans__c);
    }

     // Return numerical value for formula calculation
     blankOrZeroVal = (value) => {
        if(value && isFinite(value)) return parseFloat(parseFloat(value).toFixed(2));
        return 0;
    }

    // Custom Spinner settings
    async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }
    // Custom Spinner settings

    // Fetching primary applicant finance details
    handleGetInitialData = async () => {
        await this.spinnerImageMethod();
        this.isLoading = true;
        try{
            let applicantFinancialList = await getInitialData({applicantId : this.applicantId});

            this.proposedLoanAmount = applicantFinancialList[0].Applicant__r.Loan__r.Total_Loan_Amount__c;
            this.handleAssigningParentLevelData(applicantFinancialList[0]);

            if(applicantFinancialList.length !== 1){
                this.handleConvertSObjectToValues(applicantFinancialList[1], applicantFinancialList[2], applicantFinancialList[3]);
            }
            else{
                this.defaultValueSetup();
                let dynamicDates = this.handleDateCreation();
                this.currentYearValues.date = dynamicDates[0];
                this.lastYearValues.date = dynamicDates[1];
                this.lastToLastYearValues.date = dynamicDates[2];
            }

        }
        catch(e){
            console.error('Something is wrong ' + e);
            toastWithMessage(this, 'ERROR', 'error', 'Could not fetch financial details : ' + e);
        }
        this.isLoading = false;
    }

    
    // Handle input value change for all input fields on page
    handleInputChange = (event) => {
        try{
            const name = event.target.dataset.name;
            if(event.target.value){
                this[name.split('-')[0]][name.split('-')[1]] = this.blankOrZeroVal(event.target.value);
            }
            else{
                this[name.split('-')[0]][name.split('-')[1]] = null;
            }
            
            this.formulaCalculation();
        }
        catch(e){
            console.log(e);
        }
    }

    // Strategic panel value assignment
    handleAssigningStrategicPanelValues(){

        // Assigning Strategic net worth
        this.currentYearValues.strategicNetWorthToBe = this.blankOrZeroVal(this.currentYearValues.totalNetworth);
        this.lastYearValues.strategicNetWorthToBe = this.blankOrZeroVal(this.lastYearValues.totalNetworth);
        this.lastToLastYearValues.strategicNetWorthToBe = this.blankOrZeroVal(this.lastToLastYearValues.totalNetworth);
        // Assigning Strategic net worth

        // Strategic Secured Loans
        this.currentYearValues.strategicSecuredLoans = this.blankOrZeroVal(this.currentYearValues.securedLoans);
        this.lastYearValues.strategicSecuredLoans = this.blankOrZeroVal(this.lastYearValues.securedLoans);
        this.lastToLastYearValues.strategicSecuredLoans = this.blankOrZeroVal(this.lastToLastYearValues.securedLoans);
        // Strategic Secured Loans

        // Strategic Fixed Assets
        this.currentYearValues.strategicFixedAssets = this.blankOrZeroVal(this.currentYearValues.fixedAssets);
        this.lastYearValues.strategicFixedAssets = this.blankOrZeroVal(this.lastYearValues.fixedAssets);
        this.lastToLastYearValues.strategicFixedAssets = this.blankOrZeroVal(this.lastToLastYearValues.fixedAssets);
        // Strategic Fixed Assets

        // Strategic Turnover
        this.currentYearValues.strategicTurnover = this.blankOrZeroVal(this.currentYearValues.salesIncome);
        this.lastYearValues.strategicTurnover = this.blankOrZeroVal(this.lastYearValues.salesIncome);
        this.lastToLastYearValues.strategicTurnover = this.blankOrZeroVal(this.lastToLastYearValues.salesIncome);
        // Strategic Turnover

        // Strategic PBT
        this.currentYearValues.strategicPbt = this.blankOrZeroVal(this.currentYearValues.netProfit);
        this.lastYearValues.strategicPbt = this.blankOrZeroVal(this.lastYearValues.netProfit);
        this.lastToLastYearValues.strategicPbt = this.blankOrZeroVal(this.lastToLastYearValues.netProfit);
        // Strategic PBT


        // Strategic Strategic cash profits
        this.currentYearValues.strategicCashProfit = this.blankOrZeroVal(this.currentYearValues.cashProfits);
        this.lastYearValues.strategicCashProfit = this.blankOrZeroVal(this.lastYearValues.cashProfits);
        this.lastToLastYearValues.strategicCashProfit = this.blankOrZeroVal(this.lastToLastYearValues.cashProfits);
        // Strategic Strategic cash profits

        // Strategic Strategic cash profits year to be profit
        this.currentYearValues.strategicCashProfitOfCurrentYearToBePositive = this.blankOrZeroVal(this.currentYearValues.strategicCashProfit);
        this.lastYearValues.strategicCashProfitOfCurrentYearToBePositive = this.blankOrZeroVal(this.lastYearValues.strategicCashProfit);
        // Strategic Strategic cash profits year to be profit

        // Strategic Strategic cash profits year to be profit
        this.currentYearValues.strategicdsdrShouldBe = this.blankOrZeroVal(this.currentYearValues.dscr);
        this.lastYearValues.strategicdsdrShouldBe = this.blankOrZeroVal(this.lastYearValues.dscr);
        // Strategic Strategic cash profits year to be profit

        

    }
    // Strategic panel value assignment

    // Formula calculation of all input fields on page
    formulaCalculation = () => {
        // Total Networth
        this.currentYearValues.totalNetworth = 
        this.blankOrZeroVal(this.currentYearValues.capitalFunds) + 
        this.blankOrZeroVal(this.currentYearValues.reservesSurplus) + 
        this.blankOrZeroVal(this.currentYearValues.addLessProfitLossForTheYear);

        this.lastYearValues.totalNetworth = 
        this.blankOrZeroVal(this.lastYearValues.capitalFunds) + 
        this.blankOrZeroVal(this.lastYearValues.reservesSurplus) + 
        this.blankOrZeroVal(this.lastYearValues.addLessProfitLossForTheYear);


        this.lastToLastYearValues.totalNetworth = 
        this.blankOrZeroVal(this.lastToLastYearValues.capitalFunds) + 
        this.blankOrZeroVal(this.lastToLastYearValues.reservesSurplus) + 
        this.blankOrZeroVal(this.lastToLastYearValues.addLessProfitLossForTheYear);


        // Total Liabilities

        this.currentYearValues.totalLiability = 
        this.blankOrZeroVal(this.currentYearValues.securedLoans) + 
        this.blankOrZeroVal(this.currentYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm) + 
        this.blankOrZeroVal(this.currentYearValues.deferredTaxBalance) + 
        this.blankOrZeroVal(this.currentYearValues.currentLiabilityProvisions) + 
        this.blankOrZeroVal(this.currentYearValues.totalNetworth) + 
        this.blankOrZeroVal(this.currentYearValues.unsecuredLoansFromOthers) +
        this.blankOrZeroVal(this.currentYearValues.bankODCDLimit);
        
        this.lastYearValues.totalLiability = 
        this.blankOrZeroVal(this.lastYearValues.securedLoans) + 
        this.blankOrZeroVal(this.lastYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm) + 
        this.blankOrZeroVal(this.lastYearValues.deferredTaxBalance) + 
        this.blankOrZeroVal(this.lastYearValues.currentLiabilityProvisions) +
        this.blankOrZeroVal(this.lastYearValues.totalNetworth) +
        this.blankOrZeroVal(this.lastYearValues.unsecuredLoansFromOthers) +
        this.blankOrZeroVal(this.lastYearValues.bankODCDLimit);

        this.lastToLastYearValues.totalLiability = 
        this.blankOrZeroVal(this.lastToLastYearValues.securedLoans) + 
        this.blankOrZeroVal(this.lastToLastYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm) + 
        this.blankOrZeroVal(this.lastToLastYearValues.deferredTaxBalance) + 
        this.blankOrZeroVal(this.lastToLastYearValues.currentLiabilityProvisions) +
        this.blankOrZeroVal(this.lastToLastYearValues.totalNetworth) +
        this.blankOrZeroVal(this.lastToLastYearValues.unsecuredLoansFromOthers) + 
        this.blankOrZeroVal(this.lastToLastYearValues.bankODCDLimit);


        // Total Long term Liabilities
        
        this.currentYearValues.totalLongTermLiability = 
        this.blankOrZeroVal(this.currentYearValues.securedLoans) + 
        this.blankOrZeroVal(this.currentYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm);
        
        this.lastYearValues.totalLongTermLiability = 
        this.blankOrZeroVal(this.lastYearValues.securedLoans) + 
        this.blankOrZeroVal(this.lastYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm);

        this.lastToLastYearValues.totalLongTermLiability = 
        this.blankOrZeroVal(this.lastToLastYearValues.securedLoans) + 
        this.blankOrZeroVal(this.lastToLastYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm);

        // total assets
        
        this.currentYearValues.totalAssets = 
        this.blankOrZeroVal(this.currentYearValues.fixedAssets) + 
        this.blankOrZeroVal(this.currentYearValues.investment) + 
        this.blankOrZeroVal(this.currentYearValues.currentAssetsLoansAdvOthers);
        
        this.lastYearValues.totalAssets = 
        this.blankOrZeroVal(this.lastYearValues.fixedAssets) + 
        this.blankOrZeroVal(this.lastYearValues.investment) + 
        this.blankOrZeroVal(this.lastYearValues.currentAssetsLoansAdvOthers);

        this.lastToLastYearValues.totalAssets = 
        this.blankOrZeroVal(this.lastToLastYearValues.fixedAssets) + 
        this.blankOrZeroVal(this.lastToLastYearValues.investment) + 
        this.blankOrZeroVal(this.lastToLastYearValues.currentAssetsLoansAdvOthers);

        // total Income 

        this.currentYearValues.totalIncome = 
        this.blankOrZeroVal(this.currentYearValues.salesIncome) + 
        this.blankOrZeroVal(this.currentYearValues.othersIncome);
        
        this.lastYearValues.totalIncome = 
        this.blankOrZeroVal(this.lastYearValues.salesIncome) + 
        this.blankOrZeroVal(this.lastYearValues.othersIncome);

        this.lastToLastYearValues.totalIncome = 
        this.blankOrZeroVal(this.lastToLastYearValues.othersIncome) + 
        this.blankOrZeroVal(this.lastToLastYearValues.salesIncome);

        // Cash Profits (Depreciation+ Net Profit) 

        this.currentYearValues.cashProfits = 
        this.blankOrZeroVal(this.currentYearValues.depreciation) + 
        this.blankOrZeroVal(this.currentYearValues.netProfit);
        
        this.lastYearValues.cashProfits = 
        this.blankOrZeroVal(this.lastYearValues.depreciation) + 
        this.blankOrZeroVal(this.lastYearValues.netProfit);

        this.lastToLastYearValues.cashProfits = 
        this.blankOrZeroVal(this.lastToLastYearValues.depreciation) + 
        this.blankOrZeroVal(this.lastToLastYearValues.netProfit);

        // PBDIT (Profit before depreciation, interest & tax)

        this.currentYearValues.pbdit = 
        this.blankOrZeroVal(this.currentYearValues.depreciation) + 
        this.blankOrZeroVal(this.currentYearValues.netProfit) + 
        this.blankOrZeroVal(this.currentYearValues.taxExpense) + 
        this.blankOrZeroVal(this.currentYearValues.financeExpense);
        
        this.lastYearValues.pbdit = 
        this.blankOrZeroVal(this.lastYearValues.depreciation) + 
        this.blankOrZeroVal(this.lastYearValues.netProfit) + 
        this.blankOrZeroVal(this.lastYearValues.taxExpense) + 
        this.blankOrZeroVal(this.lastYearValues.financeExpense);

        this.lastToLastYearValues.pbdit = 
        this.blankOrZeroVal(this.lastToLastYearValues.depreciation) + 
        this.blankOrZeroVal(this.lastToLastYearValues.netProfit) + 
        this.blankOrZeroVal(this.lastToLastYearValues.taxExpense) + 
        this.blankOrZeroVal(this.lastToLastYearValues.financeExpense);

        // Total Sundry Debtors

        this.currentYearValues.totalSundryDebitors = 
        this.blankOrZeroVal(this.currentYearValues.sundryDebitorLessThanSixMonths) + 
        this.blankOrZeroVal(this.currentYearValues.sundryDebitorMoreThanSixMonths);

        this.lastYearValues.totalSundryDebitors = 
        this.blankOrZeroVal(this.lastYearValues.sundryDebitorLessThanSixMonths) + 
        this.blankOrZeroVal(this.lastYearValues.sundryDebitorMoreThanSixMonths);

        this.lastToLastYearValues.totalSundryDebitors = 
        this.blankOrZeroVal(this.lastToLastYearValues.sundryDebitorLessThanSixMonths) + 
        this.blankOrZeroVal(this.lastToLastYearValues.sundryDebitorMoreThanSixMonths);

        
        // ICOR (Interest coverage ratio)
        this.currentYearValues.icor = 
        this.blankOrZeroVal(
            this.blankOrZeroVal(this.currentYearValues.pbdit) / this.blankOrZeroVal(this.currentYearValues.financeExpense)
        );

        this.lastYearValues.icor = 
        this.blankOrZeroVal(
            this.blankOrZeroVal(this.lastYearValues.pbdit) / (this.blankOrZeroVal(this.lastYearValues.financeExpense))
        );

        // DSCR ( Debt Service Coverage Ratio)
        this.currentYearValues.dscr = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.currentYearValues.pbdit) - 
        this.blankOrZeroVal(this.currentYearValues.taxExpense)) / 
        (this.blankOrZeroVal(this.currentYearValues.financeExpense) + this.blankOrZeroVal(this.totalBalanceTenor)));


        this.lastYearValues.dscr = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.lastYearValues.pbdit) - 
        this.blankOrZeroVal(this.lastYearValues.taxExpense)) / 
        (this.blankOrZeroVal(this.lastYearValues.financeExpense) + this.blankOrZeroVal(this.totalPrincipal)));


        // Current Ratio

        this.currentYearValues.currentRatio = 
        this.blankOrZeroVal(
            this.blankOrZeroVal(this.currentYearValues.currentAssetsLoansAdvOthers) / this.blankOrZeroVal(this.currentYearValues.currentLiabilityProvisions)
        );

        this.lastYearValues.currentRatio = 
        this.blankOrZeroVal(
            this.blankOrZeroVal(this.lastYearValues.currentAssetsLoansAdvOthers) / this.blankOrZeroVal(this.lastYearValues.currentLiabilityProvisions)
        );

        // Leverage

        this.currentYearValues.leverage = 
        this.blankOrZeroVal(
            this.blankOrZeroVal(this.currentYearValues.totalLiability) / 
            (
                this.blankOrZeroVal(this.currentYearValues.totalNetworth) + 
                this.blankOrZeroVal(this.currentYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm)
            )
        );

        this.lastYearValues.leverage = 
        this.blankOrZeroVal(
            this.blankOrZeroVal(this.lastYearValues.totalLiability) / 
            (
                this.blankOrZeroVal(this.lastYearValues.totalNetworth) + 
                this.blankOrZeroVal(this.lastYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm)
            )
        );

        // Long term leverage/Debt Equity Ratio

        this.currentYearValues.longTermLeverage = 
        this.blankOrZeroVal(
            this.blankOrZeroVal(this.currentYearValues.totalLongTermLiability) / 
            (
                this.blankOrZeroVal(this.currentYearValues.totalNetworth) + 
                this.blankOrZeroVal(this.currentYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm)
            )
        );

        this.lastYearValues.longTermLeverage = 
        this.blankOrZeroVal(
            this.blankOrZeroVal(this.lastYearValues.totalLongTermLiability) / 
            (
                this.blankOrZeroVal(this.lastYearValues.totalNetworth) + 
                this.blankOrZeroVal(this.lastYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm)
            )
        );

        // Debtor  Turnover Days

        this.currentYearValues.debitorsTurnoverDays = 
        this.blankOrZeroVal(
            (this.blankOrZeroVal(this.currentYearValues.debtorsAsInAbove) / this.blankOrZeroVal(this.currentYearValues.salesIncome)) *  
            365
        );

        this.lastYearValues.debitorsTurnoverDays = 
        this.blankOrZeroVal(
            (this.blankOrZeroVal(this.lastYearValues.debtorsAsInAbove) / this.blankOrZeroVal(this.lastYearValues.salesIncome)) *
            365
        );

        //Creditor  Turnover Days

        this.currentYearValues.creditorsTurnoverDays = 
        this.blankOrZeroVal(
            (this.blankOrZeroVal(this.currentYearValues.sundryCreditors) / this.blankOrZeroVal(this.currentYearValues.salesIncome)) *  
            365
        );

        this.lastYearValues.creditorsTurnoverDays = 
        this.blankOrZeroVal(
            (this.blankOrZeroVal(this.lastYearValues.sundryCreditors) / this.blankOrZeroVal(this.lastYearValues.salesIncome)) *
            365
        );

        // Change in % NW

        this.currentYearValues.changeInNW = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.currentYearValues.totalNetworth) -  
        this.blankOrZeroVal(this.lastYearValues.totalNetworth)) / 
        this.blankOrZeroVal(this.lastYearValues.totalNetworth));

        this.lastYearValues.changeInNW = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.lastYearValues.totalNetworth) -  
        this.blankOrZeroVal(this.lastToLastYearValues.totalNetworth)) / 
        this.blankOrZeroVal(this.lastToLastYearValues.totalNetworth));

        // Change in % Turnover

        this.currentYearValues.changeTurnover = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.currentYearValues.salesIncome) -  
        this.blankOrZeroVal(this.lastYearValues.salesIncome)) / 
        this.blankOrZeroVal(this.lastYearValues.salesIncome));

        this.lastYearValues.changeTurnover = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.lastYearValues.salesIncome) -  
        this.blankOrZeroVal(this.lastToLastYearValues.salesIncome)) / 
        this.blankOrZeroVal(this.lastToLastYearValues.salesIncome));        

        // Change in % Net Profit

        this.currentYearValues.changeNetProfit = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.currentYearValues.netProfit) -  
        this.blankOrZeroVal(this.lastYearValues.netProfit)) / 
        this.blankOrZeroVal(this.lastYearValues.netProfit));

        this.lastYearValues.changeNetProfit = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.lastYearValues.netProfit) -  
        this.blankOrZeroVal(this.lastToLastYearValues.netProfit)) / 
        this.blankOrZeroVal(this.lastToLastYearValues.netProfit));  

        // Change in % Cash Profit

        this.currentYearValues.changeCashProfit = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.currentYearValues.cashProfits) -  
        this.blankOrZeroVal(this.lastYearValues.cashProfits)) / 
        this.blankOrZeroVal(this.lastYearValues.cashProfits));

        this.lastYearValues.changeCashProfit = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.lastYearValues.cashProfits) -  
        this.blankOrZeroVal(this.lastToLastYearValues.cashProfits)) / 
        this.blankOrZeroVal(this.lastToLastYearValues.cashProfits));  

        this.handleAssigningStrategicPanelValues(); // Assigning strategic panel values

        // YOY Turnover to be +ve

        this.currentYearValues.strategicYoyTurnoverToBe = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.currentYearValues.strategicTurnover) -  
        this.blankOrZeroVal(this.lastYearValues.strategicTurnover)) / 
        this.blankOrZeroVal(this.lastYearValues.strategicTurnover));

        this.lastYearValues.strategicYoyTurnoverToBe = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.lastYearValues.strategicTurnover) -  
        this.blankOrZeroVal(this.lastToLastYearValues.strategicTurnover)) / 
        this.blankOrZeroVal(this.lastToLastYearValues.strategicTurnover));  

        //Debt Equity Ratio {including proposed} to be =< 3 times

        this.currentYearValues.strategicDebtEquityRatio = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.currentYearValues.totalLongTermLiability) +  
        this.blankOrZeroVal(this.proposedLoanAmount)) / 
        (this.blankOrZeroVal(this.currentYearValues.totalNetworth) + this.blankOrZeroVal(this.currentYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm)));

        this.lastYearValues.strategicDebtEquityRatio = 
        this.blankOrZeroVal((this.blankOrZeroVal(this.lastYearValues.totalLongTermLiability) +  
        this.blankOrZeroVal(this.proposedLoanAmount)) / 
        (this.blankOrZeroVal(this.lastYearValues.totalNetworth) + this.blankOrZeroVal(this.lastYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm)));  

        // Drs. Turnover should be </= 90 days

        this.currentYearValues.strategicDrsTurnover = this.blankOrZeroVal(this.currentYearValues.debitorsTurnoverDays);
        

        this.lastYearValues.strategicDrsTurnover = this.blankOrZeroVal(this.lastYearValues.debitorsTurnoverDays);
        
    }

    // Tablet and mobile screen check
    get isMediumAndSmallScreen(){
        if(FORM_FACTOR === TABLET_FORM_FACTOR_LITERAL || FORM_FACTOR === MOBILE_FORM_FACTOR_LITERAL){
            return true;
        }
        return false;
    }

    // Large screen check
    get isLargeScreen(){
        if(FORM_FACTOR === LAPTOP_FORM_FACTOR_LITERAL){
            return true;
        }
        return false;
    }


    // Getting day with month
    get currentYearDateDayMonth(){
        let day;
        let month;
        if(this.currentYearValues.date){
            day = this.currentYearValues.date.split('-')[2];
        }
        if(this.currentYearValues.date){
            month = this.currentYearValues.date.split('-')[1];
        }

        return `${day}-${month}`;
    }
    // Getting day with month

    get yearOptions(){
        const date = new Date();
        let currentYear = date.getFullYear();
        const yearSelection = [];
        if(date.getMonth() < 2){
            currentYear--;
        }
        for(let i = currentYear - 10; i <= currentYear; i++){
            yearSelection.push({
                label : ''+i,
                value : ''+i
            });
        }
        return yearSelection;
    }

    // Year Change for credit for financial audit
    handleRecentYearChange(evt){
        const yearVal = parseFloat(evt.target.value);
        
        const currentYearDateSplit = this.currentYearValues.date.split('-');
        this.currentYearValues.date = `${yearVal}-${currentYearDateSplit[1]}-${currentYearDateSplit[2]}`;
        
        const lastYearDateSplit = this.lastYearValues.date.split('-');
        this.lastYearValues.date = `${yearVal-1}-${lastYearDateSplit[1]}-${lastYearDateSplit[2]}`;
        
        const lastToYearDateSplit = this.lastToLastYearValues.date.split('-');
        this.lastToLastYearValues.date = `${yearVal-2}-${lastToYearDateSplit[1]}-${lastToYearDateSplit[2]}`;
    }
    // Year Change for credit for financial audit


   // Creating dynamic dates
    handleDateCreation = () => {
        const date = new Date();
        let day = '31';
        let month = '03';
        let year = 1999;
        if(date.getMonth() < 3){
            year = date.getFullYear() - 1;
        }
        else{
            year = date.getFullYear();
        }
        

        return [
            year + '-' + month + '-' + (day < 10 ? ('0' + day) : day ),
            (year - 1) + '-' + month + '-' + (day < 10 ? ('0' + day) : day),
            (year - 2) + '-' + month + '-' + (day < 10 ? ('0' + day) : day),
        ];
    }

    // Year dropdown value population
    get yearDropDownPickList(){
        if(this.currentYearValues.date){
            return this.currentYearValues.date.split('-')[0];
        }
        return '';
    }

    // Converting inputs to SObject values
    handleConvertValuesToSObject = () => {

        let currentYearValuesSObject = {
            Id : this.currentYearValues.Id,
            Credit_Financial_Date__c : this.currentYearValues.date,
            Applicant__c : this.applicantId,
            Capital_Funds__c : this.currentYearValues.capitalFunds,
            Reserves_surplus__c : this.currentYearValues.reservesSurplus,
            Add_Less_Profit_Loss_for_the_year__c : this.currentYearValues.addLessProfitLossForTheYear,
            Total_Networth__c : this.currentYearValues.totalNetworth,
            Secured_loans__c : this.currentYearValues.securedLoans,
            Unsecured_loans_from_Family_member_frien__c : this.currentYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm,
            Unsecured_loans_from_Others__c : this.currentYearValues.unsecuredLoansFromOthers,
            Bank_OD_CC_Limits__c : this.currentYearValues.bankODCDLimit,
            Deferred_tax_balance__c : this.currentYearValues.deferredTaxBalance,
            Current_Liability_Provisions__c : this.currentYearValues.currentLiabilityProvisions,
            Sundry_Creditors_in_above__c : this.currentYearValues.sundryCreditors,
            Total_Liabilities__c : this.currentYearValues.totalLiability,
            Total_long_term_liabilities__c : this.currentYearValues.totalLongTermLiability,
            
            Fixed_Assets__c : this.currentYearValues.fixedAssets,
            Investment__c : this.currentYearValues.investment,
            Current_Assets_Loans_Adv_Others__c : this.currentYearValues.currentAssetsLoansAdvOthers,
            Debtors_as_in_Above__c : this.currentYearValues.debtorsAsInAbove,
            Total_Assets__c : this.currentYearValues.totalAssets,
            
            Sales_Income__c : this.currentYearValues.salesIncome,
            Other_Income_Income_not_relevant_to_key__c : this.currentYearValues.othersIncome,
            Total_Income__c : this.currentYearValues.totalIncome,
            Administrative_Expenses__c : this.currentYearValues.administrativeExpense,
            Depreciation__c : this.currentYearValues.depreciation,
            Net_Profit__c : this.currentYearValues.netProfit,
            Tax_Expense__c : this.currentYearValues.taxExpense,
            Financial_Expenses_Interest_on_SL_Ban__c : this.currentYearValues.financeExpense,
            Cash_Profits_Depreciation_Net_Profit__c : this.currentYearValues.cashProfits,
            PBDIT_Profit_before_depreciation_inter__c : this.currentYearValues.pbdit,
            Sundry_Debtors_6_months__c : this.currentYearValues.sundryDebitorMoreThanSixMonths,
            Sundry_Debtors_less_6_months__c : this.currentYearValues.sundryDebitorLessThanSixMonths,
            Total_Sundry_Debtors__c : this.currentYearValues.totalSundryDebitors,
            
            ICOR_Interest_coverage_ratio__c : this.currentYearValues.icor,
            DSCR_Debt_Service_Coverage_Ratio__c : this.currentYearValues.dscr,
            Current_Ratio__c : this.currentYearValues.currentRatio,
            Leverage__c : this.currentYearValues.leverage,
            Long_term_leverage_Debt_Equity_Ratio__c : this.currentYearValues.longTermLeverage,
            Debtor_Turnover_Days__c : this.currentYearValues.debitorsTurnoverDays,
            Creditor_Turnover_Days__c : this.currentYearValues.creditorsTurnoverDays,

            NW__c : this.currentYearValues.changeInNW,
            Turnover__c : this.currentYearValues.changeTurnover,
            Change_Net_Profit__c : this.currentYearValues.changeNetProfit,
            Change_Cash_Profit__c : this.currentYearValues.changeCashProfit,
            
            Net_worth_to_be_ve__c : this.currentYearValues.strategicNetWorthToBe,
            Strategic_Secured_Loans__c : this.currentYearValues.strategicSecuredLoans,
            Strategic_Fixed_Assets__c : this.currentYearValues.strategicFixedAssets,
            Strategic_Turnover__c : this.currentYearValues.strategicTurnover,
            Strategic_PBT__c : this.currentYearValues.strategicPbt,
            Strategic_Cash_Profit__c : this.currentYearValues.strategicCashProfit,
            Strategic_YOY_Turnover_to_be_ve__c : this.currentYearValues.strategicYoyTurnoverToBe,
            Strategic_Cash_Profit_of_current_year_to__c : this.currentYearValues.strategicCashProfitOfCurrentYearToBePositive,
            DSCR_should_be_1_1__c : this.currentYearValues.strategicdsdrShouldBe,
            Strategic_Debt_Equity_Ratio_including_p__c : this.currentYearValues.strategicDebtEquityRatio,
            Strategic_Drs_Turnover_should_be_90__c : this.currentYearValues.strategicDrsTurnover
        };

        let lastYearValuesSObject = {
            Id : this.lastYearValues.Id,
            Credit_Financial_Date__c : this.lastYearValues.date,
            Applicant__c : this.applicantId,
            Capital_Funds__c : this.lastYearValues.capitalFunds,
            Reserves_surplus__c : this.lastYearValues.reservesSurplus,
            Add_Less_Profit_Loss_for_the_year__c : this.lastYearValues.addLessProfitLossForTheYear,
            Total_Networth__c : this.lastYearValues.totalNetworth,
            Secured_loans__c : this.lastYearValues.securedLoans,
            Unsecured_loans_from_Family_member_frien__c : this.lastYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm,
            Unsecured_loans_from_Others__c : this.lastYearValues.unsecuredLoansFromOthers,
            Bank_OD_CC_Limits__c : this.lastYearValues.bankODCDLimit,
            Deferred_tax_balance__c : this.lastYearValues.deferredTaxBalance,
            Current_Liability_Provisions__c : this.lastYearValues.currentLiabilityProvisions,
            Sundry_Creditors_in_above__c : this.lastYearValues.sundryCreditors,
            Total_Liabilities__c : this.lastYearValues.totalLiability,
            Total_long_term_liabilities__c : this.lastYearValues.totalLongTermLiability,
            
            Fixed_Assets__c : this.lastYearValues.fixedAssets,
            Investment__c : this.lastYearValues.investment,
            Current_Assets_Loans_Adv_Others__c : this.lastYearValues.currentAssetsLoansAdvOthers,
            Debtors_as_in_Above__c : this.lastYearValues.debtorsAsInAbove,
            Total_Assets__c : this.lastYearValues.totalAssets,
            
            Sales_Income__c : this.lastYearValues.salesIncome,
            Other_Income_Income_not_relevant_to_key__c : this.lastYearValues.othersIncome,
            Total_Income__c : this.lastYearValues.totalIncome,
            Administrative_Expenses__c : this.lastYearValues.administrativeExpense,
            Depreciation__c : this.lastYearValues.depreciation,
            Net_Profit__c : this.lastYearValues.netProfit,
            Tax_Expense__c : this.lastYearValues.taxExpense,
            Financial_Expenses_Interest_on_SL_Ban__c : this.lastYearValues.financeExpense,
            Cash_Profits_Depreciation_Net_Profit__c : this.lastYearValues.cashProfits,
            PBDIT_Profit_before_depreciation_inter__c : this.lastYearValues.pbdit,
            Sundry_Debtors_6_months__c : this.lastYearValues.sundryDebitorMoreThanSixMonths,
            Sundry_Debtors_less_6_months__c : this.lastYearValues.sundryDebitorLessThanSixMonths,
            Total_Sundry_Debtors__c : this.lastYearValues.totalSundryDebitors,
            
            ICOR_Interest_coverage_ratio__c : this.lastYearValues.icor,
            DSCR_Debt_Service_Coverage_Ratio__c : this.lastYearValues.dscr,
            Current_Ratio__c : this.lastYearValues.currentRatio,
            Leverage__c : this.lastYearValues.leverage,
            Long_term_leverage_Debt_Equity_Ratio__c : this.lastYearValues.longTermLeverage,
            Debtor_Turnover_Days__c : this.lastYearValues.debitorsTurnoverDays,
            Creditor_Turnover_Days__c : this.lastYearValues.creditorsTurnoverDays,

            NW__c : this.lastYearValues.changeInNW,
            Turnover__c : this.lastYearValues.changeTurnover,
            Change_Net_Profit__c : this.lastYearValues.changeNetProfit,
            Change_Cash_Profit__c : this.lastYearValues.changeCashProfit,
            
            Net_worth_to_be_ve__c : this.lastYearValues.strategicNetWorthToBe,
            Strategic_Secured_Loans__c : this.lastYearValues.strategicSecuredLoans,
            Strategic_Fixed_Assets__c : this.lastYearValues.strategicFixedAssets,
            Strategic_Turnover__c : this.lastYearValues.strategicTurnover,
            Strategic_PBT__c : this.lastYearValues.strategicPbt,
            Strategic_Cash_Profit__c : this.lastYearValues.strategicCashProfit,
            Strategic_YOY_Turnover_to_be_ve__c : this.lastYearValues.strategicYoyTurnoverToBe,
            Strategic_Cash_Profit_of_current_year_to__c : this.lastYearValues.strategicCashProfitOfCurrentYearToBePositive,
            DSCR_should_be_1_1__c : this.lastYearValues.strategicdsdrShouldBe,
            Strategic_Debt_Equity_Ratio_including_p__c : this.lastYearValues.strategicDebtEquityRatio,
            Strategic_Drs_Turnover_should_be_90__c : this.lastYearValues.strategicDrsTurnover
        };

        let lastToLastYearValuesSObject = {
            Id : this.lastToLastYearValues.Id,
            Credit_Financial_Date__c : this.lastToLastYearValues.date,
            Applicant__c : this.applicantId,
            Capital_Funds__c : this.lastToLastYearValues.capitalFunds,
            Reserves_surplus__c : this.lastToLastYearValues.reservesSurplus,
            Add_Less_Profit_Loss_for_the_year__c : this.lastToLastYearValues.addLessProfitLossForTheYear,
            Total_Networth__c : this.lastToLastYearValues.totalNetworth,
            Secured_loans__c : this.lastToLastYearValues.securedLoans,
            Unsecured_loans_from_Family_member_frien__c : this.lastToLastYearValues.unsecuredLoansFromFamilyMemberFriendGroupFirm,
            Unsecured_loans_from_Others__c : this.lastToLastYearValues.unsecuredLoansFromOthers,
            Bank_OD_CC_Limits__c : this.lastToLastYearValues.bankODCDLimit,
            Deferred_tax_balance__c : this.lastToLastYearValues.deferredTaxBalance,
            Current_Liability_Provisions__c : this.lastToLastYearValues.currentLiabilityProvisions,
            Sundry_Creditors_in_above__c : this.lastToLastYearValues.sundryCreditors,
            Total_Liabilities__c : this.lastToLastYearValues.totalLiability,
            Total_long_term_liabilities__c : this.lastToLastYearValues.totalLongTermLiability,
            
            Fixed_Assets__c : this.lastToLastYearValues.fixedAssets,
            Investment__c : this.lastToLastYearValues.investment,
            Current_Assets_Loans_Adv_Others__c : this.lastToLastYearValues.currentAssetsLoansAdvOthers,
            Debtors_as_in_Above__c : this.lastToLastYearValues.debtorsAsInAbove,
            Total_Assets__c : this.lastToLastYearValues.totalAssets,
            
            Sales_Income__c : this.lastToLastYearValues.salesIncome,
            Other_Income_Income_not_relevant_to_key__c : this.lastToLastYearValues.othersIncome,
            Total_Income__c : this.lastToLastYearValues.totalIncome,
            Administrative_Expenses__c : this.lastToLastYearValues.administrativeExpense,
            Depreciation__c : this.lastToLastYearValues.depreciation,
            Net_Profit__c : this.lastToLastYearValues.netProfit,
            Tax_Expense__c : this.lastToLastYearValues.taxExpense,
            Financial_Expenses_Interest_on_SL_Ban__c : this.lastToLastYearValues.financeExpense,
            Cash_Profits_Depreciation_Net_Profit__c : this.lastToLastYearValues.cashProfits,
            PBDIT_Profit_before_depreciation_inter__c : this.lastToLastYearValues.pbdit,
            Sundry_Debtors_6_months__c : this.lastToLastYearValues.sundryDebitorMoreThanSixMonths,
            Sundry_Debtors_less_6_months__c : this.lastToLastYearValues.sundryDebitorLessThanSixMonths,
            Total_Sundry_Debtors__c : this.lastToLastYearValues.totalSundryDebitors,
            
            ICOR_Interest_coverage_ratio__c : this.lastToLastYearValues.icor,
            DSCR_Debt_Service_Coverage_Ratio__c : this.lastToLastYearValues.dscr,
            Current_Ratio__c : this.lastToLastYearValues.currentRatio,
            Leverage__c : this.lastToLastYearValues.leverage,
            Long_term_leverage_Debt_Equity_Ratio__c : this.lastToLastYearValues.longTermLeverage,
            Debtor_Turnover_Days__c : this.lastToLastYearValues.debitorsTurnoverDays,
            Creditor_Turnover_Days__c : this.lastToLastYearValues.creditorsTurnoverDays,

            NW__c : this.lastToLastYearValues.changeInNW,
            Turnover__c : this.lastToLastYearValues.changeTurnover,
            Change_Net_Profit__c : this.lastToLastYearValues.changeNetProfit,
            Change_Cash_Profit__c : this.lastToLastYearValues.changeCashProfit,
            
            Net_worth_to_be_ve__c : this.lastToLastYearValues.strategicNetWorthToBe,
            Strategic_Secured_Loans__c : this.lastToLastYearValues.strategicSecuredLoans,
            Strategic_Fixed_Assets__c : this.lastToLastYearValues.strategicFixedAssets,
            Strategic_Turnover__c : this.lastToLastYearValues.strategicTurnover,
            Strategic_PBT__c : this.lastToLastYearValues.strategicPbt,
            Strategic_Cash_Profit__c : this.lastToLastYearValues.strategicCashProfit,
            Strategic_YOY_Turnover_to_be_ve__c : this.lastToLastYearValues.strategicYoyTurnoverToBe,
            Strategic_Cash_Profit_of_current_year_to__c : this.lastToLastYearValues.strategicCashProfitOfCurrentYearToBePositive,
            DSCR_should_be_1_1__c : this.lastToLastYearValues.strategicdsdrShouldBe,
            Strategic_Debt_Equity_Ratio_including_p__c : this.lastToLastYearValues.strategicDebtEquityRatio,
            Strategic_Drs_Turnover_should_be_90__c : this.lastToLastYearValues.strategicDrsTurnover
        };

        return [currentYearValuesSObject, lastYearValuesSObject, lastToLastYearValuesSObject];
        
    }


    // Convert fetched data from DB to js objects
    handleConvertSObjectToValues = (financeCurrentYear, financeLastYear, financeLastToLastYear) => {

        let dynamicDates = this.handleDateCreation();
        
        this.currentYearValues = {
            Id : financeCurrentYear.Id,
            date : financeCurrentYear.Id === null ? dynamicDates[0] : financeCurrentYear.Credit_Financial_Date__c,
            capitalFunds : financeCurrentYear.Capital_Funds__c ,
            reservesSurplus : financeCurrentYear.Reserves_surplus__c,
            addLessProfitLossForTheYear : financeCurrentYear.Add_Less_Profit_Loss_for_the_year__c,
            totalNetworth  : financeCurrentYear.Total_Networth__c,
            securedLoans : financeCurrentYear.Secured_loans__c,
            unsecuredLoansFromFamilyMemberFriendGroupFirm : financeCurrentYear.Unsecured_loans_from_Family_member_frien__c,
            unsecuredLoansFromOthers : financeCurrentYear.Unsecured_loans_from_Others__c,
            bankODCDLimit : financeCurrentYear.Bank_OD_CC_Limits__c,
            deferredTaxBalance : financeCurrentYear.Deferred_tax_balance__c,
            currentLiabilityProvisions : financeCurrentYear.Current_Liability_Provisions__c,
            sundryCreditors : financeCurrentYear.Sundry_Creditors_in_above__c,
            totalLiability : financeCurrentYear.Total_Liabilities__c,
            totalLongTermLiability : financeCurrentYear.Total_long_term_liabilities__c,
            
            fixedAssets : financeCurrentYear.Fixed_Assets__c,
            investment : financeCurrentYear.Investment__c,
            currentAssetsLoansAdvOthers : financeCurrentYear.Current_Assets_Loans_Adv_Others__c,
            debtorsAsInAbove : financeCurrentYear.Debtors_as_in_Above__c,
            totalAssets : financeCurrentYear.Total_Assets__c,
            
            salesIncome : financeCurrentYear.Sales_Income__c,
            othersIncome : financeCurrentYear.Other_Income_Income_not_relevant_to_key__c,
            totalIncome : financeCurrentYear.Total_Income__c,
            administrativeExpense : financeCurrentYear.Administrative_Expenses__c,
            depreciation : financeCurrentYear.Depreciation__c,
            netProfit : financeCurrentYear.Net_Profit__c,
            taxExpense : financeCurrentYear.Tax_Expense__c,
            financeExpense : financeCurrentYear.Financial_Expenses_Interest_on_SL_Ban__c,
            cashProfits : financeCurrentYear.Cash_Profits_Depreciation_Net_Profit__c,
            pbdit : financeCurrentYear.PBDIT_Profit_before_depreciation_inter__c,
            sundryDebitorMoreThanSixMonths : financeCurrentYear.Sundry_Debtors_6_months__c,
            sundryDebitorLessThanSixMonths : financeCurrentYear.Sundry_Debtors_less_6_months__c,
            totalSundryDebitors : financeCurrentYear.Total_Sundry_Debtors__c,
            
            icor : financeCurrentYear.ICOR_Interest_coverage_ratio__c,
            dscr : financeCurrentYear.DSCR_Debt_Service_Coverage_Ratio__c,
            currentRatio : financeCurrentYear.Current_Ratio__c,
            leverage : financeCurrentYear.Leverage__c,
            longTermLeverage : financeCurrentYear.Long_term_leverage_Debt_Equity_Ratio__c,
            debitorsTurnoverDays : financeCurrentYear.Debtor_Turnover_Days__c,
            creditorsTurnoverDays : financeCurrentYear.Creditor_Turnover_Days__c,

            changeInNW : financeCurrentYear.NW__c,
            changeTurnover : financeCurrentYear.Turnover__c,
            changeNetProfit : financeCurrentYear.Change_Net_Profit__c,
            changeCashProfit : financeCurrentYear.Change_Cash_Profit__c,
            
            strategicNetWorthToBe : financeCurrentYear.Net_worth_to_be_ve__c,
            strategicSecuredLoans : financeCurrentYear.Strategic_Secured_Loans__c,
            strategicFixedAssets : financeCurrentYear.Strategic_Fixed_Assets__c,
            strategicTurnover : financeCurrentYear.Strategic_Turnover__c,
            strategicPbt : financeCurrentYear.Strategic_PBT__c,
            strategicCashProfit : financeCurrentYear.Strategic_Cash_Profit__c,
            strategicYoyTurnoverToBe : financeCurrentYear.Strategic_YOY_Turnover_to_be_ve__c,
            strategicCashProfitOfCurrentYearToBePositive : financeCurrentYear.Strategic_Cash_Profit_of_current_year_to__c,
            strategicdsdrShouldBe : financeCurrentYear.DSCR_should_be_1_1__c,
            strategicDebtEquityRatio : financeCurrentYear.Strategic_Debt_Equity_Ratio_including_p__c,
            strategicDrsTurnover : financeCurrentYear.Strategic_Drs_Turnover_should_be_90__c
        };
        
        this.lastYearValues = {
            Id : financeLastYear.Id,
            date : financeLastYear.Id === null ? dynamicDates[1] : financeLastYear.Credit_Financial_Date__c,
            capitalFunds : financeLastYear.Capital_Funds__c ,
            reservesSurplus : financeLastYear.Reserves_surplus__c,
            addLessProfitLossForTheYear : financeLastYear.Add_Less_Profit_Loss_for_the_year__c,
            totalNetworth  : financeLastYear.Total_Networth__c,
            securedLoans : financeLastYear.Secured_loans__c,
            unsecuredLoansFromFamilyMemberFriendGroupFirm : financeLastYear.Unsecured_loans_from_Family_member_frien__c,
            unsecuredLoansFromOthers : financeLastYear.Unsecured_loans_from_Others__c,
            bankODCDLimit : financeLastYear.Bank_OD_CC_Limits__c,
            deferredTaxBalance : financeLastYear.Deferred_tax_balance__c,
            currentLiabilityProvisions : financeLastYear.Current_Liability_Provisions__c,
            sundryCreditors : financeLastYear.Sundry_Creditors_in_above__c,
            totalLiability : financeLastYear.Total_Liabilities__c,
            totalLongTermLiability : financeLastYear.Total_long_term_liabilities__c,
            
            fixedAssets : financeLastYear.Fixed_Assets__c,
            investment : financeLastYear.Investment__c,
            currentAssetsLoansAdvOthers : financeLastYear.Current_Assets_Loans_Adv_Others__c,
            debtorsAsInAbove : financeLastYear.Debtors_as_in_Above__c,
            totalAssets : financeLastYear.Total_Assets__c,
            
            salesIncome : financeLastYear.Sales_Income__c,
            othersIncome : financeLastYear.Other_Income_Income_not_relevant_to_key__c,
            totalIncome : financeLastYear.Total_Income__c,
            administrativeExpense : financeLastYear.Administrative_Expenses__c,
            depreciation : financeLastYear.Depreciation__c,
            netProfit : financeLastYear.Net_Profit__c,
            taxExpense : financeLastYear.Tax_Expense__c,
            financeExpense : financeLastYear.Financial_Expenses_Interest_on_SL_Ban__c,
            cashProfits : financeLastYear.Cash_Profits_Depreciation_Net_Profit__c,
            pbdit : financeLastYear.PBDIT_Profit_before_depreciation_inter__c,
            sundryDebitorMoreThanSixMonths : financeLastYear.Sundry_Debtors_6_months__c,
            sundryDebitorLessThanSixMonths : financeLastYear.Sundry_Debtors_less_6_months__c,
            totalSundryDebitors : financeLastYear.Total_Sundry_Debtors__c,
            
            icor : financeLastYear.ICOR_Interest_coverage_ratio__c,
            dscr : financeLastYear.DSCR_Debt_Service_Coverage_Ratio__c,
            currentRatio : financeLastYear.Current_Ratio__c,
            leverage : financeLastYear.Leverage__c,
            longTermLeverage : financeLastYear.Long_term_leverage_Debt_Equity_Ratio__c,
            debitorsTurnoverDays : financeLastYear.Debtor_Turnover_Days__c,
            creditorsTurnoverDays : financeLastYear.Creditor_Turnover_Days__c,

            changeInNW : financeLastYear.NW__c,
            changeTurnover : financeLastYear.Turnover__c,
            changeNetProfit : financeLastYear.Change_Net_Profit__c,
            changeCashProfit : financeLastYear.Change_Cash_Profit__c,
            
            strategicNetWorthToBe : financeLastYear.Net_worth_to_be_ve__c,
            strategicSecuredLoans : financeLastYear.Strategic_Secured_Loans__c,
            strategicFixedAssets : financeLastYear.Strategic_Fixed_Assets__c,
            strategicTurnover : financeLastYear.Strategic_Turnover__c,
            strategicPbt : financeLastYear.Strategic_PBT__c,
            strategicCashProfit : financeLastYear.Strategic_Cash_Profit__c,
            strategicYoyTurnoverToBe : financeLastYear.Strategic_YOY_Turnover_to_be_ve__c,
            strategicCashProfitOfCurrentYearToBePositive : financeLastYear.Strategic_Cash_Profit_of_current_year_to__c,
            strategicdsdrShouldBe : financeLastYear.DSCR_should_be_1_1__c,
            strategicDebtEquityRatio : financeLastYear.Strategic_Debt_Equity_Ratio_including_p__c,
            strategicDrsTurnover : financeLastYear.Strategic_Drs_Turnover_should_be_90__c
        };

        this.lastToLastYearValues = {
            Id : financeLastToLastYear.Id,
            date : financeLastToLastYear.Id === null ? dynamicDates[2] : financeLastToLastYear.Credit_Financial_Date__c,
            capitalFunds : financeLastToLastYear.Capital_Funds__c ,
            reservesSurplus : financeLastToLastYear.Reserves_surplus__c,
            addLessProfitLossForTheYear : financeLastToLastYear.Add_Less_Profit_Loss_for_the_year__c,
            totalNetworth  : financeLastToLastYear.Total_Networth__c,
            securedLoans : financeLastToLastYear.Secured_loans__c,
            unsecuredLoansFromFamilyMemberFriendGroupFirm : financeLastToLastYear.Unsecured_loans_from_Family_member_frien__c,
            unsecuredLoansFromOthers : financeLastToLastYear.Unsecured_loans_from_Others__c,
            bankODCDLimit : financeLastToLastYear.Bank_OD_CC_Limits__c,
            deferredTaxBalance : financeLastToLastYear.Deferred_tax_balance__c,
            currentLiabilityProvisions : financeLastToLastYear.Current_Liability_Provisions__c,
            sundryCreditors : financeLastToLastYear.Sundry_Creditors_in_above__c,
            totalLiability : financeLastToLastYear.Total_Liabilities__c,
            totalLongTermLiability : financeLastToLastYear.Total_long_term_liabilities__c,
            
            fixedAssets : financeLastToLastYear.Fixed_Assets__c,
            investment : financeLastToLastYear.Investment__c,
            currentAssetsLoansAdvOthers : financeLastToLastYear.Current_Assets_Loans_Adv_Others__c,
            debtorsAsInAbove : financeLastToLastYear.Debtors_as_in_Above__c,
            totalAssets : financeLastToLastYear.Total_Assets__c,
            
            salesIncome : financeLastToLastYear.Sales_Income__c,
            othersIncome : financeLastToLastYear.Other_Income_Income_not_relevant_to_key__c,
            totalIncome : financeLastToLastYear.Total_Income__c,
            administrativeExpense : financeLastToLastYear.Administrative_Expenses__c,
            depreciation : financeLastToLastYear.Depreciation__c,
            netProfit : financeLastToLastYear.Net_Profit__c,
            taxExpense : financeLastToLastYear.Tax_Expense__c,
            financeExpense : financeLastToLastYear.Financial_Expenses_Interest_on_SL_Ban__c,
            cashProfits : financeLastToLastYear.Cash_Profits_Depreciation_Net_Profit__c,
            pbdit : financeLastToLastYear.PBDIT_Profit_before_depreciation_inter__c,
            sundryDebitorMoreThanSixMonths : financeLastToLastYear.Sundry_Debtors_6_months__c,
            sundryDebitorLessThanSixMonths : financeLastToLastYear.Sundry_Debtors_less_6_months__c,
            totalSundryDebitors : financeLastToLastYear.Total_Sundry_Debtors__c,
            
            icor : financeLastToLastYear.ICOR_Interest_coverage_ratio__c,
            dscr : financeLastToLastYear.DSCR_Debt_Service_Coverage_Ratio__c,
            currentRatio : financeLastToLastYear.Current_Ratio__c,
            leverage : financeLastToLastYear.Leverage__c,
            longTermLeverage : financeLastToLastYear.Long_term_leverage_Debt_Equity_Ratio__c,
            debitorsTurnoverDays : financeLastToLastYear.Debtor_Turnover_Days__c,
            creditorsTurnoverDays : financeLastToLastYear.Creditor_Turnover_Days__c,

            changeInNW : financeLastToLastYear.NW__c,
            changeTurnover : financeLastToLastYear.Turnover__c,
            changeNetProfit : financeLastToLastYear.Change_Net_Profit__c,
            changeCashProfit : financeLastToLastYear.Change_Cash_Profit__c,
            
            strategicNetWorthToBe : financeLastToLastYear.Net_worth_to_be_ve__c,
            strategicSecuredLoans : financeLastToLastYear.Strategic_Secured_Loans__c,
            strategicFixedAssets : financeLastToLastYear.Strategic_Fixed_Assets__c,
            strategicTurnover : financeLastToLastYear.Strategic_Turnover__c,
            strategicPbt : financeLastToLastYear.Strategic_PBT__c,
            strategicCashProfit : financeLastToLastYear.Strategic_Cash_Profit__c,
            strategicYoyTurnoverToBe : financeLastToLastYear.Strategic_YOY_Turnover_to_be_ve__c,
            strategicCashProfitOfCurrentYearToBePositive : financeLastToLastYear.Strategic_Cash_Profit_of_current_year_to__c,
            strategicdsdrShouldBe : financeLastToLastYear.DSCR_should_be_1_1__c,
            strategicDebtEquityRatio : financeLastToLastYear.Strategic_Debt_Equity_Ratio_including_p__c,
            strategicDrsTurnover : financeLastToLastYear.Strategic_Drs_Turnover_should_be_90__c
        };


    }
    
    // Function to check if any year data is filled or not
    handleCheckIfAnyYearIsFilled = () => {
        const automatedInputFields = new Set([
            'Id',
            'date',
            'Applicant__c'
        ]);
        
        for(let i in this.currentYearValues){
            if(!automatedInputFields.has(i) && this.currentYearValues[i]){
                return true;
            }
        }
        for(let i in this.lastYearValues){
            if(!automatedInputFields.has(i) && this.lastYearValues[i]){
                return true;
            }
        }
        for(let i in this.lastToLastYearValues){
            if(!automatedInputFields.has(i) && this.lastToLastYearValues[i]){
                return true;
            }
        }

        return false;
    }


    // Saving form data
    @api handleSaveOperation = async () => {
        
        if(!this.isComponentVisible || this.isComponentNotEditable){
            return true;
        }
        try{
            if(!this.template.querySelector('c-ausfb-financial-by-credit-secured-loans').validationCheck()){
                return false;
            }
            this.isLoading = true;
            let applicantFinancial = this.handleConvertValuesToSObject();

            let securedLoansJSON = this.template.querySelector('c-ausfb-financial-by-credit-secured-loans').getUpdatedSecuredLoans();

            await insertFinancialDetails({
                applicantFinanceDetails : applicantFinancial,
                securedLoansJSON : securedLoansJSON,
                totalPOS : this.totalPOS,
                totalCountOfMonthFY : this.totalCountOfMonthFY,
                totalBalanceTenor : this.totalBalanceTenor,
                totalPrincipal : this.totalPrincipal,
                parentApplicantDetailId : this.parentApplicantFinanceDetailId
            });
            this.handleGetInitialData();
            toastWithMessage(this, 'SUCCESS', 'success', 'Credit financial saved successfully');
            return true;
        }
        catch(e){
            console.error('Something is wrong ' + e);
            toastWithMessage(this, 'ERROR', 'error', 'Could not save financial details : ' + e);
        }
        this.isLoading = false;
    }

    
    handleSecuredLoanCalculation(evt){
        const eventData = JSON.parse(evt.detail);
        this.totalPOS = eventData.totalPOS;
        this.totalCountOfMonthFY = eventData.totalCountOfMonthFY;
        this.totalBalanceTenor = eventData.totalBalanceTenor;
        this.totalPrincipal = eventData.totalPrincipal;
        this.formulaCalculation();
    }

}