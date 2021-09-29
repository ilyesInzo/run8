global class SCH_DailyObjectiveSharingRules implements Schedulable {
    //Daily  Batches for Objectives Sharing Rules
    
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new BA01_Objective_KAM_SharingRules(),100);
      
    }
}