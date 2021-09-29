/**
 * [Class AP002_PMSlctdServTubesCfgDeepCloneAgent : a deep clone agent for the object PM_Selected_Service_Tubes_Config__c]
 * @author EWA
 * @version 1.0   - Ready for UAT
 * @hsitory 1.0   - Ready for UAT
 *          0.9.9 - Insert call need to be done at another level
 *          0.9   - To be tested version
 *          0.6   - Linked the PM_Selected_Service_Tubes_Config__c deep clone agent to the QuoteLineItem deep clone agent
 *          0.5   - Stub 
 */
public class AP002_PMSlctdServTubesCfgDeepCloneAgent extends APXXX_VirtualDeepCloneAgent {
    //Attributs of the class AP002_PMSlctdServTubesCfgDeepCloneAgent
    private static String LOG_CLASS_NAME = 'AP002_PMSlctdServTubesCfgDeepCloneAgent';
    
    /**
     * [ parentQliDeepCloneAgent : the deep clone agent for the parent quote line item ]
     */
    public AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent;
    
    //Constructors of the class AP002_PMSlctdServTubesCfgDeepCloneAgent
    /**
     * [Constructor of the class AP002_PMSlctdServTubesCfgDeepCloneAgent]
     * @param pmSelectedServiceTubesConfig [ PM_Selected_Service_Tubes_Config__c : the object for which we want a deep clone agent]
     */
    public AP002_PMSlctdServTubesCfgDeepCloneAgent(PM_Selected_Service_Tubes_Config__c pmSelectedServiceTubesConfig){
    	super(pmSelectedServiceTubesConfig);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor End');
    }    
    
    /**
     * [Constructor of the class AP002_PMSlctdServTubesCfgDeepCloneAgent]
     * @param pmSelectedServiceTubesConfig [ PM_Selected_Service_Tubes_Config__c : the object for which we want a deep clone agent ]
     * @param parentQliDeepCloneAgent      [ AP002_QuoteLineItemDeepCloneAgent   : the deep clone agent for the parent qli         ]
     */
    public AP002_PMSlctdServTubesCfgDeepCloneAgent(PM_Selected_Service_Tubes_Config__c pmSelectedServiceTubesConfig, 
    												AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent){
    	super(pmSelectedServiceTubesConfig);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	    	
    	this.parentQliDeepCloneAgent = parentQliDeepCloneAgent;
    	    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor End');
    }
    
    //Methods of the class AP002_PMSlctdServTubesCfgDeepCloneAgent
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
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Start');

        if(this.parentQliDeepCloneAgent != null){
            if(this.parentQliDeepCloneAgent.clonedObject != null)
                 this.clonedObject.put('Quote_item__c' , this.parentQliDeepCloneAgent.clonedObject.Id);
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Stop');
    }
}