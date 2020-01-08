@isTest
class SalesforceOrderTest {
    Account acct;
    Product2 theProduct;
    Contact c;
    PricebookEntry pb;
    
    SalesforceOrderTest(){
        
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
        //create and account and insert
        Account acct = new Account();
        acct.Name = 'test-account';
        insert acct;

        //Create a contact and insert it.
		Contact c = new Contact(FirstName='Testy',LastName='McTester',Email='testing@abc.com', MembershipType__c = 'Professional Membership');
		insert c;
        
    }
    
    //THE UNIT TESTS
    private static testMethod void salesforceOrderSaveReturnsId(){
        SalesforceOrderTest context = new SalesforceOrderTest();
        
        //Set the pricebook
		Id thePricebookId = Test.getStandardPricebookId();

        //Create an order.
		SalesforceOrder o = new SalesforceOrder();
        
        //Set property values
		o.setContactId(context.c.Id);
		o.setPricebookId(thePricebookId);
        o.setStatus('Draft');
        o.setAccountId(context.acct.Id);
        o.setEffectiveDate(System.today());
        
        //Add a product and save the order
        o.addProduct(context.theProduct.Id);
        Id oId = o.save();
        
        //Assert that id returned is not null
        System.assert(oId != null); 
    }
    private static testMethod void salesforceOrderGettersAndSetters(){
        SalesforceOrderTest context = new SalesforceOrderTest();
        
        //Set the pricebook
		Id thePricebookId = Test.getStandardPricebookId();

        //Create a new order.
		SalesforceOrder o = new SalesforceOrder();
        
        //Getters are returning null
        System.assert(o.getAccountId() == null);
       	System.assert(o.getContactId() == null);
        System.assert(o.getEffectiveDate() == null);
        System.assert(o.getPricebookId() == null);
        System.assert(o.getStatus() == null);
        
        //Set the property values
		o.setContactId(context.c.Id);
		o.setPricebookId(thePricebookId);
		o.addProduct(context.theProduct.Id);
        o.setStatus('Draft');
        o.setAccountId(context.acct.Id);
        o.setEffectiveDate(System.today());
        Id oId = o.save();
        
        //Getters return correct value value
       	System.assert(o.getAccountId() == context.acct.Id);
       	System.assert(o.getContactId() == context.c.Id);
        System.assert(o.getEffectiveDate() == System.today());
        System.assert(o.getPricebookId() == thePricebookId);
        System.assert(o.getStatus() == 'Draft');
    }
    private static testMethod void countOrderItems(){
        SalesforceOrderTest context = new SalesforceOrderTest();
        
        //Set the pricebook
		Id thePricebookId = Test.getStandardPricebookId();

        //Create an order.
		SalesforceOrder o = new SalesforceOrder();
        
        //Set property values
		o.setContactId(context.c.Id);
		o.setPricebookId(thePricebookId);
        o.setStatus('Draft');
        o.setAccountId(context.acct.Id);
        o.setEffectiveDate(System.today());
        
        //Add a product and save
        o.addProduct(context.theProduct.Id);
        o.save();
        
        integer numberOfOrderItems = o.countItems();
        
        System.assert(numberOfOrderItems == 1);  
    }
}