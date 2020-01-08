public without sharing virtual class FontevaProduct implements IProductBase {

    // Reference to the underlying SObject for this object.
    protected OrderApi__Item__c item;
    
    // Whether this product represents a "primary" membership product
    //   as opposed to a required or "add-on" product.
    protected Boolean isPrimary = False;
    
    // Reference to a related record for this product.
    //   For Fonteva installations this can be the Id of the Subscription record related to
    //     this instance of this product.
    protected Id relatedRecordId; 
    
    
    protected Id sObjectId;
    
    
    public Decimal price;
    
    
    public String name;
    
    
    protected String description;
    
    
    public String currencyIsoCode;
    
    static final String[] primary = new String[]{
        'Corporate',
        'Group',
        'Individual'
    };
        
	static final String query = 'SELECT Id, Name, OrderApi__Display_Name__c, CurrencyIsoCode, OrderApi__Price__c, OrderApi__Description__c, '+
        'OrderApi__Item_Class__r.Name  FROM OrderApi__Item__c WHERE Id = :theId';
    
    
    
    public FontevaProduct(Id theId){
        this.item = Database.query(query);
        this.sObjectId = theId;
        this.name = this.item.Name;
        this.price = this.item.OrderApi__Price__c;
        this.description = this.item.OrderApi__Description__c;
        this.currencyIsoCode = this.item.CurrencyIsoCode;
		this.isPrimary = determinePrimary(this.item.Name, this.item.OrderApi__Item_Class__r.Name);
    }
    
    
    public FontevaProduct(OrderApi__Item__c theItem){
        this.item = theItem;
        this.sObjectId = theItem.Id;
        this.name = theItem.Name;
        this.price = theItem.OrderApi__Price__c;
        this.description = theItem.OrderApi__Description__c;
        this.currencyIsoCode = theItem.CurrencyIsoCode;
		this.isPrimary = determinePrimary(theItem.Name, theItem.OrderApi__Item_Class__r.Name);
    }
    
    private Boolean determinePrimary(String itemName, String itemClass){
        if(itemName.contains('Region')) return false;
        for(String f :primary){
            
			if(itemClass.contains(f)) return true;
        }
        
        return False;
    }
    
    public FontevaProduct(OrderApi__Sales_Order_Line__c line){
        this.item = null;
        this.sObjectId = line.OrderApi__Item__c;
        this.name = line.OrderApi__Item__r.Name;
        this.price = line.OrderApi__Sale_Price__c;
        this.description = line.OrderApi__Item__r.OrderApi__Description__c;
        this.currencyIsoCode = line.CurrencyIsoCode;
		this.isPrimary = determinePrimary(line.OrderApi__Item__r.Name, line.OrderApi__Item_Class__r.Name);
    }
    
    public void setName(String name){
        this.name = name;
    }
    
    public void setPrice(Decimal price){
        this.price = price;
    }
    
    public FontevaProduct(){
        
    }
    
    public FontevaProduct(String name, Decimal price){
        this.name = name;
        this.price = price;
    }
    
    public Id getId(){
        return this.sObjectId;
    }
    
    public void setId(Id theId){
        this.sObjectId = theId;
    }
    
    public String getName(){
        return this.name;
    }
    
    public String getDescription(){
        return this.description;
    }
    
    public String getCurrencyIsoCode(){
        return this.currencyIsoCode;
    }
    
    public Boolean getIsPrimary(){
        return this.isPrimary;
    }
    
    public void setIsPrimary(Boolean yesOrNo){
        this.isPrimary = yesOrNo;
    }
    
    public Decimal getPrice(){
        return this.price;
    } 
    
    public Id getRelatedRecordId(){
        return this.relatedRecordId;
    }
    
    public void setRelatedRecordId(Id theRecordId){
        this.relatedRecordId = theRecordId;
    }

    
    public static List<FontevaProduct> newListFromIds(List<Id> theIds){
        List<FontevaProduct> prods = new List<FontevaProduct>();

        List<OrderApi__Item__c> items = [SELECT Id, Name, CurrencyIsoCode, OrderApi__Price__c, OrderApi__Display_Name__c,
                                         OrderApi__Description__c, OrderApi__Item_Class__r.Name, OrderApi__Line_Description__c FROM OrderApi__Item__c 
                WHERE Id = :theIds];
        
        for(OrderApi__Item__c item :items){
            FontevaProduct prod = new FontevaProduct(item);
            prods.add(prod);
        }
        
        return prods;
    }
    
    public static FontevaProduct newFromId(Id theId){
        List<FontevaProduct> prods = newListFromIds(new List<Id>{theId});
        
        if(null == prods || prods.size() < 1){
            throw new ClickpdxProductException('INITIALIZATION_ERROR: No OrderApi__Item__c record found for Id: '+theId);
        }
            
		return prods[0];
    }
    
    public static String toMembershipTypeName(String productName){
        if(null == productName) return null;
        
        String[] parts = productName.split('-');
        
        if(null == parts || !(parts.size()>0)){
            return productName.trim();
        }
        
        return parts[0].trim();
    }
    
    public String parseName(){
        return toMembershipTypeName(this.name);
    }
    
    public FontevaProduct getAsCurrency(String isoCode){
        String pName = parseName();
        String fName = pName + ' - '+ isoCode;
        Id theId;
        
        
        List<OrderApi__Item__c> theItems = [SELECT Id FROM OrderApi__Item__c WHERE OrderApi__Is_Active__c=True AND Name = :fName];
        
        if(null == theItems || !(theItems.size() > 0)){
            throw new ProductQueryException('DATA_ERROR: Cannot find the '+isoCode+' equivalent for Product: '+this.name);
        }
        
        if(theItems.size() > 1){
            throw new ProductQueryException('DATA_ERROR: Multiple products found in '+isoCode+' for Product: '+this.name);
        }
        
        theId = theItems[0].Id;
        
        return FontevaProduct.newFromId(theId);
    }
    
    public String getMembershipType(){
        return '';
    }
    
    public void setDescription(String theDesc){
        
    }
    public void setMembershipType(String theType){
        
    }
    public Id save(){
        return null;
    }
}