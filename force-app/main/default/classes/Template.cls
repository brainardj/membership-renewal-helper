public class Template {

    public static String doMerge(String part, Id whoId, Id whatId){
        
        String mergedBody;
        String completeMerge;
		List<Messaging.RenderEmailTemplateBodyResult> merges = new List<Messaging.RenderEmailTemplateBodyResult>();
   
        //if(useLetterhead && null == ClickpdxMail.Letterhead){
          //  throw new OcdlaEmailException('Letterhead has not been assigned a value.');
        //}
        if(null == whoId){
            throw new MergeException('The whoId cannot be null when rendering email templates.');            
        } else if(null == whatId){
            // throw new OcdlaEmailException('The whatId cannot be null when rendering email templates.');
        }

        if(part.contains('{!')){
            merges.addAll(Messaging.renderEmailTemplate(whoId, whatId, new List<String>{part}));
            
            if(null == merges || merges.size()<1){
                throw new MergeException('No merges resulted from the operation.');
            }
            if(!merges[0].getSuccess()){
                throw new MergeException('There was an error merging the email.');
            }
        }
        
        mergedBody = merges.size() > 0 ? merges[0].getMergedBody() : part;        
        
        return mergedBody;
            
    }
    
    public Class MergeException extends Exception{}
       
      

}