import { LightningElement,api } from 'lwc';
import isRepoSaleCollateralPopUpAllowed from '@salesforce/label/c.CollateralDedupeAllowRepoSalePopUp';
import CollateralDedupeRepoSalePopUpMessage from '@salesforce/label/c.CollateralDedupeRepoSalePopUpMessage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AusfVehicleRecordCard extends LightningElement {
    @api searchData;
    @api showTableSection;
    @api boolFromCamReport;
    @api copyDisable = false;
    collateralObj;

    connectedCallback() {
        console.log('searchData 12345'+JSON.stringify(this.searchData));
    }

    handleCopy(event){
        var collId = event.currentTarget.dataset.id;
        console.log('%% '+collId);
        console.log('searc Data is '+JSON.stringify(this.searchData))
        this.collateralObj = this.searchData.find((item)=>item.Collateral_ID__c === collId);
        console.log('%% collateralObj '+this.collateralObj);

        if(isRepoSaleCollateralPopUpAllowed.toLowerCase() === "true" && !!this.collateralObj.Repo_Sale_Date__c){
            const event = new ShowToastEvent({
                title: '',
                message: CollateralDedupeRepoSalePopUpMessage,
                variant: 'error',
                mode: 'Sticky'
            });
            this.dispatchEvent(event);
        }
        else{

            const Obj = {};
            Obj.collateralObj = this.collateralObj;

            this.dispatchEvent(new CustomEvent('copycollateral', {
                detail: Obj
            }));
        }

        
    }
}