trigger PMSelectedDipsensingconfigTrigger on PM_Selected_Dipsensing_config__c (after insert, after update, before insert, before update) {
    new PMSelectedDipsensingconfigTriggerHandler().run();     
}