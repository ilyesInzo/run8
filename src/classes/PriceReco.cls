public class PriceReco {
    //Attributs of the class PriceReco
	@Auraenabled	      
    public String minThreshHold;
    @Auraenabled	
    public String maxThreshHold;
    @Auraenabled
    public Decimal minThreshHoldValue;
    @Auraenabled
    public Decimal lin1Value;
    @Auraenabled
    public Decimal lin2Value;
    @Auraenabled
    public Decimal lin3Value;
    @Auraenabled
    public Decimal maxThreshHoldValue;
        
    @Auraenabled
    public String minThreshHoldPriceValue;
    @Auraenabled
    public String lin1PriceValue;
    @Auraenabled
    public String lin2PriceValue;
    @Auraenabled
    public String lin3PriceValue;
    @Auraenabled
    public String maxThreshHoldPriceValue;
    @Auraenabled
    public String tgValue; 
   
    @Auraenabled
    public Decimal freight;
    @Auraenabled
    public Boolean display;  
    @Auraenabled 
    public Boolean showColumn;//added by maryem qada
  
    @Auraenabled
    public Boolean disabledLin3;     
    
    @Auraenabled
    public Boolean disabledMaxThreshold;     

    @Auraenabled
    public String moq;
    @Auraenabled
    public Decimal otherMoq;    
    
    @Auraenabled
    public Decimal tg;
    @Auraenabled
	public boolean isSpecific;
    
    @Auraenabled
	public String selectedTubeConfig;
    @Auraenabled
	public String selectedDispensingConfig; 
    @Auraenabled
	public String quoteItem;     
        
    @Auraenabled
    public String errorMessage;
    
    //Constructors of the class PriceReco
    /**
     * [PriceReco Constructor Description : Blank constructor ]
     */
  	public PriceReco() {  
    }
    	    	    	
    /**
     * [PriceReco Constructor Description : create a PriceReco from another PriceReco] 
     * @param showRecoColumn    [Boolean   : ]
     * @param tg                [Decimal   : ]
     * @param isSpecific        [Boolean   : ]
     * @param display           [Boolean   : ]
     * @param moq               [String    : ]
     * @param freight           [Decimal   : ]
     * @param priceRecoDiscount [PriceReco : ]
     */
    public PriceReco(Boolean showRecoColumn, Decimal tg, Boolean isSpecific, boolean display, String moq, 
                      Decimal freight, PriceReco priceRecoDiscount) {                                   	
        this.showColumn = showRecoColumn;//added by maryem qada     
        this.freight = freight;
        this.display = display; 
        this.moq = ((moq == null || moq == '')  ? ' - ': moq);
        this.tg = tg;
        this.tgValue = tg == 0 ? '-': ''+tg; 
        this.isSpecific = isSpecific;
                                       
        if (display) {
            this.disabledLin3 = priceRecoDiscount.disabledLin3;
            this.disabledMaxThreshold = priceRecoDiscount.disabledMaxThreshold;                                                                                  
        } else {
        	this.disabledLin3 = true;
            this.disabledMaxThreshold = true;        	                                                                                                
        }                               
                                     
        if (isSpecific) {
            this.tgValue = 'Specific';
            this.minThreshHoldPriceValue = 'Specific' ;
            this.lin1PriceValue = 'Specific' ;
            this.lin2PriceValue = 'Specific' ;
            this.lin3PriceValue = 'Specific' ;
            this.maxThreshHoldPriceValue = 'Specific' ;              
        } 
        else {                	      
            /************** minThreshHoldValue ******************/                
            if (priceRecoDiscount.minThreshHoldValue != null && priceRecoDiscount.minThreshHoldValue != 0){
                Decimal minThreshHoldDiscount = priceRecoDiscount.minThreshHoldValue.setScale(3, System.roundingMode.DOWN);
                this.minThreshHoldValue = ((freight != null && freight > 0) ? 
                                            (((tg - freight) * (1 + minThreshHoldDiscount)) + freight) 
                                            : tg * (1 + minThreshHoldDiscount));  
                this.minThreshHoldPriceValue = '' + (minThreshHoldValue == 0? ' - ': ''+ minThreshHoldValue);
                System.debug('TG='+ tg + 'minThreshHoldDiscount='+ minThreshHoldDiscount + '=PRICE=' + this.minThreshHoldPriceValue);
                //this.minThreshHoldPriceValue = '' + (minThreshHoldValue == 0? ' - ': ''+minThreshHoldValue);
            } 
            else {
                system.debug('PRICE='+minThreshHoldValue + '=DISC=' + priceRecoDiscount.lin2Value);
                if (!'N/A'.equals(priceRecoDiscount.minThreshHoldPriceValue) && priceRecoDiscount.minThreshHoldValue == 0 && tg > 0) {
                    this.minThreshHoldPriceValue = '' + tg;
                    this.minThreshHoldValue = tg;
                } 
                else {
	                  this.minThreshHoldPriceValue = '-' ;                             
                }           
                //this.minThreshHoldPriceValue = '-' ;
            }
            /************** lin1Value ******************/ 
            if (priceRecoDiscount.lin1Value != null && priceRecoDiscount.lin1Value != 0){
                Decimal lin1Discount = priceRecoDiscount.lin1Value.setScale(3, System.roundingMode.DOWN);
               	this.lin1Value = ((freight > 0) ? (((tg - freight) * (1 + lin1Discount)) + freight) 
                                  : tg * (1 + lin1Discount));  
                //this.lin1PriceValue = '' + (lin1Value == 0? ' - ': ''+lin1Value) ;
                this.lin1PriceValue = '' + (lin1Value == 0? ' - ': ''+ (lin1Value));
    						System.debug('lin1Discount='+ lin1Discount + '=PRICE=' + this.lin1PriceValue);
            } 
            else {
               	//LAST MODIFIED BY MARYEM
             	  system.debug('PRICE='+lin1Value + '=DISC=' + priceRecoDiscount.lin1Value);
                if (!'N/A'.equals(priceRecoDiscount.lin1PriceValue) && priceRecoDiscount.lin1Value == 0 && tg > 0) {
                    this.lin1PriceValue = '' + tg;
                    this.lin1Value = tg;
                } 
                else {
    	              this.lin1PriceValue = '-' ;                             
                } 
                //this.lin1PriceValue = '-' ;
            }
    				/************** lin2Value ******************/ 
            if (priceRecoDiscount.lin2Value != null && priceRecoDiscount.lin2Value != 0){
                Decimal lin2Discount = priceRecoDiscount.lin2Value.setScale(3, System.roundingMode.DOWN);
                this.lin2Value = ((freight > 0) ? (((tg - freight) * (1 + lin2Discount)) + freight) 
                                  : tg * (1 + lin2Discount));   
                //this.lin2PriceValue = '' + (lin2Value == 0? ' - ': ''+lin2Value) ;
                this.lin2PriceValue = '' + (lin2Value == 0? ' - ': ''+ (lin2Value));
                System.debug('lin2Discount='+ lin2Discount + '=PRICE=' + this.lin2PriceValue);
            } 
            else {
                system.debug('PRICE='+lin2Value + '=DISC=' + priceRecoDiscount.lin2Value);
                if (!'N/A'.equals(priceRecoDiscount.lin2PriceValue) && priceRecoDiscount.lin2Value == 0 && tg > 0) {
                    this.lin2PriceValue = '' + tg;
                    this.lin2Value = tg;
                } 
                else {
    	              this.lin2PriceValue = '-' ;                             
                }
            }
            /************** lin3Value ******************/
            if (priceRecoDiscount.lin3Value != null && priceRecoDiscount.lin3Value != 0){
                Decimal lin3Discount = priceRecoDiscount.lin3Value.setScale(3, System.roundingMode.DOWN);
                this.lin3Value = ((freight > 0) ? (((tg - freight) * (1 + lin3Discount)) + freight) 
                                  : tg * (1 + lin3Discount));  
                this.lin3PriceValue = '' + (lin3Value == 0? ' - ': ''+ (lin3Value));
                //this.lin3PriceValue = '' + (lin3Value == 0? ' - ': ''+lin3Value) ;
                System.debug('lin3Discount='+ lin3Discount + '=PRICE=' + this.lin3PriceValue);
            } 
            else {
                //LAST MODIFIED BY MARYEM
                system.debug('PRICE='+lin3Value + '=DISC=' + priceRecoDiscount.lin3Value);
                if (!'N/A'.equals(priceRecoDiscount.lin3PriceValue) && priceRecoDiscount.lin3Value == 0 && tg > 0) {
                    this.lin3PriceValue = '' + tg;
                    this.lin3Value = tg;
                } 
                else {
    	              this.lin3PriceValue = '-' ;                             
                } 
                //this.lin3PriceValue = '-' ;
            }                
    				/************** maxThreshHoldValue ******************/
            if (priceRecoDiscount.maxThreshHoldValue != null && priceRecoDiscount.maxThreshHoldValue != 0){
                Decimal maxThreshHoldDiscount = priceRecoDiscount.maxThreshHoldValue.setScale(3, System.roundingMode.DOWN);
                this.maxThreshHoldValue = ((freight > 0) ? (((tg - freight) * (1 + maxThreshHoldDiscount)) + freight) 
                                          : tg * (1 + maxThreshHoldDiscount)); 
                this.maxThreshHoldPriceValue = '' + (maxThreshHoldValue == 0? ' - ': ''+ (maxThreshHoldValue));
                System.debug('MaxDiscount='+ maxThreshHoldDiscount + '=PRICE=' + this.maxThreshHoldPriceValue);
                //this.maxThreshHoldPriceValue = '' + (maxThreshHoldValue == 0? ' - ': ''+maxThreshHoldValue) ;
            } 
            else {
                //LAST MODIFIED BY MARYEM
                system.debug('PRICE='+maxThreshHoldValue + '=DISC=' + priceRecoDiscount.maxThreshHoldValue);
                if (!'N/A'.equals(priceRecoDiscount.maxThreshHoldPriceValue) && priceRecoDiscount.maxThreshHoldValue == 0 && tg > 0) {
                    this.maxThreshHoldPriceValue = '' + tg;
                    this.maxThreshHoldValue = tg;
                } 
                else {
    	              this.maxThreshHoldPriceValue = '-' ;                             
                } 
                //this.maxThreshHoldPriceValue = '-' ;
            }   	
        }//end if not specific
    }
        
    /**
     * [PriceReco Constructor Description : create a PriceReco from a PM_Discount_corridor__c] 
     * @param minThreshHold [String                  : ]
     * @param maxThreshHold [String                  : ]
     * @param priceCorridor [PM_Discount_corridor__c : ]
     * @param totalScore    [decimal                 : ]
     */
    public PriceReco(String minThreshHold, String maxThreshHold, PM_Discount_corridor__c priceCorridor, decimal totalScore) {
        this.minThreshHold = minThreshHold;
        this.maxThreshHold = maxThreshHold;
            
        if (priceCorridor != null && minThreshHold != null && maxThreshHold != null) {
            system.debug(minThreshHold + '__'+ maxThreshHold);
            system.debug('PRICE CORRIDOR');
            system.debug(priceCorridor);
            system.debug('MIN THRESHHOLD'+priceCorridor.get(minThreshHold + '__c'));
            //Get the value of the field of the threshold from the price corridor
            this.minThreshHoldValue = -(Decimal) priceCorridor.get(minThreshHold + '__c');            
            this.maxThreshHoldValue = -(Decimal) priceCorridor.get(maxThreshHold + '__c');  
                
            this.lin1Value = +(maxThreshHoldValue - minThreshHoldValue)/4 + minThreshHoldValue;
            this.lin2Value = +(maxThreshHoldValue - minThreshHoldValue)/4 + lin1Value;
            this.lin3Value = +(maxThreshHoldValue - minThreshHoldValue)/4 + lin2Value;  
            system.debug(maxThreshHoldValue + '__' + minThreshHoldValue + '__' +lin1Value + '__' +lin2Value+ '__' +lin3Value);
            system.debug('MIN=' + minThreshHoldValue + '__MAX='+ maxThreshHoldValue);
            this.minThreshHoldPriceValue = '' +  (this.minThreshHoldValue * 100).setScale(1, System.RoundingMode.DOWN) + '%';
            this.lin1PriceValue = '' +  (this.lin1Value * 100).setScale(1,System.RoundingMode.DOWN) + '%'; 
            this.lin2PriceValue = '' +  (this.lin2Value * 100).setScale(1,System.RoundingMode.DOWN) + '%'; 
            this.lin3PriceValue = '' +  (this.lin3Value * 100).setScale(1,System.RoundingMode.DOWN) + '%'; 
            this.maxThreshHoldPriceValue = '' +  (this.maxThreshHoldValue * 100).setScale(1,System.RoundingMode.DOWN) + '%';             
        } else {
            this.minThreshHoldValue = 0;            
            this.maxThreshHoldValue = 0;  
            
            this.lin1Value = 0;
            this.lin2Value = 0;
            this.lin3Value = 0;                 
            this.minThreshHoldPriceValue = 'N/A';
            this.lin1PriceValue = 'N/A';
            this.lin2PriceValue = 'N/A'; 
            this.lin3PriceValue = 'N/A'; 
            this.maxThreshHoldPriceValue = 'N/A';                 
        }


        // Based on total score, the lines must be disabled..
        //Scoring total <=4 les deux dernière lignes doivent être grisées
        //Scoring total >4 et <=6 la dernière ligne doit être grisée
        //Scoring total >6 alors aucunes lignes n’est grisées                                
        
        if (totalScore <=4 && totalScore > 0 && totalScore != null ) { //modified by maryem qada for null or = to 0 scores
            disabledLin3 = true;
            disabledMaxThreshold = true;
        } else if (totalScore > 4 && totalScore <=6 && totalScore > 0 && totalScore != null) { //modified by maryem qada for null or = to 0 scores 
           disabledLin3 = false;
           disabledMaxThreshold = true;                 
        } else {
            disabledLin3 = false;
            disabledMaxThreshold = false;                
        }                  
        
    }
    
    //Methods of the Class PriceReco
    /**
     * [validateDisplay description]
     */    
    public void validateDisplay() {
        
    }
}