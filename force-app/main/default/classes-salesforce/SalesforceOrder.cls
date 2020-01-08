public without sharing class SalesforceOrder implements IOrder {
	public Id sObjectId;
	public Id orderId;
	public Id contactId;
	public Id pricebookId;
    public String status;
    public Date effectiveDate;
    public String membershipType;
    public Id accountId;

	Order theOrder;
	SalesforceProduct product;
	List<OrderItem> theOrderItems = new List<OrderItem>();

	public SalesforceOrder() {
		theOrder = new Order();
		sObjectId = null;
	}
	public Id save(){
		Order o = new Order();
        o.Id = this.sObjectId;
        o.Contact__c = this.contactId;
        o.Pricebook2Id = this.pricebookId;
        o.Status = this.status;
        o.EffectiveDate = this.effectiveDate;
        o.AccountId = this.accountId;
        

		// Other fields have to be initialized here, too: EffectiveDate, Status, Pricebook2Id, etc.
		upsert o;
	
		this.sObjectId = o.Id;
	
		for(OrderItem line :this.theOrderItems){
            line.OrderId = this.sObjectId;
            line.Contact__c = this.contactId;
		}
	
		upsert this.theOrderItems;
	
		return this.sObjectId;
	}
	
	public void setOrderId(Id orderId){
		this.orderId = orderId;
	}

	public void setContactId(Id contactId){
		this.contactId = contactId;
	}
    
    public void setStatus(String status){
        this.status = status;
    }
    
    public void setEffectiveDate(Date effectiveDate){
        this.effectiveDate = effectiveDate;
    }
    
	public void setPricebookId(Id pricebookId){
		this.pricebookId = pricebookId;
	}
    public void setAccountId(Id accountId){
        this.accountId = accountId;
    }

	public SObject addProduct(Id prodId){
        PricebookEntry entry = [Select Id, UnitPrice from PricebookEntry where Product2Id = :prodId limit 1];
		OrderItem theOrderItem = new OrderItem();
		theOrderItem.Product2Id = prodId;
        theOrderitem.Quantity = 1.0;
        theOrderitem.UnitPrice = entry.UnitPrice;
        theOrderItem.PricebookEntryId = entry.Id;
        
		theOrderItems.Add(theOrderItem);

		return theOrderItem;
	}
	
    //Needs to be finished;
	public SObject addProduct(IProductBase prod){
		return null;
	}

	//Needs to be finishied!!!
	public List<SObject> addProducts(List<IProductBase> prods) {
        for(IProductBase prod : prods)
        {
			
        }
		return new List<SObject>();
	}

	public Id getContactId(){
		return this.contactId;
	}
    public String getStatus(){
		return this.status;
	}
    public Date getEffectiveDate(){
		return this.effectiveDate;
	}
    public Id getPricebookId(){
		return this.pricebookId;
	}
    public Id getAccountId(){
        return this.accountId;
    }

	public integer countItems(){
		return theOrderItems.Size();
	}

	public List<IProductBase> saveMock(){
		return null;
	}
	// public SalesforceOrder getFirstProduct(){
	// 	return theOrderItems[0];
	// }
}