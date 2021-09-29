/**
* Service class for interacting with Lead Object
*
* @author MQ
* @date 10/10/2017
*
*/
public class LeadService {

    ///////////////////////////////////////////////////////////////////////////////
    // WHEN CHILD CLASS EXTENDS AN ABSTRACT PARENT CLASS WE CAN'T USE STATIC METHOD
    // OF THE PARENT SO WE HAVE TO IMPLEMENT THE SINGLETON PATTERN
    ///////////////////////////////////////////////////////////////////////////////	
    private static LeadService instance = null;
    
    /**
     * @description [SalesTeamService : private constructor (Singleton pattern)]
     * @return [a new instance of the class]
     */    
    private LeadService() {
    }
    

    /**
     * @description [getInstance : a static method that returns the unique instance of the class (Singleton pattern)]
     * @return [description]
     */
    public static LeadService getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) {
            instance = new LeadService();
        }
        return instance; 
    }
    ///////////////////////////////////////////////////////////////////////////////
    
    public class BadException extends Exception {}

    private static final Set<String> LEAD_SOURCES = new Set<String>{'Website', 'Other'};
    
    /**
     * @description 
     * @param 
     * @return 
     */
    public void assignForWebSite(List<Lead> liLeadsToAssign) {
    	
        List<Lead> ls = new List<Lead>(); 
    
 		for(Lead l : liLeadsToAssign){
 			if (LEAD_SOURCES.contains(l.LeadSource)) {  
            	ls.add(new Lead(id = l.id)); 
        	}//end if 			
 		}//end for 
 		
 		Database.DMLOptions dmo = new Database.DMLOptions();  
	    dmo.assignmentRuleHeader.useDefaultRule = true; 
	    Database.update(ls, dmo);
 		       
    }// end methode

    /**
     * @description 
     * @param 
     * @return 
     */
    public static void alertlead(List<Lead> leads){
    
        List<Task> tasklist = new List<Task>();
        
        for(Lead ld : leads){
            Task t = new Task();
            t.Subject = (ld.Status == 'New')?'New Lead : 1 week':'Active Lead : 2 weeks';
            t.OwnerId = ld.OwnerId;
            t.WhoId = ld.Id;
            t.Priority = 'Normal';
            t.Status = 'Open';
            tasklist.add(t);
        }
        Database.Insert(tasklist, false);
    }
    
        /**
     * @Methode Name : GameCalculationConvertedLead 
     * @description : Game Calculation for converted Lead
     * @param : List Lead
     * @return : Void
     */
    public static void GameCalculationConvertedLead(List<Lead> leads, Map<Id,Lead> oldLeads){
    	Boolean leadConversion = false;
        Boolean leadUpdate = false;
        for(Lead lead:leads) {
            if (lead.status != oldLeads.get(lead.id).status && lead.Status == 'Converted'){
                leadConversion = true;
            }
            else{
                leadUpdate = true;
            }
        }
        
        if(leadConversion){LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_LEAD_CONVERSION);}
        if(leadUpdate){LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_LEAD_UPDATE);}
    }
    
    
            /**
     * @Methode Name : fillCountryLoockup 
     * @description : fill the Country Loockup 
     * @param : List Lead
     * @return : Void
     */
    public static void fillCountryLoockup(List<Lead> leads){
    	set<String> countryCodes = new set<String>();
        
        for(Lead ld:leads){
            if(ld.Tech_CountryCodePardot__c != null) countryCodes.add(ld.Tech_CountryCodePardot__c);
        }
        
		List<Country__c> countries = [select id, Name , Country_Code__c from Country__c where Country_Code__c in: countryCodes];        	
        
        Map<String,String> countryCodeIds = new Map<String,String>();
        
        for(Country__c country: countries){
            
            countryCodeIds.put(country.Country_Code__c,country.id);
        }
        
        for(Lead ld:leads){
            if(ld.Country__c == null && ld.Tech_CountryCodePardot__c != null){
         	    ld.Country__c = countryCodeIds.get(ld.Tech_CountryCodePardot__c);   
        	} 
        }
    }    
    
    
       
            /**
     * @Methode Name : fillProductLineForWebsiteSource 
     * @description : fill the Country Loockup 
     * @param : List Lead
     * @return : Void
     */
    public static void fillProductLineForWebsiteSource(List<Lead> leads){
    	set<String> countryCodes = new set<String>();
        List<String> marketingProduct ;
        
        System.debug('Achraf01');
        for(Lead ld:leads){
            System.debug('Achraf02');
            if(ld.LeadSource == 'Website' && ld.Marketing_product__c != null ){
                marketingProduct = ld.Marketing_product__c.split(';');
                
                if(AP00_UtilityConstants.LEAD_PRODUCTLINE_TUBE.contains(marketingProduct[0])){
                    ld.Product_Line__c = 'Tube';
                }
                else if(AP00_UtilityConstants.LEAD_PRODUCTLINE_CRP.contains(marketingProduct[0])){
                    ld.Product_Line__c = 'CRP';
                }
                else if(AP00_UtilityConstants.LEAD_PRODUCTLINE_DISPENSING.contains(marketingProduct[0])){
                    ld.Product_Line__c = 'Dispensing';
                }
                else if(AP00_UtilityConstants.LEAD_PRODUCTLINE_BEAUTYSOLUTIONS.contains(marketingProduct[0])){
                    ld.Product_Line__c = 'Beauty Solution';
                }
  
            } 
            else if(ld.LeadSource == 'Website' && ld.Sous_segment_produit_backoffice__c != null ){
                 System.debug('Achraf03' + ld.Sous_segment_produit_backoffice__c);               
                if(AP00_UtilityConstants.LEAD_PRODUCTLINE_TUBESS.contains(ld.Sous_segment_produit_backoffice__c)){
                    ld.Product_Line__c = 'Tube';
                    System.debug('Achraf04');
                }
                else if(AP00_UtilityConstants.LEAD_PRODUCTLINE_CRPSS.contains(ld.Sous_segment_produit_backoffice__c)){
                    ld.Product_Line__c = 'CRP';
                    System.debug('Achraf05');
                }
                else if(AP00_UtilityConstants.LEAD_PRODUCTLINE_BEAUTYSOLUTIONSSS.contains(ld.Sous_segment_produit_backoffice__c)){
                    ld.Product_Line__c = 'Beauty Solution';
                    System.debug('Achraf07');
                }
  
            }
            
            
        }
        
	
    }    
    
    
}