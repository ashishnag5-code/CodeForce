/* eslint-disable no-console */
// Import LightningElement and api classes from lwc module
import { LightningElement, api, wire, track } from 'lwc';
import FORM_FACTOR from "@salesforce/client/formFactor";
import recordTypeVsStageMetadataHandler from '@salesforce/apex/LightningPathLWCController.recordTypeVsStageMetadataHandler';

export default class Ausf_lightningPathLWC extends LightningElement {

   // @track selectedValue;
    @api recordId;
    @track laRecord;
    @track RecordTypeVsStageRecord;
    error;
    laRecordTypeName;

    @track steps = [];
    @track showLightningPath;
    draftStage = '';
    loanStage;
    currentStep;
    deviceType;

    connectedCallback() {
        this.handleFormFactor();
        this.callRecordTypeVsStageMetadata();
    }

    handleFormFactor() {
        if (FORM_FACTOR === "Large") {
            this.deviceType = "Desktop/Laptop";
        } else if (FORM_FACTOR === "Medium") {
            this.deviceType = "Tablet";
        } else if (FORM_FACTOR === "Small") {
            this.deviceType = "Mobile";
        }
    }

    callRecordTypeVsStageMetadata() {
        recordTypeVsStageMetadataHandler({ recordId : this.recordId})
            .then((result) => {
                let parseStage = JSON.parse(result.custmMetadataRecLst[0].Stage__c);
                let stages     = parseStage.stages;
                this.laRecord = result.loanApplcationRec[0]; 
                this.draftStage = result.loanApplcationRec[0].Draft_Stage__c;
                this.loanStage = result.loanApplcationRec[0].Stage__c;
                this.RecordTypeVsStageRecord = this.sortBySerailNoInAsc(stages);
                this.error = undefined;
                this.setSteps();
            })
            .catch((error) => {
                this.error = error;
                console.log("error inside recordTypeVsStageMetadataHandler- "+JSON.stringify(error));
            });
    }

    sortBySerailNoInAsc(stages) {
        let sortedSerialNo = stages.sort((s1, s2) => (s1.Serial_No__c > s2.Serial_No__c) ? 1 : (s1.Serial_No__c < s2.Serial_No__c) ? -1 : 0);
        return sortedSerialNo;
    }

    setSteps() {      
        let currentStage = this.laRecord.Stage__c;
        let recTypeVsStage = this.RecordTypeVsStageRecord;
        
        let step = recTypeVsStage.map(rec => {
            let obj = {};
            obj.label = rec.Stage__c;
            obj.value = rec.Serial_No__c;
            obj.key   = rec.Stage__c;
            if(rec.Stage__c == currentStage) {
                obj.class = "slds-is-active";
            }          
            else {
                obj.class = "";
            }
            if(rec.Stage__c == currentStage && currentStage == 'Rejected') {
                obj.class = "slds-is-lost";
            }            
            return obj;
        });

        let currentStep = this.RecordTypeVsStageRecord.filter(rec => rec.Stage__c == this.laRecord.Stage__c).map(recMap => recMap.Serial_No__c);
        this.currentStep    = currentStep[0];
        this.steps          = step;
        if(this.loanStage == "QDE" || this.loanStage == "DDE") {
            this.steps = this.steps.map(stepOption => {
                if (stepOption.label === this.loanStage) {
                    if(this.draftStage) {
                        stepOption.label = stepOption.label + ` (${this.draftStage})`;
                        return stepOption;
                    }
                    else {
                        return stepOption;
                    }
                } else {
                    return stepOption;
                }
            });
        }
        this.showLightningPath = true;
        console.log("this.steps-- "+JSON.stringify(this.steps));  

        this.event = setTimeout(() => {
            if(this.deviceType == "Desktop/Laptop") {
                let getPath = this.template.querySelector(".addClass");
                getPath.classList.add("pathWidth");
            }
          }, 500);
           
    }
}