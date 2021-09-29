/**
 * [ OpptiesToAccountMapping class : this class will make the link between an account and all its opportunity ]
 * @author Eric Wartelle
 * @version 0.9 - To be tested
 * @history 0.9 - To be tested
 *          0.5 - Stub
 */
public with sharing class OpptiesToAccountMapping {
	//Attributs of the class OpptiesToAccountMapping
	private Static String LOG_CLASS_NAME = 'OpptiesToAccountMapping';

	/**
	 * [ account : the account concerned by the opportunities]
	 */
	private Account account;

	/**
	 * [ accountTeamMembers : the account team members]
	 */
	private Set<AccountTeamMember> accountTeamMembers;

	/**
	 * [ oppties : the opportunities linked to the account ]
	 */
	private Set<OpportunityToQuote> oppties;

	/**
	 * [ opportunityTeamMembers :  the opportunity team members for all the concerned opportunities]
	 */
	private Set<OpportunityTeamMember> opportunityTeamMembers;


	//Constructors of the class OpptiesToAccountMapping
	/**
	 * [ Constructor of the class OpptiesToAccountMapping ]
	 * @param Account                     [ account                : the main account                        ]
	 * @param Set<AccountTeamMember>      [ accountTeamMembers     : the account team member                 ]
	 * @param Set<Opportunity>            [ oppties                : the opportunities linked to the account ]
	 * @param Set<OppportunityTeamMember> [ opportunityTeamMembers : the opportunity team members            ]
	 */
	public OpptiesToAccountMapping(Account account, Set<AccountTeamMember> accountTeamMembers, Set<OpportunityToQuote> oppties, 
										Set<OpportunityTeamMember> opportunityTeamMembers) {
		this.account = account;
		this.accountTeamMembers = accountTeamMembers;
		this.oppties = oppties;		
		this.opportunityTeamMembers = opportunityTeamMembers;
	}

	/**
	 * [ Constructor of the class OpptiesToAccountMapping ]
	 * @param Account [ account : the main account ]
	 */
	public OpptiesToAccountMapping(Account account){
		this.accountTeamMembers = new Set<AccountTeamMember>();
		this.opportunityTeamMembers = new Set<OpportunityTeamMember>();
		this.account = account;
	}

	//Methods of the class OpptiesToAccountMapping
	/**
	 * [ getAccountTeamMembersToDelete description : return the account team member that we want to delete ]
	 * @return Set<AccountTeamMember> : the account team member that we want to delete
	 */
	public Set<AccountTeamMember> getAccountTeamMembersToDelete(){
		return this.accountTeamMembers;
	}

	/**
	 * [ getOpportunityTeamMembersToDelete description : return the opportunity team member that we want to delete ]
	 * @return Set<OpportunityTeamMember> : the opportunity team members that we want to delete
	 */
	public Set<OpportunityTeamMember> getOpportunityTeamMembersToDelete(){
		return this.opportunityTeamMembers;
	}

	/**
	 * [ getNewAccountTeamMember description : return a new Account Team Member, need to be inserted into the database ]
	 * @param  User   [ user               : the user we want to add                                 ]
	 * @param  String [ teamMemberRole     : the role for the team member that we want to add        ]
	 * @param  String [ accountAccessLevel : the access level for account                            ]
	 * @param  String [ contactAccessLevel : the access level for the contacts linked to the account ]
	 * @return AccountTeamMember : the new account team member
	 */
	public AccountTeamMember getNewAccountTeamMember(Id user, String teamMemberRole, String accountAccessLevel, String contactAccessLevel){
		return new AccountTeamMember(AccountId = this.account.id, UserId = user, TeamMemberRole = teamMemberRole, 
			AccountAccessLevel = accountAccessLevel, ContactAccessLevel = contactAccessLevel);
	}

	/**
	 * [ getNewOpportunityTeamMembers description : return new Opportunity Team Members, need to be inserted into the database ]
	 * @param User   [ user                   : the user that we want to add as a team member                           ] 
	 * @param String [ teamMemberRole         : the role of the newly created team members                              ] 
	 * @param String [ opportunityAccessLevel : the access level for the oppties 			                            ]
	 * @param String [ productSubSegmment     : the product sub segment for which we want a new opportunity team member ]
	 * @return Set<OpportunityTeamMember> : the new opportunity team members
	 */
	public Set<OpportunityTeamMember> getNewOpportunityTeamMembers(Id user, String teamMemberRole, String opportunityAccessLevel, String productSubSegment){
		//We're going to generate a new Opportunity team member corresponding to the user for all the opportunity
		Set<OpportunityTeamMember> newOpportunityTeamMembers = new Set<OpportunityTeamMember>();
		if(this.oppties != null){
	  		for(OpportunityToQuote oppty : oppties){
	  			newOpportunityTeamMembers.addAll(
	  				oppty.getNewOpportunityTeamMembers(user, teamMemberRole, opportunityAccessLevel, productSubSegment)
	  			);
	  		}
  		}
		return newOpportunityTeamMembers; 
	}

	//Static method of the class OpptiesToAccountMapping
	/**
	 * [ getOpptiesToAccountMapping description : get a new OpptiesToAccountMapping corresponding to the argument                                ]
	 * @param  Account                         [ selectedAccount        : the account for which we're going to create an OpptiesToAccountMapping ]
	 * @param  Map<Id, Opportunity>            [ oppties                : all the oppties concerned by the accounts                              ]
	 * @param  Map<Id, AccountTeamMember>      [ accountTeamMembers     : all the account team members concerned by the accounts                 ]
	 * @param  Map<Id, OpportunitytTeamMember> [ opportunityTeamMembers : all the opportunity team members concerned by the opportunities        ]
	 * @param  Map<Id, Quote>				   [ quotes                 : all the quotes concerned by the opportunities							 ]
	 * @param  Map<Id, QuoteLineItem>		   [ qlis				    : all the quote line items concerned by the quote                        ]
	 * @return OpptiesToAccountMapping         [ The corresponding OpptiesToAccountMapping                                                       ]
	 */
	public static OpptiesToAccountMapping getOpptiesToAccountMapping(Account selectedAccount, Map<Id, Opportunity> opportunities,
			Set<AccountTeamMember> accountTeamMembers, Map<Id, Set<OpportunityTeamMember>> opportunityToOpportunityTeamMembersMapping, 
			Map<Id, Set<Quote>> opportunityToQuotesMapping, Map<Id, Set<QuoteLineItem>> quoteToQuoteLineItemsMapping){
		OpptiesToAccountMapping newOpptiesToAccountMapping = new OpptiesToAccountMapping(selectedAccount);

		//We need to select the correct account Team member
		newOpptiesToAccountMapping.accountTeamMembers = accountTeamMembers;

		//We need to check each oppties to see if we need to create an account for the corresponding 
		if(opportunities != null){
			newOpptiesToAccountMapping.oppties = new Set<OpportunityToQuote>();
			for(Opportunity oppty : opportunities.values()){	
				if(opportunityToOpportunityTeamMembersMapping.get(oppty.Id) != null){
					newOpptiesToAccountMapping.opportunityTeamMembers.AddAll(opportunityToOpportunityTeamMembersMapping.get(oppty.Id));
				}
				//We need to fill the oppties attributs for this OpptiesToAccountMapping
				newOpptiesToAccountMapping.oppties.Add(
					OpportunityToQuote.getOpportunityToQuote(
						oppty, 
						opportunityToQuotesMapping.get(oppty.Id), 
						quoteToQuoteLineItemsMapping
					)
				);
			}
		}

		return newOpptiesToAccountMapping;
	}
}