/**
 * [ Class AP002_PMReviewNetPricePerMOQDeepClAgent : a virtual deep clone for the PM_Review_NetPrice_per_MOQ__c object ]
 * @author EWA
 * @version 1.0   - Ready for UAT
 * @history 1.0   - Ready for UAT
 *          0.9.9 - Insert need to be done at another level
 *          0.9   - To be tested version
 *          0.6   - Linked the PM_Review_NetPrice_per_MOQ__c deep clone agent to the QuoteLineItem deep clone agent 
 *          0.5   - Stub
 */
public class AP002_PMReviewNetPricePerMOQDeepClAgent extends APXXX_VirtualDeepCloneAgent {
    //Attributs of the class AP002_PMReviewNetPricePerMOQDeepClAgent
    public static String LOG_CLASS_NAME = 'AP002_PMReviewNetPricePerMOQDeepClAgent';
    
    /**
     * [ parentQliDeepCloneAgent : the deep clone agent for the parent quote line item ]
     */
    public AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent;

    /**
     * [ AP002_PMPriceRecoDeepCloneAgent : the deep clone agent for the parent PM Price Detail ]
     */
    public AP002_PMPriceDetailDeepCloneAgent pmPriceDetailDeepCloneAgent;

    /**
     * [ AP002_PMPriceRecoDeepCloneAgent : the deep clone agent for the parent PM Price Recommendation ]
     */
    public AP002_PMPriceRecoDeepCloneAgent pmPriceRecoDeepCloneAgent;

    //Constructurs of the class AP002_PMReviewNetPricePerMOQDeepClAgent
    /**
     * [Constructors of the class AP002_PMReviewNetPricePerMOQDeepClAgent]
     * @param pmReviewNetPriceperMOQ [PM_Review_NetPrice_per_MOQ__c : a record of the PM_Review_NetPrice_per_MOQ__c objec type ]
     */
    public AP002_PMReviewNetPricePerMOQDeepClAgent(PM_Review_NetPrice_per_MOQ__c pmReviewNetPriceperMOQ){
    	super(pmReviewNetPriceperMOQ);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');    	
    }
    
    /**
     * [Constructors of the class AP002_PMReviewNetPricePerMOQDeepClAgent]
     * @param pmReviewNetPriceperMOQ  [ PM_Review_NetPrice_per_MOQ__c     : a record of the PM_Review_NetPrice_per_MOQ__c objec type ]
     * @param parentQliDeepCloneAgent [ AP002_QuoteLineItemDeepCloneAgent : a deep clone agent for the parent qli                    ]
     */
    public AP002_PMReviewNetPricePerMOQDeepClAgent(PM_Review_NetPrice_per_MOQ__c pmReviewNetPriceperMOQ, AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent){
    	super(pmReviewNetPriceperMOQ);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	this.parentQliDeepCloneAgent = parentQliDeepCloneAgent;
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');    	
    }

    /**
     * [Constructors of the class AP002_PMReviewNetPricePerMOQDeepClAgent]
     * @param pmReviewNetPriceperMOQ  [ PM_Review_NetPrice_per_MOQ__c     : a record of the PM_Review_NetPrice_per_MOQ__c objec type ]
     * @param parentQliDeepCloneAgent [ AP002_QuoteLineItemDeepCloneAgent : a deep clone agent for the parent qli                    ]
     */
    public AP002_PMReviewNetPricePerMOQDeepClAgent(PM_Review_NetPrice_per_MOQ__c pmReviewNetPriceperMOQ, AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent,
                                                    AP002_PMPriceDetailDeepCloneAgent pmPriceDetailDeepCloneAgent,
                                                    AP002_PMPriceRecoDeepCloneAgent pmPriceRecoDeepCloneAgent){
        super(pmReviewNetPriceperMOQ);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
        
        this.parentQliDeepCloneAgent = parentQliDeepCloneAgent;
        this.pmPriceDetailDeepCloneAgent = pmPriceDetailDeepCloneAgent;
        this.pmPriceRecoDeepCloneAgent = pmPriceRecoDeepCloneAgent;
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');        
    }
    
    //Methods of the class AP002_PMReviewNetPricePerMOQDeepClAgent
    /** 
     * [ (override) deepClone : we need to clone the current object but also to run the deepClone on all
 	 *   the deep clone agent ]
 	 */
 	public override void deepClone(){
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Start');
 		
 		this.clonedObject = this.objectToClone.clone(false, true, false, false); 
        this.clonedObject.put('Selected__c', false);
        this.clonedObject.put('MOQ_Units__c',null);	
        this.clonedObject.put('Quoted_Price__c', null);	

 	
 		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Stop');
 	}

    /**
     * [ (override) updateClonedObject : update the cloned object ]
     */ 
    public override void updateClonedObject(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Start');

        if(this.parentQliDeepCloneAgent != null){
            if(this.parentQliDeepCloneAgent.clonedObject != null)
                this.clonedObject.put('Quote_Line_Item__c' , this.parentQliDeepCloneAgent.clonedObject.Id);
        }
        if(this.objectToClone.get('PM_Price_Detail__c') != null){
            if(this.pmPriceDetailDeepCloneAgent != null){
                if(this.pmPriceDetailDeepCloneAgent.clonedObject != null)
                    this.clonedObject.put('PM_Price_Detail__c' , this.pmPriceDetailDeepCloneAgent.clonedObject.Id);
            }
        }
        if(this.pmPriceRecoDeepCloneAgent != null){
            if(this.pmPriceRecoDeepCloneAgent.clonedObject != null)
                this.clonedObject.put('PriceReco__c' , this.pmPriceRecoDeepCloneAgent.clonedObject.Id);
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Stop');
    }
}