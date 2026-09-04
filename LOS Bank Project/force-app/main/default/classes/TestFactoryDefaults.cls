@isTest
public class TestFactoryDefaults {

    /*
    @Description : Default field values for account
    */
    public class AccountDefaults implements TestFactory.FieldDefaults{

        public Map<Schema.SObjectField, Object> getFieldDefaults(){
            return new Map<Schema.SObjectField, Object>{
                    Account.AnnualRevenue => 2000
            };
        }
    }
    public class LoanApplicationDefaults implements TestFactory.FieldDefaults{

        public Map<Schema.SObjectField, Object> getFieldDefaults(){
            return new Map<Schema.SObjectField, Object>{
                    Loan_Application__c.Stage__c => 'QDE'
            };
        }
    }
    public class AssignmentDefaults implements TestFactory.FieldDefaults{

        public Map<Schema.SObjectField, Object> getFieldDefaults(){
            return new Map<Schema.SObjectField, Object>{
                    Assignment__c.Disbursement_Type__c  => 'Full'
            };
        }
    } 
    public class UserDefaults implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults(){
            Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
            return new Map<Schema.SObjectField, Object>{
                    User.FirstName => 'Test',
                    User.LastName => 'User',
                    User.EmployeeNumber => '12345678',
                    User.Username => 'testClass@test.com',
                    User.Email => 'test@gmail.com',
                    User.Alias => 'tuser',
                    User.TimeZoneSidKey => 'America/Los_Angeles',
                    User.EmailEncodingKey => 'UTF-8',
                    User.LanguageLocaleKey => 'en_US',
                    User.LocaleSidKey => 'en_US',
                    User.profileId => profileId,
                    User.IsActive => true
            };
        }
    }
    
    public class ChargeDefaults implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Charge__c.Charges_Name__c => 'Charge 1',
                    //Charge__c.Name => 'Charge 2',
                    Charge__c.Customer_category__c => 'cat 3',
                    Charge__c.Master_Name__c => 'Master',
                    Charge__c.Model_Age__c => 'Test',
                    Charge__c.SC_Code__c => 'Test',
                    Charge__c.Max_Charges_SOC__c => 100,
                    Charge__c.Min_charges__c => 2,
                    charge__c.Actual_rate__c =>100,
                    charge__c.Deviation_Applicable__c => 'Yes'
                    };
                        }
    }
    
    public class DeviationDefaults implements TestFactory.FieldDefaults {
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Deviation__c.Deviation_Type__c => 'Charge 1',
                Deviation__c.Active__c => true,
                    Deviation__c.Level__c => 'S1',
                    Deviation__c.Details__c => 'Charges - Min Level Breached',
                    Deviation__c.Deviation_Type__c => 'SF Dedupe - Same Product'
            };
        }
    }

}