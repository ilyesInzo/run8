/**
 * description : Test Class of WRP_01_ContactBadges Class
 * @author Achraf LAMZABI
 * @version 1.0 - Initiale
 */
@isTest
public class WRP_01_ContactBadges_Test {

    public testmethod static void getContactBadges(){      
        

        test.startTest();
        
        WRP_01_ContactBadges.wrapUserBadges wub = new WRP_01_ContactBadges.wrapUserBadges('icontactId','ibadgeId','ibadgeName','ibadgeUrl',250,'200','iimageBadge');
        List<WRP_01_ContactBadges.wrapUserBadges> lwub = new List<WRP_01_ContactBadges.wrapUserBadges>();
        lwub.add(wub);
        
        WRP_01_ContactBadges result = new WRP_01_ContactBadges('contact',lwub);
        
        System.assert(result.familyBadge == 'contact',result.familyBadge);
        System.assert(result.userbadges.size() >0 ,result.userbadges.size());
        System.assert(result.userbadges[0].wonPoints == 250 ,result.userbadges[0].wonPoints);
        
        test.stopTest();
        
    }
    
}