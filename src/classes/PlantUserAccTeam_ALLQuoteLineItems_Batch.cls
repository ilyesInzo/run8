global class PlantUserAccTeam_ALLQuoteLineItems_Batch implements Database.Batchable<sObject>{    
    
    String Query = 'SELECT id,QuoteId,Product2Id,Production_Plant__c,Product_Sub_segment__c,lastModifiedDate FROM QuoteLineItem';
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){

	    return Database.getQueryLocator(query);
	}
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<QuotelineItem> quoteLineItems = scope;
        
        //Map QLI to Quote Id
        Map<id,id> QLiToQuoteIdMap = new Map<id,Id>();
        //Set of Production Plant
        Set<String> productionPlantsSet = new set<String>();
        
        //Set of Products
        Set<id> productIds = new set<Id>();
        
        For(QuoteLineItem qli : quoteLineItems){
            
            QLiToQuoteIdMap.put(qli.id,qli.QuoteId);
            
            if(qli.Production_Plant__c != null && qli.Production_Plant__c !=''){
                 productionPlantsSet.add(qli.Production_Plant__c);
            }
            
            productIds.add(qli.Product2Id);
        }
        
        system.debug('--- QLI QUOTE MAP ---'+QLiToQuoteIdMap);
        system.debug('--- Production Plant Set ---'+productionPlantsSet);
        system.debug('--- Product Id set ---'+productIds);
        
        //Retrieve Production Plants
        List<Plant_Segment_Users__c> plantSegmentUsers = [select id,Plant_and_Cluster__c,Product__c,User__c,Plant_and_Cluster__r.Name,Plant_and_Cluster__r.Plant_Code__c from Plant_Segment_Users__c where Plant_and_Cluster__r.Plant_Code__c in:productionPlantsSet  OR Plant_and_Cluster__r.Name in:productionPlantsSet];
        
		//Map Plant to its list of Users
		Map<String,list<Plant_Segment_Users__c>> PlantSegmentUsersMap = new Map<String,list<Plant_Segment_Users__c>>();
        
        For(String plantName : productionPlantsSet){
            
            list<Plant_Segment_Users__c> users = new list <Plant_Segment_Users__c>();
            
            For(Plant_Segment_Users__c plantUser : plantSegmentUsers){
            	
                if(plantUser.Plant_and_Cluster__r.Name == plantName ){
                    
                    users.add(plantUser);
                }
                if(plantUser.Plant_and_Cluster__r.Plant_Code__c == plantName ){
                    
                    users.add(plantUser);
                }   
        	}
            PlantSegmentUsersMap.put(plantName,users);
        }
        
        //Retrieve Product sub segments Users
        List<Plant_Segment_Users__c> productSegmentUsers = [select id,Plant_and_Cluster__c,Product__c,User__c,Plant_and_Cluster__r.Name from Plant_Segment_Users__c where Product__c in:productIds];
        
        Map<id,list<Plant_Segment_Users__c>> productSubSegmentUsersMap = new map<id,list<Plant_Segment_Users__c>>();
		
        For(Id productId : productIds){
            
            list<Plant_Segment_Users__c> users = new list <Plant_Segment_Users__c>();
            
            For(Plant_Segment_Users__c plantUser : productSegmentUsers){
            	
                if(plantUser.Product__c == productId){
                    
                    users.add(plantUser);
                }    	
        	}
            productSubSegmentUsersMap.put(productId,users);
        }
        
        //Retrieve Quotes
        list<Quote> parentQuotes = [select id,OpportunityId,AccountId from Quote where id in:QLiToQuoteIdMap.values()];
        
        //Map Quote to Account Id
        Map<id,id> quoteToAccIdMap = new Map<id,id>();
        //Map Quote to Opportunity id
        Map<id,id> quoteToOppIdMap = new Map<id,id>();
        
        for(Quote quo : parentQuotes){
            
            quoteToAccIdMap.put(quo.id , quo.AccountId);
            quoteToOppIdMap.put(quo.id, quo.OpportunityId);
        }
        
        //Start Processing Quote Line Items
        List<AccountTeamMember> addAccTeamMember = new list<AccountTeamMember>();
        list<OpportunityTeamMember> addOppTeamMember = new list<OpportunityTeamMember>();
        
        For(QuoteLineItem qli : quoteLineItems){
            
            
            
            //Check if Plant User exists
            if(PlantSegmentUsersMap.containsKey(qli.Production_Plant__c)){
                
                //Retrieve Plant Users
                list<Plant_Segment_Users__c> plantUsers = PlantSegmentUsersMap.get(qli.Production_Plant__c);
                
                //Create Account Team Member
                For(Plant_Segment_Users__c plantUser : plantUsers){
                    
                    //Add Acc Team Members
                    AccountTeamMember newAccTeamMem = new AccountTeamMember();
                    newAccTeamMem.AccountId = quoteToAccIdMap.get(qli.QuoteId);
                    newAccTeamMem.UserId = plantUser.User__c;
                    newAccTeamMem.TeamMemberRole = 'Plant';
                    newAccTeamMem.AccountAccessLevel = 'Read';
                   // newAccTeamMem.OpportunityAccessLevel = 'Read';
                    newAccTeamMem.ContactAccessLevel = 'Read';
                    
                    addAccTeamMember.add(newAccTeamMem);
                    
                    //Add Opportunity Team Members
                    OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                    oppTeamMem.OpportunityId = quoteToOppIdMap.get(qli.QuoteId);
                    oppTeamMem.UserId = plantUser.User__c;
                    oppTeamMem.TeamMemberRole = 'Plant';
                    oppTeamMem.OpportunityAccessLevel = 'Read';
                    
					addOppTeamMember.add(oppTeamMem);                  
                }  
            }//End fo Plant User exist
            
            //Check if Product subSegment Users exist
            if(productSubSegmentUsersMap.containsKey(qli.Product2Id)){
                
                //Retrieve Product Sub segment Users
                list<Plant_Segment_Users__c> prodSegmentUsers = productSubSegmentUsersMap.get(qli.Product2Id);
                
                //Create Account Team Member
                For(Plant_Segment_Users__c plantUser : prodSegmentUsers){
                    
                    //Add Acc Team Members
                    AccountTeamMember newAccTeamMem = new AccountTeamMember();
                    newAccTeamMem.AccountId = quoteToAccIdMap.get(qli.QuoteId);
                    newAccTeamMem.UserId = plantUser.User__c;
                    newAccTeamMem.TeamMemberRole = 'Product';
                    newAccTeamMem.AccountAccessLevel = 'Read';
                   // newAccTeamMem.OpportunityAccessLevel = 'Read';
                    newAccTeamMem.ContactAccessLevel = 'Read';
                    
                    addAccTeamMember.add(newAccTeamMem);
                    
                    //Add Opportunity Team Members
                    OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                    oppTeamMem.OpportunityId = quoteToOppIdMap.get(qli.QuoteId);
                    oppTeamMem.UserId = plantUser.User__c;
                    oppTeamMem.TeamMemberRole = 'Product';
                    oppTeamMem.OpportunityAccessLevel = 'Read';
                    
					addOppTeamMember.add(oppTeamMem);                  
                }  
              
            }//End of Product Sub segment Users
         
        }//End of Process QuoteLineItems
        
        if(addAccTeamMember.size()>0){
            system.debug('--- Acc Team Members ---'+addAccTeamMember);
            insert addAccTeamMember;
        }
        if(addOppTeamMember.size()>0){
            system.debug('--- Opp Team Members ---'+addOppTeamMember);
            insert addOppTeamMember;
        }
        
	}
	
    global void finish(Database.BatchableContext BC){

    }

}