public class FeedItemTriggerHandler extends TriggerHandler {

    private Map<Id,FeedItem> oldFeedItemById;
    private Map<Id,FeedItem> newFeedItemById;
    private List<FeedItem> newFeedItem;
    private List<FeedItem> oldFeedItem;

    /**
     * @description Default constructor
     */
    public FeedItemTriggerHandler() {
        this.oldFeedItemById = (Map<Id, FeedItem>) Trigger.oldMap;
        this.newFeedItemById = (Map<Id, FeedItem>) Trigger.newMap;
        this.newFeedItem = (List<FeedItem>) Trigger.new;
        this.oldFeedItem = (List<FeedItem>) Trigger.old;
    }

    /**
     * @description afterInsert on FeedItem Trigger
     * @return nothing
     */
    public override void afterInsert() {

        LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_CHATTER_POST_COMMENT);
   
    }

   
}