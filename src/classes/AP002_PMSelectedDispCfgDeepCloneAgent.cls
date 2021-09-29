/**
 * [Class AP002_PMSelectedDispCfgDeepCloneAgent : a clone agent for the PM Selected Dispensing Config object type]
 * @author EWA
 * @version 1.0   - Ready for UAT
 * @history 1.0   - Ready for UAT
 *          0.9.9 - The insert are made at another level
 *          0.9   - To be tested version
 *          0.6   - Linked the PM_Selected_Dipsensing_config__c deep clone agent to the QuoteLineItem deep clone agent
 *          0.5   - Stub
 */
public class AP002_PMSelectedDispCfgDeepCloneAgent extends APXXX_VirtualDeepCloneAgent{
    //Attributs of the class AP002_PMSelectedDispCfgDeepCloneAgent
   	private static String LOG_CLASS_NAME = 'AP002_PMSelectedDispCfgDeepCloneAgent';
   	
   	/**
     * [ parentQliDeepCloneAgent : the deep clone agent for the parent quote line item ]
     */
    public AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent;
   
   	//Constructors of the class AP002_PMSelectedDispCfgDeepCloneAgent
   	/**
   	 * [ Constructor of the class AP002_PMSelectedDispCfgDeepCloneAgent]
   	 * @param pmSelectedDispensingConfig [ PM_Selected_Dipsensing_config__c : a record for the object PM_Selected_Dipsensing_config__c ]
   	 */ 
   	public AP002_PMSelectedDispCfgDeepCloneAgent(PM_Selected_Dipsensing_config__c pmSelectedDispensingConfig){
		    super(pmSelectedDispensingConfig);
		
		    System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
		
		    System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');		
	  }
	
	  /**
   	 * [ Constructor of the class AP002_PMSelectedDispCfgDeepCloneAgent]
   	 * @param pmSelectedDispensingConfig [ PM_Selected_Dipsensing_config__c  : a record for the object PM_Selected_Dipsensing_config__c ]
   	 * @param parentQliDeepCloneAgent    [ AP002_QuoteLineItemDeepCloneAgent : a deep clone agent for the parent qli                    ]
   	 */ 
   	public AP002_PMSelectedDispCfgDeepCloneAgent(PM_Selected_Dipsensing_config__c pmSelectedDispensingConfig,
   													AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent){
		    super(pmSelectedDispensingConfig);
		
		    System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
		
		    this.parentQliDeepCloneAgent = parentQliDeepCloneAgent;
		
		    System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');		
	  }
   
    //Methods of the class AP002_PMSelectedDispCfgDeepCloneAgent
    /** 
     * [ (override) deepClone : we need to clone the current object but also to run the deepClone on all
 	   *   the deep clone agent ]
 	   */
	  public override void deepClone(){
 		    System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Start');
 		
 		    this.clonedObject = this.objectToClone.clone(false, true, false, false);
 	
 		    System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Stop');
    }

    /**
     * [ (override) updateClonedObject : update the cloned object ] 
     */
    public override void updateClonedObject(){
        if(this.parentQliDeepCloneAgent != null)
            if(this.parentQliDeepCloneAgent.clonedObject != null)
                this.clonedObject.put('Quote_item__c' , this.parentQliDeepCloneAgent.clonedObject.Id);
        
    }
}