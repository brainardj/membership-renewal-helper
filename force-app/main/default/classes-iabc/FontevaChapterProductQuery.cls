public class FontevaChapterProductQuery implements IProductQuery {

    private Decimal startLat;
    
    private Decimal startLng;
    
	private Boolean excludeChapter25 = True;

    private static Double range = 50.00;
    
    private String units = 'mi';
    
    private Integer radius;
    
    private List<IABCChapter> results;
    
    
    
    public FontevaChapterProductQuery(){}
    
    
    
    
    private String query = 'SELECT Id, Name, OrderApi__Display_Name__c, OrderApi__Item_Class__r.Name,OrderApi__Description__c,'+
        	'CurrencyIsoCode, OrderApi__Price__c, '+
        	'Chapter_Location__longitude__s, Chapter_Location__latitude__s, Chapter_Code__c'+
        	' FROM OrderApi__Item__c '+
        	' WHERE '+
			// ' OrderApi__Item_Class__r.Name =:chapterNames   '+
			' OrderApi__Item_Class__r.Name LIKE \'%Chapter%\'' +
			' AND OrderApi__Is_Active__c = true    '+
			' AND Chapter_Location__longitude__s != null '+
			' AND Chapter_Location__latitude__s != null ';
			//' AND CurrencyISOCode =:currencyCode '+
			//' AND Id NOT IN (SELECT OrderApi__Item__c From OrderApi__Subscription__c  WHERE OrderApi__Contact__c = :con.Id)';
    
        
	/** 	Method returns ITEMS withing 50 miles,

		*/
    public void setRange(Integer range){
    	range = range;
    }
    
    public void setParameters(Map<String,String> params){
        
    }
    
    public void addFilter(String filter){
		
    }
    

    
	/*
	 * @method filter
	 * 
	 * @description Filter items having shapter code starts with '25' if selected item is
	 * Professional Membership,Student Transition
	 */
    public void filter(String filter){
		
    }
    
    public void start(Decimal lat, Decimal lng){
   		this.startLat = lat;
        this.startLng = lng;
    }
        
        
    public void radius(Integer radius, String units){
        this.radius = radius;
        this.units = units;
    }

    
	// getChapterItems(Contact con, String itmName, String currencyCode) {
    public List<IProductBase> getProducts() {
    
        List<IABCChapter> results = this.doQuery();
        List<IABCChapter> chapters = new List<IABCChapter>();
        // Run filters here
        Location here = Location.newInstance(this.startLat,this.startLng);
        
        for(IABCChapter ch :results){
            Location there = Location.newInstance(ch.getLat(),ch.getLng());
			Decimal dist = here.getDistance(there,'mi');
            if(dist > range){
                continue;
            }
            ch.distance = dist;
            chapters.add(ch);
        }
        
        // Need to be able to sort these by distance from "here".
        chapters.sort();
        return chapters;
    }
    
    
    
    private void queryHelper(){
			List<IABCChapter> chapterItems = new List<IABCChapter>();
			
			// Location contactLocation = Location.newInstance(con.MailingLatitude,con.MailingLongitude);

			// Boolean excludeChapter25 = Label.ChapterCode25.contains(itmName);


			Double distanceLimit = 0;


				// distanceLimit = Decimal.valueOf(Label.ContactChapterDistance);

				distanceLimit = 80.0;
			
			// Set<String> chapterNames = new Set<String>(System.Label.Chapters.split(','));
			

			
			System.Debug('Chapter Items List size = ' + chapterItems.size());
			

			
//			return chapterItems;
        
        
        // this.results = this.getChapters();
        this.results.sort();
    }

    
    public List<IABCChapter> doQuery(){
        
			List<IABCChapter> chapterItems = new List<IABCChapter>();

	        for(OrderApi__Item__c itm : Database.query(query))
			{
				

				// Decimal dist = Location.getDistance(contactLocation, itemLocation, 'km');
				
				// System.Debug('CHapter distance = ' + dist + ' CHapter name = ' + itm.name + ' Chapter code = '+ itm.Chapter_Code__c );
				
				if(itm.Chapter_Code__c != null  && excludeChapter25 && itm.Chapter_Code__c.startsWith('25')){ 
					continue;
				}
			
                if(true){//dist <= distanceLimit || Test.isRunningTest()){
					IABCChapter chpt = new IABCChapter(itm);//,  dist);
					chapterItems.add(chpt);
				}   
			}
        
        return chapterItems;
    }
    
    
    public List<IABCChapter> execute(){
        
        return doQuery();
    }
    
	/**
	 * @method getMLChapterItems
	 *
	 * @description 

	public static List<ChapterItem> getMLChapterItems(Contact con, String currencyCode, String region, String itmName) {
	
			List<ChapterItem> chapterItems = new List<ChapterItem>();
			
			Boolean excludeChapter25 = True;//Label.ChapterCode25.contains(itmName); // @jbernal
			
			Location contactLocation = Location.newInstance(con.MailingLatitude,con.MailingLongitude);
			
			List<ChapterItem>MALItems = new List<ChapterItem>();
			
			Set<String> chapterNames = new Set<String>(System.Label.Chapters.split(','));
			
			for(OrderApi__Item__c itm : [SELECT Id, Name, OrderApi__Display_Name__c, Chapter_Location__longitude__s, 
				 Chapter_Location__latitude__s, Chapter_Code__c From OrderApi__Item__c 
				 WHERE OrderApi__Is_Active__c = true 
					 AND OrderApi__Item_Class__r.Name =:chapterNames //'Chapters'
					 AND Chapter_Region__c =:region 
					 AND CurrencyISOCode =:currencyCode AND ID Not IN (SELECT OrderApi__Item__c From OrderApi__Subscription__c  WHERE OrderApi__Contact__c=:con.Id)
					 ORDER BY OrderApi__Display_Name__c])
		  {
		  
				if(itm.Chapter_Code__c != null  && excludeChapter25 && itm.Chapter_Code__c.startsWith('25')){ 
					continue;
				}                          
				
				if(itm.Chapter_Code__c!=NULL  && itm.Chapter_Code__c.endsWith('750')){
					ChapterItem CI = new ChapterItem(itm,  0);
					MALItems.add(CI);
				} else {
					Location itemLocation = Location.newInstance(itm.Chapter_Location__latitude__s, itm.Chapter_Location__longitude__s);
				
					decimal dist = Location.getDistance(contactLocation, itemLocation, 'km');
				
					if(dist == null){
							dist = 0;
					}
				
					System.Debug('Distance in decimal ' + dist);
				
					ChapterItem CI = new ChapterItem(itm,  dist);
				
					chapterItems.add(CI);
				}
			}
			
			chapterItems.sort();
			chapterItems.addAll(MALItems);
			
			return chapterItems;
	}
    */
    
}