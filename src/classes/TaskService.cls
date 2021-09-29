global class TaskService {
    
  private static TaskService instance = null;
    
  private TaskService() {}
  
    public static void calculateGame(List<Task> tasks){
   
        List<Task> taskList = new List<Task>();
        List<Task> callLogList = new List<Task>();
        
        for(Task t : tasks){
            if(t.TaskSubtype == 'Call'){
                callLogList.add(t);
            }
            else if(t.TaskSubtype == 'Task'){
                taskList.add(t);
            }
        }
        
        if(taskList.size()>0){LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_TASK_CREATION);}
        if(callLogList.size()>0){LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_LOG_CALL);}
      
  }
    

    /**
 * description : Create an Objectif Line for Tasks and Link Tasks to Objectif Lines
 * @author Achraf LAMZABI
 * @version 1.0 - Initiale
 */
    
public static void createObjectifLine(List<Task> tasks,Map<id,Task> oldTasks){    
 	
    List<Task> taskToProcess = new List<Task>();
    for(Task tt:tasks){
        if(tt.OwnerId != oldTasks.get(tt.id).OwnerId){
            taskToProcess.add(tt);
        }
    }
    
    if(taskToProcess.size()>0){
     	 createObjectifLine(taskToProcess); 
        
    }  
}

/**
 * description : Create an Objectif Line for Tasks and Link Tasks to Objectif Lines
 * @author Achraf LAMZABI
 * @version 1.0 - Initiale
 */

    
      public static void createObjectifLine(List<Task> tasks){

    // look for Objectives by user , Account 

    Set<Id> accountsId = new Set<Id>();
    Set<Id> opportunitiesId = new Set<Id>();
    Set<Id> usersId = new Set<Id>();
	//List<Task> tasks = new List<Task>();
    /*List<String> listValues = new List<String>{'Call','Email','Meeting'};     
        
   	for(Task tt : tasksIn){
        if(listValues.contains(tt.subject)){
            tasks.add(tt);
        }
    }*/

    for(Task tt : tasks){
        
        usersId.add(tt.OwnerId);
        
        if(tt.whatid != null && String.valueof(tt.whatid).startsWith('001')){
            accountsId.add(tt.whatId);
        }
        else if(tt.whatid != null && String.valueof(tt.whatid).startsWith('006')) {
            opportunitiesId.add(tt.whatId);
        }
    }

    //Map<Id,Account> mapAccounts = new Map<Id,Account>([select id,Rank__c from Account where id in : accountsId]); 
    Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>([select id,AccountId, Account.Rank__c from Opportunity where id in : opportunitiesId]); 


    for(Opportunity opp : mapOpportunities.values()){
        accountsId.add(opp.AccountId);
    }
          


    List<Objective_lines__c> existingObjectives = [select id, Account__c,KAM__c,Type_of_task__c,customer_Ranking__c from Objective_lines__c where Account__c in : accountsId];
    List<Objective_lines__c> objectifToInsert = new List<Objective_lines__c>(); 
          
    List<KAM_Objectives__c> kamObjectives = [select id,Name,OwnerId from KAM_Objectives__c where OwnerId in:usersId];      
	Map<Id,KAM_Objectives__c> mapKamObjectives = new Map<Id,KAM_Objectives__c>();
    List<Task> TasktoComplete = new List<Task>();
          
    for(KAM_Objectives__c kamObj:kamObjectives){
        
        mapKamObjectives.put(kamObj.OwnerId,kamObj);
        
    }      
          
    for(Task tt : tasks){
        id accountt = null;
        Boolean exist = false;
        if(tt.whatid != null && String.valueof(tt.whatid).startsWith('001')){
                accountt = tt.whatId;
                //rank = mapAccounts.get(accountt).Rank__c;
        }
        else if(tt.whatid != null && String.valueof(tt.whatid).startsWith('006')){
                accountt = mapOpportunities.get(tt.whatId).AccountId;
                //rank = mapOpportunities.get(tt.whatId).Account.Rank__c;
        }
        for(Objective_lines__c eol : existingObjectives){
            if(eol.account__c == accountt && eol.Type_of_task__c == tt.Subject && eol.KAM__c == tt.OwnerId){
                exist = true;
                tt.Objective_Line__c = eol.id;
            }

        }

        if(exist == false && tt.WhatId != null){
            if(mapKamObjectives.containsKey(tt.OwnerId)){
            	Objective_lines__c obj = new Objective_lines__c(
                	Account__c = accountt,
                	Type_of_task__c =  tt.Subject,
                	KAM__c = tt.ownerId
                	);
            
            	objectifToInsert.add(obj);
                TasktoComplete.add(tt);
            }
            else {
                tt.Objective_Line__c = null;
            }
        }


    }

    insert objectifToInsert;


    for(Task tt : TasktoComplete){
        id accountt = null;
        if(tt.whatid != null && String.valueof(tt.whatid).startsWith('001')){
                accountt = tt.whatId;
                //rank = mapAccounts.get(accountt).Rank__c;
        }
        else if(tt.whatid != null && String.valueof(tt.whatid).startsWith('006')){
                accountt = mapOpportunities.get(tt.whatId).AccountId;
                //rank = mapOpportunities.get(tt.whatId).Account.Rank__c;
        }
        
        	for(Objective_lines__c obl:objectifToInsert)
        	{
			
            	if(tt.Subject == obl.Type_of_task__c && tt.ownerId == obl.KAM__c && accountt == obl.Account__c ){
                	tt.Objective_Line__c = obl.id;
            	}
        	}
        
    }

  }
   
    
   /**
 * description : Edit the number of Task related to Objectif Lines
 * @author Achraf LAMZABI
 * @version 1.0 - Initiale
 */
    
      public static void EditTasksCountInObjectifLine(List<Task> tasks){
          
		Set<Id> objectifLines = new Set<Id>();
		
          for(Task tt:tasks){
              objectifLines.add(tt.Objective_Line__c);
          }          
          if(ObjectifLines.size()>0){
			EditTaskCountInObjectifLineFuture(ObjectifLines);  
		  }
          
      } 
        
	 	
     public static void EditTaskCountInObjectifLineFuture(Set<Id> objectifLines){   
     
         List<Objective_lines__c> objLines = [select id,(select id from Tasks),(SELECT Id, Subject FROM Events),Number_of_tasks__c from Objective_lines__c where id in :objectifLines];
          
          //List<Task> taskList = new List<Task>();
          
          if(objLines.size()>0){
          	List<Task> taskList = [select id,Objective_Line__c from Task where Objective_Line__c in : objectifLines];    
          
          
          Map<Id,Set<Id>> MapObjLTask = new Map<Id,Set<Id>>();
          
          For(Task tt : taskList){
              
              if(MapObjLTask.containsKey(tt.Objective_Line__c)){
                  MapObjLTask.get(tt.Objective_Line__c).add(tt.id);
              }
              else{
                  MapObjLTask.put(tt.Objective_Line__c,new Set<Id>{tt.id});
              }
          }
          
          for(Objective_lines__c obl :objLines ){
              system.debug(obl);
              
              obl.Number_of_tasks__c = MapObjLTask.ContainsKey(obl.id) ? MapObjLTask.get(obl.id).size() : 0;  
          }
          
          	update objLines;
         }
      }     
          
  
    
}