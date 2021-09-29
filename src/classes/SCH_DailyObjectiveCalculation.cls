global class  SCH_DailyObjectiveCalculation implements Schedulable {
    //Daily  Batche for Objectives Calculation
    
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new BA00_Create_Objective_Rules());
       
    }
}