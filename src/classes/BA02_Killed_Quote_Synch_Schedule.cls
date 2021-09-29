global class BA02_Killed_Quote_Synch_Schedule implements Schedulable {
    //Daily  Batches
      
    global void execute(SchedulableContext sc) {
        
         //Plant User Account Team Members
        BA02_Killed_Quote_Synchronisation kqs = new BA02_Killed_Quote_Synchronisation();
        Database.executeBatch(kqs);
        
    }
}