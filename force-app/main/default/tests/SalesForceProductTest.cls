@isTest
public class SalesforceProductTest {
        //Instance variables
    Account acct;
    Product2 theProduct;
    Contact c;
    PricebookEntry pb;
    
    SalesforceProductTest(){
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
    private static testMethod void salesforceProductSettersAndGetters(){
        SalesforceProductTest context = new SalesforceProductTest();
        
        //Create a new salesforceProduct
        SalesforceProduct testProd = new SalesforceProduct();
        
        //Set the values
        testProd.setName('testName');
        testProd.setPrice(5.00);
        testProd.setMembershipType('test-membership');
        testProd.setDescription('test-description');
        testProd.setFamily('membership');
        
        //Test the getters
        System.assert(testProd.getName() == 'testName');
        System.assert(testProd.getPrice() == 5.00);
        System.assert(testProd.getMembershipType() == 'test-membership');
        System.assert(testProd.getDescription() == 'test-description');
        System.assert(testProd.getFamily() == 'membership');
    }
}