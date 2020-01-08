public without sharing class ClickpdxDefaultController extends PagesApi.DefaultTemplateController {

    // Application settings that are Org-specific.
    AppSettings settings;
    
    

    /**
     * @var products
     * 
     * @description A list of products that make up a membership renewal package for a given member.
     */
    public List<Member> members {public get; private set;}
    
    
    // Reference to the cookie needed to persist the current user's Id and OrderId
    //  On the Fonteva platform this is JSON.
    private FontevaCookie cartCookie;
    
    
    // The template (if any) to be used on the related Visualforce page.
    public PageReference templateName {get; private set;}
    
    
    // Indicates whether the user's cookie and resulting SalesOrder should be 
    //  assigned to the Community Site Guest User.
    Boolean alwaysUseCommunitySiteGuestUser = True;
    
    
    // Corresponds to Community Site Guest User.
    private Id communitySiteGuestUserId;
    
    
    // The OrderId to be managed through this UI.
    private Id orderId;
    
    
    // The Org/Company Id.
    private Id companyId;
    
    
    // The Id of the Contact record to manage memberhsip products for
   	private Id contactId;
    
    
    // Request currency, if any.  Probably should affect the Site - Store - Business Group
    public String currencyIsoCode {get; private set;}
        
    
    // The Member whose personal information we want to display.
    public Member theMember {public get; private set;}
    
    
    // Any previous membership
    public IProductBase previous {public get; private set;}
    
    public String previousText {public get{
        return null != previous ? this.previous.getName() : '';
    } private set;}
    

    
    
    // Any response to be sent to the client.
	public Map<String,Object> response {get;private set;}
    
    
    // Legacy attribute for Visualforce action methods.
    public String responseData {get{
        if(null == this.response){
            return JSON.serialize('{}');
        }
        return JSON.serialize(this.response);
    } private set;}
    

    
    private String getParam(String param){
        PageReference p = ApexPages.currentPage();
        
        return p.getParameters().get(param);
    }
    
    /**
     * @contructor
     * 
     * @description Initialize the page; this page displays a list of IProduct objects so
     *   build that Product List here.
     */
    public ClickpdxDefaultController(){
        settings = new AppSettings();
        // initSettings();
    

        // cartCookie = new FontevaCookie(companyId);
        // cartCookie.setUserId(communitySiteGuestUserId);
        // cartCookie.setFontevaSiteId(theMember.getCurrencySiteId());
        
        // cartCookie.save();
    
        
        setResponseData('members',this.members);
    }
    
    
    private Boolean hasCart(){
        return (null != cartCookie.getCookieOrderId());
    }
    

    
    private void setResponseData(String key, Object val){
        if(null == this.response){
            this.response = new Map<String,Object>();
        }
        
        this.response.put(key,val);
    }
    
    
}