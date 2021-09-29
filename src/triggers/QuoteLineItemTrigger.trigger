trigger QuoteLineItemTrigger on QuoteLineItem (before insert, after insert, before update,after update,before delete) {
    new QuoteLineItemTriggerHandler().run();

    
}