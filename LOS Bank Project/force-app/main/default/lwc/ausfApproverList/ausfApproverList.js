import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import selectNextApprover from "@salesforce/apex/AUSFApproverController.selectNextApprover";
import assignForRelook from "@salesforce/apex/AUSFApproverController.assignForRelook";

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings

export default class AusfApproverList extends LightningElement {
  @api statusOptions;
  @api name;
  selectedApproverId = "";
  @api recordId;
  isLoaded = false;

  _currentApprovalRecord = {};
  get currentApprovalRecord(){
    return this._currentApprovalRecord;
  }
  @api set currentApprovalRecord(value = {}){
    if(Object.keys(value).length){
      this._currentApprovalRecord = value;
    }
  }

  handleChange(event) {
    this.selectedApproverId = event.target.value;
  }

  handleSave(event) {
    if(event.target.name==='approve'){
      this.getCurrentUserType();
    }

    if(event.target.name === 'relook'){
      console.log('in relook');
      this.sendForRelook(this.recordId, this.selectedApproverId);
    }
    
  }

  async connectedCallback(){
    this.handleImageSpinnerTesting();
  }

  async handleImageSpinnerTesting(){
    await this.spinnerImageMethod();
  }


 // Custom Spinner settings
 async spinnerImageMethod() {
  if(this.spinnerImage == undefined){
      this.spinnerImage = await getSpinnerImage(this.recordId);
  }
}
// Custom Spinner settings


  /*approveLoanApplication() {
    submitForApproval({
      loanAppRecordId: this.recordId,
      nextApproverId: this.selectedApproverId,
      currentApproverId: this.currentApprover
    })
      .then((data) => {
        console.log("searched data is>>" + JSON.stringify(data));
        this.currentApproverRecord = data;
      })
      .catch((error) => {
        console.log("error is " + JSON.stringify(error));
      });
  }*/

  getCurrentUserType() {
    this.isLoaded = true;
    console.log('Current Approval Record ==> ', JSON.parse(JSON.stringify(this._currentApprovalRecord)));
    selectNextApprover({ loanAppId: this.recordId,nextAprId:this.selectedApproverId, approvalRecord: this._currentApprovalRecord })
      .then((result) => {
        this.isLoaded = false;
        console.log("result " + JSON.stringify(result));
        const custEvent = new CustomEvent(
          'assignednextapprover', {
              detail: false 
          });
        this.dispatchEvent(custEvent);

        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Approver Assigned Successfuly!",
            variant: "success",
            mode: 'sticky'
          })
        );
        
      })
      .catch((error) => {
        this.isLoaded = false;
        this.error = error;
      });
  }

  sendForRelook( loanAppId, assignTo ){
    this.isLoaded = true;
    assignForRelook({ loanAppId, assignTo })
      .then( () => {
        this.isLoaded = false;
        this.showToast('Success', `Successfully sent to ${this.statusOptions?.find(item => item.value === assignTo )?.label} for approval` );
        this.fireEvent('success');
      }).catch( err => { this.isLoaded = false; this.error = JSON.stringify(err); this.showToast('', err.body.message ?? 'Something went wrong!', 'error' ) });
  }
  
  showToast( title, message, variant = 'success', mode = 'sticky' ){
    this.dispatchEvent( new ShowToastEvent({ title, message, variant, mode }) );
  }

  fireEvent(customEventName, detail){
    this.dispatchEvent(
      new CustomEvent(
        customEventName, { detail }
        )
    );
  }
  

}