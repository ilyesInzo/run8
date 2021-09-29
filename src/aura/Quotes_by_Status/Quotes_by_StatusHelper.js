//reportHelper.js

({
    createChart : function (component) {

        var ready = component.get("v.ready");
        if (ready === false) {
            return;
        }
        var chartCanvas = component.find("chart").getElement();
        
        var action = component.get("c.getData");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                /*var ResultData = JSON.parse(response.getReturnValue());
                var chartData = [];
                var chartLabels = [];
                for(var i=0; i < (ResultData.groupingsDown.groupings.length); i++){
                    //Collect all labels for Chart.js data
                    var labelTemp = ResultData.groupingsDown.groupings[i].label;
                    chartLabels.push(labelTemp);
                    
                    var keyTemp = ResultData.groupingsDown.groupings[i].key;
                    
                    //Collect all values for Chart.js data
                    var valueTemp = ResultData.factMap[keyTemp + '!T'].aggregates[0].value ;
                    chartData.push(valueTemp);
                }*/
                
                var statuslabels = [];
                
                var dispensingData = JSON.parse(response.getReturnValue())["Dispensing"];
                var tubesData = JSON.parse(response.getReturnValue())["Tubes"];
                var beautysolutionsData = JSON.parse(response.getReturnValue())["Beauty Solutions"];
                var CRPData = JSON.parse(response.getReturnValue())["CRP"];
                var statusLabels0 = ["Draft", "Presented", "Won", "Killed By Albea", "Killed By Customner", "Lost"];
                var statusLabels = [];
                
                for(var i=0; i<6; i++){
                    if(dispensingData[i] != 0 || tubesData[i] != 0 || beautysolutionsData[i] != 0 || CRPData[i] != 0){
                        statusLabels.push(statusLabels0[i]);
                    }
                    else{
                        delete(dispensingData[i]);
                        delete(tubesData[i]);
                        delete(beautysolutionsData[i]);
                        delete(CRPData[i]);
                    }
                }
                
                for (var j = 0; j < dispensingData.length; j++) {
                    if (dispensingData[j] == undefined) {         
                        dispensingData.splice(j, 1);
                        j--;
                    }
                }
                for (var j = 0; j < tubesData.length; j++) {
                    if (tubesData[j] == undefined) {         
                        tubesData.splice(j, 1);
                        j--;
                    }
                }
                for (var j = 0; j < beautysolutionsData.length; j++) {
                    if (beautysolutionsData[j] == undefined) {         
                        beautysolutionsData.splice(j, 1);
                        j--;
                    }
                }
                for (var j = 0; j < CRPData.length; j++) {
                    if (CRPData[j] == undefined) {         
                        CRPData.splice(j, 1);
                        j--;
                    }
                }

                console.log(JSON.parse(response.getReturnValue()));    

                if(dispensingData.length + tubesData.length + beautysolutionsData.length + CRPData.length > 0){
                    
                    //Construct chart
                    var barChartData = {
                        labels: statusLabels,
                        datasets: [{
                            label: 'Dispensing',
                            backgroundColor : '#23A4DB',
                            stack: 'Stack 0',
                            data: dispensingData
                        }, {
                            label: 'Tubes',
                            backgroundColor : '#0B2158',
                            stack: 'Stack 0',
                            data: tubesData
                        }, {
                            label: 'Beauty Solutions',
                            backgroundColor : '#7FDEDA',
                            stack: 'Stack 0',
                            data: beautysolutionsData
                        }, {
                            label: 'CRP',
                            backgroundColor : '#E0CC83',
                            stack: 'Stack 0',
                            data: CRPData
                        }]
                        
                    };
                    
                    var chart = new Chart(chartCanvas,{
                        type: 'horizontalBar',
                        data: barChartData,
                        options: {
                            cutoutPercentage: 75,
                            maintainAspectRatio: false,
                            legend: {
                                display: true,
                                position:'right',
                                fullWidth:false,
                                reverse:false,
                                labels: {
                                    fontColor: '#000',
                                    fontSize:10,
                                    fontFamily:"Salesforce Sans, Arial, sans-serif SANS_SERIF"
                                },
                                layout: {
                                    padding: 70,
                                }
                            },
                            scales: {
                                xAxes: [{
                                    stacked: true
                                }],
                                yAxes: [{
                                    stacked: true
                                }]
                            }
                        }
                    });
                    
                }
                
                else{
                    console.log("nodata");
                    component.set("v.nodata", true);
                }
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message on createReport: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
})