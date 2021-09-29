/**
 * @Author           : Comforth
 * @Purpose          : Apex controller for lightning components LC01_DetailOverridePMPrice
 * @Notes            : e.g. LC01_Detail_EU_TubePlastic
 * @History
 *  Date         Modified By         Description
 *  ------------ ---------------     -------------------------------------------
 *  03-MAR-2017  Hasseeb Mungroo             Initial version
 */ 
public class LC01_DetailOverridePMPrice {
    //Attributs for the class LC01_DetailOverridePMPrice
    private static String LOG_CLASS_NAME = 'LC01_DetailOverridePMPrice';

    //Method for the class LC01_DetailOverridePMPrice
    /**
     * [getOverridePrice : return an overrided price]
     * @param section      [String  : the section of Item for which you want an overrided price]
     * @param title        [String  : the title of Item for which you want an overrided price  ]
     * @param moq          [Integer :                                                          ]
     * @param moqMax       [Integer :                                                          ]
     * @param price        [Decimal : the price of the Item                                    ]
     * @param qliId        [String  : The Id of the quote line item                            ]
     * @param tubeId       [String  :                                                          ]
     * @param dispensingId [String  :                                                          ]
     * @return             [String  : the overrided price of the Item                          ]
     */
    @AuraEnabled
    public static String getOverridePrice(String section, String title, Integer moq, Integer moqMax,Decimal price,String qliId,
                                         String tubeId, String dispensingId){

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getOverridePrice Start');

        //We get back the pricing corresponding to the qliId, section, title, moq
        Boolean recalculate = false;
        String message = '';                                
        List<PM_Price_Detail__c> pricings = [select List_Price__c, MOQ_Min__c, Name, Section__c, ExtId__c,
                                             PM_Selected_Tubes_Config__c, PM_Selected_Dipsensing_config__c
                                            from PM_Price_Detail__c
                                            where Quote_item__c = :qliId and Section__c= :section 
                                          	and Name = :title and MOQ_Min__c =:moq
                                            limit 1];

        system.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - pricings : ' + pricings);

        //If the price return is not null or == 0, we're going to send it back
        String selectedTubeId = null;
        String selectedDispensingConfigId = null;        
        if (pricings != null && pricings.size() > 0) {
            PM_Price_Detail__c pricing = pricings.get(0);
            //No need to do the override as the price is the same                                     
       		if (pricing.List_Price__c  != price) {
                selectedTubeId = pricing.PM_Selected_Tubes_Config__c;
                selectedDispensingConfigId = pricing.PM_Selected_Dipsensing_config__c;
            	//Check if there is an override before creating a new one. 
            	pricing.Price_Override__c = price; 
                update pricing;
                recalculate = true;
            }              
            message = 'SUCCESS';
        } 
        // If it's not the case, we're going to generate the price
        else {            
            PM_Price_Detail__c priceDetail = new PM_Price_Detail__c();
            String location = '';            
            PM_Selected_Tubes_Config__c selectedTube = null;
            PM_Selected_Dipsensing_config__c selectedDispensingConfig = null; 
            
			QuoteLineItem qli = [select Id, Product_Sub_segment__c from QuoteLineItem where Id = :qliId];                                             
         	String productSegment = qli.Product_Sub_segment__c;                

            List<PM_Selected_Tubes_Config__c>  selectedTubes = [select id, Location__c  from PM_Selected_Tubes_Config__c where Quote_item__c =:qliId];
            if (selectedTubes != null && selectedTubes.size() > 0) {
                    selectedTube = selectedTubes.get(0);  
                	selectedTubeId = selectedTube.Id;
                	location = selectedTube.Location__c;
            } else {
                
                List<PM_Selected_Dipsensing_config__c>  selectedDispensingTubes = 
                                [select id, Location__c from PM_Selected_Dipsensing_config__c where Quote_item__c =:qliId];
                if (selectedDispensingTubes != null && selectedDispensingTubes.size() > 0) {
                    selectedDispensingConfig = selectedDispensingTubes.get(0);
                    selectedDispensingConfigId = selectedDispensingConfig.Id;
                    location = selectedDispensingConfig.Location__c;
                }              
            }
            
 			System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' MOQ=' +moq );

            Double moqDouble = Double.valueOf(moq);
            String externalId = (selectedTubeId == null ? selectedDispensingConfigId : selectedTubeId) + title;
            //ExtId__c
            List <PM_Price_Detail__c> listDetails = null;
            if (location == 'EU') {
                if ('Lotion pumps'.equalsIgnoreCase(productSegment)) {
                    /*listDetails = new List <PM_Price_Detail__c>{
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 10? price: 0), ExtId__c = externalId + 10, MOQ_Min__c = 10, MOQ_Max__c = 25, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 25? price: 0), ExtId__c = externalId + 25, MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 50? price: 0), ExtId__c = externalId + 50, MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 100? price: 0), ExtId__c = externalId + 100, MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 250? price: 0), ExtId__c = externalId + 250, MOQ_Min__c = 250, MOQ_Max__c = 500, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId)
                    };*/  
                    List<Integer> values = new List<Integer>{10, 25, 50, 100, 250, 500};
                    listDetails = SObjectUtils.generatePriceDetail(values, moqDouble, price, externalId, title, section, qliId, selectedTubeId, 
                                                                        selectedDispensingConfigId);
                } else {
                    /*listDetails = new List <PM_Price_Detail__c>{
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 10? price: 0), ExtId__c = externalId + 10, MOQ_Min__c = 10, MOQ_Max__c = 15, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 15? price: 0), ExtId__c = externalId + 15, MOQ_Min__c = 15, MOQ_Max__c = 20, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 20? price: 0), ExtId__c = externalId + 20, MOQ_Min__c = 20, MOQ_Max__c = 25, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 25? price: 0), ExtId__c = externalId + 25, MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 50? price: 0), ExtId__c = externalId + 50, MOQ_Min__c = 50, MOQ_Max__c = 75, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 75? price: 0), ExtId__c = externalId + 75, MOQ_Min__c = 75, MOQ_Max__c = 100, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 100? price: 0), ExtId__c = externalId + 100, MOQ_Min__c = 100, MOQ_Max__c = 200, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 200? price: 0), ExtId__c = externalId + 200, MOQ_Min__c = 200, MOQ_Max__c = 300, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 300? price: 0), ExtId__c = externalId + 300, MOQ_Min__c = 300, MOQ_Max__c = 500, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                        new PM_Price_Detail__c(Price_Override__c = (moqDouble == 500? price: 0), ExtId__c = externalId + 500, MOQ_Min__c = 500, MOQ_Max__c = null, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId)
                    }; */     
                    List<Integer> values = new List<Integer>{10, 15, 20, 25, 50, 75, 100, 200, 300, 500, null};
                    listDetails = SObjectUtils.generatePriceDetail(values, moqDouble, price, externalId, title, section, qliId, selectedTubeId, 
                                                                        selectedDispensingConfigId);                  
                }
            } else {
                /*listDetails = new List <PM_Price_Detail__c>{
                    new PM_Price_Detail__c(Price_Override__c = (moqDouble == 10? price: 0), ExtId__c = externalId + 10, MOQ_Min__c = 10, MOQ_Max__c = 15, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                    new PM_Price_Detail__c(Price_Override__c = (moqDouble == 15? price: 0), ExtId__c = externalId + 15, MOQ_Min__c = 15, MOQ_Max__c = 20, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                    new PM_Price_Detail__c(Price_Override__c = (moqDouble == 20? price: 0), ExtId__c = externalId + 20, MOQ_Min__c = 20, MOQ_Max__c = 25, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                    new PM_Price_Detail__c(Price_Override__c = (moqDouble == 25? price: 0), ExtId__c = externalId + 25, MOQ_Min__c = 25, MOQ_Max__c = 30, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                    new PM_Price_Detail__c(Price_Override__c = (moqDouble == 30? price: 0), ExtId__c = externalId + 30, MOQ_Min__c = 30, MOQ_Max__c = 50, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                    new PM_Price_Detail__c(Price_Override__c = (moqDouble == 50? price: 0), ExtId__c = externalId + 50, MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                    new PM_Price_Detail__c(Price_Override__c = (moqDouble == 100? price: 0), ExtId__c = externalId + 100, MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                    new PM_Price_Detail__c(Price_Override__c = (moqDouble == 250? price: 0), ExtId__c = externalId + 250, MOQ_Min__c = 250, MOQ_Max__c = 500, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId),
                    new PM_Price_Detail__c(Price_Override__c = (moqDouble == 500? price: 0), ExtId__c = externalId + 500, MOQ_Min__c = 500, MOQ_Max__c = null, List_Price__c = 0, Name = title, Section__c = section, Quote_item__c = qliId, PM_Selected_Tubes_Config__c = selectedTubeId, PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId)
                };*/ 
                List<Integer> values = new List<Integer>{10, 15, 20, 25, 30, 50, 100, 250, 500, null};
                    listDetails = SObjectUtils.generatePriceDetail(values, moqDouble, price, externalId, title, section, qliId, selectedTubeId, 
                                                                        selectedDispensingConfigId);  
            }
            
            System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' listDetails ' + listDetails);

            insert listDetails;            
            recalculate = true;
            message = 'SUCCESS';                         
        }
                                             
        if (recalculate)  {
           PMCalculatorUtility.calculateTotalMOQPRice(selectedTubeId, selectedDispensingConfigId, qliId);
           message = 'SUCCESS';                                 
        }           

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getOverridePrice Start');
                                               
        return message;
    }
}