/**
 * [ SalesTeamAffectation description : this class will help structuring the Sales Team in front of the Account and the opportunity connected to the account ]
 * @author Eric Wartelle
 * @version 0.9 - To be tested
 * @history 0.9 - To be tested
 *          0.5 - Stub
 */
public with sharing class SalesTeamAffectation {
	//Attributs of the SalesTeamAffectation class
	private static String LOG_CLASS_NAME = 'SalesTeamAffectation';

	/**
	 * [ salesTeam description : the sales that we need to check ]
	 */
	public Sales_Team__c salesTeam;

	/**
	 * [ productSubSegment : the product sub segment for which we want to  ]
	 */
	public String productSubSegment;

 	/**
 	 * [ opptiesToAccountMapping : Account and the opportunities linked to that account ]
 	 */
 	public OpptiesToAccountMapping opptiesToAccount;

	//Constructors of the SalesTeamAffectation class
	/**
	 * [ Constructor of the class SalesTeamAffectation ]
	 * @param Sales_Team__c           [ salesTeam          : the concerned sales team                                          ]
	 * @param OpptiesToAccountMapping [ opptiesToAccount   : all the account concerned by the sales team and the opportunities ]
	 * @param String                  [ productSubSegement : the product sub segment 										   ]
	 */
	public SalesTeamAffectation(Sales_Team__c salesTeam, OpptiesToAccountMapping opptiesToAccount, String productSubSegment) {
		this.salesTeam = salesTeam;
		this.opptiesToAccount = opptiesToAccount;
		this.productSubSegment = productSubSegment;
	}

	/**
	 * [ Constructor of the class SalesTeamAffectation ]
	 * @param Sales_Team__c [ salesTeam          : the concerned sales team ]
	 * @param String        [ productSubSegement : the product sub segment 	]
	 */
	public SalesTeamAffectation(Sales_Team__c salesTeam, String productSubSegment) {
		this.salesTeam = salesTeam;
		this.productSubSegment = productSubSegment;
	}

	//Methods of the SalesTeamAffectation class
	/**
	 * [ getNewAccountTeamMembers description : we're going to generate all the account team member ]
	 * @param  Map<Id, User>          [ activeUsers : all  the active user of the org             ]
 	 * @return Set<AccountTeamMember> [ the newly create account team member, need to be inserted ]
	 */
	public Set<AccountTeamMember> getNewAccountTeamMembers(Map<Id, User> activeUsers){
		//We're going to create the new account team members for all the account concerne by the Sales Team
		Set<AccountTeamMember> newAccountTeamMembers = new Set<AccountTeamMember>();
		
		//If the sales team has a KAM
		if(this.salesTeam.KAM__c != null){
			if(activeUsers.containsKey(this.salesTeam.KAM__c))
				newAccountTeamMembers.add(opptiesToAccount.getNewAccountTeamMember(this.salesTeam.KAM__c, 'KAM', 'Edit', 'Edit'));
		}
		//If the sales team has a Manager
		if(this.salesTeam.Manager__c != null){
			if(activeUsers.containsKey(this.salesTeam.Manager__c))
				newAccountTeamMembers.add(opptiesToAccount.getNewAccountTeamMember(this.salesTeam.Manager__c, 'Manager', 'Edit', 'Edit' ));
		}
		//If the sales team has a director
		if(this.salesTeam.Director__c != null){
			if(activeUsers.containsKey(this.salesTeam.Director__c))
				newAccountTeamMembers.add(opptiesToAccount.getNewAccountTeamMember(this.salesTeam.Director__c, 'Director', 'Edit', 'Edit' ));
		}
		//If the sales team has an additionnal post define.
		if(this.salesTeam.Additional__c != null){
			if(activeUsers.containsKey(this.salesTeam.Additional__c))
				newAccountTeamMembers.add(opptiesToAccount.getNewAccountTeamMember(this.salesTeam.Additional__c, 'Additional', 'Edit', 'Edit' ));
		}	
		return newAccountTeamMembers;
	}

	/**
	 * [ getAccountTeamMembersToDelete description : send back all the account team member that we need to delete ]
	 * @return Set<AccountTeamMember> [ the old account team member that need to be deleted ]
	 */
	public Set<AccountTeamMember> getAccountTeamMembersToDelete(){
		return this.opptiesToAccount.getAccountTeamMembersToDelete();
	}

	/**
	 * [ getNewOpportunityTeamMembers description : will generate all the new opportunity team member ]
	 * @param  Map<Id, User> 			  [ activeUsers : all the active users of the org                 ]
	 * @return Set<OpportunityTeamMember> [ the newly created opportunity team member that we need to had ]
	 */
	public Set<OpportunityTeamMember> getNewOpportunityTeamMembers(Map<Id, User> activeUsers){
		//We're going to generate all the new opportunity team member
		Set<OpportunityTeamMember> newOpportunityTeamMembers = new Set<OpportunityTeamMember>();
		
		//If the sales team has a KAM
		if(this.salesTeam.KAM__c != null){
			if(activeUsers.containsKey(this.salesTeam.KAM__c))
				newOpportunityTeamMembers.addAll(opptiesToAccount.getNewOpportunityTeamMembers(this.salesTeam.KAM__c, 'KAM', 'Edit', this.productSubSegment));
		}
		//If the sales team has a Manager
		if(this.salesTeam.Manager__c != null){
			if(activeUsers.containsKey(this.salesTeam.Manager__c))
				newOpportunityTeamMembers.addAll(opptiesToAccount.getNewOpportunityTeamMembers(this.salesTeam.Manager__c, 'Manager', 'Edit', this.productSubSegment));
		}
		//If the sales team has a director
		if(this.salesTeam.Director__c != null){
			if(activeUsers.containsKey(this.salesTeam.Director__c))
				newOpportunityTeamMembers.addAll(opptiesToAccount.getNewOpportunityTeamMembers(this.salesTeam.Director__c, 'Director', 'Edit', this.productSubSegment));
		}
		//If the sales team has an additionnal post define.
		if(this.salesTeam.Additional__c != null){
			if(activeUsers.containsKey(this.salesTeam.Additional__c))
				newOpportunityTeamMembers.addAll(opptiesToAccount.getNewOpportunityTeamMembers(this.salesTeam.Additional__c, 'Additional', 'Edit', this.productSubSegment));
		}
		return newOpportunityTeamMembers;
	}

	/**
	 * [ getOpportunityTeamMembersToDelete description : send back all the opportunity team member that we need to delete ]
	 * @return Set<OpportunityTeamMember> [ the opportunity team member that need to be deleted ]
	 */
	public Set<OpportunityTeamMember> getOpportunityTeamMembersToDelete(){
		//We're going to get all the actual opportunity team membre
		Set<OpportunityTeamMember> oldOpportunityTeamMember = new Set<OpportunityTeamMember>();		
		oldOpportunityTeamMember.addAll(opptiesToAccount.getOpportunityTeamMembersToDelete());

		return oldOpportunityTeamMember;
	}

	/**
	 * [ getSalesTeamAffectations description : will return SalesTeamAffectation corresponding to the salesAllocations ]
	 * @param  Map<Id, Sales_Allocations__c> [ salesAllocations : send by the script               ]
	 * @param  Map<Id, User>                 [ activeUsers      : the active user of the org       ]
	 * @return Set<SalesTeamAffectation>     [ The calculated corresponding Sales Team Affectation ]
	 */
	public static Set<SalesTeamAffectation> getSalesTeamAffectations(Map<Id, Sales_Allocations__c> salesAllocations, Map<Id, User> activeUsers){
		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getSalesTeamAffectations Start');

		//We need all the Sales Team corresponding to the Sales Allocations.
		Set<Id> salesTeamIds = new Set<Id>();
		for(Sales_Allocations__c salesAllocation : salesAllocations.values()){
			salesTeamIds.add(salesAllocation.Sales_Team__c);
		}

		Map<Id, Sales_Team__c> salesTeams = new Map<Id, Sales_Team__c>([ SELECT Id, KAM__c, Manager__c, Additional__c, Director__c 
											   							   FROM Sales_Team__c 
											                              WHERE Id IN :salesTeamIds 
											                                AND Valid_From__c <= TODAY 
											                                AND Valid_To__c >= TODAY ]);

		//We need all the Account corresponding to the Sales Allocations
		Set<Id> accountIds = new Set<Id>();
		for(Sales_ALlocations__c salesAllocation : salesAllocations.values()){
			accountIds.add(salesAllocation.Account__c);
		}

		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id
															FROM Account
														   WHERE Id in: accountIds]);

		//We need all the Account Team member linked to this accounts and linked to active users
		Map<Id, AccountTeamMember> accountTeamMemberTemps = new Map<Id, AccountTeamMember>([
			SELECT Id, AccountId, UserId, ContactAccessLevel, TeamMemberRole 
			  FROM AccountTeamMember
			 WHERE AccountId IN :accountIds
			   AND TeamMemberRole <> 'Plant'
			   AND TeamMemberRole <> 'Product'
		]);

		Map<Id, AccountTeamMember> accountTeamMembers = new Map<Id, AccountTeamMember>();
		for(AccountTeamMember accountTeamMember : accountTeamMemberTemps.values()){
			if(activeUsers.containsKey(accountTeamMember.UserId)){
				accountTeamMembers.put(accountTeamMember.Id, accountTeamMember);
			}
		}

		//We need all the Account Team Member in function of the account
		Map<Id, Set<AccountTeamMember>> accountToAccountTeamMembersMapping = new Map<Id, Set<AccountTeamMember>>();
		for(AccountTeamMember accountTeamMember : accountTeamMembers.values()){
			if(! accountToAccountTeamMembersMapping.containsKey(accountTeamMember.AccountId)){
				accountToAccountTeamMembersMapping.put(accountTeamMember.AccountId, new Set<AccountTeamMember>());
			}
			accountToAccountTeamMembersMapping.get(accountTeamMember.AccountId).add(accountTeamMember);
		}

		//We need all the opportunity linked to this account
		Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Id, AccountId 
																	     FROM Opportunity 
																	    WHERE AccountId IN: accountIds]);

		//We need all the opportunity filtered by account
		Map<Id, Map<Id, Opportunity>> accountToOpptiesMapping = new Map<Id, Map<Id, Opportunity>>();
		for(Opportunity opportunity : opportunities.values()){
			if(! accountToOpptiesMapping.containsKey(opportunity.AccountId)){
				accountToOpptiesMapping.put(opportunity.AccountId,new Map<Id, Opportunity>());
			}
			accountToOpptiesMapping.get(opportunity.AccountId).put(opportunity.Id, opportunity);
		}

		//We need all the opportunity team members linked to this account and the opportunity team member need to be linked
		// to an active user
		Set<Id> opportunityIds = opportunities.keySet();
		Map<Id, OpportunityTeamMember> opportunityTeamMembersTemp = new Map<Id, OpportunityTeamMember>([
			SELECT Id, OpportunityID, OpportunityAccessLevel, UserId, TeamMemberRole
			  FROM OpportunityTeamMember
			 WHERE OpportunityID IN :opportunityIds
			   AND TeamMemberRole <> 'Plant'
			   AND TeamMemberRole <> 'Product'
		]);

		Map<Id, OpportunityTeamMember> opportunityTeamMembers = new Map<Id, OpportunityTeamMember>();
		for(OpportunityTeamMember opportunityTeamMember : opportunityTeamMembersTemp.values()){
			if(activeUsers.containsKey(opportunityTeamMember.UserId)){
				opportunityTeamMembers.put(opportunityTeamMember.Id, opportunityTeamMember);
			}
		}

		//We need all the opportunity team members in function of there opportunity
		Map<Id, Set<OpportunityTeamMember>> opportunityToOpportunityTeamMembersMapping = new Map<Id, Set<OpportunityTeamMember>>();
		for(OpportunityTeamMember opportunityTeamMember : opportunityTeamMembers.values()){
			if(! opportunityToOpportunityTeamMembersMapping.containsKey(opportunityTeamMember.OpportunityID)){
				opportunityToOpportunityTeamMembersMapping.put(opportunityTeamMember.OpportunityID, new Set<OpportunityTeamMember>());
			}
			opportunityToOpportunityTeamMembersMapping.get(opportunityTeamMember.OpportunityID).add(opportunityTeamMember);
		}

		//We need to get all the quote linked to this opportunities
		Map<Id, Quote> quotes = new Map<Id, Quote>([
			SELECT Id, IsSyncing, OpportunityID
			  FROM Quote
			 WHERE OpportunityID IN :opportunityIds
		]);

		//We need to het all the quote in function of there opportunities
		Map<Id, Set<Quote>> opportunityToQuotesMapping = new Map<Id, Set<Quote>>();
		for(Quote quote : quotes.values()){
			if(! opportunityToQuotesMapping.containsKey(quote.OpportunityID)){
				opportunityToQuotesMapping.put(quote.OpportunityID, new set<Quote>());
			}
			opportunityToQuotesMapping.get(quote.OpportunityID).add(quote);
		}

		//We need to get all the quote line item linked to this quotes
		Set<Id> quoteIds = quotes.keySet();
		Map<Id, QuoteLineItem> qlis = new Map<Id, QuoteLineItem>([
			SELECT Id, Product2Id, QuoteId, Product_Sub_segment__c
			  FROM QuoteLineItem
			 WHERE QuoteId IN :quoteIds
		]);

		//We need to get all the quote line item in funciton of there quotes
		Map<Id, Set<QuoteLineItem>> quoteToQuoteLineItemsMapping = new Map<Id, Set<QuoteLineItem>>();
		for(QuoteLineItem qli : qlis.values()){
			if(! quoteToQuoteLineItemsMapping.containsKey(qli.QuoteId)){
				quoteToQuoteLineItemsMapping.put(qli.QuoteId, new Set<QuoteLineItem>());
			}
			quoteToQuoteLineItemsMapping.get(qli.QuoteId).add(qli);
		}

		//We need to get all the active use
		Map<Id, User> activeUser = new Map<Id, User>([
			SELECT Id, IsActive
			  FROM User
			 WHERE IsActive = True
		]);

		//For each Sales Allocation we're going to generate a Sales Team Affectation
		Set<SalesTeamAffectation> salesTeamAffectations = new Set<SalesTeamAffectation>();
		for(Sales_Allocations__c salesAllocation : salesAllocations.values() ){

			SalesTeamAffectation newSalesTeamAffectation = null;

			Sales_Team__c selectedSalesTeam = salesTeams.get(salesAllocation.Sales_Team__c);
			if(selectedSalesTeam != null){
				newSalesTeamAffectation = new SalesTeamAffectation(
					selectedSalesTeam,
					salesAllocation.Product_Sub_Segment__c
				);
			}


			if(newSalesTeamAffectation  != null){
				Account account = accounts.get(salesAllocation.Account__c);
				newSalesTeamAffectation.opptiesToAccount = OpptiesToAccountMapping.getOpptiesToAccountMapping(
					account,
					accountToOpptiesMapping.get(account.Id),
					accountToAccountTeamMembersMapping.get(account.Id),
					opportunityToOpportunityTeamMembersMapping,
					opportunityToQuotesMapping,
					quoteToQuoteLineItemsMapping
				);
				salesTeamAffectations.add(newSalesTeamAffectation);
			}

		}

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getSalesTeamAffectations Stop');

		return salesTeamAffectations;
	}

}