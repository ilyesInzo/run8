public class FeedCommentTriggerHandler extends TriggerHandler{
	
    private Map<Id,FeedComment> oldFeedCommentById;
    private Map<Id,FeedComment> newFeedCommentById;
    private List<FeedComment> newFeedComment;
    private List<FeedComment> oldFeedComment;

    /**
     * @description Default constructor
     */
    public FeedCommentTriggerHandler() {
        this.oldFeedCommentById = (Map<Id, FeedComment>) Trigger.oldMap;
        this.newFeedCommentById = (Map<Id, FeedComment>) Trigger.newMap;
        this.newFeedComment = (List<FeedComment>) Trigger.new;
        this.oldFeedComment = (List<FeedComment>) Trigger.old;
    }

    /**
     * @description AfterInsert on FeedComment Trigger
     * @return nothing
     */
    public override void afterInsert() {

        LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_CHATTER_POST_COMMENT);
   
    }
}