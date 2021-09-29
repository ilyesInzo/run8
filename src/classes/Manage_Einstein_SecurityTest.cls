@isTest
public class Manage_Einstein_SecurityTest
{
	@testSetup 
    public static void init()
	{
       
        Profile p2=[select id,Name from Profile where Name='Marketing'];
		Profile p1=[select id,Name from Profile where Name='Plant'];

        User uPlant1=TestFactory.newUser('PlantUser1','Einstein', 'Plant',false,false, false,false,03111992, p1.id);
		User uPlant2=TestFactory.newUser('PlantUser2','Einstein', 'Plant',false,false, false,false,01111992, p1.id);

		User uSeg1=TestFactory.newUser('SubSegUser1','Einstein', 'Marketing',false,false, false,false,24101994, p2.id);
		User uSeg2=TestFactory.newUser('SubSegUser2','Einstein', 'Marketing',false,false, false,false,26101994, p2.id);

        List<User> listUsers=new List<User> {uPlant1,uPlant2,uSeg1,uSeg2};
        insert listUsers;

        //---need to create  Products
		Set<String> setList=new Set<String>{'Type1','Type2','Type3'};
		List<Product2> listProduct=TestFactory.newProducts(setList, 'Family1');
        insert listProduct;

        //need to create customerMangement areas
		List<Customer_Management_Area__c>  listManagArea=TestFactory.newCustomerManagementArea();
		List<Plant_and_Cluster__c> listPlantClus=TestFactory.newPlantAndCluster(listManagArea);
        insert listPlantClus;

		//---Need to create Plant SubsegmentUsers
		System.runAs(uPlant1){
             // Do code for DML other object rather than User
	    Plant_Segment_Users__c plantSeg1= TestFactory.newPlant_Segment_Users(listPlantClus.get(0),null,uPlant1,'Plant');//PLant:SF
		Plant_Segment_Users__c plantSeg2= TestFactory.newPlant_Segment_Users(listPlantClus.get(3),null,uPlant1,'Plant');//Plant:AK
		List<Plant_Segment_Users__c> listPlantSegUsers=new List<Plant_Segment_Users__c>();
        listPlantSegUsers.add(plantSeg1);
		listPlantSegUsers.add(plantSeg2);  
		insert listPlantSegUsers;
		}

		//----Need to create Sub Sugment PlantSegmentUsers
		System.runAs(uSeg1){
	    Plant_Segment_Users__c plantSeg3= TestFactory.newPlant_Segment_Users(null,listProduct.get(0),uSeg1,'Sub Segment');//Sub Seg:Type1
		Plant_Segment_Users__c plantSeg4= TestFactory.newPlant_Segment_Users(null,listProduct.get(1),uSeg1,'Sub Segment');//Sub Seg:Type2
		List<Plant_Segment_Users__c> listPlantSegUsers=new List<Plant_Segment_Users__c>();
        listPlantSegUsers.add(plantSeg3);
		listPlantSegUsers.add(plantSeg4);  
		insert listPlantSegUsers;
		}

	}

    // test method InitialLoad on Manage_Einstein_Security class.
	static testMethod void intialLoad()
	{
		User user1=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='PlantUser1' limit 1];
        user1.Plant_List__c=null;
		User user2=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='SubSegUser1' limit 1];
		user1.Product_Sub_Segment_List__c=null;
		List<User> userToUp= new List<User>{user1,user2};
		update userToUp;
		Test.startTest(); 
        //Manage_Einstein_Security.InitialLoad(1000); 
		Database.executeBatch(new Batch_Manage_SecurityEinstein());
		Test.stopTest();
        User userafter=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='PlantUser1' limit 1];
		//System.debug('UserTest ID:' +userafter.id);
		//System.debug('List Sub Test: '+userafter.Product_Sub_Segment_List__c);
		//System.debug('List Plant Test: '+userafter.Plant_List__c);
		System.assert((userafter.Plant_List__c.contains('SF')) && (userafter.Plant_List__c.contains('AK')) );
		System.assertEquals(null,userafter.Product_Sub_Segment_List__c);
		//System.debug('List SubSeg:'+);

	}
	//test case : when we create a Plant_Segment_Users__c object , field : Product_Sub_Segment_List__c or Plant_List__c should be updated.
    
	static testMethod void PlantSegUsers_Created()
	{
		User user1=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='PlantUser1' limit 1];
		Plant_and_Cluster__c plant=[select id,Plant_Code__c from Plant_and_Cluster__c where Plant_Code__c='LV'];
        Plant_Segment_Users__c plantSeg1= TestFactory.newPlant_Segment_Users(plant,null,user1,'Plant');//PLant:LV
        
		User user2=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='SubSegUser1' limit 1];
		Product2 product=[select id, Product_Sub_segment__r.Name from Product2 where Product_Sub_segment__r.Name='Type3TestTest'];
        Plant_Segment_Users__c subseg= TestFactory.newPlant_Segment_Users(null,product,user2,'Sub Segment');//Sub Seg:Type3


        
        List<Plant_Segment_Users__c> listPlantUseradded=new List<Plant_Segment_Users__c>();
		listPlantUseradded.add(plantSeg1);
        
		// create  record type : Plant 
	    Test.startTest();
		System.runAs(user1){
			insert plantSeg1;
		}
		System.runAs(user2){
			insert subseg;
		}
		Test.stopTest();
        
	    user1=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='PlantUser1' limit 1];
		//System.debug('List Plant Test: '+user1.Plant_List__c);
		//System.assert(user1.Plant_List__c.equals('AK;SF;LV'));
		user2=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='SubSegUser1' limit 1];
		//System.debug('List Sub Product Test: '+user2.Product_Sub_Segment_List__c);
		//System.assert(user2.Product_Sub_Segment_List__c.equals('test0;test1;test2'));
		
		
	}

	//test case : when we delete a Plant_Segment_Users__c object , field : Product_Sub_Segment_List__c or Plant_List__c should be updated.
    
	static testMethod void PlantSegUsers_Deleted()
	{
        
		List<Plant_Segment_Users__c> plant=[select id, Plant_and_Cluster__r.Plant_Code__c from Plant_Segment_Users__c where Plant_and_Cluster__r.Plant_Code__c IN ('AK','SF')];
        List<Plant_Segment_Users__c> subSegment=[select id, Product__r.ProductCode from Plant_Segment_Users__c where Product__r.ProductCode IN ('test0','test1')];
        
		User user1=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='PlantUser1' limit 1];
		System.debug('List Plant del avant: '+user1.Plant_List__c);
		User user2=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='SubSegUser1' limit 1];
	    System.debug('List Sub Product del avant: '+user2.Product_Sub_Segment_List__c);
               
		// create  record type : Plant 
	    Test.startTest();
		System.runAs(user1){
			delete plant;
		}
		System.runAs(user2){
			delete subSegment;
		}
		Test.stopTest();
        
	    user1=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='PlantUser1' limit 1];
		System.debug('List Plant del: '+user1.Plant_List__c);
		//System.assert(user1.Plant_List__c.equals('AK;SF;LV'));
		user2=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where FirstName='SubSegUser1' limit 1];
		System.debug('List Sub Product del: '+user2.Product_Sub_Segment_List__c);
		//System.assert(user2.Product_Sub_Segment_List__c.equals('test0;test1;test2'));
		
		
	}
     
	
}