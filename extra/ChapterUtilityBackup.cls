public class ChapterUtility{
   
    
    // method returns ITEMS withing 50 miles, filter items having shapter code starts with '25' if selected item is=> Professional Membership,Student Transition
    public static list<ChapterItem> getChapterItems(contact con, string itmName, string currencyCode){
        List<ChapterItem> chapterItems = new List<ChapterItem>();
        Location contactLocation = Location.newInstance(con.MailingLatitude,con.MailingLongitude);
        boolean excludeChapter25 = Label.ChapterCode25.contains(itmName)?TRUE:FALSE;
        system.debug('Item name = ' + itmName);
        double distanceLimit = 0;
        try{
                distanceLimit = decimal.valueOf(Label.ContactChapterDistance);
        }catch(exception ex){
                distanceLimit = 80.0;
        }
        
        Set<String> chapterNames = new Set<String>(System.Label.Chapters.split(','));
        for(OrderApi__Item__c itm : [Select Id, Name, OrderApi__Display_Name__c, Chapter_Location__longitude__s, 
                                     Chapter_Location__latitude__s, Chapter_Code__c From OrderApi__Item__c 
                                     Where OrderApi__Item_Class__r.Name =:chapterNames  //'Chapters' 
                                           AND OrderApi__Is_Active__c = TRUE    
                                           AND Chapter_Location__longitude__s!=NULL 
                                           AND Chapter_Location__latitude__s!=NULL
                                           AND CurrencyISOCode =:currencyCode 
                                           AND ID Not IN (
                                            Select OrderApi__Item__c From OrderApi__Subscription__c  Where OrderApi__Contact__c=:con.Id
                                           )]){
            Location itemLocation = Location.newInstance(itm.Chapter_Location__latitude__s, itm.Chapter_Location__longitude__s);
            decimal dist = Location.getDistance(contactLocation, itemLocation, 'km');
            system.debug('CHapter distance = ' + dist + ' CHapter name = ' + itm.name + ' Chapter code = '+ itm.Chapter_Code__c );
            If(itm.Chapter_Code__c!=NULL  && excludeChapter25 && itm.Chapter_Code__c.startsWith('25')){ 
                continue;
            }
            
            if(dist<=distanceLimit || test.isRunningTest()){
                ChapterItem CI = new ChapterItem(itm,  dist);
                chapterItems.add(CI);
           }   
        }
        system.debug('chapter Items Size = ' + chapterItems.size());
        chapterItems.sort();
        return chapterItems;
    }
    
    // method returns member at large chapter items
    public static list<ChapterItem> getMLChapterItems(contact con, string currencyCode, string region, string itmName){
        List<ChapterItem> chapterItems = new List<ChapterItem>();
        boolean excludeChapter25 = Label.ChapterCode25.contains(itmName)?TRUE:FALSE;
        
        Location contactLocation = Location.newInstance(con.MailingLatitude,con.MailingLongitude);
        List<ChapterItem>MALItems = new List<ChapterItem>();
        Set<String> chapterNames = new Set<String>(System.Label.Chapters.split(','));
        
        for(OrderApi__Item__c itm : [Select Id, Name, OrderApi__Display_Name__c, Chapter_Location__longitude__s, 
                                     Chapter_Location__latitude__s, Chapter_Code__c From OrderApi__Item__c 
                                     Where OrderApi__Is_Active__c = TRUE 
                                           AND OrderApi__Item_Class__r.Name =:chapterNames //'Chapters'
                                           AND Chapter_Region__c =:region
                                           AND CurrencyISOCode =:currencyCode AND ID Not IN (
                                            Select OrderApi__Item__c From OrderApi__Subscription__c  Where OrderApi__Contact__c=:con.Id
                                           )
                                           order by OrderApi__Display_Name__c]){
                If(itm.Chapter_Code__c!=NULL  && excludeChapter25 && itm.Chapter_Code__c.startsWith('25')){ 
                    continue;
                }                          
                If(itm.Chapter_Code__c!=NULL  && itm.Chapter_Code__c.endsWith('750')){
                    ChapterItem CI = new ChapterItem(itm,  0);
                    MALItems.add(CI);
                }else{
                    Location itemLocation = Location.newInstance(itm.Chapter_Location__latitude__s, itm.Chapter_Location__longitude__s);
                    decimal dist = Location.getDistance(contactLocation, itemLocation, 'km');
                    if(dist==NULL){
                        dist = 0;
                    }
                    system.debug('Distance in decimal ' + dist);
                    ChapterItem CI = new ChapterItem(itm,  dist);
                    chapterItems.add(CI);
                }
        }
        chapterItems.sort();
        chapterItems.addAll(MALItems);
        return chapterItems;
    }
    
      // wrapper class to support dynamic distance sorting
    public class ChapterItem implements Comparable {

        public OrderApi__Item__c item {get;set;}
        public boolean isSelect {get;set;}
        public decimal itmDistance {get;set;}
        public boolean isStudentChapter {get;set;}
        
        public ChapterItem(OrderApi__Item__c chapterItm, decimal myDistance, boolean myselect, boolean StudentChapter){
            item = chapterItm;
            isSelect = myselect;
            isStudentChapter = StudentChapter;
            itmDistance =  myDistance.setScale(2);
        }
        
        public ChapterItem(OrderApi__Item__c chapterItm, decimal myDistance, boolean myselect){
            item = chapterItm;
            isSelect = myselect;
            isStudentChapter = FALSE;
            itmDistance =  myDistance.setScale(2);
        }
        
        public ChapterItem(OrderApi__Item__c chapterItm, decimal myDistance)
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
    
    // return a SalesOrder 
    public static OrderApi__Sales_Order__c createSalesOrder( OrderApi__Subscription__c Sub){
        OrderApi__Sales_Order__c newSO = new OrderApi__Sales_Order__c();
        newSO.OrderApi__Contact__c = Sub.OrderApi__Contact__c;
        newSO.OrderApi__Account__c = Sub.OrderApi__Account__c;
        newSO.OrderApi__Business_Group__c = Sub.OrderApi__Business_Group__c;
        newSO.OrderApi__Entity__c = Sub.OrderApi__Entity__c;
        
        return newSO;
    }
    // return a list of SalesOrderLine 
    public static OrderApi__Sales_Order_Line__c createSalesOrderLine(id SalesOrderId, id ItemId, Id contactId, date Activationdate, id PlanId){
        OrderApi__Sales_Order_Line__c newSOL = new OrderApi__Sales_Order_Line__c();
        newSOL.OrderApi__Sales_Order__c = SalesOrderId;
        newSOL.OrderApi__Item__c = ItemId;
        newSOL.OrderApi__Quantity__c = 1;
        newSOL.OrderApi__Entity__c = 'Contact';
        newSOL.OrderApi__Contact__c = contactId;
        If(Activationdate!=NULL){
            newSOL.OrderApi__Activation_Date__c = Activationdate;
            newSOL.OrderApi__Auto_Calculate_Activation_Date__c = FALSE;
        }
        if(PlanId!=NULL){
            newSOL.OrderApi__Subscription_Plan__c = PlanId;
        }
        return newSOL;
    }
    
    // renewal Sales Order Line
    public static OrderApi__Sales_Order_Line__c createRenewalSalesOrderLine(id SalesOrderId, id ItemId, Id contactId, OrderApi__Subscription__c Sub){
        OrderApi__Sales_Order_Line__c newSOL = new OrderApi__Sales_Order_Line__c();
        newSOL.OrderApi__Sales_Order__c = SalesOrderId;
        newSOL.OrderApi__Is_Renewal__c = TRUE;
        newSOL.OrderApi__Item__c = ItemId;
        newSOL.OrderApi__Subscription__c = Sub.Id;
        newSOL.OrderApi__Business_Group__c = Sub.OrderApi__Business_Group__c;
        newSOL.OrderApi__Entity__c = Sub.OrderApi__Entity__c;
        newSOL.OrderApi__Enable_Auto_Renew__c = Sub.OrderApi__Enable_Auto_Renew__c;
       
        return newSOL;
    }
    
    public static list<ChapterItem> existingSubscriptions(contact myContact){
        List<ChapterItem> existingChapters = new List<ChapterItem>();
        
      
           Set<String> chapterNames = new Set<String>(System.Label.Chapters.split(','));
           for(OrderApi__Item__c itm : [Select Id, Name, OrderApi__Display_Name__c, Chapter_Location__longitude__s, 
                                        Chapter_Location__latitude__s, Chapter_Code__c,OrderApi__Item_Class__r.Name 
                                        From OrderApi__Item__c
                                        Where Id in ( Select OrderApi__Item__c From OrderApi__Subscription__c 
                                                       Where OrderApi__Contact__c=:myContact.Id 
                                                             //AND OrderApi__Is_Active__c = TRUE
                                                    )
                                        ]){
                If(itm.OrderApi__Display_Name__c==System.Label.Professional_Membership
                    ||itm.OrderApi__Display_Name__c==System.Label.Student_Membership
                    || itm.OrderApi__Display_Name__c==System.Label.Student_Transition
                    || chapterNames.contains(itm.OrderApi__Item_Class__r.Name) //=='Chapters'
                    || itm.OrderApi__Display_Name__c==System.Label.Fellow_Membership
                    || itm.OrderApi__Display_Name__c==System.Label.Retired_Membership
                    || itm.OrderApi__Display_Name__c==System.Label.Lifetime_Fellow_Membership
                    || itm.OrderApi__Display_Name__c==System.Label.x500_Club_Membership){
                    
                       Boolean isChapterStudent  = ((itm.Chapter_Code__c !=NULL && itm.Chapter_Code__c.startsWith('25'))?TRUE:FALSE);
                       ChapterItem CI1 = new ChapterItem(itm,  0, true, isChapterStudent);
                       existingChapters.add(CI1);
                }
            } 
            
          return existingChapters;  
    }
    
    // renewal Sales Order Line
    public static List<OrderApi__Item__c> getItems(string itemname, string currencyCode){
           
           
          List<OrderApi__Item__c> items = [Select id from OrderApi__Item__c 
                                           Where  OrderApi__Is_Active__c = TRUE
                                                   AND OrderApi__Display_Name__c =:itemname 
                                                   AND CurrencyISOCode=:currencyCode Limit 1];
                                                   
         return items;  
    }
    
}