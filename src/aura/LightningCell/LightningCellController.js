/**
 * Created by Thanina on 10/07/2019.
 */
({
        Init : function(component, event, helper) {
        		helper.doInit(component, event, helper);
        		//var selectRec=component.get("v.selectedLookUpRecordAcc");
        		//alert('Disp selectedRec: '+JSON.stringify(selectRec));
        	},

        onNameChange : function(component, event, helper){

            var record = component.get("v.record");
            var field = component.get("v.field");
            record[field.name] = component.get("v.cellValue");
            var saveUpdatedRecord = $A.get("e.c:GetUpdatedRecord");
            saveUpdatedRecord.setParams({ "updatedRecord" : record});
            saveUpdatedRecord.fire();

       //     component.set("v.showSaveCancelBtn",true); //we can omit it here
        },

        OnChangePicVal : function (component, event) {
                // This will contain the string of the "value" attribute of the selected option
                var selectedOptionValue = event.getParam("value");
                var record = component.get("v.record");
                var field = component.get("v.field");
                record[field.name] = selectedOptionValue;
                var saveUpdatedRecord = $A.get("e.c:GetUpdatedRecord");
                saveUpdatedRecord.setParams({ "updatedRecord" : record});
                saveUpdatedRecord.fire();
               // alert("Option selected with value: '" + selectedOptionValue + "'");
            }


})