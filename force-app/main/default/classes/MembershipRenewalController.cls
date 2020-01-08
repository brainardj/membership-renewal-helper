public without sharing class MembershipRenewalController {

    // Application settings that are Org-specific.
    AppSettings settings;
    
    
    // Workflow-related settings.
    Boolean WORKFLOW_DO_REDIRECT_TO_CHECKOUT = False;
    
    
    // Whether to try optional Purchase History query first.
    Boolean QUERY_PURCHASE_HISTORY = False;
    
    
    // Whether to auto-add chapter
    Boolean AUTO_ADD_CHAPTERS = True;
    
    
	Boolean USE_MEMBERSHIP_TYPE_FALLBACK = True;
    
    
    /**
     * @var products
     * 
     * @description A list of products that make up a membership renewal package for a given member.
     */
    public List<IProductBase> products {public get; private set;}
    
    
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
    
    
    // Our testing Order (optional).
    private static Id testOrderId;
    
    
    // The OrderId to be managed through this UI.
    private Id orderId;
    
    
    // The Org/Company Id.
    private Id companyId;
    
    
    // The Id of the Contact record to manage memberhsip products for
   	private Id contactId;
    
    
    // The type of membership - minus the currency code.
    private String membershipType;
    
    
    // Request currency, if any.  Probably should affect the Site - Store - Business Group
    public String currencyIsoCode {get; private set;}
        
    
    // The Member whose personal information we want to display.
    public Member theMember {public get; private set;}
    
    
    // Any previous membership
    public IProductBase previous {public get; private set;}
    
    
    // Total to be displayed to the customer.
    public Decimal total {get{
        Decimal t = 0.00;
        for(IProductBase prod:this.products){
	     	t += (null == prod.getPrice() ? 0.00 : prod.getPrice());   
        } return t;
    }private set;}
    
    
    // Any response to be sent to the client.
		public Map<String,Object> response {get;private set;}
    
    
    // Legacy attribute for Visualforce action methods.
    public String responseData {get{
        if(null == this.response){
            return JSON.serialize('{}');
        }
        return JSON.serialize(this.response);
    } private set;}
    
    
    public String queryType {get; private set;}
    
    
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
    public MembershipRenewalController(Id contactIdParam){
        settings = new AppSettings();
        initSettings();
    
        // If this 
        // @TODO - Perhaps this entry point should take a null contactId to reflect the current User?
        contactId = contactIdParam;
        
        if(contactId == null){
            throw new ControllerException('DATA_ERROR: ContactId is null');
        }
        
        theMember = new Member(contactId);
    
        cartCookie = new FontevaCookie(companyId);
        cartCookie.setUserId(communitySiteGuestUserId);
        cartCookie.save();
        
        if(theMember.getMemberType() == null){
            throw new ControllerException('DATA_ERROR: MembershipType is null');
        }
        products = buildProductList(contactId, theMember.getMemberType());
    
        
        setResponseData('products',this.products);
        
    }
    
    
    /**
     * @contructor
     * 
     * @description Initialize the page; this page displays a list of IProduct objects so
     *   build that Product List here.
     */
    public MembershipRenewalController(){
        settings = new AppSettings();
        initSettings();
    
        // If this 
        // @TODO - Perhaps this entry point should take a null contactId to reflect the current User?
        contactId = getParam('id');
    
        queryType = getParam('queryType');
        
        theMember = new Member(contactId);
    
        membershipType = null == theMember.getMemberType() ? (String)settings.get('MembershipQuery.DEFAULT_MEMBERSHIP_TYPE') : theMember.getMemberType();
        
        cartCookie = new FontevaCookie(companyId);
        cartCookie.setUserId(communitySiteGuestUserId);
        cartCookie.save();
    
        products = buildProductList(contactId,theMember.getMemberType());
    
        
        setResponseData('products',this.products);
    }
    

    
    public Boolean getHasProducts(){
        return (null != products && products.size() > 0);
    }
    
    private void initSettings(){
        // Set the value for use in <apex:composition>
        templateName = settings.getTemplate();
        
        // should get this from settings.
        Member.setFields(new String[]{'Id','Name','FirstName','LastName','Email',
			'Member_ID__c','Member_Chapter__c','Member_Type__c', 'Renewal_Membership_Type__c',
            'CurrencyIsoCode','Current_Membership_Type__c', 'Membership_Join_Date__c', 'Membership_Start_Date__c',
            'Membership_End_Date__c','Membership_Cancelled_Date__c'
        });
        
        currencyIsoCode = 'USD';
        
        alwaysUseCommunitySiteGuestUser = null == settings.get('alwaysUseCommunitySiteGuestUser') ? True : (Boolean)settings.get('alwaysUseCommunitySiteGuestUser');
        
        communitySiteGuestUserId = (Id)settings.get('communitySiteGuestUserId');
        
        testOrderId = (Id)settings.get('testOrderId');
        
        companyId = (Id)settings.get('companyId');
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


    /**
     * @method createMembershipOrder
     * 
     * @description Take over the Fonteva shopping cart cookie.
     *   Replace any existing Sales Order with the membership-related products
     *    from a call to FontevaMembershipQuery.
     */
    public Id createMembershipOrder(){
        System.Type t = Type.forName((String)settings.get('OrderClass'));

        IOrder theOrder = (IOrder)t.newInstance();
        theOrder.setContactId(this.contactId);
    
    	Integer counter = 0;

        for(IProductBase prod :this.buildProductList(contactId, theMember.getMemberType())){
            // prod.setIsPrimary(counter++==1);
            theOrder.addProduct(prod); 
        }
    
        return theOrder.save(); 
    }
    
    
    /**
     * @method prepareCheckout
     * 
     * @description prepare the Order and navigate the customer to the checkout page
     *   for personal info and payment.
     */
    public PageReference prepareCheckout(){
        // orderId = cartCookie.getCookieOrderId();
        
        orderId = createMembershipOrder();
        cartCookie.setOrderId(orderId);
        cartCookie.save();
        
        setResponseData('orderId',orderId);
        
        String redirectPage = (String)settings.get('OnOrderCreationRedirectPage');
            
        setResponseData('OnOrderCreationRedirectPage',String.format(redirectPage, new List<Object>{orderId}));
        
        return null;
    }
    
    public PageReference renderMockOrderProducts(){
        
        List<IProductBase> prodsIn;
        
        List<IProductBase> prodsOut;
        
        FontevaOrder mockOrder;

        
        try { 
            
           if(null == this.contactId) {
                throw new ControllerException('Contact Id was not set.');
            }  
            
            mockOrder = new FontevaOrder();
            mockOrder.setContactId(this.contactId);
            // mockOrder.addProducts(this.products);
            Integer counter = 0;
            for(IProductBase prod :this.products){
                // prod.setIsPrimary(counter++==1);
                mockOrder.addProduct(prod); 
            }
            
            this.products = mockOrder.saveMock();
            
        } catch(Exception e){
            setResponseData('error',e.getMessage());
        }
        
        setResponseData('products',this.products);
        
        return null;
    }
    

    
    public List<IProductBase> buildProductList(Id contactId, String membershipType){

        List<IProductBase> results;

        
        String queryType = 'Purchase History';

        
        IProductQuery pq = ProductQuery.newInstance('Purchase History','Salesforce');
        IProductQuery mq = ProductQuery.newInstance('Membership Type','Salesforce');
        
        pq.setParameters(new Map<String,String>{'contactId' => contactId});
        
        results = pq.execute();
        if(null != results && results.size() > 0){
            previous = results[0];
        } 
        
        if(USE_MEMBERSHIP_TYPE_FALLBACK && (null == results || results.size() < 1)){
            queryType = 'Membership Type';
            mq.setParameters(new Map<String,String>{'membershipType' => theMember.getMembershipType(),
                'currencyIsoCode'=>theMember.getCurrencyIsoCode()});
            
            results = mq.execute();
        } 


        if(AUTO_ADD_CHAPTERS){
            results.add(this.theMember.getChapter());
        }

        return results;
    }
 
    
    private class ControllerException extends Exception {}
}