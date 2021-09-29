public class Batch_Historisation_UncheckCorridors implements Database.Batchable<sObject>, Database.Stateful { 
	String query;

	public Batch_Historisation_UncheckCorridors(){     
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'Select Id, Closed_Price__c From PM_Discount_corridor__c where Closed_Price__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<PM_Discount_corridor__c> scoope) {
        System.debug('@@@@ scoope: '+ scoope);
        if (scoope!= null && scoope.size()> 0){
              Batch_Historisation_UpdateCorr_Helper helper = new Batch_Historisation_UpdateCorr_Helper();
              helper.updateCorridors(scoope); 
             

        }
    }

    public void finish(Database.BatchableContext BC) {
    }

}