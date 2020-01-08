global class ChapterController extends PagesApi.DefaultTemplateController{

    
    global Contact UserContactData {get; set;}
    
    
    public List<ChapterUtility.ChapterItem> AllChapterItems{get; set;}
    
    
    public List<ChapterUtility.ChapterItem> existingChapterItems{get; set;}
    
    
    public Boolean hasError{ get; set; }
    
    
    public String salesorder;
    
    
    public Boolean isRenewal{ get; set; }
    
    
    public Boolean showLatLon{ get; set; }
    
    
    private OrderApi__Subscription__c subs;
    
    
    private String itemName;
    
    
    private String selectedItemName;
    
    
    private String selectedPlan;
    
    
    private String renewalSO;
    
    
    // based on this student chapter will be dsiabled or enabled
    // public boolean isChapterDisabled{ get; set; } 
    
    
    public Boolean initialised {get;set;}
    
    // Constructor
    public ChapterController(){
    	Framework.Log.push(ChapterController.class.getName(),'ChapterController');

			initialised = FALSE;
			
			this.UserContactData = getCurrentContact();
			AllChapterItems = new List<ChapterUtility.ChapterItem>();
			existingChapterItems = new List<ChapterUtility.ChapterItem>();
			Set<String> chapterNames = new Set<String>(System.Label.Chapters.split(','));
			
			selectedPlan = null;
			
			Boolean isStudentMembershipChange = false; // to keep track whether student membership is being renewed to transition or student membership
			
			isRenewal = false;
			showLatLon = false;
			//isChapterDisabled = false;
			
			// check if context is renewal or new joining
			List<ChapterUtility.ChapterItem> existingSubItems = ChapterUtility.existingSubscriptions(UserContactData);
			
			Set<Id> itemId = new Set<Id>();
			
			if(!existingSubItems.isEmpty())
			{
				system.debug(' inside renewal flow ');
				isRenewal = true;
					 
				for(ChapterUtility.ChapterItem existingSubs: existingSubItems){
						if(chapterNames.contains(existingSubs.Item.OrderApi__Item_Class__r.Name)){
								existingChapterItems.add(existingSubs);
						} else {
								if(existingSubs.item.OrderApi__Display_Name__c==System.Label.Professional_Membership
										|| existingSubs.item.OrderApi__Display_Name__c==System.Label.Student_Membership
										|| existingSubs.item.OrderApi__Display_Name__c==System.Label.Student_Transition
										|| existingSubs.item.OrderApi__Display_Name__c==System.Label.Fellow_Membership
										|| existingSubs.item.OrderApi__Display_Name__c==System.Label.Retired_Membership
										|| existingSubs.item.OrderApi__Display_Name__c==System.Label.Lifetime_Fellow_Membership
										|| existingSubs.item.OrderApi__Display_Name__c==System.Label.x500_Club_Membership){ // assumtion is that contact will have only one among these 4
										id itm = existingSubs.item.id;
										itemId.add(itm);
								}
						}
				}
				
				subs = [SELECT Id, OrderApi__Item__c, OrderApi__Contact__c, OrderApi__Account__c, 	
					OrderApi__Business_Group__c, OrderApi__Entity__c, 
					OrderApi__Item__r.OrderApi__Display_Name__c, OrderApi__Enable_Auto_Renew__c, OrderApi__Current_Term_End_Date__c
						FROM OrderApi__Subscription__c 
						WHERE OrderApi__Contact__c=:UserContactData.Id 
						//AND OrderApi__Is_Active__c = TRUE 
						AND OrderApi__Item__c = :itemId
						LIMIT 1];
										 
				String existingName = subs.OrderApi__Item__r.OrderApi__Display_Name__c;
				
				System.Debug('Existing Item = ' + existingName);
				
				// based on current item, decide renewal item
				if(existingName==System.Label.Professional_Membership || existingName==System.Label.Student_Transition)
				{
						itemName = System.Label.Professional_Membership;
				}
				// Student membership can be renewed to transition or student membership based on user selection on join process
				else if(existingName==System.Label.Student_Membership)
				{ 
					itemName = 
						(UserContactData.Renewal_Membership_Type__c != null ? UserContactData.Renewal_Membership_Type__c : System.Label.Student_Membership);
				
					isStudentMembershipChange = UserContactData.Renewal_Membership_Type__c == System.Label.Student_Transition;
				}
				else if(existingName==System.Label.Fellow_Membership)
				{
					itemName = System.Label.Fellow_Membership;
				}
				else if(existingName==System.Label.Retired_Membership)
				{
					itemName = System.Label.Retired_Membership;
				}
				else if(existingName==System.Label.Lifetime_Fellow_Membership)
				{
					itemName = System.Label.Lifetime_Fellow_Membership;
				}
				else if(existingName==System.Label.x500_Club_Membership)
				{
					itemName = System.Label.x500_Club_Membership;
				}
				
				// If membership is being changed to transition && chapter is Student chapter, disable the checkbox on ITEM
				for(ChapterUtility.ChapterItem existingChapter: existingChapterItems){
					if(existingChapter.isStudentChapter  && isStudentMembershipChange){ 
						existingChapter.isSelect = false;
					}
				}
				
				
				System.Debug('Renewal Item = ' + itemName);
				// selectedItemName = existingName; commented on March,8th since during renewal we need to use new renewal item
				selectedItemName = itemName;
				// existing subscription ends(renewal)  
			}
			else
			{
				// new 
				System.Debug('Inside new member flow.');
			
				salesorder = Framework.PageUtils.getParam('salesorder');
			
				OrderApi__Sales_Order_Line__c[] SO = [SELECT Id, 
					OrderApi__Item__r.Name,OrderApi__Item__r.OrderApi__Display_Name__c,
					OrderApi__Subscription_Plan__c , OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c 
						FROM OrderApi__Sales_Order_Line__c
						WHERE OrderApi__Sales_Order__c = :salesorder];
			
				selectedItemName = '';
			
				// item code
				if(SO.size()>0){
					selectedItemName = SO[0].OrderApi__Item__r.OrderApi__Display_Name__c;
				
					if(selectedItemName == System.Label.Professional_Membership && SO[0].OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c){ // for professional item, set same plan on chapter 
						selectedPlan = SO[0].OrderApi__Subscription_Plan__c;
					}
				}
				// ends here
			}

            
			String userCurrencyISOCode = 'USD';
			
			if(this.UserContactData.CurrencyISOCode!=NULL){
				userCurrencyISOCode = this.UserContactData.CurrencyISOCode;
			}
			
			// get chapter items <50 mile
			AllChapterItems = ChapterUtility.getChapterItems(this.UserContactData,selectedItemName,userCurrencyISOCode);

			// get ML chapters
			// if(AllChapterItems.isEmpty()){

			if(AllChapterItems.isEmpty() && existingChapterItems.isEmpty()){
					if(this.UserContactData.region__c!=NULL){
							AllChapterItems = ChapterUtility.getMLChapterItems(this.UserContactData
								 ,userCurrencyISOCode, this.UserContactData.region__c, selectedItemName);
					}
			}
      
      Framework.Log.pop();
    }
    
    
    // Method being called on Next button click
    public pagereference Next(){
        Framework.Log.push(ChapterController.class.getName(),'Next');
        hasError = FALSE;
        integer itemCounter = 0;
        id itemId = null;
        OrderApi__Subscription__c existingChapterSub = NULL;
        OrderApi__Sales_Order_Line__c newSOL;
        
        
        
        if(isRenewal){
            // get existing chapters and see user has selected it or not, in case of selection need ot create renewal SOL  
            for(ChapterUtility.ChapterItem currentChapter : existingChapterItems){
                if(currentChapter.isSelect){
                    itemCounter+=1;
                    itemId = currentChapter.item.Id;
                }
            }
            // get existing chapter subscriptions
            if(itemId!=NULL){
                existingChapterSub = [Select Id, OrderApi__Item__c, OrderApi__Contact__c, OrderApi__Account__c, OrderApi__Business_Group__c, OrderApi__Entity__c 
                                      , OrderApi__Item__r.OrderApi__Display_Name__c, OrderApi__Enable_Auto_Renew__c
                                      From OrderApi__Subscription__c 
                                      Where OrderApi__Contact__c=:UserContactData.Id 
                                          // AND OrderApi__Is_Active__c = TRUE 
                                           AND OrderApi__Item__c=:itemId Limit 1] ;
            }                          
        }
        for(ChapterUtility.ChapterItem CI : AllChapterItems){
            if(CI.isSelect){
                itemCounter+=1;
                itemId = CI.item.Id;
            }
        }
        If(itemCounter>=2 || itemCounter==0){
            Framework.Message.addMessage('Please select only one item', Framework.Message.Severity.Warning);
            hasError = true;
            return null;
        }
       
       
        
       
       if(!isRenewal){// for new member
       
            if(selectedPlan!=NULL){
                OrderApi__Item_Subscription_Plan__c[] itemPlan = [Select Id From OrderApi__Item_Subscription_Plan__c 
                                                                    Where OrderApi__Item__c =: itemId 
                                                                          AND OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c= TRUE
                                                                          AND OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c= TRUE]; // if installment plan found
                If(itemPlan.size()==0){
                    selectedPlan = NULL;    
                }
            }
            
            newSOL = ChapterUtility.createSalesOrderLine(salesorder, itemId, UserContactData.Id, NULL, selectedPlan); // create SOL for selected ITEMS
            Insert newSOL;
       }else{
           system.debug('subs data = ' + subs.Id);
           OrderApi__Sales_Order__c SO = ChapterUtility.createSalesOrder(subs);
           insert SO;
           renewalSO = SO.Id;
           list<OrderApi__Item__c> individualItems = ChapterUtility.getItems(itemName, UserContactData.CurrencyISOCode);
           list<OrderApi__Sales_Order_Line__c> newSOLs = new list<OrderApi__Sales_Order_Line__c>();
           if(!individualItems.isEmpty()){
                id individualItemId = individualItems.get(0).Id;  
                OrderApi__Sales_Order_Line__c  renSOl = ChapterUtility.createRenewalSalesOrderLine(renewalSO, individualItemId , UserContactData.Id, subs); 
                newSOLs.add(renSOl);
                
               // OrderApi__Sales_Order_Line__c renActivationdate = [Select Id, OrderApi__Activation_Date__c From OrderApi__Sales_Order_Line__c Where Id=:renSOl.Id Limit 1];
                
               // date activationDate = renActivationdate.OrderApi__Activation_Date__c;
                
                If(existingChapterSub!=NULL){
                    newSOL = ChapterUtility.createRenewalSalesOrderLine(renewalSO, itemId, UserContactData.Id, existingChapterSub); // create remewal SOL for existing subscriptions
                    newSOLs.add(newSOL);
                }else{
                    //date activationDate = subs.OrderApi__Current_Term_End_Date__c.addDays(1); 
                    date activationDate = date.today(); 
                    newSOL =  ChapterUtility.createSalesOrderLine(renewalSO, itemId, UserContactData.Id, activationDate, NULL); // create SOL for new  chapter ITEMS
                    newSOLs.add(newSOL);
                }
                
                insert newSOLs;
           }
           //insert newSOLs;
       } 
        
        
       
       Framework.Log.pop(); 
       return nextStep(); 
      // return null;
      
    }
    
    // Join process methods
    public PageReference nextStep() {
        
            //save contact address
            try{
                String stepId = Framework.PageUtils.getParam('id');
                joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
                String redirectURL = joinUtil.navStepsMap.get('Next');
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('stepId', stepId);
                //system.debug('===UserContact '+UserContact);
                //add URL param to manage is it a new join process or renewal process
                PageReference pgRef = new PageReference(redirectURL);
                system.debug('renewal SO = ' + renewalSO);
                if( String.isNotBlank( renewalSO ) &&  isRenewal) {
                    pgRef.getParameters().put( 'salesorder', renewalSO );
                }

                gen.writeStringField('redirectURL', redirectURL);
                gen.writeEndObject();

                /*if(gen.getAsString()!=null)
                    joinUtil.setRedirectURLCookie(gen.getAsString());*/           
                    return pgRef;
                    //return null;
            }catch(Exception e){
                    system.debug('===exception'+e.getLineNumber()+e.getStackTraceString());
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                     return null;

            }
    
    }
    
    
    public PageReference previousStep() {
			String stepId = Framework.PageUtils.getParam('id');
			joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
			//if(!Test.isRunningTest())
					return new PageReference(joinUtil.navStepsMap.get('Previous'));

			//return null;
    }


    public PageReference cancelStep() {
			String stepId = Framework.PageUtils.getParam('id');
			joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);        
			joinUtil.deleteCookies();
			return new PageReference(joinUtil.navStepsMap.get('First'));
    }

    
    public void initSOL(){
       // Framework.Log.push(ChapterController.class.getName(),'init');
            string salesorder = Framework.PageUtils.getParam('salesorder');
            
            if(string.isBlank(salesorder)){
                initialised=true;
                return;
            }
            
            OrderApi__Sales_Order__c SOUpdate = [Select id From OrderApi__Sales_Order__c Where Id=:salesorder ]; 
            SOUpdate.OrderApi__Status__c = 'Open' ;
            update SOUpdate;
            
            Delete [Select Id From OrderApi__Invoice__c Where OrderApi__Sales_Order__c=:salesorder];
            initialised=true;
       // Framework.Log.pop();
    }
    
    
}