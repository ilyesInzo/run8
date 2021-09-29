/**
 * [ Class AP002_PMPriceDetailDeepCloneAgent : a deep clone agent for the PM_Price_Detail__c]
 * @author EWA
 * @version 1.0   - Ready for UAT
 * @history 1.0   - Ready for UAT
 *          0.9.9 - The insert call are made at another level
 *          0.9   - To be tested version
 *          0.6   - Linked the PM_Price_Detail__c deep clone agent to the QuoteLineItem deep clone agent
 *          0.5   - Stub
 */
public class AP002_PMPriceDetailDeepCloneAgent extends APXXX_VirtualDeepCloneAgent {
    //Attributs of the class AP002_PMPriceDetailDeepCloneAgent
    public static String LOG_CLASS_NAME = 'AP002_PMPriceDetailDeepCloneAgent';
    
    /**
     * [ parentQliDeepCloneAgent : the deep clone agent for the parent quote line item ]
     */
    public AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent;

    /**
     * [ pmSelectedDispCfdDeepCloneAgent : the deep clone agent for the corresponding Selected Dispensing Config ]
     */
    public AP002_PMSelectedDispCfgDeepCloneAgent pmSelectedDispCfdDeepCloneAgent;

    /**
     * [ pmSelectedTubesCfdDeepCloneAgent : the deep clone agent for the corresponding Selected Tubes Config ]
     */ 
    public AP002_PMSelectedTubesCfgDeepCloneAgent pmSelectedTubesCfdDeepCloneAgent;
    
    //Constructors of the class AP002_PMPriceDetailDeepCloneAgent
    /**
     * [ Constructor of the class AP002_PMPriceDetailDeepCloneAgent ]
     * @param pmPriceDetail [ PM_Price_Detail__c : a record of the PM_Price_Detail__c object type]
     */
    public AP002_PMPriceDetailDeepCloneAgent(PM_Price_Detail__c pmPriceDetail){
    	super(pmPriceDetail);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');
    } 
    
    /**
     * [ Constructor of the class AP002_PMPriceDetailDeepCloneAgent ]
     * @param pmPriceDetail           [ PM_Price_Detail__c                : a record of the PM_Price_Detail__c object type ]
     * @param parentQliDeepCloneAgent [ AP002_QuoteLineItemDeepCloneAgent : the deep clone agent for the parent qli        ]
     */
    public AP002_PMPriceDetailDeepCloneAgent(PM_Price_Detail__c pmPriceDetail, AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent){
    	super(pmPriceDetail);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	this.parentQliDeepCloneAgent = parentQliDeepCloneAgent;
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');
    }   

    /**
     * [ Constructor of the class AP002_PMPriceDetailDeepCloneAgent ]
     * @param pmPriceDetail                    [ PM_Price_Detail__c                     : a record of the PM_Price_Detail__c object type                  ]
     * @param parentQliDeepCloneAgent          [ AP002_QuoteLineItemDeepCloneAgent      : the deep clone agent for the parent qli                         ]
     * @param pmSelectedDispCfdDeepCloneAgent  [ AP002_PMSelectedDispCfgDeepCloneAgent  : a deep clone agent for the patern PM Selected Dispensing Config ]
     * @param pmSelectedTubesCfdDeepCloneAgent [ AP002_PMSelectedTubesCfgDeepCloneAgent : a deep clone agent for the patern PM Selected Tubes Config      ]
     */

    /*
    public AP002_PMPriceDetailDeepCloneAgent(PM_Price_Detail__c pmPriceDetail, AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent,
                                                AP002_PMSelectedDispCfgDeepCloneAgent pmSelectedDispCfdDeepCloneAgent,
                                                AP002_PMSelectedTubesCfgDeepCloneAgent pmSelectedTubesCfdDeepCloneAgent){
        super(pmPriceDetail);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
        
        this.parentQliDeepCloneAgent = parentQliDeepCloneAgent;
        this.pmSelectedDispCfdDeepCloneAgent = pmSelectedDispCfdDeepCloneAgent;
        this.pmSelectedTubesCfdDeepCloneAgent = pmSelectedTubesCfdDeepCloneAgent;

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');
    }
    */
    //Methods of the class AP002_PMPriceDetailDeepCloneAgent
    /**
 	 * [ (override) deepClone : we need to clone the current object but also to run the deepClone on all
 	 *   the deep clone agent ]
 	 */
 	public override void deepClone(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Start');
 		
 		this.clonedObject = this.objectToClone.clone(false, true, false, false);
        this.clonedObject.put('ExtId__c',null);

 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Stop');
 	}

    /**
     * [ (override) updateClonedObject : updating the cloned object ]
     */
    public override void updateClonedObject(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Start');

        if(this.parentQliDeepCloneAgent != null){
            if(this.parentQliDeepCloneAgent.clonedObject != null)
                this.clonedObject.put('Quote_item__c' , this.parentQliDeepCloneAgent.clonedObject.Id);
        }
        if(this.pmSelectedDispCfdDeepCloneAgent != null){
            if(this.pmSelectedDispCfdDeepCloneAgent.clonedObject != null)
                this.clonedObject.put('PM_Selected_Dipsensing_Config__c' , this.pmSelectedDispCfdDeepCloneAgent.clonedObject.Id);
        }
        if(this.pmSelectedTubesCfdDeepCloneAgent != null){
            if(this.pmSelectedTubesCfdDeepCloneAgent.clonedObject != null)
                this.clonedObject.put('PM_Selected_Tubes_Config__c' , this.pmSelectedTubesCfdDeepCloneAgent.clonedObject.Id);
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Stop');
    }
}