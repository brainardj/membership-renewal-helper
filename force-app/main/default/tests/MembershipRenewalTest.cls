@isTest
public class MembershipRenewalTest {


    

    
    @isTest(SeeAllData=True)
    private static void findChapters(){
        
        Id theId;
        
        
        Test.startTest();
        
        
        Contact c = new Contact(FirstName = 'Jose',LastName = 'Bernal',Email='jbernal.web.dev@gmail.com');
        c.MailingCity = 'Portland';
        c.MailingState = 'Oregon';
        c.MailingPostalCode = '97211';
        c.MailingStreet = '4950 NE 7 AVE APT 205';
        c.MailingCountry = 'United States';
        // Assume a member somewhere near Portland, OR.
        c.MailingLatitude = 45.558834;
        c.MailingLongitude = -122.658225;
        c.Member_Type__c = 'Professional Membership - USD';
        
        insert c;

        
		// Confirms that Lat/Lng are probably populated async and not available for actual testing.
        Test.stopTest();  
        

        theId = c.Id;
        
        c = [SELECT MailingLatitude, MailingLongitude FROM Contact WHERE Id = :theId];
        
        System.debug('Lat: '+c.MailingLatitude);
        System.debug('Long: '+c.MailingLongitude);
        
        
        // Member.setFields(new String[]{'Id','Name','Email'});
        IABCMember me = new IABCMember(theId);
        
        
        IProductBase chapter = me.getChapter();
        
        
        me = new IABCMember(c);
        me.setMemberTypeField('Member_Type__c');
        System.assert(!me.isCurrentMember());
        me.getMemberType();
    } 
    
    
    /**
     * @testMethod loadController
     * 
     * @description Controller for membership renewals.
     *   Demonstrate that different query string vaues produce predictable results
     */
    @isTest(SeeAllData=True) 
    private static void loadController(){
        
        Id theId;        

        theId = '0032900000TLt7tAAD';
		
        Test.setCurrentPage(Page.MembershipRenewal);
        ApexPages.currentPage().getParameters().put('id',theId);
        
        IABCMembershipRenewalController ctl = new IABCMembershipRenewalController();
    } 
    
    
    /**
     * @testMethod memberLoad
     * 
     * @description
     *   Load member data for an existing Contact.
     *   Members should have valid member types that
     *   correspond to various Products in Salesforce.
     * 
     *  They should also be eligible to join one or more Chapters
     *   according to their location.
     */
    @isTest(SeeAllData=True) 
    private static void memberLoad(){
        
        Id theId;        

        // for Jose Bernal Contact.
        theId = '0032900000TLt7tAAD';
		
        // Make sure wrapper class returns correct data.
        IABCMember m = new IABCMember(theId);
        m.setMemberType('Professional Membership - USD');
        m.setAddress('1040 NW 10 ','Eugene','OR','97209','United States');

        
        System.assert('Professional Membership' == m.getMembershipType());

				// Check getters
				System.assert(m.firstName == 'Jose' || m.firstName == 'José');
        System.assert(m.lastName == 'Bernal');
        
        // Fetch appropriate membership product for
        //  this member. Membership should be in USD.
        IProductBase mProd = m.getChapter(); 
        
        
        System.assertEquals('IABC/Oregon Columbia', mProd.getName());
        
        System.assertNotEquals('Professional Membership - USD', mProd.getName());
        

        
        // Chapter should have a name, price, etc.
        IProductBase chapter = m.getChapter();
        System.debug('Chapter for '+m.firstName+':');
        System.debug(chapter);
    }  
    
    
    
    
    
    
    /**
     * @testMethod productLoad
     * 
     * @description Load products for various currencies.
     *   Confirm that member types can be parsed to locate 
     *    currency-specific products using the getAsCurrency() method.
     */
    @isTest(SeeAllData=True) 
    private static void productLoad(){
        
        Id prodId;        

        prodId = 'a13290000018aG2AAI';
        
        FontevaProduct usProd = new FontevaProduct(prodId);
        FontevaProduct ausProd;
        FontevaProduct canProd;
        FontevaProduct euroProd;
        


        String namePart = 'Professional Membership';
        String currencyPart = 'USD';
        
        // Test only these currencies.
        String usdIso = 'USD';
        String ausIso = 'AUD';
        String cadIso = 'CAD';
        String eurIso = 'EUR';
        
        String fullName = String.join(new String[]{namePart,currencyPart},' - ');
        
        // Parsing the product name
        //   For membership products the type and currency are separated by a -.
        System.assertEquals(fullName, usProd.getName());
         
        
        
        canProd = usProd.getAsCurrency(cadIso);
        // ausProd = canProd.getAsCurrency(ausIso);
        euroProd = canProd.getAsCurrency(eurIso);
        System.debug('New currency is: '+euroProd.getCurrencyIsoCode());
        System.debug('New price is: '+euroProd.getPrice());
    } 
    
    

    
    @isTest(SeeAllData=True)
    private static void loadChapters(){
		System.debug('LOAD CHAPTERS TEST STARTED');
        
        // In the org there should be a fair number of chapters:
        Integer MINIMUM_COUNT_CHAPTERS = 50;
        
        // Perform a query to fetch the chapters.
        IProductQuery query;

        // Store em.
		List<IProductBase> chapters;
        


		
        // Make sure wrapper class returns correct data.
        Contact c = new Contact(FirstName = 'Jose',LastName = 'Bernal',Email='jbernal.web.dev@gmail.com');
        c.MailingCity = 'Portland';
        c.MailingState = 'Oregon';
        c.MailingPostalCode = '97211';
        c.MailingStreet = '4950 NE 7 AVE APT 205';
        c.MailingCountry = 'United States';
        c.MailingLatitude = 45.558834;
        c.MailingLongitude = -122.658225;
        
        insert c;
        
        
        query = ProductQuery.newInstance('Chapter','Fonteva');
        chapters = query.execute();

        System.assert(chapters != null,'In this Org: Chapter query should not return null.');
        System.assert(chapters.size() > MINIMUM_COUNT_CHAPTERS,'There should be over '+MINIMUM_COUNT_CHAPTERS+' chapters.  Found: '+chapters.size());
        System.debug(chapters);
         
        
         
        // Also query directly - should probably also be run with SeeAllData=False
        FontevaChapterProductQuery chpts = new FontevaChapterProductQuery();
        chpts.start(c.MailingLatitude, c.MailingLongitude);
        chpts.radius(50,'km');
        // chpts.country('United States');
        
        // chpts.reset();
        // query.filter

		List<IProductBase> unfiltered = chpts.execute();
        List<IProductBase> results = chpts.getProducts();
        
        System.assert(unfiltered.size() != results.size());
        System.debug('Number of chapters: '+results.size());
        System.debug(results[0]);
		System.debug('LOAD CHAPTERS TEST ENDED');
    } 
    
 
    @isTest(SeeAllData=True)
    private static void makeOrder(){
		System.debug('MAKE ORDER TEST STARTED');

        
        
        // for Jose Bernal Contact.
        Id theId = '0032900000TLt7tAAD';
		
        // Make sure wrapper class returns correct data.
        Member m = new Member(theId);
        OrderApi__Business_Group__c theGroup = m.getBusinessGroup();
        
        
        // Confirm existence of business group for USD; 
        //  assumes that there might only be one, but what if there are two?
        System.assert(null != theGroup);
        
        
        FontevaOrder fon = new FontevaOrder();
        fon.setContactId(theId);
        fon.setCurrencyIsoCode(m.getCurrencyIsoCode());
        fon.setBusinessGroupId(theGroup.Id);
        
        // Set other variables, if necessary.
        // fon.setStore();
        // fon.setSite();

        
        // Setup an item for the cart.
        Id prodId = 'a13290000018aG2AAI';
        FontevaProduct usdMembership = new FontevaProduct(prodId);

        // Should be able to add Product to order.
        fon.addProduct(usdMembership);
        
		// Test for common save errors (missing currency, contact, business group, etc.)
     	fon.save(); 
        
        System.assert(1 == fon.countItems);
        
		System.debug('MAKE ORDER TEST ENDED');
    }
    
    
}