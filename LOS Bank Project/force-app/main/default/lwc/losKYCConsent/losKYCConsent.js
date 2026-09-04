import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import initLanguage from '@salesforce/apex/LosKYCConsent.initLanguage';
import saveDocUrl from '@salesforce/apex/LosKYCConsent.saveDocUrl';
import FORM_FACTOR from "@salesforce/client/formFactor";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LosKYCConsent  extends NavigationMixin(LightningElement) {
    @api kyctype;
    @api applicantId;
    smartPhoneKYC;

    error;
    @track languageValue;
    contentDocId = "";
    titleToContDocumIdMap;
    nameToAudioFileMap;
    audioFileUrl;
    consentDocUrl;
    docUrl;
    deviceType;
    @track languageOptions = [{label : 'None', value : ''}];
    audioSrc;
    isPlaying = false;
    audioLoaded = false;
    audioElement;
    currentTimePercentage = 0;
    lastPosition = 0;
    volume = 100;
    addMargin = true;
    @api consent;

    connectedCallback(){
        if(this.kyctype == 'Aadhaar - Smartphone KYC'){
            this.smartPhoneKYC = true;
        }else{
            this.smartPhoneKYC = false;
        }
        console.log('consent in consent comp: ', this.kyctype);
        this.handleFormFactor();
        this.initLanguageInputFLd();
     //   this.addCssForMobile();
    }

    initLanguageInputFLd() {
        initLanguage()
            .then(result => {
                let data = result;
                this.titleToContDocumIdMap  = result.titleToContDocumId;
                this.nameToAudioFileMap     = result.nameToAudioFileUrl;
             /*   this.languageOptions = data.languageOpt.map(opt => ({label : opt.language, value : opt.language, consentAudioFile : opt.consentAudioFile, 
                                                                    consentDocument : opt.consentDocument})); */
             let langOpt = [];
              for(let obj of data.languageOpt) {          
                    langOpt.push({ label : obj.language, value : obj.language, consentAudioFile : obj.consentAudioFile,
                                 consentDocument : obj.consentDocument, publicUrlForConsentDoc : obj.publicUrlForConsentDoc});
               }
               this.languageOptions = langOpt;
               this.languageValue = langOpt[0].value;
               let obj = {detail : {value : this.languageValue}};
               this.setAudioAndDocUrl(obj);
               this.updateApplicant();
            })
            .catch(error => {
                this.error = error;
                console.log("Error inside initLanguageInputFLd-- "+error);
            });
    }

  /*  addCssForMobile() {
        if(this.deviceType == "Desktop/Laptop") {
            let timeout = setTimeout(() => {
                let getCombobox = this.template.querySelector(`[data-id="consentCombobox"]`);
                getCombobox.classList.add("marginCombobox");
            },5);
            
        }
    }  */

    renderedCallback() {
        if(this.addMargin) {
            if(this.deviceType == "Mobile") {
                let getCombobox = this.template.querySelector(`[data-id="consentCombobox"]`);
                getCombobox.classList.add("slds-m-bottom_x-small");
                this.addMargin = false;
            }
        }  
    }

    handleFormFactor() {
        if (FORM_FACTOR === "Large") {
            this.deviceType = "Desktop/Laptop";
        } else if (FORM_FACTOR === "Medium") {
            this.deviceType = "Tablet";
        } else if (FORM_FACTOR === "Small") {
            this.deviceType = "Mobile";
        }
    }

    handleLanguageChange(evt) {

        this.setAudioAndDocUrl(evt);
        this.updateApplicant();
    }

    setAudioAndDocUrl(evt) {
        this.languageValue = evt.detail.value;   
        let contentDocLst  = this.languageOptions.filter(option => option.value == this.languageValue);
        let consentDoc     = contentDocLst[0].consentDocument;
        this.consentDocUrl = contentDocLst[0].publicUrlForConsentDoc;

        let audioFile = contentDocLst[0].consentAudioFile;
        this.audioFileUrl = this.nameToAudioFileMap[audioFile];
        this.docUrl = this.titleToContDocumIdMap[consentDoc];
    }

   /* showConsentDoc(event) {
        // Naviagation Service to the show preview
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: this.contentDocId // '0696s0000014CnRAAU'
            }
        })
    }
    /*
    handlePlayPause(e) {
        console.log('handle play pause');
        this.audioSrc = 'https://ausfb2022--dev1--c.sandbox.vf.force.com/resource/1668060009000/ConsentEnglish';
        if (this.audioElement === undefined) {
            this.audioElement = this.template.querySelector("audio");
        }
        this.isPlaying = !this.isPlaying;

        if (this.isPlaying) {
            console.log('play');
            if (!this.audioLoaded) {
                this.audioElement.load();
            }

            this.audioElement.play();

           
        } else {
            console.log('pause');
            this.audioElement.pause();
        }
    }
    */
    get playPauseIcon() {
        if (this.isPlaying) {
            return "utility:pause";
        }
        return "utility:play";
    }

    get playPauseAltText() {
        if (this.isPlaying) {
            return "Pause";
        }
        return "Play";
    }

    get currentTime() {
        return this.audioElement.currentTime;
    }

    get totalTime() {
        return this.audioElement.duration;
    }

    get currentTimeFormatted() {
        let minutes = Math.floor(this.audioElement.currentTime / 60);
        let seconds = this.audioElement.currentTime - minutes * 60;
        return `${minutes}:${
            seconds < 10 ? "0" + seconds.toFixed(0) : seconds.toFixed(0)
        }`;
    }

    get totalTimeFormatted() {
        let minutes = Math.floor(this.audioElement.duration / 60);
        let seconds = this.audioElement.duration - minutes * 60;
        return `${minutes}:${
            seconds < 10 ? "0" + seconds.toFixed(0) : seconds.toFixed(0)
        }`;
    }

    handlePlayPause(e) {
        console.log('inside handlePlayPause');
        if (this.audioElement === undefined) {
            this.audioElement = this.template.querySelector("audio");
        }
        this.isPlaying = !this.isPlaying;

        if (this.isPlaying) {
            if (!this.audioLoaded) {
                this.audioLoaded = true;
                this.audioElement.load();
            }

            this.audioElement.play();

            if (this.lastPosition !== 0) {
                console.log(
                    "setting time to last position: " + this.lastPosition
                );
                this.audioElement.currentTime = this.lastPosition;
            }
        } else {
            this.audioElement.pause();
        }
    }

    handleSkipForward(e) {
        this.audioElement.currentTime += 15;
    }

    handleSkipBack(e) {
        this.audioElement.currentTime -= 15;
    }

    handleOnTimeUpdate(e) {
        this.currentTimePercentage =
            (this.audioElement.currentTime / this.audioElement.duration) * 100;
    }

    handleOnPause(e) {
        console.log("paused at " + this.currentTime);
        this.lastPosition = this.currentTime;
    }

    get audioSrc() {
        return 'https://ausfb2022--dev1--c.sandbox.vf.force.com/resource/1668060009000/ConsentEnglish';
    }

    handleConsentValue(event) {
        this.consent = event.target.checked;
       // document.getElementsByName('aadhaarVerification').consent = this.consent;
        console.log('consent value is:', event.target.checked);
        this.dispatchEvent(new CustomEvent('setconsent', {
            detail: {
                consent : this.consent
            }
        }));
    }

    updateApplicant() {
        saveDocUrl({ applicantId: this.applicantId, docUrl: this.docUrl })
            .then(result => {
                console.log("inside saveDocUrl of result--"+result);
            })
            .catch(error => {
                this.error = error;
                console.log("Inside saveDocUrl"+error);
            });
    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: mode,
            message: message
        });
        this.dispatchEvent(event);
    }
}