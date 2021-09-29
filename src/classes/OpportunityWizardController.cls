public without sharing class OpportunityWizardController {
    
    @AuraEnabled
    public static Map<String, Object> getdisplayContractReminder(String oppId) {
        system.debug('OppId : '+oppId);
        
        Map<String, Object> data = new Map<String, Object>();
        
        Opportunity opp = [select id, StageName, Tech_Number_of_views__c, Contract__c, ContractId from Opportunity where Id = : oppId];
        
        system.debug('opp.Tech_Number_of_views__c : ' + opp.Tech_Number_of_views__c);
        
        if(opp.Contract__c == 'No' || opp.Tech_Number_of_views__c == null){
            data.put('displayContractReminder', false);
            data.put('contractId', '');
            opp.Tech_Number_of_views__c = 0;

             //updated for ticket 7079 containsIgnoreCase
           // if(opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost')
           if(!Label.OpportunityStage.containsIgnoreCase( opp.StageName) )
            //end update for ticket 7079
            {
                update opp;
            }            
            return data;
        }
        
        else{
            opp.Tech_Number_of_views__c += 1;
            // if(opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost')
            //updated for ticket 7079 containsIgnoreCase
           if(!Label.OpportunityStage.containsIgnoreCase( opp.StageName) )
            //end update for ticket 7079
            {
                update opp;
            }   
            
            if(opp.Tech_Number_of_views__c == 1){
                data.put('displayContractReminder', true);
                data.put('contractId', opp.ContractId);
                return data;
            }
            else{
                data.put('displayContractReminder', false);
                data.put('contractId', '');
                return data;
            }
        }
    }    
}