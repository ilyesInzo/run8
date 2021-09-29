global class Batch_Manage_SecurityEinstein implements Database.Batchable<sObject> {
	
	String query='select id,Product_Sub_Segment_List__c, Plant_List__c,( select id, RecordType.Name, Plant_and_Cluster__r.Plant_Code__c, Product__r.ProductCode from Plant_Segment_Users__r) from User where Profile.Name=\'Plant\' or  Profile.Name=\'Marketing\'';
	
	global Batch_Manage_SecurityEinstein() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	
	    Manage_Einstein_Security.InitialLoad(scope);

	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('Finish');
	}
	
}