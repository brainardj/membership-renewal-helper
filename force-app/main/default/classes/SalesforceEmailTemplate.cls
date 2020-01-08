public class SalesforceEmailTemplate implements IEmailTemplate
{
    string body;
    string subject;

    public SalesForceEmailTemplate(string template)
    {
       EmailTemplate salesforceTemplate = [select id, name , subject, body from EmailTemplate where name = :template];
        body = salesforceTemplate.body;
        subject = salesforceTemplate.subject;
        //developer name
    }
    
          
        public void SetBody(string body)
        {
            this.body = body;
        }
         
        
        public void SetSubject(string subject)
        {
            this.subject = subject;
        }
        
        
        public string GetBody()
        {
            return this.body;
        }
        
        
        public string GetSubject()
        {
            return this.subject;
        }
        
    
        public string MergeBody(string content)
        {
         
            string part = this.GetBody();
            
           /* part = part.replace('<br />','');
            part = part.replace('<br>','');
            part = part.replace('&nbsp;&nbsp;','');
            part = part.replace('  ','');
            part = part.unescapeHtml4();
            part = part.replace('&nbsp;&nbsp;','');
            part = part.replace('  ','');
              */
            //the template body might also contain merge fields so we may need to make a call to template.DoMerge();
            
             
        
           
            
            return part.replace('{{content}}', content);
            
        }
    
    
}