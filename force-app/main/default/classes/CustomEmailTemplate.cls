public class CustomEmailTemplate implements IEmailTemplate
    {
        string header;
        string body;
        string footer;
        string subject;
        /*
        NewArrivalTemplate.SetHeader('<img src=path/h%mlogo>');
        NewArrivalsTemplate.SetBody('New styles available today');
        NewArrivalsTemplate.SetFooter('<a href=http://h&mwebsite.com>');
       
        NewArrivalsTemplate.GetHeader();
        NewArrivalsTemplate.GetBody();
        NewArrivalsTemplate.GetFooter();
        
 		NewArrivalsTemplate.SetSubject(subject);
        NewArrivalsTemplate.SetBody(body);
        
        
       
        email.SetTemplate(NewArrivalsTemplate);
		*/
       
        

       
        public string MergeBody(string content)
        {
         
            string part = this.GetBody();
            
            part = part.replace('<br />','');
            part = part.replace('<br>','');
            part = part.replace('&nbsp;&nbsp;','');
            part = part.replace('  ','');
            part = part.unescapeHtml4();
            part = part.replace('&nbsp;&nbsp;','');
            part = part.replace('  ','');
            //the template body might also contain merge fields so we may need to make a call to template.DoMerge();
                       
            return part.replace('{{content}}', content);
            
        }
        
        /*public void SetHeader(string header)
        {
            this.header = header;
        }*/
        
        public void SetBody(string body)
        {
            this.body = body;
        }
         
       /* public void SetFooter(string footer)
        {
            this.footer = footer;
        }*/
        
        public void SetSubject(string subject)
        {
            this.subject = subject;
        }
        
        public string GetHeader()
        {
            return this.header;
        }
        
        public string GetBody()
        {
            return this.body;
        }
        
        public string GetFooter()
        {
            return this.footer;
        }
        
        public string GetSubject()
        {
            return this.subject;
        }
        
        
        

       

        
    }