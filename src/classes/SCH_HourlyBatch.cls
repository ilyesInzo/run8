global class SCH_HourlyBatch implements Schedulable {
    //Hourly  Batches
    
    global void execute(SchedulableContext sc) {
   		Database.executeBatch(new BA01_Sales_Team_Sharing_V02(), 50);
   		 	   
     	    
    }
}