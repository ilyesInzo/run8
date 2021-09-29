global class Plant_OppTeamMember_recover_Batch implements Database.Batchable<SObject>{
	
    private string userId;
    private integer yearfilter;
    
    
    global Plant_OppTeamMember_recover_Batch(string usrId,integer year)
    {
        userId=usrId;
        yearfilter=year;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator([select id,Plant_and_Cluster__c,Product__c,User__c,Plant_and_Cluster__r.Name,
                                                          Plant_and_Cluster__r.Plant_Code__c from Plant_Segment_Users__c 
                                                          where User__c=:userId]);
	}


    global void execute(Database.BatchableContext BC, List<SObject> scope){
    
        List<Plant_Segment_Users__c> productplantSegmentUsers = (List<Plant_Segment_Users__c>) scope;
        system.debug('scope size  '+productplantSegmentUsers.size());
        
        string teamRole=productplantSegmentUsers[0].Product__c!= null ? 'Product': 'Plant'; 
        system.debug('Role '+teamRole);
         Set<string> prodIds= new Set<string>();
        Set<string> plantCodes= new Set<string>();
        Set<string> plantNames= new Set<string>();
        For(Plant_Segment_Users__c plantUser : productplantSegmentUsers){
            system.debug('Role '+plantUser.Product__c);
             if(plantUser.Product__c != null)	
                prodIds.add(plantUser.Product__c);
            
             if(plantUser.Plant_and_Cluster__r.Plant_Code__c!= null)
                plantCodes.add(plantUser.Plant_and_Cluster__r.Plant_Code__c)	;
            
             if(plantUser.Plant_and_Cluster__r.Name != null)
                plantNames.add(plantUser.Plant_and_Cluster__r.Name)	;
            system.debug('plantUser.Plant_and_Cluster__r.Plant_Code__c '+plantUser.Plant_and_Cluster__r.Plant_Code__c);
        }
        
        List<QuoteLineItem> QuoteLineItems=[SELECT id,Quote.OpportunityId,Quote.AccountId,Product2Id,Production_Plant__c,Product_Sub_segment__c FROM QuoteLineItem 
                                            where (CALENDAR_YEAR(createdDate) =: yearfilter) and (Production_Plant__c in :plantNames or Production_Plant__c in:plantCodes or Product2Id in:prodIds  ) ];
        Set<string> acctIds= new Set<string>();
        Set<string> oppIds= new Set<string>();
        for (QuoteLineItem curQLi : QuoteLineItems)
        {
            oppIds.add(curQLi.Quote.OpportunityId);
            acctIds.add(curQLi.Quote.AccountId);
        }
        system.debug('before acctIds count '+acctIds.size() );
        system.debug('before opp count '+oppIds.size() );
        List<OpportunityTeamMember> oppmembers=[select OpportunityId  from OpportunityTeamMember  where OpportunityId in :oppIds and UserId =:userId ];
        for (OpportunityTeamMember curTeam : oppmembers)
        {
            oppIds.remove(curTeam.OpportunityId);
        }
        List<AccountTeamMember> acctTeams=[select AccountId from AccountTeamMember where AccountId in:acctIds and UserId =:userId ];
        for (AccountTeamMember curTeam : acctTeams)
        {
            acctIds.remove(curTeam.AccountId);
        }
        
        List<AccountTeamMember> addAccTeamMember = new list<AccountTeamMember>();
        list<OpportunityTeamMember> addOppTeamMember = new list<OpportunityTeamMember>();
        system.debug('after opp team  count '+oppIds.size());
         for (string curAcct : acctIds)
        {
            AccountTeamMember newAccTeamMem = new AccountTeamMember();
                        newAccTeamMem.AccountId = curAcct;
                        newAccTeamMem.UserId = userId;
                        newAccTeamMem.TeamMemberRole = teamRole;
                        newAccTeamMem.AccountAccessLevel = 'Read';
                        newAccTeamMem.ContactAccessLevel = 'Read';
                        
                        addAccTeamMember.add(newAccTeamMem);
        }
        for (string curOPP : oppIds)
        {
             OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                        oppTeamMem.OpportunityId =curOPP;
                        oppTeamMem.UserId = userId;
                        oppTeamMem.TeamMemberRole = teamRole;
                        oppTeamMem.OpportunityAccessLevel = 'Read';
                        
                        addOppTeamMember.add(oppTeamMem);  
        }
        system.debug('addAccTeamMember to add  '+addAccTeamMember.size());
        system.debug('addOppTeamMember to add  '+addOppTeamMember.size());
        database.insert(addAccTeamMember,false);
        database.insert(addOppTeamMember,false);
    }


global void finish(Database.BatchableContext BC){
     
}
}