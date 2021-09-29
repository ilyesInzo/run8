/**
 * Created by inzo on 21/09/2021.
 */

public with sharing class VisibilityTeamMemberService {

    public static final Date CURRENT_DATE = Date.today();
    public static final Date FUTURE_DATE = Date.newInstance(4000, 12, 31);
    // the field used in ST to the Role used in Account/Opp team members
    // this will make our work easier later
    public static final Map<String, String> fieldsToRole = new Map<String, String>{
            'KAM__c' => 'KAM', 'Manager__c' => 'Manager', 'Director__c' => 'Director', 'Additional__c' => 'Additional'
    };

    private static final String KAM = 'KAM';

    private static String LOG_CLASS_NAME = 'VisibilityTeamMemberService';
    // i need the isInsert to not compare as the oldMap is null
    // (i could check if this map is null and not use the isInsert any more)
    // the start/root will be the account so we will always group by account
    public static void getNewTeamVisibility(Map<Id, Sales_Allocations__c> newUpdatedSalesAllocationMap, List<Sales_Allocations__c> newSalesAllocationsToUpdate, Map<Id, Sales_Allocations__c> oldSalesAllocationsById, set<Id> accountIds, set<Id> newSalesTeamIDs, set<Id> oldSalesTeamIDs, Boolean isInsert) {
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getNewTeamVisibility Start');
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - NB affected accounts ' + accountIds.size());
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - NB affected salesTeams ' + newSalesTeamIDs.size());
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - NB updated/inserted salesAllocation ' + newSalesAllocationsToUpdate.size());
        // we need all the SalesTeam (new and old)
        // as they contain the DMKA profiles
        // we have to take the two following cases into consideration
        // 1- the sales team were empty and new affected
        // 2- the salesTeam existed and not anymore
        Map<Id, Sales_Team__c> newSalesTeams = new Map<Id, Sales_Team__c>([
                SELECT Id, KAM__c, Manager__c, Additional__c, Director__c
                FROM Sales_Team__c
                WHERE Id IN :newSalesTeamIDs
                AND Valid_From__c <= TODAY
                AND Valid_To__c >= TODAY
        ]);

        // we don't check Valid fields as the old could be archived or just replaced by other
        // no old SalesTeam for insert case
        Map<Id, Sales_Team__c> oldSalesTeam = isInsert ? null : new Map<Id, Sales_Team__c>([
                SELECT Id, KAM__c, Manager__c, Additional__c, Director__c
                FROM Sales_Team__c
                WHERE Id IN :oldSalesTeamIDs
        ]);

        // group by account <AccountID,AllocObject>
        Map<Id, List<Sales_Allocations__c>> accountToUpdatedSalesAllocationMap = new Map<Id, List<Sales_Allocations__c>>();
        // group by account <newSTId, <Role, <oldUser,newUser>>>
        // if no newSTId so no new user so the salesTeam was removed and the SA is not related to any
        Map<Id, Map<String, Map<ID, ID>>> changedTeamRoleBySalesTeamMap = new Map<Id, Map<String, Map<ID, ID>>>();

        for (Sales_Allocations__c salesAllocation : newSalesAllocationsToUpdate) {
            if (!accountToUpdatedSalesAllocationMap.containsKey(salesAllocation.Account__c)) {
                accountToUpdatedSalesAllocationMap.put(salesAllocation.Account__c, new List<Sales_Allocations__c>());
            }
            accountToUpdatedSalesAllocationMap.get(salesAllocation.Account__c).add(salesAllocation);

            // to avoid re-iterating later we will get and compare the changes
            // of course in case of insert this is not needed => no old SA/ST 1)
            // also in case the newSalesTeam was removed because in that case
            // we have just to get the oldSt with its old Roles 2)
            // and also the case the newSalesTeam treated 3)
            if (isInsert != true && salesAllocation.Sales_Team__c != null && !changedTeamRoleBySalesTeamMap.containsKey(salesAllocation.Sales_Team__c)) {
                // old and new SA have same id, but heir related ST are different
                // don't forget that one of the related ST could be empty but not both
                // if the salesTeam is treated once it is enough as we may have many SA with same ST (common case)
                changedTeamRoleBySalesTeamMap.put(salesAllocation.Sales_Team__c, getModifiedTeamRole(newSalesTeams.get(salesAllocation.Sales_Team__c), oldSalesTeam.get(oldSalesAllocationsById.get(salesAllocation.Id).Sales_Team__c), fieldsToRole)) ;

            }
        }

        // at the end of this call, we have all the AccountTeamMembers to create/update/delete
        treatAndFillAccountTeamMembers(newUpdatedSalesAllocationMap, oldSalesAllocationsById, accountIds, changedTeamRoleBySalesTeamMap, accountToUpdatedSalesAllocationMap, newSalesTeams, oldSalesTeam, isInsert);
        // in case of insert no opportunity exist for the SA
        if (isInsert != true) {
            // at the end of this call, we have all the opportunityTeamMembers to create/update/delete
            treatAndFillOpportunityTeamMembers(newUpdatedSalesAllocationMap, newSalesTeams, changedTeamRoleBySalesTeamMap);
        }

        //updateKamObjectif(newUpdatedSalesAllocations);

        // treat the Objectives either alone or inside the opportunities
        // should we also update opp owners when treating the OPP members?
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getNewTeamVisibility Stop');
    }
    private static Map<Id, Map<Id, Set<String>>> getAccountToNotUpdatedSalesAllocationMap(Map<Id, Sales_Allocations__c> newUpdatedSalesAllocations, set<Id> accountIds, Boolean isInsert) {


        //in case of insert all the allocation related to the account are not updated
        List<Sales_Allocations__c> salesAllocationsTemps;
        if(isInsert == true) {
             salesAllocationsTemps = new List<Sales_Allocations__c>([
                    SELECT Id,
                            Valid_From__c,
                            Valid_To__c,
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
                            Account__c,
                            ToArchiveWithValidTo__c,
                            ToArchiveWithValidFrom__c,
                            TECH_SalesTeam_Overlap__c
                    FROM Sales_Allocations__c
                    WHERE Account__c in :accountIds
                    And Valid_To__c >= :CURRENT_DATE
                    And Sales_Team__c != NULL
            ]);
        }else{
            salesAllocationsTemps = new List<Sales_Allocations__c>([
                    SELECT Id,
                            Valid_From__c,
                            Valid_To__c,
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
                            Account__c,
                            ToArchiveWithValidTo__c,
                            ToArchiveWithValidFrom__c,
                            TECH_SalesTeam_Overlap__c
                    FROM Sales_Allocations__c
                    WHERE Account__c in :accountIds
                    And Id not in :newUpdatedSalesAllocations.keySet()
                    And Valid_To__c >= :CURRENT_DATE
                    And Sales_Team__c != NULL
            ]);
        }


        Map<Id, Map<Id, Set<String>>> accountToNotUpdatedSalesAllocationMap = new Map<Id, Map<Id, Set<String>>>();

        // we have to do this for all the 4 DMKA
        // as for account we have many SA, and those SA could have the same ST
        // we don't have to get the DMKA for the same account and same salesTeam each time
        Set<AccountSalesTeam> AccountSalesTeamSet = new Set<AccountSalesTeam>();

        for (Sales_Allocations__c salesAllocation : salesAllocationsTemps) {
            // if the account not already added = neither the user nor his roles were added
            // some allocation could be not related to a team, so no need to work for no result ^^
            // we don't have to work if we have already a result this is why we use the AccountSalesTeamSet
            AccountSalesTeam accST = new AccountSalesTeam(salesAllocation.Account__c, salesAllocation.Sales_Team__c);
            if(salesAllocation.Sales_Team__r != null && !AccountSalesTeamSet.contains(accST)) {
                if (!accountToNotUpdatedSalesAllocationMap.containsKey(salesAllocation.Account__c)) {
                    accountToNotUpdatedSalesAllocationMap.put(salesAllocation.Account__c, getTeamRolesForSalesTeam(salesAllocation.Sales_Team__r, fieldsToRole, new Map<Id, Set<String>>()));
                } else {
                    accountToNotUpdatedSalesAllocationMap.put(salesAllocation.Account__c, getTeamRolesForSalesTeam(salesAllocation.Sales_Team__r, fieldsToRole, accountToNotUpdatedSalesAllocationMap.get(salesAllocation.Account__c)));
                }
                AccountSalesTeamSet.add(accST);
            }

        }

        return accountToNotUpdatedSalesAllocationMap;
    }
    // i know this method is a little bit tricky, it return the passed parameter
    // because it is filling it self, so when all the SA related to the account is treated
    // we will have all user with their roles for each account.
    // those user with that roles should remain in the accountTeamMembers
    private static Map<Id, Set<String>> getTeamRolesForSalesTeam(Sales_Team__c salesTeam, Map<String, String> fieldsToRole, Map<Id, Set<String>> teamRoles) {
        // we have the user and his possible roles
        for (String fieldName : fieldsToRole.keySet()) {
            Id newValue = (Id) salesTeam.get(fieldName);
            if (newValue != null) {

                if (!teamRoles.containsKey(newValue)) {
                    teamRoles.put(newValue, new Set<String>());
                }
                teamRoles.get(newValue).add(fieldsToRole.get(fieldName));
            }
        }
        return teamRoles;
    }

    private static Map<String, Map<ID, ID>> getModifiedTeamRole(Sales_Team__c newObj, Sales_Team__c oldObj, Map<String, String> fieldsToRole) {
        // <TeamRole, <oldUser, newUser>
        Map<String, Map<ID, ID>> changedTeamRole;

        for (String fieldName : fieldsToRole.keySet()) {
            ID newValue = newObj != null ? (ID) newObj.get(fieldName) : null;
            ID oldValue = oldObj != null ? (ID) oldObj.get(fieldName) : null;
            if (!SObjectUtils.equals(newValue, oldValue)) {
                changedTeamRole.put(fieldName, new Map<ID, ID>{
                        (oldValue) => (newValue)
                } );
            }
        }
        return changedTeamRole;
    }

    // if the DMKA doesn't exist it should be added
    private static Set<AccountTeamMember> getAccountTeamMembersToAdd(Sales_Team__c newSalesTeam, Map<Id, Set<String>> userRoles, ID accountID) {

        Set<AccountTeamMember> accountTeamMembers = new Set<AccountTeamMember>();
        for (String fieldName : fieldsToRole.keySet()) {
            ID user = (ID) newSalesTeam.get(fieldName);
            // the other SA are not using this user, so it could be added (no redundancy)
            if (user != null && !isAlreadyExist(user, fieldsToRole.get(fieldName), userRoles)) {
                // create Team Member
                accountTeamMembers.add(createNewAccountTeamMember(accountID,user,fieldsToRole.get(fieldName),'Edit','Edit'));
            }

        }
        return accountTeamMembers;

        /*
        if(newSalesTeam.KAM__c != null && isAlreadyExist(newSalesTeam.KAM__c, 'KAM', userRoles)){
            userRoles.get(newSalesTeam.KAM__c);
        }

        if(newSalesTeam.Director__c != null){

        }

        if(newSalesTeam.Manager__c != null){

        }

        if(newSalesTeam.Additional__c != null){

        }*/

    }

    private static Set<AccountTeamMember> getAccountTeamMembersToRemove(Sales_Team__c oldSalesTeam, Map<Id, Set<String>> userRoles, Map<Id, Map<String, AccountTeamMember>> accountTeamByUserMap) {

        Set<AccountTeamMember> accountTeamMembers = new Set<AccountTeamMember>();
        for (String fieldName : fieldsToRole.keySet()) {
            ID user = (ID) oldSalesTeam.get(fieldName);
            // the other SA are not using this user, so it could be removed from accountTeam
            if (user != null && !isAlreadyExist(user, fieldsToRole.get(fieldName), userRoles)) {

                // get the real account member (it should exist
                // otherwise something wrong or user was deleted/inactive and the ST were not updated)
                // to avoid null pointer we have to check

                AccountTeamMember accountTeamMember = getExistingAccountTeamMember(user, fieldsToRole.get(fieldName), accountTeamByUserMap);
                if(accountTeamMember != null){
                    accountTeamMembers.add(accountTeamMember);
                }
            }
        }
        return accountTeamMembers;
    }

    private static Boolean isAlreadyExist(ID user, String role, Map<Id, Set<String>> userRoles) {

        return userRoles!= null && userRoles.get(user) != null && userRoles.get(user).contains(role);
    }

    private static AccountTeamVisibility treatAndFillAccountTeamMembers(Map<Id, Sales_Allocations__c> newUpdatedSalesAllocations, Map<Id, Sales_Allocations__c> oldSalesAllocationsById, set<Id> accountIds, Map<Id, Map<String, Map<ID, ID>>> changedTeamRoleBySalesTeamMap, Map<Id, List<Sales_Allocations__c>> accountToUpdatedSalesAllocationMap, Map<Id, Sales_Team__c> newSalesTeams, Map<Id, Sales_Team__c> oldSalesTeams, Boolean isInsert) {

        // we need all the Sales Allocation related to the Account which are different from the new updated
        // and which are available/alive (not archived)
        // we will not have too much as most of them are in the newUpdated

        AccountTeamVisibility accountTeamVisibility = new AccountTeamVisibility();
        // this will avoid us looping all the not updated ST later
        Map<Id, Map<Id, Set<String>>> accountToNotUpdatedSalesAllocationMap = getAccountToNotUpdatedSalesAllocationMap(newUpdatedSalesAllocations, accountIds, isInsert);

        // we need all the Account Team Members related to those accounts
        // of course Plant and Product remain the same
        List< AccountTeamMember> accountTeamMemberTemps = new List<AccountTeamMember>([
                SELECT Id, AccountId, UserId, ContactAccessLevel, TeamMemberRole
                FROM AccountTeamMember
                WHERE AccountId IN :accountIds
                AND TeamMemberRole <> 'Plant'
                AND TeamMemberRole <> 'Product'
        ]);

        // the account members used by not-updated SalesAllocation must remain unchanged (not deleted or updated later)
        // this mean if a user U1 with a KAM Role (or any other role) is used by another SA
        // he stay unchanged to not affect other visibility
        // for the other account team it depends, only at the end of the execution of an account
        // we can guess this...
        // group by account <AccountID, <Userid, Map<Role , AccountMembers>>>
        Map<Id, Map<Id, Map<String, AccountTeamMember>>> accountToAccountTeamByUserMap = new Map<Id, Map<Id, Map<String, AccountTeamMember>>>();

        for (AccountTeamMember accountTeamMember : accountTeamMemberTemps) {
            // if the account not already added = neither the user nor his roles were added
            if (!accountToAccountTeamByUserMap.containsKey(accountTeamMember.AccountId)) {
                accountToAccountTeamByUserMap.put(accountTeamMember.AccountId, new Map<Id, Map<String, AccountTeamMember>>{
                        accountTeamMember.UserId => new Map<String, AccountTeamMember>{
                                accountTeamMember.TeamMemberRole => accountTeamMember
                        }
                } );
            } else {
                // if we have the account but not yet this user we have to add user and his roles
                if (!accountToAccountTeamByUserMap.get(accountTeamMember.AccountId).containsKey(accountTeamMember.UserId)) {
                    accountToAccountTeamByUserMap.get(accountTeamMember.AccountId).put(accountTeamMember.UserId, new Map<String, AccountTeamMember>{
                            accountTeamMember.TeamMemberRole => accountTeamMember
                    } );

                } else {
                    // else the user exist but we have to add this role
                    accountToAccountTeamByUserMap.get(accountTeamMember.AccountId).get(accountTeamMember.UserId).put(accountTeamMember.TeamMemberRole, accountTeamMember);
                }
            }

            // this list is important as i explained, it contain the account member to not touch in any case
            // in case of insert we don't have to fill it as it is equal to all the accountToAccountTeamByUserMap

        }
        /**************************** We Begin The Execution **************************/
        // actual user and his roles in the account member
        Map<Id, Map<String, AccountTeamMember>> accountTeamByUserMap;
        // actual user and his roles from the salesAlloc
        Map<Id, Set<String>> notUpdatedSalesAllocationMap;
        // in case of insert no id provided
        // so we don't use the map
        List<Sales_Allocations__c> updatedSalesAllocations;
        //if the ST for this account is treated no need to check again
        //
        Set<ID> treatedSalesTeamChanges;

        for (ID accountID : accountIds) {
            // currently we use the same Set for all the 3 cases explained below
            // but we could use different Sets
            treatedSalesTeamChanges = new Set<ID>();
            // the updated SA for this account
            updatedSalesAllocations = accountToUpdatedSalesAllocationMap.get(accountID);
            // this map could be empty either because we deal with insert operation
            // or all the active SAs related to this account were updated
            notUpdatedSalesAllocationMap = accountToNotUpdatedSalesAllocationMap != null && !accountToNotUpdatedSalesAllocationMap.isEmpty() ? accountToNotUpdatedSalesAllocationMap.get(accountID) : null;
            // this could be empty in case first SA/ST for this account
            accountTeamByUserMap = accountToAccountTeamByUserMap!= null ? accountToAccountTeamByUserMap.get(accountID) : null;

            Set<UserTeamRole> potentialUserToAdd = new Set<UserTeamRole>();
            Set<UserTeamRole> potentialUserToRemove = new Set<UserTeamRole>();


            // Some SA have the same related ST, so if it is treated once no need to check for the others (common case)
            for (Sales_Allocations__c newSA : updatedSalesAllocations) {

                // we have 3 different cases (this cases don't co-exist in normal case = only one for all the execution)
                // we insert an SA with SalesTeam (the case were we insert without SA not affect visibility abd we escaped it already)
                // we update an SA with SalesTeam (newly affected or new after archive) and without (removed)

                // ATTENTION the final operation ADD/REMOVE/UPDATE , in most case,could be determined after looping
                // through all the new SA related to the account
                if (newSA.Sales_Team__c != null) {
                    Sales_Team__c newSalesTeam = newSalesTeams.get(newSA.Sales_Team__c);

                    if (!treatedSalesTeamChanges.contains(newSalesTeam.Id)) {

                        if (isInsert == true) {
                            // 1) we check the other notUpdatedSA to guess if this user is new and need to be added to accountTeamMember

                            Set<AccountTeamMember> accountTeamToAdd = getAccountTeamMembersToAdd(newSalesTeam, notUpdatedSalesAllocationMap, accountID);
                            if (!accountTeamToAdd.isEmpty()) {
                                accountTeamVisibility.accountTeamToAdd.addAll(accountTeamToAdd);
                            }

                        } else {
                            // 2) we compare the change from old to new , afterwards we check the notUpdate to guess operation create/update/delete
                            // this is the most common and difficult case
                            Map<String, Map<ID, ID>> changedTeamRole = changedTeamRoleBySalesTeamMap.get(newSalesTeam.Id);
                            //this could be empty in only one case : we changed the SalesTeam but both of them (new and old) have the same DMKA
                            if(changedTeamRole != null && !changedTeamRole.isEmpty()){
                                // accountVisibility, potential user to add/remove will be changed in the method by reference
                                fillAccountMemberAfterSalesTeamChange(accountID, potentialUserToAdd,  potentialUserToRemove, notUpdatedSalesAllocationMap, accountTeamVisibility, accountTeamByUserMap, changedTeamRole);

                            }
                        }
                        treatedSalesTeamChanges.add(newSalesTeam.Id);
                    }

                } else {//not very common case but possible in the future (removed ST from SA)
                    //3) in that case we check only the notUpdatedSA to guess if the user will be removed from accountTeamMember
                    // we use the oldSalesAllocation for this case ;)
                    // this should exist
                    Sales_Team__c oldSalesTeam = oldSalesTeams.get(oldSalesAllocationsById.get(newSA.Id).Sales_Team__c);
                    // we verify that the accountTeam members exist
                    if (!treatedSalesTeamChanges.contains(oldSalesTeam.Id) && accountTeamByUserMap!=null && !accountTeamByUserMap.isEmpty()) {

                        Set<AccountTeamMember> accountTeamToRemove = getAccountTeamMembersToRemove(oldSalesTeam, notUpdatedSalesAllocationMap, accountTeamByUserMap);
                        if (!accountTeamToRemove.isEmpty()) {
                            accountTeamVisibility.accountTeamToRemove.addAll(accountTeamToRemove);
                        }
                        treatedSalesTeamChanges.add(oldSalesTeam.Id);
                    }
                }
            }//end loop updated SalesAllocation

            // after that we treated all the salesAllocation / SalesTeam related to the account
            // we have to do the last check to guess the final operation
            // this is applied only to the case 2)
            // if both empty so we have already the list of member to add/remove completed

            if(!potentialUserToRemove.isEmpty() || !potentialUserToAdd.isEmpty()){
                finalizeAccountTeamMember(accountID, potentialUserToAdd, potentialUserToRemove, accountTeamVisibility, accountTeamByUserMap);
            }

        }//end loop account
        return accountTeamVisibility;
    }

    private static OpportunityTeamVisibility treatAndFillOpportunityTeamMembers(Map<Id, Sales_Allocations__c> newUpdatedSalesAllocations, Map<Id, Sales_Team__c> newSalesTeams, Map<Id, Map<String, Map<ID, ID>>> changedTeamRoleBySalesTeamMap) {

        OpportunityTeamVisibility opportunityTeamMembers = new OpportunityTeamVisibility();

        // we need all opportunities related to the updated SA only
        // we will need quote and quoteLines also like what was done in the batch
        // as a double check seem to be needed

        // We need all the opportunity linked to the Sales Affectation and not to the Account
        // as the other opportunities must remain unchanged
        // the batch in the other hand is getting all opps because it is removing all opportunities
        // and this is what we want to avoid

        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([
                SELECT Id, AccountId, Sales_Allocation_Id__c,
                        OwnerId,Owner.ISM_Team_Member__c,
                        StageName
                FROM Opportunity
                WHERE Sales_Allocation_Id__c IN:newUpdatedSalesAllocations.keySet()
        ]);

        // We need all the opportunity team members related to the opportunity
        Set<Id> opportunityIds = opportunities.keySet();
        Map<Id, OpportunityTeamMember> opportunityTeamMembersTemp = new Map<Id, OpportunityTeamMember>([
                SELECT Id, OpportunityID, OpportunityAccessLevel, UserId, TeamMemberRole
                FROM OpportunityTeamMember
                WHERE OpportunityID IN :opportunityIds
                AND TeamMemberRole <> 'Plant'
                AND TeamMemberRole <> 'Product'
        ]);

        // like what we did with Accounts we will group by opp and user to make it easy the DMKA check
        // the only difference is that for an opportunity only one DMKA role should exist (no two kam or two director...)
        // so we will group by role not by user
        // group by opportunity <OpportunityID, <Role, OpportunityTeamMember>>
        Map<Id, Map<String, OpportunityTeamMember>> opportunityToOpportunityTeamByRoleMap = new Map<Id, Map<String, OpportunityTeamMember>>();

        for (OpportunityTeamMember opportunityTeamMember : opportunityTeamMembersTemp.values()) {
            // if the opportunity not already added = neither the role nor his related user were added
            if (!opportunityToOpportunityTeamByRoleMap.containsKey(opportunityTeamMember.OpportunityID)) {
                opportunityToOpportunityTeamByRoleMap.put(opportunityTeamMember.OpportunityID, new Map<String,OpportunityTeamMember>() );
            } else {
                // else we have the opportunity so we add the role and oppMember(user)
                // the role is related to only one user in case of opportunity
                // this is why we don't check, we don't have more than one oppMemberTeam for a role
                opportunityToOpportunityTeamByRoleMap.get(opportunityTeamMember.OpportunityID).put(opportunityTeamMember.TeamMemberRole, opportunityTeamMember );
            }

        }
        // for those opp, the KAM were changed and need to be updated
        // it will be treated in the same time with the opp to avoid looping again
        // the opportunity owner update called in the salesTeam after update trigger will be removed
        //List<Opportunity> opportunitiesWithDifferentOwnerToUpdate = new List<Opportunity>();

        for(Opportunity opportunity : opportunities.values()){
            // get the actual role and his related user for that opportunity
            Map<String, OpportunityTeamMember> opportunityTeamByRoleMap = opportunityToOpportunityTeamByRoleMap.get(opportunity.Id);

            // get the SalesTeam form the SalesAllocation related to this account
            // it should exist if we don't treat the case where a ST was removed from the SA
            Sales_Team__c newSalesTeam =  newSalesTeams.get(newUpdatedSalesAllocations.get(opportunity.Sales_Allocation_Id__c).Sales_Team__c);

            if(newSalesTeam != null){

                // get the change in the new salesTeam
                Map<String, Map<ID, ID>> changedTeamRole = changedTeamRoleBySalesTeamMap.get(newSalesTeam.Id);

                // if no change for the salesTeam so no update for the opp
                // the good thing is that we can guess if the KAM role was changed
                // and so update the opp owner if the other condition were also met
                if (changedTeamRole!= null && !changedTeamRole.isEmpty())
                {
                    fillOpportunityMemberAndOpportunityNewOwner(opportunity, changedTeamRole, opportunityTeamByRoleMap, opportunityTeamMembers);
                }// end check if a salesteam DMKA were changed

            }else{
                // like for the AccountTeam this case is not very common but possible in the future
                // if the salesTeam were removed from the SA (the SA don't point to a ST any more)
                // so all the opportunity team should be deleted
                opportunityTeamMembers.opportunityTeamToRemove.add(opportunityTeamByRoleMap.values());
            }

        }

        return opportunityTeamMembers;

    }


    private static void fillAccountMemberAfterSalesTeamChange(ID accountID, Set<UserTeamRole> potentialUserToAdd, Set<UserTeamRole> potentialUserToRemove, Map<Id, Set<String>> notUpdatedSalesAllocationMap, AccountTeamVisibility accountTeamVisibility, Map<Id, Map<String, AccountTeamMember>> accountTeamByUserMap, Map<String, Map<ID, ID>> changedTeamRole){

        for( String role : changedTeamRole.keySet()){
            // only one entry in this map
            Map<ID, ID> oldToNewUser = changedTeamRole.get(role);

            for(ID oldUser : oldToNewUser.keySet()){
                ID newUser = oldToNewUser.get(oldUser);

                // now wa have to compare with the notToUpdate
                // and guess if the new must be added/ and if the old must be removed
                // or to do nothing if the one to be removed will be added later and vice-versa
                // Attention the notToUpdate could be empty (case all SA related to the account were changed)

                // if old user exist in the other not updated SA/ST we don't remove it
                if(isAlreadyExist(oldUser, role, notUpdatedSalesAllocationMap) && accountTeamByUserMap!= null && !accountTeamByUserMap.isEmpty()){
                    // we have to get the accountTeamMember
                    AccountTeamMember accountTeamMember = getExistingAccountTeamMember(oldUser, role, accountTeamByUserMap);
                    if(accountTeamMember!= null)
                    {
                        accountTeamVisibility.accountTeamToRemove.add(accountTeamMember);
                    }

                }else {
                    //otherwise it could be removed, but we have to check the rest of the updated SA/ST
                    potentialUserToRemove.add(new UserTeamRole(role, oldUser));
                }

                // if new user exist in the other not updated SA/ST we don't re-add it
                if(isAlreadyExist(newUser, role, notUpdatedSalesAllocationMap)){
                    // no worry if two old ST will be changed to the same ST
                    // as we use Set it will be added once
                    accountTeamVisibility.accountTeamToAdd.add(createNewAccountTeamMember(accountID, newUser, role, 'Edit', 'Edit'));
                }else{
                    // otherwise it could be added, but we have to check the rest of the updated SA/ST
                    potentialUserToAdd.add(new UserTeamRole(role, newUser));
                }
            }
        }

    }

    private static void finalizeAccountTeamMember(ID accountID, Set<UserTeamRole> potentialUserToAdd, Set<UserTeamRole> potentialUserToRemove, AccountTeamVisibility accountTeamVisibility, Map<Id, Map<String, AccountTeamMember>> accountTeamByUserMap){

        // To Add
        Set<UserTeamRole> differenceBetweenAddAndRemove = new Set<UserTeamRole>();
        differenceBetweenAddAndRemove.addAll(potentialUserToAdd);
        differenceBetweenAddAndRemove.removeAll(potentialUserToRemove);

        if(!differenceBetweenAddAndRemove.isEmpty())
        {
            for(UserTeamRole userRole : differenceBetweenAddAndRemove){

                accountTeamVisibility.accountTeamToAdd.add(createNewAccountTeamMember(accountID,userRole.user,userRole.role,'Edit','Edit'));
            }

        }
        // To Remove
        differenceBetweenAddAndRemove = new Set<UserTeamRole>();
        differenceBetweenAddAndRemove.addAll(potentialUserToRemove);
        differenceBetweenAddAndRemove.removeAll(potentialUserToAdd);

        if(!differenceBetweenAddAndRemove.isEmpty())
        {
            for(UserTeamRole userRole : differenceBetweenAddAndRemove){

                AccountTeamMember accountTeamMember = getExistingAccountTeamMember(userRole.user, userRole.role, accountTeamByUserMap);
                if(accountTeamMember!= null)
                {
                    accountTeamVisibility.accountTeamToRemove.add(accountTeamMember);
                }
            }
        }
    }

    private static void fillOpportunityMemberAndOpportunityNewOwner(Opportunity opportunity, Map<String, Map<ID, ID>> changedTeamRole, Map<String, OpportunityTeamMember> opportunityTeamByRoleMap, OpportunityTeamVisibility opportunityTeamMembers){

        for(String role : changedTeamRole.keySet())
        {   // only one entry exist in this map
            Map<ID, ID> oldToNewUser = changedTeamRole.get(role);

            for(ID oldUser : oldToNewUser.keySet()) {
                ID newUser = oldToNewUser.get(oldUser);
                // if the new user add/removed user is a kam we MAY update the opp owner
                if(KAM.equals(role)){
                    fillOpportunitiesWithOwnerToUpdate(opportunity, newUser, opportunityTeamMembers.opportunitiesWithDifferentOwnerToUpdate);
                }

                //the user exit so the operation is either add or update
                if(newUser != null){
                    //we have an opportunity with this role so we update its user (which is the oldUser)
                    if (opportunityTeamByRoleMap != null && !opportunityTeamByRoleMap.isEmpty() && opportunityTeamByRoleMap.get(role)!= null) {

                        OpportunityTeamMember opportunityTeamMember = opportunityTeamByRoleMap.get(role);
                        opportunityTeamMember.UserId = newUser;
                        opportunityTeamMembers.opportunityTeamToUpdate.add(opportunityTeamMember);

                    }else {
                        // otherwise a new opp member should be created
                        opportunityTeamMembers.opportunityTeamToAdd.add(createNewOpportunityTeamMember(opportunity.Id, newUser, role, 'Edit'));
                    }

                }else {
                    // the user was removed so we remove it from the opportunityTeam
                    // Attention it should exist otherwise it was removed manually or something else

                    if (opportunityTeamByRoleMap != null && !opportunityTeamByRoleMap.isEmpty() && opportunityTeamByRoleMap.get(role)!= null) {
                        opportunityTeamMembers.opportunityTeamToRemove.add(opportunityTeamByRoleMap.get(role));
                    }

                }

            } // end getting the old and the new user for a role

        }// end loop roles

    }

    private static void fillOpportunitiesWithOwnerToUpdate(Opportunity opportunity, ID newUser, List<Opportunity> opportunitiesWithDifferentOwnerToUpdate){

        // check if this opportunity need really to be updated
        if(opportunity.ownerID != newUser && opportunity.owner.ISM_Team_Member__c != True && opportunity.StageName != 'Simulation'){
            opportunitiesWithDifferentOwnerToUpdate.add(opportunity);
        }

    }

    private static void updateKamObjectif(Map<Id, Sales_Allocations__c> newUpdatedSalesAllocations){

        Integer year = system.date.today().year()-1;
        Set<Id> newSalesAllocationIDs = newUpdatedSalesAllocations.keySet();
        list<Objectives__c> objectivesToUpdate = [Select Id, Account__c, Sub_Segment__c, Sales_Allocation__c
                , Sales_Allocation__r.Account__c, Sales_Allocation__r.Product_Sub_Segment__c
                 From Objectives__c
        where Sales_Allocation__c IN:newSalesAllocationIDs
        and Calendar_Year(Date__c) >=: year  ];


        Map<Id, Objectives__c> filteredObjectives = new Map<Id, Objectives__c>();
        Set<Id> filteredObjectivesIds = new Set<Id>();
        for (Objectives__c obj : objectivesToUpdate) {
            // why is this check needed
            // i will keep it
            if(obj.Account__c == obj.Sales_Allocation__r.Account__c && obj.Sub_segment__c == obj.Sales_Allocation__r.Product_Sub_Segment__c) {
                filteredObjectives.put(obj.Id,obj);
            }
        }

        filteredObjectivesIds = filteredObjectives.keySet();
        List<Objectives__Share> lObjShare = [SELECT Id From Objectives__Share WHERE ParentId in :filteredObjectivesIds and AccessLevel != 'All'];

        /*
        for (Objectives__c objectives : filteredObjectives.values()) {
            if (!accountToUpdatedSalesAllocationMap.containsKey(salesAllocation.Account__c)) {
                accountToUpdatedSalesAllocationMap.put(salesAllocation.Account__c, new Map<Id, Sales_Allocations__c>());
            }
            accountToUpdatedSalesAllocationMap.get(salesAllocation.Account__c).put(salesAllocation.Id, salesAllocation);
        }*/






        //AP01_Objective_Rules.kamObjectiveshare(objectivesToUpdate);

    }


    private static AccountTeamMember createNewAccountTeamMember(Id accountID, Id user, String teamMemberRole, String accountAccessLevel, String contactAccessLevel){
        return new AccountTeamMember(
                AccountId = accountID,
                UserId = user,
                TeamMemberRole =  teamMemberRole,
                AccountAccessLevel = accountAccessLevel,
                ContactAccessLevel = contactAccessLevel);
    }

    private static OpportunityTeamMember createNewOpportunityTeamMember(Id opportunityID, Id user, String teamMemberRole, String opportunityAccessLevel){
        return new OpportunityTeamMember(
                OpportunityId = opportunityID,
                UserId = user,
                TeamMemberRole = teamMemberRole,
                OpportunityAccessLevel = opportunityAccessLevel);
    }

    private static AccountTeamMember getExistingAccountTeamMember(Id user, String teamMemberRole, Map<Id, Map<String, AccountTeamMember>> accountTeamByUserMap){
        AccountTeamMember accountTeamMember;
        if(accountTeamByUserMap.get(user)!= null){
             accountTeamMember = accountTeamByUserMap.get(user).get(teamMemberRole);
        }
        return accountTeamMember;
    }


    /*************************Inner Class To Restructure Code***************************/

    private class AccountTeamVisibility {
        // we use set to avoid redundancy as the same team member could exist in both ST
        public Set<AccountTeamMember> accountTeamToRemove = new Set<AccountTeamMember>();
        public Set<AccountTeamMember> accountTeamToAdd = new Set<AccountTeamMember>();
        // we may not use it right now
        public Set<AccountTeamMember> accountTeamToUpdate = new Set<AccountTeamMember>();


        public AccountTeamVisibility() {

        }

    }

    private class OpportunityTeamVisibility {

        public Set<OpportunityTeamMember> opportunityTeamToRemove = new Set<OpportunityTeamMember>();
        public Set<OpportunityTeamMember> opportunityTeamToAdd = new Set<OpportunityTeamMember>();
        public Set<OpportunityTeamMember> opportunityTeamToUpdate = new Set<OpportunityTeamMember>();
        public List<Opportunity> opportunitiesWithDifferentOwnerToUpdate = new List<Opportunity>();

        public OpportunityTeamVisibility() {

        }

    }

    private class UserTeamRole implements Comparable {

        String role;
        ID user;

        public UserTeamRole(){
        }

        public UserTeamRole(String role, ID user){
            this.role = role;
            this.user = user;
        }

        public Integer compareTo(Object compareTo) {
            UserTeamRole ut = (UserTeamRole) compareTo;
            if(this.role.equals(ut.role) && this.user.equals(ut.user)){
                return 0;
            }
            return -1;
        }
    }

    private class AccountSalesTeam implements Comparable {

        ID account;
        ID salesTeam;

        public AccountSalesTeam(){
        }

        public AccountSalesTeam(ID account, ID salesTeam){
            this.account = account;
            this.salesTeam = salesTeam;
        }

        public Integer compareTo(Object compareTo) {
            AccountSalesTeam asTeam = (AccountSalesTeam) compareTo;
            if(this.account.equals(asTeam.account) && this.salesTeam.equals(asTeam.salesTeam)){
                return 0;
            }
            return -1;
        }
    }

}