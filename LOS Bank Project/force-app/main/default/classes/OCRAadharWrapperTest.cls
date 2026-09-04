@isTest
public class OCRAadharWrapperTest {
    @isTest
    public static void OCRAadharResponseWrapperTest(){
        OCRAadharResponseWrapper OCRRespWrapper=new OCRAadharResponseWrapper();
        OCRRespWrapper.ServiceExecutionStatus='ERROR';
        OCRAadharResponseWrapper.AdditionalDetails additionalDetails=new OCRAadharResponseWrapper.AdditionalDetails();
        OCRAadharResponseWrapper.InputMaskStatus inpMaskStatus=new OCRAadharResponseWrapper.InputMaskStatus();
        OCRAadharResponseWrapper.addressSplit addressSplit=new OCRAadharResponseWrapper.addressSplit();
        OCRAadharResponseWrapper.CareOfDetails careOfDetail=new OCRAadharResponseWrapper.CareOfDetails();
        careOfDetail.relation='R1';
        careOfDetail.name='N1';
        addressSplit.building='B1';
        addressSplit.city='C1';
        addressSplit.district='D1';
        addressSplit.building='B1';
        addressSplit.house='H1';
        addressSplit.locality='L1';
        addressSplit.state='S1';
        addressSplit.street='ST1';
        addressSplit.complex='C1';
        addressSplit.landmark='LD1';
        addressSplit.untagged='UT1';
        
        inpMaskStatus.isMasked=true;
        inpMaskStatus.maskedBy=null;
        inpMaskStatus.confidence=null;
        
        additionalDetails.inputMaskStatus=inpMaskStatus;
        additionalDetails.outputMaskStatus=true;
        additionalDetails.verhoeffCheck=true;
        additionalDetails.qr='Q1234';
        additionalDetails.barcode=null;
        additionalDetails.addressSplit=addressSplit;
        additionalDetails.CareOfDetails=careOfDetail;
    }
}