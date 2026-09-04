import { LightningElement, track, api } from 'lwc';
import getInternalBTDetails from '@salesforce/apex/BalanceTransferController.getInternalBTDetails'

export default class BalanceTransferInternalParent extends LightningElement {
    addBT=true;

    @track totalPOS=0
    keyIndex=0;
    @track recordCount=0
    @api loanApp;
    @api collateral
    @api productDetails
    keyId=0
    btMap=new Map()
    collateralVSbtMap=new Map()
    type
    @track btList=[]
    btRecord={}


    connectedCallback(){

        this.type = this.productDetails.get(this.collateral.Product__c).Sub_Product__c
        this.totalPOS=0
        getInternalBTDetails({recordId: this.loanApp.Id}).then((data=>{
            this.btMap = new Map()
            if(data && data.length>0){
                this.keyIndex=0
                data.forEach(input => {
                    input.isSaved=true
                    input.keyId =this.keyIndex
                    this.btMap.set(this.keyIndex, input)
                    if(input.POS__c)
                        this.totalPOS=parseFloat(input.POS__c)+this.totalPOS
                    //this.collateralVSbtMap.set(input.Loan_Number__c, input)
                    this.keyIndex++
                });
                this.btList = Array.from(this.btMap.values())  
                this.addBT=false
                this.recordCount = this.btList.length
            }
            /*this.collateral.forEach(element=>{
                if(!this.collateralVSbtMap.get(element)){
                    console.log('-- '+JSON.stringify(this.productDetails.get(element.Product__c)))
                    var subType = this.productDetails.get(element.Product__c).Sub_Product__c
                    var newElement = {POS__c:element.POS__c, SubType:subType, Loan_Number__c:element.Linked_Account_Number__c,isSaved:true, keyId:this.keyIndex}
                    this.btMap.set(this.keyIndex, newElement)
                    this.keyIndex++
                }
            })*/
            else{
                this.btMap.set(this.keyIndex, {})
                this.btList = Array.from(this.btMap.values()) 
                this.keyId=this.keyIndex;
                this.addBT=false
                this.keyIndex++
            }
        }))
        console.log('initial details '+JSON.stringify(this.btList))
           

    }

    handleAddNewBTInternalRecord(){

        this.keyIndex++
        this.keyId=this.keyIndex;
        this.addBT=true
        this.btMap.set(this.keyIndex, {})
        this.btList = Array.from(this.btMap.values())
        console.log('Schedule list '+JSON.stringify(this.btList))
        this.btRecord={}
        
    }

    @api
    getBTValidation(){
        var isUnsaved;      
        this.btList.forEach(input => {
            if(input.isSaved==false){
                isUnsaved=true
            }
        });   
        this.dispatchEvent(new CustomEvent('bt',{
            detail: {
                template:'BT Internal',
                isUnsaved: isUnsaved,
            }
        }));
            
    }

    calculateTotalPOS(){
        this.totalPOS=0
        this.btList.forEach(element=>{
            if(element.POS__c)
                this.totalPOS=parseFloat(element.POS__c)+this.totalPOS
        })
    }

    handleSave(event){
        console.log('event.data '+JSON.parse(JSON.stringify(event.detail.data)))
        event.detail.data.isSaved = event.detail.isSaved
        event.detail.data.keyId = event.detail.key
        this.btMap.set(event.detail.key, JSON.parse(JSON.stringify(event.detail.data)))
        //this.keyId=event.detail.key;
        this.btList = Array.from(this.btMap.values())
        this.recordCount = this.btList.length
        console.log('Bt list '+JSON.stringify(this.btList))
        this.addBT=false
        this.calculateTotalPOS()

    }

    handleRowAction(event){
        this.addBT=event.detail.isAdd
        event.detail.data.isSaved=event.detail.isSaved
        event.detail.data.keyId = event.detail.key
        this.btMap.set(event.detail.key, JSON.parse(JSON.stringify(event.detail.data)))
        this.btList = Array.from(this.btMap.values())
        if(this.addBT){
            this.btRecord =this.btMap.get(event.detail.key)
            //this.keyId=event.detail.key;

        }
    }

    handleDeleteAction(event){
        this.btMap.delete(event.detail.key)
        this.btList = Array.from(this.btMap.values())
        this.recordCount = this.btList.length
        this.addBT=false
        this.calculateTotalPOS()
    }
}