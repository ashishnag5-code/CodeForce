import { LightningElement,track,api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLEIWrapper from '@salesforce/apex/AUSFLEICreditController.getLEIWrapper';
import generateDocChecklists from '@salesforce/apex/AUSFLEICreditController.generateDocChecklists';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import finalExposure from '@salesforce/label/c.Final_Exposure'; //UFCE Changes - sadhana

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings


export default class AusfLEIDetailCredit extends LightningElement {
   /* @track securityStatusValue = 'inProgress';
    @track typeOfBankingValue = '';
    @track leiStatusValue = '';
    @track foreignCurrenyExposureValue ='No';
    @track capitalMarketExposureValue = 'No';
    @track realestateExposureValue = 'No';*/
    isloaded = false;
    @api recordId;
    disableRecord = false;
    isLEINoRequired = false;
    showSaveButton = true;
    @track loanApplicationRecord ={'Foreign_Curreny_Exposure__c':'No','Capital_Market_Exposure__c':'No','Realestate_Exposure__c':'No','LEI_Status__c':'No'}
    isUFCE = false;
    isModalOpen =false;
    @track totalExposure;
    modalHeader;
    modalMsg;
    get securityStatusOptions() {
        return [
                { label: 'Secured', value: 'Secured' },
                { label: 'Unsecured', value: 'Unsecured' },
                { label: 'Partly secured', value: 'Partly secured' },
            ];
    }

    get typeOfBankingOptions() {
        return [
                { label: 'Sole', value: 'Sole' },
                { label: 'Multiple', value: 'Multiple' },
            ];
    }

    get leiStatusOptions() {
        return [
                { label: 'Yes', value: 'Yes' },
                { label: 'No', value: 'No' },
            ];
    }

    get averageTurnoverOptions() {
        return [
                { label: 'Upto 1 Crore', value: 'Upto 1 Crore' },
                { label: '1 Crore-5 Crore', value: '1 Crore-5 Crore' },
                { label: '5 Crore-10 Crore', value: '5 Crore-10 Crore' },
                { label: '10 Crore-50 Crore', value: '10 Crore-50 Crore' },
                { label: 'Above 50 Crores', value: 'Above 50 Crores' },
            ];
    }

    //UFCE Changes start- sadhana
    get ufceOptions(){
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    //UFCE Changes end- sadhana

    connectedCallback(){
        this.getLEIWrapper(this.recordId);
    }

    // Custom Spinner settings
    async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }
    // Custom Spinner settings

    async getLEIWrapper(recordId){
        await this.spinnerImageMethod();
        this.isloaded = true;
        //vehicleUsage, String state,String scheme,String manufacturer
        getLEIWrapper({ loanAppId:recordId})
		.then(data => {
            if (data) {
                console.log('data if is '+JSON.stringify(data));

                if(data.loanApp){
                    this.totalExposure = data.loanApp.Final_Exposure__c; //UFCE Changes - sadhana
                    let leiRecord = data.loanApp;
                    if(data.loanApp.LEI_Status__c==='Yes'){
                        this.isLEINoRequired = true;
                    }
                    if(leiRecord.Security_Status__c || leiRecord.Type_Of_Banking__c || leiRecord.LEI_Status__c || leiRecord.Three_years_average_turnover__c || leiRecord.LEI_No__c){
                        this.disableRecord = true;
                        this.showSaveButton = false;
                    }
                    //UFCE Changes Start - Sadhana
                    if(data.isUFCE){
                        this.isUFCE = true;
                        this.loanApplicationRecord.Unhedged_Foreign_Currency_Exposure__c =data.loanApp.Unhedged_Foreign_Currency_Exposure__c;
                    }
                    //UFCE Changes End - Sadhana
                
                    if(leiRecord.Type_Of_Banking__c){
                        this.loanApplicationRecord.Type_Of_Banking__c =leiRecord.Type_Of_Banking__c;
                    }else{
                        if(data.cibilScore){
                            let cibilScore = parseInt(data.cibilScore);
                            if(cibilScore===-1){
                                this.loanApplicationRecord.Type_Of_Banking__c='Sole';
                            }else{
                                this.loanApplicationRecord.Type_Of_Banking__c='Multiple';
                            }
                        }
                    }
                
                    if(leiRecord.Security_Status__c){
                        this.loanApplicationRecord.Security_Status__c = leiRecord.Security_Status__c;
                    }else{
                        if(data.posResult){
                            let posResult = parseInt(data.posResult);
                            if(posResult>=0){
                                this.loanApplicationRecord.Security_Status__c ='Secured';
                            }else if (posResult<0){
                                this.loanApplicationRecord.Security_Status__c ='Partly secured';
                            }
                        }   
                    }

                    if(leiRecord.LEI_Status__c){
                        this.loanApplicationRecord.LEI_Status__c = leiRecord.LEI_Status__c;
                    }else{
                        if(data.cibilExposure){
                            let cibilExposure = parseInt(data.cibilExposure);
                            if(cibilExposure> 50000000){
                                this.loanApplicationRecord.LEI_Status__c ='Yes';
                                this.isLEINoRequired = true;
                            }
                        }
                    }
                    
                    if(leiRecord.Three_years_average_turnover__c){
                        this.loanApplicationRecord.Three_years_average_turnover__c = leiRecord.Three_years_average_turnover__c;
                    }else{
                        if(data.applicantFinaanceDetailList){
                            let applicantFinance = data.applicantFinaanceDetailList;
                            for(let i=0; i<applicantFinance.length;i++){
                                if(applicantFinance[i].Method_Of_Assesment__c =='Assessed' && (applicantFinance[i].Type_Of_Employment__c=='Farmer' || applicantFinance[i].Type_Of_Employment__c=='Self Employed Non-Professional' || applicantFinance[i].Type_Of_Employment__c=='Self Employed Professional')){
                                    let annualTurnover = parseInt(applicantFinance[i].Annual_Turnover__c);
                                    let onecrore = 10000000;
                                    let fivecrore = 50000000;
                                    let tencrore = 100000000;
                                    let fiftycrore = 500000000;
                                    if(annualTurnover<onecrore){
                                        this.loanApplicationRecord.Three_years_average_turnover__c = 'Upto 1 Crore';
                                    }else if(annualTurnover>onecrore && annualTurnover<fivecrore){
                                        this.loanApplicationRecord.Three_years_average_turnover__c = '1 Crore-5 Crore';
                                    }else if(annualTurnover>fivecrore && annualTurnover<tencrore){
                                        this.loanApplicationRecord.Three_years_average_turnover__c = '5 Crore-10 Crore';
                                    }else if(annualTurnover>tencrore && annualTurnover<fiftycrore){
                                        this.loanApplicationRecord.Three_years_average_turnover__c = '10 Crore-50 Crore';
                                    }else if(annualTurnover>fiftycrore){
                                        this.loanApplicationRecord.Three_years_average_turnover__c = 'Above 50 Crores';
                                    }
                                }else if(applicantFinance[i].Method_Of_Assesment__c =='Documented - ITR	'){
                                    this.loanApplicationRecord.Three_years_average_turnover__c = 'Upto 1 Crore';
                                }
                            }
                        }
                    }
                    
                }

                
                this.isloaded = false;
            }else{
                console.log('data else is '+JSON.stringify(data));
                this.isloaded = false;
            }
            
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            console.error(error)
            this.isloaded = false;
		})
    }

    handleEditAction(){
        this.disableRecord = false;
        this.showSaveButton = true;
    }

    setAverageTurnOverValue(applicantFinanceList){
        for (let i = 0; i < applicantFinanceList.length; i++) { 
            let obj = applicantFinanceList[i];
            if(obj.RecordType.Name==='Documented Without Audited financial'){
                this.loanApplicationRecord.Three_years_average_turnover__c ='Upto 1 Crore';
            }else if(obj.RecordType.Name==='Assessed No Document' && obj.Type_Of_Employment__c.includes('Self Employed')){
                if(obj.Annual_Turnover__c){
                    if(obj.Annual_Turnover__c<10000000){
                        this.loanApplicationRecord.Three_years_average_turnover__c ='Upto 1 Crore';
                    }else if(obj.Annual_Turnover__c>10000000){
                        this.loanApplicationRecord.Three_years_average_turnover__c ='Upto 1 Crore';
                    }else if(obj.Annual_Turnover__c<10000000){
                        this.loanApplicationRecord.Three_years_average_turnover__c ='Upto 1 Crore';
                    }else if(obj.Annual_Turnover__c<10000000){
                        this.loanApplicationRecord.Three_years_average_turnover__c ='Upto 1 Crore';
                    }
                }
                
            }
        }
    }

    handleChange(event) {
        this.updateDataInVariable(event);
        this.loanApplicationRecord[event.target.name] = event.target.value;
        if(event.target.name==='LEI_Status__c' && event.target.value==='Yes'){
            this.isLEINoRequired = true;
        }else if(event.target.name==='LEI_Status__c' && event.target.value==='No'){
            this.isLEINoRequired = false;
        }
        //UFCE Changes  start - sadhana
        if(event.target.name==='Unhedged_Foreign_Currency_Exposure__c' && event.target.value==='Yes'){
            this.isModalOpen = true;
            this.modalHeader = 'UFCE Certificate';
            this.modalMsg = 'Marking this yes, will make UFCE certificate mandatory at PSD';
        }else if(event.target.name==='Unhedged_Foreign_Currency_Exposure__c' && event.target.value==='No' && this.totalExposure && this.totalExposure >= finalExposure){
            this.isModalOpen = true;
            this.modalHeader = 'UFCE Declaration';
            this.modalMsg = 'Marking this yes, will make UFCE declaration mandatory at PSD';
        }
        else{
            this.isModalOpen = false;
        }
        //UFCE Changes end- sadhana
    }

    updateDataInVariable(event){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        currentObj[event.target.name] = event.target.value;
        this.newVehicleRecord = currentObj;
    }

    submitDetails() {
        this.isModalOpen = false;
    }

    //UFCE Changes start- sadhana
    createChecklists(){
        console.log('@@creat check');
        generateDocChecklists({loanAppId:this.recordId})
        .then(data=>{

        })
        .catch(error => {
            console.log('error is '+JSON.stringify(error));
            console.error(error)
		})
    }
    //UFCE Changes end- sadhana
    handleSubmitForm(){
        restricAccess({
            compName: 'ausfLEIDetailCredit' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save LEI Detail',
                        variant: 'error',
                        mode : 'sticky'
                    });
                    this.dispatchEvent(evt);
                }else{
                    //UFCE Changes start- sadhana
                    if(this.isUFCE && this.loanApplicationRecord.Unhedged_Foreign_Currency_Exposure__c == null){
                        const evt = new ShowToastEvent({
                            title: 'Mandatory',
                            message: 'Populate all the Required Fields',
                            variant: 'error',
                            mode : 'sticky'
                        });
                        this.dispatchEvent(evt);
                    }
                    else{
                        //UFCE Changes end- sadhana
                    this.isloaded = true;
                    let fields = {};
                    this.loanApplicationRecord.Id = this.recordId;
                    fields = this.loanApplicationRecord;
                    const recordInput = { fields };
                    console.log('recordInput==>' +JSON.stringify(recordInput));
                    updateRecord(recordInput)
                            .then(() => {
                                //UFCE Changes start- sadhana
                                if(this.isUFCE){
                                    this.createChecklists();
                                }
                                //UFCE Changes end- sadhana
                                this.disableRecord = true;
                                this.showSaveButton = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'Created LEI',
                                        variant: 'success'
                                    })
                                );
                                this.isloaded = false;
                                // Display fresh data in the form
                            })
                            .catch(error => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error creating record',
                                        message: error,
                                        variant: 'error',
                                        mode : 'sticky'
                                    })
                                );
                                this.isloaded = false;
                            });
                        }
                    }
                    })
                    .catch(error => {
                        console.log('error is ' + JSON.stringify(error));
                    })
                
            }
    }