/**
 * [Class AP002_PMSelectedTubesCfgDeepCloneAgent : a clone agent that will deep clone the PM Selected Services Tubes Config]
 * @author EWA
 * @version 1.0   - Ready for UAT
 * @history 1.0   - Ready for UAT
 *          0.9.9 - Insert call to be done at another level
 *          0.9   - To be tested version
 *          0.6   - Linked the PM_Selected_Tubes_Config__c deep clone agent to the QuoteLineItem deep clone agent
 *          0.5   - Stub
 */
public class AP002_PMSelectedTubesCfgDeepCloneAgent extends APXXX_VirtualDeepCloneAgent {
    //Attributs of the class AP002_PMSelectedTubesCfgDeepCloneAgent
    private static String LOG_CLASS_NAME = 'AP002_PMSelectedTubesCfgDeepCloneAgent';

    /**
     * [ parentQliDeepCloneAgent : the deep clone agent for the parent quote line item ]
     */
    public AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent;

    //Constructors of the class AP002_PMSelectedTubesCfgDeepCloneAgent
    /**
     * [Constructor of the class AP002_PMSelectedTubesCfgDeepCloneAgent]
     * @param pmSelectedTubesConfig [PM_Selected_Tubes_Config__c : record for this object ]
     */
    public AP002_PMSelectedTubesCfgDeepCloneAgent(PM_Selected_Tubes_Config__c pmSelectedTubesConfig) {
        super(pmSelectedTubesConfig);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');
    }

    /**
     * [Constructor of the class AP002_PMSelectedTubesCfgDeepCloneAgent]
     * @param pmSelectedTubesConfig   [PM_Selected_Tubes_Config__c       : record for this object                ]
     * @param parentQliDeepCloneAgent [AP002_QuoteLineItemDeepCloneAgent : a deep clone agent for the parent qli ]
     */
    public AP002_PMSelectedTubesCfgDeepCloneAgent(PM_Selected_Tubes_Config__c pmSelectedTubesConfig, AP002_QuoteLineItemDeepCloneAgent parentQliDeepCloneAgent) {
        super(pmSelectedTubesConfig);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Start');

        this.parentQliDeepCloneAgent = parentQliDeepCloneAgent;

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor Stop');

    }

    //Methods of the class AP002_PMSelectedTubesCfgDeepCloneAgent
    /**
     * [ (override) deepClone : we need to clone the current object but also to run the deepClone on all
 	 *   the deep clone agent ]
 	 */
    public override void deepClone() {
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Start');

        this.clonedObject = this.objectToClone.clone(false, true, false, false);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Stop');
    }

    /**
     * [ (override) updateClonedObject : update the cloned object]
     */
    public override void updateClonedObject() {
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Start');
        /*TriggerHandler.clearBypass('PMSelectedTubesConfigTriggerHandler');
        TriggerHandler.bypass('QuoteLineItemTriggerHandler');*/

        PM_Tubes_Config__c pmTubeConfig;
        if (this.parentQliDeepCloneAgent != null) {
            if (this.parentQliDeepCloneAgent.clonedObject != null)
            this.clonedObject.put('Quote_item__c', this.parentQliDeepCloneAgent.clonedObject.Id);
            string[] tubesegment = this.clonedObject.get('Product_segment__c').toString().split(' ');
            if((this.clonedObject.get('Product_segment__c').equals('Plastic Tubes')||
                    this.clonedObject.get('Product_segment__c').equals('Laminate Tubes')) &&
                    this.clonedObject.get('Purefoil_Segment__c')==false) {
                try {
                    pmTubeConfig = [
                            select id,Resin_Index__c
                            from PM_Tubes_Config__c
                            where Table_Name__c in ('Platts base') AND Location__c = 'EU' AND ActiveValue__c = 'TRUE'
                            AND Tubes_segment__c = :tubesegment[0]
                            LIMIT 1
                    ];
                } catch (System.QueryException e) {
                    System.debug('caught ya!');
                }

                if (pmTubeConfig != null) {
                    this.clonedObject.put('Nouveau_Platts__c', pmTubeConfig.Resin_Index__c);


                }
            }


        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - updateClonedObject Stop');
    }
}