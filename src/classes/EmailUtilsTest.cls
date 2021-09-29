@isTest
private class EmailUtilsTest {

    //static Id orgWideEmailAddressId = [SELECT Id,Address,DisplayName FROM orgWideEmailAddress LIMIT 1].Id;
    
    @isTest 
    static void createEmailMessageTest() {

        // Param
        String toAddresses1 = 'test@albea-group.com';
        String ccAddresses1 = 'test@albea-group.com';
        String bccAddresses1 = 'test@albea-group.com';
        String toAddresses2 = 'test@albea-group.com';
        String ccAddresses2 = 'test@albea-group.com';
        String bccAddresses2 = 'test@albea-group.com';
        String subject = 'Subject';
        String body = 'Body';
        String senderDisplayName = 'It is me';

        // Call Class
        Messaging.SingleEmailMessage message0 = EmailUtils.createEmailMessage(null, null, null, subject, body);

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>{
            EmailUtils.createEmailMessage(toAddresses1.split(';'), ccAddresses1.split(';'), bccAddresses1.split(';'), subject, body),
            EmailUtils.createEmailMessage(toAddresses2.split(';'), ccAddresses2.split(';'), bccAddresses2.split(';'), subject, body)
        };

        EmailUtils.setFromAddress(null, senderDisplayName, messages[0]);
        //EmailUtils.setFromAddress(orgWideEmailAddressId, null, messages[1]);
        EmailUtils.sendEmail(messages);
        EmailUtils.sendEmail(messages[0]);

        // Result
        System.assert(messages[1] != null);
    }

    
    
}