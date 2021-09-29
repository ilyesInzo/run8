public with sharing class LC01_ProductConfig_DecorationCtrl {
/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Apex controller for lightning components LC01_ProductConfig_Decoration
 * Notes            : e.g. LC01_ProductConfig_EU_TubePlastic_Decor
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   15-FEB-2017  Gulshan             Initial version
 *****************************************************************************/   
 /*
    public static final String APPLICATOR = 'Applicator';
    public static final String ER3 = 'ER3';
    public static final String OFFSET = 'Offset';
    public static final String OFFSET_SS = 'Offset + Silkscreen';
    public static final String FLEXO = 'Flexo';
    public static final String FLEXO_SS = 'Flexo + Silkscreen';
    public static final String SILKSCREEN = 'Silkscreen';
    public static final String UNPRINTED = 'Unprinted'; 

    @AuraEnabled
    public static Map <String, Object> getColors(Id pmSelectedConfigId, String printingTechno){
        Map <String, Object> mapResponse = new Map <String, Object>();
        String spec = '';
        String location = '';
        for(PM_Selected_Tubes_Config__c config : [select Diameter_mm__c, Head_Name__c, Dispensing_System_Family__c, Location__c
                                                    from PM_Selected_Tubes_Config__c
                                                    where Id = :pmSelectedConfigId
                                                    limit 1]){
            
            location = config.Location__c;

            if(config.Diameter_mm__c == 50 && config.Head_Name__c == ER3){
                spec = config.Dispensing_System_Family__c == APPLICATOR ? '50_ER3YES' : '50_ER3NO';
            }else{
                spec = String.valueOf(config.Diameter_mm__c) + '_' + config.Head_Name__c;
            }
        }
        System.debug('## spec : ' + spec);

        if(String.isNotBlank(spec)){
            // GDO - TODO : Further filters may be needed later
            for(PM_Tubes_Config__c tubeConfig : [select Spec__c, Offset__c, Flexo__c, 
                                                        Silkscreen__c, Flexo_Silkscreen__c, Offset_Silkscreen__c 
                                                    from PM_Tubes_Config__c 
                                                    where Location__c = :location
                                                    and Spec__c = :spec]){
                if(printingTechno == OFFSET){
                    mapResponse.put(OFFSET, getColorOptions(tubeConfig.Offset__c));
                }else if(printingTechno == OFFSET_SS){
                    if(tubeConfig.Offset_Silkscreen__c > 0){
                        mapResponse.put(OFFSET, getColorOptions(6));
                    }
                    mapResponse.put(SILKSCREEN, getColorOptions(tubeConfig.Offset_Silkscreen__c));
                }else if(printingTechno == FLEXO){
                    mapResponse.put(FLEXO, getColorOptions(tubeConfig.Flexo__c));
                }else if(printingTechno == FLEXO_SS){
                    if(tubeConfig.Flexo_Silkscreen__c > 0){
                        mapResponse.put(OFFSET, getColorOptions(4));
                    }
                    mapResponse.put(SILKSCREEN, getColorOptions(tubeConfig.Flexo_Silkscreen__c));
                }else if(printingTechno == SILKSCREEN){
                    mapResponse.put(SILKSCREEN, getColorOptions(tubeConfig.Silkscreen__c));
                }
            }
        }

        System.debug('## mapResponse : ' + mapResponse);

        return mapResponse;
    }  

    public static List <String> getColorOptions(Decimal count){
        List <String> listOptions = new List <String>();

        if(count > 0){
            for(Integer i = 1 ; i <= count.intValue(); i++){
                listOptions.add(String.valueOf(i));
            }
        }

        return listOptions;
    }

    @AuraEnabled
    public static SObject saveFields(String SObjectName, Map <String, Object> mapValues, Id recordId){
        return AP00_PM_UtilityMethods.saveFields(sObjectName, mapValues, recordId);
    }
    */
}