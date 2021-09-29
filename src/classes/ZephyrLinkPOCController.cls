public with sharing class ZephyrLinkPOCController {

    /**
     * @description [formatStringValue : format a String value to this format : '#######.00' or '#########']
     * @param   value [String value to format, should be '### ### ###.00' or '###,###,###.00' or '### ### ###,00'...]
     *          sizeOfDecPart [size of decimal part]
     * @return formattedValue
     */
    @TestVisible
    private static String formatStringValue(String value, Integer maxSizeOfDecPart, Boolean integerPartOnly) {

        // The return String has to be formatted like this :
        // '#############.00' or '############'

        Integer size = value.length();
        
        // The value can be a decimal with 0, 1, ... , maxSizeOfDecPart-1 digits after '.' or ',' in the last 3 chars
        // of the value String, so we get the last 3 chars and replace ',' if necessary.
        String lastThreeDigits = '';
        if (maxSizeOfDecPart < size) {
            lastThreeDigits = value.substring(size - maxSizeOfDecPart,size);
            // The value must be a decimal after '.' or ','
            if (lastThreeDigits.contains(',') || lastThreeDigits.contains('.')) {
                lastThreeDigits = lastThreeDigits.replace(',','.').remove(' ');
            } else {
                lastThreeDigits = '';
            }
        }
        
        // We remove ' ', ',' and '.' chars to have the format '###############'
        String firstDigits = value.substring(0,size - lastThreeDigits.length()).remove(' ').remove(',').remove('.');

        if (integerPartOnly) {
            return firstDigits;
        } else {
            return firstDigits+lastThreeDigits;
        }
        
    }


    @AuraEnabled
    public static boolean validlinkforcebutton(String quoteItemId){
        //return !LC01_OpenPriceMatrix.displaybuttonvalidation(quoteItemId) ;
        return !LC01_OpenPriceMatrix.displaybuttonvalidation(quoteItemId) || !LC01_OpenPriceMatrix.displayComponent(quoteItemId);
    }
    
    @AuraEnabled
    public static string readZephyrData(String zephyrDataInput,Id quoteId){
        
        system.debug('--- String Input ---'+zephyrDataInput);
        system.debug('--- Record Id ---'+quoteId);
        
        //Retrieve QuoteLineItem
        QuoteLineItem qli = [select Id,QuoteId from QuoteLineItem where id=:quoteId];
        
        //Retrieve Quote
        Quote qt = [select id,OpportunityId from Quote where id=:qli.QuoteId];
            
        //Retrieve Opportunity
        Opportunity opp = [select Id from Opportunity where id=:qt.OpportunityId];
        
        
        //Start Processing the Data
        //List<String> splitDataList = zephyrDataInput.split('    ');
        List<String> splitDataList = zephyrDataInput.split('	');
        
        //Retrieve Custom Settings Field Mapping
        Map<String,ZephyrLinkQLI__c> qliSettingsFieldMap = ZephyrLinkQLI__c.getAll();
        System.debug(LoggingLevel.INFO, ' qliSettingsFieldMap.size() ' + qliSettingsFieldMap.values().size());

        //if(splitDataList.size() < qliSettingsFieldMap.values().size() ){
        //    String errorOccured = Label.Linkforce_Too_Short_Message;
            
        //    return errorOccured;
        //}
        
        try{ 
            
            //Process and Map Each Data to its QuoteLineItemField
            //Integer Counter = 0;
            Integer InputTotalSize = splitDataList.size();
            
            system.debug('--- Input Size ---'+InputTotalSize);
            
            for(Integer counter = 0; counter <= (splitDataList.size()-1); counter++){
                
                system.debug('--- Counter ---'+counter);
                
                String dataElement = splitDataList[counter];
                
                System.debug('--- Data Element ---'+dataElement+'+');
                
                if(dataElement != '' && dataElement !='  ' ){
                    
                    //Check if Field Mapping Setting exists
                    if(qliSettingsFieldMap.containsKey(String.valueOf(Counter))){
                        
                        System.debug('--- QLI Field To Map ---'+qliSettingsFieldMap.get(String.valueOf(Counter)));
                        String Field = qliSettingsFieldMap.get(String.valueOf(Counter)).QuoteLineItem_field__c;
                        String FieldType = qliSettingsFieldMap.get(String.valueOf(Counter)).Field_Type__c;
                        
                        //Check if Quote Field
                        if(Field.startsWith('Quote.')){
                            
                            String quoteField = Field.removeStart('Quote.');
                            System.debug('--- Quote Field ---'+quoteField);
                            
                            //Map Quote Field
                            if(FieldType == 'Date'){
                                
                                   String[] strDate = dataElement.split('-');
                                   Integer myIntDate = integer.valueOf(strDate[2]);
                                   Integer myIntMonth = integer.valueOf(strDate[1]);
                                   Integer myIntYear = integer.valueOf(strDate[0]);
                                   Date parsedDate = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                   
                                
                                system.debug('--- Date Field Parsed---'+parsedDate);
                                
                                qt.put(quoteField,parsedDate);
                            }else{
                            	qt.put(quoteField,dataElement);
                            }
                            
                        }else if(Field.startsWith('Opportunity.')){
                            
                            String oppField = Field.removeStart('Opportunity.');
                            System.debug('--- Opp Field ---'+oppField);
                            
                            if(Fieldtype == 'Double'){                               
                                opp.put(oppField,double.valueOf(formatStringValue(dataElement,3,false)));
                            }
                            else if(FieldType == 'Date'){
                                
                                   String[] strDate = dataElement.split('-');
                                   Integer myIntDate = integer.valueOf(strDate[2]);
                                   Integer myIntMonth = integer.valueOf(strDate[1]);
                                   Integer myIntYear = integer.valueOf(strDate[0]);
                                   Date parsedDate = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                   
                                
                                system.debug('--- Date Field Parsed---'+parsedDate);
                                
                                opp.put(oppField,parsedDate);
                            }else{
                                opp.put(oppField,dataElement);
                            }
                                
                        }else{

                            //Set Quote Line Item Field Update
                            if(FieldType == 'Integer'){
                                if (Field == 'Quantity') {
                                    dataElement = dataElement.replace('ku', '');
                                }
                                qli.put(Field,Integer.valueOf(formatStringValue(dataElement,3,true)));                                
                            }else if(FieldType == 'Double'){
                                qli.put(Field,Double.valueOf(formatStringValue(dataElement,3,false)));                            
                            }else{
                                system.debug('--- !Date Field ---'+dataElement);
                            	system.debug('--- Field---'+Field);

                                if(Field == 'Production_Plant__c'){
                                	qli.put(Field,QuoteLineItemService.getInstance().transcoPlantName(dataElement));
                                	system.debug('--- Field trasncoded ---'+QuoteLineItemService.getInstance().transcoPlantName(dataElement));
                                }
                                else{
                                    if (Field == 'Billing_Currency__c'){
                                        dataElement = dataElement.replace('(INR)', '');

                                    }
                                    qli.put(Field,dataElement);
                                }

                            }
                            
                        }    
                    }                   
                }                
            }
            
            //Update QuoteLineItem/Quote/Opportunity            
            update opp;
            update qt;
            update qli;
            
          //  String response = 'Quote Line Item has been Updated '+splitDataList;
            //String response = 'This quote item and some information of the related quote / opportunity, have been updated with the RFQ Excel file';
            
            //return response;
            //return 'This quote item and some information of the related quote / opportunity, have been updated with the RFQ Excel file';
            return Label.Linkforce_Success_Message;
       
        }catch(exception e){
            
            String excp = ''+e;
            system.debug('--- Exception ---'+excp);
            //String errorOccured = 'There is an error in your file, please review it or contact your Winforce Administrator. Thank you.';
            String errorOccured = Label.Linkforce_Error_Message;
            
            return errorOccured;
        }
        
    }
    
}