import { LightningElement, api, track } from 'lwc';
import getLoanApplicationDetails from '@salesforce/apex/LANCreationController.getLoanApplicationDetails'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LanCreationComponent extends LightningElement {

    @api loanId;
    @track loanAppRecord={}
    @track loanType
    @track loadLANSection=false
    primaryApplicant={};
    @track collateralDetails = [];
    boolNorecordsFull=false;
    userType;
    isAutomobileView = false;
    isPropertyView = false;
    viewMoreFull = false
    isDetailView = false;
    viewMorePartial = false
    collatralDetailAutomobile;
     collatralDetailProperty;
     linkageDetailAutomobile;
     linkageDetailProperty;
     automobileDetail;
     propertyDetail;
     valuationDetailProperty;
     valuationDetailAutombile
     collateralRecord;


    tablecolumn = [
        {
            label: 'Collateral Id',
            type: 'button',
            typeAttributes:{
                label: {fieldName : 'strCollateralId'},
                variant: 'base'
            }
        },
        {
            label: 'Collateral Type',
            fieldName: 'strCollateralType',
            type: 'text'
    
        },
        {
            label: 'Product Name_ Code',
            fieldName: 'strProductNameCode',
            type: 'text'
    
        },
        {
            label: 'Linkage Type',
            fieldName: 'strCollateralType',
            type: 'text'
    
        },
        {
            label: 'Customer Name',
            fieldName: 'PropertyOwnerName',
            type: 'text'
    
        },
        {
            label: 'Cust ID',
            fieldName: 'strCustomerId',
            type: 'text'
    
        },
        {
            label: 'Linked Account',
            fieldName: 'strAccountNumber',
            type: 'text'
    
        },
        {
            label: 'Relationship',
            fieldName: 'strAccountCustomerRelation',
            type: 'String'
    
        },
        {
            label: 'Value',
            fieldName: 'strTotalCollateralValue',
            type: 'text'
    
        }
    ];
    

    viewMoreHandler(event){    
        this.isLoading = true;
        let recordId = event.detail.row.strCustomerId;
        console.log('%% selected customer id'+recordId);
        //if(card==='full'){
             this.collateralRecord = this.collateralDetails.find((item)=>item.strCustomerId === recordId);
             this.isPropertyView =this.collateralRecord.boolIsProprtyView;
             this.isAutomobileView =this.collateralRecord.boolIsAutomobileView;
             this.isDetailView = 
             this.collatralDetailAutomobile = [{label:'Collateral ID',value:this.collateralRecord.strCollateralId},{label:'Collateral Type',value:this.collateralRecord.strCollateralType},{label:'Product Name Code',value:this.collateralRecord.strProductNameCode},{label:'Collateral Value',value:this.collateralRecord.strTotalCollateralValue},{label:'Collateral Unused Value',value:this.collateralRecord.strCollateralUnusedValue},{label:'Total utilized Value',value:this.collateralRecord.strAmountCollValueCollCcy}];
             this.collatralDetailProperty = [{label:'Collateral ID',value:this.collateralRecord.strCollateralId},{label:'Collateral Type',value:this.collateralRecord.strCollateralType},{label:'Product Name Code',value:this.collateralRecord.strProductNameCode},{label:'Collateral Value',value:this.collateralRecord.strTotalCollateralValue},{label:'Collateral Unused Value',value:this.collateralRecord.strCollateralUnusedValue},{label:'Total utilized Value',value:this.collateralRecord.strAmountCollValueCollCcy},{label:'Property Owner Name',value:this.collateralRecord.strPropertyOwnerName},{label:'Property Title & Type',value:this.collateralRecord.strPropertyType},{label:'Occupancy Type',value:this.collateralRecord.strPropertyType}];
             
             this.linkageDetailAutomobile = [{label:'Linkage Type',value:this.collateralRecord.strCollateralType},{label:'Customer ID',value:this.collateralRecord.strCollateralId},{label:'Customer Name',value:this.collateralRecord.strPropertyOwnerName},{label:'Relationship',value:this.collateralRecord.strAccountCustomerRelation},{label:'Linked Account Number',value:this.collateralRecord.strAccountNumber},{label:'Apportioned Amount',value:this.collateralRecord.strAmountCollValueCollCcy},{label:'POS',value:this.collateralRecord.strCollateralUnusedValue}];
             this.linkageDetailProperty = [{label:'Linkage Type',value:this.collateralRecord.strCollateralType},{label:'Customer ID',value:this.collateralRecord.strCollateralId},{label:'Customer Name',value:this.collateralRecord.strPropertyOwnerName},{label:'Relationship',value:this.collateralRecord.strAccountCustomerRelation},{label:'Linked Account Number',value:this.collateralRecord.strAccountNumber},{label:'Apportioned Amount',value:this.collateralRecord.strAmountCollValueCollCcy},{label:'POS',value:this.collateralRecord.strCollateralUnusedValue}];

             this.automobileDetail = [{label:'Make',value:this.collateralRecord.strMake},{label:'Model',value:this.collateralRecord.strModel},{label:'Mfg Year',value:this.collateralRecord.strManufactureYear},{label:'Chassis Number',value:this.collateralRecord.ChassisNumber},{label:'Engine Number',value:this.collateralRecord.strEngineNumber},{label:'Registration Number',value:this.collateralRecord.strRegistrationNumber}];
             this.propertyDetail = [{label:'House No/Plot No',value:this.collateralRecord.strKhasaraPlotNo},{label:'Address',value:this.collateralRecord.strAddress},{label:'Model',value:this.collateralRecord.strModel},{label:'Taluka',value:this.collateralRecord.strTehsilTaluka},{label:'Village',value:this.collateralRecord.strVillage},{label:'Property Description',value:this.collateralRecord.strPropertyDesc1}];
             
             this.valuationDetailAutombile = [{label:'Valuation date',value:this.collateralRecord.strLastValuationDate},{label:'Valuation Amount',value:this.collateralRecord.strLastValue},{label:'Total Pos',value:this.collateralRecord.strTotalPos}];
             this.valuationDetailProperty = [{label:'Valuation date',value:this.collateralRecord.strLastValuationDate},{label:'Area Unit',value:this.collateralRecord.strAreaUnit},{label:'Land Area',value:this.collateralRecord.strTotalArea},{label:'Construction Value',value:this.collateralRecord.strCostPrice}];
             this.viewMoreFull = true

        //}
        console.log('%% collateralRecord'+JSON.stringify(this.collateralRecord));
        this.isLoading = false;
        //this.viewLess = false;
   }

   showToast() {
    const event = new ShowToastEvent({
        title: '',
        message: 'Details section is not available for selected collateral',
    });
    this.dispatchEvent(event);
}

viewLessHandler(){
    this.viewMoreFull = false
    this.viewMorePartial = false
    this.viewLess = true
}

    

    get showCollateralList(){
        return this.collateralDetails && this.collateralDetails.length > 0
    }
    connectedCallback() {
        this.getLoanDetails();
    }

    getLoanDetails() {
        getLoanApplicationDetails({ loanAppId: this.loanId }).then((data => {
            this.loanAppRecord = data.loan   
            this.primaryApplicant = data.primaryApplicant;
            this.loanType = data.productType;   
            this.userType = data.userType;
            this.loadLANSection=true
        })).catch((error => {
            this.showToast('Error', error.message.body, 'error', 'sticky')
        }))
    }

    getCollateralDetails(event){
        this.collateralDetails = event.detail.collateralDetails;
        if (this.collateralDetails.length === 0) {
            this.boolNorecordsFull = true;
        } else {
            this.boolNorecordsFull = false;
        }
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    showLoanDetailsCmp(){
        this.dispatchEvent(new CustomEvent('displayloandetails'));
    }
}