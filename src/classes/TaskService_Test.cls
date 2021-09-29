/**
 * description : Test Class of TaskService Class
 * @author Achraf LAMZABI
 * @version 1.0 - Initiale
 */
@isTest
public class TaskService_Test {

    @testSetup 
    private static void init() {
        		
        		//Create Country
        		Country__c frCountry = TestFactory.getFrance();
            	insert frCountry;
    
                //Create Distribution Channel
                Distribution_Channel__c distCountry1 = TestFactory.newDistributionChannel();
                insert distCountry1;
                
                //Create Sales Area
                Sales_Area__c salesArea = TestFactory.newSalesArea();
                insert salesArea;
    
                // Create a State
                State__c state = TestFactory.newState('FRANCE','FR');
            	state.Country__c = frCountry.id;
                insert state;
                
                //Create Test Accounts
    
                Account acc = TestFactory.newAccount(frCountry.Id,distCountry1.Id,salesArea.Id, state.Id,'VAT1');
            	acc.Street__c = 'Cartault';
        		acc.Name = AP00_UtilityConstants.ACCOUNT_GAMIFICATION_ACCOUNT_NAME;
                insert acc; 
        
        		Badge__c b1 = new Badge__c(Name= AP00_UtilityConstants.BADGE_TASK_CREATION,
                                          Badge_family__c='Task',
                                          Points_to_win__c='150',
                                           Points_By_Action__c ='5'
                                          );
        		Badge__c b2 = new Badge__c(Name = AP00_UtilityConstants.BADGE_LOG_CALL,
                                          Badge_family__c='Task',
                                          Points_to_win__c='150',
                                          Points_By_Action__c ='25'
                                          );
        		insert new List<Badge__c>{b1,b2};

    }

    
     
    public testmethod static void calculateGame(){      
        

        test.startTest();
        
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        
        Task t = new Task();
            	t.Subject = 'new';
            	t.Priority = 'Normal';
            	t.Status = 'Open';
        		t.TaskSubtype = 'Call';
        		insert t;
        
        List<Badge__c> b = [select id, Badge_family__c,Name, Points_to_win__c,	Points_By_Action__c,Image__c , Image_url__c from Badge__c where Name =: AP00_UtilityConstants.BADGE_LOG_CALL];
        if(b.size()>0){
            
        	List<User_badge__c> ubToEditlist = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: result.Id];            
	
        	System.assert(ubToEditlist.size()>0 && ubToEditlist[0].won_points__c == 25,ubToEditlist);
        }
        
        test.stopTest();
        
    }
    
    public testmethod static void calculateGame2(){      
        

        test.startTest();
        
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        
        Task t = new Task();
            	t.Subject = 'new';
            	t.Priority = 'Normal';
            	t.Status = 'Open';
        		t.TaskSubtype = 'Task';
        		insert t;
        
        List<Badge__c> b = [select id, Badge_family__c,Name, Points_to_win__c,	Points_By_Action__c,Image__c , Image_url__c from Badge__c where Name =: AP00_UtilityConstants.BADGE_TASK_CREATION];
        if(b.size()>0){
            
        	List<User_badge__c> ubToEditlist = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: result.Id];            
	
        	System.assert(ubToEditlist.size()>0 && ubToEditlist[0].won_points__c == 5,ubToEditlist);
        }
        
        test.stopTest();
        
    }
    
    public testmethod static void EditTasksCountInObjectifLine_Test(){ 
        
     	// Create User For Test 
        User us = TestFactory.newUser('test','user','SALES - KAM', true, true, true, true, 123);
        User us2 = TestFactory.newUser('test2','user2','SALES - KAM', true, true, true, true, 124);
        
        insert new List<User>{us,us2};
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = [select id , name from Account limit 1];
		
        Opportunity opp = TestFactory.newOpportunity('Opp2','Qualification',null,null,acc.Id);
        insert opp;
        
		test.startTest();
        
        KAM_Objectives__c kamObjectif = new KAM_Objectives__c(
        		Name = 'Test Objectif',
        		Year__c = '2020',
        		OwnerId = us.id );
        
        insert kamObjectif;
        
        Task t = new Task();
            	t.Subject = 'Call';
            	t.Priority = 'Normal';
            	t.Status = 'Open';
        		t.TaskSubtype = 'Call';
        		t.WhatId = acc.id;
        		t.OwnerId = us.id;
        
        Task t2 = new Task();
            	t2.Subject = 'Call';
            	t2.Priority = 'Normal';
            	t2.Status = 'Open';
        		t2.TaskSubtype = 'Call';
        		t2.WhatId = opp.id;
        		t2.OwnerId = us.id;
        
        insert t;
        insert t2;
        
        List<Objective_Lines__c> result = [select id,Account__c,Number_of_tasks__c,Type_Of_task__c,KAM__c,KAM_Objective__c from Objective_Lines__c where Account__c =: acc.id ];
        
        System.assert(result.size()>0);
        
        TaskService.EditTaskCountInObjectifLineFuture(new set<Id> {result[0].id} );
        
        List<Objective_Lines__c> result3 = [select id,Account__c,Number_of_tasks__c,Type_Of_task__c,KAM__c,KAM_Objective__c from Objective_Lines__c where Account__c =: acc.id ];

        
        System.assert(result3.size()>0 );
        // && result3[0].Number_of_tasks__c == 2,'-->' + result3[0].Number_of_tasks__c);
        
        t2.OwnerId = us2.id;
        update t2;
        
        List<Objective_Lines__c> result2 = [select id,Account__c,Number_of_tasks__c,Type_Of_task__c,KAM__c,KAM_Objective__c from Objective_Lines__c where Account__c =: acc.id ];
        
        System.assert(result2.size()>0); 
                      //&& result2[0].Number_of_tasks__c == 1,result2[0].Number_of_tasks__c);
        
        
        
        test.stopTest();
        
    }
    
}