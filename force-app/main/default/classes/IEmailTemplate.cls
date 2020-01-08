public interface IEmailTemplate {
    
    string MergeBody(string body);
    
    string GetSubject();
    
    string GetBody();
    
    void SetSubject(string theSubject);
    
    void SetBody(string theBody);
   
    
    
    

}