/**
 * [ Class QuoteToQuoteLineItem : will link a quote to it's corresponding quote line item ]
 * @author Eric Wartelle
 * @version 0.9 - To be tested
 * @history 0.9 - To be tested
 *          0.5 - Stub
 */ 
public with sharing class QuoteToQuoteLineItem {
	//Attributs for the class QuoteToQuoteLineItem
	private static String LOG_CLASS_NAME = 'QuoteToQuoteLineItem';

	/** 
	 * [ quote : the corresponding quote ]
	 */
	public Quote quote;

	/**
	 * [ qlis : the quote line items linked to the corresponding quote ]
	 */
	public Set<QuoteLineItem> qlis;

	//Constructors for the class QuoteToQuoteLineItem
	/**
	 * [ Constructor for the class QuoteToQuoteLineItem ]
	 * @param Quote              [ quote : a quote             ]
	 * @param Set<QuoteLineItem> [ qlis  : the quote line item ]
	 */
	public QuoteToQuoteLineItem(Quote quote, Set<QuoteLineItem> qlis) {
		this.quote = quote;
		this.qlis = qlis;
	}

	/**
	 * [ Constructor for the class QuoteToQuoteLineItem ]
	 * @param Quote [ quote : the selected quote ]
	 */
	public QuoteToQuoteLineItem(Quote quote){
		this.quote = quote;
		this.qlis = new Set<QuoteLineItem>();
	}

	//Methods for the class QuoteToQuoteLineItem
	/**
	 * [ getProductSubSegment description : return all product sub segment ]
	 * @return List<String> [ the list of product sub segment ]
	 */
	public List<String> getProductSubSegment(){
		List<String> productSubSegments = new List<String>();
		for(QuoteLineItem qli : qlis){
			productSubSegments.add(qli.Product_Sub_segment__c);
		}
		return productSubSegments;
	}

	/**
	 * [ containsProductSubSegment description : test if the product sub segment is concern by the qli ]
	 * @param  String  [ productSubSegment : the product sub segment that we want to test ]
	 * @return boolean [ True / False                                                     ]
	 */
	public boolean containsProductSubSegment(String productSubSegment){
		// We're going to check if the product sub segment is referenced by each qlis 
		Boolean flag = false;	
		if(qlis != null){
			for(QuoteLineItem qli : qlis){
				System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - qli.Product_Sub_segment__c : ' + qli.Product2Id);
				System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - productSubSegment : ' + productSubSegment);
				if(qli.Product2Id == productSubSegment){
					flag = true;
				}
			}
		}
		return flag;
	}
	
	/**
	 * [ isSync description : test if ]
	 * @return boolean [ true/false ]
	 */
	public boolean IsSyncing(){
		return this.quote.IsSyncing;
	}

	// Static method
	/**
	 * [ getQuoteToQuoteLineItem description : gonna generate a new QuoteToQuoteLineItem base on the given argument ]
	 * @param Quote 				 [ quote : the starting quote  ]
	 * @param Map<Id, QuoteLineItem> [ qlis : the quote line items ]
	 * @return QuoteToQuoteLineItem : the newly Created quote to quoteLineItem
	 */
	public static QuoteToQuoteLineItem getQuoteToQuoteLineItem(Quote quote, Set<QuoteLineItem> qlis){
		QuoteToQuoteLineItem newQuoteToQuoteLineItem = new QuoteToQuoteLineItem(quote, qlis);

		return newQuoteToQuoteLineItem;
	}
}