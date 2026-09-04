import { LightningElement, api, track, wire } from 'lwc';
import lookUp from '@salesforce/apex/GenericCustomLookupController.search';
//import fetchIconName from '@salesforce/apex/GenericCustomLookupController.getIconName';
import fetchLookupData from '@salesforce/apex/GenericCustomLookupController.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/GenericCustomLookupController.fetchDefaultRecord';
import fetchDefaultColor from '@salesforce/apex/GenericCustomLookupController.fetchDefaultColor';
import fetchDefaultIssuerCompany from '@salesforce/apex/GenericCustomLookupController.fetchDefaultIssuerCompany';
import getBankRecords from '@salesforce/apex/LoanDetailsController.getBankRecords';
import fetchDefaultRecordForBank from '@salesforce/apex/RelatedPaymentFavouringsController.fetchDefaultRecordForBank'

const DELAY = 120;
const VISIBLE_FIELD_MAPPING = {
    'color_code__c': 'Color_Code__c',
    'existing_policy_insurer_company__c': 'Name__c'
};

export default class GenericCustomLookup extends LightningElement {
    @api sObjectApiName;
    @api inputRequired;
    @api label;
    @api placeholder = 'search...';
    @api objectName;
    @api required;
    @api stepid;
    @api searchFields;
    @api fieldapi;
    @api recordTypeName = '';
    @api dependentFieldApi = '';
    @api dependentPicklistValue = '';
    @api dependentFieldSecondApi = '';
    @api dependentPicklistSecondValue = '';
    @api dependentFieldThirdApi = ''; 
    @api dependentPicklistThirdValue = '';
    @api dependentFieldFourthApi = '';
    @api dependentPicklistFourthValue = '';
    @api dependentFieldFifthApi    = '';
    @api dependentPicklistFifthValue  = '';
    @api parentComponentName = '';
    @api hideInputLabel
    @api keyForFinancialInstitute
    @api isDisabled = false;
    @api isRequired;
    @api inputName;
    @api existingValue;
    @api existingIcon;
    @api isUsedOrNow = false;
    errorMessag = "";
    customErrorMessage = "";
    @track isPurchaseCityLookup = false;
    @track isSourcingNameLookup = false;
    isCompanyLookup = false;
    isDealerStateLookup = false;
    isDealerNameLookup  = false;
    isOutletNameLookup  = false;
    searchKey;
    isBankMasterLookup=false;
    isFinancialInstituteLookup=false
    cbsBankData=[]
    @api loanApp;
    @track selectedRecord = {}; // to store selected lookup record in object formate 

    get isDealerDetail(){
        return this.parentComponentName == 'dealerDetail'
    }

    _defaultRecordId = '';
    get defaultRecordId(){
        return this._defaultRecordId;
    }
    @api set defaultRecordId(value){
        console.log({value});
        if(value){
            this._defaultRecordId = value;
            this.selectDefaultColor(value);
            this.selectDefaultIssuerCompany(value);
            //R2-37
            if(this.objectName=='Village Master'){
                this.connectedCallback()
            }
        }
    }

    @api callHandleRemove() {
        this.handleRemove();
    }

    @api
    reflectSelectedRecordValues(recordSelected){
        this.selectedRecord = recordSelected;
        console.log('Purchase City -->' + this.isPurchaseCityLookup);
        console.log('Selected Record :: ' + JSON.stringify(this.selectedRecord)) ;
            this.handelSelectRecordHelper();
    }

    @api
    validateChildFlds(component) {
        let getInputFLd = this.template.querySelector(`[dataset-name='${component.name}']`);
        let getSearchInputFLd = this.template.querySelector(`[data-source="searchInputField"]`);
                  
        if(this.isRequired && (!getInputFLd.value || getInputFLd.value == "" || getInputFLd.value == "undefined" || getInputFLd.value == undefined)) {
           getSearchInputFLd.classList.add('slds-has-error');
           this.customErrorMessage = "Complete this field."; 
           getSearchInputFLd.focus();                 
           return "false";
        }
        else {
            getSearchInputFLd.classList.remove('slds-has-error');
            this.customErrorMessage = "";                             
            return "true";           
        }
    }

    @api enableOrDisableLookupFLd(component, state) {
        this.isDisabled = state;
        let getSearchInputFLd = this.template.querySelector(`[data-source="searchInputField"]`);
        let getInputFLd = this.template.querySelector(`[dataset-name='${component.name}']`);
        this.commonMethodForEnabOrDisabLookup(getSearchInputFLd, state);
        this.commonMethodForEnabOrDisabLookup(getInputFLd, state);
    }

