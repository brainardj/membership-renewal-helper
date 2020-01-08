public class IABCMember extends Member {

    public Contact c {get;private set;}
    
    public String firstName {get{return c.FirstName;}}
    
    public String lastName {get{return c.LastName;}}
    
    private String memberType;
      
    private String mailingStreet;
    
    private String mailingCity;
    
    private String mailingState;
    
    private String mailingPostalCode;
    
    private String mailingCountry;
    
    private String currencyIsoCode;
    
    
    
    public String getCurrencyIsoCode(){
        return this.currencyIsoCode;
    }
    
    
    
    public Id getCurrencySiteId(){
        if(null == this.currencyIsoCode){
            throw new MemberException('Cannot retrieve site when member currency is not set.');
        }
        
        
        List<PagesApi__Site__c> theSites;
        
        theSites = [SELECT Id, Name FROM PagesApi__Site__c WHERE CurrencyIsoCode = :this.currencyIsoCode];
        
        
        if(null == theSites || !(theSites.size() > 0)){
            throw new MemberException('No site found for member with currencyCode: '+this.currencyIsoCode);
        }
        
		return theSites[0].Id;
    }
    
    private static String[] fields = new String[]{
    	'Id','Name','FirstName','LastName','Email','CurrencyIsoCode','MailingCountry','MailingState','MailingLatitude','MailingLongitude'};
    
    
	public static String fn = 'Member_Type__c';
    
    public static void setFields(String[] fields){
        fields = fields;
    }
    
    
    
    public Member(){}
    
    public Member(ClickpdxDefaultController ctrl){
        
    }
    
    public IProductBase getMembership(){
        return null;
    }
    
    
    public IProductBase getMembershipAtLarge(){
        
        return null;
    }
    
    
    
    public OrderApi__Business_Group__c getBusinessGroup(){
        if(null == this.currencyIsoCode){
            throw new MemberException('Cannot retrieve business group when currency code is not set.');
        }
        
        List<OrderApi__Business_Group__c> groups = new List<OrderApi__Business_Group__c>();
        
        Map<String,OrderApi__Business_Group__c> bizs = new Map<String,OrderApi__Business_Group__c>();
        
        groups = [SELECT Id, Name, CurrencyIsoCode FROM OrderApi__Business_Group__c];
        
        for(OrderApi__Business_Group__c theGroup : groups){
            bizs.put(theGroup.CurrencyIsoCode,theGroup);
        }
        
        return bizs.get(this.currencyIsoCode);
    }
    
    
	@RemoteAction
    public static Member lookup(String memberId){
		String tmp = memberId.trim();
        Member m;
        
        List<Contact> contacts = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE Member_ID__c = :memberId];
        
        if(null == contacts || !(contacts.size() > 0)){
            return null;
        }
        
        try {
        	m = new Member(contacts[0].Id);
        } catch(Exception e){
       		return null; 
        }
        
        return m;
    }
    
    
    public IProductBase getChapter(){
        
		FontevaChapterProductQuery chpts;
        
        
		List<IProductBase> mProds;
        
        
        try {
            if(null == this.c || null == this.c.Member_Type__c){
                throw new MemberException('QUERY_ERROR: cannot execute query without a valid membership type.');
            }
            
            if(null == c.MailingLatitude || null == c.MailingLongitude){
                throw new MemberException('DATA_ERROR: Cannot locate chapter without a proper location.');
            }
            
            chpts = new FontevaChapterProductQuery();
            chpts.start(c.MailingLatitude, c.MailingLongitude);
            chpts.radius(50,'km');
            // chpts.country('United States');
            
            
            // query = ProductQuery.newInstance('Membership Type','Fonteva');
            // String membershipType = FontevaProduct.toMembershipTypeName(this.c.Member_Type__c);
            // query.setParameters(new Map<String,String>{'membershipType'=>membershipType,'currencyIsoCode'=>'USD'});
            
            mProds = chpts.getProducts();
            
            if(null == mProds || !(mProds.size()>0)){
                return null;
            }
            
        } catch(SObjectException e){
            throw new MemberException('Could not retrieve data from the given member query.  '+e.getMessage());
        }
        
        return mProds[0];
    }
    

    
    public Member(Id contactId){
		this.c = fetch(contactId);
        this.currencyIsoCode = this.c.CurrencyIsoCode;
    }
    
    public Member(Contact c){
        this.c = c;
    }
    
    
    
    
    public void setMemberType(String memberType){
        this.memberType = memberType;
    }
    
    public void setAddress(String street, String city, String state, String postalCode, String country){
        this.mailingStreet = street;
        this.mailingCity = city;
        this.mailingState = state;
        this.mailingPostalCode = postalCode;
        this.mailingCountry = country;
    }
    
    public void setMemberTypeField(String fn){
        fn = fn;
    }
    
    public void setCurrencyIsoCode(String currencyIsoCode){
        this.currencyIsoCode = currencyIsoCode;
    }
    
    public String getMemberType(){
        
        try {
            String tmp = null == this.c.get(fn) ? null : (String)this.c.get(fn);
            
            if(null == tmp) return null;
            
            return tmp;
        } catch(System.SObjectException e){
            return null;   
        }
    }
    
    public String getMembershipType(){
        String mt = getMemberType();
        String[] tmp = mt.split(' - ');
        
        return tmp[0];
    }
    
    public Boolean isCurrentMember(){
        try {
        	return null != this.c.get(fn);
        }catch(System.SObjectException e){
            return False;
        }
    }
    
    
    private String helper(){
        String[] f = fields;
                
        if(!f.contains(fn)){
            f.add(fn);
        }
        String clause = 'SELECT '+String.join(f,',');
        clause += ' FROM Contact WHERE Id = :contactId';
        return clause;
    }
    
    public static void setQery(String query){
		query = query;
    }
    
    private Contact fetch(Id contactId){
        
		return Database.query(helper());
    }
 
 
    
    private class MemberException extends Exception {}
}