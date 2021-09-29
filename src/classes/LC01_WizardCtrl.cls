public class LC01_WizardCtrl{
    
    @AuraEnabled
    public static integer getstep(string qliId){
        
        QuoteLineItem qli = [Select Total_Score__c, (Select Id From PM_Selected_Tubes_Configs__r where Shape__c != null OR Diameter_inches__c != null limit 1), 
                            (Select Id From PM_Selected_Dipsensing_Configs__r where Product_Hierarchy__c != null OR Engine_Name__c != null OR Product_Type__c != null OR Product_Name__c != null OR Product_Range__c != null limit 1), 
                            (Select Id From Price_recommendations__r where Lin1_Discount__c != 0 OR Lin2_Discount__c != 0 OR Lin3_Discount__c != 0 OR Max_Threshhold_Discount__c != 0 OR Min_Threshhold_Discount__c != 0 limit 1), 
                            (Select Id From PM_Review_NetPrice_per_MOQ__r where Selected__c = true limit 1) 
                            From QuoteLineItem where Id =:qliId];
        integer step = 0;        
        step = (!qli.PM_Selected_Tubes_Configs__r.isEmpty() || !qli.PM_Selected_Dipsensing_Configs__r.isEmpty())?1:step;
        step = (!qli.Price_recommendations__r.isEmpty())?2:step;
        step = (!qli.PM_Review_NetPrice_per_MOQ__r.isEmpty())?3:step;
        step = (qli.Total_Score__c == null)?0:step;
        
        return step;
    }
    
}