    commonMethodForEnabOrDisabLookup(inputFLd, state) {
        if(state == true) {
            inputFLd.classList.add("disabledBgColor");
        }
        else if(state == false) {
            inputFLd.classList.remove("disabledBgColor");
        }
    }

    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true;
    searchKey; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    @track iconName;
    // initial function to populate default selected lookup record if defaultRecordId provided
    connectedCallback() {
        console.log("selectedRecord inside genericlookup-- "+ JSON.stringify(this.selectedRecord));
        if (this.fieldapi == 'Purchase_City__c') {
            this.isPurchaseCityLookup = true;
        }
        else if (this.fieldapi == 'Source_Name__c') {
            this.isSourcingNameLookup = true;
        }
        else if (this.fieldapi == 'Purchase_State__c') {
            this.isDealerStateLookup = true;
        }
        else if (this.fieldapi == 'Account_Name__c') {
            this.isDealerNameLookup = true;
        }
        else if (this.fieldapi == 'Outlet_Name__c') {
            this.isOutletNameLookup = true;
        }
        else if(this.fieldapi == 'Bank_Name_PMT__c'){
            this.isBankMasterLookup=true
            if (this._defaultRecordId != ''){
                fetchDefaultRecordForBank({recordId: this._defaultRecordId}).then((data=>{
                    if(data){
                        this.selectedRecord = {Id:data.Bank_Name__c, Bank_Name__c: data.Bank_Name__c}
                        //this.selectedRecord = data;
                        this.handelSelectRecordHelper();
                    }
                    
                            //this.selectedRecord = {Id:this.loanApp.Repayment_Bank_Name__c, Bank_Name__c: this.loanApp.Repayment_Bank_Name__c}
                    
                }))
            }
        }
        else if(this.fieldapi == 'Financial_Institute_Name__c' || this.fieldapi == 'Financial_Institution__c'){
            this.isFinancialInstituteLookup=true
            if(this.fieldapi == 'Financial_Institute_Name__c'){
                fetchDefaultRecord({ recordId: this._defaultRecordId, 'sObjectApiName': 'Generic_Master__c' })
                .then((result) => {
                    if (result != null) {
                        if (result && result.sObjectList.length > 0) {
                            
                            this.selectedRecord = result.sObjectList[0];
                            //this.selectedRecord = {Id:this.loanApp.Repayment_Bank_Name__c, Bank_Name__c: this.loanApp.Repayment_Bank_Name__c}
                           this.handelSelectRecordHelper();
                        }
                        this.iconName = result.iconName;
                    }
                })
                .catch((error) => {
                    this.error = error;
                 //   this.selectedRecord = {};
                });
            }
        }
        else if(this.fieldapi == 'Company_Name__c'){
            this.isCompanyLookup = true;
            if (this._defaultRecordId != '') {
                fetchDefaultRecord({ recordId: this._defaultRecordId, 'sObjectApiName': 'Generic_Master__c' })
                .then((result) => {
                    if (result != null) {
                        if (result && result.sObjectList.length > 0) {
                            
                            this.selectedRecord = result.sObjectList[0];
                            //this.selectedRecord = {Id:this.loanApp.Repayment_Bank_Name__c, Bank_Name__c: this.loanApp.Repayment_Bank_Name__c}
                           this.handelSelectRecordHelper();
                        }
                        this.iconName = result.iconName;
                    }
                })
                .catch((error) => {
                    this.error = error;
                 //   this.selectedRecord = {};
                });
            }
        }

        else if(this.fieldapi == 'Color_Code__c'){
            this.selectDefaultColor(this.defaultRecordId);
        }

        else if(this.fieldapi == 'Financial_Institute_Name__c'){
                fetchDefaultRecord({ recordId: this._defaultRecordId, 'sObjectApiName': 'Generic_Master__c' })
                .then((result) => {
                    if (result != null) {
                        if (result && result.sObjectList.length > 0) {
                            
                            this.selectedRecord = result.sObjectList[0];
                            //this.selectedRecord = {Id:this.loanApp.Repayment_Bank_Name__c, Bank_Name__c: this.loanApp.Repayment_Bank_Name__c}
                           this.handelSelectRecordHelper();
                        }
                        this.iconName = result.iconName;
                    }
                })
                .catch((error) => {
                    this.error = error;
                 //   this.selectedRecord = {};
                });
        }

        else if(this.fieldapi == 'Bank_Name__c'){
            this.isBankMasterLookup=true
            console.log('loan App' +JSON.stringify(this.loanApp))
            /*if(this.loanApp.Repayment_Bank_Name__c){
                this.selectedRecord = {Id:this.loanApp.Repayment_Bank_Name__c, Bank_Name__c: this.loanApp.Repayment_Bank_Name__c}
                this.handelSelectRecordHelper();
            }*/
            fetchDefaultRecord({ recordId: this.loanApp.RecordTypeId, 'sObjectApiName': 'Loan_Application__c' })
                    .then((result) => {
                        if(this.loanApp.Repayment_Bank_Name__c){
                            this.selectedRecord = {Id:this.loanApp.Repayment_Bank_Name__c, Bank_Name__c: this.loanApp.Repayment_Bank_Name__c}
                            this.handelSelectRecordHelper();
                        }
                    })
                    .catch((error) => {
                        this.error = error;
            });
            getBankRecords({recordId:this.loanApp.Id || this.loanApp.id}).then((data)=>{
                if(data && data.length>0){
                    data.forEach(element => {
                        this.cbsBankData.push({Id:element.Bank_Name__c, Bank_Name__c: element.Bank_Name__c})
                    }); 
                    this.cbsBankData = this.removeDuplicates(this.cbsBankData)
                    this.lstResult=this.cbsBankData
                }
                
            }).catch((error)=>{

            })
        }
        else{
            console.log('this.defaultRecordId ', this.defaultRecordId);
            if (this.defaultRecordId != '' && this.isCompanyLookup ==false) {
                fetchDefaultRecord({ recordId: this.defaultRecordId, 'sObjectApiName': this.sObjectApiName })
                    .then((result) => {
                        if (result != null) {
                            if (result && result.sObjectList.length > 0) {
                                this.selectedRecord = result.sObjectList[0];
                                console.log('this.defaultBank-->' + JSON.stringify(this.selectedRecord));
                                this.handelSelectRecordHelper();
                            }
                            this.iconName = result.iconName?result.iconName:'custom:custom33';
                        }
                    })
                    .catch((error) => {
                        this.error = error;
                    });
            }
        }

        if(this.existingValue){
            console.log('value from parent'+this.existingValue);
            this.showSelectedRecordOnLoad();
        }

        

        
    }

