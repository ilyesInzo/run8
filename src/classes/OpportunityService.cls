/**
* @description Service class for interacting with Opportunity Object
* @author MQ
* @date 16/10/2017
*
*/
public class OpportunityService {
	
    private static OpportunityService instance = null;
	Private static final String authoProfilesIDToDelQLI = Label.Auth_Profile_Delete;
    
    private OpportunityService() {
    }
     
    public static OpportunityService getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) {
            instance = new OpportunityService();
        }
        return instance;
    }
    
    public class BadException extends Exception {}

    /**
     * @description get all Opportunities by Sales Allocations Ids
     * @param salesAllocationsIds [set of Sales Allocations Ids]
     * @return opportunities [List of Opportunity]
     */
    public List<Opportunity> getOpportunitiesBySalesAllocationsId(Set<Id> salesAllocationsIds) {

        List<Opportunity> opportunities = [
            Select 
                Id,
                OwnerId,Owner.ISM_Team_Member__c,
                Sales_Allocation_Id__c,StageName
            From Opportunity
            Where Sales_Allocation_Id__c In :salesAllocationsIds and StageName != 'Simulation' and StageName != 'Closed Lost' and StageName != 'Closed Killed' and StageName != 'Closed Won'
        ]; 

        return opportunities;
    }

    /**
     * @description update the Opportunity OwnerId when a Sales Team is modified
     * @param newSalesTeam [List of Sales_Team__c]
     * @param oldSalesTeamsById [Map of Sales_Team__c by Id]
     * @return updateResults [List of Database.SaveResult]
     */
    public void updateOpptyOwnerId(List<Sales_Team__c> newSalesTeam, Map<Id,Sales_Team__c> oldSalesTeamsById) {

        Set<String> fieldsToCompare = new Set<String>{'KAM__c','Manager__c','Director__c','Additional__c'};
        Set<Id> salesTeamUpdatedOrInsertedIds = new Set<Id>();
        for (Sales_Team__c st : newSalesTeam) {
            // Get only Ids of Sales Teams which have users updated
            if (SObjectUtils.isModified(st,oldSalesTeamsById.get(st.id),fieldsToCompare)) {
                salesTeamUpdatedOrInsertedIds.add(st.Id);
            } 
        }

        System.debug(LoggingLevel.ERROR,'OpportunityService.updateOpptySalesTeam : salesTeamUpdatedOrInsertedIds = '+salesTeamUpdatedOrInsertedIds);
        if (!salesTeamUpdatedOrInsertedIds.isEmpty()) {

            // Fetch Active Sales Allocations
            Map<Id, Sales_Allocations__c> salesAllocationsById = SalesAllocationsService.getInstance().getValidSalesAllocationsFromSalesTeamIds(salesTeamUpdatedOrInsertedIds);

            // Fetch the concerned Opportunities
            List<Opportunity> oppsToUpdate = getOpportunitiesBySalesAllocationsId(salesAllocationsById.keySet());
            
            // Update Opportunities owner and Sales Allocation Team linked to
            // the newSalesAllocation
            if(!oppsToUpdate.isEmpty()) {
                list <Opportunity> finalList = new list<Opportunity>();

                for(Opportunity opp : oppsToUpdate) {
                    Sales_Allocations__c sa = salesAllocationsById.get(opp.Sales_Allocation_Id__c);
                    //System.debug(LoggingLevel.ERROR,'OpportunityService.updateOpptySalesTeam : KamId before = '+opp.OwnerId);
                    if (opp.OwnerId !=   sa.Sales_Team__r.KAM__c && opp.Owner.ISM_Team_Member__c != True && opp.StageName != 'Simulation')
                            {
                                opp.OwnerId = sa.Sales_Team__r.KAM__c;
                                finalList.add(opp);
                            }
                    //System.debug(LoggingLevel.ERROR,'OpportunityService.updateOpptySalesTeam : KamId after = '+opp.OwnerId);           
                }

                // We can't have partial success, we need a rollback, so set to true
                update finalList;      

            }
        }

    }

    /**
     * @description update the Opportunity Sales Team if the Sales Allocations is archived
     * @param salesAllocationToArchived [List of Sales_Allocations__c]
     * @return
     */
    public List<Database.SaveResult> updateOpptyOwnerId(Map<Id,Sales_Allocations__c> salesAllocationToArchivedById) {

       
        List<Database.SaveResult> updateResults = new List<Database.SaveResult>();
        // Fetch the concerned Opportunities
        List<Opportunity> oppsToUpdate = getOpportunitiesBySalesAllocationsId(salesAllocationToArchivedById.keySet());
        
        // Update Opportunities owner and Sales Allocation Team linked to
        // the newSalesAllocation
        list <Opportunity> finalList = new list<Opportunity>();
        if(!oppsToUpdate.isEmpty()) {
            
            for(Opportunity opp : oppsToUpdate) {
                Sales_Allocations__c sa = salesAllocationToArchivedById.get(opp.Sales_Allocation_Id__c);

                //System.debug(LoggingLevel.ERROR,'OpportunityService.updateOpptySalesTeam : KamId before = '+opp.OwnerId);
                 if (opp.OwnerId !=   sa.Sales_Team__r.KAM__c && sa.Sales_Team__r.KAM__c!= null && opp.Owner.ISM_Team_Member__c != True && opp.StageName != 'Simulation')
                    {
                         opp.OwnerId = sa.Sales_Team__r.KAM__c;
                         finalList.add(opp);
                    }
                //System.debug(LoggingLevel.ERROR,'OpportunityService.updateOpptySalesTeam : KamId after = '+opp.OwnerId);           
            }

            // We can't have partial success, we need a rollback, so set to true
            updateResults = Database.update(finalList, true);        

        }

        return updateResults;
        
    }
    
    /**
     * @description update the Opportunity ownerID if it is attached to a salesAlloc
     * @param listSalesAllocations [List of Sales_Allocations__c]
     * @return
     */
    
        public static void updateOpptyOwnerId(List<Opportunity> liOpportunitiesToProcess) {       
        //Fill the list of opportunities to update
        List<Opportunity> liOppToUpdate = new  List<Opportunity>();

        Map<Id,Id> owners = new Map<Id,Id>();

        for(Opportunity opp: liOpportunitiesToProcess){
        	//check if the KAM of the attached sales allocation is different from the current owner
        	if(opp.ownerID != opp.Sales_Allocation_Id__r.sales_team__r.kam__c && opp.owner.ISM_Team_Member__c != True && opp.StageName != 'Simulation'){
                
                owners.put(opp.Id,opp.ownerID);

        		opp.ownerid = opp.Sales_Allocation_Id__r.sales_team__r.kam__c;	
                liOppToUpdate.add(opp);
        	}//end if kam != owner	
        }//end loop through liOpportunitiesToProcess
    	
    	update liOppToUpdate;

        //Update the OpportunityTeamMembers of the last Owners => Edit 
        Set<String> roles = new Set<String>{'KAM','Manager','Director','Additional'};
        List<OpportunityTeamMember> oppMembers = [select id, OpportunityId,UserId,TeamMemberRole,opportunityAccessLevel 
                                                from OpportunityTeamMember where OpportunityId in :owners.keySet() and TeamMemberRole in: roles];

        List<OpportunityTeamMember> oppMemberstoUpdate = new list<OpportunityTeamMember>();

        for(OpportunityTeamMember opm : oppMembers){

            if(opm.UserId == owners.get(opm.OpportunityId)){
                opm.opportunityAccessLevel = 'Edit';
                oppMemberstoUpdate.add(opm);
            }
        }

        update oppMemberstoUpdate;                                        

    }//end method
    
    public static void checkEditSimulationStatus( List<Opportunity> newOpportunities , Map<Id, Opportunity> oldMapOpportunities ) {
        
        if (!authoProfilesIDToDelQLI.contains(UserInfo.getProfileId())) {
			for (Opportunity opp : newOpportunities) 
            {
                if(opp.StageName != 'Simulation' && oldMapOpportunities.containsKey(opp.id) && oldMapOpportunities.get(opp.id).StageName == 'Simulation'){
                    if( opp.TECH_EditSimulationStatus__c == false ){
                		opp.addError(Label.MSG_OppChangeSimulationStatus);
                	}
                	else{
                    	opp.TECH_EditSimulationStatus__c = false;
                	}
            	}		
			}
        }
        
    }

}