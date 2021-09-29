global class BA01_Sales_Team_Sharing implements Database.Batchable<SObject>{
	
	public String query;
     
	global Database.QueryLocator start(Database.BatchableContext BC){
    	Date todayDate =   Date.today() ;
    	Date validFromValid = date.newinstance(1700, 01, 01);
    	//Date yesterdayDate =Date.today() -1;
    	
    	//get all salesalloc processed today ==> which have either validfrom = today or validto = today -1
        query = '' 
            + 'Select '
            + ' id, '
            + ' Sales_Allocations__c.Product_Sub_Segment__c, '
            + ' Sales_Allocations__c.Account__c, '
            + ' Sales_Team__c,sales_team__r.Tech_Overlapped_SalesTeam__c, '
            + ' KAMF__c, '
            + ' Manager__c, '
            + ' Director__c, '
            + ' Additional__c, '
            + ' Sales_Team__r.KAM__c, '
            + ' Valid_To__c, '
            + ' Valid_From__c ';
        query +=' FROM Sales_Allocations__c ';
        query +=' WHERE ( Valid_From__c= :todayDate OR (Valid_From__c= :validFromValid  AND LASTMODIFIEDDATE = LAST_N_DAYS:1)) AND Valid_To__c >=  :todayDate AND Sales_Team__c != null ' ;
        query +=' Order by Valid_From__c DESC ';
        
        system.debug('--- Query ---'+query);
        
        return Database.getQueryLocator(query);
    }//end start
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){    
		list<Sales_Allocations__c> allSalesAllocs = scope;
		
		//get the old salesteams
		set<id> idsOldSalesTeam = new Set<id>();
		for(Integer i = 0; i < allSalesAllocs.size(); i++){
			//if(idsOldSalesTeam.add(allSalesAllocs[i].sales_team__r.Tech_Overlapped_SalesTeam__c) != null)
				idsOldSalesTeam.add(allSalesAllocs[i].sales_team__r.Tech_Overlapped_SalesTeam__c);
        }
			
		SalesTeamService.processAllocation(allSalesAllocs ,idsOldSalesTeam);		          
        
    }//end execute
    
    global void finish(Database.BatchableContext BC){
    	//Update opportunity owners
    	Database.executeBatch(new BA01_Opportunity_Owner());    
           
    }	    
}