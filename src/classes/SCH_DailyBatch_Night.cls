global class SCH_DailyBatch_Night implements Schedulable {
    //Daily Night Batches
    
    global void execute(SchedulableContext sc) {
        
         //Calculate net new business
        Database.executeBatch(new BA00_Create_Objective_Rules());

    }
}