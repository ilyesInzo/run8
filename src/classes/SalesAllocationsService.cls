/**
* Service class for interacting with Sales Allocations
*
* @author MDK
* @date 09/10/2017
* @description
*
*/
public class SalesAllocationsService extends SalesService {

    ///////////////////////////////////////////////////////////////////////////////
    // WHEN CHILD CLASS EXTENDS AN ABSTRACT PARENT CLASS WE CAN'T USE STATIC METHOD
    // OF THE PARENT SO WE HAVE TO IMPLEMENT THE SINGLETON PATTERN
    ///////////////////////////////////////////////////////////////////////////////
    /**
     * @description Singleton : private static variable referencing the class
     */
    private static SalesAllocationsService instance = null;

    /**
     * @description [SalesAllocationsService : private constructor (Singleton pattern)]
     * @return [a new instance of the class]
     */
    private SalesAllocationsService() {
    }

    /**
     * @description [getInstance : a static method that returns the unique instance of the class (Singleton pattern)]
     * @return [description]
     */
    public static SalesAllocationsService getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) {
            instance = new SalesAllocationsService();
        }
        return instance;
    }
    ///////////////////////////////////////////////////////////////////////////////


    private static String LOG_CLASS_NAME = 'SalesAllocationService';

	/**
     * @description [getValidSalesAllocationsFromSalesTeamIds : description]
     * @param salesTeamIds [description]
     * @return salesAllocationsById [Sales_Allocations__c.Id => Sales_Allocations__c]
     */
    public Map<Id, Sales_Allocations__c> getValidSalesAllocationsFromSalesTeamIds(Set<Id> salesTeamIds) {

        Map<Id, Sales_Allocations__c> salesAllocationsById = new Map<Id, Sales_Allocations__c>([
			Select  Id,
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
            From Sales_Allocations__c
            Where Sales_Team__c in :salesTeamIds
            And Valid_To__c >= :CURRENT_DATE
        ]);

        return salesAllocationsById;
    }

	/**
     * @description
     * @param
     * @return
     */
	public void linkClonedSalesTeamsToSalesAllocations(Set<Id> resetedSalesTeamIds, List<Sales_Team__c> clonedSalesTeams){

		Map<Id, Sales_Allocations__c> salesAllocationsToLink = getValidSalesAllocationsFromSalesTeamIds(resetedSalesTeamIds);

        if(!clonedSalesTeams.isEmpty()) {

        	Map<Object, SObject> clonedSalesTeamsByTechOverSTId = SObjectUtils.toMap(clonedSalesTeams,'Tech_Overlapped_SalesTeam__c');

        	for(Sales_Allocations__c sa : salesAllocationsToLink.values()) {

                // Set the Archive Date for the Archived Bath (see ArchiveSalesAllocationBatch)
                // if Sales Allocations have been archived
                if (sa.ToArchiveWithValidTo__c == null && sa.ToArchiveWithValidFrom__c == null) {
                    sa.ToArchiveWithValidTo__c = YESTERDAY_DATE;
                    sa.ToArchiveWithValidFrom__c = sa.Valid_From__c;
                }  else {
                    sa.addError(System.Label.SALESALLOCATION_ARCHIVE_ERRORMSG);
                }
                sa.TECH_SalesTeam_Overlap__c = sa.Sales_Team__c;
                sa.Valid_From__c = CURRENT_DATE;
                sa.Sales_Team__c = ((Sales_Team__c) clonedSalesTeamsByTechOverSTId.get((Id) sa.Sales_Team__c)).Id;
                sa.Sales_Allocation_Unique_Checker__c = sa.Account__c +'_'+ sa.Product_Sub_Segment__c +'_'+String.valueOf(sa.Valid_To__c);
            }

        	if (!salesAllocationsToLink.isEmpty()) {
        		system.debug(LoggingLevel.ERROR,'SalesAllocationsService.linkClonedSalesTeamsToSalesAllocations : Nbr of Sales Allocations to update = '+salesAllocationsToLink.values().size());
                // We have to bypass the Trigger to optimize the performance
                // Be careful to check if something has to be done on SA in the trigger to do it here.
				//TriggerHandler.bypass('SalesAllocationsTriggerHandler');
                update salesAllocationsToLink.values();
                //TriggerHandler.clearBypass('SalesAllocationsTriggerHandler');
        	}
        }
	}


    /**
     * @description
     * @param
     * @return
     */
    public void setSalesAllocationUniqueChecker(List<Sales_Allocations__c> newSalesAllocations) {
        for(Sales_Allocations__c sa : newSalesAllocations) {
            sa.Sales_Allocation_Unique_Checker__c = sa.Account__c +'_'+ sa.Product_Sub_Segment__c +'_'+String.valueOf(sa.Valid_To__c);
        }
    }

	/**
     * @description
     * @param
     * @return
     */
	public List<Database.SaveResult> archiveSalesAllocations(List<Sales_Allocations__c> salesAllocations) {

		List<Sales_Allocations__c> salesAllocationsToInsert = new List<Sales_Allocations__c>();
    	for(Sales_Allocations__c sa : salesAllocations){

 			Sales_allocations__c saToArchive = new Sales_allocations__c();
 			saToArchive.Valid_From__c 			= sa.ToArchiveWithValidFrom__c;
 			saToArchive.Valid_To__c 			= sa.ToArchiveWithValidTo__c;
 			saToArchive.Account__c				= sa.Account__c;
 			saToArchive.Product_Sub_Segment__c 	= sa.Product_Sub_Segment__c;
 			saToArchive.Sales_Team__c 			= sa.Tech_SalesTeam_Overlap__c;


            System.debug(LoggingLevel.DEBUG, 'Valid_From__c : ' + saToArchive.Valid_From__c);

         	salesAllocationsToInsert.add(saToArchive);
        }

        // We can't have partial success, we need a rollback, so set to true
        List<Database.SaveResult> insertResults = Database.insert(salesAllocationsToInsert,true);

    	return insertResults;

    }

    /**
     * @description
     * @param
     * @return
     */
    public List<Database.SaveResult> resetSalesAllocationsArchivedDate(List<Sales_Allocations__c> salesAllocations) {

        for(Sales_Allocations__c sa : salesAllocations){
            sa.ToArchiveWithValidFrom__c = null;
            sa.ToArchiveWithValidTo__c = null;
        }

        // To be sure to not run the trigger again and have DML issue
        TriggerHandler.bypass('SalesAllocationsTriggerHandler');

        // We can't have partial success, we need a rollback, so set to true
        List<Database.SaveResult> updateResults = Database.update(salesAllocations,true);

        TriggerHandler.clearBypass('SalesAllocationsTriggerHandler');

        return updateResults;

    }

    /**
     * [ applySalesAllocation description : applied the new sales team to the concerned accounts and opportunities ]
     * @param Map<Id, Sales_Allocations__c> [ salesAllocations : sales allocations send by a script ]
     */
    public static void applySalesAllocation(Map<Id, Sales_Allocations__c> salesAllocations){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - applySalesAllocation Start');

        //We need to get all the active use
        Map<Id, User> activeUsers = new Map<Id, User>([
            SELECT Id, IsActive
              FROM User
             WHERE IsActive = True
        ]);

        Set<SalesTeamAffectation> currentSalesTeamAffectations = SalesTeamAffectation.getSalesTeamAffectations(salesAllocations, activeUsers);

        //First we need to get the old AccountTeamMembers and OpportunityTeamMembers
        Set<AccountTeamMember> oldAccountTeamMembers = new Set<AccountTeamMember>();
        for(SalesTeamAffectation currentSalesTeamAffectation : currentSalesTeamAffectations){
            if(currentSalesTeamAffectation.getAccountTeamMembersToDelete() != null)
                oldAccountTeamMembers.addAll(currentSalesTeamAffectation.getAccountTeamMembersToDelete());
        }

        Set<OpportunityTeamMember> oldOpportunityTeamMembers = new Set<OpportunityTeamMember>();
        for(SalesTeamAffectation currentSalesTeamAffectation : currentSalesTeamAffectations){
            if(currentSalesTeamAffectation.getOpportunityTeamMembersToDelete() != null)
                oldOpportunityTeamMembers.addAll(currentSalesTeamAffectation.getOpportunityTeamMembersToDelete());
        }

        //Then we need to get the new AccountTeamMembers and OpportunityTeamMembers
        Set<AccountTeamMember> newAccountTeamMembers = new Set<AccountTeamMember>();
        for(SalesTeamAffectation currentSalesTeamAffectation : currentSalesTeamAffectations){
            if(currentSalesTeamAffectation.getNewAccountTeamMembers(activeUsers) != null)
                newAccountTeamMembers.addAll(currentSalesTeamAffectation.getNewAccountTeamMembers(activeUsers));
        }

        Set<OpportunityTeamMember> newOpportunityTeamMembers = new Set<OpportunityTeamMember>();
        for(SalesTeamAffectation currentSalesTeamAffectation : currentSalesTeamAffectations){
            if(currentSalesTeamAffectation.getNewOpportunityTeamMembers(activeUsers) != null)
                newOpportunityTeamMembers.addAll(currentSalesTeamAffectation.getNewOpportunityTeamMembers(activeUsers));
        }

        //After that, we need to delete the old AccountTeamMembers and the old OpportunityTeamMembers
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deletion phase start');
        delete(new List<AccountTeamMember>(oldAccountTeamMembers));
        delete(new List<OpportunityTeamMember>(oldOpportunityTeamMembers));
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deletion phase stop');

        //We finish by creating the new AccountTeamMembers and OpportunityTeamMembers
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - insertion phase start');
        insert(new List<AccountTeamMember>(newAccountTeamMembers));

        //We're going to manage the new Opportunity Team Members with specific option
        Database.DMLOptions otmDMLOptions = new Database.DMLOptions();
        otmDMLOptions.optAllOrNone = false;
        List<Database.SaveResult> opportunityTeamMemberDMLResults =
                Database.insert(
                      new List<OpportunityTeamMember>(newOpportunityTeamMembers),
                      otmDMLOptions
        );
        String errorMessages = '';
        for(Database.SaveResult opportunityTeamMemberDMLResult : opportunityTeamMemberDMLResults){
            if(! opportunityTeamMemberDMLResult.isSuccess()){
                for(Database.Error error : opportunityTeamMemberDMLResult.getErrors()){
                    errorMessages += '|' + error.getMessage();
                }
            }
        }
        if(errorMessages.length() > 0){
            throw new SalesAllocationException('');
        }
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - insertion phase stop');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - applySalesAllocation Stop');

    }

    public  void updateRequestForSalesAllocations(List<Sales_Allocations__c> salesAllocations, Map<Id,Sales_Allocations__c> oldSalesAllocationsById){
       System.debug('@@@ salesAllocations: '+ salesAllocations);
        Set<String> fieldsToCompare = new Set<String>{'New_KAM__c','New_Director__c','New_Manager__c','New_Additionnal__c'};

        //Added by Thanina.
        Set<String> fieldRequestStatus = new Set<String>{'Request_MAJ_Alloc_Status__c'};

        //-- End Added for NZ2-------

       boolean updateUser = false;

        //Added by Zak
        //When a request is rejected or Approved the submitter need to receive a Notification
        boolean notifyUser= false;
        Set<String> listUsersToNotif = new Set<String>();
        String notifDescription ='';

       for (Sales_Allocations__c salesA:salesAllocations){
            //Case_1
           if (oldSalesAllocationsById !=null && SObjectUtils.isModified(salesA,oldSalesAllocationsById.get(salesA.id),fieldsToCompare)
           && (salesA.New_KAM__c != null || salesA.New_Director__c != null
              || salesA.New_Manager__c != null || salesA.New_Additionnal__c!= null)) {

               salesA.Submitted_by__c = UserInfo.getUserId();
               updateUser = true;
               if (salesA.Request_MAJ_Alloc_Status__c != Label.Request_MAJ_SA_Statut) {
                   //updateUser = true;
                   // ----- Added by Thanina 27/08 for NZ2 ---
                   //added by Zak
                   updateUser = true;


                   salesA.Request_MAJ_Alloc_Status__c = Label.Request_MAJ_SA_Statut;
                   salesA.Approved__c = false;
                   salesA.Rejected__c = false;
                   //  ------ End Modifs Thanina    -------
                   salesA.Request_Response_Date__c = null;
                   //RE-INIT Backup fields ----
                   salesA.New_Director_Backup__c =null;
                   salesA.New_Manager_Backup__c = null;
                   salesA.New_KAM_Backup__c = null;
                   salesA.New_Additional_Backup__c = null;
                   //end -- re init

               }
           }
                //Case_2
               if (oldSalesAllocationsById!=null && SObjectUtils.isModified(salesA,oldSalesAllocationsById.get(salesA.id),fieldRequestStatus)) {

                   if (salesA.Request_MAJ_Alloc_Status__c == Label.Request_MAJ_SA_Approve) {


                       salesA.Approved__c = true;
                       salesA.Rejected__c = false;
                       salesA.Request_MAJ_Alloc_Status__c = 'None';
                       salesA.Request_Response_Date__c = Date.today();

                       //added by Zak
                       listUsersToNotif.add(salesA.Submitted_by__c);


                       salesA.New_Director_Backup__c = salesA.New_Director__c;
                       salesA.New_Director__c = null;
                       salesA.New_Manager_Backup__c = salesA.New_Manager__c;
                       salesA.New_Manager__c = null;
                       salesA.New_KAM_Backup__c = salesA.New_KAM__c;
                       salesA.New_KAM__c = null;
                       salesA.New_Additional_Backup__c = salesA.New_Additionnal__c;
                       salesA.New_Additionnal__c = null;

                   }
                   //Case_3
                   if (salesA.Request_MAJ_Alloc_Status__c == Label.Request_MAJ_SA_Reject) {
                       salesA.Approved__c = false;
                       salesA.Rejected__c = true;
                       salesA.Request_MAJ_Alloc_Status__c = 'None';
                       salesA.Request_Response_Date__c = Date.today();
                       //added by Zak
                       listUsersToNotif.add(salesA.Submitted_by__c);

                       salesA.New_KAM_Backup__c = salesA.New_KAM__c;
                       salesA.New_KAM__c = null;
                       salesA.New_Manager_Backup__c = salesA.New_Manager__c;
                       salesA.New_Manager__c = null;
                       salesA.New_Director_Backup__c = salesA.New_Director__c;
                       salesA.New_Director__c = null;
                       salesA.New_Additional_Backup__c = salesA.New_Additionnal__c;
                       salesA.New_Additionnal__c = null;

                   }
               }

       }

      if (updateUser) updateUsers();
      //Added By Zak
      if(listUsersToNotif.size() > 0) {
            createChatterNotif(listUsersToNotif, 'Your Sales Allocation Update Request have been Approved/Rejected. Please check that in '+Label.upListViewSall);
            uncheckUsers(listUsersToNotif);
        }



    }

    private void updateUsers(){
        Id currentUser = UserInfo.getUserId();
        User userToUpdate = [select Id, Update_Request_Sales_Alloc__c from User where Id = :currentUser];
        if(userToUpdate.Update_Request_Sales_Alloc__c == false){
                userToUpdate.Update_Request_Sales_Alloc__c = true;
        }
        update userToUpdate;

    }

    //added by Zak
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
    //added by Zak
    private void uncheckUsers(Set<String> listUsersToNotif)
    {
        List<User> userToUpdate = [select Id, Update_Request_Sales_Alloc__c from User where Id IN :listUsersToNotif];

        List<User> usersToUncheck = new List<User>();
        for(User u:userToUpdate)
        {
            if(u.Update_Request_Sales_Alloc__c == true)
            {
                u.Update_Request_Sales_Alloc__c = false;
                usersToUncheck.add(u);
            }
        }

        if(usersToUncheck.size() > 0) update usersToUncheck;

    }


    public  void updateSalesAllocVisibility(list<Sales_Allocations__c>  newSalesAllocations, Map<Id,Sales_Allocations__c> oldSalesAllocationsById, boolean isInsert){
        map<Id, Sales_Allocations__c> listSalesAlloToUpdate = new map<Id,Sales_Allocations__c>();
        set<Id> accountIds = new set<Id>();
        for (Sales_Allocations__c sa: newSalesAllocations){

            if ((isInsert == true || sa.Sales_Team__c != oldSalesAllocationsById.get(sa.Id).Sales_Team__c )
                    && sa.Valid_From__c <=  Date.Today() &&  sa.Valid_To__c >= Date.Today()){
                //listSalesAlloToUpdate.put(sa.Id, sa);
               // accountIds.add(sa.Account__c);
                sa.Update_Visibility__c = true;
            }
        }
/*
        Map<Id, Sales_Allocations__c> scopeSalesAlloc = new Map<Id, Sales_Allocations__c>([
                SELECT id, Sales_Allocations__c.Product_Sub_Segment__c, Sales_Allocations__c.Account__c,
                        Sales_Team__c,sales_team__r.Tech_Overlapped_SalesTeam__c, KAMF__c, Manager__c, Director__c,
                        Additional__c, Sales_Team__r.KAM__c,Sales_Team__r.KAM__r.isActive, Valid_To__c, Valid_From__c, Prod_Sub_Segment__c,
                        Sales_Team__r.Manager__c, Sales_Team__r.Manager__r.isActive, Sales_Team__r.Director__c,
                        Sales_Team__r.Director__r.isActive, Sales_Team__r.Additional__c, Sales_Team__r.Additional__r.isActive
                FROM Sales_Allocations__c
                WHERE Valid_From__c <= : Date.Today()
                AND Valid_To__c >= :Date.Today()
                AND Sales_Team__c != NULL
                AND Id IN: listSalesAlloToUpdate.keySet()
        ]);*/

       // SalesAllocationsService.updateAccountTeamMember(scopeSalesAlloc.values());
       // SalesAllocationsService.updateOpportunityTeamMember(scopeSalesAlloc.values());
    }


    public static void updateAccountTeamMember ( list<Sales_Allocations__c> salesAllocationToUpdate){
        set<Id> accountIds = new set<Id>();
        for (Sales_Allocations__c sa: salesAllocationToUpdate ){
            accountIds.add(sa.Account__c);
        }
        list<AccountTeamMember> usersId = new list<AccountTeamMember>();

        for (Sales_Allocations__c sa:salesAllocationToUpdate){

            if (sa.Sales_Team__c != null){
                if(sa.Sales_Team__r.KAM__c != null && sa.Sales_Team__r.KAM__r.isActive){

                    //Add KAM Account Member
                    AccountTeamMember KAM = new AccountTeamMember();
                    KAM.AccountId = sa.Account__c;
                    KAM.UserId = sa.Sales_Team__r.KAM__c;
                    KAM.TeamMemberRole = 'KAM';
                    KAM.AccountAccessLevel ='Edit';
                    KAM.ContactAccessLevel = 'Edit';
                    usersId.add(KAM);
                }
                if(sa.Sales_Team__r.Manager__c != null && sa.Sales_Team__r.Manager__r.isActive){

                    //Add KAM Account Member
                    AccountTeamMember Manager = new AccountTeamMember();
                    Manager.AccountId = sa.Account__c;
                    Manager.UserId = sa.Sales_Team__r.Manager__c;
                    Manager.TeamMemberRole = 'Manager';
                    Manager.AccountAccessLevel ='Edit';
                    Manager.ContactAccessLevel = 'Edit';
                    usersId.add(Manager);
                }

                if(sa.Sales_Team__r.Director__c != null && sa.Sales_Team__r.Director__r.isActive){

                    //Add KAM Account Member
                    AccountTeamMember Director = new AccountTeamMember();
                    Director.AccountId = sa.Account__c;
                    Director.UserId = sa.Sales_Team__r.Director__c;
                    Director.TeamMemberRole = 'Director';
                    Director.AccountAccessLevel ='Edit';
                    Director.ContactAccessLevel = 'Edit';
                    usersId.add(Director);
                }
                if(sa.Sales_Team__r.Additional__c != null && sa.Sales_Team__r.Additional__r.isActive){

                    //Add KAM Account Member
                    AccountTeamMember Additional = new AccountTeamMember();
                    Additional.AccountId = sa.Account__c;
                    Additional.UserId = sa.Sales_Team__r.Additional__c;
                    Additional.TeamMemberRole = 'Additional';
                    Additional.AccountAccessLevel ='Edit';
                    Additional.ContactAccessLevel = 'Edit';
                    usersId.add(Additional);
                }


            }


        }
        Map<Id, AccountTeamMember> accountTeamMemberTemps = new Map<Id, AccountTeamMember>([
                SELECT Id, AccountId, UserId, ContactAccessLevel, TeamMemberRole
                FROM AccountTeamMember
                WHERE AccountId IN :accountIds
                AND TeamMemberRole <> 'Plant'
                AND TeamMemberRole <> 'Product'
        ]);
        delete accountTeamMemberTemps.values();
        insert usersId;

    }

    public static void updateOpportunityTeamMember ( list<Sales_Allocations__c> salesAllocationToUpdate){
        map<String, Sales_Allocations__c> mapAccountAndSubSegment2SalesAlloc = new  map<String, Sales_Allocations__c>();
        set<Id> accountIds = new set<Id>();
        for (Sales_Allocations__c sa: salesAllocationToUpdate){
            mapAccountAndSubSegment2SalesAlloc.put(sa.Account__c+'_'+sa.Product_Sub_Segment__c, sa);
            accountIds.add(sa.Account__c);
        }

        list<Opportunity> opportunitiesList = [select Id from Opportunity where AccountId IN:accountIds];
        set<Id> opportunitiesId = new set<Id>();
        for (Opportunity opp:opportunitiesList){
            opportunitiesId.add(opp.Id);
        }
        if (opportunitiesList.size() > 0){
            list<QuoteLineItem> qliList = [select Id, Quote.OpportunityId,Product2Id,Tech_Account__c  from quoteLineItem
                                            where Quote.OpportunityId IN: opportunitiesId];
            map<Id, list<String>> mapOpportunity2AccountAndSubSegment = new map<Id, list<String>>();
            for (QuoteLineItem qli : qliList ){
                if (mapOpportunity2AccountAndSubSegment.get(qli.Quote.OpportunityId) == null){
                    list<String> init = new list<String>();
                    init.add(qli.Tech_Account__c+'_'+qli.Product2Id);
                    mapOpportunity2AccountAndSubSegment.put(qli.Quote.OpportunityId, init);
                }else{
                    mapOpportunity2AccountAndSubSegment.get(qli.Quote.OpportunityId).add(qli.Tech_Account__c+'_'+qli.Product2Id);
                }

            }
            List<OpportunityTeamMember> oppTeamMembertoCreate = new list<OpportunityTeamMember>();
            for (Id oppId:mapOpportunity2AccountAndSubSegment.keySet()){
                for (String key: mapOpportunity2AccountAndSubSegment.get(oppId)){
                    Sales_Allocations__c sa = mapAccountAndSubSegment2SalesAlloc.get(key);
                    if (sa!= null && sa.Sales_Team__c != null){
                        if(sa.Sales_Team__r.KAM__c != null && sa.Sales_Team__r.KAM__r.isActive){

                            OpportunityTeamMember KAM = new OpportunityTeamMember();
                            KAM.OpportunityId = oppId;
                            KAM.UserId = sa.Sales_Team__r.KAM__c;
                            KAM.TeamMemberRole = 'KAM';
                            KAM.OpportunityAccessLevel = 'Edit';
                            OppTeamMembertoCreate.add(KAM);
                        }
                        if(sa.Sales_Team__r.Manager__c != null && sa.Sales_Team__r.Manager__r.isActive){

                            OpportunityTeamMember Manager = new OpportunityTeamMember();
                            Manager.OpportunityId = oppId;
                            Manager.UserId = sa.Sales_Team__r.Manager__c;
                            Manager.TeamMemberRole = 'Manager';
                            Manager.OpportunityAccessLevel = 'Edit';
                            OppTeamMembertoCreate.add(Manager);
                        }

                        if(sa.Sales_Team__r.Director__c != null && sa.Sales_Team__r.Director__r.isActive){

                            OpportunityTeamMember Director = new OpportunityTeamMember();
                            Director.OpportunityId = oppId;
                            Director.UserId = sa.Sales_Team__r.Director__c;
                            Director.TeamMemberRole = 'Director';
                            Director.OpportunityAccessLevel = 'Edit';
                            OppTeamMembertoCreate.add(Director);
                        }
                        if(sa.Sales_Team__r.Additional__c != null && sa.Sales_Team__r.Additional__r.isActive){

                            OpportunityTeamMember Additional = new OpportunityTeamMember();
                            Additional.OpportunityId = oppId;
                            Additional.UserId = sa.Sales_Team__r.Additional__c;
                            Additional.TeamMemberRole = 'Additional';
                            Additional.OpportunityAccessLevel = 'Edit';
                            OppTeamMembertoCreate.add(Additional);
                        }


                    }

                }
            }

            Map<Id, OpportunityTeamMember> oppTeamMemberTemps = new Map<Id, OpportunityTeamMember>([
                    SELECT Id
                    FROM OpportunityTeamMember
                    WHERE OpportunityId IN :mapOpportunity2AccountAndSubSegment.keySet()
                    AND TeamMemberRole <> 'Plant'
                    AND TeamMemberRole <> 'Product'
                    AND TeamMemberRole <> 'Owner'
            ]);
            delete oppTeamMemberTemps.values();
            insert OppTeamMembertoCreate;
        }






    }

    /********************** UPDATE MEMBERS VISIBILITY NEW VERSION ************************/
    // in this method we prepare ourselves
    public void manageTeamMemberVisibility(list<Sales_Allocations__c>  newSalesAllocations, Map<Id,Sales_Allocations__c> oldSalesAllocationsById, boolean isInsert){

        // We need the accountIds of the changed Sales Allocation to get ALL the Allocation later
        // We need them to guess if an updated team member need to be created/removed/updated or nothing
        set<Id> accountIds = new set<Id>();

        // we need this as the SA could be updated normally (no ST changed),
        // but the visibility could change only if the ST change
        Map<Id, Sales_Allocations__c> allocationWithUpdatedSalesTeam = new Map<Id, Sales_Allocations__c>();

        // We will get the id of the new and old ST
        // we can have the same ST in both Set (because we can affect a new ST(not archived) the SA)
        // the request to get the needed values will be done later
        // of course this set don't make sense if insert operation
        set<Id> newSalesTeamIDs = new set<Id>();
        set<Id> oldSalesTeamIDs = new set<Id>();
        List<Sales_Allocations__c> newSalesAllocationsToUpdate = new List<Sales_Allocations__c>();
        //in case of insert we are only interested on SA with a ST affected (they affect visibility)
        System.debug(isInsert);
        System.debug(newSalesAllocations);
        for (Sales_Allocations__c sa: newSalesAllocations) {

            accountIds.add(sa.Account__c);
            // No archived
            if (sa.Valid_From__c <= Date.Today() && sa.Valid_To__c >= Date.Today()) {
                // Those Sales Allocation will be inserted
                // We don't have to check visibility if the allocation is not affected to ST (simple insert)
                // I separated the two condition for better visibility instead of using ||

                if (isInsert == true) {
                    if(sa.Sales_Team__c != null){
                        // The SA Sales team could be changed for many reasons :
                        // 1 - The SalesTeam was empty in the SA and it is newly added/affected
                        // 2 - The old SalesTeam was archived and the new one affected
                        newSalesTeamIDs.add(sa.Sales_Team__c);
                        newSalesAllocationsToUpdate.add(sa);
                    }//else we do nothing it is a simple insert without visibility to add/update

                } else if (sa.Sales_Team__c != oldSalesAllocationsById.get(sa.Id).Sales_Team__c) {
                    allocationWithUpdatedSalesTeam.put(sa.Id, sa);
                    newSalesAllocationsToUpdate.add(sa);
                    if(sa.Sales_Team__c != null){
                        newSalesTeamIDs.add(sa.Sales_Team__c);
                    }
                    if(oldSalesAllocationsById.get(sa.Id).Sales_Team__c != null){
                        oldSalesTeamIDs.add(oldSalesAllocationsById.get(sa.Id).Sales_Team__c);
                    }
                }
            }
        }
        // if we have SA with updated ST
        if(!newSalesAllocationsToUpdate.isEmpty()){
            VisibilityTeamMemberService.getNewTeamVisibility(allocationWithUpdatedSalesTeam, newSalesAllocationsToUpdate, oldSalesAllocationsById, accountIds, newSalesTeamIDs, oldSalesTeamIDs, isInsert);
        }


        // now we have we can begin our request and get the information needed



    }
}