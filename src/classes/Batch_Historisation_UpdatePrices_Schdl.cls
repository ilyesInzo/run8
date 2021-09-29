global class Batch_Historisation_UpdatePrices_Schdl implements Schedulable {

	global void execute(SchedulableContext sc) {
		
			Batch_Historisation_UpdatePrices b = new Batch_Historisation_UpdatePrices();
		    database.executebatch(b,1);
			
	}
}