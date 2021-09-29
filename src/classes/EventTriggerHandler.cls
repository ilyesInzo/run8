public class EventTriggerHandler extends TriggerHandler {
	
    private Map<Id,Event> oldEventsById;
    private Map<Id,Event> newEventsById;
    private List<Event> newEvents; 
    private List<Event> oldEvents;

    public EventTriggerHandler() {
        this.oldEventsById = (Map<Id, Event>) Trigger.oldMap;
        this.newEventsById = (Map<Id, Event>) Trigger.newMap;
        this.newEvents = (List<Event>) Trigger.new;
        this.oldEvents = (List<Event>) Trigger.old; 
    }
 
    public override void afterInsert() {
        LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_EVENT_CREATION);
    }
}