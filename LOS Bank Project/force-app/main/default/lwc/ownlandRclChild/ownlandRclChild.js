import { LightningElement, track, api, wire } from 'lwc';
import getCropsDetails from '@salesforce/apex/AgricultureIncomeDetailsController.getCropsDetails';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import upsertIncome from '@salesforce/apex/AgricultureIncomeDetailsController.upsertIncome';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; // R2 Updated
import getVisibleFieldsForFinancials from '@salesforce/apex/AgricultureIncomeDetailsController.getVisibleFieldsForFinancials';
import AREA_UNDER_CROP_UNIT from '@salesforce/schema/Applicant_Financials_Details__c.Area_under_Crop_Unit__c'
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2
export default class FarmerOwnLandRclTemplate extends LightningElement {
    isDelete = true; //R2
    @api applicantId
    @api financialId
    @api recordTypeName
    @api recordTypeId
    @api loanId

    @track cropOptions=[];
    cropOptionsPicklist=[];

    Id='';
    keyId;
    record={}
    showRecordViewForm=false;
    displayButtons=true;
    readOnly=false;
    edit=false;
    @api isR2 //R2-389

    ownLandTotalIncome = 0;
    cropDetails;

    Crop_Details__c=''
    MSP__c=0
    Irrigartion_Source__c=''
    Area_under_crop__c=0
    Sowing_Month__c=''
    Harvesting_Month__c=''
    Estimated_Yield__c=0
    Estimated_Sale_Value__c=0
    Net_Revenue__c=0
    Area_under_Crop_Unit__c=''
    Cost_of_Cultivation__c=''
    costOfCultivation

    @api changedData;
    keyval
    @api 
    get sendKey(){
        return this.keyval
    }
    set sendKey(value){
        this.keyval = value
        if(value){
            this.keyId = value
        }
    }

    connectedCallback(){
        this.getVisibleFields();
        this.getCropsData();
        this.handleDeleteVisbility();//R2
    }

    getVisibleFields(){
        let screen = ''
        if(this.type=='ownland'){
            screen='Farmer - Agriculture Own Land'
        }else{
            screen='Farmer - Rented Land'
        }
        getVisibleFieldsForFinancials({ strScreen :screen, strStage :'QDE', strProfile :'', loanId: this.loanId, customerType:''})
        .then(result => {
            console.log('result is '+JSON.stringify(result));
            result.forEach(input => {
                if(this.template.querySelectorAll('[data-id="'+input+'"]')){
                    this.template.querySelectorAll('[data-id="'+input+'"]').forEach(element =>{
                        element.classList.remove('slds-hide');
                    })
                }
            });
            if(this.isR2 && this.edit){
                this.template.querySelector('lightning-accordion').activeSectionName=""
            }
        })
        .catch(error => {
            console.log('result is '+error);
        })

    }

