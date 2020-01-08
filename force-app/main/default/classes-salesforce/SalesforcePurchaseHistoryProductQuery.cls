public class SalesforcePurchaseHistoryProductQuery implements IProductQuery{
    Id contactId;

    public SalesforcePurchaseHistoryProductQuery(){}
    
    public List<IProductBase> getProducts(){
		List<SalesforceProduct> sProds;
		sProds = doQuery();
        return sProds;
    }

	public void setParameters(Map<String,String> params){
        if(params.get('contactId') != null)
        	this.contactId = params.get('contactId');
	}
    
    //Return a list of products consistent with the memebers most recent membership purchase.
    public List<SalesforceProduct> doQuery(){
        
        
        List<OrderItem> memberships = [select order.effectiveDate, contact__r.firstName, contact__r.Id, orderId, Product2Id, Product2.name from orderItem 
                                       where contact__c =:this.contactId AND Product2.family = 'membership' order by order.effectiveDate desc];
        
        List<Id> productIds = new List<Id>();
        
        for(OrderItem orderItem : memberships){
            productIds.Add(orderItem.Product2Id);
        }
        
       	return SalesforceProduct.newListFromIds(productIds);
    }
    
    
    //Execute methods for testing purposes
    public List<SalesforceProduct> execute(Map<string,string> params) {
				return doQuery();
    }
    public List<SalesforceProduct> execute(){
        return Execute(new Map<string,string>{'contactId' => contactId});
    }
    
    //Exception classes
    private class PurchaseHistoryProductQueryException extends Exception{}

}