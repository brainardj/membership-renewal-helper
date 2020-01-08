public class ClickpdxEmailController {

    List<id> recordIds = null;

		AppSettings settings;

		
		public String communityUrl {get; private set;}

    public ClickpdxEmailController(ApexPages.StandardSetController controller){
        Map<id,sObject> records = new Map<id,sObject>(controller.getSelected());
        recordIds = new List<id>(records.keySet());
        
				settings = new AppSettings();
				
				communityUrl = (String) settings.get('CommunityUrl');
				
    }
    public void SendEmail(){
       //ClickpdxEmail.sendEmails(recordIds, 'foobar'); 
    }
    
    public PageReference TestEmail(){
       // ClickpdxEmail.TestEmail(recordIds, 'foobar');
        ClickpdxEmail.EmailHelper(recordIds[0]);
        
        return null;
        
    }
    
    public void PreviewEmail(){
        //ClickpdxEmail.previewEmails(recordIds, 'foobar'); 
    }

}