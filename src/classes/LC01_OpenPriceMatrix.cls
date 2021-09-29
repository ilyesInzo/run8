public class LC01_OpenPriceMatrix{
    
    @AuraEnabled
    public static Boolean displayComponent(String quoteItemId){
        List<String> PMSegments = Label.Label_PM_Eligible_ProductSubSegment.split(';');
        set<String> PMSet = new set<String>();
        PMSet.addAll(PMSegments);
        QuoteLineItem qli = [Select Id, Product_Sub_segment__c FROM QuoteLineItem WHERE Id = :quoteItemId Limit 1 ];
        system.debug('displayComponent : ' + PMSet.contains(qli.Product_Sub_Segment__c));
        return(PMSet.contains(qli.Product_Sub_Segment__c));                             
    }

    @AuraEnabled
    public static list<boolean> displayCurrencyError(String quoteItemId){
    	QuoteLineItem qli = [Select Id, Location__c, Quote.Opportunity.Account.Country__r.Country_Code__c, Product_Line__c, Quote.Project_Type__c ,Billing_Currency__c, Production_Cluster__c, Production_Plant__c	
                             FROM QuoteLineItem WHERE Id = :quoteItemId Limit 1 ];
        Boolean showErrorCurrency = qli.Billing_Currency__c =='EURO' || qli.Billing_Currency__c =='American Dollar' ? false: true;               
        
        return  new list<boolean> {displaybuttonvalidation(qli.id),showErrorCurrency};    
                             	
    }
    
    @AuraEnabled 
   // public static list<boolean> displaybuttonvalidation(String quoteItemId){
    public static boolean displaybuttonvalidation(String quoteItemId){ //commented by maryem qada for currency errors 
        
        QuoteLineItem qli = [Select Id, Location__c, Quote.Opportunity.Account.Country__r.Country_Code__c, Product_Line__c, Quote.Project_Type__c ,Billing_Currency__c	
                             FROM QuoteLineItem WHERE Id = :quoteItemId Limit 1 ];
        string countryCode = qli.Quote.Opportunity.Account.Country__r.Country_Code__c;
        final String tableName = 'Access to PricematriX by PL,zone, country';
        final String PRICEMATRIX_EUROPE = 'PricematriX Europe';
        final String PRICEMATRIX_AMERICAS = 'PricematriX Americas';
        final String PRODUCT_LINE_TUBES  = 'Tubes';
        final String PRODUCT_LINE_DISPENSING  = 'Dispensing';
        
        if(qli.Product_Line__c != PRODUCT_LINE_DISPENSING && qli.Product_Line__c != PRODUCT_LINE_TUBES){
            return false;
        }        
               
        
        String buildquery = 'SELECT Id,Product_Line_Tubes__c, Product_Line_Dispensing__c FROM PM_Global_Config__c WHERE ';        
        buildquery  += 'Table_Name__c = \''+tableName+'\' ';
        buildquery  += 'AND Country_code__c =:countryCode ';
        buildquery  += (qli.Product_Line__c == PRODUCT_LINE_DISPENSING)?'AND (Product_Line_Dispensing__c = \''+PRICEMATRIX_EUROPE+'\' OR Product_Line_Dispensing__c = \''+PRICEMATRIX_AMERICAS+'\') ':'';
        buildquery  += (qli.Product_Line__c == PRODUCT_LINE_TUBES)?'AND (Product_Line_Tubes__c = \''+PRICEMATRIX_EUROPE+'\' OR Product_Line_Tubes__c = \''+PRICEMATRIX_AMERICAS+'\') ':'';
        buildquery  += (qli.Quote.Project_Type__c == 'P0')?'AND PricematriX_used_for_P0__c = true ':'';
        buildquery  += (qli.Quote.Project_Type__c == 'P0+')?'AND PricematriX_used_for_P0plus__c = true ':'';
        buildquery  += (qli.Quote.Project_Type__c == 'P1')?'AND PricematriX_used_for_P1__c = true ':'';
        
        System.debug('******buildquery  *****' + buildquery  );
        
        List<PM_Global_Config__c> globalconfigLst = Database.Query(buildquery);
        
        boolean showPricematriX = !globalconfigLst.isEmpty();
        System.debug('******globalconfigLst*****' + globalconfigLst);
        System.debug('****** Existing qli.Location__c =' + qli.Location__c); 
        // Fill location if empty (first time)
        if(showPricematriX && (qli.Location__c == null || qli.Location__c == '')  ){
            PM_Global_Config__c gc = globalconfigLst.get(0);
            System.debug('****** gc =' + gc);
            String accessForProductLineTubes = gc.Product_Line_Tubes__c;
            String accessForProductLineDispensing = gc.Product_Line_Dispensing__c;
            
            System.debug('****** accessForProductLineTubes =' + accessForProductLineTubes);
            System.debug('****** accessForProductLineDispensing = ' + accessForProductLineDispensing);
            
            if(accessForProductLineTubes == PRICEMATRIX_EUROPE || accessForProductLineDispensing == PRICEMATRIX_EUROPE ){
                qli.Location__c = 'EU';
            }else if(accessForProductLineTubes == PRICEMATRIX_AMERICAS || accessForProductLineDispensing == PRICEMATRIX_AMERICAS ){
                qli.Location__c = 'US';
            }
            System.debug('****** update qli.Location__c =' + qli.Location__c);
            
            update qli;
            
        }
        
        System.debug('******!isEmpty() - showPricematriX*****' + showPricematriX);
               
        return showPricematriX; 
    }
      
    @AuraEnabled
    public static QuoteLineItem getQuoteItemRecord(String quoteItemId){
        return [Select Id, Location__c, Quote.Opportunity.Account.Country__r.Country_Code__c, Product_Line__c, 
        Quote.Project_Type__c,
        Product_Final_Look__c,
        Billing_Currency__c	
                FROM QuoteLineItem 
                WHERE Id = :quoteItemId
                LIMIT 1 ];
    }
    @AuraEnabled
    public static boolean getTubeEU(String quoteItemId){
        QuoteLineItem ql = [Select Id, Location__c,  Product_Line__c 
        	
                FROM QuoteLineItem 
                WHERE Id = :quoteItemId
                LIMIT 1 ];
        if (ql.Location__c=='EU' && ql.Product_Line__c =='Tubes')
        {return true;
        }else
        {return false;}
    
    }
    
    @AuraEnabled
    public static void setIDRFQ(String quoteItemId){
    
        QuoteLineItem qli = [Select Id,ispricematrix__c, ID_Calculette__c
                             FROM QuoteLineItem WHERE Id = :quoteItemId Limit 1 ];
        
        qli.ID_Calculette__c = 'PM';
        update qli;
        
        //QuoteLineItemService.createPMReviewPerMoqRecords(new list<Quotelineitem>{qli});          
    
    }
    
}