/*****
 * Trigger Name: PaymentFavouringTrigger
 * Description: Payment Favouring Trigger
 * Test Class Name: PaymentTriggerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Nov-02-2023          -   Mohit M.            -   SFAU-5483 - Invalid Account Number
*/
trigger PaymentFavouringTrigger on Payment__c (before insert, after insert, before update, after update, after delete) {
    new PaymentTriggerHandler().run('Payment__c', 'Payment_Trigger__c');
}