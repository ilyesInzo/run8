/**
 * @author Dhanjay Ujoodha - Comforth
 * @date 08/12/2016
 */
public class VFC02_deepclonequotectrl {

    public VFC02_deepclonequotectrl (ApexPages.StandardController controller){
    }
    
    
    public PageReference deepclonequote(){
    
        Savepoint sp = Database.setSavepoint();
        
        try{
            String quoteId = ApexPages.CurrentPage().getParameters().get('Id');
            string queryquote = '';
            Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Quote.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                if(schemaFieldMap.get(fieldName).getDescribe().isAccessible() && schemaFieldMap.get(fieldName).getDescribe().isCreateable()){
                    queryquote += (queryquote == '')? 'Select ' + fieldName : ', ' + fieldName;
                }
            }
            queryquote += ' FROM Quote where Id =:quoteId ';

            Quote currentquote = Database.query(queryquote);
            
            Quote clonedquote = currentquote.clone(false, true, false, false);
            clonedquote.Name = '(CLONE) ' + clonedquote.Name;
            clonedquote.Status = 'Draft';
            insert clonedquote;
            
            
            string queryqlitems = '';
            schemaFieldMap = Schema.SObjectType.QuoteLineItem.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                if(schemaFieldMap.get(fieldName).getDescribe().isAccessible() && schemaFieldMap.get(fieldName).getDescribe().isCreateable()){
                    queryqlitems += (queryqlitems == '')? 'Select ' + fieldName : ', ' + fieldName;
                }
            }
            queryqlitems += ' FROM QuoteLineItem where QuoteId =:quoteId ';

            List<QuoteLineItem> currqlitemslist = Database.query(queryqlitems);

            List<QuoteLineItem> clonedqlitemslist = currqlitemslist.deepClone();
             
             for(QuoteLineItem qli : clonedqlitemslist){
                 qli.QuoteId = clonedquote.Id;
             }
             insert clonedqlitemslist;
        
             return new PageReference('/' + clonedquote.Id).setRedirect(true);
        }
        catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
            return null;
        }
    }
    
}