@isTest 
public class LC01_ProductConfig_SpecPreconfig_Test {

	@testSetup 
    public static void testSetup(){
    	insert new PM_SpecPreconfig__c(Name = 'SP34D Pump Only Essential', Location__c = 'EU', Product_Sub_Segment__c = 'Lotion',
                Configuration__c = 'Engine_Name__c=SP34D;Product_Type__c=Pump Only',
                Configuration_2__c='Pump_Segmentation__c=Essential;Attachment__c=Screw On',
                Configuration_3__c='Dispenser_tube__c=Yes;Neck_Finish__c=Europa 5',
                Configuration_4__c='Actuator__c=Soprano;Lockability__c=Lockable;Collar__c=Straight;Dosage__c=130µl;Cap__c=No');

     
    }

    static testmethod void test_getPreconfig() {
    	list<PM_SpecPreconfig__c> specPreconf = LC01_ProductConfig_SpecPreconfigCtrl.getPreconfig('EU', 'Lotion');
        System.assertEquals(specPreconf.size(), 1);
    }

    static testmethod void test_setFieldsValue() {
    	list<PM_SpecPreconfig__c> specPreconf = LC01_ProductConfig_SpecPreconfigCtrl.getPreconfig('EU', 'Lotion');
    	PM_Selected_Dipsensing_config__c selectedConfig = new PM_Selected_Dipsensing_config__c();
    	PM_Selected_Dipsensing_config__c result =
    					 (PM_Selected_Dipsensing_config__c) LC01_ProductConfig_SpecPreconfigCtrl.setFieldsValue(selectedConfig,specPreconf[0].configuration__c, specPreconf[0].configuration_2__c,
                                 specPreconf[0].configuration_3__c, specPreconf[0].configuration_4__c);
        System.assertEquals(result.Engine_Name__c , 'SP34D');
        System.assertEquals(result.Product_Type__c , 'Pump Only');
        System.assertEquals(result.Dosage__c , '130µl');

        result = (PM_Selected_Dipsensing_config__c) LC01_ProductConfig_SpecPreconfigCtrl.resetConfig(result);
        System.assertEquals(result.Engine_Name__c , null);
        System.assertEquals(result.Product_Type__c , null);
        System.assertEquals(result.Dosage__c , null);
    }

   
}