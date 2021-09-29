public class LC01_ProductConfig_SpecPreconfigCtrl {


	@AuraEnabled
	public static list<PM_SpecPreconfig__c> getPreconfig(String location, String productSegment){

		list<PM_SpecPreconfig__c> existingPreconfig = [select Id,Name, Name__c, Configuration__c, Configuration_2__c, Configuration_3__c, Configuration_4__c
		from PM_SpecPreconfig__c
		where location__c = :location
		and Product_Sub_Segment__c =: productSegment
		order by Name];

		return existingPreconfig;
	}

	@AuraEnabled
	public static sObject setFieldsValue(sObject selectedConfig, String configuration, String configuration2, String configuration3, String configuration4){

		if (configuration2 != null) configuration = configuration + ';' +  configuration2;
		if (configuration3 != null) configuration = configuration + ';' +  configuration3;
		if (configuration4 != null) configuration = configuration + ';' +  configuration4;
		list<String> separatedFields = configuration.split(';');

		map<String, String> fieldsToSet = new map<String, String>();
		for (String subList:separatedFields){
			list<String> valueMapping = subList.split('=');
			fieldsToSet.put(valueMapping[0],valueMapping[1] );
			//selectedConfig = assignIgnoreNull('PM_Selected_Tubes_Config__c',selectedConfig,valueMapping[0],valueMapping[1]);

		}

		Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(String.ValueOf(selectedConfig.getSObjectType())).getDescribe().fields.getMap();
		List<String> editableFields = new List<String>();
		for(Schema.SObjectField fieldRef : fields.values()) {
			Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();

			if(fieldResult.isUpdateable() && (fieldResult.getType() == Schema.DisplayType.Double ||
					fieldResult.getType() == Schema.DisplayType.String  ||
					fieldResult.getType() == Schema.DisplayType.PICKLIST
			) && fieldResult.getType() != Schema.DisplayType.REFERENCE
					&& fieldResult.getName() != 'Location__c'
					&& fieldResult.getName() != 'Product_segment__c'
					&& fieldResult.getName() != 'Delivery__c'
					&& fieldResult.getName() != 'Destination__c'
					&& fieldResult.getName() != 'Is_Combo__c'
					&& fieldResult.getName() != 'Combo_Num_Versions__c'
					&& fieldResult.getName() != 'Combo_Num_Plate_Changes__c'
					&& fieldResult.getName() != 'Combo_Num_Tubes_Artwork__c'
					&& fieldResult.getName() != 'Payment_terms__c'
					&& fieldResult.getName() != 'Stockage__c'
					&& fieldResult.getName() != 'Nouveau_Platts__c'
					&& fieldResult.getName() != 'Incoterm__c'
					&& fieldResult.getName() != 'Zip_Code__c'
					&& fieldResult.getName() != 'Quality_Level__c'
					&& fieldResult.getName() != 'Resin_Index__c'
					&& fieldResult.getName() != 'Number_of_ref_per_run__c'
					&& fieldResult.getName() != 'Number_of_tubes_per_artwork_in_Ku__c'
					&& fieldResult.getName() != 'Head__c'







					) {

				editableFields.add(fieldResult.getname());

			}
		}

		for(String fieldName:editableFields){
			if (fieldsToSet.get(fieldName) != null){

				selectedConfig = assignIgnoreNull(String.ValueOf(selectedConfig.getSObjectType()),selectedConfig,fieldName,fieldsToSet.get(fieldName));
			}else {
				selectedConfig.put(fieldName, null);
			}
		}
		selectedConfig.put('Is_from_preconfig__c' ,true);

		return selectedConfig;
	}


	public static sObject assignIgnoreNull(String typeObj, sObject obj, String fieldName, Object value) {
		if (value != null) {
			Schema.DescribeFieldResult descr;
			if (typeObj.equalsIgnoreCase('PM_Selected_Tubes_Config__c')) {
				descr = Schema.SObjectType.PM_Selected_Tubes_Config__c.fields.getMap().get(fieldName).getDescribe();
			} else if (typeObj.equalsIgnoreCase('PM_Selected_Dipsensing_config__c')) {
				descr = Schema.SObjectType.PM_Selected_Dipsensing_config__c.fields.getMap().get(fieldName).getDescribe();
			}
			Schema.DisplayType type = descr.getType();
			if ( type == Schema.DisplayType.DateTime) {
				DateTime 	dateGMT = getDateTime(value);
				obj.put(fieldName, dateGMT);
			} else {
				if ( type == Schema.DisplayType.Date) {
					obj.put(fieldName, Date.valueOf(String.valueOf(value)));
				} else {
					if (type == Schema.DisplayType.Double) {
						obj.put(fieldName, Integer.valueOf(value));
					} else {
						if (type == Schema.DisplayType.String) {
							obj.put(fieldName, String.valueOf(value).left(descr.getLength()));
						} else {
							if (type == Schema.DisplayType.Currency) {
								obj.put(fieldName, Decimal.valueOf(String.valueOf(value)));

							} else {
								obj.put(fieldName, value);
							}
						}
					}

				}

			}

		}

		return obj;


	}

	public static DateTime getDateTime(Object value){
		DateTime 	dateTimeZone 	= DateTime.valueOfGmt(String.valueOf(value).left(19).replace('T', ' '));
		Integer 	hoursOffset 	= Integer.valueOf(String.valueOf(value).substring(20, 22));
		Integer 	minutesOffset 	= Integer.valueOf(String.valueOf(value).substring(22, 24));
		String  	sign 			= String.valueOf(value).substring(19, 20);
		DateTime 	dateGMT			= (sign.equals('+') ?
				(dateTimeZone.addMinutes(-minutesOffset).addHours(-hoursOffset)) :
				(dateTimeZone.addMinutes(minutesOffset).addHours(hoursOffset)));
		return dateGMT;
	}

	@AuraEnabled
	public static sObject resetConfig(sObject selectedConfig){
		Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(String.ValueOf(selectedConfig.getSObjectType())).getDescribe().fields.getMap();
		List<String> editableFields = new List<String>();
		for(Schema.SObjectField fieldRef : fields.values()) {
			Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
			if(fieldResult.isUpdateable() && (fieldResult.getType() == Schema.DisplayType.Double ||
					fieldResult.getType() == Schema.DisplayType.String ||
					fieldResult.getType() == Schema.DisplayType.PICKLIST

			) && fieldResult.getType() != Schema.DisplayType.REFERENCE
					&& fieldResult.getName() != 'Location__c'
					&& fieldResult.getName() != 'Product_segment__c'
					&& fieldResult.getName() != 'Delivery__c'
					&& fieldResult.getName() != 'Destination__c'
					&& fieldResult.getName() != 'Is_Combo__c'
					&& fieldResult.getName() != 'Combo_Num_Versions__c'
					&& fieldResult.getName() != 'Combo_Num_Plate_Changes__c'
					&& fieldResult.getName() != 'Combo_Num_Tubes_Artwork__c'
					&& fieldResult.getName() != 'Payment_terms__c'
					&& fieldResult.getName() != 'Stockage__c'
					&& fieldResult.getName() != 'Nouveau_Platts__c'
					&& fieldResult.getName() != 'Incoterm__c'
					&& fieldResult.getName() != 'Zip_Code__c'
					&& fieldResult.getName() != 'Quality_Level__c'
					&& fieldResult.getName() != 'Resin_Index__c'
					&& fieldResult.getName() != 'Number_of_ref_per_run__c'
					&& fieldResult.getName() != 'Number_of_tubes_per_artwork_in_Ku__c'




					) {
				editableFields.add(fieldResult.getname());
			}
		}

		for(String fieldName:editableFields){

			selectedConfig.put(fieldName, null);

		}
		selectedConfig.put('Is_from_preconfig__c' ,false);
		return selectedConfig;
	}
}