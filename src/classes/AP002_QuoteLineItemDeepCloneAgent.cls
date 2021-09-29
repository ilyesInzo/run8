/**
 * [Class AP002_QuoteLineItemDeepCloneAgent : will ensure the deep clone of one quote line item ]
 * @author EWA
 * @version 0.9.9 - Insert call will be done at another level
 * @history 0.9.9 - Insert call will be done at another level
 *          0.9   - Version to be tested
 *          0.5   - Stub
 */
public class AP002_QuoteLineItemDeepCloneAgent extends APXXX_VirtualDeepCloneAgent {
   	//Attributs of the class AP002_QuoteLineItemDeepCloneAgent
	private static String LOG_CLASS_NAME = 'AP002_QuoteLineItemDeepCloneAgent';

	/**
	 * [ pmMOQPriceDeepCloneAgent description : a PM_MOQ_price__c deep clone agent ]
	 */
	public List<AP002_PMMOQPriceDeepCloneAgent> pmMOQPriceDeepCloneAgents;
	
	/**
	 * [ pmPriceDetailDeepCloneAgent description : a PM_Price_Detail__c deep clone agent ]
	 */
	public List<AP002_PMPriceDetailDeepCloneAgent> pmPriceDetailDeepCloneAgents;
	
	/**
	 * [ pmPriceRecoDeepCloneAgent description : a PM_Price_Recommendation__c deep clone agent ]
	 */
	public List<AP002_PMPriceRecoDeepCloneAgent> pmPriceRecoDeepCloneAgents;
	
	/**
	 * [ pmReviewNetPricePerMOQDeepClAgents description : a PM_Review_NetPrice_per_MOQ__c deep clone agent ]
	 */
	//public List<AP002_PMReviewNetPricePerMOQDeepClAgent> pmReviewNetPricePerMOQDeepClAgents;
	
	/**
	 * [ pmSelectedDispCfgDeepCloneAgent description : a PM_Selected_Dipsensing_config__c deep clone agent ]
	 */
	public List<AP002_PMSelectedDispCfgDeepCloneAgent> pmSelectedDispCfgDeepCloneAgents;
	
	/**
	 * [ pmSelectedTubesCfdDeepCloneAgent description : a PM_Selected_Tubes_Config__c deep clone agent ]
	 */
	public List<AP002_PMSelectedTubesCfgDeepCloneAgent> pmSelectedTubesCfdDeepCloneAgents;
	
	/**
	 * [ pmSlctdServTubesCfgDeepCloneAgent description : a PM_Selected_Service_Tubes_Config__c deep clone agent ]
	 */
	public List<AP002_PMSlctdServTubesCfgDeepCloneAgent> pmSlctdServTubesCfgDeepCloneAgents;
	
	/**
	 * [parentQuoteDeepCloneAgent description : a deep clone agent for the parent quote]
	 */
	public AP002_QuoteDeepCloneAgent parentQuoteDeepCloneAgent;	

	/**
	 * [sameOpportunity description : a flag to tell if we use the same opportunity or not ]
	 */
	public boolean sameOpportunity;

	/**
	 * [sameAccount description : a flag to tell if we use the same account or not ]
	 */
	public boolean sameAccount;


    
    //Constructors of the class AP002_QuoteLineItemDeepCloneAgent
    /**
     * [Constructors for the class AP002_QuoteLineItemDeepCloneAgent]
     * @param qli [QuoteLineItem : the quote line item that we want to clone]
     */
    public AP002_QuoteLineItemDeepCloneAgent(QuoteLineItem qli){
    	super(qli);  
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	this.pmMOQPriceDeepCloneAgents = new List<AP002_PMMOQPriceDeepCloneAgent>();
    	//this.pmReviewNetPricePerMOQDeepClAgents = new List<AP002_PMReviewNetPricePerMOQDeepClAgent>();
    	this.pmPriceRecoDeepCloneAgents = new List<AP002_PMPriceRecoDeepCloneAgent>();
    	this.pmSelectedTubesCfdDeepCloneAgents = new List<AP002_PMSelectedTubesCfgDeepCloneAgent>();
    	this.pmPriceDetailDeepCloneAgents = new List<AP002_PMPriceDetailDeepCloneAgent>();
    	this.pmSelectedDispCfgDeepCloneAgents = new List<AP002_PMSelectedDispCfgDeepCloneAgent>();
    	this.pmSlctdServTubesCfgDeepCloneAgents = new List<AP002_PMSlctdServTubesCfgDeepCloneAgent>();
    	this.initializeDeepCloneAgents();
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');  	
    	
    }
    
    /**
     * [Constructors for the class AP002_QuoteLineItemDeepCloneAgent]
     * @param qli                       [ QuoteLineItem             : the quote line item that we want to clone ]
     * @param parentQuoteDeepCloneAgent [ AP002_QuoteDeepCloneAgent : the deep clone agent for the parent       ]
     */
    public AP002_QuoteLineItemDeepCloneAgent(QuoteLineItem qli, AP002_QuoteDeepCloneAgent parentQuoteDeepCloneAgent){
    	super(qli);  
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	this.parentQuoteDeepCloneAgent = parentQuoteDeepCloneAgent;
    	//this.pmReviewNetPricePerMOQDeepClAgents = new List<AP002_PMReviewNetPricePerMOQDeepClAgent>();
    	this.pmPriceRecoDeepCloneAgents = new List<AP002_PMPriceRecoDeepCloneAgent>();
    	this.pmSelectedTubesCfdDeepCloneAgents = new List<AP002_PMSelectedTubesCfgDeepCloneAgent>();
    	this.pmMOQPriceDeepCloneAgents = new List<AP002_PMMOQPriceDeepCloneAgent>();
    	this.pmPriceDetailDeepCloneAgents = new List<AP002_PMPriceDetailDeepCloneAgent>();
    	this.pmSelectedDispCfgDeepCloneAgents = new List<AP002_PMSelectedDispCfgDeepCloneAgent>();
    	this.pmSlctdServTubesCfgDeepCloneAgents = new List<AP002_PMSlctdServTubesCfgDeepCloneAgent>();
    	this.initializeDeepCloneAgents();
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');  	
    	
    }

