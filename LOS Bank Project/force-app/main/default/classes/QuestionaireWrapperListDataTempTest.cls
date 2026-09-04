@isTest
public class QuestionaireWrapperListDataTempTest {
    testmethod static void main(){
        QuestionaireWrapperListDataTemp obj = new QuestionaireWrapperListDataTemp();
        QuestionaireWrapperTemp objQWT = new QuestionaireWrapperTemp();
        objQWT.helpText = 'String';
        objQWT.apiName = 'String';
        objQWT.addressType = 'String';
        objQWT.autoLoan = true;
        objQWT.borrower = true;
        objQWT.coBorrower = true;
        objQWT.current = true;
        objQWT.guarantor = true;
        objQWT.isMandatory = true;
        objQWT.isMandatoryForVehicle = true;
        objQWT.office = true;
        objQWT.permanent = true;
        objQWT.section = 'String';
        objQWT.twoWheeler = true;
        objQWT.vehicle = true;
        obj.BorrowerList = new List<QuestionaireWrapperTemp>{objQWT};
        obj.VehicleList = new List<QuestionaireWrapperTemp>{objQWT};
    }
}