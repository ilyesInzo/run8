/**
 * description : Test Class of LC02_CalculateGamificationPoints Class
 * @author Achraf LAMZABI
 * @version 1.0 - Initiale
 */
@isTest
public class LC02_CalculateGamificationPoints_Test {

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
        
        		Badge__c b1 = new Badge__c(Name='Account Creation',
                                          Badge_family__c='Account',
                                          Points_to_win__c='150',
                                           Points_By_Action__c ='5'
                                          );
        		Badge__c b2 = new Badge__c(Name='Contact Creation',
                                          Badge_family__c='Contact',
                                          Points_to_win__c='150',
                                          Points_By_Action__c ='25'
                                          );
        		insert new List<Badge__c>{b1,b2};

    }

    
     
    public testmethod static void calculatePoints(){      
        

        test.startTest();
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        LC02_CalculateGamificationPoints.calculatePoints('Contact Creation');
        
        List<Badge__c> b = [select id, Badge_family__c,Name, Points_to_win__c,	Points_By_Action__c,Image__c , Image_url__c from Badge__c where Name = 'Contact Creation'];
        if(b.size()>0){
            
        	List<User_badge__c> ubToEditlist = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: result.Id];            
	
        	System.assert(ubToEditlist.size()>0 && ubToEditlist[0].won_points__c == 25,ubToEditlist);
            
            LC02_CalculateGamificationPoints.calculatePoints('Contact Creation');
			
            List<User_badge__c> ubToEditlist2 = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: result.Id];            
	
        	System.assert(ubToEditlist2.size()>0 && ubToEditlist2[0].won_points__c == 50,ubToEditlist2);
            
            
        }
        test.stopTest();
        
    }
	
	 
     public testmethod static void calculateGameEvent(){      
        
        test.startTest();
        
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        
        Event t = new Event();
            	t.Subject = 'new';
        		t.StartDateTime = datetime.now();
        		t.EndDateTime = datetime.now().addHours(3);
        		t.Type = 'Call';
        		insert t;
        
        List<Badge__c> b = [select id, Badge_family__c,Name, Points_to_win__c,	Points_By_Action__c,Image__c , Image_url__c from Badge__c where Name =: AP00_UtilityConstants.BADGE_EVENT_CREATION];
        if(b.size()>0){
            
        	List<User_badge__c> ubToEditlist = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: result.Id];            
	
        	System.assert(ubToEditlist.size()>0 && ubToEditlist[0].won_points__c == 25,ubToEditlist);
        }
        
        test.stopTest();
        
    }
    
        public testmethod static void calculateGameComment(){      
        

        test.startTest();
        
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        
        FeedItem post = new FeedItem();
            post.ParentId = UserInfo.getUserId();
            post.Body = 'body';
        insert post;

        FeedComment comm = new FeedComment();
        comm.FeedItemId = post.id;
        comm.CommentBody = 'OO'; 
        insert comm;


        
        List<Badge__c> b = [select id, Badge_family__c,Name, Points_to_win__c,	Points_By_Action__c,Image__c , Image_url__c from Badge__c where Name =: AP00_UtilityConstants.BADGE_CHATTER_POST_COMMENT];
        if(b.size()>0){
            
        	List<User_badge__c> ubToEditlist = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: result.Id];            
	
        	System.assert(ubToEditlist.size()>0 && ubToEditlist[0].won_points__c == 50,ubToEditlist);
        }
        
        test.stopTest();
        
    }
    
}