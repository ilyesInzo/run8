public class Batch_Historisation_UncheckDispPricing implements Database.Batchable<sObject>, Database.Stateful { 
	String query;

	public Batch_Historisation_UncheckDispPricing(){     
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'Select Id, Closed_Price__c From PM_Dispensing_Pricing__c where Closed_Price__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<PM_Dispensing_Pricing__c> scoope) {
        System.debug('@@@@ scoope: '+ scoope);
        if (scoope!= null && scoope.size()> 0){
              Batch_Historisation_UpdatePrices_Helper helper = new Batch_Historisation_UpdatePrices_Helper();
              helper.updateDispensingPricing(scoope);
             

        }
    }

    public void finish(Database.BatchableContext BC) {

        Batch_Historisation_UncheckTubesPricing b = new Batch_Historisation_UncheckTubesPricing();
        database.executebatch(b);
    }

}