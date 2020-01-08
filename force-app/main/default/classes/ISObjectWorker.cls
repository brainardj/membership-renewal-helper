public interface ISObjectWorker {


    
    // Called from Batchable.start()
    Database.QueryLocator getRecords();
    
    // Called from Batchable.execute()
    void execute(List<SObject> scope);
    
    // Called from Batchable.execute() when Batchable.IS_TEST is True
    void test(List<SObject> scope);
}