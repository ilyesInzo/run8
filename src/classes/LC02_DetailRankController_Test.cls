/**
 * description : Test Class of LC02_DetailRankController Class
 * @author Achraf LAMZABI
 * @version 1.0 - Initiale
 */
@isTest
public class LC02_DetailRankController_Test {
      
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
        		Badge__c b3 = new Badge__c(Name='Contact Update',
                                          Badge_family__c='Contact',
                                          Points_to_win__c='150',
                                          Points_By_Action__c ='25'
                                          );
        		insert new List<Badge__c>{b1,b2,b3};

    }

    
     
    public testmethod static void getContactBadges(){      
        

        test.startTest();
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        List<WRP_01_ContactBadges> wrp = LC02_DetailRankController.getContactBadges(result.id);
        
        System.assert(wrp.size()>0,wrp);
        
        test.stopTest();
        
    }
    
     public testmethod static void getContactBadges2(){      
        

        test.startTest();
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        LC02_CalculateGamificationPoints.calculatePoints('Contact Creation');
        LC02_CalculateGamificationPoints.calculatePoints('Contact Update');
        List<WRP_01_ContactBadges> wrp = LC02_DetailRankController.getContactBadges(result.id);
        
        System.assert(wrp.size()>0,wrp);
        
        test.stopTest();
        
    }
    
    public testmethod static void getlistRankingByBadge(){      
        

        test.startTest();
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        LC02_CalculateGamificationPoints.calculatePoints('Contact Creation');
        LC02_CalculateGamificationPoints.calculatePoints('Contact Update');
        List<User_badge__c> wrp = LC02_DetailRankController.getlistRankingByBadge('Contact Creation',result.id);
        
        System.assert(wrp.size()>0,wrp);
        
        test.stopTest();
        
    }

}