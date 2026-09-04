@isTest
public class ChargeTriggerServiceTest {
	@testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1', Type='Queue' ),true); 
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount', Account_Code__c='2103', Branch_Queue__c=grp.Id ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345', Adhar_Card__c   = 123456, Loan_Amount__c  = 1000, Product__c='10201', Customer_Type__c='Individual',
            Stage__c ='DDE', EMI_Date__c = '10/3/2022', Tenure__c = 10, Branch_Master__c = accInstance.Id ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash', Middle_Name__c = 'Kumar', Last_Name__c = 'Mandal', CIF_No__c = '576321', Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId() ),true);
        
        Address__c  addInstance1 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline11', Address_Line_2__c ='TestAddressline22', Address_Line_3__c ='TestAddressline33',
            State__c='MAHARASHTRA', City__c='EAST DELHI', Area_Name__c='JAGJIT NAGAR', Area_Type__c='Urban', Taluka__c='NA', Pincode__c='110053',
            Land_mark__c='Testing', Applicant__c =appl.Id, Status__c='Owned', Address_Type__c='Permanent', Type__c='Bungalow' ),true);
        
        List<Deviation__c> devList = New List<Deviation__c>();
        Deviation__c dev1 = (Deviation__c)TestFactory.createSObject(new Deviation__c(Loan_application__c = loanAppl.id,
                            Deviation_Type__c = 'Charges - Min Level Breached'),'TestFactoryDefaults.DeviationDefaults', false);
        devList.add(dev1);
        Deviation__c dev2 = (Deviation__c)TestFactory.createSObject(new Deviation__c(Loan_application__c = loanAppl.id,
                            Deviation_Type__c = GlobalConstants.LS_CHARGE_DEVIATION_NAME),'TestFactoryDefaults.DeviationDefaults', false);
        devList.add(dev2);
        insert devList;
        
        List<Charge__c> chargeList = New List<Charge__c>();
        Charge__c add2 = (Charge__c)TestFactory.createSObject(new Charge__c(Loan_Application__c = loanAppl.id,Value_Type__c='Percent',
            Charge_Amount__c = 200,Rate_value_As_per_Policy__c = 400, Charges_Name__c = GlobalConstants.PF_CHARGE),'TestFactoryDefaults.ChargeDefaults', false);
        chargeList.add(add2);
        Charge__c add3 = (Charge__c)TestFactory.createSObject(new Charge__c(Loan_Application__c = loanAppl.id,Value_Type__c='Fixed',
            Charge_Amount__c = 200,Rate_value_As_per_Policy__c = 400, Charges_Name__c = GlobalConstants.LS_CHARGE),'TestFactoryDefaults.ChargeDefaults', false);
        chargeList.add(add3);
        Charge__c add4 = (Charge__c)TestFactory.createSObject(new Charge__c(Loan_Application__c = loanAppl.id,Value_Type__c='Fixed',
            Charge_Amount__c = 400,Rate_value_As_per_Policy__c = 200, Charges_Name__c = GlobalConstants.LS_CHARGE),'TestFactoryDefaults.ChargeDefaults', false);
        chargeList.add(add4);
        insert chargeList;
    }
    
    @isTest
    static void chargeTest(){
        List<Deviation__c> devList = [SELECT Active__c, Actual_Value__c, Archived__c, BRE_Response__c, CreatedById, CreatedDate, 
                                      Days_left_for_Insurance_Expiry__c, Department__c, Details__c, Deviation_Type__c, Field_Investigation__c, 
                                      Id, IsDeleted, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, 
                                      Level_Priority__c, Level__c, Loan_Application__c, Mitigates__c, Name, Policy_Value__c, 
                                      Remarks__c, Request_Time__c, Return_to_PSD_Motor_Ins__c, Source__c, Stage__c, SystemModstamp, 
                                      Variance__c FROM Deviation__c];
        List<Charge__c> chargeList = [Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                                      SystemModstamp, Loan_Application__c, Actual_rate__c, Charge_Amount__c, Charges_Name__c, 
                                      Customer_category__c, Dedn_Cod__c, Deviation_Applicable__c, Master_Name__c, Max_Charges_SOC__c, 
                                      Min_charges__c, Model_Age__c, Rate_value_As_per_Policy__c, SC_Code__c, Sequence_NO__c, 
                                      Sequence_Number__c, Shown_to_UI__c, Tax_Amount__c, Tax_Applicable__c, Tax_Percentage__c, 
                                      Total_Amount__c, Value_Type__c, External_Id_For_Upsert__c from Charge__c];
        ChargeTriggerService charge = New ChargeTriggerService();
        charge.beforeInsert(chargeList);
        charge.beforeUpdate(chargeList,null,null);
        charge.beforeDelete(null);
        charge.afterDelete(null);
        charge.afterUndelete(null);
        ChargeTriggerService.checkIfDeviationNeedToUpdated('P123','P123');
        ChargeTriggerService.markApplicationChargeChangedFlag(chargeList,null);
        for(Charge__c cha: chargeList){
            cha.Min_charges__c = 4;
        }
        update chargeList;
    }
}