    /**
     * [Constructors for the class AP002_QuoteLineItemDeepCloneAgent]
     * @param QuoteLineItem             [ qli                       : the quote line item that we want to clone     ]
     * @param AP002_QuoteDeepCloneAgent [ parentQuoteDeepCloneAgent : the deep clone agent for the parent           ]
     * @param boolean                   [ sameOpportunity           : a flag to tell if we use the same opportunity ]
     */
    public AP002_QuoteLineItemDeepCloneAgent(QuoteLineItem qli, AP002_QuoteDeepCloneAgent parentQuoteDeepCloneAgent, boolean sameOpportunity){
    	super(qli);  
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	this.parentQuoteDeepCloneAgent = parentQuoteDeepCloneAgent;
    	//this.pmReviewNetPricePerMOQDeepClAgents = new List<AP002_PMReviewNetPricePerMOQDeepClAgent>();
    	this.pmPriceRecoDeepCloneAgents = new List<AP002_PMPriceRecoDeepCloneAgent>();
    	this.pmSelectedTubesCfdDeepCloneAgents = new List<AP002_PMSelectedTubesCfgDeepCloneAgent>();
    	this.pmMOQPriceDeepCloneAgents = new List<AP002_PMMOQPriceDeepCloneAgent>();
    	this.pmPriceDetailDeepCloneAgents = new List<AP002_PMPriceDetailDeepCloneAgent>();
    	this.pmSelectedDispCfgDeepCloneAgents = new List<AP002_PMSelectedDispCfgDeepCloneAgent>();
    	this.pmSlctdServTubesCfgDeepCloneAgents = new List<AP002_PMSlctdServTubesCfgDeepCloneAgent>();
    	this.sameOpportunity = sameOpportunity;
    	this.initializeDeepCloneAgents();
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');  	
    	
    }

    /**
     * [Constructors for the class AP002_QuoteLineItemDeepCloneAgent]
     * @param QuoteLineItem             [ qli                       : the quote line item that we want to clone     ]
     * @param AP002_QuoteDeepCloneAgent [ parentQuoteDeepCloneAgent : the deep clone agent for the parent           ]
     * @param boolean                   [ sameOpportunity           : a flag to tell if we use the same opportunity ]
     * @param boolean 					[ sameAccount				: a flag to tell if we use the same account     ]
     */
    public AP002_QuoteLineItemDeepCloneAgent(QuoteLineItem qli, AP002_QuoteDeepCloneAgent parentQuoteDeepCloneAgent, 
    												boolean sameOpportunity, boolean sameAccount){
    	super(qli);  
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	this.parentQuoteDeepCloneAgent = parentQuoteDeepCloneAgent;
    	//this.pmReviewNetPricePerMOQDeepClAgents = new List<AP002_PMReviewNetPricePerMOQDeepClAgent>();
    	this.pmPriceRecoDeepCloneAgents = new List<AP002_PMPriceRecoDeepCloneAgent>();
    	this.pmSelectedTubesCfdDeepCloneAgents = new List<AP002_PMSelectedTubesCfgDeepCloneAgent>();
    	this.pmMOQPriceDeepCloneAgents = new List<AP002_PMMOQPriceDeepCloneAgent>();
    	this.pmPriceDetailDeepCloneAgents = new List<AP002_PMPriceDetailDeepCloneAgent>();
    	this.pmSelectedDispCfgDeepCloneAgents = new List<AP002_PMSelectedDispCfgDeepCloneAgent>();
    	this.pmSlctdServTubesCfgDeepCloneAgents = new List<AP002_PMSlctdServTubesCfgDeepCloneAgent>();
    	this.sameOpportunity = sameOpportunity;
    	this.sameAccount = sameAccount;
    	this.initializeDeepCloneAgents();
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');  	
    	
    }
  
    //Methods of the class AP002_QuoteLineItemDeepCloneAgent
    /**
     * [initializeDeepCloneAgents description : we're going to initialize each SObject linked to the Quote Line Item]
     */
 	private void initializeDeepCloneAgents(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializeDeepCloneAgents Start');
 		
		//If it exist, we need to get the PM Selected Dispensing Config linked to the Quote Line Item
 		this.initializePmSelectedDipsensingconfig();
 		
 		//If it exist, we need to get the PM Selected Services Tubes Config linked to the Quote Line Item
 		this.initializePMSelectedServiceTubesConfig();
 		
 		//If it exist, we need to get the PM Selected Tubes Config linked to the Quote Line Item
 		this.initializePmSelectedTubesConfig();

 		//If it exist, we need to get the PM Moq Price linked to the Quote Line Item
 		this.initializePMMoqPrice();
 		
 		//If it exist, we need to get the PM Price Detail linked to the Quote Line Item
 		this.initializePMPriceDetail();
 		
 		//If it exist, we need to get the PM Price Recommendation linked to the Quote Line Item
 		this.initializePMPriceRecommendation();
 		
 		//If it exist, we need to get the PM Review Net Price linked to the Quote Line Item
 		//Commented 26/11 ALE
 		//this.initializePMReviewNetPriceperMOQ();
 		
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializeDeepCloneAgents Stop');
 	}
 	
 	/**
 	 * [ initializePMMoqPrice description : get the PM MOQ Price linked to the quote line item and generate the 
 	 *  concerned deep clone agent.] 
 	 */
 	private void initializePMMoqPrice(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePMMoqPrice Start');

		//We're going to add all the PM_MOQ_Price linked to the Quote Line Item to the list deepCloneAgents 	
		if(this.parentQuoteDeepCloneAgent.pmMOQPrices != null){					   
			if(this.parentQuoteDeepCloneAgent.pmMOQPrices.size() != 0) {
				for(PM_MOQ_price__c pmMOQPrice : this.parentQuoteDeepCloneAgent.pmMOQPrices){
					if(pmMOQPrice.Quote_item__c == this.objectToClone.Id){
						AP002_PMMOQPriceDeepCloneAgent temp = new AP002_PMMOQPriceDeepCloneAgent(pmMOQPrice, this);
						for(AP002_PMSelectedTubesCfgDeepCloneAgent pmSelectedTubesCfdDeepCloneAgent : this.pmSelectedTubesCfdDeepCloneAgents){
							if(pmMOQPrice.PM_Selected_Tubes_Config__c == pmSelectedTubesCfdDeepCloneAgent.objectToClone.Id){
								temp.pmSelectedTubesCfdDeepCloneAgent = pmSelectedTubesCfdDeepCloneAgent;
							}
						}
						for(AP002_PMSelectedDispCfgDeepCloneAgent pmSelectedDispCfgDeepCloneAgent : this.pmSelectedDispCfgDeepCloneAgents){
							if(pmMOQPrice.PM_Selected_Dipsensing_Config__c == pmSelectedDispCfgDeepCloneAgent.objectToClone.Id){
								temp.pmSelectedDispCfdDeepCloneAgent = pmSelectedDispCfgDeepCloneAgent;
							}
						}
						this.pmMOQPriceDeepCloneAgents.Add(temp);	
					}
				}	
			}	
		}				 
 		
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePMMoqPrice Stop');
 	}
 	
