trigger QuoteTrigger on Quote (before insert, before update,before delete ) {
    new QuoteTriggerHandler().run();
}