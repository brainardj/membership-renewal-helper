/**
 *  @class IABCSetMemberType
 * 
 *  @description A class to query and update the Contact.Member_Type__c field.
 */
public class IABCSetMemberType implements ISObjectWorker {


    // Name of static resource 
    public static final String TAB_STATIC_RESOURCE_NAME = 'IABCDuplicates';
    
    
    public static String theQuery = 'SELECT Id, Member_ID__c, Member_Type__c, CurrencyIsoCode, Company__c, MailingState '
        +' FROM Contact WHERE (MailingState = NULL AND Company__c = NULL) AND Member_ID__c = :dupIds';
    

    
	public Database.QueryLocator getRecords() {
		String contents = DuplicateContactInfo.loadStaticResourceAsString(TAB_STATIC_RESOURCE_NAME);
		String[] dupIds = contents.split('\n');
        
		return Database.getQueryLocator(theQuery);
	}


	public Contact doUpdate(Contact c) {
		c.IabcHasSubscription__c = true;
        return c;
	}
	
	
	
	public void execute(List<Contact> scope) {
		for(Contact c :scope){
			// c.put('IabcFlagDup__c',True);
			this.doUpdate(c);
		}
			
		update scope;
	}
    
    public void test(List<Contact> scope) {
        for(Contact c :scope){
            c.put('test some field','foobar');
        }
    }
	
    
    public static String loadStaticResourceAsString(String srn){
	    StaticResource src = [SELECT Id, Body FROM StaticResource WHERE Name = :srn LIMIT 1];
        
        return src.Body.toString();
    }
   
}