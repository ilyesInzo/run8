global class SCH_DailyBatch implements Schedulable {
    //Daily  Batches
    
    global void execute(SchedulableContext sc) {
        
         //Plant User Account Team Members
        Database.executeBatch(new PlantUserAccOppTeam_Batch());
    }
}