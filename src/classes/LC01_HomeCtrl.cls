public class LC01_HomeCtrl {
    @AuraEnabled 
    public static QuoteLineItem getQuoteItemById(String quoteItemId) {
        return QuoteLineItemService.getInstance().getQuoteLineItemByIds(new Set<Id> {quoteItemId}).get(quoteItemId);
    }

}