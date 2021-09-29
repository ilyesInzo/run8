/**
 * @description Controller class used by PriceMatrix
 * @author EWA
 * @version 1.1
 * @history 1.1 - Refactoring
 *          1.0 - Initial version
 * @remark  L55, L143, L146 ==> actuatorversion not an external variable so value is known before execution
 */
public class AP00_LotionLeadTime{
    //Static Method for the AP00_LotionLeadTime
    public static void calcLotionLeadTime(PM_Selected_Dipsensing_config__c seldisp){
        List<String> values;
        
        //engine type
        String enginetype = '';
        values = LC00_ServicePicklistCtrl.getValues('PM_Lean_config__c', 'LeadTime__c', 
                new Map<String,String>{'Product_Segment__c' => 'Lotion pumps', 
                'Location__c' => 'EU', 
                'Table_Name__c' => 'Engine',                                        
                'Engine_Name__c' => seldisp.Engine_Name__c
                });
        for(String s : values){
            enginetype = s;
        }
        
        //Neck finish        
        String neckfinish = '';
        values = LC00_ServicePicklistCtrl.getValues('PM_Lean_config__c', 'LeadTime__c', 
                new Map<String,String>{'Product_Segment__c' => 'Lotion pumps', 
                'Location__c' => 'EU', 
                'Table_Name__c' => 'Neck Finishing',                                        
                'Neck_Finish__c' => seldisp.Neck_Finish__c
                });
        for(String s : values){
            neckfinish = s;
        }
                
        //shape
        Integer shape = SObjectUtils.getCorrespondingCode(seldisp.Collar__c, 'Concave');
        
        //Actuator diameter         
        string actuatorconcat = seldisp.Engine_Name__c + '_' + seldisp.Pump_Segmentation__c + '_' + seldisp.Attachment__c + '_' + seldisp.Neck_Finish__c + '_' + seldisp.Product_Type__c;
        string actuatordiameter = '';
        values = LC00_ServicePicklistCtrl.getValues('PM_Lean_config__c', 'LeadTime__c', 
                new Map<String,String>{'Product_Segment__c' => 'Lotion pumps', 
                'Location__c' => 'EU', 
                'Table_Name__c' => 'Actuator type',                                        
                'Concatenate__c' => actuatorconcat
                });
        for(String s : values){
            actuatordiameter = s;
        }
        
        //specific actuator version        
        //string actuatorversion = '3';
        
        //Lockable
        Integer lockable = SObjectUtils.getCorrespondingCode(seldisp.Lockability__c, 'Non lockable');
        
        //cap
        string cap = '';        
        values = LC00_ServicePicklistCtrl.getValues('PM_Lean_config__c', 'LeadTime__c', 
                new Map<String,String>{'Product_Segment__c' => 'Lotion pumps', 
                'Location__c' => 'EU', 
                'Table_Name__c' => 'Cap',                                        
                'Cap__c' => seldisp.Cap__c
                });
        for(String s : values){
            cap = s;
        }
        
        
        //Bague de purge        
        Integer baguedepurge = SObjectUtils.getCorrespondingCode(seldisp.Purge_Ring__c, 'No');
        
        //Sleeved pump
        Integer sleevedpump = SObjectUtils.getCorrespondingCode(seldisp.Plastic_Protection__c, 'No');
        
        //Montage moteur Néa par le dessous dans une bague GCMI
        Integer Montagemoteur = SObjectUtils.getCorrespondingCode(seldisp.NEA_below_GCMI__c, 'No');
        
        //Dispenser tube
        Integer Dispensertube = SObjectUtils.getCorrespondingCode(seldisp.Dispenser_tube__c, 'No');
        
        //Average : 1 order every N weeks 
        Decimal averagepw = 0;        
        for(PM_Review_NetPrice_per_MOQ__c nprice : [select Quote_Line_Item__r.Annual_Volume__c,MOQ_Units__c from PM_Review_NetPrice_per_MOQ__c where Selected__c =true and Quote_Line_Item__c =:seldisp.Quote_item__c]){
            try{
                averagepw = (52 / (nprice.Quote_Line_Item__r.Annual_Volume__c / nprice.MOQ_Units__c)).setScale(2);
            }
            Catch(Exception e){
                averagepw = 0;
            }
        }
        
        // supply chain policy trigger frequency
        Decimal frequency = 6;
        
        //Engine : NEA or SP3
        Boolean engine = (enginetype == '' || enginetype == 'NEA');
        
        //Neck : F0 or FEA all Æ or TCS Æ 13 or 15 [includes GPI] or GCMI all Æ or M17 M17-24 M19E M19-21 M19-21E
        Boolean Neck = false;
        values = LC00_ServicePicklistCtrl.getValues('PM_Lean_config__c', 'Standard__c', 
                new Map<String,String>{'Product_Segment__c' => 'Lotion pumps', 
                'Location__c' => 'EU', 
                'Table_Name__c' => 'Neck Lotion Standard',                                        
                'Lotion__c' => neckfinish
                });
        for(String s : values){
            Neck = boolean.ValueOf(s);
        }
        
        //Maximum 2 finishing operation steps
        Boolean maxfinish = true;
        
        //No manual operation
        Boolean nomanualope = !('SP2SP3'.contains(enginetype.left(3)) && lockable == 2);
        
        //No subcontracted process step
        Boolean nosubcon = ((sleevedpump == 1 && Dispensertube == 1) || (sleevedpump == 0 || Dispensertube == 0));

        //LP theoretical
        Integer lptheo = (engine && Neck && maxfinish && nomanualope && nosubcon)?1:3;
        
        
        //LP1 : any pump with 4275 cap
        boolean LP1 = (cap == '4275 cap');
        
        //LP2 : concave neck
        boolean LP2 = (shape == 2);
        
        //LP3 : SP3 neck FEA/TCS17
        boolean LP3 = (enginetype.left(3) == 'SP3' && neckfinish == 'TCS17');
        
        //LP5 : SP343 M17 cylindrical with bague de purge
        boolean LP5 = (enginetype.left(5) == 'SP343' && neckfinish == 'M17' && shape == 1 && baguedepurge == 2);
        
        //LP6 : actuator Æ 10
        boolean LP6 = (actuatordiameter == '14mm');
        
        //LP7 : old versions of actuators
        //boolean LP7 = (actuatorversion == '2');       actuatorversion is defined with the value '3' at line 55 so LP7 == False
        
        //LP8 : fine mist versions of actuators
        //boolean LP8 = (actuatorversion == '1');       actuatorversion is defined with the value '3' at line 55 so LP8 == False
        
        //LP9 : Mini-Nea
        boolean LP9 = (enginetype == 'NEA' && neckfinish == 'M17' );
        
        //LP10 : Nea with SP3 finishing
        boolean LP10 = (enginetype.left(3) == 'NEA' && Montagemoteur == 2);
        
        //L>P
        //This is an Multi-OR so false is an invariant
        //boolean LP = (LP1 || LP2 || LP3 || LP5 || LP6 || LP7 || LP8 || LP9 || LP10);
        boolean LP = (LP1 || LP2 || LP3 || LP5 || LP6 || LP9 || LP10);
        
        
        //PL1 : SP2 necks GCMI 20/22/24-410 except actuator Æ 16
        Boolean PL1 = (enginetype == 'SP2' && maxfinish && nomanualope  && nosubcon  && actuatordiameter != '16mm' && (neckfinish == 'GCMI 20-410' || neckfinish == 'GCMI 22-410'  || neckfinish == 'GCMI 24-410'));
               
        //PL2 : Dispenser tubes Nea and SP3
        Boolean PL2 = (engine && Dispensertube == 2);
        
        //PL3 : Premium only because of sleevage being the last process step
        Boolean PL3 = (engine && Neck && maxfinish && nomanualope && sleevedpump == 2 && Dispensertube == 1);
        
        //PL4 : SP343A M19-21 or M1921E Premium only because of 3 finishing steps
        
        //PL5 : SP3 neck FITME
        Boolean PL5 = (enginetype.left(3) == 'SP3' && neckfinish == 'FITME');
        
        //PL6 : SP3 neck GCMI18-400 cylindrical
        Boolean PL6 = (enginetype.left(3) == 'SP3' && neckfinish == 'GCMI 18-400' && shape == 1);
        
        //PL7 : SP3 neck M17-21 lockable
        Boolean PL7 = (enginetype.left(3) == 'SP3' && neckfinish == 'M17-21' && lockable == 2);
        
        //P>L
        Boolean PL = (PL1 || PL2 || PL3 || PL5 || PL6 || PL7);
        
        
        //(L>P being stronger than P>L)
        Integer lpstrongerpl = 0;
        if(lptheo == 1){
            lpstrongerpl = (LP)?3:1;
        }
        else if(lptheo == 3){
            lpstrongerpl = (PL && !LP)?3:1;
        }
        
        //Lean being adjusted upon average customer demand
        string lean = '';
        if(lpstrongerpl == 1){
            lean = (averagepw <= frequency)?'LEAN':'LEAN_LFLD';
        }
        else if(lpstrongerpl == 3){
            lean = 'PREMIUM';
        }
        system.debug('**************lean***********************' + lean);
        seldisp.Lean_possibility__c = lean;
        
    }

}