trigger OpportunityTrigger on Opportunity (before update, before insert, after insert) {
    new OpportunityTriggerHandler().run();
}