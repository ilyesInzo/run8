/**
 * Created by Thanina on 10/07/2019.
 */
({
    doInit : function(component, event, helper) {
        // alert(component.get("v.sObjectName"));
        helper.Init(component, event, helper);
        
    },
    handleApplicationEvent : function(component, event, helper) {
        
        var updatedRecord = event.getParam("updatedRecord");
        var listRecords = new Map();
        listRecords = component.get("v.updatedRecordList");
        
        listRecords[updatedRecord.Id]=  updatedRecord;
        component.set("v.updatedRecordList",listRecords);
        component.set("v.showSaveCancelBtn",true);
        
        var nbUpRows=0;
        for (var key in listRecords) {
            nbUpRows++;
        }
        component.set("v.nbUpdatedRows",JSON.stringify(nbUpRows));
        component.set("v.displayNBUpdatedRows",true);
    },
    
    handleSelectionEvent : function(component, event, helper) {
        
        var selectedRecordVar = event.getParams()['selectedRecord'];
        var isSelectedVar = event.getParams()['isSelected'];
        //alert('show is selected: '+JSON.stringify(isSelectedVar));
        var listSelectedRecords = new Map();
        listSelectedRecords = component.get("v.selectedRecordList");
        // alert('@@@selected val: '+JSON.stringify(isSelectedVar));
        var showBtn = false;
        if(isSelectedVar == true)
        {
            listSelectedRecords[selectedRecordVar.Id]=  selectedRecordVar;
            showBtn = true;
        }
        if(isSelectedVar == false){
            helper.deleteMapValue(component,selectedRecordVar.Id);
            
        }
        
        component.set("v.selectedRecordList",listSelectedRecords);
        var nbSelectedRows=0;
        for (var key in listSelectedRecords) {
            nbSelectedRows++;
        }
        component.set("v.nbSelectedRows",JSON.stringify(nbSelectedRows));
        if(nbSelectedRows != 0) showBtn = true;
        component.set("v.showAppRejectBtn",showBtn);
        
        //alert('@@@NBSelectedRecord: '+JSON.stringify(nbSelectedRows));
        // console.log(component.get("v.selectedRecordList"));
        
    },
    
    Cancel : function(component, event, helper) {
        
        helper.refreshTable(component, event, helper);
        //alert('View Was Refreshed!!!');
        
    },
    Save :  function(component, event, helper) {
        //console.log(component.get("v.showSpinner"));
        
        //component.set("v.showSpinner", true);
        
        console.log(component.get("v.showSpinner"));
        
        //var listRecordToUpdate= component.get("v.updatedRecordList");
        var listUpRecords= component.get("v.updatedRecordList");
        //  alert('here Up List: ' + JSON.stringify(listUpRecords));
        helper.updateRecord(component,event,helper);
        helper.refreshTable(component,event,helper);
        console.log(component.get("v.showSpinner"));
        
    },
    Reject : function(component, event, helper) {
        
        //Need to do test here
        var nameObj=component.get("v.sObjectName");
        var fieldNameRequest= '';
        
        if(nameObj == 'Sales_Team__c')  fieldNameRequest='Request_MAJ_SA_Status__c';
        if(nameObj == 'Sales_Allocations__c')  fieldNameRequest='Request_MAJ_Alloc_Status__c';
        
        var selectedRows= component.get("v.selectedRecordList");
        var selectedCountRows= component.get("v.nbSelectedRows");
        
        if(selectedCountRows != '0')
        {
            helper.updateSelectedRows(fieldNameRequest,'Rejected',selectedRows);
            helper.saveUpdatedRowsInServer(component,event,helper,selectedRows);
            helper.refreshTable(component,event,helper);
            
        }
        //alert('View Was Refreshed!!!');
        
    },
    Approve : function(component, event, helper) {
        
        var nameObj=component.get("v.sObjectName");
        var fieldNameRequest= '';
        
        if(nameObj == 'Sales_Team__c')  fieldNameRequest='Request_MAJ_SA_Status__c';
        if(nameObj == 'Sales_Allocations__c')  fieldNameRequest='Request_MAJ_Alloc_Status__c';
        
        var selectedRows= component.get("v.selectedRecordList");
        var selectedCountRows= component.get("v.nbSelectedRows");
        
        
        if(selectedCountRows != '0')
        {
            // alert('am inside approve');
            helper.updateSelectedRows(fieldNameRequest,'Approved',selectedRows);
            helper.saveUpdatedRowsInServer(component,event,helper,selectedRows);
            helper.refreshTable(component,event,helper);
            
        }
    },
    doFilter: function(component, event, helper) {
        //calling helper
        helper.FilterRecords(component,helper);
    },
    
    
    /*
       -- This Part for Pagination --
    */
    
    onNext : function(component, event, helper) {
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
        //alert('all data: '+JSON.stringify(component.get("v.allData")));
    },
    
    onPrev : function(component, event, helper) {
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
        //alert('all data: '+JSON.stringify(component.get("v.allData")));
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        console.log('Currentpage'+component.get("v.currentPageNumber"));
        helper.buildData(component, helper);
        //alert('all data: '+JSON.stringify(component.get("v.allData")));
    },
    
    onFirst : function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
        //alert('all data: '+JSON.stringify(component.get("v.allData")));
    },
    
    onLast : function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        //added today
        // component.set("v.currentPageString",component.get("v.currentPageNumber").toString());
        
        helper.buildData(component, helper);
        //alert('all data: '+JSON.stringify(component.get("v.allData")));
    },
    //To select ALL Rows
    selectAllCheckbox : function(component, event, helper) {
        
        var ifSelected = event.getSource().get("v.value");
        component.set("v.sameValToAll",ifSelected);
        component.set("v.needToSelectAll",true);
        
        var listAllRows = component.get("v.allData");
        var mapAllSelected = component.get("v.selectedRecordList");
        var nbAllRows = JSON.stringify(listAllRows.length);
        helper.constructMapFromList(component,listAllRows,mapAllSelected);
        
        if(ifSelected == false){
            mapAllSelected = {};
            nbAllRows = '0';
            component.set("v.allCheckboxes",{});
        }
        
        
        component.set("v.selectedRecordList",mapAllSelected);
        component.set("v.nbSelectedRows",nbAllRows);
        
        if(nbAllRows!='0') component.set("v.showAppRejectBtn",true);
        else component.set("v.showAppRejectBtn",false);
    }
})