trigger ObjectiveLineTrigger on Objective_Lines__c (before insert) {
	new ObjectifLineTriggerHandler().run();
}