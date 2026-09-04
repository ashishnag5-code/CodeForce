import { LightningElement, api, track } from 'lwc';

export default class AusfbFinancialByCreditSecuredLoans extends LightningElement {
    
    // Formula field for parent Applicant financial
    totalPOS = 0;
    totalCountOfMonthFY = 0;
    totalBalanceTenor = 0;
    totalPrincipal = 0;

    // POS Date field
    @api lastYearDataDate;

    // breakup securedloan table
    @track securedLoans = [];

    // SetupConfig flag variables
    @api formulaFieldOnFormDisable;
    @api isComponentVisible;
    @api isComponentNotEditable;
    // SetupConfig flag variables

    // Check for secured loans
    get isSecuredLoanAdded(){
        return this.securedLoans.length > 0;
    }

    // Getting initial data for setup
    @api getInitialData(securedLoanJSON){
        if(!securedLoanJSON){ // If no secured loans is created
            this.securedLoans = [];
            this.totalPOS = 0;
            this.totalCountOfMonthFY = 0;
            this.totalBalanceTenor = 0;
            this.totalPrincipal = 0;
        }
        else{
            this.securedLoans= JSON.parse(securedLoanJSON);
            this.formulaCalculationSecuredLoans();
        }
        
    }

    // add more secured loans
    addSecuredLoans = () => {
        this.securedLoans.push(
            {
                index : this.securedLoans.length + 1,
                loanName : null,
                pos : null,
                countOfMonth : null,
                balanceTenure : null,
                principalPaidLiability : null,
            }
        );
    }

    // Deleting secured loans rows
    handleDeleteSecuredLoanClick = (event) => {
        const index = event.target.dataset.index;
        this.securedLoans.splice(index, 1);
        this.formulaCalculationSecuredLoans();
    }

     // Checking validation on server side for metadata conditions
     @api
     validationCheck(){
        // Check for lightning-input to be valid
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.secured-loan-input');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

     // Return numerical value for formula calculation
     blankOrZeroVal = (value) => {
        if(value && isFinite(value)) return parseFloat(parseFloat(value).toFixed(2));
        return 0;
    }

    // Handle input value change in secured loans
    handleInputSecuredLoanChange = (event) => {
        const index = event.target.dataset.index;
        const fieldName = event.target.dataset.field;
        if(fieldName === 'loanName')
            this.securedLoans[parseInt(index)][fieldName] = (event.target.value);
        else
        this.securedLoans[parseInt(index)][fieldName] = this.blankOrZeroVal(event.target.value);


        this.formulaCalculationSecuredLoans();
    }

    // Formula calculation of all inputs for secured loans
    formulaCalculationSecuredLoans = () => {
        
        this.totalPOS = 0;
        this.totalCountOfMonthFY = 0;
        this.totalBalanceTenor = 0;
        this.totalPrincipal = 0;

        for(let i of this.securedLoans) {
            
            this.totalPOS += this.blankOrZeroVal(i.pos);
            this.totalCountOfMonthFY += this.blankOrZeroVal(i.countOfMonth);
            this.totalBalanceTenor += this.blankOrZeroVal(i.balanceTenure);
            this.totalPrincipal += this.blankOrZeroVal(i.principalPaidLiability);
            
        }

        // Firing event to recalculate the parent formulas
        this.dispatchEvent(new CustomEvent('recalculate', { 
            detail : JSON.stringify({
                totalPOS :  this.totalPOS,
                totalCountOfMonthFY : this.totalCountOfMonthFY,
                totalBalanceTenor : this.totalBalanceTenor,
                totalPrincipal : this.totalPrincipal
            })
        }))
    
    }

    // Return updated data to parent
    @api getUpdatedSecuredLoans(){
        return JSON.stringify(this.securedLoans);
    }

}