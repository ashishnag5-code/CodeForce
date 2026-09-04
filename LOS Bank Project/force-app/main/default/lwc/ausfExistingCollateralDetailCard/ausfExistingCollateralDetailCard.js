import { LightningElement,api } from 'lwc';
import deleteCollateral from '@salesforce/apex/AUSFVehicleController.deleteCollateral';

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings

export default class AusfExistingCollateralDetailCard extends LightningElement {
    @api existingCollateralList;
    @api label;
    @api loanId;

     // Custom Spinner settings
     async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.loanId);
        }
    }
    // Custom Spinner settings

    async connectedCallback(){
        await this.spinnerImageMethod();
    }

    handleDeleteAction(event){
        this.isloading = true;
        const idToDelete = event.currentTarget.dataset.id;
        let collList = this.existingCollateralList;
        console.log('before slice list is '+JSON.stringify(collList))
        let todoTaskIndex;
        for(let i=0; i<collList.length; i++) {
            console.log('current ls is '+JSON.stringify(collList[i]));
            if(idToDelete === collList[i].Id) {
                console.log('colllist is '+collList[i])
                console.log('idToDelete is '+idToDelete)
                todoTaskIndex = i;
            }
        }

        //collList.splice(todoTaskIndex, 1);
        console.log('after list is '+JSON.stringify(collList))
        //if(collList.length===0){
            /*const Obj = {};
            Obj.showDetail = false;
            if(collList[idToDelete].Type_Of_Existing_Collateral__c ==='CBS'){
                Obj.type='CBS';
            }
            if(collList[idToDelete].Type_Of_Existing_Collateral__c ==='Manual'){
                Obj.type='Manual';
            }
            this.dispatchEvent(new CustomEvent('existingcollateral', {
                detail: Obj
            }));*/
        //}
        //this.existingCollateralList = collList;
        //this.isloading = false;
        
        this.deleteCollateral(idToDelete);
    
    }
    deleteCollateral(collateralId){
        this.isloading = true;
        deleteCollateral({collId : collateralId})
                .then(result => {
                    console.log('Deleted result is ' + JSON.stringify(result));
                    this.isloading = false;
                    //this.showToast('Successfully deleted collateral','success');

                })
                .catch(error => {
                    this.isloading = false;
                    this.error =error;
                });

    }
}