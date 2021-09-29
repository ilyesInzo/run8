trigger SalesTeamTrigger on Sales_Team__c (before insert, before update, after update) {
    new SalesTeamTriggerHandler().run();
}