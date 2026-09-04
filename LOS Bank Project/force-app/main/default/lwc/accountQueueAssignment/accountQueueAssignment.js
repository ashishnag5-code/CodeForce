import { LightningElement, api, wire } from 'lwc';
import ACCOUNT_fWHNewDisbursementAuthorQueue_FIELD from '@salesforce/schema/Account.X4WH_New_Disbursement_Author_Queue__c';
import ACCOUNT_fWHNewDisbursementMakerQueue_FIELD from '@salesforce/schema/Account.X4WH_New_Disbursement_Maker_Queue__c';
import ACCOUNT_fWHUsedCOWDisbursementAuthorQueue_FIELD from '@salesforce/schema/Account.X4WH_Used_COW_Disbursement_Author_Queue__c';
import ACCOUNT_fWHUsedCOWDisbursementMakerQueue_FIELD from '@salesforce/schema/Account.X4WH_Used_COW_Disbursement_Maker_Queue__c';
import ACCOUNT_commercialNewDisbursementAuthorQueue_FIELD from '@salesforce/schema/Account.Commercial_New_Disbursement_Author_Queue__c';
import ACCOUNT_commercialNewDisbursementMakerQueue_FIELD from '@salesforce/schema/Account.Commercial_New_Disbursement_Maker_Queue__c';
import ACCOUNT_commercialUsedCOWDisburseMakerQueue_FIELD from '@salesforce/schema/Account.Commercial_Used_COW_Disburse_Maker_Queue__c';
import ACCOUNT_commercialUsedCOWDisburseAuthorQueue_FIELD from '@salesforce/schema/Account.Commercial_Used_COW_Disburse_Auth_Queue__c';
import ACCOUNT_kYCAllProducts_FIELD from '@salesforce/schema/Account.KYC_All_Products__c';
import ACCOUNT_RPC_FT_RIT_Queue_FIELD from '@salesforce/schema/Account.RPC_FT_RIT_Queue__c';
import ACCOUNT_pDDAuthorQueueAllProducts_FIELD from '@salesforce/schema/Account.PDD_Author_Queue_All_Products__c';

import ACCOUNT_pDDMakerQueueAllProducts_FIELD from '@salesforce/schema/Account.PDD_Maker_Queue_All_Products__c';

import ACCOUNT_tractorUsedCOWDisburseAuthorQueue_FIELD from '@salesforce/schema/Account.Tractor_Used_COW_Disburse_Author_Queue__c';
import ACCOUNT_tractorUsedCOWDisburseMakerQueue_FIELD from '@salesforce/schema/Account.Tractor_Used_COW_Disburse_Maker_Queue__c';
import ACCOUNT_tractorNewDisbursementAuthorQueue_FIELD from '@salesforce/schema/Account.Tractor_New_Disbursement_Author_Queue__c';
import ACCOUNT_tractorNewDisbursementMakerQueue_FIELD from '@salesforce/schema/Account.Tractor_New_Disbursement_Maker_Queue__c';

