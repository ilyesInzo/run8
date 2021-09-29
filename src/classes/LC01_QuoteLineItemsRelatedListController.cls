public class LC01_QuoteLineItemsRelatedListController {
    @AuraEnabled
    public static List<QuoteLineItem> getQuoteLineItems(String quoteId){
        return [Select Id, LineNumber, Quote.Name,QuoteId, Product2.Name, UnitPrice, ListPrice, Quantity  FROM QuoteLineItem WHERE QuoteId = :quoteId];
    }
}