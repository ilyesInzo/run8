global class SCH_WeeklyBatch implements Schedulable {
    //Weekly Batches
    
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new BA01_Lead_Reminder());
        Database.executeBatch(new BA01_Contract_Reminder());
    }
}