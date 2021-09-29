global class PM_SaveQuotePDF
{
    @future(callout=true)
    public static void savepdf(String quoteId, String quoteTemplateId)
    {   
         try {
            
            // build url
            String quoteTemplateDataViewerUrl = '/quote/quoteTemplateDataViewer.apexp';
            // add quoteid
            quoteTemplateDataViewerUrl = quoteTemplateDataViewerUrl +'?id='+quoteId;
            //add quotetemplateID
            quoteTemplateDataViewerUrl = quoteTemplateDataViewerUrl + '&summlid='+ quoteTemplateId;
            PageReference pageRef = new PageReference(quoteTemplateDataViewerUrl);
            QuoteDocument quotedoc = new QuoteDocument(Document  =  pageRef.getContentAsPDF(), QuoteId = quoteId);
            insert quotedoc;
        } catch (Exception e) {
            System.debug(e.getMessage());             
        }
    }

}