 	/**
 	 * [ initializePMPriceDetail description : get the PM Price Detail linked to the quote line item and generate
 	 *   the concerned deep clone agent. ] 
 	 */
 	private void initializePMPriceDetail(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePMPriceDetail Start');
 		 
 		//We're going to add all PM_Price_Detail__c linked to the Quote line Item to the list deepCloneAgents
 		if(this.parentQuoteDeepCloneAgent.pmPriceDetails != null){
	 		if(this.parentQuoteDeepCloneAgent.pmPriceDetails.size() != 0){
	 			for(PM_Price_Detail__c pmPriceDetail : this.parentQuoteDeepCloneAgent.pmPriceDetails){
	 				if(pmPriceDetail.Quote_item__c == this.objectToClone.Id){
			 			AP002_PMPriceDetailDeepCloneAgent temp = new AP002_PMPriceDetailDeepCloneAgent(pmPriceDetail, this);
			 			for(AP002_PMSelectedTubesCfgDeepCloneAgent pmSelectedTubesCfdDeepCloneAgent : pmSelectedTubesCfdDeepCloneAgents){
							if(pmPriceDetail.PM_Selected_Tubes_Config__c == pmSelectedTubesCfdDeepCloneAgent.objectToClone.Id){
								temp.pmSelectedTubesCfdDeepCloneAgent = pmSelectedTubesCfdDeepCloneAgent;
							}
						}	
						for(AP002_PMSelectedDispCfgDeepCloneAgent pmSelectedDispCfgDeepCloneAgent : this.pmSelectedDispCfgDeepCloneAgents){
							if(pmPriceDetail.PM_Selected_Dipsensing_Config__c == pmSelectedDispCfgDeepCloneAgent.objectToClone.Id){
								temp.pmSelectedDispCfdDeepCloneAgent = pmSelectedDispCfgDeepCloneAgent;
							}
						}
			 			this.pmPriceDetailDeepCloneAgents.Add(temp);	
			 		}		
	 			}			
	 		}
 		}
 		
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePMPriceDetail Stop');
 	}
 	
 	/**
 	 * [ initializePMPriceRecommendation : get the PM Price Recommendation linked to the quote line item and generate
 	 *   the concerned deep clone agent. ]
 	 */
 	private void initializePMPriceRecommendation(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePMPriceRecommendation Start');
 		
 		//We're going to add all PM_Price_Recommendation__c linked to the Quote Line Item to the list deepCloneAgents
 		if(this.parentQuoteDeepCloneAgent.pmPriceRecommendations != null){
	 		if(this.parentQuoteDeepCloneAgent.pmPriceRecommendations.size() != 0){
	 			for(PM_Price_Recommendation__c pmPriceRecommendation : this.parentQuoteDeepCloneAgent.pmPriceRecommendations){
	 				if(pmPriceRecommendation.Quote_Line_Item__c == this.objectToClone.Id){
		 				AP002_PMPriceRecoDeepCloneAgent temp = new AP002_PMPriceRecoDeepCloneAgent(pmPriceRecommendation, this);
		 				for(AP002_PMSelectedTubesCfgDeepCloneAgent pmSelectedTubesCfdDeepCloneAgent : pmSelectedTubesCfdDeepCloneAgents){
							if(pmPriceRecommendation.PM_Selected_Tubes_Config__c == pmSelectedTubesCfdDeepCloneAgent.objectToClone.Id){
								temp.pmSelectedTubesCfdDeepCloneAgent = pmSelectedTubesCfdDeepCloneAgent;
							}
						}
						for(AP002_PMSelectedDispCfgDeepCloneAgent pmSelectedDispCfgDeepCloneAgent : this.pmSelectedDispCfgDeepCloneAgents){
							if(pmPriceRecommendation.PM_Selected_Dipsensing_Config__c == pmSelectedDispCfgDeepCloneAgent.objectToClone.Id){
								temp.pmSelectedDispCfdDeepCloneAgent = pmSelectedDispCfgDeepCloneAgent;
							}
						}
		 				this.pmPriceRecoDeepCloneAgents.add(temp);
		 			}
	 			}
	 		}
 		}
 		
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePMPriceRecommendation Stop');
 	}
 	
 	/**
 	 * [ initializePMReviewNetPriceperMOQ description : get the PM Review NetPrice per MOQ linked to the quote line item
 	 *   and generate the concerned deep clone agent. ]
 	 */

 	//Commented 26/11 ALE
 	/* 
 	private void initializePMReviewNetPriceperMOQ(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePMReviewNetPriceperMOQ Start');
 		
 		//We're going to add all PM_Review_NetPrice_per_MOQ__c linked to the Quote Line Item to the list deepCloneAgents
 		if(this.parentQuoteDeepCloneAgent.pmReviewNetPriceperMOQs != null){
	 		if(this.parentQuoteDeepCloneAgent.pmReviewNetPriceperMOQs.size() != 0){
	 			for(PM_Review_NetPrice_per_MOQ__c pmReviewNetPriceperMOQ : this.parentQuoteDeepCloneAgent.pmReviewNetPriceperMOQs){
	 				if(pmReviewNetPriceperMOQ.Quote_Line_Item__c == this.objectToClone.Id){
		 				AP002_PMReviewNetPricePerMOQDeepClAgent temp = new AP002_PMReviewNetPricePerMOQDeepClAgent(pmReviewNetPriceperMOQ, this);
		 				for(AP002_PMPriceRecoDeepCloneAgent pmPriceRecoDeepCloneAgentTemp : this.pmPriceRecoDeepCloneAgents){
		 					if(pmPriceRecoDeepCloneAgentTemp.objectToClone.Id == pmReviewNetPriceperMOQ.PriceReco__c){
		 						temp.pmPriceRecoDeepCloneAgent = pmPriceRecoDeepCloneAgentTemp;
		 					}
		 				}
		 				for(AP002_PMPriceDetailDeepCloneAgent pmPriceDetailDeepCloneAgentTemp : this.pmPriceDetailDeepCloneAgents){
		 					if(pmPriceDetailDeepCloneAgentTemp.objectToClone.Id == pmReviewNetPriceperMOQ.PM_Price_Detail__c){
		 						temp.pmPriceDetailDeepCloneAgent = pmPriceDetailDeepCloneAgentTemp;
		 					}
		 				}
		 				this.pmReviewNetPricePerMOQDeepClAgents.Add(temp);
		 			}
	 			}
	 		}
 		}
 		
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePMReviewNetPriceperMOQ Stop');
 	}
 	*/

 	/**
 	 * [ initializePmSelectedDipsensingconfig description : get the PM Selected Dispensing Config linked to the quote line item
 	 *   and generate the concerned deep clone agent. ]
 	 */
 	private void initializePmSelectedDipsensingconfig(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePmSelectedDipsensingconfig Start');
 		
 		
 		//We're going to add all PM_Selected_Dispensing_config__c linked to the Quote Line Item to the list deepCloneAgents
 		if(this.parentQuoteDeepCloneAgent.pmSelectedDispensingConfigs != null){
	 		if(this.parentQuoteDeepCloneAgent.pmSelectedDispensingConfigs.size() != 0){
	 			for(PM_Selected_Dipsensing_config__c pmSelectedDispensingConfig : this.parentQuoteDeepCloneAgent.pmSelectedDispensingConfigs){
	 				if(pmSelectedDispensingConfig.Quote_item__c == this.objectToClone.Id){
	 					AP002_PMSelectedDispCfgDeepCloneAgent temp = new AP002_PMSelectedDispCfgDeepCloneAgent(pmSelectedDispensingConfig, this);
	 					this.pmSelectedDispCfgDeepCloneAgents.add(temp);
	 				}
	 			}
	 		}
 		}
 		
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePmSelectedDipsensingconfig Stop');
 	}
 	
