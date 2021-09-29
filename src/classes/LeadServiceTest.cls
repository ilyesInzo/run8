/**
* Test class of LeadService
*
* @author MDK
* @date 09/10/2017
* @description The aim of this class is to test :
*    - all LeadService methods
*	
*/
@isTest
public class LeadServiceTest {

    @testSetup 
    private static void init() {

        insert TestFactory.newCountry();

        User u1 = TestFactory.newUser('SALES - KAM', 1234);
        insert u1;

        User u2 = TestFactory.newUser('SALES - KAM', 4321);
        insert u2;

        insert TestFactory.newUser('System Administrator', 1);

        Lead lead1 = TestFactory.newLead('New');
        lead1.OwnerId = u1.Id;
        lead1.Product_Line__c = 'Tube';
        insert lead1;
               
        Lead lead2 = TestFactory.newLead('Active');
        lead2.OwnerId = u2.Id;
        lead2.Product_Line__c = 'Tube';
        insert lead2;
        
        //Create Country
        Country__c frCountry = [
	    			Select Id
	    			From Country__c
	    			Where Country_Code__c = 'FR' 
	    		];
        
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
        
        Badge__c b1 = new Badge__c(Name= AP00_UtilityConstants.BADGE_LEAD_CONVERSION,
                                          Badge_family__c='Lead',
                                          Points_to_win__c='150',
                                           Points_By_Action__c ='5'
                                          );
        Badge__c b2 = new Badge__c(Name = AP00_UtilityConstants.BADGE_LEAD_UPDATE,
                                          Badge_family__c='Lead',
                                          Points_to_win__c='150',
                                          Points_By_Action__c ='25'
                                          );
        		insert new List<Badge__c>{b1,b2};
    }

    /**
     * @description 
     * @param 
     * @return 
     */
    @isTest
    static void assignForWebSiteTest(){

    	User kamUser = [
    		Select Id, FirstName
    		From User
    		Where Matricule_ADS__c = '1234'
    	];

    	User admUser = [
    		Select Id, FirstName
    		From User
    		Where Matricule_ADS__c = '1'
    	];    	

    	System.debug(LoggingLevel.ERROR,'user = '+user.FirstName);

    	Test.startTest();

    		System.runAs(kamUser) {

	    		Country__c countryMN = [
	    			Select Id
	    			From Country__c
	    			Where Country_Code__c = 'MN' 
	    		];

	    		Country__c countryIL = [
	    			Select Id
	    			From Country__c
	    			Where Country_Code__c = 'IL' 
	    		];
        		
        		insert TestFactory.newLead('New','WebSite', countryMN.Id, 'Tube');
        		insert TestFactory.newLead('New','Other', countryMN.Id, 'Tube');
        		insert TestFactory.newLead('New','WebSite', countryIL.Id, 'Tube');

        	}

        	// Need to be admin to query all Leads
        	System.runAs(admUser) {

	    		List<Lead> lead1 = [
	    			Select OwnerId,Owner.Name
	    			From Lead
                    Where Product_Line__c = 'Tube' AND Tech_Country_Code__c='MN' and LeadSource ='WebSite'
	    		];
				
				List<Lead> lead2 = [
	    			Select OwnerId
	    			From Lead
                    Where Product_Line__c = 'Tube' AND Tech_Country_Code__c='MN' and LeadSource ='Other'
	    		];
	    		
	    		List<Lead> lead3 = [
	    			Select OwnerId
	    			From Lead
                    Where Product_Line__c = 'Tube' AND Tech_Country_Code__c='IL' and LeadSource ='WebSite'
	    		];
				
				// For the MN country code and Tube product line the lead should be assigned to the same user
	    		//System.assertEquals(lead1[0].OwnerId, kamUser.Id);
	    		//System.assertEquals(lead2[0].OwnerId, kamUser.Id);
	    		// For the IL country code and Tube product line the lead should be assigned to another user
	    		System.assertNotEquals(lead3[0].OwnerId, kamUser.Id);
	    		//System.assertEquals(lead3[0].OwnerId, kamUser.Id);
    		}

        Test.stopTest();

    }

