public with sharing class LC01_SelectedProductConfigCtrl {

    @AuraEnabled
    public static sObject getSelectedConfig(Sobject so, Map<String, Object> mapfilters) {
        system.debug('*******mapfilters********' + mapfilters);
        string objectname = String.ValueOf(so.getSObjectType());
        String sQuery = AP00_PM_UtilityMethods.getAllFieldsForSOQL(objectname);

        string filters = '';

        if (sQuery != null) {

            for (String key : mapfilters.keySet()) {
                if (key != 'NOTNULL') {
                    string retval = (mapfilters.get(key) instanceof String && mapfilters.get(key) != 'true' && mapfilters.get(key) != 'false') ? '\'' + String.ValueOf(mapfilters.get(key)) + '\'' : String.ValueOf(mapfilters.get(key));

                    filters += (filters == '') ? ' WHERE ' + key + ' = ' + retval : ' AND ' + key + ' = ' + retval ;
                    //filters += (filters == '')?' WHERE ' + key + ' = \'' + mapfilters.get(key) + '\'':' AND ' + key + ' = \'' + mapfilters.get(key) + '\'';
                } else {
                    if (String.ValueOf(mapfilters.get(key)) != '')
                        filters += ' AND ' + String.ValueOf(mapfilters.get(key)) + ' = null' ;
                }
            }


            sQuery += filters ;
            sQuery += ' order by createdDate DESC, lastModifiedDate DESC ' ;
            system.debug('**********sQuery ******' + sQuery);

            for (SObject config : Database.query(sQuery)) {
                system.debug('**********config ******' + config);
                return config;
            }
        }

        sObject sObj = Schema.getGlobalDescribe().get(objectname).newSObject();

        for (String key : mapfilters.keySet()) {
            if (key != 'NOTNULL')
                sObj.put(key, mapfilters.get(key));
        }
        insert sObj;

        // return the record with all Fields in simulations case
        if (mapfilters.containsKey('Quote_item__c')) {
            List<QuoteLineItem> qlis = [select id,QuoteId, Quote.status from QuoteLineItem where id = :String.valueOf(mapfilters.get('Quote_item__c'))];
            if (qlis.size() > 0 && qlis[0].Quote.status == 'Simulation') {
                SObject config = Database.query(sQuery);

                system.debug('**********new sObj******' + config);
                return config;
            }
        }

        system.debug('**********new sObj******' + sObj);
        return sObj;
    }

    @AuraEnabled
    public static Sobject saveSelectedConfig(Sobject so) {

        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(String.ValueOf(so.getSObjectType())).getDescribe().fields.getMap();
        List<String> editableFields = new List<String>();
        for (Schema.SObjectField fieldRef : fields.values()) {
            Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
            if (fieldResult.isUpdateable() && (fieldResult.getType() == Schema.DisplayType.Double ||
                    fieldResult.getType() == Schema.DisplayType.String ||
                    fieldResult.getType() == Schema.DisplayType.PICKLIST
            ) && fieldResult.getType() != Schema.DisplayType.REFERENCE
                    && fieldResult.getName() != 'Location__c'
                    && fieldResult.getName() != 'Product_segment__c'
                    ) {
                editableFields.add(fieldResult.getname());
            }
        }

        if (String.ValueOf(so.getSObjectType()) == 'PM_Selected_Tubes_Config__c' || String.ValueOf(so.getSObjectType()) == 'PM_Selected_Dipsensing_config__c') {
            for (String fieldName : editableFields) {
                if (so.get(fieldName) == null) {
                    so.put(fieldName, null);
                }
            }
        }
        upsert so;

        Id soId = so.Id;
        if (String.ValueOf(so.getSObjectType()) == 'PM_Selected_Service_Tubes_Config__c') {
            String sQuery = AP00_PM_UtilityMethods.getAllFieldsForSOQL('PM_Selected_Service_Tubes_Config__c');
            sQuery += ' WHERE Id =: soId';
            for (SObject updatedso : Database.query(sQuery)) {
                return updatedso;
            }
        }

        return so;
    }
    @AuraEnabled
    public static List<sObject> getMOQ(Id qliId) {
        System.debug('@@@@@ qliId: ' + qliId);
        /*just to correct the  problem of duplicated pm selected tube config (for the copyquote cases) in product ==> to be deleted when this problem is resolved to optimise the code  */
        PM_Selected_Tubes_Config__c pm = [SELECT Id FROM PM_Selected_Tubes_Config__c WHERE Quote_item__c = :qliId order by createddate DESC NULLS Last, LastModifiedDate DESC NULLS Last limit 1];
        if (pm != null) {
            return [
                    select Id, MOQ_Max__c, MOQ__c, List_Price__c, Billing_Currency__c
                    from PM_MOQ_price__c
                    where Quote_item__c = :qliId and PM_Selected_Tubes_Config__c = :pm.id
                    order by MOQ_Min__c
            ];
        }
        return [
                select Id, MOQ_Max__c, MOQ__c, List_Price__c, Billing_Currency__c
                from PM_MOQ_price__c
                where Quote_item__c = :qliId
                order by MOQ_Min__c
        ];

    }
    @AuraEnabled
    public static List<sObject> getsObjectList(string objectname, Map<String, String> mapfilters, string orderby) {
        system.debug('**********mapfilters******' + mapfilters);
        String sQuery = AP00_PM_UtilityMethods.getAllFieldsForSOQL(objectname);

        string filters = '';
        List<sObject> sobjectlist = new List<sObject>();
        if (sQuery != null) {

            for (String key : mapfilters.keySet()) {
                filters += (filters == '') ? ' WHERE ' + key + ' = \'' + mapfilters.get(key) + '\'' : ' AND ' + key + ' = \'' + mapfilters.get(key) + '\'';
            }

            sQuery += filters ;

            sQuery += (orderby != '' && orderby != null) ? (' order by ' + orderby) : '';

            system.debug('**********sQuery ******' + sQuery);
            for (SObject config : Database.query(sQuery)) {
                system.debug('**********config ******' + config);
                sobjectlist.add(config);
            }
        }

        return sobjectlist;
    }


    @AuraEnabled
    public static Map <String, List<Integer>> getColors(PM_Selected_Tubes_Config__c selcon, string segment) {
        system.debug('******getColorsUS***Diameter_mm__c*****' + selcon.Diameter_inches__c);
        system.debug('******getColorsUS***Printing_type__c*****' + selcon.Printing_type__c);
        string selectedvalue = (selcon.Printing_type__c == null) ? '' : selcon.Printing_type__c;
        /*
         PM_Selected_Tubes_Config__c selcon = new PM_Selected_Tubes_Config__c();

         for(PM_Selected_Tubes_Config__c sel : [Select Id, Diameter_inches__c, Head_Name__c, Product_segment__c, Location__c from PM_Selected_Tubes_Config__c where Id =:selectedconId]){
             selcon = sel;
            system.debug('******colors*Selected_Tubes_Config*******'+ sel );
         }
         */
        Map <String, List<Integer>> mapcolors = new Map <String, List<Integer>>();
        mapcolors.put('NB_Offset_Colors__c', new List<Integer>());
        mapcolors.put('NB_Flexo_Colors__c', new List<Integer>());
        mapcolors.put('NB_SS_Colors__c', new List<Integer>());
        string spec = selcon.Diameter_inches__c + '_' + selcon.Head_Name__c;
        /*string segment = '';
        segment = (selcon.Product_segment__c == 'Plastic Tubes')?'Plastic':segment;
        segment = (selcon.Product_segment__c == 'Laminate Tubes')?'Laminate':segment;*/

        for (PM_Tubes_Config__c tube : [
                Select Offset__c, Flexo__c, Silkscreen__c, Spec__c
                from PM_Tubes_Config__c
                where Spec__c = :spec and Active__c = true and
                Location__c = :selcon.Location__c and Tubes_Segment__c = :segment and Table_Name__c = 'Deco # Colors Possibility (full path)'
        ]) {

            system.debug('******colors*found*******' + tube);
            if (selectedvalue.contains('Offset')) {
                integer offset = (tube.Offset__c == null) ? 0 : integer.valueOf(tube.Offset__c);
                mapcolors.put('NB_Offset_Colors__c', getColorOptions(offset));
            }
            if (selectedvalue.contains('Flexo')) {
                integer flexo = (tube.Flexo__c == null) ? 0 : integer.valueOf(tube.Flexo__c);
                mapcolors.put('NB_Flexo_Colors__c', getColorOptions(flexo));
            }
            if (selectedvalue.contains('Silkscreen')) {
                integer Silkscreen = (tube.Silkscreen__c == null) ? 0 : integer.valueOf(tube.Silkscreen__c);
                mapcolors.put('NB_SS_Colors__c', getColorOptions(Silkscreen));
            }

        }
        system.debug('******mapcolors********' + mapcolors);

        return mapcolors;
    }


    @AuraEnabled
    public static Map <String, List<Integer>> getPlasticTubeEUColors(PM_Selected_Tubes_Config__c selcon, string segment) {
        system.debug('******getPlasticTubeEUColors***Diameter_mm__c*****' + selcon.Diameter_mm__c);
        system.debug('******getPlasticTubeEUColors***Printing_technologies__c*****' + selcon.Printing_technologies__c);
        string selectedvalue = selcon.Printing_technologies__c;
        /*
        PM_Selected_Tubes_Config__c selcon = new PM_Selected_Tubes_Config__c();
        
        for(PM_Selected_Tubes_Config__c sel : [Select Id, Diameter_mm__c, Head_Name__c, Dispensing_System_Family__c, Product_segment__c, Location__c from PM_Selected_Tubes_Config__c where Id =:selectedconId]){
           selcon = sel;
           system.debug('******colors*Selected_Tubes_Config*******'+ sel );                   
        }
        */
        Map <String, List<Integer>> mapcolors = new Map <String, List<Integer>>();
        mapcolors.put('NB_Offset_Colors__c', new List<Integer>());
        mapcolors.put('NB_Flexo_Colors__c', new List<Integer>());
        mapcolors.put('NB_SS_Colors__c', new List<Integer>());

        String spec = '';
        if (selcon.Diameter_mm__c == 50 && selcon.Head_Name__c == 'ER3') {
            spec = selcon.Dispensing_System_Family__c == 'Applicator' ? '50_ER3YES' : '50_ER3NO';
        } else {
            spec = String.valueOf(selcon.Diameter_mm__c) + '_' + selcon.Head_Name__c;
        }


        if (String.isNotBlank(spec)) {
            // GDO - TODO : Further filters may be needed later
            //updated for ticket 6631.
            for (PM_Tubes_Config__c tubeConfig : [
                    select Spec__c, Offset__c, Flexo__c,
                            Silkscreen__c, Flexo_Silkscreen__c, Offset_Silkscreen__c
                    from PM_Tubes_Config__c
                    where Location__c = :selcon.Location__c
                    and Active__c = true and Spec__c = :spec and Tubes_Segment__c = :segment and table_name__c = 'Deco NB Colors Possibility'
            ]) {
                if (selectedvalue == 'Offset') {
                    mapcolors.put('NB_Offset_Colors__c', getColorOptions(Integer.ValueOf(tubeConfig.Offset__c)));
                } else if (selectedvalue == 'Offset + Silkscreen') {
                    if (tubeConfig.Offset_Silkscreen__c > 0) {
                        mapcolors.put('NB_Offset_Colors__c', getColorOptions(6));
                    }
                    mapcolors.put('NB_SS_Colors__c', getColorOptions(Integer.ValueOf(tubeConfig.Offset_Silkscreen__c)));
                } else if (selectedvalue == 'Flexo') {
                    mapcolors.put('NB_Flexo_Colors__c', getColorOptions(Integer.ValueOf(tubeConfig.Flexo__c)));
                } else if (selectedvalue == 'Flexo + Silkscreen') {
                    if (tubeConfig.Flexo_Silkscreen__c > 0) {
                        mapcolors.put('NB_Flexo_Colors__c', getColorOptions(4));
                    }
                    mapcolors.put('NB_SS_Colors__c', getColorOptions(Integer.ValueOf(tubeConfig.Flexo_Silkscreen__c)));
                } else if (selectedvalue == 'Silkscreen') {
                    mapcolors.put('NB_SS_Colors__c', getColorOptions(Integer.ValueOf(tubeConfig.Silkscreen__c)));
                }
            }
        }
        system.debug('******mapcolors********' + mapcolors);

        return mapcolors;
    }


    public static List <Integer> getColorOptions(Integer count) {
        List <Integer> listOptions = new List <Integer>();

        for (integer i = 1; i <= count; i++) {
            listOptions.add(i);
        }

        return listOptions;
    }


    @AuraEnabled
    public static Map <String, List<Integer>> getLaminateUSColors(PM_Selected_Tubes_Config__c selcon, string segment) {

        system.debug('******getLaminateUSColors***Diameter_inches__c*****' + selcon.Diameter_inches__c);
        system.debug('******getLaminateUSColors***Printing_type__c*****' + selcon.Printing_type__c);
        system.debug('******getLaminateUSColors***selcon.Location__c*****' + selcon.Location__c);
        string selectedvalue = (selcon.Printing_type__c == null) ? '' : selcon.Printing_type__c;

        Map <String, List<Integer>> mapcolors = new Map <String, List<Integer>>();
        mapcolors.put('NB_Offset_Colors__c', new List<Integer>());
        mapcolors.put('NB_Flexo_Colors__c', new List<Integer>());
        mapcolors.put('NB_SS_Colors__c', new List<Integer>());
        string spec = selcon.Diameter_inches__c;
        for (PM_Tubes_Config__c tube : [
                Select Offset__c, Flexo__c, Silkscreen__c, Spec__c
                from PM_Tubes_Config__c
                where Spec__c = :spec and Active__c = true and
                Location__c = :selcon.Location__c and Tubes_Segment__c = :segment and Table_Name__c = 'Deco NB Colors Possibility'
        ]) {

            system.debug('******colors*found*******' + tube);
            if (selectedvalue == 'Offset') {
                integer offset = (tube.Offset__c == null) ? 0 : integer.valueOf(tube.Offset__c);
                mapcolors.put('NB_Offset_Colors__c', getColorOptions(offset));
            }
            if (selectedvalue.contains('Flexo')) {
                integer flexo = (tube.Flexo__c == null) ? 0 : integer.valueOf(tube.Flexo__c);
                mapcolors.put('NB_Flexo_Colors__c', getColorOptions(flexo));
            }
            if (selectedvalue.contains('Silkscreen')) {
                integer Silkscreen = (tube.Silkscreen__c == null) ? 0 : integer.valueOf(tube.Silkscreen__c);
                mapcolors.put('NB_SS_Colors__c', getColorOptions(Silkscreen));
            }

        }
        system.debug('******mapcolors********' + mapcolors);

        return mapcolors;
    }


    @AuraEnabled
    public static Map <String, List<Integer>> getPurefoilEUColors(PM_Selected_Tubes_Config__c selcon, string segment) {

        string selectedvalue = selcon.Printing_technologies__c;

        Map <String, List<Integer>> mapcolors = new Map <String, List<Integer>>();
        mapcolors.put('NB_Offset_Colors__c', new List<Integer>());
        mapcolors.put('NB_SS_Colors__c', new List<Integer>());

        String spec = String.valueOf(selcon.Diameter_mm__c) + '_' + selcon.Head_Name__c;
        if (String.isNotBlank(spec)) {
            for (PM_Tubes_Config__c tubeConfig : [
                    select Spec__c, Offset__c, Flexo__c,
                            Silkscreen__c, Flexo_Silkscreen__c, Offset_Silkscreen__c
                    from PM_Tubes_Config__c
                    where Location__c = :selcon.Location__c
                    and Active__c = true and Spec__c = :spec and Tubes_Segment__c = :segment and Table_Name__c = 'Deco NB Colors Possibility'
            ]) {


                if (selectedvalue == 'Offset') {
                    mapcolors.put('NB_Offset_Colors__c', getColorOptions(Integer.ValueOf(tubeConfig.Offset__c)));
                } else if (selectedvalue == 'Offset + Silkscreen') {
                    if (tubeConfig.Offset_Silkscreen__c > 0) {
                        mapcolors.put('NB_Offset_Colors__c', getColorOptions(6));
                    }
                    mapcolors.put('NB_SS_Colors__c', getColorOptions(Integer.ValueOf(tubeConfig.Offset_Silkscreen__c)));
                } else if (selectedvalue == 'Flexo + Silkscreen') {
                    mapcolors.put('NB_SS_Colors__c', getColorOptions(Integer.ValueOf(tubeConfig.Flexo_Silkscreen__c)));
                } else if (selectedvalue == 'Silkscreen') {
                    mapcolors.put('NB_SS_Colors__c', getColorOptions(Integer.ValueOf(tubeConfig.Silkscreen__c)));
                }
            }
        }
        system.debug('******mapcolors********' + mapcolors);

        return mapcolors;
    }


}