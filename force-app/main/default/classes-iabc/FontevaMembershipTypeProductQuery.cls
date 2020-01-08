public class FontevaMembershipTypeProductQuery implements IProductQuery {

    

    String membershipType;
    
    
    String currencyIsoCode;

    
	static final Integer NO_QUERY_RESULTS = 0;
  
    
    
    
    
    public FontevaMembershipTypeProductQuery(){
        AppSettings settings = new AppSettings();
        membershipType = (String)settings.get('MembershipQuery.DEFAULT_MEMBERSHIP_TYPE');
    }
    
     
    // Try to return at least one product
    public List<IProductBase> getProducts() {
        
        List<FontevaProduct> prods = new List<FontevaProduct>();
        
        List<FontevaProduct> found = execute();  
        
        if(null != found && found.size() > NO_QUERY_RESULTS){
            prods.addAll(found);
        }

        
        return prods;
    }
    
    
    
    public void setParameters(Map<String,String> params){
        if(null != params.get('membershipType')){
            membershipType = (String)params.get('membershipType');
        }
        
        if(null != params.get('currencyIsoCode')){
			currencyIsoCode = (String)params.get('currencyIsoCode');
        }
        
        if(membershipType.split('-').size()>1){
            throw new ProductQueryException('INITIALIZATION_ERROR: Membership type cannot contain dashes ('+membershipType+'.)');
        }

    }
    


    private OrderApi__Item__c getProduct(String membershipType){
    	Map<String,Id> typesToProducts = new Map<String,Id>();

        
        String calcItem = membershipType + ' - ' + currencyIsoCode;
        
        List<OrderApi__Item__c> items = [SELECT Id, Name, OrderApi__Display_Name__c, OrderApi__Price__c FROM
                                        OrderApi__Item__c
                                         // WHERE OrderApi__Item_Class__r.Name = :calcItemClass
                                         // AND Name LIKE '%Member%'];
                                         WHERE Name = :calcItem];
        
        if(null == items || items.size() < 1){
        	throw new ProductQueryException('NO_RECORDS_FOUND_ERROR: No OrderApi__Item__c records found for Item(Name: '+calcItem+')');
        }
          
        
        return items[0];
    }
    
    
    // Return a list of products that correlates to the membership type.
    public List<FontevaProduct> doQuery(){
        if(null == membershipType){
            throw new ProductQueryException('INITIALIZATION_ERROR: the membershipType for this query instance was not set.');
        }
        
        return doQuery(this.membershipType);
    }
    
    
    
    public List<FontevaProduct> doQuery(String membershipType) {
        
        OrderApi__Item__c prod = getProduct(membershipType);
        FontevaProduct primary = FontevaProduct.newFromId(prod.Id);
        // primary.setIsPrimary(True);
        
        return new List<FontevaProduct>{primary};
    }


    public List<FontevaProduct> execute(Map<String,String> params) {
        return doQuery(params.get('membershipType'));
    }
    
    
    public List<FontevaProduct> execute(){
        if(null == membershipType){
            throw new ProductQueryException('INITIALIZATION_ERROR: The membershipType cannot be empty or null.');
        }
        
        return execute(new Map<String,String>{'membershipType' => membershipType});
    }

    
}