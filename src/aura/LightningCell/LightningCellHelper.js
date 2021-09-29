/**
 * Created by Thanina on 10/07/2019.
 */
({
    	doInit : function(component, event, helper) {

        		var record = component.get("v.record");
                var field = component.get("v.field");
               //alert('Field value: ' +JSON.stringify(record[field.name]));

                component.set("v.cellValue", record[field.name]);
               // if(component.get("v.selectedLookUpRecordAcc") != undefined)
                     // alert('Disp cell Val: '+JSON.stringify(component.get("v.cellValue")));

                if(field.editable.toUpperCase() == 'TRUE')
                 component.set("v.isEditable", true);

                if(field.type.toUpperCase() == 'STRING' || field.type.toUpperCase() == 'ID')
                    {
                        component.set("v.isTextField", true);

                    }
                else if(field.type.toUpperCase() == 'DATE'){
                	component.set("v.isDateField", true);
                }
                else if(field.type.toUpperCase() == 'DATETIME'){
                	component.set("v.isDateTimeField", true);
                }
                else if(field.type.toUpperCase() == 'CURRENCY'){
                	component.set("v.isCurrencyField", true);
                }
                else if(field.type.toUpperCase() == 'PICKLIST'){
                    component.set("v.isPicklist", true);
                    //need To get specified Options don't forget to update that

                 }
                else if(field.type.toUpperCase() == 'REFERENCE'){
                	component.set("v.isReferenceField", true);
                	var parentName= (field.parentObjectType != null) ? field.parentObjectType : '';
                	var parentObjFilters = (field.parentObjectFilters != undefined) ? field.parentObjectFilters : '';
                	component.set("v.ObjectLookupName",parentName);
                	component.set("v.ObjectLookupFilter",parentObjFilters);
                    component.set("v.selectedLookUpRecordAcc",record[field.name]);
                	//alert('@@@ is REFFFFFF before');
                    var relationShipName = '';
                    if(field.name.indexOf('__c') == -1) {
                        relationShipName = field.name.substring(0, field.name.indexOf('Id'));

                    }
                    else {
                        relationShipName = field.name.substring(0, field.name.indexOf('__c')) + '__r';
                    }
                    if(record[relationShipName] != null)
                               {
                                    component.set("v.cellLabel", record[relationShipName].Name);
                               }




                }
        }

})