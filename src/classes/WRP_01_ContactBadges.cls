public class WRP_01_ContactBadges {
    
    	@AuraEnabled
		public String familyBadge {get; set;}
    	@AuraEnabled
        public List<wrapUserBadges> userbadges {get; set;}
 
        public WRP_01_ContactBadges(String family,List<wrapUserBadges> badgesList) {
            familyBadge = family;
            userbadges = badgesList;
        }
    
    	public class wrapUserBadges {
            @AuraEnabled
            public String contactId {get; set;}
            @AuraEnabled
            public String badgeId {get; set;}
            @AuraEnabled
            public String badgeName {get; set;}
            @AuraEnabled
            public String badgeUrl {get; set;}
            @AuraEnabled
            public Decimal wonPoints {get; set;}
            @AuraEnabled
            public String pointsToWin {get; set;}
            @AuraEnabled
            public String imageBadge {get; set;}
            
            public wrapUserBadges(String icontactId,String ibadgeId,String ibadgeName,String ibadgeUrl,Decimal iwonPoints,String ipointsToWin,String iimageBadge) {
                contactId = icontactId;
                badgeId = ibadgeId;
                badgeName = ibadgeName;
                badgeUrl = ibadgeUrl;
                wonPoints = iwonPoints;
                pointsToWin = ipointsToWin;
                imageBadge = iimageBadge;
            }
    	}
}