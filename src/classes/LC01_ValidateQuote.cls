public class LC01_ValidateQuote {
    @AuraEnabled
    public static QuoteLineItem initiateObjects(String quoteItemId, String opportunityId) {
        system.debug('input1 :' + quoteItemId);
        system.debug('input2 :' + opportunityId);
        QuoteLineItem qliToReturn = new QuoteLineItem();
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        if(quoteItemId != null && quoteItemId != '') {
            qliList = [select id, Location__c, QuoteId, Quote.Name, Quote.Project_TYpe__c, Product2.Name, Quote.RecordTypeId, 
                       Quote.Quote_Due_Date__c, Quote.OpportunityId, Quote.Opportunity.RecordTypeId, Quote.Opportunity.Name, 
                       Quote.Opportunity.Quote_Type__c, Quote.Opportunity.CloseDate, 
                       Quote.status, Quote.Opportunity.StageName, 
                       Quote.Opportunity.AccountId, Quote.Opportunity.Account.Name from
                       QuoteLineItem where id = :quoteItemId];
        } else {
            qliList = [select id, Location__c, QuoteId, Quote.Name, Quote.Project_TYpe__c, Product2.Name, Quote.RecordTypeId, 
                       Quote.Quote_Due_Date__c, Quote.OpportunityId, Quote.Opportunity.RecordTypeId, Quote.Opportunity.Name, 
                       Quote.Opportunity.Quote_Type__c, Quote.Opportunity.CloseDate, 
                       Quote.status, Quote.Opportunity.StageName, 
                       Quote.Opportunity.AccountId, Quote.Opportunity.Account.Name from
                       QuoteLineItem where Quote.OpportunityId = :opportunityId];
        }
        if(qliList.size() > 0) {
            qliToReturn = qliList [0];
        }
        
        system.debug('return : ' + qliToReturn);
        return qliToReturn;
    }
    
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname, Boolean nullRequired) {
        List<String> optionlist = new List<String>();
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();
        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        if(nullRequired == true) {
            optionlist.add('--None--');
        }
        
        for (Schema.PicklistEntry pv :picklistValues) {
            optionlist.add(pv.getValue());
        }
        return optionlist;
    }
    
    
    @AuraEnabled
    public static void validateConfigurations(QuoteLineItem qli, Quote quoteRecord, Opportunity opportunityRecord, Account accountRecord, Boolean validate) {
        
        
        List<Opportunity> opportunityRecordlst = [Select id,stageName,TECH_EditSimulationStatus__c,AccountId,Sales_Allocation_Id__r.sales_team__r.kam__c,ownerID,owner.ISM_Team_Member__c from Opportunity where id = :opportunityRecord.id];

        System.debug('ValidateConfiguration');
        
        System.debug('ValidateConfiguration Quote :' + quoteRecord);
        System.debug('ValidateConfiguration Opportunity :' + opportunityRecordlst[0]);
        
        if(validate == true) {
            System.debug('Validate = True');
            quoteRecord.status = 'Draft';
            quoteRecord.TECH_EditSimulationStatus__c = true;
            opportunityRecordlst[0].stageName = 'Needs Analysis';
            opportunityRecordlst[0].TECH_EditSimulationStatus__c = true;
        }
        
        if(accountRecord != null) {
            List<String> elligibleProducts = LC01_PriceSimulatorController.getElligibleProduct(accountRecord.id);
            System.debug('AAA :' + elligibleProducts);
            System.debug('BBB :' + qli.Product2.Name);
            System.debug('BBB :' + qli.Product2.Name);
            
            if(elligibleProducts.contains(qli.Product2.Name)) {
                opportunityRecordlst[0].AccountId = accountRecord.id;
            } else {
                throw new AuraHandledException('You are not allowed to configure ' + qli.Product2.Name + ' for this Account');
            }
            
        }
        
        System.debug(' ZAK:Owner Change ');
        
        //Fill the list of opportunities to update
        
        
        
        //check if the KAM of the attached sales allocation is different from the current owner
        if(opportunityRecordlst[0].ownerID != opportunityRecordlst[0].Sales_Allocation_Id__r.sales_team__r.kam__c && opportunityRecordlst[0].owner.ISM_Team_Member__c != True){
            
            
            opportunityRecordlst[0].ownerid = opportunityRecordlst[0].Sales_Allocation_Id__r.sales_team__r.kam__c;	
            
        }//end if kam != owner
        
        // We can't have partial success, we need a rollback, so set to true
        //  Database.update(opportunityRecord, true); 
        
        
        update quoteRecord;
        update opportunityRecordlst[0];
        
        
        
    }
    
}