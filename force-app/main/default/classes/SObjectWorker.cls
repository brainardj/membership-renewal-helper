/**
 *  @class - SObjectWorker 
 * 
 *  @description - Use a list of Contact records identified, for example, by Member ID (or event Contact.Id) to flag large
 *    numbers of records.  The query and Org Triggers eat up too much CPU time and must be executed in batches.
 * 
 * 	@author - José Bernal
 * 
 * 	@created - Sept. 20, 2019
 */
global without sharing class SObjectWorker implements Database.Batchable<SObject> {


	global Boolean IS_TEST = False;
	
	
	
	// Name of the ISObjectWorkerQuery
	global String className;
	
	
	// Instance of ISObjectWorker
	global ISObjectWorker iworker;
	
	
	
	public SObjectWorker(String iworkerName){
		System.Type t = System.Type.forName(iworkerName);
		
		iworker = (ISObjectWorker)t.newInstance();
	}
	


	global Database.QueryLocator start(Database.BatchableContext bc) {

		return iworker.getRecords();
	}


	

	
	global void execute(Database.BatchableContext bc, List<SObject> scope){
		if(!IS_TEST) {
			iworker.execute(scope);
		} else {
			iworker.test(scope);
		}
	}
	

	
	
	global void finish(Database.BatchableContext bc){
			// Get the ID of the AsyncApexJob representing this batch job
			// from Database.BatchableContext.
			// Query the AsyncApexJob object to retrieve the current job's information.
			AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
												TotalJobItems, CreatedBy.Email
												FROM AsyncApexJob WHERE Id =
												:bc.getJobId()];
			
			// Send an email to the Apex job's submitter notifying of job completion.
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {a.CreatedBy.Email};
			
			mail.setToAddresses(toAddresses);
			mail.setSubject('Apex Sharing Recalculation ' + a.Status);
			mail.setPlainTextBody
					('The batch Apex job processed ' + a.TotalJobItems +
					 ' batches with '+ a.NumberOfErrors + ' failures.');
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
    
    
            
}