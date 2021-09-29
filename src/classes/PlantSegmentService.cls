/**
* @description Service class for interacting with Plant Segment
* @author MDK
* @date 07/11/2017
*/
public abstract class PlantSegmentService {
    
    
    /**
* @description set updateAccOppTeam run a batch to update Acc and Opp team
* @param newQuoteLineIems : trigger.new
* @return nothing
*/
    public static void updateAccOppTeam(List<Plant_Segment_Users__c> oldPlantSegmentUsers) {
        
        System.debug(LoggingLevel.ERROR, 'PlantSegmentService.updateAccOppTeam : in PlantSegmentUserDelete');
        
        map<id, String> mapUserPlantsAndClustersToDelete = new map<id, String>();
        map<id, String> mapUserPlantsAndClustersNameToDelete = new map<id, String>();
        
        map<id, String> mapUserProdSubSegToDelete = new map<id, String>();
        
        set<id> idProds = new set<id>();
        set<id> idPlantsAndCLusters = new set<id>();
        set<id> idRecTypes = new set<id>();
        
        for(Plant_Segment_Users__c plSegUser :oldPlantSegmentUsers) {
            idProds.add(plSegUser.Product__c);
            idPlantsAndCLusters.add(plSegUser.Plant_and_Cluster__c);
            idRecTypes.add(plSegUser.recordTypeID);
        }
        
        map<id, Product2> mapIdProdSubSgName = new map<id, Product2>([Select id, name
                                                                      From Product2
                                                                      Where id in :idProds
                                                                     ]);
        
        map<id, Plant_and_Cluster__c> mapIdPlantAndClusterName = new map<id, Plant_and_Cluster__c>([Select id, name,Plant_Code__c
                                                                                                    From Plant_and_Cluster__c
                                                                                                    Where id in :idPlantsAndCLusters
                                                                                                   ]);
        
        map<id, RecordType> mapIdRecTypeName = new map<id, RecordType>([Select id, name, sobjecttype
                                                                        From RecordType
                                                                        Where sobjecttype = 'Plant_Segment_Users__c'
                                                                       ]);
        
        //get the values of plant/cluster and prod sub segments deleted
        for(Plant_Segment_Users__c plSegUser :oldPlantSegmentUsers) {
            if(mapIdRecTypeName.get(plSegUser.recordTypeID) != null && mapIdRecTypeName.get(plSegUser.recordTypeID).Name == 'Plant') {
                System.debug(LoggingLevel.ERROR, 'PlantSegmentService.updateAccOppTeam : dans Plant ');
                mapUserPlantsAndClustersToDelete.put(plSegUser.User__c, mapIdPlantAndClusterName.get(plSegUser.Plant_and_Cluster__c).Plant_Code__c);
                mapUserPlantsAndClustersNameToDelete.put(plSegUser.User__c, mapIdPlantAndClusterName.get(plSegUser.Plant_and_Cluster__c).Name);
                
            } 
            else if(mapIdRecTypeName.get(plSegUser.recordTypeID) != null && mapIdRecTypeName.get(plSegUser.recordTypeID).Name == 'Sub Segment') {
                System.debug(LoggingLevel.ERROR, 'PlantSegmentService.updateAccOppTeam : dans Sub Segment ');
                mapUserProdSubSegToDelete.put(plSegUser.User__c, mapIdProdSubSgName.get(plSegUser.Product__c).Name);
                System.debug(LoggingLevel.ERROR, 'PlantSegmentService.updateAccOppTeam : mapUserProdSubSegToDelete ' + mapUserProdSubSegToDelete);
            }
        }
        
        //get all qlis that have this values
        map<id, quotelineitem> setIdQlisPlantAndClusterToDelete = new map<id, quotelineitem>([select id, Quote.OpportunityID, quote.opportunity.AccountID
                                                                                              from QuotelineItem
                                                                                              where (Production_Plant__c in :mapUserPlantsAndClustersToDelete.values() OR
                                                                                                   Production_Plant__c in : mapUserPlantsAndClustersNameToDelete.values() )]);
        
        map<id, quotelineitem> setIdQlisProdToDelete = new map<id, quotelineitem>([select id, Quote.OpportunityID, quote.opportunity.AccountID
                                                                                   from QuoteLineItem
                                                                                   where Product_Sub_segment__c in :mapUserProdSubSegToDelete.values()]);
        
        System.debug(LoggingLevel.ERROR, 'PlantSegmentService.updateAccOppTeam : dans setIdQlisPlantAndClusterToDelete ' + setIdQlisPlantAndClusterToDelete);
        System.debug(LoggingLevel.ERROR, 'PlantSegmentService.updateAccOppTeam : dans setIdQlisProdToDelete ' + setIdQlisProdToDelete);
        
        //get all related opps and accs
        Set<id> setIdOppsPlAndClusToDelete = new set<id>();
        Set<id> setIdOppsProdToDelete = new set<id>();
        
        Set<id> setIdAccsPlAndClusToDelete = new set<id>();
        Set<id> setIdAccsProdToDelete = new set<id>();
        
        for(quotelineitem qli :setIdQlisPlantAndClusterToDelete.values()) {
            setIdOppsPlAndClusToDelete.Add(qli.Quote.OpportunityID);
            setIdAccsPlAndClusToDelete.add(qli.quote.opportunity.AccountID);
        }
        
        for(quotelineitem qli :setIdQlisProdToDelete.values()) {
            setIdOppsProdToDelete.Add(qli.Quote.OpportunityID);
            setIdAccsProdToDelete.add(qli.quote.opportunity.AccountID);
        }
        
        System.debug(LoggingLevel.ERROR, 'PlantSegmentService.updateAccOppTeam : setIdAccsProdToDelete ' + setIdAccsProdToDelete);
        System.debug(LoggingLevel.ERROR, 'PlantSegmentService.updateAccOppTeam : setIdAccsProdToDelete ' + setIdAccsProdToDelete);
        
        //get all related accTM and oppTM
        set<ID> setAccTMToDelete = new set<ID>();
        set<ID> setOppTMToDelete = new set<ID>();
        
        //accs
        for(AccountTeamMember accTM :[Select id from AccountTeamMember
                                      Where AccountId in :setIdAccsProdToDelete
                                      And UserId in :mapUserProdSubSegToDelete.keyset()
                                      And TeamMemberRole = 'Product'
                                     ]) {
                                         setAccTMToDelete.add(accTM.ID);
                                     }
        
        for(AccountTeamMember accTM :[Select id from AccountTeamMember
                                      Where AccountId in :setIdAccsPlAndClusToDelete
                                      And (UserId in :mapUserPlantsAndClustersToDelete.keyset() OR UserId in :mapUserPlantsAndClustersNameToDelete.keyset() )
                                      And TeamMemberRole = 'Plant'
                                     ]) {
                                         setAccTMToDelete.add(accTM.ID);
                                     }
        
        //opps
        for(OpportunityTeamMember oppTM :[select id
                                          from OpportunityTeamMember
                                          where OpportunityId in :setIdOppsProdToDelete
                                          AND UserId in :mapUserProdSubSegToDelete.keyset()
                                          AND TeamMemberRole = 'Product'
                                         ]) {
                                             setOppTMToDelete.add(oppTM.ID);
                                         }
        
        for(OpportunityTeamMember oppTM :[select id
                                          from OpportunityTeamMember
                                          where OpportunityId in :setIdOppsPlAndClusToDelete
                                          AND (UserId in :mapUserPlantsAndClustersToDelete.keyset() OR UserId in :mapUserPlantsAndClustersNameToDelete.keyset() )
                                          AND TeamMemberRole = 'Plant'
                                         ]) {
                                             setOppTMToDelete.add(oppTM.ID);
                                         }
        
        System.debug(LoggingLevel.ERROR, 'PlantSegmentService.updateAccOppTeam : setOppTMToDelete ' + setOppTMToDelete);
        System.debug(LoggingLevel.ERROR, 'PlantSegmentService.updateAccOppTeam : setAccTMToDelete ' + setAccTMToDelete);
        
        //schedule the batch for deletion
        //check how many jobs are schedueled
        Integer nbSchedueledJobs = (Integer) [Select count() From AsyncApexJob Where JobType = 'BatchApex' and(Status = 'Processing' or Status = 'Preparing')];
        if(nbSchedueledJobs < 5) {
            //Call deletion job
            Database.executeBatch(new BA01_RemoveAccOppAccess(setAccTMToDelete, setOppTMToDelete, false, 'AccountTeamMember'));
        } else {
            //re-schedule deletion in 15 minutes
            Datetime sysTime = System.now().addSeconds(900);
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            System.schedule('AccountTeamMembersDeletion ' + sysTime, chronExpression, new SCH_BatchDeletionAccOppTM(setAccTMToDelete, setOppTMToDelete, true, 'AccountTeamMember'));
        }
        
    }
    
    
    
    
    //Added By Zak
    
