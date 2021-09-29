public class Batch_Historisation_UpdatePrices implements Database.Batchable<sObject>, Database.Stateful { 
	String query;
    public list<Object> errors = new list<Object>();

	public Batch_Historisation_UpdatePrices(){     
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select Id, Dispensing_Pricing__c, Dispensing_Pricing__r.closed_Price__c, Selected_Dispensing__c, Selected_Tube__c, Tube_Pricing__c, Tube_Pricing__r.closed_Price__c, Unique_Key__c ' +
            ' from PM_Config_to_Pricing__c where ((Selected_Dispensing__r.Quote_item__r.Quote.Status = \'Draft\' or Selected_Dispensing__r.Quote_item__r.Quote.Status = \'Simulation\') ' +
            ' and Dispensing_Pricing__r.Closed_Price__c = true) ' + 
            ' or ((Selected_Tube__r.Quote_item__r.Quote.Status = \'Draft\' or Selected_Tube__r.Quote_item__r.Quote.Status = \'Simulation\') and Tube_Pricing__r.Closed_Price__c = true ) ';
        if (Test.isRunningTest()) query += ' limit 1';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scoope) {
        System.debug('@@@@ scoope:-->  '+ scoope);
        if (scoope!= null && scoope.size()> 0){
              Batch_Historisation_UpdatePrices_Helper helper = new Batch_Historisation_UpdatePrices_Helper();
              helper.init(scoope); 
              errors.addAll(helper.updateSelectedConfigs());
              //helper.updatePrices();
             

        }
    }

    public void finish(Database.BatchableContext BC) {

           System.debug('@@@ Errors: '+ errors);
          
          if (errors.size()>0) {
            String[] toAddresses = new String[] { 'salesforcesupport@albea-group.com' };//System.Label.EMAIL_ALERT_TOADDRESSES.split(';');
            String senderDisplayName = 'Batch Error: Historisation - Update Prices' ;
            String subject = 'Error from Org : ' + UserInfo.getOrganizationName();
            String body = 'ERRORS : \n\n'+ JSON.serializePretty(errors);
            Messaging.SingleEmailMessage message = EmailUtils.createEmailMessage(toAddresses, null, null, subject, body);
            EmailUtils.setFromAddress(null, senderDisplayName, message);
            EmailUtils.sendEmail(message);

          }

          Batch_Historisation_UncheckDispPricing b = new Batch_Historisation_UncheckDispPricing();
          database.executebatch(b);
    }

}