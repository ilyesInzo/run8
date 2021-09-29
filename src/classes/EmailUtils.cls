/**
* @author
* @date 
* @description 
*/
public class EmailUtils {

    /**
     * [createEmailMessage Creation d'un Email basique]
     * @param  toAddresses  [liste d'adresses destinataires]
     * @param  ccAddresses  [liste d'adresses en copie]
     * @param  bccAddresses [liste d'adresses en copie cachee]
     * @param  subject      [sujet du mail]
     * @param  body         [coprs du mail]
     * @return              [un objet Email]
     */
    public static Messaging.SingleEmailMessage createEmailMessage(String[] toAddresses, String[] ccAddresses, String[] bccAddresses, String subject, String textBody, String htmlBody) {
        // Log
        if ( (toAddresses == null || toAddresses.size() <= 0) 
            && (ccAddresses == null || ccAddresses.size() <= 0)
            && (bccAddresses == null || bccAddresses.size() <= 0) ) {
            System.debug(LoggingLevel.WARN, 'EmailUtils.createEmailMessage : Aucun destinataire renseigne');
        }
        if (String.isBlank(subject) && String.isBlank(textBody) && String.isBlank(htmlBody)) {
            System.debug(LoggingLevel.WARN, 'EmailUtils.createEmailMessage : Sujet et Corps du mail vide');
        }

        // Mail
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //message.setSubject(subject);
        //message.setPlainTextBody(body);
        setContent(subject, textBody, htmlBody, message);
        setToAddress(toAddresses, ccAddresses, bccAddresses, null, message);
        return message;
    }

    /**
     * [createEmailMessage description]
     * @param  toAddresses  [description]
     * @param  ccAddresses  [description]
     * @param  bccAddresses [description]
     * @param  subject      [description]
     * @param  body         [description]
     * @return              [description]
     */
    public static Messaging.SingleEmailMessage createEmailMessage(String[] toAddresses, String[] ccAddresses, String[] bccAddresses, String subject, String body) {
        return createEmailMessage(toAddresses, ccAddresses, bccAddresses, subject, body, null);
    }


    /**
     * [setContent description]
     * @param subject       [description]
     * @param plainTextBody [description]
     * @param htmlBody      [description]
     * @param message       [description]
     */
    public static void setContent(String subject, String plainTextBody, String htmlBody, Messaging.SingleEmailMessage message) {
        if (String.isNotBlank(subject)) {
            message.setSubject(subject);
        }
        if (String.isNotBlank(plainTextBody)) {
            message.setPlainTextBody(plainTextBody);
        }
        if (String.isNotBlank(htmlBody)) {
            message.setHtmlBody(htmlBody);
        }
    }

    /**
     * [setToAddress description]
     * @param message               [description]
     * @param orgWideEmailAddressId [description]
     */
    public static void setToAddress(String[] toAddresses, String[] ccAddresses, String[] bccAddresses, Boolean treatTargetObjectAsRecipient, Messaging.SingleEmailMessage message) {
        // Mise a jour des champs adresses du mail : emetteur et destinataires
        if (toAddresses != null && toAddresses.size() > 0) {
            message.setToAddresses(toAddresses);
        }
        if (ccAddresses != null && ccAddresses.size() > 0) {
            message.setCcAddresses(ccAddresses);
        }
        if (bccAddresses != null && bccAddresses.size() > 0) {
            message.setBccAddresses(bccAddresses);
        }
        // Si l'on utilise un template et que l'on veut que le destinataire 
        // ne soit pas dans les destinataires
        if (treatTargetObjectAsRecipient != null) {
            message.setTreatTargetObjectAsRecipient(treatTargetObjectAsRecipient);
        }
    }

    /**
     * [setFromAddress description]
     * @param message               [description]
     * @param orgWideEmailAddressId [description]
     */
    public static void setFromAddress(Id orgWideEmailAddressId, String senderDisplayName, Messaging.SingleEmailMessage message) {
        
        if (String.isNotBlank(orgWideEmailAddressId)) {
            message.setOrgWideEmailAddressId(orgWideEmailAddressId);
        }
        
        if (String.isNotBlank(senderDisplayName)) {
            message.setSenderDisplayName(senderDisplayName);   
        }
    }

    /**
     * [sendEmail Fonction d'envoi de mail unitaire.]
     * @param message [Email]
     */
    public static void sendEmail(Messaging.SingleEmailMessage message) {
        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
    }

    /**
     * [sendEmail Fonction d'envoi de mail.]
     * @param messages [Liste d'Email]
     */
    public static void sendEmail(Messaging.SingleEmailMessage[] messages) {
        Messaging.sendEmail(messages);
    }
 
}