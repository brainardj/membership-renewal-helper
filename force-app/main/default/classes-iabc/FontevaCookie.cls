public class FontevaCookie {
    
    public String companyId;
    
    public String userId;
    
    public String salesOrderId;
    
    static final String COOKIE_SUFFIX = 'fonteva-shopping-cart';
    
    public String cookieName {get{return this.companyId+'-'+COOKIE_SUFFIX;}}
    
    private Id siteId;
    
    
    public FontevaCookie(Id companyId){
        this.companyId = companyId;
    }
    
    public void setUserId(Id userId){
        this.userId = userId;
    }
    
    public void setOrderId(Id orderId){
        this.salesOrderId = orderId;
    }
    
    public void setFontevaSiteId(Id siteId){
        this.siteId = siteId;
    }
	
    
    public void save(){
        Integer THIRTY_DAYS = 86400 * 30;
        Cookie shoppingCartId;
        Cookie siteInfo;
        
        shoppingCartId = new Cookie(this.cookieName, this.serialize(), null, THIRTY_DAYS, False);
        siteInfo = new Cookie('fonteva_site', this.siteId, null, THIRTY_DAYS, False);
        
        // Set the new cookie for the page
        ApexPages.currentPage().setCookies(new Cookie[]{siteInfo,shoppingCartId});
    }
    
    public String serialize(){
        Map<String,String> cData = new Map<String,String>();
        cData.put('userId',this.userId);
        if(null != this.salesOrderId){
            cData.put('salesOrderId',this.salesOrderId);
        }
        
        return JSON.serialize(cData);
    }
    
    public String getCookieUserId(){
        return this.deserialize().get('userId');
    }
    
    public String getCookieOrderId(){
        return this.deserialize().get('salesOrderId');
    }
    
    public Map<String,String> deserialize(){
        Cookie fontevaCart = ApexPages.currentPage().getCookies().get(this.cookieName);
        
        String theJson = fontevaCart.getValue();
        
        Map<String,String> userData = (Map<String,String>)JSON.deserialize(theJson, Map<String,String>.class);
        
        return userData;
    }
}