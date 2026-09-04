import { LightningElement,api,wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import FINANCE_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import getExistingChildFinancialRecords from '@salesforce/apex/FinancialViewTemplateR2Controller.getExistingChildFinancialRecords'

export default class FarmerFinancialComponent extends LightningElement {

    activeSections = ['Agriculture Detail 1'];
    @track showOtherIncomeSection = false;
    @track showModal = false;
    saveDets;
    type=''
    @api financialId
    @track agricultureIncomeDetailsList =[{
        id:0,
        label: 'Agriculture Detail 1'
    }];

    @api isR2 //R2-389
    @api initialRecord;
    renderOwnLandTemplate=false;
    renderRclTemplate=false;
    renderOwnLandRCLTemplate=false;
    renderCommercialAgriHaulageTemplate=false;
    renderDairyBusinessTemplate=false;
    dairyRecordTypeId;
    commercialRecordTypeId;
    ownlandRecordTypeId;
    rclRecordTypeId;
    recordTypeId;
    recordTypeName;
    displayRecordEdit=false;
    @api applicantId;
    @api loanAppId;
    @track incomeList=[]
    @track displayTable=false

    dairyRec;
    @api 
    get dairyRecords(){
        return this.dairyRec;
    }
    set dairyRecords(value){
        this.dairyRec = value;
        if(value && value.length>0){
            if(!this.isR2){
                this.renderDairyBusinessTemplate = true;
                this.displayRecordEdit=true;
            }
            
        }
    }
    comRecs;
    @api
    get commercialRecords(){
        return this.comRecs;
    }
    set commercialRecords(value){
        this.comRecs = value;
        if(value && value.length>0){
            if(!this.isR2){
                this.renderCommercialAgriHaulageTemplate = true;
                this.displayRecordEdit=true;
            }
        }
    }
    ownlandRec;
    @api 
    get ownLandRecords(){
        return this.ownlandRec;
    }
    set ownLandRecords(value){
        this.ownlandRec = value;
        if(value && value.length>0){
            if(!this.isR2){
                this.renderOwnLandTemplate = true;
                this.displayRecordEdit=true;
            }
            this.type='ownland'
            this.recordTypeId = value[0].RecordTypeId
        }
    }
    rclRec
    @api 
    get rclRecords(){
        return this.rclRec;
    }
    set rclRecords(value){
        this.rclRec = value;
        if(value && value.length>0){
            if(!this.isR2){
                this.renderRclTemplate = true;
                this.displayRecordEdit=true;
            }
            this.type='rcl'
            this.recordTypeId = value[0].RecordTypeId
        }
    };

    @wire(getObjectInfo, { objectApiName: FINANCE_OBJECT })
    objectInfo({data, error}){
        if(data){
            console.log('inside farmer financial getObj Info')
            const rtis = data.recordTypeInfos;
            this.dairyRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Farmer - Dairy Business');
            this.commercialRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Farmer - Commercial');
            this.ownlandRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Farmer - Agriculture Own Land');
            this.rclRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Farmer - Agriculture Rented Land');
            
        }
    }

    keyIndex = 0;

    async connectedCallback(){
        this.childRecords = await getExistingChildFinancialRecords({applicantId: this.applicantId})
        if(this.childRecords && this.childRecords.length>0){
            this.setIncomeList();
        }
    }
    
    get agricultureTypeOptions(){
        return [
            { label: 'Own Land', value: 'Farmer - Agriculture Own Land' },
            { label: 'Rented Cultivated Land / Consider Documeted Proff / Valid lease Agreement  / Sarpanch Letter / Cultivator name Updated Land Revnue Record', value: 'Farmer - Agriculture Rented Land' },
            { label: 'Commercial/Agri Haulage Income Details', value: 'Farmer - Commercial' },
            { label: 'Dairy Business', value: 'Farmer - Dairy Business' }
        ];
    }


    async handleChange(event){
        var key = event.target.accessKey;
        var value = event.target.value;
        this.agricultureIncomeDetailsList[key].agricultureType = value;
        this.handleR2CloseAll()
        let resp = await this.handleR2ViewAll(value)
        setTimeout(() => {
        if(value == 'Farmer - Agriculture Own Land'){
            this.agricultureIncomeDetailsList[key].renderOwnLandTemplate = true;
                //this.recordTypeName = 'Farmer - Agriculture Own Land';
                this.recordTypeId = this.ownlandRecordTypeId;
                this.type = 'ownland'
        }
        else{
            this.agricultureIncomeDetailsList[key].renderOwnLandTemplate = false;
        }
        if(value == 'Farmer - Agriculture Rented Land'){
            this.agricultureIncomeDetailsList[key].renderRclTemplate = true;
            //this.recordTypeName = 'Farmer - Agriculture Rented Land';
            this.recordTypeId = this.rclRecordTypeId;
            this.type = 'rcl'
            
        }
        else{
            this.agricultureIncomeDetailsList[key].renderRclTemplate = false;
        }
        if(value == 'Farmer - Commercial'){
            this.agricultureIncomeDetailsList[key].renderCommercialAgriHaulageTemplate = true;
        }
        else{
            this.agricultureIncomeDetailsList[key].renderCommercialAgriHaulageTemplate = false;
        }
        if(value == 'Farmer - Dairy Business'){
            this.agricultureIncomeDetailsList[key].renderDairyBusinessTemplate = true;
        }
        else{
            this.agricultureIncomeDetailsList[key].renderDairyBusinessTemplate = false;
        }
    }, 500);   

    }

    /*addNewAgricultureIncomeDetail(event){
        this.keyIndex = this.keyIndex+1;
        this.activeSections.push('Agriculture Detail '+(this.agricultureIncomeDetailsList.length+1));
        this.agricultureIncomeDetailsList.push({agricultureType : '', id: this.keyIndex, label: 'Agriculture Detail '+(this.agricultureIncomeDetailsList.length+1)});
    }

    handleDeleteRow(event){

        console.log(event.target.accessKey);
        let list=[];
        list = this.agricultureIncomeDetailsList;
        list = list.filter(function (element) {
            return parseInt(element.id) != parseInt(event.target.accessKey);
        })
        this.activeSections=[]
        var a=1;
        list.forEach(element => {

            element.label = 'Agriculture Detail '+a;
            this.activeSections.push(element.label);
            a++;
            
        });
        this.agricultureIncomeDetailsList = list;
        console.log('Agri List: '+JSON.stringify(this.agricultureIncomeDetailsList));
    }*/

    async passToParent(event){
        const selectedEvent = new CustomEvent("farmerevent", {
            // detail: this.salaryfinancialRecord
            detail:{
                totalIncome: event.detail.totalIncome,
                template:event.detail.template,
                record: event.detail.record,
            }    
            
         });

         // Dispatches the event.
         this.dispatchEvent(selectedEvent);
         if(this.isR2){
            this.childRecords = await getExistingChildFinancialRecords({applicantId: this.applicantId})
            this.setIncomeList()
         }
         
    }

    async passIncomeToParent(event){
        var temp = event.detail.template
        var other= event.detail.other
        const selectedEvent = new CustomEvent("calculatemonthlyincome", {
            detail:{
                template: temp,
                other: other
                }                
            });
            this.dispatchEvent(selectedEvent);
            if(this.isR2){
                this.childRecords = await getExistingChildFinancialRecords({applicantId: this.applicantId})
                this.setIncomeList()
             }
    }
    
    handleCloseAll(){
        this.dispatchEvent(new CustomEvent('home', {
            detail: {
                redirect: false,
                template: 'farmer'
            }
        }));
    }

    async handleR2ViewAll(value){
        this.isPreviewAll=true
        this.displayRecordEdit=false
        let recordType=value
        this.childRecords = await getExistingChildFinancialRecords({applicantId: this.applicantId})
        this.ownLandRecords=[];
        this.rclRecords=[]
        this.commercialRecords=[]
        this.dairyRecords=[]
        if(this.childRecords && this.childRecords.length>0){
            this.childRecords.forEach(input=>{
                let name = input.RecordType.DeveloperName
                if(recordType =='Farmer - Agriculture Own Land' && name == 'Farmer_Agriculture_Own_Land'){
                    this.ownLandRecords.push(input)
                }else if(recordType=='Farmer - Agriculture Rented Land' && name == 'Farmer_Agriculture_Rented_Land'){
                    this.rclRecords.push(input)
                }else if(recordType=='Farmer - Commercial' && name == 'Farmer_Commercial'){
                    this.commercialRecords.push(input)
                }else if(recordType=='Farmer - Dairy Business' && name == 'Farmer_Dairy_Business'){
                    this.dairyRecords.push(input)
                }
            })
            this.setIncomeList()
        }
        
        /*if(this.dairyRecords && this.dairyRecords.length>0){
            this.renderDairyBusinessTemplate = true;
            this.displayRecordEdit=true;
        }
        if(this.commercialRecords && this.commercialRecords.length>0){
            this.renderCommercialAgriHaulageTemplate = true;
            this.displayRecordEdit=true;
        }
        if(this.ownLandRecords && this.ownLandRecords.length>0){
            this.renderOwnLandTemplate = true;
            this.displayRecordEdit=true;
        }
        if(this.rclRecords && this.rclRecords.length>0){
            this.renderRclTemplate = true;
            this.displayRecordEdit=true;
        }
        if(!this.displayRecordEdit){
            showToastMessage(this, "", "warning", "No Existing Records Found", "sticky");
        }else{
            this.isPreviewAll=false
        }*/
    }

    setIncomeList(){
        this.displayTable=false
        let incomeListMap = new Map()
        this.incomeList=[]
        this.childRecords.forEach(input=>{
            let name = input.RecordType.DeveloperName
            if(name == 'Farmer_Agriculture_Own_Land'){
                let income = incomeListMap['Own Land']?incomeListMap['Own Land']:0;
                incomeListMap['Own Land'] = income+input.Net_Revenue__c;
            }
            if(name == 'Farmer_Agriculture_Rented_Land'){
                let income = incomeListMap['Rented Cultivated Land / Consider Documeted Proff / Valid lease Agreement  / Sarpanch Letter / Cultivator name Updated Land Revnue Record']?incomeListMap['Rented Cultivated Land / Consider Documeted Proff / Valid lease Agreement  / Sarpanch Letter / Cultivator name Updated Land Revnue Record']:0;
                incomeListMap['Rented Cultivated Land / Consider Documeted Proff / Valid lease Agreement  / Sarpanch Letter / Cultivator name Updated Land Revnue Record'] = income+input.Net_Revenue__c;
            }
            if(name == 'Farmer_Commercial'){
                let income = incomeListMap['Commercial/Agri Haulage Income Details']?incomeListMap['Commercial/Agri Haulage Income Details']:0;
                incomeListMap['Commercial/Agri Haulage Income Details'] = income+input.Net_Annual_Income__c;
            }
            if(name == 'Farmer_Dairy_Business'){
                let income = incomeListMap['Dairy Business']?incomeListMap['Dairy Business']:0;
                incomeListMap['Dairy Business'] = income+(input.Total_Net_Income__c*12);
            }
        })
        let options=[]
        let total = 0; // R2-2376
        if(incomeListMap['Own Land']){
            options.push({Name:'Own Land',Value:incomeListMap['Own Land']})
            total += incomeListMap['Own Land'] ? incomeListMap['Own Land'] : 0;  // R2-2376
        }
        if(incomeListMap['Rented Cultivated Land / Consider Documeted Proff / Valid lease Agreement  / Sarpanch Letter / Cultivator name Updated Land Revnue Record']){
            options.push({Name:'Rented Cultivated Land / Consider Documeted Proff / Valid lease Agreement  / Sarpanch Letter / Cultivator name Updated Land Revnue Record',Value:incomeListMap['Rented Cultivated Land / Consider Documeted Proff / Valid lease Agreement  / Sarpanch Letter / Cultivator name Updated Land Revnue Record']})
            // R2-2376
            total += incomeListMap['Rented Cultivated Land / Consider Documeted Proff / Valid lease Agreement  / Sarpanch Letter / Cultivator name Updated Land Revnue Record'] ? incomeListMap['Rented Cultivated Land / Consider Documeted Proff / Valid lease Agreement  / Sarpanch Letter / Cultivator name Updated Land Revnue Record'] : 0;
        }
        if(incomeListMap['Commercial/Agri Haulage Income Details']){
            options.push({Name:'Commercial/Agri Haulage Income Details', Value:incomeListMap['Commercial/Agri Haulage Income Details']})
            total += incomeListMap['Commercial/Agri Haulage Income Details'] ? incomeListMap['Commercial/Agri Haulage Income Details'] : 0;  // R2-2376
        }
        if(incomeListMap['Dairy Business']){
            options.push({Name:'Dairy Business', Value:incomeListMap['Dairy Business']})
            total += incomeListMap['Dairy Business'] ? incomeListMap['Dairy Business'] : 0;  // R2-2376
        }
        options.push({ Name: 'Total', Value: total });  // R2-2376
        this.incomeList = options
        this.displayTable=true
    }

    handleR2CloseAll(){
        this.displayRecordEdit=false
        this.renderOwnLandTemplate=false;
        this.renderRclTemplate=false;
        this.renderOwnLandRCLTemplate=false;
        this.renderCommercialAgriHaulageTemplate=false;
        this.renderDairyBusinessTemplate=false;
    }
      
}