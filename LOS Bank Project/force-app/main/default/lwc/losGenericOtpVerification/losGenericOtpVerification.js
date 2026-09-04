import { LightningElement, track,api } from 'lwc';

export default class LosGenericOtpVerification extends LightningElement {

    @api isShowModal =false;
    @api boolResendOtp = false;
    @api boolIsDisableVerifyButton = false;
    @track increse1Second=27;

    showModalBox(){
        this.isShowModal = true;
        this.boolIsDisableVerifyButton = false;
        this.set27SecondTimer();
        this.boolResendOtp = false;
    }

    hideModalBox(){
        this.isShowModal = false;
        const showModelEvent = new CustomEvent ( "getmodelvalue",{
            detail:this.showModel
        });

        this.dispatchEvent(showModelEvent);
    }

    handleResendOTP(){
        this.otpCode = String(parseInt(Math.random() * 600000));
        if(this.otpCode.length == 5){
            this.otpCode +='0' ;
        }
        console.log('OTP'+this.otpCode);
        this.boolResendOtp = false;
        this.set27SecondTimer();
    }
    

    @api
    set27SecondTimer(){
        this.increse1Second=27;
        this.secondTimeInterval =   setInterval(() => {
            this.increse1Second -= 1;                            
         }, 1000);
        setTimeout(()=> {
            window.clearInterval(this.secondTimeInterval);
            this.boolResendOTP = true;
        }, 27000);
    }

    handleOTPVerify(event){
        if(event.detail.value.length == 6 ){
            this.enterOTPValue = event.detail.value;
            this.boolIsDisableVerifyButton=false;
        }
    }

    handleOTPVerification(){

    }

}