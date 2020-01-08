global without sharing class ClickpdxEmail {
    
    private static Boolean ALL_OR_NOTHING = False;
   
    private static String CC_ADDRESS = null;
    
    Boolean HasTemplate {get{return this.theTemplate!=null;} private set;}
    
    IEmailTemplate theTemplate = null; 
    
    string emailBody;
    
    string emailSubject;
    
    Contact theContact;
    
    private static Messaging.SingleEmailMessage[] theMessages = new Messaging.SingleEmailMessage[]{};
    
    private static Messaging.SendEmailResult[] results = new Messaging.SendEmailResult[]{};
    
    public static String LetterheadName;
        
    private static String Letterhead {
        get {
            if(null == Letterhead){
               // Letterhead = [SELECT ClickpdxCore__Value__c  FROM ClickpdxCore__CoreConfig__mdt  WHERE DeveloperName = :LetterheadName LIMIT 1].ClickpdxCore__Value__c;
            }
            return Letterhead;
        } 
        private set;
    }
    
    // This is the method that handles sets up an email with a template 
    public static void emailHelper(Id contactId){
           
    	ClickpdxEmail email = new ClickpdxEmail();
        
        CustomEmailTemplate renewal = new CustomEmailTemplate();
        
        SalesforceEmailTemplate newTemplate = new SalesforceEmailTemplate('new_template');
               
        string templateSubject ='Renew your membership today {!Contact.FirstName} {!Contact.LastName} ';
                 
        string templateBody = '<html>Hello {!Contact.firstName} {!Contact.lastName} {{content}} </html>';
                
        renewal.SetSubject(templateSubject);
        renewal.SetBody(templateBody);
        
        //If working with the custom email template class pass in renewal to setTemplate, if working with the SaleforceEmailTemplate pass in newTemplate
        email.setTemplate(newTemplate);
        email.setBody('<a href="http://MembershipRenewal?id={!Contact.Id}"> This is the link to access your products</a>');
        
        Contact c = [SELECT Id, firstName, lastName, Email from Contact where Id= :contactId];
        
        email.setContact(c);
       
        SendEmailStatus status = email.Test();
        
        string contactStatus =json.serialize(status);
        
        c.Status__c = contactStatus;
        
        update c;     
    }
    
    //This method merges fields on the email and sends the email
    public SendEmailStatus Test()
    {
        /*if(!HasTemplate && null == this.emailSubject)
        {
            throw new ClickpdxEmailException('Email has no subject');
        }
        if(!HasTemplate && null ==this.emailBody)
        {
            throw new ClickpdxEmailException('Email has no body');
        }*/
        
        string body = this.getBody();
        
        //string body = Template.doMerge(this.getBody(), this.theContact.Id, null);
            
        string mergedSubject = Template.doMerge(this.GetSubject(), this.theContact.Id, null);
        
        string mergedBody = Template.doMerge(body, this.theContact.Id, null);
        
        Messaging.SingleEmailMessage msg = toSingleEmailMessage(this.theContact.Email, mergedSubject, mergedBody, this.theContact.Id);

        ClickpdxEmail.addToQueue(msg);
    	//SendEmail(email);
    	
    	//email.send();
    	ClickpdxEmail.doEmailTestSend();
        List <SendEmailStatus> statuses= ClickpdxEmail.getStatuses();
        return statuses[0];
        
    }
    
    public string getBody()
    {
       return HasTemplate ? theTemplate.MergeBody(this.emailBody) : this.emailBody;   
    }
    
    public void setTemplate(IEmailTemplate theTemplate)
    {
       this.theTemplate = theTemplate;   
    }
    
   public String getSubject()
   {
      return HasTemplate ? theTemplate.GetSubject() : this.emailSubject;   
   }
    
    public void setContact(Contact c)
    {
        theContact = c;
    }
    
    public void setBody(string body)
    {
         emailBody = body;
        
    }
        
    public void setSubject(string subject)
    {
        emailSubject = subject;
    }
    
     
    //Creating an email
      //  for a selected user,
        //the email will have a link which is unique the user and will show their subscriptions which they are able to renew
    

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
            throw new ClickpdxEmailException('No Contacts selected.');
        }
        
        ClickpdxEmail.reset();
        ClickpdxEmail.LetterheadName = 'OcdlaEmailLetterhead';
        
        String templateBody;
        String templateSubject;
        
        
        //OcdlaEmailTemplate__c emailTemplate = [SELECT Id, OcdlaSubject__c, OcdlaHtmlBody__c  FROM OcdlaEmailTemplate__c
        //                                       WHERE Name = :emailTemplateName LIMIT 1];
        //templateSubject = emailTemplate.OcdlaSubject__c;
        //templateBody = emailTemplate.OcdlaHtmlBody__c;

        
        for(Contact c :contacts){
            Messaging.SingleEmailMessage msg;
            String subject;
            String body;
            
            subject = Template.doMerge(templateSubject, c.Id, null);
            body = Template.doMerge(templateBody, c.Id, null); // True for "useLetterhead"


            msg = toSingleEmailMessage(c.Email, subject, body, c.Id);

            ClickpdxEmail.addToQueue(msg);
        }

        if(theMessages.size() == 0){
            throw new ClickpdxEmailException('No SingleEmailMessage records were created.');
        }
        ClickpdxEmail.doEmailSend();
        
		return getStatuses(results);
    }

    
    
    /**
     * previewEmails
     */
    webservice static String[] testEmails(List<Id> recordIds, String emailTemplateName){

        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :recordIds];
        String[] bodies = new String[]{};
        ClickpdxEmail.LetterheadName = 'OcdlaEmailLetterhead';
        
        String templateBody;
        String templateSubject;
        
        
       // EmailTemplate emailTemplate = [SELECT Id, Subject, Body  FROM EmailTemplate WHERE Name = 'default_template'];
        //templateSubject = emailTemplate.Subject;
        //templateBody = emailTemplate.Body;

        
        for(Contact c :contacts){
            Messaging.SingleEmailMessage msg;
            String subject;
            String body;
            
            subject = Template.doMerge(templateSubject, c.Id, null);
            body = Template.doMerge(templateBody, c.Id, null); // True for "useLetterhead"


			bodies.add(body);
            msg = toSingleEmailMessage('jbernal.web.dev@gmail.com', subject, body, null);

            ClickpdxEmail.addToQueue(msg);
        }


        ClickpdxEmail.doEmailTestSend();
        
        return bodies;
    }
    /**
     * previewEmails
     */
    webservice static String[] previewEmails(List<Id> recordIds, String emailTemplateName){

        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :recordIds];
        String[] bodies = new String[]{};
        ClickpdxEmail.LetterheadName = 'OcdlaEmailLetterhead';
        
        String templateBody;
        String templateSubject;
        
        
        //OcdlaEmailTemplate__c emailTemplate = [SELECT Id, OcdlaSubject__c, OcdlaHtmlBody__c  FROM OcdlaEmailTemplate__c WHERE Name = :emailTemplateName LIMIT 1];
        //templateSubject = emailTemplate.OcdlaSubject__c;
        //templateBody = emailTemplate.OcdlaHtmlBody__c;

        
        for(Contact c :contacts){
            Messaging.SingleEmailMessage msg;
            String subject;
            String body;
            
            subject = Template.doMerge(templateSubject, c.Id, null);
            body = Template.doMerge(templateBody, c.Id, null); // True for "useLetterhead"


			bodies.add(body);
            msg = toSingleEmailMessage('jbernal.web.dev@gmail.com', subject, body, null);

            // ClickpdxEmail.addToQueue(msg);
        }


        // ClickpdxEmail.doEmailSend();
        
        return bodies;
    }
    
    
    public static Messaging.SingleEmailMessage addToQueue(Messaging.SingleEmailMessage m){
        theMessages.add(m);
        return m;
    }


    
    public static Messaging.SendEmailResult[] doEmailSend(){
		Boolean sent;
        
        //OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress LIMIT 1];


            
        List<String> ccAddresses = new List<String>();
        if(null != CC_ADDRESS) {
            ccAddresses.add(CC_ADDRESS);
        }

        for(Messaging.SingleEmailMessage msg :theMessages){
            msg.setCcAddresses(ccAddresses);
            msg.setSenderDisplayName(null);
            //msg.setOrgWideEmailAddressId(owa.id);
        }
        
        results = send(theMessages);
        System.debug(results);
        
        return results;
    }
     
    
    public static Messaging.SendEmailResult[] doEmailTestSend(){
		Boolean sent;
        
        //OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress limit 1];
        
        List<String> toAddresses = new List<String>{UserInfo.getUserEmail()};      

        for(Messaging.SingleEmailMessage msg :theMessages){
            msg.setToAddresses(toAddresses);
            msg.setTargetObjectId(null);
            msg.setSenderDisplayName(null);
           // msg.setOrgWideEmailAddressId(owa.id);
        }
        
        results = send(theMessages);
        return results;
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
            throw new ClickpdxEmailException('Empty SendEmailResult[].');
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
            throw new ClickpdxEmailException('Status array is discordant.');
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
    

    
    
    public class ClickpdxEmailException extends Exception {}
    
}