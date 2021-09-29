global class PlantUserAccOppTeam_Sched implements Schedulable {
   global void execute(SchedulableContext sc) {
   
      
      Id batchJobId = Database.executeBatch(new PlantUserAccOppTeam_Batch(), 200);
   }
}