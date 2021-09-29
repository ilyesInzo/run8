trigger PMSelectedTubesConfigTrigger on PM_Selected_Tubes_Config__c (after insert, after update, before insert, before update) {
	new PMSelectedTubesConfigTriggerHandler().run();   	 
}