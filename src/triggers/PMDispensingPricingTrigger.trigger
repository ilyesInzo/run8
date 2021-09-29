/**
* @description PM Dispensing Princing Trigger
* @author Malha A.
* @date 20/01/2019
*/

trigger PMDispensingPricingTrigger on PM_Dispensing_Pricing__c (before insert) {
    new PMDispensingPricingHandler().run();       
}