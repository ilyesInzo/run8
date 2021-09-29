/**
 * [ description BA01_Sales_Team_Sharing_V02 : script that recalculate the Opportunity Team Member and Account Team Member ]
 * @author Eric Wartelle
 * @version 0.5 - To be tested
 */
global class BA01_Sales_Team_Sharing_V02 implements Database.Batchable<SObject>{
	//Attributs of the class BA01_Sales_Team_Sharing_V02     	
	private static String LOG_CLASS_NAME = 'BA01_Sales_Team_Sharing_V02';

    //Methods of the class BA01_Sales_Team_Sharing_V02
    /**
     * [ Method start : start the initialisation phase ]
     */
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Initialisation Start');    	
    	
    	String Query = 'SELECT Id FROM Account WHERE Account_status__c = \'Active\'';
        
        system.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Query : ' + query);
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Initialisation End');
        
        return Database.getQueryLocator(query);
    }
    
    /**
     * [ Methode execute : the main execute part ]
     */
    global void execute(Database.BatchableContext BC, List<SObject> scope){   
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Execute Start');

    	Map<Id, Account> scopeAccount = new Map<Id, Account>((List<Account>) scope);
    	Set<Id> scopeAccountIds = scopeAccount.keySet();
    	Date todayDate =   Date.today() ;

    	//get all salesalloc that are valid today
		Map<Id, Sales_Allocations__c> scopeSalesAlloc = new Map<Id, Sales_Allocations__c>([
			SELECT id, Sales_Allocations__c.Product_Sub_Segment__c, Sales_Allocations__c.Account__c,
                   Sales_Team__c,sales_team__r.Tech_Overlapped_SalesTeam__c, KAMF__c, Manager__c, Director__c,
                   Additional__c, Sales_Team__r.KAM__c, Valid_To__c, Valid_From__c, Prod_Sub_Segment__c
              FROM Sales_Allocations__c
        	  WHERE Valid_From__c <= :todayDate 
        	    AND Valid_To__c >= :todayDate 
        	    AND Sales_Team__c != NULL 
        	    AND Account__c IN: scopeAccountIds
		]);
			
		SalesAllocationsService.applySalesAllocation(scopeSalesAlloc);	

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Execute End');	             
    }
    
    /**
     * [ Methode finish : will run at the end ]
     */
    global void finish(Database.BatchableContext BC){
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Finish Start');

    	Database.executeBatch(new BA01_Opportunity_Owner());	  

    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Finish End');  
           
    }	    
}