    renderedCallback(){
        if(this.existingValue){
            this.iconName = this.existingIcon ? this.existingIcon : this.iconName;
            this.handelSelectRecordHelper();
        }
        console.log('Selected Record Rerendered :: ' + JSON.stringify(this.selectedRecord)) ;
    }

    fetchData() {
        console.log('fetchdata 1 value', this.dependentPicklistValue);
        console.log('fetchdata 2 value', this.dependentPicklistSecondValue);
        console.log('fetchdata 3 value', this.dependentPicklistThirdValue);
        console.log('fetchdata 4 value', this.dependentPicklistFourthValue);
        console.log('fetchdata fieldapi value', this.fieldapi);
        console.log('searchTerm', this.searchKey);
        let dependencyQueryVal = '';
        let dependencyWhereClauseVal = '';
        let mySearchQuery = '';
        if (this.searchKey) {
            if (this.fieldapi == 'Purchase_City__c') {
                mySearchQuery = 'Purchase_City__c like \'%' + this.searchKey + '%\'';
            }
            else if(this.fieldapi == 'Company_Name__c'){
                mySearchQuery = 'Company_Name__c like \'%' + this.searchKey + '%\'';
            }
            else if(this.fieldapi == 'Bank_Name__c' || this.fieldapi == 'Bank_Name_PMT__c' || this.fieldapi =='Financial_Institute_Name__c' || this.fieldapi == 'Financial_Institution__c'){
                mySearchQuery = 'Bank_Name__c like \'%' + this.searchKey + '%\'';              
            }
            else if(this.fieldapi == 'Purchase_State__c'){
                mySearchQuery = 'Purchase_State__c like \'%' + this.searchKey + '%\'';              
            }
            else if(this.fieldapi == 'Account_Name__c'){
                mySearchQuery = 'Account_Name__c like \'%' + this.searchKey + '%\'';              
            }
            
            else if(this.fieldapi == 'Outlet_Name__c'){
                mySearchQuery = 'Parent.Name like \'%' + this.searchKey + '%\'';              
            }
            
            else if(this.fieldapi == 'Account_Code__c'){
                mySearchQuery = '(Account_Code__c like \'%' + this.searchKey + '%\''+' OR '+'Account_Name__c like \'%' + this.searchKey + '%\')';
            }else if(this.fieldapi == 'Color_Code__c'){
                mySearchQuery = 'Color_Code__c like \'%' + this.searchKey + '%\'';              
            } else if(this.fieldapi?.toLowerCase() === 'existing_policy_insurer_company__c'){
                mySearchQuery = `Name__c LIKE \'%${this.searchKey}%\'`;
            }
            else {
                mySearchQuery = 'Name like \'%' + this.searchKey + '%\'';
            }
        }

        //R2-37
        if(this.objectName=='Village Master'){
            let allDataFilled=true
            if(this.recordTypeName=='District' && !this.dependentPicklistValue){
                allDataFilled=false
            }else if(this.recordTypeName=='Tehsil' && (!this.dependentPicklistValue || !this.dependentPicklistSecondValue)){
                allDataFilled=false
            }else if(this.recordTypeName=='Village' && (!this.dependentPicklistValue || !this.dependentPicklistSecondValue || !this.dependentPicklistThirdValue)){
                allDataFilled=false
            }else if(this.recordTypeName=='Survey Number' && (!this.dependentPicklistValue || !this.dependentPicklistSecondValue || !this.dependentPicklistThirdValue || !this.dependentPicklistFourthValue)){
                allDataFilled=false
            }
            if(!allDataFilled){
                this.hasRecords=false
                this.isSearchLoading = false;
                return
            }
        }
        
        //dealerDetail parent component
        if (this.parentComponentName == "dealerDetail" && (this.fieldapi == 'Purchase_City__c' || this.fieldapi == 'Account_Name__c')) {
             
               
            if(this.isUsedOrNow && (this.fieldapi == 'Purchase_City__c' || this.fieldapi == 'Account_Name__c')){
                const productCondition = this.dependentPicklistValue === 'Commercial' ? `${this.dependentFieldApi} IN (\'CV\', \'Car Taxi\', \'4W\', \'3W\', \'CV - All\')` : `${this.dependentFieldApi} = '${this.dependentPicklistValue}'`;
                const clause = ` ( ${ productCondition } OR ${this.dependentFieldApi} = 'ALL' )`;
                console.log('clause-->' +this.dependentPicklistThirdValue);
               /* if (this.dependentPicklistValue && !this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue) {
                    dependencyQueryVal = this.dependentFieldApi;
                    dependencyWhereClauseVal = "AND (" + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' OR " + this.dependentFieldApi + "='ALL')";
                }
                else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi;
                    dependencyWhereClauseVal = "AND (" + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' OR " + this.dependentFieldApi + "='ALL') AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "'";
                }
                else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi 
                    dependencyWhereClauseVal = "AND (" + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' OR " + this.dependentFieldApi + "='ALL') AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' AND " + this.dependentFieldThirdApi + " IN (" + "'" + this.dependentPicklistThirdValue + "'" + ")";
                }*/
                if (this.dependentPicklistValue && !this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue) {
                    dependencyQueryVal = this.dependentFieldApi;
                   // dependencyWhereClauseVal = "AND (" + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' OR " + this.dependentFieldApi + "='ALL')";
                   dependencyWhereClauseVal = "AND "+clause;
                }
                else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi;
                   // dependencyWhereClauseVal = "AND (" + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' OR " + this.dependentFieldApi + "='ALL') AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "'";
                    dependencyWhereClauseVal = "AND "+clause+" AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "'";
                }
                else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi 
                    //dependencyWhereClauseVal = "AND (" + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' OR " + this.dependentFieldApi + "='ALL') AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' AND " + this.dependentFieldThirdApi + " IN (" + "'" + this.dependentPicklistThirdValue + "'" + ")";
                    dependencyWhereClauseVal = "AND "+clause+" AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' AND " + this.dependentFieldThirdApi + " IN (" + "'" + this.dependentPicklistThirdValue + "'" + ")";
                }
            }
            else{
                const productCondition = this.dependentPicklistSecondValue === 'Commercial' ? `${this.dependentFieldSecondApi} IN (\'CV\', \'Car Taxi\', \'4W\', \'3W\', \'CV - All\')` : `${this.dependentFieldSecondApi} = '${this.dependentPicklistSecondValue}'`;
                const clause = ` ( ${ productCondition } OR ${this.dependentFieldSecondApi} = 'ALL' )`;
                console.log('clause-->' +clause);
            
               /*  if (this.dependentPicklistValue && this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi;
                    dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND (" + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' OR " + this.dependentFieldSecondApi + "='ALL')";
                }
                else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi;
                    dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND (" + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' OR " + this.dependentFieldSecondApi + "='ALL') AND " + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "'";
                }
                else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && this.dependentPicklistFourthValue && !this.dependentPicklistFifthValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi + ',' + this.dependentFieldFourthApi;
                    dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND (" + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' OR " + this.dependentFieldSecondApi + "='ALL') AND " + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' AND " + this.dependentFieldFourthApi + " IN (" + "'" + this.dependentPicklistFourthValue + "'" + ")";
                }*/
                 if (this.dependentPicklistValue && this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi;
                    dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN ('"  + this.dependentPicklistValue + "') AND " + clause;
                    // dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN ("  + this.dependentPicklistValue + ") AND (" + this.dependentFieldSecondApi + " IN " + this.dependentPicklistSecondValue + " OR " + this.dependentFieldSecondApi + "='ALL')";
                }
                else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi;
                    dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN ('" +  this.dependentPicklistValue +  "') AND " + clause + " AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' OR " + this.dependentFieldThirdApi + "='ALL')";
                    // dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN (" +  this.dependentPicklistValue +  ") AND (" + this.dependentFieldSecondApi + " IN " + this.dependentPicklistSecondValue + " OR " + this.dependentFieldSecondApi + "='ALL') AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' OR " + this.dependentFieldThirdApi + "='ALL')";
                }
                else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && this.dependentPicklistFourthValue && !this.dependentPicklistFifthValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi + ',' + this.dependentFieldFourthApi;
                    dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN ('" +   this.dependentPicklistValue +  "') AND " + clause + " AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' OR " + this.dependentFieldThirdApi + "='ALL') AND " + this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "'";
                    // dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN (" +   this.dependentPicklistValue +  ") AND (" + this.dependentFieldSecondApi + " IN " + this.dependentPicklistSecondValue + " OR " + this.dependentFieldSecondApi + "='ALL') AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' OR " + this.dependentFieldThirdApi + "='ALL') AND " + this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "'";
                }
            }
        }
        else if(this.parentComponentName == "dealerDetail" && (this.fieldapi == 'Outlet_Name__c')){
            dependencyQueryVal = this.dependentFieldApi;
            dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "'";
        }
        //losQuickLoan parent component
        else if (this.parentComponentName == "losQuickLoan" && (this.fieldapi == 'Purchase_City__c' || this.fieldapi == 'Source_Name__c')) {
                const productCondition = this.dependentPicklistSecondValue === 'Commercial' ? `${this.dependentFieldSecondApi} IN (\'CV\', \'Car Taxi\', \'4W\', \'3W\', \'CV - All\')` : `${this.dependentFieldSecondApi} = '${this.dependentPicklistSecondValue}'`;
                const clause = ` ( ${ productCondition } OR ${this.dependentFieldSecondApi} = 'ALL' )`;
                console.log(clause);
                if (this.dependentPicklistValue && this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi;
                    dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN ("  + this.dependentPicklistValue + ") AND " + clause;
                    // dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN ("  + this.dependentPicklistValue + ") AND (" + this.dependentFieldSecondApi + " IN " + this.dependentPicklistSecondValue + " OR " + this.dependentFieldSecondApi + "='ALL')";
                }
                else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi;
                    dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN (" +  this.dependentPicklistValue +  ") AND " + clause + " AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' OR " + this.dependentFieldThirdApi + "='ALL')";
                    // dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN (" +  this.dependentPicklistValue +  ") AND (" + this.dependentFieldSecondApi + " IN " + this.dependentPicklistSecondValue + " OR " + this.dependentFieldSecondApi + "='ALL') AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' OR " + this.dependentFieldThirdApi + "='ALL')";
                }
                else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && this.dependentPicklistFourthValue && !this.dependentPicklistFifthValue) {
                    dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi + ',' + this.dependentFieldFourthApi;
                    dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN (" +   this.dependentPicklistValue +  ") AND " + clause + " AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' OR " + this.dependentFieldThirdApi + "='ALL') AND " + this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "'";
                    // dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN (" +   this.dependentPicklistValue +  ") AND (" + this.dependentFieldSecondApi + " IN " + this.dependentPicklistSecondValue + " OR " + this.dependentFieldSecondApi + "='ALL') AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' OR " + this.dependentFieldThirdApi + "='ALL') AND " + this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "'";
                }
                // R2-30 - Populate Source Code based on selected Sourcing channel name
                if(this.fieldapi === 'Source_Name__c' ){
                    dependencyQueryVal += `,Account_Code__c${dependencyQueryVal.toLowerCase().includes('purchase_city__c') ? '' : ',Purchase_City__c'}`;//R2-1738
                }
        }
        else if(this.parentComponentName!='financialViewComponent') {
            if (this.dependentPicklistValue && !this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
                dependencyQueryVal = this.dependentFieldApi;
                dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "'";
            }
            else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
                dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi;
                dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "'";
            }
            else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
                dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi;
                dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' AND " + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "'";
            }
            else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && this.dependentPicklistFourthValue && !this.dependentPicklistFifthValue) {
                dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi + ',' + this.dependentFieldFourthApi;
                dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' AND " + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' AND " + this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "'";
            }
            else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && this.dependentPicklistFourthValue && this.dependentPicklistFifthValue) {
                dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi + ',' + this.dependentFieldFourthApi + ',' + this.dependentFieldFifthApi;
                dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' AND " + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' AND " + this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "' AND " + this.dependentFieldFifthApi + "='" + this.dependentPicklistFifthValue + "'";
            }
        }
        /*
        if ((this.fieldapi == 'Purchase_City__c' && this.parentComponentName != "dealerDetail") || this.fieldapi == 'Source_Name__c') {
            if (this.dependentPicklistValue && this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
            dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi;
            console.log('%%1 dependencyQueryVal: '+dependencyQueryVal);
            dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN (" + this.dependentPicklistValue + ") AND (" + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue +"' OR "+ this.dependentFieldSecondApi + "='ALL')";
        }
      } 
        else if((this.fieldapi == 'Purchase_City__c') && this.parentComponentName == "dealerDetail"){
            dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi + ',' + this.dependentFieldThirdApi;
            if(!this.dependentPicklistThirdValue){
            //    dependencyQueryVal+= ','+ this.dependentFieldThirdApi;
            }
            dependencyWhereClauseVal = "AND (" + this.dependentFieldApi + " ='" + this.dependentPicklistValue +"' OR "+ this.dependentFieldApi + "='') AND (" + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue +"' OR "+ this.dependentFieldSecondApi + "='ALL')";
        }
        else if(this.parentComponentName == "dealerDetail" && (this.fieldapi == 'Account_Name__c')){
            console.log('****');
            dependencyQueryVal = this.dependentFieldSecondApi+ ',' +this.dependentFieldFourthApi;
            dependencyWhereClauseVal = " AND (" + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue +"' OR "+ this.dependentFieldSecondApi + "='ALL') AND "+ this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "'";
            console.log('****'+dependencyWhereClauseVal);
        }
        else if(this.parentComponentName == "dealerDetail" && (this.fieldapi == 'Outlet_Name__c')){
            dependencyQueryVal = this.dependentFieldApi;
            dependencyWhereClauseVal = "AND "+ this.dependentFieldApi + " IN ('"+this.dependentPicklistValue + "')";
        }
        else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
            dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi;
            dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN (" + this.dependentPicklistValue + ") AND (" + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue +"' OR "+ this.dependentFieldSecondApi + "='ALL') AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue +"' OR "+ this.dependentFieldThirdApi + "='ALL')";
        }
        else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && this.dependentPicklistFourthValue && !this.dependentPicklistFifthValue) {
            dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi;
            dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN (" + this.dependentPicklistValue + ") AND (" + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue +"' OR "+ this.dependentFieldSecondApi + "='ALL') AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue +"' OR "+ this.dependentFieldThirdApi + "='ALL') AND " + this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "'";
        }
        else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && this.dependentPicklistFourthValue && this.dependentPicklistFifthValue) {
            dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi;
            dependencyWhereClauseVal = "AND " + this.dependentFieldApi + " IN (" + this.dependentPicklistValue + ") AND (" + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue +"' OR "+ this.dependentFieldSecondApi + "='ALL') AND (" + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue +"' OR "+ this.dependentFieldThirdApi + "='ALL') AND " + this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "' AND " + this.dependentFieldFifthApi + "='" + this.dependentPicklistFifthValue + "'";
        }
        else{
        if (this.dependentPicklistValue && this.dependentPicklistSecondValue && !this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
            dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi;
            dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "'";
        }
        else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && !this.dependentPicklistFourthValue) {
            dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi;
            dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' AND " + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "'";
        }
        else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && this.dependentPicklistFourthValue && !this.dependentPicklistFifthValue) {
            dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi;
            dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' AND " + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' AND " + this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "'";
        }
        else if (this.dependentPicklistValue && this.dependentPicklistSecondValue && this.dependentPicklistThirdValue && this.dependentPicklistFourthValue && this.dependentPicklistFifthValue) {
            dependencyQueryVal = this.dependentFieldApi + ',' + this.dependentFieldSecondApi + ',' + this.dependentFieldThirdApi;
            dependencyWhereClauseVal = "AND " + this.dependentFieldApi + "='" + this.dependentPicklistValue + "' AND " + this.dependentFieldSecondApi + "='" + this.dependentPicklistSecondValue + "' AND " + this.dependentFieldThirdApi + "='" + this.dependentPicklistThirdValue + "' AND " + this.dependentFieldFourthApi + "='" + this.dependentPicklistFourthValue + "' AND " + this.dependentFieldFifthApi + "='" + this.dependentPicklistFifthValue + "'";
        }
        }
        */
        if (this.fieldapi == 'Purchase_City__c' ) {
            console.log('%%dependencyQueryVal 1: ', dependencyQueryVal);
            if(dependencyQueryVal!= null && dependencyQueryVal!= '')
                dependencyQueryVal = dependencyQueryVal + "," + this.fieldapi;
            else
            dependencyQueryVal = this.fieldapi;
            console.log('%%dependencyQueryVal: ', dependencyQueryVal);
        }
        if (this.fieldapi == 'Purchase_State__c' ) {
            dependencyQueryVal = dependencyQueryVal + "," + this.fieldapi;
        }
        if (this.fieldapi == 'Account_Name__c' ) {
         //dependencyQueryVal = dependencyQueryVal + "," + this.fieldapi;
           dependencyQueryVal =this.fieldapi;
        }
        
        if (this.fieldapi == 'Outlet_Name__c' ) {
            dependencyQueryVal = dependencyQueryVal + "," + this.fieldapi;
        }
        
        if(this.fieldapi =='Company_Name__c'){
            dependencyQueryVal =this.fieldapi;
        }

        if(this.fieldapi =='Color_Code__c'){
            dependencyQueryVal =this.fieldapi;
        } else if(this.fieldapi.toLowerCase() === 'existing_policy_insurer_company__c'){
            dependencyQueryVal = 'Name__c';
        }

        if(this.fieldapi =='Bank_Name__c' || this.fieldapi == 'Bank_Name_PMT__c' || this.fieldapi == 'Financial_Institute_Name__c' || this.fieldapi == 'Financial_Institution__c'){
            dependencyQueryVal = 'Bank_Name__c';
        }
        
        console.log('dependencyQueryVal', dependencyQueryVal);
        console.log('dependencyWhereClauseVal', dependencyWhereClauseVal);
        console.log('mySearchQuery-->' +mySearchQuery);


        lookUp({ searchTerm: this.searchKey, searchQuery: mySearchQuery, myObject: this.sObjectApiName, fieldApi: this.fieldapi, myrecordTypeName: this.recordTypeName, dependencyQuery: dependencyQueryVal, dependencyWhereClause: dependencyWhereClauseVal })
            .then(result => {
                this.isSearchLoading = false;
                console.log('record', JSON.parse(JSON.stringify(result.sObjectList)));
                //this.hasRecords = result.sObjectList.length == 0 ? false : true;
                if ( (this.fieldapi == 'Purchase_City__c')) {
                    this.lstResult = JSON.parse(JSON.stringify(this.removeDuplicates(result.sObjectList)));
                    console.log('Purchasing set record', JSON.parse(JSON.stringify(this.removeDuplicates(result.sObjectList))));
                    this.hasRecords = this.lstResult.length == 0 ? false : true;
                }
                else if(this.fieldapi == 'Bank_Name__c') {
                    //this.lstResult = JSON.parse(JSON.stringify(result.sObjectList));
                    var dummyList=[]
                    if(this.cbsBankData && this.cbsBankData.length>0){
                        this.cbsBankData.forEach(bank => {
                            if(bank.Bank_Name__c && (bank.Bank_Name__c.includes(this.searchKey) || !this.searchKey)){
                                //this.lstResult.push(bank)
                                dummyList.push(bank)
                            }
                        });
                    }
                    dummyList=dummyList.concat(JSON.parse(JSON.stringify(result.sObjectList)));
                    //this.lstResult = this.lstResult.concat(JSON.parse(JSON.stringify(result.sObjectList)));
                    //this.lstResult = this.lstResult.concat(this.cbsBankData)
                    this.lstResult = this.removeDuplicates(dummyList)
                    this.hasRecords = this.lstResult.length == 0 ? false : true;
                    
                    console.log('Bank set record', JSON.parse(JSON.stringify(this.removeDuplicates(this.lstResult))));
                }
                else {
                    this.hasRecords = result.sObjectList.length == 0 ? false : true;
                    this.lstResult = JSON.parse(JSON.stringify(result.sObjectList));
                    console.log('&& list', JSON.stringify(this.lstResult));
                }
                this.lstResult = this.mapVisibleFieldValues(VISIBLE_FIELD_MAPPING, this.fieldapi, this.lstResult);
                console.log('&& list', JSON.stringify(this.lstResult));
                this.isSearchLoading = false;
                console.log('result.iconName', result.iconName);
                this.iconName = result.iconName;

            }).catch(error => {
                this.message = error.message;
                this.showSpinner = false;
            })
    }

    handleKeyChangeValue(event) {
        console.log('KeyChange');
        if ((this.fieldapi == 'Purchase_City__c')  || (this.fieldapi =='Company_Name__c')) {//|| this.fieldapi =='Company_Name__c'
            if (event.target.value && event.target.value.length > 2) {
                console.log('KeyChange fetch data');
                this.handleKeyChange(event);
            }
            else {
                console.log('inside key change', event.target.value.length);
                this.hasRecords = false;
                this.lstResult = null;
                this.showResults(event);

            }
        }
        else {
            this.handleKeyChange(event);
        }
    }


    // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.

        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;

        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
            this.fetchData();
            console.log('searchKey', this.searchKey);
        }, DELAY);

        this.showResults(event);



    }


    showResults(event) {
        console.log('inside show results');

        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;

        const whichEvent = event.target.getAttribute('data-source');
        switch (whichEvent) {
            case 'searchInputField':
                ( (this.fieldapi == 'Purchase_City__c' || this.fieldapi=='Company_Name__c' )&& (event.target.value.length <= 2 && this.parentComponentName == "")) ? clsList.remove('slds-is-open') : clsList.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');
                break;
        }
    }

    handleToggleResult(event) {
        console.log('Toggle');
        if ( (this.fieldapi == 'Purchase_City__c'  && this.parentComponentName == '') ) { //|| this.fieldapi =='Company_Name__c'
            if (event.target.value && event.target.value.length > 2) {
                console.log('Toggle fetch data');
                this.toggleResult(event);
            }
        }else {
            this.toggleResult(event);
        }
    }


    // method to toggle lookup result section on UI 
    toggleResult(event) {
        this.isSearchLoading = true;
        this.lstResult = null;
        this.fetchData();
        if(!this.isDisabled){
        this.showResults(event);
        }



    }

    removeDuplicates(arr) {
        var myMap = new Map()
        if(this.fieldapi==='Bank_Name__c'){
            arr.forEach(currentItem => {
                myMap.set(currentItem.Bank_Name__c, currentItem);
            });
        }else{
            arr.forEach(currentItem => {
                myMap.set(currentItem.Purchase_City__c, currentItem);
            });
        }
        console.log('myMap', myMap);
        console.log('myMap.values()', myMap.values());
        let arraytemp = [];

        for (let [key, value] of myMap) {
            console.log(key + " = " + value);
            arraytemp.push(value);
        }
        console.log('arraytemp', arraytemp);
        return arraytemp;
    }


    // method to clear selected lookup record  
    handleRemove() {
        this.searchKey = '';
        this.selectedRecord = {};
        if(this.isDealerDetail){
            this.isDisabled = false;
        }
        console.log('this.handleRemove-->' + JSON.stringify(this.selectedRecord));
        this.lookupUpdatehandler('deselect'); // update value on parent component as well from helper function 

        // remove selected pill and display input field again 
        this.showInputField();


        this.existingValue = this.existingValue ? undefined : this.existingValue;
    }

    showInputField(){
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-hide');
        searchBoxWrapper.classList.add('slds-show');
        const pillDiv = this.template.querySelector('.pillDiv');
        console.log('Pildiv Details >> '+ JSON.stringify(pillDiv));
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
    }

    // method to update selected record from search result 
    handelSelectedRecord(event) {
        this.customErrorMessage = "";
        var objId = event.target.getAttribute('data-recid'); // get selected record Id 
        console.log('objId', objId);
        this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list
        console.log('this.handelSelectedRecord-->' + JSON.stringify(this.selectedRecord));

        console.log('selectedRecord', this.selectedRecord);
        this.lookupUpdatehandler('select'); // update value on parent component as well from helper function 
       setTimeout(() => this.handelSelectRecordHelper(), 0);
       // this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI*/

    }

    //method to display selected record onload
    showSelectedRecordOnLoad(){
        this.selectedRecord = {Name:this.existingValue};//this.lstResult.find(data => data.Name === this.existingValue); // find selected record from list
        console.log('this.showSelectedRecordOnLoad-->' + JSON.stringify(this.selectedRecord));
        console.log('selectedRecord', this.selectedRecord);
    }

    /*COMMON HELPER METHOD STARTED*/
    handelSelectRecordHelper() {
      //  if(this.parentComponentName == "dealerDetail" && this.selectedRecord && this.selectedRecord[this.fieldapi]){
            this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
            const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
            searchBoxWrapper.classList.remove('slds-show');
            searchBoxWrapper.classList.add('slds-hide');
            const pillDiv = this.template.querySelector('.pillDiv');
            pillDiv.classList.remove('slds-hide');
            pillDiv.classList.add('slds-show');
      //  }
    }

    // send selected lookup record to parent component using custom event
    lookupUpdatehandler(context) {
        console.log('this.fieldapinupdatehandler-->' +this.fieldapi);
       if (context === 'deselect') {
            if(this.fieldapi=='Financial_Institute_Name__c' || this.fieldapi == 'Financial_Institution__c'){
                var lookupValue = { value: undefined, name: undefined, purchasingCityName: undefined, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName, key: this.keyForFinancialInstitute  };

            }else if(this.fieldapi=='Name' && this.objectName =='Group'){
                var lookupValue = { value: undefined, name: undefined, purchasingCityName: undefined, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName, label:this.label };
                //var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Name, purchasingCityName: undefined, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName, label:this.label };
            }else if(this.fieldapi == 'Name' && this.objectName =='Village Master'){//R2-37
                var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Name, 
                    fieldapi: this.fieldapi, objApiName: this.objectName, recordTypeName: this.recordTypeName };
            }else{
                var lookupValue = { value: undefined, name: undefined, purchasingCityName: undefined, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
            }
        } else {
            if (this.fieldapi == 'Purchase_City__c') {
                var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Name, purchasingCityName: this.selectedRecord.Purchase_City__c, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
            }
            else if (this.fieldapi == 'Company_Name__c') {
                var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Company_Name__c, purchasingCityName: this.selectedRecord.Company_Name__c, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
            }
            else if (this.fieldapi == 'Bank_Name__c' || this.fieldapi == 'Bank_Name_PMT__c') {
                var lookupValue = { value: this.selectedRecord.Bank_Name__c, name: this.selectedRecord.Bank_Name__c, purchasingCityName: this.selectedRecord.Company_Name__c, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
            }
            else if (this.fieldapi == 'Purchase_State__c') {
                var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Purchase_State__c, purchasingCityName: "", stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
            }
            else if (this.fieldapi == 'Account_Name__c') {
                var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Name, purchasingCityName: "", stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
            }
            
            else if (this.fieldapi == 'Outlet_Name__c') {
                var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Name, purchasingCityName: "", stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
            }
            
            else if (this.fieldapi=='Financial_Institute_Name__c' || this.fieldapi == 'Financial_Institution__c'){
                var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Bank_Name__c, purchasingCityName: undefined, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName, key: this.keyForFinancialInstitute };

            }
            else if(this.fieldapi=='Name' && this.objectName =='Group'){
                var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Name, purchasingCityName: undefined, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName, label:this.label };
            }else if (this.fieldapi == 'Color_Code__c') {
                var lookupValue = { value: this.selectedRecord.Color_Code__c, name: this.selectedRecord.Color_Code__c, purchasingCityName: "", stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
            } else if (this.fieldapi == 'Existing_Policy_Insurer_Company__c') {
                var lookupValue = { value: this.selectedRecord.Name__c, name: this.selectedRecord.Name__c, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
            } else if(this.fieldapi == 'Name' && this.objectName =='Village Master'){//R2-37
                var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Name, 
                    fieldapi: this.fieldapi, objApiName: this.objectName, recordTypeName: this.recordTypeName };
            } else {
                var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Name, purchasingCityName: this.selectedRecord.Purchase_City__c, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName, sourceCode: this.selectedRecord.Account_Code__c };//R2-30 - Populate dealer source code when channel is selected

            }
        }
        lookupValue['context'] = context;
        console.log('detail from gerneric lookup--'+JSON.stringify(lookupValue));
        this.dispatchEvent(new CustomEvent('lookupselect', {

            detail: lookupValue
        }));
    }
    mapVisibleFieldValues(fieldMappings, fieldApi, records){
        if(fieldMappings?.[fieldApi?.toLowerCase()]){
            return records.map(item => ({
                ...item,
                Name: item?.[fieldMappings?.[fieldApi?.toLowerCase()]]
            }));
        }
        return records;
    }

    @api
    resetData(){
            this.selectedRecord = {};
            this.showInputField();
    }

    selectDefaultColor(selectedColor){
        if(!selectedColor || this.fieldapi !== 'Color_Code__c') return;
        console.log({selectedColor});

        fetchDefaultColor({ fetchDefaultColor: selectedColor })
            .then((result) => {
                if (result != null) {
                    if (result && result.sObjectList.length > 0) {
                        const [ selectedRecord ] = this.mapVisibleFieldValues(VISIBLE_FIELD_MAPPING, this.fieldapi, result.sObjectList);
                        console.log(' Default color == this.selectedRecord ', {...selectedRecord})
                        this.selectedRecord = selectedRecord;
                        console.log('parsed '+JSON.stringify(this.selectedRecord))
                        //this.selectedRecord = {Id:this.loanApp.Repayment_Bank_Name__c, Bank_Name__c: this.loanApp.Repayment_Bank_Name__c}
                        this.handelSelectRecordHelper();
                    }
                    this.iconName = result.iconName;
                }
            })
            .catch((error) => {
                this.error = error;
            //    this.selectedRecord = {};
            });
    }

    selectDefaultIssuerCompany(defaultIssuerCompany){
        if(!defaultIssuerCompany || this.fieldapi !== 'Existing_Policy_Insurer_Company__c') return;
        console.log({defaultIssuerCompany});

        fetchDefaultIssuerCompany({ defaultIssuerCompany })
            .then((result) => {
                if (result != null) {
                    if (result && result.sObjectList.length > 0) {
                        const [ selectedRecord ] = this.mapVisibleFieldValues(VISIBLE_FIELD_MAPPING, this.fieldapi, result.sObjectList);
                        console.log(' Default Issuer == this.selectedRecord ', {...selectedRecord})
                        this.selectedRecord = selectedRecord;
                        console.log('parsed '+JSON.stringify(this.selectedRecord))
                        //this.selectedRecord = {Id:this.loanApp.Repayment_Bank_Name__c, Bank_Name__c: this.loanApp.Repayment_Bank_Name__c}
                        this.handelSelectRecordHelper();
                    }
                    this.iconName = result.iconName;
                }
            })
            .catch((error) => {
                this.error = error;
            //    this.selectedRecord = {};
            });
    }

    @api setBankName(){
        this.selectedRecord = {Id:this.loanApp.Repayment_Bank_Name__c, Bank_Name__c: this.loanApp.Repayment_Bank_Name__c}
        console.log('this.setBankName-->' + JSON.stringify(this.selectedRecord));
        this.handelSelectRecordHelper();
    }

    @api setDefaultBankName(name){
        console.log('name '+name);
        this.selectedRecord = {Id: name, Bank_Name__c: name};
        console.log('selected record '+JSON.stringify(this.selectedRecord));
        this.handelSelectRecordHelper();
    }
}