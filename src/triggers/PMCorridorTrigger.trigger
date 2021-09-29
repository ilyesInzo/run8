/**
* @description PM Corridor Trigger
* @author Malha A.
* @date 21/01/2019
*/


trigger PMCorridorTrigger on PM_Discount_corridor__c (before insert) {
    new PMCorridorHandler().run();
}