trigger TaskTrigger on Task (after insert,after update,before insert,before update) {
	new TaskTriggerHandler().run(); 
}