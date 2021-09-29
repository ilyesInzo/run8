public class ObjectifLineService {
	private static ObjectifLineService instance = null;
    
  	//private ObjectifLineService() {}
    
    public static void addObjectifKam(List<Objective_Lines__c> objectifLines){
    		
        Set<Id> userId = new Set<Id>();
        Set<Id> accountId = new Set<Id>();
        
        for(Objective_Lines__c obL:objectifLines){    
            userId.add(obL.Kam__c);
            accountId.add(obl.Account__c);
        }
        
        Map<id,Account> mapAccounts = new Map<Id,Account>([select id,name,Customer_Ranking__c from Account where id in:accountId]);
        
        List<KAM_Objectives__c> kamObjs = [select id,Name,OwnerId from KAM_Objectives__c where OwnerId in : userId]; 
    	
        Map<Id,Id> userToKamObjectif = new Map<Id,Id>();
        
        for(KAM_Objectives__c kamObj : kamObjs ){
            userToKamObjectif.put(kamObj.OwnerId,kamObj.Id);
        }
        
        for(Objective_Lines__c obL:objectifLines){
            
            obl.Customer_Ranking__c = mapAccounts.get(obl.Account__c).Customer_Ranking__c;
            
            if(userToKamObjectif.containsKey(obl.Kam__c)){
            	obl.KAM_Objective__c = userToKamObjectif.get(obl.Kam__c);
            }
            else{
                //obl.addError('the Objectif Kam is Missing');
            }
        }
        
    }
    
    
    public static void updateNumberOfClient(List<KAM_Objectives__c> kamObjectifs){
        
        Set<Id> usersId = new Set<Id>();
        
        for(KAM_Objectives__c ko : kamObjectifs ){
            usersId.add(ko.OwnerId);
        }
        
        List<AccountTeamMember> atmList = [select id, AccountId,userId, Account.Customer_Ranking__c from AccountTeamMember where userId in : usersId];
        Map<Id,List<AccountTeamMember>> mapAtm = new Map<Id,List<AccountTeamMember>>();
        
        for(AccountTeamMember atmElement:atmList){
            
            if(mapAtm.containsKey(atmElement.userId)){
                mapAtm.get(atmElement.userId).add(atmElement);
            }
            else {
                mapAtm.put(atmElement.userId,new List<AccountTeamMember>{atmElement});
            }
        }
        
        Map<id,wrapAccountRanking> mapWrp = new Map<id,wrapAccountRanking>();
        
        for(Id userIdElement: mapAtm.keySet()){
            
            Set<Id> gold = new Set<Id>();
            Set<Id> bronze = new Set<Id>();
            Set<Id> platinium = new Set<Id>();
            Set<Id> silver = new Set<Id>();
            
            for(AccountTeamMember atmElement :mapAtm.get(userIdElement)){
                
                if (atmElement.Account.Customer_Ranking__c == 'Gold'){
                    gold.add(atmElement.AccountId);
                }
                else if (atmElement.Account.Customer_Ranking__c == 'Platinum'){
                	platinium.add(atmElement.AccountId);
                }
                else if (atmElement.Account.Customer_Ranking__c == 'Silver'){
                	silver.add(atmElement.AccountId);
                }
                else if (atmElement.Account.Customer_Ranking__c == 'Bronze'){
                	bronze.add(atmElement.AccountId);
                }
            }
            
            mapWrp.put(userIdElement,new wrapAccountRanking(gold,silver,bronze,platinium));
            
        }
        system.debug(mapWrp);
        for(KAM_Objectives__c kamObj: kamObjectifs){
            system.debug(mapWrp.get(kamObj.OwnerId));
            system.debug(kamObj.OwnerId);
            if(mapWrp.containskey(kamObj.OwnerId)){
                kamObj.Number_of_Gold_clients__c = mapWrp.get(kamObj.OwnerId).gold.size();
                kamObj.Number_of_Platinum_clients__c = mapWrp.get(kamObj.OwnerId).platinium.size();
                kamObj.Number_of_Silver_clients__c = mapWrp.get(kamObj.OwnerId).silver.size();
                kamObj.Number_of_Bronze_clients__c = mapWrp.get(kamObj.OwnerId).bronze.size();
            }
        }
        
        update kamObjectifs;
        
    }
    
    public class wrapAccountRanking {
            
            public Set<Id> gold {get; set;}
           	public Set<Id> silver {get; set;}
            public Set<Id> bronze {get; set;}
        	public Set<Id> platinium {get; set;}
        
            public wrapAccountRanking(Set<Id> igold,Set<Id> isilver,Set<Id> ibronze,Set<Id> iplatinium) {
                gold = igold;
                silver = isilver;
                bronze = ibronze;
                platinium = iplatinium;
  
            }
    	}
}