public without sharing class FontevaOrder implements IOrder {

    // static List<IProductBase> products;
    
    // Salesforce internal Id.
    public Id sObjectId;
    
    
    // Bill To Contact Id
   	private Id contactId;
    
    
    // The underlying SObject.
    private OrderApi__Sales_Order__c theOrder;
    
    
    public final static String FONTEVA_ORDER_INITIAL_STATUS = 'Open';
    
    
		public final static String FONTEVA_ORDER_CLOSED_STATUS = 'Closed';
    
    
    // List of related Lines for the order.
    List<OrderApi__Sales_Order_Line__c> lines = new List<OrderApi__Sales_Order_Line__c>();
    
    
    // Whether the order is persisted to a database or not.
    public Boolean isSaved {public get; private set;}
    
    
    // Number of items in this order.
    public Integer countItems {get{return this.lines.size();}private set;}
    
    
    // Corresponds to OrderApi__Sales_Order__c.OrderApi__Business_Group__c 
    private Id businessGroupId;
    
    
    // Corresponds to OrderApi__Sales_Order__c.CurrencyIsoCode
    private String currencyIsoCode;
    
    
    
    
    // Default Contructor
    public FontevaOrder(){
        theOrder = new OrderApi__Sales_Order__c(OrderApi__Entity__c = 'Contact');
        // OrderApi__Business_Group__c 
        // 
        this.sObjectId = null;
        this.isSaved = false;
    }
    
    
    
    // Constructor.
    public FontevaOrder(Id theId){
        this();
        if(null == theId){
            throw new ClickpdxOrderException('DATA_ERROR: Constructor requires a non-null Id parameter.');
        }
        this.sObjectId = theId;
        theOrder.Id = theId;
    }
    
    public void setContactId(Id contactId){
        this.contactId = contactId;
    }
    
    public void setOrderId(Id orderId){
        this.sObjectId = orderId;
    }
    
    public void setBusinessGroupId(Id bGroup){
        this.businessGroupId = bGroup;
    }
    
    public void setCurrencyIsoCode(String isoCode){
        this.currencyIsoCode = isoCode;
    }
    

    
    public OrderApi__Sales_Order__c create(){
        return new OrderApi__Sales_Order__c(OrderApi__Entity__c = 'Contact');
    }
    
    public OrderApi__Sales_Order__c create(Map<String,String> params){
        return new OrderApi__Sales_Order__c(OrderApi__Entity__c = 'Contact');
    }
    
    public OrderApi__Sales_Order_Line__c addProduct(Id productId){
        if(null == this.contactId){
            throw new ClickpdxOrderException('Contact Id is not set on the Order.');
        }
        
        return newLine(new FontevaProduct(productId), this.contactId);
    }
    
    private OrderApi__Sales_Order_Line__c newLine(IProductBase prod, Id contactId){
        OrderApi__Sales_Order_Line__c line = new OrderApi__Sales_Order_Line__c();
        
        Boolean hasPriorSubscription = null != prod.getRelatedRecordId();
        
        line.OrderApi__Item__c = prod.getId();
        line.OrderApi__Quantity__c = 1.0;
        line.OrderApi__Price_Override__c = False;
        line.OrderApi__Sale_Price__c = null;
        line.OrderApi__Contact__c = contactId;
        // line.OrderApi__Account__c;
        line.OrderApi__Entity__c = 'Contact';
        
        line.OrderApi__Is_Renewal__c =  hasPriorSubscription;
        line.OrderApi__Subscription__c = hasPriorSubscription ? prod.getRelatedRecordId() : null;
        

        line.OrderApi__Business_Group__c = this.businessGroupId;
        line.CurrencyIsoCode = this.currencyIsoCode;
        
        // Let this happen automatically per vendor's installed triggers/flows.
        // line.OrderApi__Price_Rule__c;
        
        return line;
    }
    
    

    
    
    public OrderApi__Sales_Order_Line__c addProduct(IProductBase prod){
    	if(null == this.contactId) {
    		throw new ClickpdxOrderException('DATA_ERROR: ContactId must be set on Order.');
    	}
    	
    	return addProduct(prod,this.contactId);
    }
    
    public OrderApi__Sales_Order_Line__c addProduct(IProductBase prod, Id contactId){
        OrderApi__Sales_Order_Line__c line = this.newLine(prod,contactId);
        
        lines.add(line);
        
        return line;
    }
    
    
    public List<OrderApi__Sales_Order_Line__c> addProducts(List<IProductBase> prods){
        for(IProductBase prod :prods){
            OrderApi__Sales_Order_Line__c line = this.newLine(prod,contactId);
            lines.add(line);
        }
        
        return lines;
    }
    
    
    
    public List<IProductBase> saveMock(){
        

        
        System.SavePoint sp;
        
        List<IProductBase> products;
        
        sp = Database.setSavepoint();
        
            this.save();
           
        	products = this.getProducts();
        	System.debug(products);
        
        Database.rollback(sp);
        
        this.isSaved = false;
        
        return products;
    }
    
    
    public Id save(){
		// theOrder = OrderApi__Sales_Order__c theOrder = new OrderApi__Sales_Order__c();
		theOrder.OrderApi__Contact__c = this.contactId;
        theOrder.OrderApi__Status__c = FONTEVA_ORDER_INITIAL_STATUS;
        
        
        if(null == this.businessGroupId){
            throw new ClickpdxOrderException('INITIALIZATION_ERROR: Business Group must be set before saving order (OrderApi__Sales_Order__c.OrderApi__Business_Group__c)');
        }
        if(null == this.currencyIsoCode){
            throw new ClickpdxOrderException('INITIALIZATION_ERROR: Currency must be set before saving order (OrderApi__Sales_Order__c.CurrencyIsoCode)');
        }
        
        theOrder.OrderApi__Business_Group__c = this.businessGroupId;
        
        theOrder.CurrencyIsoCode = this.currencyIsoCode;
    

        
        insert theOrder;
        
        this.sObjectId = theOrder.Id;
        
        for(OrderApi__Sales_Order_Line__c line :this.lines){
            line.OrderApi__Sales_Order__c = this.sObjectId;
        }
        
        upsert this.lines;

        
        theOrder.OrderApi__Status__c = FONTEVA_ORDER_CLOSED_STATUS;
        update theOrder;
        
        this.isSaved = True;
        
        return this.sObjectId;
    }
    
    
    public List<FontevaProduct> getProducts(){
        
        if(!this.isSaved){
            throw new ClickpdxOrderException('DATA_INITIALIZATION_ERROR: Cannot get products when order is in unsaved state.');
        }
        
        List<FontevaProduct> prods = new List<FontevaProduct>();
        
        List<OrderApi__Sales_Order_Line__c> lookup = [SELECT Id, OrderApi__Is_Subscription__c, OrderApi__Sales_Order__c, OrderApi__Item__c, OrderApi__Sale_Price__c,
                                                     OrderApi__Item__r.Name, OrderApi__Item_Class__r.Name, OrderApi__Item__r.OrderApi__Description__c
                                                     FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :this.sObjectId];
        Boolean PRESERVE_ID = True;
        Boolean DEEP_CLONE = True;
        Boolean PRESERVER_READ_ONLY_TIMESTAMPS;
        
        Boolean NO_PRESERVE_ID = False;
        Boolean NO_DEEP_CLONE = False;
        Boolean NO_PRESERVE_READ_ONLY_TIMESTAMPS = False;
        
        for(OrderApi__Sales_Order_Line__c line : lookup){
            
            FontevaProduct prod = new FontevaProduct(line);
            prods.add(prod);
        }
        
        return prods;
    }
    

    
    
    
}