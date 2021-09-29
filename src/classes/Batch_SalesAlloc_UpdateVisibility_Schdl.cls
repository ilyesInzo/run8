global class Batch_SalesAlloc_UpdateVisibility_Schdl implements Schedulable {

	global void execute(SchedulableContext sc) {
				
		    database.executebatch(new Batch_SalesAlloc_UpdateVisibility(),50);
			
	}
}