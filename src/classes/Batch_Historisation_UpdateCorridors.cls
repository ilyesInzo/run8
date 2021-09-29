public class Batch_Historisation_UpdateCorridors implements Database.Batchable<sObject>, Database.Stateful{ 
	String query;
  public list<Object> errors = new list<Object>();

	public Batch_Historisation_UpdateCorridors(){     
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select Id, (select Id from PM_Selected_Dipsensing_Configs__r), '+
         ' (select Id from PM_Selected_Tubes_Configs__r), '+
         ' selected_corridor__c, selected_corridor__r.Closed_Price__c ' +
         ' from QuoteLineItem where (Quote.Status = \'Draft\' or Quote.Status = \'Simulation\') and selected_corridor__c != null '+
         ' and selected_corridor__r.Closed_Price__c = true';


       return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scoope) {
          

        if (scoope!= null && scoope.size()> 0){
              Batch_Historisation_UpdateCorr_Helper helper = new Batch_Historisation_UpdateCorr_Helper();
              helper.init(scoope); 
              errors.addAll(helper.updateSelectedConfigs());
              

        }
    }

    public void finish(Database.BatchableContext BC) {
          System.debug('@@@ Errors: '+ errors);
          
          if (errors.size()>0) {
            String[] toAddresses = new String[] { 'salesforcesupport@albea-group.com' };//System.Label.EMAIL_ALERT_TOADDRESSES.split(';');
            String senderDisplayName = 'Batch Error: Historisation - Update Corridors' ;
            String subject = 'Error from Org : ' + UserInfo.getOrganizationName();
            String body = 'ERRORS : \n\n'+ JSON.serializePretty(errors);
            Messaging.SingleEmailMessage message = EmailUtils.createEmailMessage(toAddresses, null, null, subject, body);
            EmailUtils.setFromAddress(null, senderDisplayName, message);
            EmailUtils.sendEmail(message);

          }

          Batch_Historisation_UncheckCorridors b = new Batch_Historisation_UncheckCorridors();
          database.executebatch(b);

    }

}