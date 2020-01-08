/**
* @class FontevaPurchaseHistoryProductQuery
* 
* @description Helper class to retrieve the appropriate list of Products for a given Membership.
*/
public without sharing class FontevaPurchaseHistoryProductQuery implements IProductQuery {
    
    String contactId;
    
    String membershipType;

	static final Integer NO_QUERY_RESULTS = 0;
  

    public FontevaPurchaseHistoryProductQuery(){
        AppSettings settings = new AppSettings();
        membershipType = (String)settings.get('MembershipQuery.DEFAULT_MEMBERSHIP_TYPE');
    }

    

    public List<IProductBase> getProducts() {
        
        List<FontevaProduct> prods = new List<FontevaProduct>();
        
        List<FontevaProduct> found = getProductsByPurchaseHistory(contactId);
        
        if(null != found && found.size() > NO_QUERY_RESULTS){
            prods.addAll(found);
        }
        
        
        return prods;
    }
    
    
    public void setParameters(Map<String,String> params){
    	contactId = null != params.get('contactId') ? (Id)params.get('contactId') : null;
    }
    
    
    public OrderApi__Subscription__c getMostRecentSubscription(){
        return getMostRecentSubscription(this.contactId);
    }
    
    
    public OrderApi__Subscription__c getMostRecentSubscription(Id contactId){
        List<OrderApi__Subscription__c> subs;
        
        subs = [SELECT Id, Name, 
                OrderApi__Account__c, OrderApi__Contact__c,
                OrderApi__Subscription_Plan__c, OrderApi__Sales_Order_Line__c, OrderApi__Item_Class__c,
                OrderApi__Entity__c, OrderApi__Enable_Auto_Renew__c, 
                
                OrderApi__Activated_Date__c, OrderApi__Current_Term_Start_Date__c, OrderApi__Current_Term_End_Date__c, 
                
                OrderApi__Status__c, OrderApi__Is_Active__c, OrderApi__Is_Cancelled__c, OrderApi__Is_Expired__c,
                OrderApi__Is_Pending__c, OrderApi__Is_Suspended__c, 
                
                OrderApi__Item__c
                // Renew_Email_Sent__c
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Contact__c = :contactId
                AND (OrderApi__Item_Class__r.Name LIKE '%Group%' OR OrderApi__Item_Class__r.Name LIKE '%Individual%')
                ORDER BY OrderApi__Activated_Date__c DESC];
        
		// Return the Subscription record with the most recent Activation Date.
        return (null == subs || 1 > subs.size()) ? null : subs[0];
    }

    
    
    
    public List<FontevaProduct> getProductsByPurchaseHistory(Id contactId){
    	Id membershipProductId;
    	
    	Id relatedRecordId;
    	
    	Contact c = [SELECT Id, FirstName, LastName, Current_Membership_Type__c FROM Contact WHERE Id = :this.contactId];
    	
        if(null == this.contactId){
            throw new ProductQueryException('MISSING_PARAMETER_ERROR: A Contact Id was not provided for the membership query.');
        }
        
        // What happens if the member has no recent Subscription purchase?
        OrderApi__Subscription__c sub = getMostRecentSubscription(this.contactId);
        
        if(null == sub) return null;
        
        membershipProductId = sub.OrderApi__Item__c;
        relatedRecordId = sub.Id;
        
        
        FontevaProduct primaryMembership = FontevaProduct.newFromId(membershipProductId);

        primaryMembership.setIsPrimary(True);
        primaryMembership.setRelatedRecordId(relatedRecordId);
        
        return new List<FontevaProduct>{primaryMembership};
    }



    public List<FontevaProduct> execute(Map<String,String> params) {
        

            return getProductsByPurchaseHistory(params.get('contactId'));

    }
    
    
    public List<FontevaProduct> execute(){
        if(null == contactId){
            throw new ProductQueryException('INITIALIZATION_ERROR: The membershipType cannot be empty or null.');
        }
        
        return execute(new Map<String,String>{'contactId' => contactId});
    }

    
    
    private class SubscriptionNotFoundException extends Exception {}
    

    
}