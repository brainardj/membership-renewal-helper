global without sharing class OcdlaMail {
    
    private static Boolean ALL_OR_NOTHING = False;
   
    private static String CC_ADDRESS = 'admin@ocdla.org';
    
    private static Messaging.SingleEmailMessage[] theMessages = new Messaging.SingleEmailMessage[]{};
    
    private static Messaging.SendEmailResult[] results = new Messaging.SendEmailResult[]{};
        
    public static String LetterheadName;
        
    private static String Letterhead {
        get {
            if(null == Letterhead){
                Letterhead = [SELECT ClickpdxCore__Value__c  FROM ClickpdxCore__CoreConfig__mdt  WHERE DeveloperName = :LetterheadName LIMIT 1].ClickpdxCore__Value__c;
            }
            return Letterhead;
        } 
        private set;
    }
    

    private static void reset(){
        theMessages = new Messaging.SingleEmailMessage[]{};
        results = new Messaging.SendEmailResult[]{};
    }
    
    /**
     * previewEmails
     */
    webservice static List<SendEmailStatus> sendEmails(List<Id> recordIds, String emailTemplateName){

        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :recordIds];

        if(null == contacts || 0 == contacts.size()){
            throw new OcdlaEmailException('No Contacts selected.');
        }
        
        OcdlaMail.reset();
        OcdlaMail.LetterheadName = 'OcdlaEmailLetterhead';
        
        String templateBody;
        String templateSubject;
        
        
        OcdlaEmailTemplate__c emailTemplate = [SELECT Id, OcdlaSubject__c, OcdlaHtmlBody__c  FROM OcdlaEmailTemplate__c
                                               WHERE Name = :emailTemplateName LIMIT 1];
        templateSubject = emailTemplate.OcdlaSubject__c;
        templateBody = emailTemplate.OcdlaHtmlBody__c;

        
        for(Contact c :contacts){
            Messaging.SingleEmailMessage msg;
            String subject;
            String body;
            
            subject = OcdlaMail.doMerge(templateSubject, c.Id, null, False);
            body = OcdlaMail.doMerge(templateBody, c.Id, null, True); // True for "useLetterhead"


            msg = toSingleEmailMessage(c.Email, subject, body, c.Id);

            OcdlaMail.addToQueue(msg);
        }

        if(theMessages.size() == 0){
            throw new OcdlaEmailException('No SingleEmailMessage records were created.');
        }
        OcdlaMail.doEmailSend();
        
		return getStatuses(results);
    }

    
    
    /**
     * previewEmails
     */
    webservice static String[] testEmails(List<Id> recordIds, String emailTemplateName){

        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :recordIds];
        String[] bodies = new String[]{};
        OcdlaMail.LetterheadName = 'OcdlaEmailLetterhead';
        
        String templateBody;
        String templateSubject;
        
        
        OcdlaEmailTemplate__c emailTemplate = [SELECT Id, OcdlaSubject__c, OcdlaHtmlBody__c  FROM OcdlaEmailTemplate__c WHERE Name = :emailTemplateName LIMIT 1];
        templateSubject = emailTemplate.OcdlaSubject__c;
        templateBody = emailTemplate.OcdlaHtmlBody__c;

        
        for(Contact c :contacts){
            Messaging.SingleEmailMessage msg;
            String subject;
            String body;
            
            subject = OcdlaMail.doMerge(templateSubject, c.Id, null, False);
            body = OcdlaMail.doMerge(templateBody, c.Id, null, True); // True for "useLetterhead"


			bodies.add(body);
            msg = toSingleEmailMessage('jbernal.web.dev@gmail.com', subject, body, null);

            OcdlaMail.addToQueue(msg);
        }


        OcdlaMail.doEmailTestSend();
        
        return bodies;
    }
    /**
     * previewEmails
     */
    webservice static String[] previewEmails(List<Id> recordIds, String emailTemplateName){

        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :recordIds];
        String[] bodies = new String[]{};
        OcdlaMail.LetterheadName = 'OcdlaEmailLetterhead';
        
        String templateBody;
        String templateSubject;
        
        
        OcdlaEmailTemplate__c emailTemplate = [SELECT Id, OcdlaSubject__c, OcdlaHtmlBody__c  FROM OcdlaEmailTemplate__c WHERE Name = :emailTemplateName LIMIT 1];
        templateSubject = emailTemplate.OcdlaSubject__c;
        templateBody = emailTemplate.OcdlaHtmlBody__c;

        
        for(Contact c :contacts){
            Messaging.SingleEmailMessage msg;
            String subject;
            String body;
            
            subject = OcdlaMail.doMerge(templateSubject, c.Id, null, False);
            body = OcdlaMail.doMerge(templateBody, c.Id, null, True); // True for "useLetterhead"


			bodies.add(body);
            msg = toSingleEmailMessage('jbernal.web.dev@gmail.com', subject, body, null);

            // OcdlaMail.addToQueue(msg);
        }


        // OcdlaMail.doEmailSend();
        
        return bodies;
    }
    
    
    public static Messaging.SingleEmailMessage addToQueue(Messaging.SingleEmailMessage m){
        theMessages.add(m);
        return m;
    }


    
    public static Messaging.SendEmailResult[] doEmailSend(){
		Boolean sent;
        
        OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress LIMIT 1];


            
        List<String> ccAddresses = new List<String>();
        if(null != CC_ADDRESS) {
            ccAddresses.add(CC_ADDRESS);
        }

        for(Messaging.SingleEmailMessage msg :theMessages){
            msg.setCcAddresses(ccAddresses);
            msg.setSenderDisplayName(null);
            msg.setOrgWideEmailAddressId(owa.id);
        }
        
        results = send(theMessages);
        System.debug(results);
        
        return results;
    }
     
    
    public static Messaging.SendEmailResult[] doEmailTestSend(){
		Boolean sent;
        
        OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress limit 1];
        
        List<String> toAddresses = new List<String>{UserInfo.getUserEmail()};      

        for(Messaging.SingleEmailMessage msg :theMessages){
            msg.setToAddresses(toAddresses);
            msg.setTargetObjectId(null);
            msg.setSenderDisplayName(null);
            msg.setOrgWideEmailAddressId(owa.id);
        }
        
        return send(theMessages);
    }

    


    public static String doEmailPreview(){
        String previewAll = '';
        
        for(Messaging.SingleEmailMessage m :theMessages){
            previewAll += m.getHtmlBody();
        }
        
        return previewAll;
    }

    
    /**
     *  WARNING!  The String parameter <part> of this method must contain
     *  actual merge fields for the whatId, otherwise the merge will fail with an 
     *     EMAIL_TEMPLATE_PROCESSING_ERROR error.
     */
    public static String doMerge(String part, Id whoId, Id whatId){
        return doMerge(part,whoId,whatId,False);
    }
    
    
    
    public static String doMerge(String part, Id whoId, Id whatId, Boolean useLetterhead){
        
        String mergedBody;
        String completeMerge;
		List<Messaging.RenderEmailTemplateBodyResult> merges = new List<Messaging.RenderEmailTemplateBodyResult>();
   
        if(useLetterhead && null == OcdlaMail.Letterhead){
            throw new OcdlaEmailException('Letterhead has not been assigned a value.');
        }
        if(null == whoId){
            throw new OcdlaEmailException('The whoId cannot be null when rendering email templates.');            
        } else if(null == whatId){
            // throw new OcdlaEmailException('The whatId cannot be null when rendering email templates.');
        }
        
        if(useLetterhead){
            // part = part.replace('<br />','');
            part = part.replace('<br>','');
            part = part.replace('&nbsp;&nbsp;','');
            part = part.replace('  ','');
            part = part.unescapeHtml4();
            part = part.replace('&nbsp;&nbsp;','');
            part = part.replace('  ','');
        }
        
        // Messaging.RenderEmailTemplateBodyResult theMerge = new Messaging.RenderEmailTemplateBodyResult();
        
        if(part.contains('{!')){
            merges.addAll(Messaging.renderEmailTemplate(whoId, whatId, new List<String>{part}));
            
            if(null == merges || merges.size()<1){
                throw new OcdlaEmailException('No merges resulted from the operation.');
            }
            if(!merges[0].getSuccess()){
                throw new OcdlaEmailException('There was an error merging the email.');
            }
        }
        
        mergedBody = merges.size() > 0 ? merges[0].getMergedBody() : part;
        
        return (useLetterhead ? OcdlaMail.Letterhead.replace('{{content}}', mergedBody) : mergedBody);
    }
    



    public static Messaging.SendEmailResult[] send(){
        return Messaging.sendEmail(theMessages, ALL_OR_NOTHING);
    }    
    
    public static Messaging.SendEmailResult[] send(List<Messaging.SingleEmailMessage> theMessages){
        return Messaging.sendEmail(theMessages, ALL_OR_NOTHING);
    }
 


    public static List<SendEmailStatus> getStatuses(){
        return getStatuses(results);
    }
    public static List<SendEmailStatus> getStatuses(List<Messaging.SendEmailResult> results){
        List<SendEmailStatus> statuses = new List<SendEmailStatus>();
        
        if(null == results || results.size() == 0){
            throw new OcdlaEmailException('Empty SendEmailResult[].');
        }
        
        Integer index = 0;
        for(Messaging.SendEmailResult result :results){
            SendEmailStatus theStatus = new SendEmailStatus();
            List<Messaging.SendEmailError> theErrors;
            
            if(!result.isSuccess()){
               	theErrors = result.getErrors();
                
                theStatus.isSuccess = false;
                theStatus.targetObjectId = theErrors[0].getTargetObjectId();
                theStatus.message = theErrors[0].getStatusCode() + ': '+theErrors[0].getMessage();

            } else {
                theStatus.isSuccess = true;
                theStatus.targetObjectId = theMessages[index].getTargetObjectId();
            }

            theStatus.whatId = theMessages[index].getWhatId();            
            statuses.add(theStatus);
            index++;
        }
        
        if(results.size() == 0 || results.size() != statuses.size()){
            throw new OcdlaEmailException('Status array is discordant.');
        }
        
        return statuses;
    }
    
    
    
    /**
     * For more information on setReferences see:
     *   https://tools.ietf.org/html/rfc2822#section-3.6.4
     * 
     */
    public static Messaging.SingleEmailMessage toSingleEmailMessage(String to, String subject, String body, Id whoId){
        return toSingleEmailMessage(to,subject,body,whoId,null);
    }
    public static Messaging.SingleEmailMessage toSingleEmailMessage(String to, String subject, String body, Id whoId, Id whatId){
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();

        
        msg.setSubject(subject);
        msg.setToAddresses(new List<String>{to});
        msg.setSenderDisplayName('OCDLA');
        msg.setHtmlBody(body);
        msg.setTreatBodiesAsTemplate(False); // Necessary because in this implementation the merge has already happened.
        msg.setTargetObjectId(whoId);
        msg.saveAsActivity = False;
        msg.setWhatId(whatId);
        String rand = '<'+Math.random()+'@ocdla.force.com>';
        msg.setReferences(rand);
        msg.setInReplyTo(rand); 
        
        return msg;
    }
    
    
    
    
    global class SendEmailStatus {
        webservice Boolean isSuccess = True;
        
        webservice DateTime dateSent;
        
        webservice String message;
        
        webservice Id targetObjectId {get; set;}
        
        webservice Id whatId {get; set;}
        
        public SendEmailStatus(){}
    }
    

    
    
    public class OcdlaEmailException extends Exception {}
    
}