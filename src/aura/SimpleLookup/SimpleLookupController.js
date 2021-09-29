/**
 * Created by Thanina on 11/07/2019.
 */
({
    onfocus : function(component,event,helper){
           $A.util.addClass(component.find("mySpinner"), "slds-show");
            var forOpen = component.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');
            // Get Default 5 Records order by createdDate DESC
             var getInputkeyWord = '';
             helper.searchHelper(component,event,getInputkeyWord);
        },
        onblur : function(component,event,helper){
            window.setTimeout(
        $A.getCallback(function() {
            component.set("v.listOfSearchRecords", null );
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }), 100
    );

        },
        keyPressController : function(component, event, helper) {
           // get the search Input keyword
             var getInputkeyWord = component.get("v.SearchKeyWord");
           // check if getInputKeyWord size id more then 0 then open the lookup result List and
           // call the helper
           // else close the lookup result List part.
            if( getInputkeyWord.length > 0 ){
                 var forOpen = component.find("searchRes");
                   $A.util.addClass(forOpen, 'slds-is-open');
                   $A.util.removeClass(forOpen, 'slds-is-close');
                helper.searchHelper(component,event,getInputkeyWord);
            }
            else{
                 component.set("v.listOfSearchRecords", null );
                 var forclose = component.find("searchRes");
                   $A.util.addClass(forclose, 'slds-is-close');
                   $A.util.removeClass(forclose, 'slds-is-open');
              }
    	},

      // function for clear the Record Selaction
        clear :function(component,event,heplper){
             var pillTarget = component.find("lookup-pill");
             var lookUpTarget = component.find("lookupField");

             $A.util.addClass(pillTarget, 'slds-hide');
             $A.util.removeClass(pillTarget, 'slds-show');

             $A.util.addClass(lookUpTarget, 'slds-show');
             $A.util.removeClass(lookUpTarget, 'slds-hide');

             component.set("v.SearchKeyWord",null);
             component.set("v.listOfSearchRecords", null );
             component.set("v.selectedRecord", {} );
             //----Reeinit value after deleting selection---
             var initRecord=component.get("v.InputRecord");
             var initField=component.get("v.InputField");
             initRecord[initField.name] = null;
             //--------------------------------------------
        },

      // This function call when the end User Select any record from the result list.
        handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event
           var initRecord=component.get("v.InputRecord");
           var initField=component.get("v.InputField");

           var selectedAccountGetFromEvent = event.getParam("recordByEvent");
    	   component.set("v.selectedRecord" , selectedAccountGetFromEvent);
    	  // alert(v.selectedRecord[name]);
    	   //show save button and fire an other event: Nina---

    	      var saveUpdatedRecord = $A.get("e.c:GetUpdatedRecord");
    	      //We should Set set the selected record to the record field reference value then give this one to as param to Event
    	      if(selectedAccountGetFromEvent!= null)
    	      {
    	         var relationShipName = '';
                 initRecord[initField.name] = selectedAccountGetFromEvent.Id;
                 if(initField.name.indexOf('__c') == -1) {
                      relationShipName = initField.name.substring(0, initField.name.indexOf('Id'));
                 }
                 else {
                         relationShipName = initField.name.substring(0, initField.name.indexOf('__c')) + '__r';
                 }
                 var nameRecord= new Map();
                 nameRecord['Name']=selectedAccountGetFromEvent.Name;
                 nameRecord['Id']=selectedAccountGetFromEvent.Id;
                // alert('show fields: '+ JSON.stringify(nameRecord));
                 initRecord[relationShipName] = nameRecord;
                // initRecord[relationShipName].Name = ;
                // component.set("v.selectedLookUpRecordAcc",record[field.name]);
                // component.set("v.saveCellVal",initRecord[initField.name]) ;
                 //added to delete after .... if not working : 14-08
                // component.set("v.saveCellVal",selectedAccountGetFromEvent);
    	      }
    	      //--------------

            //  component.set("v.showSaveBTN",true);
              //alert('Nina selected Record: '+JSON.stringify(initRecord));

           // End Event Nina--------------

            var forclose = component.find("lookup-pill");
               $A.util.addClass(forclose, 'slds-show');
               $A.util.removeClass(forclose, 'slds-hide');

            var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');

            var lookUpTarget = component.find("lookupField");
                $A.util.addClass(lookUpTarget, 'slds-hide');
                $A.util.removeClass(lookUpTarget, 'slds-show');

            saveUpdatedRecord.setParams({ "updatedRecord" : initRecord});
            saveUpdatedRecord.fire();

    	}
})