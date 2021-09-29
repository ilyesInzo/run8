global class PlantUserAccOppTeam_Batch implements Database.Batchable<sObject>{    
    
    String Query = 'SELECT id,QuoteId,Product2Id,Production_Plant__c,Product_Sub_segment__c,lastModifiedDate FROM QuoteLineItem where lastModifiedDate=LAST_N_DAYS:1 ';
    
      
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
        
        //Retrieve Production Plants and Product sub segments Users
        List<Plant_Segment_Users__c> productplantSegmentUsers = [select id,Plant_and_Cluster__c,Product__c,User__c,Plant_and_Cluster__r.Name,
                                                          Plant_and_Cluster__r.Plant_Code__c from Plant_Segment_Users__c 
                                                          where User__c != null and (Product__c in:productIds OR (Plant_and_Cluster__r.Plant_Code__c in:productionPlantsSet  OR Plant_and_Cluster__r.Name in:productionPlantsSet)) ];
        //Active Users Ids
        Set<Id> idsPlantUsers = new Set<Id>();
        
        //Map Plant to its list of Users
		Map<String,list<Plant_Segment_Users__c>> PlantSegmentUsersMap = new Map<String,list<Plant_Segment_Users__c>>();
        
        //Map ProductId to its list of Users
        Map<id,list<Plant_Segment_Users__c>> productSubSegmentUsersMap = new map<id,list<Plant_Segment_Users__c>>();
		
        
        For(String plantName : productionPlantsSet) {
            
            list<Plant_Segment_Users__c> users = new list <Plant_Segment_Users__c>();
            
            For(Plant_Segment_Users__c plantUser : productplantSegmentUsers){
            	
                idsPlantUsers.add( (id) plantUser.User__c );
                
                if(plantUser.Plant_and_Cluster__r.Name == plantName || plantUser.Plant_and_Cluster__r.Plant_Code__c == plantName ){
                    
                    users.add(plantUser);
                    
                }   
        	}
            PlantSegmentUsersMap.put(plantName,users);
        }
        
		
        For(Id productId : productIds){
            
            list<Plant_Segment_Users__c> users = new list <Plant_Segment_Users__c>();
            
            For(Plant_Segment_Users__c plantUser : productplantSegmentUsers){
            	
                if(plantUser.Product__c == productId){
                    
                    users.add(plantUser);
                }    	
        	}
            productSubSegmentUsersMap.put(productId,users);
        }
        
        //Retrieve Inactive Users
        Map< id, user > inactiveUserMap = new Map< id, user >( [ select id from user where id in :idsPlantUsers and isActive = false ]);
        system.debug( ' inactiveUserMap '+ inactiveUserMap.keySet());
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
                   
                    if( !inactiveUserMap.containsKey( (id) plantUser.user__c) ) {
                        
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
                                    
                }  
            }//End fo Plant User exist
            
            //Check if Product subSegment Users exist
            if(productSubSegmentUsersMap.containsKey(qli.Product2Id)){
                
                //Retrieve Product Sub segment Users
                list<Plant_Segment_Users__c> prodSegmentUsers = productSubSegmentUsersMap.get(qli.Product2Id);
                
                //Create Account Team Member
                For(Plant_Segment_Users__c plantUser : prodSegmentUsers){
                    
                    if( !inactiveUserMap.containsKey( (id) plantUser.user__c) ) {
                        
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
                }  
              
            }//End of Product Sub segment Users
         
        }//End of Process QuoteLineItems
        
        if(addAccTeamMember.size()>0){
            system.debug('--- Acc Team Members ---'+addAccTeamMember);
            try{
            	insert addAccTeamMember;
            }
            catch(exception ex )
            {
               // BatchMonitor.getInstance('Plant').SetLog('PlantUserAccOppTeam_Batch','insert AccTeamMember',ex.getMessage());
            }
        }
        if(addOppTeamMember.size()>0){
            system.debug('--- Opp Team Members ---'+addOppTeamMember);
            try{ 
                insert addOppTeamMember;
            }
            catch(exception ex )
            {
               // BatchMonitor.getInstance('Plant').SetLog('PlantUserAccOppTeam_Batch','insert OppTeamMember',ex.getMessage());
            }
        }
        
	}
	
    global void finish(Database.BatchableContext BC){
 			//BatchMonitor.getInstance('Plant').SendLog();
    }

}