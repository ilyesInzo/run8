public class QuoteLineItemTriggerHandler extends TriggerHandler {

    private Map<Id,QuoteLineItem> oldQuoteLineItemsById;
    private Map<Id,QuoteLineItem> newQuoteLineItemsById;
    private List<QuoteLineItem> newQuoteLineItems;
    private List<QuoteLineItem> oldQuoteLineItems;

    /**
     * @description Default constructor
     */
    public QuoteLineItemTriggerHandler() {
        this.oldQuoteLineItemsById = (Map<Id, QuoteLineItem>) Trigger.oldMap;
        this.newQuoteLineItemsById = (Map<Id, QuoteLineItem>) Trigger.newMap;
        this.newQuoteLineItems = (List<QuoteLineItem>) Trigger.new;
        this.oldQuoteLineItems = (List<QuoteLineItem>) Trigger.old;
    }

    /**
     * @description beforeInsert on QuoteLineItem Trigger
     * @return nothing
     */
    public override void beforeInsert() {

        SObjectUtils.checkChar(newQuoteLineItems);
        QuoteLineItemService.getInstance().setQuoteLineItems(newQuoteLineItems);
        QuoteLineItemService.setLocation(newQuoteLineItems);
        system.debug('@@qama newQuoteLineItems '+newQuoteLineItems );
        //system.debug('@@qama newQuoteLineItemsById.keyset() '+ newQuoteLineItemsById.keyset());
        QuoteLineItemService.setBrandName( newQuoteLineItems);

        // Process Builder Changed To Trigger
        QuoteLineItemService.setQliInformation( newQuoteLineItems);


    }

    /**
     * @description beforeInsert on QuoteLineItem Trigger
     * @return nothing
     */
    public override void afterInsert(){
        //QuoteLineItemService.setLocation(newQuoteLineItems);
        //We should Copy Customer Scoring that will find on Account Ticket 7773
        // QuoteLineItemService.copyCustomerScoringFromAccount(newQuoteLineItems);
    }

    /**
     * @description beforeUpdate on QuoteLineItem Trigger
     * @return nothing
     */
    public override void beforeUpdate() {
        QuoteLineItemService.checkElligibilityOfUpdate(newQuoteLineItems,oldQuoteLineItemsById);
        SObjectUtils.checkChar(newQuoteLineItems);

        // Process Builder Changed To Trigger
        QuoteLineItemService.setQliInformationBeforeUpdate(newQuoteLineItems);


    }

    /**
     * @description afterUpdate on QuoteLineItem Trigger
     * @return nothing
     */
    public override void afterUpdate() {
        QuoteLineItemService.reinitBypasses(newQuoteLineItems) ;

    }

    /**
     * @description beforeDelete on QuoteLineItem Trigger
     * @return nothing
     */
    public override void beforeDelete() {

        // Need to check if they can delete use :oldQuoteLineItems Cant_Delete__c
        System.debug('@@@@@ List QLI To Del: '+oldQuoteLineItemsById.keySet());
        QuoteLineItemService.checkCanDeleteQLI(oldQuoteLineItemsById);
        QuoteLineItemService.deleteRelatedConfig(oldQuoteLineItemsById);

    }

}