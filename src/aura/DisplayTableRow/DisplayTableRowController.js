/**
 * Created by Thanina on 05/08/2019.
 */
({
    doInit : function (component, event, helper){


        var mapListCheck= component.get("v.listCheckBoxes");
        var valKey = component.get("v.index") + '-' + component.get("v.currentPageNum");
        component.set("v.key",valKey);

        if(component.get("v.fromSelectALL") == false)
        {
            if( mapListCheck[valKey] == undefined) mapListCheck[valKey]=false;
            component.set("v.val",mapListCheck[valKey]);
        }
        else{
             mapListCheck[valKey]=component.get("v.val");
        }

    },
    checkboxSelect : function(component, event, helper)
        {
            component.set("v.fromSelectALL",false);
            var selectedRec = event.getSource().get("v.value");
            var allCheck = component.get("v.listCheckBoxes");
            var cle= component.get("v.key");

            allCheck[cle]= selectedRec;
            component.set("v.listCheckBoxes",allCheck);

            //alert ('displ value inside change: ' +JSON.stringify(selectedRec));


            var record = component.get("v.row");
            //alert('Selected Record: '+ JSON.stringify(record));
            var saveSelectedRecord = $A.get("e.c:GetSelectedRecord");

                   saveSelectedRecord.setParams({
                           "selectedRecord" : record,
                           "isSelected" : selectedRec
                   });

             saveSelectedRecord.fire();


        }
})