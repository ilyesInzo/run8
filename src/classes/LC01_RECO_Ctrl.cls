public class LC01_RECO_Ctrl{
    
    @AuraEnabled
    public static Sobject saveproductconfig(Sobject so){
        upsert so;
        
        return so;
    }
    
    @AuraEnabled
    public static List<String> getmarketofapplst (String Location){
        List<String> marketofapplst = new List<String>();
        for(PM_Global_Config__c config : [Select Market_of_Application__c from PM_Global_Config__c where Table_name__c ='Market of Application' and Location__c =:Location order by Market_of_Application__c]){
            marketofapplst.add(config.Market_of_Application__c);
        }
        
        return marketofapplst;
    }
    
    @AuraEnabled
    public static QuoteLineItem saveqli(QuoteLineItem qli){
        
        update qli;
        
        return qli;
    }
    
    @AuraEnabled
    public static void saveToQuote(String quoteId, String quoteTemplateId){
        PM_SaveQuotePDF.savepdf(quoteId, quoteTemplateId);
    }
    /**
    @param input    Blob data representing correct string in @inCharset encoding
    @param inCharset    encoding of the Blob data (for example 'ISO 8859-2')
    */
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }   
    
}