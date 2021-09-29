public class QuoteTriggerHandler extends TriggerHandler {
    
    private Map<Id,Quote> oldQuotesById;
    private Map<Id,Quote> newQuotesById;
    private List<Quote> newQuotes;
    private List<Quote> oldQuotes;

    /**
     * @description Default constructor
     */
    public QuoteTriggerHandler() {
        this.oldQuotesById = (Map<Id, Quote>) Trigger.oldMap;
        this.newQuotesById = (Map<Id, Quote>) Trigger.newMap;
        this.newQuotes = (List<Quote>) Trigger.new;
        this.oldQuotes = (List<Quote>) Trigger.old;
    }

    /**
     * @description beforeInsert on Quote Trigger
     * @return nothing
     */
    public override void beforeInsert() {

        SObjectUtils.checkChar(newQuotes);
   
    }

    /**
     * @description beforeUpdate on Quote Trigger
     * @return nothing
     */
    public override void beforeUpdate() {

        QuoteService.checkEditSimulationStatus(newQuotes,oldQuotesById);
        SObjectUtils.checkChar(newQuotes);
        QuoteService.setQuotes(newQuotes);
   		QuoteService.checkKPIs(newQuotes);//added by maryem
   		QuoteService.checkCLIisPricematrix(newQuotesById, oldQuotesById);
    }

    /**
     * @description beforeDelete on Quote Trigger
     * @return nothing
     */
    public override void beforeDelete() {
        QuoteService.checkCanDeleteQuote(oldQuotes);
    }
    
}