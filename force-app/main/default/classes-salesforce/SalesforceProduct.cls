public without sharing class SalesforceProduct implements IProductBase {
    public Id id;
    public String name;
    public Decimal price;
    public String description;
    public String membershipType;
    public String family;
    
    public Boolean isPrimary {get; set;}
    
    private Id relatedRecordId;
    
    // The underlying PricebookEntry record.
    private PricebookEntry entry;
    
    
    public SalesforceProduct() {}
    
    public SalesforceProduct(PricebookEntry pbEntry){
        this.entry = pbEntry;
        this.id = entry.Product2Id;
        this.name = entry.Product2.Name;
        this.description = entry.Product2.Description;
        this.price = entry.UnitPrice;
        this.membershipType = entry.Product2.MembershipType__c;
        this.family = entry.Product2.Family;
        
    }
    
    // Return the Id of the underlying Product.
    public String getId(){
        return this.id;
    }
    
    public String getName(){
        return this.name;
    }
    
    public String getDescription(){
        return this.description;
    }
    public String getMembershipType(){
        return this.membershipType;
    }
    public String getFamily(){
        return this.family;
    }
    
    public Boolean getIsPrimary(){
        return this.isPrimary;
    }
    
    public Decimal getPrice(){
        return this.price;
    }
    
    public void setRelatedRecordId(Id recordId){
    	this.relatedRecordId = recordId;
    }
    
    public Id getRelatedRecordId(){
    	return this.relatedRecordId;
    }

    public void setName(String name){
        this.name = name;
    }
    
    public void setPrice(Decimal price){
        this.price = price;
    }

    public void setDescription(String description){
        this.description = description;
    }
    public void setMembershipType(String membershipType){
        this.membershipType = membershipType;
    }
    public void setFamily(String family){
        this.family = family;
    }
    public static List<SalesforceProduct> newListFromIds(List<Id> theIds){
        List<SalesforceProduct> prods = new List<SalesforceProduct>();

        List<PricebookEntry> entries = [SELECT Product2.Id, Product2.Name, UnitPrice, Product2.Description, Product2.MembershipType__c, Product2.Family
        FROM PricebookEntry WHERE Product2.Id = :theIds limit 1];
        
        for(PricebookEntry entry :entries){
            SalesforceProduct prod = new SalesforceProduct(entry);
            
            prods.add(prod);
        }
        
        return prods;
    }
    public Id save(){
        Product2 product = new Product2();
        //set the properties on the new product 
        product.Id = this.getId();
        product.Name = this.name;
        product.Description = this.description;
        product.MembershipType__c = this.membershipType;
        product.Family = this.family;
        
        //insert the product
        upsert product;
        //call to getId on the product
        if(this.price != null)
        {
            //products dont take prices. create an insert of a new pricebookEntry
            PricebookEntry entry = new PricebookEntry();
            entry.Product2Id = product.Id;
            entry.UnitPrice = this.price;
            entry.Pricebook2Id = Test.getStandardPricebookId();
            insert entry;

        }
        //return the id
        return product.Id;
        
    }
}