public class LC01_SimulatorButtons {

    @AuraEnabled 
    public static void deleteConfigurations(String qliId , String oppId) {

      Id quoteId;
      Id opportId;
        
        List<Quotelineitem> qliToDelete = new List<Quotelineitem>();
        
        if((qliId == null || qliId == '')  && oppId != null){
            qliToDelete = [select id, QuoteId, Quote.OpportunityId, Product_Sub_segment__c, location__c from Quotelineitem where Quote.OpportunityId =: oppId];	
        }  

        else{
        	qliToDelete = [select id, QuoteId, Quote.OpportunityId, Product_Sub_segment__c, location__c from Quotelineitem where id =: qliId];
        }
        
      if(qliToDelete.size()>0){
        System.debug('qli to Delete : ' + qliToDelete[0]);
        
        opportId = qliToDelete[0].Quote.OpportunityId;
        quoteId = qliToDelete[0].QuoteId;

        Quote quoteToDelete = new Quote(id = quoteId , TECH_DeleteSimulation__c = true );
        update quoteToDelete;
        Opportunity opportunityToDelete = new Opportunity(id = opportId);
        
        System.debug('Opportunity to delete : ' + opportId);
        System.debug('Quote to delete : ' + quoteId);

        delete qliToDelete;
        delete quoteToDelete;
        delete opportunityToDelete;
        }


    }
    
}