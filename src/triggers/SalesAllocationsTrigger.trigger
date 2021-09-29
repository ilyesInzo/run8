trigger SalesAllocationsTrigger on Sales_Allocations__c (before insert, before update) {
    new SalesAllocationsTriggerHandler().run();
}