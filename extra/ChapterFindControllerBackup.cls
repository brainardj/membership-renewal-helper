Global class FindChapterController extends PagesApi.DefaultTemplateController{

    Global Contact UserContactData {get; set;}
    public boolean hasError{ get; set; }
    public boolean isRenewal{ get; set; }
    public boolean isCurrencyChange{ get; set; }
    public boolean isUpdateAddress{ get; set; }
    public boolean isChapterButton{ get; set; }
    public string initialCurrency;
    
    public FindChapterController(){
       this.UserContactData = getCurrentContact();
       hasError = false;
       isRenewal = false;
       isCurrencyChange = false;
       isUpdateAddress = false;
       isChapterButton=true;
       
       if(String.isBlank(this.UserContactData.MailingStreet)){ // hide find chapter button if address is blank
        isChapterButton = false;
       }
       
       
       if (!String.isBlank(Framework.PageUtils.getParam('addressonly'))) { // execute address flow only if user come to this page from "Address Update" link
            isUpdateAddress = TRUE;
       }
       
       If(String.isBlank(Framework.PageUtils.getParam('id'))){ // execute address flow only if user come to this page from "Address Update" link
           isUpdateAddress = TRUE; 
       } 
       
       List<ChapterUtility.ChapterItem> existingChapterItems = new List<ChapterUtility.ChapterItem>();
       // check if context is renewal or new joining
       existingChapterItems = ChapterUtility.existingSubscriptions(UserContactData);
       If(!existingChapterItems.isEmpty() && !isUpdateAddress){ // consider renewal only if contact has existing cubscription and user does not access this page from "Address Update" link
            system.debug(' inside renewal flow ');
            isRenewal = TRUE;
        }
        initialCurrency = UserContactData.CurrencyISOCode; 
       // system.debug('current ISO code = ' + initialCurrency); 
       // system.debug('currency change' + isCurrencyChange);
    }
    
    public pagereference SaveAndShowChapters(){
        // check data 
        hasError = FALSE;
        isCurrencyChange = false;
        If(String.isBlank(UserContactData.MailingStreet)){
            //Framework.Message.addMessage(System.Label.FindChapter_Street_error, Framework.Message.Severity.Warning);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.FindChapter_Street_error));
            hasError = true;
            return null;
        }
        /*
        let VF page hanbdle this
        If(String.isBlank(UserContactData.MailingStateCode)){
            Framework.Message.addMessage(System.Label.FindChapter_State_Error, Framework.Message.Severity.Warning);
            hasError = true;
            return null;
        }*/
        If(String.isBlank(UserContactData.MailingCountryCode)){
          //  Framework.Message.addMessage(System.Label.FindChapter_Country_error, Framework.Message.Severity.Warning);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.FindChapter_Country_error));
            hasError = true;
            return null;
        }
        system.debug('Before Lattitude = ' + UserContactData.MailingLatitude + ' longitude = ' + UserContactData.MailingLongitude); 

            try{
                string conAddress = UserContactData.MailingStreet;
                If(!String.isBlank(UserContactData.MailingCity)){
                    conAddress = conAddress + ','+UserContactData.MailingCity;
                }
                If(!String.isBlank(UserContactData.MailingStateCode)){
                    conAddress = conAddress + ','+UserContactData.MailingStateCode;
                }
                //GEOCODE API callout to populate latitude and longitude on Contact
                HttpResponse res = Geocode.MakeGetCallout(conAddress, UserContactData.MailingCountryCode);
                Geocode GP = Geocode.parse(res.getBody());
                if( GP.results.size()>0 ){
                    UserContactData.MailingLatitude = GP.results[0].Geometry.Location.lat;
                    UserContactData.MailingLongitude = GP.results[0].Geometry.Location.lng;
                }
            }catch(System.CalloutException ex){
                system.debug('Callout Error message = ' + ex.getMessage());
                //Framework.Message.addMessage(System.Label.FindChapterController_Callout_Error, Framework.Message.Severity.Warning);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.FindChapterController_Callout_Error));
                hasError = true;
                return null;
            }catch (Exception ex) {
                system.debug('Error message = ' + ex.getMessage());
               // Framework.Message.addMessage(System.Label.FindChapterController_Callout_Error, Framework.Message.Severity.Warning);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.FindChapterController_Callout_Error));
                hasError = true;
                return null;
            }    
         
       // system.debug('on Page contact b4 update = ' + UserContactData.currencyIsoCOde ) ;
        update UserContactData;
        //re set the value in below fields after update as without this, page causes issue 
        Contact myCon = [Select id, CurrencyISOCODE, PagesApi__Site__c, Region__c From Contact Where Id=:UserContactData.Id][0];
        UserContactData.CurrencyIsoCode = myCon.CurrencyIsoCode;
        UserContactData.PagesApi__Site__c = myCon.PagesApi__Site__c;
        UserContactData.Region__c = myCon.Region__c;
        
      //  system.debug('on Page contact after update = ' + UserContactData.currencyIsoCOde ) ;
        
        //UserContactData = getCurrentContact();
        
        isChapterButton=true;
        
      //  system.debug('after Lattitude = ' + UserContactData.MailingLatitude + ' longitude = ' + UserContactData.MailingLongitude);
        
        // show message if currency changes and 
        string currenctCurr = [Select Id, CurrencyISOCode From Contact Where Id=:UserContactData.Id][0].CurrencyISOCode;
        if(initialCurrency!=null && initialCurrency!=currenctCurr && isRenewal){
            isCurrencyChange = TRUE;
            //Framework.Message.addMessage(System.Label.FindChapter_Currency_Msg, Framework.Message.Severity.Warning);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.FindChapter_Currency_Msg));
            hasError = true;
            return null;
        }
       if(isUpdateAddress){
          // Framework.Message.addMessage(System.Label.FindChapter_Address_Success, Framework.Message.Severity.Success); 
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.FindChapter_Address_Success));
       }else{ 
           //Framework.Message.addMessage(System.Label.FindChapter_Success, Framework.Message.Severity.Success); 
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.FindChapter_Success));
       }    
       return null;
    }
    
    
    public PageReference nextStep() {
        //save contact address
        try{
            String stepId = Framework.PageUtils.getParam('id');
            System.debug( 'stepId: '+stepId );
                
            joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
            String redirectURL = joinUtil.navStepsMap.get('Next');
            System.debug( 'redirectURL: '+redirectURL );
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('stepId', stepId);
            //system.debug('===UserContact '+UserContact);
            PageReference pgRef = new PageReference(redirectURL);
            
            gen.writeStringField('redirectURL', redirectURL);
            gen.writeEndObject();

            /*if(gen.getAsString()!=null)
                joinUtil.setRedirectURLCookie(gen.getAsString());*/           
                return pgRef;
                //return null;
            }
            catch(Exception e){
                system.debug('===exception'+e.getLineNumber()+e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                 return null;

            }
    }
      
    public PageReference previousStep() {
        String stepId = Framework.PageUtils.getParam('id');
        joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
        //if(!Test.isRunningTest())
            return new PageReference(joinUtil.navStepsMap.get('Previous'));

        //return null;
    }

    public PageReference cancelStep() {
        String stepId = Framework.PageUtils.getParam('id');
        joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);        
        joinUtil.deleteCookies();
        return new PageReference(joinUtil.navStepsMap.get('First'));
    }
    
}