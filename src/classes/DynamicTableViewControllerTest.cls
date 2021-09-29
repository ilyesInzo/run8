@isTest
public class DynamicTableViewControllerTest {

	@TestSetup
	public static void MyJDD() {
        
		/*Dynamic_List_View_Config__mdt mdt = new Dynamic_List_View_Config__mdt(MasterLabel = 'List Manager 1',
                                                                              DeveloperName = 'List Manager 1',
                                                                              ObjectName__c = 'SalesTeam__c', 
																		      UniqueKeyObject__c = 'ListManager01', 
																		      ColumnsList__c = 'ObjectnotNull');*/
        //creer des sales teams
		User testUser = [select id from user where  KAM__c= true and manager__c = true and profile.name='SALES - KAM' AND Matricule_ADS__c != null limit 1];
		Sales_Team__c salesTeam = new Sales_Team__c(Name= 'Test Sales Team test', kam__c=testUser.id , Valid_To__c = Date.today());
		insert salesTeam;
        
	}

	@istest
	public static void getFieldSetDescriptionTest() {
		Test.startTest();
		String result = DynamicTableViewController.getFieldSetDescription('SalesTeam__c', 'ListManager01');
		System.assert(result != Null, result);
		Test.stopTest();
	}
    
    @istest
    public static void getsObjectsRecordTest(){
        Test.startTest();
        String result=DynamicTableViewController.getsObjectsRecord('Sales_Team__c', 'and Kam__c != Null','["Name","Sales_Team_Key__c","Id"]','ListManager01');
		System.assert(result != '', result);
        //
        Test.stopTest();
        
    }
    
        @istest
    public static void getsObjectsRecordTest2(){
        Test.startTest();
        String result=DynamicTableViewController.getsObjectsRecord('Sales_Team__c', 'and Kam__c != Null','id','ListManager01');
		System.assert(result != '', result);
        //
        Test.stopTest();
        
    }
    
    @istest
    public static void updateRecordsListTest(){
         Test.startTest();
        
       /* //1_modification de la salesteam   */
		
        
        Sales_Team__c salesteam = [select id,name,kam__c,Valid_To__c from Sales_Team__c where name='Test Sales Team test' limit 1];
        salesteam.kam__c = null;
        
        //2_serialization de la salesteam
        
        String resultFinal;
        Map<String,Sales_Team__c> st = new Map<String,Sales_Team__c>();
        st.put(salesteam.id,salesteam);
        
        if(st!=null){
             resultFinal = JSON.serialize(st);}
      
       //3_Appel de la fonction
        DynamicTableViewController.updateRecordsList(resultFinal);
        
       //4_Requet SalesTeam 
        Sales_Team__c salesteam2 = [select id,name,kam__c,Valid_To__c from Sales_Team__c where name='Test Sales Team test' limit 1];
	   
        System.assert(salesteam2.kam__c == null, salesteam2.kam__c);
        
        Test.stopTest();        
    }
}