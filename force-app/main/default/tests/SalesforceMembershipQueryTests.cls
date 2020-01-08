@isTest
public class SalesforceMembershipQueryTests 
{
    //Instance variables
    Account acct;
    Product2 theProduct;
    Contact c;
    PricebookEntry pb; 
    
    SalesforceMembershipQueryTests(){
        //Create a SalesforceProduct.
		SalesforceProduct prod = new SalesforceProduct();
		prod.setName('test-membership');
		prod.setPrice(2.50);
		prod.setDescription('A test membership');
        prod.setMembershipType('Professional Membership');
        prod.setFamily('membership');
        
        //Save the product
		Id prodId = prod.save();
        Id prodId2 = prod.save();
        theProduct = [select Id, Name, Description, MembershipType__c, Family From Product2 where Name = 'test-membership' limit 1 ];
        pb = [Select Id, UnitPrice from PricebookEntry where Product2.Name = 'test-membership' limit 1];
        acct = [Select Id, Name From Account where Name = 'test-account' limit 1];    
        c = [select FirstName, LastName, Email, MembershipType__c from Contact where FirstName = 'Testy' limit 1];
        //System.Assert(prodId == prodId2);
        
    }
    @testSetup
    static void setup(){
        //create an account and insert
        Account acct = new Account();
        acct.Name = 'test-account';
        insert acct;
        
        //Create a contact and insert it.
		Contact c = new Contact(FirstName='Testy',LastName='McTester',Email='testing@abc.com', MembershipType__c = 'Professional Membership');
		insert c;
        
    }
    
    //THE UNIT TESTS
    private static testMethod void queryByMembershipType(){
        SalesforceMembershipQueryTests context = new SalesforceMembershipQueryTests();
        SalesforceMembershipTypeProductQuery mq = new SalesforceMembershipTypeProductQuery();
        //Set the pricebook
		Id thePricebookId = Test.getStandardPricebookId();

        //Create an order.
		SalesforceOrder o = new SalesforceOrder();
		o.setContactId(context.c.Id);
		o.setPricebookId(thePricebookId);
		o.addProduct(context.theProduct.Id);
        o.setStatus('Draft');
        o.setAccountId(context.acct.Id);
        o.setEffectiveDate(System.today());
        o.save();
        
        mq.setParameters(new Map<String,String>{'membershipType' => context.c.MembershipType__c});
        List<SalesforceProduct> results = mq.doQuery();
        System.Assert(results[0].MembershipType == 'Professional Membership');
        System.Assert(results.size() == 1);
    }
    
    private static testMethod void queryByPurchasHistory(){
        
        SalesforceMembershipQueryTests context = new SalesforceMembershipQueryTests();
        SalesforcePurchaseHistoryProductQuery phq = new SalesforcePurchaseHistoryProductQuery();
        phq.setParameters(new Map<String,String>{'contactId'=> context.c.Id});
        //Set the pricebook
		Id thePricebookId = Test.getStandardPricebookId();

        //Create an order.
		SalesforceOrder o = new SalesforceOrder();
		o.setContactId(context.c.Id);
		o.setPricebookId(thePricebookId);
		o.addProduct(context.theProduct.Id);
        o.setStatus('Draft');
        o.setAccountId(context.acct.Id);
        o.setEffectiveDate(System.today());
        o.save();
        
        //Does it work with a valid contact Id?
        List<SalesforceProduct> results = phq.execute();
        System.Assert(results.Size() == 1);
        List<SalesforceProduct> results2 = phq.doQuery();
        System.Assert(results2.Size() == 1);
        
    }
    private static testMethod void TestTheQueryViaExecute(){
        SalesforceMembershipQueryTests context = new SalesforceMembershipQueryTests();
        SalesforceMembershipTypeProductQuery mq = new SalesforceMembershipTypeProductQuery();
        
        mq.setParameters(new Map<String,String>{'membershipType' => context.c.MembershipType__c});
        
        List<SalesforceProduct> memberships = mq.execute();
        
        System.assert(memberships.size() > 0); 
    }
    private static testMethod void loadProductsByMembershipTypeViaExecute(){
        SalesforceMembershipQueryTests context = new SalesforceMembershipQueryTests();
        SalesforceMembershipTypeProductQuery q = new SalesforceMembershipTypeProductQuery();
        q.setParameters(new Map<String,String>{'membershipType' => context.c.MembershipType__c});
        List<SalesforceProduct> products = q.doQuery();

        List<SalesforceProduct> products2 = q.execute();

        System.Assert(products.size() == products2.size());
    }
    
    private static testMethod void getProductsReturnsAtLeastOneProduct(){
        SalesforceMembershipQueryTests context = new SalesforceMembershipQueryTests();
        SalesforceMembershipTypeProductQuery q = new SalesforceMembershipTypeProductQuery();
        
        //check the context values
        System.debug(context.c.Id);
        System.debug(context.theProduct.MembershipType__c);
        
        //set the properties
        q.setParameters(new Map<String,String>{'membershipType' => context.theProduct.MembershipType__c});
        q.setParameters(new Map<String,String>{'contactId' => context.c.Id});
        
        //List that holds value returned
        List<IProductBase> productList = q.getProducts();
        
        System.assert(productList[0] != null);
    }
    private static testMethod void testMembershipTypeProductQueryCount(){
        SalesforceMembershipQueryTests context = new SalesforceMembershipQueryTests();
        SalesforceMembershipTypeProductQuery query = new SalesforceMembershipTypeProductQuery();
        query.setParameters(new Map<String,String>{'membershipType' => context.c.MembershipType__c});
        
        List<SalesforceProduct> prods = query.doQuery();
        System.assert(prods.size() == 1);
    }
    
    //MEMBERSHIP_RENEWAL_CONTROLLER_TESTS   
    private static testMethod void TestTheMembershipController(){
        SalesforceMembershipQueryTests context = new SalesforceMembershipQueryTests();
        Id contactId = context.c.Id;
        
        MembershipRenewalController memberController = new MembershipRenewalController(contactId);

    }
    private static testMethod void getServiceTest(){
        
        IProductQuery chapterQuery = ProductQuery.newInstance('Chapter');
        String database = 'Salesforce';
        String typeName;
        String queryType = 'Chapter';
        
        
        if(queryType == 'Chapter'){
            typeName = database +'ChapterProductQuery';
        }else
            throw new System.AssertException(); 
        
        
        System.type theType = Type.forName(typeName);
        System.assert(theType != null);
        System.assert(chapterQuery != null);

    }
    private static testMethod void buildProductsListCountWithMembershipType(){
        SalesforceMembershipQueryTests context = new SalesforceMembershipQueryTests();
        MembershipRenewalController mrc = new MembershipRenewalController(context.c.Id);
        List<IProductBase> results = mrc.buildProductList(context.c.Id, context.c.MembershipType__c);
        System.assert(results.size() == 1);
    }
        private static testMethod void testProductQueryClass(){
        ProductQuery pq = new ProductQuery();
        pq.setDatabase('Salesforce');

    }
}