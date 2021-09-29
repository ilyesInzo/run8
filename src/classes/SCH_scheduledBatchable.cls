global class SCH_scheduledBatchable implements Schedulable {
   global void execute(SchedulableContext sc) {
   
      Database.executeBatch(new BA01_Objective_Rules(),100);
      Database.executeBatch(new BA01_Objective_KAM_SharingRules(),100);
      Database.executeBatch(new BA01_Objective_Plant_SharingRules(),100);
      //Database.executeBatch(new BA01_Objective_Rules_LostRetention());
   }
}