 	/**
 	 * [ initializePmSelectedTubesConfig description : get the PM Selected Tubes Config linked to the quote line item and 
 	 *  generate the concerned deep clone agent. ]
 	 */
 	private void initializePmSelectedTubesConfig(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePmSelectedTubesConfig Start');
 		
 		//We're going to add all PM_Selected_Tubes_Config__c linked to the Quote Line Item to the list deepCloneAgents
 		if(this.parentQuoteDeepCloneAgent.pmSelectedTubesConfigs != null){
			if(this.parentQuoteDeepCloneAgent.pmSelectedTubesConfigs.size() != 0){
				for(PM_Selected_Tubes_Config__c pmSelectedTubesConfig : this.parentQuoteDeepCloneAgent.pmSelectedTubesConfigs){
					if(pmSelectedTubesConfig.Quote_item__c == this.objectToClone.Id){
						this.pmSelectedTubesCfdDeepCloneAgents.Add(new AP002_PMSelectedTubesCfgDeepCloneAgent(pmSelectedTubesConfig, this));
					}
				}
			}
 		}
 		
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePmSelectedTubesConfig Stop');
 	} 
 	
 	/**
 	 * [ initializePMSelectedServiceTubesConfig description : get the PM Selected Service Tubes Config linked to the quote line item 
 	 *   and generate the concerned deep clone agent. ]
 	 */
 	private void initializePMSelectedServiceTubesConfig(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePMSelectedServiceTubesConfig Start');
 		
 		//We're going to add all PM_Selected_Service_Tubes_Config__c linked to the Quote Line Item to the list deepCloneAgents
 		if(this.parentQuoteDeepCloneAgent.pmSelectedServiceTubesConfigs != null){
	 		if(this.parentQuoteDeepCloneAgent.pmSelectedServiceTubesConfigs.size() != 0){
	 			for(PM_Selected_Service_Tubes_Config__c pmSelectedServiceTubesConfig : this.parentQuoteDeepCloneAgent.pmSelectedServiceTubesConfigs){
	 				if(pmSelectedServiceTubesConfig.Quote_item__c == this.objectToClone.Id){
		 				AP002_PMSlctdServTubesCfgDeepCloneAgent temp = new AP002_PMSlctdServTubesCfgDeepCloneAgent(pmSelectedServiceTubesConfig, this);	
		 				this.pmSlctdServTubesCfgDeepCloneAgents.add(temp);
	 				}
	 			}																 
	 		}
 		}
 		
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializePMSelectedServiceTubesConfig Stop');
 	}
 	
 	/**
 	 * [ (override) deepClone : we need to clone the current object but also to run the deepClone on all
 	 *   the deep clone agent ]
 	 */
 	public override void deepClone(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Start');
 		
 		this.clonedObject = this.objectToClone.clone(false, true, false, false);
 		
 		//We're going to run the deepClone method for all the deep clone agent linked to this object.
 		for(AP002_PMSelectedDispCfgDeepCloneAgent pmSelectedDispCfgDeepCloneAgent : this.pmSelectedDispCfgDeepCloneAgents){
	 		if(pmSelectedDispCfgDeepCloneAgent != null){
				pmSelectedDispCfgDeepCloneAgent.deepClone();
	 		}
		}
		for(AP002_PMSelectedTubesCfgDeepCloneAgent pmSelectedTubesCfdDeepCloneAgent : this.pmSelectedTubesCfdDeepCloneAgents ){	
			if(pmSelectedTubesCfdDeepCloneAgent != null){
				pmSelectedTubesCfdDeepCloneAgent.deepClone();	
			}
		}	
		for(AP002_PMSlctdServTubesCfgDeepCloneAgent pmSlctdServTubesCfgDeepCloneAgent : this.pmSlctdServTubesCfgDeepCloneAgents){
			if(pmSlctdServTubesCfgDeepCloneAgent != null){
				pmSlctdServTubesCfgDeepCloneAgent.deepClone();
			}
		}

		/*for(AP002_PMReviewNetPricePerMOQDeepClAgent pmReviewNetPricePerMOQDeepClAgent : this.pmReviewNetPricePerMOQDeepClAgents){
			if(pmReviewNetPricePerMOQDeepClAgent != null){
				pmReviewNetPricePerMOQDeepClAgent.deepClone();
			}
		}*/
		for(AP002_PMMOQPriceDeepCloneAgent pmMOQPriceDeepCloneAgent : this.pmMOQPriceDeepCloneAgents){
			if(pmMOQPriceDeepCloneAgent != null){
				pmMOQPriceDeepCloneAgent.deepClone();
			}
		}
		for(AP002_PMPriceDetailDeepCloneAgent pmPriceDetailDeepCloneAgent : this.pmPriceDetailDeepCloneAgents){
			if(pmPriceDetailDeepCloneAgent != null){
				pmPriceDetailDeepCloneAgent.deepClone(); 
			}
		} 
		for(AP002_PMPriceRecoDeepCloneAgent pmPriceRecoDeepCloneAgent : this.pmPriceRecoDeepCloneAgents){
			if(pmPriceRecoDeepCloneAgent != null) {
				pmPriceRecoDeepCloneAgent.deepClone();
			}
		}

		//Zone Product Offer for other MOQ
 		this.cleanProductOfferForOtherMOQSection();

 		//Zone Quote Line Item information
 		this.cleanQuoteLineItemInformationSection();

 		//Zone Financial Information 
		this.cleanFinancialInformationSection();	

		this.cleanEveryTime();

		if(! this.sameAccount){
			System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Same Account');
			this.clonedObject.put('selected_corridor__c',null);
			this.clonedObject.put('Customer_Scoring__c',0);
			this.clonedObject.put('Total_Score__c', 0);

			this.clonedObject.put('Brand__c',null);
 			this.clonedObject.put('Product_Brand_Name_to_be_added__c',null);
			
			this.resetDealScoring();
		}

		if(! this.sameOpportunity){
			System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Different Opportunity');
			this.clonedObject.put('selected_corridor__c',null);
			this.clonedObject.put('Customer_Scoring__c',0);
			this.clonedObject.put('Total_Score__c', 0);

			this.clonedObject.put('Brand__c',null);
 			this.clonedObject.put('Product_Brand_Name_to_be_added__c',null);

			this.resetDealScoring();
		}

		if(this.objectToClone.get('isPriceMatrix__c') == true){
			System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Price Matrix');
 			this.clonedObject.put('Sales_price_per_1000_KCur__c',0);
 		}
 		else{
 			if(this.sameOpportunity){
 				System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Price Matrix & Same Opportunity');
 				this.clonedObject.put('Sales_price_per_1000_KCur__c',0);
 			}
 			else{
 				System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Price Matrix & Different Opportunity');
 				//Zone Quote Item Information
 				this.cleandQuoteItemInformationSection();

 				//Zone SKP KPIs
 				this.cleanSKPKPIsSection();

 				//Zone Manufacturing
 				this.cleanManufacturingSection();

 				//Zone Tooling
 				this.cleanToolingSection();

 				//Zone Trading
 				this.cleanTradingSection();

 				//Zone Competitor
 				this.cleanCompetitorSection();

 				//Zone Product specification
 				this.cleanProductSpecificationSection();

 				//Zone RFQ Detail
 				this.cleanRFQDetailSection();
 			}
 		}

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Stop');
 	}

