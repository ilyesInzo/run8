trigger PlantSegmentUsersTrigger on Plant_Segment_Users__c(after delete, after insert) {
	new PlantSegmentUsersTriggerHandler().run();
}