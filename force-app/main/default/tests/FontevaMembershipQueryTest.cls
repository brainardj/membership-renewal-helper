@isTest
public class FontevaMembershipQueryTest {

    public Contact c;
    
	public OrderApi__Item_Class__c itemClass;

	public OrderApi__Item__c item;    

    private FontevaMembershipQueryTest(){
    	c = [SELECT Id, Member_ID__c, Member_Type__c, FirstName, LastName, Email FROM Contact WHERE Member_ID__c = '1234abcde' LIMIT 1];
        itemClass = [SELECT Id, Name FROM OrderApi__Item_Class__c WHERE Name = 'Individual Membership - USD' LIMIT 1];
        item = [SELECT Id, Name, OrderApi__Display_Name__c, OrderApi__Description__c, 
                OrderApi__Price__c FROM OrderApi__Item__c WHERE Name = 'Professional Membership - USD' LIMIT 1];
    }
    
    
    @testSetup
    private static void testSetup(){
        
        Contact c = new Contact(FirstName='John',LastName='Doe',Email='test@abc.com');
        c.Member_ID__c = '1234abcde';
        c.Member_Chapter__c = null;
        c.Member_Type__c = 'Professional Membership - USD';
        c.Renewal_Membership_Type__c = 'Professional Membership - USD';
        // c.CurrencyIsoCode;
        // c.Current_Membership_Type__c = 'Professional Membership - USD';
        c.Membership_Join_Date__c = null;
        c.Membership_Start_Date__c = null;
        c.Membership_End_Date__c = null;
        c.Membership_Cancelled_Date__c = null;
        
        insert c;
        
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c(Name = 'Individual Membership - USD');
        insert itemClass;
        
        OrderApi__Item__c item = new OrderApi__Item__c(Name = 'Professional Membership - USD');
        item.OrderApi__Price__c = 275.00;
        item.OrderApi__Is_Active__c = True;
        item.OrderApi__Item_Class__c = itemClass.Id;
        insert item;        
    }
    
    private static testMethod void mockOrder(){
        FontevaMembershipQueryTest context = new FontevaMembershipQueryTest();
        
        FontevaProduct prod = new FontevaProduct(context.item);
        
        System.debug('Will output a FontevaProduct (using OrderApi__Item__c constructor.)');
        System.debug(prod);
        
        // Examine rollback results.
        List<IProductBase> asProducts;
        
        
        // System.debug(prod);
        
        FontevaOrder mockOrder = new FontevaOrder();
        mockOrder.setContactId(context.c.Id);
        mockOrder.addProducts(new List<IProductBase>{prod});
        
        System.assert(mockOrder.countItems == 1);
        
        // Save and backout.
        asProducts = mockOrder.saveMock();
        

		// System.debug(asProducts);
        
        System.assert(asProducts.size() == 1);
        
        
    }
    
    private static testMethod void queryByMembershipType(){
        FontevaMembershipQueryTest context = new FontevaMembershipQueryTest();
        
        FontevaMembershipTypeProductQuery query;
        
        Map<String,String> params;
        
        params = new Map<String,String>();
        params.put('membershipType',context.c.Member_Type__c);
        
        query = new FontevaMembershipTypeProductQuery();
        query.setParameters(params);
		
        List<FontevaProduct> prods = query.execute();

		System.assert(null != prods);
        System.assert(prods.size() > 0);
    }
    
      
    private static testMethod void noPurchaseHistory(){
        FontevaMembershipQueryTest context = new FontevaMembershipQueryTest();
        
        FontevaPurchaseHistoryProductQuery query;
        
        Map<String,String> params;
        
        params = new Map<String,String>();
        params.put('contactId',context.c.Id);
        
        query = new FontevaPurchaseHistoryProductQuery();
        query.setParameters(params);
		
        List<FontevaProduct> prods = query.execute(); 
        
        System.assert(prods == null);
    }
    
    /*
    private static testMethod void queryByChapter(){
        
        FontevaChapterProductQuery query;
        
        Map<String,String> params;
        
        params = new Map<String,String>();
        params.put('lat','foobar');
        params.put('long','foobar2');
        
        query = new FontevaChapterProductQuery();
        query.setParameters(params);
		
        List<FontevaProduct> prods = query.execute();                
    }
    */
    
}