 	/**
	 * [ (override) updateClonedObject : update the cloned object ]
 	 */
 	public override void updateClonedObject(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Start');

 		//We're going to run the updateClonedObject method for all the deep clone agent linked to this object.
 		for(AP002_PMSelectedDispCfgDeepCloneAgent pmSelectedDispCfgDeepCloneAgent : this.pmSelectedDispCfgDeepCloneAgents){
	 		if(pmSelectedDispCfgDeepCloneAgent != null){
				pmSelectedDispCfgDeepCloneAgent.updateClonedObject();	
	 		}
	 	}
		for(AP002_PMSelectedTubesCfgDeepCloneAgent pmSelectedTubesCfdDeepCloneAgent : this.pmSelectedTubesCfdDeepCloneAgents ){	
			if(pmSelectedTubesCfdDeepCloneAgent != null){
				pmSelectedTubesCfdDeepCloneAgent.updateClonedObject();		
			}
		}
		for(AP002_PMSlctdServTubesCfgDeepCloneAgent pmSlctdServTubesCfgDeepCloneAgent : this.pmSlctdServTubesCfgDeepCloneAgents){
			if(pmSlctdServTubesCfgDeepCloneAgent != null){
				pmSlctdServTubesCfgDeepCloneAgent.updateClonedObject();
			}
		}
		/*
		for(AP002_PMReviewNetPricePerMOQDeepClAgent pmReviewNetPricePerMOQDeepClAgent : this.pmReviewNetPricePerMOQDeepClAgents){
			if(pmReviewNetPricePerMOQDeepClAgent != null){
				pmReviewNetPricePerMOQDeepClAgent.updateClonedObject();
			}
		}*/
		for(AP002_PMMOQPriceDeepCloneAgent pmMOQPriceDeepCloneAgent : this.pmMOQPriceDeepCloneAgents){
			if(pmMOQPriceDeepCloneAgent != null){
				pmMOQPriceDeepCloneAgent.updateClonedObject();
			}
		}
		for(AP002_PMPriceDetailDeepCloneAgent pmPriceDetailDeepCloneAgent : this.pmPriceDetailDeepCloneAgents){
			if(pmPriceDetailDeepCloneAgent != null){
				pmPriceDetailDeepCloneAgent.updateClonedObject();  
			}
		}
		for(AP002_PMPriceRecoDeepCloneAgent pmPriceRecoDeepCloneAgent : this.pmPriceRecoDeepCloneAgents){
			if(pmPriceRecoDeepCloneAgent != null) {
				pmPriceRecoDeepCloneAgent.updateClonedObject();
			}
		}

		this.resetCustomerScoring();

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Stop');
 	}

 	/**
 	 * [ getAllClonedSObject description : return all the cloned sobject ]
 	 * @return List<SObject> : the cloned object
 	 */
 	public List<SObject> getAllClonedSObject(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedSObject Start');

 		List<SObject> result = new List<SObject>();

 		for(AP002_PMMOQPriceDeepCloneAgent pmMOQPriceDeepCloneAgent : this.pmMOQPriceDeepCloneAgents){
	 		if(pmMOQPriceDeepCloneAgent != null){
	 			if(pmMOQPriceDeepCloneAgent.clonedObject != null){
	 				result.Add(pmMOQPriceDeepCloneAgent.clonedObject);
	 			}
	 		}
	 	}
	 	for(AP002_PMPriceDetailDeepCloneAgent pmPriceDetailDeepCloneAgent : this.pmPriceDetailDeepCloneAgents){
	 		if(pmPriceDetailDeepCloneAgent != null){
	 			if(pmPriceDetailDeepCloneAgent.clonedObject != null){
	 				result.Add(pmPriceDetailDeepCloneAgent.clonedObject);
	 			}
	 		}
	 	}
	 	/*
 		for(AP002_PMReviewNetPricePerMOQDeepClAgent pmReviewNetPricePerMOQDeepClAgent : this.pmReviewNetPricePerMOQDeepClAgents){
	 		if(pmReviewNetPricePerMOQDeepClAgent != null){
	 			if(pmReviewNetPricePerMOQDeepClAgent.clonedObject != null){
	 				result.Add(pmReviewNetPricePerMOQDeepClAgent.clonedObject);
	 			}
	 		}
 		}*/
 		for(AP002_PMSelectedDispCfgDeepCloneAgent pmSelectedDispCfgDeepCloneAgent : this.pmSelectedDispCfgDeepCloneAgents){
	 		if(pmSelectedDispCfgDeepCloneAgent != null){
	 			if(pmSelectedDispCfgDeepCloneAgent.clonedObject != null){
	 				result.Add(pmSelectedDispCfgDeepCloneAgent.clonedObject);
	 			}
	 		}
	 	}
 		for(AP002_PMSelectedTubesCfgDeepCloneAgent pmSelectedTubesCfdDeepCloneAgent : this.pmSelectedTubesCfdDeepCloneAgents ){	
			if(pmSelectedTubesCfdDeepCloneAgent != null){
 				if(pmSelectedTubesCfdDeepCloneAgent.clonedObject != null){
 					result.Add(pmSelectedTubesCfdDeepCloneAgent.clonedObject);
 				}
 			}
 		}
 		for(AP002_PMSlctdServTubesCfgDeepCloneAgent pmSlctdServTubesCfgDeepCloneAgent : this.pmSlctdServTubesCfgDeepCloneAgents){
	 		if(pmSlctdServTubesCfgDeepCloneAgent != null){
	 			if(pmSlctdServTubesCfgDeepCloneAgent.clonedObject != null){
	 				result.Add(pmSlctdServTubesCfgDeepCloneAgent.clonedObject);
	 			}
	 		}
	 	}
 		if(this.clonedObject != null){
 			result.Add(this.clonedObject);
 		}

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedSObject Stop');

 		return result;
 	}

