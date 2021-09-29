global class LC02_CalculateGamificationPoints {
    
    
    public static void calculatePoints(String badgeName){
    
        if(Test.isRunningTest()){
            calculatePointsNF(badgeName);
        }
        else{
            calculatePointsFutureCall(badgeName);
        }
        
    }
    
   
    public static void calculatePointsFutureCall(String badgeName){
    	calculatePointsNF(badgeName);
    }
    
    public static void calculatePointsNF(String badgeName){
    	Id userId = System.UserInfo.getUserId();
        Contact c = LC02_gamificationController.getContactInfos(userId);
        
        
        List<Badge__c> b = [select id, Badge_family__c,Name, Points_to_win__c,	Points_By_Action__c,Image__c , Image_url__c from Badge__c where Name =:badgeName];
        User_badge__c ubToEdit = new User_badge__c();
        
        if(c != null && b.size()>0){

            List<User_badge__c> ubToEditlist = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: c.Id];            

            if(ubToEditlist.size() > 0){
                ubToEdit = ubToEditlist[0];
                ubToEdit.won_points__c = ubToEdit.won_points__c + Integer.valueOf(b[0].Points_By_Action__c);
            }
            else{
                ubToEdit = new User_badge__c(contact__c = c.Id, Badge__c = b[0].id, won_points__c = Integer.valueOf(b[0].Points_By_Action__c));
            }

            upsert ubToedit;
            
        }
        
    }

}