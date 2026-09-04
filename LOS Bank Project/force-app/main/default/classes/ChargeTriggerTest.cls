@isTest
public class ChargeTriggerTest {

    @testSetup static void setup() {
        
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Four_Wheeler').getRecordTypeId()
        ),true);

        Loan_Application__c tractorLoan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'TR-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10501',
            Stage__c='Credit',
            Collateral_Type__c='10109',
            RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Tractor').getRecordTypeId()
        ),true);

        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Customer_Type__c ='Individual',
            Residential_Status__c ='Resident',
            Loan__c =loanAppl.Id            
        ),true);
        
        Deviation__c devs= new Deviation__c(
        Deviation_Type__c = 'Charges - Min Level Breached',
        Active__c=true  ,Loan_application__c=  loanAppl.Id
        );     
        insert devs;
        Deviation__c pfDeviation = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Deviation_Type__c = GlobalConstants.PF_CHARGE_DEVIATION_NAME,
            Active__c=true, 
            Loan_application__c= loanAppl.Id
        ),true);
        Deviation__c dcDeviation = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Deviation_Type__c = GlobalConstants.DC_CHARGE_DEVIATION_NAME,
            Active__c=true, 
            Loan_application__c= loanAppl.Id
        ),true);
        Deviation__c dcDeviationTR = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Deviation_Type__c = GlobalConstants.DC_CHARGE_DEVIATION_NAME,
            Active__c=true, 
            Actual_Value__c=500,
            Loan_application__c= tractorLoan.Id
        ),true);
        
        
        
    }
    
    @isTest static void validateAfterInsert() {

        List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c WHERE Application_Number__c = 'AP-12345' LIMIT 1];  
        
        // Charge__c ch= new Charge__c(Value_Type__c = 'Fixed',Deviation_Applicable__c='Yes',
        //             Charge_Amount__c=200,Rate_value_As_per_Policy__c=675,
        //                             Actual_rate__c=270, Loan_Application__c  =loanApps[0].Id
        //                            );
        
        List<Charge__c> chargeRec = new List<Charge__c>();
        for(Integer i=0;i<4;i++) {
            Charge__c chg = new Charge__c();
            chg.Total_Amount__c = 100;
            chg.Loan_Application__c = loanApps[0].Id;
            chg.Charges_Name__c = (i==0)?'Processing Fees':(i==1)?'Documentation Charges':(i==2)?'LS Charges':'Other Charges';
            chargeRec.add(chg);
        }
        insert chargeRec;

        System.Test.startTest();
        // insert new List<Charge__c>{ch};
            
        List<Deviation__c> devs = [SELECT Id, Actual_Value__c FROM Deviation__c WHERE Loan_Application__c=:loanApps[0].Id LIMIT 1];
        Assert.areEqual(devs[0].Actual_Value__c, chargeRec[0].Charge_Amount__c, 'Trigger could not update the deviation\'s Actual_Value__c');
            
        System.Test.stopTest();
    }
    
    @isTest static void validateAfterInsertWithPercentCharge() {
        
        List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c WHERE Application_Number__c='AP-12345' LIMIT 1];  
        
        // Charge__c ch = new Charge__c(Value_Type__c = 'Percent',Deviation_Applicable__c='Yes',
        //             Charge_Amount__c=300,Rate_value_As_per_Policy__c=775,
        //                             Actual_rate__c=370, Loan_Application__c  =loanApps[0].Id
        //                            );
        
        List<Charge__c> chargeRec = new List<Charge__c>();
        for(Integer i=0;i<4;i++) {
            Charge__c chg = new Charge__c();
            chg.Total_Amount__c = 100;
            chg.Loan_Application__c = loanApps[0].Id;
            chg.Charges_Name__c = (i==0)?'Processing Fees':(i==1)?'Documentation Charges':(i==2)?'LS Charges':'Other Charges';
            chargeRec.add(chg);
        }
        insert chargeRec;

        System.Test.startTest();
        // insert new List<Charge__c>{ch};
            
        List<Deviation__c> devs = [SELECT Id, Actual_Value__c FROM Deviation__c WHERE Loan_Application__c=:loanApps[0].Id LIMIT 1];
        Assert.areEqual(devs[0].Actual_Value__c, chargeRec[0].Actual_rate__c, 'Trigger could not update the deviation\'s Actual_Value__c');
            
        System.Test.stopTest();
    }
    
    @isTest static void validateAfterUpdate() {
        
        List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c WHERE Application_Number__c='AP-12345' LIMIT 1];  
        
        List<Charge__c> chargeRec = new List<Charge__c>();
        for(Integer i=0;i<4;i++) {
            Charge__c chg = new Charge__c();
            chg.Total_Amount__c = 100;
            chg.Loan_Application__c = loanApps[0].Id;
            chg.Charges_Name__c = (i==0)?'Processing Fees':(i==1)?'Documentation Charges':(i==2)?'LS Charges':'Other Charges';
            chargeRec.add(chg);
        }
        insert chargeRec;
        
        System.Test.startTest();
        
        List<Deviation__c> devs = [SELECT Id, Actual_Value__c FROM Deviation__c WHERE Loan_Application__c=:loanApps[0].Id LIMIT 1];
        Assert.areEqual(devs[0].Actual_Value__c, chargeRec[0].Charge_Amount__c, 'Trigger could not update the deviation\'s Actual_Value__c during update');
            
        System.Test.stopTest();
    }

    @isTest static void validateTractorChargeAfterUpdate() {
        
        List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c WHERE Application_Number__c='TR-12345' LIMIT 1];  
        
        List<Charge__c> chargeRec = new List<Charge__c>();
        for(Integer i=0;i<3;i++) {
            Charge__c chg = new Charge__c();
            chg.Total_Amount__c = 100;
            chg.Rate_value_As_per_Policy__c=600;
            chg.Charge_Amount__c=500;
            chg.Value_Type__c='Fixed';
            chg.Deviation_Applicable__c='Yes';
            chg.Loan_Application__c = loanApps[0].Id;
            chg.Charges_Name__c = (i==0)?'Other Charges':(i==1)?'Documentation Charges':(i==2)?'LS Charges':'';
            chargeRec.add(chg);
        }
            Charge__c chg = new Charge__c();
            chg.Total_Amount__c = 1;
            chg.Rate_value_As_per_Policy__c=1;
            chg.Actual_Rate__c=1;
            chg.Charge_Amount__c=0.5;
            chg.Value_Type__c='Percent';
            chg.Deviation_Applicable__c='Yes';
            chg.Loan_Application__c = loanApps[0].Id;
            chg.Charges_Name__c = 'Processing Fees';
            chargeRec.add(chg);
            insert chargeRec;
        
        System.Test.startTest();
        
        List<Charge__c> charges = [SELECT Id, Charges_Name__c FROM Charge__c WHERE Loan_Application__c=:loanApps[0].Id];
        for(Charge__c charge: charges){
            if(charge.Charges_Name__c!='Processing Fees'){
                charge.Rate_value_As_per_Policy__c=700;
            }
        }
        update charges;
        List<Deviation__c> devs = [SELECT Id, Actual_Value__c FROM Deviation__c WHERE Loan_Application__c=:loanApps[0].Id LIMIT 1];
        Assert.areEqual(devs[0].Actual_Value__c, chargeRec[0].Charge_Amount__c, 'Trigger could not update the deviation\'s Actual_Value__c during update');
            
        System.Test.stopTest();
    }

    @isTest static void validateTractorAfterChargeAmtIncrease() {
        
        List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c WHERE Application_Number__c='TR-12345' LIMIT 1];  
        
        List<Charge__c> chargeRec = new List<Charge__c>();
        for(Integer i=0;i<3;i++) {
            Charge__c chg = new Charge__c();
            chg.Total_Amount__c = 100;
            chg.Rate_value_As_per_Policy__c=100;
            chg.Charge_Amount__c=500;
            chg.Value_Type__c='Fixed';
            chg.Deviation_Applicable__c='Yes';
            chg.Loan_Application__c = loanApps[0].Id;
            chg.Charges_Name__c = (i==0)?'Other Charges':(i==1)?'Documentation Charges':(i==2)?'LS Charges':'';
            chargeRec.add(chg);
        }
        insert chargeRec;
        System.Test.startTest();
        
        List<Charge__c> charges = [SELECT Id, Charges_Name__c FROM Charge__c WHERE Loan_Application__c=:loanApps[0].Id];
        List<Deviation__c> devs = [SELECT Id, Actual_Value__c FROM Deviation__c WHERE Loan_Application__c=:loanApps[0].Id LIMIT 1];
        Assert.areEqual(devs[0].Actual_Value__c, chargeRec[0].Charge_Amount__c, 'Trigger could not update the deviation\'s Actual_Value__c during update');
        ChargeTriggerService objChargeTriggerService = new ChargeTriggerService();
        objChargeTriggerService.beforeDelete(new Map<Id,sObject>());
        objChargeTriggerService.afterDelete(new Map<Id,sObject>());
        objChargeTriggerService.afterUndelete(new Map<Id,sObject>());
        System.Test.stopTest();
    }

  

    
}