 	/**
 	 * [ getAllClonedPMMOQPrice description : will return all the cloned PMMOQPrice items ]
 	 * @return List<PM_MOQ_price__c> : all the cloned PMMOQPrice items
 	 */
 	public List<PM_MOQ_price__c> getAllClonedPMMOQPrice(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMMOQPrice Start');

 		List<PM_MOQ_Price__c> result = new List<PM_MOQ_Price__c>();

 		for(AP002_PMMOQPriceDeepCloneAgent pmMOQPriceDeepCloneAgent : this.pmMOQPriceDeepCloneAgents){
	 		if(pmMOQPriceDeepCloneAgent != null){
	 			if(pmMOQPriceDeepCloneAgent.clonedObject != null){
	 				result.add((PM_MOQ_Price__c) pmMOQPriceDeepCloneAgent.clonedObject);
	 			}
	 		}
	 	}

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMMOQPrice Stop');

 		return result;
 	}

 	/**
 	 * [ getAllClonedPMPriceDetail description : will return all the cloned PMPriceDetail items ]
 	 * @return List<PM_Price_Detail__c> : all the cloned PMPriceDetail items
 	 */
 	public List<PM_Price_Detail__c> getAllClonedPMPriceDetail(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMPriceDetail Start');

		List<PM_Price_Detail__c> result = new List<PM_Price_Detail__c>(); 	

		for(AP002_PMPriceDetailDeepCloneAgent pmPriceDetailDeepCloneAgent : pmPriceDetailDeepCloneAgents){
			if(pmPriceDetailDeepCloneAgent != null){
				if(pmPriceDetailDeepCloneAgent.clonedObject != null){
					result.add((PM_Price_Detail__c) pmPriceDetailDeepCloneAgent.clonedObject);
				}
			}
		}

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMPriceDetail Stop');	

 		return result;
 	}

 	/**
 	 * [ getAllClonedPMPriceRecommendation description : will return all the cloned PMPriceRecommendation items ]
 	 * @return List<PM_Price_Recommendation__c> : all the cloned PMPriceRecommendation items
 	 */
 	public List<PM_Price_Recommendation__c> getAllClonedPMPriceRecommendation(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMPriceRecommendation Start');

 		List<PM_Price_Recommendation__c> result = new List<PM_Price_Recommendation__c>();	

 		if(this.pmPriceRecoDeepCloneAgents != null){
	 		for(AP002_PMPriceRecoDeepCloneAgent pmPriceRecoDeepCloneAgent : this.pmPriceRecoDeepCloneAgents){
	 			if(pmPriceRecoDeepCloneAgent.clonedObject != null)
	 				result.add((PM_Price_Recommendation__c) pmPriceRecoDeepCloneAgent.clonedObject);
	 		}
	 	}

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMPriceRecommendation Stop');

 		return result;
 	}

 	/**
 	 * [ getAllClonedPMReviewNetPriceperMOQ description : will return all the cloned PMReviewNetPricePerMOQ items ]
 	 * @return List<PM_Review_NetPrice_per_MOQ__c> : all the cloned PMReviewNetPricePerMOQ items
 	 */
 	/* 
 	public List<PM_Review_NetPrice_per_MOQ__c> getAllClonedPMReviewNetPriceperMOQ(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMReviewNetPriceperMOQ Start');

 		List<PM_Review_NetPrice_per_MOQ__c> result = new List<PM_Review_NetPrice_per_MOQ__c>();

 		/*
 		if(this.pmReviewNetPricePerMOQDeepClAgents != null){
	 		for(AP002_PMReviewNetPricePerMOQDeepClAgent pmReviewNetPricePerMOQDeepClAgent : this.pmReviewNetPricePerMOQDeepClAgents){
	 			if(pmReviewNetPricePerMOQDeepClAgent.clonedObject != null)
	 				result.Add((PM_Review_NetPrice_per_MOQ__c) pmReviewNetPricePerMOQDeepClAgent.clonedObject);
	 		}
 		}
 		*/
/*
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMReviewNetPriceperMOQ Stop');

 		return result;
 	}
*/
 	/**
 	 * [ getAllClonedPMSelectedDispensingConfig description : will return all the cloned PMSelectedDispensingConfig items ]
 	 * @return List<PM_Selected_Dipsensing_config__c> : all the cloned PMSelectedDispensingConfig items
 	 */ 
 	public List<PM_Selected_Dipsensing_config__c> getAllClonedPMSelectedDispensingConfig(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMSelectedDispensingConfig Start');

 		List<PM_Selected_Dipsensing_config__c> result = new List<PM_Selected_Dipsensing_config__c>();

 		for(AP002_PMSelectedDispCfgDeepCloneAgent pmSelectedDispCfgDeepCloneAgent : this.pmSelectedDispCfgDeepCloneAgents){
	 		if(pmSelectedDispCfgDeepCloneAgent != null){
	 			if(pmSelectedDispCfgDeepCloneAgent.clonedObject != null){
	 				result.add((PM_Selected_Dipsensing_config__c) pmSelectedDispCfgDeepCloneAgent.clonedObject);
	 			}
	 		}
 		}

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMSelectedDispensingConfig Stop');

 		return result;
 	}

 	/**
 	 * [ getAllClonedPMSelectedTubesConfig description : will return all the cloned PMSelectedTubesConfig items ]
 	 * @return List<PM_Selected_Tubes_Config__c> : all the cloned PMSelectedTubesConfig items
 	 */
 	public List<PM_Selected_Tubes_Config__c> getAllClonedPMSelectedTubesConfig(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMSelectedTubesConfig Start');

 		List<PM_Selected_Tubes_Config__c> result = new List<PM_Selected_Tubes_Config__c>();

 		if(this.pmSelectedTubesCfdDeepCloneAgents != null){
	 		for(AP002_PMSelectedTubesCfgDeepCloneAgent pmSelectedTubesCfdDeepCloneAgent : this.pmSelectedTubesCfdDeepCloneAgents){
	 			if(pmSelectedTubesCfdDeepCloneAgent.clonedObject != null)
	 				result.add((PM_Selected_Tubes_Config__c) pmSelectedTubesCfdDeepCloneAgent.clonedObject);
	 		}
	 	}

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMSelectedTubesConfig Stop');

 		return result;
 	}

 	/**
 	 * [ getAllClonedPMSelectedServiceTubesConfig description : will return all the cloned PMSelectedServiceTubesConfig items ]
 	 * @return List<PM_Selected_Service_Tubes_Config__c> : all the cloned PMSelectedServiceTubesConfig items
 	 */
 	public List<PM_Selected_Service_Tubes_Config__c> getAllClonedPMSelectedServiceTubesConfig(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMSelectedServiceTubesConfig Start');

 		List<PM_Selected_Service_Tubes_Config__c> result = new List<PM_Selected_Service_Tubes_Config__c>();

 		for(AP002_PMSlctdServTubesCfgDeepCloneAgent pmSlctdServTubesCfgDeepCloneAgent : this.pmSlctdServTubesCfgDeepCloneAgents){
	 		if(pmSlctdServTubesCfgDeepCloneAgent != null){
	 			if(pmSlctdServTubesCfgDeepCloneAgent.clonedObject != null){
	 				result.add((PM_Selected_Service_Tubes_Config__c) pmSlctdServTubesCfgDeepCloneAgent.clonedObject);
	 			}
	 		}
	 	}

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getAllClonedPMSelectedServiceTubesConfig Start');

 		return result;
 	}