    handleValidations() {
        var valid;        
        const allValid = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            
        }, true);

        if (allValid) {
            valid = true
        } else {
            valid = false;
        }
        return valid;
    }


    getCropsData(){
        getCropsDetails({applicantId: this.applicantId}).then((data)=>{
            this.cropDetails = data;
            var cropOptionsPicklist=[];
            
            data.forEach(element => {
                var newItem = {label: element.Crop__c, value: element.Crop__c}
                cropOptionsPicklist.push(newItem);
                console.log('Crop Options '+JSON.stringify(this.cropOptionsPicklist));
                this.cropOptions = cropOptionsPicklist;
            })
        }).catch((error)=>{
            if(this.applicantId){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'We could not find crop data related to Applicants current city/state',
                        variant: 'error',
                    }),
                );
            }
        })
    }
     //R2
    async handleDeleteVisbility(){
        const isDelete = await renderDeleteAction({ recordId: this.loanId});
        this.isDelete = isDelete;
        console.log('isDelete-->' +isDelete);
    }
    @track areaUnderCropUnitOptions=[]
    @wire (getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: AREA_UNDER_CROP_UNIT})
    retrieveUnit({error, data}){
        if(data){
            this.areaUnderCropUnitOptions = data.values;
        }
    }

    @api type;
    @api 
    get initialRecord(){
        return this.initialRec;
    }
    set initialRecord(value){
        this.initialRec = value
        if(value && value.RecordTypeId == this.recordTypeId)
        {
           let dummy = JSON.parse(JSON.stringify(value))
            this.readOnly = true;
            this.edit = true
            this.showRecordViewForm=true;
            this.Id=value.Id
            //this.keyId=this.sendKey;
            this.record = dummy;
            console.log(value);
        }
    }

    remo;
    @api
    get newRecord(){
        return this.remo;
    }
    set newRecord(value){
        this.remo = value;
        if(value){
            this.record = JSON.parse(JSON.stringify(value));
            this.handleNewMappings();
        }
    }

    handleClose(event){
        if(this.record.Id){
            this.showRecordViewForm = true 
             
        }
        this.readOnly = true;
        this.edit = true; 
        if(this.isR2){
            this.template.querySelector('lightning-accordion').activeSectionName=""
        }
    }

    setStringDefaultValues(data){
        return data?data:''
    }

    setNumericDefaultValues(data){
        if(data){
            data = parseFloat(data)
        }
        return data?parseFloat(data.toFixed(2)):0
    }

    handleEdit(event){
        
        this.readOnly = false;
        this.edit = false; 
        this.showRecordViewForm = false
        this.getVisibleFields();
        if(this.isR2){
            this.template.querySelector('lightning-accordion').activeSectionName="A"
        }
        this.cropDetails.forEach(element => {
            if(element.Crop__c == this.Crop_Details__c){
                this.costOfCultivation = element.New_Coc_Acres__c
            }
        })
    }

    handleMappings(){
        if(this.recordTypeId)
            this.record.RecordTypeId = this.recordTypeId
        if(this.applicantId)
            this.record.Applicant__c = this.applicantId; 
        if(this.financialId){
            this.record.Applicant_Financials__c = this.financialId;
        }
        this.record.Crop_Details__c = this.setStringDefaultValues(this.Crop_Details__c)
        this.record.MSP__c = this.setNumericDefaultValues(this.MSP__c)
        this.record.Irrigartion_Source__c = this.setStringDefaultValues(this.Irrigartion_Source__c)
        this.record.Area_under_crop__c = this.setNumericDefaultValues(this.Area_under_crop__c)
        this.record.Area_under_Crop_Unit__c = this.setStringDefaultValues(this.Area_under_Crop_Unit__c)
        this.record.Sowing_Month__c = this.setStringDefaultValues(this.Sowing_Month__c)
        this.record.Harvesting_Month__c = this.setStringDefaultValues(this.Harvesting_Month__c)
        this.record.Estimated_Yield__c = this.setNumericDefaultValues(this.Estimated_Yield__c)
        this.Estimated_Sale_Value__c = this.setNumericDefaultValues(this.Estimated_Sale_Value__c)
        this.Net_Revenue__c = this.setNumericDefaultValues(this.Net_Revenue__c)
        this.Cost_of_Cultivation__c = this.setNumericDefaultValues(this.Cost_of_Cultivation__c)
        this.record.Estimated_Sale_Value__c = this.setNumericDefaultValues(this.Estimated_Sale_Value__c)
        this.record.Net_Revenue__c = this.setNumericDefaultValues(this.Net_Revenue__c)
        this.record.Cost_of_Cultivation__c = this.setNumericDefaultValues(this.Cost_of_Cultivation__c)
        if(this.Id){
            this.record.Id = this.Id;
        }

    }

    handleNewMappings(){
        if(this.record.RecordTypeId)
            this.recordTypeId = this.record.RecordTypeId
        if(this.record.Applicant__c)
        this.applicantId = this.record.Applicant__c
        if(this.record.Applicant_Financials__c)
            this.financialId= this.record.Applicant_Financials__c; 

        this.Crop_Details__c = this.setStringDefaultValues(this.record.Crop_Details__c)
        this.MSP__c = this.setNumericDefaultValues(this.record.MSP__c)
        this.Irrigartion_Source__c = this.setStringDefaultValues(this.record.Irrigartion_Source__c)
        this.Area_under_crop__c = this.setNumericDefaultValues(this.record.Area_under_crop__c)
        this.Area_under_Crop_Unit__c = this.setStringDefaultValues(this.record.Area_under_Crop_Unit__c)
        this.Sowing_Month__c = this.setStringDefaultValues(this.record.Sowing_Month__c)
        this.Harvesting_Month__c = this.setStringDefaultValues(this.record.Harvesting_Month__c)
        this.Estimated_Yield__c = this.setNumericDefaultValues(this.record.Estimated_Yield__c)
        this.Estimated_Sale_Value__c = this.setNumericDefaultValues(this.record.Estimated_Sale_Value__c)
        this.Net_Revenue__c = this.setNumericDefaultValues(this.record.Net_Revenue__c)
        this.Cost_of_Cultivation__c = this.setNumericDefaultValues(this.record.Cost_of_Cultivation__c);

        if(this.record.Id){
            this.Id = this.record.Id;
        }
        this.setModeToReadOnlyInChild();
    }

    setModeToReadOnlyInChild(){
        if(this.record.Id){
            this.readOnly=true
            this.displayButtons=false
            this.edit=true
            this.showRecordViewForm=true
        }
        
    }

    
    async saveIncome(event){

        //4733 start
        const isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.loanId})
        if(isEditRestricted){
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to edit Financial Details',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            return
        }
        //4733 end
        
        this.handleMappings();

        if(this.handleValidations()){
            if(!this.financialId && !this.record.Applicant_Financials__c){
                const selectedEvent = new CustomEvent("farmerevent", {
                    detail:{
                            totalIncome: this.ownLandTotalIncome,
                            template:'farmer',
                            record: this.record,  
                        }                
                    });
                    this.dispatchEvent(selectedEvent);
            }
            else{
                upsertIncome({record: this.record}).then((data)=>{
                    this.record.Id = data.Id;
                    this.readOnly = true;
                    this.edit = true;
                    this.showRecordViewForm=true;
                    this.getVisibleFields()
                    const selectedEvent = new CustomEvent("calculatemonthlyincome", {
                        detail:{ 
                            template: 'farmer',
                            other: true
                        }                
                    });
                    this.dispatchEvent(selectedEvent);
                })
            }
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter the Mandatory Details',
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
        

        

    }

    get irrigationSourceOptions(){
        return [
            { label: 'Well', value: 'well' },
            { label: 'Borewell', value: 'borewell' },
            { label: 'Canal', value: 'canal' },
            { label: 'River', value: 'river' },
            { label: 'Rainfall', value: 'rainfall'}
        ];
    }

    handleCropValueChange(event){
        var value = event.target.value
        this.cropDetails.forEach(element => {
            if(element.Crop__c == value){
                this.Crop_Details__c = value;
                this.MSP__c = parseFloat(element.ew_Market_Price_Quintal__c);
                this.Sowing_Month__c = element.Sowing_Month__c;
                this.Harvesting_Month__c = element.Harvest_Month__c;
                this.Estimated_Yield__c = parseFloat(element.New_Yield__c);
                this.costOfCultivation = element.New_Coc_Acres__c?parseFloat(element.New_Coc_Acres__c):''
                if(this.Area_under_crop__c){
                    //this.Net_Revenue__c = this.Area_under_crop__c * this.Estimated_Yield__c;
                    let areaUnderCropInAcres = parseFloat(this.computeAreaUnderCropsInAcres())
                    //this.Net_Revenue__c = areaUnderCropInAcres * this.Estimated_Yield__c * this.MSP__c;
                    if(this.type=='ownland'){
                        this.Cost_of_Cultivation__c = this.costOfCultivation * areaUnderCropInAcres
                        //element.New_Coc_Acres__c?(areaUnderCropInAcres*parseFloat(element.New_Coc_Acres__c)):''
                        this.Net_Revenue__c = (areaUnderCropInAcres * this.Estimated_Yield__c * this.MSP__c)-this.Cost_of_Cultivation__c;
                        this.Estimated_Sale_Value__c = this.Net_Revenue__c; // 22 Sept - Kunal for Agri land - Estimanted sale should be same as net revenue
                    } else if( this.isR2 ){
                        this.Estimated_Sale_Value__c = areaUnderCropInAcres * this.Estimated_Yield__c * this.MSP__c; //R2-2375 - If the field order is not followed Estimated Sale value is not recalculated
                        this.Net_Revenue__c = 1/2 * this.Estimated_Sale_Value__c;
                    }else{
                        this.Net_Revenue__c = areaUnderCropInAcres * this.Estimated_Yield__c * this.MSP__c;
                    }
                    this.dispatchEvent(new CustomEvent('calculatetotal',{
                        detail:{
                            amount: this.Net_Revenue__c,
                            template: this.type,
                            key: this.keyId,
                            isDeleted: false
                        }
                    }));
                }
            }      
        });

    }

    computeAreaUnderCropsInAcres(){
        let areaUnderCropsInAcres;
        if(this.Area_under_Crop_Unit__c == 'Acres' || this.Area_under_Crop_Unit__c == 'Killa'){
            areaUnderCropsInAcres = this.Area_under_crop__c
        }else if(this.Area_under_Crop_Unit__c == 'Bigha'){
            areaUnderCropsInAcres = this.Area_under_crop__c * 1.61 //0.619
        }else if(this.Area_under_Crop_Unit__c == 'Hectare'){
            areaUnderCropsInAcres = this.Area_under_crop__c * 2.471
        }else if(this.Area_under_Crop_Unit__c == 'Canal'){
            areaUnderCropsInAcres = this.Area_under_crop__c * 0.124
        }//R2-2362
        return areaUnderCropsInAcres;
        
    }

    handleChange(event){
        var value = event.target.value;
        var name = event.target.name
        if(name=='Area_under_crop__c'){
            this.Area_under_crop__c = value
        }
        if(name=='Area_under_Crop_Unit__c'){
            this.Area_under_Crop_Unit__c = value
        }
        if(name=='Area_under_crop__c' || name=='Area_under_Crop_Unit__c'){
            let areaUnderCropInAcres = parseFloat(this.computeAreaUnderCropsInAcres())
            var netRevAndEstimatedScale// = this.computeAreaUnderCropsInAcres() * this.Estimated_Yield__c * this.MSP__c
            //var netRevAndEstimatedScale = parseFloat(this.Area_under_crop__c) * this.Estimated_Yield__c;
            if(this.type=='ownland'){
                this.Cost_of_Cultivation__c = this.costOfCultivation?(areaUnderCropInAcres*parseFloat(this.costOfCultivation)):''
                netRevAndEstimatedScale = (areaUnderCropInAcres * this.Estimated_Yield__c * this.MSP__c)-this.Cost_of_Cultivation__c;
                this.Net_Revenue__c = netRevAndEstimatedScale;
                this.dispatchEvent(new CustomEvent('calculatetotal',{
                    detail:{
                        amount: this.Net_Revenue__c,
                        template: this.type,
                        key: this.keyId,
                        isDeleted: false
                    }
                }));
                this.Estimated_Sale_Value__c = this.Net_Revenue__c; // 22 Sept - Kunal for Agri land - Estimanted sale should be same as net revenue
            }
            if(this.type=='rcl'){
                netRevAndEstimatedScale = areaUnderCropInAcres * this.Estimated_Yield__c * this.MSP__c
                this.Net_Revenue__c = (50/100) * netRevAndEstimatedScale
                this.dispatchEvent(new CustomEvent('calculatetotal',{
                    detail:{
                        amount: this.Net_Revenue__c,
                        template: this.type,
                        key:this.keyId, 
                        isDeleted: false
                    }
                }));
            }
            if(this.type!='ownland'){
                this.Estimated_Sale_Value__c = netRevAndEstimatedScale; 
            }
        }

        
        if(name=='Irrigartion_Source__c'){
            this.Irrigartion_Source__c = value;
        }

    }

    handleDeleteRow(event){

        

        if(this.record.Id){
            markRecordsInactive({afd :this.record.Id}).then((data)=>{
                const selectedEvent = new CustomEvent("calculatemonthlyincome", {
                    detail:{ 
                        template: 'farmer',
                    }                
                });
                this.dispatchEvent(selectedEvent);
                this.dispatchEvent(new CustomEvent('deletedrecord',{
                    detail: this.keyId
                }));
                this.dispatchEvent(new CustomEvent('calculatetotal',{
                    detail:{
                        amount: this.Net_Revenue__c,
                        template: this.type,
                        isDeleted: true,
                        key: this.keyId
                    }
                }
                ));
            }).catch((error)=>{
            })
        }
        else{
            this.dispatchEvent(new CustomEvent('deletedrecord',{
                detail: this.keyId
            }));
            this.dispatchEvent(new CustomEvent('calculatetotal',{
                detail:{
                    amount: this.Net_Revenue__c,
                    template: this.type, 
                    isDeleted: true,
                    key: this.keyId
                }
            }
            ));
        }
    
    }

    
}