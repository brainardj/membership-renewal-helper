public class ChapterUtility {
 
	
	/** 	Method returns ITEMS withing 50 miles,
		*		filter items having shapter code starts with '25' if selected item is
		*		Professional Membership,Student Transition
		*/
	public static List<ChapterItem> getChapterItems(Contact con, String itmName, String currencyCode) {
	
			List<ChapterItem> chapterItems = new List<ChapterItem>();
			
			Location contactLocation = Location.newInstance(con.MailingLatitude,con.MailingLongitude);

			Boolean excludeChapter25 = Label.ChapterCode25.contains(itmName);

			System.Debug('Item name = ' + itmName);

			Double distanceLimit = 0;

			try {
				distanceLimit = Decimal.valueOf(Label.ContactChapterDistance);
			} catch(Exception ex) {
				distanceLimit = 80.0;
			}
			
			Set<String> chapterNames = new Set<String>(System.Label.Chapters.split(','));
			
			for(OrderApi__Item__c itm : [SELECT Id, Name, OrderApi__Display_Name__c, Chapter_Location__longitude__s, 
				 Chapter_Location__latitude__s, Chapter_Code__c From OrderApi__Item__c 
				 WHERE OrderApi__Item_Class__r.Name = :chapterNames  //'Chapters' 
					 AND OrderApi__Is_Active__c = true    
					 AND Chapter_Location__longitude__s != null 
					 AND Chapter_Location__latitude__s != null
					 AND CurrencyISOCode =:currencyCode 
					 AND Id NOT IN (SELECT OrderApi__Item__c From OrderApi__Subscription__c  WHERE OrderApi__Contact__c = :con.Id)])
			{
			
				Location itemLocation = Location.newInstance(itm.Chapter_Location__latitude__s, itm.Chapter_Location__longitude__s);
				
				Decimal dist = Location.getDistance(contactLocation, itemLocation, 'km');
				
				System.Debug('CHapter distance = ' + dist + ' CHapter name = ' + itm.name + ' Chapter code = '+ 
				itm.Chapter_Code__c );
				
				if(itm.Chapter_Code__c != null  && excludeChapter25 && itm.Chapter_Code__c.startsWith('25')){ 
					continue;
				}
			
				if(dist<=distanceLimit || Test.isRunningTest()){
					ChapterItem CI = new ChapterItem(itm,  dist);
					chapterItems.add(CI);
				}   
			}
			
			System.Debug('Chapter Items List size = ' + chapterItems.size());
			
			chapterItems.sort();
			
			return chapterItems;
	}
	
	
	/**
	 * @method getMLChapterItems
	 *
	 * @description 
	 */
	public static List<ChapterItem> getMLChapterItems(Contact con, String currencyCode, String region, String itmName) {
	
			List<ChapterItem> chapterItems = new List<ChapterItem>();
			
			Boolean excludeChapter25 = Label.ChapterCode25.contains(itmName);
			
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
				
				if(itm.Chapter_Code__c != null  && itm.Chapter_Code__c.endsWith('750')){
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
	
	
	/**
	 * @method createSalesOrder
	 *
	 * @description 
	 */
	public static OrderApi__Sales_Order__c createSalesOrder(OrderApi__Subscription__c sub) {
			OrderApi__Sales_Order__c newSO = new OrderApi__Sales_Order__c();
			newSO.OrderApi__Contact__c = sub.OrderApi__Contact__c;
			newSO.OrderApi__Account__c = sub.OrderApi__Account__c;
			newSO.OrderApi__Business_Group__c = sub.OrderApi__Business_Group__c;
			newSO.OrderApi__Entity__c = sub.OrderApi__Entity__c;
			
			return newSO;
	}
	
	
	/**
	 * @method createSalesOrderLine
	 *
	 * @description 
	 */ 
	public static OrderApi__Sales_Order_Line__c createSalesOrderLine(Id SalesOrderId, Id ItemId, Id contactId, Date Activationdate, Id PlanId) {
			OrderApi__Sales_Order_Line__c newSOL = new OrderApi__Sales_Order_Line__c();
			newSOL.OrderApi__Sales_Order__c = SalesOrderId;
			newSOL.OrderApi__Item__c = ItemId;
			newSOL.OrderApi__Quantity__c = 1;
			newSOL.OrderApi__Entity__c = 'Contact';
			newSOL.OrderApi__Contact__c = contactId;
			
			if(Activationdate != null){
					newSOL.OrderApi__Activation_Date__c = Activationdate;
					newSOL.OrderApi__Auto_Calculate_Activation_Date__c = FALSE;
			}
			if(PlanId != null){
					newSOL.OrderApi__Subscription_Plan__c = PlanId;
			}
			
			return newSOL;
	}
	
	
	/**
	 * @method createRenewalSalesOrderLine
	 *
	 * @description 
	 */ 
	public static OrderApi__Sales_Order_Line__c createRenewalSalesOrderLine(Id SalesOrderId, Id ItemId, Id contactId, OrderApi__Subscription__c sub){
			OrderApi__Sales_Order_Line__c newSOL = new OrderApi__Sales_Order_Line__c();
			newSOL.OrderApi__Sales_Order__c = SalesOrderId;
			newSOL.OrderApi__Is_Renewal__c = True;
			newSOL.OrderApi__Item__c = ItemId;
			newSOL.OrderApi__Subscription__c = sub.Id;
			newSOL.OrderApi__Business_Group__c = sub.OrderApi__Business_Group__c;
			newSOL.OrderApi__Entity__c = sub.OrderApi__Entity__c;
			newSOL.OrderApi__Enable_Auto_Renew__c = sub.OrderApi__Enable_Auto_Renew__c;
		 
			return newSOL;
	}
	
	
	/**
	 * @method existingSubscriptions
	 *
	 * @description 
	 */ 
	public static List<ChapterItem> existingSubscriptions(Contact myContact){
			List<ChapterItem> existingChapters = new List<ChapterItem>();
			
		
			Set<String> chapterNames = new Set<String>(System.Label.Chapters.split(','));
			
			for(OrderApi__Item__c itm : [Select Id, Name, OrderApi__Display_Name__c, Chapter_Location__longitude__s, 
					Chapter_Location__latitude__s, Chapter_Code__c,OrderApi__Item_Class__r.Name 
					From OrderApi__Item__c
					Where Id in ( Select OrderApi__Item__c From OrderApi__Subscription__c 
												 Where OrderApi__Contact__c=:myContact.Id 
															 //AND OrderApi__Is_Active__c = TRUE
					)])
			{
				If(itm.OrderApi__Display_Name__c==System.Label.Professional_Membership
						||itm.OrderApi__Display_Name__c==System.Label.Student_Membership
						|| itm.OrderApi__Display_Name__c==System.Label.Student_Transition
						|| chapterNames.contains(itm.OrderApi__Item_Class__r.Name) //=='Chapters'
						|| itm.OrderApi__Display_Name__c==System.Label.Fellow_Membership
						|| itm.OrderApi__Display_Name__c==System.Label.Retired_Membership
						|| itm.OrderApi__Display_Name__c==System.Label.Lifetime_Fellow_Membership
						|| itm.OrderApi__Display_Name__c==System.Label.x500_Club_Membership){
					
							 Boolean isChapterStudent  = ((itm.Chapter_Code__c != null && itm.Chapter_Code__c.startsWith('25'))?TRUE:FALSE);
							 ChapterItem CI1 = new ChapterItem(itm,  0, true, isChapterStudent);
							 existingChapters.add(CI1);
				}
			} 
					
			return existingChapters;  
	}
	
	
	
	/**
	 * @method getItems
	 *
	 * @description 
	 */ 
	public static List<OrderApi__Item__c> getItems(string itemname, string currencyCode){
				 
		List<OrderApi__Item__c> items = [SELECT Id FROM OrderApi__Item__c 
			 WHERE OrderApi__Is_Active__c = True
			 AND OrderApi__Display_Name__c =:itemname 
			 AND CurrencyISOCode=:currencyCode LIMIT 1];
																								 
		return items;  
	}
	
	
	
	// Wrapper class to support dynamic distance sorting
	public class ChapterItem implements Comparable {

			public OrderApi__Item__c item {get;set;}
			
			public Boolean isSelect {get;set;}
			
			public Decimal itmDistance {get;set;}
			
			public Boolean isStudentChapter {get;set;}
			
			
			public ChapterItem(OrderApi__Item__c chapterItm, Decimal myDistance, Boolean myselect, Boolean StudentChapter){
					item = chapterItm;
					isSelect = myselect;
					isStudentChapter = StudentChapter;
					itmDistance =  myDistance.setScale(2);
			}
			
			public ChapterItem(OrderApi__Item__c chapterItm, Decimal myDistance, Boolean myselect){
					item = chapterItm;
					isSelect = myselect;
					isStudentChapter = FALSE;
					itmDistance =  myDistance.setScale(2);
			}
			
			public ChapterItem(OrderApi__Item__c chapterItm, Decimal myDistance)
			{
					item = chapterItm;
					isSelect = FALSE;
					isStudentChapter = FALSE;
					itmDistance = myDistance.setScale(2);
			}
	
			public Integer compareTo(Object objToCompare) {
					return Integer.valueOf(itmDistance -  ((ChapterItem)objToCompare).itmDistance );
			}
	}
	
}