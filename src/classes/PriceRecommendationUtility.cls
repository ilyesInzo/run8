public class PriceRecommendationUtility {
		public static Map<String, String> PRODUCT_SEGMENT_TO_MACRO_SEGMENT = new Map<String, String>();
    	public static Map<String, String> MARKET_APPLICATION_TO_MACRO_MARKET_APP = new Map<String, String>();
    	public static Map<String, String> CUSTOMER_TYPE_TO_MACRO_CUSTOMER_TYPE = new Map<String, String>();
    
    	public static String CUSTOMER_TYPE_FILLERS_DISTRIBUTORS = 'FILLERS & DISTRIBUTORS';
    	public static String CUSTOMER_TYPE_DIRECT_DISTRIBUTION = 'DIRECT DISTRIBUTION';
    	
    	public static Map<String, String> PRICE_CORRIDOR_FORMULA = new Map<String, String>();
     
    	static {
    		PRICE_CORRIDOR_FORMULA.put('EU_SPG_LAMINATE TUBES','Diameter_mm__c,Head_Name__c,Printing_technologies__c,Cap_Eurocode__c');
			PRICE_CORRIDOR_FORMULA.put('EU_TPG_LAMINATE TUBES','Diameter_mm__c,Head_Name__c,Cap_Name__c,Sleeve_Material__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_PPG_LAMINATE TUBES','Diameter_mm__c,Head_Name__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_MPG_LAMINATE TUBES','Diameter_mm__c,Head_Name__c'); 
            
            PRICE_CORRIDOR_FORMULA.put('EU_SPG_PLASTIC TUBES','Diameter_mm__c,Head_Name__c,Printing_technologies__c,Cap_Eurocode__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_TPG_PLASTIC TUBES','Diameter_mm__c,Head_Name__c,Cap_Name__c,Printing_technologies__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_PPG_PLASTIC TUBES','Diameter_mm__c,Head_Name__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_MPG_PLASTIC TUBES','Diameter_mm__c,Head_Name__c'); 

			PRICE_CORRIDOR_FORMULA.put('EU_TPG_PUREFOIL TUBES','Diameter_mm__c,Head_Name__c,Cap_Name__c,Printing_technologies__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_PPG_PUREFOIL TUBES','Diameter_mm__c,Head_Name__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_MPG_PUREFOIL TUBES','Diameter_mm__c,Head_Name__c'); 
            
			PRICE_CORRIDOR_FORMULA.put('EU_TPG_FINE MIST PUMPS','Product_Name__c,Attachment__c,Actuator__c,_'); 
			PRICE_CORRIDOR_FORMULA.put('EU_PPG_FINE MIST PUMPS','Product_Name__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_MPG_FINE MIST PUMPS','Product_Name__c'); 
            
			PRICE_CORRIDOR_FORMULA.put('EU_TPG_LOTION PUMPS','Engine_Name__c,Pump_Segmentation__c,Actuator__c,Collar__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_PPG_LOTION PUMPS','Engine_Name__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_MPG_LOTION PUMPS','Engine_Name__c'); 
            
			PRICE_CORRIDOR_FORMULA.put('EU_TPG_FOAM PUMPS','Product_Hierarchy__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_PPG_FOAM PUMPS','Product_Hierarchy__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_MPG_FOAM PUMPS','Product_Hierarchy__c'); 

			PRICE_CORRIDOR_FORMULA.put('EU_TPG_SAMPLERS','Product_Name__c,Engine_Neck__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_PPG_SAMPLERS','Product_Name__c'); 
			PRICE_CORRIDOR_FORMULA.put('EU_MPG_SAMPLERS','Product_Name__c'); 

			PRICE_CORRIDOR_FORMULA.put('US_TPG_LAMINATE TUBES','Diameter_inches__c,Head_Name__c,Cap_Name__c,Printing_technologies__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_PPG_LAMINATE TUBES','Diameter_inches__c,Head_Name__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_MPG_LAMINATE TUBES','Diameter_inches__c,MARKETAPP'); 
            
			PRICE_CORRIDOR_FORMULA.put('US_TPG_PLASTIC TUBES','Diameter_inches__c,Sleeve_type__c,Cap_Name__c,Printing_type__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_PPG_PLASTIC TUBES','Diameter_inches__c,Sleeve_type__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_MPG_PLASTIC TUBES','Diameter_inches__c,MARKETAPP'); 

/*			US_PRICE_CORRIDOR_FORMULA.put('TPG_PUREFOIL TUBES','Diameter_mm__c,Head_Name__c,Cap_Name__c,Printing_technologies__c'); 
			US_PRICE_CORRIDOR_FORMULA.put('PPG_PUREFOIL TUBES','Diameter_mm__c,Head_Name__c'); 
			US_PRICE_CORRIDOR_FORMULA.put('MPG_PUREFOIL TUBES','Diameter_mm__c,Head_Name__c'); 
*/            
			PRICE_CORRIDOR_FORMULA.put('US_TPG_FINE MIST PUMPS','Product_Name__c,Attachment__c,Actuator__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_PPG_FINE MIST PUMPS','Product_Name__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_MPG_FINE MIST PUMPS','Product_Name__c'); 
            
			PRICE_CORRIDOR_FORMULA.put('US_TPG_LOTION PUMPS','Engine_Name__c,Pump_Segmentation__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_PPG_LOTION PUMPS','Engine_Name__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_MPG_LOTION PUMPS','Engine_Name__c'); 
            
			PRICE_CORRIDOR_FORMULA.put('US_TPG_FOAM PUMPS','Product_Hierarchy__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_PPG_FOAM PUMPS','Product_Hierarchy__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_MPG_FOAM PUMPS','Product_Hierarchy__c'); 
 
			PRICE_CORRIDOR_FORMULA.put('US_TPG_SAMPLERS','Product_Name__c,Engine_Neck__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_PPG_SAMPLERS','Product_Name__c'); 
			PRICE_CORRIDOR_FORMULA.put('US_MPG_SAMPLERS','Product_Name__c');             
            
            
/*            PRODUCT_SEGMENT_TO_MACRO_SEGMENT.put('LAMINATE TUBES','Laminate');             
            PRODUCT_SEGMENT_TO_MACRO_SEGMENT.put('PLASTIC TUBES','Plastic');             
            PRODUCT_SEGMENT_TO_MACRO_SEGMENT.put('PUREFOIL TUBES','Purefoil');             
            PRODUCT_SEGMENT_TO_MACRO_SEGMENT.put('FINE MIST PUMPS','Fine Mist');             
            PRODUCT_SEGMENT_TO_MACRO_SEGMENT.put('LOTION PUMPS','Lotion');             
            PRODUCT_SEGMENT_TO_MACRO_SEGMENT.put('FOAM PUMPS','Foam');  
    		PRODUCT_SEGMENT_TO_MACRO_SEGMENT.put('SAMPLERS','Samplers'); 
            
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('BABY CARE', 'Personal, Body & Hair Care'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('BODY CARE', 'Personal, Body & Hair Care'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('COLOUR COSMETICS', 'Colour Cosmetics'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('FACIAL CARE', 'Skin Care'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('FOOD & BEVERAGE', 'Non-beauty market'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('FRAGRANCE', 'Fragrance'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('HAIR CARE', 'Personal, Body & Hair Care'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('HEALTHCARE & PHARMACY', 'Non-beauty market'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('HOUSEHOLD & INDUSTRIAL', 'Non-beauty market'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('MEN\'S GROOMING', 'Skin Care'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('ORAL CARE', 'Oral Care'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('OTHERS', 'Non-beauty market'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('PERSONAL CARE', 'Personal, Body & Hair Care'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('PET CARE', 'Non-beauty market'); 
            MARKET_APPLICATION_TO_MACRO_MARKET_APP.put('SUN CARE', 'Personal, Body & Hair Care');   
            
            CUSTOMER_TYPE_TO_MACRO_CUSTOMER_TYPE.put('Brand owner', '1'); 
            CUSTOMER_TYPE_TO_MACRO_CUSTOMER_TYPE.put('Direct Seller', '2'); 
            CUSTOMER_TYPE_TO_MACRO_CUSTOMER_TYPE.put('Formulator', '3'); 
            CUSTOMER_TYPE_TO_MACRO_CUSTOMER_TYPE.put('Distributor', '4'); 
            CUSTOMER_TYPE_TO_MACRO_CUSTOMER_TYPE.put('Contract filler', '5');             
*/
	if(Test.isRunningTest()){
	//do something
	
	PRICE_CORRIDOR_FORMULA.put('EU_TPG_NAME0','null_null_GLOBAL ACCOUNT_null');
	PRICE_CORRIDOR_FORMULA.put('EU_PPG_NAME0','null_null_GLOBAL ACCOUNT_null');
	PRICE_CORRIDOR_FORMULA.put('EU_MPG_NAME0','null_GLOBAL ACCOUNT');
	}
} 
        
}