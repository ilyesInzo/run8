@isTest(SeeAllData=true)
public class PlantUserAccOppTeam_Batch_RecapTest {
    
    
    static testMethod void testMethod2() 
    {
        
        Test.startTest();
        
            ID jobID = Database.executeBatch(new PlantUserAccOppTeam_Batch_RecapHistory() , 200);
                
        Test.stopTest();
    }
    
    
}