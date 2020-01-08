@isTest
private class MemberLoadTest {

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
        theId = '003f200002rHkrsAAC';
		
        // Make sure wrapper class returns correct data.
        Member m = new Member(theId);
        m.setMemberType('Professional Membership - USD');
        m.setAddress('1040 NW 10 ','Eugene','OR','97209','United States');

        
        System.assert('Professional Membership' == m.getMembershipType());

				// Check getters
				System.assert(m.firstName == 'Jose' || m.firstName == 'José');
        System.assert(m.lastName == 'Bernal');
        
        // Fetch appropriate membership product for
        //  this member. Membership should be in USD.
        // IProductBase mProd = m.getChapter(); 
        
        
        // System.assertEquals('IABC/Oregon Columbia', mProd.getName());
        
        // System.assertNotEquals('Professional Membership - USD', mProd.getName());
        

        
        // Chapter should have a name, price, etc.
        // IProductBase chapter = m.getChapter();
        // System.debug('Chapter for '+m.firstName+':');
        // System.debug(chapter);
    }  
    
    
}