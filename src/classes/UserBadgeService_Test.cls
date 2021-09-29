/**
 * description : Test Class of UserBadgeService Class
 * @author Achraf LAMZABI
 * @version 1.0 - Initiale
 */
@isTest
public class UserBadgeService_Test {

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

    
     
    public testmethod static void winBadge(){      
        

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
            
            ubToEditlist[0].won_points__c = 160;
            update ubToEditlist[0];
            
            List<User_badge__c> ubToEditlist2 = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,won__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: result.Id];            
			
        	System.assert(ubToEditlist2.size()>0 && ubToEditlist2[0].won__c == true,ubToEditlist2);
            
            
        }
        
        test.stopTest();
        
    }
    
   public testmethod static void winBadge2(){      
        

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
            
            ubToEditlist[0].won_points__c = 100;
            update ubToEditlist[0];
            
            List<User_badge__c> ubToEditlist2 = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,won__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: result.Id];            
			
        	System.assert(ubToEditlist2.size()>0 && ubToEditlist2[0].won__c == false,ubToEditlist2);
            
            
        }
        
        test.stopTest();
        
    }    
    
}