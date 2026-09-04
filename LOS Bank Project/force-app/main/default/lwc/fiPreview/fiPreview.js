import { LightningElement,api } from 'lwc';

export default class FiPreview extends LightningElement {
@api imagesList;

handleClickDelete(event) {
    this.showSpinner=true;
      const storeEvent = new CustomEvent('myeventdelete', {
        detail: {
            value: event.currentTarget.name
        }
      }
      );
      this.dispatchEvent(storeEvent);
    
}

}