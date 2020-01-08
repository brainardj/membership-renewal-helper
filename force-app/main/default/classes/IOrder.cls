public interface IOrder {
	SObject create();
	
	SObject create(Map<String,String> params);
	
	Id save();
	
	void setOrderId(Id orderId);
    
    void setContactId(Id contactId);
	
	SObject addProduct(Id prodId);
	
	SObject addProduct(IProductBase prod);
    
    List<SObject> addProducts(List<IProductBase> prods);
    
    void setBusinessGroupId(Id theId);
    
    void setCurrencyIsoCode(String code);
}