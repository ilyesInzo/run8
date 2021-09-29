/**
* @author
* @date 
* @description 
*/
global abstract class ParentBatch {

    // Declarer une variable global et implementer Database.Stateful dans le fils 
    // permet de conserver les valeurs de la liste entre differents appels de batches 
    // traites par lots (ie Database.executeBatch(job,3))
    // On aura bien acces a l'ensemble des erreurs dans la methode finish().
    global List<String> errors = new List<String>();

    global abstract String getBatchName();

    global virtual void addErrors(String message) {
        errors.add(message);
    }

    global virtual void addErrors(List<Database.SaveResult> results, String message) {
        Boolean isFirstError = true;
        for (Integer i=0; i<results.size(); i++) {
            Database.SaveResult result = results[i];
            if (!result.isSuccess()) {
                if (isFirstError) {
                    errors.add(message);
                    isFirstError = false;
                }
                for (Database.Error err : result.getErrors()) {
                    errors.add(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }

    global virtual void addErrors(List<SObject> sObjects, List<Database.SaveResult> results, String message) {
        Boolean isFirstError = true;
        for (Integer i=0; i<results.size(); i++) {
            Database.SaveResult result = results[i];
            if (!result.isSuccess()) {
                if (isFirstError) {
                    errors.add(message);
                    isFirstError = false;
                }
                for (Database.Error err : result.getErrors()) {
                    errors.add(err.getStatusCode() + ': ' + err.getMessage() + ', Id = '+sObjects[i].Id);
                }
            }
        }
    }


    global virtual void finish(Database.BatchableContext BC) {
        // Envoi d'un mail en cas d'erreur
        if (!errors.isEmpty()) {
            String[] toAddresses = System.Label.EMAIL_ALERT_TOADDRESSES.split(';');
            String senderDisplayName = 'Apex error message on batch ' + getBatchName();
            String subject = 'Error from Org : ' + UserInfo.getOrganizationName();
            String body = String.join(errors, '\n');
            System.debug(getBatchName() + ' : ' + body);
            Messaging.SingleEmailMessage message = EmailUtils.createEmailMessage(toAddresses, null, null, subject, body);
            EmailUtils.setFromAddress(null, senderDisplayName, message);
            EmailUtils.sendEmail(message);

        }
    }
}