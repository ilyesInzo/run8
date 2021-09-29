trigger AccountTrigger on Account (before insert, before update, after insert) {
    new AccountTriggerHandler().run();
}