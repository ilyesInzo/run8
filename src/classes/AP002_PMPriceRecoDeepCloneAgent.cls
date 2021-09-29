/**
 * [ Class AP002_PMPriceRecoDeepCloneAgent : a deep clone agent for the PM_Price_Recommendation__c object type ]
 * @author EWA
 * @version 1.0   - Ready for UAT
 * @history 1.0   - Ready for UAT
 *          0.9.9 - The insert need to be done at another level
 *          0.9   - To be tested version
 *          0.6   - Linked the PM_Price_Recommendation__c deep clone agent to the QuoteLineItem deep clone agent
 *          0.5   - Stub
 */
public class AP002_PMPriceRecoDeepCloneAgent extends APXXX_VirtualDeepCloneAgent {
    //Attributs of the class AP002_PMPriceRecoDeepCloneAgent
    private static String LOG_CLASS_NAME = 'AP002_PMPriceRecoDeepCloneAgent';
    
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
    
    //Constructors of the class AP002_PMPriceRecoDeepCloneAgent
    /**
     * [ Constructor of the class AP002_PMPriceRecoDeepCloneAgent ]
     * @param pmPriceRecommandation [ PM_Price_Recommendation__c : a record for the PM_Price_Recommendation__c object type] 
     */
    public AP002_PMPriceRecoDeepCloneAgent(PM_Price_Recommendation__c pmPriceRecommendation){
    	super(pmPriceRecommendation);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');
    }
    
    /**
     * [ Constructor of the class AP002_PMPriceRecoDeepCloneAgent ]
     * @param pmPriceRecommandation   [ PM_Price_Recommendation__c : a record for the PM_Price_Recommendation__c object type ] 
     * @param parentQliDeepCloneAgent [ AP002_QuoteLineItemDeepCloneAgent : a deep clone agent for the parent qli            ]
     */
    public AP002_PMPriceRecoDeepCloneAgent(PM_Price_Recommendation__c pmPriceRecommendation, AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent){
    	super(pmPriceRecommendation);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	this.parentQliDeepCloneAgent = parentQliDeepCloneAgent;
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');
    }

    /**
     * [ Constructor of the class AP002_PMPriceRecoDeepCloneAgent ]
     * @param pmPriceRecommandation            [ PM_Price_Recommendation__c             : a record for the PM_Price_Recommendation__c object type         ] 
     * @param parentQliDeepCloneAgent          [ AP002_QuoteLineItemDeepCloneAgent      : a deep clone agent for the parent qli                           ]
     * @param pmSelectedDispCfdDeepCloneAgent  [ AP002_PMSelectedDispCfgDeepCloneAgent  : a deep clone agent for the patern PM Selected Dispensing Config ]
     * @param pmSelectedTubesCfdDeepCloneAgent [ AP002_PMSelectedTubesCfgDeepCloneAgent : a deep clone agent for the patern PM Selected Tubes Config      ]
     */

    /*
    public AP002_PMPriceRecoDeepCloneAgent(PM_Price_Recommendation__c pmPriceRecommendation, AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent,
                                                AP002_PMSelectedDispCfgDeepCloneAgent pmSelectedDispCfdDeepCloneAgent,
                                                AP002_PMSelectedTubesCfgDeepCloneAgent pmSelectedTubesCfdDeepCloneAgent){
        super(pmPriceRecommendation);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
        
        this.parentQliDeepCloneAgent = parentQliDeepCloneAgent;
        this.pmSelectedDispCfdDeepCloneAgent = pmSelectedDispCfdDeepCloneAgent;
        this.pmSelectedTubesCfdDeepCloneAgent = pmSelectedTubesCfdDeepCloneAgent;
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');
    }
    */
    
    //Methods of the class AP002_PMPriceRecoDeepCloneAgent
    /** [ (override) deepClone : we need to clone the current object but also to run the deepClone on all
 	 *   the deep clone agent ]
 	 */
 	public override void deepClone(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Start');
 		
 		this.clonedObject = this.objectToClone.clone(false, true, false, false);
        this.clonedObject.put('Unique_Key__c', null);
 	
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Stop');
 	}

    /**
     * [ (override) updateClonedObject description : will update the cloned object ]
     */
    public override void updateClonedObject(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Start');

        if(this.parentQliDeepCloneAgent != null){
            if(this.parentQliDeepCloneAgent.clonedObject != null){
                this.clonedObject.put('Quote_Line_Item__c' , this.parentQliDeepCloneAgent.clonedObject.Id);
            }
        }
        if(this.pmSelectedDispCfdDeepCloneAgent != null){
            System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.pmSelectedDispCfdDeepCloneAgent is not null');
            if(this.pmSelectedDispCfdDeepCloneAgent.clonedObject != null){
                System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - Updating PM Selected Dispensing Config for PM Price Recommendation');
                this.clonedObject.put('PM_Selected_Dipsensing_Config__c' , this.pmSelectedDispCfdDeepCloneAgent.clonedObject.Id);
            }
        }
        if(this.pmSelectedTubesCfdDeepCloneAgent != null){
            System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.pmSelectedTubesCfdDeepCloneAgent is not null');
            if(this.pmSelectedTubesCfdDeepCloneAgent.clonedObject != null){
                System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - Updating PM Selected Tubes Config for PM Price Recommendation');
                this.clonedObject.put('PM_Selected_Tubes_Config__c' , this.pmSelectedTubesCfdDeepCloneAgent.clonedObject.Id);
            }
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Stop');
    }

    /**
     * [ (override) updateUniqueKey  description : will update the unique Key ]
     */
    public void updateUniqueKey(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateUniqueKey Start');

        if(this.parentQliDeepCloneAgent != null){
            if(this.parentQliDeepCloneAgent.clonedObject != null){
                this.clonedObject.put('Quote_Line_Item__c' , this.parentQliDeepCloneAgent.clonedObject.Id);
                String uniqueKey = this.parentQliDeepCloneAgent.clonedObject.Id + '_' + this.clonedObject.get('MOQ__c');
                if(this.clonedObject.get('MOQ__c') != 999 ){
                    System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - uniqueKey : ' + uniqueKey);
                    this.clonedObject.put('Unique_Key__c' , uniqueKey);
                }
            }
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateUniqueKey Start');
    }
}