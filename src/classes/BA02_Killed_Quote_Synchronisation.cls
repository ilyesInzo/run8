public class BA02_Killed_Quote_Synchronisation implements Database.Batchable<sObject>, Database.Stateful { 
	String query; 
	public list<Object> errors = new list<Object>();

	
	public BA02_Killed_Quote_Synchronisation() {
		}
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		//Request SOQL
		Integer timeLimit = Integer.valueOf(Label.KillQuoteTimeLimit);
         System.debug('@@@@ timeLimit: '+ timeLimit+ '---' + Label.KillQuoteTimeLimit);
        if(Test.isRunningTest()){
            timeLimit = 0;
        }
		Date dt = Date.today().addDays(- timeLimit);
		query = 'Select Id, Status, Decision_Date__c, OpportunityId from Quote where Status IN (\'Killed By Customer\',\'Killed By Albea\') and Decision_Date__c =: dt' ;
		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext BC, List<Quote> scoope) {
		// Quote or Sobject ?
        System.debug('@@@@ scoope: '+ scoope);
        if (scoope!= null && scoope.size()> 0){
              BA02_Killed_Quote_Synchronisation_Helper helper = new BA02_Killed_Quote_Synchronisation_Helper();
              helper.updateopp(scoope);
			  errors.addAll(helper.updateopp(scoope));
             
        }
        
    }
	
	public void finish(Database.BatchableContext BC) {

		System.debug('@@@ Errors: '+ errors);

		if (errors.size()>0) {
            String[] toAddresses = new String[] { 'salesforcesupport@albea-group.com' };//System.Label.EMAIL_ALERT_TOADDRESSES.split(';');
            String senderDisplayName = 'Batch Error: Killed Quote synchronisation' ;
            String subject = 'Error from Org : ' + UserInfo.getOrganizationName();
            String body = 'ERRORS : \n\n'+ JSON.serializePretty(errors);
            Messaging.SingleEmailMessage message = EmailUtils.createEmailMessage(toAddresses, null, null, subject, body);
            EmailUtils.setFromAddress(null, senderDisplayName, message);
            //EmailUtils.sendEmail(message);

          }

     
  }	
	
	
	
    
}