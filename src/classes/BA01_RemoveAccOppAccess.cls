global with sharing class BA01_RemoveAccOppAccess implements Database.Batchable<sObject> {
	public String Query ;
	public Set<ID> accIds;
	public Set<ID> oppIds;
	public Boolean isReschedueled ;
	public String objectTeam ;
    
    //contructor
    global BA01_RemoveAccOppAccess(Set<ID> idAccMembersToDelete,set<id> idOppMembersToDelete, Boolean isReschedueledParam,String teamType ) {
		accIds 			= new set<id>();
		accIds			= idAccMembersToDelete;
		
		oppIds 			= new set<id>();
		oppIds			= idOppMembersToDelete;
		
		isReschedueled 	= isReschedueledParam ;
		objectTeam 		= teamType;  
	}
    
    
	global Database.QueryLocator start(Database.BatchableContext BC){    	
        if(objectTeam == 'AccountTeamMember')   
       		Query = 'Select id From AccountTeamMember Where id in :accIds' ; 	   
        else if(objectTeam == 'OpportunityTeamMember')
       		Query = 'Select id From OpportunityTeamMember Where id in :oppIds' ;  	
        
        system.debug('--- Query ---'+Query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
    	//check how many jobs are schedueled
    	Integer nbSchedueledJobs = (Integer)[Select count() From AsyncApexJob Where JobType = 'BatchApex' and ( Status = 'Processing' or Status = 'Preparing' ) ];
    	
    	if(isReschedueled && nbSchedueledJobs>=5 ){
    		//re-schedule deletion in 15 minutes
		    Datetime sysTime = System.now().addSeconds( 900 );		
		    String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
		
		    System.schedule( objectTeam+' Deletion ' + sysTime, chronExpression, new SCH_BatchDeletionAccOppTM(accIds,oppIds, true,objectTeam )  );    		    		
    	}
    	else{
    		if(objectTeam == 'AccountTeamMember'){
    			list<AccountTeamMember> accTMs = scope;	
	    		//deduplicate
	    		set<AccountTeamMember> setAccTMs = 	new set<AccountTeamMember>();
	    		setAccTMs.addAll(accTMs);
	    			
	    		delete 	new list<AccountTeamMember> (setAccTMs) ;	
    		}
    		else if(objectTeam == 'OpportunityTeamMember'){
    			list<OpportunityTeamMember> oppTMs = scope;	
	    		//deduplicate
	    		set<OpportunityTeamMember> setOppTMs = 	new set<OpportunityTeamMember>();
	    		setOppTMs.addAll(oppTMs);
	    			
	    		delete 	new list<OpportunityTeamMember> (setOppTMs) ;	
    		}    		 
    	} 
    	
    	
        
    }
    
    global void finish(Database.BatchableContext BC){
    	if(objectTeam == 'AccountTeamMember'){
       		//delete opp TM
	       //check how many jobs are schedueled
	    	Integer nbSchedueledJobs = (Integer)[Select count() From AsyncApexJob Where JobType = 'BatchApex' and ( Status = 'Processing' or Status = 'Preparing' ) ];
	    	
	    	if(nbSchedueledJobs>=5 ){
	    		//re-schedule deletion in 15 minutes
			    Datetime sysTime = System.now().addSeconds( 900 );		
			    String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
			
			    System.schedule( 'OpportunityTeamMember Deletion ' + sysTime, chronExpression, new SCH_BatchDeletionAccOppTM(accIds,oppIds, true,'OpportunityTeamMember' )  );    		    		
	    	}
	    	else{
	    		Database.executeBatch(new BA01_RemoveAccOppAccess(accIds,oppIds, false, 'OpportunityTeamMember' ));   	
	    	}		
       	}
       
    }
    
}