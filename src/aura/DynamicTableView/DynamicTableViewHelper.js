/**
 * Created by Thanina on 10/07/2019.
 */
//helper.toggleSpinner(component);

({
    Init: function(component, event, helper) {
        // component.set("v.showSpinner", true);
        helper.getTableFieldSet(component, event, helper);
        helper.initListCheckBoxes(component, event, false);
    },
    updateRecord: function(component, event, helper) {
        //alert('Inside Up Record: '+JSON.stringify(component.get("v.updatedRecordList")));
        helper.saveUpdatedRowsInServer(
            component,
            event,
            helper,
            component.get("v.updatedRecordList")
        );
    },
    getTableFieldSet: function(component, event, helper) {
        var action = component.get("c.getFieldSetDescription");
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldSetName: component.get("v.fieldSetName")
        });
        helper.toggleSpinner(component);

        action.setCallback(this, function(response) {
            //alert(response.getReturnValue());
            var fieldSetObj = JSON.parse(response.getReturnValue());
            //console.log('@@@disp: fieldSetValues: '+ fieldSetObj);
            component.set("v.fieldSetValues", fieldSetObj);
            //Call helper method to fetch the records
            helper.getTableRows(component, event, helper);
            helper.toggleSpinner(component);

        });
        $A.enqueueAction(action);
    },
    
    getTableRows: function(component, event, helper) {
        var action = component.get("c.getsObjectsRecord");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setFieldNames = new Set();
        
        for (var c = 0, clang = fieldSetValues.length; c < clang; c++) {
            if (!setFieldNames.has(fieldSetValues[c].name)) {
                setFieldNames.add(fieldSetValues[c].name);
                if (fieldSetValues[c].type == "REFERENCE") {
                    if (fieldSetValues[c].name.indexOf("__c") == -1) {
                        setFieldNames.add(
                            fieldSetValues[c].name.substring(
                                0,
                                fieldSetValues[c].name.indexOf("Id")
                            ) + ".Name"
                        );
                    } else {
                        //Here I should add all list of parentObject
                        setFieldNames.add(
                            fieldSetValues[c].name.substring(
                                0,
                                fieldSetValues[c].name.indexOf("__c")
                            ) + "__r.Name"
                        );
                    }
                }
            }
        }
        var arrFieldNames = [];
        setFieldNames.forEach(v => arrFieldNames.push(v));
        component.set("v.saveListFields", arrFieldNames); // To use in search fields
        
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            queryFilters: component.get("v.filters"),
            fieldNameJson: JSON.stringify(arrFieldNames),
            fieldSetName: component.get("v.fieldSetName")
        });
        helper.toggleSpinner(component);
        action.setCallback(this, function(response) {
            // alert(response.getReturnValue());
            var state = response.getState();
            var list = [];
            if (state === "SUCCESS") {
                //  alert('erreur gete dat: '+ JSON.stringify(response.getReturnValue()));
                list = JSON.parse(response.getReturnValue());
                //alert('erreur gete dat: '+ JSON.stringify(list));
                //console.log(list);
                //component.set("v.tableRecords", list);
                component.set("v.tableRecordsInit", list);
                component.set("v.totalRecordsCount", list.length);
                console.log("length :" + list.length);
                /*-- Added for Pagination-- */
                component.set(
                    "v.totalPages",
                    Math.ceil(list.length / component.get("v.pageSize"))
                );
                component.set("v.currentPageNumber", 1);
                component.set("v.allData", list);
                helper.buildData(component, helper);
                
                // -- END Pagination ----
            } else alert("erreur gete data");
            helper.toggleSpinner(component);
        });
        $A.enqueueAction(action);
    },
    FilterRecords: function(component, helper) {
        //data showing in table
        var data = component.get("v.tableRecords");
        // all data featched from apex when component loaded
        var allData = component.get("v.tableRecordsInit");
        //Search tems
        var searchKey = component.get("v.searchKey");
        
        if (searchKey.length >= 3) {
            //init pagination
			component.set("v.currentPageNumber", 1);
            
            
            // check is data is not undefined and its lenght is greater than 0
            if (data != undefined || data.length > 0) {
                // filter method create a new array tha pass the test (provided as function)
                var filteredData = allData.filter(
                    word =>
                    !searchKey ||
                    helper.checkExistingWordKey(component, word, searchKey)
                    //(word.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1) ||
                    //(word.Id.toLowerCase().indexOf(searchKey.toLowerCase()) > -1)
                );
            }
            // set new filtered array value to data showing in the table.
            component.set("v.allData", filteredData);
            component.set(
                "v.totalPages",
                Math.ceil(filteredData.length / component.get("v.pageSize"))
            );
            helper.buildData(component, helper);
            // check if searchKey is blank
        }
        if (searchKey == "") {
            component.set("v.allData", component.get("v.tableRecordsInit"));
            helper.buildData(component, helper);
            component.set(
                "v.totalPages",
                Math.ceil(component.get("v.tableRecordsInit").length / component.get("v.pageSize"))
            );
        }
    },
    
    checkExistingWordKey: function(component, word, searchKey) {
        var filedNames = component.get("v.saveListFields");
        //alert('Word: ' +JSON.stringify(word));
        var bool = false;
        var isRef = false;
        
        filedNames.forEach(function(field) {
            isRef = false;
            if (field.display != "false") {
                if (field.indexOf("__r") > -1) {
                    field = field.substring(0, field.indexOf("__r")) + "__r";
                    isRef = true;
                }
                if (word[field] != undefined) {
                    if (isRef)
                        bool =
                            bool ||
                            word[field].Name.toLowerCase().indexOf(searchKey.toLowerCase()) >
                            -1;
                    else
                        bool =
                            bool ||
                            word[field].toLowerCase().indexOf(searchKey.toLowerCase()) > -1;
                }
            }
        });
        //alert('bool: '+ bool);
        return bool;
    },
    
    /*
   * this function will build table data
   * based on current page selection
   * */
    buildData: function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        
        component.set("v.currentPageString", pageNumber.toString());
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var x = (pageNumber - 1) * pageSize;
        
        //creating data-table data
        for (; x < pageNumber * pageSize; x++) {
            if (allData[x]) {
                data.push(allData[x]);
            }
        }
        component.set("v.tableRecords", data);
        helper.generatePageList(component, pageNumber);
    },
    
    /*
   * this function generate page list
   * */
    generatePageList: function(component, pageNumber) {
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if (totalPages > 1) {
            if (totalPages <= 10) {
                var counter = 2;
                for (; counter < totalPages; counter++) {
                    pageList.push(counter);
                }
            } else {
                if (pageNumber < 5) {
                    pageList.push(2, 3, 4, 5, 6);
                } else {
                    if (pageNumber > totalPages - 5) {
                        pageList.push(
                            totalPages - 5,
                            totalPages - 4,
                            totalPages - 3,
                            totalPages - 2,
                            totalPages - 1
                        );
                    } else {
                        pageList.push(
                            pageNumber - 2,
                            pageNumber - 1,
                            pageNumber,
                            pageNumber + 1,
                            pageNumber + 2
                        );
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    },
    
    //Delete key in map
    deleteMapValue: function(component, key) {
        // retrieve errorMap attribute
        var selectedRecordsMap = component.get("v.selectedRecordList");
        
        // delete the key
        delete selectedRecordsMap[key];
        
        // set the attribute with the new errorMap
        component.set("v.selectedRecordList", selectedRecordsMap);
    },
    //Init map selected app
    initListCheckBoxes: function(component, event, select) {
        var pgNum = component.get("v.currentPageString");
        var dataList = component.get("v.tableRecords");
        var listCheckBoxes = component.get("v.allCheckboxes");
        for (var i = 0; i < dataList.length; i++) {
            var indice = i.toString() + "-" + pgNum;
            listCheckBoxes[indice] = select;
        }
        
        component.set("v.allCheckboxes", listCheckBoxes);
    },
    
    //Construct Map from List
    constructMapFromList: function(component, varList, varMap) {
        for (var i = 0; i < varList.length; i++) {
            varMap[varList[i].Id] = varList[i];
        }
    },
    constructListFromMap: function(component, varList, varMap) {
        /*for(var i=0;i<varList.length;i++)
                    {
                        varMap[varList[i].Id] = varList[i];
                    }*/
    },
    
    refreshTable: function(component, event, helper) {
        helper.toggleSpinner(component);
        $A.get("e.force:refreshView").fire();
        component.set("v.updatedRecordList", {});
        component.set("v.selectedRecordList", {});
        component.set("v.nbUpdatedRows", "0");
        component.set("v.nbSelectedRows", "0");
        component.set("v.displayNBUpdatedRows", false);
        helper.toggleSpinner(component);

    },
    
    updateSelectedRows: function(nameField, valueToSet, mapRows) {
        for (var key in mapRows) {
            var rowUp = mapRows[key];
            rowUp[nameField] = valueToSet;
            mapRows[key] = rowUp;
            //alert('here selected Row Updated:' + JSON.stringify(mapRows[key]));
            // listRows.push(mapRows[key]);
        }
        // alert('map afterModif: '+JSON.stringify(mapRows));
    },
    
    saveUpdatedRowsInServer: function(component, event, helper, listRowsToUp) {
       
        var action = component.get("c.updateRecordsList");
        action.setParams({
            sObjectRecordList: JSON.stringify(listRowsToUp)
        });
        helper.toggleSpinner(component);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.setTimeout(function(){  
                    
                    component.set("v.showSpinner", false);
                    
                    component.set("v.displayPopupSuccess", true);
                    
                    window.setTimeout(function(){ 
                        component.set("v.displayPopupSuccess", false);
                    }, 1500);
                }, 3000);
                
                
            } else {window.setTimeout(function(){  
                
                component.set("v.showSpinner", false);
                
                component.set("v.displayPopupFailed", true);
                
                window.setTimeout(function(){ 
                    component.set("v.displayPopupFailed", false);
                }, 1500);
            }, 3000);}
            helper.toggleSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    filterListAfterRejectApprove: function(
        component,
        event,
        helper,
        searchKey,
        field,
        listRowsUp
    ) {
        // var allDataFil = component.get("v.allData");
        //var allDataFil=
        alert("ata: " + JSON.stringify(listRowsUp));
        var filteredData = listRowsUp.filter(
            word =>
            !searchKey ||
            word.field.toLowerCase().indexOf(searchKey.toLowerCase()) > -1
        );
        
        // set new filtered array value to data showing in the table.
        alert("FiltredData: " + JSON.stringify(filteredData));
        component.set("v.allData", filteredData);
        helper.buildData(component, helper);
    },
    toggleSpinner: function(component) {
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide"); 
    }
});