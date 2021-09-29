public class LC02_DetailRankController {
    	
        @AuraEnabled
    	public static List<WRP_01_ContactBadges>  getContactBadges(Id contactId){ 
            system.debug('ioo' + contactId);
		
        	List<Badge__c> allBadges = [select id, Badge_family__c,Name, Points_to_win__c,Image__c , Image_url__c from Badge__c];
            List<User_badge__c> ownedBadges = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c from User_badge__c where contact__c =:contactId];
            
            Map<Id,User_badge__c> ownedBadgesMap = new Map<Id,User_badge__c>();
            for(User_badge__c ub : ownedBadges){
                ownedBadgesMap.put(ub.Badge__c,ub);
            }
            
            Map<String,List<WRP_01_ContactBadges.wrapUserBadges>> mapToReturn = new Map<String,List<WRP_01_ContactBadges.wrapUserBadges>>();
            
            for(Badge__c bg : allBadges){
                
                WRP_01_ContactBadges.wrapUserBadges ubElement;
                Decimal wonPoints = 0;

                if(ownedBadgesMap.containsKey(bg.id)){
                    wonPoints = ownedBadgesMap.get(bg.id).won_points__c;
                }
                
                ubElement = new WRP_01_ContactBadges.wrapUserBadges(contactId,bg.id,bg.Name,bg.Image_url__c,wonPoints,bg.Points_to_win__c,bg.Image__c);

                
                if(mapToReturn.containsKey(bg.Badge_family__c)){
                    mapToReturn.get(bg.Badge_family__c).add(ubElement);
                }
                else{
                    mapToReturn.put(bg.Badge_family__c, new List<WRP_01_ContactBadges.wrapUserBadges>{ubElement});
                }
                
            }   
            
            List<WRP_01_ContactBadges> listWrpToReturn = new List<WRP_01_ContactBadges>();
            for(String family : mapToReturn.keySet()){
                listWrpToReturn.add(new WRP_01_ContactBadges(family,mapToReturn.get(family)));
            }
                
            System.debug('OOP + ' +  mapToReturn);
            System.debug('OOP2 + ' +  listWrpToReturn);
            
            return listWrpToReturn;
            
    }
    
     @AuraEnabled
    public static List<User_badge__c> getlistRankingByBadge (String badgeName , String contactId){
        System.debug('AAA1 ' +  badgeName);
        System.debug('AAA2 ' +  contactId);
        
        
        List<User_badge__c> listToProcess = [select id, Name , Contact__c , Contact__r.Name , Badge__c,Badge__r.Name, won_points__c from User_badge__c
                                           	where Badge__r.Name =: badgeName Order by won_points__c desc];
        System.debug('AAA3 ' +  listToProcess);
        
        Integer MyRank;
        Integer x = 0 ;
        Integer y = 0;
        Integer sizeList = 10;
        List<User_badge__c> listToreturn = new List<User_badge__c>();
        
        if(listToProcess.size() < 10 ) {sizeList = listToProcess.size(); }
        System.debug('listsize = ' + listToProcess.size());
        
        while(x < listToProcess.size() || y < sizeList){  
            System.debug('x = ' + x);
            System.debug('y = ' + y);
            
            if(y <  10 ) {listToreturn.add(listToProcess[y]); y++;}
            if(x < listToProcess.size()){
            	if(listToProcess[x].contact__c == contactId){ MyRank = x+1; x = listToProcess.size(); System.debug('mayRank = ' + MyRank);}
            	else{ x++;}    
            }
        }
        
        if(x > y && x != 0 && MyRank > y){
            listToProcess[x-1].Badge__r.Name = String.ValueOf(MyRank);
            listToreturn.add(listToProcess[x-1]);
        }
        System.debug('AAA4 ' +  listToreturn);
        return listToreturn;
    }
    
}