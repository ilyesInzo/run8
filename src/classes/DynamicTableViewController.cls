/**
 * Created by Thanina on 10/07/2019.
 */

public  class DynamicTableViewController {

    
	public static  Dynamic_List_View_Config__mdt configView;


	@AuraEnabled
	public static String getFieldSetDescription(String sObjectName, String fieldSetName) {
		
        if(Test.isRunningTest()){
          configView  = new Dynamic_List_View_Config__mdt(MasterLabel = 'List Manager 1',
                                                                              DeveloperName = 'List Manager 1',
                                                                              ObjectName__c = 'SalesTeam__c', 
																		      UniqueKeyObject__c = 'ListManager01', 
																		      ColumnsList__c = 'ObjectnotNull');
        }
        else{
          configView = [select ObjectName__c, UniqueKeyObject__c, ColumnsList__c, ViewFilters__c, ObjectFieldsName__c from Dynamic_List_View_Config__mdt where ObjectName__c = :sObjectName and UniqueKeyObject__c = :fieldSetName limit 1];  
        }
		//System.debug('@@display list column json:' +configView.ColumnsList__c );

		return (configView.ColumnsList__c.trim());
	}


	/**
	 *
	 *
	 * @param sObjectName
	 * @param queryFilters
	 * @param fieldNameJson : list of fields to return
	 *
	 * @return Json (list sObjects Records)
	 */
	@AuraEnabled
	public static String getsObjectsRecord(String sObjectName, String queryFilters, String fieldNameJson, String fieldSetName) {   
		String result=''; Integer countNBFilters=0;
        System.debug('IIII'+fieldNameJson);
        
        if(Test.isRunningTest()){
          configView  = new Dynamic_List_View_Config__mdt(MasterLabel = 'List Manager 1',
                                                                              DeveloperName = 'List Manager 1',
                                                                              ObjectName__c = 'SalesTeam__c', 
																		      UniqueKeyObject__c = 'ListManager01', 
																		      ColumnsList__c = 'ObjectnotNull',
                                                         						ViewFilters__c = '(Valid_To__c > = TODAY)');
        }
        else{
		configView = [select ObjectName__c, UniqueKeyObject__c, ColumnsList__c, ViewFilters__c, ObjectFieldsName__c from Dynamic_List_View_Config__mdt where ObjectName__c = :sObjectName and UniqueKeyObject__c = :fieldSetName limit 1];
        }
		List<sObject> lstResult = new List<sObject>();
		//System.debug('Json names: '+fieldNameJson);
		

		try{
			List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
			//System.debug('list names: '+fieldNames);
			// Set<String> setFieldNames = new Set<String>();
			String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;

			if(configView != null) {   

				if(!String.isBlank(configView.ViewFilters__c)) {
					countNBFilters = countNBFilters + 1;
					query += '  WHERE ' + (configView.ViewFilters__c.trim());
				}
				if(queryFilters != NULL && queryFilters.trim() != '') {

					if(countNBFilters != 0) 
						query += ' '+queryFilters.trim() ;
					else query += ' WHERE ' + queryFilters.trim() 
						;
					// countNBFilters = countNBFilters + 1;

				}

				System.debug('@@@@ query: '+query);
			} 
			else  System.debug('@@@@I am null');



			// if(!String.isBlank(configView.ViewFilters__c))
				//{ 
				System.debug('@@@@Inside Filters');
			// if(countNBFilters!=0) query += '  and ( '+ configView.ViewFilters__c.trim() + ' )';
			// else query += ' WHERE ' + configView.ViewFilters__c.trim();
			// }
			//  query += ' limit 10';
			/*for(sObject s : Database.query(query)){
			 lstResult.add(s);
			 }*/
			// query += '  limit 100';
			//query = query + ' limit 2000';
			lstResult = Database.query(query)
				;
			System.debug('@@@@size'+lstResult.size());
			if(lstResult.size() > 0) {
				// System.debug('ObjectList: '+lstResult);
				result = JSON.serialize(lstResult);
				// System.debug('JSON: '+result);
			} 
			else result='[]';
		} 
		catch(Exception e) {
			result += e.getLineNumber() + ' : ' + e.getMessage();
		}

		return result;
	}
	/**
	 *  Update Modified Records:
	 */
	/*@AuraEnabled
	public static void updateRecords(String updatedRecordsMap) {   
		System.debug('@@@@@@@list keys inside update : ' +updatedRecordsMap);
		// if(updatedRecordsMap.size() != 0) System.debug('@@@@@@Size: '+updatedRecordsMap.size());
	}*/

	@AuraEnabled
	public static void updateRecordsList(String sObjectRecordList) {
		System.debug('@@@@@@@list keys inside update : ' + sObjectRecordList);

		Map<String, SObject> listObjectToUP = (Map<String, SObject>)JSON.deserialize(sObjectRecordList, Map<String, SObject>.class);
		if(listObjectToUP!= null && listObjectToUP.size() > 0)

            /*for (SObject o :listObjectToUP.values) {
			 o.Approved__c = false;
			 o.rejected__c = false;
			 }*/
			update listObjectToUP.values();
        }
	
	// if(updatedRecordsMap.size() != 0) System.debug('@@@@@@Size: '+updatedRecordsMap.size());
}