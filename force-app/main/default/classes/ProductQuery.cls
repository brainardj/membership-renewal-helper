public class ProductQuery {
    IProductQuery query;
    String queryType;
    Id contactId;
    String membershipType;
    String database;
    List<IProductBase> results;
    
    public ProductQuery(){}
    
    public void setDatabase(String databaseName){
        this.database = databaseName;
    }
    
    public String toHtml(){
        return 'an unordered list of product list items';
    }

    
    public static IProductQuery newInstance(String queryType, String dbName){
        
        String typeName;

        if(queryType == 'Chapter'){
            typeName =  dbName +'ChapterProductQuery';
        } else if(queryType == 'Membership Type'){
            typeName = dbName +'MembershipTypeProductQuery';
        } else if(queryType == 'Purchase History'){
            typeName = dbName +'PurchaseHistoryProductQuery';
        }

        System.type theType = Type.forName(typeName);
        
        IProductQuery query = (IProductQuery)theType.newInstance();

        return query;
    }
    
    private class ProductQueryException extends Exception {}
}