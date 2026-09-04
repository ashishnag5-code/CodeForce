import { LightningElement, api } from 'lwc';

export default class AusfDetailCardTile extends LightningElement {
    @api sectionTitle;
    @api collateralList;
}