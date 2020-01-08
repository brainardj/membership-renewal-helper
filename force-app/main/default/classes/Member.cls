public class Member {

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