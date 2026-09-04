import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import getLevelVsApprovers from "@salesforce/apex/AUSFApproverController.getLevelVsApprovers";
// import getLevelVsApprovers from "@salesforce/apex/AUSFApproverController.reAssignTwoWheeler";
import shareLoanApp from "@salesforce/apex/AUSFApproverController.shareLoanApp";
import assignForRelook from "@salesforce/apex/AUSFApproverController.assignForRelook";
import currentUserId from '@salesforce/user/Id';
import { toastWithMessage, reduceErrors } from 'c/lwcutilities';
export default class AusfLevelVsApprover extends LightningElement {
  @api recordId;
  _levelOptions = [];
  @api levelOptions =[];
  selectedLevel = "";
  @track approverNameOptions =[];
  @track selectedApprover = "";
  @api name;
  @api currentApprovalRecord;
  isLoaded = false;

  _levelVsApproverMap = {};
  @api get levelVsApproverMap(){
    return this._levelVsApproverMap;
  }

  set levelVsApproverMap( value ){
    if( value ){
      this._levelVsApproverMap = value;
      const currentApprover = Object.values( value ).flat().find( item => item.UserId === currentUserId );
      // R2-2457 - Remove Level is there are no corresponding users to map
      if( this.name === 'Forward' && currentApprover && value[currentApprover.Approver_Level__c]?.length === 1 ){
        this._levelOptions = this.levelOptions.filter( level => level.value !== currentApprover.Approver_Level__c );
      } else {
          this._levelOptions = this.levelOptions;
      }
    }
  }



  connectedCallback(){
   // this.getLevelVsApprovers(this.recordId);
   this.handleImageSpinnerSetting();
  }
  async handleImageSpinnerSetting(){
    await this.spinnerImageMethod();
  }


   // Custom Spinner settings
   async spinnerImageMethod() {
    if(this.spinnerImage == undefined){
        this.spinnerImage = await getSpinnerImage(this.recordId);
    }
  }
  // Custom Spinner settings

  
  handleChange(event) {
    if(event.target.name ==='Level'){
      this.selectedLevelValue = event.target.value;
      this.getApproverName(this.selectedLevelValue)
    }else if(event.target.name ==='Approver'){
      this.selectedApproverId = event.target.value;
    }
    
  }

  handleSave(event) {
    const action = event.target.name, isRelook = action?.toLowerCase() === 'relook';
    // Remarks are mandatory
    if( !this.currentApprovalRecord.Remarks__c && !isRelook ){
      return;
    }

    if(action ==='Forward'){
      this.hanldeForword(action);
    }

    if(isRelook){
      console.log('in relook');
      this.sendForRelook( this.recordId, this.selectedApproverId, this.selectedLevelValue );
    }

    if(action === 'Reassign'){
      // this.handleReassign();
      this.hanldeForword(action);
      console.log('in Reassign');
    }
    
  }

  handleReassign(){

  }

  hanldeForword(action){
    this.isLoaded = true;
    shareLoanApp({ loanAppId: this.recordId,userId:this.selectedApproverId,level:this.selectedLevelValue, action, approvalRecord: this.currentApprovalRecord })
      .then((result) => {
        this.isLoaded = false;
        console.log('result '+result)
        this.showToast('Successfully shared loan application with selected User')
        const custEvent = new CustomEvent(
          'forwardapprover', {
              detail: { action } 
          });
        this.dispatchEvent(custEvent);
      })
      .catch((error) => {
        this.isLoaded = false;
        this.error = error;
      });
  }

  getApproverName(level){
    this.approverNameOptions =[];
    console.log('level '+level)
    console.log('Map '+JSON.stringify(this.levelVsApproverMap))
    console.log('approverList '+JSON.stringify(this.levelVsApproverMap[level]))
    let approvers = this.levelVsApproverMap[level];
    if (approvers.length > 0) {
      for (let i = 0; i < approvers.length; i++) {
        console.log('approver Name ==>  '+JSON.stringify(approvers[i].User?.Name ?? approvers[i]?.Name ));
        const userId = approvers[i].User?.Id ?? approvers[i].Id;
        if( userId !== currentUserId || this.name === 'Reassign' ){
          this.approverNameOptions = [
            ...this.approverNameOptions,
            {
              value: approvers[i].User?.Id ?? approvers[i].Id,
              label: approvers[i].User?.Name ?? approvers[i].Name
            }
          ];
        }
      }
      //this.isApprove = true;
    }
  }

  showToast(message) {
    const event = new ShowToastEvent({
        title: '',
        message: message,
        variant: 'success',
        mode: 'sticky'
    });
    this.dispatchEvent(event);
  }

  sendForRelook( loanAppId, assignTo, assigneLevel ){
    this.isLoaded = true;
    assignForRelook({ loanAppId, assignTo, assigneLevel })
      .then( () => {
        this.isLoaded = false;
        this.showToast(`Successfully sent to ${this.approverNameOptions?.find(item => item.value === assignTo )?.label ?? 'the selected user'} for approval` );
        this.fireEvent('forwardapprover', { action: 'relook'});
      }).catch( err => { this.isLoaded = false; this.error = reduceErrors( err )?.join?.(', '); toastWithMessage( this, '', 'error', this.error ) });
  }

  handleCancel(){
    this.fireEvent('forwardapprover', { action: this.name, isDissmissal: true });
  }

  fireEvent(customEventName, detail){
    this.dispatchEvent(
      new CustomEvent(
        customEventName, { detail }
        )
    );
  }
  /*getLevelVsApprovers() {
    this.isloading = true;
    getLevelVsApprovers({ loanAppId: this.recordId,nextAprId:this.selectedApproverId })
      .then((result) => {
        this.isloading = false;
        console.log("result " + JSON.stringify(result));  
        if (result) {
          //this.approverOptions = result.levels;
          this.levelVsApproverMap = result.mapOfApproverLevelVsAccountTeam;
          if (result.levels.length > 1) {
            for (let i = 0; i < result.levels.length; i++) {
              console.log('')
              this.levelOptions = [
                ...this.levelOptions,
                {
                  value: result.levels[i],
                  label: result.levels[i]
                }
              ];
            }
            //this.isApprove = true;
          }
        }
        
      })
      .catch((error) => {
        this.isloading = false;
        this.error = error;
      });
  }*/

  

}