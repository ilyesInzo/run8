({
	helperMethod : function() {
		
	}
	
	
	/*  


	<div style="{!if(v.isDisabled, '', 'display : none')}">        
       <ui:inputText value="{!v.value}" label="{!v.label}" disabled="true"/>  
    </div>
   
	<div style="{!if(and(and(lessthan(v.optionslength, 85),greaterthan(v.optionslength, 0)),not(v.isDisabled)), '', 'display : none')}">        
       <label class="slds-form-element__label">{!v.label}</label>
		<div class="slds-button-group" style="display: block!important;" role="group">
			<aura:iteration items="{!v.options}" var="opt">			        	
				<ui:button label="{!opt}" buttonTitle="{!opt}" class="{!if(v.pickvalue == opt, 'slds-button--brand', 'slds-button--neutral')}" press="{!c.buttonChange}" labelClass="label-button" />
			</aura:iteration>
		</div>
    </div> 
    
	<div style="{!if(and(!v.isDisabled, or(v.optionslength == 0, v.optionslength >= 85)), '', 'display : none')}">        
       <ui:inputSelect label="{!v.label}" value="{!v.pickvalue}" change="{!c.pickvaluechange}" disabled="{!v.optionssize == 0}" >
			<ui:inputSelectOption text="" label="--None--" />  
			<aura:iteration items="{!v.options}" var="opt"> 
				<ui:inputSelectOption text="{!opt}" label="{!opt}"/>
			</aura:iteration>
	  </ui:inputSelect>
    </div>

*/
})