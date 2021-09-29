/**
* Service class for interacting with Sales Team
*
* @author MDK
* @date 12/10/2017
* @description
*
*/
public class SalesTeamService extends SalesService {

    private final String AVAILABLE_SALES_TEAM = 'AVAILABLE SALES TEAM';

    ///////////////////////////////////////////////////////////////////////////////
    // WHEN CHILD CLASS EXTENDS AN ABSTRACT PARENT CLASS WE CAN'T USE STATIC METHOD
    // OF THE PARENT SO WE HAVE TO IMPLEMENT THE SINGLETON PATTERN
    ///////////////////////////////////////////////////////////////////////////////
    /**
     * @description Singleton : private static variable referencing the class
     */
    private static SalesTeamService instance = null;

    /**
     * @description [SalesTeamService : private constructor (Singleton pattern)]
     * @return [a new instance of the class]
     */
    private SalesTeamService() {
    }

    /**
     * @description [getInstance : a static method that returns the unique instance of the class (Singleton pattern)]
     * @return [description]
     */
    public static SalesTeamService getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) {
            instance = new SalesTeamService();
        }
        return instance;
    }
    ///////////////////////////////////////////////////////////////////////////////

    public class BadException extends Exception {}
    public class DuplicateFoundException extends Exception {}

    /**
     * @description 
     * @param 
     * @return 
     */
    private Sales_Team__c cloneSalesTeam(Sales_Team__c newSTeams) {

        // We clone a part of the Sales Team
        Sales_team__c clonedSalesTeam = new Sales_team__c(
            Sales_Team__c = newSTeams.Sales_Team__c,
            KAM__c = newSTeams.KAM__c,
            Manager__c = newSTeams.Manager__c,
            Director__c = newSTeams.Director__c,
            Additional__c = newSTeams.Additional__c,
            Name = (newSTeams.Name != AVAILABLE_SALES_TEAM ? newSTeams.Name : newSTeams.Name +'_'+newSTeams.Sales_Team_Key__c),
            Sales_team_Description__c = newSTeams.Sales_team_Description__c,
            Valid_From__c = CURRENT_DATE,
            Valid_To__c = FUTURE_DATE,
            Tech_Overlapped_SalesTeam__c = newSTeams.Id,
            //----Added By Thanina For NZ2---
            Approved__c = newSTeams.Approved__c,
            Rejected__c = newSTeams.Rejected__c,
            Request_MAJ_SA_Status__c = newSTeams.Request_MAJ_SA_Status__c,
            Director_Backup__c = newSTeams.Director_Backup__c,
            Kam_Backup__c = newSTeams.Kam_Backup__c,
            Additional_Backup__c = newSTeams.Additional_Backup__c,
            Manager_Backup__c = newSTeams.Manager_Backup__c,
            New_Director__c = newSTeams.New_Director__c,
            New_Manager__c = newSTeams.New_Manager__c,
            New_KAM__c = newSTeams.New_KAM__c,
            New_Additional__c = newSTeams.New_Additional__c,
            Submitted_by__c = newSTeams.Submitted_by__c
            //----End Added NINA ----------
        );

        return clonedSalesTeam;
        
    }

    /**
     * @description 
     * @param 
     * @return 
     */
    private void resetSalesTeam(Sales_Team__c newSTeam, Sales_Team__c oldSTeam) {
		system.debug('**************resetSalesTeam**************');
        newSTeam.Valid_To__c = YESTERDAY_DATE; 
        newSTeam.KAM__c = oldSTeam.KAM__c;
        newSTeam.Manager__c = oldSTeam.Manager__c;
        newSTeam.Director__c = oldSTeam.Director__c;
        newSTeam.Additional__c = oldSTeam.Additional__c;     
        newSTeam.Sales_Team_Key_Referential__c = '';  
        //newSTeam.Sales_Team__c = '';
        //replace workflow rules 
        newSTeam.Name = (newSTeam.Name != AVAILABLE_SALES_TEAM ? newSTeam.Name +'_'+ newSTeam.Valid_To__c : newSTeam.Name+'_'+newSTeam.Sales_Team_Key__c+'_'+ newSTeam.Valid_To__c); 
        
    }

	/**
     * @description 
     * @param 
     * @return 
     */
    public void updateSalesTeam(List<Sales_Team__c> newSTeams, Map<id, Sales_Team__c> oldSTeamsById) {
		system.debug('**************updateSalesTeam**************');
        List<Sales_team__c> salesTeamsToInsert = new List<Sales_team__c>();
        Set<Id> salesTeamToResetIds = new Set<Id>();
        
        Set<String> fieldsToCompare = new Set<String>{'KAM__c','Manager__c','Director__c','Additional__c'};
        for (Sales_Team__c st : newSTeams) {           
            // Check if SalesTeam users have been modified
            system.debug(LoggingLevel.ERROR,'SalesTeamService.updateSalesTeam : Name = '+st.Name+' Valid_From__c = '+st.Valid_From__c+' Valid_To__c = '+st.Valid_To__c);
            if (SObjectUtils.isModified(st,oldSTeamsById.get(st.id),fieldsToCompare) && st.Valid_From__c != CURRENT_DATE && st.Valid_To__c >= CURRENT_DATE) {
                
                //Clone of a part of the Sales Team
                system.debug(LoggingLevel.ERROR,'SalesTeamService.updateSalesTeam : insert the cloned Sales Team');
               
                salesTeamsToInsert.add(cloneSalesTeam(st));

                //Reset Sales Team => Valid_To__c = YESTERDAY
                system.debug(LoggingLevel.ERROR,'SalesTeamService.updateSalesTeam : reset the original Sales Team');
                resetSalesTeam(st,oldSTeamsById.get(st.Id));

                salesTeamToResetIds.add(st.Id);
            }            
        }         
    
        if (!salesTeamsToInsert.isEmpty()) {
            // Insert cloned Sales Teams
            system.debug(LoggingLevel.ERROR,'SalesTeamService.updateSalesTeam : Nbr of Sales Teams to insert = '+salesTeamsToInsert.size());
            insert salesTeamsToInsert;

            // Link cloned Sales Team to Sales Allocations
            // this will be called in the after update trigger
            // so that the sales team complete updating
            // than we will affect the new inserted salesTeam instead of the old archived
            // SalesAllocationsService.getInstance().linkClonedSalesTeamsToSalesAllocations(salesTeamToResetIds,salesTeamsToInsert);
            
        }
        
    }


    public void afterUpdateSalesTeam(Map<id, Sales_Team__c> archivedSalesTeams){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - afterUpdateSalesTeam Start');

        //First we're getting back the Id for the newsales teams we have created from the sales team that have been archived
        List<Id> archivedSalesTeamsId = new List<Id>();
        for(Sales_Team__c archivedSalesTeam : archivedSalesTeams.values()){
            archivedSalesTeamsId.add(archivedSalesTeam.Id);
        }

        //We're going to update each of the new SalesTeam
        List<Sales_Team__c> newSalesTeams = new List<Sales_Team__c>();
        for(Sales_Team__c newSalesTeam : [SELECT Id, Sales_Team_Key_Referential__c, Sales_Team__c, Tech_Overlapped_SalesTeam__c
                                            FROM Sales_Team__c 
                                           WHERE Tech_Overlapped_SalesTeam__c IN :archivedSalesTeamsId]){
            newSalesTeam.Sales_Team_Key_Referential__c = archivedSalesTeams.get(newSalesTeam.Tech_Overlapped_SalesTeam__c).Sales_Team_Key__c;
            newSalesTeams.add(newSalesTeam);
        }

        //The update with a bypass trigger
        TriggerHandler.bypass('SalesTeamTriggerHandler');
        update(newSalesTeams);
        TriggerHandler.clearBypass('SalesTeamTriggerHandler');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - afterUpdateSalesTeam Stop');
    }

    /**
     * @description checkQLIAllocation
     * @param quoteLineItems [List of QuoteLineItems]
     * @return
     */
    public Map<QuoteLineItem,Boolean> checkQLIAllocation(List<QuoteLineItem> quoteLineItems){
		system.debug('**************checkQLIAllocation**************');

        // Get All UserInfos
        Id userProfileId = UserInfo.getProfileId();
        Id userId = UserInfo.getUserId();
        User su = [select id, Name, ISM_Team_Member__c from User where id =:userId limit 1];
        
        Set<String> authorizedProfiles = new Set<String>(System.Label.OPPORTUNITY_SET_SALESTEAM_AUTHORIZED_PROFILE.split(';')); 
        
        //Map Quote to Opportunity Id
        Map<Id,Id> quoteToOpportunityMap = new map<Id,Id>();
        //Map Quote to Account Id
        Map<Id,Id> quoteToAccIdMap = new Map<Id,Id>();
        Set<Id> quoteIds = SObjectUtils.toSetOfId(quoteLineItems,'QuoteId');
        System.debug(LoggingLevel.ERROR,'SalesTeamService.checkQLIAllocation : quoteIds = '+quoteIds);        
        For(Quote quo : [
                Select id,OpportunityId,AccountId 
                From Quote 
                Where Id In :quoteIds
            ]) {            

            quoteToAccIdMap.put(quo.id , quo.AccountId);            
            quoteToOpportunityMap.put(quo.id , quo.OpportunityId);
        }
        
        //Map of Opportunity id
        Map<Object,SObject> oppIdMap = SObjectUtils.toMap([
            Select Id,Sales_Allocation_ID__c 
            From Opportunity 
            Where Id In: quoteToOpportunityMap.values()
        ],'Id');

        
        System.debug(LoggingLevel.ERROR,'SalesTeamService.checkQLIAllocation : AccountId = '+quoteToAccIdMap.values());

        //Retrieve Sales Allocation on Accounts
        list<Sales_Allocations__c> lstAlloc = [
            Select  Id, 
                    KAMF__c, 
                    Manager__c, 
                    Additional__c, 
                    Director__c, 
                    Sales_Team__c,
                    Sales_Team__r.Manager__c,
                    Sales_Team__r.Additional__c,
                    Sales_Team__r.KAM__c,
                    Sales_Team__r.Director__c,
                    Product_Sub_Segment__c,
                    Account__c 
            From Sales_Allocations__c 
            Where Account__c in :quoteToAccIdMap.values() 
            And Valid_To__c >= TODAY
        ];  

        System.debug(LoggingLevel.ERROR,'SalesTeamService.checkQLIAllocation : All Sales Allocations = '+lstAlloc);

        //Opportunities to update Team Members
        Map<Id,Opportunity> updOpps = new Map<Id,Opportunity>();
        //Opportunity team members to add
        List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
        Map<QuoteLineItem, Boolean> qliToUserAllocationCheckMap = new Map<QuoteLineItem,Boolean>();
        if (!quoteLineItems.isEmpty()) {
            For(QuoteLineItem qli : quoteLineItems){
                qliToUserAllocationCheckMap.put(qli,false);
            }
        }
        if (!lstAlloc.isEmpty()) {
            Map<id,list<Sales_Allocations__c>> accountSalesAllocationMap = SObjectUtils.toMapOfListById(lstAlloc,'Account__c');
            System.debug(LoggingLevel.ERROR,'SalesTeamService.checkQLIAllocation : Account to Sales Alloc Map = '+accountSalesAllocationMap);
            

            //Process Quote Line Items
            For(QuoteLineItem qli : quoteLineItems){
                
                //Check Allocations on Account
                If (accountSalesAllocationMap.containsKey(quoteToAccIdMap.get(qli.QuoteId))) {
                    System.debug(LoggingLevel.ERROR,'SalesTeamService.checkQLIAllocation : There are Allocations = '+accountSalesAllocationMap.containsKey(quoteToAccIdMap.get(qli.QuoteId)));
                    For(Sales_Allocations__c salesAlloc : accountSalesAllocationMap.get(quoteToAccIdMap.get(qli.QuoteId))){
                        System.debug(LoggingLevel.ERROR,'SalesTeamService.checkQLIAllocation : Sales Allocations = '+salesAlloc);
                        //Check Product Segment
                        if(salesAlloc.Product_Sub_Segment__c == qli.Product2Id){
                                       
                            
                            if( authorizedProfiles.contains(PROFILESBYID.get(userProfileId).Name) || 
                                userId == salesAlloc.Sales_Team__r.KAM__c || 
                                userId == salesAlloc.Sales_Team__r.Director__c || 
                                userId == salesAlloc.Sales_Team__r.Manager__c || 
                                userId == salesAlloc.Sales_Team__r.Additional__c || (su != null && su.ISM_Team_Member__c == true)){
                                
                                qliToUserAllocationCheckMap.put(qli,true);
                                System.debug(LoggingLevel.ERROR,'SalesTeamService.checkQLIAllocation : QLITOUSER = '+qliToUserAllocationCheckMap);
                                
                                //Retrieve Opportunity
                                Opportunity ParentOpp = (Opportunity) oppIdMap.get(quoteToOpportunityMap.get(qli.QuoteId));
                                
                                //Set Sales Allocation On Opportunity
                                /*ParentOpp.Account_manager_KAM__c = salesAlloc.KAMF__c;
                                ParentOpp.Sales_Manager__c  = salesAlloc.Manager__c;
                                ParentOpp.Sales_Director__c  = salesAlloc.Director__c;
                                ParentOpp.Sales_Additional__c  = salesAlloc.Additional__c;
                                ParentOpp.Account_manager_KAM_lookup__c = salesAlloc.Sales_Team__r.KAM__c;
                                ParentOpp.Sales_Allocation_Reference_ID__c = salesAlloc.Id;*/
                                ParentOpp.Sales_Allocation_Id__c = salesAlloc.Id;
								system.debug('**************salesAlloc.Sales_Team__r.KAM__c' + salesAlloc.Sales_Team__r.KAM__c);
                                System.debug(' ZAK : step 1 don t change opporty owner for simul opporty ');
                                if(salesAlloc.Sales_Team__r.KAM__c != null && (su != null && su.ISM_Team_Member__c != true) && ParentOpp.StageName == 'Simulation'){
                                    ParentOpp.OwnerId = salesAlloc.Sales_Team__r.KAM__c;
                                }
                                
                                // If we have more than one Sales Allocation/Sub Segment on the Opportunity
                                // we keep the first inserted
                                if (!updOpps.containsKey(ParentOpp.Id)) {
                                    updOpps.put(ParentOpp.Id,ParentOpp);
                                }
                                
                                
                                //Add as Opportunity Member
                                if(salesAlloc.Sales_Team__r.KAM__c != null){
                                    //Create New KAM
                                    OpportunityTeamMember oppKAM = new OpportunityTeamMember();
                                    oppKAM.OpportunityId = ParentOpp.id;
                                    oppKAM.UserId = salesAlloc.Sales_Team__r.KAM__c;
                                    oppKAM.TeamMemberRole = 'KAM';
                                    oppKAM.opportunityAccessLevel='Edit';
                                   
                                    oppTeamMembers.add(oppKAM);  
                                }
                                if(salesAlloc.Sales_Team__r.Director__c != null){
                                    //Create New Director
                                    OpportunityTeamMember oppDir = new OpportunityTeamMember();
                                    oppDir.OpportunityId = ParentOpp.id;
                                    oppDir.UserId = salesAlloc.Sales_Team__r.Director__c;
                                    oppDir.TeamMemberRole = 'Director';
                                    oppDir.opportunityAccessLevel='Edit';
                                   
                                    oppTeamMembers.add(oppDir);  
                                }
                                if(salesAlloc.Sales_Team__r.Manager__c != null){
                                    //Create New Director
                                    OpportunityTeamMember oppMgr = new OpportunityTeamMember();
                                    oppMgr.OpportunityId = ParentOpp.id;
                                    oppMgr.UserId = salesAlloc.Sales_Team__r.Manager__c;
                                    oppMgr.TeamMemberRole = 'Manager';
                                    oppMgr.opportunityAccessLevel='Edit';
                                   
                                    oppTeamMembers.add(oppMgr);  
                                }
                                if(salesAlloc.Sales_Team__r.Additional__c != null){
                                    //Create New Additional
                                    OpportunityTeamMember oppAdd = new OpportunityTeamMember();
                                    oppAdd.OpportunityId = ParentOpp.id;
                                    oppAdd.UserId = salesAlloc.Sales_Team__r.Additional__c;
                                    oppAdd.TeamMemberRole = 'Additional';
                                    oppAdd.opportunityAccessLevel='Edit';
                                   
                                    oppTeamMembers.add(oppAdd);  
                                }
                            }          
                        }
                    }
                }
            }

        }

        if(updOpps.size()>0){
            
            System.debug(LoggingLevel.ERROR,'SalesTeamService.checkQLIAllocation : Opportunity To Update = '+updOpps.values());
            update updOpps.values();
        }
        
        if(oppTeamMembers.size()>0){
            
         	insert oppTeamMembers;
        }
        
        return qliToUserAllocationCheckMap;
    }

    /**
     * @description processAllocation TO OPTIMIZE !
     * @param salesAllocations
     * @param salesTeamToRemove [description] 
     * @return
     */
    public static void processAllocation(list<Sales_Allocations__c> salesAllocations ,Set<id> salesTeamToRemove){
        
        System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : salesAllocations_size = '+salesAllocations.size());
        System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : salesTeamToRemove_size = '+salesTeamToRemove.size());
        //Retrieve list of sales Accounts ids
        Set<Id> salesAccountIds = new set<Id>();
        
        //Retrieve Set of Product Segment Ids
        Set<id> allocProdSegments = new set<Id>();
        
        System.debug(LoggingLevel.ERROR,'Sales Allocations = '+salesAllocations);
        for(Sales_Allocations__c salesAlloc : salesAllocations){
            
            salesAccountIds.add(salesAlloc.Account__c);
            allocProdSegments.add(salesAlloc.Product_Sub_Segment__c);
        }
        
        //Sales Team to Remove
        
        Set<id> salesTeamMembersToRemove = new Set<id>();
        
        if(salesTeamToRemove != null){
            
            //Retrieve Old Sales Team Members
            list<Sales_Team__c> salesTeamRemoved = [
                Select  Id,
                        Additional__c,
                        Director__c,
                        KAM__c,
                        Manager__c,
                        Valid_From__c,
                        Valid_To__c 
                From Sales_Team__c 
                Where Id in:salesTeamToRemove
            ];
            
            for(Sales_Team__c oldTeam : salesTeamRemoved){
                
                //Add Team Members Id
                if(oldTeam.KAM__c != null){
                    salesTeamMembersToRemove.add(oldTeam.KAM__c);
                }
                if(oldTeam.Additional__c != null){
                    salesTeamMembersToRemove.add(oldTeam.Additional__c);
                }
                if(oldTeam.Director__c != null){
                    salesTeamMembersToRemove.add(oldTeam.Director__c);
                }
                if(oldTeam.Manager__c != null){
                    salesTeamMembersToRemove.add(oldTeam.Manager__c);
                }
            }
        }
        
        //Retrieve list of Account Members
        list<AccountTeamMember> existingAccountTeamMembers = [
            Select AccountAccessLevel,AccountId,Id,TeamMemberRole,Title,UserId 
            From AccountTeamMember 
            Where AccountId In :salesAccountIds 
            And UserId In :salesTeamMembersToRemove
        ];
        
        //Map Account to its existing Account Team Member Map
        map<id,list<AccountTeamMember>> accToExistingAccTeamMembersMap = new map<id,list<AccountTeamMember>>();
        
        for(Id accId : salesAccountIds){
            
            list<AccountTeamMember> existingTeamMembers = new list<AccountTeamMember>();
            
            for(AccountTeamMember existingMember : existingAccountTeamMembers){
                
                if(existingMember.AccountId == accId){
                    
                    existingTeamMembers.add(existingMember);
                }
            }
            accToExistingAccTeamMembersMap.put(accId,existingTeamMembers);         
        }
        
        //Retrieve list of existing Opportunities Team Members
        // List<Opportunity> existingOpportunities = [select Id,AccountId from Opportunity where AccountId in:salesAccountIds];
        map<id,Opportunity> mapExistingOpportunities = new map<id, opportunity>([
            Select Id,AccountId 
            From Opportunity 
            Where AccountId In :salesAccountIds
        ]);

        System.debug(LoggingLevel.ERROR,'Opportunitities = '+mapExistingOpportunities);

        //*** Update we need only Opportunities with the same Product Sub segment ***//
        Set<Id> existingOppIds = new set<Id>();
        
        
        // Retrieve Quotes
        // List<Quote> existingQuotes = [select id,OpportunityId,AccountId from Quote where OpportunityId in:existingOppIds];
        Map<id,Quote> mapExistingQuotes = new Map<id,quote>([
            Select id,OpportunityId,AccountId
            From Quote 
            Where OpportunityId In :mapExistingOpportunities.keyset()
        ]);
        
        Map<Id,Set<id>> oppToQuoteIdsMap = new Map<id,Set<id>>();
        Set<id> quoteIds = new set<id>();
        
        System.debug(LoggingLevel.ERROR,'Quotes = '+mapExistingQuotes);
        For(Quote quo : mapExistingQuotes.values()){
            Set<id> OppquoteIds = new set<id>();               
            OppquoteIds = oppToQuoteIdsMap.get(mapExistingOpportunities.get(quo.opportunityID).Id) != null ? oppToQuoteIdsMap.get(mapExistingOpportunities.get(quo.opportunityID).Id) : new set<id>();
            OppquoteIds.add(quo.id);
            
            oppToQuoteIdsMap.put(mapExistingOpportunities.get(quo.opportunityID).Id,OppquoteIds);
        }
            
        //Get Quote Line Items with the same Product Segment
        // list<QuoteLineItem> existingProductSegmentQLIs = [SELECT id,QuoteId,Product2Id,Product_Sub_segment__c FROM QuoteLineItem where QuoteId in: quoteIds and Product2Id in:allocProdSegments];
        map<id, quotelineitem> mapExistingProductSegmentQLIs = new map<id,quotelineitem>([
            Select id,QuoteId,Product2Id,Product_Sub_segment__c 
            From QuoteLineItem 
            Where QuoteId In: mapExistingQuotes.keyset() 
            And Product2Id In: allocProdSegments
        ]);
        
        //Map Quote with Product sub Segment qli List
        Map<id,List<QuoteLineItem>> quoteToProdQLIList = new Map<id,List<QuoteLineItem>>();
        
        For(QuotelineItem qli : mapExistingProductSegmentQLIs.values()){
            list<QuoteLineItem> prodSubSementQLIs = new list<QuoteLineItem>();
            prodSubSementQLIs = quoteToProdQLIList.get(mapExistingProductSegmentQLIs.get(qli.ID).quoteID) != null ? quoteToProdQLIList.get(mapExistingProductSegmentQLIs.get(qli.ID).quoteID) : new list<QuoteLineItem>();
            prodSubSementQLIs.add(qli);
            
            quoteToProdQLIList.put(mapExistingProductSegmentQLIs.get(qli.ID).QuoteID,prodSubSementQLIs);                    
        }
                    
        //Map Account with its list of Opportunity Members
        Map<id,list<Opportunity>> accToExistingOppsMap = new map<id,list<Opportunity>>();
        
        For(Id accId : salesAccountIds){
            
            list<Opportunity> opportunities = new list<Opportunity>();
            
            For(Opportunity opp : mapexistingOpportunities.values()/*existingOpportunities*/){
                
                if(opp.AccountId == accId){
                    opportunities.add(opp);
                }  
            }
            accToExistingOppsMap.put(accId,opportunities);
        }
        
        //Get Opportunity Ids
        set<id> existingOppsIds = new set<id>();
        
        for(Opportunity opp : mapexistingOpportunities.values()/*existingOpportunities*/){
            
            existingOppsIds.add(opp.id);
        }
        //Retrieve Existing Opportunity Team Members
        system.debug('@@qama getQueries() '+Limits.getQueries());
        
        //list<OpportunityTeamMember> existingOppTeamMembers = [select id,UserId,OpportunityId from OpportunityTeamMember where OpportunityId in:existingOppsIds and UserId in:salesTeamMembersToRemove];
        map<id,OpportunityTeamMember > mapexistingOppTeamMembers = new map<id,OpportunityTeamMember>([
            Select id,UserId,OpportunityId 
            From OpportunityTeamMember 
            Where OpportunityId In :existingOppsIds 
            And UserId in:salesTeamMembersToRemove
        ]);
        
        //Map Existing OpportinityMembers to its Opportunity
        map<id,list<OpportunityTeamMember>> OpptoExistingTeamMembersMap = new map<id,list<OpportunityTeamMember>>();
        
        for(OpportunityTeamMember tm : mapexistingOppTeamMembers.values()){
            
            list<OpportunityTeamMember> oppTeamMembers = new list<OpportunityTeamMember>();
            oppTeamMembers = OpptoExistingTeamMembersMap.get(tm.opportunityID) != null ? OpptoExistingTeamMembersMap.get(tm.opportunityID) :   new list<OpportunityTeamMember>();
            oppTeamMembers.add(tm);
                        
            OpptoExistingTeamMembersMap.put(tm.opportunityID,oppTeamMembers);
        }
         
        //Map Account Allocations to its Sales Team
        Set<id> salesTeamIds = new set<Id>();
        
        //Retrieve Sales Teams
        for(Sales_Allocations__c salesAlloc : salesAllocations){
            
            salesTeamIds.add(salesAlloc.Sales_Team__c);
        }

        list<Sales_Team__c> salesTeams = [
            Select Additional_CSL_Matricule__c,
                Additional__c,
                Director_SAD_Matricule__c,
                Director__c,
                Id,
                KAM__c,
                Key_Account_Manager_Matricule__c,
                Manager_SAM_Matricule__c,
                Manager__c,
                Name,
                Sales_team_Description__c,
                USERNAME__c,
                Valid_From__c,
                Valid_To__c 
            From Sales_Team__c 
            Where id in:salesTeamIds AND Valid_To__c > TODAY
        ];
        
        //Map Sales Allocations to its Sales Team
        map<id,Sales_Team__c> salesTeamIdMap = new map<id,Sales_Team__c>();
        map<id,Sales_Team__c> allocationToSalesTeamMap = new map<id,Sales_Team__c>();
        
        for(Sales_Team__c salesTeam : salesTeams) {
            
            salesTeamIdMap.put(salesTeam.id,salesTeam);
        }
        for(Sales_Allocations__c salesAlloc : salesAllocations){
        
            allocationToSalesTeamMap.put(salesAlloc.id ,salesTeamIdMap.get(salesAlloc.Sales_Team__c));
        }
        
        //
        //  Start processing Sales Allocation
        //
        //
        Set<AccountTeamMember> accTeamMembersToRemove = new Set<AccountTeamMember>();
        List<AccountTeamMember> accTeamMembersToCreate = new list<AccountTeamMember>();
        
        List<OpportunityTeamMember> oppTeamMembertoCreate = new list<OpportunityTeamMember>();
        Set<OpportunityTeamMember> oppTeamMembertoRemove = new Set<OpportunityTeamMember>();
        
        for(Sales_Allocations__c salesAlloc : salesAllocations){
            
            //Get SalesTeam
            Sales_Team__c salesTeam = allocationToSalesTeamMap.get(salesAlloc.id);
            System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : --- Sales Team to create ---'+salesTeam);
            
            //Create Account Team Members from salesTeam
            if(salesTeam.KAM__c != null){
                
                //Add KAM Account Member
                AccountTeamMember KAM = new AccountTeamMember();
                KAM.AccountId = salesAlloc.Account__c;
                KAM.UserId = salesTeam.KAM__c;
                KAM.TeamMemberRole = 'KAM';
                KAM.AccountAccessLevel ='Edit';
                KAM.ContactAccessLevel = 'Edit';
               // KAM.OpportunityAccessLevel = 'Edit';
                accTeamMembersToCreate.add(KAM);
            }
            if(salesTeam.Manager__c != null ){
                
                //Add Manager Account Member
                AccountTeamMember Manager = new AccountTeamMember();
                Manager.AccountId = salesAlloc.Account__c;
                Manager.UserId = salesTeam.Manager__c;
                Manager.TeamMemberRole = 'Manager';
                Manager.AccountAccessLevel ='Edit';
                Manager.ContactAccessLevel = 'Edit';
               // Manager.OpportunityAccessLevel = 'Edit';
                accTeamMembersToCreate.add(Manager);
            }
            if(salesTeam.Director__c != null ){
                
                //Add Director Account Member
                AccountTeamMember Director = new AccountTeamMember();
                Director.AccountId = salesAlloc.Account__c;
                Director.UserId = salesTeam.Director__c;
                Director.TeamMemberRole = 'Director';
                Director.AccountAccessLevel ='Edit';
                Director.ContactAccessLevel = 'Edit';
              //  Director.OpportunityAccessLevel = 'Edit';
                accTeamMembersToCreate.add(Director);
            }
            if(salesTeam.Additional__c != null ){
                
                //Add Additional Account Member
                AccountTeamMember Additional = new AccountTeamMember();
                Additional.AccountId = salesAlloc.Account__c;
                Additional.UserId = salesTeam.Additional__c;
                Additional.TeamMemberRole = 'Additional';
                Additional.AccountAccessLevel ='Edit';
                Additional.ContactAccessLevel = 'Edit';
              //  Additional.OpportunityAccessLevel = 'Edit';
                
                accTeamMembersToCreate.add(Additional);
            }
             
            //Retrieve Existing Account TeamMembers to Remove
            if(accToExistingAccTeamMembersMap.containsKey(salesAlloc.Account__c)){
                
                //Add Existing Members to Delete List
                accTeamMembersToRemove.addAll(accToExistingAccTeamMembersMap.get(salesAlloc.Account__c));
            }
            
            //Create Opportunity Team Members
            System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : Sales Allocation Product Segment = '+salesAlloc.Product_Sub_Segment__c);
            
            
            //Check for exisiting Opportunities related to the Account
            if(accToExistingOppsMap.containsKey(salesAlloc.Account__c)){
                
                //Retrieve List of Opportunities
                list<Opportunity> opportunities = accToExistingOppsMap.get(salesAlloc.Account__c);
                
                //Create New Opportunity Team members for each Opportunities
                For(Opportunity opp : opportunities){
                    
                    Boolean hasProductSegment = false;
                    System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : OppId = '+opp.Id);
                    
                    //Check if Opportunity have quotes
                    if(oppToQuoteIdsMap.containsKey(opp.Id)){                        
                        System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : Opp to Quotes Map = '+oppToQuoteIdsMap.get(opp.Id));                        
                        For(Id quoteId : oppToQuoteIdsMap.get(opp.Id)){                        
                            System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : Quote Id  = '+quoteId);            
                            //retrieve list of Quoteline Items
                            if(quoteToProdQLIList.containsKey(quoteId)){                         
                                //Check if QuoteLineItem 
                                For(QuoteLineItem qli : quoteToProdQLIList.get(quoteId)){                                     
                                    System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : qli Product segment = '+qli.Product2Id);                                    
                                    if(qli.Product2Id != salesAlloc.Product_Sub_Segment__c){
                                        //Opportunity have Product Sub Segment in QuoteLineItem
                                        hasProductSegment = true;
                                    }
                                }
                            }
                        }
                    }//End of Opportunity have quotes
                    
                    if(hasProductSegment) {
                    
                        System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : Opportunity to create New Opp Team Members = '+opp.Id);
                        //Create Opp Team Members from salesTeam
                        if(salesTeam.KAM__c != null){
                            
                            //Add KAM Opportunity Member
                            OpportunityTeamMember oppKAM = new OpportunityTeamMember();
                            oppKAM.OpportunityId = opp.Id;
                            oppKAM.UserId = salesTeam.KAM__c;
                            oppKAM.TeamMemberRole = 'KAM';
                            //Set Edit rights for KAM
                            oppKAM.OpportunityAccessLevel = 'Edit';
                            
                            oppTeamMembertoCreate.add(oppKAM);
                        }
                        if(salesTeam.Manager__c != null ){
                            
                            //Add Manager Opportunity Member
                            OpportunityTeamMember oppManager = new OpportunityTeamMember();
                            oppManager.OpportunityId = opp.Id;
                            oppManager.UserId = salesTeam.Manager__c;
                            oppManager.TeamMemberRole = 'Manager';
                            oppManager.OpportunityAccessLevel = 'Edit';
                            OppTeamMembertoCreate.add(oppManager);
                        }
                        if(salesTeam.Director__c != null ){
                    
                            //Add Director Opportunity Member
                            OpportunityTeamMember oppDirector = new OpportunityTeamMember();
                            oppDirector.OpportunityId = opp.Id;
                            oppDirector.UserId = salesTeam.Director__c;
                            oppDirector.TeamMemberRole = 'Director';
                            oppDirector.OpportunityAccessLevel = 'Edit';
                            OppTeamMembertoCreate.add(oppDirector);
                        }
                        if(salesTeam.Additional__c != null ){
                    
                            //Add Additional Opportunity Member
                            OpportunityTeamMember oppAdditional = new OpportunityTeamMember();
                            oppAdditional.OpportunityId = opp.Id;
                            oppAdditional.UserId = salesTeam.Additional__c;
                            oppAdditional.TeamMemberRole = 'Additional';
                            oppAdditional.OpportunityAccessLevel = 'Edit';
                            OppTeamMembertoCreate.add(oppAdditional);
                        }
                        
                        //Retrieve Existing Opportunity TeamMembers to Remove
                        if(OpptoExistingTeamMembersMap.containsKey(opp.Id)){
                            
                            //Add Existing Members to Delete List
                            OppTeamMembertoRemove.addAll(OpptoExistingTeamMembersMap.get(opp.Id));
                        }
                        
                    }//End of Product SEgment Check
                }//End of existing Opportunity
            }//End of Opportunity Process
            
            
        }//End of Sales Allocation Process Loop
       
        //Remove Previous AccountTeam Members and Insert New AccountTeam Members
        if(accTeamMembersToRemove.size() >0){
            list<AccountTeamMember> liAccTeamMembersToRemove = new list<AccountTeamMember>();
            liAccTeamMembersToRemove.addAll(accTeamMembersToRemove);
            delete  liAccTeamMembersToRemove;
        }
        if(accTeamMembersToCreate.size() >0){
            System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : getDMLRows() = '+Limits.getDMLRows());
            System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : accTeamMembersToCreate.size() = '+accTeamMembersToCreate.size() + accTeamMembersToRemove.size() );
            
            Database.SaveResult[] srList = Database.insert(accTeamMembersToCreate, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : Successfully inserted Account Memmber ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : The following error has occurred.');                    
                        System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : '+err.getStatusCode() + ': ' + err.getMessage());
                        System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : error = ' + err.getFields());
                    }
                }
            }
                        
            //insert accTeamMembersToCreate;
        }
        //Remove Provious Opportunity Team and Insert New Opportunity Team Members
        if(OppTeamMembertoRemove.size() >0){
            list<OpportunityTeamMember> liOppTeamMembertoRemove = new list<OpportunityTeamMember>();
            liOppTeamMembertoRemove.addAll(OppTeamMembertoRemove);
                        
            delete liOppTeamMembertoRemove;
        }
        
        if(oppTeamMembertoCreate.size() >0){
            Database.SaveResult[] srListOpp = Database.insert(OppTeamMembertoCreate, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srListOpp) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : Successfully inserted Opportunity Team Member ID = ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : The following error has occurred.');                    
                        System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug(LoggingLevel.ERROR,'SalesTeamService.processAllocation : error = ' + err.getFields());
                    }
                }
            }
           
        }   
  
    }

    /** New sales team management **/
    public static String LOG_CLASS_NAME = 'SalesTeamService';

    /**
     * [ getSalesAllocations Description : return the sales allocations corresponding to the Sales Team]
     * @param SalesTeams [ Map<Id, Sales_Teams__c> : Sales Team sent by the script ]
     */
    public static Map<Id, Sales_Allocations__c> getSalesAllocations(Map<Id, Sales_Team__c> SalesTeams){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getSalesAllocations Start');

        //Variables definitions
        Set<Id> salesTeamsKeySet = SalesTeams.keySet();

        Map<Id, Sales_Allocations__c> salesAllocations = new Map<Id, Sales_Allocations__c>([
            SELECT Account_id18__c, Account_Number__c, Account__c, Additional_id18__c, Additional__c, CreatedById, CreatedDate, Customer_Group__c,
                   DataLoaderExtId__c, DirectorID18__c, Director_ST__c, Director__c, Id, ID_18__c, IsDeleted, KAMF__c, KAMid18__c, KAM__c,
                   LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, ManagerID18__c, Manager__c, Name, OwnerId, 
                   ProductLine__c, Product_Line__c, Product_Sub_Segment__c, Prod_Sub_Segment__c, Sales_Allocation_Unique_Checker__c,
                   Sales_Team_Description__c, Sales_Team_ID18__c, Sales_Team_Key__c, Sales_Team__c, Sub_Segment_ID18__c, SystemModstamp, 
                   TECH_Account_Id__c, TECH_Product_Id__c, TECH_SalesTeam_Overlap__c, ToArchiveWithValidFrom__c, ToArchiveWithValidTo__c,
                   Unic_Key__c, Valid_From__c, Valid_To__c 
            FROM Sales_Allocations__c 
            WHERE Sales_Team__c = : salesTeamsKeySet
              AND Valid_From__c < TODAY
              AND Valid_To__c > TODAY
        ]);


        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getSalesAllocations Stop');

        return salesAllocations;
    }

    /**
     * [ updateAccountAndOpportunityTeam description : will treat all Sales_Teams__c object and applyed modification to the corresponding account
     *   and opportunity ]
     * @param SalesTeams [ Map<Id, Sales_Team__c> : Sales Team send by the script]
     */
    public static void updateAccountAndOpportunityTeam(Map<Id, Sales_Team__c> SalesTeams){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateAccountAndOpportunityTeam Start');

        // We need to get all the active user .
        //We need to get all the active use
        Map<Id, User> activeUsers = new Map<Id, User>([
            SELECT Id, IsActive
              FROM User
             WHERE IsActive = True
        ]);

        //
        Set<SalesTeamAffectation> salesTeamAffectations = new Set<SalesTeamAffectation>();

        //We're going to update all the account team
        List<AccountTeamMember> oldAccountTeamMembers = new List<AccountTeamMember>();
        List<AccountTeamMember> newAccountTeamMembers = new List<AccountTeamMember>();

        for(SalesTeamAffectation salesTeamAffectation : salesTeamAffectations){
            oldAccountTeamMembers.addAll(salesTeamAffectation.getAccountTeamMembersToDelete());
            newAccountTeamMembers.addAll(salesTeamAffectation.getNewAccountTeamMembers(activeUsers));
        }

        //We're going to update all the opportunity team
        List<OpportunityTeamMember> oldOpportunityTeamMembers = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> newOpportunityTeamMembers = new List<OpportunityTeamMember>();

        for(SalesTeamAffectation salesTeamAffectation : salesTeamAffectations){
            oldOpportunityTeamMembers.addAll(salesTeamAffectation.getOpportunityTeamMembersToDelete());
            newOpportunityTeamMembers.addAll(salesTeamAffectation.getNewOpportunityTeamMembers(activeUsers));
        }

        //We're going to update all the team
        if(oldAccountTeamMembers.size() != 0){
            delete(oldAccountTeamMembers);
        }
        if(oldOpportunityTeamMembers.size() != 0){
            delete(oldOpportunityTeamMembers);
        }
        if(newAccountTeamMembers.size() != 0){
            insert(newAccountTeamMembers);
        }
        if(newOpportunityTeamMembers.size() != 0){
            insert(newOpportunityTeamMembers);
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateAccountAndOpportunityTeam End');
    }

    public  void updateRequestForSalesTeams(List<Sales_Team__c> salesTeams, Map<Id,Sales_Team__c> oldSalesTeamsById){
        System.debug('@@@ salesTeams: '+ salesTeams);
        Set<String> fieldsToCompare = new Set<String>{'New_KAM__c','New_Director__c','New_Manager__c','New_Additional__c'};
        //Added by Thanina.
        Set<String> fieldRequestStatus = new Set<String>{'Request_MAJ_SA_Status__c'};
        //-- End Added for NZ2-------
        boolean updateUser = false;

        //When a request is rejected or Approved the submitter need to receive a Notification
        boolean notifyUser= false;
        Set<String> listUsersToNotif = new Set<String>();
        String notifDescription ='';

        for (Sales_Team__c salesT:salesTeams){

            //-----Case 1 :  Submitted Request MAJ ST-------------
           if (oldSalesTeamsById!=null && SObjectUtils.isModified(salesT,oldSalesTeamsById.get(salesT.id),fieldsToCompare)
            && (salesT.New_KAM__c != null || salesT.New_Director__c != null
              || salesT.New_Manager__c != null || salesT.New_Additional__c!= null)){

              salesT.Submitted_by__c = UserInfo.getUserId();


               if(salesT.Request_MAJ_SA_Status__c != Label.Request_MAJ_SA_Statut)
               {
                   //updateUser = true;
                   // ----- Added by Thanina 27/08 for NZ2 ---
                   updateUser = true;
                   salesT.Request_MAJ_SA_Status__c = Label.Request_MAJ_SA_Statut;
                   salesT.Approved__c = false;
                   salesT.Rejected__c = false;
                   //  ------ End Modifs Thanina    -------

                   //Re - Init backup fields ----
                   salesT.Director_Backup__c = null;
                   salesT.Manager_Backup__c = null;
                   salesT.Kam_Backup__c = null;
                   salesT.Additional_Backup__c = null;
                   salesT.Request_MAJ_Response__c = null;
                   // ****** End Re -Init *********
               }
           }

            // ----- End Case : 01 --------
            // ----- Case 2 : Approved Request MAJ ST --------
            if (oldSalesTeamsById!=null && SObjectUtils.isModified(salesT,oldSalesTeamsById.get(salesT.id),fieldRequestStatus))
            {
                if( salesT.Request_MAJ_SA_Status__c == Label.Request_MAJ_SA_Approve) {
                    salesT.Approved__c = true;
                    salesT.Rejected__c = false;
                    salesT.Request_MAJ_SA_Status__c = 'None';
                    salesT.Request_MAJ_Response__c = Date.today();
                    //notifyUser = true;
                    listUsersToNotif.add(salesT.Submitted_by__c);

                    if(salesT.New_Director__c != null)
                    {
                        // Save Kam Value in in His
                        salesT.Director_Backup__c = salesT.Director__c;
                        salesT.Director__c = salesT.New_Director__c;
                        // Replace fields by New Ones.
                        salesT.New_Director__c=null;
                    }
                    if(salesT.New_Manager__c != null )
                    {
                        // Save Kam Value in in His
                        salesT.Manager_Backup__c = salesT.Manager__c;
                        salesT.Manager__c = salesT.New_Manager__c;
                        // Replace fields by New Ones.
                        salesT.New_Manager__c=null;
                    }
                    if(salesT.New_KAM__c!= null)
                    {
                        // Save Kam Value in in His
                        salesT.Kam_Backup__c = salesT.KAM__c;
                        salesT.KAM__c = salesT.New_KAM__c;
                        // Replace fields by New Ones.
                        salesT.New_KAM__c = null;
                    }
                    if(salesT.New_Additional__c!= null)
                    {
                        // Save Kam Value in in His
                        salesT.Additional_Backup__c = salesT.Additional__c;
                        salesT.Additional__c = salesT.New_Additional__c;
                        // Replace fields by New Ones.
                        salesT.New_Additional__c = null;
                    }


                }

            // ----- End Case : 02 ---------

            // ----- Case 3 : Rejected Request MAJ ST --------
            if(salesT.Request_MAJ_SA_Status__c == Label.Request_MAJ_SA_Reject)
            {
                salesT.Approved__c = false;
                salesT.Rejected__c = true;
                salesT.Request_MAJ_Response__c = Date.today();
                //notifyUser = true;
                listUsersToNotif.add(salesT.Submitted_by__c);
                //added Now------
                salesT.Request_MAJ_SA_Status__c = 'None';

                if(salesT.New_Director__c != null)
                {
                    // Save Kam Value in in His
                    salesT.Director_Backup__c = salesT.New_Director__c;
                    //salesT.Director__c = salesT.New_Director__c;
                    // Replace fields by New Ones.
                    salesT.New_Director__c=null;
                }
                if(salesT.New_Manager__c != null )
                {
                    // Save Kam Value in in His
                    salesT.Manager_Backup__c = salesT.New_Manager__c;
                    //salesT.Manager__c = salesT.New_Manager__c;
                    // Replace fields by New Ones.
                    salesT.New_Manager__c=null;
                }
                if(salesT.New_KAM__c!= null)
                {
                    // Save Kam Value in in His
                    salesT.Kam_Backup__c = salesT.New_KAM__c;
                   // salesT.KAM__c = salesT.New_KAM__c;
                    // Replace fields by New Ones.
                    salesT.New_KAM__c = null;
                }
                if(salesT.New_Additional__c!= null)
                {
                    // Save Kam Value in in His
                    salesT.Additional_Backup__c = salesT.New_Additional__c;
                  //  salesT.Additional__c = salesT.New_Additional__c;
                    // Replace fields by New Ones.
                    salesT.New_Additional__c = null;
                }
                // End Added ----
            }
            // ----- End Case : 03 ---------
            }
       }

        if (updateUser) updateUsers();
        if(listUsersToNotif.size() > 0) {
            
            createChatterNotif(listUsersToNotif, 'Your Sales Team Update Request have been Approved/Rejected. Please check that in '+Label.upListViewSt);
            //Query to find filtre apiname
            uncheckUsers(listUsersToNotif);
        }
    }


     private void updateUsers(){
        Id currentUser = UserInfo.getUserId();
        User userToUpdate = [select Id, Update_Request_Sales_Team__c from User where Id = :currentUser];
        if(userToUpdate.Update_Request_Sales_Team__c == false){
            userToUpdate.Update_Request_Sales_Team__c = true;

        }  
        update userToUpdate;
                
    }
    @TestVisible
    private void createChatterNotif(Set<String> listUsersToNotif, String body)
    {
        List<FeedItem> listPostChatter = new List<FeedItem>();
        for(String userId: listUsersToNotif )
        {
            FeedItem post = new FeedItem();
            post.ParentId = userId;
            post.Body = body;
            listPostChatter.add(post);
        }

        insert listPostChatter;
    }
    
	@TestVisible
    private void uncheckUsers(Set<String> listUsersToNotif)
    {
        List<User> userToUpdate = [select Id, Update_Request_Sales_Team__c from User where Id IN :listUsersToNotif];

        List<User> usersToUncheck = new List<User>();
        for(User u:userToUpdate)
        {
            if(u.Update_Request_Sales_Team__c == true)
            {
                u.Update_Request_Sales_Team__c = false;
                usersToUncheck.add(u);
            }
        }

        if(usersToUncheck.size() > 0) update usersToUncheck;

    }


    public  void updateSalesTeamsVisibility(list<Sales_Team__c>  newSalesTeams, Map<Id,Sales_Team__c> oldSalesTeamsById, boolean isInsert){

        set<Id> salesTeamIds = new set<Id>();
        for (Sales_Team__c st: newSalesTeams){
            if ((oldSalesTeamsById != null && oldSalesTeamsById.get(st.Id) != null && (st.KAM__c != oldSalesTeamsById.get(st.Id).KAM__c
                    || st.Manager__c != oldSalesTeamsById.get(st.Id).Manager__c
                    || st.Director__c != oldSalesTeamsById.get(st.Id).Director__c
                    || st.Additional__c != oldSalesTeamsById.get(st.Id).Additional__c))
                    || isInsert == true){
                salesTeamIds.add(st.Id);
            }
        }

        if (salesTeamIds.size() > 0){
            list<Sales_Allocations__c> salesAllocations = [select Id, Account__c from Sales_Allocations__c
            where Sales_Team__c IN:salesTeamIds ];

            set<Id> accountIds = new set<Id>();
            for (Sales_Allocations__c sa: salesAllocations){
                accountIds.add(sa.Account__c);
            }

            Map<Id, Sales_Allocations__c> scopeSalesAlloc = new Map<Id, Sales_Allocations__c>([
                    SELECT id, Sales_Allocations__c.Product_Sub_Segment__c, Sales_Allocations__c.Account__c,
                            Sales_Team__c,sales_team__r.Tech_Overlapped_SalesTeam__c, KAMF__c, Manager__c, Director__c,
                            Additional__c, Sales_Team__r.KAM__c, Valid_To__c, Valid_From__c, Prod_Sub_Segment__c
                    FROM Sales_Allocations__c
                    WHERE Valid_From__c <= : Date.Today()
                    AND Valid_To__c >= :Date.Today()
                    AND Sales_Team__c != NULL
                    AND Account__c IN: accountIds
            ]);

            SalesAllocationsService.applySalesAllocation(scopeSalesAlloc);

        }

    }


}