    public static void PlantUserSegAccOppTeam(List<Plant_Segment_Users__c> newPlantSegmentUsers) {
        
        //Retrieve Product sub segments users
        Set<id > productIds = new Set<Id >();
        //Retrieve Production Plant "usine"
        Set<String> productionPlantsSetId = new set<String>();
        
        Set<id> plantSegId = new Set<id> ();
        
        Map<id,Plant_Segment_Users__c> plantsegmentUserwithPlantName = new Map<id, Plant_Segment_Users__c>(
            							[select id,Product__c,Plant_and_Cluster__c,Plant_and_Cluster__r.Name,Plant_and_Cluster__r.Plant_Code__c
                                         from Plant_Segment_Users__c where id in:newPlantSegmentUsers]);
        
        For(Plant_Segment_Users__c psu :newPlantSegmentUsers) {
            
            plantSegId.add(psu.id);
            
            if(psu.Product__c != null) {
            productIds.add(psu.Product__c);
            }
            
            if(psu.Plant_and_Cluster__c != null) {
                productionPlantsSetId.add(plantsegmentUserwithPlantName.get(psu.id).Plant_and_Cluster__r.Plant_Code__c);
                productionPlantsSetId.add(plantsegmentUserwithPlantName.get(psu.id).Plant_and_Cluster__r.Name);
            }
            
        }
        
        system.debug('--- Production Plant Set ---' + productionPlantsSetId);
        system.debug('--- Product Id set ---' + productIds);
        
        
        
        
        //ListquoteLineItems > quoteLineItemsPrd + quoteLineItemsPlt
        
        //quoteLineItemsPrd
        List<QuotelineItem> quoteLineItemsPrd = [SELECT id, QuoteId,Quote.OpportunityId, Quote.Opportunity.accountId, Product2Id, Production_Plant__c, Product_Sub_segment__c, lastModifiedDate FROM QuoteLineItem where Product2Id in :productIds OR Production_Plant__c in :productionPlantsSetId];
        //OR Production_Plant__c in :productionPlantsSetId ];
  		
        System.debug('Liste Qli :'+quoteLineItemsPrd);
        System.debug('Liste Qli Size :'+ quoteLineItemsPrd.size());
        Map<Id, List<QuoteLineItem>> mapQuote = new Map<Id,List<QuoteLineItem>>();
        
        For(QuoteLineItem qli : quoteLineItemsPrd){
            
            if(mapQuote.ContainsKey(qli.Quote.Opportunity.accountId)){
                mapQuote.get(qli.Quote.Opportunity.accountId).add(qli);
            }
            else{
                mapQuote.put(qli.Quote.Opportunity.accountId,new List<QuoteLineItem>{qli});
            }
            
        }
        
        System.debug('Liste Map : ' + mapQuote);
        
        List<Id> listIdQliPrd = new List<Id>();
        List<List<Id>> listoflstQuotes = new List<List<Id>>();
        List<id> listintermed = new List<id>();
        integer full = 0;
        integer compt = 1;
        
        for(Id idacc :mapQuote.keySet()){
            System.debug('AAA1');
            for(QuoteLineItem qli: mapQuote.get(idacc)){
            	System.debug('AAA2');    
                if(math.mod(compt, 4000) == 0){
                    System.debug('AAA3');
                    full =1;                
                }
                System.debug('AAA4');
                listintermed.add(qli.id);
                compt++;
             }
            System.debug('AAA5');
            if(full == 1){
                System.debug('AAA6');
                listoflstQuotes.add(listintermed);
                listintermed = new List<id>();
                full =0;
            }
                   
            }  
        
        if(full == 0){
                System.debug('AAA6');
                listoflstQuotes.add(listintermed);
                listintermed = new List<id>();
                //full =0;
            }
        System.debug('AAA7');
        List<id> listprdid = new List<id>();
        for(List<id> listidPrd :listoflstQuotes){
         	System.debug('Liste Acc : ' + listidPrd);
			futureMethodCallFromScheduler(listidPrd,plantSegId);   
            
            }
    }
  
    
    @future
    public static void futureMethodCallFromScheduler(List<id> ListQLI, set<id> plantSegId ) {
        system.debug('******futureMethodCallFromScheduler get called');
                
        List<QuotelineItem> quoteLineItemsPrd = [SELECT id, QuoteId, Product2Id, Production_Plant__c, Product_Sub_segment__c, lastModifiedDate FROM QuoteLineItem where id in : ListQLI];

        //Map QLI to Quote Id
        Map<id, id> QLiToQuoteIdMapPrd = new Map<id, Id>();
        For(QuoteLineItem qli :quoteLineItemsPrd) {
            QLiToQuoteIdMapPrd.put(qli.id, qli.QuoteId);
        }
        
        system.debug('--- QLI QUOTE MAP ---' + QLiToQuoteIdMapPrd);

        //Retrieve Quotes
        list<Quote> parentQuotesPrd = [select id, OpportunityId, AccountId from Quote where id in :QLiToQuoteIdMapPrd.values()];
        /*
        list<id> Accid = new list<id>();
        for(Quote acc :parentQuotesPrd){
            Accid.add(acc.AccountId);
        }
        
        list<id> oppid = new list<id>();
        for(Quote opp :parentQuotesPrd){
            oppid.add(opp.OpportunityId);
        }  
  
        List<Opportunity> quoteToOpp = [select id from Opportunity where id in : oppid FOR UPDATE];
        List<Account> quoteToAcc =[select id from Account where id in : Accid FOR UPDATE];
        
        //Map Quote to Account Id
        Map<id, id> quoteToAccIdMapPrdOpp = new Map<id, id>();
        //Map Quote to Opportunity id
        Map<id, id> quoteToOppIdMapPrdAcc = new Map<id, id>();
		            
        
        list<Quote> parentQuotesPrdOpp = [select id, OpportunityId from Quote where OpportunityId in :quoteToOpp];
		for(Quote quo :parentQuotesPrd) {
            quoteToAccIdMapPrdOpp.put(quo.id, quo.OpportunityId);
        }
        
        list<Quote> parentQuotesPrdAcc = [select id, AccountId from Quote where AccountId in :quoteToAcc];
		for(Quote quo :parentQuotesPrd) {
            quoteToOppIdMapPrdAcc.put(quo.id, quo.AccountId);
        }*/

        /////////////////////////////////
        
        //Map Quote to Account Id
        Map<id, id> quoteToAccIdMapPrd = new Map<id, id>();
        //Map Quote to Opportunity id
        Map<id, id> quoteToOppIdMapPrd = new Map<id, id>();
		            
        for(Quote quo :parentQuotesPrd) {
            
            quoteToAccIdMapPrd.put(quo.id, quo.AccountId);
            quoteToOppIdMapPrd.put(quo.id, quo.OpportunityId);
        }
        
        //////////////////////////////////
        
        //Start Processing Quote Line Items
        List<AccountTeamMember> addAccTeamMemberPrd = new list<AccountTeamMember>();
        list<OpportunityTeamMember> addOppTeamMemberPrd = new list<OpportunityTeamMember>();
		
		
        list<Plant_Segment_Users__c> prodSegmentUsers = [SELECT id, Plant_and_Cluster__c, Product__c, User__c, Plant_and_Cluster__r.Name, Plant_and_Cluster__r.Plant_Code__c FROM Plant_Segment_Users__c where id in: plantSegId];
        
        For(QuoteLineItem qli :quoteLineItemsPrd) {
                
                //Create Account Team Member
                For(Plant_Segment_Users__c plantUser :prodSegmentUsers) {
                    
                    if(plantUser.product__c != null && qli.Product2Id == plantUser.Product__c) {
                        //Add Acc Team Members
                        AccountTeamMember newAccTeamMem = new AccountTeamMember();
                        newAccTeamMem.AccountId = quoteToAccIdMapPrd.get(qli.QuoteId);
                        newAccTeamMem.UserId = plantUser.User__c;
                        newAccTeamMem.TeamMemberRole = 'Product';
                        newAccTeamMem.AccountAccessLevel = 'Read';
                        // newAccTeamMem.OpportunityAccessLevel = 'Read';
                        newAccTeamMem.ContactAccessLevel = 'Read';
                        
                        addAccTeamMemberPrd.add(newAccTeamMem);
                        
                        // system.debug('AAA1' + addAccTeamMember);
                        
                        //Add Opportunity Team Members
                        OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                        oppTeamMem.OpportunityId = quoteToOppIdMapPrd.get(qli.QuoteId);
                        //oppTeamMem.OpportunityId = parentQuotesPrd2(qli.QuoteId);
                        oppTeamMem.UserId = plantUser.User__c;
                        oppTeamMem.TeamMemberRole = 'Product';
                        oppTeamMem.OpportunityAccessLevel = 'Read';
                        addOppTeamMemberPrd.add(oppTeamMem);
                        // system.debug('AAA2' + addOppTeamMember);
                    }
                else if(plantUser.Plant_and_Cluster__c != null && (qli.Production_Plant__c == plantUser.Plant_and_Cluster__r.Name || 
                                                                  qli.Production_Plant__c == plantUser.Plant_and_Cluster__r.Plant_Code__c)) {
                        
                        //Add Acc Team Members
                        AccountTeamMember newAccTeamMem = new AccountTeamMember();
                        newAccTeamMem.AccountId = quoteToAccIdMapPrd.get(qli.QuoteId);
                        newAccTeamMem.UserId = plantUser.User__c;
                        newAccTeamMem.TeamMemberRole = 'Plant';
                        newAccTeamMem.AccountAccessLevel = 'Read';
                        // newAccTeamMem.OpportunityAccessLevel = 'Read';
                        newAccTeamMem.ContactAccessLevel = 'Read';
                        
                        addAccTeamMemberPrd.add(newAccTeamMem);
                        
                        //Add Opportunity Team Members
                        OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                        oppTeamMem.OpportunityId = quoteToOppIdMapPrd.get(qli.QuoteId);
                        oppTeamMem.UserId = plantUser.User__c;
                        oppTeamMem.TeamMemberRole = 'Plant';
                        oppTeamMem.OpportunityAccessLevel = 'Read';
                        
                        addOppTeamMemberPrd.add(oppTeamMem);
                    }
                
                }
                
            }//End of Product Sub segment Users
        //End of Process QuoteLineItems for Prducts role
         if(addOppTeamMemberPrd.size() > 0) {
            system.debug('--- Opp Team Members ---' + addOppTeamMemberPrd);
            insert addOppTeamMemberPrd;
        }
        if(addAccTeamMemberPrd.size() > 0) {
            system.debug('--- Acc Team Members ---' + addAccTeamMemberPrd);
            insert addAccTeamMemberPrd;
        }
       //@todo Map<id,list<>>
        
        
    }
}