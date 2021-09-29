({
    //Main function
    /**
     * Function doInit : this function is run at the loading of the page      
     */
    doInit : function(component, event, helper){
        var action = component.get("c.displayCopyQuote");
        action.setParams({
            recordId : component.get("v.recordId")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.displayCopyQuote', response.getReturnValue());
            }
        }
        );
        $A.enqueueAction(action);

        helper.isQuoteWon(component);
        helper.displayData(component, event, helper);
        helper.getContract(component);
        
    },

    /**
     * Function cloneQuote : this function is run when the user has clicked on the "Copy Quote" button
     */
    cloneQuote : function(component, event, helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");

        console.log('Clone the quote an stay within the same opportunity');

        helper.cloneQuote1(component);
        var cloneQuoteWizard = component.find('cloneQuoteWizard');
        $A.util.removeClass(cloneQuoteWizard,'slds-fade-in-open');
        $A.util.addClass(cloneQuoteWizard,'slds-fade-in-hide');

        var cloneQuoteServiceMessage = component.find('cloneQuoteServiceMessage');
        $A.util.removeClass(cloneQuoteServiceMessage,'slds-fade-in-hide');
        $A.util.addClass(cloneQuoteServiceMessage,'slds-fade-in-open');
    },
    cloneQuoteNewOpportunity : function(component, event, helper){
        
        var oppty = JSON.parse(JSON.stringify(component.get('v.oppty')));
        var selectedLookUpRecord = component.get('v.selectedLookUpRecordAcc').Id;
        if(oppty.Name == undefined || selectedLookUpRecord == undefined || oppty.CloseDate == undefined || oppty.Quote_Type__c == undefined){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: "Please fill all the fields before saving",
                type: "error"
            });
            toastEvent.fire();
            return false;
        }

        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");

        console.log('Clone the quote to a new opportunity');

        var cloneQuoteWizard = component.find('cloneQuoteWizard');
        $A.util.removeClass(cloneQuoteWizard,'slds-fade-in-open');
        $A.util.addClass(cloneQuoteWizard,'slds-fade-in-hide');

        var newOpportunityWizard = component.find('newOpportunityWizard');
        $A.util.removeClass(newOpportunityWizard,'slds-fade-in-open');
        $A.util.addClass(newOpportunityWizard,'slds-fade-in-hide');

        var cloneQuoteServiceMessage = component.find('cloneQuoteServiceMessage');
        $A.util.removeClass(cloneQuoteServiceMessage,'slds-fade-in-hide');
        $A.util.addClass(cloneQuoteServiceMessage,'slds-fade-in-open');

        helper.cloneQuote3(component);
        
    },
    cloneQuoteExistingOpportunity : function(component, event, helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");

        console.log('Clone the quote to an existing opportunity');
        //helper.displayData(component, event, helper);

        if(component.get("v.selectedLookUpRecordOpp").Id != undefined){
            helper.cloneQuote2(component);
            var cloneQuoteWizard = component.find('cloneQuoteWizard');
            $A.util.removeClass(cloneQuoteWizard,'slds-fade-in-open');
            $A.util.addClass(cloneQuoteWizard,'slds-fade-in-hide');

            var selectOpportunityWizard = component.find('selectOpportunityWizard');
            $A.util.removeClass(selectOpportunityWizard,'slds-fade-in-open');
            $A.util.addClass(selectOpportunityWizard,'slds-fade-in-hide');

            var cloneQuoteServiceMessage = component.find('cloneQuoteServiceMessage');
            $A.util.removeClass(cloneQuoteServiceMessage,'slds-fade-in-hide');
            $A.util.addClass(cloneQuoteServiceMessage,'slds-fade-in-open');
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                message: "Please select an opportunity",
                type: "error"
            });
            toastEvent.fire();
            return false;
        }


        
    },
    /////////////////////////
    // Show and Hide modal
    /////////////////////////
	showModal : function(component, event, helper) {
    	console.log('Showing clone quote wizard window');
        var modalElement = component.find('cloneQuoteWizard');
		$A.util.removeClass(modalElement,'slds-fade-in-hide');
    	$A.util.addClass(modalElement,'slds-fade-in-open');
        var cloneQuoteServiceMessage = component.find('cloneQuoteServiceMessage');
        
        console.log(cloneQuoteServiceMessage.get('v.body'));

        // helper.displayData(component, event, helper);
    }, 
    
    hideModal : function(component,event, helper){    	
    	console.log('Hiding clone quote wizard window.');
        var modalElement = component.find('cloneQuoteWizard');
		$A.util.removeClass(modalElement,'slds-fade-in-open');
    	$A.util.addClass(modalElement,'slds-fade-in-hide');   

        // helper.displayData(component, event, helper);  
    },
    

    showNewOpportunityModal : function(component, event, helper){
        console.log('Showing new opportunity wizard window');
        var modalElement = component.find('newOpportunityWizard');
        $A.util.removeClass(modalElement,'slds-fade-in-hide');
        $A.util.addClass(modalElement,'slds-fade-in-open');

        // helper.displayData(component, event, helper);
    },

    hideNewOpportunityModal : function(component, event, helper){        
        console.log('Hiding clone quote wizard window.');
        var modalElement = component.find('newOpportunityWizard');
        $A.util.removeClass(modalElement,'slds-fade-in-open');
        $A.util.addClass(modalElement,'slds-fade-in-hide');  

        // helper.displayData(component, event, helper);   
    },

    showSelectOpportunityModal : function(component, event, helper){
        console.log('Showing Select opportunity wizard window');
        var modalElement = component.find('selectOpportunityWizard');
        $A.util.removeClass(modalElement,'slds-fade-in-hide');
        $A.util.addClass(modalElement,'slds-fade-in-open');

        // helper.displayData(component, event, helper);
    },

    hideSelectOpportunityModal : function(component, event, helper){
        console.log('Hiding Select opportunity wizard window');
        var modalElement = component.find('selectOpportunityWizard');
        $A.util.removeClass(modalElement,'slds-fade-in-open');
        $A.util.addClass(modalElement,'slds-fade-in-hide');

        // helper.displayData(component, event, helper);
    },

    showCloneQuoteServiceMessage : function(component, event, helper){
        console.log('Showing Select opportunity wizard window');
        var cloneQuoteServiceMessage = component.find('cloneQuoteServiceMessage');
        $A.util.removeClass(cloneQuoteServiceMessage,'slds-fade-in-hide');
        $A.util.addClass(cloneQuoteServiceMessage,'slds-fade-in-open');

        // helper.displayData(component, event, helper);
    },

    hideCloneQuoteServiceMessage : function(component, event, helper){
        console.log('Hiding Select opportunity wizard window');
        var cloneQuoteServiceMessage = component.find('cloneQuoteServiceMessage');
        $A.util.removeClass(cloneQuoteServiceMessage,'slds-fade-in-open');
        $A.util.addClass(cloneQuoteServiceMessage,'slds-fade-in-hide');

        // helper.displayData(component, event, helper);
    },
    toggle: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }

   
})