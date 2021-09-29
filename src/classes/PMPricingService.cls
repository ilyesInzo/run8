/**
* @description PM Pricing/corridor service
* @author Malha A.
* @date 20/01/2019 (Historization)
*/

public without sharing class PMPricingService {

    public static void checkDates(list<sObject> newPMPricing, String objectName, list<String> matchingCriteriaFields ) {
            // matching criteria are used to verify data integrity
            set<String> matchingCriteria = new set<String>(); 
            map<String, sObject> mapMatchingCriteria2PM = new map<String, sObject>();
            String thirdField;

            for (sObject pm : newPMPricing){
                String concat = getMatchingCriteria(matchingCriteriaFields, pm);
                System.debug('concat: '+ concat);
                matchingCriteria.add(concat);
                mapMatchingCriteria2PM.put(concat, pm);
            }
            System.debug('matchingCriteria: '+ matchingCriteria);

            // Get Existing prices 
            String query = 'select Id, Matching_Criteria__c, Valid_From__c, Valid_To__c, Closed_Price__c from '+ objectName+ 
                           ' where Matching_Criteria__c in: matchingCriteria';
            
            list<sObject> existingPricng = Database.query(query);

            System.debug('existingPricng: '+ existingPricng);
            map<String, boolean> doNotInsert = new map<String, boolean>();
            list<sObject> toUpdate = new list<sObject>();

            // Check if we have to update Valid To Date on existing princing/Corridor or block inserted record
            for (sObject currentPM: existingPricng){
                sObject newPM = mapMatchingCriteria2PM.get((String)currentPM.get('Matching_Criteria__c'));
                if (!checkValidDates (newPM, currentPM)){
                    doNotInsert.put((String) currentPM.get('Matching_Criteria__c'), true);
                }else {
                    if(((Date)currentPM.get('Valid_To__c')).year() == Integer.valueOf(Label.Historization_End_Date)){           
                        currentPM.put('Valid_To__c', ((Date) newPM.get('Valid_From__c')).addDays(-1)) ;
                        currentPM.put('Closed_Price__c', true);
                        toUpdate.add(currentPM);
                    }
                }
            }

            update toUpdate;
            System.debug('TO UPDATE: '+toUpdate);
            // If inserted record must be blocked, Do_not_insert__c field is updated to True. 
            // A validation rule is used to throw error in this case
            for (sObject pm:newPMPricing){
                String concat = getMatchingCriteria(matchingCriteriaFields, pm);

                if (doNotInsert.get(concat) == true){
                    pm.put('Do_not_insert__c', true) ;
                }
            }


    }


    public static String  getMatchingCriteria(list<String> matchingCriteriaFields, sObject pMPricing){
            String result = (String) pMPricing.get(matchingCriteriaFields[0]);
            for (integer i=1; i<matchingCriteriaFields.size(); i++){
                  String toAdd = pMPricing.get(matchingCriteriaFields[i])!= null?(String)pMPricing.get(matchingCriteriaFields[i]):'' ;
                  result += '_' + toAdd;
              
            }
            return result;
    }

    public static boolean checkValidDates (sObject newPM , sObject currentPM){
          boolean result;
          if (((Date)newPM.get('Valid_From__c') <= (Date)currentPM.get('Valid_To__c')
                     &&  (Date) newPM.get('Valid_From__c') >= (Date) currentPM.get('Valid_From__c')
                    && ((Date)currentPM.get('Valid_To__c')).year() != Integer.valueOf(Label.Historization_End_Date)) 
                    || ((Date) newPM.get('Valid_To__c') == (Date) currentPM.get('Valid_To__c') && 
                     (Date) newPM.get('Valid_From__c') == (Date) currentPM.get('Valid_From__c') )){

                result = false;
          }
          else {
                result = true;
          }

          return result;
    }
}