 	/**
 	 * [ updateUniqueKeys description : will update the unique key on all the record linked to the QLI ]
 	 */
 	public void updateUniqueKeys(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateUniqueKeys Start.');

 		if(this.pmPriceRecoDeepCloneAgents != null){
 			for(AP002_PMPriceRecoDeepCloneAgent pmPriceRecoDeepCloneAgent : this.pmPriceRecoDeepCloneAgents){
 				pmPriceRecoDeepCloneAgent.updateUniqueKey();
 			}
 		}

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateUniqueKeys End.');
 	}

 	/**
 	 * [ resetDealScoring description : the action that need to be done to reset deal scoring ]
 	 */
 	public void resetDealScoring(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - resetDealScoring Start.');

 		this.clonedObject.put('Deal_scoring__c', 0);
 		this.clonedObject.put('DS_NB_month_of_stock_at_Albea_expenses__c', null);
 		this.clonedObject.put('DS_Contract_duration__c', null);
 		this.clonedObject.put('DS_Indexation_of_raw_material_costs__c', null);
 		this.clonedObject.put('DS_Exclusivity_Single_vs_Multiple_Supp__c', null);
 		this.clonedObject.put('DS_Tooling_CAPEX_investments_required__c', null);
 		this.clonedObject.put('DS_Albea_dependency_to_suppliers__c', null);
 		this.clonedObject.put('DS_Penalties_customer_in_the_contract__c', null);
 		this.clonedObject.put('DS_Type_of_business__c', null);
 		this.clonedObject.put('DS_Penalties_in_the_contract_for_Albea__c', null);
 		this.clonedObject.put('DS_Multiple_Release_Order_Blanket_Order__c', null);
 		this.clonedObject.put('DS_Skonto_for_cash_payment__c', null);

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - resetDealScoring Stop.');
 	}

 	/**
 	 * [ resetCustomerScoring description : the action that need to be done to reset customer scoring ]
 	 */
 	public void resetCustomerScoring(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - resetCustomerScoring Start.');

 		//Resetting the informations use to calculate the customer scoring 
 		//Id accId = (Id) this.parentQuoteDeepCloneAgent.clonedObject.get('AccountID');
 		if(this.parentQuoteDeepCloneAgent.AccountID != null && this.parentQuoteDeepCloneAgent.AccountID != ''){
 			Id accId = this.parentQuoteDeepCloneAgent.AccountID;
	 		Account acc = [SELECT Business_at_other_product_line__c, Payment_terms__c, Required_level_of_documentation__c,
	 		  					  Monthly_overdue_DSO__c, Quality_requirement__c, Customer_end_of_year_rebate__c,
	 		  					  Customer_EBB_rate__c, Type
	 						 FROM Account
	 						WHERE Id =: accId ];
	 		//system.Debug('ici : ' + accId);
	 		//system.Debug('ici : ' + (Id) this.parentQuoteDeepCloneAgent.AccountID);
	 		this.clonedObject.put('Business_at_other_product_line__c', acc.Business_at_other_product_line__c);
	 		this.clonedObject.put('Payment_terms__c', acc.Payment_terms__c);
	 		this.clonedObject.put('Required_level_of_documentation__c', acc.Required_level_of_documentation__c);
	 		this.clonedObject.put('Monthly_overdue_DSO__c', acc.Monthly_overdue_DSO__c);
	 		this.clonedObject.put('Quality_requirement__c', acc.Quality_requirement__c);
	 		this.clonedObject.put('Customer_end_of_year_rebate__c', acc.Customer_end_of_year_rebate__c);
	 		this.clonedObject.put('Customer_EBB_rate__c', acc.Customer_EBB_rate__c);

	 		//Recalculing the customer scoring with the new information
	 		string typeval = acc.Type;
	        
	        System.debug('############### this.clonedObject.Quote.Opportunity.Account.Type : '+typeval);
	        
	        List<Scoring__c> custscorelst = LCC01_Scorings_Controller.getscoringslists('Customer', 
	        	LCC01_Scorings_Controller.getlocation(
	        		(String) this.clonedObject.get('Location__c')
	        	)
	        );
	        
	        Decimal customerScoring = 0;
	        for(Scoring__c score : custscorelst){
	                String selval = (String)this.clonedObject.get(score.Criteria_API_Name__c);
	                decimal weight = 0;
	                weight = (typeval == 'Prospect' && score.Prospect__c != null)?score.Prospect__c:weight;
	                weight = (typeval == 'Client' && score.Existing__c != null)?score.Existing__c:weight;
	                customerScoring += (selval != null && score.Level_1_Key__c == selval && score.Level_1_Value__c != null)?((score.Level_1_Value__c * weight)/100):0;
	                customerScoring += (selval != null && score.Level_2_Key__c == selval && score.Level_2_Value__c != null)?((score.Level_2_Value__c * weight)/100):0;
	                customerScoring += (selval != null && score.Level_3_Key__c == selval && score.Level_3_Value__c != null)?((score.Level_3_Value__c * weight)/100):0;
	                customerScoring += (selval != null && score.Level_4_Key__c == selval && score.Level_4_Value__c != null)?((score.Level_4_Value__c * weight)/100):0;
	                customerScoring += (selval != null && score.Level_5_Key__c == selval && score.Level_5_Value__c != null)?((score.Level_5_Value__c * weight)/100):0;
	        }
	        
	        customerScoring = customerScoring.setScale(3);

	        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - customerScoring : ' + customerScoring);

	        this.clonedObject.put('Customer_Scoring__c', customerScoring);

	 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - resetCustomerScoring Stop.');

	 	}
 	}

 	/**
 	 * [ listPricesToNull description : clean the section Quote Item Information ]
 	 */
 	public void cleandQuoteItemInformationSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleandQuoteItemInformationSection Start');

 		this.clonedObject.put('Production_Cluster__c',''); 
		this.clonedObject.put('Production_Plant__c','');	this.clonedObject.put('Item_name__c','');
		this.clonedObject.put('Invoicing_Cluster__c','');	this.clonedObject.put('Location__c','');
		this.clonedObject.put('Invoicing_Plant__c','');		this.clonedObject.put('Price_Book__c','');
		this.clonedObject.put('Purefoil_Segment__c',false); this.clonedObject.put('Service__c','');
		this.clonedObject.put('Incoterm__c','');			this.clonedObject.put('Service_list__c','');
		this.clonedObject.put('Comments__c','');			this.clonedObject.put('Service_amount_k_Cur__c',0);	
		this.clonedObject.put('Innovation__c','');			this.clonedObject.put('tech_validation_error_update_qli__c','');
		this.clonedObject.put('Sub_Segment_Copy__c','');	this.clonedObject.put('Tech_validation_error__c','');
		this.clonedObject.put('ID_Calculette__c','');		this.clonedObject.put('Bypass_VR__c',false);
		 
