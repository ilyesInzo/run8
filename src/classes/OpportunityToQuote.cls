/**
 * [ OpportunityToQuote description : will link the opportunity to the corresponding quote ]
 * @author Eric Wartelle
 * @version 0.9 - To be tested
 * @history 0.9 - To be tested
 *          0.5 - Stub
 */
public with sharing class OpportunityToQuote {
	//Attributs of the class OpportunityToQuote
	private static string LOG_CLASS_NAME = 'OpportunityToQuote';

	/**
	 * opportunity : the concerned opportunity 
	 */
	public Opportunity opportunity;

	/**
	 * quoteToQuoteLineItems : the quote linked to the opportunity and there 
	 * corresponding quote line item
	 */
	public Set<QuoteToQuoteLineItem> quoteToQuoteLineItems;

	//Constructors of the class OpportunityToQuote
	/**
	 * [ Constructor of the class OpportunityToQuote ]
	 * @param Opportunity 			    [ opportunity           : the base opportunity                   ]
	 * @param Set<QuoteToQuoteLineItem> [ quoteToQuoteLineItems : a set of QuoteToQuoteLineItem instance ] 
	 */
	public OpportunityToQuote(Opportunity opportunity, Set<QuoteToQuoteLineItem> quoteToQuoteLineItems) {
		this.opportunity = opportunity;
		this.quoteToQuoteLineItems = quoteToQuoteLineItems;
	}

	/**
	 * [ Constructor of the class OpportunityToQuote ]
	 * @param Opportunity [ opportunity : the base opportunity ]
	 */
	public OpportunityToQuote(Opportunity opportunity){
		this.opportunity = opportunity;
		this.quoteToQuoteLineItems = new Set<quoteToQuoteLineItem>();
	}

	//Methods of the class OpportunityToQuote
	/**
	 * [ getSyncQuote description : will return the corresponding quote to synchronise ]
	 * @return QuoteToQuoteLineItem the synced quote with the corresponding quote line item or null if no quote has been sync
	 */
	public QuoteToQuoteLineItem getSyncQuote(){
		for(QuoteToQuoteLineItem quoteToQuoteLineItem : quoteToQuoteLineItems){
			if(quoteToQuoteLineItem.isSyncing()){
				return quoteToQuoteLineItem;
			}
		}

		return null;
	}

	/**
	 * [ Method getNewOpportunityTeamMembers : return the corresponding opportunity team members ]
	 * @param Id     					  [ User                   : the user for which you want to create an opportunity team member               ]
	 * @param String 					  [ teamMemberRole         : the role of the newly created Team Member 						                ]
	 * @param String 					  [ opportunityAccessLevel : the access level for the newly created Team Member 				 			]
	 * @param String 					  [ productSubSegment 	   : the product sub segment for which the use should be an opportunity team member ]
   	 * @return Set<OpportunityTeamMember> [ all the opportunity team members created for the afformentioned arguments                               ]
	 */
	public Set<OpportunityTeamMember> getNewOpportunityTeamMembers(Id user, String teamMemberRole, String opportunityAccessLevel, String productSubSegment){
		Set<OpportunityTeamMember> newOpportunityTeamMembers = new Set<OpportunityTeamMember>();
		for(QuoteToQuoteLineItem quoteToQuoteLineItem : quoteToQuoteLineItems){
			if(quoteToQuoteLineItem.containsProductSubSegment(productSubSegment) ){
				OpportunityTeamMember newOpportunityTeamMember = new OpportunityTeamMember(
					OpportunityId = opportunity.Id,
  					UserId = user,
  					TeamMemberRole = teamMemberRole,
  					OpportunityAccessLevel = opportunityAccessLevel
				);

				newOpportunityTeamMembers.add(newOpportunityTeamMember);
			}
		}
		return newOpportunityTeamMembers;
	}

	//Static methods for the class OpportunityToQuote
	/**
	 * [ Method getOpportunityToQuotes: return a set of OpportunityToQuote from arguments ]
	 * @param  Opportunity            [ selectedOpportunity          : the concerned opportunity                                          ]
	 * @param  Map<id, Quote> 		  [ quotes                       : the quotes sent by the script                                      ]
	 * @param  Map<Id, QuoteLineItem> [ quoteToQuoteLineItemsMapping : a mapping between the quotes and the corresponding Quote Line Item ]
	 * @return OpportunityToQuote     [ a new Opportunity To Quote Mapper                                                                 ]
	 */
	public static OpportunityToQuote getOpportunityToQuote(Opportunity selectedOpportunity, Set<Quote> quotes, Map<Id, Set<QuoteLineItem>> quoteToQuoteLineItemsMapping){
		OpportunityToQuote newOpportunityToQuote = new OpportunityToQuote(selectedOpportunity);

		//We need to generate each quote to quote line item
		if(quotes != null){
			for(Quote quote : quotes){
				newOpportunityToQuote.quoteToQuoteLineItems.add(QuoteToQuoteLineItem.getQuoteToQuoteLineItem(quote, quoteToQuoteLineItemsMapping.get(quote.Id)));
			}
		}

		return newOpportunityToQuote;
	}
}