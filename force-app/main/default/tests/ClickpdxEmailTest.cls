@IsTest
public class ClickpdxEmailTest {
    private static TestMethod void LoadEmailTemplate()
    {
        Contact c = new Contact(FirstName = 'Jack', LastName = 'Brainard', Email = 'brainardj@gmail.com');
        insert c;
      
        ClickpdxEmail email = new ClickpdxEmail();
        
        CustomEmailTemplate renewal = new CustomEmailTemplate();
        
        SalesforceEmailTemplate newTemplate = new SalesforceEmailTemplate('test_template');
        
        string templateSubject ='Renew your membership today {!Contact.FirstName} {!Contact.LastName} ';
                 
        string templateBody = '<html>Hello {!Contact.firstName} {!Contact.lastName} {{content}} </html>';
        
        renewal.SetSubject(templateSubject);
        renewal.SetBody(templateBody);
 
        c = [SELECT Id, firstName, lastName, Email from Contact where Id= :c.Id];
        
        string body = newTemplate.GetBody();
             
        string MergedBody = renewal.MergeBody('foobar');
       
    }
    
    private static TestMethod void EmailHelperTest()
    {
        Contact c = new Contact(FirstName = 'Jack', LastName = 'Brainard', Email = 'brainardj@gmail.com');
        insert c;
        
        ClickpdxEmail email = new ClickpdxEmail();
        
        c = [SELECT Id, firstName, lastName, Email from Contact where Id= :c.Id];
        
        ClickpdxEmail.emailHelper(c.Id);	       
    }
    
    private static TestMethod void SendEmail()
    {
        
        Contact c = new Contact(FirstName = 'Jack', LastName = 'Brainard', Email = 'brainardj@gmail.com');
        insert c;
        
        ClickpdxEmail email = new ClickpdxEmail();
        
        //email.SetTemplate(MembershipRenewalTemplate);
        email.SetSubject('Hello {!Contact.FirstName} {!Contact.LastName}');
        email.SetBody('<a href="http://MembershipRenewal?id={!Contact.Id}"/>');
        
        c = [SELECT Id, firstName, lastName, Email from Contact where Id= :c.Id];
        
        email.SetContact(c);
        
        
       
        ClickpdxEmail.SendEmailStatus status = email.Test();
        
    }
    
    private static TestMethod void SendEmailWithTemplate()
    {
        Contact c = new Contact(FirstName = 'Jack', LastName = 'Brainard', Email = 'brainardj@gmail.com');
        insert c;
        
        ClickpdxEmail email = new ClickpdxEmail();
        
        CustomEmailTemplate MembershipRenewalTemplate = new CustomEmailTemplate();
        
        string templateSubject ='Renew your membership today {!Contact.FirstName} {!Contact.LastName} ';
                 
        string templateBody = '<html>Hello {!Contact.firstName} {!Contact.lastName} {{content}} </html>';
        
        MembershipRenewalTemplate.SetSubject(templateSubject);
        MembershipRenewalTemplate.SetBody(templateBody);
        
        email.SetTemplate(MembershipRenewalTemplate);
        email.SetBody('<a href="http://MembershipRenewal?id={!Contact.Id}"/>');
        string mySubject = email.GetSubject();
        string myBody = email.GetBody();
        
        system.assert(mySubject != null);
        system.assert(myBody != null);
        
        c = [SELECT Id, firstName, lastName, Email from Contact where Id= :c.Id];
        
        email.SetContact(c);
       
        ClickpdxEmail.SendEmailStatus status = email.Test();
    }
    
    private static TestMethod void ContentDoMerge()
    {
        
        Contact c = new Contact(FirstName = 'Jack', LastName = 'Brainard', Email = 'brainardj@gmail.com');
        insert c;
        
        ClickpdxEmail email = new ClickpdxEmail();
        
        CustomEmailTemplate MembershipRenewalTemplate = new CustomEmailTemplate();
        
        string templateSubject ='Renew your membership today {!Contact.FirstName} {!Contact.LastName} ';
                 
        string templateBody = '<html>Hello {!Contact.firstName} {!Contact.lastName} {{content}} </html>';
        
        MembershipRenewalTemplate.SetSubject(templateSubject);
        MembershipRenewalTemplate.SetBody(templateBody);
        
        email.SetTemplate(MembershipRenewalTemplate);
        email.SetBody('<a href="http://MembershipRenewal?id={!Contact.Id}"/>');
        string mySubject = email.GetSubject();
        string myBody = email.GetBody();
        
        system.assert(mySubject != null);
        //system.assertEquals('<a href="http://MembershipRenewal?id={!Contact.Id}"/>', myBody);
        
        c = [SELECT Id, firstName, lastName, Email from Contact where Id= :c.Id];
        
        email.SetContact(c);
        
        string mergedBody = Template.doMerge(myBody, c.Id, null);
       
        ClickpdxEmail.SendEmailStatus status = email.Test();
        
    }
    

}