		this.clonedObject.put('ProductPicture__c','');

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleandQuoteItemInformationSection Stop');
 	}

 	/**
 	 * [ cleanSKPKPIsSection description : clean the section SKP KPIs ]
 	 */
 	public void cleanSKPKPIsSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanSKPKPIsSection Start');

 		this.clonedObject.put('KPI_SKP_Config_OK__c',false);  	
		this.clonedObject.put('KPI_SKP_Price_checked_OK__c',false);		
		this.clonedObject.put('KPI_SKP_Price_Reco_OK__c',false);
		this.clonedObject.put('KPI_SKP_PPI_OK__c',false);

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanSKPKPIsSection Stop');
 	}

 	/**
 	 * [ cleanFinancialInformationSection description : clean the section Financial Information ]
 	 */
 	public void cleanFinancialInformationSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanFinancialInformationSection Start');

 		this.clonedObject.put('Sales_price_per_1000_KCur__c'	 , null );
		this.clonedObject.put('Minimum_Order_Quantity__c'		 , null );
		this.clonedObject.put('ALBEA_CAPEX_needed_k_Cur__c'		 , null );
		//this.clonedObject.put('Billing_Currency__c'				 , null );
		this.clonedObject.put('Service_amount_k_Cur__c'			 , 0    );
		this.clonedObject.put('CB1__c'							 , 0    );
		this.clonedObject.put('Tooling_contribution__c'			 , 0    );
		this.clonedObject.put('Invoicing_cluster_contribution__c', 0    );
		this.clonedObject.put('Tooling_sales_price_k_Cur__c'     , 0    );
		this.clonedObject.put('Price_book_level_per_1000__c'     , 0    );
		this.clonedObject.put('Delta_vs_list_price__c'           , null );

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanFinancialInformationSection Start');
 	}

 	/**
 	 * [ cleanManufacturingSection description : clean the section Manufacturing ]
 	 */
 	public void cleanManufacturingSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanManufacturingSection Start');

 		this.clonedObject.put('CB0__c', 0);
		this.clonedObject.put('CB1__c', 0);
		this.clonedObject.put('Price_book_level_per_1000__c', 0);

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanManufacturingSection Stop');
 	}

 	/**
 	 * [ cleanToolingSection description : clean the section Tooling ]
 	 */
 	public void cleanToolingSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanToolingSection Start');

 		this.clonedObject.put('Tooling_contribution__c', 0);
		this.clonedObject.put('Tooling_sales_price_k_Cur__c', 0);

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanToolingSection Stop');
 	}

 	/**
 	 * [ cleanTradingSection description : clean the section Trading ]
 	 */
 	public void cleanTradingSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanTradingSection Start');

 		this.clonedObject.put('Invoicing_cluster_contribution__c', 0);

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanTradingSection Stop');
 	}

 	/**
 	 * [ cleanCompetitorSection description : clean the section Competitor ]
 	 */
 	public void cleanCompetitorSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanCompetitorSection Start');

 		this.clonedObject.put('Competitor_price_per_1000_Cur__c', 0);

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanCompetitorSection Stop');
 	}

 	/**
 	 * [ cleanProductSpecification description : clean the section Product Specification ]
 	 */
 	public void cleanProductSpecificationSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanProductSpecificationSection Start');

 		this.clonedObject.put('Dose__c', '');		this.clonedObject.put('Material__c', '');
		this.clonedObject.put('Cap__c', '');		this.clonedObject.put('Printing_type__c', '');
		this.clonedObject.put('Diameter__c', '');

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanProductSpecificationSection Stop');
 	}

 	/**
 	 * [ cleanRFQDetailSection description : clean the section RFQ Detail ]
 	 */
 	public void cleanRFQDetailSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanRFQDetail Start');

 		this.clonedObject.put('Reference_pricing__c','');	this.clonedObject.put('Actuor_Type__c','');
		this.clonedObject.put('Product_Hierarchy__c','');	this.clonedObject.put('Finish__c','');
		this.clonedObject.put('Market_Segment__c','');		this.clonedObject.put('Dressing__c','');
		this.clonedObject.put('Market_Sub_Segment__c','');	this.clonedObject.put('Fitting_Method__c','');

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanRFQDetail Stop');
 	}

 	/**
 	 * [ cleanProductOfferForOtherMOQSection description : clean the section Product Offer for other MOQ ]
 	 */
 	public void cleanProductOfferForOtherMOQSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanProductOfferForOtherMOQSection Start');

 		this.clonedObject.put('X1_MOQ_per_SKU__c', null);		this.clonedObject.put('X1_Piece_Price_Currency_per_1000_pieces__c', null);
		this.clonedObject.put('X1_MOQ_Option1__c','');		this.clonedObject.put('X1_MOQ_Option2_c__c','');
		this.clonedObject.put('X2_MOQ_per_SKU__c', null);		this.clonedObject.put('X2_Piece_Price_Currency_per_1000_pieces__c', null);
		this.clonedObject.put('X2_MOQ_Option1_c__c','');	this.clonedObject.put('X2_Option_2_2__c','');
		this.clonedObject.put('X3_MOQ_per_SKU__c', null);		this.clonedObject.put('X3_Piece_Price_Currency_per_1000_pieces__c', null);
		this.clonedObject.put('X1_Option_1_3__c','');		this.clonedObject.put('X2_Option_2_3__c','');
		this.clonedObject.put('X4_MOQ_per_SKU__c', null);		this.clonedObject.put('X4_Piece_Price_Currency_per_1000_pieces__c', null);
		this.clonedObject.put('X1_Option_1_4__c','');		this.clonedObject.put('X2_Option_2_4__c','');
		this.clonedObject.put('X5_MOQ_per_SKU__c', null);		this.clonedObject.put('X5_Piece_Price_Currency_per_1000_pieces__c', null);
		this.clonedObject.put('X1_Option_1_5__c','');		this.clonedObject.put('X2_Option_2_5__c','');
		this.clonedObject.put('X7_MOQ_per_SKU__c', null);		this.clonedObject.put('X7_Piece_Price_Currency_per_1000_pieces__c', null);
		this.clonedObject.put('X1_Option_1_7__c','');		this.clonedObject.put('X2_Option_2_7__c','');

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanProductOfferForOtherMOQSection Stop');
 	}

 	/**
 	 * [ cleanQuoteLineItemInformationSection description : clean fields in the section Quote Line Item Information ]
 	 */
 	public void cleanQuoteLineItemInformationSection(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanQuoteLineItemInformationSection Start');

 		this.clonedObject.put('Quoted_Price_Color__c', null);
 		this.clonedObject.put('Color_matching_process__c', null);

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanQuoteLineItemInformationSection Stop');
 	}

 	/**
 	 * [ cleanEveryTime description : clean the fields that need to be cleaned every time ]
 	 */
 	public void cleanEveryTime(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanEveryTime Start');

 		//this.clonedObject.put('selected_corridor__c',null);

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanEveryTime Stop');
 	}




}