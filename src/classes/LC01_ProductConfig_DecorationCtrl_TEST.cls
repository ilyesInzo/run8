@isTest
public class LC01_ProductConfig_DecorationCtrl_TEST {/*
    public static final String APPLICATOR = 'Applicator';
    public static final String ER3 = 'ER3';
    public static final String OFFSET = 'Offset';
    public static final String OFFSET_SS = 'Offset + Silkscreen';
    public static final String FLEXO = 'Flexo';
    public static final String FLEXO_SS = 'Flexo + Silkscreen';
    public static final String SILKSCREEN = 'Silkscreen';
    public static final String UNPRINTED = 'Unprinted';
    
    static testMethod void getColors_Test_PrintTech_IsOffset(){
        
        PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=13, Head_Name__c='CD1', Dispensing_System_Family__c='Twist-off', Location__c='EU');
        insert pms;
        
        Id pmsId = pms.Id;
        
        PM_Tubes_Config__c pmt = new PM_Tubes_Config__c(Offset__c=5, Flexo__c=0, Silkscreen__c=1, Flexo_Silkscreen__c=0, Offset_Silkscreen__c=0, Spec__c='13_CD1', Location__c='EU');
        insert pmt;
        
        List<Object> expList1 = new List<Object>{'1','2','3','4','5'};
        Map <String, Object> expMap = new Map<String, Object>();
        expMap.put(OFFSET, expList1);
        System.debug('####Expected Map: '+expMap);
        
        Test.startTest();
            Map<String, Object> testMap = new Map<String, Object>(LC01_ProductConfig_DecorationCtrl.getColors(pmsId, OFFSET));
        Test.stopTest();
        
        System.assertEquals(expMap, testMap);
        
    }
    
    static testMethod void getColors_Test_PrintTech_IsOffsetSS_and_OffsetSilkScreen_GreaterThanZero(){
        
        PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=25, Head_Name__c='CF6', Dispensing_System_Family__c='Nozzle', Location__c='EU');
        insert pms;
        
        Id pmsId = pms.Id;
        
        PM_Tubes_Config__c pmt = new PM_Tubes_Config__c(Offset__c=6, Flexo__c=0, Silkscreen__c=6, Flexo_Silkscreen__c=0, Offset_Silkscreen__c=4, Spec__c='25_CF6', Location__c='EU');
        insert pmt;
        
        List<Object> expList1 = new List<Object>{'1','2','3','4','5','6'};
        List<Object> expList2 = new List<Object>{'1','2','3','4'};
        Map <String, Object> expMap = new Map<String, Object>();
        expMap.put(OFFSET, expList1);
        expMap.put(SILKSCREEN, expList2);
        System.debug('####Expected Map: '+expMap);
        
        Test.startTest();
            Map<String, Object> testMap = new Map<String, Object>(LC01_ProductConfig_DecorationCtrl.getColors(pmsId, OFFSET_SS));
        Test.stopTest();
        
        System.assertEquals(expMap, testMap);
        
    }
    
    static testMethod void getColors_Test_PrintTech_IsFlexo(){
        PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=35, Head_Name__c='PC35', Dispensing_System_Family__c='Flip-top cap', Location__c='EU');
        insert pms;
        
        Id pmsId = pms.Id;
        
        PM_Tubes_Config__c pmt = new PM_Tubes_Config__c(Offset__c=7, Flexo__c=10, Silkscreen__c=6, Flexo_Silkscreen__c=3, Offset_Silkscreen__c=3, Spec__c='35_PC35', Location__c='EU');
        insert pmt;
        
        List<Object> expList1 = new List<Object>{'1','2','3','4','5','6','7','8','9','10'};
        Map <String, Object> expMap = new Map<String, Object>();
        expMap.put(FLEXO, expList1);
        System.debug('####Expected Map: '+expMap);
        
        Test.startTest();
            Map<String, Object> testMap = new Map<String, Object>(LC01_ProductConfig_DecorationCtrl.getColors(pmsId, FLEXO));
        Test.stopTest();
        
        System.assertEquals(expMap, testMap);
        
    }
    
    static testMethod void getColors_Test_PrintTech_IsFlexoSS_and_FlexoSilkScreen_GreaterThanZero(){
        
        PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=25, Head_Name__c='CF151', Dispensing_System_Family__c='Nozzle', Location__c='EU');
        insert pms;
        
        Id pmsId = pms.Id;
        
        PM_Tubes_Config__c pmt = new PM_Tubes_Config__c(Offset__c=6, Flexo__c=4, Silkscreen__c=3, Flexo_Silkscreen__c=3, Offset_Silkscreen__c=0, Spec__c='25_CF151', Location__c='EU');
        insert pmt;
        
        List<Object> expList1 = new List<Object>{'1','2','3','4'};
        List<Object> expList2 = new List<Object>{'1','2','3'};
        Map <String, Object> expMap = new Map<String, Object>();
        expMap.put(OFFSET, expList1);
        expMap.put(SILKSCREEN, expList2);
        System.debug('####Expected Map: '+expMap);
        
        Test.startTest();
            Map<String, Object> testMap = new Map<String, Object>(LC01_ProductConfig_DecorationCtrl.getColors(pmsId, FLEXO_SS));
        Test.stopTest();
        
        System.assertEquals(expMap, testMap);
    }
    
    static testMethod void getColors_Test_PrintTech_IsSilkScreen(){
        
        PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=16, Head_Name__c='M9', Dispensing_System_Family__c='Screw head', Location__c='EU');
        insert pms;
        
        Id pmsId = pms.Id;
        
        PM_Tubes_Config__c pmt = new PM_Tubes_Config__c(Offset__c=6, Flexo__c=4, Silkscreen__c=3, Flexo_Silkscreen__c=3, Offset_Silkscreen__c=0, Spec__c='16_M9', Location__c='EU');
        insert pmt;
        
        List<Object> expList1 = new List<Object>{'1','2','3'};
        Map <String, Object> expMap = new Map<String, Object>();
        expMap.put(SILKSCREEN, expList1);
        System.debug('####Expected Map: '+expMap);
        
        Test.startTest();
            Map<String, Object> testMap = new Map<String, Object>(LC01_ProductConfig_DecorationCtrl.getColors(pmsId, SILKSCREEN));
        Test.stopTest();
        
        System.assertEquals(expMap, testMap);
    }
    
    static testMethod void getColors_Test_TernaryCond_IfTrue(){
        
        PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=50, Head_Name__c='ER3', Dispensing_System_Family__c=APPLICATOR, Location__c='EU');
        insert pms;
        
        Id pmsId = pms.Id;
        
        PM_Tubes_Config__c pmt = new PM_Tubes_Config__c(Offset__c=6, Flexo__c=4, Silkscreen__c=3, Flexo_Silkscreen__c=3, Offset_Silkscreen__c=4, Spec__c='50_ER3YES', Location__c='EU');
        insert pmt;
        
        List<Object> expList1 = new List<Object>{'1','2','3'};
        Map <String, Object> expMap = new Map<String, Object>();
        expMap.put(SILKSCREEN, expList1);
        System.debug('####Expected Map: '+expMap);
        
        Test.startTest();
            Map<String, Object> testMap = new Map<String, Object>(LC01_ProductConfig_DecorationCtrl.getColors(pmsId, SILKSCREEN));
        Test.stopTest();
        
        System.assertEquals(expMap, testMap);
    }
    
    static testmethod void saveFields_Test(){
        Map<String, Object> testMap = new Map<String, Object>();
        //Diameter_mm__c=16, Head_Name__c='M9', Dispensing_System_Family__c='Screw head', Location__c='EU'
        testMap.put('Diameter_mm__c', 16);
        testMap.put('Head_Name__c', 'M9');
        testMap.put('Dispensing_System_Family__c', 'Screw head');
        testMap.put('Location__c', 'EU');
        
        sObject s = new PM_Selected_Tubes_Config__c(Diameter_mm__c=16, Head_Name__c='M9', Dispensing_System_Family__c='Screw head', Location__c='EU');
        insert s;
        
        Id sId = s.Id;
        
        List<PM_Selected_Tubes_Config__c> s_list = [SELECT Id, 
                                        Diameter_mm__c,
                                        Head_Name__c,
                                        Dispensing_System_Family__c,
                                        Location__c
                                FROM PM_Selected_Tubes_Config__c
                                WHERE Id=:s.Id];
        
        Test.startTest();
            PM_Selected_Tubes_Config__c s_test = (PM_Selected_Tubes_Config__c)LC01_ProductConfig_DecorationCtrl.saveFields('PM_Selected_Tubes_Config__c', testMap, sId);
        Test.stopTest();
        
        System.assertEquals(s_list[0], s_test); 
    }*/
}