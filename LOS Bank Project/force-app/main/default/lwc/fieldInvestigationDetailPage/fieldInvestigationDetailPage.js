import { LightningElement, api, track } from 'lwc';

export default class RecordEditFormCreateExampleLWC extends LightningElement {

    @api recordId;
    isRemarksMandatory = false;
    isAddressMandatory = false;
    showQuestionnaireLink = false;
    @track currentLocation;

    

  handleConditions(event) {
        if (event.target.fieldName == 'Opening_Remarks__c') {
            if (event.target.value == 'Customer Not Interested' || event.target.value == 'Address Not Traceable') {
                this.isRemarksMandatory = true;
                this.showQuestionnaireLink = false;

            }
            else if (event.target.value == 'Lets Start') {
                this.isRemarksMandatory = false;
                this.showQuestionnaireLink = true;
            }
            //when Opening remarks is Door lockedß
            else {
                this.showQuestionnaireLink = false;
                this.isRemarksMandatory = false;
            }
        }
        if (event.target.fieldName == 'Address_match__c') {
            if (event.target.value == 'No') {
                this.isAddressMandatory = true;
            }
            else {
                this.isAddressMandatory = false;

            }
        }



    }
    getCurrentDateTime() {
        var today = new Date();
        var todayDate = String(today.getDate()).padStart(2, '0');
        var todayMonth = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var year = today.getFullYear();
        var currentOffset = today.getTimezoneOffset();

        var ISTOffset = 330;   // IST offset UTC +5:30 

        var ISTTime = new Date(today.getTime() + (ISTOffset + currentOffset) * 60000);

        // ISTTime now represents the time in IST coordinates

        var hh = ISTTime.getHours();
        var m = ISTTime.getMinutes();
        var s = ISTTime.getSeconds();
        var dd = "am";
        var h = hh;
        if (h >= 12) {
            h = hh - 12;
            dd = "pm";
        }
        if (h == 0) {
            h = 12;
        }
        m = m < 10 ? "0" + m : m;

        s = s < 10 ? "0" + s : s;
        var replacement = h + ":" + m;
        replacement += " " + dd;
        console.log('replacement>>>>' + replacement);
        var currentDateTime = todayDate + '/' + todayMonth + '/' + year + ', ' + replacement;
        console.log('this.currentDate>>>>' + this.currentDateTime);
        return currentDateTime;


    }

    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
    }

    onSubmitHandler(event) {
        event.preventDefault();
        // Get data from submitted form
        const fields = event.detail.fields;
        // Here you can execute any logic before submit
        // and set or modify existing fields
        fields.FI_Submission_Date_Time__c = this.getCurrentDateTime();
        // You need to submit the form after modifications
        console.log('onsubmit event recordEditForm>>' + JSON.stringify(event.detail.fields));

        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }


    navigateWithoutAura() {
        let cmpDef = {
            componentDef: "c:fieldInvestigationQuestionaire"
        };

        let encodedDef = btoa(JSON.stringify(cmpDef));
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/one/one.app#" + encodedDef
            }
        });
    }

    connectedCallback() {
       
        this.geolocation();
    }

    geolocation() {
        var latitude;
        var longitude;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {

                // Get the Latitude and Longitude from Geolocation API
                latitude = position.coords.latitude;
                longitude = position.coords.longitude;
                // Add Latitude and Longitude to the markers list.

                this.currentLocation = 'Lat:' + latitude + ',' + 'Long:' + longitude;
                console.log('123currentLocation>>>' + this.currentLocation);

            });
        }
    }

}