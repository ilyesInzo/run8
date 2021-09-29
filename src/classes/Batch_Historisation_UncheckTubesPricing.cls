public class Batch_Historisation_UncheckTubesPricing implements Database.Batchable<sObject>, Database.Stateful { 
	String query;

	public Batch_Historisation_UncheckTubesPricing(){     
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'Select Id, Closed_Price__c From PM_Tubes_Pricing__c where Closed_Price__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<PM_Tubes_Pricing__c> scoope) {
        System.debug('@@@@ scoope: '+ scoope);
        if (scoope!= null && scoope.size()> 0){
              Batch_Historisation_UpdatePrices_Helper helper = new Batch_Historisation_UpdatePrices_Helper();
              helper.updateTubesPricing(scoope);
             
        }
    }

    public void finish(Database.BatchableContext BC) {

          Batch_Historisation_UpdateCorridors b = new Batch_Historisation_UpdateCorridors();
          database.executebatch(b,1);
    }

}