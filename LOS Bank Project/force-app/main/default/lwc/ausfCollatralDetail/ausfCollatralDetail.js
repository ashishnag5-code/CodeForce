import { LightningElement, api } from 'lwc';
export default class AusfCollatralDetail extends LightningElement {
    @api collateralList;
    @api sectionTitle
    connectedCallback(){
        console.log('in connected callback '+JSON.stringify(this.collateralList))
    }
}