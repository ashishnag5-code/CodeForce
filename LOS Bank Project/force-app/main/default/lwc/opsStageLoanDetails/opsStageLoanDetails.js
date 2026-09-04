import { api, LightningElement, track } from 'lwc';
import getVisibleFieldsForLoanDetails from '@salesforce/apex/LANCreationController.getVisibleFieldsForLoanDetails'
import callEMIScheduleAPI from '@salesforce/apex/EMIScheduleAPIController.callEMIScheduleAPI'
import getPDFData from '@salesforce/apex/EMIScheduleAPIController.getPDFData'
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSpinnerImage } from 'c/customSpinner';
import minFirstEMIDaysOps from '@salesforce/label/c.minFirstEMIDaysOps';

export default class OpsStageLoanDetails extends NavigationMixin(LightningElement){

    @api loanApp;
    @api loanAppRecordType
    @api emiDates;
    @api spinnerImage
    @track isLoading

    triggerEMISchedule=false
    Scheme__c = ''
    @track emiDateOptions=[];

    async connectedCallback() {
        if (this.spinnerImage == undefined) {
            this.spinnerImage = await getSpinnerImage(this.loanApp.Id);
        }
        this.getLoanApplicationDetailsForCmp();
    }

    showToastMessage(titleValue, messageValue, variantValue, mode){
        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    getLoanApplicationDetailsForCmp() {
        this.Scheme__c = this.loanApp.Scheme__r ? this.loanApp.Scheme__r.Scheme_Name__c : ''
        if(this.loanAppRecordType == 'Four Wheeler'){
            if(this.emiDates && this.emiDates[0]){
                var list=[]
                if(this.emiDates[0].Four_Wheeler_EMI_Date__c.includes(',')){
                    this.emiDates[0].Four_Wheeler_EMI_Date__c.split(',').forEach(dateValue=>{
                        list.push({label:dateValue, value:dateValue})
                    })  
                }else if(this.emiDates[0].Four_Wheeler_EMI_Date__c.length>0){
                    var newDate = this.emiDates[0].Four_Wheeler_EMI_Date__c
                    list.push({label:newDate, value:newDate})
                }
                this.emiDateOptions = list;
            }else{
                this.showToastMessage('Warning','We could not find EMI Date Options','warning', 'sticky')
            }
        }
        else if(this.loanAppRecordType == 'Two Wheeler'){
            if(this.emiDates && this.emiDates[0]){
                var list=[]
                if(this.emiDates[0].Two_Wheeler_EMI_Date__c.includes(',')){
                    this.emiDates[0].Two_Wheeler_EMI_Date__c.split(',').forEach(dateValue=>{
                        list.push({label:dateValue, value:dateValue})
                    })  
                }else if(this.emiDates[0].Two_Wheeler_EMI_Date__c.length>0){
                    var newDate = this.emiDates[0].Two_Wheeler_EMI_Date__c
                    list.push({label:newDate, value:newDate})
                }
                this.emiDateOptions = list;
            }else{
                this.showToastMessage('Warning','We could not find EMI Date Options','warning', 'sticky')
            }
        }
        getVisibleFieldsForLoanDetails({ strScreen: 'CIN_LAN_Creation', strStage: 'Ops', strProfile: '' }).then((data => {
            data.forEach(input => {
                this.template.querySelectorAll('[data-id="' + input + '"]').forEach(element => {
                    element.classList.remove('slds-hide');
                })
            });
        })).catch((error => {
            console.log('Error ->' + error.message.body)
        }))
    }

    callEMISchedule() {
        this.isLoading=true
        if(this.triggerEMISchedule){
            callEMIScheduleAPI({ loanApp: this.loanApp }).then((data) => {
                this.isLoading = false
                getPDFData({ loanApp: this.loanApp, refId: data, masterName:'EMI Schedule' }).then((data => {
                    this.openVFPageForEMI(data)
                }))
            }).catch((error) => {
                this.isLoading = false
                this.showToastMessage('Error', 'We Encountered an Error while Processing Your Request', 'error', 'sticky')
            })
        }
    }

    validateFirstEMIDate(firstEMIDate){
        const todaysdate = new Date();
        let addMonths, minDays = minFirstEMIDaysOps, maxDays;
        if(this.loanApp.Emi_Frequency__c && this.loanApp.EMI_Date__c && firstEMIDate){
            if(this.loanApp.Emi_Frequency__c == 'MONTHLY'){
                addMonths = 1;
                maxDays = 60;
            }else if(this.loanApp.Emi_Frequency__c == 'QUARTERLY'){
                addMonths = 3;
                maxDays = 120;
            }else if(this.loanApp.Emi_Frequency__c == 'HALF YEARLY'){
                addMonths = 6;
                maxDays = 210;
            }
            if(new Date(firstEMIDate).getDate() != Number(this.loanApp.EMI_Date__c)){
                this.showToastMessage('Error', 'The First EMI Date should only be '+this.loanApp.EMI_Date__c+ ' of any month.', 'error');
                return false;
            }else if(new Date(firstEMIDate).getDate() == Number(this.loanApp.EMI_Date__c)){
                if(new Date(firstEMIDate) < todaysdate){
                    this.showToastMessage('Error', 'Entered First EMI Date is a past date. Please enter a valid date', 'error');
                    return false;
                }else{
                    let datDiff = (new Date(firstEMIDate).getTime() - new Date(todaysdate).getTime());
                    console.log('datDiff: '+datDiff/(1000 * 3600 * 24));
                    //SFAU-5235 : Updated by Samridhi
                    if((datDiff/(1000 * 3600 * 24))+1 < minDays || (datDiff/(1000 * 3600 * 24))+1 > maxDays){
                        console.log('came into if');
                        this.showToastMessage('Error', 'First EMI Date cannot be less than '+minDays+' days and more than '+maxDays+' days from today. Please enter a valid First EMI Date.', 'error');
                        return false;
                    }else{
                        console.log('came into else');
                        return true;
                    }
                }
            }else{
                return true;
            }
        }
    }

    calculateFirstEMIDate(){
        console.log('called calculateFirstEMIDate');
        var addMonths;
        var minDays = minFirstEMIDaysOps;
        var maxDays;
        const todaysdate = new Date();
        if(this.loanApp.Emi_Frequency__c && this.loanApp.EMI_Date__c){
            if(this.loanApp.Emi_Frequency__c == 'MONTHLY'){
                addMonths = 1;
                maxDays = 60;
            }else if(this.loanApp.Emi_Frequency__c == 'QUARTERLY'){
                addMonths = 3;
                maxDays = 120;
            }else if(this.loanApp.Emi_Frequency__c == 'HALF YEARLY'){
                addMonths = 6;
                maxDays = 210;
            }
            console.log('date first: '+this.loanApp.First_EMI_Date__c);
            console.log('type first: '+typeof(this.loanApp.First_EMI_Date__c));
            if(this.loanApp.EMI_Date__c == '10' || this.loanApp.EMI_Date__c == '18'){            
                let currentMonthEMIDate = new Date(todaysdate.getFullYear(), todaysdate.getMonth(), Number(this.loanApp.EMI_Date__c));
                console.log('currentMonthEMIDate: '+currentMonthEMIDate);
                if(currentMonthEMIDate < todaysdate){
                    let expectedFirstEMIDate = new Date(todaysdate.getFullYear(), Number(parseInt(todaysdate.getMonth())+parseInt(addMonths)), Number(this.loanApp.EMI_Date__c));
                    console.log('expectedFirstEMIDate: '+expectedFirstEMIDate);
                    
                    let expectedEmiDateDiff = (new Date(expectedFirstEMIDate).getTime() - todaysdate.getTime());
                    let expectedCurrentDateDiff = (new Date(expectedFirstEMIDate).getTime() - currentMonthEMIDate.getTime());
                    console.log('expectedEmiDateDiff: '+expectedEmiDateDiff);
                    console.log('expectedCurrentDateDiff: '+expectedCurrentDateDiff);
                    if((expectedEmiDateDiff /(1000 * 3600 * 24)) > minDays && (expectedCurrentDateDiff/(1000 * 3600 * 24)) < maxDays){
                        console.log('(parseInt(expectedFirstEMIDate.getMonth())+1).length: '+'0'+(parseInt(expectedFirstEMIDate.getMonth())+1).toString());
                        let monthVal = (parseInt(expectedFirstEMIDate.getMonth())+1).toString().length==1?'0'+(parseInt(expectedFirstEMIDate.getMonth())+1).toString():(parseInt(expectedFirstEMIDate.getMonth())+1);
                        this.loanApp.First_EMI_Date__c = expectedFirstEMIDate.getFullYear() +'-'+ monthVal +'-'+ expectedFirstEMIDate.getDate();
                        console.log('answer:'+this.loanApp.First_EMI_Date__c);
                    }else{
                        console.log('(parseInt(todaysdate.getMonth())+parseInt(addMonths)+2).length: '+(parseInt(todaysdate.getMonth())+parseInt(addMonths)+2).toString().length);
                        let monthVal = (parseInt(todaysdate.getMonth())+parseInt(addMonths)+2).toString().length==1?'0'+(parseInt(todaysdate.getMonth())+parseInt(addMonths)+2).toString():(parseInt(todaysdate.getMonth())+parseInt(addMonths)+2)
                        this.loanApp.First_EMI_Date__c = todaysdate.getFullYear() +'-'+ monthVal +'-'+ Number(this.loanApp.EMI_Date__c);
                    }
                }else{
                    let currentMonthDiff = (currentMonthEMIDate.getTime() - todaysdate.getTime());
                    if((currentMonthDiff/(1000 * 3600 * 24)) > minDays && (currentMonthDiff/(1000 * 3600 * 24)) < maxDays){
                        console.log('currentMonthEMIDate.getMonth().length==1: '+currentMonthEMIDate.getMonth().toString().length);
                        let monthVal = currentMonthEMIDate.getMonth().toString().length==1?'0'+currentMonthEMIDate.getMonth().toString():currentMonthEMIDate.getMonth();
                        this.loanApp.First_EMI_Date__c = currentMonthEMIDate.getFullYear() +'-'+ monthVal +'-'+ currentMonthEMIDate.getDate();
                    }else{
                        console.log('(parseInt(todaysdate.getMonth())+parseInt(addMonths)+1).length: '+(parseInt(todaysdate.getMonth())+parseInt(addMonths)+1).toString().length);
                        let monthVal = (parseInt(todaysdate.getMonth())+parseInt(addMonths)+1).toString().length==1?'0'+(parseInt(todaysdate.getMonth())+parseInt(addMonths)+1).toString():(parseInt(todaysdate.getMonth())+parseInt(addMonths)+1);
                        this.loanApp.First_EMI_Date__c = todaysdate.getFullYear() +'-'+  monthVal +'-'+ Number(this.loanApp.EMI_Date__c);
                    }
                }
                // this.loanApp.First_EMI_Date__c = new Date(this.loanApp.First_EMI_Date__c);
                // let res = new Date(this.loanApp.First_EMI_Date__c);
                // let dates = new Date(Number(parseInt(res.getMonth())+1)+'/'+res.getDate()+'/'+res.getFullYear());
                 console.log('date: '+this.loanApp.First_EMI_Date__c);
                 console.log('type: '+typeof(this.loanApp.First_EMI_Date__c));
                // console.log('type: '+typeof(dates));
                 //this.loanApp.First_EMI_Date__c = new Date("08/18/23");
            }
        }
    }

    openVFPageForEMI(content) {
        if (content && content.ContentDocumentId) {
            this.triggerEMISchedule=false
            this.template.querySelector('[data-id="emiScheduleButton"]').disabled = true
            var docId = content.ContentDocumentId
            this.callEMIAPI = false
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    recordIds: docId,
                    selectedRecordId: docId
                }
            })
        } else {
            this.showToastMessage('Error', 'No EMI Schedule Found', 'error', 'sticky');
        }
    }

    handleChange(event){
        this.loanApp = JSON.parse(JSON.stringify(this.loanApp))
        if(event.target.name == 'EMI_Date__c'){
            this.loanApp.EMI_Date__c = event.target.value
            this.calculateFirstEMIDate()
        }
        if(event.target.name == 'First_EMI_Date__c'){
            this.loanApp.First_EMI_Date__c = event.target.value
        }
        if(this.validateFirstEMIDate(this.loanApp.First_EMI_Date__c)){
            this.triggerEMISchedule = true
            this.template.querySelector('[data-id="emiScheduleButton"]').disabled = false
        }else{
            this.triggerEMISchedule = false
            this.template.querySelector('[data-id="emiScheduleButton"]').disabled = true
        }
        
        
    }
}