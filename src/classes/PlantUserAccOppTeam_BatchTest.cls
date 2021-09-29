@isTest(SeeAllData=true)
public class PlantUserAccOppTeam_BatchTest {

    
    static testMethod void testMethod1() 
    {
   
        Test.startTest();

            PlantUserAccOppTeam_Batch obj = new PlantUserAccOppTeam_Batch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
}