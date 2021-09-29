({
	displayData : function(component, event, helper){
        var disabledCheckbox = component.get('v.disabledCheckbox');
        var UseNewOpportunityFlag = component.get('v.UseNewOpportunityFlag');
        var UseSelectedAccountFlag = component.get('v.UseSelectedAccountFlag');
        var enabledCheckbox = component.get('v.enabledCheckbox');
        var UseSelectedOpportunityFlag = component.get('v.UseSelectedOpportunityFlag');

        console.log('-------------------------------------------------------');
        console.log('Disabled Checbox Flag : ' + disabledCheckbox);
        console.log('Use New Opportunity Flag : ' + UseNewOpportunityFlag);
        console.log('Use Selected Account Flag : ' + UseSelectedAccountFlag);
        console.log('Enabled Checkbox Flag : ' + enabledCheckbox);
        console.log('Use Selected Opportunity Flag : ' + UseSelectedOpportunityFlag);
        console.log('-------------------------------------------------------');
    },

	isQuoteWon : function(component) {
		var action = component.get("c.isQuoteWon");
		var quoteId = component.get('v.recordId');
		action.setParams({
			"quoteId" : quoteId,
		});
		action.setCallback(
			this,
			function(response){
				var state = response.getState();
				console.log(response.getReturnValue());
				console.log(JSON.stringify(response.getParams()));
				if (component.isValid() && state === "SUCCESS") {
					component.set('v.disabledCheckbox', response.getReturnValue());
					component.set('v.enabledCheckbox', ! response.getReturnValue());
				}
			}

		);
		console.log('Calling the callback');
		$A.enqueueAction(action);
	},
	getContract : function(component) {
		var action = component.get("c.getNewOpportunity");
		var quoteId = component.get('v.recordId');
		var oppty = component.get('v.oppty');

		action.setParams({
			"quoteId" : quoteId,
		});
		action.setCallback(
			this,
			function(response){
				var state = response.getState();
				console.log(response.getReturnValue());
				console.log(JSON.stringify(response.getParams()));
				if (component.isValid() && state === "SUCCESS") {
					//console.log('Return Value : ');
					//console.log(response.getReturnValue());

					console.log('Opportunity.AccountID default value : ');
					console.log(component.get('v.oppty.AccountId'));
					component.clearReference('v.oppty');
					component.set('v.oppty', response.getReturnValue());
					console.log('Opportunity.AccountID default value : ');
				}
			}

		);
		console.log('Calling the callback');
		$A.enqueueAction(action);
	},
	/**
	 * [ cloneQuote1 description : call the clone quote method = clone quote to the same opportunity ]
	 */
	cloneQuote1 : function(component) {
		var quoteId = component.get('v.recordId');
		var cloneQuoteServiceMessage = component.find('cloneQuoteServiceMessage');

 		console.log('ID of the quote we want to clone : ' + quoteId);

		var action = component.get("c.CloneQuote");
		console.log('Setting the params');
		action.setParams({
			"quoteId" : quoteId,
			"OpportunityStageName" : '',
			"OpportunityQuoteType" : '',
			"OpportunityName" : '',
			"OpportunityCloseDate" : '',
			"OpportunityId" : '',
			"AccountId" : '',
		});
		console.log('Setting the callback');
		action.setCallback(
			this,
			function(response){
				var state = response.getState();
				console.log(response.getReturnValue());
				console.log(JSON.stringify(response.getParams()));
				var errors = response.getError();
				console.log(response);
				console.log(response[0]);
				
				if (component.isValid() && state === "SUCCESS") {
					var navEvt = $A.get("e.force:navigateToSObject");
					navEvt.setParams({
					  "isredirect" : true,
				      "recordId": response.getReturnValue(),
				      "slideDevName" : "detail"
				    });
				    navEvt.fire();
				    var spinner = component.find("mySpinner");
        			$A.util.addClass(spinner, "slds-hide");
				    var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
					    title: "Success !",
					    message: "Congratulations, the quote was copied with success!",
					    type: "success"
					});
					toastEvent.fire();
				} else {
					var spinner = component.find("mySpinner");
        			$A.util.addClass(spinner, "slds-hide");
	        			var cloneQuoteServiceMessage = component.find('cloneQuoteServiceMessage');
						$A.util.removeClass(cloneQuoteServiceMessage,'slds-fade-in-open');
	       				$A.util.addClass(cloneQuoteServiceMessage,'slds-fade-in-hide');
	       				var cloneQuoteWizard = component.find('cloneQuoteWizard');
	        			$A.util.removeClass(cloneQuoteWizard,'slds-fade-in-hide');
	        			$A.util.addClass(cloneQuoteWizard,'slds-fade-in-open');
				        var selectOpportunityWizard = component.find('selectOpportunityWizard');

					this.errorMessageManager(errors);
				}
			}

		);
		console.log('Calling the callback');
		$A.enqueueAction(action);
	},
	/**
	 * [ cloneQuote3 description : call the clone quote method = new opportunity with the same account or not ]
	 */
	cloneQuote3 : function(component) {
		var quoteId = component.get('v.recordId'); 	
		var oppty = JSON.parse(JSON.stringify(component.get('v.oppty')));
		var selectedLookUpRecord = component.get('v.selectedLookUpRecordAcc').Id;
		//console.log('New Opportunity StageName :' + oppty.StageName);
 		console.log('New Opportunity Quote Type :' +oppty.Quote_Type__c);
 		console.log('New Opportunity Name :' +oppty.Name);
 		console.log('New Opportunity Close Date :' +oppty.CloseDate);
 		console.log('New Opportunity AccountID :' +selectedLookUpRecord);

 		console.log('ID of the quote we want to clone : ' + quoteId);

		var action = component.get("c.CloneQuote");
		console.log('Setting the params');
		action.setParams({
			"quoteId" : quoteId,
			"OpportunityStageName" : "Needs Analysis",
			"OpportunityQuoteType" : oppty.Quote_Type__c,
			"OpportunityName" : oppty.Name,
			"OpportunityCloseDate" : oppty.CloseDate,
			"OpportunityId" : '',
			"AccountId" : selectedLookUpRecord,
		});
		console.log('Setting the callback');
		action.setCallback(
			this,
			function(response){
				var state = response.getState();
				console.log(response.getReturnValue());
				console.log(JSON.stringify(response.getParams()));
				var errors = response.getError();

				if (component.isValid() && state === "SUCCESS") {
					var navEvt = $A.get("e.force:navigateToSObject");
					navEvt.setParams({
					  "isredirect" : true,
				      "recordId": response.getReturnValue(),
				      "slideDevName" : "detail"
				    });
				    navEvt.fire();
				    var spinner = component.find("mySpinner");
        			$A.util.addClass(spinner, "slds-hide");
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
					    title: "Success !",
					    message: "Congratulations, the quote was copied with success!",
					    type: "success"
					});
					toastEvent.fire();
				} else {
					var spinner = component.find("mySpinner");
        			$A.util.addClass(spinner, "slds-hide");
        			var cloneQuoteServiceMessage = component.find('cloneQuoteServiceMessage');
					$A.util.removeClass(cloneQuoteServiceMessage,'slds-fade-in-open');
       				$A.util.addClass(cloneQuoteServiceMessage,'slds-fade-in-hide');
       				var cloneQuoteWizard = component.find('cloneQuoteWizard');
        			$A.util.removeClass(cloneQuoteWizard,'slds-fade-in-hide');
        			$A.util.addClass(cloneQuoteWizard,'slds-fade-in-open');
			        var newOpportunityWizard = component.find('newOpportunityWizard');
			        $A.util.removeClass(newOpportunityWizard,'slds-fade-in-hide');
			        $A.util.addClass(newOpportunityWizard,'slds-fade-in-open');

					this.errorMessageManager(errors);
				}
			}

		);
		console.log('Calling the callback');
		$A.enqueueAction(action);
	},
	/**
	 * [ cloneQuote2 description : call the clone quote method = another open opportunity ]
	 */
	cloneQuote2 : function(component) {
		var quoteId = component.get('v.recordId'); 		
		var clonedQuote = JSON.parse(JSON.stringify(component.get('v.clonedQuote')));
		var existingOppId = component.get("v.selectedLookUpRecordOpp").Id;
		
		console.log(clonedQuote.OpportunityId);
 		console.log('ID of the quote we want to clone : ' + quoteId);

		var action = component.get("c.CloneQuote");
		console.log('Setting the params');
		action.setParams({
			"quoteId" : quoteId,
			"OpportunityStageName" : '',
			"OpportunityQuoteType" : '',
			"OpportunityName" : '',
			"OpportunityCloseDate" : '',
			"OpportunityId" : existingOppId,
			"AccountId" : '',
		});
		console.log('Setting the callback');
		action.setCallback(
			this,
			function(response){
				var state = response.getState();
				console.log(response.getReturnValue());
				console.log(JSON.stringify(response.getParams()));

				var errors = response.getError();
				if (component.isValid() && state === "SUCCESS") {
					var navEvt = $A.get("e.force:navigateToSObject");
					navEvt.setParams({
					  "isredirect" : true,
				      "recordId": response.getReturnValue(),
				      "slideDevName" : "detail"
				    });
				    navEvt.fire();
				    var spinner = component.find("mySpinner");
        			$A.util.addClass(spinner, "slds-hide");
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
					    title: "Success !",
					    message: "Congratulations, the quote was copied with success!",
					    type: "success"
					});
					toastEvent.fire();
				} else {
					var spinner = component.find("mySpinner");
        			$A.util.addClass(spinner, "slds-hide");
        			var cloneQuoteServiceMessage = component.find('cloneQuoteServiceMessage');
        			$A.util.removeClass(cloneQuoteServiceMessage,'slds-fade-in-open');
                    $A.util.addClass(cloneQuoteServiceMessage,'slds-fade-in-hide');
       				var cloneQuoteWizard = component.find('cloneQuoteWizard');
        			$A.util.removeClass(cloneQuoteWizard,'slds-fade-in-hide');
        			$A.util.addClass(cloneQuoteWizard,'slds-fade-in-open');
			        var newOpportunityWizard = component.find('selectOpportunityWizard');
			        $A.util.removeClass(newOpportunityWizard,'slds-fade-in-hide');
			        $A.util.addClass(newOpportunityWizard,'slds-fade-in-open');
					this.errorMessageManager(errors);
				}
			}

		);
		console.log('Calling the callback');
		$A.enqueueAction(action);
	},
	errorMessageManager : function (errorResponses){
		var errorMessage = '';
		console.log('1');
		console.log(errorResponses);
		console.log('2');
		console.log(errorResponses[0]);
		console.log('3');
		console.log(errorResponses[0].message);
		console.log('4');
		console.log(errorResponses.length);
		console.log('5');
		console.log(JSON.stringify(errorResponses).message);
		for(var indexErrorResponse = 0; indexErrorResponse < errorResponses.length; indexErrorResponse++){
			var errorResponse = errorResponses[indexErrorResponse];

			//FieldErrors Management
			if (typeof errorResponse.fieldErrors != 'undefined'){
				if (typeof Object.values(errorResponse.fieldErrors) != 'undefined'){
					if (typeof Object.keys(errorResponse.fieldErrors) != 'undefined'){
			var fieldErrors = errorResponse.fieldErrors;

			var fieldErrorValues = Object.values(fieldErrors);

			var fieldErrorKeys = Object.keys(fieldErrors);

			for(var indexFieldErrorKeys = 0; indexFieldErrorKeys < fieldErrorKeys.length; indexFieldErrorKeys++) {
				var fieldErrorKey = fieldErrorKeys[indexFieldErrorKeys];
				var fieldErrorValue = fieldErrorValues[indexFieldErrorKeys];
				console.log("fieldErrorValues" + fieldErrorValues);
				console.log("fieldErrorKeys" + fieldErrorKeys);
				// errorMessage = fieldErrorKey + ' : ' + fieldErrorValue[0].statusCode + ' - ' + fieldErrorValue[0].message + '\n';
				errorMessage = '- ' + fieldErrorValue[0].message + ' | ';
	

			}
					}
				}
			}
			//PageErrors Management
			var pageErrors = errorResponse.pageErrors;
			if(typeof pageErrors != 'undefined'){
				for(var indexPageError = 0; indexPageError < pageErrors.length; indexPageError++){
					var pageError = pageErrors[indexPageError];
					console.log("pageError" + pageError.message);
					// errorMessage += pageError.statusCode + ' | ' + pageError.message + '\n';
					if(pageError.statusCode == "FIELD_CUSTOM_VALIDATION_EXCEPTION" && !errorMessage.includes(pageError.message)){
						errorMessage += '- ' +  pageError.message + '\n';
					}				
				}
			}
		}
		var toastEvent = $A.get("e.force:showToast");

		if(errorMessage == ""){
			toastEvent.setParams({
		    title: "Error !",
		    message: "The system encountered a following problem, please contact your administrator",
		    duration: 60000,
		    type: "error"
		});
		}
		else if(errorMessage.includes("You are not allowed to change the field Location")){
			toastEvent.setParams({
		    title: "Error !",
		    message: "The original quote and the target opportunity must have the same location",
		    duration: 60000,
		    type: "error"
		});
		}
		else{
			toastEvent.setParams({
		    title: "Error !",
		    message: "The system encountered the following problem(s) : " + '\n' + errorMessage,
		    duration: 60000,
		    type: "error"
		});
		}
		
		toastEvent.fire();
	}	


})