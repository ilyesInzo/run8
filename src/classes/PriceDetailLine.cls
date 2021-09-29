public class PriceDetailLine {
        @Auraenabled          
        public String title;
        @Auraenabled              
        public String section;
    
        @Auraenabled          
        public String x5;
        @Auraenabled          
        public Decimal x5Override;  
    
        @Auraenabled          
        public String x10;
        @Auraenabled          
        public Decimal x10Override;    
                      
        @Auraenabled          
        public String x15;
        @Auraenabled          
        public Decimal x15Override;    
    
        @Auraenabled          
        public String x20;
        @Auraenabled          
        public Decimal x20Override;
    
        @Auraenabled          
        public String x25;
        @Auraenabled          
        public Decimal x25Override;  
    
        @Auraenabled          
        public String x50;
        @Auraenabled          
        public Decimal x50Override;
    
        @Auraenabled          
        public String x75; 
        @Auraenabled          
        public Decimal x75Override;
    
        @Auraenabled          
        public String x100;
        @Auraenabled          
        public Decimal x100Override;
    
        @Auraenabled          
        public String x200;
        @Auraenabled          
        public Decimal x200Override;
    
        @Auraenabled          
        public String x300;
        @Auraenabled          
        public Decimal x300Override;
    
        @Auraenabled          
        public String x500;
        @Auraenabled          
        public Decimal x500Override;
        
        //added by maryem qada 27/06/2018 ==> adding moq 1000
        @Auraenabled          
        public String x1000;
        @Auraenabled          
        public Decimal x1000Override;
        
        //Specific MOQ from Price RECO
      	@Auraenabled          
        public String xSpecific;
        @Auraenabled          
        public Decimal xSpecificOverride;
        
        @Auraenabled        
        public String iscombo;
        @Auraenabled        
        public String x5combocomments;
        @Auraenabled        
        public String x10combocomments;
        @Auraenabled        
        public String x15combocomments;
        @Auraenabled        
        public String x20combocomments;
        @Auraenabled        
        public String x25combocomments;
        @Auraenabled        
        public String x50combocomments;
        @Auraenabled        
        public String x75combocomments;
        @Auraenabled        
        public String x100combocomments;
        @Auraenabled        
        public String x200combocomments;
        @Auraenabled        
        public String x300combocomments;
        @Auraenabled        
        public String x500combocomments;
         //added by maryem qada 27/06/2018 ==> adding moq 1000
        @Auraenabled          
        public String x1000combocomments;
        //SPECIFIC MOQ
        @Auraenabled        
        public String xSpecificcombocomments;
     
    /*	//constructor for specific MOQ
        public static PriceDetailLine insertPriceDetailIntoLine(Boolean isSpecificMoq,PriceDetailLine priceLine, Decimal moq, String price, decimal priceOverride, string iscombo, string combocomments) {
       		priceLine.iscombo = iscombo;
            priceLine.xSpecific = price;
            priceLine.xSpecificOverride = priceOverride;
            priceLine.xSpecificcombocomments = combocomments;
            
            return priceLine;
        }//end constructor for specific MOQ
     */
     
    public static PriceDetailLine insertPriceDetailIntoLine(Boolean isSpecificMoq,PriceDetailLine priceLine, Decimal moq, String price, decimal priceOverride, string iscombo, string combocomments) {
        priceLine.iscombo = iscombo;
        
        if(isSpecificMoq){
        	priceLine.xSpecific = price;
            priceLine.xSpecificOverride = priceOverride;
            priceLine.xSpecificcombocomments = combocomments;	
        }else {
        	if (moq == 5) {
	            priceLine.x5 = price;
	            priceLine.x5Override = priceOverride;
	            priceLine.x5combocomments = combocomments;
	            
	        } else if (moq == 10) {
	            priceLine.x10 = price;
	            priceLine.x10Override = priceOverride;
	            priceLine.x10combocomments = combocomments;
	            
	        } else if (moq == 15) {
	            priceLine.x15 = price;
	            priceLine.x15Override = priceOverride;
	            priceLine.x15combocomments = combocomments;
	            
	        } else if (moq == 20) {
	            priceLine.x20 = price; 
	            priceLine.x20Override = priceOverride;
	            priceLine.x20combocomments = combocomments;
	            
	        } else if (moq == 25) {
	            priceLine.x25 = price;
	            priceLine.x25Override = priceOverride;
	            priceLine.x25combocomments = combocomments;
	            
	        } else if (moq == 50) {
	            priceLine.x50 = price;
	            priceLine.x50Override = priceOverride;
	            priceLine.x50combocomments = combocomments;
	            
	        } else if (moq == 75) {
	            priceLine.x75 = price;
	            priceLine.x75Override = priceOverride;
	            priceLine.x75combocomments = combocomments;
	            
	        } else if (moq == 100) {
	            priceLine.x100 = price;
	            priceLine.x100Override = priceOverride;
	            priceLine.x100combocomments = combocomments;
	            
	        } else if (moq == 200) {
	            priceLine.x200 = price;
	            priceLine.x200Override = priceOverride;
	            priceLine.x200combocomments = combocomments;
	            
	        } else if (moq == 300) {
	            priceLine.x300 = price;
	            priceLine.x300Override = priceOverride;
	            priceLine.x300combocomments = combocomments;
	            
	        } else if (moq == 500) {
	            priceLine.x500 = price;
	            priceLine.x500Override = priceOverride;
	            priceLine.x500combocomments = combocomments;
	        
	        } else if (moq == 1000) {
	            priceLine.x1000 = price;
	            priceLine.x1000Override = priceOverride;
	            priceLine.x1000combocomments = combocomments;
	        }	
        }//end else specificmoq= true 
        
        return priceLine;
    }    
    
}