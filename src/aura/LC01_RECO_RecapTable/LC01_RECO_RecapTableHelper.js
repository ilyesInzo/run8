({
    getSelectedTubeConfig :function( component,event,helper){
         this.CallServerMethodhelper(component, "getSelectedConfig",
                                    {qliId : component.get("v.qli.Id")}, 
                                    function (response) { 
                                        if (response.getState() === "SUCCESS") { 
                                            component.set("v.selectedTube",response.getReturnValue());
                                             helper.configSpecificRecapFields(component,event,helper);
                                        } 
                                    }); 
                               
    },
    configSpecificRecapFields:function(component,event,helper){
    	let SilkscreenVal='Yes (1 color)';
        var context = component.get("v.context");
        var selectedTube=component.get("v.selectedTube");
        
        var Sleeve_Material;
        var Printing_technologies;
        var NB_Offset_Colors='';
        var Sleeve_Length = selectedTube.Specific_length_mm__c ?selectedTube.Specific_length_mm__c :  selectedTube.Sleeve_length_mm__c ;
               
        if(context==='Laminate Tubes')
        {
           	Sleeve_Material=selectedTube.Sleeve_Material_Mix__c;
            Printing_technologies = selectedTube.Printing_technologies__c + (selectedTube.Silkscreen__c==SilkscreenVal?' + Silkscreen' :'');
            NB_Offset_Colors = selectedTube.NB_Flexo_Colors__c + (selectedTube.Silkscreen__c==SilkscreenVal?'+1' :'');
        }
        else
        {
            Sleeve_Material=selectedTube.Sleeve_Material__c;
         	Printing_technologies=selectedTube.Printing_technologies__c;
            NB_Offset_Colors= (selectedTube.NB_Flexo_Colors__c? selectedTube.NB_Flexo_Colors__c:
                               ( selectedTube.NB_Offset_Colors__c? selectedTube.NB_Offset_Colors__c:'')) ;
            NB_Offset_Colors+= (NB_Offset_Colors.length>0? '+':'') +(selectedTube.NB_SS_Colors__c ?(selectedTube.NB_SS_Colors__c) : '');
        }
        component.set("v.Sleeve_Length",Sleeve_Length);
        component.set("v.Sleeve_Material",Sleeve_Material);
        component.set("v.Printing_technologies",Printing_technologies);
        component.set("v.NB_Offset_Colors",NB_Offset_Colors);
	},
    getFinalPriceOffer :function( component,event,helper){
         this.CallServerMethodhelper(component, "getFinalPriceOffer",
                                    {quoteLineItemId : component.get("v.qli.Id")}, 
                                    function (response) { 
                                        if (response.getState() === "SUCCESS") { 
                                            component.set("v.FinalPriceOfferList",response.getReturnValue());
                                            this.refreshPricesAndMOQs(component,event,helper);
                                        } 
                                    }); 
                               
    },
    refreshPricesAndMOQs:function(component, helper,event){
        var selectedTube=component.get("v.selectedTube");
        var PriceOfferList= component.get("v.FinalPriceOfferList");
 		var priceMap=new Map();
        for(let i=1;i<PriceOfferList.length ;i++)
        {
           priceMap.set(selectedTube['Recap_MOQ'+i+'__c'],selectedTube['Recap_Price'+i+'__c'])
        }
        for(let i=0;i<PriceOfferList.length ;i++)
        {
            selectedTube['Recap_MOQ'+(i+1)+'__c']=PriceOfferList[i] ? PriceOfferList[i].MOQ_Units__c:'';
            selectedTube['Recap_Price'+(i+1)+'__c']=PriceOfferList[i]? priceMap.get(PriceOfferList[i].MOQ_Units__c):'';
           	if(PriceOfferList[i]) component.set("v.price"+(i+1)+"",PriceOfferList[i].Quoted_Price__c); 
        }
        component.set("v.selectedTube", component.get("v.selectedTube")) 
        
	},
    SaveRecapHelper:function(component,event,helper,feedBack){
        $A.util.removeClass(component.find("mySpinner"), "slds-hide");
          this.CallServerMethodhelper(component, "saveSelectedConfig",
                                    {so : component.get("v.selectedTube")}, 
                                    function (response) { 
                                        $A.util.addClass(component.find("mySpinner"), "slds-hide");                              
                                        if (response.getState() === "SUCCESS") { 
                                            if(feedBack)
                                            {
                                                this.fireToast(component,event,"Configuration was saved successfully.","success");
                                               
                                            }
                                        } 
                                    });          
    },
     //select table and copy to clipboard then clean  selection&data
   CopyTableToClipBoardHelper : function(component, event,helper) {
        document.getSelection().empty();     
        //prcess tables 
        var tbl=this.copyTables(component,event,helper);
        //select table by range
        var range = document.createRange();
        range.selectNode(tbl);
        window.getSelection().addRange(range) ;
        //copy
        document.execCommand('copy');
        //clean
        document.getSelection().empty();
        document.body.removeChild(tbl);
   
    },
    //this method copy table 1 and table 2 inside one table to be selected and copied to clipboard
    copyTables: function(component,event,helper)
    {
        //
        var index=0;
        //extract document's body 
        var body = document.getElementsByTagName("body")[0];
         var globalDiv = document.createElement("div");    
        var div1 = document.createElement("div");
        var div2 = document.createElement("div");
        //create tabl
        var copiedTable = document.createElement("table");
        //create tbody structure
        var tblBody = document.createElement("tbody");
        //read table 1 by id
        var table1ToCopyFrom=document.getElementById("table1");
        //copie first table
        this.copyRows(index, table1ToCopyFrom,tblBody,'string',this);     
        //attach tbody structure to table
        copiedTable.appendChild(tblBody);
         copiedTable.style.width="500px";
        div1.appendChild(copiedTable);
        div1.style.width="50%";
        div1.style.padding="20px";
         div1.style.display= "table-cell";
        var copiedTable2 = document.createElement("table");
        //create tbody structure
        var tblBody2 = document.createElement("tbody");
         //read table 2 by id
        var table2ToCopyFrom=document.getElementById("table2");
         //copie second table
        this.copyRows(index=0, table2ToCopyFrom,tblBody2,'input',this);
        //attach tbody structure to table
        copiedTable2.appendChild(tblBody2);
        copiedTable2.style.width="500px";
        div2.appendChild(copiedTable2);
       	div2.style.width="50%";
        div2.style.padding="20px";
        div2.style.display= "table-cell";
        //attach table to document's body
        
        
        globalDiv.style.width="auto";
        globalDiv.style.display= "flex";
        globalDiv.appendChild(div1);
        globalDiv.appendChild(div2);
        body.appendChild(globalDiv);
        
        return globalDiv;
	},
    //copy rows
    //i is an indexer
    //tableToCopyFrom: table source
    //tblBody is tbody structure to append row on ,on each iteration 
    //type can be input (read data from input.value) or string(read data from innerHTML)
    copyRows:function(i, tableToCopyFrom,tblBody,type,helper){
       if(i<tableToCopyFrom.rows.length)
       {
           if(i==0)
           {
               var emtyrow = document.createElement("tr");
               var emptyCell1=  document.createElement("td");
                var emptyCell2=  document.createElement("td");
               emtyrow.appendChild(emptyCell1);
                emtyrow.appendChild(emptyCell2);
                tblBody.appendChild(emtyrow);
           }
           //create row
           var row = document.createElement("tr");
           //read source table current row
            var rowFrom=tableToCopyFrom.rows[i];
           //fetch source table columns of current row
            for(var j=0;j<rowFrom.children.length;j++)
            {
                //create column
                /*if(rowFrom.children.length==1)
                {
                    var cellEmpty=  document.createElement("td");             
      				row.appendChild(cellEmpty);
                }*/
                var cell=  document.createElement("td");
                var celldiv=  document.createElement("div");
                //read source table current column              
                var value=type=='input'? rowFrom.cells[j].children[rowFrom.cells[j].children.length-1].innerText
                : rowFrom.cells[j].innerText; 
              
                //attach value to new Column
                var cellText = document.createTextNode(value); 
                celldiv.appendChild(cellText);
                if(rowFrom.cells[j].rowSpan>1){
                    cell.rowSpan =rowFrom.cells[j].rowSpan;
                    cell.style.position= "relative";
                }
               	
                celldiv.className = (j==0 && rowFrom.children.length!=1)  ?"Recap-header" : "Recap-Line";
                cell.appendChild(celldiv);
                
                cell.style.width="50%";
                //attach Column to new row
      			row.appendChild(cell);
            }
           //attach row to tbody structure
            tblBody.appendChild(row);
           //fetch next row
        	helper.copyRows(++i, tableToCopyFrom,tblBody,type,helper);
       }
    },
    getKamManager :function(component,event){
        $A.util.removeClass(component.find("mySpinner"), "slds-hide");
         this.CallServerMethodhelper(component, "getKamManagerEMail",
                                    {quoteId : component.get("v.qli.QuoteId")}, 
                                    function (response) { 
                                        $A.util.addClass(component.find("mySpinner"), "slds-hide");                              
                                        if (response.getState() === "SUCCESS") { 
                                           component.set("v.managerEmail",response.getReturnValue());
                                               
                                        } 
                                    });   
    },
    sendMail:function(component,event){
        this.CallServerMethodhelper(component, "sendEmail",
                                  	{message: component.get("v.msg"),
                                     quoteId : component.get("v.qli.QuoteId"),
                                     to: component.get("v.managerEmail"),
                                     subject: component.get("v.subject")}, 
                                    function (response) { 
                                        $A.util.addClass(component.find("mySpinner"), "slds-hide"); 
                                        var state=response.getState() ;
                                        if (state === "SUCCESS") { 
                                            this.fireToast(component,event,"Mail Has Been Send To Kam's Manager","success");
                                             component.set('v.msg','');
                                            component.set('v.subject','');
                                                var cmpTarget = component.find('Modalbox1');
                                                var cmpBack = component.find('Modalbackdrop');
                                                $A.util.removeClass(cmpBack,'slds-backdrop--open');
                                                $A.util.removeClass(cmpTarget, 'slds-fade-in-open');  
                                        }
                                         else if (state === "ERROR") {
                                                var errors = response.getError();
                                             
                                                if (errors) {
                                                    if (errors[0] && errors[0].message) {
                                                         this.fireToast(component,event,errors[0].message,"error");
                                                    }
                                                } 
                                        }
                                    });   		                     
    },
    fireToast:function(component,event,message,type){
       var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    message: message,
                                                    type : type
                                                });
                                                toastEvent.fire();  
    },
    CallServerMethodhelper: function (component, method, params, callback) {
        var action = component.get('c.' + method);
        if (params != null) {
            action.setParams(params);
        }
        if (callback) {
            action.setCallback(this, callback);
        }
        $A.enqueueAction(action);
    }
})