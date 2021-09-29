/**
 * [APXXX_VirtualDeepCloneAgent : a virtual controller (can't be instanciated)]
 * @author EWA
 * @version 1.0 - To be deployed
 * @history 1.0 - To be deployed
 *          0.5 - Stub
 */
public virtual class APXXX_VirtualDeepCloneAgent {
    //Attributs of the class APXXX_VirtualDeepCloneAgent
	private static String LOG_CLASS_NAME = 'APXXX_VirtualDeepCloneAgent';
   
    /**
     * [objectToClone : the original sObject that we want to clone]
     */
   	public sObject objectToClone;
   	
   	/**
   	 * [clonedObject : the cloned sObject]
   	 */
   	public sObject clonedObject;
    
    //Constructors of the class APXXX_VirtualDeepCloneAgent
    /**
     * [Constructor of the class APXXX_VirtualDeepCloneAgent]
     * @param stdController [ApexPages.StandardController : ]
     */
    public APXXX_VirtualDeepCloneAgent(sObject objectToClone){
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');
    	
    	this.objectToClone = objectToClone;
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');
    }
    
    //Methods of the class APXXX_VirtualDeepCloneAgent
    /**
     * [clone description : the clone action to be called by the Visualforce Page]
     */
    public sObject cloneAction(){
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Clone Start');
    	
    	if(this.canBeClone()){
    		this.deepClone();
    		this.initializeClone();
    	}
    	else{
    		this.cantBeCloneAction();
    	}
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Clone Stop');
    	
    	return this.clonedObject;
    }
    
    /**
     * [canBeClone description : determine if we can clone the object or not]
     * @return [Boolean : True -> Can be cloned | False -> Can't be cloned]
     */
    public virtual Boolean canBeClone(){
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - canBeClone Start');
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - canBeClone Stop');
    	
    	return true;
    }
    
    /**
     * [cantBeCloneAction description : action to be done after the clone]
     */
    public virtual void cantBeCloneAction(){
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cantBeCloneAction Start');
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cantBeCloneAction Stop');
    	
    }
    
    /**
     * [deepClone description : will deep clone the original object]
     */
    public virtual void deepClone(){
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Start');
    	
    	this.clonedObject = this.objectToClone.clone(true, true, false, false);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Stop');	
    	
    }
    
    /**
     * [ initializeClone description : initialize the cloned object ]
     */
    public virtual void initializeClone(){
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializeClone Start');
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializeClone Stop');
    	
    }

    /**
     * [ updateClonedObject description : update the cloned object ]
     */
    public virtual void updateClonedObject(){

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Start');
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Stop');

    }
}