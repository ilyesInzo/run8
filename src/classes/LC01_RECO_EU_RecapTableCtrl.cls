public with sharing  class LC01_RECO_EU_RecapTableCtrl {
	@AuraEnabled
        public static PM_Selected_Tubes_Config__c getSelectedConfig(Id qliId){
           String sQuery = AP00_PM_UtilityMethods.getAllFieldsForSOQL('PM_Selected_Tubes_Config__c');
        
        if(sQuery != null){
            sQuery += ' WHERE Quote_item__c = :qliId  order by createdDate DESC, lastModifiedDate DESC LIMIT 1';          
        } 
            return Database.query(sQuery);
        }
         @AuraEnabled
        public static void saveSelectedConfig(PM_Selected_Tubes_Config__c so){
            database.update(so,false) ;
            
        }
    	@AuraEnabled
        public static List<PM_Review_NetPrice_per_MOQ__c> getFinalPriceOffer(Id quoteLineItemId){
            Recordtype finalReviewRecType = [select Id, DeveloperName, sobjecttype from RecordType where DeveloperName = 'Final_Review_Price' and sobjecttype = 'PM_Review_NetPrice_per_MOQ__c' limit 1];
			system.debug('getFinalPriceOffer : finalReviewRecType ' +finalReviewRecType);
			return [select  MOQ_Units__c,Quoted_Price__c  from PM_Review_NetPrice_per_MOQ__c  where Quote_Line_Item__c = :quoteLineItemId and  MOQ_Units__c!= null and RecordTypeId = :finalReviewRecType.id order by MOQ_Units__c  ];
            
            
        }
         @AuraEnabled 
        public static void sendEmail(String message, id qliId,string to,string subject) {
              String currentUseremail = UserInfo.getUserEmail();       
              String  url= URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/QuoteLineItem/'+qliId+'/view' ;
              String msg= message.replaceAll('<p>', '').replaceAll('</p>', '\r');
              String body = msg+'\r the link of the Quote Line Item concerned is : '+url;
            try{
              Messaging.SingleEmailMessage emailMessage = EmailUtils.createEmailMessage(new List<string>{to}, null, null, subject, body);
              EmailUtils.sendEmail(emailMessage);    
            }
            catch(Exception ex)
            {
                 //throw new AuraHandledException(ex.getMessage());
            }
 }
         @AuraEnabled 
        public static String getKamManagerEMail(id quoteId) {
           
            Opportunity opp= [select Sales_Allocation_Id__r.Sales_Team__r.Manager__c,(select Id from Quotes where Id= :quoteId) from Opportunity  Limit 1];
             User Manger=null;
            if( opp.Sales_Allocation_Id__r.Sales_Team__r.Manager__c != null)
            {
                 Manger=[select Id,Email from user where id=:opp.Sales_Allocation_Id__r.Sales_Team__r.Manager__c];
            	system.debug(Manger);
            }
            return Manger!= null?  Manger.Email:null;
 }
}