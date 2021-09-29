trigger UserBadge on User_badge__c (before insert , before update) {
	new UserBadgeTriggerHandler().run();   
}