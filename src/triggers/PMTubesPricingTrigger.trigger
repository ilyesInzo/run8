/**
* @description PM Tubes Pricing Trigger
* @author Malha A.
* @date 21/01/2019
*/


trigger PMTubesPricingTrigger on PM_Tubes_Pricing__c (before insert) {
    new PMTubesPricingHandler().run();       
}