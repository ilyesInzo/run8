public with sharing class LC01_ProductConfigCtrl {
/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Apex controller for lightning components LC01_ProductConfig_XXX
 * Notes            : e.g. LC01_ProductConfig_EU_TubePlastic
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   07-FEB-2017  Gulshan             Initial version
 *****************************************************************************/    
    @AuraEnabled
    public static PM_Selected_Tubes_Config__c getSelectedTubeConfig(Id qliId){
        
        String sQuery = AP00_PM_UtilityMethods.getAllFieldsForSOQL('PM_Selected_Tubes_Config__c');
        
        if(sQuery != null){
            sQuery += ' WHERE Quote_item__c = :qliId  order by createdDate DESC, lastModifiedDate DESC LIMIT 1';
            for(PM_Selected_Tubes_Config__c config : (List <PM_Selected_Tubes_Config__c>) Database.query(sQuery)){
                System.debug('## config.Dispensing_System_Family__c : ' + config.Dispensing_System_Family__c);
                return config;                                           
            }
        }
        System.debug('## getSelectedTubeConfig sQuery : ' + sQuery);
        PM_Selected_Tubes_Config__c config = new PM_Selected_Tubes_Config__c(Quote_item__c = qliId);
        insert config;
        return config;
    }
    
    /*
    @AuraEnabled
    public static PM_Selected_Dipsensing_Config__c getSelectedDispensingConfig(Id qliId){
        
        String sQuery = AP00_PM_UtilityMethods.getAllFieldsForSOQL('PM_Selected_Dipsensing_Config__c');
        
        if(sQuery != null){
            sQuery += ' WHERE Quote_item__c = :qliId LIMIT 1';
            for(PM_Selected_Dipsensing_Config__c config : (List <PM_Selected_Dipsensing_Config__c>) Database.query(sQuery)){
                System.debug('## config : ' + config);
                return config;                                           
            }
        }
        System.debug('## getSelectedDispensingConfig sQuery : ' + sQuery);
        PM_Selected_Dipsensing_Config__c config = new PM_Selected_Dipsensing_Config__c(Quote_item__c = qliId);
        insert config;
        return config;
    }
    */
    
    @AuraEnabled
    public static SObject saveFields(String SObjectName, Map <String, Object> mapValues, Id recordId){
        return AP00_PM_UtilityMethods.saveFields(sObjectName, mapValues, recordId);
    }
    
    @AuraEnabled 
    public static QuoteLineItem getQuoteItemById(String quoteItemId) {
        return QuoteLineItemService.getInstance().getQuoteLineItemByIds(new Set<Id> {quoteItemId}).get(quoteItemId);
    }
    
    @AuraEnabled
    public static String refreshProductImage(String quoteItemId){
        PM_selected_Tubes_config__c stc =  getSelectedTubeConfig(quoteItemId);
        String result = PM_GetProductImageHelper.getProductImage(stc);
        return result;
    }

    @AuraEnabled
    public static Sobject saveSelectedConfig(Sobject so){
        upsert so;
        return so;
    }

    @AuraEnabled
    public static sObject getSelectedConfig(Sobject so, Map<String, Object> mapfilters){
        return LC01_SelectedProductConfigCtrl.getSelectedConfig(so, mapfilters);
    }
}