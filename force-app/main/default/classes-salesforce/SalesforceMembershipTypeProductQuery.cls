public class SalesforceMembershipTypeProductQuery implements IProductQuery{
    String membershipType;

    public SalesforceMembershipTypeProductQuery(){}
    
    public void setParameters(Map<String,String> params){
        if(params.get('membershipType') != null)
        	this.membershipType = params.get('membershipType');
	}
    
    public List<IProductBase> getProducts(){
		List<SalesforceProduct> sProds;        
		sProds = doQuery();
        return sProds;
    }

    //Return a list of products that correlates to the membership type.
    public List<SalesforceProduct> doQuery() {
        if(this.membershipType == null){
            throw new MembershipTypeProductQueryException('DATA_ERROR:You have to provide a membership type to perform this query.');
        }
        List<PricebookEntry> memberships = [SELECT Product2Id, Product2.MembershipType__c, Product2.Family FROM PricebookEntry WHERE Product2.MembershipType__c= :this.membershipType];
        List<Id> productIds = new List<Id>();

        for(PricebookEntry entry : memberships){
            productIds.Add(entry.Product2Id);
        }

        return SalesforceProduct.newListFromIds(productIds);
    }

    public List<SalesforceProduct> Execute() {
				return doQuery();
    }
    
    private class MembershipTypeProductQueryException extends Exception {}
}