    /**
     * @description 
     * @param 
     * @return 
     */
    @isTest
    static void alertlead() {

        List<Lead> leads = [
            Select Status,LastName,Email,Company,OwnerId 
            From Lead
        ];

        List<User> users = [
            Select Id, FirstName, Matricule_ADS__c
            From User
        ];

        Map<Object,SObject> userIdsByMatricule = SObjectUtils.toMap(users,'Matricule_ADS__c');
        
        LeadService.alertlead(leads);        
        
        Test.startTest();        
             BA01_Lead_Reminder batchlr = new BA01_Lead_Reminder();
             batchlr.query = 'select Id, OwnerId, Status from Lead';             
             Database.executeBatch(batchlr);
        Test.stopTest();

        List<Task> tasks = [
            Select Subject,Priority,Status,WhoId,OwnerId
            From Task
            Where WhoId In :leads
        ];

        for (Task tsk : tasks) {
            System.assertEquals('Normal',tsk.Priority);
            System.assertEquals('Open',tsk.Status);
            if (userIdsByMatricule.get('1234').Id == tsk.OwnerId) {
                System.assertEquals('New Lead : 1 week',tsk.Subject);
            } else if (userIdsByMatricule.get('4321').Id == tsk.OwnerId) {
                System.assertEquals('Active Lead : 2 weeks',tsk.Subject);
            }          
        }
        
    }

   
    @isTest
    private static void testCharCheckerForLeadTriggerPositive(){

        Lead lead = new Lead(
            Status = 'New',  
            LastName = 'Test',  
            Email = 'test@gmail.com', 
            Company = 'TEST'
        );
       
        
        Test.startTest();           
            Boolean triggersError = false;
            try{
                insert lead;
            }catch(Exception e){
                triggersError = true;   
            }      
        Test.stopTest();
        
        //asserts
        system.assertEquals(false,triggersError);       
    }

    @isTest
    private static void testCharCheckerForLeadTriggerNagative(){
        
        Lead lead = new Lead(
            Status = 'New',  
            LastName = 'Test 饿饿',  
            Email = 'test@gmail.com', 
            Company = 'TEST' 
        );      
        
        Test.startTest();           
            Boolean triggersError = false;
            try{
                insert lead;
            }catch(Exception e){
                triggersError = true;   
            }      
        Test.stopTest();
        
        //asserts
        system.assertEquals(true,triggersError);        
    }
    
    
      public testmethod static void GameCalculationConvertedLead(){      
        

        test.startTest();
        
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        System.debug('contact='+result);
        Lead ld = [select id, FirstName,LastName from Lead limit 1];
        ld.FirstName = 'John';
        update ld;
          
        List<Badge__c> b = [select id, Badge_family__c,Name, Points_to_win__c,	Points_By_Action__c,Image__c , Image_url__c from Badge__c where Name =: AP00_UtilityConstants.BADGE_LEAD_UPDATE];
         System.debug('badge='+b);
         if(b.size()>0){
            
        	List<User_badge__c> ubToEditlist = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: result.Id];            
	
        	System.assert(ubToEditlist.size()>0 && ubToEditlist[0].won_points__c == 25,ubToEditlist);
        }
        
        test.stopTest();
        
    }
    
    public testmethod static void fillCountryLoockupTest(){      
        

        test.startTest();
        
 		Lead lead = new Lead(
            Status = 'New',  
            LastName = 'Test',  
            Email = 'test@gmail.com', 
            Company = 'TESTCountryCode',
            Tech_CountryCodePardot__c = 'FR'
        );
        
        insert lead;
        
        List<Lead> result = [select id,Company,Country__c from Lead where Company = 'TESTCountryCode'];
        
        System.assert(result.size()>0 && result[0].Country__c != null);
        
        test.stopTest();
        
    }

}