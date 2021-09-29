global with sharing class SCH_BatchDeletionAccOppTM implements Schedulable {
	public Set<ID> accIds;
	public Set<ID> oppIds;
	public Boolean isReschedueled ;
	public String objectTeam ;
    
    //contructor
    global SCH_BatchDeletionAccOppTM(Set<ID> idAccMembersToDelete, Set<ID> idOppMembersToDelete, Boolean isReschedueledParam,String teamType) {
		accIds 			= new set<id>();
		accIds			= idAccMembersToDelete;
		
		oppIds 			= new set<id>();
		oppIds			= idOppMembersToDelete;
		
		isReschedueled 	= isReschedueledParam ;
		objectTeam 		= teamType;
	}
    
    global void execute(SchedulableContext sc) {
    	
        //Plant User Account Team Members
        Database.executeBatch(new BA01_RemoveAccOppAccess(accIds,oppIds,isReschedueled, objectTeam));        
        
    }
    
}