import ACCOUNT_tWDisbursementAuthorQueue_FIELD from '@salesforce/schema/Account.TW_Disbursement_Author_Queue__c';
import ACCOUNT_tWDisbursementMakerQueue_FIELD from '@salesforce/schema/Account.TW_Disbursement_Maker_Queue__c';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Account.Id';
import {updateRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountDetails from '@salesforce/apex/AccountQueueAssignmentController.getAccountDetails';

export default class AccountQueueAssignment extends LightningElement {
    //recordSelected = '3D00G6s000001TFS7';
    @api recordId;
    accountDetails;
    error;
    fieldValues = {};
    queueArray = [];
    iconname = 'custom:custom33';

    isDataLoaded = false;

    connectedCallback(){
        this.fieldValues.tWDisbursementMakerQueue = '12345-Dummy';
    }

    @wire(getAccountDetails,{ accId: '$recordId' }) 
    wiredAccount({ error, data }) {
        if (data) {
            this.accountDetails = JSON.parse(JSON.stringify(data));
            console.log('Account Data >>> '+ JSON.stringify(this.accountDetails));
            this.error = undefined;
            this.fieldValues.tWDisbursementMakerQueue = this.accountDetails.TW_Disbursement_Maker_Queue__c ? this.accountDetails.TW_Disbursement_Maker_Queue__c : '';
            this.fieldValues.tWDisbursementAuthorQueue = this.accountDetails.TW_Disbursement_Author_Queue__c ? this.accountDetails.TW_Disbursement_Author_Queue__c : '';            
            this.fieldValues.fWHNewDisbursementMakerQueue = this.accountDetails.X4WH_New_Disbursement_Maker_Queue__c ? this.accountDetails.X4WH_New_Disbursement_Maker_Queue__c : '';
            this.fieldValues.fWHUsedCOWDisbursementMakerQueue = this.accountDetails.X4WH_Used_COW_Disbursement_Maker_Queue__c ? this.accountDetails.X4WH_Used_COW_Disbursement_Maker_Queue__c : '';
            this.fieldValues.tractorNewDisbursementMakerQueue = this.accountDetails.Tractor_New_Disbursement_Maker_Queue__c ? this.accountDetails.Tractor_New_Disbursement_Maker_Queue__c : '';
            this.fieldValues.tractorUsedCOWDisburseMakerQueue = this.accountDetails.Tractor_Used_COW_Disburse_Maker_Queue__c ? this.accountDetails.Tractor_Used_COW_Disburse_Maker_Queue__c : '';
            this.fieldValues.commercialNewDisbursementMakerQueue = this.accountDetails.Commercial_New_Disbursement_Maker_Queue__c ? this.accountDetails.Commercial_New_Disbursement_Maker_Queue__c : '';
            this.fieldValues.commercialUsedCOWDisburseMakerQueue = this.accountDetails.Commercial_Used_COW_Disburse_Maker_Queue__c ? this.accountDetails.Commercial_Used_COW_Disburse_Maker_Queue__c : '';
            this.fieldValues.fWHNewDisbursementAuthorQueue = this.accountDetails.X4WH_New_Disbursement_Author_Queue__c ? this.accountDetails.X4WH_New_Disbursement_Author_Queue__c : '';
            this.fieldValues.fWHUsedCOWDisbursementAuthorQueue = this.accountDetails.X4WH_Used_COW_Disbursement_Author_Queue__c ? this.accountDetails.X4WH_Used_COW_Disbursement_Author_Queue__c : '';
            this.fieldValues.commercialNewDisbursementAuthorQueue = this.accountDetails.Commercial_New_Disbursement_Author_Queue__c ? this.accountDetails.Commercial_New_Disbursement_Author_Queue__c : '';
            this.fieldValues.commercialUsedCOWDisburseAuthorQueue = this.accountDetails.Commercial_Used_COW_Disburse_Auth_Queue__c ? this.accountDetails.Commercial_Used_COW_Disburse_Auth_Queue__c : '';
            this.fieldValues.tractorNewDisbursementAuthorQueue = this.accountDetails.Tractor_New_Disbursement_Author_Queue__c ? this.accountDetails.Tractor_New_Disbursement_Author_Queue__c : '';
            this.fieldValues.tractorUsedCOWDisburseAuthorQueue = this.accountDetails.Tractor_Used_COW_Disburse_Author_Queue__c ? this.accountDetails.Tractor_Used_COW_Disburse_Author_Queue__c : '';
            this.fieldValues.pDDMakerQueueAllProducts = this.accountDetails.PDD_Maker_Queue_All_Products__c ? this.accountDetails.PDD_Maker_Queue_All_Products__c : '';
            this.fieldValues.pDDAuthorQueueAllProducts = this.accountDetails.PDD_Author_Queue_All_Products__c ? this.accountDetails.PDD_Author_Queue_All_Products__c : '';
            //this.fieldValues.cPCQueueLoanDisbursement = this.accountDetails.CPC_Queue_Loan_Disbursement__c ? this.accountDetails.CPC_Queue_Loan_Disbursement__c : '';
            //this.fieldValues.cPCQueueFileTrackingRIT = this.accountDetails.CPC_Queue_File_Tracking_RIT__c ? this.accountDetails.CPC_Queue_File_Tracking_RIT__c : '';
            this.fieldValues.rPCFTRITQueue = this.accountDetails.RPC_FT_RIT_Queue__c ? this.accountDetails.RPC_FT_RIT_Queue__c : '';
            this.fieldValues.kYCAllProducts = this.accountDetails.KYC_All_Products__c ? this.accountDetails.KYC_All_Products__c : '';

            this.isDataLoaded = true;


            //  this.accountDetails.TW_Disbursement_Maker_Queue__c ? this.queueArray.push(this.accountDetails.TW_Disbursement_Maker_Queue__c) : '';
            //  this.accountDetails.X4WH_New_Disbursement_Maker_Queue__c ? this.queueArray.push(this.accountDetails.X4WH_New_Disbursement_Maker_Queue__c) : '';
            //  this.accountDetails.X4WH_Used_COW_Disbursement_Maker_Queue__c ? this.queueArray.push(this.accountDetails.X4WH_Used_COW_Disbursement_Maker_Queue__c) : '';
            //  this.accountDetails.Tractor_New_Disbursement_Maker_Queue__c ? this.queueArray.push(this.accountDetails.Tractor_New_Disbursement_Maker_Queue__c) : '';
            //  this.accountDetails.Tractor_Used_COW_Disburse_Maker_Queue__c ? this.queueArray.push(this.accountDetails.Tractor_Used_COW_Disburse_Maker_Queue__c) : '';
            //  this.accountDetails.Commercial_New_Disbursement_Maker_Queue__c ? this.queueArray.push(this.accountDetails.Commercial_New_Disbursement_Maker_Queue__c) : '';
            //  this.accountDetails.Commercial_Used_COW_Disburse_Maker_Queue__c ? this.queueArray.push(this.accountDetails.Commercial_Used_COW_Disburse_Maker_Queue__c) : '';
            //  this.accountDetails.X4WH_New_Disbursement_Author_Queue__c ? this.queueArray.push(this.accountDetails.X4WH_New_Disbursement_Author_Queue__c) : '';
            //  this.accountDetails.X4WH_Used_COW_Disbursement_Author_Queue__c ? this.queueArray.push(this.accountDetails.X4WH_Used_COW_Disbursement_Author_Queue__c) : '';
            //  this.accountDetails.Commercial_New_Disbursement_Author_Queue__c ? this.queueArray.push(this.accountDetails.Commercial_New_Disbursement_Author_Queue__c) : '';
            //  this.accountDetails.Commercial_Used_COW_Disburse_Auth_Queue__c ? this.queueArray.push(this.accountDetails.Commercial_Used_COW_Disburse_Auth_Queue__c) : '';
            //  this.accountDetails.Tractor_New_Disbursement_Author_Queue__c ? this.queueArray.push(this.accountDetails.Tractor_New_Disbursement_Author_Queue__c) : '';
            //  this.accountDetails.Tractor_Used_COW_Disburse_Author_Queue__c ? this.queueArray.push(this.accountDetails.Tractor_Used_COW_Disburse_Author_Queue__c) : '';
            //  this.accountDetails.PDD_Maker_Queue_All_Products__c ? this.queueArray.push(this.accountDetails.PDD_Maker_Queue_All_Products__c) : '';
            //  this.accountDetails.PDD_Author_Queue_All_Products__c ? this.queueArray.push(this.accountDetails.PDD_Author_Queue_All_Products__c) : '';
            //  this.accountDetails.CPC_Queue_Loan_Disbursement__c ? this.queueArray.push(this.accountDetails.CPC_Queue_Loan_Disbursement__c) : '';
            //  this.accountDetails.CPC_Queue_File_Tracking_RIT__c ? this.queueArray.push(this.accountDetails.CPC_Queue_File_Tracking_RIT__c) : '';
            //  this.accountDetails.Store_Queue_Only_File_Tracking__c ? this.queueArray.push(this.accountDetails.Store_Queue_Only_File_Tracking__c) : '';
            //  this.accountDetails.KYC_All_Products_FT_RIT_Queue__c ? this.queueArray.push(this.accountDetails.KYC_All_Products_FT_RIT_Queue__c) : '';

            //  if(this.queueArray.length > 0){
            //     //this.assignQueue();
            //  }

        } else if (error) {
            this.error = error;
            this.accountDetailsrecord = undefined;
        }
    }


    handleChange(event){

       //c/assessedEditView this.selectedRecord = {Id:event.detail.value, Name: event.detail.name};
        console.log('Selected value '+ event.detail.value);
        console.log('Selected name '+ event.detail.name);
        console.log('Selected label '+ event.detail.label);

        if(event.detail.label == 'TW Disbursement Maker Queue'){
            this.fieldValues.tWDisbursementMakerQueue = event.detail.name;
        }
        else if(event.detail.label == 'T4WH New Disbursement Maker Queue'){
            this.fieldValues.fWHNewDisbursementMakerQueue = event.detail.name;
        }
        else if(event.detail.label == '4WH Used/COW Disbursement Maker Queue'){
            this.fieldValues.fWHUsedCOWDisbursementMakerQueue = event.detail.name;
        }
        else if(event.detail.label == 'Tractor New Disbursement Maker Queue'){
            this.fieldValues.tractorNewDisbursementMakerQueue = event.detail.name;
        }
        else if(event.detail.label == 'Tractor - Used/COW Disburse Maker Queue'){
            this.fieldValues.tractorUsedCOWDisburseMakerQueue = event.detail.name;
        }
        else if(event.detail.label == 'Commercial New Disbursement Maker Queue'){
            this.fieldValues.commercialNewDisbursementMakerQueue = event.detail.name;
        }
        else if(event.detail.label == 'Commercial Used/COW Disburse Maker Queue'){
            this.fieldValues.commercialUsedCOWDisburseMakerQueue = event.detail.name;
        }
        else if(event.detail.label == 'TW Disbursement Author Queue'){
            this.fieldValues.tWDisbursementAuthorQueue = event.detail.name;
        }
        else if(event.detail.label == '4WH New Disbursement Author Queue'){
            this.fieldValues.fWHNewDisbursementAuthorQueue = event.detail.name;
        }
        else if(event.detail.label == '4WH Used/COW Disbursement Author Queue'){
            this.fieldValues.fWHUsedCOWDisbursementAuthorQueue = event.detail.name;
        }
        else if(event.detail.label == 'Commercial New Disbursement Author Queue'){
            this.fieldValues.commercialNewDisbursementAuthorQueue = event.detail.name;
        }
        else if(event.detail.label == 'Commercial UsedCOW Disburse Author Queue'){
            this.fieldValues.commercialUsedCOWDisburseAuthorQueue = event.detail.name;
        }
        else if(event.detail.label == 'Tractor New Disbursement Author Queue'){
            this.fieldValues.tractorNewDisbursementAuthorQueue = event.detail.name;
        }
        else if(event.detail.label == 'Tractor - Used/COW Disburse Author Queue'){
            this.fieldValues.tractorUsedCOWDisburseAuthorQueue = event.detail.name;
        }
        else if(event.detail.label == 'PDD Maker Queue (All Products)'){
            this.fieldValues.pDDMakerQueueAllProducts = event.detail.name;
        }
        else if(event.detail.label == 'PDD Author Queue (All Products)'){
            this.fieldValues.pDDAuthorQueueAllProducts = event.detail.name;
        }
        else if(event.detail.label == 'CPC Queue - Loan Disbursement'){
            this.fieldValues.cPCQueueLoanDisbursement = event.detail.name;
        }
        else if(event.detail.label == 'RPC - FT/RIT Queue'){
            this.fieldValues.rPCFTRITQueue = event.detail.name;
        }
        else if(event.detail.label == 'Store Queue (Only File Tracking)'){
            this.fieldValues.storeQueueOnlyFileTracking = event.detail.name;
        }
        else if(event.detail.label == 'KYC (All Products)'){
            this.fieldValues.kYCAllProducts = event.detail.name;
        }
    }
    handleNameChange(event){
        console.log('inside handle name change...');
        //console.log(event.detail.name);
    }
    updateAccount(){


        const FIELDS = {};
        FIELDS[ACCOUNT_ID_FIELD.fieldApiName] = this.recordId;
        FIELDS[ACCOUNT_fWHNewDisbursementAuthorQueue_FIELD.fieldApiName] = this.fieldValues.fWHNewDisbursementAuthorQueue ? this.fieldValues.fWHNewDisbursementAuthorQueue: '';
        FIELDS[ACCOUNT_fWHNewDisbursementMakerQueue_FIELD.fieldApiName] = this.fieldValues.fWHNewDisbursementMakerQueue ? this.fieldValues.fWHNewDisbursementMakerQueue : '';
        FIELDS[ACCOUNT_fWHUsedCOWDisbursementAuthorQueue_FIELD.fieldApiName] = this.fieldValues.fWHUsedCOWDisbursementAuthorQueue ?this.fieldValues.fWHUsedCOWDisbursementAuthorQueue : '';
        FIELDS[ACCOUNT_fWHUsedCOWDisbursementMakerQueue_FIELD.fieldApiName] = this.fieldValues.fWHUsedCOWDisbursementMakerQueue ? this.fieldValues.fWHUsedCOWDisbursementMakerQueue : '';
        FIELDS[ACCOUNT_commercialNewDisbursementAuthorQueue_FIELD.fieldApiName] = this.fieldValues.commercialNewDisbursementAuthorQueue ? this.fieldValues.commercialNewDisbursementAuthorQueue : '';
        FIELDS[ACCOUNT_commercialNewDisbursementMakerQueue_FIELD.fieldApiName] = this.fieldValues.commercialNewDisbursementMakerQueue ? this.fieldValues.commercialNewDisbursementMakerQueue : '';
        FIELDS[ACCOUNT_commercialUsedCOWDisburseMakerQueue_FIELD.fieldApiName] = this.fieldValues.commercialUsedCOWDisburseMakerQueue ? this.fieldValues.commercialUsedCOWDisburseMakerQueue : '';
        FIELDS[ACCOUNT_commercialUsedCOWDisburseAuthorQueue_FIELD.fieldApiName] = this.fieldValues.commercialUsedCOWDisburseAuthorQueue ? this.fieldValues.commercialUsedCOWDisburseAuthorQueue : '';
        //FIELDS[ACCOUNT_cPCQueueFileTrackingRIT_FIELD.fieldApiName] = this.fieldValues.cPCQueueFileTrackingRIT ? this.fieldValues.cPCQueueFileTrackingRIT : '';
        FIELDS[ACCOUNT_RPC_FT_RIT_Queue_FIELD.fieldApiName] = this.fieldValues.rPCFTRITQueue ? this.fieldValues.rPCFTRITQueue : '';
        FIELDS[ACCOUNT_kYCAllProducts_FIELD.fieldApiName] = this.fieldValues.kYCAllProducts ? this.fieldValues.kYCAllProducts : '';
        FIELDS[ACCOUNT_pDDAuthorQueueAllProducts_FIELD.fieldApiName] = this.fieldValues.pDDAuthorQueueAllProducts ? this.fieldValues.pDDAuthorQueueAllProducts : '';
        FIELDS[ACCOUNT_pDDMakerQueueAllProducts_FIELD.fieldApiName] = this.fieldValues.pDDMakerQueueAllProducts ? this.fieldValues.pDDMakerQueueAllProducts : '';
        //FIELDS[ACCOUNT_storeQueueOnlyFileTracking_FIELD.fieldApiName] = this.fieldValues.storeQueueOnlyFileTracking ? this.fieldValues.storeQueueOnlyFileTracking : '';
        FIELDS[ACCOUNT_tractorUsedCOWDisburseAuthorQueue_FIELD.fieldApiName] = this.fieldValues.tractorUsedCOWDisburseAuthorQueue ? this.fieldValues.tractorUsedCOWDisburseAuthorQueue : '';
        FIELDS[ACCOUNT_tractorUsedCOWDisburseMakerQueue_FIELD.fieldApiName] = this.fieldValues.tractorUsedCOWDisburseMakerQueue ? this.fieldValues.tractorUsedCOWDisburseMakerQueue : '';
        FIELDS[ACCOUNT_tractorNewDisbursementAuthorQueue_FIELD.fieldApiName] = this.fieldValues.tractorNewDisbursementAuthorQueue ? this.fieldValues.tractorNewDisbursementAuthorQueue : '';
        FIELDS[ACCOUNT_tractorNewDisbursementMakerQueue_FIELD.fieldApiName] = this.fieldValues.tractorNewDisbursementMakerQueue ? this.fieldValues.tractorNewDisbursementMakerQueue : '';
        FIELDS[ACCOUNT_tWDisbursementAuthorQueue_FIELD.fieldApiName] = this.fieldValues.tWDisbursementAuthorQueue ? this.fieldValues.tWDisbursementAuthorQueue : '';
        FIELDS[ACCOUNT_tWDisbursementMakerQueue_FIELD.fieldApiName] = this.fieldValues.tWDisbursementMakerQueue ? this.fieldValues.tWDisbursementMakerQueue : '';

        const recordInputForUpdate ={fields: FIELDS};
            updateRecord(recordInputForUpdate)
                .then(result => {
                    console.log('inside update...');
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,//error.body.output.fieldErrors,
                            variant: 'error',
                        }),
                    );
                });

    }
}